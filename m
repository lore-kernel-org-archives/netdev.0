From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH tip 8/9] tracing: attach eBPF programs to kprobe/kretprobe
Date: Thu, 15 Jan 2015 20:16:09 -0800
Message-ID: <1421381770-4866-9-git-send-email-ast@plumgrid.com>
References: <1421381770-4866-1-git-send-email-ast@plumgrid.com>
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421381770-4866-1-git-send-email-ast@plumgrid.com>
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
index a3897f5e43ca..0f1a0418bef7 100644
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
index 6075c4f4b67e..79ca0c63ffaf 100644
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
index 14cfbbcec32e..c485c7cc8d57 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -209,3 +209,42 @@ static int __init register_tracing_filter_ops(void)
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
index bb0140414238..75b7e93b2d28 100644
--- a/kernel/trace/trace_events_filter.c
+++ b/kernel/trace/trace_events_filter.c
@@ -1891,7 +1891,8 @@ static int create_filter_start(char *filter_str, bool set_str,
 	return err;
 }
 
-static int create_filter_bpf(char *filter_str, struct event_filter **filterp)
+static int create_filter_bpf(struct ftrace_event_call *call, char *filter_str,
+			     struct event_filter **filterp)
 {
 	struct event_filter *filter;
 	struct bpf_prog *prog;
@@ -1920,7 +1921,10 @@ static int create_filter_bpf(char *filter_str, struct event_filter **filterp)
 
 	filter->prog = prog;
 
-	if (prog->aux->prog_type != BPF_PROG_TYPE_TRACING_FILTER) {
+	if (((call->flags & TRACE_EVENT_FL_KPROBE) &&
+	     prog->aux->prog_type != BPF_PROG_TYPE_KPROBE_FILTER) ||
+	    (!(call->flags & TRACE_EVENT_FL_KPROBE) &&
+	     prog->aux->prog_type != BPF_PROG_TYPE_TRACING_FILTER)) {
 		/* valid fd, but invalid bpf program type */
 		err = -EINVAL;
 		goto free_filter;
@@ -2051,7 +2055,7 @@ int apply_event_filter(struct ftrace_event_file *file, char *filter_string)
 	 */
 	if (memcmp(filter_string, "bpf", 3) == 0 && filter_string[3] != 0 &&
 	    filter_string[4] != 0) {
-		err = create_filter_bpf(filter_string, &filter);
+		err = create_filter_bpf(call, filter_string, &filter);
 		if (!err)
 			file->flags |= TRACE_EVENT_FL_BPF;
 	} else {
diff --git a/kernel/trace/trace_kprobe.c b/kernel/trace/trace_kprobe.c
index 296079ae6583..113d10973e39 100644
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
+		if (trace_filter_call_bpf(ftrace_file->filter, regs) == 0)
+			return;
+
 	local_save_flags(irq_flags);
 	pc = preempt_count();
 
@@ -978,6 +983,10 @@ __kretprobe_trace_func(struct trace_kprobe *tk, struct kretprobe_instance *ri,
 	if (ftrace_trigger_soft_disabled(ftrace_file))
 		return;
 
+	if (ftrace_file->flags & TRACE_EVENT_FL_BPF)
+		if (trace_filter_call_bpf(ftrace_file->filter, regs) == 0)
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
