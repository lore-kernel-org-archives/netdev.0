From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 6/8] percpu: add __percpu sparse annotations to trace
Date: Tue, 26 Jan 2010 00:22:13 +0900
Message-ID: <1264432935-10453-7-git-send-email-tj@kernel.org>
References: <1264432935-10453-1-git-send-email-tj@kernel.org>
Cc: Tejun Heo <tj@kernel.org>, Steven Rostedt <rostedt@goodmis.org>
To: linux-kernel@vger.kernel.org, axboe@kernel.dk,
	rusty@rustcorp.com.au, akpm@linux-foundation.org,
	ebiederm@xmission.com, tytso@mit.edu, Trond.Myklebust@netapp.com,
	aelder@sgi.com, hch@
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:42976 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753860Ab0AYPTK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Jan 2010 10:19:10 -0500
In-Reply-To: <1264432935-10453-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add __percpu sparse annotations to trace.

These annotations are to make sparse consider percpu variables to be
in a different address space and warn if accessed without going
through percpu accessors.  This patch doesn't affect normal builds.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Frederic Weisbecker <fweisbec@gmail.com>
Cc: Ingo Molnar <mingo@redhat.com>
---
 include/linux/ftrace_event.h         |    4 ++--
 include/trace/ftrace.h               |    4 ++--
 kernel/trace/trace_event_profile.c   |   16 ++++++++--------
 kernel/trace/trace_functions_graph.c |    2 +-
 kernel/trace/trace_kprobe.c          |    4 ++--
 kernel/trace/trace_ksym.c            |   10 +++++-----
 kernel/trace/trace_syscalls.c        |    4 ++--
 7 files changed, 22 insertions(+), 22 deletions(-)

