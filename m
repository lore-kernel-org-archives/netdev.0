From: Jarek Poplawski <jarkao2@gmail.com>
Subject: [PATCH 4/6] pkt_sched: Add qdisc->ops->peek() implementation.
Date: Thu, 16 Oct 2008 09:48:04 +0000
Message-ID: <20081016094804.GE19019@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.179]:56856 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754287AbYJPJsM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Oct 2008 05:48:12 -0400
Received: by ik-out-1112.google.com with SMTP id c30so2382006ika.5
        for <netdev@vger.kernel.org>; Thu, 16 Oct 2008 02:48:10 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Add qdisc->ops->peek() implementation for work-conserving qdiscs.

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
---
 net/sched/sch_atm.c       |   10 ++++++++++
 net/sched/sch_blackhole.c |    1 +
 net/sched/sch_dsmark.c    |   10 ++++++++++
 net/sched/sch_gred.c      |    1 +
 net/sched/sch_multiq.c    |   29 +++++++++++++++++++++++++++++
 net/sched/sch_netem.c     |    1 +
 net/sched/sch_red.c       |    9 +++++++++
 net/sched/sch_teql.c      |    9 +++++++++
 8 files changed, 70 insertions(+), 0 deletions(-)

diff --git a/net/sched/sch_atm.c b/net/sched/sch_atm.c
index 43d3725..f9eac08 100644
--- a/net/sched/sch_atm.c
+++ b/net/sched/sch_atm.c
@@ -522,6 +522,15 @@ static struct sk_buff *atm_tc_dequeue(struct Qdisc *sch)
 	return skb;
 }
 
+static struct sk_buff *atm_tc_peek(struct Qdisc *sch)
+{
+	struct atm_qdisc_data *p = qdisc_priv(sch);
+
+	pr_debug("atm_tc_peek(sch %p,[qdisc %p])\n", sch, p);
+
+	return p->link.q->ops->peek(p->link.q);
+}
+
 static int atm_tc_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct atm_qdisc_data *p = qdisc_priv(sch);
@@ -694,6 +703,7 @@ static struct Qdisc_ops atm_qdisc_ops __read_mostly = {
 	.priv_size	= sizeof(struct atm_qdisc_data),
 	.enqueue	= atm_tc_enqueue,
 	.dequeue	= atm_tc_dequeue,
+	.peek		= atm_tc_peek,
 	.requeue	= atm_tc_requeue,
 	.drop		= atm_tc_drop,
 	.init		= atm_tc_init,
diff --git a/net/sched/sch_blackhole.c b/net/sched/sch_blackhole.c
index 507fb48..094a874 100644
--- a/net/sched/sch_blackhole.c
+++ b/net/sched/sch_blackhole.c
@@ -33,6 +33,7 @@ static struct Qdisc_ops blackhole_qdisc_ops __read_mostly = {
 	.priv_size	= 0,
 	.enqueue	= blackhole_enqueue,
 	.dequeue	= blackhole_dequeue,
+	.peek		= blackhole_dequeue,
 	.owner		= THIS_MODULE,
 };
 
diff --git a/net/sched/sch_dsmark.c b/net/sched/sch_dsmark.c
index ba43aab..3e49147 100644
--- a/net/sched/sch_dsmark.c
+++ b/net/sched/sch_dsmark.c
@@ -313,6 +313,15 @@ static struct sk_buff *dsmark_dequeue(struct Qdisc *sch)
 	return skb;
 }
 
+static struct sk_buff *dsmark_peek(struct Qdisc *sch)
+{
+	struct dsmark_qdisc_data *p = qdisc_priv(sch);
+
+	pr_debug("dsmark_peek(sch %p,[qdisc %p])\n", sch, p);
+
+	return p->q->ops->peek(p->q);
+}
+
 static int dsmark_requeue(struct sk_buff *skb, struct Qdisc *sch)
 {
 	struct dsmark_qdisc_data *p = qdisc_priv(sch);
@@ -496,6 +505,7 @@ static struct Qdisc_ops dsmark_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct dsmark_qdisc_data),
 	.enqueue	=	dsmark_enqueue,
 	.dequeue	=	dsmark_dequeue,
+	.peek		=	dsmark_peek,
 	.requeue	=	dsmark_requeue,
 	.drop		=	dsmark_drop,
 	.init		=	dsmark_init,
diff --git a/net/sched/sch_gred.c b/net/sched/sch_gred.c
index c1ad6b8..cb20ee3 100644
--- a/net/sched/sch_gred.c
+++ b/net/sched/sch_gred.c
@@ -602,6 +602,7 @@ static struct Qdisc_ops gred_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct gred_sched),
 	.enqueue	=	gred_enqueue,
 	.dequeue	=	gred_dequeue,
