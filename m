From: Toby Gray <toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH 2/5] usb: cdc-ncm: Set altsetting only when network interface
 is opened
Date: Fri, 17 Feb 2012 10:31:14 +0000
Message-ID: <4F3E2C72.8000207@realvnc.com>
References: <1329317261-3406-1-git-send-email-toby.gray@realvnc.com>	<1329317261-3406-3-git-send-email-toby.gray@realvnc.com> <CAL_Kpj01s=jCr5wkyaLanFUGFO4bsUcgHt+vP9W9mKAPA4Sh5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Toby Gray <tg-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>, Oliver Neukum <oliver-Q6YOFhsQ4GZ7tPAFqOLdPg@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexey Orishko <alexey.orishko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL_Kpj01s=jCr5wkyaLanFUGFO4bsUcgHt+vP9W9mKAPA4Sh5Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 17/02/12 09:57, Alexey Orishko wrote:
> On Wed, Feb 15, 2012 at 3:47 PM, Toby Gray<toby.gray-BiNz9QiKYoNBDgjK7y7TUQ@public.gmane.org>  wrote:
>
>> Some NCM devices fail to send the NetworkConnection status if the host
>> is not trying to read from the control interrupt endpoint in the first
>> few seconds after the data interface alternate setting is selected.
> I have a feeling that the problem description above is not correct:
> more likely the fault is related to device initialization or other
> state machine problem in device.

I think I've been explaining my understanding badly and we actually 
agree :) I imagine that the device has code something like the following 
in it's initialization code:

void handle_set_alternate_setting(int altsetting) {
     if (altsetting == 0) {
         reset_interface_configuration();
     } else if (altsetting == 1) {
         queue_networkconnection_notification(DISCONNECTED, 1000MS_TIMEOUT);
         //ignore timeout in sending notification
         queue_speed_configuration_notification(tx_speed, rx_speed, 
1000MS_TIMEOUT);
         //ignore timeout in sending speed configuration
         queue_networkconnection_notification(CONNECTED, 1000MS_TIMEOUT);
         // ignore timeout in sending notification
     }
}

Is that the sort of behavior you were thinking of?

> Looking at the trace, the patch serves its purpose, however there
> might be other devices which can't get network status in time or get
> similar problem. If this would be the case, driver could set a timer
> after selecting alt1; in the absence of the connect message set alt0
> to reset a function when timer expires and set alt1 again.

I might be overly cautious but this behavior sounds like it could impact 
reliability. All my patch series does is keep the device in the reset 
alternate setting until the network interface comes up. My understanding 
is that this won't impact CDC NCM devices which queue the network 
notifications indefinitely and it solves the issue for the device I'm 
having issues with.

My reading of the CDC NCM specification is that it doesn't give any 
timing constraints on when a NetworkConnection notification can come 
from the device. You mentioned that 3G modems can take 1-2 minutes, so 
if some sort of timer was added after selecting alt1, what value could 
be used for it which would work reliably with all NCM CDC devices? Also 
what devices could we test this timer code on?

Regards,

Toby
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
