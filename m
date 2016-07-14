From: John Fastabend <john.fastabend@gmail.com>
Subject: [RFC PATCH v2 08/10] net: sched: pfifo_fast use alf_queue
Date: Wed, 13 Jul 2016 23:23:12 -0700
Message-ID: <20160714062312.8270.65942.stgit@john-Precision-Tower-5810>
References: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fw@strlen.de, jhs@mojatatu.com, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com, brouer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35450 "EHLO
	mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751390AbcGNGXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 02:23:33 -0400
Received: by mail-pf0-f196.google.com with SMTP id t190so4298013pfb.2
        for <netdev@vger.kernel.org>; Wed, 13 Jul 2016 23:23:33 -0700 (PDT)
In-Reply-To: <20160714061852.8270.66271.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This converts the pfifo_fast qdisc to use the alf_queue enqueue and
dequeue routines then sets the NOLOCK bit.

This also removes the logic used to pick the next band to dequeue from
and instead just checks each alf_queue for packets from top priority
to lowest. This might need to be a bit more clever but seems to work
for now.

Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
---
 net/sched/sch_generic.c |  131 +++++++++++++++++++++++++++--------------------
 1 file changed, 75 insertions(+), 56 deletions(-)

diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index 7dcd066..2ac3eb9 100644
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
@@ -555,88 +556,79 @@ static const u8 prio2band[TC_PRIO_MAX + 1] = {
 
 /*
  * Private data for a pfifo_fast scheduler containing:
- * 	- queues for the three band
- * 	- bitmap indicating which of the bands contain skbs
+ *	- rings for priority bands
  */
 struct pfifo_fast_priv {
-	u32 bitmap;
-	struct sk_buff_head q[PFIFO_FAST_BANDS];
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
-static inline struct sk_buff_head *band2list(struct pfifo_fast_priv *priv,
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
-	if (skb_queue_len(&qdisc->q) < qdisc_dev(qdisc)->tx_queue_len) {
-		int band = prio2band[skb->priority & TC_PRIO_MAX];
-		struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
-		struct sk_buff_head *list = band2list(priv, band);
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
+	struct sk_buff *skb = NULL;
+	int band;
 
-	if (likely(band >= 0)) {
-		struct sk_buff_head *list = band2list(priv, band);
-		struct sk_buff *skb = __qdisc_dequeue_head(qdisc, list);
+	for (band = 0; band < PFIFO_FAST_BANDS && !skb; band++) {
+		struct skb_array *q = band2list(priv, band);
 
-		qdisc->q.qlen--;
-		if (skb_queue_empty(list))
-			priv->bitmap &= ~(1 << band);
+		if (__skb_array_empty(q))
+			continue;
 
-		return skb;
+		skb = skb_array_consume_bh(q);
 	}
 
-	return NULL;
-}
-
-static struct sk_buff *pfifo_fast_peek(struct Qdisc *qdisc)
-{
-	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
-	int band = bitmap2band[priv->bitmap];
-
-	if (band >= 0) {
-		struct sk_buff_head *list = band2list(priv, band);
-
-		return skb_peek(list);
+	if (likely(skb)) {
+		qdisc_qstats_cpu_backlog_dec(qdisc, skb);
+		qdisc_bstats_cpu_update(qdisc, skb);
+		qdisc_qstats_cpu_qlen_dec(qdisc);
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
+			kfree_skb(skb);
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
@@ -654,24 +646,51 @@ nla_put_failure:
 
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
+		struct skb_array *q = band2list(priv, prio);
+		int err;
 
-	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++)
-		__skb_queue_head_init(band2list(priv, prio));
+		err = skb_array_init(q, qlen, GFP_KERNEL);
+		if (err)
+			return -ENOMEM;
+	}
 
 	/* Can by-pass the queue discipline */
 	qdisc->flags |= TCQ_F_CAN_BYPASS;
+	qdisc->flags |= TCQ_F_NOLOCK;
+	qdisc->flags |= TCQ_F_CPUSTATS;
+
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
 	.enqueue	=	pfifo_fast_enqueue,
 	.dequeue	=	pfifo_fast_dequeue,
-	.peek		=	pfifo_fast_peek,
+	.peek		=	qdisc_peek_dequeued,
 	.init		=	pfifo_fast_init,
+	.destroy	=	pfifo_fast_destroy,
 	.reset		=	pfifo_fast_reset,
 	.dump		=	pfifo_fast_dump,
 	.owner		=	THIS_MODULE,
