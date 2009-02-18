From: Ingo Molnar <mingo@elte.hu>
Subject: [patch] timers: add mod_timer_pending()
Date: Wed, 18 Feb 2009 13:05:08 +0100
Message-ID: <20090218120508.GB4100@elte.hu>
References: <20090218051906.174295181@vyatta.com> <20090218052747.437271195@vyatta.com> <20090218092041.GC3294@elte.hu> <499BDDFE.5010101@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Rick Jones <rick.jones2@hp.com>,
	Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, tglx@linutronix.de,
	Martin Josefsson <gandalf@wlug.westbo.se>
To: Patrick McHardy <kaber@trash.net>, Oleg Nesterov <oleg@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <499BDDFE.5010101@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Patrick McHardy <kaber@trash.net> wrote:

> Ingo Molnar wrote:
>>> -extern int __mod_timer(struct timer_list *timer, unsigned long expires);
>>> +extern int __mod_timer(struct timer_list *timer, unsigned long expires, int activate);
>>
>> This is not really acceptable, it slows down every single add_timer() 
>> and mod_timer() call in the kernel with a flag that has one specific 
>> value in all but your case. There's more than 2000 such callsites in 
>> the kernel.
>>
>> Why dont you use something like this instead:
>>
>> 	if (del_timer(timer))
>> 		add_timer(timer);
>
> We need to avoid having a timer that was deleted by one CPU
> getting re-added by another, but want to avoid taking the
> conntrack lock for every timer update. The timer-internal
> locking is enough for this as long as we have a mod_timer
> variant that forwards a timer, but doesn't activate it in
> case it isn't active already.

that makes sense - but the implementation is still somewhat 
ugly. How about the one below instead? Not tested.

One open question is this construct in mod_timer():

+	/*
+	 * This is a common optimization triggered by the
+	 * networking code - if the timer is re-modified
+	 * to be the same thing then just return:
+	 */
+	if (timer->expires == expires && timer_pending(timer))
+		return 1;

We've had this for ages, but it seems rather SMP-unsafe. 
timer_pending(), if used in an unserialized fashion, can be any 
random value in theory - there's no internal serialization here 
anywhere.

We could end up with incorrectly not re-activating a timer in 
mod_timer() for example - have such things never been observed 
in practice?

So the original patch which added this to mod_timer_noact() was 
racy i think, and we cannot preserve this optimization outside 
of the timer list lock. (we could do it inside of it.)

	Ingo

------------------->
Subject: timers: add mod_timer_pending()
From: Ingo Molnar <mingo@elte.hu>
Date: Wed, 18 Feb 2009 12:23:29 +0100

Impact: new timer API

Based on an idea from Stephen Hemminger: introduce
 mod_timer_pending() which is a mod_timer() offspring
that is an invariant on already removed timers.

(regular mod_timer() re-activates non-pending timers.)

This is useful for the networking code in that it can
allow unserialized mod_timer_pending() timer-forwarding
calls, but a single del_timer*() will stop the timer
from being reactivated again.

Also while at it:

- optimize the regular mod_timer() path some more, the
  timer-stat and a debug check was needlessly duplicated
  in __mod_timer().

- make the exports come straight after the function, as
  most other exports in timer.c already did.

- eliminate __mod_timer() as an external API, change the
  users to mod_timer().

The regular mod_timer() code path is not impacted
significantly, due to inlining optimizations and due to
the simplifications - but performance testing would be nice
nevertheless.

Based-on-patch-from: Stephen Hemminger <shemminger@vyatta.com>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 arch/powerpc/platforms/cell/spufs/sched.c  |    2 
 drivers/infiniband/hw/ipath/ipath_driver.c |    6 -
 include/linux/timer.h                      |   22 -----
 kernel/relay.c                             |    2 
 kernel/timer.c                             |  110 +++++++++++++++++++----------
 5 files changed, 80 insertions(+), 62 deletions(-)

Index: linux/arch/powerpc/platforms/cell/spufs/sched.c
===================================================================
--- linux.orig/arch/powerpc/platforms/cell/spufs/sched.c
+++ linux/arch/powerpc/platforms/cell/spufs/sched.c
@@ -508,7 +508,7 @@ static void __spu_add_to_rq(struct spu_c
 		list_add_tail(&ctx->rq, &spu_prio->runq[ctx->prio]);
 		set_bit(ctx->prio, spu_prio->bitmap);
 		if (!spu_prio->nr_waiting++)
-			__mod_timer(&spusched_timer, jiffies + SPUSCHED_TICK);
+			mod_timer(&spusched_timer, jiffies + SPUSCHED_TICK);
 	}
 }
 
