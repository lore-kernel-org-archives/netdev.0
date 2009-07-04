From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: Soft-Lockup/Race in networking in 2.6.31-rc1+195 (
	possibly?caused by netem)
Date: Sat, 4 Jul 2009 17:18:55 +0200
Message-ID: <20090704151855.GA21896@ami.dom.local>
References: <200907031326.21822.andres@anarazel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arun R Bharadwaj <arun@linux.vnet.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Joao Correia <joaomiguelcorreia@gmail.com>
To: Andres Freund <andres@anarazel.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f207.google.com ([209.85.218.207]:61876 "EHLO
	mail-bw0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752977AbZGDPTF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jul 2009 11:19:05 -0400
Content-Disposition: inline
In-Reply-To: <200907031326.21822.andres@anarazel.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andres Freund wrote, On 07/03/2009 01:26 PM:

> On Friday 03 July 2009 08:12:13 Jarek Poplawski wrote:
>> On Fri, Jul 03, 2009 at 03:31:31AM +0200, Andres Freund wrote:
>> ...
>>
>>> Ok. I finally see the light. I bisected the issue down to
>>> eea08f32adb3f97553d49a4f79a119833036000a :  timers: Logic to move non
>>> pinned timers
>>>
>>> Disabling timer migration like provided in the earlier commit stops the
>>> issue from occuring.
>>>
>>> That it is related to timers is sensible in the light of my findings,
>>> that I could trigger the issue only when using delay in netem - that is
>>> the codepath using qdisc_watchdog...
>> Andres, thanks for your work and time. It saved me a lot of searching,
>> because I wasn't able to trigger this on my old box.
> Thanks. It allowed me to go through some of my remaining paperwork ;-)
> 
> Does anybody of you have an idea where the problem actually resides? 
> qdisc_watchdog_schedule looks innocent enough for my uneducated eyes - and the 
> patch/infrastructure from Arun goes over my head...
> I will happily test some ideas/patches.

Since there are still no 100% proofs nor suspects, here are some
suggestions of additional checking. This bisected commit could
probably be additionally verified by applying to 2.6.30 with a
preceding one; I attach both of them below.

Another suggestion is to try this without lockdep e.g. by setting
/sys/module/lockdep/parameters/lock_stat and prove_locking to 0.

Thanks,
Jarek P.

--------------->
commit 597d0275736dad9c3bda6f0a00a1c477dc0f37b1
Author: Arun R Bharadwaj <arun@linux.vnet.ibm.com>
Date:   Thu Apr 16 12:13:26 2009 +0530

    timers: Framework for identifying pinned timers
    
    * Arun R Bharadwaj <arun@linux.vnet.ibm.com> [2009-04-16 12:11:36]:
    
    This patch creates a new framework for identifying cpu-pinned timers
    and hrtimers.
    
    This framework is needed because pinned timers are expected to fire on
    the same CPU on which they are queued. So it is essential to identify
    these and not migrate them, in case there are any.
    
    For regular timers, the currently existing add_timer_on() can be used
    queue pinned timers and subsequently mod_timer_pinned() can be used
    to modify the 'expires' field.
    
    For hrtimers, new modes HRTIMER_ABS_PINNED and HRTIMER_REL_PINNED are
    added to queue cpu-pinned hrtimer.
    
    [ tglx: use .._PINNED mode argument instead of creating tons of new
    functions ]
    
    Signed-off-by: Arun R Bharadwaj <arun@linux.vnet.ibm.com>
    Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

diff --git a/include/linux/hrtimer.h b/include/linux/hrtimer.h
index 0d2f7c8..7400900 100644
--- a/include/linux/hrtimer.h
+++ b/include/linux/hrtimer.h
@@ -30,8 +30,11 @@ struct hrtimer_cpu_base;
  * Mode arguments of xxx_hrtimer functions:
  */
 enum hrtimer_mode {
-	HRTIMER_MODE_ABS,	/* Time value is absolute */
-	HRTIMER_MODE_REL,	/* Time value is relative to now */
+	HRTIMER_MODE_ABS = 0x0,		/* Time value is absolute */
+	HRTIMER_MODE_REL = 0x1,		/* Time value is relative to now */
+	HRTIMER_MODE_PINNED = 0x02,	/* Timer is bound to CPU */
+	HRTIMER_MODE_ABS_PINNED = 0x02,
+	HRTIMER_MODE_REL_PINNED = 0x03,
 };
 
 /*
diff --git a/include/linux/timer.h b/include/linux/timer.h
index 6cdb6f3..ccf882e 100644
--- a/include/linux/timer.h
+++ b/include/linux/timer.h
@@ -163,7 +163,10 @@ extern void add_timer_on(struct timer_list *timer, int cpu);
 extern int del_timer(struct timer_list * timer);
 extern int mod_timer(struct timer_list *timer, unsigned long expires);
 extern int mod_timer_pending(struct timer_list *timer, unsigned long expires);
+extern int mod_timer_pinned(struct timer_list *timer, unsigned long expires);
 
+#define TIMER_NOT_PINNED	0
+#define TIMER_PINNED		1
 /*
  * The jiffies value which is added to now, when there is no timer
  * in the timer wheel:
diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
index cb8a15c..c71bcd5 100644
--- a/kernel/hrtimer.c
+++ b/kernel/hrtimer.c
@@ -193,7 +193,8 @@ struct hrtimer_clock_base *lock_hrtimer_base(const struct hrtimer *timer,
  * Switch the timer base to the current CPU when possible.
  */
 static inline struct hrtimer_clock_base *
