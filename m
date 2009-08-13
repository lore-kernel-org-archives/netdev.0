From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH] Speed-up pfifo_fast lookup using a bitmap
Date: Thu, 13 Aug 2009 12:58:18 +0530
Message-ID: <20090813072818.7541.77365.sendpatchset@localhost.localdomain>
Cc: Jarek Poplawski <jarkao2@gmail.com>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au, Krishna Kumar <krkumar2@in.ibm.com>,
	kaber@trash.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e23smtp09.au.ibm.com ([202.81.31.142]:44333 "EHLO
	e23smtp09.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751014AbZHMH2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 03:28:25 -0400
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp09.au.ibm.com (8.14.3/8.13.1) with ESMTP id n7D7Q4mv011924
	for <netdev@vger.kernel.org>; Thu, 13 Aug 2009 17:26:04 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7D7SPJ51118268
	for <netdev@vger.kernel.org>; Thu, 13 Aug 2009 17:28:25 +1000
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7D7SOG0006405
	for <netdev@vger.kernel.org>; Thu, 13 Aug 2009 17:28:25 +1000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maintain a per-qdisc bitmap indicating availability of skbs for
each band. This helps in faster lookup for a skb when there are
no high priority skbs. Also, it helps in (rare) cases where there
are no skbs on the list where an immediate lookup helps rather
than iterating through the three bands.

Another option I considered was to create a private qdisc pointer
and avoid touching Qdisc structure:
	struct pfifo_fast_priv {
		unsigned long bitmap;
		struct sk_buff_head q[PFIFO_FAST_BANDS];
	};
but the test numbers came a little less, since it takes a few more
memory references on enqueue/dequeue.

By keeping the bitmap in Qdisc, it is possible to implement the
lookup for other schedulers, maybe sch_prio which goes through 16
bands?

The BW numbers are average across 5 iterations for multiple
netperf sessions (1-12 on x86_64, and 1-32 on P6) tested with
Chelsio 10 gbps cards over a 2 hour run:

-------------------------------------------------------------------------
     |         x86_64 (Mb/s)          |               P6 (Mb/s)
--------------------------------------|----------------------------------
Size |  ORG BW          NEW BW        |    ORG BW          NEW BW       
-----|--------------------------------|----------------------------------
16K  |  157700          158237        |    153876          156696
64K  |  155916          157882        |    154176          155987
128K |  155122          155628        |    154983          155904
256K |  154808          158913        |    153898          155164
-------------------------------------------------------------------------

Thanks,

- KK

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---

 include/net/sch_generic.h |    1 
 net/sched/sch_generic.c   |   46 +++++++++++++++++++++++-------------
 2 files changed, 31 insertions(+), 16 deletions(-)

diff -ruNp org/include/net/sch_generic.h new/include/net/sch_generic.h
--- org/include/net/sch_generic.h	2009-08-07 12:05:43.000000000 +0530
+++ new/include/net/sch_generic.h	2009-08-07 19:35:16.000000000 +0530
@@ -72,6 +72,7 @@ struct Qdisc
 	 * For performance sake on SMP, we put highly modified fields at the end
 	 */
 	unsigned long		state;
+	unsigned long		bitmap;
 	struct sk_buff_head	q;
 	struct gnet_stats_basic bstats;
 	struct gnet_stats_queue	qstats;
diff -ruNp org/net/sched/sch_generic.c new/net/sched/sch_generic.c
--- org/net/sched/sch_generic.c	2009-08-07 12:05:43.000000000 +0530
+++ new/net/sched/sch_generic.c	2009-08-13 11:57:54.000000000 +0530
@@ -406,18 +406,29 @@ static const u8 prio2band[TC_PRIO_MAX+1]
 
 #define PFIFO_FAST_BANDS 3
 
-static inline struct sk_buff_head *prio2list(struct sk_buff *skb,
-					     struct Qdisc *qdisc)
+/*
+ * Convert a bitmap to the first band number where an skb is queue'd, where:
+ * 	bitmap=0 means there are no skbs for any bands
+ * 	bitmap=1 means there is a skb on band 0
+ *	bitmap=7 means there are skbs on all 3 bands, etc.
+ */
+static const int bitmap2band[] =
+	{-1, 0, 1, 0, 2, 0, 1, 0};
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
@@ -427,14 +438,17 @@ static int pfifo_fast_enqueue(struct sk_
 
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
@@ -442,12 +456,12 @@ static struct sk_buff *pfifo_fast_dequeu
 
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
