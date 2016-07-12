From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 3/3] bpf: avoid stack copy and use skb ctx for event output
Date: Wed, 13 Jul 2016 00:36:19 +0200
Message-ID: <8608680161f01de4cfafbd5ef685acde8e35ef23.1468362046.git.daniel@iogearbox.net>
References: <cover.1468362046.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, peterz@infradead.org, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:44881 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbcGLWgv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 18:36:51 -0400
In-Reply-To: <cover.1468362046.git.daniel@iogearbox.net>
In-Reply-To: <cover.1468362046.git.daniel@iogearbox.net>
References: <cover.1468362046.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work improves bpf_skb_event_output() helper in two ways, i) it
avoids that users need to unnecessary extract sampled skb data to
stack first via bpf_skb_load_bytes() and then copy once again into
the ring buffer slot, and ii) it avoids that only portions can be
sampled with bpf_skb_load_bytes() due to stack limit.

Instead, we can make use of the passed in skb context that we have
in the helper anyway, and use some of the reserved flag bits as a
length argument. The helper will use the new __output_custom() facility
from perf with bpf_skb_copy_cb() as callback helper. It will pass
the data for setup to bpf_event_output(), which generates and pushes
the raw record. The linear data used in the non-frag part of the
record serves as custom / programmatically defined meta data passed
along with the appended sample.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h      |  5 ++++-
 include/uapi/linux/bpf.h |  2 ++
 kernel/bpf/core.c        |  8 ++++++--
 kernel/trace/bpf_trace.c | 33 +++++++++++++++------------------
 net/core/filter.c        | 43 ++++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 69 insertions(+), 22 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index b3336b4..afd64c8 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -209,8 +209,11 @@ u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *fp);
 
 const struct bpf_func_proto *bpf_get_trace_printk_proto(void);
-const struct bpf_func_proto *bpf_get_event_output_proto(void);
 
