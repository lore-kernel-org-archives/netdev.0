From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC] v5 expedited "big hammer" RCU grace periods
Date: Sun, 17 May 2009 12:11:41 -0700
Message-ID: <20090517191141.GA25915@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mingo@elte.hu, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fifth cut of "big hammer" expedited RCU grace periods.  This uses per-CPU
kthreads that are scheduled in parallel by a call to smp_call_function()
by yet another kthread.  The synchronize_sched(), synchronize_rcu(),
and synchronize_bh() primitives wake this kthread up and then wait for
it to force the grace period.

As before, this does nothing to expedite callbacks already registered
with call_rcu() or call_rcu_bh(), but there is no need to.  Just maps
to synchronize_rcu() and a new synchronize_rcu_bh() on preemptable RCU,
which has more complex grace-period detection -- this can be fixed later.

Passes light rcutorture testing.  Grace periods take about 45 microseconds
on an 8-CPU Power machine, which I believe is good enough from a
performance viewpoint.  Scalability may eventually need to be addressed
in the smp_call_function() primitive and perhaps also in the scan through
the CPUs that determines when all have completed.  Although this is most
definitely not ready for inclusion, it seems to be a promising approach.

Shortcomings:

o	CPU hotplug testing would probably cause it to die horribly.

o	It is not clear to me why I retained the single non-per-CPU
	kthread, it can probably be dispensed with.

o	The per-CPU kthreads do not boost themselves to real-time
	priority, and thus could be blocked by real-time processes.
	Use of real-time priority might also speed things up a bit.

o	Contains random debug statements.

o	Does not address preemptable RCU.

Changes since v4:

o	Use per-CPU kthreads to force the quiescent states in parallel.

Changes since v3:

o	Use a kthread that schedules itself on each CPU in turn to
	force a grace period.  The synchronize_rcu() primitive
	wakes up the kthread in order to avoid messing with affinity
	masks on user tasks.

o	Tried a number of additional variations on the v3 approach, none
	of which helped much.

Changes since v2:

o	Use reschedule IPIs rather than a softirq.

Changes since v1:

o	Added rcutorture support, and added exports required by
	rcutorture.

o	Added comment stating that smp_call_function() implies a
	memory barrier, suggested by Mathieu.

o	Added #include for delay.h.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---

 include/linux/rcuclassic.h |   16 ++
 include/linux/rcupdate.h   |   25 ++--
 include/linux/rcupreempt.h |   10 +
 include/linux/rcutree.h    |   13 +-
 kernel/rcupdate.c          |  273 +++++++++++++++++++++++++++++++++++++++++++++
 kernel/rcupreempt.c        |    1 
 kernel/rcutorture.c        |  200 +++++++++++++++++---------------
 7 files changed, 432 insertions(+), 106 deletions(-)

diff --git a/include/linux/rcuclassic.h b/include/linux/rcuclassic.h
index bfd92e1..ea1ceb2 100644
--- a/include/linux/rcuclassic.h
+++ b/include/linux/rcuclassic.h
@@ -158,14 +158,28 @@ extern struct lockdep_map rcu_lock_map;
 
 #define call_rcu_sched(head, func) call_rcu(head, func)
 
+static inline void synchronize_rcu_expedited(void)
+{
+	synchronize_sched_expedited();
+}
+
+static inline void synchronize_rcu_bh_expedited(void)
+{
+	synchronize_sched_expedited();
+}
+
 extern void __rcu_init(void);
-#define rcu_init_sched()	do { } while (0)
 extern void rcu_check_callbacks(int cpu, int user);
 extern void rcu_restart_cpu(int cpu);
 
 extern long rcu_batches_completed(void);
 extern long rcu_batches_completed_bh(void);
 
+static inline void rcu_init_sched(void)
+{
+	synchronize_sched_expedited_init();
+}
+
 #define rcu_enter_nohz()	do { } while (0)
 #define rcu_exit_nohz()		do { } while (0)
 
diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 15fbb3c..60163d2 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -51,7 +51,19 @@ struct rcu_head {
 	void (*func)(struct rcu_head *head);
 };
 
