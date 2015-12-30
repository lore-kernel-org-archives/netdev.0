From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH 09/12] net: sched: pfifo_fast use alf_queue
Date: Wed, 30 Dec 2015 09:54:20 -0800
Message-ID: <20151230175420.26257.868.stgit@john-Precision-Tower-5810>
References: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com
To: daniel@iogearbox.net, eric.dumazet@gmail.com, jhs@mojatatu.com,
	aduyck@mirantis.com, brouer@redhat.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33306 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754866AbbL3Ryj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:54:39 -0500
Received: by mail-pa0-f47.google.com with SMTP id cy9so141191346pac.0
        for <netdev@vger.kernel.org>; Wed, 30 Dec 2015 09:54:38 -0800 (PST)
In-Reply-To: <20151230175000.26257.41532.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This converts the pfifo_fast qdisc to use the alf_queue enqueue
and dequeue routines then sets the NOLOCK bit.

This also removes the logic used to pick the next band to dequeue
from and instead just checks each alf_queue for packets from
top priority to lowest. This might need to be a bit more clever
but seems to work for now.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/sch_generic.c |  120 +++++++++++++++++++++++++----------------------
 1 file changed, 65 insertions(+), 55 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index be5d63a..480cf63 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -26,6 +26,7 @@
 #include <linux/list.h>
 #include <linux/slab.h>
 #include <linux/if_vlan.h>
+#include <linux/alf_queue.h>
 #include <net/sch_generic.h>
 #include <net/pkt_sched.h>
 #include <net/dst.h>
@@ -467,87 +468,80 @@ static const u8 prio2band[TC_PRIO_MAX + 1] = {
 
 /*
  * Private data for a pfifo_fast scheduler containing:
- * 	- queues for the three band
- * 	- bitmap indicating which of the bands contain skbs
+ *	- rings for the priority bands
  */
 struct pfifo_fast_priv {
-	u32 bitmap;
-	struct sk_buff_head q[PFIFO_FAST_BANDS];
+	struct alf_queue *q[PFIFO_FAST_BANDS];
 };
 
-/*
- * Convert a bitmap to the first band number where an skb is queued, where:
- * 	bitmap=0 means there are no skbs on any band.
- * 	bitmap=1 means there is an skb on band 0.
- *	bitmap=7 means there are skbs on all 3 bands, etc.
- */
-static const int bitmap2band[] = {-1, 0, 1, 0, 2, 0, 1, 0};
-
-static inline struct sk_buff_head *band2list(struct pfifo_fast_priv *priv,
-					     int band)
+static inline struct alf_queue *band2list(struct pfifo_fast_priv *priv,
+					  int band)
 {
-	return priv->q + band;
+	return priv->q[band];
 }
 
 static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc *qdisc)
 {
-	if (skb_queue_len(&qdisc->q) < qdisc_dev(qdisc)->tx_queue_len) {
-		int band = prio2band[skb->priority & TC_PRIO_MAX];
-		struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
-		struct sk_buff_head *list = band2list(priv, band);
-
-		priv->bitmap |= (1 << band);
-		qdisc->q.qlen++;
-		return __qdisc_enqueue_tail(skb, qdisc, list);
-	}
-
-	return qdisc_drop(skb, qdisc);
-}
-
-static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
-{
+	int band = prio2band[skb->priority & TC_PRIO_MAX];
 	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
-	int band = bitmap2band[priv->bitmap];
+	struct alf_queue *q = band2list(priv, band);
+	int n;
 
-	if (likely(band >= 0)) {
-		struct sk_buff_head *list = band2list(priv, band);
-		struct sk_buff *skb = __qdisc_dequeue_head(qdisc, list);
+	if (!q) {
+		WARN_ON(1);
+		return qdisc_drop(skb, qdisc);
+	}
 
-		qdisc->q.qlen--;
-		if (skb_queue_empty(list))
-			priv->bitmap &= ~(1 << band);
+	n = alf_mp_enqueue(q, &skb, 1);
 
-		return skb;
+	/* If queue is overrun fall through to drop */
+	if (n) {
+		qdisc_qstats_cpu_qlen_inc(qdisc);
+		qdisc_qstats_cpu_backlog_inc(qdisc, skb);
+		return NET_XMIT_SUCCESS;
 	}
 
-	return NULL;
+	return qdisc_drop_cpu(skb, qdisc);
 }
 
-static struct sk_buff *pfifo_fast_peek(struct Qdisc *qdisc)
+static struct sk_buff *pfifo_fast_dequeue(struct Qdisc *qdisc)
 {
 	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
-	int band = bitmap2band[priv->bitmap];
+	struct sk_buff *skb = NULL;
+	int band;
+
+	for (band = 0; band < PFIFO_FAST_BANDS && !skb; band++) {
+		struct alf_queue *q = band2list(priv, band);
 
-	if (band >= 0) {
-		struct sk_buff_head *list = band2list(priv, band);
+		if (alf_queue_empty(q))
+			continue;
 
-		return skb_peek(list);
+		alf_mc_dequeue(q, &skb, 1);
 	}
 
-	return NULL;
+	if (likely(skb)) {
+		qdisc_qstats_cpu_backlog_dec(qdisc, skb);
+		qdisc_bstats_cpu_update(qdisc, skb);
+		qdisc_qstats_cpu_qlen_dec(qdisc);
+	}
+
+	return skb;
 }
 
 static void pfifo_fast_reset(struct Qdisc *qdisc)
 {
-	int prio;
+	int i, band;
 	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
 
-	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++)
-		__qdisc_reset_queue(qdisc, band2list(priv, prio));
+	for (band = 0; band < PFIFO_FAST_BANDS; band++)
+		alf_queue_flush(band2list(priv, band));
 
-	priv->bitmap = 0;
-	qdisc->qstats.backlog = 0;
-	qdisc->q.qlen = 0;
+	for_each_possible_cpu(i) {
+		struct gnet_stats_queue *q = per_cpu_ptr(qdisc->cpu_qstats, i);
+
+		q->backlog = 0;
+		q->qlen = 0;
+	}
 }
 
 static int pfifo_fast_dump(struct Qdisc *qdisc, struct sk_buff *skb)
@@ -565,14 +559,30 @@ nla_put_failure:
 
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
+
+	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++) {
+		unsigned int size = roundup_pow_of_two(qlen);
+		struct alf_queue *q;
 
-	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++)
-		__skb_queue_head_init(band2list(priv, prio));
+		q = alf_queue_alloc(size, GFP_KERNEL);
+		if (IS_ERR_OR_NULL(q))
+			return -ENOMEM;
+
+		priv->q[prio] = q;
+	}
 
 	/* Can by-pass the queue discipline */
 	qdisc->flags |= TCQ_F_CAN_BYPASS;
+	qdisc->flags |= TCQ_F_NOLOCK;
+	qdisc->flags |= TCQ_F_CPUSTATS;
+
 	return 0;
 }
 
@@ -581,7 +591,7 @@ struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.priv_size	=	sizeof(struct pfifo_fast_priv),
 	.enqueue	=	pfifo_fast_enqueue,
 	.dequeue	=	pfifo_fast_dequeue,
-	.peek		=	pfifo_fast_peek,
+	.peek		=	qdisc_peek_dequeued,
 	.init		=	pfifo_fast_init,
 	.reset		=	pfifo_fast_reset,
 	.dump		=	pfifo_fast_dump,
