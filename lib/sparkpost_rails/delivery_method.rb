module SparkpostRails
  class DeliveryMethod
    include HTTParty
    base_uri "https://api.sparkpost.com/api/v1"

    attr_accessor :settings, :response

    def initialize(options = {})
      @settings = options
    end

    def deliver!(mail)
      data = {
        :options => {
          :open_tracking => SparkpostRails.configuration.track_opens,
          :click_tracking => SparkpostRails.configuration.track_clicks
        },
        :campaign_id => SparkpostRails.configuration.campaign_id,
        :return_path => SparkpostRails.configuration.return_path,
        :recipients => [
          {
            :address => {
              :name   => mail[:to].display_names.first,
              :email  => mail.to.first
            }
          }
        ],
        :content => {
          :from => {
            :name   => mail[:from].display_names.first,
            :email  => mail.from.first
          },
          :subject  => mail.subject
          # :reply_to => mail.reply_to.first
        }
      }
      if mail.multipart?
        data[:content][:html] = mail.html_part.body.to_s
        data[:content][:text] = mail.text_part.body.to_s
      else
        data[:content][:text] = mail.body.to_s
      end
      headers = {
        "Authorization" => SparkpostRails.configuration.api_key,
        "Content-Type"  => "application/json"
      }
      r = self.class.post('/transmissions', { headers: headers, body: data.to_json })
      @response = r.body
    end
  end
end
