From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: dynticks + iptables almost stops the boot process [was: Re:
	2.6.20-rc6-mm3]
Date: Wed, 07 Feb 2007 00:17:33 +0100
Message-ID: <1170803853.3785.45.camel@chaos>
References: <20070131215241.GB2890@inferi.kami.home>
	 <20070131232130.GC4137@inferi.kami.home>
	 <1170358572.29240.292.camel@localhost.localdomain>
	 <1170360101.29240.297.camel@localhost.localdomain>
	 <20070201211137.GA2830@inferi.kami.home>
	 <1170369202.29240.339.camel@localhost.localdomain>
	 <20070202191802.GA4262@inferi.kami.home>
	 <1170448034.29240.364.camel@localhost.localdomain>
	 <20070202204344.GB4262@inferi.kami.home> <20070206164826.GA3491@elte.hu>
	 <20070206192840.GB2971@inferi.kami.home>  <45C90B57.90104@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@osdl.org>,
	linux-kernel@vger.kernel.org, mingo@redhat.com,
	netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([213.239.205.134]:38192 "EHLO mail.tglx.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1030551AbXBFXRY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Feb 2007 18:17:24 -0500
In-Reply-To: <45C90B57.90104@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2007-02-07 at 00:12 +0100, Tilman Schmidt wrote:
> > No, not this. Anyway the last patch Thomas forwarded does fix the
> > problem.
> 
> Which one would that be? I might try it for comparison.

Find the combined patch of all fixlets on top of -mm3 below.

	tglx

Index: linux-2.6.20/kernel/timer.c
===================================================================
--- linux-2.6.20.orig/kernel/timer.c
+++ linux-2.6.20/kernel/timer.c
@@ -985,8 +985,9 @@ static int timekeeping_resume(struct sys
 
 	if (now && (now > timekeeping_suspend_time)) {
 		unsigned long sleep_length = now - timekeeping_suspend_time;
+
 		xtime.tv_sec += sleep_length;
-		jiffies_64 += (u64)sleep_length * HZ;
+		wall_to_monotonic.tv_sec -= sleep_length;
 	}
 	/* re-base the last cycle value */
 	clock->cycle_last = clocksource_read(clock);
@@ -994,7 +995,7 @@ static int timekeeping_resume(struct sys
 	timekeeping_suspended = 0;
 	write_sequnlock_irqrestore(&xtime_lock, flags);
 
-	clockevents_notify(CLOCK_EVT_NOTIFY_RESUME, NULL);
+	touch_softlockup_watchdog();
 	/* Resume hrtimers */
 	clock_was_set();
 
Index: linux-2.6.20/kernel/time/clockevents.c
===================================================================
--- linux-2.6.20.orig/kernel/time/clockevents.c
+++ linux-2.6.20/kernel/time/clockevents.c
@@ -42,8 +42,8 @@ unsigned long clockevent_delta2ns(unsign
 	u64 clc = ((u64) latch << evt->shift);
 
 	do_div(clc, evt->mult);
-	if (clc < KTIME_MONOTONIC_RES.tv64)
-		clc = KTIME_MONOTONIC_RES.tv64;
+	if (clc < 1000)
+		clc = 1000;
 	if (clc > LONG_MAX)
 		clc = LONG_MAX;
 
@@ -72,18 +72,22 @@ void clockevents_set_mode(struct clock_e
  *
  * Returns 0 on success, -ETIME when the event is in the past.
  */
-int clockevents_program_event(struct clock_event_device *dev, ktime_t expires)
+int clockevents_program_event(struct clock_event_device *dev, ktime_t expires,
+			      ktime_t now)
 {
 	unsigned long long clc;
 	int64_t delta;
 
-	delta = ktime_to_ns(ktime_sub(expires, ktime_get()));
+	delta = ktime_to_ns(ktime_sub(expires, now));
 
 	if (delta <= 0)
 		return -ETIME;
 
 	dev->next_event = expires;
 
+	if (dev->mode == CLOCK_EVT_MODE_SHUTDOWN)
+		return 0;
+
 	if (delta > dev->max_delta_ns)
 		delta = dev->max_delta_ns;
 	if (delta < dev->min_delta_ns)
Index: linux-2.6.20/kernel/time/tick-broadcast.c
===================================================================
--- linux-2.6.20.orig/kernel/time/tick-broadcast.c
+++ linux-2.6.20/kernel/time/tick-broadcast.c
@@ -159,6 +159,8 @@ static void tick_do_periodic_broadcast(v
  */
 static void tick_handle_periodic_broadcast(struct clock_event_device *dev)
 {
+	dev->next_event.tv64 = KTIME_MAX;
+
 	tick_do_periodic_broadcast();
 
 	/*
@@ -174,7 +176,7 @@ static void tick_handle_periodic_broadca
 	for (;;) {
 		ktime_t next = ktime_add(dev->next_event, tick_period);
 
-		if (!clockevents_program_event(dev, next))
+		if (!clockevents_program_event(dev, next, ktime_get()))
 			return;
 		tick_do_periodic_broadcast();
 	}
@@ -294,17 +296,31 @@ cpumask_t *tick_get_broadcast_oneshot_ma
 	return &tick_broadcast_oneshot_mask;
 }
 
+static int tick_broadcast_set_event(ktime_t expires, int force)
+{
+	struct clock_event_device *bc = tick_broadcast_device.evtdev;
+	ktime_t now = ktime_get();
+	int res;
+
+	for(;;) {
+		res = clockevents_program_event(bc, expires, now);
+		if (!res || !force)
+			return res;
+		now = ktime_get();
+		expires = ktime_add(now, ktime_set(0, bc->min_delta_ns));
+	}
+}
+
 /*
  * Reprogram the broadcast device:
  *
  * Called with tick_broadcast_lock held and interrupts disabled.
  */
-static int tick_broadcast_reprogram(int force)
+static int tick_broadcast_reprogram(void)
 {
-	struct clock_event_device *bc = tick_broadcast_device.evtdev;
-	ktime_t tmp, expires = { .tv64 = KTIME_MAX };
+	ktime_t expires = { .tv64 = KTIME_MAX };
 	struct tick_device *td;
-	int cpu, res;
+	int cpu;
 
 	/*
 	 * Find the event which expires next:
@@ -319,13 +335,7 @@ static int tick_broadcast_reprogram(int 
 	if (expires.tv64 == KTIME_MAX)
 		return 0;
 
-	for(;;) {
-		res = clockevents_program_event(bc, expires);
-		if (!res || !force)
-			return res;
-		tmp = ktime_set(0, bc->min_delta_ns << 1);
-		expires = ktime_add(ktime_get(), tmp);
-	}
+	return tick_broadcast_set_event(expires, 0);
 }
 
 /*
@@ -333,14 +343,15 @@ static int tick_broadcast_reprogram(int 
  */
 static void tick_handle_oneshot_broadcast(struct clock_event_device *dev)
 {
-	ktime_t now;
 	struct tick_device *td;
-	cpumask_t mask = CPU_MASK_NONE;
+	cpumask_t mask;
+	ktime_t now;
 	int cpu;
 
 	spin_lock(&tick_broadcast_lock);
-
 again:
+	dev->next_event.tv64 = KTIME_MAX;
+	mask = CPU_MASK_NONE;
 	now = ktime_get();
 	/* Find all expired events */
 	for (cpu = first_cpu(tick_broadcast_oneshot_mask); cpu != NR_CPUS;
@@ -360,7 +371,7 @@ again:
 		 * events. This happens in dyntick mode, as the
 		 * maximum PIT delta is quite small.
 		 */
-		if (tick_broadcast_reprogram(0))
+		if (tick_broadcast_reprogram())
 			goto again;
 	}
 	spin_unlock(&tick_broadcast_lock);
@@ -398,6 +409,8 @@ void tick_broadcast_oneshot_control(unsi
 		if (!cpu_isset(cpu, tick_broadcast_oneshot_mask)) {
 			cpu_set(cpu, tick_broadcast_oneshot_mask);
 			clockevents_set_mode(dev, CLOCK_EVT_MODE_SHUTDOWN);
+			if (dev->next_event.tv64 < bc->next_event.tv64)
+				tick_broadcast_set_event(dev->next_event, 1);
 		}
 	} else {
 		if (cpu_isset(cpu, tick_broadcast_oneshot_mask)) {
@@ -408,8 +421,6 @@ void tick_broadcast_oneshot_control(unsi
 		}
 	}
 
-	if (!cpus_empty(tick_broadcast_oneshot_mask))
-		tick_broadcast_reprogram(1);
 out:
 	spin_unlock_irqrestore(&tick_broadcast_lock, flags);
 }
@@ -422,6 +433,7 @@ void tick_broadcast_setup_oneshot(struct
 	if (bc->mode != CLOCK_EVT_MODE_ONESHOT) {
 		bc->event_handler = tick_handle_oneshot_broadcast;
 		clockevents_set_mode(bc, CLOCK_EVT_MODE_ONESHOT);
+		bc->next_event.tv64 = KTIME_MAX;
 	}
 }
 
Index: linux-2.6.20/include/linux/clockchips.h
===================================================================
--- linux-2.6.20.orig/include/linux/clockchips.h
+++ linux-2.6.20/include/linux/clockchips.h
@@ -128,7 +128,7 @@ extern void clockevents_set_mode(struct 
 extern int clockevents_register_notifier(struct notifier_block *nb);
 extern void clockevents_unregister_notifier(struct notifier_block *nb);
 extern int clockevents_program_event(struct clock_event_device *dev,
-				     ktime_t expires);
+				     ktime_t expires, ktime_t now);
 
 extern void clockevents_notify(unsigned long reason, void *arg);
 
Index: linux-2.6.20/kernel/time/tick-common.c
===================================================================
--- linux-2.6.20.orig/kernel/time/tick-common.c
+++ linux-2.6.20/kernel/time/tick-common.c
@@ -89,7 +89,7 @@ void tick_handle_periodic(struct clock_e
 	for (;;) {
 		ktime_t next = ktime_add(dev->next_event, tick_period);
 
-		if (!clockevents_program_event(dev, next))
+		if (!clockevents_program_event(dev, next, ktime_get()))
 			return;
 		tick_periodic(cpu);
 	}
@@ -120,7 +120,7 @@ void tick_setup_periodic(struct clock_ev
 		clockevents_set_mode(dev, CLOCK_EVT_MODE_ONESHOT);
 
 		for (;;) {
-			if (!clockevents_program_event(dev, next))
+			if (!clockevents_program_event(dev, next, ktime_get()))
 				return;
 			next = ktime_add(next, tick_period);
 		}
Index: linux-2.6.20/kernel/time/tick-oneshot.c
===================================================================
--- linux-2.6.20.orig/kernel/time/tick-oneshot.c
+++ linux-2.6.20/kernel/time/tick-oneshot.c
@@ -28,14 +28,15 @@
 int tick_program_event(ktime_t expires, int force)
 {
 	struct clock_event_device *dev = __get_cpu_var(tick_cpu_device).evtdev;
+	ktime_t now = ktime_get();
 
 	while (1) {
-		int ret = clockevents_program_event(dev, expires);
+		int ret = clockevents_program_event(dev, expires, now);
 
 		if (!ret || !force)
 			return ret;
-		expires = ktime_add(expires,
-				    ktime_set(0, dev->min_delta_ns << 2));
+		now = ktime_get();
+		expires = ktime_add(now, ktime_set(0, dev->min_delta_ns));
 	}
 }
 
@@ -48,7 +49,7 @@ void tick_setup_oneshot(struct clock_eve
 {
 	newdev->event_handler = handler;
 	clockevents_set_mode(newdev, CLOCK_EVT_MODE_ONESHOT);
-	clockevents_program_event(newdev, next_event);
+	clockevents_program_event(newdev, next_event, ktime_get());
 }
 
 /**
Index: linux-2.6.20/kernel/time/tick-sched.c
===================================================================
--- linux-2.6.20.orig/kernel/time/tick-sched.c
+++ linux-2.6.20/kernel/time/tick-sched.c
@@ -137,13 +137,15 @@ __setup("nohz=", setup_tick_nohz);
  */
 void tick_nohz_update_jiffies(void)
 {
-	struct tick_sched *ts = &__get_cpu_var(tick_cpu_sched);
+	int cpu = smp_processor_id();
+	struct tick_sched *ts = &per_cpu(tick_cpu_sched, cpu);
 	unsigned long flags;
 	ktime_t now;
 
 	if (!ts->tick_stopped)
 		return;
 
+	cpu_clear(cpu, nohz_cpu_mask);
 	now = ktime_get();
 
 	local_irq_save(flags);
@@ -161,17 +163,24 @@ void tick_nohz_update_jiffies(void)
 void tick_nohz_stop_sched_tick(void)
 {
 	unsigned long seq, last_jiffies, next_jiffies, delta_jiffies, flags;
-	struct tick_sched *ts = &__get_cpu_var(tick_cpu_sched);
+	struct tick_sched *ts;
 	ktime_t last_update, expires, now, delta;
-
-	if (unlikely(ts->nohz_mode == NOHZ_MODE_INACTIVE))
-		return;
+	int cpu;
 
 	local_irq_save(flags);
 
+	cpu = smp_processor_id();
+	ts = &per_cpu(tick_cpu_sched, cpu);
+
+	if (unlikely(ts->nohz_mode == NOHZ_MODE_INACTIVE))
+		goto end;
+
 	if (need_resched())
 		goto end;
 
+	cpu = smp_processor_id();
+	BUG_ON(local_softirq_pending());
+
 	now = ktime_get();
 	/*
 	 * When called from irq_exit we need to account the idle sleep time
@@ -196,12 +205,20 @@ void tick_nohz_stop_sched_tick(void)
 	next_jiffies = get_next_timer_interrupt(last_jiffies);
 	delta_jiffies = next_jiffies - last_jiffies;
 
-	/* Do not stop the tick, if we are only one off */
-	if (!ts->tick_stopped && delta_jiffies == 1)
+	/*
+	 * Do not stop the tick, if we are only one off
+	 * or if the cpu is required for rcu
+	 */
+	if (!ts->tick_stopped && (delta_jiffies == 1 || rcu_needs_cpu(cpu)))
 		goto out;
 
 	/* Schedule the tick, if we are at least one jiffie off */
 	if ((long)delta_jiffies >= 1) {
+
+		if (rcu_needs_cpu(cpu))
+			delta_jiffies = 1;
+		else
+			cpu_set(cpu, nohz_cpu_mask);
 		/*
 		 * nohz_stop_sched_tick can be called several times before
 		 * the nohz_restart_sched_tick is called. This happens when
@@ -237,6 +254,7 @@ void tick_nohz_stop_sched_tick(void)
 		 * softirq.
 		 */
 		tick_do_update_jiffies64(ktime_get());
+		cpu_clear(cpu, nohz_cpu_mask);
 	}
 	raise_softirq_irqoff(TIMER_SOFTIRQ);
 out:
@@ -253,7 +271,8 @@ end:
  */
 void tick_nohz_restart_sched_tick(void)
 {
-	struct tick_sched *ts = &__get_cpu_var(tick_cpu_sched);
+	int cpu = smp_processor_id();
+	struct tick_sched *ts = &per_cpu(tick_cpu_sched, cpu);
 	unsigned long ticks;
 	ktime_t now, delta;
 
@@ -265,6 +284,7 @@ void tick_nohz_restart_sched_tick(void)
 
 	local_irq_disable();
 	tick_do_update_jiffies64(now);
+	cpu_clear(cpu, nohz_cpu_mask);
 
 	/* Account the idle time */
 	delta = ktime_sub(now, ts->idle_entrytime);