+u64 bpf_event_output(struct bpf_map *map, u64 flags, void *meta, u64 size_meta,
+		     void *ctx, u64 size_ctx,
+		     unsigned long (*ctx_copy_cb)(void *dst, const void *src,
+						  unsigned long n));
 #ifdef CONFIG_BPF_SYSCALL
 DECLARE_PER_CPU(int, bpf_prog_active);
 
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 262a7e8..c4d9224 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -401,6 +401,8 @@ enum bpf_func_id {
 /* BPF_FUNC_perf_event_output and BPF_FUNC_perf_event_read flags. */
 #define BPF_F_INDEX_MASK		0xffffffffULL
 #define BPF_F_CURRENT_CPU		BPF_F_INDEX_MASK
+/* BPF_FUNC_perf_event_output for sk_buff input context. */
+#define BPF_F_CTXLEN_MASK		(0xfffffULL << 32)
 
 /* user accessible mirror of in-kernel sk_buff.
  * new fields can only be added to the end of this structure
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index d638062..47a7054 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -1054,9 +1054,13 @@ const struct bpf_func_proto * __weak bpf_get_trace_printk_proto(void)
 	return NULL;
 }
 
-const struct bpf_func_proto * __weak bpf_get_event_output_proto(void)
+u64 __weak
+bpf_event_output(struct bpf_map *map, u64 flags, void *meta,
+		 u64 size_meta, void *ctx, u64 size_ctx,
+		 unsigned long (*ctx_copy_cb)(void *dst, const void *src,
+					      unsigned long n))
 {
-	return NULL;
+	return -ENOTSUPP;
 }
 
 /* Always built-in helper functions. */
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index 4d3d5b8..9c076d1 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -296,29 +296,26 @@ static const struct bpf_func_proto bpf_perf_event_output_proto = {
 
 static DEFINE_PER_CPU(struct pt_regs, bpf_pt_regs);
 
-static u64 bpf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
+u64 bpf_event_output(struct bpf_map *map, u64 flags, void *meta, u64 size_meta,
+		     void *ctx, u64 size_ctx,
+		     unsigned long (*ctx_copy_cb)(void *dst, const void *src,
+						  unsigned long n))
 {
 	struct pt_regs *regs = this_cpu_ptr(&bpf_pt_regs);
+	struct perf_raw_record_frag frag = {
+		.data		= ctx,
+		.copy_cb	= ctx_copy_cb,
+	};
+	struct perf_raw_record raw = {
+		.size		= size_meta + size_ctx,
+		.size_head	= size_meta,
+		.data		= meta,
+		.frag		= size_ctx ? &frag : NULL,
+	};
 
 	perf_fetch_caller_regs(regs);
 
-	return bpf_perf_event_output((long)regs, r2, flags, r4, size);
-}
-
-static const struct bpf_func_proto bpf_event_output_proto = {
-	.func		= bpf_event_output,
-	.gpl_only	= true,
-	.ret_type	= RET_INTEGER,
-	.arg1_type	= ARG_PTR_TO_CTX,
-	.arg2_type	= ARG_CONST_MAP_PTR,
-	.arg3_type	= ARG_ANYTHING,
-	.arg4_type	= ARG_PTR_TO_STACK,
-	.arg5_type	= ARG_CONST_STACK_SIZE,
-};
-
-const struct bpf_func_proto *bpf_get_event_output_proto(void)
-{
-	return &bpf_event_output_proto;
+	return __bpf_perf_event_output(regs, map, flags, &raw);
 }
 
 static u64 bpf_get_current_task(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
diff --git a/net/core/filter.c b/net/core/filter.c
index 10c4a2f..af48d1e 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2025,6 +2025,47 @@ bool bpf_helper_changes_skb_data(void *func)
 	return false;
 }
 
+static unsigned long bpf_skb_copy_cb(void *dst_buff, const void *skb,
+				     unsigned long len)
+{
+	void *ptr = skb_header_pointer(skb, 0, len, dst_buff);
+
+	if (unlikely(!ptr))
+		return len;
+	if (ptr != dst_buff)
+		memcpy(dst_buff, ptr, len);
+
+	return 0;
+}
+
+static u64 bpf_skb_event_output(u64 r1, u64 r2, u64 flags, u64 r4,
+				u64 size_meta)
+{
+	struct sk_buff *skb = (struct sk_buff *)(long) r1;
+	u64 size_skb = (flags & BPF_F_CTXLEN_MASK) >> 32;
+
+	if (unlikely(flags & ~(BPF_F_CTXLEN_MASK | BPF_F_INDEX_MASK)))
+		return -EINVAL;
+	if (unlikely(size_skb > skb->len))
+		return -EINVAL;
+
+	return bpf_event_output((struct bpf_map *)(long) r2,
+				flags & ~BPF_F_CTXLEN_MASK,
+				(void *)(long) r4, size_meta,
+				skb, size_skb, bpf_skb_copy_cb);
+}
+
+static const struct bpf_func_proto bpf_skb_event_output_proto = {
+	.func		= bpf_skb_event_output,
+	.gpl_only	= true,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_CONST_MAP_PTR,
+	.arg3_type	= ARG_ANYTHING,
+	.arg4_type	= ARG_PTR_TO_STACK,
+	.arg5_type	= ARG_CONST_STACK_SIZE,
+};
+
 static unsigned short bpf_tunnel_key_af(u64 flags)
 {
 	return flags & BPF_F_TUNINFO_IPV6 ? AF_INET6 : AF_INET;
@@ -2357,7 +2398,7 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 	case BPF_FUNC_get_hash_recalc:
 		return &bpf_get_hash_recalc_proto;
 	case BPF_FUNC_perf_event_output:
-		return bpf_get_event_output_proto();
+		return &bpf_skb_event_output_proto;
 	case BPF_FUNC_get_smp_processor_id:
 		return &bpf_get_smp_processor_id_proto;
 #ifdef CONFIG_SOCK_CGROUP_DATA
-- 
1.9.3
