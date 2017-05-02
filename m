From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 15/17] net: sched: pfifo_fast use skb_array
Date: Tue, 02 May 2017 08:40:51 -0700
Message-ID: <20170502154051.9304.37479.stgit@john-Precision-Tower-5810>
References: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33931 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750769AbdEBPlG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:41:06 -0400
Received: by mail-pg0-f68.google.com with SMTP id t7so23049618pgt.1
        for <netdev@vger.kernel.org>; Tue, 02 May 2017 08:41:06 -0700 (PDT)
In-Reply-To: <20170502153518.9304.17904.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This converts the pfifo_fast qdisc to use the skb_array data structure
and set the lockless qdisc bit.

This also removes the logic used to pick the next band to dequeue from
and instead just checks a per priority array for packets from top priority
to lowest. This might need to be a bit more clever but seems to work
for now.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/sch_generic.c |  134 ++++++++++++++++++++++++++++-------------------
 1 file changed, 81 insertions(+), 53 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index db5f7a0..be5a201 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -26,6 +26,7 @@
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/if_vlan.h>
+#include <linux/skb_array.h>
 #include <net/sch_generic.h>
 #include <net/pkt_sched.h>
 #include <net/dst.h>
@@ -578,93 +579,95 @@ struct Qdisc_ops noqueue_qdisc_ops __read_mostly = {
 
 /*
  * Private data for a pfifo_fast scheduler containing:
- * 	- queues for the three band
- * 	- bitmap indicating which of the bands contain skbs
+ *	- rings for priority bands
  */
 struct pfifo_fast_priv {
-	u32 bitmap;
-	struct qdisc_skb_head q[PFIFO_FAST_BANDS];
+	struct skb_array q[PFIFO_FAST_BANDS];
 };
 
-/*
- * Convert a bitmap to the first band number where an skb is queued, where:
- * 	bitmap=0 means there are no skbs on any band.
- * 	bitmap=1 means there is an skb on band 0.
- *	bitmap=7 means there are skbs on all 3 bands, etc.
- */
-static const int bitmap2band[] = {-1, 0, 1, 0, 2, 0, 1, 0};
-
-static inline struct qdisc_skb_head *band2list(struct pfifo_fast_priv *priv,
-					     int band)
+static inline struct skb_array *band2list(struct pfifo_fast_priv *priv,
+					  int band)
 {
-	return priv->q + band;
+	return &priv->q[band];
 }
 
 static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc,
 			      struct sk_buff **to_free)
 {
-	if (qdisc->q.qlen < qdisc_dev(qdisc)->tx_queue_len) {
-		int band = prio2band[skb->priority & TC_PRIO_MAX];
-		struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
-		struct qdisc_skb_head *list = band2list(priv, band);
-
-		priv->bitmap |= (1 << band);
-		qdisc->q.qlen++;
-		return __qdisc_enqueue_tail(skb, qdisc, list);
-	}
+	int band = prio2band[skb->priority & TC_PRIO_MAX];
+	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
+	struct skb_array *q = band2list(priv, band);
+	int err;
 
-	return qdisc_drop(skb, qdisc, to_free);
+	err = skb_array_produce_bh(q, skb);
+
+	if (unlikely(err))
+		return qdisc_drop_cpu(skb, qdisc, to_free);
+
+	qdisc_qstats_cpu_qlen_inc(qdisc);
+	qdisc_qstats_cpu_backlog_inc(qdisc, skb);
+	return NET_XMIT_SUCCESS;
 }
 
 static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
 {
 	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
-	int band = bitmap2band[priv->bitmap];
-
-	if (likely(band >= 0)) {
-		struct qdisc_skb_head *qh = band2list(priv, band);
-		struct sk_buff *skb = __qdisc_dequeue_head(qh);
+	struct sk_buff *skb = NULL;
+	int band;
 
-		if (likely(skb != NULL)) {
-			qdisc_qstats_backlog_dec(qdisc, skb);
-			qdisc_bstats_update(qdisc, skb);
-		}
+	for (band = 0; band < PFIFO_FAST_BANDS && !skb; band++) {
+		struct skb_array *q = band2list(priv, band);
 
-		qdisc->q.qlen--;
-		if (qh->qlen == 0)
-			priv->bitmap &= ~(1 << band);
+		if (__skb_array_empty(q))
+			continue;
 
-		return skb;
+		skb = skb_array_consume_bh(q);
+	}
+	if (likely(skb)) {
+		qdisc_qstats_cpu_backlog_dec(qdisc, skb);
+		qdisc_bstats_cpu_update(qdisc, skb);
+		qdisc_qstats_cpu_qlen_dec(qdisc);
 	}
 
-	return NULL;
+	return skb;
 }
 
 static struct sk_buff *pfifo_fast_peek(struct Qdisc *qdisc)
 {
 	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
-	int band = bitmap2band[priv->bitmap];
+	struct sk_buff *skb = NULL;
+	int band;
 
-	if (band >= 0) {
-		struct qdisc_skb_head *qh = band2list(priv, band);
+	for (band = 0; band < PFIFO_FAST_BANDS && !skb; band++) {
+		struct skb_array *q = band2list(priv, band);
 
-		return qh->head;
+		skb = skb_array_peek(q);
+		if (!skb)
+			continue;
 	}
 
-	return NULL;
+	return skb;
 }
 
 static void pfifo_fast_reset(struct Qdisc *qdisc)
 {
-	int prio;
+	int i, band;
 	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
 
-	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++)
-		__qdisc_reset_queue(band2list(priv, prio));
+	for (band = 0; band < PFIFO_FAST_BANDS; band++) {
+		struct skb_array *q = band2list(priv, band);
+		struct sk_buff *skb;
 
-	priv->bitmap = 0;
-	qdisc->qstats.backlog = 0;
-	qdisc->q.qlen = 0;
+		while ((skb = skb_array_consume_bh(q)) != NULL)
+			__skb_array_destroy_skb(skb);
+	}
+
+	for_each_possible_cpu(i) {
+		struct gnet_stats_queue *q = per_cpu_ptr(qdisc->cpu_qstats, i);
+
+		q->backlog = 0;
+		q->qlen = 0;
+	}
 }
 
 static int pfifo_fast_dump(struct Qdisc *qdisc, struct sk_buff *skb)
@@ -682,17 +685,40 @@ static int pfifo_fast_dump(struct Qdisc *qdisc, struct sk_buff *skb)
 
 static int pfifo_fast_init(struct Qdisc *qdisc, struct nlattr *opt)
 {
-	int prio;
+	unsigned int qlen = qdisc_dev(qdisc)->tx_queue_len;
 	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
+	int prio;
+
+	/* guard against zero length rings */
+	if (!qlen)
+		return -EINVAL;
 
-	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++)
-		qdisc_skb_head_init(band2list(priv, prio));
+	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++) {
+		struct skb_array *q = band2list(priv, prio);
+		int err;
+
+		err = skb_array_init(q, qlen, GFP_KERNEL);
+		if (err)
+			return -ENOMEM;
+	}
 
 	/* Can by-pass the queue discipline */
 	qdisc->flags |= TCQ_F_CAN_BYPASS;
 	return 0;
 }
 
+static void pfifo_fast_destroy(struct Qdisc *sch)
+{
+	struct pfifo_fast_priv *priv = qdisc_priv(sch);
+	int prio;
+
+	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++) {
+		struct skb_array *q = band2list(priv, prio);
+
+		skb_array_cleanup(q);
+	}
+}
+
 struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.id		=	"pfifo_fast",
 	.priv_size	=	sizeof(struct pfifo_fast_priv),
@@ -700,9 +726,11 @@ struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.dequeue	=	pfifo_fast_dequeue,
 	.peek		=	pfifo_fast_peek,
 	.init		=	pfifo_fast_init,
+	.destroy	=	pfifo_fast_destroy,
 	.reset		=	pfifo_fast_reset,
 	.dump		=	pfifo_fast_dump,
 	.owner		=	THIS_MODULE,
+	.static_flags	=	TCQ_F_NOLOCK | TCQ_F_CPUSTATS,
 };
 EXPORT_SYMBOL(pfifo_fast_ops);
 
