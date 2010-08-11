From: Greg KH <greg@kroah.com>
Subject: Re: Problem with non aligned DMA in usbnet on ARM
Date: Wed, 11 Aug 2010 13:13:32 -0700
Message-ID: <20100811201332.GB10379@kroah.com>
References: <AANLkTi=ycg=adcizNWKMCb7EdfDANM=6Es7r_gF1LbhV@mail.gmail.com>
 <20100811095454.GA22543@n2100.arm.linux.org.uk>
 <AANLkTimX46QKAGhiyo8AodaXVjuzoxr5-5z2V4gRr1Vu@mail.gmail.com>
 <20100811150443.GB8867@kroah.com>
 <AANLkTimmJDKbh3_pRY_ASKvjsf4YuuUMh3edh5LvDv-p@mail.gmail.com>
 <20100811174238.GA12382@kroah.com>
 <4C62F4EF.1050808@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	linux-usb <linux-usb@vger.kernel.org>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Martin Fuzzey <mfuzzey@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:43393 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756685Ab0HKUNn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Aug 2010 16:13:43 -0400
Content-Disposition: inline
In-Reply-To: <4C62F4EF.1050808@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 11, 2010 at 09:07:27PM +0200, Martin Fuzzey wrote:
> Greg KH wrote:
> >> So the question is are hcds expected to accept arbitarilly aligned but
> >> heap allocated pointers (such as the result of kmalloc() + 1)?
> >>     
> >
> > It sounds like your HCD doesn't like this, so perhaps we should make
> > that rule :)
> >
> > If you allocate the urb with a kmalloc() call with no offset, does it
> > all work properly? 
> Yes
> >  The driver should be calling usb_alloc_urb() which
> > does this automatically for them, right?  Or is it trying to allocate
> > things on its own somehow?
> >
> >   
> It's not the URB itself (which is allocated by usb_alloc_urb) but rather
> the buffer pointer within the URB that causes the problem.

Doh, you are right, sorry about that.

> It's the asix driver (or more exactly the usbnet core used by that driver).
> It does (rx_submit() in drivers/net/usb/usbnet.c):
> 
> urb = usb_alloc_urb();
> skb = alloc_skb (...);
> skb_reserve (skb, NET_IP_ALIGN);
> usb_fill_bulk_urb (urb,...  skb->data);
> usb_submit_urb(urb)
> 
> skb->data as returned by alloc_skb() is aligned
> but skb_reserve adds 2.
> 
> Thus removing the skb_reserve() call makes it work.
> BUT if I do that the IP header is no longer aligned so accesses further
> up the network stack have to be fixed up by exception handlers which is
> expensive (even with hcds which don't require this)

Can you fix this in the host controller driver?

thanks,

greg k-h
