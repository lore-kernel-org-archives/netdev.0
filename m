From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 07:35:58 +0000
Message-ID: <20080819073558.GD4376@ff.dom.local>
References: <20080818.165411.255925269.davem@davemloft.net> <20080819000551.GA26699@gondor.apana.org.au> <20080818.171124.192743795.davem@davemloft.net> <20080818.210701.80578862.davem@davemloft.net> <20080819064609.GA4376@ff.dom.local> <20080819072316.GA4878@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:41047 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752480AbYHSHgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 03:36:11 -0400
Received: by ug-out-1314.google.com with SMTP id c2so407382ugf.37
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 00:36:09 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080819072316.GA4878@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 05:23:16PM +1000, Herbert Xu wrote:
> On Tue, Aug 19, 2008 at 06:46:09AM +0000, Jarek Poplawski wrote:
> >
> > Actually, I, and earlier Herbert, have written about destroying root
> > qdiscs without sch_tree_lock(). I don't know how Herbert, but I'd
> > prefer to leave here this lock for child qdiscs: they can remove some
> > common structures, so this needs more checking, and even if they don't
> > do this currently, there is no need to remove this possibility here.
> > Similarly, I'm not sure if removing BH protection is really needed
> > here.
> 
> Qdiscs can die in two ways, when the underlying device dies or
> when the user removes/replaces the qdisc.  In the first case the
> we're being called from dev_shutdown so all users of the qdisc
> should have ceased or dev_deactivate is buggy.  The other case
> is again divided into two subcases.  First of all if we're removing
> the root qdisc then again dev_deactivate gets called and the same
> reasoning applies.

This case is quite clear.

> 
> If we're removing a non-root qdisc, then we will first grab the
> root qdisc's lock, kill the child, and release the root lock.  By
> convention, any user of a child qdisc must have acquired the root
> qdisc's lock because the child is only reachable through the root.
> Therefore once we have released the root qdisc lock after killing
> the child, we're guaranteed that no further references to that
> child can be made.

By convention, there was always this comment that destroy is under
sch_tree_lock(), so it was legal to depend on this. I'm not afraid
of somebody using such an under destroy qdisc - it's about a code
inside this qdisc could refer to not destroyed part.

> If for whatever reason the code does not reflect the reasoning
> above, please feel free to fix the code :)

Sure, I'll try to look for such problems.

Cheers,
Jarek P.
