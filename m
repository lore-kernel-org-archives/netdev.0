From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 2/3] bpf: allow networking programs to use bpf_trace_printk() for debugging
Date: Fri, 12 Jun 2015 14:40:25 -0700
Message-ID: <1434145226-17892-3-git-send-email-ast@plumgrid.com>
References: <1434145226-17892-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Wang Nan <wangnan0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	Daniel Wagner <daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1434145226-17892-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

bpf_trace_printk() is a helper function used to debug eBPF programs.
Let socket and TC programs use it as well.
Note, it's DEBUG ONLY helper. If it's used in the program,
the kernel will print warning banner to make sure users don't use
it in production.

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 include/linux/bpf.h      |    1 +
 kernel/bpf/core.c        |    4 ++++
 kernel/trace/bpf_trace.c |   20 ++++++++++++--------
 net/core/filter.c        |    2 ++
 4 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 1b9a3f5b27f6..4383476a0d48 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -150,6 +150,7 @@ struct bpf_array {
 u64 bpf_tail_call(u64 ctx, u64 r2, u64 index, u64 r4, u64 r5);
 void bpf_prog_array_map_clear(struct bpf_map *map);
 bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *fp);
+const struct bpf_func_proto *bpf_get_trace_printk_proto(void);
 
 #ifdef CONFIG_BPF_SYSCALL
 void bpf_register_prog_type(struct bpf_prog_type_list *tl);
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 1fc45cc83076..c5bedc82bc1c 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -733,6 +733,10 @@ const struct bpf_func_proto bpf_ktime_get_ns_proto __weak;
 const struct bpf_func_proto bpf_get_current_pid_tgid_proto __weak;
 const struct bpf_func_proto bpf_get_current_uid_gid_proto __weak;
 const struct bpf_func_proto bpf_get_current_comm_proto __weak;
+const struct bpf_func_proto * __weak bpf_get_trace_printk_proto(void)
+{
+	return NULL;
+}
 
 /* Always built-in helper functions. */
 const struct bpf_func_proto bpf_tail_call_proto = {
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 3a17638cdf46..4f9b5d41869b 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -147,6 +147,17 @@ static const struct bpf_func_proto bpf_trace_printk_proto = {
 	.arg2_type	= ARG_CONST_STACK_SIZE,
 };
 
+const struct bpf_func_proto *bpf_get_trace_printk_proto(void)
+{
+	/*
+	 * this program might be calling bpf_trace_printk,
+	 * so allocate per-cpu printk buffers
+	 */
+	trace_printk_init_buffers();
+
+	return &bpf_trace_printk_proto;
+}
+
 static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
@@ -168,15 +179,8 @@ static const struct bpf_func_proto *kprobe_prog_func_proto(enum bpf_func_id func
 		return &bpf_get_current_uid_gid_proto;
 	case BPF_FUNC_get_current_comm:
 		return &bpf_get_current_comm_proto;
-
 	case BPF_FUNC_trace_printk:
-		/*
-		 * this program might be calling bpf_trace_printk,
-		 * so allocate per-cpu printk buffers
-		 */
-		trace_printk_init_buffers();
-
-		return &bpf_trace_printk_proto;
+		return bpf_get_trace_printk_proto();
 	default:
 		return NULL;
 	}
diff --git a/net/core/filter.c b/net/core/filter.c
index 20aa51ccbf9d..65ff107d3d29 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1442,6 +1442,8 @@ sk_filter_func_proto(enum bpf_func_id func_id)
 		return &bpf_tail_call_proto;
 	case BPF_FUNC_ktime_get_ns:
 		return &bpf_ktime_get_ns_proto;
+	case BPF_FUNC_trace_printk:
+		return bpf_get_trace_printk_proto();
 	default:
 		return NULL;
 	}
-- 
1.7.9.5
