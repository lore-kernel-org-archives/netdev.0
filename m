From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Mon, 18 Aug 2008 21:07:01 -0700 (PDT)
Message-ID: <20080818.210701.80578862.davem@davemloft.net>
References: <20080818.165411.255925269.davem@davemloft.net>
	<20080819000551.GA26699@gondor.apana.org.au>
	<20080818.171124.192743795.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, netdev@vger.kernel.org, denys@visp.net.lb
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42606
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751110AbYHSEHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Aug 2008 00:07:02 -0400
In-Reply-To: <20080818.171124.192743795.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 18 Aug 2008 17:11:24 -0700 (PDT)

> Especially since we've bullet-proof'd dev_deactivate(), there
> should be absolutely no more references to the qdisc any
> longer.
> 
> I'll look into doing it this way, thanks.

Ok, here it is.  I'll push this out to net-2.6 after I do
some testing here.

pkt_sched: Don't hold qdisc lock over qdisc_destroy().

Based upon reports by Denys Fedoryshchenko, and feedback
and help from Jarek Poplawski and Herbert Xu.

We always either:

1) Never made an external reference to this qdisc.

or

2) Did a dev_deactivate() which purged all asynchronous
   references.

So do not lock the qdisc when we call qdisc_destroy(),
it's illegal anyways as when we drop the lock this is
free'd memory.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_api.c     |   13 ++-----------
 net/sched/sch_generic.c |    6 ------
 2 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 7d7070b..d91a233 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -638,11 +638,8 @@ static void notify_and_destroy(struct sk_buff *skb, struct nlmsghdr *n, u32 clid
 	if (new || old)
 		qdisc_notify(skb, n, clid, old, new);
 
-	if (old) {
-		sch_tree_lock(old);
+	if (old)
 		qdisc_destroy(old);
-		sch_tree_unlock(old);
-	}
 }
 
 /* Graft qdisc "new" to class "classid" of qdisc "parent" or
@@ -1092,16 +1089,10 @@ create_n_graft:
 
 graft:
 	if (1) {
-		spinlock_t *root_lock;
-
 		err = qdisc_graft(dev, p, skb, n, clid, q, NULL);
 		if (err) {
-			if (q) {
-				root_lock = qdisc_root_lock(q);
-				spin_lock_bh(root_lock);
+			if (q)
 				qdisc_destroy(q);
-				spin_unlock_bh(root_lock);
-			}
 			return err;
 		}
 	}
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6f96b7b..c3ed4d4 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -518,8 +518,6 @@ void qdisc_reset(struct Qdisc *qdisc)
 }
 EXPORT_SYMBOL(qdisc_reset);
 
-/* Under qdisc_lock(qdisc) and BH! */
-
 void qdisc_destroy(struct Qdisc *qdisc)
 {
 	const struct Qdisc_ops  *ops = qdisc->ops;
@@ -712,14 +710,10 @@ static void shutdown_scheduler_queue(struct net_device *dev,
 	struct Qdisc *qdisc_default = _qdisc_default;
 
 	if (qdisc) {
-		spinlock_t *root_lock = qdisc_lock(qdisc);
-
 		dev_queue->qdisc = qdisc_default;
 		dev_queue->qdisc_sleeping = qdisc_default;
 
-		spin_lock_bh(root_lock);
 		qdisc_destroy(qdisc);
-		spin_unlock_bh(root_lock);
 	}
 }
 
-- 
1.5.6.5.GIT

