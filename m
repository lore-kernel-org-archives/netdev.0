From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 06/11]: kill PSCHED_TDIFF
Date: Fri, 23 Mar 2007 14:35:46 +0100 (MET)
Message-ID: <20070323133521.10264.67254.sendpatchset@localhost.localdomain>
References: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61429 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934280AbXCWNfr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Mar 2007 09:35:47 -0400
In-Reply-To: <20070323133513.10264.16515.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: kill PSCHED_TDIFF

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit d72d57707edf96c31e62da0841faf59c011dcd92
tree 8b6192c94e025fb8b6e1be3b02526d4792bd4fa1
parent ec252ac5640ea38d3630cdb97333c398a75391b9
author Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 00:01:47 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 23 Mar 2007 10:31:29 +0100

 include/net/pkt_sched.h |    1 -
 net/sched/sch_cbq.c     |   14 +++++++-------
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index c40147a..1639737 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -51,7 +51,6 @@ typedef long	psched_tdiff_t;
 #define PSCHED_GET_TIME(stamp) \
 	((stamp) = PSCHED_NS2US(ktime_to_ns(ktime_get())))
 
-#define PSCHED_TDIFF(tv1, tv2)		(long)((tv1) - (tv2))
 #define PSCHED_TDIFF_SAFE(tv1, tv2, bound) \
 					min_t(long long, (tv1) - (tv2), bound)
 #define PSCHED_PASTPERFECT		0
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 2bb271b..f9e8403 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -386,7 +386,7 @@ cbq_mark_toplevel(struct cbq_sched_data *q, struct cbq_class *cl)
 		psched_tdiff_t incr;
 
 		PSCHED_GET_TIME(now);
-		incr = PSCHED_TDIFF(now, q->now_rt);
+		incr = now - q->now_rt;
 		now = q->now + incr;
 
 		do {
@@ -474,7 +474,7 @@ cbq_requeue(struct sk_buff *skb, struct Qdisc *sch)
 static void cbq_ovl_classic(struct cbq_class *cl)
 {
 	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
-	psched_tdiff_t delay = PSCHED_TDIFF(cl->undertime, q->now);
+	psched_tdiff_t delay = cl->undertime - q->now;
 
 	if (!cl->delayed) {
 		delay += cl->offtime;
@@ -509,7 +509,7 @@ static void cbq_ovl_classic(struct cbq_class *cl)
 		psched_tdiff_t base_delay = q->wd_expires;
 
 		for (b = cl->borrow; b; b = b->borrow) {
-			delay = PSCHED_TDIFF(b->undertime, q->now);
+			delay = b->undertime - q->now;
 			if (delay < base_delay) {
 				if (delay <= 0)
 					delay = 1;
@@ -547,7 +547,7 @@ static void cbq_ovl_rclassic(struct cbq_class *cl)
 static void cbq_ovl_delay(struct cbq_class *cl)
 {
 	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
-	psched_tdiff_t delay = PSCHED_TDIFF(cl->undertime, q->now);
+	psched_tdiff_t delay = cl->undertime - q->now;
 
 	if (!cl->delayed) {
 		psched_time_t sched = q->now;
@@ -776,7 +776,7 @@ cbq_update(struct cbq_sched_data *q)
 			 idle = (now - last) - last_pktlen/rate
 		 */
 
-		idle = PSCHED_TDIFF(q->now, cl->last);
+		idle = q->now - cl->last;
 		if ((unsigned long)idle > 128*1024*1024) {
 			avgidle = cl->maxidle;
 		} else {
@@ -1004,7 +1004,7 @@ cbq_dequeue(struct Qdisc *sch)
 	psched_tdiff_t incr;
 
 	PSCHED_GET_TIME(now);
-	incr = PSCHED_TDIFF(now, q->now_rt);
+	incr = now - q->now_rt;
 
 	if (q->tx_class) {
 		psched_tdiff_t incr2;
@@ -1650,7 +1650,7 @@ cbq_dump_class_stats(struct Qdisc *sch, unsigned long arg,
 	cl->xstats.undertime = 0;
 
 	if (cl->undertime != PSCHED_PASTPERFECT)
-		cl->xstats.undertime = PSCHED_TDIFF(cl->undertime, q->now);
+		cl->xstats.undertime = cl->undertime - q->now;
 
 	if (gnet_stats_copy_basic(d, &cl->bstats) < 0 ||
 #ifdef CONFIG_NET_ESTIMATOR
