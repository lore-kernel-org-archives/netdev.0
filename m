From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 11:55:22 +0000
Message-ID: <20080821115521.GC4079@ff.dom.local>
References: <20080821100155.GA3621@ff.dom.local> <20080821.030523.205239441.davem@davemloft.net> <20080821101145.GA3963@ff.dom.local> <20080821101830.GB3963@ff.dom.local> <20080821102153.GB3789@gondor.apana.org.au> <20080821102338.GA3864@gondor.apana.org.au> <20080821103354.GA4079@ff.dom.local> <20080821105110.GA4088@gondor.apana.org.au> <20080821112055.GB4079@ff.dom.local> <20080821112609.GA5052@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	denys@visp.net.lb
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:13017 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbYHULz2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 07:55:28 -0400
Received: by ug-out-1314.google.com with SMTP id c2so1010119ugf.37
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 04:55:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080821112609.GA5052@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 09:26:09PM +1000, Herbert Xu wrote:
> On Thu, Aug 21, 2008 at 11:20:56AM +0000, Jarek Poplawski wrote:
> >
> > I thought I described the problem quite clearly, except this error in
> > the lock name. I certainly can miss much more things than you. And,
> > after your answer I'm simply not sure if the question is still valid.
> 
> OK I've lost track of what you were trying to say.  Could you please
> just restate the problem you saw?
> 

Sure, here is a scenario:

cpu1					cpu2
rtnl_lock()
qdisc_graft()
// parent != NULL
->cops-graft()
notify_and_destroy()			qdisc_run()
					spin_lock(root_lock)
qdisc_destroy(old)			dequeue_skb()
					tbf_dequeue()
					qdisc_tree_decrease_qlen()	
					qdisc_lookup()
//deleting from qdisc_sleeping->list	//walking qdisc_sleeping->list
//under rtnl_lock() only		//under qdisc root_lock only
list_del(qdisc->list)			list_for_each_entry(txq_root)


Jarek P.
