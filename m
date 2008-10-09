From: Evgeniy Polyakov <s0mbre@tservice.net.ru>
Subject: [tbench regression fixes]: digging out smelly deadmen.
Date: Fri, 10 Oct 2008 03:17:59 +0400
Message-ID: <20081009231759.GA8664@tservice.net.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="nFreZHaLTZJo0R7j"
Cc: linux-kernel@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.net.ru ([195.178.208.66]:60934 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750891AbYJIXj7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Oct 2008 19:39:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--nFreZHaLTZJo0R7j
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline


Hi.

It was reported recently that tbench has a long history of regressions,
starting at least from 2.6.23 kernel. I verified that in my test
environment tbench 'lost' more than 100 MB/s from 470 down to 355
between at least 2.6.24 and 2.6.27. 2.6.26-2.6.27 performance regression
in my machines is rougly corresponds to 375 down to 355 MB/s.

I spent several days in various tests and bisections (unfortunately
bisect can not always point to the 'right' commit), and found following
problems.

First, related to the network, as lots of people expected: TSO/GSO over
loopback with tbench workload eats about 5-10 MB/s, since TSO/GSO frame
creation overhead is not paid by the optimized super-frame processing
gains. Since it brings really impressive improvement in big-packet
workload, it was (likely) decided not to add a patch for this, but
instead one can disable TSO/GSO via ethtool. This patch was added in
2.6.27 window, so it has its part in its regression.

Second part in the 26-27 window regression (I remind, it is about 20
MB/s) is related to the scheduler changes, which was expected by another
group of people. I tracked it down to the
a7be37ac8e1565e00880531f4e2aff421a21c803 commit, which, if being
reverted, returns 2.6.27 tbench perfromance to the highest (for
2.6.26-2.6.27) 365 MB/s mark. I also tested tree, stopped at above
commit itself, i.e. not 2.6.27, and got 373 MB/s, so likely another
changes in that merge ate couple of megs. Attached patch against 2.6.27.

Curious reader can ask, where did we lost another 100 MB/s? This small
issue was not detected (or at least reported in netdev@ with provocative
enough subject), and it happend to live somehere in 2.6.24-2.6.25 changes.
I was so lucky to 'guess' (just after couple of hundreds of compilations),
that it corresponds to 8f4d37ec073c17e2d4aa8851df5837d798606d6f commit about
high-resolution timers, attached patch against 2.6.25 brings tbench
performance for the 2.6.25 kernel tree to 455 MB/s.

There are still somewhat missed 20 MB/s, but 2.6.24 has 475 MB/s, so
likely bug lives between 2.6.24 and above 8f4d37ec073 commit.

I can test your patches (the most interesting attached one does not
apply clearly to the current tree) for the 2.6.27 tree tomorrow
(it is more than 3 A.M. in Moscow).

P.S. I'm not currently subscribed to any of the mentioned lists (and write
from long-ago-unused email), so can not find appropriate subject and reply
into the thread.

-- 
	Evgeniy Polyakov

--nFreZHaLTZJo0R7j
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="return-10mb-2.6.27.diff"

diff --git a/kernel/sched.c b/kernel/sched.c
index 13dd2db..70eb173 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -1243,9 +1243,6 @@ static void resched_task(struct task_struct *p)
  */
 #define SRR(x, y) (((x) + (1UL << ((y) - 1))) >> (y))
 
-/*
- * delta *= weight / lw
- */
 static unsigned long
 calc_delta_mine(unsigned long delta_exec, unsigned long weight,
 		struct load_weight *lw)
@@ -1273,6 +1270,12 @@ calc_delta_mine(unsigned long delta_exec, unsigned long weight,
 	return (unsigned long)min(tmp, (u64)(unsigned long)LONG_MAX);
 }
 
