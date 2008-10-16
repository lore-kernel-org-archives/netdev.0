From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 2/6] pkt_sched: Add ->peek() methods for fifo, prio and SFQ
	qdiscs.
Date: Thu, 16 Oct 2008 09:47:26 +0000
Message-ID: <20081016094726.GC19019@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.187]:44142 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753816AbYJPJrd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 05:47:33 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1473854nfc.21
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2008 02:47:31 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>

Just as a demonstration how easy adding a peek operation to the
work-conserving qdiscs actually is. It doesn't need to keep or change
any internal state in many cases thanks to the guarantee that the
packet will either be dequeued or, if another packet arrives, the
upper qdisc will immediately ->peek again to reevaluate the state.

(This is only slightly modified Patrick's patch.)

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 include/net/sch_generic.h |    5 +++++
 net/sched/sch_fifo.c      |    2 ++
 net/sched/sch_prio.c      |   14 ++++++++++++++
 net/sched/sch_sfq.c       |   12 ++++++++++++
 4 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index f81f7c4..da6839a 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -433,6 +433,11 @@ static inline struct sk_buff *qdisc_dequeue_tail(struct Qdisc *sch)
 	return __qdisc_dequeue_tail(sch, &sch->q);
 }
 
+static inline struct sk_buff *qdisc_peek_head(struct Qdisc *sch)
+{
+	return skb_peek(&sch->q);
+}
+
 static inline int __qdisc_requeue(struct sk_buff *skb, struct Qdisc *sch,
 				  struct sk_buff_head *list)
 {
diff --git a/net/sched/sch_fifo.c b/net/sched/sch_fifo.c
index 23d258b..8825e88 100644
--- a/net/sched/sch_fifo.c
+++ b/net/sched/sch_fifo.c
@@ -83,6 +83,7 @@ struct Qdisc_ops pfifo_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct fifo_sched_data),
 	.enqueue	=	pfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
+	.peek		=	qdisc_peek_head,
 	.requeue	=	qdisc_requeue,
 	.drop		=	qdisc_queue_drop,
 	.init		=	fifo_init,
@@ -98,6 +99,7 @@ struct Qdisc_ops bfifo_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct fifo_sched_data),
 	.enqueue	=	bfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
+	.peek		=	qdisc_peek_head,
 	.requeue	=	qdisc_requeue,
 	.drop		=	qdisc_queue_drop,
 	.init		=	fifo_init,
diff --git a/net/sched/sch_prio.c b/net/sched/sch_prio.c
index 504a78c..3651da3 100644
--- a/net/sched/sch_prio.c
+++ b/net/sched/sch_prio.c
@@ -120,6 +120,19 @@ prio_requeue(struct sk_buff *skb, struct Qdisc* sch)
 	return ret;
 }
 
+static struct sk_buff *prio_peek(struct Qdisc *sch)
+{
+	struct prio_sched_data *q = qdisc_priv(sch);
+	int prio;
+
+	for (prio = 0; prio < q->bands; prio++) {
+		struct Qdisc *qdisc = q->queues[prio];
+		struct sk_buff *skb = qdisc->ops->peek(qdisc);
+		if (skb)
+			return skb;
+	}
+	return NULL;
+}
 
 static struct sk_buff *prio_dequeue(struct Qdisc* sch)
 {
@@ -421,6 +434,7 @@ static struct Qdisc_ops prio_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct prio_sched_data),
 	.enqueue	=	prio_enqueue,
 	.dequeue	=	prio_dequeue,
+	.peek		=	prio_peek,
 	.requeue	=	prio_requeue,
 	.drop		=	prio_drop,
 	.init		=	prio_init,
diff --git a/net/sched/sch_sfq.c b/net/sched/sch_sfq.c
index fe1508e..198b83d 100644
--- a/net/sched/sch_sfq.c
+++ b/net/sched/sch_sfq.c
@@ -391,8 +391,19 @@ sfq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 	return NET_XMIT_CN;
 }
 
+static struct sk_buff *
+sfq_peek(struct Qdisc *sch)
+{
+	struct sfq_sched_data *q = qdisc_priv(sch);
+	sfq_index a;
 
+	/* No active slots */
+	if (q->tail == SFQ_DEPTH)
+		return NULL;
 
+	a = q->next[q->tail];
+	return skb_peek(&q->qs[a]);
+}
 
 static struct sk_buff *
 sfq_dequeue(struct Qdisc *sch)
@@ -624,6 +635,7 @@ static struct Qdisc_ops sfq_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct sfq_sched_data),
 	.enqueue	=	sfq_enqueue,
 	.dequeue	=	sfq_dequeue,
+	.peek		=	sfq_peek,
 	.requeue	=	sfq_requeue,
 	.drop		=	sfq_drop,
 	.init		=	sfq_init,
-- 
1.5.6.5

