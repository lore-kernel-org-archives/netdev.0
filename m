From: David Miller <davem@davemloft.net>
Subject: [PATCH]: tasklet_hrtimer revert...
Date: Tue, 01 Sep 2009 18:00:10 -0700 (PDT)
Message-ID: <20090901.180010.97451011.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55228
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752651AbZIBA74 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 20:59:56 -0400
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 12489C8C405
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2009 18:00:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I'll push this into net-2.6 shortly...

pkt_sched: Revert tasklet_hrtimer changes.

These are full of unresolved problems, mainly that conversions don't
work 1-1 from hrtimers to tasklet_hrtimers because unlike hrtimers
tasklets can't be killed from softirq context.

And when a qdisc gets reset, that's exactly what we need to do here.

We'll work this out in the net-next-2.6 tree and if warranted we'll
backport that work to -stable.

This reverts the following 3 changesets:

a2cb6a4dd470d7a64255a10b843b0d188416b78f
("pkt_sched: Fix bogon in tasklet_hrtimer changes.")

38acce2d7983632100a9ff3fd20295f6e34074a8
("pkt_sched: Convert CBQ to tasklet_hrtimer.")

ee5f9757ea17759e1ce5503bdae2b07e48e32af9
("pkt_sched: Convert qdisc_watchdog to tasklet_hrtimer")

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/pkt_sched.h |    4 ++--
 net/sched/sch_api.c     |   10 +++++-----
 net/sched/sch_cbq.c     |   25 +++++++++++--------------
 3 files changed, 18 insertions(+), 21 deletions(-)

diff --git a/include/net/pkt_sched.h b/include/net/pkt_sched.h
index 7eafb8d..82a3191 100644
--- a/include/net/pkt_sched.h
+++ b/include/net/pkt_sched.h
@@ -61,8 +61,8 @@ psched_tdiff_bounded(psched_time_t tv1, psched_time_t tv2, psched_time_t bound)
 }
 
 struct qdisc_watchdog {
-	struct tasklet_hrtimer	timer;
-	struct Qdisc		*qdisc;
+	struct hrtimer	timer;
+	struct Qdisc	*qdisc;
 };
 
 extern void qdisc_watchdog_init(struct qdisc_watchdog *wd, struct Qdisc *qdisc);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 92e6f3a..24d17ce 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -458,7 +458,7 @@ EXPORT_SYMBOL(qdisc_warn_nonwc);
 static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 {
 	struct qdisc_watchdog *wd = container_of(timer, struct qdisc_watchdog,
-						 timer.timer);
+						 timer);
 
 	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
 	__netif_schedule(qdisc_root(wd->qdisc));
