From: Patrick McHardy <kaber@trash.net>
Subject: [NET_SCHED 08/10]: sch_cbq: use hrtimer for delay_timer
Date: Fri, 16 Mar 2007 06:30:59 +0100 (MET)
Message-ID: <20070316053029.22744.83969.sendpatchset@localhost.localdomain>
References: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	shemminger@linux-foundation.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:45276 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752445AbXCPFbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Mar 2007 01:31:00 -0400
In-Reply-To: <20070316053018.22744.76883.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[NET_SCHED]: sch_cbq: use hrtimer for delay_timer

Switch delay_timer to hrtimer.

The class penalty parameter is changed to use psched ticks as units.
Since iproute never supported using this and the only existing user
(libnl) incorrectly assumes psched ticks as units anyway, this
shouldn't break anything.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 2d548d3ea10cb1b49db8913fbab32811d9e7c3d0
tree 11561d6ada5553eb4fe945bd02cb31779be3c80d
parent 40c78645115590d29549f6a1603847a620206d29
author Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:16:05 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 16 Mar 2007 06:16:05 +0100

 net/sched/sch_cbq.c |   70 ++++++++++++++++++++++++++++++---------------------
 1 files changed, 41 insertions(+), 29 deletions(-)

diff --git a/net/sched/sch_cbq.c b/net/sched/sch_cbq.c
index 32f6a30..ed7d540 100644
--- a/net/sched/sch_cbq.c
+++ b/net/sched/sch_cbq.c
@@ -112,7 +112,7 @@ #endif
 
 	/* Overlimit strategy parameters */
 	void			(*overlimit)(struct cbq_class *cl);
-	long			penalty;
+	psched_tdiff_t		penalty;
 
 	/* General scheduler (WRR) parameters */
 	long			allot;
@@ -143,7 +143,7 @@ #endif
 	psched_time_t		undertime;
 	long			avgidle;
 	long			deficit;	/* Saved deficit for WRR */
-	unsigned long		penalized;
+	psched_time_t		penalized;
 	struct gnet_stats_basic bstats;
 	struct gnet_stats_queue qstats;
 	struct gnet_stats_rate_est rate_est;
@@ -180,7 +180,7 @@ #endif
 	psched_time_t		now_rt;		/* Cached real time */
 	unsigned		pmask;
 
