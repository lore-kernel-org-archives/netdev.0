From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 19 Aug 2008 07:56:23 +0000
Message-ID: <20080819075623.GE4376@ff.dom.local>
References: <20080818.165411.255925269.davem@davemloft.net> <20080819000551.GA26699@gondor.apana.org.au> <20080818.171124.192743795.davem@davemloft.net> <20080818.210701.80578862.davem@davemloft.net> <20080819064609.GA4376@ff.dom.local> <20080819072316.GA4878@gondor.apana.org.au> <20080819073558.GD4376@ff.dom.local> <20080819074606.GA5261@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.174]:36638 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753517AbYHSH43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 03:56:29 -0400
Received: by ug-out-1314.google.com with SMTP id c2so411657ugf.37
        for <netdev@vger.kernel.org>; Tue, 19 Aug 2008 00:56:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080819074606.GA5261@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 19, 2008 at 05:46:06PM +1000, Herbert Xu wrote:
> On Tue, Aug 19, 2008 at 07:35:58AM +0000, Jarek Poplawski wrote:
> >
> > > If we're removing a non-root qdisc, then we will first grab the
> > > root qdisc's lock, kill the child, and release the root lock.  By
> > > convention, any user of a child qdisc must have acquired the root
> > > qdisc's lock because the child is only reachable through the root.
> > > Therefore once we have released the root qdisc lock after killing
> > > the child, we're guaranteed that no further references to that
> > > child can be made.
> > 
> > By convention, there was always this comment that destroy is under
> > sch_tree_lock(), so it was legal to depend on this. I'm not afraid
> > of somebody using such an under destroy qdisc - it's about a code
> > inside this qdisc could refer to not destroyed part.
> 
> No no no, it's not about qdisc_destroy at all.  If you're relying
> on the lock around qdisc_destroy, then you're already too late.
> The qdisc should have been removed before we get to qdisc_destroy.
> 
> It's the act of removal that's protected by the root lock, and
> still is.  For example, in htb_graft we do sch_tree_lock before
> killing any children, this is the lock that I was referring to.

I'm not sure I can understand you: could you look at htb_destroy()
instead and think of this as a child qdisc of prio or another htb?
Having a top level "queue" lock guarantees there is no activity at
the whole tree at the moment.

Thanks,
Jarek P.
