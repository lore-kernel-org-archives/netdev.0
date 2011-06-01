From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [RFC/PATCH] sungem: Spring cleaning and GRO support
Date: Wed, 01 Jun 2011 13:45:07 +1000
Message-ID: <1306899907.29297.12.camel@pasglop>
References: <1306828745.7481.660.camel@pasglop>
	 <20110531.194115.486383514.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ruediger.herbst@googlemail.com,
	bhamilton04@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:59268 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933197Ab1FADpT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 May 2011 23:45:19 -0400
In-Reply-To: <20110531.194115.486383514.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> And I think I see what the problem is:
> 
> > +	if (unlikely(netif_queue_stopped(dev) &&
> > +		     TX_BUFFS_AVAIL(gp) > (MAX_SKB_FRAGS + 1))) {
> > +		netif_tx_lock(dev);
> > +		if (netif_queue_stopped(dev) &&
> > +		    TX_BUFFS_AVAIL(gp) > (MAX_SKB_FRAGS + 1))
> > +			netif_wake_queue(dev);
> > +		netif_tx_unlock(dev);
> > +	}
> >  }
> 
> Don't use netif_tx_lock(), that has a loop and multiple atomics :-)
> 
> It's going to grab a special global TX lock, and then grab a lock for
> TX queue zero, and finally set an atomic state bit in TX queue zero.
> 
> Take a look at the implementation in netdevice.h

Ah good point ! I think I stole that from another driver (or I just had
a brain fart), indeed, it's bad.

> It's a special "lock everything TX", a mechanism for multiqueue
> drivers to shut quiesce all TX queue activity safely in one operation.
> 
> Instead, do something like:
> 
> 	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);
> 
> 	__netif_tx_lock(txq, smp_processor_id();
> 	...
> 	__netif_tx_unlock(txq);
> 
> and I bet your TX numbers improve a bit.

Right, I'll give that a go. With the assistance of the other Ben H I've
been able to simplify the driver a lot more now too. mutex and remaining
lock are gone, rtnl lock does the job fine for synchronizing vs. reset
task and I cleared up a ton more of unused bits and pieces now that we
don't deal with link timer when the thing is off anymore.

I'll have a new patch later today hopefully with new numbers.

Cheers,
Ben.


