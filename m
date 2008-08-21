From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Thu, 21 Aug 2008 22:48:34 +1000
Message-ID: <20080821124834.GA8794@gondor.apana.org.au>
References: <20080821120112.GA7705@gondor.apana.org.au> <20080821121920.GD4079@ff.dom.local> <20080821122245.GA8533@gondor.apana.org.au> <20080821.052754.104318066.davem@davemloft.net> <20080821123538.GA8703@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, denys@visp.net.lb
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36241 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752839AbYHUMsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 08:48:40 -0400
Content-Disposition: inline
In-Reply-To: <20080821123538.GA8703@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 21, 2008 at 10:35:38PM +1000, Herbert Xu wrote:
>
> You're right, this doesn't work at all.  In fact it's been broken
> even before we removed the root lock.  The problem is that we used
> to have one big linked list for each device.  That was protected
> by the device qdisc lock.  Now we have one list for each txq and
> qdisc_lookup walks every single txq.  This means that no single
> qdisc root lock can protect this anymore.

How about going back to a single list per-device again? This list
is only used on the slow path (well anything that tries to walk
a potentially unbounded linked list is slow :), and qdisc_lookup
walks through everything anyway.

We'll need to then add a new lock to protect this list, until we
remove requeue.

Actually just doing the locking will be sufficient.  Something like
this totally untested patch (I've abused your tx global lock):

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index ef0efec..3f5f9b9 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -202,16 +202,25 @@ struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
 struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
 {
 	unsigned int i;
+	struct Qdisc *q;
+
+	spin_lock_bh(&dev->tx_global_lock);
 
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
-		struct Qdisc *q, *txq_root = txq->qdisc_sleeping;
+		struct Qdisc *txq_root = txq->qdisc_sleeping;
 
 		q = qdisc_match_from_root(txq_root, handle);
 		if (q)
-			return q;
+			goto unlock;
 	}
-	return qdisc_match_from_root(dev->rx_queue.qdisc_sleeping, handle);
+
+	q = qdisc_match_from_root(dev->rx_queue.qdisc_sleeping, handle);
+
+unlock:
+	spin_unlock_bh(&dev->tx_global_lock);
+
+	return q;
 }
 
 static struct Qdisc *qdisc_leaf(struct Qdisc *p, u32 classid)
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index c3ed4d4..292a373 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -526,8 +526,10 @@ void qdisc_destroy(struct Qdisc *qdisc)
 	    !atomic_dec_and_test(&qdisc->refcnt))
 		return;
 
+	spin_lock_bh(&dev->tx_global_lock);
 	if (qdisc->parent)
 		list_del(&qdisc->list);
+	spin_unlock_bh(&dev->tx_global_lock);
 
 #ifdef CONFIG_NET_SCHED
 	qdisc_put_stab(qdisc->stab);

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
