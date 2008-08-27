From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 1/2] pkt_sched: Fix gen_estimator locks
Date: Wed, 27 Aug 2008 11:09:39 +0000
Message-ID: <20080827110938.GB7258@ff.dom.local>
References: <20080827095549.GA12583@gondor.apana.org.au> <20080827.025747.197547570.davem@davemloft.net> <20080827104457.GA7258@ff.dom.local> <20080827.034723.73512507.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:64566 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305AbYH0LJp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Aug 2008 07:09:45 -0400
Received: by ug-out-1314.google.com with SMTP id c2so898808ugf.37
        for <netdev@vger.kernel.org>; Wed, 27 Aug 2008 04:09:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080827.034723.73512507.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 27, 2008 at 03:47:23AM -0700, David Miller wrote:
> From: Jarek Poplawski <jarkao2@gmail.com>
> Date: Wed, 27 Aug 2008 10:44:58 +0000
> 
> > Yes, it should be simpler. (We can probably consider a pointer to
> > itself instead of NULL for root qdiscs, to skip testing for NULL e.g.
> > while getting a lock.) On the other hand, we lose with this the
> > possibility to easily determine which dev_queue is "the owner" of the
> > qdisc, or if some dev_queue contains a clone only.
> 
> For root qdiscs we can add a TCQ_F_SHARED flag for this purpose.

Yes, but we can't do something like this:

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index e7fb9e0..a7f508c 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -235,6 +235,9 @@ struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
 		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
 		struct Qdisc *txq_root = txq->qdisc_sleeping;
 
+		/* skip the clones */
+		if (txq_root->dev_queue != txq)
+			continue;
 		q = qdisc_match_from_root(txq_root, handle);
 		if (q)
 			goto unlock;

Jarek P.
