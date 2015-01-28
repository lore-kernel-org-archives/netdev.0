From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 linux-trace 1/8] tracing: attach eBPF programs to tracepoints and syscalls
Date: Tue, 27 Jan 2015 20:06:06 -0800
Message-ID: <1422417973-10195-2-git-send-email-ast@plumgrid.com>
References: <1422417973-10195-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422417973-10195-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

User interface:
fd = open("/sys/kernel/debug/tracing/__event__/filter")

write(fd, "bpf_123")

where 123 is process local FD associated with eBPF program previously loaded.
__event__ is static tracepoint event or syscall.
(kprobe support is in next patch)
Once program is successfully attached to tracepoint event, the tracepoint
will be auto-enabled

close(fd)
auto-disables tracepoint event and detaches eBPF program from it

eBPF programs can call in-kernel helper functions to:
- lookup/update/delete elements in maps
- memcmp
- fetch_ptr/u64/u32/u16/u8 values from unsafe address via probe_kernel_read(),
  so that eBPF program can walk any kernel data structures

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/ftrace_event.h       |    4 ++
 include/trace/bpf_trace.h          |   25 +++++++
 include/trace/ftrace.h             |   29 ++++++++
 include/uapi/linux/bpf.h           |    7 ++
 kernel/trace/Kconfig               |    1 +
 kernel/trace/Makefile              |    1 +
 kernel/trace/bpf_trace.c           |  129 ++++++++++++++++++++++++++++++++++++
 kernel/trace/trace.h               |    3 +
 kernel/trace/trace_events.c        |   33 ++++++++-
 kernel/trace/trace_events_filter.c |   79 +++++++++++++++++++++-
 kernel/trace/trace_syscalls.c      |   31 +++++++++
 11 files changed, 340 insertions(+), 2 deletions(-)
 create mode 100644 include/trace/bpf_trace.h
 create mode 100644 kernel/trace/bpf_trace.c

diff --git a/include/linux/ftrace_event.h b/include/linux/ftrace_event.h
index 0bebb5c348b8..79de230b7df3 100644
--- a/include/linux/ftrace_event.h
+++ b/include/linux/ftrace_event.h
@@ -248,6 +248,7 @@ enum {
 	TRACE_EVENT_FL_WAS_ENABLED_BIT,
 	TRACE_EVENT_FL_USE_CALL_FILTER_BIT,
 	TRACE_EVENT_FL_TRACEPOINT_BIT,
+	TRACE_EVENT_FL_BPF_BIT,
 };
 
 /*
@@ -270,6 +271,7 @@ enum {
 	TRACE_EVENT_FL_WAS_ENABLED	= (1 << TRACE_EVENT_FL_WAS_ENABLED_BIT),
 	TRACE_EVENT_FL_USE_CALL_FILTER	= (1 << TRACE_EVENT_FL_USE_CALL_FILTER_BIT),
 	TRACE_EVENT_FL_TRACEPOINT	= (1 << TRACE_EVENT_FL_TRACEPOINT_BIT),
+	TRACE_EVENT_FL_BPF		= (1 << TRACE_EVENT_FL_BPF_BIT),
 };
 
 struct ftrace_event_call {
@@ -544,6 +546,8 @@ event_trigger_unlock_commit_regs(struct ftrace_event_file *file,
 		event_triggers_post_call(file, tt);
 }
 
+unsigned int trace_filter_call_bpf(struct event_filter *filter, void *ctx);
+
 enum {
 	FILTER_OTHER = 0,
 	FILTER_STATIC_STRING,
diff --git a/include/trace/bpf_trace.h b/include/trace/bpf_trace.h
new file mode 100644
index 000000000000..4e64f61f484d
--- /dev/null
+++ b/include/trace/bpf_trace.h
@@ -0,0 +1,25 @@
+/* Copyright (c) 2011-2015 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#ifndef _LINUX_KERNEL_BPF_TRACE_H
+#define _LINUX_KERNEL_BPF_TRACE_H
+
+/* For tracepoint filters argN fields match one to one to arguments
+ * passed to tracepoint events
+ *
+ * For syscall entry filters argN fields match syscall arguments
+ * For syscall exit filters arg1 is a return value
+ */
+struct bpf_context {
+	u64 arg1;
+	u64 arg2;
+	u64 arg3;
+	u64 arg4;
+	u64 arg5;
+	u64 arg6;
+};
+
+#endif /* _LINUX_KERNEL_BPF_TRACE_H */
diff --git a/include/trace/ftrace.h b/include/trace/ftrace.h
index 139b5067345b..07b68332f149 100644
--- a/include/trace/ftrace.h
+++ b/include/trace/ftrace.h
@@ -17,6 +17,7 @@
  */
 
 #include <linux/ftrace_event.h>
