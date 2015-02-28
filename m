From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v4 tip 2/7] tracing: attach BPF programs to kprobes
Date: Fri, 27 Feb 2015 16:08:50 -0800
Message-ID: <1425082135-11967-3-git-send-email-ast@plumgrid.com>
References: <1425082135-11967-1-git-send-email-ast@plumgrid.com>
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425082135-11967-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

User interface:
struct perf_event_attr attr = {.type = PERF_TYPE_TRACEPOINT, .config = event_id, ...};
event_fd = perf_event_open(&attr,...);
ioctl(event_fd, PERF_EVENT_IOC_SET_BPF, prog_fd);

prog_fd is a file descriptor associated with BPF program previously loaded.
event_id is an ID of created kprobe

close(event_fd) - automatically detaches BPF program from it

BPF programs can call in-kernel helper functions to:
- lookup/update/delete elements in maps
- probe_read - wraper of probe_kernel_read() used to access any kernel
  data structures

BPF programs receive 'struct pt_regs *' as an input
('struct pt_regs' is architecture dependent)

Note, kprobes are _not_ a stable kernel ABI, so bpf programs attached to
kprobes must be recompiled for every kernel version and user must supply correct
LINUX_VERSION_CODE in attr.kern_version during bpf_prog_load() call.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/ftrace_event.h    |   14 ++++++
 include/uapi/linux/bpf.h        |    3 ++
 include/uapi/linux/perf_event.h |    1 +
 kernel/bpf/syscall.c            |    7 ++-
 kernel/events/core.c            |   59 +++++++++++++++++++++++
 kernel/trace/Makefile           |    1 +
 kernel/trace/bpf_trace.c        |   99 +++++++++++++++++++++++++++++++++++++++
 kernel/trace/trace_kprobe.c     |   10 +++-
 8 files changed, 192 insertions(+), 2 deletions(-)
 create mode 100644 kernel/trace/bpf_trace.c

diff --git a/include/linux/ftrace_event.h b/include/linux/ftrace_event.h
index c674ee8f7fca..0aa535bc9f05 100644
--- a/include/linux/ftrace_event.h
+++ b/include/linux/ftrace_event.h
@@ -13,6 +13,7 @@ struct trace_array;
 struct trace_buffer;
 struct tracer;
 struct dentry;
