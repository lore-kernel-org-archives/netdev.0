From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] kthread: NUMA aware kthread_create_on_cpu()
Date: Sun, 28 Nov 2010 20:33:53 +0100
Message-ID: <1290972833.29196.90.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andi Kleen <andi@firstfloor.org>, Tejun Heo <tj@kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:42342 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752513Ab0K1TeC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Nov 2010 14:34:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All kthreads being created from a single helper task, they all use
memory from a single node for their kernel stack and task struct.

This patch creates kthread_create_on_cpu(), adding a 'cpu' parameter to
parameters already used by kthread_create().

This parameter serves in allocating memory for the new kthread on its
memory node if available.

Users of this new function are : ksoftirqd, kworker, migration,
pktgend...

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Tejun Heo <tj@kernel.org>
---
 include/linux/kthread.h   |   12 ++++++++----
 include/linux/mempolicy.h |    5 +++++
 kernel/kthread.c          |   29 ++++++++++++++++++++++-------
 kernel/softirq.c          |    3 ++-
 kernel/stop_machine.c     |    4 ++--
 kernel/workqueue.c        |    5 +++--
 mm/mempolicy.c            |    8 ++++++++
 net/core/pktgen.c         |    3 ++-
 8 files changed, 52 insertions(+), 17 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 685ea65..032b6ee 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -4,10 +4,14 @@
 #include <linux/err.h>
 #include <linux/sched.h>
 
