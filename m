From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v8 tip 4/9] tracing: allow BPF programs to call bpf_ktime_get_ns()
Date: Thu, 19 Mar 2015 18:59:42 -0700
Message-ID: <1426816787-5001-5-git-send-email-ast@plumgrid.com>
References: <1426816787-5001-1-git-send-email-ast@plumgrid.com>
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1426816787-5001-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bpf_ktime_get_ns() is used by programs to compute time delta between events
or as a timestamp

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
Reviewed-by: Steven Rostedt <rostedt@goodmis.org>
---
 include/uapi/linux/bpf.h |    1 +
 kernel/trace/bpf_trace.c |   14 ++++++++++++++
 2 files changed, 15 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index b2948feeb70b..238c6883877b 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -165,6 +165,7 @@ enum bpf_func_id {
 	BPF_FUNC_map_update_elem, /* int map_update_elem(&map, &key, &value, flags) */
 	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
 	BPF_FUNC_probe_read,      /* int bpf_probe_read(void *dst, int size, void *src) */
+	BPF_FUNC_ktime_get_ns,    /* u64 bpf_ktime_get_ns(void) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 28d00e9dd966..769c577a1fc8 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -71,6 +71,18 @@ static const struct bpf_func_proto bpf_probe_read_proto = {
 	.arg3_type = ARG_ANYTHING,
 };
 
+static u64 bpf_ktime_get_ns(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	/* NMI safe access to clock monotonic */
+	return ktime_get_mono_fast_ns();
+}
+
+static const struct bpf_func_proto bpf_ktime_get_ns_proto = {
+	.func = bpf_ktime_get_ns,
+	.gpl_only = true,
+	.ret_type = RET_INTEGER,
+};
+
 static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -82,6 +94,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return &bpf_map_delete_elem_proto;
 	case BPF_FUNC_probe_read:
 		return &bpf_probe_read_proto;
+	case BPF_FUNC_ktime_get_ns:
+		return &bpf_ktime_get_ns_proto;
 	default:
 		return NULL;
 	}
-- 
1.7.9.5