-/* Internal to kernel, but needed by rcupreempt.h. */
+/* Exported common interfaces */
+extern void synchronize_rcu(void);
+extern void rcu_barrier(void);
+extern void rcu_barrier_bh(void);
+extern void rcu_barrier_sched(void);
+extern void synchronize_sched_expedited(void);
+extern int sched_expedited_torture_stats(char *page);
+
+/* Internal to kernel */
+extern void rcu_init(void);
+extern void rcu_scheduler_starting(void);
+extern void synchronize_sched_expedited_init(void);
+extern int rcu_needs_cpu(int cpu);
 extern int rcu_scheduler_active;
 
 #if defined(CONFIG_CLASSIC_RCU)
@@ -259,15 +271,4 @@ extern void call_rcu(struct rcu_head *head,
 extern void call_rcu_bh(struct rcu_head *head,
 			void (*func)(struct rcu_head *head));
 
-/* Exported common interfaces */
-extern void synchronize_rcu(void);
-extern void rcu_barrier(void);
-extern void rcu_barrier_bh(void);
-extern void rcu_barrier_sched(void);
-
-/* Internal to kernel */
-extern void rcu_init(void);
-extern void rcu_scheduler_starting(void);
-extern int rcu_needs_cpu(int cpu);
-
 #endif /* __LINUX_RCUPDATE_H */
diff --git a/include/linux/rcupreempt.h b/include/linux/rcupreempt.h
index fce5227..78117ed 100644
--- a/include/linux/rcupreempt.h
+++ b/include/linux/rcupreempt.h
@@ -74,6 +74,16 @@ extern int rcu_needs_cpu(int cpu);
 
 extern void __synchronize_sched(void);
 
+static inline void synchronize_rcu_expedited(void)
+{
+	synchronize_rcu();  /* Placeholder for new rcupreempt implementation. */
+}
+
+static inline void synchronize_rcu_bh_expedited(void)
+{
+	synchronize_rcu();  /* Placeholder for new rcupreempt implementation. */
+}
+
 extern void __rcu_init(void);
 extern void rcu_init_sched(void);
 extern void rcu_check_callbacks(int cpu, int user);
diff --git a/include/linux/rcutree.h b/include/linux/rcutree.h
index 58b2aa5..7b533ec 100644
--- a/include/linux/rcutree.h
+++ b/include/linux/rcutree.h
@@ -279,8 +279,14 @@ static inline void __rcu_read_unlock_bh(void)
 
 #define call_rcu_sched(head, func) call_rcu(head, func)
 
-static inline void rcu_init_sched(void)
+static inline void synchronize_rcu_expedited(void)
+{
+	synchronize_sched_expedited();
+}
+
+static inline void synchronize_rcu_bh_expedited(void)
 {
+	synchronize_sched_expedited();
 }
 
 extern void __rcu_init(void);
@@ -290,6 +296,11 @@ extern void rcu_restart_cpu(int cpu);
 extern long rcu_batches_completed(void);
 extern long rcu_batches_completed_bh(void);
 
+static inline void rcu_init_sched(void)
+{
+	synchronize_sched_expedited_init();
+}
+
 #ifdef CONFIG_NO_HZ
 void rcu_enter_nohz(void);
 void rcu_exit_nohz(void);
diff --git a/kernel/rcupdate.c b/kernel/rcupdate.c
index a967c9f..e80b75d 100644
--- a/kernel/rcupdate.c
+++ b/kernel/rcupdate.c
@@ -45,6 +45,8 @@
 #include <linux/mutex.h>
 #include <linux/module.h>
 #include <linux/kernel_stat.h>
+#include <linux/delay.h>
+#include <linux/kthread.h>
 
 enum rcu_barrier {
 	RCU_BARRIER_STD,
@@ -98,6 +100,30 @@ void synchronize_rcu(void)
 }
 EXPORT_SYMBOL_GPL(synchronize_rcu);
 
+/**
+ * synchronize_rcu_bh - wait until an rcu_bh grace period has elapsed.
+ *
+ * Control will return to the caller some time after a full rcu_bh grace
+ * period has elapsed, in other words after all currently executing rcu_bh
+ * read-side critical sections have completed.  RCU read-side critical
+ * sections are delimited by rcu_read_lock_bh() and rcu_read_unlock_bh(),
+ * and may be nested.
+ */
+void synchronize_rcu_bh(void)
+{
+	struct rcu_synchronize rcu;
+
+	if (rcu_blocking_is_gp())
+		return;
+
+	init_completion(&rcu.completion);
+	/* Will wake me after RCU finished. */
+	call_rcu_bh(&rcu.head, wakeme_after_rcu);
+	/* Wait for it. */
+	wait_for_completion(&rcu.completion);
+}
+EXPORT_SYMBOL_GPL(synchronize_rcu_bh);
+
 static void rcu_barrier_callback(struct rcu_head *notused)
 {
 	if (atomic_dec_and_test(&rcu_barrier_cpu_count))
@@ -129,6 +155,7 @@ static void rcu_barrier_func(void *type)
 static inline void wait_migrated_callbacks(void)
 {
 	wait_event(rcu_migrate_wq, !atomic_read(&rcu_migrate_type_count));
+	smp_mb(); /* In case we didn't sleep. */
 }
 
 /*
@@ -229,3 +256,249 @@ void rcu_scheduler_starting(void)
 	WARN_ON(nr_context_switches() > 0);
 	rcu_scheduler_active = 1;
 }
+
+
+#ifndef CONFIG_SMP
+
+void __init synchronize_sched_expedited_init(void)
+{
+}
+
+void synchronize_sched_expedited(void)
+{
+}
+EXPORT_SYMBOL_GPL(synchronize_sched_expedited);
+
+int sched_expedited_torture_stats(char *page)
+{
+}
+EXPORT_SYMBOL_GPL(sched_expedited_torture_stats);
+
+#else /* #ifndef CONFIG_SMP */
+
+static DEFINE_MUTEX(rcu_sched_expedited_mutex);
+static DECLARE_WAIT_QUEUE_HEAD(need_sched_expedited_wq);
+static DECLARE_WAIT_QUEUE_HEAD(sched_expedited_done_wq);
+static int need_sched_expedited;
+static int sched_expedited_done;
+struct task_struct *krcu_sched_expedited_task;
+static DEFINE_PER_CPU(struct task_struct *, krcu_sched_expedited_task);
+static DEFINE_PER_CPU(wait_queue_head_t, sched_expedited_qs_wq);
+static DEFINE_PER_CPU(int, sched_expedited_done_qs);
+static DEFINE_PER_CPU(struct mutex, sched_expedited_done_mutex);
+
+#define SCHED_EXPEDITED_QS_DONE_QS	0
+#define SCHED_EXPEDITED_QS_NEED_QS	1
+#define SCHED_EXPEDITED_QS_STOP		2
+#define SCHED_EXPEDITED_QS_STOPPED	3
+
+int sched_expedited_torture_stats(char *page)
+{
+	int cnt = 0;
+#ifdef CONFIG_RCU_TRACE
+	int cpu;
+	
+	cnt += sprintf(&page[cnt],
+		       "nse = %d, sed = %d, QSneededFrom: ",
+		       need_sched_expedited, sched_expedited_done);
+	for_each_online_cpu(cpu) {
+		if (per_cpu(sched_expedited_done_qs, cpu))
+			cnt += sprintf(&page[cnt], " %d/%d",
+				       cpu,
+				       per_cpu(sched_expedited_done_qs, cpu));
+	}
+	cnt += sprintf(&page[cnt], "\n");
+#endif /* #ifdef CONFIG_RCU_TRACE */
+	return cnt;
+}
+EXPORT_SYMBOL_GPL(sched_expedited_torture_stats);
+
+/*
+ * Per-CPU kernel thread that constitutes a quiescent state when running.
+ */
+static int krcu_sched_expedited_percpu(void *hcpu)
+{
+	long cpu = (long)hcpu;
+	struct mutex *mp = &per_cpu(sched_expedited_done_mutex, cpu);
+	int *mydonqs = &per_cpu(sched_expedited_done_qs, cpu);
+	wait_queue_head_t *mywq = &per_cpu(sched_expedited_qs_wq, cpu);
+	/* @@@ struct sched_param param = { .sched_priority = 0 }; */
+
+	sched_setaffinity(0, &cpumask_of_cpu(cpu));
+	/* @@@ FIXME: need to handle sched_setaffinity() failure. */
+	/* set_freezable(); */
+	/* sched_setscheduler_nocheck(current, SCHED_FIFO, &param); */
+	for (;;) {
+		wait_event_interruptible(*mywq,
+					 *mydonqs != SCHED_EXPEDITED_QS_DONE_QS);
+		mutex_lock(mp);
+		if (*mydonqs == SCHED_EXPEDITED_QS_DONE_QS)
+			continue;
+		if (*mydonqs == SCHED_EXPEDITED_QS_STOP) {
+			*mydonqs = SCHED_EXPEDITED_QS_STOPPED;
+			break;
+		}
+		*mydonqs = SCHED_EXPEDITED_QS_DONE_QS;
+		mutex_unlock(mp);
+	}
+	while (!kthread_should_stop())
+		schedule_timeout_uninterruptible(1);
+	return 0;
+}
+
+void sched_expedited_wake(void *unused)
+{
+	mutex_lock(&__get_cpu_var(sched_expedited_done_mutex));
+	if (__get_cpu_var(sched_expedited_done_qs) ==
+	    SCHED_EXPEDITED_QS_DONE_QS) {
+		__get_cpu_var(sched_expedited_done_qs) =
+			SCHED_EXPEDITED_QS_NEED_QS;
+		wake_up(&__get_cpu_var(sched_expedited_qs_wq));
+	}
+	mutex_unlock(&__get_cpu_var(sched_expedited_done_mutex));
+}
+
+/*
+ * Kernel thread that processes synchronize_sched_expedited() requests.
+ * This is implemented as a separate kernel thread to avoid the need
+ * to mess with other tasks' cpumasks.
+ */
+static int krcu_sched_expedited(void *arg)
+{
+	int cpu;
+	int mycpu;
+	int nwait;
+
+	do {
+		wait_event_interruptible(need_sched_expedited_wq,
+					 need_sched_expedited);
+		smp_mb(); /* In case we didn't sleep. */
+		if (!need_sched_expedited)
+			continue;
+		need_sched_expedited = 0;
+		get_online_cpus();
+		preempt_disable();
+		mycpu = smp_processor_id();
+		smp_call_function(sched_expedited_wake, NULL, 1);
+		preempt_enable();
+		nwait = 0;
+		for_each_online_cpu(cpu) {
+			if (cpu == mycpu)
+				continue;
+			while (per_cpu(sched_expedited_done_qs, cpu) ==
+			       SCHED_EXPEDITED_QS_NEED_QS) {
+				if (++nwait <= 10)
+					udelay(10);
+				else {
+					schedule_timeout_uninterruptible(1);
+/*&&&&*/if (nwait == HZ) {
+/*&&&&*/printk(KERN_ALERT "krcu_sched_expedited(): cpu=%d/%d, mycpu=%d\n", cpu, per_cpu(sched_expedited_done_qs, cpu), mycpu);
+/*&&&&*/}
+				}
+			}
+		}
+		put_online_cpus();
+		sched_expedited_done = 1;
+		smp_mb();  /* in case not yet asleep. */
+		wake_up(&sched_expedited_done_wq);
+	} while (!kthread_should_stop());
+	return 0;
+}
+
+static int __cpuinit
+synchronize_sched_expedited_notify(struct notifier_block *self,
+				   unsigned long action, void *hcpu)
+{
+	long cpu = (long)hcpu;
+	struct task_struct **tsp = &per_cpu(krcu_sched_expedited_task, cpu);
+	struct mutex *mp = &per_cpu(sched_expedited_done_mutex, cpu);
+
+	switch (action) {
+	case CPU_UP_PREPARE:
+	case CPU_UP_PREPARE_FROZEN:
+		if (*tsp == NULL)
+			mutex_lock(mp);
+			per_cpu(sched_expedited_done_qs, cpu) =
+				SCHED_EXPEDITED_QS_DONE_QS;
+			mutex_unlock(mp);
+			init_waitqueue_head(&per_cpu(sched_expedited_qs_wq,
+						     cpu));
+			*tsp = kthread_run(krcu_sched_expedited_percpu,
+					   (void *)cpu,
+					   "krcu_sched_expedited");
+			WARN_ON(IS_ERR(*tsp));
+			if (IS_ERR(*tsp)) {
+				*tsp = NULL;
+				return NOTIFY_BAD;
+			}
+/*&&&&*/printk(KERN_ALERT "synchronize_sched_expedited_notify() onlining cpu %ld\n", cpu);
+		break;
+	case CPU_DEAD:
+	case CPU_DEAD_FROZEN:
+	case CPU_UP_CANCELED:
+	case CPU_UP_CANCELED_FROZEN:
+		WARN_ON(*tsp == NULL);
+		if (*tsp) {
+			mutex_lock(mp);
+			while (per_cpu(sched_expedited_done_qs, cpu) !=
+			       SCHED_EXPEDITED_QS_STOPPED) {
+				per_cpu(sched_expedited_done_qs, cpu) =
+					SCHED_EXPEDITED_QS_STOP;
+				mutex_unlock(mp);
+				wake_up(&per_cpu(sched_expedited_qs_wq, cpu));
+				schedule_timeout_uninterruptible(1);
+				mutex_lock(mp);
+			}
+			mutex_unlock(mp);
+			kthread_stop(*tsp);
+			*tsp = NULL;
+		}
+/*&&&&*/printk(KERN_ALERT "synchronize_sched_expedited_notify() offlining cpu %ld\n", cpu);
+		break;
+	default:
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+/*
+ * Late-boot initialization for synchronize_sched_expedited().
+ * The scheduler must be running before this can be called.
+ */
+void __init synchronize_sched_expedited_init(void)
+{
+	int cpu;
+
+/*&&&&*/printk(KERN_ALERT "Initializing synchronize_sched_expedited()\n");
+	for_each_possible_cpu(cpu)
+		mutex_init(&per_cpu(sched_expedited_done_mutex, cpu));
+	hotcpu_notifier(synchronize_sched_expedited_notify, 0);
+	get_online_cpus();
+	for_each_online_cpu(cpu)
+		synchronize_sched_expedited_notify(NULL, CPU_UP_PREPARE,
+						   (void *)cpu);
+	put_online_cpus();
+	krcu_sched_expedited_task = kthread_run(krcu_sched_expedited, NULL,
+					        "krcu_sched_expedited");
+	WARN_ON(IS_ERR(krcu_sched_expedited_task));
+}
+
+void synchronize_sched_expedited(void)
+{
+	/* If there is only one CPU, we are done. */
+	if (num_online_cpus() == 1)
+		return;
+
+	/* Multiple CPUs, make krcu_sched_expedited() sequence through them. */
+	mutex_lock(&rcu_sched_expedited_mutex);
+	need_sched_expedited = 1;
+	smp_mb(); /* in case kthread not yet sleeping. */
+	wake_up(&need_sched_expedited_wq);
+	wait_event(sched_expedited_done_wq, sched_expedited_done);
+	smp_mb(); /* in case we didn't actually sleep. */
+	sched_expedited_done = 0;
+	mutex_unlock(&rcu_sched_expedited_mutex);
+}
+EXPORT_SYMBOL_GPL(synchronize_sched_expedited);
+
+#endif /* #else #ifndef CONFIG_SMP */
diff --git a/kernel/rcupreempt.c b/kernel/rcupreempt.c
index ce97a4d..4485758 100644
--- a/kernel/rcupreempt.c
+++ b/kernel/rcupreempt.c
@@ -1507,6 +1507,7 @@ void __init rcu_init_sched(void)
 						  NULL,
 						  "rcu_sched_grace_period");
 	WARN_ON(IS_ERR(rcu_sched_grace_period_task));
+	synchronize_sched_expedited_init();
 }
 
 #ifdef CONFIG_RCU_TRACE
diff --git a/kernel/rcutorture.c b/kernel/rcutorture.c
index 9b4a975..eebd4b8 100644
--- a/kernel/rcutorture.c
+++ b/kernel/rcutorture.c
@@ -257,14 +257,14 @@ struct rcu_torture_ops {
 	void (*init)(void);
 	void (*cleanup)(void);
 	int (*readlock)(void);
-	void (*readdelay)(struct rcu_random_state *rrsp);
+	void (*read_delay)(struct rcu_random_state *rrsp);
 	void (*readunlock)(int idx);
 	int (*completed)(void);
-	void (*deferredfree)(struct rcu_torture *p);
+	void (*deferred_free)(struct rcu_torture *p);
 	void (*sync)(void);
 	void (*cb_barrier)(void);
 	int (*stats)(char *page);
-	int irqcapable;
+	int irq_capable;
 	char *name;
 };
 static struct rcu_torture_ops *cur_ops = NULL;
@@ -320,7 +320,7 @@ rcu_torture_cb(struct rcu_head *p)
 		rp->rtort_mbtest = 0;
 		rcu_torture_free(rp);
 	} else
-		cur_ops->deferredfree(rp);
+		cur_ops->deferred_free(rp);
 }
 
 static void rcu_torture_deferred_free(struct rcu_torture *p)
