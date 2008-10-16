From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 6/6] pkt_sched: Add peek emulation for non-work-conserving
	qdiscs.
Date: Thu, 16 Oct 2008 09:48:39 +0000
Message-ID: <20081016094839.GG19019@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:47947 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754338AbYJPJsp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 05:48:45 -0400
Received: by nf-out-0910.google.com with SMTP id d3so1473995nfc.21
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2008 02:48:44 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch adds qdisc_peek_dequeued() wrapper to emulate peek method
with qdisc->dequeue() and storing "peeked" skb in qdisc->gso_skb until
dequeuing. This is mainly for compatibility reasons not to break some
strange configs because peeking is expected for non-work-conserving
parent qdiscs to query work-conserving child qdiscs.

This implementation requires using qdisc_dequeue_peeked() wrapper
instead of directly calling qdisc->dequeue() for all qdiscs ever
querried with qdisc->ops->peek() or qdisc_peek_dequeued().

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 include/net/sch_generic.h |   23 +++++++++++++++++++++++
 net/sched/sch_atm.c       |    4 ++--
 net/sched/sch_cbq.c       |    1 +
 net/sched/sch_hfsc.c      |    3 ++-
 net/sched/sch_htb.c       |    1 +
 net/sched/sch_netem.c     |    5 +++--
 net/sched/sch_tbf.c       |    3 ++-
 7 files changed, 34 insertions(+), 6 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index da6839a..9dcb5bf 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -438,6 +438,29 @@ static inline struct sk_buff *qdisc_peek_head(struct Qdisc *sch)
 	return skb_peek(&sch->q);
 }
 
+/* generic pseudo peek method for non-work-conserving qdisc */
+static inline struct sk_buff *qdisc_peek_dequeued(struct Qdisc *sch)
+{
+	/* we can reuse ->gso_skb because peek isn't called for root qdiscs */
+	if (!sch->gso_skb)
+		sch->gso_skb = sch->dequeue(sch);
+
+	return sch->gso_skb;
+}
+
+/* use instead of qdisc->dequeue() for all qdiscs queried with ->peek() */
+static inline struct sk_buff *qdisc_dequeue_peeked(struct Qdisc *sch)
+{
+	struct sk_buff *skb = sch->gso_skb;
+
+	if (skb)
+		sch->gso_skb = NULL;
+	else
+		skb = sch->dequeue(sch);
+
+	return skb;
+}
+
 static inline int __qdisc_requeue(struct sk_buff *skb, struct Qdisc *sch,
 				  struct sk_buff_head *list)
 {
diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 2ee0c1a..6eb9a65 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -484,7 +484,7 @@ static void sch_atm_dequeue(unsigned long data)
 			if (!atm_may_send(flow->vcc, skb->truesize))
 				break;
 
-			skb = flow->q->dequeue(flow->q);
+			skb = qdisc_dequeue_peeked(flow->q);
 			if (unlikely(!skb))
 				break;
 
@@ -519,7 +519,7 @@ static struct sk_buff *atm_tc_dequeue(struct Qdisc *sch)
 
 	pr_debug("atm_tc_dequeue(sch %p,[qdisc %p])\n", sch, p);
 	tasklet_schedule(&p->task);
-	skb = p->link.q->dequeue(p->link.q);
+	skb = qdisc_dequeue_peeked(p->link.q);
 	if (skb)
 		sch->q.qlen--;
 	return skb;
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 8b06fa9..3447b54 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -2065,6 +2065,7 @@ static struct Qdisc_ops cbq_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct cbq_sched_data),
 	.enqueue	=	cbq_enqueue,
 	.dequeue	=	cbq_dequeue,
+	.peek		=	qdisc_peek_dequeued,
 	.requeue	=	cbq_requeue,
 	.drop		=	cbq_drop,
 	.init		=	cbq_init,
diff --git a/net/sched/sch_hfsc.c b/net/sched/sch_hfsc.c
index ddfc408..d90b165 100644
--- a/net/sched/sch_hfsc.c
+++ b/net/sched/sch_hfsc.c
@@ -1634,7 +1634,7 @@ hfsc_dequeue(struct Qdisc *sch)
 		}
 	}
 
-	skb = cl->qdisc->dequeue(cl->qdisc);
+	skb = qdisc_dequeue_peeked(cl->qdisc);
 	if (skb == NULL) {
 		if (net_ratelimit())
 			printk("HFSC: Non-work-conserving qdisc ?\n");
@@ -1727,6 +1727,7 @@ static struct Qdisc_ops hfsc_qdisc_ops __read_mostly = {
 	.dump		= hfsc_dump_qdisc,
 	.enqueue	= hfsc_enqueue,
 	.dequeue	= hfsc_dequeue,
+	.peek		= qdisc_peek_dequeued,
 	.requeue	= hfsc_requeue,
 	.drop		= hfsc_drop,
 	.cl_ops		= &hfsc_class_ops,
diff --git a/net/sched/sch_htb.c b/net/sched/sch_htb.c
index d14f020..3fda819 100644
--- a/net/sched/sch_htb.c
+++ b/net/sched/sch_htb.c
@@ -1565,6 +1565,7 @@ static struct Qdisc_ops htb_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct htb_sched),
 	.enqueue	=	htb_enqueue,
 	.dequeue	=	htb_dequeue,
+	.peek		=	qdisc_peek_dequeued,
 	.requeue	=	htb_requeue,
 	.drop		=	htb_drop,
 	.init		=	htb_init,
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 74fbdb5..3080bd6 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -290,8 +290,8 @@ static struct sk_buff *netem_dequeue(struct Qdisc *sch)
 
 		/* if more time remaining? */
 		if (cb->time_to_send <= now) {
-			skb = q->qdisc->dequeue(q->qdisc);
-			if (!skb)
+			skb = qdisc_dequeue_peeked(q->qdisc);
+			if (unlikely(!skb))
 				return NULL;
 
 			pr_debug("netem_dequeue: return skb=%p\n", skb);
@@ -714,6 +714,7 @@ static struct Qdisc_ops netem_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct netem_sched_data),
 	.enqueue	=	netem_enqueue,
 	.dequeue	=	netem_dequeue,
+	.peek		=	qdisc_peek_dequeued,
 	.requeue	=	netem_requeue,
 	.drop		=	netem_drop,
 	.init		=	netem_init,
diff --git a/net/sched/sch_tbf.c b/net/sched/sch_tbf.c
index 61fdc77..435076c 100644
--- a/net/sched/sch_tbf.c
+++ b/net/sched/sch_tbf.c
@@ -192,7 +192,7 @@ static struct sk_buff *tbf_dequeue(struct Qdisc* sch)
 		toks -= L2T(q, len);
 
 		if ((toks|ptoks) >= 0) {
-			skb = q->qdisc->dequeue(q->qdisc);
+			skb = qdisc_dequeue_peeked(q->qdisc);
 			if (unlikely(!skb))
 				return NULL;
 
@@ -467,6 +467,7 @@ static struct Qdisc_ops tbf_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct tbf_sched_data),
 	.enqueue	=	tbf_enqueue,
 	.dequeue	=	tbf_dequeue,
+	.peek		=	qdisc_peek_dequeued,
 	.requeue	=	tbf_requeue,
 	.drop		=	tbf_drop,
 	.init		=	tbf_init,
-- 
1.5.6.5

