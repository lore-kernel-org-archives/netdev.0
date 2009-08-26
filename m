From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC 2/4] pktgen: spin using hrtimer
Date: Tue, 25 Aug 2009 23:15:15 -0700
Message-ID: <20090826061728.694353568@vyatta.com>
References: <20090826061513.755294685@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Robert Olsson <Robert.Olsson@data.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:36519 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751375AbZHZGZ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 02:25:57 -0400
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>
Content-Disposition: inline; filename=pktgen-hrtimer-spin.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This changes how the pktgen thread spins/waits between
packets if delay is configured.  The new code is basically
an revised version of what the nanosleep system call does.

It requires exporting hrtimer_init_sleeper from standard hrtimer
code, since pktgen can be a module.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
 kernel/hrtimer.c  |    1 +
 net/core/pktgen.c |   43 ++++++++++++++++++++++++++-----------------
 2 files changed, 27 insertions(+), 17 deletions(-)

--- a/net/core/pktgen.c	2009-08-25 22:49:33.979402479 -0700
+++ b/net/core/pktgen.c	2009-08-25 22:49:55.966424251 -0700
@@ -131,6 +131,7 @@
 #include <linux/ioport.h>
 #include <linux/interrupt.h>
 #include <linux/capability.h>
+#include <linux/hrtimer.h>
 #include <linux/freezer.h>
 #include <linux/delay.h>
 #include <linux/timer.h>
@@ -2084,33 +2085,32 @@ static void pktgen_setup_inject(struct p
 	pkt_dev->nflows = 0;
 }
 
-static inline s64 delta_ns(ktime_t a, ktime_t b)
-{
-	return ktime_to_ns(ktime_sub(a, b));
-}
-
 static void spin(struct pktgen_dev *pkt_dev, ktime_t spin_until)
 {
-	ktime_t start, now;
-	s64 dt;
+	struct hrtimer_sleeper t;
+	enum hrtimer_mode mode = HRTIMER_MODE_REL;
+	unsigned long slack = rt_task(current) ? 0 : current->timer_slack_ns;
+
+	hrtimer_init_on_stack(&t.timer, CLOCK_MONOTONIC, mode);
+	hrtimer_set_expires_range_ns(&t.timer, spin_until, slack);
+	hrtimer_init_sleeper(&t, current);
 
-	start = now = ktime_now();
+	/* based on do_nanosleep() */
+	do {
+		set_current_state(TASK_INTERRUPTIBLE);
+		hrtimer_start_expires(&t.timer, mode);
+		if (!hrtimer_active(&t.timer))
+			t.task = NULL;
 
-	while ((dt = delta_ns(spin_until, now)) > 0) {
-		/* TODO: optimize sleeping behavior */
-		if (dt > TICK_NSEC)
-			schedule_timeout_interruptible(1);
-		else if (dt > 100*NSEC_PER_USEC) {
-			if (!pkt_dev->running)
-				return;
-			if (need_resched())
-				schedule();
-		}
+		if (likely(t.task))
+			schedule();
 
-		now = ktime_now();
-	}
+		hrtimer_cancel(&t.timer);
+		mode = HRTIMER_MODE_ABS;
+	} while (t.task && pkt_dev->running && !signal_pending(current));
 
-	pkt_dev->idle_acc += ktime_to_ns(ktime_sub(now, start));
+	__set_current_state(TASK_RUNNING);
+	destroy_hrtimer_on_stack(&t.timer);
 }
 
 static inline void set_pkt_overhead(struct pktgen_dev *pkt_dev)
@@ -3352,8 +3352,12 @@ static __inline__ void pktgen_xmit(struc
 	int ret;
 
 	if (pkt_dev->delay) {
-		if (ktime_lt(ktime_now(), pkt_dev->next_tx))
+		ktime_t start = ktime_now();
+		if (ktime_lt(start, pkt_dev->next_tx)) {
 			spin(pkt_dev, pkt_dev->next_tx);
+			pkt_dev->idle_acc += ktime_to_ns(ktime_sub(ktime_now(),
+								   start));
+		}
 
 		/* This is max DELAY, this has special meaning of
 		 * "never transmit"
--- a/kernel/hrtimer.c	2009-08-25 22:49:29.768405220 -0700
+++ b/kernel/hrtimer.c	2009-08-25 22:49:48.777711560 -0700
@@ -1477,6 +1477,7 @@ void hrtimer_init_sleeper(struct hrtimer
 	sl->timer.function = hrtimer_wakeup;
 	sl->task = task;
 }
+EXPORT_SYMBOL_GPL(hrtimer_init_sleeper);
 
 static int __sched do_nanosleep(struct hrtimer_sleeper *t, enum hrtimer_mode mode)
 {

-- 

