From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v5 tip 3/7] tracing: allow BPF programs to call bpf_ktime_get_ns()
Date: Sun,  1 Mar 2015 15:27:41 -0800
Message-ID: <1425252465-27527-4-git-send-email-ast@plumgrid.com>
References: <1425252465-27527-1-git-send-email-ast@plumgrid.com>
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
In-Reply-To: <1425252465-27527-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

bpf_ktime_get_ns() is used by programs to compue time delta between events
or as a timestamp

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/uapi/linux/bpf.h |    1 +
 kernel/trace/bpf_trace.c |   11 +++++++++++
 2 files changed, 12 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 4486d36d2e9e..101e509d1001 100644
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
index bcce9b238dad..aa48b85cadb6 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -36,6 +36,12 @@ static u64 bpf_probe_read(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	return probe_kernel_read(dst, unsafe_ptr, size);
 }
 
+static u64 bpf_ktime_get_ns(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	/* NMI safe access to clock monotonic */
+	return ktime_get_mono_fast_ns();
+}
+
 static struct bpf_func_proto kprobe_prog_funcs[] = {
 	[BPF_FUNC_probe_read] = {
 		.func = bpf_probe_read,
@@ -45,6 +51,11 @@ static struct bpf_func_proto kprobe_prog_funcs[] = {
 		.arg2_type = ARG_CONST_STACK_SIZE,
 		.arg3_type = ARG_ANYTHING,
 	},
+	[BPF_FUNC_ktime_get_ns] = {
+		.func = bpf_ktime_get_ns,
+		.gpl_only = true,
+		.ret_type = RET_INTEGER,
+	},
 };
 
 static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
-- 
1.7.9.5
