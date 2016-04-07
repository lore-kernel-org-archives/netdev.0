From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 03/10] perf: split perf_trace_buf_prepare into alloc and update parts
Date: Wed, 6 Apr 2016 18:43:24 -0700
Message-ID: <1459993411-2754735-4-git-send-email-ast@fb.com>
References: <1459993411-2754735-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	"Wang Nan" <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459993411-2754735-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

split allows to move expensive update of 'struct trace_entry' to later phase.
Repurpose unused 1st argument of perf_tp_event() to indicate event type.

While splitting use temp variable 'rctx' instead of '*rctx' to avoid
unnecessary loads done by the compiler due to -fno-strict-aliasing

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/perf_event.h      |  2 +-
 include/linux/trace_events.h    |  8 ++++----
 include/trace/perf.h            |  8 ++++----
 kernel/events/core.c            |  6 ++++--
 kernel/trace/trace_event_perf.c | 39 ++++++++++++++++++++-------------------
 kernel/trace/trace_kprobe.c     | 10 ++++++----
 kernel/trace/trace_syscalls.c   | 13 +++++++------
 kernel/trace/trace_uprobe.c     |  5 +++--
 8 files changed, 49 insertions(+), 42 deletions(-)

diff --git a/include/linux/perf_event.h b/include/linux/perf_event.h
index e89f7199c223..eb41b535ef38 100644
--- a/include/linux/perf_event.h
+++ b/include/linux/perf_event.h
@@ -1016,7 +1016,7 @@ static inline bool perf_paranoid_kernel(void)
 }
 
 extern void perf_event_init(void);
-extern void perf_tp_event(u64 addr, u64 count, void *record,
+extern void perf_tp_event(u16 event_type, u64 count, void *record,
 			  int entry_size, struct pt_regs *regs,
 			  struct hlist_head *head, int rctx,
 			  struct task_struct *task);
diff --git a/include/linux/trace_events.h b/include/linux/trace_events.h
index 0810f81b6db2..56f795e6a093 100644
--- a/include/linux/trace_events.h
+++ b/include/linux/trace_events.h
@@ -605,15 +605,15 @@ extern void perf_trace_del(struct perf_event *event, int flags);
 extern int  ftrace_profile_set_filter(struct perf_event *event, int event_id,
 				     char *filter_str);
 extern void ftrace_profile_free_filter(struct perf_event *event);
-extern void *perf_trace_buf_prepare(int size, unsigned short type,
-				    struct pt_regs **regs, int *rctxp);
+void perf_trace_buf_update(void *record, u16 type);
+void *perf_trace_buf_alloc(int size, struct pt_regs **regs, int *rctxp);
 
 static inline void
-perf_trace_buf_submit(void *raw_data, int size, int rctx, u64 addr,
+perf_trace_buf_submit(void *raw_data, int size, int rctx, u16 type,
 		       u64 count, struct pt_regs *regs, void *head,
 		       struct task_struct *task)
 {
-	perf_tp_event(addr, count, raw_data, size, regs, head, rctx, task);
+	perf_tp_event(type, count, raw_data, size, regs, head, rctx, task);
 }
 #endif
 
diff --git a/include/trace/perf.h b/include/trace/perf.h
index 6f7e37869065..77cd9043b7e4 100644
--- a/include/trace/perf.h
+++ b/include/trace/perf.h
@@ -53,8 +53,7 @@ perf_trace_##call(void *__data, proto)					\
 			     sizeof(u64));				\
 	__entry_size -= sizeof(u32);					\
 									\
-	entry = perf_trace_buf_prepare(__entry_size,			\
-			event_call->event.type, &__regs, &rctx);	\
+	entry = perf_trace_buf_alloc(__entry_size, &__regs, &rctx);	\
 	if (!entry)							\
 		return;							\
 									\
@@ -64,8 +63,9 @@ perf_trace_##call(void *__data, proto)					\
 									\
 	{ assign; }							\
 									\
-	perf_trace_buf_submit(entry, __entry_size, rctx, 0,		\
-		__count, __regs, head, __task);				\
+	perf_trace_buf_submit(entry, __entry_size, rctx,		\
+			      event_call->event.type, __count, __regs,	\
+			      head, __task);				\
 }
 
 /*
diff --git a/kernel/events/core.c b/kernel/events/core.c
index de24fbce5277..d8512883c0a0 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -6987,7 +6987,7 @@ static int perf_tp_event_match(struct perf_event *event,
 	return 1;
 }
 
-void perf_tp_event(u64 addr, u64 count, void *record, int entry_size,
+void perf_tp_event(u16 event_type, u64 count, void *record, int entry_size,
 		   struct pt_regs *regs, struct hlist_head *head, int rctx,
 		   struct task_struct *task)
 {
@@ -6999,9 +6999,11 @@ void perf_tp_event(u64 addr, u64 count, void *record, int entry_size,
 		.data = record,
 	};
 
-	perf_sample_data_init(&data, addr, 0);
+	perf_sample_data_init(&data, 0, 0);
 	data.raw = &raw;
 
+	perf_trace_buf_update(record, event_type);
+
 	hlist_for_each_entry_rcu(event, head, hlist_entry) {
 		if (perf_tp_event_match(event, &data, regs))
 			perf_swevent_event(event, count, &data, regs);
diff --git a/kernel/trace/trace_event_perf.c b/kernel/trace/trace_event_perf.c
index 7a68afca8249..5a927075977f 100644
--- a/kernel/trace/trace_event_perf.c
+++ b/kernel/trace/trace_event_perf.c
@@ -260,42 +260,43 @@ void perf_trace_del(struct perf_event *p_event, int flags)
 	tp_event->class->reg(tp_event, TRACE_REG_PERF_DEL, p_event);
 }
 
-void *perf_trace_buf_prepare(int size, unsigned short type,
-			     struct pt_regs **regs, int *rctxp)
+void *perf_trace_buf_alloc(int size, struct pt_regs **regs, int *rctxp)
 {
-	struct trace_entry *entry;
-	unsigned long flags;
 	char *raw_data;
-	int pc;
+	int rctx;
 
 	BUILD_BUG_ON(PERF_MAX_TRACE_SIZE % sizeof(unsigned long));
 
 	if (WARN_ONCE(size > PERF_MAX_TRACE_SIZE,
-			"perf buffer not large enough"))
+		      "perf buffer not large enough"))
 		return NULL;
 
-	pc = preempt_count();
-
-	*rctxp = perf_swevent_get_recursion_context();
-	if (*rctxp < 0)
+	*rctxp = rctx = perf_swevent_get_recursion_context();
+	if (rctx < 0)
 		return NULL;
 
 	if (regs)
-		*regs = this_cpu_ptr(&__perf_regs[*rctxp]);
-	raw_data = this_cpu_ptr(perf_trace_buf[*rctxp]);
+		*regs = this_cpu_ptr(&__perf_regs[rctx]);
+	raw_data = this_cpu_ptr(perf_trace_buf[rctx]);
 
 	/* zero the dead bytes from align to not leak stack to user */
 	memset(&raw_data[size - sizeof(u64)], 0, sizeof(u64));