-struct task_struct *kthread_create(int (*threadfn)(void *data),
-				   void *data,
-				   const char namefmt[], ...)
-	__attribute__((format(printf, 3, 4)));
+struct task_struct *kthread_create_on_cpu(int (*threadfn)(void *data),
+					  void *data,
+					  int cpu,
+					  const char namefmt[], ...)
+	__attribute__((format(printf, 4, 5)));
+
+#define kthread_create(threadfn, data, namefmt, arg...) \
+	kthread_create_on_cpu(threadfn, data, -1, namefmt, ##arg)
 
 /**
  * kthread_run - create and wake a thread.
diff --git a/include/linux/mempolicy.h b/include/linux/mempolicy.h
index 31ac26c..5c66d66 100644
--- a/include/linux/mempolicy.h
+++ b/include/linux/mempolicy.h
@@ -200,6 +200,7 @@ struct mempolicy *mpol_shared_policy_lookup(struct shared_policy *sp,
 					    unsigned long idx);
 
 extern void numa_default_policy(void);
+extern void numa_cpubind_policy(int cpu);
 extern void numa_policy_init(void);
 extern void mpol_rebind_task(struct task_struct *tsk, const nodemask_t *new,
 				enum mpol_rebind_step step);
@@ -317,6 +318,10 @@ static inline void numa_default_policy(void)
 {
 }
 
+static inline void numa_cpubind_policy(int cpu)
+{
+}
+
 static inline void mpol_rebind_task(struct task_struct *tsk,
 				const nodemask_t *new,
 				enum mpol_rebind_step step)
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 2dc3786..3ddb9ae 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -15,6 +15,7 @@
 #include <linux/module.h>
 #include <linux/mutex.h>
 #include <linux/slab.h>
+#include <linux/mempolicy.h>
 #include <linux/freezer.h>
 #include <trace/events/sched.h>
 
@@ -27,6 +28,7 @@ struct kthread_create_info
 	/* Information passed to kthread() from kthreadd. */
 	int (*threadfn)(void *data);
 	void *data;
+	int cpu;
 
 	/* Result passed back to kthread_create() from kthreadd. */
 	struct task_struct *result;
@@ -101,7 +103,15 @@ static int kthread(void *_create)
 static void create_kthread(struct kthread_create_info *create)
 {
 	int pid;
-
+	static int last_cpu_pref = -1;
+
+	if (create->cpu != last_cpu_pref) {
+		if (create->cpu == -1)
+			numa_default_policy();
+		else
+			numa_cpubind_policy(create->cpu);
+		last_cpu_pref = create->cpu;
+	}
 	/* We want our own signal handler (we take no signals by default). */
 	pid = kernel_thread(kthread, create, CLONE_FS | CLONE_FILES | SIGCHLD);
 	if (pid < 0) {
@@ -111,15 +121,18 @@ static void create_kthread(struct kthread_create_info *create)
 }
 
 /**
- * kthread_create - create a kthread.
+ * kthread_create_on_cpu - create a kthread.
  * @threadfn: the function to run until signal_pending(current).
  * @data: data ptr for @threadfn.
+ * @cpu: cpu number.
  * @namefmt: printf-style name for the thread.
  *
  * Description: This helper function creates and names a kernel
  * thread.  The thread will be stopped: use wake_up_process() to start
  * it.  See also kthread_run().
  *
+ * If thread is going to be bound on a particular cpu, give its number
+ * in @cpu, to get NUMA affinity for kthread stack, or else give -1.
  * When woken, the thread will run @threadfn() with @data as its
  * argument. @threadfn() can either call do_exit() directly if it is a
  * standalone thread for which noone will call kthread_stop(), or
@@ -129,15 +142,17 @@ static void create_kthread(struct kthread_create_info *create)
  *
  * Returns a task_struct or ERR_PTR(-ENOMEM).
  */
-struct task_struct *kthread_create(int (*threadfn)(void *data),
-				   void *data,
-				   const char namefmt[],
-				   ...)
+struct task_struct *kthread_create_on_cpu(int (*threadfn)(void *data),
+					  void *data,
+					  int cpu,
+					  const char namefmt[],
+					  ...)
 {
 	struct kthread_create_info create;
 
 	create.threadfn = threadfn;
 	create.data = data;
+	create.cpu = cpu;
 	init_completion(&create.done);
 
 	spin_lock(&kthread_create_lock);
@@ -164,7 +179,7 @@ struct task_struct *kthread_create(int (*threadfn)(void *data),
 	}
 	return create.result;
 }
-EXPORT_SYMBOL(kthread_create);
+EXPORT_SYMBOL(kthread_create_on_cpu);
 
 /**
  * kthread_bind - bind a just-created kthread to a cpu.
diff --git a/kernel/softirq.c b/kernel/softirq.c
index 18f4be0..b2b7044 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -831,7 +831,8 @@ static int __cpuinit cpu_callback(struct notifier_block *nfb,
 	switch (action) {
 	case CPU_UP_PREPARE:
 	case CPU_UP_PREPARE_FROZEN:
-		p = kthread_create(run_ksoftirqd, hcpu, "ksoftirqd/%d", hotcpu);
+		p = kthread_create_on_cpu(run_ksoftirqd, hcpu, hotcpu,
+					  "ksoftirqd/%d", hotcpu);
 		if (IS_ERR(p)) {
 			printk("ksoftirqd for %i failed\n", hotcpu);
 			return notifier_from_errno(PTR_ERR(p));
diff --git a/kernel/stop_machine.c b/kernel/stop_machine.c
index 2df820b..7c0f287 100644
--- a/kernel/stop_machine.c
+++ b/kernel/stop_machine.c
@@ -301,8 +301,8 @@ static int __cpuinit cpu_stop_cpu_callback(struct notifier_block *nfb,
 	case CPU_UP_PREPARE:
 		BUG_ON(stopper->thread || stopper->enabled ||
 		       !list_empty(&stopper->works));
-		p = kthread_create(cpu_stopper_thread, stopper, "migration/%d",
-				   cpu);
+		p = kthread_create_on_cpu(cpu_stopper_thread, stopper, cpu,
+					  "migration/%d", cpu);
 		if (IS_ERR(p))
 			return notifier_from_errno(PTR_ERR(p));
 		get_task_struct(p);
diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 90db1bd..f054fb9 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -1318,8 +1318,9 @@ static struct worker *create_worker(struct global_cwq *gcwq, bool bind)
 	worker->id = id;
 
 	if (!on_unbound_cpu)
-		worker->task = kthread_create(worker_thread, worker,
-					      "kworker/%u:%d", gcwq->cpu, id);
+		worker->task = kthread_create_on_cpu(worker_thread, worker,
+					gcwq->cpu,
+					"kworker/%u:%d", gcwq->cpu, id);
 	else
 		worker->task = kthread_create(worker_thread, worker,
 					      "kworker/u:%d", id);
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 4a57f13..f959edc 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2278,6 +2278,14 @@ void numa_default_policy(void)
 	do_set_mempolicy(MPOL_DEFAULT, 0, NULL);
 }
 
+void numa_cpubind_policy(int cpu)
+{
+	nodemask_t mask;
+
+	init_nodemask_of_node(&mask, cpu_to_node(cpu));
+	do_set_mempolicy(MPOL_BIND, 0, &mask);
+}
+
 /*
  * Parse and format mempolicy from/to strings
  */
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 33bc382..c921fe9 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -3785,7 +3785,8 @@ static int __init pktgen_create_thread(int cpu)
 	list_add_tail(&t->th_list, &pktgen_threads);
 	init_completion(&t->start_done);
 
-	p = kthread_create(pktgen_thread_worker, t, "kpktgend_%d", cpu);
+	p = kthread_create_on_cpu(pktgen_thread_worker, t, cpu,
+				  "kpktgend_%d", cpu);
 	if (IS_ERR(p)) {
 		pr_err("kernel_thread() failed for cpu %d\n", t->cpu);
 		list_del(&t->th_list);


