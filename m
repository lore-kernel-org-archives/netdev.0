From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 12:19:20 +0000
Message-ID: <20080821121920.GD4079@ff.dom.local>
References: <20080821101145.GA3963@ff.dom.local> <20080821101830.GB3963@ff.dom.local> <20080821102153.GB3789@gondor.apana.org.au> <20080821102338.GA3864@gondor.apana.org.au> <20080821103354.GA4079@ff.dom.local> <20080821105110.GA4088@gondor.apana.org.au> <20080821112055.GB4079@ff.dom.local> <20080821112609.GA5052@gondor.apana.org.au> <20080821115521.GC4079@ff.dom.local> <20080821120112.GA7705@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:11268 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751609AbYHUMT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 08:19:27 -0400
Received: by ug-out-1314.google.com with SMTP id c2so1014903ugf.37
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 05:19:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080821120112.GA7705@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 10:01:12PM +1000, Herbert Xu wrote:
> On Thu, Aug 21, 2008 at 11:55:22AM +0000, Jarek Poplawski wrote:
> > 
> > Sure, here is a scenario:
> > 
> > cpu1					cpu2
> > rtnl_lock()
> > qdisc_graft()
> > // parent != NULL
> > ->cops-graft()
> > notify_and_destroy()			qdisc_run()
> > 					spin_lock(root_lock)
> > qdisc_destroy(old)			dequeue_skb()
> > 					tbf_dequeue()
> > 					qdisc_tree_decrease_qlen()	
> > 					qdisc_lookup()
> > //deleting from qdisc_sleeping->list	//walking qdisc_sleeping->list
> > //under rtnl_lock() only		//under qdisc root_lock only
> > list_del(qdisc->list)			list_for_each_entry(txq_root)
> 
> Good catch.  Longer term we should fix it so that it doesn't do
> the silly lookup at run-time.  In fact we'll be getting rid of
> requeue so there will be no need to do this in TBF at all.
> 
> However, for now please create a patch to put a pair of root locks
> around the list_del in qdisc_destroy.

Since qdisc_destroy() is used for destroying root qdisc too, isn't it
better to get this lock back in notify_and_destroy() like this:

if (old) {
	if (parent)
		sch_tree_lock()
	qdisc_destroy()
	if (parent)
		sch_tree_unlock()
}
	

Thanks,
Jarek P.