+static inline unsigned long
+calc_delta_fair(unsigned long delta_exec, struct load_weight *lw)
+{
+	return calc_delta_mine(delta_exec, NICE_0_LOAD, lw);
+}
+
 static inline void update_load_add(struct load_weight *lw, unsigned long inc)
 {
 	lw->weight += inc;
diff --git a/kernel/sched_fair.c b/kernel/sched_fair.c
index fb8994c..3597a3c 100644
--- a/kernel/sched_fair.c
+++ b/kernel/sched_fair.c
@@ -334,34 +334,6 @@ int sched_nr_latency_handler(struct ctl_table *table, int write,
 #endif
 
 /*
- * delta *= w / rw
- */
-static inline unsigned long
-calc_delta_weight(unsigned long delta, struct sched_entity *se)
-{
-	for_each_sched_entity(se) {
-		delta = calc_delta_mine(delta,
-				se->load.weight, &cfs_rq_of(se)->load);
-	}
-
-	return delta;
-}
-
-/*
- * delta *= rw / w
- */
-static inline unsigned long
-calc_delta_fair(unsigned long delta, struct sched_entity *se)
-{
-	for_each_sched_entity(se) {
-		delta = calc_delta_mine(delta,
-				cfs_rq_of(se)->load.weight, &se->load);
-	}
-
-	return delta;
-}
-
-/*
  * The idea is to set a period in which each task runs once.
  *
  * When there are too many tasks (sysctl_sched_nr_latency) we have to stretch
@@ -390,80 +362,47 @@ static u64 __sched_period(unsigned long nr_running)
  */
 static u64 sched_slice(struct cfs_rq *cfs_rq, struct sched_entity *se)
 {
-	return calc_delta_weight(__sched_period(cfs_rq->nr_running), se);
+	u64 slice = __sched_period(cfs_rq->nr_running);
+
+	for_each_sched_entity(se) {
+		cfs_rq = cfs_rq_of(se);
+
+		slice *= se->load.weight;
+		do_div(slice, cfs_rq->load.weight);
+	}
+
+
+	return slice;
 }
 
 /*
  * We calculate the vruntime slice of a to be inserted task
  *
- * vs = s*rw/w = p
+ * vs = s/w = p/rw
  */
 static u64 sched_vslice_add(struct cfs_rq *cfs_rq, struct sched_entity *se)
 {
 	unsigned long nr_running = cfs_rq->nr_running;
+	unsigned long weight;
+	u64 vslice;
 
 	if (!se->on_rq)
 		nr_running++;
 
-	return __sched_period(nr_running);
-}
-
-/*
- * The goal of calc_delta_asym() is to be asymmetrically around NICE_0_LOAD, in
- * that it favours >=0 over <0.
- *
- *   -20         |
- *               |
- *     0 --------+-------
- *             .'
- *    19     .'
- *
- */
-static unsigned long
-calc_delta_asym(unsigned long delta, struct sched_entity *se)
-{
-	struct load_weight lw = {
-		.weight = NICE_0_LOAD,
-		.inv_weight = 1UL << (WMULT_SHIFT-NICE_0_SHIFT)
-	};
+	vslice = __sched_period(nr_running);
 
 	for_each_sched_entity(se) {
-		struct load_weight *se_lw = &se->load;
-		unsigned long rw = cfs_rq_of(se)->load.weight;
-
-#ifdef CONFIG_FAIR_SCHED_GROUP
-		struct cfs_rq *cfs_rq = se->my_q;
-		struct task_group *tg = NULL
-
-		if (cfs_rq)
-			tg = cfs_rq->tg;
-
-		if (tg && tg->shares < NICE_0_LOAD) {
-			/*
-			 * scale shares to what it would have been had
-			 * tg->weight been NICE_0_LOAD:
-			 *
-			 *   weight = 1024 * shares / tg->weight
-			 */
-			lw.weight *= se->load.weight;
-			lw.weight /= tg->shares;
-
-			lw.inv_weight = 0;
-
-			se_lw = &lw;
-			rw += lw.weight - se->load.weight;
-		} else
-#endif
+		cfs_rq = cfs_rq_of(se);
 
-		if (se->load.weight < NICE_0_LOAD) {
-			se_lw = &lw;
-			rw += NICE_0_LOAD - se->load.weight;
-		}
+		weight = cfs_rq->load.weight;
+		if (!se->on_rq)
+			weight += se->load.weight;
 
-		delta = calc_delta_mine(delta, rw, se_lw);
+		vslice *= NICE_0_LOAD;
+		do_div(vslice, weight);
 	}
 
-	return delta;
+	return vslice;
 }
 
 /*
@@ -480,7 +419,11 @@ __update_curr(struct cfs_rq *cfs_rq, struct sched_entity *curr,
 
 	curr->sum_exec_runtime += delta_exec;
 	schedstat_add(cfs_rq, exec_clock, delta_exec);
-	delta_exec_weighted = calc_delta_fair(delta_exec, curr);
+	delta_exec_weighted = delta_exec;
+	if (unlikely(curr->load.weight != NICE_0_LOAD)) {
+		delta_exec_weighted = calc_delta_fair(delta_exec_weighted,
+							&curr->load);
+	}
 	curr->vruntime += delta_exec_weighted;
 }
 
@@ -687,17 +630,8 @@ place_entity(struct cfs_rq *cfs_rq, struct sched_entity *se, int initial)
 
 	if (!initial) {
 		/* sleeps upto a single latency don't count. */
-		if (sched_feat(NEW_FAIR_SLEEPERS)) {
-			unsigned long thresh = sysctl_sched_latency;
-
-			/*
-			 * convert the sleeper threshold into virtual time
-			 */
-			if (sched_feat(NORMALIZED_SLEEPER))
-				thresh = calc_delta_fair(thresh, se);
-
-			vruntime -= thresh;
-		}
+		if (sched_feat(NEW_FAIR_SLEEPERS))
+			vruntime -= sysctl_sched_latency;
 
 		/* ensure we never gain time by being placed backwards. */
 		vruntime = max_vruntime(se->vruntime, vruntime);
@@ -1277,13 +1211,11 @@ static unsigned long wakeup_gran(struct sched_entity *se)
 	unsigned long gran = sysctl_sched_wakeup_granularity;
 
 	/*
-	 * More easily preempt - nice tasks, while not making it harder for
-	 * + nice tasks.
+	 * More easily preempt - nice tasks, while not making
+	 * it harder for + nice tasks.
 	 */
-	if (sched_feat(ASYM_GRAN))
-		gran = calc_delta_asym(sysctl_sched_wakeup_granularity, se);
-	else
-		gran = calc_delta_fair(sysctl_sched_wakeup_granularity, se);
+	if (unlikely(se->load.weight > NICE_0_LOAD))
+		gran = calc_delta_fair(gran, &se->load);
 
 	return gran;
 }
diff --git a/kernel/sched_features.h b/kernel/sched_features.h
index 9353ca7..34ef70f 100644
--- a/kernel/sched_features.h
+++ b/kernel/sched_features.h
@@ -1,5 +1,4 @@
 SCHED_FEAT(NEW_FAIR_SLEEPERS, 1)
-SCHED_FEAT(NORMALIZED_SLEEPER, 1)
 SCHED_FEAT(WAKEUP_PREEMPT, 1)
 SCHED_FEAT(START_DEBIT, 1)
 SCHED_FEAT(AFFINE_WAKEUPS, 1)

--nFreZHaLTZJo0R7j
Content-Type: text/x-diff; charset=us-ascii
Content-Disposition: attachment; filename="return-80mb-2.6.25.diff"

diff --git a/arch/x86/kernel/entry_64.S b/arch/x86/kernel/entry_64.S
index c20c9e7..e06ecab 100644
--- a/arch/x86/kernel/entry_64.S
+++ b/arch/x86/kernel/entry_64.S
@@ -295,8 +295,8 @@ sysret_careful:
 	/* Handle a signal */ 
 sysret_signal:
 	TRACE_IRQS_ON
-	ENABLE_INTERRUPTS(CLBR_NONE)
-	testl $_TIF_DO_NOTIFY_MASK,%edx
+	sti
+	testl $(_TIF_SIGPENDING|_TIF_SINGLESTEP|_TIF_MCE_NOTIFY),%edx
 	jz    1f
 
 	/* Really a signal */
@@ -390,7 +390,7 @@ int_very_careful:
 	jmp int_restore_rest
 	
 int_signal:
-	testl $_TIF_DO_NOTIFY_MASK,%edx
+	testl $(_TIF_SIGPENDING|_TIF_SINGLESTEP|_TIF_MCE_NOTIFY),%edx
 	jz 1f
 	movq %rsp,%rdi		# &ptregs -> arg1
 	xorl %esi,%esi		# oldset -> arg2
@@ -637,7 +637,7 @@ retint_careful:
 	jmp retint_check
 	
 retint_signal:
-	testl $_TIF_DO_NOTIFY_MASK,%edx
+	testl $(_TIF_SIGPENDING|_TIF_SINGLESTEP|_TIF_MCE_NOTIFY),%edx
 	jz    retint_swapgs
 	TRACE_IRQS_ON
 	ENABLE_INTERRUPTS(CLBR_NONE)
diff --git a/arch/x86/kernel/signal_32.c b/arch/x86/kernel/signal_32.c
index 0157a6f..1b085d2 100644
--- a/arch/x86/kernel/signal_32.c
+++ b/arch/x86/kernel/signal_32.c
@@ -667,9 +667,6 @@ void do_notify_resume(struct pt_regs *regs, void *_unused,
 	/* deal with pending signal delivery */
 	if (thread_info_flags & (_TIF_SIGPENDING | _TIF_RESTORE_SIGMASK))
 		do_signal(regs);
-
-	if (thread_info_flags & _TIF_HRTICK_RESCHED)
-		hrtick_resched();
 	
 	clear_thread_flag(TIF_IRET);
 }
diff --git a/arch/x86/kernel/signal_64.c b/arch/x86/kernel/signal_64.c
index 1c83e51..9691bb8 100644
--- a/arch/x86/kernel/signal_64.c
+++ b/arch/x86/kernel/signal_64.c
@@ -504,9 +504,6 @@ do_notify_resume(struct pt_regs *regs, void *unused, __u32 thread_info_flags)
 	/* deal with pending signal delivery */
 	if (thread_info_flags & (_TIF_SIGPENDING|_TIF_RESTORE_SIGMASK))
 		do_signal(regs);
-
-	if (thread_info_flags & _TIF_HRTICK_RESCHED)
-		hrtick_resched();
 }
 
 void signal_fault(struct pt_regs *regs, void __user *frame, char *where)
