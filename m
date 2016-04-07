From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 04/10] perf, bpf: allow bpf programs attach to tracepoints
Date: Wed, 6 Apr 2016 18:43:25 -0700
Message-ID: <1459993411-2754735-5-git-send-email-ast@fb.com>
References: <1459993411-2754735-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <peterz@infradead.org>,
	"David S . Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:20853 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754813AbcDGBnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2016 21:43:43 -0400
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u371dVXq014352
	for <netdev@vger.kernel.org>; Wed, 6 Apr 2016 18:43:42 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 225a080snf-3
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 06 Apr 2016 18:43:42 -0700
Received: from facebook.com (2401:db00:11:d093:face:0:1b:0)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 22d8f49cfc6211e5808e0002c9931860-e45f93f0 for <netdev@vger.kernel.org>;	Wed,
 06 Apr 2016 18:43:32 -0700
In-Reply-To: <1459993411-2754735-1-git-send-email-ast@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

introduce BPF_PROG_TYPE_TRACEPOINT program type and allow it to be attached
to the perf tracepoint handler, which will copy the arguments into
the per-cpu buffer and pass it to the bpf program as its first argument.
The layout of the fields can be discovered by doing
'cat /sys/kernel/debug/tracing/events/sched/sched_switch/format'
prior to the compilation of the program with exception that first 8 bytes
are reserved and not accessible to the program. This area is used to store
the pointer to 'struct pt_regs' which some of the bpf helpers will use:
+---------+
| 8 bytes | hidden 'struct pt_regs *' (inaccessible to bpf program)
+---------+
| N bytes | static tracepoint fields defined in tracepoint/format (bpf readonly)
+---------+
| dynamic | __dynamic_array bytes of tracepoint (inaccessible to bpf yet)
+---------+

Not that all of the fields are already dumped to user space via perf ring buffer
and broken application access it directly without consulting tracepoint/format.
Same rule applies here: static tracepoint fields should only be accessed
in a format defined in tracepoint/format. The order of fields and
field sizes are not an ABI.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/trace/perf.h     | 10 +++++++++-
 include/uapi/linux/bpf.h |  1 +
 kernel/events/core.c     | 13 +++++++++----
 3 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/include/trace/perf.h b/include/trace/perf.h
index 77cd9043b7e4..a182306eefd7 100644
--- a/include/trace/perf.h
+++ b/include/trace/perf.h
@@ -34,6 +34,7 @@ perf_trace_##call(void *__data, proto)					\
 	struct trace_event_call *event_call = __data;			\
 	struct trace_event_data_offsets_##call __maybe_unused __data_offsets;\
 	struct trace_event_raw_##call *entry;				\
+	struct bpf_prog *prog = event_call->prog;			\
 	struct pt_regs *__regs;						\
 	u64 __count = 1;						\
 	struct task_struct *__task = NULL;				\
@@ -45,7 +46,7 @@ perf_trace_##call(void *__data, proto)					\
 	__data_size = trace_event_get_offsets_##call(&__data_offsets, args); \
 									\
 	head = this_cpu_ptr(event_call->perf_events);			\
-	if (__builtin_constant_p(!__task) && !__task &&			\
+	if (!prog && __builtin_constant_p(!__task) && !__task &&	\
 				hlist_empty(head))			\
 		return;							\
 									\
@@ -63,6 +64,13 @@ perf_trace_##call(void *__data, proto)					\
 									\
 	{ assign; }							\
 									\
+	if (prog) {							\
+		*(struct pt_regs **)entry = __regs;			\
+		if (!trace_call_bpf(prog, entry) || hlist_empty(head)) { \
+			perf_swevent_put_recursion_context(rctx);	\
+			return;						\
+		}							\
+	}								\
 	perf_trace_buf_submit(entry, __entry_size, rctx,		\
 			      event_call->event.type, __count, __regs,	\
 			      head, __task);				\
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 23917bb47bf3..70eda5aeb304 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -92,6 +92,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_KPROBE,
 	BPF_PROG_TYPE_SCHED_CLS,
 	BPF_PROG_TYPE_SCHED_ACT,
+	BPF_PROG_TYPE_TRACEPOINT,
 };
 
 #define BPF_PSEUDO_MAP_FD	1
diff --git a/kernel/events/core.c b/kernel/events/core.c
index d8512883c0a0..e5ffe97d6166 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -6725,12 +6725,13 @@ int perf_swevent_get_recursion_context(void)
 }
 EXPORT_SYMBOL_GPL(perf_swevent_get_recursion_context);
 
-inline void perf_swevent_put_recursion_context(int rctx)
+void perf_swevent_put_recursion_context(int rctx)
 {
 	struct swevent_htable *swhash = this_cpu_ptr(&swevent_htable);
 
 	put_recursion_context(swhash->recursion, rctx);
 }
+EXPORT_SYMBOL_GPL(perf_swevent_put_recursion_context);
 
 void ___perf_sw_event(u32 event_id, u64 nr, struct pt_regs *regs, u64 addr)
 {
@@ -7106,6 +7107,7 @@ static void perf_event_free_filter(struct perf_event *event)
 
 static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 {
+	bool is_kprobe, is_tracepoint;
 	struct bpf_prog *prog;
 
 	if (event->attr.type != PERF_TYPE_TRACEPOINT)
@@ -7114,15 +7116,18 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 	if (event->tp_event->prog)
 		return -EEXIST;
 
-	if (!(event->tp_event->flags & TRACE_EVENT_FL_UKPROBE))
-		/* bpf programs can only be attached to u/kprobes */
+	is_kprobe = event->tp_event->flags & TRACE_EVENT_FL_UKPROBE;
+	is_tracepoint = event->tp_event->flags & TRACE_EVENT_FL_TRACEPOINT;
+	if (!is_kprobe && !is_tracepoint)
+		/* bpf programs can only be attached to u/kprobe or tracepoint */
 		return -EINVAL;
 
 	prog = bpf_prog_get(prog_fd);
 	if (IS_ERR(prog))
 		return PTR_ERR(prog);
 
-	if (prog->type != BPF_PROG_TYPE_KPROBE) {
+	if ((is_kprobe && prog->type != BPF_PROG_TYPE_KPROBE) ||
+	    (is_tracepoint && prog->type != BPF_PROG_TYPE_TRACEPOINT)) {
 		/* valid fd, but invalid bpf program type */
 		bpf_prog_put(prog);
 		return -EINVAL;
-- 
2.8.0