+	return raw_data;
+}
+EXPORT_SYMBOL_GPL(perf_trace_buf_alloc);
+NOKPROBE_SYMBOL(perf_trace_buf_alloc);
+
+void perf_trace_buf_update(void *record, u16 type)
+{
+	struct trace_entry *entry = record;
+	int pc = preempt_count();
+	unsigned long flags;
 
-	entry = (struct trace_entry *)raw_data;
 	local_save_flags(flags);
 	tracing_generic_entry_update(entry, flags, pc);
 	entry->type = type;
-
-	return raw_data;
 }
-EXPORT_SYMBOL_GPL(perf_trace_buf_prepare);
-NOKPROBE_SYMBOL(perf_trace_buf_prepare);
+NOKPROBE_SYMBOL(perf_trace_buf_update);
 
 #ifdef CONFIG_FUNCTION_TRACER
 static void
@@ -319,13 +320,13 @@ perf_ftrace_function_call(unsigned long ip, unsigned long parent_ip,
 	memset(&regs, 0, sizeof(regs));
 	perf_fetch_caller_regs(&regs);
 
-	entry = perf_trace_buf_prepare(ENTRY_SIZE, TRACE_FN, NULL, &rctx);
+	entry = perf_trace_buf_alloc(ENTRY_SIZE, NULL, &rctx);
 	if (!entry)
 		return;
 
 	entry->ip = ip;
 	entry->parent_ip = parent_ip;
-	perf_trace_buf_submit(entry, ENTRY_SIZE, rctx, 0,
+	perf_trace_buf_submit(entry, ENTRY_SIZE, rctx, TRACE_FN,
 			      1, &regs, head, NULL);
 
 #undef ENTRY_SIZE
diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
index 919e0ddd8fcc..5546eec0505f 100644
--- a/kernel/trace/trace_kprobe.c
+++ b/kernel/trace/trace_kprobe.c
@@ -1149,14 +1149,15 @@ kprobe_perf_func(struct trace_kprobe *tk, struct pt_regs *regs)
 	size = ALIGN(__size + sizeof(u32), sizeof(u64));
 	size -= sizeof(u32);
 
-	entry = perf_trace_buf_prepare(size, call->event.type, NULL, &rctx);
+	entry = perf_trace_buf_alloc(size, NULL, &rctx);
 	if (!entry)
 		return;
 
 	entry->ip = (unsigned long)tk->rp.kp.addr;
 	memset(&entry[1], 0, dsize);
 	store_trace_args(sizeof(*entry), &tk->tp, regs, (u8 *)&entry[1], dsize);
-	perf_trace_buf_submit(entry, size, rctx, 0, 1, regs, head, NULL);
+	perf_trace_buf_submit(entry, size, rctx, call->event.type, 1, regs,
+			      head, NULL);
 }
 NOKPROBE_SYMBOL(kprobe_perf_func);
 
@@ -1184,14 +1185,15 @@ kretprobe_perf_func(struct trace_kprobe *tk, struct kretprobe_instance *ri,
 	size = ALIGN(__size + sizeof(u32), sizeof(u64));
 	size -= sizeof(u32);
 
-	entry = perf_trace_buf_prepare(size, call->event.type, NULL, &rctx);
+	entry = perf_trace_buf_alloc(size, NULL, &rctx);
 	if (!entry)
 		return;
 
 	entry->func = (unsigned long)tk->rp.kp.addr;
 	entry->ret_ip = (unsigned long)ri->ret_addr;
 	store_trace_args(sizeof(*entry), &tk->tp, regs, (u8 *)&entry[1], dsize);
-	perf_trace_buf_submit(entry, size, rctx, 0, 1, regs, head, NULL);
+	perf_trace_buf_submit(entry, size, rctx, call->event.type, 1, regs,
+			      head, NULL);
 }
 NOKPROBE_SYMBOL(kretprobe_perf_func);
 #endif	/* CONFIG_PERF_EVENTS */
diff --git a/kernel/trace/trace_syscalls.c b/kernel/trace/trace_syscalls.c
index e78f364cc192..b2b6efc083a4 100644
--- a/kernel/trace/trace_syscalls.c
+++ b/kernel/trace/trace_syscalls.c
@@ -587,15 +587,16 @@ static void perf_syscall_enter(void *ignore, struct pt_regs *regs, long id)
 	size = ALIGN(size + sizeof(u32), sizeof(u64));
 	size -= sizeof(u32);
 
-	rec = (struct syscall_trace_enter *)perf_trace_buf_prepare(size,
-				sys_data->enter_event->event.type, NULL, &rctx);
+	rec = perf_trace_buf_alloc(size, NULL, &rctx);
 	if (!rec)
 		return;
 
 	rec->nr = syscall_nr;
 	syscall_get_arguments(current, regs, 0, sys_data->nb_args,
 			       (unsigned long *)&rec->args);
-	perf_trace_buf_submit(rec, size, rctx, 0, 1, regs, head, NULL);
+	perf_trace_buf_submit(rec, size, rctx,
+			      sys_data->enter_event->event.type, 1, regs,
+			      head, NULL);
 }
 
 static int perf_sysenter_enable(struct trace_event_call *call)