-switch_hrtimer_base(struct hrtimer *timer, struct hrtimer_clock_base *base)
+switch_hrtimer_base(struct hrtimer *timer, struct hrtimer_clock_base *base,
+		    int pinned)
 {
 	struct hrtimer_clock_base *new_base;
 	struct hrtimer_cpu_base *new_cpu_base;
@@ -907,9 +908,9 @@ int __hrtimer_start_range_ns(struct hrtimer *timer, ktime_t tim,
 	ret = remove_hrtimer(timer, base);
 
 	/* Switch the timer base, if necessary: */
-	new_base = switch_hrtimer_base(timer, base);
+	new_base = switch_hrtimer_base(timer, base, mode & HRTIMER_MODE_PINNED);
 
-	if (mode == HRTIMER_MODE_REL) {
+	if (mode & HRTIMER_MODE_REL) {
 		tim = ktime_add_safe(tim, new_base->get_time());
 		/*
 		 * CONFIG_TIME_LOW_RES is a temporary way for architectures
diff --git a/kernel/timer.c b/kernel/timer.c
index 5c1e84b..3424dfd 100644
--- a/kernel/timer.c
+++ b/kernel/timer.c
@@ -604,7 +604,8 @@ static struct tvec_base *lock_timer_base(struct timer_list *timer,
 }
 
 static inline int
-__mod_timer(struct timer_list *timer, unsigned long expires, bool pending_only)
+__mod_timer(struct timer_list *timer, unsigned long expires,
+						bool pending_only, int pinned)
 {
 	struct tvec_base *base, *new_base;
 	unsigned long flags;
@@ -668,7 +669,7 @@ out_unlock:
  */
 int mod_timer_pending(struct timer_list *timer, unsigned long expires)
 {
-	return __mod_timer(timer, expires, true);
+	return __mod_timer(timer, expires, true, TIMER_NOT_PINNED);
 }
 EXPORT_SYMBOL(mod_timer_pending);
 
@@ -702,11 +703,33 @@ int mod_timer(struct timer_list *timer, unsigned long expires)
 	if (timer->expires == expires && timer_pending(timer))
 		return 1;
 
-	return __mod_timer(timer, expires, false);
+	return __mod_timer(timer, expires, false, TIMER_NOT_PINNED);
 }
 EXPORT_SYMBOL(mod_timer);
 
 /**
+ * mod_timer_pinned - modify a timer's timeout
+ * @timer: the timer to be modified
+ * @expires: new timeout in jiffies
+ *
+ * mod_timer_pinned() is a way to update the expire field of an
+ * active timer (if the timer is inactive it will be activated)
+ * and not allow the timer to be migrated to a different CPU.
+ *
+ * mod_timer_pinned(timer, expires) is equivalent to:
+ *
+ *     del_timer(timer); timer->expires = expires; add_timer(timer);
+ */
+int mod_timer_pinned(struct timer_list *timer, unsigned long expires)
+{
+	if (timer->expires == expires && timer_pending(timer))
+		return 1;
+
+	return __mod_timer(timer, expires, false, TIMER_PINNED);
+}
+EXPORT_SYMBOL(mod_timer_pinned);
+
+/**
  * add_timer - start a timer
  * @timer: the timer to be added
  *
@@ -1356,7 +1379,7 @@ signed long __sched schedule_timeout(signed long timeout)
 	expire = timeout + jiffies;
 
 	setup_timer_on_stack(&timer, process_timeout, (unsigned long)current);
-	__mod_timer(&timer, expire, false);
+	__mod_timer(&timer, expire, false, TIMER_NOT_PINNED);
 	schedule();
 	del_singleshot_timer_sync(&timer);
 

commit eea08f32adb3f97553d49a4f79a119833036000a
Author: Arun R Bharadwaj <arun@linux.vnet.ibm.com>
Date:   Thu Apr 16 12:16:41 2009 +0530

    timers: Logic to move non pinned timers
    
    * Arun R Bharadwaj <arun@linux.vnet.ibm.com> [2009-04-16 12:11:36]:
    
    This patch migrates all non pinned timers and hrtimers to the current
    idle load balancer, from all the idle CPUs. Timers firing on busy CPUs
    are not migrated.
    
    While migrating hrtimers, care should be taken to check if migrating
    a hrtimer would result in a latency or not. So we compare the expiry of the
    hrtimer with the next timer interrupt on the target cpu and migrate the
    hrtimer only if it expires *after* the next interrupt on the target cpu.
    So, added a clockevents_get_next_event() helper function to return the
    next_event on the target cpu's clock_event_device.
    
    [ tglx: cleanups and simplifications ]
    
    Signed-off-by: Arun R Bharadwaj <arun@linux.vnet.ibm.com>
    Signed-off-by: Thomas Gleixner <tglx@linutronix.de>

diff --git a/include/linux/clockchips.h b/include/linux/clockchips.h
index 3a1dbba..20a100f 100644
--- a/include/linux/clockchips.h
+++ b/include/linux/clockchips.h
@@ -143,3 +143,12 @@ extern void clockevents_notify(unsigned long reason, void *arg);
 #endif
 
 #endif
+
+#ifdef CONFIG_GENERIC_CLOCKEVENTS
+extern ktime_t clockevents_get_next_event(int cpu);
+#else
+static inline ktime_t clockevents_get_next_event(int cpu)
+{
+	return (ktime_t) { .tv64 = KTIME_MAX };
+}
+#endif
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6185040..311dec1 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -257,6 +257,7 @@ extern void task_rq_unlock_wait(struct task_struct *p);
 extern cpumask_var_t nohz_cpu_mask;
 #if defined(CONFIG_SMP) && defined(CONFIG_NO_HZ)
 extern int select_nohz_load_balancer(int cpu);
+extern int get_nohz_load_balancer(void);
 #else
 static inline int select_nohz_load_balancer(int cpu)
 {
@@ -1772,6 +1773,17 @@ int sched_nr_latency_handler(struct ctl_table *table, int write,
 		struct file *file, void __user *buffer, size_t *length,
 		loff_t *ppos);
 #endif
+#ifdef CONFIG_SCHED_DEBUG
+static inline unsigned int get_sysctl_timer_migration(void)
+{
+	return sysctl_timer_migration;
+}
+#else
+static inline unsigned int get_sysctl_timer_migration(void)
+{
+	return 1;
+}
+#endif
 extern unsigned int sysctl_sched_rt_period;
 extern int sysctl_sched_rt_runtime;
 
diff --git a/kernel/hrtimer.c b/kernel/hrtimer.c
index c71bcd5..b675a67 100644
--- a/kernel/hrtimer.c
+++ b/kernel/hrtimer.c
@@ -43,6 +43,8 @@
 #include <linux/seq_file.h>
 #include <linux/err.h>
 #include <linux/debugobjects.h>
+#include <linux/sched.h>
+#include <linux/timer.h>
 
 #include <asm/uaccess.h>
 
@@ -198,8 +200,19 @@ switch_hrtimer_base(struct hrtimer *timer, struct hrtimer_clock_base *base,
 {
 	struct hrtimer_clock_base *new_base;
 	struct hrtimer_cpu_base *new_cpu_base;
+	int cpu, preferred_cpu = -1;
+
+	cpu = smp_processor_id();
+#if defined(CONFIG_NO_HZ) && defined(CONFIG_SMP)
+	if (!pinned && get_sysctl_timer_migration() && idle_cpu(cpu)) {
+		preferred_cpu = get_nohz_load_balancer();
+		if (preferred_cpu >= 0)
+			cpu = preferred_cpu;
+	}
+#endif
 
-	new_cpu_base = &__get_cpu_var(hrtimer_bases);
+again:
+	new_cpu_base = &per_cpu(hrtimer_bases, cpu);
 	new_base = &new_cpu_base->clock_base[base->index];
 
 	if (base != new_base) {
@@ -219,6 +232,40 @@ switch_hrtimer_base(struct hrtimer *timer, struct hrtimer_clock_base *base,
 		timer->base = NULL;
 		spin_unlock(&base->cpu_base->lock);
 		spin_lock(&new_base->cpu_base->lock);
+
+		/* Optimized away for NOHZ=n SMP=n */
+		if (cpu == preferred_cpu) {
+			/* Calculate clock monotonic expiry time */
+#ifdef CONFIG_HIGH_RES_TIMERS
+			ktime_t expires = ktime_sub(hrtimer_get_expires(timer),
+							new_base->offset);
+#else
+			ktime_t expires = hrtimer_get_expires(timer);
+#endif
+
+			/*
+			 * Get the next event on target cpu from the
+			 * clock events layer.
+			 * This covers the highres=off nohz=on case as well.
+			 */
+			ktime_t next = clockevents_get_next_event(cpu);
+
+			ktime_t delta = ktime_sub(expires, next);
+
+			/*
+			 * We do not migrate the timer when it is expiring
+			 * before the next event on the target cpu because
+			 * we cannot reprogram the target cpu hardware and
+			 * we would cause it to fire late.
+			 */
+			if (delta.tv64 < 0) {
+				cpu = smp_processor_id();
+				spin_unlock(&new_base->cpu_base->lock);
+				spin_lock(&base->cpu_base->lock);
+				timer->base = base;
+				goto again;
+			}
+		}
 		timer->base = new_base;
 	}
 	return new_base;
@@ -236,7 +283,7 @@ lock_hrtimer_base(const struct hrtimer *timer, unsigned long *flags)
 	return base;
 }
 
-# define switch_hrtimer_base(t, b)	(b)
+# define switch_hrtimer_base(t, b, p)	(b)
 
 #endif	/* !CONFIG_SMP */
 
diff --git a/kernel/sched.c b/kernel/sched.c
index 7f1dd56..9fe3774 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -4244,6 +4244,11 @@ static struct {
 	.load_balancer = ATOMIC_INIT(-1),
 };
 
+int get_nohz_load_balancer(void)
+{
+	return atomic_read(&nohz.load_balancer);
+}
+
 /*
  * This routine will try to nominate the ilb (idle load balancing)
  * owner among the cpus whose ticks are stopped. ilb owner will do the idle
diff --git a/kernel/time/clockevents.c b/kernel/time/clockevents.c
index d13be21..ab20ded 100644
--- a/kernel/time/clockevents.c
+++ b/kernel/time/clockevents.c
@@ -18,6 +18,7 @@
 #include <linux/notifier.h>
 #include <linux/smp.h>
 #include <linux/sysdev.h>
+#include <linux/tick.h>
 
 /* The registered clock event devices */
 static LIST_HEAD(clockevent_devices);
@@ -251,4 +252,15 @@ void clockevents_notify(unsigned long reason, void *arg)
 	spin_unlock(&clockevents_lock);
 }
 EXPORT_SYMBOL_GPL(clockevents_notify);
