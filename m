From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [RFC PATCH v2 tip 5/7] use BPF in tracing filters
Date: Wed,  5 Feb 2014 17:10:44 -0800
Message-ID: <1391649046-4383-6-git-send-email-ast@plumgrid.com>
References: <1391649046-4383-1-git-send-email-ast@plumgrid.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Jovi Zhangwei <jovi.zhangwei@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:52930 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932202AbaBFBLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Feb 2014 20:11:03 -0500
Received: by mail-pd0-f169.google.com with SMTP id v10so1051545pde.14
        for <netdev@vger.kernel.org>; Wed, 05 Feb 2014 17:11:02 -0800 (PST)
In-Reply-To: <1391649046-4383-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Such filters can be written in C and allow safe read-only access to
any kernel data structure.
Like systemtap but with safety guaranteed by kernel.

The user can do:
cat bpf_program > /sys/kernel/debug/tracing/.../filter
if tracing event is either static or dynamic via kprobe_events.

The program can be anything as long as bpf_check() can verify its safety.
For example, the user can create kprobe_event on dst_discard()
and use logically following code inside BPF filter:
      skb = (struct sk_buff *)ctx->arg1;
      dev = bpf_load_pointer(&skb->dev);
to access 'struct net_device'
Since its prototype is 'int dst_discard(struct sk_buff *skb);'
bpf_load_pointer() will try to fetch 'dev' field of 'sk_buff'
structure and will suppress page-fault if pointer is incorrect.

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/ftrace_event.h       |    5 +
 include/trace/bpf_trace.h          |   41 ++++++++
 include/trace/ftrace.h             |   17 ++++
 kernel/trace/Kconfig               |    1 +
 kernel/trace/Makefile              |    1 +
 kernel/trace/bpf_trace_callbacks.c |  193 ++++++++++++++++++++++++++++++++++++
 kernel/trace/trace.c               |    7 ++
 kernel/trace/trace.h               |   11 +-
 kernel/trace/trace_events.c        |    9 +-
 kernel/trace/trace_events_filter.c |   61 +++++++++++-
 kernel/trace/trace_kprobe.c        |   15 ++-
 11 files changed, 356 insertions(+), 5 deletions(-)
 create mode 100644 include/trace/bpf_trace.h
 create mode 100644 kernel/trace/bpf_trace_callbacks.c