@@ -329,18 +329,18 @@ static void rcu_torture_deferred_free(struct rcu_torture *p)
 }
 
 static struct rcu_torture_ops rcu_ops = {
-	.init = NULL,
-	.cleanup = NULL,
-	.readlock = rcu_torture_read_lock,
-	.readdelay = rcu_read_delay,
-	.readunlock = rcu_torture_read_unlock,
-	.completed = rcu_torture_completed,
-	.deferredfree = rcu_torture_deferred_free,
-	.sync = synchronize_rcu,
-	.cb_barrier = rcu_barrier,
-	.stats = NULL,
-	.irqcapable = 1,
-	.name = "rcu"
+	.init		= NULL,
+	.cleanup	= NULL,
+	.readlock	= rcu_torture_read_lock,
+	.read_delay	= rcu_read_delay,
+	.readunlock	= rcu_torture_read_unlock,
+	.completed	= rcu_torture_completed,
+	.deferred_free	= rcu_torture_deferred_free,
+	.sync		= synchronize_rcu,
+	.cb_barrier	= rcu_barrier,
+	.stats		= NULL,
+	.irq_capable 	= 1,
+	.name 		= "rcu"
 };
 
 static void rcu_sync_torture_deferred_free(struct rcu_torture *p)
@@ -370,18 +370,18 @@ static void rcu_sync_torture_init(void)
 }
 
 static struct rcu_torture_ops rcu_sync_ops = {
-	.init = rcu_sync_torture_init,
-	.cleanup = NULL,
-	.readlock = rcu_torture_read_lock,
-	.readdelay = rcu_read_delay,
-	.readunlock = rcu_torture_read_unlock,
-	.completed = rcu_torture_completed,
-	.deferredfree = rcu_sync_torture_deferred_free,
-	.sync = synchronize_rcu,
-	.cb_barrier = NULL,
-	.stats = NULL,
-	.irqcapable = 1,
-	.name = "rcu_sync"
+	.init		= rcu_sync_torture_init,
+	.cleanup	= NULL,
+	.readlock	= rcu_torture_read_lock,
+	.read_delay	= rcu_read_delay,
+	.readunlock	= rcu_torture_read_unlock,
+	.completed	= rcu_torture_completed,
+	.deferred_free	= rcu_sync_torture_deferred_free,
+	.sync		= synchronize_rcu,
+	.cb_barrier	= NULL,
+	.stats		= NULL,
+	.irq_capable	= 1,
+	.name		= "rcu_sync"
 };
 
 /*
@@ -432,33 +432,33 @@ static void rcu_bh_torture_synchronize(void)
 }
 
 static struct rcu_torture_ops rcu_bh_ops = {
-	.init = NULL,
-	.cleanup = NULL,
-	.readlock = rcu_bh_torture_read_lock,
-	.readdelay = rcu_read_delay,  /* just reuse rcu's version. */
-	.readunlock = rcu_bh_torture_read_unlock,
-	.completed = rcu_bh_torture_completed,
-	.deferredfree = rcu_bh_torture_deferred_free,
-	.sync = rcu_bh_torture_synchronize,
-	.cb_barrier = rcu_barrier_bh,
-	.stats = NULL,
-	.irqcapable = 1,
-	.name = "rcu_bh"
+	.init		= NULL,
+	.cleanup	= NULL,
+	.readlock	= rcu_bh_torture_read_lock,
+	.read_delay	= rcu_read_delay,  /* just reuse rcu's version. */
+	.readunlock	= rcu_bh_torture_read_unlock,
+	.completed	= rcu_bh_torture_completed,
+	.deferred_free	= rcu_bh_torture_deferred_free,
+	.sync		= rcu_bh_torture_synchronize,
+	.cb_barrier	= rcu_barrier_bh,
+	.stats		= NULL,
+	.irq_capable	= 1,
+	.name		= "rcu_bh"
 };
 
 static struct rcu_torture_ops rcu_bh_sync_ops = {
-	.init = rcu_sync_torture_init,
-	.cleanup = NULL,
-	.readlock = rcu_bh_torture_read_lock,
-	.readdelay = rcu_read_delay,  /* just reuse rcu's version. */
-	.readunlock = rcu_bh_torture_read_unlock,
-	.completed = rcu_bh_torture_completed,
-	.deferredfree = rcu_sync_torture_deferred_free,
-	.sync = rcu_bh_torture_synchronize,
-	.cb_barrier = NULL,
-	.stats = NULL,
-	.irqcapable = 1,
-	.name = "rcu_bh_sync"
+	.init		= rcu_sync_torture_init,
+	.cleanup	= NULL,
+	.readlock	= rcu_bh_torture_read_lock,
+	.read_delay	= rcu_read_delay,  /* just reuse rcu's version. */
+	.readunlock	= rcu_bh_torture_read_unlock,
+	.completed	= rcu_bh_torture_completed,
+	.deferred_free	= rcu_sync_torture_deferred_free,
+	.sync		= rcu_bh_torture_synchronize,
+	.cb_barrier	= NULL,
+	.stats		= NULL,
+	.irq_capable	= 1,
+	.name		= "rcu_bh_sync"
 };
 
 /*
@@ -530,17 +530,17 @@ static int srcu_torture_stats(char *page)
 }
 
 static struct rcu_torture_ops srcu_ops = {
-	.init = srcu_torture_init,
-	.cleanup = srcu_torture_cleanup,
-	.readlock = srcu_torture_read_lock,
-	.readdelay = srcu_read_delay,
-	.readunlock = srcu_torture_read_unlock,
-	.completed = srcu_torture_completed,
-	.deferredfree = rcu_sync_torture_deferred_free,
-	.sync = srcu_torture_synchronize,
-	.cb_barrier = NULL,
-	.stats = srcu_torture_stats,
-	.name = "srcu"
+	.init		= srcu_torture_init,
+	.cleanup	= srcu_torture_cleanup,
+	.readlock	= srcu_torture_read_lock,
+	.read_delay	= srcu_read_delay,
+	.readunlock	= srcu_torture_read_unlock,
+	.completed	= srcu_torture_completed,
+	.deferred_free	= rcu_sync_torture_deferred_free,
+	.sync		= srcu_torture_synchronize,
+	.cb_barrier	= NULL,
+	.stats		= srcu_torture_stats,
+	.name		= "srcu"
 };
 
 /*
@@ -574,32 +574,47 @@ static void sched_torture_synchronize(void)
 }
 
 static struct rcu_torture_ops sched_ops = {
-	.init = rcu_sync_torture_init,
-	.cleanup = NULL,
-	.readlock = sched_torture_read_lock,
-	.readdelay = rcu_read_delay,  /* just reuse rcu's version. */
-	.readunlock = sched_torture_read_unlock,
-	.completed = sched_torture_completed,
-	.deferredfree = rcu_sched_torture_deferred_free,
-	.sync = sched_torture_synchronize,
-	.cb_barrier = rcu_barrier_sched,
-	.stats = NULL,
-	.irqcapable = 1,
-	.name = "sched"
+	.init		= rcu_sync_torture_init,
+	.cleanup	= NULL,
+	.readlock	= sched_torture_read_lock,
+	.read_delay	= rcu_read_delay,  /* just reuse rcu's version. */
+	.readunlock	= sched_torture_read_unlock,
+	.completed	= sched_torture_completed,
+	.deferred_free	= rcu_sched_torture_deferred_free,
+	.sync		= sched_torture_synchronize,
+	.cb_barrier	= rcu_barrier_sched,
+	.stats		= NULL,
+	.irq_capable	= 1,
+	.name		= "sched"
 };
 
 static struct rcu_torture_ops sched_ops_sync = {
-	.init = rcu_sync_torture_init,
-	.cleanup = NULL,
-	.readlock = sched_torture_read_lock,
-	.readdelay = rcu_read_delay,  /* just reuse rcu's version. */
-	.readunlock = sched_torture_read_unlock,
-	.completed = sched_torture_completed,
-	.deferredfree = rcu_sync_torture_deferred_free,
-	.sync = sched_torture_synchronize,
-	.cb_barrier = NULL,
-	.stats = NULL,
-	.name = "sched_sync"
+	.init		= rcu_sync_torture_init,
+	.cleanup	= NULL,
+	.readlock	= sched_torture_read_lock,
+	.read_delay	= rcu_read_delay,  /* just reuse rcu's version. */
+	.readunlock	= sched_torture_read_unlock,
+	.completed	= sched_torture_completed,
+	.deferred_free	= rcu_sync_torture_deferred_free,
+	.sync		= sched_torture_synchronize,
+	.cb_barrier	= NULL,
+	.stats		= NULL,
+	.name		= "sched_sync"
+};
+
+static struct rcu_torture_ops sched_expedited_ops = {
+	.init		= rcu_sync_torture_init,
+	.cleanup	= NULL,
+	.readlock	= sched_torture_read_lock,
+	.read_delay	= rcu_read_delay,  /* just reuse rcu's version. */
+	.readunlock	= sched_torture_read_unlock,
+	.completed	= sched_torture_completed,
+	.deferred_free	= rcu_sync_torture_deferred_free,
+	.sync		= synchronize_sched_expedited,
+	.cb_barrier	= NULL,
+	.stats		= sched_expedited_torture_stats,
+	.irq_capable	= 1,
+	.name		= "sched_expedited"
 };
 
 /*
@@ -635,7 +650,7 @@ rcu_torture_writer(void *arg)
 				i = RCU_TORTURE_PIPE_LEN;
 			atomic_inc(&rcu_torture_wcount[i]);
 			old_rp->rtort_pipe_count++;
-			cur_ops->deferredfree(old_rp);
+			cur_ops->deferred_free(old_rp);
 		}
 		rcu_torture_current_version++;
 		oldbatch = cur_ops->completed();
@@ -700,7 +715,7 @@ static void rcu_torture_timer(unsigned long unused)
 	if (p->rtort_mbtest == 0)
 		atomic_inc(&n_rcu_torture_mberror);
 	spin_lock(&rand_lock);
-	cur_ops->readdelay(&rand);
+	cur_ops->read_delay(&rand);
 	n_rcu_torture_timers++;
 	spin_unlock(&rand_lock);
 	preempt_disable();
@@ -738,11 +753,11 @@ rcu_torture_reader(void *arg)
 
 	VERBOSE_PRINTK_STRING("rcu_torture_reader task started");
 	set_user_nice(current, 19);
-	if (irqreader && cur_ops->irqcapable)
+	if (irqreader && cur_ops->irq_capable)
 		setup_timer_on_stack(&t, rcu_torture_timer, 0);
 
 	do {
-		if (irqreader && cur_ops->irqcapable) {
+		if (irqreader && cur_ops->irq_capable) {
 			if (!timer_pending(&t))
 				mod_timer(&t, 1);
 		}
@@ -757,7 +772,7 @@ rcu_torture_reader(void *arg)
 		}
 		if (p->rtort_mbtest == 0)
 			atomic_inc(&n_rcu_torture_mberror);
-		cur_ops->readdelay(&rand);
+		cur_ops->read_delay(&rand);
 		preempt_disable();
 		pipe_count = p->rtort_pipe_count;
 		if (pipe_count > RCU_TORTURE_PIPE_LEN) {
@@ -778,7 +793,7 @@ rcu_torture_reader(void *arg)
 	} while (!kthread_should_stop() && fullstop == FULLSTOP_DONTSTOP);
 	VERBOSE_PRINTK_STRING("rcu_torture_reader task stopping");
 	rcutorture_shutdown_absorb("rcu_torture_reader");
-	if (irqreader && cur_ops->irqcapable)
+	if (irqreader && cur_ops->irq_capable)
 		del_timer_sync(&t);
 	while (!kthread_should_stop())
 		schedule_timeout_uninterruptible(1);
@@ -1078,6 +1093,7 @@ rcu_torture_init(void)
 	int firsterr = 0;
 	static struct rcu_torture_ops *torture_ops[] =
 		{ &rcu_ops, &rcu_sync_ops, &rcu_bh_ops, &rcu_bh_sync_ops,
+		  &sched_expedited_ops,
 		  &srcu_ops, &sched_ops, &sched_ops_sync, };
 
 	mutex_lock(&fullstop_mutex);