+
+ktime_t clockevents_get_next_event(int cpu)
+{
+	struct tick_device *td;
+	struct clock_event_device *dev;
+
+	td = &per_cpu(tick_cpu_device, cpu);
+	dev = td->evtdev;
+
+	return dev->next_event;
+}
 #endif
diff --git a/kernel/timer.c b/kernel/timer.c
index 3424dfd..3f841db 100644
--- a/kernel/timer.c
+++ b/kernel/timer.c
@@ -37,6 +37,7 @@
 #include <linux/delay.h>
 #include <linux/tick.h>
 #include <linux/kallsyms.h>
+#include <linux/sched.h>
 
 #include <asm/uaccess.h>
 #include <asm/unistd.h>
@@ -609,9 +610,7 @@ __mod_timer(struct timer_list *timer, unsigned long expires,
 {
 	struct tvec_base *base, *new_base;
 	unsigned long flags;
-	int ret;
-
-	ret = 0;
+	int ret = 0 , cpu;
 
 	timer_stats_timer_set_start_info(timer);
 	BUG_ON(!timer->function);
@@ -630,6 +629,18 @@ __mod_timer(struct timer_list *timer, unsigned long expires,
 
 	new_base = __get_cpu_var(tvec_bases);
 
+	cpu = smp_processor_id();
+
+#if defined(CONFIG_NO_HZ) && defined(CONFIG_SMP)
+	if (!pinned && get_sysctl_timer_migration() && idle_cpu(cpu)) {
+		int preferred_cpu = get_nohz_load_balancer();
+
+		if (preferred_cpu >= 0)
+			cpu = preferred_cpu;
+	}
+#endif
+	new_base = per_cpu(tvec_bases, cpu);
+
 	if (base != new_base) {
 		/*
 		 * We are trying to schedule the timer on the local CPU.
