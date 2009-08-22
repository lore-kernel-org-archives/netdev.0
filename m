From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/2]: pkt_sched: Convert CBQ to tasklet_hrtimer.
Date: Fri, 21 Aug 2009 17:03:33 -0700 (PDT)
Message-ID: <20090821.170333.153413841.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tglx@linutronix.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46049
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755624AbZHVADV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Aug 2009 20:03:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This code expects to run in softirq context, and bare hrtimers
run in hw IRQ context.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/sched/sch_cbq.c |   23 +++++++++++++----------
 1 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index d5798e1..81652d6 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -163,7 +163,7 @@ struct cbq_sched_data
 	psched_time_t		now_rt;		/* Cached real time */
 	unsigned		pmask;
 
-	struct hrtimer		delay_timer;
+	struct tasklet_hrtimer	delay_timer;
 	struct qdisc_watchdog	watchdog;	/* Watchdog timer,
 						   started when CBQ has
 						   backlog, but cannot
@@ -503,6 +503,8 @@ static void cbq_ovl_delay(struct cbq_class *cl)
 		cl->undertime = q->now + delay;
 
 		if (delay > 0) {
+			struct hrtimer *ht;
+
 			sched += delay + cl->penalty;
 			cl->penalized = sched;
 			cl->cpriority = TC_CBQ_MAXPRIO;
@@ -510,12 +512,12 @@ static void cbq_ovl_delay(struct cbq_class *cl)
 
 			expires = ktime_set(0, 0);
 			expires = ktime_add_ns(expires, PSCHED_TICKS2NS(sched));
-			if (hrtimer_try_to_cancel(&q->delay_timer) &&
-			    ktime_to_ns(ktime_sub(
-					hrtimer_get_expires(&q->delay_timer),
-					expires)) > 0)
-				hrtimer_set_expires(&q->delay_timer, expires);
-			hrtimer_restart(&q->delay_timer);
+			ht = &q->delay_timer.timer;
+			if (hrtimer_try_to_cancel(ht) &&
+			    ktime_to_ns(ktime_sub(hrtimer_get_expires(ht),
+						  expires)) > 0)
+				hrtimer_set_expires(ht, expires);
+			hrtimer_restart(ht);
 			cl->delayed = 1;
 			cl->xstats.overactions++;
 			return;
@@ -621,7 +623,7 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 
 		time = ktime_set(0, 0);
 		time = ktime_add_ns(time, PSCHED_TICKS2NS(now + delay));
-		hrtimer_start(&q->delay_timer, time, HRTIMER_MODE_ABS);
+		tasklet_hrtimer_start(&q->delay_timer, time, HRTIMER_MODE_ABS);
 	}
 
 	sch->flags &= ~TCQ_F_THROTTLED;
@@ -1214,7 +1216,7 @@ cbq_reset(struct Qdisc* sch)
 	q->tx_class = NULL;
 	q->tx_borrowed = NULL;
 	qdisc_watchdog_cancel(&q->watchdog);
-	hrtimer_cancel(&q->delay_timer);
+	tasklet_hrtimer_cancel(&q->delay_timer);
 	q->toplevel = TC_CBQ_MAXLEVEL;
 	q->now = psched_get_time();
 	q->now_rt = q->now;
@@ -1397,7 +1399,8 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->link.minidle = -0x7FFFFFFF;
 
 	qdisc_watchdog_init(&q->watchdog, sch);
-	hrtimer_init(&q->delay_timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
+	tasklet_hrtimer_init(&q->delay_timer, cbq_undelay,
+			     CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
 	q->delay_timer.function = cbq_undelay;
 	q->toplevel = TC_CBQ_MAXLEVEL;
 	q->now = psched_get_time();
-- 
1.6.3.4