@@ -468,8 +468,8 @@ static enum hrtimer_restart qdisc_watchdog(struct hrtimer *timer)
 
 void qdisc_watchdog_init(struct qdisc_watchdog *wd, struct Qdisc *qdisc)
 {
-	tasklet_hrtimer_init(&wd->timer, qdisc_watchdog,
-			     CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
+	hrtimer_init(&wd->timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
+	wd->timer.function = qdisc_watchdog;
 	wd->qdisc = qdisc;
 }
 EXPORT_SYMBOL(qdisc_watchdog_init);
@@ -485,13 +485,13 @@ void qdisc_watchdog_schedule(struct qdisc_watchdog *wd, psched_time_t expires)
 	wd->qdisc->flags |= TCQ_F_THROTTLED;
 	time = ktime_set(0, 0);
 	time = ktime_add_ns(time, PSCHED_TICKS2NS(expires));
-	tasklet_hrtimer_start(&wd->timer, time, HRTIMER_MODE_ABS);
+	hrtimer_start(&wd->timer, time, HRTIMER_MODE_ABS);
 }
 EXPORT_SYMBOL(qdisc_watchdog_schedule);
 
 void qdisc_watchdog_cancel(struct qdisc_watchdog *wd)
 {
-	tasklet_hrtimer_cancel(&wd->timer);
+	hrtimer_cancel(&wd->timer);
 	wd->qdisc->flags &= ~TCQ_F_THROTTLED;
 }
 EXPORT_SYMBOL(qdisc_watchdog_cancel);
diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 149b040..d5798e1 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -163,7 +163,7 @@ struct cbq_sched_data
 	psched_time_t		now_rt;		/* Cached real time */
 	unsigned		pmask;
 
-	struct tasklet_hrtimer	delay_timer;
+	struct hrtimer		delay_timer;
 	struct qdisc_watchdog	watchdog;	/* Watchdog timer,
 						   started when CBQ has
 						   backlog, but cannot
@@ -503,8 +503,6 @@ static void cbq_ovl_delay(struct cbq_class *cl)
 		cl->undertime = q->now + delay;
 
 		if (delay > 0) {
-			struct hrtimer *ht;
-
 			sched += delay + cl->penalty;
 			cl->penalized = sched;
 			cl->cpriority = TC_CBQ_MAXPRIO;
@@ -512,12 +510,12 @@ static void cbq_ovl_delay(struct cbq_class *cl)
 
 			expires = ktime_set(0, 0);
 			expires = ktime_add_ns(expires, PSCHED_TICKS2NS(sched));
-			ht = &q->delay_timer.timer;
-			if (hrtimer_try_to_cancel(ht) &&
-			    ktime_to_ns(ktime_sub(hrtimer_get_expires(ht),
-						  expires)) > 0)
-				hrtimer_set_expires(ht, expires);
-			hrtimer_restart(ht);
+			if (hrtimer_try_to_cancel(&q->delay_timer) &&
+			    ktime_to_ns(ktime_sub(
+					hrtimer_get_expires(&q->delay_timer),
+					expires)) > 0)
+				hrtimer_set_expires(&q->delay_timer, expires);
+			hrtimer_restart(&q->delay_timer);
 			cl->delayed = 1;
 			cl->xstats.overactions++;
 			return;
@@ -593,7 +591,7 @@ static psched_tdiff_t cbq_undelay_prio(struct cbq_sched_data *q, int prio,
 static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 {
 	struct cbq_sched_data *q = container_of(timer, struct cbq_sched_data,
-						delay_timer.timer);
+						delay_timer);
 	struct Qdisc *sch = q->watchdog.qdisc;
 	psched_time_t now;
 	psched_tdiff_t delay = 0;
@@ -623,7 +621,7 @@ static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 
 		time = ktime_set(0, 0);
 		time = ktime_add_ns(time, PSCHED_TICKS2NS(now + delay));
-		tasklet_hrtimer_start(&q->delay_timer, time, HRTIMER_MODE_ABS);
+		hrtimer_start(&q->delay_timer, time, HRTIMER_MODE_ABS);
 	}
 
 	sch->flags &= ~TCQ_F_THROTTLED;
@@ -1216,7 +1214,7 @@ cbq_reset(struct Qdisc* sch)
 	q->tx_class = NULL;
 	q->tx_borrowed = NULL;
 	qdisc_watchdog_cancel(&q->watchdog);
-	tasklet_hrtimer_cancel(&q->delay_timer);
+	hrtimer_cancel(&q->delay_timer);
 	q->toplevel = TC_CBQ_MAXLEVEL;
 	q->now = psched_get_time();
 	q->now_rt = q->now;
@@ -1399,8 +1397,7 @@ static int cbq_init(struct Qdisc *sch, struct nlattr *opt)
 	q->link.minidle = -0x7FFFFFFF;
 
 	qdisc_watchdog_init(&q->watchdog, sch);
-	tasklet_hrtimer_init(&q->delay_timer, cbq_undelay,
-			     CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
+	hrtimer_init(&q->delay_timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
 	q->delay_timer.function = cbq_undelay;
 	q->toplevel = TC_CBQ_MAXLEVEL;
 	q->now = psched_get_time();
-- 
1.6.4.2

