From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 03/11]: kill PSCHED_TADD/PSCHED_TADD2
Date: Fri, 23 Mar 2007 14:35:42 +0100 (MET)
Message-ID: <20070323133517.10264.81521.sendpatchset@localhost.localdomain>
References: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61420 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934055AbXCWNfn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 09:35:43 -0400
In-Reply-To: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: kill PSCHED_TADD/PSCHED_TADD2

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 145a1a6010c6b852ffab28c110d8911a6161aa8b
tree 84b7bf284ea3b870a9b5fd9dae3adaad9979dc26
parent 4a4a3d59dca71f202ab063b909c84c96c8ea09a7
author Patrick McHardy <kaber@trash.net> Thu, 22 Mar 2007 23:58:42 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 10:31:27 +0100

 include/net/pkt_sched.h |    2 --
 net/sched/sch_cbq.c     |   12 ++++++------
 net/sched/sch_netem.c   |    2 +-
 3 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 276d1ad..32cdf01 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -55,8 +55,6 @@ typedef long	psched_tdiff_t;
 #define PSCHED_TDIFF_SAFE(tv1, tv2, bound) \
 					min_t(long long, (tv1) - (tv2), bound)
 #define PSCHED_TLESS(tv1, tv2)		((tv1) < (tv2))
-#define PSCHED_TADD2(tv, delta, tv_res) ((tv_res) = (tv) + (delta))
-#define PSCHED_TADD(tv, delta)		((tv) += (delta))
 #define PSCHED_SET_PASTPERFECT(t)	((t) = 0)
 #define PSCHED_IS_PASTPERFECT(t)	((t) == 0)
 
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 57ac6c5..290b26b 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -387,7 +387,7 @@ cbq_mark_toplevel(struct cbq_sched_data *q, struct cbq_class *cl)
 
 		PSCHED_GET_TIME(now);
 		incr = PSCHED_TDIFF(now, q->now_rt);
-		PSCHED_TADD2(q->now, incr, now);
+		now = q->now + incr;
 
 		do {
 			if (PSCHED_TLESS(cl->undertime, now)) {
@@ -492,7 +492,7 @@ static void cbq_ovl_classic(struct cbq_class *cl)
 			cl->avgidle = cl->minidle;
 		if (delay <= 0)
 			delay = 1;
-		PSCHED_TADD2(q->now, delay, cl->undertime);
+		cl->undertime = q->now + delay;
 
 		cl->xstats.overactions++;
 		cl->delayed = 1;
@@ -558,7 +558,7 @@ static void cbq_ovl_delay(struct cbq_class *cl)
 			delay -= (-cl->avgidle) - ((-cl->avgidle) >> cl->ewma_log);
 		if (cl->avgidle < cl->minidle)
 			cl->avgidle = cl->minidle;
-		PSCHED_TADD2(q->now, delay, cl->undertime);
+		cl->undertime = q->now + delay;
 
 		if (delay > 0) {
 			sched += delay + cl->penalty;
@@ -820,7 +820,7 @@ cbq_update(struct cbq_sched_data *q)
 			idle -= L2T(&q->link, len);
 			idle += L2T(cl, len);
 
-			PSCHED_TADD2(q->now, idle, cl->undertime);
+			cl->undertime = q->now + idle;
 		} else {
 			/* Underlimit */
 
@@ -1018,12 +1018,12 @@ cbq_dequeue(struct Qdisc *sch)
 		   cbq_time = max(real_time, work);
 		 */
 		incr2 = L2T(&q->link, q->tx_len);
-		PSCHED_TADD(q->now, incr2);
+		q->now += incr2;
 		cbq_update(q);
 		if ((incr -= incr2) < 0)
 			incr = 0;
 	}
-	PSCHED_TADD(q->now, incr);
+	q->now += incr;
 	q->now_rt = now;
 
 	for (;;) {
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index bc42843..6044ae7 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -218,7 +218,7 @@ static int netem_enqueue(struct sk_buff *skb, struct Qdisc *sch)
 				  &q->delay_cor, q->delay_dist);
 
 		PSCHED_GET_TIME(now);
-		PSCHED_TADD2(now, delay, cb->time_to_send);
+		cb->time_to_send = now + delay;
 		++q->counter;
 		ret = q->qdisc->enqueue(skb, q->qdisc);
 	} else {
