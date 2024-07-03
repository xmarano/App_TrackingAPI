//
//  ContentView.swift
//  TrackingAPI
//
//  Created by Léo Grégori on 03/07/2024.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @StateObject private var viewModel = TrackingFunc()
    @State var region = MKCoordinateRegion(
        center: .init(latitude: 37.334606, longitude: -122.009102),
        span: .init(latitudeDelta: 0.2, longitudeDelta: 0.2)
    )
    @State var trackingNumber: String = ""
    @State var carrierCode: String = ""
    let securityKey = "APIKey"
        
    var body: some View {
        VStack {
                TextField("Tracking Number", text: $trackingNumber)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(.bar, in: RoundedRectangle(cornerRadius: 10))
                
                TextField("Carrier Code", text: $carrierCode)
                    .padding(.horizontal, 15)
                    .padding(.vertical, 12)
                    .background(.bar, in: RoundedRectangle(cornerRadius: 10))
                
                Button(action: {
                    viewModel.trackPackage(
                        trackingNumber: trackingNumber,
                        carrierCode: carrierCode,
                        securityKey: securityKey)
                }) {
                    Text("Track Package")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                
            Map(coordinateRegion: $region)
                .frame(height: 250)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                if let trackingResult = viewModel.trackingResult {
                    // tracking info
                }
            }
            .padding()
        }
}

class TrackingFunc: ObservableObject {
    @Published var trackingResult: TrackingResult?
    
    func trackPackage(trackingNumber: String, carrierCode: String, securityKey: String) {
        let url = URL(string: "https://api.17track.net/track/v2.2/interfaceName")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(securityKey, forHTTPHeaderField: "17token")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody = [
            ["number": trackingNumber, "carrier": carrierCode]
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            request.httpBody = jsonData
        } catch {
            print("Failed to serialize JSON: \(error.localizedDescription)")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data")
                return
            }
            
            do {
                let result = try JSONDecoder().decode(TrackingResult.self, from: data)
                DispatchQueue.main.async {
                    self.trackingResult = result
                }
            } catch {
                print("Failed to decode JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }
}

struct TrackingResult: Codable {
    // json response api
}


#Preview {
    ContentView()
}
