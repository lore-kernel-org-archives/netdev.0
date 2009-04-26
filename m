From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC] v2 expedited "big hammer" RCU grace periods
Date: Sat, 25 Apr 2009 22:23:40 -0700
Message-ID: <20090426052340.GA24931@linux.vnet.ibm.com>
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752548AbZDZFYB@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Second cut of "big hammer" expedited RCU grace periods, but only for
rcu_bh.  This creates another softirq vector, so that entering this
softirq vector will have forced an rcu_bh quiescent state (as noted by
Dave Miller).  Use smp_call_function() to invoke raise_softirq() on all
CPUs in order to cause this to happen.  Track the CPUs that have passed
through a quiescent state (or gone offline) with a cpumask.

Does nothing to expedite callbacks already registered with call_rcu_bh(),
but there is no need to.

Passes light rcutorture testing.  Grace periods take about 28 microseconds
on an 8CPU 1.5GHZ Power box.

Shortcomings:

o	Needs more testing, still not for inclusion.

o	Does not handle rcu, only rcu_bh.

Changes since v1:

o	Added rcutorture support, and added exports required by
	rcutorture.

o	Added comment stating that smp_call_function() implies a
	memory barrier, suggested by Mathieu.

o	Added #include for delay.h.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---

 include/linux/interrupt.h |    1 
 include/linux/rcupdate.h  |    2 
 kernel/rcupdate.c         |  115 +++++++++++++++++++++++++
 kernel/rcutorture.c       |  205 +++++++++++++++++++++++++---------------------
 4 files changed, 231 insertions(+), 92 deletions(-)

diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 91bb76f..b7b58cc 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -338,6 +338,7 @@ enum
 	TASKLET_SOFTIRQ,
 	SCHED_SOFTIRQ,
 	HRTIMER_SOFTIRQ,
+	RCU_EXPEDITED_SOFTIRQ,
 	RCU_SOFTIRQ,	/* Preferable RCU should always be the last softirq */
 
 	NR_SOFTIRQS
diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 15fbb3c..a606b42 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -264,6 +264,8 @@ extern void synchronize_rcu(void);
 extern void rcu_barrier(void);
 extern void rcu_barrier_bh(void);
 extern void rcu_barrier_sched(void);
+extern void synchronize_rcu_bh_expedited(void);
+extern long rcu_batches_completed_bh_expedited(void);
 
 /* Internal to kernel */
 extern void rcu_init(void);
diff --git a/kernel/rcupdate.c b/kernel/rcupdate.c
index a967c9f..e995e73 100644
--- a/kernel/rcupdate.c
+++ b/kernel/rcupdate.c
@@ -45,6 +45,7 @@
 #include <linux/mutex.h>
 #include <linux/module.h>
 #include <linux/kernel_stat.h>
