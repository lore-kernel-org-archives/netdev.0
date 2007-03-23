From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 05/11]: kill PSCHED_SET_PASTPERFECT/PSCHED_IS_PASTPERFECT
Date: Fri, 23 Mar 2007 14:35:45 +0100 (MET)
Message-ID: <20070323133520.10264.82856.sendpatchset@localhost.localdomain>
References: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61426 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934077AbXCWNfq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 09:35:46 -0400
In-Reply-To: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: kill PSCHED_SET_PASTPERFECT/PSCHED_IS_PASTPERFECT

Use direct assignment and comparison instead.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit ec252ac5640ea38d3630cdb97333c398a75391b9
tree bce7b2c63ffb0694942484418f1adf08ed78292d
parent 4f8fc418f88c0b7ee6e726b05f27c42d8e20593c
author Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 00:01:32 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 10:31:29 +0100

 include/net/pkt_sched.h |    3 +--
 include/net/red.h       |    4 ++--
 net/sched/sch_cbq.c     |   17 ++++++++---------
 net/sched/sch_netem.c   |    2 +-
 4 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 49325ff..c40147a 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -54,8 +54,7 @@ typedef long	psched_tdiff_t;
 #define PSCHED_TDIFF(tv1, tv2)		(long)((tv1) - (tv2))
 #define PSCHED_TDIFF_SAFE(tv1, tv2, bound) \
 					min_t(long long, (tv1) - (tv2), bound)
-#define PSCHED_SET_PASTPERFECT(t)	((t) = 0)
-#define PSCHED_IS_PASTPERFECT(t)	((t) == 0)
+#define PSCHED_PASTPERFECT		0
 
 struct qdisc_watchdog {
 	struct hrtimer	timer;
diff --git a/include/net/red.h b/include/net/red.h
index a4eb379..d9e1149 100644
--- a/include/net/red.h
+++ b/include/net/red.h
@@ -151,7 +151,7 @@ static inline void red_set_parms(struct red_parms *p,
 
 static inline int red_is_idling(struct red_parms *p)
 {
-	return !PSCHED_IS_PASTPERFECT(p->qidlestart);
+	return p->qidlestart != PSCHED_PASTPERFECT;
 }
 
 static inline void red_start_of_idle_period(struct red_parms *p)
@@ -161,7 +161,7 @@ static inline void red_start_of_idle_period(struct red_parms *p)
 
 static inline void red_end_of_idle_period(struct red_parms *p)
 {
-	PSCHED_SET_PASTPERFECT(p->qidlestart);
+	p->qidlestart = PSCHED_PASTPERFECT;
 }
 
 static inline void red_restart(struct red_parms *p)
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 9e6cdab..2bb271b 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -738,7 +738,7 @@ cbq_update_toplevel(struct cbq_sched_data *q, struct cbq_class *cl,
 	if (cl && q->toplevel >= borrowed->level) {
 		if (cl->q->q.qlen > 1) {
 			do {
-				if (PSCHED_IS_PASTPERFECT(borrowed->undertime)) {
+				if (borrowed->undertime == PSCHED_PASTPERFECT) {
 					q->toplevel = borrowed->level;
 					return;
 				}
@@ -824,7 +824,7 @@ cbq_update(struct cbq_sched_data *q)
 		} else {
 			/* Underlimit */
 
-			PSCHED_SET_PASTPERFECT(cl->undertime);
+			cl->undertime = PSCHED_PASTPERFECT;
 			if (avgidle > cl->maxidle)
 				cl->avgidle = cl->maxidle;
 			else
@@ -845,7 +845,7 @@ cbq_under_limit(struct cbq_class *cl)
 	if (cl->tparent == NULL)
 		return cl;
 
-	if (PSCHED_IS_PASTPERFECT(cl->undertime) || q->now >= cl->undertime) {
+	if (cl->undertime == PSCHED_PASTPERFECT || q->now >= cl->undertime) {
 		cl->delayed = 0;
 		return cl;
 	}
@@ -868,8 +868,7 @@ cbq_under_limit(struct cbq_class *cl)
 		}
 		if (cl->level > q->toplevel)
 			return NULL;
-	} while (!PSCHED_IS_PASTPERFECT(cl->undertime) &&
-		 q->now < cl->undertime);
+	} while (cl->undertime != PSCHED_PASTPERFECT && q->now < cl->undertime);
 
 	cl->delayed = 0;
 	return cl;
@@ -1054,11 +1053,11 @@ cbq_dequeue(struct Qdisc *sch)
 		*/
 
 		if (q->toplevel == TC_CBQ_MAXLEVEL &&
-		    PSCHED_IS_PASTPERFECT(q->link.undertime))
+		    q->link.undertime == PSCHED_PASTPERFECT)
 			break;
 
 		q->toplevel = TC_CBQ_MAXLEVEL;
-		PSCHED_SET_PASTPERFECT(q->link.undertime);
+		q->link.undertime = PSCHED_PASTPERFECT;
 	}
 
 	/* No packets in scheduler or nobody wants to give them to us :-(
@@ -1289,7 +1288,7 @@ cbq_reset(struct Qdisc* sch)
 			qdisc_reset(cl->q);
 
 			cl->next_alive = NULL;
-			PSCHED_SET_PASTPERFECT(cl->undertime);
+			cl->undertime = PSCHED_PASTPERFECT;
 			cl->avgidle = cl->maxidle;
 			cl->deficit = cl->quantum;
 			cl->cpriority = cl->priority;
@@ -1650,7 +1649,7 @@ cbq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	cl->xstats.avgidle = cl->avgidle;
 	cl->xstats.undertime = 0;
 
-	if (!PSCHED_IS_PASTPERFECT(cl->undertime))
+	if (cl->undertime != PSCHED_PASTPERFECT)
 		cl->xstats.undertime = PSCHED_TDIFF(cl->undertime, q->now);
 
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
diff --git a/net/sched/sch_netem.c b/net/sched/sch_netem.c
index 5d571aa..1e88301 100644
--- a/net/sched/sch_netem.c
+++ b/net/sched/sch_netem.c
@@ -532,7 +532,7 @@ static int tfifo_init(struct Qdisc *sch, struct rtattr *opt)
 	} else
 		q->limit = max_t(u32, sch->dev->tx_queue_len, 1);
 
-	PSCHED_SET_PASTPERFECT(q->oldest);
+	q->oldest = PSCHED_PASTPERFECT;
 	return 0;
 }
 