diff --git a/include/asm-x86/thread_info_32.h b/include/asm-x86/thread_info_32.h
index 5bd5082..0514e3b 100644
--- a/include/asm-x86/thread_info_32.h
+++ b/include/asm-x86/thread_info_32.h
@@ -132,7 +132,6 @@ static inline struct thread_info *current_thread_info(void)
 #define TIF_SYSCALL_AUDIT	6	/* syscall auditing active */
 #define TIF_SECCOMP		7	/* secure computing */
 #define TIF_RESTORE_SIGMASK	8	/* restore signal mask in do_signal() */
-#define TIF_HRTICK_RESCHED	9	/* reprogram hrtick timer */
 #define TIF_MEMDIE		16
 #define TIF_DEBUG		17	/* uses debug registers */
 #define TIF_IO_BITMAP		18	/* uses I/O bitmap */
@@ -152,7 +151,6 @@ static inline struct thread_info *current_thread_info(void)
 #define _TIF_SYSCALL_AUDIT	(1<<TIF_SYSCALL_AUDIT)
 #define _TIF_SECCOMP		(1<<TIF_SECCOMP)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
-#define _TIF_HRTICK_RESCHED	(1<<TIF_HRTICK_RESCHED)
 #define _TIF_DEBUG		(1<<TIF_DEBUG)
 #define _TIF_IO_BITMAP		(1<<TIF_IO_BITMAP)
 #define _TIF_FREEZE		(1<<TIF_FREEZE)
