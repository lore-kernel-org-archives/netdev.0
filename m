From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Mon, 18 Aug 2008 11:25:16 +1000
Message-ID: <20080818012516.GB31337@gondor.apana.org.au>
References: <20080814084429.GB12217@ff.dom.local> <20080814085250.GC12217@ff.dom.local> <20080817.155723.214209606.davem@davemloft.net> <20080817.160329.121812684.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:41282 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751002AbYHRBZW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Aug 2008 21:25:22 -0400
Content-Disposition: inline
In-Reply-To: <20080817.160329.121812684.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 17, 2008 at 04:03:29PM -0700, David Miller wrote:
> 
> I thought about it some more, but there is still the dev_queue_xmit()
> context that can have a reference to the old qdisc, be about to take
> the qdisc lock and feed packets into it's ->enqueue().
> 
> That's why we need the RCU destruction still.  dev_deactivate() really
> doesn't clear out all references to the qdisc fully.
> 
> It might be a better approach to work on making that simply not matter,
> and just rely on RCU or similar to defer destruction and any real state
> changes internally to the qdisc tree will simply use the root qdisc's
> lock to block out enqueue/dequeue/requeue calls.
> 
> In that kind of scheme dev_deactivate() just sets the RCU pointer and
> doesn't sit around waiting for anything.

Well one of the advantages of it being synchronous is that the
driver may be relying on this so that it knows all transmissions
have ceased in dev_close.  If we stick with RCU then drivers would
have to implement their own synchronisation anyway.

So what's the issue with dev_queue_xmit? That should be taken care
of by something like rcu_barrier_bh, no?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
