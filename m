From: Mike Galbraith <efault@gmx.de>
Subject: [rfc/rft][patch] should use scheduler sync hint in tcp_prequeue()?
Date: Tue, 02 Mar 2010 10:41:41 +0100
Message-ID: <1267522901.25906.101.camel@marge.simson.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Greetings network land.

The reason for this query is that wake_affine() fails if there is one
and only one task on a runqueue to encourage tasks spreading out, which
increases cpu utilization.  However, for tasks which are communicating
at high frequency, the cost of the resulting cache misses, should
partners land in non-shared caches, is horrible to behold.  My Q6600 has
shared caches, which may or may not be hit IFF something perturbs the
system, and bounces partner to the right core.  That won't happen on a
box with no shared caches of course, and even with shared caches
available, the pain is highly visible in the TCP numbers below. 

The sync hint tells wake_affine() that the waker is likely going to
sleep soonish, so it subtracts the waker from the load imbalance
calculation, allowing the partner task to be awakened affine.  In the
shared cache available case, that is also an enabler that the task be
placed in an idle shared cache, which can increase throughput quite a
bit (see .31 vs .33 AF UNIX), or may cost a bit if there is little to no
execution overlap (see pipe).

Now, I _could_ change wake_affine() to globally succeed in the one task
case, but am loath to do so because that very well may upset delicate
load balancing apple cart.  I think it's much safer to target the spot
that I know hurts like hell.  Thoughts?

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 34f5cc2..ba3fc64 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -939,7 +939,7 @@ static inline int tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 
 		tp->ucopy.memory = 0;
 	} else if (skb_queue_len(&tp->ucopy.prequeue) == 1) {
-		wake_up_interruptible_poll(sk->sk_sleep,
+		wake_up_interruptible_sync_poll(sk->sk_sleep,
 					   POLLIN | POLLRDNORM | POLLRDBAND);
 		if (!inet_csk_ack_scheduled(sk))
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,

That was the RFC bit, now moving along to the RFT.  Busy folks can fast
forward to relevant numbers, or just poke 'D' :)

Below the lmbench numbers is a diff from my experimental fast-path cycle
recovery tree against .33.  That's me hoping that some folks with some
time on their hands to test the high speed low drag things that network
folks do, and who wouldn't mind seeing such things go a bit faster, will
become curious and give it a go.

Should anyone do any testing, I'd be particularly interested in seeing
_negative_ results, and a way to reproduce them if it can be done on
localhost + generic Q6600 box.  No high speed low drag hardware here
unfortunately.  Any results highly welcome, food for thought comes in
many flavors.

(offline preferred... may be considered spam)

Oh, almost forgot.  Second set of three runs for 33-smpx is with
SD_SHARE_PKG_RESOURCES disabled on MC domain to disallow use of shared
cache and compare cost/benefit.  TCP numbers is what's relevant to
$subject.

*Local* Communication latencies in microseconds - smaller is better
---------------------------------------------------------------------
Host                 OS 2p/0K  Pipe AF     UDP  RPC/   TCP  RPC/ TCP
                        ctxsw       UNIX         UDP         TCP conn
--------- ------------- ----- ----- ---- ----- ----- ----- ----- ----
marge     2.6.31.12-smp 0.730 2.845 4.85 6.463  11.3  26.2  14.9  31.
marge     2.6.31.12-smp 0.750 2.864 4.78 6.460  11.2  22.9  14.6  31.
marge     2.6.31.12-smp 0.710 2.835 4.81 6.478  11.5  11.0  14.5  30.
marge        2.6.33-smp 1.320 4.552 5.02 9.169  12.5  26.5  15.4  18.
marge        2.6.33-smp 1.450 4.621 5.45 9.286  12.5  11.4  15.4  18.
marge        2.6.33-smp 1.450 4.589 5.53 9.168  12.6  27.5  15.4  18.
marge       2.6.33-smpx 1.160 3.565 5.97 7.513  11.3 9.776  13.9  18.
marge       2.6.33-smpx 1.140 3.569 6.02 7.479  11.2 9.849  14.0  18.
marge       2.6.33-smpx 1.090 3.563 6.39 7.450  11.2 9.785  14.0  18.
marge       2.6.33-smpx 0.730 2.665 4.85 6.565  11.9  10.3  15.2  31.
marge       2.6.33-smpx 0.740 2.701 4.03 6.573  11.7  10.3  15.4  31.
marge       2.6.33-smpx 0.710 2.753 4.86 6.533  11.7  10.3  15.3  31.

File & VM system latencies in microseconds - smaller is better
-------------------------------------------------------------------------------
Host                 OS   0K File      10K File     Mmap    Prot   Page   100fd
                        Create Delete Create Delete Latency Fault  Fault  selct
--------- ------------- ------ ------ ------ ------ ------- ----- ------- -----
marge     2.6.31.12-smp                               798.0 0.503 0.96940 1.434
marge     2.6.31.12-smp                               795.0 0.523 0.96630 1.435
marge     2.6.31.12-smp                               791.0 0.536 0.97410 1.438
marge        2.6.33-smp                               841.0 0.603 1.00320 1.492
marge        2.6.33-smp                               818.0 0.582 0.99960 1.496
marge        2.6.33-smp                               814.0 0.578 1.00750 1.492
marge       2.6.33-smpx                               782.0 0.486 0.97290 1.489
marge       2.6.33-smpx                               787.0 0.491 0.97950 1.498
marge       2.6.33-smpx                               801.0 0.469 0.97690 1.492
marge       2.6.33-smpx                               783.0 0.496 0.97200 1.497
marge       2.6.33-smpx                               809.0 0.505 0.98070 1.504
marge       2.6.33-smpx                               796.0 0.501 0.98820 1.502

*Local* Communication bandwidths in MB/s - bigger is better
-----------------------------------------------------------------------------
Host                OS  Pipe AF    TCP  File   Mmap  Bcopy  Bcopy  Mem   Mem
                             UNIX      reread reread (libc) (hand) read write
--------- ------------- ---- ---- ---- ------ ------ ------ ------ ---- -----
marge     2.6.31.12-smp 2821 2971 762. 2829.2 4799.0 1243.0 1230.3 4469 1682.
marge     2.6.31.12-smp 2824 2931 760. 2833.3 4736.5 1239.5 1235.8 4462 1678.
marge     2.6.31.12-smp 2796 2936 1139 2843.3 4815.7 1242.8 1234.6 4471 1685.
marge        2.6.33-smp 2670 5151 739. 2816.6 4768.5 1243.7 1237.2 4389 1684.
marge        2.6.33-smp 2627 5126 1135 2806.9 4783.1 1245.1 1236.1 4413 1684.
marge        2.6.33-smp 2582 5037 1137 2799.6 4755.4 1242.0 1239.1 4471 1683.
marge       2.6.33-smpx 2848 5184 2972 2820.5 4804.8 1242.6 1236.9 4315 1686.
marge       2.6.33-smpx 2804 5183 2934 2822.8 4759.3 1245.0 1234.7 4462 1688.
marge       2.6.33-smpx 2729 5177 2920 2837.6 4820.0 1246.9 1238.5 4467 1684.
marge       2.6.33-smpx 2843 2896 1928 2786.5 4751.2 1242.2 1238.6 4493 1682.
marge       2.6.33-smpx 2869 2886 1936 2841.4 4748.9 1244.3 1237.7 4456 1683.
marge       2.6.33-smpx 2845 2895 1947 2836.0 4813.6 1242.7 1236.3 4473 1674.

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 78efe7c..ebbfcba 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -278,6 +278,10 @@ static inline int select_nohz_load_balancer(int cpu)
 }
 #endif
 
