From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 linux-trace 2/8] tracing: allow eBPF programs to call ktime_get_ns()
Date: Tue, 27 Jan 2015 20:06:07 -0800
Message-ID: <1422417973-10195-3-git-send-email-ast@plumgrid.com>
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

bpf_ktime_get_ns() is used by programs to compue time delta between events
or as a timestamp

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/uapi/linux/bpf.h |    1 +
 kernel/trace/bpf_trace.c |   10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 3bf42875287c..227a4e404726 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -169,6 +169,7 @@ enum bpf_func_id {
 	BPF_FUNC_fetch_u16,       /* u16 bpf_fetch_u16(void *unsafe_ptr) */
 	BPF_FUNC_fetch_u8,        /* u8 bpf_fetch_u8(void *unsafe_ptr) */
 	BPF_FUNC_memcmp,          /* int bpf_memcmp(void *unsafe_ptr, void *safe_ptr, int size) */
+	BPF_FUNC_ktime_get_ns,    /* u64 bpf_ktime_get_ns(void) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 4aabbe2626c5..1c07f55702d6 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -54,6 +54,11 @@ static u64 bpf_memcmp(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	return -1;
 }
 
+static u64 bpf_ktime_get_ns(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	return ktime_get_ns();
+}
+
 static struct bpf_func_proto tracing_filter_funcs[] = {
 #define FETCH(SIZE)				\
 	[BPF_FUNC_fetch_##SIZE] = {		\
@@ -75,6 +80,11 @@ static struct bpf_func_proto tracing_filter_funcs[] = {
 		.arg2_type = ARG_PTR_TO_STACK,
 		.arg3_type = ARG_CONST_STACK_SIZE,
 	},
+	[BPF_FUNC_ktime_get_ns] = {
+		.func = bpf_ktime_get_ns,
+		.gpl_only = true,
+		.ret_type = RET_INTEGER,
+	},
 };
 
 static const struct bpf_func_proto *tracing_filter_func_proto(enum bpf_func_id func_id)
-- 
1.7.9.5