diff --git a/include/linux/ftrace_event.h b/include/linux/ftrace_event.h
index 2233c98..72fccdd 100644
--- a/include/linux/ftrace_event.h
+++ b/include/linux/ftrace_event.h
@@ -138,8 +138,8 @@ struct ftrace_event_call {
 
 #define FTRACE_MAX_PROFILE_SIZE	2048
 
-extern char *perf_trace_buf;
-extern char *perf_trace_buf_nmi;
+extern char __percpu *perf_trace_buf;
+extern char __percpu *perf_trace_buf_nmi;
 
 #define MAX_FILTER_PRED		32
 #define MAX_FILTER_STR_VAL	256	/* Should handle KSYM_SYMBOL_LEN */
diff --git a/include/trace/ftrace.h b/include/trace/ftrace.h
index c6fe03e..210d421 100644
--- a/include/trace/ftrace.h
+++ b/include/trace/ftrace.h
@@ -773,7 +773,7 @@ __attribute__((section("_ftrace_events"))) event_##call = {		\
  *	struct ftrace_event_call *event_call = &event_<call>;
  *	extern void perf_tp_event(int, u64, u64, void *, int);
  *	struct ftrace_raw_##call *entry;
- *	struct perf_trace_buf *trace_buf;
+ *	struct perf_trace_buf __percpu *trace_buf;
  *	u64 __addr = 0, __count = 1;
  *	unsigned long irq_flags;
  *	struct trace_entry *ent;
@@ -859,7 +859,7 @@ ftrace_profile_templ_##call(struct ftrace_event_call *event_call,	\
 	struct trace_entry *ent;					\
 	int __entry_size;						\
 	int __data_size;						\
-	char *trace_buf;						\
+	char __percpu *trace_buf;					\
 	char *raw_data;							\
 	int __cpu;							\
 	int rctx;							\
diff --git a/kernel/trace/trace_event_profile.c b/kernel/trace/trace_event_profile.c
index 9e25573..4b16312 100644
--- a/kernel/trace/trace_event_profile.c
+++ b/kernel/trace/trace_event_profile.c
@@ -9,11 +9,11 @@
 #include "trace.h"
 
 
-char *perf_trace_buf;
-EXPORT_SYMBOL_GPL(perf_trace_buf);
+char __percpu *perf_trace_buf;
+EXPORT_PER_CPU_SYMBOL_GPL(perf_trace_buf);
 
-char *perf_trace_buf_nmi;
-EXPORT_SYMBOL_GPL(perf_trace_buf_nmi);
+char __percpu *perf_trace_buf_nmi;
+EXPORT_PER_CPU_SYMBOL_GPL(perf_trace_buf_nmi);
 
 typedef typeof(char [FTRACE_MAX_PROFILE_SIZE]) perf_trace_t ;
 
@@ -22,20 +22,20 @@ static int	total_profile_count;
 
 static int ftrace_profile_enable_event(struct ftrace_event_call *event)
 {
-	char *buf;
+	char __percpu *buf;
 	int ret = -ENOMEM;
 
 	if (event->profile_count++ > 0)
 		return 0;
 
 	if (!total_profile_count) {
-		buf = (char *)alloc_percpu(perf_trace_t);
+		buf = (char __percpu *)alloc_percpu(perf_trace_t);
 		if (!buf)
 			goto fail_buf;
 
 		rcu_assign_pointer(perf_trace_buf, buf);
 
-		buf = (char *)alloc_percpu(perf_trace_t);
+		buf = (char __percpu *)alloc_percpu(perf_trace_t);
 		if (!buf)
 			goto fail_buf_nmi;
 
@@ -81,7 +81,7 @@ int ftrace_profile_enable(int event_id)
 
 static void ftrace_profile_disable_event(struct ftrace_event_call *event)
 {
-	char *buf, *nmi_buf;
+	char __percpu *buf, *nmi_buf;
 
 	if (--event->profile_count > 0)
 		return;
diff --git a/kernel/trace/trace_functions_graph.c b/kernel/trace/trace_functions_graph.c
index 9d976f3..2144178 100644
--- a/kernel/trace/trace_functions_graph.c
+++ b/kernel/trace/trace_functions_graph.c
@@ -21,7 +21,7 @@ struct fgraph_cpu_data {
 };
 
 struct fgraph_data {
-	struct fgraph_cpu_data		*cpu_data;
+	struct fgraph_cpu_data __percpu *cpu_data;
 
 	/* Place to preserve last processed entry. */
 	struct ftrace_graph_ent_entry	ent;
diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
index 6ea90c0..4567950 100644
--- a/kernel/trace/trace_kprobe.c
+++ b/kernel/trace/trace_kprobe.c
@@ -1262,7 +1262,7 @@ static __kprobes int kprobe_profile_func(struct kprobe *kp,
 	struct trace_entry *ent;
 	int size, __size, i, pc, __cpu;
 	unsigned long irq_flags;
-	char *trace_buf;
+	char __percpu *trace_buf;
 	char *raw_data;
 	int rctx;
 
@@ -1327,7 +1327,7 @@ static __kprobes int kretprobe_profile_func(struct kretprobe_instance *ri,
 	struct trace_entry *ent;
 	int size, __size, i, pc, __cpu;
 	unsigned long irq_flags;
-	char *trace_buf;
+	char __percpu *trace_buf;
 	char *raw_data;
 	int rctx;
 
diff --git a/kernel/trace/trace_ksym.c b/kernel/trace/trace_ksym.c
index 94103cd..7e5c483 100644
--- a/kernel/trace/trace_ksym.c
+++ b/kernel/trace/trace_ksym.c
@@ -42,7 +42,7 @@
 #define KSYM_TRACER_OP_LEN 3 /* rw- */
 
 struct trace_ksym {
-	struct perf_event	**ksym_hbp;
+	struct perf_event	* __percpu *ksym_hbp;
 	struct perf_event_attr	attr;
 #ifdef CONFIG_PROFILE_KSYM_TRACER
 	atomic64_t		counter;
@@ -200,8 +200,8 @@ int process_new_ksym_entry(char *ksymname, int op, unsigned long addr)
 	entry->ksym_hbp = register_wide_hw_breakpoint(&entry->attr,
 					ksym_hbp_handler);
 
-	if (IS_ERR(entry->ksym_hbp)) {
-		ret = PTR_ERR(entry->ksym_hbp);
+	if (IS_ERR((void __force *)entry->ksym_hbp)) {
+		ret = PTR_ERR((void __force *)entry->ksym_hbp);
 		printk(KERN_INFO "ksym_tracer request failed. Try again"
 					" later!!\n");
 		goto err;
@@ -331,8 +331,8 @@ static ssize_t ksym_trace_filter_write(struct file *file,
 			entry->ksym_hbp =
 				register_wide_hw_breakpoint(&entry->attr,
 					ksym_hbp_handler);
-			if (IS_ERR(entry->ksym_hbp))
-				ret = PTR_ERR(entry->ksym_hbp);
+			if (IS_ERR((void __force *)entry->ksym_hbp))
+				ret = PTR_ERR((void __force *)entry->ksym_hbp);
 			else
 				goto out_unlock;
 		}
diff --git a/kernel/trace/trace_syscalls.c b/kernel/trace/trace_syscalls.c
index 75289f3..9f7de51 100644
--- a/kernel/trace/trace_syscalls.c
+++ b/kernel/trace/trace_syscalls.c
@@ -433,7 +433,7 @@ static void prof_syscall_enter(struct pt_regs *regs, long id)
 	struct syscall_metadata *sys_data;
 	struct syscall_trace_enter *rec;
 	unsigned long flags;
-	char *trace_buf;
+	char __percpu *trace_buf;
 	char *raw_data;
 	int syscall_nr;
 	int rctx;
@@ -531,7 +531,7 @@ static void prof_syscall_exit(struct pt_regs *regs, long ret)
 	struct syscall_trace_exit *rec;
 	unsigned long flags;
 	int syscall_nr;
-	char *trace_buf;
+	char __percpu *trace_buf;
 	char *raw_data;
 	int rctx;
 	int size;
-- 
1.6.4.2

