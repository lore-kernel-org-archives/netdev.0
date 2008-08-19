From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 17:46:06 +1000
Message-ID: <20080819074606.GA5261@gondor.apana.org.au>
References: <20080818.165411.255925269.davem@davemloft.net> <20080819000551.GA26699@gondor.apana.org.au> <20080818.171124.192743795.davem@davemloft.net> <20080818.210701.80578862.davem@davemloft.net> <20080819064609.GA4376@ff.dom.local> <20080819072316.GA4878@gondor.apana.org.au> <20080819073558.GD4376@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:53540 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752649AbYHSHqN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 03:46:13 -0400
Content-Disposition: inline
In-Reply-To: <20080819073558.GD4376@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 07:35:58AM +0000, Jarek Poplawski wrote:
>
> > If we're removing a non-root qdisc, then we will first grab the
> > root qdisc's lock, kill the child, and release the root lock.  By
> > convention, any user of a child qdisc must have acquired the root
> > qdisc's lock because the child is only reachable through the root.
> > Therefore once we have released the root qdisc lock after killing
> > the child, we're guaranteed that no further references to that
> > child can be made.
> 
> By convention, there was always this comment that destroy is under
> sch_tree_lock(), so it was legal to depend on this. I'm not afraid
> of somebody using such an under destroy qdisc - it's about a code
> inside this qdisc could refer to not destroyed part.

No no no, it's not about qdisc_destroy at all.  If you're relying
on the lock around qdisc_destroy, then you're already too late.
The qdisc should have been removed before we get to qdisc_destroy.

It's the act of removal that's protected by the root lock, and
still is.  For example, in htb_graft we do sch_tree_lock before
killing any children, this is the lock that I was referring to.

> > If for whatever reason the code does not reflect the reasoning
> > above, please feel free to fix the code :)
> 
> Sure, I'll try to look for such problems.

Of course if you find any classful qdisc that does not hold the
tree lock when killing children, then please send patches.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