-	struct timer_list	delay_timer;
+	struct hrtimer		delay_timer;
 	struct qdisc_watchdog	watchdog;	/* Watchdog timer,
 						   started when CBQ has
 						   backlog, but cannot
@@ -549,7 +549,8 @@ static void cbq_ovl_delay(struct cbq_cla
 	psched_tdiff_t delay = PSCHED_TDIFF(cl->undertime, q->now);
 
 	if (!cl->delayed) {
-		unsigned long sched = jiffies;
+		psched_time_t sched = q->now;
+		ktime_t expires;
 
 		delay += cl->offtime;
 		if (cl->avgidle < 0)
@@ -559,14 +560,18 @@ static void cbq_ovl_delay(struct cbq_cla
 		PSCHED_TADD2(q->now, delay, cl->undertime);
 
 		if (delay > 0) {
-			sched += PSCHED_US2JIFFIE(delay) + cl->penalty;
+			sched += delay + cl->penalty;
 			cl->penalized = sched;
 			cl->cpriority = TC_CBQ_MAXPRIO;
 			q->pmask |= (1<<TC_CBQ_MAXPRIO);
-			if (del_timer(&q->delay_timer) &&
-			    (long)(q->delay_timer.expires - sched) > 0)
-				q->delay_timer.expires = sched;
-			add_timer(&q->delay_timer);
+
+			expires = ktime_set(0, 0);
+			expires = ktime_add_ns(expires, PSCHED_US2NS(sched));
+			if (hrtimer_try_to_cancel(&q->delay_timer) &&
+			    ktime_to_ns(ktime_sub(q->delay_timer.expires,
+			    			  expires)) > 0)
+				q->delay_timer.expires = expires;
+			hrtimer_restart(&q->delay_timer);
 			cl->delayed = 1;
 			cl->xstats.overactions++;
 			return;
@@ -583,7 +588,7 @@ static void cbq_ovl_lowprio(struct cbq_c
 {
 	struct cbq_sched_data *q = qdisc_priv(cl->qdisc);
 
-	cl->penalized = jiffies + cl->penalty;
+	cl->penalized = q->now + cl->penalty;
 
 	if (cl->cpriority != cl->priority2) {
 		cl->cpriority = cl->priority2;
@@ -604,19 +609,19 @@ static void cbq_ovl_drop(struct cbq_clas
 	cbq_ovl_classic(cl);
 }
 
-static unsigned long cbq_undelay_prio(struct cbq_sched_data *q, int prio)
+static psched_tdiff_t cbq_undelay_prio(struct cbq_sched_data *q, int prio,
+				       psched_time_t now)
 {
 	struct cbq_class *cl;
 	struct cbq_class *cl_prev = q->active[prio];
-	unsigned long now = jiffies;
-	unsigned long sched = now;
+	psched_time_t sched = now;
 
 	if (cl_prev == NULL)
 		return 0;
 
 	do {
 		cl = cl_prev->next_alive;
-		if ((long)(now - cl->penalized) > 0) {
+		if (now - cl->penalized > 0) {
 			cl_prev->next_alive = cl->next_alive;
 			cl->next_alive = NULL;
 			cl->cpriority = cl->priority;
@@ -632,30 +637,34 @@ static unsigned long cbq_undelay_prio(st
 			}
 
 			cl = cl_prev->next_alive;
-		} else if ((long)(sched - cl->penalized) > 0)
+		} else if (sched - cl->penalized > 0)
 			sched = cl->penalized;
 	} while ((cl_prev = cl) != q->active[prio]);
 
-	return (long)(sched - now);
+	return sched - now;
 }
 
-static void cbq_undelay(unsigned long arg)
+static enum hrtimer_restart cbq_undelay(struct hrtimer *timer)
 {
-	struct Qdisc *sch = (struct Qdisc*)arg;
-	struct cbq_sched_data *q = qdisc_priv(sch);
-	long delay = 0;
+	struct cbq_sched_data *q = container_of(timer, struct cbq_sched_data,
+						delay_timer);
+	struct Qdisc *sch = q->watchdog.qdisc;
+	psched_time_t now;
+	psched_tdiff_t delay = 0;
 	unsigned pmask;
 
+	PSCHED_GET_TIME(now);
+
 	pmask = q->pmask;
 	q->pmask = 0;
 
 	while (pmask) {
 		int prio = ffz(~pmask);
-		long tmp;
+		psched_tdiff_t tmp;
 
 		pmask &= ~(1<<prio);
 
-		tmp = cbq_undelay_prio(q, prio);
+		tmp = cbq_undelay_prio(q, prio, now);
 		if (tmp > 0) {
 			q->pmask |= 1<<prio;
 			if (tmp < delay || delay == 0)
@@ -664,12 +673,16 @@ static void cbq_undelay(unsigned long ar
 	}
 
 	if (delay) {
-		q->delay_timer.expires = jiffies + delay;
-		add_timer(&q->delay_timer);
+		ktime_t time;
+
+		time = ktime_set(0, 0);
+		time = ktime_add_ns(time, PSCHED_US2NS(now + delay));
+		hrtimer_start(&q->delay_timer, time, HRTIMER_MODE_ABS);
 	}
 
 	sch->flags &= ~TCQ_F_THROTTLED;
 	netif_schedule(sch->dev);
+	return HRTIMER_NORESTART;
 }
 
 
@@ -1265,7 +1278,7 @@ cbq_reset(struct Qdisc* sch)
 	q->tx_class = NULL;
 	q->tx_borrowed = NULL;
 	qdisc_watchdog_cancel(&q->watchdog);
-	del_timer(&q->delay_timer);
+	hrtimer_cancel(&q->delay_timer);
 	q->toplevel = TC_CBQ_MAXLEVEL;
 	PSCHED_GET_TIME(q->now);
 	q->now_rt = q->now;
@@ -1367,7 +1380,7 @@ static int cbq_set_overlimit(struct cbq_
 	default:
 		return -EINVAL;
 	}
-	cl->penalty = (ovl->penalty*HZ)/1000;
+	cl->penalty = ovl->penalty;
 	return 0;
 }
 
@@ -1435,8 +1448,7 @@ static int cbq_init(struct Qdisc *sch, s
 	q->link.stats_lock = &sch->dev->queue_lock;
 
 	qdisc_watchdog_init(&q->watchdog, sch);
-	init_timer(&q->delay_timer);
-	q->delay_timer.data = (unsigned long)sch;
+	hrtimer_init(&q->delay_timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
 	q->delay_timer.function = cbq_undelay;
 	q->toplevel = TC_CBQ_MAXLEVEL;
 	PSCHED_GET_TIME(q->now);
@@ -1514,7 +1526,7 @@ static __inline__ int cbq_dump_ovl(struc
 	opt.strategy = cl->ovl_strategy;
 	opt.priority2 = cl->priority2+1;
 	opt.pad = 0;
-	opt.penalty = (cl->penalty*1000)/HZ;
+	opt.penalty = cl->penalty;
 	RTA_PUT(skb, TCA_CBQ_OVL_STRATEGY, sizeof(opt), &opt);
 	return skb->len;
 