diff --git a/include/asm-x86/thread_info_64.h b/include/asm-x86/thread_info_64.h
index 6c9b214..35ec680 100644
--- a/include/asm-x86/thread_info_64.h
+++ b/include/asm-x86/thread_info_64.h
@@ -112,7 +112,6 @@ static inline struct thread_info *stack_thread_info(void)
 #define TIF_SECCOMP		8	/* secure computing */
 #define TIF_RESTORE_SIGMASK	9	/* restore signal mask in do_signal */
 #define TIF_MCE_NOTIFY		10	/* notify userspace of an MCE */
-#define TIF_HRTICK_RESCHED	11	/* reprogram hrtick timer */
 /* 16 free */
 #define TIF_IA32		17	/* 32bit process */ 
 #define TIF_FORK		18	/* ret_from_fork */
@@ -135,7 +134,6 @@ static inline struct thread_info *stack_thread_info(void)
 #define _TIF_SECCOMP		(1<<TIF_SECCOMP)
 #define _TIF_RESTORE_SIGMASK	(1<<TIF_RESTORE_SIGMASK)
 #define _TIF_MCE_NOTIFY		(1<<TIF_MCE_NOTIFY)
-#define _TIF_HRTICK_RESCHED	(1<<TIF_HRTICK_RESCHED)
 #define _TIF_IA32		(1<<TIF_IA32)
 #define _TIF_FORK		(1<<TIF_FORK)
 #define _TIF_ABI_PENDING	(1<<TIF_ABI_PENDING)
@@ -153,9 +151,6 @@ static inline struct thread_info *stack_thread_info(void)
 /* work to do on any return to user space */
 #define _TIF_ALLWORK_MASK (0x0000FFFF & ~_TIF_SECCOMP)
 
-#define _TIF_DO_NOTIFY_MASK \
-	(_TIF_SIGPENDING|_TIF_SINGLESTEP|_TIF_MCE_NOTIFY|_TIF_HRTICK_RESCHED)
-
 /* flags to check in __switch_to() */
 #define _TIF_WORK_CTXSW \
     (_TIF_IO_BITMAP|_TIF_DEBUGCTLMSR|_TIF_DS_AREA_MSR|_TIF_BTS_TRACE_TS)
diff --git a/include/linux/hrtimer.h b/include/linux/hrtimer.h
index 1ad56a7..386600e 100644
--- a/include/linux/hrtimer.h
+++ b/include/linux/hrtimer.h
@@ -214,11 +214,6 @@ static inline ktime_t hrtimer_cb_get_time(struct hrtimer *timer)
 	return timer->base->get_time();
 }
 
