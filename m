From: Alexei Starovoitov <ast@fb.com>
Subject: [PATCH v2 net-next 05/10] bpf: register BPF_PROG_TYPE_TRACEPOINT program type
Date: Wed, 6 Apr 2016 18:43:26 -0700
Message-ID: <1459993411-2754735-6-git-send-email-ast@fb.com>
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

register tracepoint bpf program type and let it call the same set
of helper functions as BPF_PROG_TYPE_KPROBE

Signed-off-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/trace/bpf_trace.c | 45 +++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 43 insertions(+), 2 deletions(-)

diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 3e4ffb3ace5f..3e5ebe3254d2 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -268,7 +268,7 @@ static const struct bpf_func_proto bpf_perf_event_output_proto = {
 	.arg5_type	= ARG_CONST_STACK_SIZE,
 };
 
-static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
+static const struct bpf_func_proto *tracing_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
 	case BPF_FUNC_map_lookup_elem:
@@ -295,12 +295,20 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return &bpf_get_smp_processor_id_proto;
 	case BPF_FUNC_perf_event_read:
 		return &bpf_perf_event_read_proto;
+	default:
+		return NULL;
+	}
+}
+
+static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
 	case BPF_FUNC_perf_event_output:
 		return &bpf_perf_event_output_proto;
 	case BPF_FUNC_get_stackid:
 		return &bpf_get_stackid_proto;
 	default:
-		return NULL;
+		return tracing_func_proto(func_id);
 	}
 }
 
@@ -332,9 +340,42 @@ static struct bpf_prog_type_list kprobe_tl = {
 	.type	= BPF_PROG_TYPE_KPROBE,
 };
 
+static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
+{
+	switch (func_id) {
+	case BPF_FUNC_perf_event_output:
+	case BPF_FUNC_get_stackid:
+		return NULL;
+	default:
+		return tracing_func_proto(func_id);
+	}
+}
+
+static bool tp_prog_is_valid_access(int off, int size, enum bpf_access_type type)
+{
+	if (off < sizeof(void *) || off >= PERF_MAX_TRACE_SIZE)
+		return false;
+	if (type != BPF_READ)
+		return false;
+	if (off % size != 0)
+		return false;
+	return true;
+}
+
+static const struct bpf_verifier_ops tracepoint_prog_ops = {
+	.get_func_proto  = tp_prog_func_proto,
+	.is_valid_access = tp_prog_is_valid_access,
+};
+
+static struct bpf_prog_type_list tracepoint_tl = {
+	.ops	= &tracepoint_prog_ops,
+	.type	= BPF_PROG_TYPE_TRACEPOINT,
+};
+
 static int __init register_kprobe_prog_ops(void)
 {
 	bpf_register_prog_type(&kprobe_tl);
+	bpf_register_prog_type(&tracepoint_tl);
 	return 0;
 }
 late_initcall(register_kprobe_prog_ops);
-- 
2.8.0