+#include <trace/bpf_trace.h>
 
 /*
  * DECLARE_EVENT_CLASS can be used to add a generic function
@@ -617,6 +618,24 @@ static inline notrace int ftrace_get_offsets_##call(			\
 #undef __perf_task
 #define __perf_task(t)	(t)
 
+/* zero extend integer, pointer or aggregate type to u64 without warnings */
+#define __CAST_TO_U64(expr) ({ \
+	u64 ret = 0; \
+	switch (sizeof(expr)) { \
+	case 8: ret = *(u64 *) &expr; break; \
+	case 4: ret = *(u32 *) &expr; break; \
+	case 2: ret = *(u16 *) &expr; break; \
+	case 1: ret = *(u8 *) &expr; break; \
+	} \
+	ret; })
+
+#define __BPF_CAST1(a,...) __CAST_TO_U64(a)
+#define __BPF_CAST2(a,...) __CAST_TO_U64(a), __BPF_CAST1(__VA_ARGS__)
+#define __BPF_CAST3(a,...) __CAST_TO_U64(a), __BPF_CAST2(__VA_ARGS__)
+#define __BPF_CAST4(a,...) __CAST_TO_U64(a), __BPF_CAST3(__VA_ARGS__)
+#define __BPF_CAST5(a,...) __CAST_TO_U64(a), __BPF_CAST4(__VA_ARGS__)
+#define __BPF_CAST6(a,...) __CAST_TO_U64(a), __BPF_CAST5(__VA_ARGS__)
+
 #undef DECLARE_EVENT_CLASS
 #define DECLARE_EVENT_CLASS(call, proto, args, tstruct, assign, print)	\
 									\
@@ -632,6 +651,16 @@ ftrace_raw_event_##call(void *__data, proto)				\
 	if (ftrace_trigger_soft_disabled(ftrace_file))			\
 		return;							\
 									\
