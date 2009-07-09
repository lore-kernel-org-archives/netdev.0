From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 1/3] net: serialize hrtimer callback in sched_cbq
Date: Thu, 09 Jul 2009 21:59:22 -0000
Message-ID: <20090709215606.526259917@linutronix.de>
References: <20090709215455.703939259@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Peter Zijlstra <peterz@infradead.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:37942 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756882AbZGIV7n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 17:59:43 -0400
Content-Disposition: inline;
	filename=net-sched-cbq-serialize-hrtimer-callback.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hrtimer callback cbq_undelay() is not serialized against
cbq_ovl_delay(). That affects at least q->pmask and q->delay_timer.

Lock it proper.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 net/sched/sch_cbq.c |    8 ++++++++
 1 file changed, 8 insertions(+)

Index: linux-2.6/net/sched/sch_cbq.c
===================================================================
--- linux-2.6.orig/net/sched/sch_cbq.c
+++ linux-2.6/net/sched/sch_cbq.c
@@ -163,6 +163,7 @@ struct cbq_sched_data
 	psched_time_t		now_rt;		/* Cached real time */
 	unsigned		pmask;
 
+	spinlock_t		lock;
 	struct hrtimer		delay_timer;
 	struct qdisc_watchdog	watchdog;	/* Watchdog timer,
 						   started when CBQ has
@@ -503,6 +504,9 @@ static void cbq_ovl_delay(struct cbq_cla
 		cl->undertime = q->now + delay;
 
 		if (delay > 0) {
+			unsigned long flags;
+
+			spin_lock_irqsave(&q->lock, flags);
 			sched += delay + cl->penalty;
 			cl->penalized = sched;
 			cl->cpriority = TC_CBQ_MAXPRIO;
@@ -518,6 +522,7 @@ static void cbq_ovl_delay(struct cbq_cla
 			hrtimer_restart(&q->delay_timer);
 			cl->delayed = 1;
 			cl->xstats.overactions++;
+			spin_unlock_irqrestore(&q->lock, flags);
 			return;
 		}
 		delay = 1;
@@ -599,6 +604,7 @@ static enum hrtimer_restart cbq_undelay(
 
 	now = psched_get_time();
 
+	spin_lock(&q->lock);
 	pmask = q->pmask;
 	q->pmask = 0;
 
@@ -623,6 +629,7 @@ static enum hrtimer_restart cbq_undelay(
 		time = ktime_add_ns(time, PSCHED_TICKS2NS(now + delay));
 		hrtimer_start(&q->delay_timer, time, HRTIMER_MODE_ABS);
 	}
+	spin_unlock(&q->lock);
 
 	sch->flags &= ~TCQ_F_THROTTLED;
 	__netif_schedule(qdisc_root(sch));
@@ -1396,6 +1403,7 @@ static int cbq_init(struct Qdisc *sch, s
 	q->link.avpkt = q->link.allot/2;
 	q->link.minidle = -0x7FFFFFFF;
 
+	spin_lock_init(&q->lock);
 	qdisc_watchdog_init(&q->watchdog, sch);
 	hrtimer_init(&q->delay_timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
 	q->delay_timer.function = cbq_undelay;


