From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 17:23:16 +1000
Message-ID: <20080819072316.GA4878@gondor.apana.org.au>
References: <20080818.165411.255925269.davem@davemloft.net> <20080819000551.GA26699@gondor.apana.org.au> <20080818.171124.192743795.davem@davemloft.net> <20080818.210701.80578862.davem@davemloft.net> <20080819064609.GA4376@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:54504 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750864AbYHSHXW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 03:23:22 -0400
Content-Disposition: inline
In-Reply-To: <20080819064609.GA4376@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 06:46:09AM +0000, Jarek Poplawski wrote:
>
> Actually, I, and earlier Herbert, have written about destroying root
> qdiscs without sch_tree_lock(). I don't know how Herbert, but I'd
> prefer to leave here this lock for child qdiscs: they can remove some
> common structures, so this needs more checking, and even if they don't
> do this currently, there is no need to remove this possibility here.
> Similarly, I'm not sure if removing BH protection is really needed
> here.

Qdiscs can die in two ways, when the underlying device dies or
when the user removes/replaces the qdisc.  In the first case the
we're being called from dev_shutdown so all users of the qdisc
should have ceased or dev_deactivate is buggy.  The other case
is again divided into two subcases.  First of all if we're removing
the root qdisc then again dev_deactivate gets called and the same
reasoning applies.

If we're removing a non-root qdisc, then we will first grab the
root qdisc's lock, kill the child, and release the root lock.  By
convention, any user of a child qdisc must have acquired the root
qdisc's lock because the child is only reachable through the root.
Therefore once we have released the root qdisc lock after killing
the child, we're guaranteed that no further references to that
child can be made.

If for whatever reason the code does not reflect the reasoning
above, please feel free to fix the code :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
