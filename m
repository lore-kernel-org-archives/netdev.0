From: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Subject: Re: [PATCHv4] usbnet: Resubmit interrupt URB once if halted
Date: Thu, 21 Apr 2011 10:03:34 -0400 (EDT)
Message-ID: <Pine.LNX.4.44L0.1104210958560.1939-100000@iolanthe.rowland.org>
References: <20110420214452.C599321126@glenhelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
To: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20110420214452.C599321126-6A69KNNYBwgF248FYctl9mCaruZE5nAUZeezCHUQhQ4@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Apr 2011, Paul Stewart wrote:

> Set a flag if the interrupt URB completes with ENOENT as this
> occurs legitimately during system suspend.  When the
> usbnet_resume is called, test this flag and try once to resubmit
> the interrupt URB.

I still don't think this is the best way to go.

> This version of the patch moves the urb submit directly into
> usbnet_resume.  Is it okay to submit a GFP_KERNEL urb from
> usbnet_resume()?

Yes, it is.

> Signed-off-by: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
> ---
>  drivers/net/usb/usbnet.c   |   13 ++++++++++++-
>  include/linux/usb/usbnet.h |    1 +
>  2 files changed, 13 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 02d25c7..3651a48 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -482,6 +482,7 @@ static void intr_complete (struct urb *urb)
>  	case -ESHUTDOWN:	/* hardware gone */
>  		if (netif_msg_ifdown (dev))
>  			devdbg (dev, "intr shutdown, code %d", status);
> +		set_bit(EVENT_INTR_HALT, &dev->flags);

Is this new flag really needed?

>  		return;
>  
>  	/* NOTE:  not throttling like RX/TX, since this endpoint
> @@ -1294,9 +1295,19 @@ int usbnet_resume (struct usb_interface *intf)
>  {
>  	struct usbnet		*dev = usb_get_intfdata(intf);
>  
> -	if (!--dev->suspend_count)
> +	if (!--dev->suspend_count) {
>  		tasklet_schedule (&dev->bh);
>  
> +		/* resubmit interrupt URB if it was halted by suspend */
> +		if (dev->interrupt && netif_running(dev->net) &&
> +		    netif_device_present(dev->net) &&
> +		    test_bit(EVENT_INTR_HALT, &dev->flags)) {

Why do you need the test_bit()?  If the other conditions are all true,
don't you want to resubmit the interrupt URB regardless?

> +			clear_bit(EVENT_INTR_HALT, &dev->flags);
> +			usb_submit_urb(dev->interrupt, GFP_KERNEL);
> +		}
> +	}
> +}
> +
>  	return 0;
>  }

Alan Stern

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
