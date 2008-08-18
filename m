From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Sun, 17 Aug 2008 18:35:05 -0700 (PDT)
Message-ID: <20080817.183505.163224950.davem@davemloft.net>
References: <20080817.155723.214209606.davem@davemloft.net>
	<20080817.160329.121812684.davem@davemloft.net>
	<20080818012516.GB31337@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40676
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750974AbYHRBfF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 21:35:05 -0400
In-Reply-To: <20080818012516.GB31337@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 18 Aug 2008 11:25:16 +1000

> So what's the issue with dev_queue_xmit? That should be taken care
> of by something like rcu_barrier_bh, no?

The code in dev_queue_xmit() used to resample the pointer.  It
relied upon the fact that we always used the same top-level
spinlock to set the qdisc.

But now that the lock is in the qdisc itself instead of the
netdevice or netdev_queue, that no longer works.

That's why I got rid of the "resample" code in these places
and tried to move everything into RCU.

I think I see another way out of this:

1) Add __QDISC_STATE_DEACTIVATE.

2) Set it right before dev_deactivate() swaps resets the qdisc
   pointer.

3) Test it in dev_queue_xmit() et al. once the qdisc root lock is
   acquired, and drop lock and resample ->qdisc if
   __QDISC_STATE_DEACTIVATE is set.
