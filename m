From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH RFC] v8 expedited "big hammer" RCU grace periods
Date: Sat, 20 Jun 2009 14:28:58 -0700
Message-ID: <20090620212858.GA29272@linux.vnet.ibm.com>
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

Eighth cut of "big hammer" expedited RCU grace periods.  This leverages
the existing per-CPU migration kthreads, as suggested by Ingo.  These
are awakened in a loop, and waited for in a second loop.  Not fully
scalable, but removing the extra hop through smp_call_function
reduces latency on systems with moderate numbers of CPUs.  The
synchronize_rcu_expedited() and and synchronize_bh_expedited() primitives
invoke synchronize_sched_expedited(), except for CONFIG_PREEMPT_RCU,
where they instead invoke synchronize_rcu() and synchronize_rcu_bh(),
respectively.  This will be fixed in the future, after preemptable RCU
is folded into the rcutree implementation.

As before, this does nothing to expedite callbacks already registered
with call_rcu() or call_rcu_bh(), but there is no need to.

Passes many hours of rcutorture testing in parallel with a script
that randomly offlines and onlines CPUs in a number of configurations.
Grace periods take about 40 microseconds on an 8-CPU Power machine, which
I believe is good enough from a performance viewpoint for the near future.
There was some slowdown from the prior version, which was unfortunately
necessary to fix some bugs.

This is not yet for inclusion, but is quite close.  Assuming no further
bugs, the next submission will split the mechanism from the torture
testing.

Shortcomings:

o	Does not address preemptable RCU (though synchronize_sched_expedited()
	is in fact expedited in this configuration).

o	Probably not helpful on systems with thousands of CPUs, but likely
	quite helpful even on systems with a few hundreds of CPUs.

Changes since v7:

o	Fixed several embarrassing bugs turned up by tests on multiple
	configurations.

Changes since v6:

o	Moved to using the migration threads, as suggested by Ingo.

Changes since v5:

o	Fixed several embarrassing locking bugs, including those
	noted by Ingo and Lai.

o	Added a missing set of braces.

o	Cut out the extra kthread, so that synchronize_sched_expedited()
	directly calls smp_call_function() and waits for the quiescent
	states.

o	Removed some debug code, but promoted one to production.

o	Fix a compiler warning.

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

 include/linux/rcuclassic.h |   15 +++
 include/linux/rcupdate.h   |   25 ++---
 include/linux/rcupreempt.h |   10 ++
 include/linux/rcutree.h    |   12 ++
 kernel/rcupdate.c          |   25 +++++
 kernel/rcutorture.c        |  202 ++++++++++++++++++++++++---------------------
 kernel/sched.c             |  129 ++++++++++++++++++++++++++++
 7 files changed, 310 insertions(+), 108 deletions(-)

diff --git a/include/linux/rcuclassic.h b/include/linux/rcuclassic.h
index bfd92e1..b4b4fe1 100644
--- a/include/linux/rcuclassic.h
+++ b/include/linux/rcuclassic.h
@@ -158,14 +158,27 @@ extern struct lockdep_map rcu_lock_map;
 
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
+}
+
 #define rcu_enter_nohz()	do { } while (0)
 #define rcu_exit_nohz()		do { } while (0)
 
diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 15fbb3c..688e645 100644
--- a/include/linux/rcupdate.h
+++ b/include/linux/rcupdate.h
@@ -51,7 +51,19 @@ struct rcu_head {
 	void (*func)(struct rcu_head *head);
 };
 
-/* Internal to kernel, but needed by rcupreempt.h. */
+/* Exported common interfaces */
+extern void synchronize_rcu(void);
+extern void synchronize_rcu_bh(void);
+extern void rcu_barrier(void);
+extern void rcu_barrier_bh(void);
+extern void rcu_barrier_sched(void);
+extern void synchronize_sched_expedited(void);
+extern int sched_expedited_torture_stats(char *page);
+
+/* Internal to kernel */
+extern void rcu_init(void);
+extern void rcu_scheduler_starting(void);
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
index fce5227..f164ac9 100644
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
+	synchronize_rcu_bh();  /* Placeholder for new rcupreempt impl. */
+}
+
 extern void __rcu_init(void);
 extern void rcu_init_sched(void);
 extern void rcu_check_callbacks(int cpu, int user);
diff --git a/include/linux/rcutree.h b/include/linux/rcutree.h
index 58b2aa5..41c23cb 100644
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
@@ -290,6 +296,10 @@ extern void rcu_restart_cpu(int cpu);
 extern long rcu_batches_completed(void);
 extern long rcu_batches_completed_bh(void);
 
+static inline void rcu_init_sched(void)
+{
+}
+
 #ifdef CONFIG_NO_HZ
 void rcu_enter_nohz(void);
 void rcu_exit_nohz(void);
