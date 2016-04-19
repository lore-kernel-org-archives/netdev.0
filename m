From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next] perf, bpf: minimize the size of perf_trace_() tracepoint handler
Date: Mon, 18 Apr 2016 20:11:50 -0700
Message-ID: <1461035510-2810305-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Wang Nan <wangnan0@huawei.com>, Josef Bacik <jbacik@fb.com>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<kernel-team@fb.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

move trace_call_bpf() into helper function to minimize the size
of perf_trace_*() tracepoint handlers.
    text	   data	    bss	    dec	 	   hex	filename
10541679	5526646	2945024	19013349	1221ee5	vmlinux_before
10509422	5526646	2945024	18981092	121a0e4	vmlinux_after

It may seem that perf_fetch_caller_regs() can also be moved,
but that is incorrect, since ip/sp will be wrong.

bpf+tracepoint performance is not affected, since
perf_swevent_put_recursion_context() is now inlined.
export_symbol_gpl can also be dropped.

No measurable change in normal perf tracepoints.

Suggested-by: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/trace_events.h |  5 +++++
 include/trace/perf.h         | 13 +++----------
 kernel/events/core.c         | 20 +++++++++++++++++++-
 3 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/include/linux/trace_events.h b/include/linux/trace_events.h
index fe6441203b59..222f6aa0418f 100644
--- a/include/linux/trace_events.h
+++ b/include/linux/trace_events.h
@@ -609,6 +609,11 @@ extern void ftrace_profile_free_filter(struct perf_event *event);
 void perf_trace_buf_update(void *record, u16 type);
 void *perf_trace_buf_alloc(int size, struct pt_regs **regs, int *rctxp);
 
+void perf_trace_run_bpf_submit(void *raw_data, int size, int rctx,
+			       struct trace_event_call *call, u64 count,
+			       struct pt_regs *regs, struct hlist_head *head,
+			       struct task_struct *task);
+
 static inline void
 perf_trace_buf_submit(void *raw_data, int size, int rctx, u16 type,
 		       u64 count, struct pt_regs *regs, void *head,
diff --git a/include/trace/perf.h b/include/trace/perf.h
index a182306eefd7..88de5c205e86 100644
--- a/include/trace/perf.h
+++ b/include/trace/perf.h
@@ -64,16 +64,9 @@ perf_trace_##call(void *__data, proto)					\
 									\
 	{ assign; }							\
 									\
-	if (prog) {							\
-		*(struct pt_regs **)entry = __regs;			\
-		if (!trace_call_bpf(prog, entry) || hlist_empty(head)) { \
-			perf_swevent_put_recursion_context(rctx);	\
-			return;						\
-		}							\
-	}								\
-	perf_trace_buf_submit(entry, __entry_size, rctx,		\
-			      event_call->event.type, __count, __regs,	\
-			      head, __task);				\
+	perf_trace_run_bpf_submit(entry, __entry_size, rctx,		\
+				  event_call, __count, __regs,		\
+				  head, __task);			\
 }
 
 /*
diff --git a/kernel/events/core.c b/kernel/events/core.c
index 5056abffef27..9eb23dc27462 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -6741,7 +6741,6 @@ void perf_swevent_put_recursion_context(int rctx)
 
 	put_recursion_context(swhash->recursion, rctx);
 }
-EXPORT_SYMBOL_GPL(perf_swevent_put_recursion_context);
 
 void ___perf_sw_event(u32 event_id, u64 nr, struct pt_regs *regs, u64 addr)
 {
@@ -6998,6 +6997,25 @@ static int perf_tp_event_match(struct perf_event *event,
 	return 1;
 }
 
+void perf_trace_run_bpf_submit(void *raw_data, int size, int rctx,
+			       struct trace_event_call *call, u64 count,
+			       struct pt_regs *regs, struct hlist_head *head,
+			       struct task_struct *task)
+{
+	struct bpf_prog *prog = call->prog;
+
+	if (prog) {
+		*(struct pt_regs **)raw_data = regs;
+		if (!trace_call_bpf(prog, raw_data) || hlist_empty(head)) {
+			perf_swevent_put_recursion_context(rctx);
+			return;
+		}
+	}
+	perf_tp_event(call->event.type, count, raw_data, size, regs, head,
+		      rctx, task);
+}
+EXPORT_SYMBOL_GPL(perf_trace_run_bpf_submit);
+
 void perf_tp_event(u16 event_type, u64 count, void *record, int entry_size,
 		   struct pt_regs *regs, struct hlist_head *head, int rctx,
 		   struct task_struct *task)
-- 
2.8.0
