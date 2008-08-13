From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 12 Aug 2008 22:11:03 -0700 (PDT)
Message-ID: <20080812.221103.91087925.davem@davemloft.net>
References: <20080812.011510.20845920.davem@davemloft.net>
	<E1KT803-00086Y-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46616
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751198AbYHMFLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 01:11:03 -0400
In-Reply-To: <E1KT803-00086Y-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Wed, 13 Aug 2008 14:30:19 +1000

> David Miller <davem@davemloft.net> wrote:
> >
> > The qdisc pointer traverses to the softirq handler, which can be run
> > in a process context (via ksoftirqd), and this pointer gets there
> > via the per-cpu ->output_queue.
> 
> Here are two possible solutions:
> 
> 1) The active way: smp_call_function and forcibly remove the qdiscs
> in question from each output_queue.
> 
> 2) The passive way: Make dev_deactive call yield() until no qdisc's
> are on an output_queue.  This assumes there is some sort of dead
> flag detection on the output_queue side so it doesn't keep going
> forever.

Yes, we'll need some kind of dead flag it seems.

Another thing we can do is, in the yield loop, grabbing the
__QDISC_STATE_RUNNING bit.

But actually, I think Jarek has a point.

The existing loop there in dev_deactivate() should work _iff_ we make
it look at the proper qdisc.

This is another case where I didn't transform things correctly.  The
old code worked on dev->state since that's where we kept what used
to be __LINK_STATE_QDISC_RUNNING.

But now that state is kept in the qdisc itself.  But we just zapped
the active qdisc, so the old one is in ->qdisc_sleeping not ->qdisc.

So, just like one of Jarek's patches, we should simply change
dev_queue->qdisc into dev_queue->qdisc_sleeping and that should
take care of the bulk of the issues.

Shouldn't it?

Hmmm... maybe we have to sample __QDISC_STATE_SCHED too.


