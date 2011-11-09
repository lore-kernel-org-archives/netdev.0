From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] net/usb: Misc. fixes for the LG-VL600 LTE USB modem
Date: Wed, 09 Nov 2011 11:51:44 -0600
Message-ID: <1320861104.24903.4.camel@dcbw.foobar.com>
References: <1320808200-28209-1-git-send-email-prox@prolixium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: oliver@neukum.name, gregkh@suse.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Mark Kamichoff <prox@prolixium.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320808200-28209-1-git-send-email-prox@prolixium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-11-08 at 22:10 -0500, Mark Kamichoff wrote:
> Add checking for valid magic values (needed for stability in the event
> corrupted packets are received) and remove some other unneeded checks.
> Also, fix flagging device as WWAN (Bugzilla bug #39952).
> 
> Signed-off-by: Mark Kamichoff <prox@prolixium.com>
> ---
>  drivers/net/usb/cdc_ether.c |    2 +-
>  drivers/net/usb/lg-vl600.c  |   30 ++++++++++++++----------------
>  2 files changed, 15 insertions(+), 17 deletions(-)
> 
> diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
> index c924ea2..99ed6eb 100644
> --- a/drivers/net/usb/cdc_ether.c
> +++ b/drivers/net/usb/cdc_ether.c
> @@ -567,7 +567,7 @@ static const struct usb_device_id	products [] = {
>  {
>  	USB_DEVICE_AND_INTERFACE_INFO(0x1004, 0x61aa, USB_CLASS_COMM,
>  			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
> -	.driver_info = (unsigned long)&wwan_info,
> +	.driver_info = 0,
>  },
>  
>  /*
> diff --git a/drivers/net/usb/lg-vl600.c b/drivers/net/usb/lg-vl600.c
> index d43db32..b975a39 100644
> --- a/drivers/net/usb/lg-vl600.c
> +++ b/drivers/net/usb/lg-vl600.c
> @@ -144,10 +144,11 @@ static int vl600_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
>  	}
>  
>  	frame = (struct vl600_frame_hdr *) buf->data;
> -	/* NOTE: Should check that frame->magic == 0x53544448?
> -	 * Otherwise if we receive garbage at the beginning of the frame
> -	 * we may end up allocating a huge buffer and saving all the
> -	 * future incoming data into it.  */
> +	/* Yes, check that frame->magic == 0x53544448 (or 0x44544d48),
> +	 * otherwise we may run out of memory w/a bad packet */
> +	if (ntohl(frame->magic) != 0x53544448 &&
> +			ntohl(frame->magic) != 0x44544d48)
> +		goto error;
>  
>  	if (buf->len < sizeof(*frame) ||
>  			buf->len != le32_to_cpup(&frame->len)) {
> @@ -209,8 +210,9 @@ static int vl600_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
>  			 * for IPv6 packets, and set the ethertype to IPv6
>  			 * (0x86dd) so Linux can understand it.
>  			 */
> -			if ((buf->data[sizeof(*ethhdr)] & 0xf0) == 0x60)
> -				ethhdr->h_proto = __constant_htons(ETH_P_IPV6);
> +			if ((buf->data[sizeof(*ethhdr)] & 0xf0) == 0x60) {
> +				ethhdr->h_proto = htons(ETH_P_IPV6);
> +			}

This change seems somewhat gratuitous; what's the reason for (a) the
switch from __constant_htons() to plain htons() and (b) adding the {} ?

Dan

>  		}
>  
>  		if (count) {
> @@ -296,6 +298,11 @@ encapsulate:
>  	 * overwrite the remaining fields.
>  	 */
>  	packet = (struct vl600_pkt_hdr *) skb->data;
> +	/* The VL600 wants IPv6 packets to have an IPv4 ethertype
> +	 * Since this modem only supports IPv4 and IPv6, just set all
> +	 * frames to 0x0800 (ETH_P_IP)
> +	 */
> +	packet->h_proto = htons(ETH_P_IP);
>  	memset(&packet->dummy, 0, sizeof(packet->dummy));
>  	packet->len = cpu_to_le32(orig_len);
>  
> @@ -308,21 +315,12 @@ encapsulate:
>  	if (skb->len < full_len) /* Pad */
>  		skb_put(skb, full_len - skb->len);
>  
> -	/* The VL600 wants IPv6 packets to have an IPv4 ethertype
> -	 * Check if this is an IPv6 packet, and set the ethertype
> -	 * to 0x800
> -	 */
> -	if ((skb->data[sizeof(struct vl600_pkt_hdr *) + 0x22] & 0xf0) == 0x60) {
> -		skb->data[sizeof(struct vl600_pkt_hdr *) + 0x20] = 0x08;
> -		skb->data[sizeof(struct vl600_pkt_hdr *) + 0x21] = 0;
> -	}
> -
>  	return skb;
>  }
>  
>  static const struct driver_info	vl600_info = {
>  	.description	= "LG VL600 modem",
> -	.flags		= FLAG_ETHER | FLAG_RX_ASSEMBLE,
> +	.flags		= FLAG_RX_ASSEMBLE | FLAG_WWAN,
>  	.bind		= vl600_bind,
>  	.unbind		= vl600_unbind,
>  	.status		= usbnet_cdc_status,
