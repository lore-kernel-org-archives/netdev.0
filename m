From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v3 linux-trace 2/8] tracing: allow eBPF programs to call ktime_get_ns()
Date: Mon,  9 Feb 2015 19:45:55 -0800
Message-ID: <1423539961-21792-3-git-send-email-ast@plumgrid.com>
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

bpf_ktime_get_ns() is used by programs to compue time delta between events
or as a timestamp

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/uapi/linux/bpf.h |    1 +
 kernel/trace/bpf_trace.c |   10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index d73d7d0abe6e..ecae21e58ba3 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -169,6 +169,7 @@ enum bpf_func_id {
 	BPF_FUNC_fetch_u16,       /* u16 bpf_fetch_u16(void *unsafe_ptr) */
 	BPF_FUNC_fetch_u8,        /* u8 bpf_fetch_u8(void *unsafe_ptr) */
 	BPF_FUNC_probe_memcmp,    /* int bpf_probe_memcmp(unsafe_ptr, safe_ptr, size) */
+	BPF_FUNC_ktime_get_ns,    /* u64 bpf_ktime_get_ns(void) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index ec065e0a364e..e3196266b72f 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -69,6 +69,11 @@ static u64 bpf_probe_memcmp(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
 	return -1;
 }
 
+static u64 bpf_ktime_get_ns(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	return ktime_get_ns();
+}
+
 static struct bpf_func_proto tp_prog_funcs[] = {
 #define FETCH(SIZE)				\
 	[BPF_FUNC_fetch_##SIZE] = {		\
@@ -90,6 +95,11 @@ static struct bpf_func_proto tp_prog_funcs[] = {
 		.arg2_type = ARG_PTR_TO_STACK,
 		.arg3_type = ARG_CONST_STACK_SIZE,
 	},
+	[BPF_FUNC_ktime_get_ns] = {
+		.func = bpf_ktime_get_ns,
+		.gpl_only = true,
+		.ret_type = RET_INTEGER,
+	},
 };
 
 static const struct bpf_func_proto *tp_prog_func_proto(enum bpf_func_id func_id)
-- 
1.7.9.5
