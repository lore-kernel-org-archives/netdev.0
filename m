From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: Re: [PATCH] Speed-up pfifo_fast lookup using a bitmap
Date: Fri, 14 Aug 2009 13:49:07 +0530
Message-ID: <20090814081907.18169.10600.sendpatchset@localhost.localdomain>
Cc: kaber@trash.net, netdev@vger.kernel.org, davem@davemloft.net,
	Krishna Kumar <krkumar2@in.ibm.com>,
	herbert@gondor.apana.org.au
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:47823 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754054AbZHNITS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 04:19:18 -0400
Received: from d23relay01.au.ibm.com (d23relay01.au.ibm.com [202.81.31.243])
	by e23smtp09.au.ibm.com (8.14.3/8.13.1) with ESMTP id n7E8Gi5E028756
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 18:16:44 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay01.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7E8JI8K495922
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 18:19:18 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7E8JH2q004021
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 18:19:18 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski <jarkao2@gmail.com> wrote on 08/13/2009 04:57:16 PM:

> > Sounds reasonable. To quantify that, I will test again for a longer
> > run and report the difference.
>
> Yes, more numbers would be appreciated.

I did a longer 7-hour testing of original code, public bitmap (the
code submitted earlier) and a private bitmap (patch below). Each
result line is aggregate of 5 iterations of individual 1, 2, 4, 8,
32 netperf sessions, each running for 55 seconds:

-------------------------------------------------------
IO Size     Org        Public          Private
-------------------------------------------------------
4K          122571     126821          125913
16K         135715     135642          135530 
128K        131324     131862          131668
256K        130060     130107          130378
-------------------------------------------------------
Total:      519670     524433 (0.92%)  523491 (0.74%)
-------------------------------------------------------

The difference between keeping the bitmap private and public is
not much.

> > The tests are on the latest tree which contains CAN_BYPASS. So a
> > single netperf process running this change will get no advantage
> > since this enqueue/dequeue never happens unless the NIC is slow.
> > But for multiple processes, it should help.
> 
> I mean: since the previous patch saved ~2% on omitting enqueue/dequeue,
> and now enqueue/dequeue is ~2% faster, is it still worth to omit this?

I haven't tested the bitmap patch without the bypass code.
Theoretically I assume that patch should help as we still save
an enqueue/dequeue.

Thanks,

- KK

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---

 net/sched/sch_generic.c |   70 ++++++++++++++++++++++++++------------
 1 file changed, 48 insertions(+), 22 deletions(-)

diff -ruNp org/net/sched/sch_generic.c new2/net/sched/sch_generic.c
--- org/net/sched/sch_generic.c	2009-08-07 12:05:43.000000000 +0530
+++ new2/net/sched/sch_generic.c	2009-08-14 12:48:37.000000000 +0530
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
+ * 	bitmap=0 means there are no skbs on any bands.
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
+	return &priv->q[0] + band;
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
+	.priv_size	=	sizeof (struct pfifo_fast_priv),
 	.enqueue	=	pfifo_fast_enqueue,
 	.dequeue	=	pfifo_fast_dequeue,
 	.peek		=	pfifo_fast_peek,