-static inline int hrtimer_is_hres_active(struct hrtimer *timer)
-{
-	return timer->base->cpu_base->hres_active;
-}
-
 /*
  * The resolution of the clocks. The resolution value is returned in
  * the clock_getres() system call to give application programmers an
@@ -253,10 +248,6 @@ static inline ktime_t hrtimer_cb_get_time(struct hrtimer *timer)
 	return timer->base->softirq_time;
 }
 
-static inline int hrtimer_is_hres_active(struct hrtimer *timer)
-{
-	return 0;
-}
 #endif
 
 extern ktime_t ktime_get(void);
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6a1e7af..7b7905d 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -285,7 +285,6 @@ extern void trap_init(void);
 extern void account_process_tick(struct task_struct *task, int user);
 extern void update_process_times(int user);
 extern void scheduler_tick(void);
-extern void hrtick_resched(void);
 
 extern void sched_show_task(struct task_struct *p);
 
@@ -887,7 +886,7 @@ struct sched_class {
 #endif
 
 	void (*set_curr_task) (struct rq *rq);
-	void (*task_tick) (struct rq *rq, struct task_struct *p, int queued);
+	void (*task_tick) (struct rq *rq, struct task_struct *p);
 	void (*task_new) (struct rq *rq, struct task_struct *p);
 	void (*set_cpus_allowed)(struct task_struct *p, cpumask_t *newmask);
 
diff --git a/kernel/Kconfig.hz b/kernel/Kconfig.hz
index 526128a..4af1580 100644
--- a/kernel/Kconfig.hz
+++ b/kernel/Kconfig.hz
@@ -54,5 +54,3 @@ config HZ
 	default 300 if HZ_300
 	default 1000 if HZ_1000
 
-config SCHED_HRTICK
-	def_bool HIGH_RES_TIMERS && X86
diff --git a/kernel/sched.c b/kernel/sched.c
index 8dcdec6..c481937 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -65,7 +65,6 @@
 #include <linux/reciprocal_div.h>
 #include <linux/unistd.h>
 #include <linux/pagemap.h>
-#include <linux/hrtimer.h>
 
 #include <asm/tlb.h>
 #include <asm/irq_regs.h>
@@ -452,12 +451,6 @@ struct rq {
 	struct list_head migration_queue;
 #endif
 
-#ifdef CONFIG_SCHED_HRTICK
-	unsigned long hrtick_flags;
-	ktime_t hrtick_expire;
-	struct hrtimer hrtick_timer;
-#endif
-
 #ifdef CONFIG_SCHEDSTATS
 	/* latency stats */
 	struct sched_info rq_sched_info;
@@ -594,16 +587,16 @@ enum {
 	SCHED_FEAT_NEW_FAIR_SLEEPERS	= 1,
 	SCHED_FEAT_WAKEUP_PREEMPT	= 2,
 	SCHED_FEAT_START_DEBIT		= 4,
-	SCHED_FEAT_HRTICK		= 8,
-	SCHED_FEAT_DOUBLE_TICK		= 16,
+	SCHED_FEAT_TREE_AVG		= 8,
+	SCHED_FEAT_APPROX_AVG		= 16,
 };
 
 const_debug unsigned int sysctl_sched_features =
 		SCHED_FEAT_NEW_FAIR_SLEEPERS	* 1 |
 		SCHED_FEAT_WAKEUP_PREEMPT	* 1 |
 		SCHED_FEAT_START_DEBIT		* 1 |
-		SCHED_FEAT_HRTICK		* 1 |
-		SCHED_FEAT_DOUBLE_TICK		* 0;
+		SCHED_FEAT_TREE_AVG		* 0 |
+		SCHED_FEAT_APPROX_AVG		* 0;
 
 #define sched_feat(x) (sysctl_sched_features & SCHED_FEAT_##x)
 
@@ -841,173 +834,6 @@ void sched_clock_idle_wakeup_event(u64 delta_ns)
 }
 EXPORT_SYMBOL_GPL(sched_clock_idle_wakeup_event);
 
