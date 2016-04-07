From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 07/10] bpf: sanitize bpf tracepoint access
Date: Wed, 6 Apr 2016 18:43:28 -0700
Message-ID: <1459993411-2754735-8-git-send-email-ast@fb.com>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459993411-2754735-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

during bpf program loading remember the last byte of ctx access
and at the time of attaching the program to tracepoint check that
the program doesn't access bytes beyond defined in tracepoint fields

This also disallows access to __dynamic_array fields, but can be
relaxed in the future.

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h          |  1 +
 include/linux/trace_events.h |  1 +
 kernel/bpf/verifier.c        |  6 +++++-
 kernel/events/core.c         |  8 ++++++++
 kernel/trace/trace_events.c  | 18 ++++++++++++++++++
 5 files changed, 33 insertions(+), 1 deletion(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 198f6ace70ec..b2365a6eba3d 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -131,6 +131,7 @@ struct bpf_prog_type_list {
 struct bpf_prog_aux {
 	atomic_t refcnt;
 	u32 used_map_cnt;
+	u32 max_ctx_offset;
 	const struct bpf_verifier_ops *ops;
 	struct bpf_map **used_maps;
 	struct bpf_prog *prog;
diff --git a/include/linux/trace_events.h b/include/linux/trace_events.h
index 56f795e6a093..fe6441203b59 100644
--- a/include/linux/trace_events.h
+++ b/include/linux/trace_events.h
@@ -569,6 +569,7 @@ extern int trace_define_field(struct trace_event_call *call, const char *type,
 			      int is_signed, int filter_type);
 extern int trace_add_event_call(struct trace_event_call *call);
 extern int trace_remove_event_call(struct trace_event_call *call);
+extern int trace_event_get_offsets(struct trace_event_call *call);
 
 #define is_signed_type(type)	(((type)(-1)) < (type)1)
 
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 2e08f8e9b771..58792fed5678 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -652,8 +652,12 @@ static int check_ctx_access(struct verifier_env *env, int off, int size,
 			    enum bpf_access_type t)
 {
 	if (env->prog->aux->ops->is_valid_access &&
-	    env->prog->aux->ops->is_valid_access(off, size, t))
+	    env->prog->aux->ops->is_valid_access(off, size, t)) {
+		/* remember the offset of last byte accessed in ctx */
+		if (env->prog->aux->max_ctx_offset < off + size)
+			env->prog->aux->max_ctx_offset = off + size;
 		return 0;
+	}
 
 	verbose("invalid bpf_context access off=%d size=%d\n", off, size);
 	return -EACCES;
diff --git a/kernel/events/core.c b/kernel/events/core.c
index e5ffe97d6166..9a01019ff7c8 100644
--- a/kernel/events/core.c
+++ b/kernel/events/core.c
@@ -7133,6 +7133,14 @@ static int perf_event_set_bpf_prog(struct perf_event *event, u32 prog_fd)
 		return -EINVAL;
 	}
 
+	if (is_tracepoint) {
+		int off = trace_event_get_offsets(event->tp_event);
+
+		if (prog->aux->max_ctx_offset > off) {
+			bpf_prog_put(prog);
+			return -EACCES;
+		}
+	}
 	event->tp_event->prog = prog;
 
 	return 0;
diff --git a/kernel/trace/trace_events.c b/kernel/trace/trace_events.c
index 05ddc0820771..ced963049e0a 100644
--- a/kernel/trace/trace_events.c
+++ b/kernel/trace/trace_events.c
@@ -204,6 +204,24 @@ static void trace_destroy_fields(struct trace_event_call *call)
 	}
 }
 
+/*
+ * run-time version of trace_event_get_offsets_<call>() that returns the last
+ * accessible offset of trace fields excluding __dynamic_array bytes
+ */
+int trace_event_get_offsets(struct trace_event_call *call)
+{
+	struct ftrace_event_field *tail;
+	struct list_head *head;
+
+	head = trace_get_fields(call);
+	/*
+	 * head->next points to the last field with the largest offset,
+	 * since it was added last by trace_define_field()
+	 */
+	tail = list_first_entry(head, struct ftrace_event_field, link);
+	return tail->offset + tail->size;
+}
+
 int trace_event_raw_init(struct trace_event_call *call)
 {
 	int id;
-- 
2.8.0
