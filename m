From: Steve.Glendinning@smsc.com
Subject: Re: [patch]USB autosuspend for cdc-ether
Date: Tue, 24 Nov 2009 15:11:28 +0000
Message-ID: <OFCBC12A15.7006C53A-ON80257678.00524557-80257678.005373C0@smsc.com>
References: <200911231621.04499.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: "David S. Miller" <davem@davemloft.net>,
	David Brownell <david-b@pacbell.net>,
	linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	stern@rowland.harvard.edu,
	"Torgny Johansson" <torgny.johansson@ericsson.com>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:58398 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933420AbZKXP1Q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Nov 2009 10:27:16 -0500
In-Reply-To: <200911231621.04499.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Oliver,

Interesting patch, I'm going to try and add support for this
to smsc95xx.

A few things I noticed:

> @@ -929,7 +961,11 @@ kevent (struct work_struct *work)
>        int         retval = 0;
> 
>        clear_bit (EVENT_LINK_RESET, &dev->flags);
> +      status = usb_autopm_get_interface(dev->intf);
> +      if (status < 0)
> +         goto skip_reset;
>        if(info->link_reset && (retval = info->link_reset(dev)) < 0) {
> +skip_reset:
>           devinfo(dev, "link reset failed (%d) usbnet usb-%s-%s, %s",
>              retval,
>              dev->udev->bus->bus_name, dev->udev->devpath,

on EVENT_LINK_RESET you call usb_autopm_get_interface with no matching
usb_autopm_put_interface, so you leak 1 reference count and the device
never autosuspends.

> @@ -958,7 +994,7 @@ static void tx_complete (struct urb *urb)
> 
>        switch (urb->status) {
>        case -EPIPE:
> -         usbnet_defer_kevent (dev, EVENT_TX_HALT);
> +         usbnet_defer_kevent (dev, EVENT_TX_HALT); 
>           break;
> 
>        /* software-driven interface shutdown */

The only change here is the addition of trailing whitespace (which both
checkpatch.pl and git complain about).  You should run your patch through
scripts/checkpatch.pl and fix these up.

--
Steve