-static void __resched_task(struct task_struct *p, int tif_bit);
-
-static inline void resched_task(struct task_struct *p)
-{
-	__resched_task(p, TIF_NEED_RESCHED);
-}
-
-#ifdef CONFIG_SCHED_HRTICK
-/*
- * Use HR-timers to deliver accurate preemption points.
- *
- * Its all a bit involved since we cannot program an hrt while holding the
- * rq->lock. So what we do is store a state in in rq->hrtick_* and ask for a
- * reschedule event.
- *
- * When we get rescheduled we reprogram the hrtick_timer outside of the
- * rq->lock.
- */
-static inline void resched_hrt(struct task_struct *p)
-{
-	__resched_task(p, TIF_HRTICK_RESCHED);
-}
-
-static inline void resched_rq(struct rq *rq)
-{
-	unsigned long flags;
-
-	spin_lock_irqsave(&rq->lock, flags);
-	resched_task(rq->curr);
-	spin_unlock_irqrestore(&rq->lock, flags);
-}
-
-enum {
-	HRTICK_SET,		/* re-programm hrtick_timer */
-	HRTICK_RESET,		/* not a new slice */
-};
-
-/*
- * Use hrtick when:
- *  - enabled by features
- *  - hrtimer is actually high res
- */
-static inline int hrtick_enabled(struct rq *rq)
-{
-	if (!sched_feat(HRTICK))
-		return 0;
-	return hrtimer_is_hres_active(&rq->hrtick_timer);
-}
-
-/*
- * Called to set the hrtick timer state.
- *
- * called with rq->lock held and irqs disabled
- */
-static void hrtick_start(struct rq *rq, u64 delay, int reset)
-{
-	assert_spin_locked(&rq->lock);
-
-	/*
-	 * preempt at: now + delay
-	 */
-	rq->hrtick_expire =
-		ktime_add_ns(rq->hrtick_timer.base->get_time(), delay);
-	/*
-	 * indicate we need to program the timer
-	 */
-	__set_bit(HRTICK_SET, &rq->hrtick_flags);
-	if (reset)
-		__set_bit(HRTICK_RESET, &rq->hrtick_flags);
-
-	/*
-	 * New slices are called from the schedule path and don't need a
-	 * forced reschedule.
-	 */
-	if (reset)
-		resched_hrt(rq->curr);
-}
-
-static void hrtick_clear(struct rq *rq)
-{
-	if (hrtimer_active(&rq->hrtick_timer))
-		hrtimer_cancel(&rq->hrtick_timer);
-}
-
-/*
- * Update the timer from the possible pending state.
- */
-static void hrtick_set(struct rq *rq)
-{
-	ktime_t time;
-	int set, reset;
-	unsigned long flags;
-
-	WARN_ON_ONCE(cpu_of(rq) != smp_processor_id());
-
-	spin_lock_irqsave(&rq->lock, flags);
-	set = __test_and_clear_bit(HRTICK_SET, &rq->hrtick_flags);
-	reset = __test_and_clear_bit(HRTICK_RESET, &rq->hrtick_flags);
-	time = rq->hrtick_expire;
-	clear_thread_flag(TIF_HRTICK_RESCHED);
-	spin_unlock_irqrestore(&rq->lock, flags);
-
-	if (set) {
-		hrtimer_start(&rq->hrtick_timer, time, HRTIMER_MODE_ABS);
-		if (reset && !hrtimer_active(&rq->hrtick_timer))
-			resched_rq(rq);
-	} else
-		hrtick_clear(rq);
-}
-
-/*
- * High-resolution timer tick.
- * Runs from hardirq context with interrupts disabled.
- */
-static enum hrtimer_restart hrtick(struct hrtimer *timer)
-{
-	struct rq *rq = container_of(timer, struct rq, hrtick_timer);
-
-	WARN_ON_ONCE(cpu_of(rq) != smp_processor_id());
-
-	spin_lock(&rq->lock);
-	__update_rq_clock(rq);
-	rq->curr->sched_class->task_tick(rq, rq->curr, 1);
-	spin_unlock(&rq->lock);
-
-	return HRTIMER_NORESTART;
-}
-
-static inline void init_rq_hrtick(struct rq *rq)
-{
-	rq->hrtick_flags = 0;
-	hrtimer_init(&rq->hrtick_timer, CLOCK_MONOTONIC, HRTIMER_MODE_REL);
-	rq->hrtick_timer.function = hrtick;
-	rq->hrtick_timer.cb_mode = HRTIMER_CB_IRQSAFE_NO_SOFTIRQ;
-}
-
-void hrtick_resched(void)
-{
-	struct rq *rq;
-	unsigned long flags;
-
-	if (!test_thread_flag(TIF_HRTICK_RESCHED))
-		return;
-
-	local_irq_save(flags);
-	rq = cpu_rq(smp_processor_id());
-	hrtick_set(rq);
-	local_irq_restore(flags);
-}
-#else
-static inline void hrtick_clear(struct rq *rq)
-{
-}
-
-static inline void hrtick_set(struct rq *rq)
-{
-}
-
-static inline void init_rq_hrtick(struct rq *rq)
-{
-}
-
-void hrtick_resched(void)
-{
-}
-#endif
-
 /*
  * resched_task - mark a task 'to be rescheduled now'.
  *
@@ -1021,16 +847,16 @@ void hrtick_resched(void)
 #define tsk_is_polling(t) test_tsk_thread_flag(t, TIF_POLLING_NRFLAG)
 #endif
 
-static void __resched_task(struct task_struct *p, int tif_bit)
+static void resched_task(struct task_struct *p)
 {
 	int cpu;
 
 	assert_spin_locked(&task_rq(p)->lock);
 
-	if (unlikely(test_tsk_thread_flag(p, tif_bit)))
+	if (unlikely(test_tsk_thread_flag(p, TIF_NEED_RESCHED)))
 		return;
 
-	set_tsk_thread_flag(p, tif_bit);
+	set_tsk_thread_flag(p, TIF_NEED_RESCHED);
 
 	cpu = task_cpu(p);
 	if (cpu == smp_processor_id())
@@ -1096,10 +922,10 @@ void wake_up_idle_cpu(int cpu)
 #endif
 
 #else
-static void __resched_task(struct task_struct *p, int tif_bit)
+static inline void resched_task(struct task_struct *p)
 {
 	assert_spin_locked(&task_rq(p)->lock);
-	set_tsk_thread_flag(p, tif_bit);
+	set_tsk_need_resched(p);
 }
 #endif
 
@@ -3766,8 +3592,8 @@ void scheduler_tick(void)
 	}
 	rq->tick_timestamp = rq->clock;
 	update_cpu_load(rq);
-	curr->sched_class->task_tick(rq, curr, 0);
-	update_sched_rt_period(rq);
+	if (curr != rq->idle) /* FIXME: needed? */
+		curr->sched_class->task_tick(rq, curr);
 	spin_unlock(&rq->lock);
 
 #ifdef CONFIG_SMP
