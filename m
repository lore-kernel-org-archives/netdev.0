From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCHv5] usbnet: Resubmit interrupt URB once if halted
Date: Fri, 22 Apr 2011 11:47:15 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1104221129530.1877-100000@iolanthe.rowland.org>
References: <20110422152451.3C5A9202ED@glenhelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>, <davemloft.net-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	<bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110422152451.3C5A9202ED-6A69KNNYBwgF248FYctl9mCaruZE5nAUZeezCHUQhQ4@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Apr 2011, Paul Stewart wrote:

> Resubmit interrupt URB if device is open.  Use a flag set in
> usbnet_open() to determine this state.  Also kill and free
> interrupt URB in usbnet_disconnect().

Generally good, but a couple of things are questionable...

> Signed-off-by: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> ---
>  drivers/net/usb/usbnet.c   |   14 ++++++++++++++
>  include/linux/usb/usbnet.h |    1 +
>  2 files changed, 15 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 02d25c7..c7cf4af 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -643,6 +643,7 @@ static int usbnet_open (struct net_device *net)
>  		}
>  	}
>  
> +	set_bit(EVENT_DEV_OPEN, &dev->flags);
>  	netif_start_queue (net);
>  	if (netif_msg_ifup (dev)) {
>  		char	*framing;

You forgot to clear this flag in usbnet_stop().

By the way, there is FLAG_AVOID_UNLINK_URBS defined in usbnet.h and
used in usbnet_stop().  Is it meant to apply to the interrupt URB as
well as the others?

> @@ -1105,6 +1106,11 @@ void usbnet_disconnect (struct usb_interface *intf)
>  	if (dev->driver_info->unbind)
>  		dev->driver_info->unbind (dev, intf);
>  
> +	if (dev->interrupt) {
> +		usb_kill_urb(dev->interrupt);
> +		usb_free_urb(dev->interrupt);
> +	}
> +

usb_kill_urb and usb_free_urb include their own tests for urb == NULL; 
you don't need to test it here or below.

>  	free_netdev(net);
>  	usb_put_dev (xdev);
>  }
> @@ -1285,6 +1291,10 @@ int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
>  		 * wake the device
>  		 */
>  		netif_device_attach (dev->net);
> +
> +		/* Stop interrupt URBs */
> +		if (dev->interrupt)
> +			usb_kill_urb(dev->interrupt);
>  	}
>  	return 0;
>  }

There is a subtle question here: When is the best time to kill the 
interrupt URB?  Without knowing any of the details, I'd guess that the 
interrupt URB reports asynchronous events and the driver could run into 
trouble if one of those events occurred while everything else was 
turned off.  This suggests that the interrupt URB should be killed as 
soon as possible rather than as late as possible.  But maybe it doesn't 
matter; it all depends on the design of the driver.

> @@ -1297,6 +1307,10 @@ int usbnet_resume (struct usb_interface *intf)
>  	if (!--dev->suspend_count)
>  		tasklet_schedule (&dev->bh);
>  
> +		/* resume interrupt URBs */
> +		if (dev->interrupt && test_bit(EVENT_DEV_OPEN, &dev->flags))
> +			usb_submit_urb(dev->interrupt, GFP_NOIO);
> +
>  	return 0;
>  }

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