diff --git a/kernel/rcupdate.c b/kernel/rcupdate.c
index a967c9f..eae29c2 100644
--- a/kernel/rcupdate.c
+++ b/kernel/rcupdate.c
@@ -98,6 +98,30 @@ void synchronize_rcu(void)
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
@@ -129,6 +153,7 @@ static void rcu_barrier_func(void *type)
 static inline void wait_migrated_callbacks(void)
 {
 	wait_event(rcu_migrate_wq, !atomic_read(&rcu_migrate_type_count));
+	smp_mb(); /* In case we didn't sleep. */
 }
 
 /*
diff --git a/kernel/rcutorture.c b/kernel/rcutorture.c
index 9b4a975..b33db53 100644
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
@@ -574,32 +574,49 @@ static void sched_torture_synchronize(void)
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
+extern int rcu_expedited_torture_stats(char *page);
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
+	.stats		= rcu_expedited_torture_stats,
+	.irq_capable	= 1,
+	.name		= "sched_expedited"
 };
 
 /*
@@ -635,7 +652,7 @@ rcu_torture_writer(void *arg)
 				i = RCU_TORTURE_PIPE_LEN;
 			atomic_inc(&rcu_torture_wcount[i]);
 			old_rp->rtort_pipe_count++;
-			cur_ops->deferredfree(old_rp);
+			cur_ops->deferred_free(old_rp);
 		}
 		rcu_torture_current_version++;
 		oldbatch = cur_ops->completed();
@@ -700,7 +717,7 @@ static void rcu_torture_timer(unsigned long unused)
 	if (p->rtort_mbtest == 0)
 		atomic_inc(&n_rcu_torture_mberror);
 	spin_lock(&rand_lock);
-	cur_ops->readdelay(&rand);
+	cur_ops->read_delay(&rand);
 	n_rcu_torture_timers++;
 	spin_unlock(&rand_lock);
 	preempt_disable();
@@ -738,11 +755,11 @@ rcu_torture_reader(void *arg)
 
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
@@ -757,7 +774,7 @@ rcu_torture_reader(void *arg)
 		}
 		if (p->rtort_mbtest == 0)
 			atomic_inc(&n_rcu_torture_mberror);
-		cur_ops->readdelay(&rand);
+		cur_ops->read_delay(&rand);
 		preempt_disable();
 		pipe_count = p->rtort_pipe_count;
 		if (pipe_count > RCU_TORTURE_PIPE_LEN) {
@@ -778,7 +795,7 @@ rcu_torture_reader(void *arg)
 	} while (!kthread_should_stop() && fullstop == FULLSTOP_DONTSTOP);
 	VERBOSE_PRINTK_STRING("rcu_torture_reader task stopping");
 	rcutorture_shutdown_absorb("rcu_torture_reader");
-	if (irqreader && cur_ops->irqcapable)
+	if (irqreader && cur_ops->irq_capable)
 		del_timer_sync(&t);
 	while (!kthread_should_stop())
 		schedule_timeout_uninterruptible(1);
@@ -1078,6 +1095,7 @@ rcu_torture_init(void)
 	int firsterr = 0;
 	static struct rcu_torture_ops *torture_ops[] =
 		{ &rcu_ops, &rcu_sync_ops, &rcu_bh_ops, &rcu_bh_sync_ops,
+		  &sched_expedited_ops,
 		  &srcu_ops, &sched_ops, &sched_ops_sync, };
 
 	mutex_lock(&fullstop_mutex);
diff --git a/kernel/sched.c b/kernel/sched.c
index 26efa47..144ab97 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -6730,6 +6730,11 @@ fail:
 	return ret;
 }
 
+#define RCU_MIGRATION_IDLE	0
+#define RCU_MIGRATION_NEED_QS	1
+#define RCU_MIGRATION_GOT_QS	2
+#define RCU_MIGRATION_MUST_SYNC	3
+
 /*
  * migration_thread - this is a highprio system thread that performs
  * thread migration by bumping thread off CPU then 'pushing' onto
@@ -6737,6 +6742,7 @@ fail:
  */
 static int migration_thread(void *data)
 {
+	int badcpu;
 	int cpu = (long)data;
 	struct rq *rq;
 
@@ -6771,8 +6777,17 @@ static int migration_thread(void *data)
 		req = list_entry(head->next, struct migration_req, list);
 		list_del_init(head->next);
 
-		spin_unlock(&rq->lock);
-		__migrate_task(req->task, cpu, req->dest_cpu);
+		if (req->task != NULL) {
+			spin_unlock(&rq->lock);
+			__migrate_task(req->task, cpu, req->dest_cpu);
+		} else if (likely(cpu == (badcpu = smp_processor_id()))) {
+			req->dest_cpu = RCU_MIGRATION_GOT_QS;
+			spin_unlock(&rq->lock);
+		} else {
+			req->dest_cpu = RCU_MIGRATION_MUST_SYNC;
+			spin_unlock(&rq->lock);
+			WARN_ONCE(1, "migration_thread() on CPU %d, expected %d\n", badcpu, cpu);
+		}
 		local_irq_enable();
 
 		complete(&req->done);
@@ -10239,3 +10254,113 @@ struct cgroup_subsys cpuacct_subsys = {
 	.subsys_id = cpuacct_subsys_id,
 };
 #endif	/* CONFIG_CGROUP_CPUACCT */
+
+#ifndef CONFIG_SMP
+
+int rcu_expedited_torture_stats(char *page)
+{
+	return 0;
+}
+EXPORT_SYMBOL_GPL(rcu_expedited_torture_stats);
+
+void synchronize_sched_expedited(void)
+{
+}
+EXPORT_SYMBOL_GPL(synchronize_sched_expedited);
+
+#else /* #ifndef CONFIG_SMP */
+
+static DEFINE_PER_CPU(struct migration_req, rcu_migration_req);
+static DEFINE_MUTEX(rcu_sched_expedited_mutex);
+
+#define RCU_EXPEDITED_STATE_POST -2
+#define RCU_EXPEDITED_STATE_IDLE -1
+
+static int rcu_expedited_state = RCU_EXPEDITED_STATE_IDLE;
+
+int rcu_expedited_torture_stats(char *page)
+{
+	int cnt = 0;
+	int cpu;
+
+	cnt += sprintf(&page[cnt], "state: %d /", rcu_expedited_state);
+	for_each_online_cpu(cpu) {
+		 cnt += sprintf(&page[cnt], " %d:%d",
+				cpu, per_cpu(rcu_migration_req, cpu).dest_cpu);
+	}
+	cnt += sprintf(&page[cnt], "\n");
+	return cnt;
+}
+EXPORT_SYMBOL_GPL(rcu_expedited_torture_stats);
+
+static long synchronize_sched_expedited_count;
+
+/*
+ * Wait for an rcu-sched grace period to elapse, but use "big hammer"
+ * approach to force grace period to end quickly.  This consumes
+ * significant time on all CPUs, and is thus not recommended for
+ * any sort of common-case code.
+ *
+ * Note that it is illegal to call this function while holding any
+ * lock that is acquired by a CPU-hotplug notifier.  Failing to
+ * observe this restriction will result in deadlock.
+ */
+void synchronize_sched_expedited(void)
+{
+	int cpu;
+	unsigned long flags;
+	bool need_full_sync = 0;
+	struct rq *rq;
+	struct migration_req *req;
+	long snap;
+	int trycount = 0;
+
+	smp_mb();  /* ensure prior mod happens before capturing snap. */
+	snap = ACCESS_ONCE(synchronize_sched_expedited_count) + 1;
+	get_online_cpus();
+	while (!mutex_trylock(&rcu_sched_expedited_mutex)) {
+		put_online_cpus();
+		if (trycount++ < 10)
+			udelay(trycount * num_online_cpus());
+		else {
+			synchronize_sched();
+			return;
+		}
+		if (ACCESS_ONCE(synchronize_sched_expedited_count) - snap > 0) {
+			smp_mb(); /* ensure test happens before caller kfree */
+			return;
+		}
+		get_online_cpus();
+	}
+	rcu_expedited_state = RCU_EXPEDITED_STATE_POST;
+	for_each_online_cpu(cpu) {
+		rq = cpu_rq(cpu);
+		req = &per_cpu(rcu_migration_req, cpu);
+		init_completion(&req->done);
+		req->task = NULL;
+		req->dest_cpu = RCU_MIGRATION_NEED_QS;
+		spin_lock_irqsave(&rq->lock, flags);
+		list_add(&req->list, &rq->migration_queue);
+		spin_unlock_irqrestore(&rq->lock, flags);
+		wake_up_process(rq->migration_thread);
+	}
+	for_each_online_cpu(cpu) {
+		rcu_expedited_state = cpu;
+		req = &per_cpu(rcu_migration_req, cpu);
+		rq = cpu_rq(cpu);
+		wait_for_completion(&req->done);
+		spin_lock_irqsave(&rq->lock, flags);
+		if (unlikely(req->dest_cpu == RCU_MIGRATION_MUST_SYNC))
+			need_full_sync = 1;
+		req->dest_cpu = RCU_MIGRATION_IDLE;
+		spin_unlock_irqrestore(&rq->lock, flags);
+	}
+	rcu_expedited_state = RCU_EXPEDITED_STATE_IDLE;
+	mutex_unlock(&rcu_sched_expedited_mutex);
+	put_online_cpus();
+	if (need_full_sync)
+		synchronize_sched();
+}
+EXPORT_SYMBOL_GPL(synchronize_sched_expedited);
+
+#endif /* #else #ifndef CONFIG_SMP */
