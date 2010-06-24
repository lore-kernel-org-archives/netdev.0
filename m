From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next-2.6 2/2] 3c59x: Use fine-grained locks for MII
 and windowed register access
Date: Thu, 24 Jun 2010 16:00:57 +0200
Message-ID: <20100624140057.GJ5570@secunet.com>
References: <1277337161.26161.14.camel@localhost>
 <1277337341.26161.18.camel@localhost>
 <20100624120517.GI5570@secunet.com>
 <1277384239.26161.162.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chase Douglas <chase.douglas@canonical.com>,
	Arne Nordmark <nordmark@mech.kth.se>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:50677 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754822Ab0FXN76 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jun 2010 09:59:58 -0400
Content-Disposition: inline
In-Reply-To: <1277384239.26161.162.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 24, 2010 at 01:57:19PM +0100, Ben Hutchings wrote:
> > 
> > This adds a lot of calls to spin_lock_irqsave/spin_unlock_irqrestore to many
> > places where this is not necessary at all. For example during device probe and
> > device open, window_read/window_write are called multiple times, each time
> > disabling the interrupts. I'd suggest to have unlocked, locked and irqsave
> > versions of window_read/window_write and use them in appropriate places.
> 
> So what?  These are not speed-critical.  The fast-path functions do
> acquire the lock just once.
> 

The point is that we should not disable the interrupts if we don't need to
do so. It is not speed critical for the 3c59x driver but disabling the
interrupts should be avoided whenever possible. For example during device
probe and device open we can't race against an interrupt handler because
the device is not yet running.

An example from vortex_probe1() is:

for (i = 0; i < 6; i++)
	window_write8(vp, dev->dev_addr[i], 2, i);

which expands to someting like:

for (i = 0; i < 6; i++) {
	unsigned long flags;
	spin_lock_irqsave(&vp->window_lock, flags);
	window_set(vp, window);
	iowrite8(dev->dev_addr[i], vp->ioaddr  + i);
	spin_unlock_irqrestore(&vp->window_lock, flags);
	return ret;
}

which is quite odd in a codepath that could simply do:

for (i = 0; i < 6; i++) {
	window_set(vp, window);
	iowrite8(dev->dev_addr[i], vp->ioaddr + i);
}

> 
> This locked section is now very short - 5 or 6 register read/writes and
> no delays.  We might even be able to get away without locking here as
> the only software state this accesses is dev->if_port and I don't think
> it can race with anything except SIOCGIFMAP (which seems harmless).
> 

Best would be, if we don't need to disable the interrupts on this cpu
at all. But then we probaply need to disable the interupt line with
disable_irq. That's why I suggested to move the timer to thread context.

Steffen
