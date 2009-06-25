From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: [PATCH -tip 1/3] synchronize_sched_expedited() primitive
Date: Thu, 25 Jun 2009 09:08:16 -0700
Message-ID: <39466.8976929553$1245946236@news.gmane.org>
References: <20090625160706.GA9467@linux.vnet.ibm.com>
Cc: mingo@elte.hu, akpm@linux-foundation.org,
	torvalds@linux-foundation.org, davem@davemloft.net,
	dada1@cosmosbay.com, zbr@ioremap.net, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1759272AbZFYQIr@vger.kernel.org>
In-Reply-To: <20090625160706.GA9467@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adds the synchronize_sched_expedited() primitive that implements
the "big hammer" expedited RCU grace periods.  This primitive is placed
in kernel/sched.c rather than kernel/rcupdate.c due to its need to
interact closely with the migration_thread() kthread.  The idea is to
wake up this kthread with req->task set to NULL, in response to which
the kthread reports the quiescent state resulting from the kthread
having been scheduled.

Because this patch needs to fallback to the slow versions of the
primitives in response to some races with CPU onlining and offlining,
a new synchronize_rcu_bh() primitive is added as well.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---
 include/linux/rcupdate.h   |   25 +++++----
 include/linux/rcupreempt.h |   10 ++++
 include/linux/rcutree.h    |   12 ++++-
 kernel/rcupdate.c          |   25 +++++++++
 kernel/sched.c             |  129 +++++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 186 insertions(+), 15 deletions(-)

diff --git a/include/linux/rcupdate.h b/include/linux/rcupdate.h
index 0cdfdb6..3c89d6a 100644
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
 
 #if defined(CONFIG_TREE_RCU)
@@ -257,15 +269,4 @@ extern void call_rcu(struct rcu_head *head,
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
index 5a51538..d4dfd24 100644
--- a/include/linux/rcutree.h
+++ b/include/linux/rcutree.h
@@ -286,8 +286,14 @@ static inline void __rcu_read_unlock_bh(void)
 
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
@@ -297,6 +303,10 @@ extern void rcu_restart_cpu(int cpu);
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
diff --git a/kernel/sched.c b/kernel/sched.c
index 7c9098d..9ae80be 100644
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -7024,6 +7024,11 @@ fail:
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
@@ -7031,6 +7036,7 @@ fail:
  */
 static int migration_thread(void *data)
 {
+	int badcpu;
 	int cpu = (long)data;
 	struct rq *rq;
 
@@ -7065,8 +7071,17 @@ static int migration_thread(void *data)
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
@@ -10554,3 +10569,113 @@ struct cgroup_subsys cpuacct_subsys = {
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
-- 
1.5.2.5
