From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 1/3] perf: generalize perf_callchain
Date: Wed, 17 Feb 2016 19:58:57 -0800
Message-ID: <1455767939-2700534-2-git-send-email-ast@fb.com>
References: <1455767939-2700534-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Wang Nan <wangnan0@huawei.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455767939-2700534-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

. avoid walking the stack when there is no room left in the buffer
. generalize get_perf_callchain() to be called from bpf helper

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 arch/x86/include/asm/stacktrace.h |  2 +-
 arch/x86/kernel/cpu/perf_event.c  |  4 ++--
 arch/x86/kernel/dumpstack.c       |  6 ++++--
 arch/x86/kernel/stacktrace.c      | 18 +++++++++++-------
 arch/x86/oprofile/backtrace.c     |  3 ++-
 include/linux/perf_event.h        | 13 +++++++++++--
 kernel/events/callchain.c         | 32 ++++++++++++++++++++------------
 kernel/events/internal.h          |  2 --
 8 files changed, 51 insertions(+), 29 deletions(-)

diff --git a/arch/x86/include/asm/stacktrace.h b/arch/x86/include/asm/stacktrace.h
index 70bbe39043a9..7c247e7404be 100644
--- a/arch/x86/include/asm/stacktrace.h
+++ b/arch/x86/include/asm/stacktrace.h
@@ -37,7 +37,7 @@ print_context_stack_bp(struct thread_info *tinfo,
 /* Generic stack tracer with callbacks */
 
 struct stacktrace_ops {
-	void (*address)(void *data, unsigned long address, int reliable);
+	int (*address)(void *data, unsigned long address, int reliable);
 	/* On negative return stop dumping */
 	int (*stack)(void *data, char *name);
 	walk_stack_t	walk_stack;
diff --git a/arch/x86/kernel/cpu/perf_event.c b/arch/x86/kernel/cpu/perf_event.c
index 1b443db2db50..d276b31ca473 100644
--- a/arch/x86/kernel/cpu/perf_event.c
+++ b/arch/x86/kernel/cpu/perf_event.c
@@ -2180,11 +2180,11 @@ static int backtrace_stack(void *data, char *name)
 	return 0;
 }
 
-static void backtrace_address(void *data, unsigned long addr, int reliable)
+static int backtrace_address(void *data, unsigned long addr, int reliable)
 {
 	struct perf_callchain_entry *entry = data;
 
-	perf_callchain_store(entry, addr);
+	return perf_callchain_store(entry, addr);
 }
 
 static const struct stacktrace_ops backtrace_ops = {
diff --git a/arch/x86/kernel/dumpstack.c b/arch/x86/kernel/dumpstack.c
index 9c30acfadae2..0d1ff4b407d4 100644
--- a/arch/x86/kernel/dumpstack.c
+++ b/arch/x86/kernel/dumpstack.c
@@ -135,7 +135,8 @@ print_context_stack_bp(struct thread_info *tinfo,
 		if (!__kernel_text_address(addr))
 			break;
 
-		ops->address(data, addr, 1);
+		if (ops->address(data, addr, 1))
+			break;
 		frame = frame->next_frame;
 		ret_addr = &frame->return_address;
 		print_ftrace_graph_addr(addr, data, ops, tinfo, graph);
@@ -154,10 +155,11 @@ static int print_trace_stack(void *data, char *name)
 /*
  * Print one address/symbol entries per line.
  */
-static void print_trace_address(void *data, unsigned long addr, int reliable)
+static int print_trace_address(void *data, unsigned long addr, int reliable)
 {
 	touch_nmi_watchdog();
 	printk_stack_address(addr, reliable, data);
+	return 0;
 }
 
 static const struct stacktrace_ops print_trace_ops = {
diff --git a/arch/x86/kernel/stacktrace.c b/arch/x86/kernel/stacktrace.c
index fdd0c6430e5a..9ee98eefc44d 100644
--- a/arch/x86/kernel/stacktrace.c
+++ b/arch/x86/kernel/stacktrace.c
@@ -14,30 +14,34 @@ static int save_stack_stack(void *data, char *name)
 	return 0;
 }
 
-static void
+static int
 __save_stack_address(void *data, unsigned long addr, bool reliable, bool nosched)
 {
 	struct stack_trace *trace = data;
 #ifdef CONFIG_FRAME_POINTER
 	if (!reliable)
-		return;
+		return 0;
 #endif
 	if (nosched && in_sched_functions(addr))
-		return;
+		return 0;
 	if (trace->skip > 0) {
 		trace->skip--;
-		return;
+		return 0;
 	}
-	if (trace->nr_entries < trace->max_entries)
+	if (trace->nr_entries < trace->max_entries) {
 		trace->entries[trace->nr_entries++] = addr;
+		return 0;
+	} else {
+		return -1; /* no more room, stop walking the stack */
+	}
 }
 
-static void save_stack_address(void *data, unsigned long addr, int reliable)
+static int save_stack_address(void *data, unsigned long addr, int reliable)
 {
 	return __save_stack_address(data, addr, reliable, false);
 }
 
-static void
+static int
 save_stack_address_nosched(void *data, unsigned long addr, int reliable)
 {
 	return __save_stack_address(data, addr, reliable, true);
diff --git a/arch/x86/oprofile/backtrace.c b/arch/x86/oprofile/backtrace.c
index 4e664bdb535a..cb31a4440e58 100644
--- a/arch/x86/oprofile/backtrace.c
+++ b/arch/x86/oprofile/backtrace.c
@@ -23,12 +23,13 @@ static int backtrace_stack(void *data, char *name)
 	return 0;
 }
 
-static void backtrace_address(void *data, unsigned long addr, int reliable)
+static int backtrace_address(void *data, unsigned long addr, int reliable)
 {
 	unsigned int *depth = data;
 
 	if ((*depth)--)
 		oprofile_add_trace(addr);
+	return 0;
 }
 
 static struct stacktrace_ops backtrace_ops = {
diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index b35a61a481fa..7da3c25999df 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -964,11 +964,20 @@ DECLARE_PER_CPU(struct perf_callchain_entry, perf_callchain_entry);
 
 extern void perf_callchain_user(struct perf_callchain_entry *entry, struct pt_regs *regs);
 extern void perf_callchain_kernel(struct perf_callchain_entry *entry, struct pt_regs *regs);
+extern struct perf_callchain_entry *
+get_perf_callchain(struct pt_regs *regs, u32 init_nr, bool kernel, bool user,
+		   bool crosstask, bool add_mark);
+extern int get_callchain_buffers(void);
+extern void put_callchain_buffers(void);
 
-static inline void perf_callchain_store(struct perf_callchain_entry *entry, u64 ip)
+static inline int perf_callchain_store(struct perf_callchain_entry *entry, u64 ip)
 {
-	if (entry->nr < PERF_MAX_STACK_DEPTH)
+	if (entry->nr < PERF_MAX_STACK_DEPTH) {
 		entry->ip[entry->nr++] = ip;
+		return 0;
+	} else {
+		return -1; /* no more room, stop walking the stack */
+	}
 }
 
 extern int sysctl_perf_event_paranoid;
diff --git a/kernel/events/callchain.c b/kernel/events/callchain.c
index 9c418002b8c1..343c22f5e867 100644
--- a/kernel/events/callchain.c
+++ b/kernel/events/callchain.c
@@ -159,15 +159,24 @@ put_callchain_entry(int rctx)
 struct perf_callchain_entry *
 perf_callchain(struct perf_event *event, struct pt_regs *regs)
 {
-	int rctx;
-	struct perf_callchain_entry *entry;
-
-	int kernel = !event->attr.exclude_callchain_kernel;
-	int user   = !event->attr.exclude_callchain_user;
+	bool kernel = !event->attr.exclude_callchain_kernel;
+	bool user   = !event->attr.exclude_callchain_user;
+	/* Disallow cross-task user callchains. */
+	bool crosstask = event->ctx->task && event->ctx->task != current;
 
 	if (!kernel && !user)
 		return NULL;
 
+	return get_perf_callchain(regs, 0, kernel, user, crosstask, true);
+}
+
+struct perf_callchain_entry *
+get_perf_callchain(struct pt_regs *regs, u32 init_nr, bool kernel, bool user,
+		   bool crosstask, bool add_mark)
+{
+	struct perf_callchain_entry *entry;
+	int rctx;
+
 	entry = get_callchain_entry(&rctx);
 	if (rctx == -1)
 		return NULL;
@@ -175,10 +184,11 @@ perf_callchain(struct perf_event *event, struct pt_regs *regs)
 	if (!entry)
 		goto exit_put;
 
-	entry->nr = 0;
+	entry->nr = init_nr;
 
 	if (kernel && !user_mode(regs)) {
-		perf_callchain_store(entry, PERF_CONTEXT_KERNEL);
+		if (add_mark)
+			perf_callchain_store(entry, PERF_CONTEXT_KERNEL);
 		perf_callchain_kernel(entry, regs);
 	}
 
@@ -191,13 +201,11 @@ perf_callchain(struct perf_event *event, struct pt_regs *regs)
 		}
 
 		if (regs) {
-			/*
-			 * Disallow cross-task user callchains.
-			 */
-			if (event->ctx->task && event->ctx->task != current)
+			if (crosstask)
 				goto exit_put;
 
-			perf_callchain_store(entry, PERF_CONTEXT_USER);
+			if (add_mark)
+				perf_callchain_store(entry, PERF_CONTEXT_USER);
 			perf_callchain_user(entry, regs);
 		}
 	}
diff --git a/kernel/events/internal.h b/kernel/events/internal.h
index 2bbad9c1274c..4199b6d193f5 100644
--- a/kernel/events/internal.h
+++ b/kernel/events/internal.h
@@ -182,8 +182,6 @@ DEFINE_OUTPUT_COPY(__output_copy_user, arch_perf_out_copy_user)
 /* Callchain handling */
 extern struct perf_callchain_entry *
 perf_callchain(struct perf_event *event, struct pt_regs *regs);
-extern int get_callchain_buffers(void);
-extern void put_callchain_buffers(void);
 
 static inline int get_recursion_context(int *recursion)
 {
-- 
2.4.6