Index: linux/drivers/infiniband/hw/ipath/ipath_driver.c
===================================================================
--- linux.orig/drivers/infiniband/hw/ipath/ipath_driver.c
+++ linux/drivers/infiniband/hw/ipath/ipath_driver.c
@@ -2715,7 +2715,7 @@ static void ipath_hol_signal_up(struct i
  * to prevent HoL blocking, then start the HoL timer that
  * periodically continues, then stop procs, so they can detect
  * link down if they want, and do something about it.
- * Timer may already be running, so use __mod_timer, not add_timer.
+ * Timer may already be running, so use mod_timer, not add_timer.
  */
 void ipath_hol_down(struct ipath_devdata *dd)
 {
@@ -2724,7 +2724,7 @@ void ipath_hol_down(struct ipath_devdata
 	dd->ipath_hol_next = IPATH_HOL_DOWNCONT;
 	dd->ipath_hol_timer.expires = jiffies +
 		msecs_to_jiffies(ipath_hol_timeout_ms);
-	__mod_timer(&dd->ipath_hol_timer, dd->ipath_hol_timer.expires);
+	mod_timer(&dd->ipath_hol_timer, dd->ipath_hol_timer.expires);
 }
 
 /*
@@ -2763,7 +2763,7 @@ void ipath_hol_event(unsigned long opaqu
 	else {
 		dd->ipath_hol_timer.expires = jiffies +
 			msecs_to_jiffies(ipath_hol_timeout_ms);
-		__mod_timer(&dd->ipath_hol_timer,
+		mod_timer(&dd->ipath_hol_timer,
 			dd->ipath_hol_timer.expires);
 	}
 }
Index: linux/include/linux/timer.h
===================================================================
--- linux.orig/include/linux/timer.h
+++ linux/include/linux/timer.h
@@ -161,8 +161,8 @@ static inline int timer_pending(const st
 
 extern void add_timer_on(struct timer_list *timer, int cpu);
 extern int del_timer(struct timer_list * timer);
-extern int __mod_timer(struct timer_list *timer, unsigned long expires);
 extern int mod_timer(struct timer_list *timer, unsigned long expires);
+extern int mod_timer_pending(struct timer_list *timer, unsigned long expires);
 
 /*
  * The jiffies value which is added to now, when there is no timer
@@ -221,25 +221,7 @@ static inline void timer_stats_timer_cle
 }
 #endif
 
-/**
- * add_timer - start a timer
- * @timer: the timer to be added
- *
- * The kernel will do a ->function(->data) callback from the
- * timer interrupt at the ->expires point in the future. The
- * current time is 'jiffies'.
- *
- * The timer's ->expires, ->function (and if the handler uses it, ->data)
- * fields must be set prior calling this function.
- *
- * Timers with an ->expires field in the past will be executed in the next
- * timer tick.
- */
-static inline void add_timer(struct timer_list *timer)
-{
-	BUG_ON(timer_pending(timer));
-	__mod_timer(timer, timer->expires);
-}
+extern void add_timer(struct timer_list *timer);
 
 #ifdef CONFIG_SMP
   extern int try_to_del_timer_sync(struct timer_list *timer);
Index: linux/kernel/relay.c
===================================================================
--- linux.orig/kernel/relay.c
+++ linux/kernel/relay.c
@@ -748,7 +748,7 @@ size_t relay_switch_subbuf(struct rchan_
 			 * from the scheduler (trying to re-grab
 			 * rq->lock), so defer it.
 			 */
-			__mod_timer(&buf->timer, jiffies + 1);
+			mod_timer(&buf->timer, jiffies + 1);
 	}
 
 	old = buf->data;
Index: linux/kernel/timer.c
===================================================================
--- linux.orig/kernel/timer.c
+++ linux/kernel/timer.c
@@ -600,11 +600,14 @@ static struct tvec_base *lock_timer_base
 	}
 }
 
