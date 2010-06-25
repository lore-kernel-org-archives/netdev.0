From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next-2.6 2/2] 3c59x: Use fine-grained locks for MII
 and windowed register access
Date: Fri, 25 Jun 2010 10:24:47 +0200
Message-ID: <20100625082447.GK5570@secunet.com>
References: <1277337161.26161.14.camel@localhost>
 <1277337341.26161.18.camel@localhost>
 <20100624120517.GI5570@secunet.com>
 <1277384239.26161.162.camel@localhost>
 <20100624140057.GJ5570@secunet.com>
 <1277426759.26161.179.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Chase Douglas <chase.douglas@canonical.com>,
	Arne Nordmark <nordmark@mech.kth.se>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:37450 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751750Ab0FYIXr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jun 2010 04:23:47 -0400
Content-Disposition: inline
In-Reply-To: <1277426759.26161.179.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 25, 2010 at 01:45:59AM +0100, Ben Hutchings wrote:
> > 
> > The point is that we should not disable the interrupts if we don't need to
> > do so. It is not speed critical for the 3c59x driver but disabling the
> > interrupts should be avoided whenever possible. For example during device
> > probe and device open we can't race against an interrupt handler because
> > the device is not yet running.
> > 
> > An example from vortex_probe1() is:
> > 
> > for (i = 0; i < 6; i++)
> > 	window_write8(vp, dev->dev_addr[i], 2, i);
> > 
> > which expands to someting like:
> > 
> > for (i = 0; i < 6; i++) {
> > 	unsigned long flags;
> > 	spin_lock_irqsave(&vp->window_lock, flags);
> > 	window_set(vp, window);
> > 	iowrite8(dev->dev_addr[i], vp->ioaddr  + i);
> > 	spin_unlock_irqrestore(&vp->window_lock, flags);
> > 	return ret;
> > }
> [...]
> 
> I still fail to see why this matters.
> 

These locks are not needed, why you want to have them arround?
It adds overhead, even if they are not in a fast-path function.
And much more important, this gives a reader of the code the
impression that these locks are needed. For somebody who tries
to understand the code, it will be probaply not that easy to
figure out which of these locks are needed and for what reason.

> The sfc driver which I look after in my day job also uses
> spin_lock_irqsave() for each CSR update, when this could be avoided in
> the initialisation path.  None of the many customers using rt kernels
> has ever complained about this.  It's just not an important issue.

Perhaps I'm fussy, personally I prefer to use the appropriate
lock in any case. But that's just my opinion, other people might
think different about that.

Steffen