diff --git a/include/linux/ftrace_event.h b/include/linux/ftrace_event.h
index 4e4cc28..616ae01 100644
--- a/include/linux/ftrace_event.h
+++ b/include/linux/ftrace_event.h
@@ -204,6 +204,7 @@ enum {
 	TRACE_EVENT_FL_IGNORE_ENABLE_BIT,
 	TRACE_EVENT_FL_WAS_ENABLED_BIT,
 	TRACE_EVENT_FL_USE_CALL_FILTER_BIT,
+	TRACE_EVENT_FL_BPF_BIT,
 };
 
 /*
@@ -224,6 +225,7 @@ enum {
 	TRACE_EVENT_FL_IGNORE_ENABLE	= (1 << TRACE_EVENT_FL_IGNORE_ENABLE_BIT),
 	TRACE_EVENT_FL_WAS_ENABLED	= (1 << TRACE_EVENT_FL_WAS_ENABLED_BIT),
 	TRACE_EVENT_FL_USE_CALL_FILTER	= (1 << TRACE_EVENT_FL_USE_CALL_FILTER_BIT),
+	TRACE_EVENT_FL_BPF		= (1 << TRACE_EVENT_FL_BPF_BIT),
 };
 
 struct ftrace_event_call {
@@ -487,6 +489,9 @@ event_trigger_unlock_commit_regs(struct ftrace_event_file *file,
 		event_triggers_post_call(file, tt);
 }
 
+struct bpf_context;
+void filter_call_bpf(struct event_filter *filter, struct bpf_context *ctx);
+
 enum {
 	FILTER_OTHER = 0,
 	FILTER_STATIC_STRING,
diff --git a/include/trace/bpf_trace.h b/include/trace/bpf_trace.h
new file mode 100644
index 0000000..3402384
--- /dev/null
+++ b/include/trace/bpf_trace.h
@@ -0,0 +1,41 @@
+/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#ifndef _LINUX_KERNEL_BPF_TRACE_H
+#define _LINUX_KERNEL_BPF_TRACE_H
+
+struct pt_regs;
+
+struct bpf_context {
+	long arg1;
+	long arg2;
+	long arg3;
+	long arg4;
+	long arg5;
+	struct pt_regs *regs;
+};
+
+static inline void init_bpf_context(struct bpf_context *ctx, long arg1,
+				    long arg2, long arg3, long arg4, long arg5)
+{
+	ctx->arg1 = arg1;
+	ctx->arg2 = arg2;
+	ctx->arg3 = arg3;
+	ctx->arg4 = arg4;
+	ctx->arg5 = arg5;
+}
+void *bpf_load_pointer(void *unsafe_ptr);
+long bpf_memcmp(void *unsafe_ptr, void *safe_ptr, long size);
+void bpf_dump_stack(struct bpf_context *ctx);
+void bpf_trace_printk(char *fmt, long fmt_size,
+		      long arg1, long arg2, long arg3);
+void *bpf_table_lookup(struct bpf_context *ctx, long table_id, const void *key);
+long bpf_table_update(struct bpf_context *ctx, long table_id, const void *key,
+		      const void *leaf);
+
+extern struct bpf_callbacks bpf_trace_cb;
+
+#endif /* _LINUX_KERNEL_BPF_TRACE_H */
diff --git a/include/trace/ftrace.h b/include/trace/ftrace.h
index 1a8b28d..2348afd 100644
--- a/include/trace/ftrace.h
+++ b/include/trace/ftrace.h
@@ -17,6 +17,8 @@
  */
 
 #include <linux/ftrace_event.h>
