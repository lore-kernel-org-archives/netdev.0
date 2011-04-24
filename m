From: Oliver Neukum <oliver@neukum.org>
Subject: Re: [PATCHv5] usbnet: Resubmit interrupt URB once if halted
Date: Sun, 24 Apr 2011 08:36:47 +0200
Message-ID: <201104240836.47491.oliver@neukum.org>
References: <20110422152451.3C5A9202ED@glenhelen.mtv.corp.google.com> <Pine.LNX.4.44L0.1104221129530.1877-100000@iolanthe.rowland.org> <BANLkTi=xBJuSFNPO3hkKu+N2tNspw=FZNQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Alan Stern <stern@rowland.harvard.edu>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, davem@davemloft.net,
	bhutchings@solarflare.com
To: Paul Stewart <pstew@chromium.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out003.kontent.com ([81.88.40.217]:60388 "EHLO
	smtp-out003.kontent.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795Ab1DXGf1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2011 02:35:27 -0400
In-Reply-To: <BANLkTi=xBJuSFNPO3hkKu+N2tNspw=FZNQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 22. April 2011, 17:59:15 schrieb Paul Stewart:
> >
> >>       free_netdev(net);
> >>       usb_put_dev (xdev);
> >>  }
> >> @@ -1285,6 +1291,10 @@ int usbnet_suspend (struct usb_interface *intf, pm_message_t message)
> >>                * wake the device
> >>                */
> >>               netif_device_attach (dev->net);
> >> +
> >> +             /* Stop interrupt URBs */
> >> +             if (dev->interrupt)
> >> +                     usb_kill_urb(dev->interrupt);
> >>       }
> >>       return 0;
> >>  }
> >
> > There is a subtle question here: When is the best time to kill the
> > interrupt URB?  Without knowing any of the details, I'd guess that the
> > interrupt URB reports asynchronous events and the driver could run into
> > trouble if one of those events occurred while everything else was
> > turned off.  This suggests that the interrupt URB should be killed as
> > soon as possible rather than as late as possible.  But maybe it doesn't
> > matter; it all depends on the design of the driver.
> 
> I'm not sure I can answer this question either.  As it stands, nobody
> was killing them before.  Just trying to make it better.

Hm. Are we looking at the same code? usbnet_suspend now has:

		/*
		 * accelerate emptying of the rx and queues, to avoid
		 * having everything error out.
		 */
		netif_device_detach (dev->net);
		usbnet_terminate_urbs(dev);
		usb_kill_urb(dev->interrupt);

This suggests that if you want to resubmit the interrupt URB in resume()
you do it first. Which drivers use the interrupt URB?

	Regards
		Oliver