@@ -660,14 +661,14 @@ static void perf_syscall_exit(void *ignore, struct pt_regs *regs, long ret)
 	size = ALIGN(sizeof(*rec) + sizeof(u32), sizeof(u64));
 	size -= sizeof(u32);
 
-	rec = (struct syscall_trace_exit *)perf_trace_buf_prepare(size,
-				sys_data->exit_event->event.type, NULL, &rctx);
+	rec = perf_trace_buf_alloc(size, NULL, &rctx);
 	if (!rec)
 		return;
 
 	rec->nr = syscall_nr;
 	rec->ret = syscall_get_return_value(current, regs);
-	perf_trace_buf_submit(rec, size, rctx, 0, 1, regs, head, NULL);
+	perf_trace_buf_submit(rec, size, rctx, sys_data->exit_event->event.type,
+			      1, regs, head, NULL);
 }
 
 static int perf_sysexit_enable(struct trace_event_call *call)
diff --git a/kernel/trace/trace_uprobe.c b/kernel/trace/trace_uprobe.c
index 7915142c89e4..c53485441c88 100644
--- a/kernel/trace/trace_uprobe.c
+++ b/kernel/trace/trace_uprobe.c
@@ -1131,7 +1131,7 @@ static void __uprobe_perf_func(struct trace_uprobe *tu,
 	if (hlist_empty(head))
 		goto out;
 
-	entry = perf_trace_buf_prepare(size, call->event.type, NULL, &rctx);
+	entry = perf_trace_buf_alloc(size, NULL, &rctx);
 	if (!entry)
 		goto out;
 
@@ -1152,7 +1152,8 @@ static void __uprobe_perf_func(struct trace_uprobe *tu,
 		memset(data + len, 0, size - esize - len);
 	}
 
-	perf_trace_buf_submit(entry, size, rctx, 0, 1, regs, head, NULL);
+	perf_trace_buf_submit(entry, size, rctx, call->event.type, 1, regs,
+			      head, NULL);
  out:
 	preempt_enable();
 }
-- 
2.8.0