+#ifdef CONFIG_NO_HZ
+extern int nohz_ratelimit(int cpu);
+#endif
+
 /*
  * Only dump TASK_* tasks. (0 for all tasks)
  */
@@ -1160,14 +1164,8 @@ struct sched_entity {
 	u64			vruntime;
 	u64			prev_sum_exec_runtime;
 
-	u64			last_wakeup;
-	u64			avg_overlap;
-
 	u64			nr_migrations;
 
-	u64			start_runtime;
-	u64			avg_wakeup;
-
 #ifdef CONFIG_SCHEDSTATS
 	u64			wait_start;
 	u64			wait_max;
diff --git a/include/net/tcp.h b/include/net/tcp.h
index 34f5cc2..ba3fc64 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -939,7 +939,7 @@ static inline int tcp_prequeue(struct sock *sk, struct sk_buff *skb)
 
 		tp->ucopy.memory = 0;
 	} else if (skb_queue_len(&tp->ucopy.prequeue) == 1) {
-		wake_up_interruptible_poll(sk->sk_sleep,
+		wake_up_interruptible_sync_poll(sk->sk_sleep,
 					   POLLIN | POLLRDNORM | POLLRDBAND);
 		if (!inet_csk_ack_scheduled(sk))
 			inet_csk_reset_xmit_timer(sk, ICSK_TIME_DACK,
diff --git a/kernel/sched.c b/kernel/sched.c
index 3a8fb30..5fac30a 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -535,8 +535,11 @@ struct rq {
 	#define CPU_LOAD_IDX_MAX 5
 	unsigned long cpu_load[CPU_LOAD_IDX_MAX];
 #ifdef CONFIG_NO_HZ
+	u64 nohz_stamp;
 	unsigned char in_nohz_recently;
 #endif
+	unsigned int skip_clock_update;
+
 	/* capture load from *all* tasks on this cpu: */
 	struct load_weight load;
 	unsigned long nr_load_updates;
@@ -634,6 +637,13 @@ static inline
 void check_preempt_curr(struct rq *rq, struct task_struct *p, int flags)
 {
 	rq->curr->sched_class->check_preempt_curr(rq, p, flags);
+
+	/*
+	 * A queue event has occurred, and we're going to schedule.  In
+	 * this case, we can save a useless back to back clock update.
+	 */
+	if (test_tsk_need_resched(p))
+		rq->skip_clock_update = 1;
 }
 
 static inline int cpu_of(struct rq *rq)
@@ -663,7 +673,8 @@ static inline int cpu_of(struct rq *rq)
 
 inline void update_rq_clock(struct rq *rq)
 {
-	rq->clock = sched_clock_cpu(cpu_of(rq));
+	if (!rq->skip_clock_update)
+		rq->clock = sched_clock_cpu(cpu_of(rq));
 }
 
 /*
@@ -1247,6 +1258,17 @@ void wake_up_idle_cpu(int cpu)
 	if (!tsk_is_polling(rq->idle))
 		smp_send_reschedule(cpu);
 }
+
+int nohz_ratelimit(int cpu)
+{
+	struct rq *rq = cpu_rq(cpu);
+	u64 diff = rq->clock - rq->nohz_stamp;
+
+	rq->nohz_stamp = rq->clock;
+
+	return diff < (NSEC_PER_SEC / HZ) >> 1;
+}
+
 #endif /* CONFIG_NO_HZ */
 
 static u64 sched_avg_period(void)
@@ -1885,9 +1907,7 @@ static void update_avg(u64 *avg, u64 sample)
 
 static void enqueue_task(struct rq *rq, struct task_struct *p, int wakeup)
 {
-	if (wakeup)
-		p->se.start_runtime = p->se.sum_exec_runtime;
-
+	update_rq_clock(rq);
 	sched_info_queued(p);
 	p->sched_class->enqueue_task(rq, p, wakeup);
 	p->se.on_rq = 1;
@@ -1895,17 +1915,7 @@ static void enqueue_task(struct rq *rq, struct task_struct *p, int wakeup)
 
 static void dequeue_task(struct rq *rq, struct task_struct *p, int sleep)
 {
-	if (sleep) {
-		if (p->se.last_wakeup) {
-			update_avg(&p->se.avg_overlap,
-				p->se.sum_exec_runtime - p->se.last_wakeup);
-			p->se.last_wakeup = 0;
-		} else {
-			update_avg(&p->se.avg_wakeup,
-				sysctl_sched_wakeup_granularity);
-		}
-	}
-
+	update_rq_clock(rq);
 	sched_info_dequeued(p);
 	p->sched_class->dequeue_task(rq, p, sleep);
 	p->se.on_rq = 0;
@@ -2378,7 +2388,6 @@ static int try_to_wake_up(struct task_struct *p, unsigned int state,
 
 	smp_wmb();
 	rq = orig_rq = task_rq_lock(p, &flags);
-	update_rq_clock(rq);
 	if (!(p->state & state))
 		goto out;
 
@@ -2412,7 +2421,6 @@ static int try_to_wake_up(struct task_struct *p, unsigned int state,
 		set_task_cpu(p, cpu);
 
 	rq = __task_rq_lock(p);
-	update_rq_clock(rq);
 
 	WARN_ON(p->state != TASK_WAKING);
 	cpu = task_cpu(p);
@@ -2446,22 +2454,6 @@ out_activate:
 	activate_task(rq, p, 1);
 	success = 1;
 
-	/*
-	 * Only attribute actual wakeups done by this task.
-	 */
-	if (!in_interrupt()) {
-		struct sched_entity *se = &current->se;
-		u64 sample = se->sum_exec_runtime;
-
-		if (se->last_wakeup)
-			sample -= se->last_wakeup;
-		else
-			sample -= se->start_runtime;
-		update_avg(&se->avg_wakeup, sample);
-
-		se->last_wakeup = se->sum_exec_runtime;
-	}
-
 out_running:
 	trace_sched_wakeup(rq, p, success);
 	check_preempt_curr(rq, p, wake_flags);
@@ -2523,10 +2515,6 @@ static void __sched_fork(struct task_struct *p)
 	p->se.sum_exec_runtime		= 0;
 	p->se.prev_sum_exec_runtime	= 0;
 	p->se.nr_migrations		= 0;
-	p->se.last_wakeup		= 0;
-	p->se.avg_overlap		= 0;
-	p->se.start_runtime		= 0;
-	p->se.avg_wakeup		= sysctl_sched_wakeup_granularity;
 
 #ifdef CONFIG_SCHEDSTATS
 	p->se.wait_start			= 0;
@@ -2666,7 +2654,6 @@ void wake_up_new_task(struct task_struct *p, unsigned long clone_flags)
 	rq = task_rq_lock(p, &flags);
 	BUG_ON(p->state != TASK_WAKING);
 	p->state = TASK_RUNNING;
-	update_rq_clock(rq);
 	activate_task(rq, p, 0);
 	trace_sched_wakeup_new(rq, p, 1);
 	check_preempt_curr(rq, p, WF_FORK);
@@ -3121,8 +3108,6 @@ static void double_rq_lock(struct rq *rq1, struct rq *rq2)
 			raw_spin_lock_nested(&rq1->lock, SINGLE_DEPTH_NESTING);
 		}
 	}
-	update_rq_clock(rq1);
-	update_rq_clock(rq2);
 }
 
 /*
@@ -5423,23 +5408,9 @@ static inline void schedule_debug(struct task_struct *prev)
 
 static void put_prev_task(struct rq *rq, struct task_struct *prev)
 {
-	if (prev->state == TASK_RUNNING) {
-		u64 runtime = prev->se.sum_exec_runtime;
-
-		runtime -= prev->se.prev_sum_exec_runtime;
-		runtime = min_t(u64, runtime, 2*sysctl_sched_migration_cost);
-
-		/*
-		 * In order to avoid avg_overlap growing stale when we are
-		 * indeed overlapping and hence not getting put to sleep, grow
-		 * the avg_overlap on preemption.
-		 *
-		 * We use the average preemption runtime because that
-		 * correlates to the amount of cache footprint a task can
-		 * build up.
-		 */
-		update_avg(&prev->se.avg_overlap, runtime);
-	}
+	if (prev->se.on_rq)
+		update_rq_clock(rq);
+	rq->skip_clock_update = 0;
 	prev->sched_class->put_prev_task(rq, prev);
 }
 
@@ -5502,7 +5473,6 @@ need_resched_nonpreemptible:
 		hrtick_clear(rq);
 
 	raw_spin_lock_irq(&rq->lock);
-	update_rq_clock(rq);
 	clear_tsk_need_resched(prev);
 
 	if (prev->state && !(preempt_count() & PREEMPT_ACTIVE)) {
@@ -6059,7 +6029,6 @@ void rt_mutex_setprio(struct task_struct *p, int prio)
 	BUG_ON(prio < 0 || prio > MAX_PRIO);
 
 	rq = task_rq_lock(p, &flags);
-	update_rq_clock(rq);
 
 	oldprio = p->prio;
 	on_rq = p->se.on_rq;
@@ -6101,7 +6070,6 @@ void set_user_nice(struct task_struct *p, long nice)
 	 * the task might be in the middle of scheduling on another CPU.
 	 */
 	rq = task_rq_lock(p, &flags);
-	update_rq_clock(rq);
 	/*
 	 * The RT priorities are set via sched_setscheduler(), but we still
 	 * allow the 'normal' nice value to be set - but as expected
@@ -6384,7 +6352,6 @@ recheck:
 		raw_spin_unlock_irqrestore(&p->pi_lock, flags);
 		goto recheck;
 	}
-	update_rq_clock(rq);
 	on_rq = p->se.on_rq;
 	running = task_current(rq, p);
 	if (on_rq)
@@ -7409,7 +7376,6 @@ void sched_idle_next(void)
 
 	__setscheduler(rq, p, SCHED_FIFO, MAX_RT_PRIO-1);
 
-	update_rq_clock(rq);
 	activate_task(rq, p, 0);
 
 	raw_spin_unlock_irqrestore(&rq->lock, flags);
@@ -7464,7 +7430,6 @@ static void migrate_dead_tasks(unsigned int dead_cpu)
 	for ( ; ; ) {
 		if (!rq->nr_running)
 			break;
-		update_rq_clock(rq);
 		next = pick_next_task(rq);
 		if (!next)
 			break;
@@ -7748,7 +7713,6 @@ migration_call(struct notifier_block *nfb, unsigned long action, void *hcpu)
 		rq->migration_thread = NULL;
 		/* Idle task back to normal (off runqueue, low prio) */
 		raw_spin_lock_irq(&rq->lock);
-		update_rq_clock(rq);
 		deactivate_task(rq, rq->idle, 0);
 		__setscheduler(rq, rq->idle, SCHED_NORMAL, 0);
 		rq->idle->sched_class = &idle_sched_class;
@@ -9746,7 +9710,6 @@ static void normalize_task(struct rq *rq, struct task_struct *p)
 {
 	int on_rq;
 
-	update_rq_clock(rq);
 	on_rq = p->se.on_rq;
 	if (on_rq)
 		deactivate_task(rq, p, 0);
@@ -10108,8 +10071,6 @@ void sched_move_task(struct task_struct *tsk)
 
 	rq = task_rq_lock(tsk, &flags);
 
-	update_rq_clock(rq);
-
 	running = task_current(rq, tsk);
 	on_rq = tsk->se.on_rq;
 
diff --git a/kernel/sched_debug.c b/kernel/sched_debug.c
index 67f95aa..e91311d 100644
--- a/kernel/sched_debug.c
+++ b/kernel/sched_debug.c
@@ -407,8 +407,6 @@ void proc_sched_show_task(struct task_struct *p, struct seq_file *m)
 	PN(se.exec_start);
 	PN(se.vruntime);
 	PN(se.sum_exec_runtime);
-	PN(se.avg_overlap);
-	PN(se.avg_wakeup);
 
 	nr_switches = p->nvcsw + p->nivcsw;
 
diff --git a/kernel/sched_fair.c b/kernel/sched_fair.c
index 8fe7ee8..22edbd6 100644
--- a/kernel/sched_fair.c
+++ b/kernel/sched_fair.c
@@ -1239,7 +1239,6 @@ static inline unsigned long effective_load(struct task_group *tg, int cpu,
 
 static int wake_affine(struct sched_domain *sd, struct task_struct *p, int sync)
 {
-	struct task_struct *curr = current;
 	unsigned long this_load, load;
 	int idx, this_cpu, prev_cpu;
 	unsigned long tl_per_task;
@@ -1254,18 +1253,6 @@ static int wake_affine(struct sched_domain *sd, struct task_struct *p, int sync)
 	load	  = source_load(prev_cpu, idx);
 	this_load = target_load(this_cpu, idx);
 
-	if (sync) {
-	       if (sched_feat(SYNC_LESS) &&
-		   (curr->se.avg_overlap > sysctl_sched_migration_cost ||
-		    p->se.avg_overlap > sysctl_sched_migration_cost))
-		       sync = 0;
-	} else {
-		if (sched_feat(SYNC_MORE) &&
-		    (curr->se.avg_overlap < sysctl_sched_migration_cost &&
-		     p->se.avg_overlap < sysctl_sched_migration_cost))
-			sync = 1;
-	}
-
 	/*
 	 * If sync wakeup then subtract the (maximum possible)
 	 * effect of the currently running task from the load
@@ -1530,6 +1517,7 @@ static int select_task_rq_fair(struct task_struct *p, int sd_flag, int wake_flag
 			sd = tmp;
 	}
 
+#ifdef CONFIG_FAIR_GROUP_SCHED
 	if (sched_feat(LB_SHARES_UPDATE)) {
 		/*
 		 * Pick the largest domain to update shares over
@@ -1543,9 +1531,16 @@ static int select_task_rq_fair(struct task_struct *p, int sd_flag, int wake_flag
 		if (tmp)
 			update_shares(tmp);
 	}
+#endif
 
-	if (affine_sd && wake_affine(affine_sd, p, sync))
-		return cpu;
+	if (affine_sd) {
+		if (cpu == prev_cpu)
+			return cpu;
+		if (wake_affine(affine_sd, p, sync))
+			return cpu;
+		if (!(affine_sd->flags & SD_BALANCE_WAKE))
+			return prev_cpu;
+	}
 
 	while (sd) {
 		int load_idx = sd->forkexec_idx;
@@ -1590,42 +1585,11 @@ static int select_task_rq_fair(struct task_struct *p, int sd_flag, int wake_flag
 }
 #endif /* CONFIG_SMP */
 
-/*
- * Adaptive granularity
- *
- * se->avg_wakeup gives the average time a task runs until it does a wakeup,
- * with the limit of wakeup_gran -- when it never does a wakeup.
- *
- * So the smaller avg_wakeup is the faster we want this task to preempt,
- * but we don't want to treat the preemptee unfairly and therefore allow it
- * to run for at least the amount of time we'd like to run.
- *
- * NOTE: we use 2*avg_wakeup to increase the probability of actually doing one
- *
- * NOTE: we use *nr_running to scale with load, this nicely matches the
- *       degrading latency on load.
- */
-static unsigned long
-adaptive_gran(struct sched_entity *curr, struct sched_entity *se)
-{
-	u64 this_run = curr->sum_exec_runtime - curr->prev_sum_exec_runtime;
-	u64 expected_wakeup = 2*se->avg_wakeup * cfs_rq_of(se)->nr_running;
-	u64 gran = 0;
-
-	if (this_run < expected_wakeup)
-		gran = expected_wakeup - this_run;
-
-	return min_t(s64, gran, sysctl_sched_wakeup_granularity);
-}
-
 static unsigned long
 wakeup_gran(struct sched_entity *curr, struct sched_entity *se)
 {
 	unsigned long gran = sysctl_sched_wakeup_granularity;
 
-	if (cfs_rq_of(curr)->curr && sched_feat(ADAPTIVE_GRAN))
-		gran = adaptive_gran(curr, se);
-
 	/*
 	 * Since its curr running now, convert the gran from real-time
 	 * to virtual-time in his units.
@@ -1740,11 +1704,6 @@ static void check_preempt_wakeup(struct rq *rq, struct task_struct *p, int wake_
 	if (sched_feat(WAKEUP_SYNC) && sync)
 		goto preempt;
 
-	if (sched_feat(WAKEUP_OVERLAP) &&
-			se->avg_overlap < sysctl_sched_migration_cost &&
-			pse->avg_overlap < sysctl_sched_migration_cost)
-		goto preempt;
-
 	if (!sched_feat(WAKEUP_PREEMPT))
 		return;
 
diff --git a/kernel/sched_features.h b/kernel/sched_features.h
index d5059fd..c545e04 100644
--- a/kernel/sched_features.h
+++ b/kernel/sched_features.h
@@ -31,12 +31,6 @@ SCHED_FEAT(START_DEBIT, 1)
 SCHED_FEAT(WAKEUP_PREEMPT, 1)
 
 /*
- * Compute wakeup_gran based on task behaviour, clipped to
- *  [0, sched_wakeup_gran_ns]
- */
-SCHED_FEAT(ADAPTIVE_GRAN, 1)
-
-/*
  * When converting the wakeup granularity to virtual time, do it such
  * that heavier tasks preempting a lighter task have an edge.
  */
@@ -48,12 +42,6 @@ SCHED_FEAT(ASYM_GRAN, 1)
 SCHED_FEAT(WAKEUP_SYNC, 0)
 
 /*
- * Wakeup preempt based on task behaviour. Tasks that do not overlap
- * don't get preempted.
- */
-SCHED_FEAT(WAKEUP_OVERLAP, 0)
-
-/*
  * Use the SYNC wakeup hint, pipes and the likes use this to indicate
  * the remote end is likely to consume the data we just wrote, and
  * therefore has cache benefit from being placed on the same cpu, see
@@ -70,16 +58,6 @@ SCHED_FEAT(SYNC_WAKEUPS, 1)
 SCHED_FEAT(AFFINE_WAKEUPS, 1)
 
 /*
- * Weaken SYNC hint based on overlap
- */
-SCHED_FEAT(SYNC_LESS, 1)
-
-/*
- * Add SYNC hint based on overlap
- */
-SCHED_FEAT(SYNC_MORE, 0)
-
-/*
  * Prefer to schedule the task we woke last (assuming it failed
  * wakeup-preemption), since its likely going to consume data we
  * touched, increases cache locality.
diff --git a/kernel/time/tick-sched.c b/kernel/time/tick-sched.c
index f992762..f25735a 100644
--- a/kernel/time/tick-sched.c
+++ b/kernel/time/tick-sched.c
@@ -262,6 +262,9 @@ void tick_nohz_stop_sched_tick(int inidle)
 		goto end;
 	}
 
+	if (nohz_ratelimit(cpu))
+		goto end;
+
 	ts->idle_calls++;
 	/* Read jiffies and the time when jiffies were updated last */
 	do {
