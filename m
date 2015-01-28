From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 linux-trace 7/8] tracing: attach eBPF programs to kprobe/kretprobe
Date: Tue, 27 Jan 2015 20:06:12 -0800
Message-ID: <1422417973-10195-8-git-send-email-ast@plumgrid.com>
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

introduce new type of eBPF programs BPF_PROG_TYPE_KPROBE_FILTER.
Such programs are allowed to call the same helper functions
as tracing filters, but bpf_context is different:
For tracing filters bpf_context is 6 arguments of tracepoints or syscalls
For kprobe filters bpf_context == pt_regs

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/ftrace_event.h       |    2 ++
 include/uapi/linux/bpf.h           |    1 +
 kernel/trace/bpf_trace.c           |   39 ++++++++++++++++++++++++++++++++++++
 kernel/trace/trace_events_filter.c |   10 ++++++---
 kernel/trace/trace_kprobe.c        |   11 +++++++++-
 5 files changed, 59 insertions(+), 4 deletions(-)

diff --git a/include/linux/ftrace_event.h b/include/linux/ftrace_event.h
index 79de230b7df3..b057ca0c5539 100644
--- a/include/linux/ftrace_event.h
+++ b/include/linux/ftrace_event.h
@@ -249,6 +249,7 @@ enum {
 	TRACE_EVENT_FL_USE_CALL_FILTER_BIT,
 	TRACE_EVENT_FL_TRACEPOINT_BIT,
 	TRACE_EVENT_FL_BPF_BIT,
+	TRACE_EVENT_FL_KPROBE_BIT,
 };
 
 /*
@@ -272,6 +273,7 @@ enum {
 	TRACE_EVENT_FL_USE_CALL_FILTER	= (1 << TRACE_EVENT_FL_USE_CALL_FILTER_BIT),
 	TRACE_EVENT_FL_TRACEPOINT	= (1 << TRACE_EVENT_FL_TRACEPOINT_BIT),
 	TRACE_EVENT_FL_BPF		= (1 << TRACE_EVENT_FL_BPF_BIT),
+	TRACE_EVENT_FL_KPROBE		= (1 << TRACE_EVENT_FL_KPROBE_BIT),
 };
 
 struct ftrace_event_call {
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 227a4e404726..974932b8b5c6 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -119,6 +119,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_UNSPEC,
 	BPF_PROG_TYPE_SOCKET_FILTER,
 	BPF_PROG_TYPE_TRACING_FILTER,
+	BPF_PROG_TYPE_KPROBE_FILTER,
 };
 
 /* flags for BPF_MAP_UPDATE_ELEM command */
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 1c07f55702d6..0fc50d3ecde1 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -137,3 +137,42 @@ static int __init register_tracing_filter_ops(void)
 	return 0;
 }
 late_initcall(register_tracing_filter_ops);
+
+/* check access to fields of 'struct pt_regs' from BPF program */
+static bool kprobe_filter_is_valid_access(int off, int size, enum bpf_access_type type)
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
+/* kprobe filter programs are allowed to call the same helper functions
+ * as tracing filters, but bpf_context is different:
+ * For tracing filters bpf_context is 6 arguments of tracepoints or syscalls
+ * For kprobe filters bpf_context == pt_regs
+ */
+static struct bpf_verifier_ops kprobe_filter_ops = {
+	.get_func_proto = tracing_filter_func_proto,
+	.is_valid_access = kprobe_filter_is_valid_access,
+};
+
+static struct bpf_prog_type_list kprobe_tl = {
+	.ops = &kprobe_filter_ops,
+	.type = BPF_PROG_TYPE_KPROBE_FILTER,
+};
+
+static int __init register_kprobe_filter_ops(void)
+{
+	bpf_register_prog_type(&kprobe_tl);
+	return 0;
+}
+late_initcall(register_kprobe_filter_ops);
diff --git a/kernel/trace/trace_events_filter.c b/kernel/trace/trace_events_filter.c
index e0303b3cc9fb..e4a0268f2810 100644
--- a/kernel/trace/trace_events_filter.c
+++ b/kernel/trace/trace_events_filter.c
@@ -1894,7 +1894,8 @@ static int create_filter_start(char *filter_str, bool set_str,
 	return err;
 }
 
-static int create_filter_bpf(char *filter_str, struct event_filter **filterp)
+static int create_filter_bpf(struct ftrace_event_call *call, char *filter_str,
+			     struct event_filter **filterp)
 {
 	struct event_filter *filter;
 	struct bpf_prog *prog;
@@ -1923,7 +1924,10 @@ static int create_filter_bpf(char *filter_str, struct event_filter **filterp)
 
 	filter->prog = prog;
 
-	if (prog->aux->prog_type != BPF_PROG_TYPE_TRACING_FILTER) {
+	if (((call->flags & TRACE_EVENT_FL_KPROBE) &&
+	     prog->aux->prog_type != BPF_PROG_TYPE_KPROBE_FILTER) ||
+	    (!(call->flags & TRACE_EVENT_FL_KPROBE) &&
+	     prog->aux->prog_type != BPF_PROG_TYPE_TRACING_FILTER)) {
 		/* valid fd, but invalid bpf program type */
 		err = -EINVAL;
 		goto free_filter;
@@ -2054,7 +2058,7 @@ int apply_event_filter(struct ftrace_event_file *file, char *filter_string)
 	 */
 	if (memcmp(filter_string, "bpf", 3) == 0 && filter_string[3] != 0 &&
 	    filter_string[4] != 0) {
-		err = create_filter_bpf(filter_string, &filter);
+		err = create_filter_bpf(call, filter_string, &filter);
 		if (!err)
 			file->flags |= TRACE_EVENT_FL_BPF;
 	} else {
diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
index 5edb518be345..ec62dd8cb35f 100644
--- a/kernel/trace/trace_kprobe.c
+++ b/kernel/trace/trace_kprobe.c
@@ -19,6 +19,7 @@
 
 #include <linux/module.h>
 #include <linux/uaccess.h>
+#include <trace/bpf_trace.h>
 
 #include "trace_probe.h"
 
@@ -930,6 +931,10 @@ __kprobe_trace_func(struct trace_kprobe *tk, struct pt_regs *regs,
 	if (ftrace_trigger_soft_disabled(ftrace_file))
 		return;
 
+	if (ftrace_file->flags & TRACE_EVENT_FL_BPF)
+		if (!trace_filter_call_bpf(ftrace_file->filter, regs))
+			return;
+
 	local_save_flags(irq_flags);
 	pc = preempt_count();
 
@@ -978,6 +983,10 @@ __kretprobe_trace_func(struct trace_kprobe *tk, struct kretprobe_instance *ri,
 	if (ftrace_trigger_soft_disabled(ftrace_file))
 		return;
 
+	if (ftrace_file->flags & TRACE_EVENT_FL_BPF)
+		if (!trace_filter_call_bpf(ftrace_file->filter, regs))
+			return;
+
 	local_save_flags(irq_flags);
 	pc = preempt_count();
 
@@ -1286,7 +1295,7 @@ static int register_kprobe_event(struct trace_kprobe *tk)
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