+struct bpf_prog;
 
 struct trace_print_flags {
 	unsigned long		mask;
@@ -252,6 +253,7 @@ enum {
 	TRACE_EVENT_FL_WAS_ENABLED_BIT,
 	TRACE_EVENT_FL_USE_CALL_FILTER_BIT,
 	TRACE_EVENT_FL_TRACEPOINT_BIT,
+	TRACE_EVENT_FL_KPROBE_BIT,
 };
 
 /*
@@ -265,6 +267,7 @@ enum {
  *                     it is best to clear the buffers that used it).
  *  USE_CALL_FILTER - For ftrace internal events, don't use file filter
  *  TRACEPOINT    - Event is a tracepoint
+ *  KPROBE        - Event is a kprobe
  */
 enum {
 	TRACE_EVENT_FL_FILTERED		= (1 << TRACE_EVENT_FL_FILTERED_BIT),
@@ -274,6 +277,7 @@ enum {
 	TRACE_EVENT_FL_WAS_ENABLED	= (1 << TRACE_EVENT_FL_WAS_ENABLED_BIT),
 	TRACE_EVENT_FL_USE_CALL_FILTER	= (1 << TRACE_EVENT_FL_USE_CALL_FILTER_BIT),
 	TRACE_EVENT_FL_TRACEPOINT	= (1 << TRACE_EVENT_FL_TRACEPOINT_BIT),
+	TRACE_EVENT_FL_KPROBE		= (1 << TRACE_EVENT_FL_KPROBE_BIT),
 };
 
 struct ftrace_event_call {
@@ -303,6 +307,7 @@ struct ftrace_event_call {
 #ifdef CONFIG_PERF_EVENTS
 	int				perf_refcount;
 	struct hlist_head __percpu	*perf_events;
+	struct bpf_prog			*prog;
 
 	int	(*perf_perm)(struct ftrace_event_call *,
 			     struct perf_event *);
@@ -548,6 +553,15 @@ event_trigger_unlock_commit_regs(struct ftrace_event_file *file,
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
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 45da7ec7d274..4486d36d2e9e 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -118,6 +118,7 @@ enum bpf_map_type {
 enum bpf_prog_type {
 	BPF_PROG_TYPE_UNSPEC,
 	BPF_PROG_TYPE_SOCKET_FILTER,
+	BPF_PROG_TYPE_KPROBE,
 };
 
 /* flags for BPF_MAP_UPDATE_ELEM command */
@@ -151,6 +152,7 @@ union bpf_attr {
 		__u32		log_level;	/* verbosity level of verifier */
 		__u32		log_size;	/* size of user buffer */
 		__aligned_u64	log_buf;	/* user supplied buffer */
+		__u32		kern_version;	/* checked when type=kprobe */
 	};
 } __attribute__((aligned(8)));
 
@@ -162,6 +164,7 @@ enum bpf_func_id {
 	BPF_FUNC_map_lookup_elem, /* void *map_lookup_elem(&map, &key) */
 	BPF_FUNC_map_update_elem, /* int map_update_elem(&map, &key, &value, flags) */
 	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
+	BPF_FUNC_probe_read,      /* int bpf_probe_read(void *dst, int size, void *src) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/include/uapi/linux/perf_event.h b/include/uapi/linux/perf_event.h
index 3c8b45de57ec..ad4dade2a502 100644
--- a/include/uapi/linux/perf_event.h
+++ b/include/uapi/linux/perf_event.h
@@ -382,6 +382,7 @@ struct perf_event_attr {
 #define PERF_EVENT_IOC_SET_OUTPUT	_IO ('$', 5)
 #define PERF_EVENT_IOC_SET_FILTER	_IOW('$', 6, char *)
 #define PERF_EVENT_IOC_ID		_IOR('$', 7, __u64 *)
+#define PERF_EVENT_IOC_SET_BPF		_IOW('$', 8, __u32)
 
 enum perf_event_ioc_flags {
 	PERF_IOC_FLAG_GROUP		= 1U << 0,
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 536edc2be307..504c10b990ef 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -16,6 +16,7 @@
 #include <linux/file.h>
 #include <linux/license.h>
 #include <linux/filter.h>
+#include <linux/version.h>
 
 static LIST_HEAD(bpf_map_types);
 
@@ -467,7 +468,7 @@ struct bpf_prog *bpf_prog_get(u32 ufd)
 }
 
 /* last field in 'union bpf_attr' used by this command */
-#define	BPF_PROG_LOAD_LAST_FIELD log_buf
+#define	BPF_PROG_LOAD_LAST_FIELD kern_version
 
 static int bpf_prog_load(union bpf_attr *attr)
 {
@@ -492,6 +493,10 @@ static int bpf_prog_load(union bpf_attr *attr)
 	if (attr->insn_cnt >= BPF_MAXINSNS)
 		return -EINVAL;
 
+	if (type == BPF_PROG_TYPE_KPROBE &&
+	    attr->kern_version != LINUX_VERSION_CODE)
+		return -EINVAL;
+
 	/* plain bpf_prog allocation */
 	prog = bpf_prog_alloc(bpf_prog_size(attr->insn_cnt), GFP_USER);
 	if (!prog)
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 89f0f16d55f9..9cf449bae28a 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -42,6 +42,8 @@
 #include <linux/module.h>
 #include <linux/mman.h>
 #include <linux/compat.h>
+#include <linux/bpf.h>
+#include <linux/filter.h>
 
 #include "internal.h"
 
@@ -3402,6 +3404,7 @@ errout:
 }
 
 static void perf_event_free_filter(struct perf_event *event);
+static void perf_event_free_bpf_prog(struct perf_event *event);
 
 static void free_event_rcu(struct rcu_head *head)
 {
@@ -3411,6 +3414,7 @@ static void free_event_rcu(struct rcu_head *head)
 	if (event->ns)
 		put_pid_ns(event->ns);
 	perf_event_free_filter(event);
+	perf_event_free_bpf_prog(event);
 	kfree(event);
 }
 
@@ -3923,6 +3927,7 @@ static inline int perf_fget_light(int fd, struct fd *p)
 static int perf_event_set_output(struct perf_event *event,
 				 struct perf_event *output_event);
 static int perf_event_set_filter(struct perf_event *event, void __user *arg);
+static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd);
 
 static long _perf_ioctl(struct perf_event *event, unsigned int cmd, unsigned long arg)
 {
@@ -3976,6 +3981,9 @@ static long _perf_ioctl(struct perf_event *event, unsigned int cmd, unsigned lon
 	case PERF_EVENT_IOC_SET_FILTER:
 		return perf_event_set_filter(event, (void __user *)arg);
 
+	case PERF_EVENT_IOC_SET_BPF:
+		return perf_event_set_bpf_prog(event, arg);
+
 	default:
 		return -ENOTTY;
 	}
@@ -6436,6 +6444,49 @@ static void perf_event_free_filter(struct perf_event *event)
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
+	if (!(event->tp_event->flags & TRACE_EVENT_FL_KPROBE))
+		/* bpf programs can only be attached to kprobes */
+		return -EINVAL;
+
+	prog = bpf_prog_get(prog_fd);
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	if (prog->aux->prog_type != BPF_PROG_TYPE_KPROBE) {
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
@@ -6451,6 +6502,14 @@ static void perf_event_free_filter(struct perf_event *event)
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
index 98f26588255e..c575a300103b 100644
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
index 000000000000..bcce9b238dad
--- /dev/null
+++ b/kernel/trace/bpf_trace.c
@@ -0,0 +1,99 @@
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
+static u64 bpf_probe_read(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	void *dst = (void *) (long) r1;
+	int size = (int) r2;
+	void *unsafe_ptr = (void *) (long) r3;
+
+	return probe_kernel_read(dst, unsafe_ptr, size);
+}
+
+static struct bpf_func_proto kprobe_prog_funcs[] = {
+	[BPF_FUNC_probe_read] = {
+		.func = bpf_probe_read,
+		.gpl_only = true,
+		.ret_type = RET_INTEGER,
+		.arg1_type = ARG_PTR_TO_STACK,
+		.arg2_type = ARG_CONST_STACK_SIZE,
+		.arg3_type = ARG_ANYTHING,
+	},
+};
+
+static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_map_lookup_elem:
+		return &bpf_map_lookup_elem_proto;
+	case BPF_FUNC_map_update_elem:
+		return &bpf_map_update_elem_proto;
+	case BPF_FUNC_map_delete_elem:
+		return &bpf_map_delete_elem_proto;
+	default:
+		if (func_id < 0 || func_id >= ARRAY_SIZE(kprobe_prog_funcs))
+			return NULL;
+		return &kprobe_prog_funcs[func_id];
+	}
+}
+
+/* bpf+kprobe programs can access fields of 'struct pt_regs' */
+static bool kprobe_prog_is_valid_access(int off, int size, enum bpf_access_type type)
+{
+	/* check bounds */
+	if (off < 0 || off >= sizeof(struct pt_regs))
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
+static struct bpf_verifier_ops kprobe_prog_ops = {
+	.get_func_proto = kprobe_prog_func_proto,
+	.is_valid_access = kprobe_prog_is_valid_access,
+};
+
+static struct bpf_prog_type_list kprobe_tl = {
+	.ops = &kprobe_prog_ops,
+	.type = BPF_PROG_TYPE_KPROBE,
+};
+
+static int __init register_kprobe_prog_ops(void)
+{
+	bpf_register_prog_type(&kprobe_tl);
+	return 0;
+}
+late_initcall(register_kprobe_prog_ops);
diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
index d73f565b4e06..dc3462507d7c 100644
--- a/kernel/trace/trace_kprobe.c
+++ b/kernel/trace/trace_kprobe.c
@@ -1134,11 +1134,15 @@ static void
 kprobe_perf_func(struct trace_kprobe *tk, struct pt_regs *regs)
 {
 	struct ftrace_event_call *call = &tk->tp.call;
+	struct bpf_prog *prog = call->prog;
 	struct kprobe_trace_entry_head *entry;
 	struct hlist_head *head;
 	int size, __size, dsize;
 	int rctx;
 
+	if (prog && !trace_call_bpf(prog, regs))
+		return;
+
 	head = this_cpu_ptr(call->perf_events);
 	if (hlist_empty(head))
 		return;
@@ -1165,11 +1169,15 @@ kretprobe_perf_func(struct trace_kprobe *tk, struct kretprobe_instance *ri,
 		    struct pt_regs *regs)
 {
 	struct ftrace_event_call *call = &tk->tp.call;
+	struct bpf_prog *prog = call->prog;
 	struct kretprobe_trace_entry_head *entry;
 	struct hlist_head *head;
 	int size, __size, dsize;
 	int rctx;
 
+	if (prog && !trace_call_bpf(prog, regs))
+		return;
+
 	head = this_cpu_ptr(call->perf_events);
 	if (hlist_empty(head))
 		return;
@@ -1286,7 +1294,7 @@ static int register_kprobe_event(struct trace_kprobe *tk)
 		kfree(call->print_fmt);
 		return -ENODEV;
 	}
-	call->flags = 0;
+	call->flags = TRACE_EVENT_FL_KPROBE;
 	call->class->reg = kprobe_register;
 	call->data = tk;
 	ret = trace_add_event_call(call);
-- 
1.7.9.5
