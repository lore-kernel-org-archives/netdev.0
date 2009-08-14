From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH v1] Speed-up pfifo_fast lookup using a public bitmap
Date: Fri, 14 Aug 2009 18:55:20 +0530
Message-ID: <20090814132520.27518.3049.sendpatchset@localhost.localdomain>
References: <20090814132458.27518.65144.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	kaber@trash.net, Krishna Kumar <krkumar2@in.ibm.com>,
	davem@davemloft.net
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:43844 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754913AbZHNNZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2009 09:25:19 -0400
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp09.au.ibm.com (8.14.3/8.13.1) with ESMTP id n7EDMhVs026810
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 23:22:43 +1000
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7EDPKi61187946
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 23:25:20 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7EDPJt7018031
	for <netdev@vger.kernel.org>; Fri, 14 Aug 2009 23:25:20 +1000
In-Reply-To: <20090814132458.27518.65144.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---

 include/net/sch_generic.h |    1 
 net/sched/sch_generic.c   |   46 +++++++++++++++++++++++-------------
 2 files changed, 31 insertions(+), 16 deletions(-)

diff -ruNp org/include/net/sch_generic.h new/include/net/sch_generic.h
--- org/include/net/sch_generic.h	2009-08-07 12:05:43.000000000 +0530
+++ new/include/net/sch_generic.h	2009-08-13 16:55:32.000000000 +0530
@@ -72,6 +72,7 @@ struct Qdisc
 	 * For performance sake on SMP, we put highly modified fields at the end
 	 */
 	unsigned long		state;
+	u32			bitmap;
 	struct sk_buff_head	q;
 	struct gnet_stats_basic bstats;
 	struct gnet_stats_queue	qstats;
diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
--- org/net/sched/sch_generic.c	2009-08-07 12:05:43.000000000 +0530
+++ new/net/sched/sch_generic.c	2009-08-14 18:23:01.000000000 +0530
@@ -406,18 +406,28 @@ static const u8 prio2band[TC_PRIO_MAX+1]
 
 #define PFIFO_FAST_BANDS 3
 
-static inline struct sk_buff_head *prio2list(struct sk_buff *skb,
-					     struct Qdisc *qdisc)
+/*
+ * Convert a bitmap to the first band number where an skb is queued, where:
+ * 	bitmap=0 means there are no skbs on any band.
+ * 	bitmap=1 means there is an skb on band 0.
+ *	bitmap=7 means there are skbs on all 3 bands, etc.
+ */
+static const int bitmap2band[] = {-1, 0, 1, 0, 2, 0, 1, 0};
+
+static inline struct sk_buff_head *band2list(struct Qdisc *qdisc, int band)
 {
 	struct sk_buff_head *list = qdisc_priv(qdisc);
-	return list + prio2band[skb->priority & TC_PRIO_MAX];
+
+	return list + band;
 }
 
 static int pfifo_fast_enqueue(struct sk_buff *skb, struct Qdisc* qdisc)
 {
-	struct sk_buff_head *list = prio2list(skb, qdisc);
+	int band = prio2band[skb->priority & TC_PRIO_MAX];
+	struct sk_buff_head *list = band2list(qdisc, band);
 
 	if (skb_queue_len(list) < qdisc_dev(qdisc)->tx_queue_len) {
+		qdisc->bitmap |= (1 << band);
 		qdisc->q.qlen++;
 		return __qdisc_enqueue_tail(skb, qdisc, list);
 	}
@@ -427,14 +437,17 @@ static int pfifo_fast_enqueue(struct sk_
 
 static struct sk_buff *pfifo_fast_dequeue(struct Qdisc* qdisc)
 {
-	int prio;
-	struct sk_buff_head *list = qdisc_priv(qdisc);
+	int band = bitmap2band[qdisc->bitmap];
 
-	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++) {
-		if (!skb_queue_empty(list + prio)) {
-			qdisc->q.qlen--;
-			return __qdisc_dequeue_head(qdisc, list + prio);
-		}
+	if (likely(band >= 0)) {
+		struct sk_buff_head *list = qdisc_priv(qdisc);
+		struct sk_buff *skb = __qdisc_dequeue_head(qdisc, list + band);
+
+		qdisc->q.qlen--;
+		if (skb_queue_empty(list + band))
+			qdisc->bitmap &= ~(1 << band);
+
+		return skb;
 	}
 
 	return NULL;
@@ -442,12 +455,12 @@ static struct sk_buff *pfifo_fast_dequeu
 
 static struct sk_buff *pfifo_fast_peek(struct Qdisc* qdisc)
 {
-	int prio;
-	struct sk_buff_head *list = qdisc_priv(qdisc);
+	int band = bitmap2band[qdisc->bitmap];
+
+	if (band >= 0) {
+		struct sk_buff_head *list = qdisc_priv(qdisc);
 
-	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++) {
-		if (!skb_queue_empty(list + prio))
-			return skb_peek(list + prio);
+		return skb_peek(list + band);
 	}
 
 	return NULL;
@@ -461,6 +474,7 @@ static void pfifo_fast_reset(struct Qdis
 	for (prio = 0; prio < PFIFO_FAST_BANDS; prio++)
 		__qdisc_reset_queue(qdisc, list + prio);
 
+	qdisc->bitmap = 0;
 	qdisc->qstats.backlog = 0;
 	qdisc->q.qlen = 0;
 }
