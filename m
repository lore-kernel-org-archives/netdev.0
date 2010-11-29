From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 3/4] kthread: NUMA aware kthread_create_on_cpu()
Date: Mon, 29 Nov 2010 16:14:55 +0100
Message-ID: <1291043695.3435.980.camel@edumazet-laptop>
References: <1290972833.29196.90.camel@edumazet-laptop>
	 <20101128224024.GA12300@basil.fritz.box>
	 <1290984712.29196.100.camel@edumazet-laptop>
	 <20101128230146.GB12300@basil.fritz.box>
	 <1290987424.29196.128.camel@edumazet-laptop>
	 <20101129090510.GA15763@basil.fritz.box>
	 <1291023532.3435.29.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, Tejun Heo <tj@kernel.org>,
	Rusty Russell <rusty@rustcorp.com.au>,
	Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291023532.3435.29.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

All kthreads being created from a single helper task, they all use
memory from a single node for their kernel stack and task struct.

This patch suite creates kthread_create_on_cpu(), adding a 'cpu'
parameter to parameters already used by kthread_create().

This parameter serves in allocating memory for the new kthread on its
memory node if possible.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: David Miller <davem@davemloft.net>
Cc: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Rusty Russell <rusty@rustcorp.com.au>
Cc: Tejun Heo <tj@kernel.org>
Cc: linux-arch@vger.kernel.org
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
---
 include/linux/kthread.h |   14 ++++++++++----
 include/linux/sched.h   |    1 +
 kernel/fork.c           |    3 ++-
 kernel/kthread.c        |   32 ++++++++++++++++++++++++++------
 4 files changed, 39 insertions(+), 11 deletions(-)

diff --git a/include/linux/kthread.h b/include/linux/kthread.h
index 685ea65..ad753bc 100644
--- a/include/linux/kthread.h
+++ b/include/linux/kthread.h
@@ -4,10 +4,15 @@
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
+
 
 /**
  * kthread_run - create and wake a thread.
@@ -34,6 +39,7 @@ void *kthread_data(struct task_struct *k);
 
 int kthreadd(void *unused);
 extern struct task_struct *kthreadd_task;
+extern int tsk_fork_get_node(struct task_struct *tsk);
 
 /*
  * Simple work processor based on kthread.
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 2c79e92..e212776 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -1456,6 +1456,7 @@ struct task_struct {
 #ifdef CONFIG_NUMA
 	struct mempolicy *mempolicy;	/* Protected by alloc_lock */
 	short il_next;
+	short pref_node_fork;
 #endif
 	atomic_t fs_excl;	/* holding fs exclusive resources */
 	struct rcu_head rcu;
diff --git a/kernel/fork.c b/kernel/fork.c
index 3ebae16..4355dd4 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -66,6 +66,7 @@
 #include <linux/posix-timers.h>
 #include <linux/user-return-notifier.h>
 #include <linux/oom.h>
+#include <linux/kthread.h>
 
 #include <asm/pgtable.h>
 #include <asm/pgalloc.h>
@@ -251,7 +252,7 @@ static struct task_struct *dup_task_struct(struct task_struct *orig)
 	struct task_struct *tsk;
 	struct thread_info *ti;
 	unsigned long *stackend;
-	int node = numa_node_id();
+	int node = tsk_fork_get_node(orig);
 	int err;
 
 	prepare_to_copy(orig);
diff --git a/kernel/kthread.c b/kernel/kthread.c
index 2dc3786..4aec26d 100644
--- a/kernel/kthread.c
+++ b/kernel/kthread.c
@@ -27,6 +27,7 @@ struct kthread_create_info
 	/* Information passed to kthread() from kthreadd. */
 	int (*threadfn)(void *data);
 	void *data;
+	int cpu;
 
 	/* Result passed back to kthread_create() from kthreadd. */
 	struct task_struct *result;
@@ -98,10 +99,24 @@ static int kthread(void *_create)
 	do_exit(ret);
 }
 
+/* called from do_fork() to get node information for about to be created task */
+int tsk_fork_get_node(struct task_struct *tsk)
+{
+#ifdef CONFIG_NUMA
+	if (tsk == kthreadd_task)
+		return tsk->pref_node_fork;
+#endif
+	return numa_node_id();
+}
+
 static void create_kthread(struct kthread_create_info *create)
 {
 	int pid;
 
+#ifdef CONFIG_NUMA
+	current->pref_node_fork = (create->cpu != -1) ?
+		cpu_to_node(create->cpu) : -1;
+#endif
 	/* We want our own signal handler (we take no signals by default). */
 	pid = kernel_thread(kthread, create, CLONE_FS | CLONE_FILES | SIGCHLD);
 	if (pid < 0) {
@@ -111,15 +126,18 @@ static void create_kthread(struct kthread_create_info *create)
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
@@ -129,15 +147,17 @@ static void create_kthread(struct kthread_create_info *create)
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
@@ -164,7 +184,7 @@ struct task_struct *kthread_create(int (*threadfn)(void *data),
 	}
 	return create.result;
 }
-EXPORT_SYMBOL(kthread_create);
+EXPORT_SYMBOL(kthread_create_on_cpu);
 
 /**
  * kthread_bind - bind a just-created kthread to a cpu.