+#include <linux/kexec.h>
+#include <trace/bpf_trace.h>
 
 /*
  * DECLARE_EVENT_CLASS can be used to add a generic function
@@ -556,6 +558,21 @@ ftrace_raw_event_##call(void *__data, proto)				\
 	if (ftrace_trigger_soft_disabled(ftrace_file))			\
 		return;							\
 									\
+	if (unlikely(ftrace_file->flags & FTRACE_EVENT_FL_FILTERED) &&	\
+	    unlikely(ftrace_file->event_call->flags & TRACE_EVENT_FL_BPF)) { \
+		struct bpf_context _ctx;				\
+		struct pt_regs _regs;					\
+		void (*_fn)(struct bpf_context *, proto,		\
+			    long, long, long, long);			\
+		crash_setup_regs(&_regs, NULL);				\
+		_fn = (void (*)(struct bpf_context *, proto, long, long,\
+				long, long))init_bpf_context;		\
+		_fn(&_ctx, args, 0, 0, 0, 0);				\
+		_ctx.regs = &_regs;					\
+		filter_call_bpf(ftrace_file->filter, &_ctx);		\
+		return;							\
+	}								\
+									\
 	local_save_flags(irq_flags);					\
 	pc = preempt_count();						\
 									\
diff --git a/kernel/trace/Kconfig b/kernel/trace/Kconfig
index 015f85a..2809cd1 100644
--- a/kernel/trace/Kconfig
+++ b/kernel/trace/Kconfig
@@ -80,6 +80,7 @@ config FTRACE_NMI_ENTER
 
 config EVENT_TRACING
 	select CONTEXT_SWITCH_TRACER
+	select BPF64
 	bool
 
 config CONTEXT_SWITCH_TRACER
diff --git a/kernel/trace/Makefile b/kernel/trace/Makefile
index 1378e84..dc4fb44 100644
--- a/kernel/trace/Makefile
+++ b/kernel/trace/Makefile
@@ -51,6 +51,7 @@ obj-$(CONFIG_EVENT_TRACING) += trace_event_perf.o
 endif
 obj-$(CONFIG_EVENT_TRACING) += trace_events_filter.o
 obj-$(CONFIG_EVENT_TRACING) += trace_events_trigger.o
+obj-$(CONFIG_EVENT_TRACING) += bpf_trace_callbacks.o
 obj-$(CONFIG_KPROBE_EVENT) += trace_kprobe.o
 obj-$(CONFIG_TRACEPOINTS) += power-traces.o
 ifeq ($(CONFIG_PM_RUNTIME),y)
diff --git a/kernel/trace/bpf_trace_callbacks.c b/kernel/trace/bpf_trace_callbacks.c
new file mode 100644
index 0000000..2b7955d
--- /dev/null
+++ b/kernel/trace/bpf_trace_callbacks.c
@@ -0,0 +1,193 @@
+/* Copyright (c) 2011-2014 PLUMgrid, http://plumgrid.com
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ */
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/bpf_jit.h>
+#include <linux/uaccess.h>
+#include <trace/bpf_trace.h>
+#include "trace.h"
+
+#define MAX_CTX_OFF sizeof(struct bpf_context)
+
+static const struct bpf_context_access ctx_access[MAX_CTX_OFF] = {
+	[offsetof(struct bpf_context, arg1)] = {
+		FIELD_SIZEOF(struct bpf_context, arg1),
+		BPF_READ
+	},
+	[offsetof(struct bpf_context, arg2)] = {
+		FIELD_SIZEOF(struct bpf_context, arg2),
+		BPF_READ
+	},
+	[offsetof(struct bpf_context, arg3)] = {
+		FIELD_SIZEOF(struct bpf_context, arg3),
+		BPF_READ
+	},
+	[offsetof(struct bpf_context, arg4)] = {
+		FIELD_SIZEOF(struct bpf_context, arg4),
+		BPF_READ
+	},
+	[offsetof(struct bpf_context, arg5)] = {
+		FIELD_SIZEOF(struct bpf_context, arg5),
+		BPF_READ
+	},
+};
+
+static const struct bpf_context_access *get_context_access(int off)
+{
+	if (off >= MAX_CTX_OFF)
+		return NULL;
+	return &ctx_access[off];
+}
+
+void *bpf_load_pointer(void *unsafe_ptr)
+{
+	void *ptr = NULL;
+
+	probe_kernel_read(&ptr, unsafe_ptr, sizeof(void *));
+	return ptr;
+}
+
+long bpf_memcmp(void *unsafe_ptr, void *safe_ptr, long size)
+{
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
+void bpf_dump_stack(struct bpf_context *ctx)
+{
+	unsigned long flags;
+
+	local_save_flags(flags);
+
+	__trace_stack_regs(flags, 0, preempt_count(), ctx->regs);
+}
+
+/*
+ * limited trace_printk()
+ * only %d %u %p %x conversion specifiers allowed
+ */
+void bpf_trace_printk(char *fmt, long fmt_size, long arg1, long arg2, long arg3)
+{
+	int fmt_cnt = 0;
+	int i;
+
+	/*
+	 * bpf_check() guarantees that fmt points to bpf program stack and
+	 * fmt_size bytes of it were initialized by bpf program
+	 */
+	if (fmt[fmt_size - 1] != 0)
+		return;
+
+	for (i = 0; i < fmt_size; i++)
+		if (fmt[i] == '%') {
+			if (i + 1 >= fmt_size)
+				return;
+			if (fmt[i + 1] != 'p' && fmt[i + 1] != 'd' &&
+			    fmt[i + 1] != 'u' && fmt[i + 1] != 'x')
+				return;
+			fmt_cnt++;
+		}
+	if (fmt_cnt > 3)
+		return;
+	__trace_printk((unsigned long)__builtin_return_address(3), fmt,
+		       arg1, arg2, arg3);
+}
+
+
+static const struct bpf_func_proto *get_func_proto(char *strtab, int id)
+{
+	if (!strcmp(strtab + id, "bpf_load_pointer")) {
+		static const struct bpf_func_proto proto = {RET_INTEGER};
+		return &proto;
+	}
+	if (!strcmp(strtab + id, "bpf_memcmp")) {
+		static const struct bpf_func_proto proto = {RET_INTEGER,
+			INVALID_PTR, PTR_TO_STACK_IMM,
+			CONST_ARG_STACK_IMM_SIZE};
+		return &proto;
+	}
+	if (!strcmp(strtab + id, "bpf_dump_stack")) {
+		static const struct bpf_func_proto proto = {RET_VOID,
+			PTR_TO_CTX};
+		return &proto;
+	}
+	if (!strcmp(strtab + id, "bpf_trace_printk")) {
+		static const struct bpf_func_proto proto = {RET_VOID,
+			PTR_TO_STACK_IMM, CONST_ARG_STACK_IMM_SIZE};
+		return &proto;
+	}
+	if (!strcmp(strtab + id, "bpf_table_lookup")) {
+		static const struct bpf_func_proto proto = {
+			PTR_TO_TABLE_CONDITIONAL, PTR_TO_CTX,
+			CONST_ARG_TABLE_ID, PTR_TO_STACK_IMM_TABLE_KEY};
+		return &proto;
+	}
+	if (!strcmp(strtab + id, "bpf_table_update")) {
+		static const struct bpf_func_proto proto = {RET_INTEGER,
+			PTR_TO_CTX, CONST_ARG_TABLE_ID,
+			PTR_TO_STACK_IMM_TABLE_KEY,
+			PTR_TO_STACK_IMM_TABLE_ELEM};
+		return &proto;
+	}
+	return NULL;
+}
+
+static void execute_func(char *strtab, int id, u64 *regs)
+{
+	regs[R0] = 0;
+
+	/*
+	 * strcmp-approach is not efficient.
+	 * TODO: optimize it for poor archs that don't have JIT yet
+	 */
+	if (!strcmp(strtab + id, "bpf_load_pointer")) {
+		regs[R0] = (u64)bpf_load_pointer((void *)regs[R1]);
+	} else if (!strcmp(strtab + id, "bpf_memcmp")) {
+		regs[R0] = (u64)bpf_memcmp((void *)regs[R1], (void *)regs[R2],
+					   (long)regs[R3]);
+	} else if (!strcmp(strtab + id, "bpf_dump_stack")) {
+		bpf_dump_stack((struct bpf_context *)regs[R1]);
+	} else if (!strcmp(strtab + id, "bpf_trace_printk")) {
+		bpf_trace_printk((char *)regs[R1], (long)regs[R2],
+				 (long)regs[R3], (long)regs[R4],
+				 (long)regs[R5]);
+	} else {
+		pr_err_once("trace cannot execute unknown bpf function %d '%s'\n",
+			    id, strtab + id);
+	}
+}
+
+static void *jit_select_func(char *strtab, int id)
+{
+	if (!strcmp(strtab + id, "bpf_load_pointer"))
+		return bpf_load_pointer;
+
+	if (!strcmp(strtab + id, "bpf_memcmp"))
+		return bpf_memcmp;
+
+	if (!strcmp(strtab + id, "bpf_dump_stack"))
+		return bpf_dump_stack;
+
+	if (!strcmp(strtab + id, "bpf_trace_printk"))
+		return bpf_trace_printk;
+
+	return NULL;
+}
+
+struct bpf_callbacks bpf_trace_cb = {
+	execute_func, jit_select_func, get_func_proto, get_context_access
+};
+
diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index 815c878..1a7762b 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -1791,6 +1791,13 @@ void __trace_stack(struct trace_array *tr, unsigned long flags, int skip,
 	__ftrace_trace_stack(tr->trace_buffer.buffer, flags, skip, pc, NULL);
 }
 
+void __trace_stack_regs(unsigned long flags, int skip, int pc,
+			struct pt_regs *regs)
+{
+	__ftrace_trace_stack(global_trace.trace_buffer.buffer, flags, skip,
+			     pc, regs);
+}
+
 /**
  * trace_dump_stack - record a stack back trace in the trace buffer
  * @skip: Number of functions to skip (helper handlers)
diff --git a/kernel/trace/trace.h b/kernel/trace/trace.h
index 02b592f..fa7db5f 100644
--- a/kernel/trace/trace.h
+++ b/kernel/trace/trace.h
@@ -619,6 +619,8 @@ void ftrace_trace_userstack(struct ring_buffer *buffer, unsigned long flags,
 
 void __trace_stack(struct trace_array *tr, unsigned long flags, int skip,
 		   int pc);
+void __trace_stack_regs(unsigned long flags, int skip, int pc,
+			struct pt_regs *regs);
 #else
 static inline void ftrace_trace_stack(struct ring_buffer *buffer,
 				      unsigned long flags, int skip, int pc)
@@ -640,6 +642,10 @@ static inline void __trace_stack(struct trace_array *tr, unsigned long flags,
 				 int skip, int pc)
 {
 }
+static inline void __trace_stack_regs(unsigned long flags, int skip, int pc,
+				      struct pt_regs *regs)
+{
+}
 #endif /* CONFIG_STACKTRACE */
 
 extern cycle_t ftrace_now(int cpu);
@@ -939,12 +945,15 @@ struct ftrace_event_field {
 	int			is_signed;
 };
 
+struct bpf_program;
+
 struct event_filter {
 	int			n_preds;	/* Number assigned */
 	int			a_preds;	/* allocated */
 	struct filter_pred	*preds;
 	struct filter_pred	*root;
 	char			*filter_string;
+	struct bpf_program	*prog;
 };
 
 struct event_subsystem {
@@ -1017,7 +1026,7 @@ filter_parse_regex(char *buff, int len, char **search, int *not);
 extern void print_event_filter(struct ftrace_event_file *file,
 			       struct trace_seq *s);
 extern int apply_event_filter(struct ftrace_event_file *file,
-			      char *filter_string);
+			      char *filter_string, int filter_len);
 extern int apply_subsystem_event_filter(struct ftrace_subsystem_dir *dir,
 					char *filter_string);
 extern void print_subsystem_event_filter(struct event_subsystem *system,
diff --git a/kernel/trace/trace_events.c b/kernel/trace/trace_events.c
index e71ffd4..b6aadc3 100644
--- a/kernel/trace/trace_events.c
+++ b/kernel/trace/trace_events.c
@@ -1042,9 +1042,16 @@ event_filter_write(struct file *filp, const char __user *ubuf, size_t cnt,
 	mutex_lock(&event_mutex);
 	file = event_file_data(filp);
 	if (file)
-		err = apply_event_filter(file, buf);
+		err = apply_event_filter(file, buf, cnt);
 	mutex_unlock(&event_mutex);
 
+	if (file->event_call->flags & TRACE_EVENT_FL_BPF)
+		/*
+		 * allocate per-cpu printk buffers, since BPF program
+		 * might be calling bpf_trace_printk
+		 */
+		trace_printk_init_buffers();
+
 	free_page((unsigned long) buf);
 	if (err < 0)
 		return err;
diff --git a/kernel/trace/trace_events_filter.c b/kernel/trace/trace_events_filter.c
index 8a86319..d4fb09c 100644
--- a/kernel/trace/trace_events_filter.c
+++ b/kernel/trace/trace_events_filter.c
@@ -23,6 +23,8 @@
 #include <linux/mutex.h>
 #include <linux/perf_event.h>
 #include <linux/slab.h>
+#include <linux/bpf_jit.h>
+#include <trace/bpf_trace.h>
 
 #include "trace.h"
 #include "trace_output.h"
@@ -535,6 +537,20 @@ static int filter_match_preds_cb(enum move_type move, struct filter_pred *pred,
 	return WALK_PRED_DEFAULT;
 }
 
+void filter_call_bpf(struct event_filter *filter, struct bpf_context *ctx)
+{
+	BUG_ON(!filter || !filter->prog);
+
+	if (!filter->prog->jit_image) {
+		pr_warn_once("BPF jit image is not available. Fallback to emulation\n");
+		bpf_run(filter->prog, ctx);
+		return;
+	}
+
+	filter->prog->jit_image(ctx);
+}
+EXPORT_SYMBOL_GPL(filter_call_bpf);
+
 /* return 1 if event matches, 0 otherwise (discard) */
 int filter_match_preds(struct event_filter *filter, void *rec)
 {
@@ -794,6 +810,7 @@ static void __free_filter(struct event_filter *filter)
 	if (!filter)
 		return;
 
+	bpf_free(filter->prog);
 	__free_preds(filter);
 	kfree(filter->filter_string);
 	kfree(filter);
@@ -1898,6 +1915,37 @@ static int create_filter_start(char *filter_str, bool set_str,
 	return err;
 }
 
+static int create_filter_bpf(char *filter_str, int filter_len,
+			     struct event_filter **filterp)
+{
+	struct event_filter *filter;
+	int err = 0;
+
+	*filterp = NULL;
+
+	filter = __alloc_filter();
+	if (filter)
+		err = replace_filter_string(filter, "bpf");
+
+	if (!filter || err) {
+		__free_filter(filter);
+		return -ENOMEM;
+	}
+
+	err = bpf_load_image(filter_str, filter_len, &bpf_trace_cb,
+			     &filter->prog);
+
+	if (err) {
+		pr_err("failed to load bpf %d\n", err);
+		__free_filter(filter);
+		return -EACCES;
+	}
+
+	*filterp = filter;
+
+	return err;
+}
+
 static void create_filter_finish(struct filter_parse_state *ps)
 {
 	if (ps) {
@@ -1985,7 +2033,8 @@ static int create_system_filter(struct event_subsystem *system,
 }
 
 /* caller must hold event_mutex */
-int apply_event_filter(struct ftrace_event_file *file, char *filter_string)
+int apply_event_filter(struct ftrace_event_file *file, char *filter_string,
+		       int filter_len)
 {
 	struct ftrace_event_call *call = file->event_call;
 	struct event_filter *filter;
@@ -2007,7 +2056,15 @@ int apply_event_filter(struct ftrace_event_file *file, char *filter_string)
 		return 0;
 	}
 
-	err = create_filter(call, filter_string, true, &filter);
+	if (!strcmp(filter_string, "bpf")) {
+		err = create_filter_bpf(filter_string, filter_len, &filter);
+		if (!err)
+			call->flags |= TRACE_EVENT_FL_BPF;
+	} else {
+		err = create_filter(call, filter_string, true, &filter);
+		if (!err)
+			call->flags &= ~TRACE_EVENT_FL_BPF;
+	}
 
 	/*
 	 * Always swap the call filter with the new filter
diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
index bdbae45..1e508d2 100644
--- a/kernel/trace/trace_kprobe.c
+++ b/kernel/trace/trace_kprobe.c
@@ -19,7 +19,7 @@
 
 #include <linux/module.h>
 #include <linux/uaccess.h>
-
+#include <trace/bpf_trace.h>
 #include "trace_probe.h"
 
 #define KPROBE_EVENT_SYSTEM "kprobes"
@@ -936,6 +936,19 @@ __kprobe_trace_func(struct trace_kprobe *tk, struct pt_regs *regs,
 	if (ftrace_trigger_soft_disabled(ftrace_file))
 		return;
 
+	if (unlikely(ftrace_file->flags & FTRACE_EVENT_FL_FILTERED) &&
+	    unlikely(ftrace_file->event_call->flags & TRACE_EVENT_FL_BPF)) {
+		struct bpf_context ctx;
+		ctx.regs = regs;
+		ctx.arg1 = regs_get_argument_nth(regs, 0);
+		ctx.arg2 = regs_get_argument_nth(regs, 1);
+		ctx.arg3 = regs_get_argument_nth(regs, 2);
+		ctx.arg4 = regs_get_argument_nth(regs, 3);
+		ctx.arg5 = regs_get_argument_nth(regs, 4);
+		filter_call_bpf(ftrace_file->filter, &ctx);
+		return;
+	}
+
 	local_save_flags(irq_flags);
 	pc = preempt_count();
 
-- 
1.7.9.5
