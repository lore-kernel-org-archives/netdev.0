From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 7/8] percpu: add __percpu sparse annotations to hw_breakpoint
Date: Tue, 26 Jan 2010 00:22:14 +0900
Message-ID: <1264432935-10453-8-git-send-email-tj@kernel.org>
References: <1264432935-10453-1-git-send-email-tj@kernel.org>
Cc: Tejun Heo <tj@kernel.org>
To: linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:42986 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753848Ab0AYPTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 10:19:11 -0500
In-Reply-To: <1264432935-10453-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add __percpu sparse annotations to hw_breakpoint.

These annotations are to make sparse consider percpu variables to be
in a different address space and warn if accessed without going
through percpu accessors.  This patch doesn't affect normal builds.

per_cpu(nr_task_bp_pinned, cpu) is replaced with
&per_cpu(nr_task_bp_pinned[0], cpu).  This is the same to the compiler
but allows per_cpu() macro to correctly drop __percpu designation for
the returned pointer.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
---
 include/linux/hw_breakpoint.h           |    8 ++++----
 kernel/hw_breakpoint.c                  |   14 +++++++-------
 samples/hw_breakpoint/data_breakpoint.c |    6 +++---
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/include/linux/hw_breakpoint.h b/include/linux/hw_breakpoint.h
index 41235c9..f462d3d 100644
--- a/include/linux/hw_breakpoint.h
+++ b/include/linux/hw_breakpoint.h
@@ -66,14 +66,14 @@ register_wide_hw_breakpoint_cpu(struct perf_event_attr *attr,
 				perf_overflow_handler_t	triggered,
 				int cpu);
 
-extern struct perf_event **
+extern struct perf_event * __percpu *
 register_wide_hw_breakpoint(struct perf_event_attr *attr,
 			    perf_overflow_handler_t triggered);
 
 extern int register_perf_hw_breakpoint(struct perf_event *bp);
 extern int __register_perf_hw_breakpoint(struct perf_event *bp);
 extern void unregister_hw_breakpoint(struct perf_event *bp);
-extern void unregister_wide_hw_breakpoint(struct perf_event **cpu_events);
+extern void unregister_wide_hw_breakpoint(struct perf_event * __percpu *cpu_events);
 
 extern int reserve_bp_slot(struct perf_event *bp);
 extern void release_bp_slot(struct perf_event *bp);
@@ -98,7 +98,7 @@ static inline struct perf_event *
 register_wide_hw_breakpoint_cpu(struct perf_event_attr *attr,
 				perf_overflow_handler_t	 triggered,
 				int cpu)		{ return NULL; }
-static inline struct perf_event **
+static inline struct perf_event * __percpu *
 register_wide_hw_breakpoint(struct perf_event_attr *attr,
 			    perf_overflow_handler_t triggered)	{ return NULL; }
 static inline int
@@ -107,7 +107,7 @@ static inline int
 __register_perf_hw_breakpoint(struct perf_event *bp) 	{ return -ENOSYS; }
 static inline void unregister_hw_breakpoint(struct perf_event *bp)	{ }
 static inline void
-unregister_wide_hw_breakpoint(struct perf_event **cpu_events)		{ }
+unregister_wide_hw_breakpoint(struct perf_event * __percpu *cpu_events)	{ }
 static inline int
 reserve_bp_slot(struct perf_event *bp)			{return -ENOSYS; }
 static inline void release_bp_slot(struct perf_event *bp) 		{ }
diff --git a/kernel/hw_breakpoint.c b/kernel/hw_breakpoint.c
index 50dbd59..11dae6d 100644
--- a/kernel/hw_breakpoint.c
+++ b/kernel/hw_breakpoint.c
@@ -74,7 +74,7 @@ static DEFINE_MUTEX(nr_bp_mutex);
 static unsigned int max_task_bp_pinned(int cpu)
 {
 	int i;
-	unsigned int *tsk_pinned = per_cpu(nr_task_bp_pinned, cpu);
+	unsigned int *tsk_pinned = &per_cpu(nr_task_bp_pinned[0], cpu);
 
 	for (i = HBP_NUM -1; i >= 0; i--) {
 		if (tsk_pinned[i] > 0)
@@ -163,7 +163,7 @@ static void toggle_bp_task_slot(struct task_struct *tsk, int cpu, bool enable)
 
 	count = task_bp_pinned(tsk);
 
-	tsk_pinned = per_cpu(nr_task_bp_pinned, cpu);
+	tsk_pinned = &per_cpu(nr_task_bp_pinned[0], cpu);
 	if (enable) {
 		tsk_pinned[count]++;
 		if (count > 0)
@@ -377,17 +377,17 @@ EXPORT_SYMBOL_GPL(unregister_hw_breakpoint);
  *
  * @return a set of per_cpu pointers to perf events
  */
-struct perf_event **
+struct perf_event * __percpu *
 register_wide_hw_breakpoint(struct perf_event_attr *attr,
 			    perf_overflow_handler_t triggered)
 {
-	struct perf_event **cpu_events, **pevent, *bp;
+	struct perf_event * __percpu *cpu_events, **pevent, *bp;
 	long err;
 	int cpu;
 
 	cpu_events = alloc_percpu(typeof(*cpu_events));
 	if (!cpu_events)
-		return ERR_PTR(-ENOMEM);
+		return (void __percpu __force *)ERR_PTR(-ENOMEM);
 
 	get_online_cpus();
 	for_each_online_cpu(cpu) {
@@ -415,7 +415,7 @@ fail:
 	put_online_cpus();
 
 	free_percpu(cpu_events);
-	return ERR_PTR(err);
+	return (void __percpu __force *)ERR_PTR(err);
 }
 EXPORT_SYMBOL_GPL(register_wide_hw_breakpoint);
 
@@ -423,7 +423,7 @@ EXPORT_SYMBOL_GPL(register_wide_hw_breakpoint);
  * unregister_wide_hw_breakpoint - unregister a wide breakpoint in the kernel
  * @cpu_events: the per cpu set of events to unregister
  */
-void unregister_wide_hw_breakpoint(struct perf_event **cpu_events)
+void unregister_wide_hw_breakpoint(struct perf_event * __percpu *cpu_events)
 {
 	int cpu;
 	struct perf_event **pevent;
diff --git a/samples/hw_breakpoint/data_breakpoint.c b/samples/hw_breakpoint/data_breakpoint.c
index c69cbe9..bd0f337 100644
--- a/samples/hw_breakpoint/data_breakpoint.c
+++ b/samples/hw_breakpoint/data_breakpoint.c
@@ -34,7 +34,7 @@
 #include <linux/perf_event.h>
 #include <linux/hw_breakpoint.h>
 
-struct perf_event **sample_hbp;
+struct perf_event * __percpu *sample_hbp;
 
 static char ksym_name[KSYM_NAME_LEN] = "pid_max";
 module_param_string(ksym, ksym_name, KSYM_NAME_LEN, S_IRUGO);
@@ -61,8 +61,8 @@ static int __init hw_break_module_init(void)
 	attr.bp_type = HW_BREAKPOINT_W | HW_BREAKPOINT_R;
 
 	sample_hbp = register_wide_hw_breakpoint(&attr, sample_hbp_handler);
-	if (IS_ERR(sample_hbp)) {
-		ret = PTR_ERR(sample_hbp);
+	if (IS_ERR((void __force *)sample_hbp)) {
+		ret = PTR_ERR((void __force *)sample_hbp);
 		goto fail;
 	}
 
-- 
1.6.4.2

