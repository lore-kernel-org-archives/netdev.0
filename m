From: Indrek Peri <Indrek.Peri@Ericsson.com>
Subject: Re: [RFC] Keep track of interrupt URB status and resubmit in bh if
 necessary
Date: Fri, 4 Mar 2011 12:01:45 +0100
Message-ID: <4D70C699.8000606@Ericsson.com>
References: <20110303055828.073E520218@glenhelen.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"dbrownell@users.sourceforge.org" <dbrownell@users.sourceforge.org>
To: Paul Stewart <pstew@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw10.se.ericsson.net ([193.180.251.61]:59085 "EHLO
	mailgw10.se.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759474Ab1CDLAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 06:00:49 -0500
In-Reply-To: <20110303055828.073E520218@glenhelen.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


To my understanding usbnet has design questions, like EVENT_DEV_ASLEEP,
device states and events. In struct "flags" member holds an event to
execute deferred work. Actually, in usbnet_bh, EVENT_DEV_ASLEEP is
really needed in if-statement. Without that, in selective suspend
case driver crashes.

Another problem was that "suspend" removed interrupt URB. I tought in
the same way as Paul, I added insertion of interrupt URB. Paul added
it in usbnet_bh and I in "resume". I do not see a problem to add
interrupt URB in "resume". My patch had a typo, in "resume" we
should use GFP_ATOMIC in usb_submit_urb. Now is the question is
this good design? My interpretation of David is that driver needs
"resume driver" transition where RX and INT URBs are activated.

I guess that usbnet needs a redesign and rewriting. 
usbnet is used by many USB-Ethernet devices that actually do not
use selective suspend.

BR, Indrek



On 03/03/2011 06:45 AM, Paul Stewart wrote:
> It appears that a patch from Indrek Peri similar to the one below
> without resolution.  I'm new to this problem (suspend-resume causing
> interrupt URBs to stop delivering) and am curious about what the correct
> solution would should like.  Before becoming aware of this thread, I
> just added a "usb_submit_urb" of "dev->interrupt" into "usbnet_resume()"
> and that worked to solve the issue I was having.  Apparently this isn't
> the correct solution though, from David's response to Indrek.  So, I'm
> curious about what the right code should be.
> 
> I'll note is that submitting the interrupt URB seems fairly benign.  If
> we are in a situation where we should not have sent an URB (e.g, the
> netif wasn't running) intr_complete correctly handles this case and does
> not re-submit the URB, so at most we get one "rogue" interrupt URB after
> resume-from-suspend.  The only nasty thing is that this URB should
> probably not be submitted from interrupt, which the resume function
> almost certainly is.  I'm guessing this is part of why David NAKed
> Indrek's patch.  Am I correct?
> 
> Does something like the patch below seem like a resonable solution?
> 
> Cc: David Brownell <dbrownell@users.sourceforge.org>
> Cc: Indrek Peri <Indrek.Peri@Ericsson.com>
> Signed-off-by: Paul Stewart <pstew@google.com>
> ---
>  drivers/net/usb/usbnet.c   |   21 +++++++++++++++++++--
>  include/linux/usb/usbnet.h |    1 +
>  2 files changed, 20 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
> index 02d25c7..bc6a8e0 100644
> --- a/drivers/net/usb/usbnet.c
> +++ b/drivers/net/usb/usbnet.c
> @@ -471,6 +471,8 @@ static void intr_complete (struct urb *urb)
>  	struct usbnet	*dev = urb->context;
>  	int		status = urb->status;
>  
> +	dev->interrupt_urb_running = 0;
> +
>  	switch (status) {
>  	/* success */
>  	case 0:
> @@ -497,7 +499,9 @@ static void intr_complete (struct urb *urb)
>  
>  	memset(urb->transfer_buffer, 0, urb->transfer_buffer_length);
>  	status = usb_submit_urb (urb, GFP_ATOMIC);
> -	if (status != 0 && netif_msg_timer (dev))
> +	if (status == 0)
> +		dev->interrupt_urb_running = 1;
> +	else if (netif_msg_timer (dev))
>  		deverr(dev, "intr resubmit --> %d", status);
>  }
>  
> @@ -580,6 +584,7 @@ static int usbnet_stop (struct net_device *net)
>  	remove_wait_queue (&unlink_wakeup, &wait);
>  
>  	usb_kill_urb(dev->interrupt);
> +	dev->interrupt_urb_running = 0;
>  
>  	/* deferred work (task, timer, softirq) must also stop.
>  	 * can't flush_scheduled_work() until we drop rtnl (later),
> @@ -640,7 +645,8 @@ static int usbnet_open (struct net_device *net)
>  			if (netif_msg_ifup (dev))
>  				deverr (dev, "intr submit %d", retval);
>  			goto done;
> -		}
> +		} else
> +			dev->interrupt_urb_running = 1;
>  	}
>  
>  	netif_start_queue (net);
> @@ -1065,6 +1071,17 @@ static void usbnet_bh (unsigned long param)
>  		if (dev->txq.qlen < TX_QLEN (dev))
>  			netif_wake_queue (dev->net);
>  	}
> +
> +	// Do we need to re-enable interrupt URBs?
> +	if (netif_running (dev->net) &&
> +	    netif_device_present (dev->net) &&
> +	    dev->interrupt_urb_running == 0) {
> +		usb_submit_urb (dev->interrupt, GFP_KERNEL);
> +
> +		/* Unconditionally mark as running so we don't retry */
> +		dev->interrupt_urb_running = 1;
> +	}
> +
>  }
>  
>  
> diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
> index ba09fe8..1b8ed8a 100644
> --- a/include/linux/usb/usbnet.h
> +++ b/include/linux/usb/usbnet.h
> @@ -49,6 +49,7 @@ struct usbnet {
>  	u32			hard_mtu;	/* count any extra framing */
>  	size_t			rx_urb_size;	/* size for rx urbs */
>  	struct mii_if_info	mii;
> +	int			interrupt_urb_running;
>  
>  	/* various kinds of pending driver work */
>  	struct sk_buff_head	rxq;