+	if (ftrace_file->flags & TRACE_EVENT_FL_BPF) {			\
+		__maybe_unused const u64 z = 0;				\
+		struct bpf_context __ctx = ((struct bpf_context) {	\
+				__BPF_CAST6(args, z, z, z, z, z)	\
+			});						\
+									\
+		if (!trace_filter_call_bpf(ftrace_file->filter, &__ctx))\
+			return;						\
+	}								\
+									\
 	__data_size = ftrace_get_offsets_##call(&__data_offsets, args); \
 									\
 	entry = ftrace_event_buffer_reserve(&fbuffer, ftrace_file,	\
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 45da7ec7d274..3bf42875287c 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -118,6 +118,7 @@ enum bpf_map_type {
 enum bpf_prog_type {
 	BPF_PROG_TYPE_UNSPEC,
 	BPF_PROG_TYPE_SOCKET_FILTER,
+	BPF_PROG_TYPE_TRACING_FILTER,
 };
 
 /* flags for BPF_MAP_UPDATE_ELEM command */
@@ -162,6 +163,12 @@ enum bpf_func_id {
 	BPF_FUNC_map_lookup_elem, /* void *map_lookup_elem(&map, &key) */
 	BPF_FUNC_map_update_elem, /* int map_update_elem(&map, &key, &value, flags) */
 	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
+	BPF_FUNC_fetch_ptr,       /* void *bpf_fetch_ptr(void *unsafe_ptr) */
+	BPF_FUNC_fetch_u64,       /* u64 bpf_fetch_u64(void *unsafe_ptr) */
+	BPF_FUNC_fetch_u32,       /* u32 bpf_fetch_u32(void *unsafe_ptr) */
+	BPF_FUNC_fetch_u16,       /* u16 bpf_fetch_u16(void *unsafe_ptr) */
+	BPF_FUNC_fetch_u8,        /* u8 bpf_fetch_u8(void *unsafe_ptr) */
+	BPF_FUNC_memcmp,          /* int bpf_memcmp(void *unsafe_ptr, void *safe_ptr, int size) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
index a5da09c899dd..eb60b234b824 100644
--- a/kernel/trace/Kconfig
+++ b/kernel/trace/Kconfig
@@ -75,6 +75,7 @@ config FTRACE_NMI_ENTER
 
 config EVENT_TRACING
 	select CONTEXT_SWITCH_TRACER
+	select BPF_SYSCALL
 	bool
 
 config CONTEXT_SWITCH_TRACER
diff --git a/kernel/trace/Makefile b/kernel/trace/Makefile
index 979ccde26720..ef821d90f3f5 100644
--- a/kernel/trace/Makefile
+++ b/kernel/trace/Makefile
@@ -53,6 +53,7 @@ obj-$(CONFIG_EVENT_TRACING) += trace_event_perf.o
 endif
 obj-$(CONFIG_EVENT_TRACING) += trace_events_filter.o
 obj-$(CONFIG_EVENT_TRACING) += trace_events_trigger.o
+obj-$(CONFIG_EVENT_TRACING) += bpf_trace.o
 obj-$(CONFIG_KPROBE_EVENT) += trace_kprobe.o
 obj-$(CONFIG_TRACEPOINTS) += power-traces.o
 ifeq ($(CONFIG_PM),y)
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
new file mode 100644
index 000000000000..4aabbe2626c5
--- /dev/null
+++ b/kernel/trace/bpf_trace.c
@@ -0,0 +1,129 @@
+/* Copyright (c) 2011-2015 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/bpf.h>
+#include <linux/filter.h>
+#include <linux/uaccess.h>
+#include <trace/bpf_trace.h>
+#include "trace.h"
+
+static u64 bpf_fetch_ptr(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	void *unsafe_ptr = (void *) (long) r1;
+	void *ptr = NULL;
+
+	probe_kernel_read(&ptr, unsafe_ptr, sizeof(ptr));
+	return (u64) (unsigned long) ptr;
+}
+
+#define FETCH(SIZE) \
+static u64 bpf_fetch_##SIZE(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)	\
+{									\
+	void *unsafe_ptr = (void *) (long) r1;				\
+	SIZE val = 0;							\
+									\
+	probe_kernel_read(&val, unsafe_ptr, sizeof(val));		\
+	return (u64) (SIZE) val;					\
+}
+FETCH(u64)
+FETCH(u32)
+FETCH(u16)
+FETCH(u8)
+#undef FETCH
+
+static u64 bpf_memcmp(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	void *unsafe_ptr = (void *) (long) r1;
+	void *safe_ptr = (void *) (long) r2;
+	u32 size = (u32) r3;
+	char buf[64];
+	int err;
+
+	if (size < 64) {
+		err = probe_kernel_read(buf, unsafe_ptr, size);
+		if (err)
+			return err;
+		return memcmp(buf, safe_ptr, size);
+	}
+	return -1;
+}
+
+static struct bpf_func_proto tracing_filter_funcs[] = {
+#define FETCH(SIZE)				\
+	[BPF_FUNC_fetch_##SIZE] = {		\
+		.func = bpf_fetch_##SIZE,	\
+		.gpl_only = true,		\
+		.ret_type = RET_INTEGER,	\
+	},
+	FETCH(ptr)
+	FETCH(u64)
+	FETCH(u32)
+	FETCH(u16)
+	FETCH(u8)
+#undef FETCH
+	[BPF_FUNC_memcmp] = {
+		.func = bpf_memcmp,
+		.gpl_only = false,
+		.ret_type = RET_INTEGER,
+		.arg1_type = ARG_ANYTHING,
+		.arg2_type = ARG_PTR_TO_STACK,
+		.arg3_type = ARG_CONST_STACK_SIZE,
+	},
+};
+
+static const struct bpf_func_proto *tracing_filter_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_map_lookup_elem:
+		return &bpf_map_lookup_elem_proto;
+	case BPF_FUNC_map_update_elem:
+		return &bpf_map_update_elem_proto;
+	case BPF_FUNC_map_delete_elem:
+		return &bpf_map_delete_elem_proto;
+	default:
+		if (func_id < 0 || func_id >= ARRAY_SIZE(tracing_filter_funcs))
+			return NULL;
+		return &tracing_filter_funcs[func_id];
+	}
+}
+
+/* check access to argN fields of 'struct bpf_context' from program */
+static bool tracing_filter_is_valid_access(int off, int size, enum bpf_access_type type)
+{
+	/* check bounds */
+	if (off < 0 || off >= sizeof(struct bpf_context))
+		return false;
+
+	/* only read is allowed */
+	if (type != BPF_READ)
+		return false;
+
+	/* disallow misaligned access */
+	if (off % size != 0)
+		return false;
+
+	return true;
+}
+
+static struct bpf_verifier_ops tracing_filter_ops = {
+	.get_func_proto = tracing_filter_func_proto,
+	.is_valid_access = tracing_filter_is_valid_access,
+};
+
+static struct bpf_prog_type_list tl = {
+	.ops = &tracing_filter_ops,
+	.type = BPF_PROG_TYPE_TRACING_FILTER,
+};
+
+static int __init register_tracing_filter_ops(void)
+{
+	bpf_register_prog_type(&tl);
+	return 0;
+}
+late_initcall(register_tracing_filter_ops);
diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
index 8de48bac1ce2..d667547c6f0e 100644
--- a/kernel/trace/trace.h
+++ b/kernel/trace/trace.h
@@ -977,12 +977,15 @@ struct ftrace_event_field {
 	int			is_signed;
 };
 
+struct bpf_prog;
+
 struct event_filter {
 	int			n_preds;	/* Number assigned */
 	int			a_preds;	/* allocated */
 	struct filter_pred	*preds;
 	struct filter_pred	*root;
 	char			*filter_string;
+	struct bpf_prog		*prog;
 };
 
 struct event_subsystem {
diff --git a/kernel/trace/trace_events.c b/kernel/trace/trace_events.c
index b03a0ea77b99..70482817231a 100644
--- a/kernel/trace/trace_events.c
+++ b/kernel/trace/trace_events.c
@@ -1084,6 +1084,26 @@ event_filter_read(struct file *filp, char __user *ubuf, size_t cnt,
 	return r;
 }
 
+static int event_filter_release(struct inode *inode, struct file *filp)
+{
+	struct ftrace_event_file *file;
+	char buf[2] = "0";
+
+	mutex_lock(&event_mutex);
+	file = event_file_data(filp);
+	if (file) {
+		if (file->flags & TRACE_EVENT_FL_BPF) {
+			/* auto-disable the filter */
+			ftrace_event_enable_disable(file, 0);
+
+			/* if BPF filter was used, clear it on fd close */
+			apply_event_filter(file, buf);
+		}
+	}
+	mutex_unlock(&event_mutex);
+	return 0;
+}
+
 static ssize_t
 event_filter_write(struct file *filp, const char __user *ubuf, size_t cnt,
 		   loff_t *ppos)
@@ -1107,8 +1127,18 @@ event_filter_write(struct file *filp, const char __user *ubuf, size_t cnt,
 
 	mutex_lock(&event_mutex);
 	file = event_file_data(filp);
-	if (file)
+	if (file) {
+		/*
+		 * note to user space tools:
+		 * write() into debugfs/tracing/events/xxx/filter file
+		 * must be done with the same privilege level as open()
+		 */
 		err = apply_event_filter(file, buf);
+		if (!err && file->flags & TRACE_EVENT_FL_BPF)
+			/* once filter is applied, auto-enable it */
+			ftrace_event_enable_disable(file, 1);
+	}
+
 	mutex_unlock(&event_mutex);
 
 	free_page((unsigned long) buf);
@@ -1363,6 +1393,7 @@ static const struct file_operations ftrace_event_filter_fops = {
 	.open = tracing_open_generic,
 	.read = event_filter_read,
 	.write = event_filter_write,
+	.release = event_filter_release,
 	.llseek = default_llseek,
 };
 
diff --git a/kernel/trace/trace_events_filter.c b/kernel/trace/trace_events_filter.c
index ced69da0ff55..e0303b3cc9fb 100644
--- a/kernel/trace/trace_events_filter.c
+++ b/kernel/trace/trace_events_filter.c
@@ -23,6 +23,9 @@
 #include <linux/mutex.h>
 #include <linux/perf_event.h>
 #include <linux/slab.h>
+#include <linux/bpf.h>
+#include <trace/bpf_trace.h>
+#include <linux/filter.h>
 
 #include "trace.h"
 #include "trace_output.h"
@@ -541,6 +544,21 @@ static int filter_match_preds_cb(enum move_type move, struct filter_pred *pred,
 	return WALK_PRED_DEFAULT;
 }
 
+unsigned int trace_filter_call_bpf(struct event_filter *filter, void *ctx)
+{
+	unsigned int ret;
+
+	if (in_nmi()) /* not supported yet */
+		return 0;
+
+	rcu_read_lock();
+	ret = BPF_PROG_RUN(filter->prog, ctx);
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(trace_filter_call_bpf);
+
 /* return 1 if event matches, 0 otherwise (discard) */
 int filter_match_preds(struct event_filter *filter, void *rec)
 {
@@ -795,6 +813,8 @@ static void __free_filter(struct event_filter *filter)
 	if (!filter)
 		return;
 
+	if (filter->prog)
+		bpf_prog_put(filter->prog);
 	__free_preds(filter);
 	kfree(filter->filter_string);
 	kfree(filter);
@@ -1874,6 +1894,50 @@ static int create_filter_start(char *filter_str, bool set_str,
 	return err;
 }
 
+static int create_filter_bpf(char *filter_str, struct event_filter **filterp)
+{
+	struct event_filter *filter;
+	struct bpf_prog *prog;
+	long ufd;
+	int err = 0;
+
+	*filterp = NULL;
+
+	filter = __alloc_filter();
+	if (!filter)
+		return -ENOMEM;
+
+	err = replace_filter_string(filter, filter_str);
+	if (err)
+		goto free_filter;
+
+	err = kstrtol(filter_str + 4, 0, &ufd);
+	if (err)
+		goto free_filter;
+
+	prog = bpf_prog_get(ufd);
+	if (IS_ERR(prog)) {
+		err = PTR_ERR(prog);
+		goto free_filter;
+	}
+
+	filter->prog = prog;
+
+	if (prog->aux->prog_type != BPF_PROG_TYPE_TRACING_FILTER) {
+		/* valid fd, but invalid bpf program type */
+		err = -EINVAL;
+		goto free_filter;
+	}
+
+	*filterp = filter;
+
+	return 0;
+
+free_filter:
+	__free_filter(filter);
+	return err;
+}
+
 static void create_filter_finish(struct filter_parse_state *ps)
 {
 	if (ps) {
@@ -1971,6 +2035,7 @@ int apply_event_filter(struct ftrace_event_file *file, char *filter_string)
 		filter_disable(file);
 		filter = event_filter(file);
 
+		file->flags &= ~TRACE_EVENT_FL_BPF;
 		if (!filter)
 			return 0;
 
@@ -1983,7 +2048,19 @@ int apply_event_filter(struct ftrace_event_file *file, char *filter_string)
 		return 0;
 	}
 
-	err = create_filter(call, filter_string, true, &filter);
+	/*
+	 * 'bpf_123' string is a request to attach eBPF program with id == 123
+	 * also accept 'bpf 123', 'bpf.123', 'bpf-123' variants
+	 */
+	if (memcmp(filter_string, "bpf", 3) == 0 && filter_string[3] != 0 &&
+	    filter_string[4] != 0) {
+		err = create_filter_bpf(filter_string, &filter);
+		if (!err)
+			file->flags |= TRACE_EVENT_FL_BPF;
+	} else {
+		err = create_filter(call, filter_string, true, &filter);
+		file->flags &= ~TRACE_EVENT_FL_BPF;
+	}
 
 	/*
 	 * Always swap the call filter with the new filter
diff --git a/kernel/trace/trace_syscalls.c b/kernel/trace/trace_syscalls.c
index c6ee36fcbf90..e1b25a834cc7 100644
--- a/kernel/trace/trace_syscalls.c
+++ b/kernel/trace/trace_syscalls.c
@@ -7,6 +7,7 @@
 #include <linux/ftrace.h>
 #include <linux/perf_event.h>
 #include <asm/syscall.h>
+#include <trace/bpf_trace.h>
 
 #include "trace_output.h"
 #include "trace.h"
@@ -290,6 +291,20 @@ static int __init syscall_exit_define_fields(struct ftrace_event_call *call)
 	return ret;
 }
 
+static void populate_bpf_ctx(struct bpf_context *ctx, struct pt_regs *regs)
+{
+	struct task_struct *task = current;
+	unsigned long args[6];
+
+	syscall_get_arguments(task, regs, 0, 6, args);
+	ctx->arg1 = args[0];
+	ctx->arg2 = args[1];
+	ctx->arg3 = args[2];
+	ctx->arg4 = args[3];
+	ctx->arg5 = args[4];
+	ctx->arg6 = args[5];
+}
+
 static void ftrace_syscall_enter(void *data, struct pt_regs *regs, long id)
 {
 	struct trace_array *tr = data;
@@ -319,6 +334,14 @@ static void ftrace_syscall_enter(void *data, struct pt_regs *regs, long id)
 	if (!sys_data)
 		return;
 
+	if (ftrace_file->flags & TRACE_EVENT_FL_BPF) {
+		struct bpf_context ctx;
+
+		populate_bpf_ctx(&ctx, regs);
+		if (!trace_filter_call_bpf(ftrace_file->filter, &ctx))
+			return;
+	}
+
 	size = sizeof(*entry) + sizeof(unsigned long) * sys_data->nb_args;
 
 	local_save_flags(irq_flags);
@@ -366,6 +389,14 @@ static void ftrace_syscall_exit(void *data, struct pt_regs *regs, long ret)
 	if (!sys_data)
 		return;
 
+	if (ftrace_file->flags & TRACE_EVENT_FL_BPF) {
+		struct bpf_context ctx = {};
+
+		ctx.arg1 = syscall_get_return_value(current, regs);
+		if (!trace_filter_call_bpf(ftrace_file->filter, &ctx))
+			return;
+	}
+
 	local_save_flags(irq_flags);
 	pc = preempt_count();
 
-- 
1.7.9.5
