From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH v2] Speed-up pfifo_fast lookup using a private bitmap
Date: Fri, 14 Aug 2009 18:55:43 +0530
Message-ID: <20090814132543.27518.39569.sendpatchset@localhost.localdomain>
References: <20090814132458.27518.65144.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	herbert@gondor.apana.org.au, Krishna Kumar <krkumar2@in.ibm.com>,
	kaber@trash.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp02.in.ibm.com ([59.145.155.2]:44641 "EHLO
	e28smtp02.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756115AbZHNNZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 09:25:35 -0400
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by e28smtp02.in.ibm.com (8.14.3/8.13.1) with ESMTP id n7EDPXMx019977
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 18:55:33 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7EDPXTX1884208
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 18:55:33 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n7EDPWux016878
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 23:25:33 +1000
In-Reply-To: <20090814132458.27518.65144.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---

 net/sched/sch_generic.c |   70 ++++++++++++++++++++++++++------------
 1 file changed, 48 insertions(+), 22 deletions(-)

diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
--- org/net/sched/sch_generic.c	2009-08-07 12:05:43.000000000 +0530
+++ new/net/sched/sch_generic.c	2009-08-14 18:23:16.000000000 +0530
@@ -406,18 +406,38 @@ static const u8 prio2band[TC_PRIO_MAX+1]
 
 #define PFIFO_FAST_BANDS 3
 
-static inline struct sk_buff_head *prio2list(struct sk_buff *skb,
-					     struct Qdisc *qdisc)
+/*
+ * Private data for a pfifo_fast scheduler containing:
+ * 	- the three band queues
+ * 	- bitmap indicating which of the bands contain skbs.
+ */
+struct pfifo_fast_priv {
+	u32 bitmap;
+	struct sk_buff_head q[PFIFO_FAST_BANDS];
+};
+
+/*
+ * Convert a bitmap to the first band number where an skb is queued, where:
+ * 	bitmap=0 means there are no skbs on any band.
+ * 	bitmap=1 means there is an skb on band 0.
+ *	bitmap=7 means there are skbs on all 3 bands, etc.
+ */
+static const int bitmap2band[] = {-1, 0, 1, 0, 2, 0, 1, 0};
+
+static inline struct sk_buff_head *band2list(struct pfifo_fast_priv *priv,
+					     int band)
 {
-	struct sk_buff_head *list = qdisc_priv(qdisc);
-	return list + prio2band[skb->priority & TC_PRIO_MAX];
+	return priv->q + band;
 }
 
 static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc* qdisc)
 {
-	struct sk_buff_head *list = prio2list(skb, qdisc);
+	int band = prio2band[skb->priority & TC_PRIO_MAX];
+	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
+	struct sk_buff_head *list = band2list(priv, band);
 
 	if (skb_queue_len(list) < qdisc_dev(qdisc)->tx_queue_len) {
+		priv->bitmap |= (1 << band);
 		qdisc->q.qlen++;
 		return __qdisc_enqueue_tail(skb, qdisc, list);
 	}
@@ -427,14 +447,18 @@ static int pfifo_fast_enqueue(struct sk_
 
 static struct sk_buff *pfifo_fast_dequeue(struct Qdisc* qdisc)
 {
-	int prio;
-	struct sk_buff_head *list = qdisc_priv(qdisc);
+	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
+	int band = bitmap2band[priv->bitmap];
 
-	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++) {
-		if (!skb_queue_empty(list + prio)) {
-			qdisc->q.qlen--;
-			return __qdisc_dequeue_head(qdisc, list + prio);
-		}
+	if (likely(band >= 0)) {
+		struct sk_buff_head *list = band2list(priv, band);
+		struct sk_buff *skb = __qdisc_dequeue_head(qdisc, list);
+
+		qdisc->q.qlen--;
+		if (skb_queue_empty(list))
+			priv->bitmap &= ~(1 << band);
+
+		return skb;
 	}
 
 	return NULL;
@@ -442,12 +466,13 @@ static struct sk_buff *pfifo_fast_dequeu
 
 static struct sk_buff *pfifo_fast_peek(struct Qdisc* qdisc)
 {
-	int prio;
-	struct sk_buff_head *list = qdisc_priv(qdisc);
+	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
+	int band = bitmap2band[priv->bitmap];
+
+	if (band >= 0) {
+		struct sk_buff_head *list = band2list(priv, band);
 
-	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++) {
-		if (!skb_queue_empty(list + prio))
-			return skb_peek(list + prio);
+		return skb_peek(list);
 	}
 
 	return NULL;
@@ -456,11 +481,12 @@ static struct sk_buff *pfifo_fast_peek(s
 static void pfifo_fast_reset(struct Qdisc* qdisc)
 {
 	int prio;
-	struct sk_buff_head *list = qdisc_priv(qdisc);
+	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
 
 	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++)
-		__qdisc_reset_queue(qdisc, list + prio);
+		__qdisc_reset_queue(qdisc, band2list(priv, prio));
 
+	priv->bitmap = 0;
 	qdisc->qstats.backlog = 0;
 	qdisc->q.qlen = 0;
 }
@@ -480,17 +506,17 @@ nla_put_failure:
 static int pfifo_fast_init(struct Qdisc *qdisc, struct nlattr *opt)
 {
 	int prio;
-	struct sk_buff_head *list = qdisc_priv(qdisc);
+	struct pfifo_fast_priv *priv = qdisc_priv(qdisc);
 
 	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++)
-		skb_queue_head_init(list + prio);
+		skb_queue_head_init(band2list(priv, prio));
 
 	return 0;
 }
 
 static struct Qdisc_ops pfifo_fast_ops __read_mostly = {
 	.id		=	"pfifo_fast",
-	.priv_size	=	PFIFO_FAST_BANDS * sizeof(struct sk_buff_head),
+	.priv_size	=	sizeof(struct pfifo_fast_priv),
 	.enqueue	=	pfifo_fast_enqueue,
 	.dequeue	=	pfifo_fast_dequeue,
 	.peek		=	pfifo_fast_peek,
