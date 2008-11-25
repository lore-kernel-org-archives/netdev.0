From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH] pkt_sched: sch_api: Remove qdisc_list_lock
Date: Tue, 25 Nov 2008 11:29:41 +0000
Message-ID: <20081125112941.GA8136@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:3456 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750963AbYKYL3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 06:29:48 -0500
Received: by nf-out-0910.google.com with SMTP id d3so1287670nfc.21
        for <netdev@vger.kernel.org>; Tue, 25 Nov 2008 03:29:46 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After implementing qdisc->ops->peek() there is no more calling
qdisc_tree_decrease_qlen() without rtnl_lock(), so qdisc_list_lock
added by commit: f6e0b239a2657ea8cb67f0d83d0bfdbfd19a481b "pkt_sched:
Fix qdisc list locking" can be removed.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---

 net/sched/sch_api.c |   25 ++++---------------------
 1 files changed, 4 insertions(+), 21 deletions(-)

diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 1ef25e6..3fcfd4e 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -204,28 +204,16 @@ struct Qdisc *qdisc_match_from_root(struct Qdisc *root, u32 handle)
 	return NULL;
 }
 
-/*
- * This lock is needed until some qdiscs stop calling qdisc_tree_decrease_qlen()
- * without rtnl_lock(); currently hfsc_dequeue(), netem_dequeue(), tbf_dequeue()
- */
-static DEFINE_SPINLOCK(qdisc_list_lock);
-
 static void qdisc_list_add(struct Qdisc *q)
 {
-	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS)) {
-		spin_lock_bh(&qdisc_list_lock);
+	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS))
 		list_add_tail(&q->list, &qdisc_root_sleeping(q)->list);
-		spin_unlock_bh(&qdisc_list_lock);
-	}
 }
 
 void qdisc_list_del(struct Qdisc *q)
 {
-	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS)) {
-		spin_lock_bh(&qdisc_list_lock);
+	if ((q->parent != TC_H_ROOT) && !(q->flags & TCQ_F_INGRESS))
 		list_del(&q->list);
-		spin_unlock_bh(&qdisc_list_lock);
-	}
 }
 EXPORT_SYMBOL(qdisc_list_del);
 
@@ -234,22 +222,17 @@ struct Qdisc *qdisc_lookup(struct net_device *dev, u32 handle)
 	unsigned int i;
 	struct Qdisc *q;
 
-	spin_lock_bh(&qdisc_list_lock);
-
 	for (i = 0; i < dev->num_tx_queues; i++) {
 		struct netdev_queue *txq = netdev_get_tx_queue(dev, i);
 		struct Qdisc *txq_root = txq->qdisc_sleeping;
 
 		q = qdisc_match_from_root(txq_root, handle);
 		if (q)
-			goto unlock;
+			goto out;
 	}
 
 	q = qdisc_match_from_root(dev->rx_queue.qdisc_sleeping, handle);
-
-unlock:
-	spin_unlock_bh(&qdisc_list_lock);
-
+out:
 	return q;
 }
 
