From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 22:01:12 +1000
Message-ID: <20080821120112.GA7705@gondor.apana.org.au>
References: <20080821.030523.205239441.davem@davemloft.net> <20080821101145.GA3963@ff.dom.local> <20080821101830.GB3963@ff.dom.local> <20080821102153.GB3789@gondor.apana.org.au> <20080821102338.GA3864@gondor.apana.org.au> <20080821103354.GA4079@ff.dom.local> <20080821105110.GA4088@gondor.apana.org.au> <20080821112055.GB4079@ff.dom.local> <20080821112609.GA5052@gondor.apana.org.au> <20080821115521.GC4079@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:51772 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752810AbYHUMBT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 08:01:19 -0400
Content-Disposition: inline
In-Reply-To: <20080821115521.GC4079@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 11:55:22AM +0000, Jarek Poplawski wrote:
> 
> Sure, here is a scenario:
> 
> cpu1					cpu2
> rtnl_lock()
> qdisc_graft()
> // parent != NULL
> ->cops-graft()
> notify_and_destroy()			qdisc_run()
> 					spin_lock(root_lock)
> qdisc_destroy(old)			dequeue_skb()
> 					tbf_dequeue()
> 					qdisc_tree_decrease_qlen()	
> 					qdisc_lookup()
> //deleting from qdisc_sleeping->list	//walking qdisc_sleeping->list
> //under rtnl_lock() only		//under qdisc root_lock only
> list_del(qdisc->list)			list_for_each_entry(txq_root)

Good catch.  Longer term we should fix it so that it doesn't do
the silly lookup at run-time.  In fact we'll be getting rid of
requeue so there will be no need to do this in TBF at all.

However, for now please create a patch to put a pair of root locks
around the list_del in qdisc_destroy.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