@@ -3913,8 +3739,6 @@ need_resched_nonpreemptible:
 
 	schedule_debug(prev);
 
-	hrtick_clear(rq);
-
 	/*
 	 * Do the rq-clock update outside the rq lock:
 	 */
@@ -3952,20 +3776,14 @@ need_resched_nonpreemptible:
 		++*switch_count;
 
 		context_switch(rq, prev, next); /* unlocks the rq */
-		/*
-		 * the context switch might have flipped the stack from under
-		 * us, hence refresh the local variables.
-		 */
-		cpu = smp_processor_id();
-		rq = cpu_rq(cpu);
 	} else
 		spin_unlock_irq(&rq->lock);
 
-	hrtick_set(rq);
-
-	if (unlikely(reacquire_kernel_lock(current) < 0))
+	if (unlikely(reacquire_kernel_lock(current) < 0)) {
+		cpu = smp_processor_id();
+		rq = cpu_rq(cpu);
 		goto need_resched_nonpreemptible;
-
+	}
 	preempt_enable_no_resched();
 	if (unlikely(test_thread_flag(TIF_NEED_RESCHED)))
 		goto need_resched;
@@ -7248,7 +7066,6 @@ void __init sched_init(void)
 		INIT_LIST_HEAD(&rq->migration_queue);
 		rq_attach_root(rq, &def_root_domain);
 #endif
-		init_rq_hrtick(rq);
 		atomic_set(&rq->nr_iowait, 0);
 		highest_cpu = i;
 	}
diff --git a/kernel/sched_fair.c b/kernel/sched_fair.c
index 0080968..14a5af5 100644
--- a/kernel/sched_fair.c
+++ b/kernel/sched_fair.c
@@ -677,29 +677,13 @@ static void put_prev_entity(struct cfs_rq *cfs_rq, struct sched_entity *prev)
 	cfs_rq->curr = NULL;
 }
 
-static void
-entity_tick(struct cfs_rq *cfs_rq, struct sched_entity *curr, int queued)
+static void entity_tick(struct cfs_rq *cfs_rq, struct sched_entity *curr)
 {
 	/*
 	 * Update run-time statistics of the 'current'.
 	 */
 	update_curr(cfs_rq);
 
-#ifdef CONFIG_SCHED_HRTICK
-	/*
-	 * queued ticks are scheduled to match the slice, so don't bother
-	 * validating it and just reschedule.
-	 */
-	if (queued)
-		return resched_task(rq_of(cfs_rq)->curr);
-	/*
-	 * don't let the period tick interfere with the hrtick preemption
-	 */
-	if (!sched_feat(DOUBLE_TICK) &&
-			hrtimer_active(&rq_of(cfs_rq)->hrtick_timer))
-		return;
-#endif
-
 	if (cfs_rq->nr_running > 1 || !sched_feat(WAKEUP_PREEMPT))
 		check_preempt_tick(cfs_rq, curr);
 }
