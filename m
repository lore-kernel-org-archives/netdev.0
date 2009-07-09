From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch 3/3] net: use HRTIMER_RESTART in sched_cbq
Date: Thu, 09 Jul 2009 21:59:34 -0000
Message-ID: <20090709215606.725707255@linutronix.de>
References: <20090709215455.703939259@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Peter Zijlstra <peterz@infradead.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.tglx.de ([62.245.132.106]:37953 "EHLO www.tglx.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757133AbZGIV7y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Jul 2009 17:59:54 -0400
Content-Disposition: inline; filename=net-sched-cbq-use-hrtimer-restart.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Restarting a hrtimer from the callback function via hrtimer_start is
inefficient. The canonical way is to modify the expiry value of the
timer and return HRTIMER_RESTART to the hrtimer core code which takes
care of the restart.

Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 net/sched/sch_cbq.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

Index: linux-2.6/net/sched/sch_cbq.c
===================================================================
--- linux-2.6.orig/net/sched/sch_cbq.c
+++ linux-2.6/net/sched/sch_cbq.c
@@ -605,6 +605,7 @@ static enum hrtimer_restart cbq_undelay(
 	struct cbq_sched_data *q = container_of(timer, struct cbq_sched_data,
 						delay_timer);
 	struct Qdisc *sch = q->watchdog.qdisc;
+	enum hrtimer_restart ret = HRTIMER_NORESTART;
 	psched_time_t now;
 	psched_tdiff_t delay = 0;
 	unsigned pmask;
@@ -634,13 +635,14 @@ static enum hrtimer_restart cbq_undelay(
 
 		time = ktime_set(0, 0);
 		time = ktime_add_ns(time, PSCHED_TICKS2NS(now + delay));
-		hrtimer_start(&q->delay_timer, time, HRTIMER_MODE_ABS);
+		hrtimer_set_expires(&q->delay_timer, time);
+		ret = HRTIMER_RESTART;
 	}
 	spin_unlock(&q->lock);
 
 	sch->flags &= ~TCQ_F_THROTTLED;
 	__netif_schedule(qdisc_root(sch));
-	return HRTIMER_NORESTART;
+	return ret;
 }
 
 #ifdef CONFIG_NET_CLS_ACT


