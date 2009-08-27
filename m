From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 11/14] pktgen: spin using hrtimer
Date: Thu, 27 Aug 2009 16:55:17 -0700
Message-ID: <20090827235705.985449360@vyatta.com>
References: <20090827235506.624381734@vyatta.com>
Cc: netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58751 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752742AbZH0X7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 19:59:19 -0400
Content-Disposition: inline; filename=pktgen-hrtimer-spin.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This changes how the pktgen thread spins/waits between
packets if delay is configured. It uses a high res timer to
wait for time to arrive.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 kernel/hrtimer.c  |    1 +
 net/core/pktgen.c |   49 ++++++++++++++++++++++++++++---------------------
 2 files changed, 29 insertions(+), 21 deletions(-)

--- a/net/core/pktgen.c	2009-08-27 16:00:52.538250235 -0700
+++ b/net/core/pktgen.c	2009-08-27 16:28:17.520270294 -0700
@@ -131,6 +131,7 @@
 #include <linux/ioport.h>
 #include <linux/interrupt.h>
 #include <linux/capability.h>
+#include <linux/hrtimer.h>
 #include <linux/freezer.h>
 #include <linux/delay.h>
 #include <linux/timer.h>
@@ -2086,33 +2087,40 @@ static void pktgen_setup_inject(struct p
 	pkt_dev->nflows = 0;
 }
 
-static inline s64 delta_ns(ktime_t a, ktime_t b)
-{
-	return ktime_to_ns(ktime_sub(a, b));
-}
 
 static void spin(struct pktgen_dev *pkt_dev, ktime_t spin_until)
 {
-	ktime_t start, now;
-	s64 dt;
+	ktime_t start;
+	s32 remaining;
+	struct hrtimer_sleeper t;
 
-	start = now = ktime_now();
+	hrtimer_init_on_stack(&t.timer, CLOCK_MONOTONIC, HRTIMER_MODE_ABS);
+	hrtimer_set_expires(&t.timer, spin_until);
 
-	while ((dt = delta_ns(spin_until, now)) > 0) {
-		/* TODO: optimize sleeping behavior */
-		if (dt > TICK_NSEC)
-			schedule_timeout_interruptible(1);
-		else if (dt > 100*NSEC_PER_USEC) {
-			if (!pkt_dev->running)
-				return;
-			if (need_resched())
+	remaining = ktime_to_us(hrtimer_expires_remaining(&t.timer));
+	if (remaining <= 0)
+		return;
+
+	start = ktime_now();
+	if (remaining < 100)
+		udelay(remaining); 	/* really small just spin */
+	else {
+		/* see do_nanosleep */
+		hrtimer_init_sleeper(&t, current);
+		do {
+			set_current_state(TASK_INTERRUPTIBLE);
+			hrtimer_start_expires(&t.timer, HRTIMER_MODE_ABS);
+			if (!hrtimer_active(&t.timer))
+				t.task = NULL;
+
+			if (likely(t.task))
 				schedule();
-		}
 
-		now = ktime_now();
+			hrtimer_cancel(&t.timer);
+		} while (t.task && pkt_dev->running && !signal_pending(current));
+		__set_current_state(TASK_RUNNING);
 	}
-
-	pkt_dev->idle_acc += ktime_to_ns(ktime_sub(now, start));
+	pkt_dev->idle_acc += ktime_to_ns(ktime_sub(ktime_now(), start));
 }
 
 static inline void set_pkt_overhead(struct pktgen_dev *pkt_dev)
@@ -3360,8 +3368,7 @@ static void pktgen_xmit(struct pktgen_de
 	int ret;
 
 	if (pkt_dev->delay) {
-		if (ktime_lt(ktime_now(), pkt_dev->next_tx))
-			spin(pkt_dev, pkt_dev->next_tx);
+		spin(pkt_dev, pkt_dev->next_tx);
 
 		/* This is max DELAY, this has special meaning of
 		 * "never transmit"
--- a/kernel/hrtimer.c	2009-08-27 16:00:52.547269763 -0700
+++ b/kernel/hrtimer.c	2009-08-27 16:02:04.543287103 -0700
@@ -1477,6 +1477,7 @@ void hrtimer_init_sleeper(struct hrtimer
 	sl->timer.function = hrtimer_wakeup;
 	sl->task = task;
 }
+EXPORT_SYMBOL_GPL(hrtimer_init_sleeper);
 
 static int __sched do_nanosleep(struct hrtimer_sleeper *t, enum hrtimer_mode mode)
 {

-- 

