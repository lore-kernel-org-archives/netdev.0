From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH net-next 4/8] bpf: support bpf_get_stackid() and bpf_perf_event_output() in tracepoint programs
Date: Mon, 4 Apr 2016 21:52:50 -0700
Message-ID: <1459831974-2891931-5-git-send-email-ast@fb.com>
References: <1459831974-2891931-1-git-send-email-ast@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>,
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
In-Reply-To: <1459831974-2891931-1-git-send-email-ast@fb.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

needs two wrapper functions to fetch 'struct pt_regs *' to convert
tracepoint bpf context into kprobe bpf context to reuse existing
helper functions

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h      |  1 +
 kernel/bpf/stackmap.c    |  2 +-
 kernel/trace/bpf_trace.c | 42 +++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 43 insertions(+), 2 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 21ee41b92e8a..198f6ace70ec 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -160,6 +160,7 @@ struct bpf_array {
 #define MAX_TAIL_CALL_CNT 32
 
 u64 bpf_tail_call(u64 ctx, u64 r2, u64 index, u64 r4, u64 r5);
+u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 void bpf_fd_array_map_clear(struct bpf_map *map);
 bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *fp);
 const struct bpf_func_proto *bpf_get_trace_printk_proto(void);
diff --git a/kernel/bpf/stackmap.c b/kernel/bpf/stackmap.c
index 499d9e933f8e..35114725cf30 100644
--- a/kernel/bpf/stackmap.c
+++ b/kernel/bpf/stackmap.c
@@ -116,7 +116,7 @@ free_smap:
 	return ERR_PTR(err);
 }
 
-static u64 bpf_get_stackid(u64 r1, u64 r2, u64 flags, u64 r4, u64 r5)
+u64 bpf_get_stackid(u64 r1, u64 r2, u64 flags, u64 r4, u64 r5)
 {
 	struct pt_regs *regs = (struct pt_regs *) (long) r1;
 	struct bpf_map *map = (struct bpf_map *) (long) r2;
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 3e5ebe3254d2..413ec5614180 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -340,12 +340,52 @@ static struct bpf_prog_type_list kprobe_tl = {
 	.type	= BPF_PROG_TYPE_KPROBE,
 };
 
+static u64 bpf_perf_event_output_tp(u64 r1, u64 r2, u64 index, u64 r4, u64 size)
+{
+	/*
+	 * r1 points to perf tracepoint buffer where first 8 bytes are hidden
+	 * from bpf program and contain a pointer to 'struct pt_regs'. Fetch it
+	 * from there and call the same bpf_perf_event_output() helper
+	 */
+	u64 ctx = *(long *)r1;
+
+	return bpf_perf_event_output(ctx, r2, index, r4, size);
+}
+
+static const struct bpf_func_proto bpf_perf_event_output_proto_tp = {
+	.func		= bpf_perf_event_output_tp,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_CONST_MAP_PTR,
+	.arg3_type	= ARG_ANYTHING,
+	.arg4_type	= ARG_PTR_TO_STACK,
+	.arg5_type	= ARG_CONST_STACK_SIZE,
+};
+
+static u64 bpf_get_stackid_tp(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	u64 ctx = *(long *)r1;
+
+	return bpf_get_stackid(ctx, r2, r3, r4, r5);
+}
+
+static const struct bpf_func_proto bpf_get_stackid_proto_tp = {
+	.func		= bpf_get_stackid_tp,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_CONST_MAP_PTR,
+	.arg3_type	= ARG_ANYTHING,
+};
+
 static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
 	case BPF_FUNC_perf_event_output:
+		return &bpf_perf_event_output_proto_tp;
 	case BPF_FUNC_get_stackid:
-		return NULL;
+		return &bpf_get_stackid_proto_tp;
 	default:
 		return tracing_func_proto(func_id);
 	}
-- 
2.8.0