+	.peek		=	qdisc_peek_head,
 	.requeue	=	gred_requeue,
 	.drop		=	gred_drop,
 	.init		=	gred_init,
diff --git a/net/sched/sch_multiq.c b/net/sched/sch_multiq.c
index 915f314..155648d 100644
--- a/net/sched/sch_multiq.c
+++ b/net/sched/sch_multiq.c
@@ -155,6 +155,34 @@ static struct sk_buff *multiq_dequeue(struct Qdisc *sch)
 
 }
 
+static struct sk_buff *multiq_peek(struct Qdisc *sch)
+{
+	struct multiq_sched_data *q = qdisc_priv(sch);
+	unsigned int curband = q->curband;
+	struct Qdisc *qdisc;
+	struct sk_buff *skb;
+	int band;
+
+	for (band = 0; band < q->bands; band++) {
+		/* cycle through bands to ensure fairness */
+		curband++;
+		if (curband >= q->bands)
+			curband = 0;
+
+		/* Check that target subqueue is available before
+		 * pulling an skb to avoid excessive requeues
+		 */
+		if (!__netif_subqueue_stopped(qdisc_dev(sch), curband)) {
+			qdisc = q->queues[curband];
+			skb = qdisc->ops->peek(qdisc);
+			if (skb)
+				return skb;
+		}
+	}
+	return NULL;
+
+}
+
 static unsigned int multiq_drop(struct Qdisc *sch)
 {
 	struct multiq_sched_data *q = qdisc_priv(sch);
@@ -451,6 +479,7 @@ static struct Qdisc_ops multiq_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct multiq_sched_data),
 	.enqueue	=	multiq_enqueue,
 	.dequeue	=	multiq_dequeue,
+	.peek		=	multiq_peek,
 	.requeue	=	multiq_requeue,
 	.drop		=	multiq_drop,
 	.init		=	multiq_init,
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index a119599..2898d9d 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -541,6 +541,7 @@ static struct Qdisc_ops tfifo_qdisc_ops __read_mostly = {
 	.priv_size	=	sizeof(struct fifo_sched_data),
 	.enqueue	=	tfifo_enqueue,
 	.dequeue	=	qdisc_dequeue_head,
+	.peek		=	qdisc_peek_head,
 	.requeue	=	qdisc_requeue,
 	.drop		=	qdisc_queue_drop,
 	.init		=	tfifo_init,
diff --git a/net/sched/sch_red.c b/net/sched/sch_red.c
index 5da0583..7abc514 100644
--- a/net/sched/sch_red.c
+++ b/net/sched/sch_red.c
@@ -140,6 +140,14 @@ static struct sk_buff * red_dequeue(struct Qdisc* sch)
 	return skb;
 }
 
+static struct sk_buff * red_peek(struct Qdisc* sch)
+{
+	struct red_sched_data *q = qdisc_priv(sch);
+	struct Qdisc *child = q->qdisc;
+
+	return child->ops->peek(child);
+}
+
 static unsigned int red_drop(struct Qdisc* sch)
 {
 	struct red_sched_data *q = qdisc_priv(sch);
@@ -361,6 +369,7 @@ static struct Qdisc_ops red_qdisc_ops __read_mostly = {
 	.cl_ops		=	&red_class_ops,
 	.enqueue	=	red_enqueue,
 	.dequeue	=	red_dequeue,
+	.peek		=	red_peek,
 	.requeue	=	red_requeue,
 	.drop		=	red_drop,
 	.init		=	red_init,
diff --git a/net/sched/sch_teql.c b/net/sched/sch_teql.c
index d35ef05..8d7acd8 100644
--- a/net/sched/sch_teql.c
+++ b/net/sched/sch_teql.c
@@ -123,6 +123,14 @@ teql_dequeue(struct Qdisc* sch)
 	return skb;
 }
 
+static struct sk_buff *
+teql_peek(struct Qdisc* sch)
+{
+	struct teql_sched_data *dat = qdisc_priv(sch);
+
+	return skb_peek(&dat->q);
+}
+
 static __inline__ void
 teql_neigh_release(struct neighbour *n)
 {
@@ -433,6 +441,7 @@ static __init void teql_master_setup(struct net_device *dev)
 
 	ops->enqueue	=	teql_enqueue;
 	ops->dequeue	=	teql_dequeue;
+	ops->peek	=	teql_peek;
 	ops->requeue	=	teql_requeue;
 	ops->init	=	teql_qdisc_init;
 	ops->reset	=	teql_reset;
-- 
1.5.6.5

