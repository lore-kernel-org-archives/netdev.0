From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [NET_SCHED]: Avoid requeue warning on dev_deactivate
Date: Thu, 10 May 2007 22:53:04 +1000
Message-ID: <20070510125304.GA26090@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3109 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755027AbXEJMxQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 08:53:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave:

While I'm looking at qdisc_restart I found that we might end up calling
noop_requeue on device shutdown which prints a warning unnecessarily.

[NET_SCHED]: Avoid requeue warning on dev_deactivate

When we relinquish queue_lock in qdisc_restart and then retake it for
requeueing, we might race against dev_deactivate and end up requeueing
onto noop_qdisc.  This causes a warning to be printed.

This patch fixes this by checking this before we requeue.  As an added
bonus, we can remove the same check in __qdisc_run which was added to
prevent dev->gso_skb from being requeued when we're shutting down.

Even though we've had to add a new conditional in its place, it's better
because it only happens on requeues rather than every single time that
qdisc_run is called.

For this to work we also need to move the clearing of gso_skb up in
dev_deactivate as now qdisc_restart can occur even after we wait for
__LINK_STATE_QDISC_RUNNING to clear (but it won't do anything as long
as the queue and gso_skb is already clear).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 5f04b06..4181910 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -161,7 +161,9 @@ static inline int qdisc_restart(struct net_device *dev)
 		 */
 
 requeue:
-		if (skb->next)
+		if (unlikely(q == &noop_qdisc))
+			kfree_skb(skb);
+		else if (skb->next)
 			dev->gso_skb = skb;
 		else
 			q->ops->requeue(skb, q);
@@ -176,15 +178,11 @@ out:
 
 void __qdisc_run(struct net_device *dev)
 {
-	if (unlikely(dev->qdisc == &noop_qdisc))
-		goto out;
-
 	do {
 		if (!qdisc_restart(dev))
 			break;
 	} while (!netif_queue_stopped(dev));
 
-out:
 	clear_bit(__LINK_STATE_QDISC_RUNNING, &dev->state);
 }
 
@@ -546,6 +544,7 @@ void dev_activate(struct net_device *dev)
 void dev_deactivate(struct net_device *dev)
 {
 	struct Qdisc *qdisc;
+	struct sk_buff *skb;
 
 	spin_lock_bh(&dev->queue_lock);
 	qdisc = dev->qdisc;
@@ -553,8 +552,12 @@ void dev_deactivate(struct net_device *dev)
 
 	qdisc_reset(qdisc);
 
+	skb = dev->gso_skb;
+	dev->gso_skb = NULL;
 	spin_unlock_bh(&dev->queue_lock);
 
+	kfree_skb(skb);
+
 	dev_watchdog_down(dev);
 
 	/* Wait for outstanding dev_queue_xmit calls. */
@@ -563,11 +566,6 @@ void dev_deactivate(struct net_device *dev)
 	/* Wait for outstanding qdisc_run calls. */
 	while (test_bit(__LINK_STATE_QDISC_RUNNING, &dev->state))
 		yield();
-
-	if (dev->gso_skb) {
-		kfree_skb(dev->gso_skb);
-		dev->gso_skb = NULL;
-	}
 }
 
 void dev_init_scheduler(struct net_device *dev)
