From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH tip 3/9] tracing: allow eBPF programs to call ktime_get_ns()
Date: Thu, 15 Jan 2015 20:16:04 -0800
Message-ID: <1421381770-4866-4-git-send-email-ast@plumgrid.com>
References: <1421381770-4866-1-git-send-email-ast@plumgrid.com>
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1421381770-4866-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

bpf_ktime_get_ns() is used by programs to compue time delta between events
or as a timestamp

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 include/uapi/linux/bpf.h |    1 +
 kernel/trace/bpf_trace.c |   10 ++++++++++
 2 files changed, 11 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index ef88e3f45b85..6075c4f4b67e 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -171,6 +171,7 @@ enum bpf_func_id {
 	BPF_FUNC_memcmp,          /* int bpf_memcmp(void *unsafe_ptr, void *safe_ptr, int size) */
 	BPF_FUNC_dump_stack,      /* void bpf_dump_stack(void) */
 	BPF_FUNC_printk,          /* int bpf_printk(const char *fmt, int fmt_size, ...) */
+	BPF_FUNC_ktime_get_ns,    /* u64 bpf_ktime_get_ns(void) */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 3825d7a3cbd1..14cfbbcec32e 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -114,6 +114,11 @@ static u64 bpf_printk(u64 r1, u64 fmt_size, u64 r3, u64 r4, u64 r5)
 			      mod_l[2] ? r5 : (u32) r5);
 }
 
+static u64 bpf_ktime_get_ns(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	return ktime_get_ns();
+}
+
 static struct bpf_func_proto tracing_filter_funcs[] = {
 #define FETCH(SIZE)				\
 	[BPF_FUNC_fetch_##SIZE] = {		\
@@ -147,6 +152,11 @@ static struct bpf_func_proto tracing_filter_funcs[] = {
 		.arg1_type = ARG_PTR_TO_STACK,
 		.arg2_type = ARG_CONST_STACK_SIZE,
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
