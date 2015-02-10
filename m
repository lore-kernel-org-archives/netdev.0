From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v3 linux-trace 7/8] tracing: attach eBPF programs to kprobe/kretprobe
Date: Mon,  9 Feb 2015 19:46:00 -0800
Message-ID: <1423539961-21792-8-git-send-email-ast@plumgrid.com>
References: <1423539961-21792-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1423539961-21792-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

introduce new type of eBPF programs BPF_PROG_TYPE_KPROBE.
Such programs are allowed to call the same helper functions
as tracing filters, but bpf_context is different:
For tracing filters bpf_context is 6 arguments of tracepoints or syscalls
For kprobe filters bpf_context == pt_regs

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/ftrace_event.h |    3 +++
 include/uapi/linux/bpf.h     |    1 +
 kernel/events/core.c         |    5 ++++-
 kernel/trace/bpf_trace.c     |   39 +++++++++++++++++++++++++++++++++++++++
 kernel/trace/trace_kprobe.c  |   10 +++++++++-
 5 files changed, 56 insertions(+), 2 deletions(-)

diff --git a/include/linux/ftrace_event.h b/include/linux/ftrace_event.h
index 479d0a4a42b3..cd6efd23bfae 100644
--- a/include/linux/ftrace_event.h
+++ b/include/linux/ftrace_event.h
@@ -249,6 +249,7 @@ enum {
 	TRACE_EVENT_FL_WAS_ENABLED_BIT,
 	TRACE_EVENT_FL_USE_CALL_FILTER_BIT,
 	TRACE_EVENT_FL_TRACEPOINT_BIT,
+	TRACE_EVENT_FL_KPROBE_BIT,
 };
 
 /*
@@ -262,6 +263,7 @@ enum {
  *                     it is best to clear the buffers that used it).
  *  USE_CALL_FILTER - For ftrace internal events, don't use file filter
  *  TRACEPOINT    - Event is a tracepoint
+ *  KPROBE        - Event is a kprobe
  */
 enum {
 	TRACE_EVENT_FL_FILTERED		= (1 << TRACE_EVENT_FL_FILTERED_BIT),
@@ -271,6 +273,7 @@ enum {
 	TRACE_EVENT_FL_WAS_ENABLED	= (1 << TRACE_EVENT_FL_WAS_ENABLED_BIT),
 	TRACE_EVENT_FL_USE_CALL_FILTER	= (1 << TRACE_EVENT_FL_USE_CALL_FILTER_BIT),
 	TRACE_EVENT_FL_TRACEPOINT	= (1 << TRACE_EVENT_FL_TRACEPOINT_BIT),
+	TRACE_EVENT_FL_KPROBE		= (1 << TRACE_EVENT_FL_KPROBE_BIT),
 };
 
 struct ftrace_event_call {
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index ecae21e58ba3..cf443900318d 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -119,6 +119,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_UNSPEC,
 	BPF_PROG_TYPE_SOCKET_FILTER,
 	BPF_PROG_TYPE_TRACEPOINT,
+	BPF_PROG_TYPE_KPROBE,
 };
 
 /* flags for BPF_MAP_UPDATE_ELEM command */
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 674a8ca17190..94de727a8c0c 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -6288,7 +6288,10 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 	if (IS_ERR(prog))
 		return PTR_ERR(prog);
 
-	if (prog->aux->prog_type != BPF_PROG_TYPE_TRACEPOINT) {
+	if (((event->tp_event->flags & TRACE_EVENT_FL_KPROBE) &&
+	     prog->aux->prog_type != BPF_PROG_TYPE_KPROBE) ||
+	    (!(event->tp_event->flags & TRACE_EVENT_FL_KPROBE) &&
+	     prog->aux->prog_type != BPF_PROG_TYPE_TRACEPOINT)) {
 		/* valid fd, but invalid bpf program type */
 		bpf_prog_put(prog);
 		return -EINVAL;
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index e3196266b72f..52dbd1e7dc28 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -153,3 +153,42 @@ static int __init register_tp_prog_ops(void)
 	return 0;
 }
 late_initcall(register_tp_prog_ops);
+
+/* check access to fields of 'struct pt_regs' from BPF program */
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
+/* kprobe filter programs are allowed to call the same helper functions
+ * as tracing filters, but bpf_context is different:
+ * For tracing filters bpf_context is 6 arguments of tracepoints or syscalls
+ * For kprobe filters bpf_context == pt_regs
+ */
+static struct bpf_verifier_ops kprobe_prog_ops = {
+	.get_func_proto = tp_prog_func_proto,
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
index 5edb518be345..d503ac43b85b 100644
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
