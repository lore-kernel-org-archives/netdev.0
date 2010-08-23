From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Fix deadlock between boomerang_interrupt and
 boomerang_start_tx in 3c59x
Date: Mon, 23 Aug 2010 14:32:27 -0400
Message-ID: <20100823183227.GB12906@hmsreliant.think-freely.org>
References: <1281538818-3915-1-git-send-email-nhorman@tuxdriver.com>
 <20100811.231334.39172883.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, klassert@mathematik.tu-chemnitz.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36445 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752584Ab0HWSiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Aug 2010 14:38:04 -0400
Content-Disposition: inline
In-Reply-To: <20100811.231334.39172883.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 11, 2010 at 11:13:34PM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Wed, 11 Aug 2010 11:00:18 -0400
> 
> > @@ -2133,6 +2134,15 @@ boomerang_start_xmit(struct sk_buff *skb, struct net_device *dev)
> >  			   dev->name, vp->cur_tx);
> >  	}
> >  
> > +	/*
> > +	 * We can't allow a recursion from our interrupt handler back into the
> > +	 * tx routine, as they take the same spin lock, and that causes
> > +	 * deadlock.  Just return NETDEV_TX_BUSY and let the stack try again in
> > +	 * a bit
> > +	 */
> > +	if (vp->handling_irq)
> > +		return NETDEV_TX_BUSY;
> > +
> >  	if (vp->cur_tx - vp->dirty_tx >= TX_RING_SIZE) {
> >  		if (vortex_debug > 0)
> >  			pr_warning("%s: BUG! Tx Ring full, refusing to send buffer.\n",
> 
> This is just as racy as your previous patch :-)
> 
> You don't hold vp->lock so right after testing this another cpu can
> enter the interrupt handler, take the lock, and set vp->handling_irq
> to '1'.
> 
> This is becomming hopeless, you can't synchronize the state without
> holding the same lock which is giving us trouble in the first place.
> 
> Maybe just toss the pr_*() statements from the interrupt handler.
> 
> This driver is old enough that the easiest to verify fix is probably
> the best one to make.
> 
> 


Dave, any further thoughts here?  Is the explination regarding the lack of
lock-race satisfactory, or would you rather we just pull all the pr_* calls from
the interrupt handler?

Neil