@@ -803,43 +787,6 @@ static inline struct sched_entity *parent_entity(struct sched_entity *se)
 
 #endif	/* CONFIG_FAIR_GROUP_SCHED */
 
-#ifdef CONFIG_SCHED_HRTICK
-static void hrtick_start_fair(struct rq *rq, struct task_struct *p)
-{
-	int requeue = rq->curr == p;
-	struct sched_entity *se = &p->se;
-	struct cfs_rq *cfs_rq = cfs_rq_of(se);
-
-	WARN_ON(task_rq(p) != rq);
-
-	if (hrtick_enabled(rq) && cfs_rq->nr_running > 1) {
-		u64 slice = sched_slice(cfs_rq, se);
-		u64 ran = se->sum_exec_runtime - se->prev_sum_exec_runtime;
-		s64 delta = slice - ran;
-
-		if (delta < 0) {
-			if (rq->curr == p)
-				resched_task(p);
-			return;
-		}
-
-		/*
-		 * Don't schedule slices shorter than 10000ns, that just
-		 * doesn't make sense. Rely on vruntime for fairness.
-		 */
-		if (!requeue)
-			delta = max(10000LL, delta);
-
-		hrtick_start(rq, delta, requeue);
-	}
-}
-#else
-static inline void
-hrtick_start_fair(struct rq *rq, struct task_struct *p)
-{
-}
-#endif
-
 /*
  * The enqueue_task method is called before nr_running is
  * increased. Here we update the fair scheduling stats and
@@ -857,8 +804,6 @@ static void enqueue_task_fair(struct rq *rq, struct task_struct *p, int wakeup)
 		enqueue_entity(cfs_rq, se, wakeup);
 		wakeup = 1;
 	}
-
-	hrtick_start_fair(rq, rq->curr);
 }
 
 /*
@@ -879,8 +824,6 @@ static void dequeue_task_fair(struct rq *rq, struct task_struct *p, int sleep)
 			break;
 		sleep = 1;
 	}
-
-	hrtick_start_fair(rq, rq->curr);
 }
 
 /*
@@ -1152,7 +1095,6 @@ static void check_preempt_wakeup(struct rq *rq, struct task_struct *p)
 
 static struct task_struct *pick_next_task_fair(struct rq *rq)
 {
-	struct task_struct *p;
 	struct cfs_rq *cfs_rq = &rq->cfs;
 	struct sched_entity *se;
 
@@ -1164,10 +1106,7 @@ static struct task_struct *pick_next_task_fair(struct rq *rq)
 		cfs_rq = group_cfs_rq(se);
 	} while (cfs_rq);
 
-	p = task_of(se);
-	hrtick_start_fair(rq, p);
-
-	return p;
+	return task_of(se);
 }
 
 /*
@@ -1322,14 +1261,14 @@ move_one_task_fair(struct rq *this_rq, int this_cpu, struct rq *busiest,
 /*
  * scheduler tick hitting a task of our scheduling class:
  */
-static void task_tick_fair(struct rq *rq, struct task_struct *curr, int queued)
+static void task_tick_fair(struct rq *rq, struct task_struct *curr)
 {
 	struct cfs_rq *cfs_rq;
 	struct sched_entity *se = &curr->se;
 
 	for_each_sched_entity(se) {
 		cfs_rq = cfs_rq_of(se);
-		entity_tick(cfs_rq, se, queued);
+		entity_tick(cfs_rq, se);
 	}
 }
 
diff --git a/kernel/sched_idletask.c b/kernel/sched_idletask.c
index 2bcafa3..ef7a266 100644
--- a/kernel/sched_idletask.c
+++ b/kernel/sched_idletask.c
@@ -61,7 +61,7 @@ move_one_task_idle(struct rq *this_rq, int this_cpu, struct rq *busiest,
 }
 #endif
 
-static void task_tick_idle(struct rq *rq, struct task_struct *curr, int queued)
+static void task_tick_idle(struct rq *rq, struct task_struct *curr)
 {
 }
 
diff --git a/kernel/sched_rt.c b/kernel/sched_rt.c
index 0a6d2e5..7f67b1a 100644
--- a/kernel/sched_rt.c
+++ b/kernel/sched_rt.c
@@ -1149,7 +1149,7 @@ static void watchdog(struct rq *rq, struct task_struct *p)
 	}
 }
 
-static void task_tick_rt(struct rq *rq, struct task_struct *p, int queued)
+static void task_tick_rt(struct rq *rq, struct task_struct *p)
 {
 	update_curr_rt(rq);
 

--nFreZHaLTZJo0R7j--
