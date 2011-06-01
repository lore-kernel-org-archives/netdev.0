From: David Miller <davem@davemloft.net>
Subject: Re: [RFC/PATCH] sungem: Spring cleaning and GRO support
Date: Tue, 31 May 2011 19:41:15 -0700 (PDT)
Message-ID: <20110531.194115.486383514.davem@davemloft.net>
References: <1306828745.7481.660.camel@pasglop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ruediger.herbst@googlemail.com,
	bhamilton04@gmail.com
To: benh@kernel.crashing.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:41707 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933143Ab1FAClW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 May 2011 22:41:22 -0400
In-Reply-To: <1306828745.7481.660.camel@pasglop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Tue, 31 May 2011 17:59:05 +1000

> Now the results .... on a dual G5 machine with a 1000Mb link, no
> measurable netperf difference on Rx and a 3% loss on Tx.
> 
> So taking the lock is the Tx path hurts...

It shouldn't.  You're replacing one lock with another, and in fact
because TX reclaim occurs in softirq context (and thus SKB freeing can
be done directly, instead of rescheduled to a softirq) it should be
faster.

And I think I see what the problem is:

> +	if (unlikely(netif_queue_stopped(dev) &&
> +		     TX_BUFFS_AVAIL(gp) > (MAX_SKB_FRAGS + 1))) {
> +		netif_tx_lock(dev);
> +		if (netif_queue_stopped(dev) &&
> +		    TX_BUFFS_AVAIL(gp) > (MAX_SKB_FRAGS + 1))
> +			netif_wake_queue(dev);
> +		netif_tx_unlock(dev);
> +	}
>  }

Don't use netif_tx_lock(), that has a loop and multiple atomics :-)

It's going to grab a special global TX lock, and then grab a lock for
TX queue zero, and finally set an atomic state bit in TX queue zero.

Take a look at the implementation in netdevice.h

It's a special "lock everything TX", a mechanism for multiqueue
drivers to shut quiesce all TX queue activity safely in one operation.

Instead, do something like:

	struct netdev_queue *txq = netdev_get_tx_queue(dev, 0);

	__netif_tx_lock(txq, smp_processor_id();
	...
	__netif_tx_unlock(txq);

and I bet your TX numbers improve a bit.
