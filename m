From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [RFC/PATCH] sungem: Spring cleaning and GRO support
Date: Wed, 01 Jun 2011 07:58:08 +1000
Message-ID: <1306879088.7481.679.camel@pasglop>
References: <1306828745.7481.660.camel@pasglop>
	 <1306875564.2866.39.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"R. Herbst" <ruediger.herbst@googlemail.com>,
	Brian Hamilton <bhamilton04@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:52246 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758298Ab1EaV6U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2011 17:58:20 -0400
In-Reply-To: <1306875564.2866.39.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > Now the results .... on a dual G5 machine with a 1000Mb link, no
> > measurable netperf difference on Rx and a 3% loss on Tx.
> 
> Is TX throughput now CPU-limited or is there some other problem?

I haven't had a chance to measure that properly yet (bloody perf needs
to be build 64-bit and I have a 32-bit distro on that machine, will need
to move over libs etc... today).

> Lacking TSO is going to hurt, but I know we managed multi-gigabit
> single-stream TCP throughput without TSO on x86 systems from 2005.

Right. It -could- be something else too, I need to investigate.

> [...]
> > @@ -736,6 +747,22 @@ static __inline__ void gem_post_rxds(struct gem *gp, int limit)
> >  	}
> >  }
> >  
> > +#define ALIGNED_RX_SKB_ADDR(addr) \
> > +        ((((unsigned long)(addr) + (64UL - 1UL)) & ~(64UL - 1UL)) - (unsigned long)(addr))
> 
> We already have a macro for most of this, so you can define this as:

This is just existing code moved around that I didn't get to cleanup
yet, in fact I was wondering if we really needed that... David, do you
remember if that's something you added for Sparc or I added back then
due to some obscure Apple errata ? I'd like to just switch to
netdev_alloc_skb()

> 	(PTR_ALIGN(addr, 64) - (addr))
> 
> (assuming addr is always a byte pointer; otherwise you need ALIGN and
> the casts to unsigned long).

Yup, I know these :-)

> > +static __inline__ struct sk_buff *gem_alloc_skb(struct net_device *dev, int size,
> > +						gfp_t gfp_flags)
> > +{
> > +	struct sk_buff *skb = alloc_skb(size + 64, gfp_flags);
> 
> You probably should be using netdev_alloc_skb().

As I said above. This is existing code mostly, I need to figure out if
there's a HW reason for the extra alignment first.
  
> > +	if (likely(skb)) {
> > +		int offset = (int) ALIGNED_RX_SKB_ADDR(skb->data);
> > +		if (offset)
> > +			skb_reserve(skb, offset);
> 
> skb_reserve() is inline and very simple, so it may be cheaper to call it
> unconditionally.

Ok. Again, existing code :-)

> > +		skb->dev = dev;
> > +	}
> > +	return skb;
> > +}
> > +
> [...]
> > @@ -951,11 +956,12 @@ static irqreturn_t gem_interrupt(int irq, void *dev_id)
> >  #ifdef CONFIG_NET_POLL_CONTROLLER
> >  static void gem_poll_controller(struct net_device *dev)
> >  {
> > -	/* gem_interrupt is safe to reentrance so no need
> > -	 * to disable_irq here.
> > -	 */
> > -	gem_interrupt(dev->irq, dev);
> > -}
> > +	struct gem *gp = netdev_priv(dev);
> > +
> > +	disable_irq(gp->pdev->irq);
> > +	gem_interrupt(gp->pdev->irq, dev);
> > +	enable_irq(gp->pdev->irq);
> > +
> >  #endif
> 
> This might work better with the closing brace left in place...

Ah right, I haven't tested NETPOLL, thanks.

> The change from dev->irq to gp->pdev->irq looks unnecessary - though I
> hope that one day we can get rid of those I/O resource details in struct
> net_device.

That was my thinking. Other drivers I've looked at tend to use pdev->irq
and I don't want to overly rely on "irq" in the netdev, but that doesn't
matter much does it ?

> [...]
> >  static int gem_do_start(struct net_device *dev)
> >  {
> [...] 
> >  	if (request_irq(gp->pdev->irq, gem_interrupt,
> >  				   IRQF_SHARED, dev->name, (void *)dev)) {
> >  		netdev_err(dev, "failed to request irq !\n");
> >  
> > -		spin_lock_irqsave(&gp->lock, flags);
> > -		spin_lock(&gp->tx_lock);
> > -
> >  		napi_disable(&gp->napi);
> > -
> > -		gp->running =  0;
> > +		netif_device_detach(dev);
> 
> I don't think this can be right, as there seems to be no way for the
> device to be re-attached after this failure other than a suspend/resume
> cycle.

Indeed, brain fart. Will fix, thanks. 

> >  		gem_reset(gp);
> >  		gem_clean_rings(gp);
> > -		gem_put_cell(gp);
> >  
> > -		spin_unlock(&gp->tx_lock);
> > -		spin_unlock_irqrestore(&gp->lock, flags);
> > +		spin_lock_bh(&gp->lock);
> > +		gem_put_cell(gp);
> > +		spin_unlock_bh(&gp->lock);
> >  
> >  		return -EAGAIN;
> >  	}
> [...]
> 
> Is the pm_mutex really needed?  All control operations should already be
> serialised by the RTNL lock, and you've started taking that in the
> suspend and resume functions.

Well, it's been there forever and I need to get my head around it, but
yes, the rtnl lock might be able to get rid of it, good point. I just
actually added that :-)

So all ndo_set_* are going to be covered by rtnl including the ethtool ?

I don't really want to take the rtnl lock in the reset task (at least
not for the whole duration of it), so I may have to be a bit creative on
synchronization there.

Part of the point of that patch is to remove the looooong locked region
under the private lock, ie most of the chip reset/init sequences are now
done without a lock held (I forgot to add that to the changeset comment
I suppose) and I want to keep it that way.

Thanks for your review, I'll give it another shot after I've managed to
do some measurements/profiling.

Cheers,
Ben.

