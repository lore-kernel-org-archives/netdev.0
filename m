From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to tracepoints and syscalls
Date: Mon,  9 Feb 2015 19:45:54 -0800
Message-ID: <1423539961-21792-2-git-send-email-ast@plumgrid.com>
References: <1423539961-21792-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1423539961-21792-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

User interface:
struct perf_event_attr attr = {.type = PERF_TYPE_TRACEPOINT, .config = event_id, ...};
event_fd = perf_event_open(&attr,...);
ioctl(event_fd, PERF_EVENT_IOC_SET_BPF, prog_fd);

prog_fd is a file descriptor associated with eBPF program previously loaded.
event_id is an ID of static tracepoint event or syscall.
(kprobe support is in next patch)

close(event_fd) - automatically detaches eBPF program from it

eBPF programs can call in-kernel helper functions to:
- lookup/update/delete elements in maps
- fetch_ptr/u64/u32/u16/u8 values from unsafe address via probe_kernel_read(),
  so that eBPF program can walk any kernel data structures
- probe_memcmp - combination of probe_kernel_read() and memcmp()

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 include/linux/bpf.h             |    6 +-
 include/linux/ftrace_event.h    |   11 +++
 include/trace/bpf_trace.h       |   25 +++++++
 include/trace/ftrace.h          |   31 +++++++++
 include/uapi/linux/bpf.h        |    7 ++
 include/uapi/linux/perf_event.h |    1 +
 kernel/events/core.c            |   55 +++++++++++++++
 kernel/trace/Makefile           |    1 +
 kernel/trace/bpf_trace.c        |  145 +++++++++++++++++++++++++++++++++++++++
 kernel/trace/trace_syscalls.c   |   35 ++++++++++
 10 files changed, 316 insertions(+), 1 deletion(-)
 create mode 100644 include/trace/bpf_trace.h
 create mode 100644 kernel/trace/bpf_trace.c

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index bbfceb756452..a0f6f636ced0 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -130,10 +130,14 @@ struct bpf_prog_aux {
 
 #ifdef CONFIG_BPF_SYSCALL
 void bpf_prog_put(struct bpf_prog *prog);
+struct bpf_prog *bpf_prog_get(u32 ufd);
 #else
 static inline void bpf_prog_put(struct bpf_prog *prog) {}
+static inline struct bpf_prog *bpf_prog_get(u32 ufd)
+{
+	return ERR_PTR(-ENOENT);
+}
 #endif
-struct bpf_prog *bpf_prog_get(u32 ufd);
 /* verify correctness of eBPF program */
 int bpf_check(struct bpf_prog *fp, union bpf_attr *attr);
 
diff --git a/include/linux/ftrace_event.h b/include/linux/ftrace_event.h
index 0bebb5c348b8..479d0a4a42b3 100644
--- a/include/linux/ftrace_event.h
+++ b/include/linux/ftrace_event.h
@@ -13,6 +13,7 @@ struct trace_array;
 struct trace_buffer;
 struct tracer;
 struct dentry;
+struct bpf_prog;
 
 struct trace_print_flags {
 	unsigned long		mask;
@@ -299,6 +300,7 @@ struct ftrace_event_call {
 #ifdef CONFIG_PERF_EVENTS
 	int				perf_refcount;
 	struct hlist_head __percpu	*perf_events;
+	struct bpf_prog			*prog;
 
 	int	(*perf_perm)(struct ftrace_event_call *,
 			     struct perf_event *);
@@ -544,6 +546,15 @@ event_trigger_unlock_commit_regs(struct ftrace_event_file *file,
 		event_triggers_post_call(file, tt);
 }
 
+#ifdef CONFIG_BPF_SYSCALL
+unsigned int trace_call_bpf(struct bpf_prog *prog, void *ctx);
+#else
+static inline unsigned int trace_call_bpf(struct bpf_prog *prog, void *ctx)
+{
+	return 1;
+}
+#endif
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
index 139b5067345b..4c275ce2dcf0 100644
--- a/include/trace/ftrace.h
+++ b/include/trace/ftrace.h
@@ -17,6 +17,7 @@
  */
 
 #include <linux/ftrace_event.h>
+#include <trace/bpf_trace.h>
 
 /*
  * DECLARE_EVENT_CLASS can be used to add a generic function
@@ -755,12 +756,32 @@ __attribute__((section("_ftrace_events"))) *__event_##call = &event_##call
 #undef __perf_task
 #define __perf_task(t)	(__task = (t))
 
+/* zero extend integer, pointer or aggregate type to u64 without warnings */
+#define __CAST_TO_U64(EXPR) ({ \
+	u64 ret = 0; \
+	typeof(EXPR) expr = EXPR; \
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
 static notrace void							\
 perf_trace_##call(void *__data, proto)					\
 {									\
 	struct ftrace_event_call *event_call = __data;			\
+	struct bpf_prog *prog = event_call->prog;			\
 	struct ftrace_data_offsets_##call __maybe_unused __data_offsets;\
 	struct ftrace_raw_##call *entry;				\
 	struct pt_regs __regs;						\
@@ -771,6 +792,16 @@ perf_trace_##call(void *__data, proto)					\
 	int __data_size;						\
 	int rctx;							\
 									\
+	if (prog) {							\
+		__maybe_unused const u64 z = 0;				\
+		struct bpf_context __ctx = ((struct bpf_context) {	\
+				__BPF_CAST6(args, z, z, z, z, z)	\
+			});						\
+									\
+		if (!trace_call_bpf(prog, &__ctx))			\
+			return;						\
+	}								\
+									\
 	__data_size = ftrace_get_offsets_##call(&__data_offsets, args); \
 									\
 	head = this_cpu_ptr(event_call->perf_events);			\
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 45da7ec7d274..d73d7d0abe6e 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -118,6 +118,7 @@ enum bpf_map_type {
 enum bpf_prog_type {
 	BPF_PROG_TYPE_UNSPEC,
 	BPF_PROG_TYPE_SOCKET_FILTER,
+	BPF_PROG_TYPE_TRACEPOINT,
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
+	BPF_FUNC_probe_memcmp,    /* int bpf_probe_memcmp(unsafe_ptr, safe_ptr, size) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/include/uapi/linux/perf_event.h b/include/uapi/linux/perf_event.h
index 9b79abbd1ab8..d7ba67234761 100644
--- a/include/uapi/linux/perf_event.h
+++ b/include/uapi/linux/perf_event.h
@@ -360,6 +360,7 @@ struct perf_event_attr {
 #define PERF_EVENT_IOC_SET_OUTPUT	_IO ('$', 5)
 #define PERF_EVENT_IOC_SET_FILTER	_IOW('$', 6, char *)
 #define PERF_EVENT_IOC_ID		_IOR('$', 7, __u64 *)
+#define PERF_EVENT_IOC_SET_BPF		_IOW('$', 8, __u32)
 
 enum perf_event_ioc_flags {
 	PERF_IOC_FLAG_GROUP		= 1U << 0,
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 882f835a0d85..674a8ca17190 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -42,6 +42,8 @@
 #include <linux/module.h>
 #include <linux/mman.h>
 #include <linux/compat.h>
+#include <linux/bpf.h>
+#include <linux/filter.h>
 
 #include "internal.h"
 
@@ -3283,6 +3285,7 @@ errout:
 }
 
 static void perf_event_free_filter(struct perf_event *event);
+static void perf_event_free_bpf_prog(struct perf_event *event);
 
 static void free_event_rcu(struct rcu_head *head)
 {
@@ -3292,6 +3295,7 @@ static void free_event_rcu(struct rcu_head *head)
 	if (event->ns)
 		put_pid_ns(event->ns);
 	perf_event_free_filter(event);
+	perf_event_free_bpf_prog(event);
 	kfree(event);
 }
 
@@ -3795,6 +3799,7 @@ static inline int perf_fget_light(int fd, struct fd *p)
 static int perf_event_set_output(struct perf_event *event,
 				 struct perf_event *output_event);
 static int perf_event_set_filter(struct perf_event *event, void __user *arg);
+static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd);
 
 static long perf_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
@@ -3849,6 +3854,9 @@ static long perf_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 	case PERF_EVENT_IOC_SET_FILTER:
 		return perf_event_set_filter(event, (void __user *)arg);
 
+	case PERF_EVENT_IOC_SET_BPF:
+		return perf_event_set_bpf_prog(event, arg);
+
 	default:
 		return -ENOTTY;
 	}
@@ -6266,6 +6274,45 @@ static void perf_event_free_filter(struct perf_event *event)
 	ftrace_profile_free_filter(event);
 }
 
+static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
+{
+	struct bpf_prog *prog;
+
+	if (event->attr.type != PERF_TYPE_TRACEPOINT)
+		return -EINVAL;
+
+	if (event->tp_event->prog)
+		return -EEXIST;
+
+	prog = bpf_prog_get(prog_fd);
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	if (prog->aux->prog_type != BPF_PROG_TYPE_TRACEPOINT) {
+		/* valid fd, but invalid bpf program type */
+		bpf_prog_put(prog);
+		return -EINVAL;
+	}
+
+	event->tp_event->prog = prog;
+
+	return 0;
+}
+
+static void perf_event_free_bpf_prog(struct perf_event *event)
+{
+	struct bpf_prog *prog;
+
+	if (!event->tp_event)
+		return;
+
+	prog = event->tp_event->prog;
+	if (prog) {
+		event->tp_event->prog = NULL;
+		bpf_prog_put(prog);
+	}
+}
+
 #else
 
 static inline void perf_tp_register(void)
@@ -6281,6 +6328,14 @@ static void perf_event_free_filter(struct perf_event *event)
 {
 }
 
+static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
+{
+	return -ENOENT;
+}
+
+static void perf_event_free_bpf_prog(struct perf_event *event)
+{
+}
 #endif /* CONFIG_EVENT_TRACING */
 
 #ifdef CONFIG_HAVE_HW_BREAKPOINT
diff --git a/kernel/trace/Makefile b/kernel/trace/Makefile
index 979ccde26720..54ae225e5fc6 100644
--- a/kernel/trace/Makefile
+++ b/kernel/trace/Makefile
@@ -53,6 +53,7 @@ obj-$(CONFIG_EVENT_TRACING) += trace_event_perf.o
 endif
 obj-$(CONFIG_EVENT_TRACING) += trace_events_filter.o
 obj-$(CONFIG_EVENT_TRACING) += trace_events_trigger.o
+obj-$(CONFIG_BPF_SYSCALL) += bpf_trace.o
 obj-$(CONFIG_KPROBE_EVENT) += trace_kprobe.o
 obj-$(CONFIG_TRACEPOINTS) += power-traces.o
 ifeq ($(CONFIG_PM),y)
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
new file mode 100644
index 000000000000..ec065e0a364e
--- /dev/null
+++ b/kernel/trace/bpf_trace.c
@@ -0,0 +1,145 @@
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
+unsigned int trace_call_bpf(struct bpf_prog *prog, void *ctx)
+{
+	unsigned int ret;
+
+	if (in_nmi()) /* not supported yet */
+		return 1;
+
+	rcu_read_lock();
+	ret = BPF_PROG_RUN(prog, ctx);
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(trace_call_bpf);
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
+static u64 bpf_probe_memcmp(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
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
+static struct bpf_func_proto tp_prog_funcs[] = {
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
+	[BPF_FUNC_probe_memcmp] = {
+		.func = bpf_probe_memcmp,
+		.gpl_only = false,
+		.ret_type = RET_INTEGER,
+		.arg1_type = ARG_ANYTHING,
+		.arg2_type = ARG_PTR_TO_STACK,
+		.arg3_type = ARG_CONST_STACK_SIZE,
+	},
+};
+
+static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_map_lookup_elem:
+		return &bpf_map_lookup_elem_proto;
+	case BPF_FUNC_map_update_elem:
+		return &bpf_map_update_elem_proto;
+	case BPF_FUNC_map_delete_elem:
+		return &bpf_map_delete_elem_proto;
+	default:
+		if (func_id < 0 || func_id >= ARRAY_SIZE(tp_prog_funcs))
+			return NULL;
+		return &tp_prog_funcs[func_id];
+	}
+}
+
+/* check access to argN fields of 'struct bpf_context' from program */
+static bool tp_prog_is_valid_access(int off, int size,
+				    enum bpf_access_type type)
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
+static struct bpf_verifier_ops tp_prog_ops = {
+	.get_func_proto = tp_prog_func_proto,
+	.is_valid_access = tp_prog_is_valid_access,
+};
+
+static struct bpf_prog_type_list tl = {
+	.ops = &tp_prog_ops,
+	.type = BPF_PROG_TYPE_TRACEPOINT,
+};
+
+static int __init register_tp_prog_ops(void)
+{
+	bpf_register_prog_type(&tl);
+	return 0;
+}
+late_initcall(register_tp_prog_ops);
diff --git a/kernel/trace/trace_syscalls.c b/kernel/trace/trace_syscalls.c
index c6ee36fcbf90..3487c41f4c0e 100644
--- a/kernel/trace/trace_syscalls.c
+++ b/kernel/trace/trace_syscalls.c
@@ -7,6 +7,7 @@
 #include <linux/ftrace.h>
 #include <linux/perf_event.h>
 #include <asm/syscall.h>
+#include <trace/bpf_trace.h>
 
 #include "trace_output.h"
 #include "trace.h"
@@ -545,11 +546,26 @@ static DECLARE_BITMAP(enabled_perf_exit_syscalls, NR_syscalls);
 static int sys_perf_refcount_enter;
 static int sys_perf_refcount_exit;
 
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
 static void perf_syscall_enter(void *ignore, struct pt_regs *regs, long id)
 {
 	struct syscall_metadata *sys_data;
 	struct syscall_trace_enter *rec;
 	struct hlist_head *head;
+	struct bpf_prog *prog;
 	int syscall_nr;
 	int rctx;
 	int size;
@@ -564,6 +580,15 @@ static void perf_syscall_enter(void *ignore, struct pt_regs *regs, long id)
 	if (!sys_data)
 		return;
 
+	prog = sys_data->enter_event->prog;
+	if (prog) {
+		struct bpf_context ctx;
+
+		populate_bpf_ctx(&ctx, regs);
+		if (!trace_call_bpf(prog, &ctx))
+			return;
+	}
+
 	head = this_cpu_ptr(sys_data->enter_event->perf_events);
 	if (hlist_empty(head))
 		return;
@@ -624,6 +649,7 @@ static void perf_syscall_exit(void *ignore, struct pt_regs *regs, long ret)
 	struct syscall_metadata *sys_data;
 	struct syscall_trace_exit *rec;
 	struct hlist_head *head;
+	struct bpf_prog *prog;
 	int syscall_nr;
 	int rctx;
 	int size;
@@ -638,6 +664,15 @@ static void perf_syscall_exit(void *ignore, struct pt_regs *regs, long ret)
 	if (!sys_data)
 		return;
 
+	prog = sys_data->exit_event->prog;
+	if (prog) {
+		struct bpf_context ctx = {};
+
+		ctx.arg1 = syscall_get_return_value(current, regs);
+		if (!trace_call_bpf(prog, &ctx))
+			return;
+	}
+
 	head = this_cpu_ptr(sys_data->exit_event->perf_events);
 	if (hlist_empty(head))
 		return;
-- 
1.7.9.5
