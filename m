From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH 03/13] net_sched: rename ->gso_skb to ->dequeued_skb
Date: Tue,  4 Nov 2014 09:56:26 -0800
Message-ID: <1415123796-8093-4-git-send-email-xiyou.wangcong@gmail.com>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:45375 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751901AbaKDR4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:56:49 -0500
Received: by mail-pa0-f47.google.com with SMTP id kx10so14919655pab.34
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:56:49 -0800 (PST)
In-Reply-To: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h | 16 ++++++++--------
 net/sched/sch_generic.c   | 14 +++++++-------
 2 files changed, 15 insertions(+), 15 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a690e6f..6320c18 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -80,7 +80,7 @@ struct Qdisc {
 
 	struct gnet_stats_rate_est64	rate_est;
 	struct Qdisc		*next_sched;
-	struct sk_buff		*gso_skb;
+	struct sk_buff		*dequeued_skb;
 	/*
 	 * For performance sake on SMP, we put highly modified fields at the end
 	 */
@@ -671,24 +671,24 @@ static inline struct sk_buff *qdisc_peek_head(struct Qdisc *sch)
 /* generic pseudo peek method for non-work-conserving qdisc */
 static inline struct sk_buff *qdisc_peek_dequeued(struct Qdisc *sch)
 {
-	/* we can reuse ->gso_skb because peek isn't called for root qdiscs */
-	if (!sch->gso_skb) {
-		sch->gso_skb = sch->dequeue(sch);
-		if (sch->gso_skb)
+	/* we can reuse ->dequeued_skb because peek isn't called for root qdiscs */
+	if (!sch->dequeued_skb) {
+		sch->dequeued_skb = sch->dequeue(sch);
+		if (sch->dequeued_skb)
 			/* it's still part of the queue */
 			sch->q.qlen++;
 	}
 
-	return sch->gso_skb;
+	return sch->dequeued_skb;
 }
 
 /* use instead of qdisc->dequeue() for all qdiscs queried with ->peek() */
 static inline struct sk_buff *qdisc_dequeue_peeked(struct Qdisc *sch)
 {
-	struct sk_buff *skb = sch->gso_skb;
+	struct sk_buff *skb = sch->dequeued_skb;
 
 	if (skb) {
-		sch->gso_skb = NULL;
+		sch->dequeued_skb = NULL;
 		sch->q.qlen--;
 	} else {
 		skb = sch->dequeue(sch);
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 6efca30..9feeb5c 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -47,7 +47,7 @@ EXPORT_SYMBOL(default_qdisc_ops);
 
 static inline int dev_requeue_skb(struct sk_buff *skb, struct Qdisc *q)
 {
-	q->gso_skb = skb;
+	q->dequeued_skb = skb;
 	q->qstats.requeues++;
 	q->q.qlen++;	/* it's still part of the queue */
 	__netif_schedule(q);
@@ -82,7 +82,7 @@ static void try_bulk_dequeue_skb(struct Qdisc *q,
 static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 				   int *packets)
 {
-	struct sk_buff *skb = q->gso_skb;
+	struct sk_buff *skb = q->dequeued_skb;
 	const struct netdev_queue *txq = q->dev_queue;
 
 	*packets = 1;
@@ -91,7 +91,7 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 		/* check the reason of requeuing without tx lock first */
 		txq = skb_get_tx_queue(txq->dev, skb);
 		if (!netif_xmit_frozen_or_stopped(txq)) {
-			q->gso_skb = NULL;
+			q->dequeued_skb = NULL;
 			q->q.qlen--;
 		} else
 			skb = NULL;
@@ -654,9 +654,9 @@ void qdisc_reset(struct Qdisc *qdisc)
 	if (ops->reset)
 		ops->reset(qdisc);
 
-	if (qdisc->gso_skb) {
-		kfree_skb_list(qdisc->gso_skb);
-		qdisc->gso_skb = NULL;
+	if (qdisc->dequeued_skb) {
+		kfree_skb_list(qdisc->dequeued_skb);
+		qdisc->dequeued_skb = NULL;
 		qdisc->q.qlen = 0;
 	}
 }
@@ -694,7 +694,7 @@ void qdisc_destroy(struct Qdisc *qdisc)
 	module_put(ops->owner);
 	dev_put(qdisc_dev(qdisc));
 
-	kfree_skb_list(qdisc->gso_skb);
+	kfree_skb_list(qdisc->dequeued_skb);
 	/*
 	 * gen_estimator est_timer() might access qdisc->q.lock,
 	 * wait a RCU grace period before freeing qdisc.
-- 
1.8.3.1