-int __mod_timer(struct timer_list *timer, unsigned long expires)
+static inline int
+__mod_timer(struct timer_list *timer, unsigned long expires, bool pending_only)
 {
 	struct tvec_base *base, *new_base;
 	unsigned long flags;
-	int ret = 0;
+	int ret;
+
+	ret = 0;
 
 	timer_stats_timer_set_start_info(timer);
 	BUG_ON(!timer->function);
@@ -614,6 +617,9 @@ int __mod_timer(struct timer_list *timer
 	if (timer_pending(timer)) {
 		detach_timer(timer, 0);
 		ret = 1;
+	} else {
+		if (pending_only)
+			goto out_unlock;
 	}
 
 	debug_timer_activate(timer);
@@ -640,42 +646,28 @@ int __mod_timer(struct timer_list *timer
 
 	timer->expires = expires;
 	internal_add_timer(base, timer);
+
+out_unlock:
 	spin_unlock_irqrestore(&base->lock, flags);
 
 	return ret;
 }
 
-EXPORT_SYMBOL(__mod_timer);
-
 /**
- * add_timer_on - start a timer on a particular CPU
- * @timer: the timer to be added
- * @cpu: the CPU to start it on
+ * mod_timer_pending - modify a pending timer's timeout
+ * @timer: the pending timer to be modified
+ * @expires: new timeout in jiffies
  *
- * This is not very scalable on SMP. Double adds are not possible.
+ * mod_timer_pending() is the same for pending timers as mod_timer(),
+ * but will not re-activate and modify already deleted timers.
+ *
+ * It is useful for unserialized use of timers.
  */
-void add_timer_on(struct timer_list *timer, int cpu)
+int mod_timer_pending(struct timer_list *timer, unsigned long expires)
 {
-	struct tvec_base *base = per_cpu(tvec_bases, cpu);
-	unsigned long flags;
-
-	timer_stats_timer_set_start_info(timer);
-	BUG_ON(timer_pending(timer) || !timer->function);
-	spin_lock_irqsave(&base->lock, flags);
-	timer_set_base(timer, base);
-	debug_timer_activate(timer);
-	internal_add_timer(base, timer);
-	/*
-	 * Check whether the other CPU is idle and needs to be
-	 * triggered to reevaluate the timer wheel when nohz is
-	 * active. We are protected against the other CPU fiddling
-	 * with the timer by holding the timer base lock. This also
-	 * makes sure that a CPU on the way to idle can not evaluate
-	 * the timer wheel.
-	 */
-	wake_up_idle_cpu(cpu);
-	spin_unlock_irqrestore(&base->lock, flags);
+	return __mod_timer(timer, expires, true);
 }
+EXPORT_SYMBOL(mod_timer_pending);
 
 /**
  * mod_timer - modify a timer's timeout
@@ -699,9 +691,6 @@ void add_timer_on(struct timer_list *tim
  */
 int mod_timer(struct timer_list *timer, unsigned long expires)
 {
-	BUG_ON(!timer->function);
-
-	timer_stats_timer_set_start_info(timer);
 	/*
 	 * This is a common optimization triggered by the
 	 * networking code - if the timer is re-modified
@@ -710,12 +699,62 @@ int mod_timer(struct timer_list *timer, 
 	if (timer->expires == expires && timer_pending(timer))
 		return 1;
 
-	return __mod_timer(timer, expires);
+	return __mod_timer(timer, expires, false);
 }
-
 EXPORT_SYMBOL(mod_timer);
 
 /**
+ * add_timer - start a timer
+ * @timer: the timer to be added
+ *
+ * The kernel will do a ->function(->data) callback from the
+ * timer interrupt at the ->expires point in the future. The
+ * current time is 'jiffies'.
+ *
+ * The timer's ->expires, ->function (and if the handler uses it, ->data)
+ * fields must be set prior calling this function.
+ *
+ * Timers with an ->expires field in the past will be executed in the next
+ * timer tick.
+ */
+void add_timer(struct timer_list *timer)
+{
+	BUG_ON(timer_pending(timer));
+	mod_timer(timer, timer->expires);
+}
+EXPORT_SYMBOL(add_timer);
+
+/**
+ * add_timer_on - start a timer on a particular CPU
+ * @timer: the timer to be added
+ * @cpu: the CPU to start it on
+ *
+ * This is not very scalable on SMP. Double adds are not possible.
+ */
+void add_timer_on(struct timer_list *timer, int cpu)
+{
+	struct tvec_base *base = per_cpu(tvec_bases, cpu);
+	unsigned long flags;
+
+	timer_stats_timer_set_start_info(timer);
+	BUG_ON(timer_pending(timer) || !timer->function);
+	spin_lock_irqsave(&base->lock, flags);
+	timer_set_base(timer, base);
+	debug_timer_activate(timer);
+	internal_add_timer(base, timer);
+	/*
+	 * Check whether the other CPU is idle and needs to be
+	 * triggered to reevaluate the timer wheel when nohz is
+	 * active. We are protected against the other CPU fiddling
+	 * with the timer by holding the timer base lock. This also
+	 * makes sure that a CPU on the way to idle can not evaluate
+	 * the timer wheel.
+	 */
+	wake_up_idle_cpu(cpu);
+	spin_unlock_irqrestore(&base->lock, flags);
+}
+
+/**
  * del_timer - deactive a timer.
  * @timer: the timer to be deactivated
  *
@@ -744,7 +783,6 @@ int del_timer(struct timer_list *timer)
 
 	return ret;
 }
-
 EXPORT_SYMBOL(del_timer);
 
 #ifdef CONFIG_SMP
@@ -778,7 +816,6 @@ out:
 
 	return ret;
 }
-
 EXPORT_SYMBOL(try_to_del_timer_sync);
 
 /**
@@ -816,7 +853,6 @@ int del_timer_sync(struct timer_list *ti
 		cpu_relax();
 	}
 }
-
 EXPORT_SYMBOL(del_timer_sync);
 #endif
 
@@ -1314,7 +1350,7 @@ signed long __sched schedule_timeout(sig
 	expire = timeout + jiffies;
 
 	setup_timer_on_stack(&timer, process_timeout, (unsigned long)current);
-	__mod_timer(&timer, expire);
+	__mod_timer(&timer, expire, false);
 	schedule();
 	del_singleshot_timer_sync(&timer);
 