+#include <linux/delay.h>
 
 enum rcu_barrier {
 	RCU_BARRIER_STD,
@@ -217,10 +218,124 @@ static int __cpuinit rcu_barrier_cpu_hotplug(struct notifier_block *self,
 	return NOTIFY_OK;
 }
 
+static DEFINE_MUTEX(synchronize_rcu_bh_mutex);
+static long synchronize_rcu_bh_completed; /* Expedited-grace-period count. */
+
+long rcu_batches_completed_bh_expedited(void)
+{
+	return synchronize_rcu_bh_completed;
+}
+EXPORT_SYMBOL_GPL(rcu_batches_completed_bh_expedited);
+
+#ifndef CONFIG_SMP
+
+static void __init synchronize_rcu_expedited_init(void)
+{
+}
+
+void synchronize_rcu_bh_expedited(void)
+{
+	mutex_lock(&synchronize_rcu_bh_mutex);
+	synchronize_rcu_bh_completed++;
+	mutex_unlock(&synchronize_rcu_bh_mutex);
+}
+EXPORT_SYMBOL_GPL(synchronize_rcu_bh_expedited);
+
+#else /* #ifndef CONFIG_SMP */
+
+static DEFINE_PER_CPU(int, rcu_bh_need_qs);
+static cpumask_var_t rcu_bh_waiting_map;
+
+static void synchronize_rcu_bh_expedited_help(struct softirq_action *unused)
+{
+	if (__get_cpu_var(rcu_bh_need_qs)) {
+		smp_mb();
+		__get_cpu_var(rcu_bh_need_qs) = 0;
+		smp_mb();
+	}
+}
+
+static void rcu_bh_fast_qs(void *unused)
+{
+	raise_softirq(RCU_EXPEDITED_SOFTIRQ);
+}
+
+static void __init synchronize_rcu_expedited_init(void)
+{
+	open_softirq(RCU_EXPEDITED_SOFTIRQ, synchronize_rcu_bh_expedited_help);
+	alloc_bootmem_cpumask_var(&rcu_bh_waiting_map);
+}
+
+void synchronize_rcu_bh_expedited(void)
+{
+	int cpu;
+	int done;
+	int times = 0;
+
+	mutex_lock(&synchronize_rcu_bh_mutex);
+
+	/* Take snapshot of online CPUs, blocking CPU hotplug. */
+	preempt_disable();
+	cpumask_copy(rcu_bh_waiting_map, &cpu_online_map);
+	preempt_enable();
+
+	/* Mark each online CPU as needing a quiescent state. */
+	for_each_cpu(cpu, rcu_bh_waiting_map)
+		per_cpu(rcu_bh_need_qs, cpu) = 1;
+
+	/* Call for a quiescent state on each online CPU. */
+	preempt_disable();
+	cpumask_clear_cpu(smp_processor_id(), rcu_bh_waiting_map);
+	smp_call_function(rcu_bh_fast_qs, NULL, 1); /* implies smp_mb(). */
+	preempt_enable();
+
+	/*
+	 * Loop waiting for each CPU to either pass through a quiescent
+	 * state or to go offline.  We don't care which.
+	 */
+	for (;;) {
+		
+		/* Ignore CPUs that have gone offline, blocking CPU hotplug. */
+		preempt_disable();
+		cpumask_and(rcu_bh_waiting_map, rcu_bh_waiting_map,
+			    &cpu_online_map);
+		cpumask_clear_cpu(smp_processor_id(), rcu_bh_waiting_map);
+		preempt_enable();
+
+		/* Check if any CPUs still need a quiescent state. */
+		done = 1;
+		for_each_cpu(cpu, rcu_bh_waiting_map) {
+			if (per_cpu(rcu_bh_need_qs, cpu)) {
+				done = 0;
+				break;
+			}
+			cpumask_clear_cpu(cpu, rcu_bh_waiting_map);
+		}
+		if (done)
+			break;
+
+		/*
+		 * Wait a bit.  If we have already waited a fair
+		 * amount of time, sleep.
+		 */
+		if (++times < 10)
+			udelay(10 * times);
+		else
+			schedule_timeout_uninterruptible(1);
+	}
+
+	synchronize_rcu_bh_completed++;
+	mutex_unlock(&synchronize_rcu_bh_mutex);
+}
+EXPORT_SYMBOL_GPL(synchronize_rcu_bh_expedited);
+
+#endif /* #else #ifndef CONFIG_SMP */
+
 void __init rcu_init(void)
 {
 	__rcu_init();
 	hotcpu_notifier(rcu_barrier_cpu_hotplug, 0);
+	synchronize_rcu_expedited_init();
 }
 
 void rcu_scheduler_starting(void)
diff --git a/kernel/rcutorture.c b/kernel/rcutorture.c
index 9b4a975..8845936 100644
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
@@ -432,33 +432,53 @@ static void rcu_bh_torture_synchronize(void)
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
+};
+
+static int rcu_bh_expedited_torture_completed(void)
+{
+	return rcu_batches_completed_bh_expedited();
+}
+
+static struct rcu_torture_ops rcu_bh_expedited_ops = {
+	.init		= rcu_sync_torture_init,
+	.cleanup	= NULL,
+	.readlock	= rcu_bh_torture_read_lock,
+	.read_delay	= rcu_read_delay,  /* just reuse rcu's version. */
+	.readunlock	= rcu_bh_torture_read_unlock,
+	.completed	= rcu_bh_expedited_torture_completed,
+	.deferred_free	= rcu_sync_torture_deferred_free,
+	.sync		= synchronize_rcu_bh_expedited,
+	.cb_barrier	= NULL,
+	.stats		= NULL,
+	.irq_capable	= 1,
+	.name		= "rcu_bh_expedited"
 };
 
 /*
@@ -530,17 +550,17 @@ static int srcu_torture_stats(char *page)
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
@@ -574,32 +594,32 @@ static void sched_torture_synchronize(void)
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
 };
 
 /*
@@ -635,7 +655,7 @@ rcu_torture_writer(void *arg)
 				i = RCU_TORTURE_PIPE_LEN;
 			atomic_inc(&rcu_torture_wcount[i]);
 			old_rp->rtort_pipe_count++;
-			cur_ops->deferredfree(old_rp);
+			cur_ops->deferred_free(old_rp);
 		}
 		rcu_torture_current_version++;
 		oldbatch = cur_ops->completed();
@@ -700,7 +720,7 @@ static void rcu_torture_timer(unsigned long unused)
 	if (p->rtort_mbtest == 0)
 		atomic_inc(&n_rcu_torture_mberror);
 	spin_lock(&rand_lock);
-	cur_ops->readdelay(&rand);
+	cur_ops->read_delay(&rand);
 	n_rcu_torture_timers++;
 	spin_unlock(&rand_lock);
 	preempt_disable();
@@ -738,11 +758,11 @@ rcu_torture_reader(void *arg)
 
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
@@ -757,7 +777,7 @@ rcu_torture_reader(void *arg)
 		}
 		if (p->rtort_mbtest == 0)
 			atomic_inc(&n_rcu_torture_mberror);
-		cur_ops->readdelay(&rand);
+		cur_ops->read_delay(&rand);
 		preempt_disable();
 		pipe_count = p->rtort_pipe_count;
 		if (pipe_count > RCU_TORTURE_PIPE_LEN) {
@@ -778,7 +798,7 @@ rcu_torture_reader(void *arg)
 	} while (!kthread_should_stop() && fullstop == FULLSTOP_DONTSTOP);
 	VERBOSE_PRINTK_STRING("rcu_torture_reader task stopping");
 	rcutorture_shutdown_absorb("rcu_torture_reader");
-	if (irqreader && cur_ops->irqcapable)
+	if (irqreader && cur_ops->irq_capable)
 		del_timer_sync(&t);
 	while (!kthread_should_stop())
 		schedule_timeout_uninterruptible(1);
@@ -1078,6 +1098,7 @@ rcu_torture_init(void)
 	int firsterr = 0;
 	static struct rcu_torture_ops *torture_ops[] =
 		{ &rcu_ops, &rcu_sync_ops, &rcu_bh_ops, &rcu_bh_sync_ops,
+		  &rcu_bh_expedited_ops,
 		  &srcu_ops, &sched_ops, &sched_ops_sync, };
 
 	mutex_lock(&fullstop_mutex);
