From: Henning Schild <henning.schild-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH net] cdc_ether: Fix handling connection notification
Date: Wed, 30 Nov 2016 20:09:09 +0100
Message-ID: <20161130200909.3a35a29e@md1em3qc>
References: <20161130184216.4224-1-kristian.evensen@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kristian Evensen <kristian.evensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161130184216.4224-1-kristian.evensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Am Wed, 30 Nov 2016 19:42:16 +0100
schrieb Kristian Evensen <kristian.evensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>:

> Commit bfe9b9d2df66 ("cdc_ether: Improve ZTE MF823/831/910 handling")
> introduced a work-around in usbnet_cdc_status() for devices that
> exported cdc carrier on twice on connect. Before the commit, this
> behavior caused the link state to be incorrect. It was assumed that
> all CDC Ethernet devices would either export this behavior, or send
> one off and then one on notification (which seems to be the default
> behavior).
> 
> Unfortunately, it turns out multiple devices sends a connection
> notification multiple times per second (via an interrupt), even when
> connection state does not change. This has been observed with several
> different USB LAN dongles (at least), for example 13b1:0041 (Linksys).
> After bfe9b9d2df66, the link state has been set as down and then up
> for each notification. This has caused a flood of Netlink NEWLINK
> messages and syslog to be flooded with messages similar to:
> 
> cdc_ether 2-1:2.0 eth1: kevent 12 may have been dropped
> 
> This commit fixes the behavior by reverting usbnet_cdc_status() to
> how it was before bfe9b9d2df66. The work-around has been moved to a
> separate status-function which is only called when a known, affect
> device is detected.
> 
> Fixes: bfe9b9d2df66 ("cdc_ether: Improve ZTE MF823/831/910 handling")
> Reported-by: Henning Schild <henning.schild-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
> Signed-off-by: Kristian Evensen <kristian.evensen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> ---
>  drivers/net/usb/cdc_ether.c | 38
> +++++++++++++++++++++++++++++++------- 1 file changed, 31
> insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
> index 45e5e43..8c628ea 100644
> --- a/drivers/net/usb/cdc_ether.c
> +++ b/drivers/net/usb/cdc_ether.c
> @@ -388,12 +388,6 @@ void usbnet_cdc_status(struct usbnet *dev,
> struct urb *urb) case USB_CDC_NOTIFY_NETWORK_CONNECTION:
>  		netif_dbg(dev, timer, dev->net, "CDC: carrier %s\n",
>  			  event->wValue ? "on" : "off");
> -
> -		/* Work-around for devices with broken
> off-notifications */
> -		if (event->wValue &&
> -		    !test_bit(__LINK_STATE_NOCARRIER,
> &dev->net->state))
> -			usbnet_link_change(dev, 0, 0);
> -
>  		usbnet_link_change(dev, !!event->wValue, 0);
>  		break;
>  	case USB_CDC_NOTIFY_SPEED_CHANGE:	/* tx/rx rates */
> @@ -466,6 +460,36 @@ static int usbnet_cdc_zte_rx_fixup(struct usbnet
> *dev, struct sk_buff *skb) return 1;
>  }
>  
> +/* Ensure correct link state
> + *
> + * Some devices (ZTE MF823/831/910) export two carrier on
> notifications when
> + * connected. This causes the link state to be incorrect. Work
> around this by
> + * always setting the state to off, then on.
> + */
> +void usbnet_cdc_zte_status(struct usbnet *dev, struct urb *urb)
> +{
> +	struct usb_cdc_notification *event;
> +
> +	if (urb->actual_length < sizeof(*event))
> +		return;
> +
> +	event = urb->transfer_buffer;
> +
> +	if (event->bNotificationType !=
> USB_CDC_NOTIFY_NETWORK_CONNECTION) {
> +		usbnet_cdc_status(dev, urb);
> +		return;
> +	}
> +
> +	netif_dbg(dev, timer, dev->net, "CDC: carrier %s\n",
> +		  event->wValue ? "on" : "off");
> +
> +	if (event->wValue &&
> +	    !test_bit(__LINK_STATE_NOCARRIER, &dev->net->state))

You should probably use netif_carrier_ok(dev->net) instead.

> +		usbnet_link_change(dev, 0, 0);
> +
> +	usbnet_link_change(dev, !!event->wValue, 0);

Would the following work?

usbnet_link_change(dev, !!event->wValue, event->wValue &&
netif_carrier_ok(dev->net));

> +}
> +
>  static const struct driver_info	cdc_info = {
>  	.description =	"CDC Ethernet Device",
>  	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
> @@ -481,7 +505,7 @@ static const struct driver_info
> zte_cdc_info = { .flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
>  	.bind =		usbnet_cdc_zte_bind,
>  	.unbind =	usbnet_cdc_unbind,
> -	.status =	usbnet_cdc_status,
> +	.status =	usbnet_cdc_zte_status,
>  	.set_rx_mode =	usbnet_cdc_update_filter,
>  	.manage_power =	usbnet_manage_power,
>  	.rx_fixup = usbnet_cdc_zte_rx_fixup,

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
