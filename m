From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 17/17] net: sched: lock once per bulk dequeue
Date: Tue, 02 May 2017 08:41:29 -0700
Message-ID: <20170502154129.9304.19974.stgit@john-Precision-Tower-5810>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33003 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750752AbdEBPlm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:41:42 -0400
Received: by mail-pg0-f68.google.com with SMTP id s62so11402984pgc.0
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:41:41 -0700 (PDT)
In-Reply-To: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


---
 net/sched/sch_generic.c |   53 +++++++++++++++++++++--------------------------
 1 file changed, 24 insertions(+), 29 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index be5a201..0f0831a 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -205,33 +205,22 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 {
 	const struct netdev_queue *txq = q->dev_queue;
 	struct sk_buff *skb = NULL;
+	spinlock_t *lock = NULL;
 
-	*packets = 1;
-	if (unlikely(!skb_queue_empty(&q->gso_skb))) {
-		spinlock_t *lock = NULL;
-
-		if (q->flags & TCQ_F_NOLOCK) {
-			lock = qdisc_lock(q);
-			spin_lock(lock);
-		}
-
-		skb = skb_peek(&q->gso_skb);
-
-		/* skb may be null if another cpu pulls gso_skb off in between
-		 * empty check and lock.
-		 */
-		if (!skb) {
-			if (lock)
-				spin_unlock(lock);
-			goto validate;
-		}
+	if (q->flags & TCQ_F_NOLOCK) {
+		lock = qdisc_lock(q);
+		spin_lock(lock);
+	}
 
+	*packets = 1;
+	skb = skb_peek(&q->gso_skb);
+	if (unlikely(skb)) {
 		/* skb in gso_skb were already validated */
 		*validate = false;
 		/* check the reason of requeuing without tx lock first */
 		txq = skb_get_tx_queue(txq->dev, skb);
 		if (!netif_xmit_frozen_or_stopped(txq)) {
-			skb = __skb_dequeue(&q->gso_skb);
+			__skb_unlink(skb, &q->gso_skb);
 			if (qdisc_is_percpu_stats(q)) {
 				qdisc_qstats_cpu_backlog_dec(q, skb);
 				qdisc_qstats_cpu_qlen_dec(q);
@@ -246,17 +235,18 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 			spin_unlock(lock);
 		return skb;
 	}
-validate:
-	*validate = true;
 
-	if ((q->flags & TCQ_F_ONETXQUEUE) &&
-	    netif_xmit_frozen_or_stopped(txq))
-		return skb;
+	*validate = true;
 
 	skb = qdisc_dequeue_skb_bad_txq(q);
-	if (unlikely(skb))
+	if (unlikely(skb)) {
 		goto bulk;
-	skb = q->dequeue(q);
+	}
+
+	if (!(q->flags & TCQ_F_ONETXQUEUE) ||
+	    !netif_xmit_frozen_or_stopped(txq))
+		skb = q->dequeue(q);
+
 	if (skb) {
 bulk:
 		if (qdisc_may_bulk(q))
@@ -264,6 +254,11 @@ static struct sk_buff *dequeue_skb(struct Qdisc *q, bool *validate,
 		else
 			try_bulk_dequeue_skb_slow(q, skb, packets);
 	}
+
+blocked:
+	if (lock)
+		spin_unlock(lock);
+
 	return skb;
 }
 
@@ -621,7 +616,7 @@ static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
 		if (__skb_array_empty(q))
 			continue;
 
-		skb = skb_array_consume_bh(q);
+		skb = __skb_array_consume(q);
 	}
 	if (likely(skb)) {
 		qdisc_qstats_cpu_backlog_dec(qdisc, skb);
@@ -658,7 +653,7 @@ static void pfifo_fast_reset(struct Qdisc *qdisc)
 		struct skb_array *q = band2list(priv, band);
 		struct sk_buff *skb;
 
-		while ((skb = skb_array_consume_bh(q)) != NULL)
+		while ((skb = __skb_array_consume(q)) != NULL)
 			__skb_array_destroy_skb(skb);
 	}
 
