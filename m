From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 3/3] bpf: avoid stack copy and use skb ctx for event output
Date: Thu, 14 Jul 2016 18:08:05 +0200
Message-ID: <866a4913c877ddec6c16058fa71d2a3e596033b6.1468511633.git.daniel@iogearbox.net>
References: <cover.1468511632.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, peterz@infradead.org, tgraf@suug.ch,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1468511632.git.daniel@iogearbox.net>
In-Reply-To: <cover.1468511632.git.daniel@iogearbox.net>
References: <cover.1468511632.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This work addresses a couple of issues bpf_skb_event_output()
helper currently has: i) We need two copies instead of just a
single one for the skb data when it should be part of a sample.
The data can be non-linear and thus needs to be extracted via
bpf_skb_load_bytes() helper first, and then copied once again
into the ring buffer slot. ii) Since bpf_skb_load_bytes()
currently needs to be used first, the helper needs to see a
constant size on the passed stack buffer to make sure BPF
verifier can do sanity checks on it during verification time.
Thus, just passing skb->len (or any other non-constant value)
wouldn't work, but changing bpf_skb_load_bytes() is also not
the proper solution, since the two copies are generally still
needed. iii) bpf_skb_load_bytes() is just for rather small
buffers like headers, since they need to sit on the limited
BPF stack anyway. Instead of working around in bpf_skb_load_bytes(),
this work improves the bpf_skb_event_output() helper to address
all 3 at once.

We can make use of the passed in skb context that we have in
the helper anyway, and use some of the reserved flag bits as
a length argument. The helper will use the new __output_custom()
facility from perf side with bpf_skb_copy() as callback helper
to walk and extract the data. It will pass the data for setup
to bpf_event_output(), which generates and pushes the raw record
with an additional frag part. The linear data used in the first
frag of the record serves as programmatically defined meta data
passed along with the appended sample.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h      |  7 ++++++-
 include/uapi/linux/bpf.h |  2 ++
 kernel/bpf/core.c        |  6 ++++--
 kernel/trace/bpf_trace.c | 33 +++++++++++++++------------------
 net/core/filter.c        | 43 ++++++++++++++++++++++++++++++++++++++++++-
 5 files changed, 69 insertions(+), 22 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index b3336b4..c13e92b 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -209,7 +209,12 @@ u64 bpf_get_stackid(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 bool bpf_prog_array_compatible(struct bpf_array *array, const struct bpf_prog *fp);
 
 const struct bpf_func_proto *bpf_get_trace_printk_proto(void);
-const struct bpf_func_proto *bpf_get_event_output_proto(void);
+
+typedef unsigned long (*bpf_ctx_copy_t)(void *dst, const void *src,
+					unsigned long len);
+
+u64 bpf_event_output(struct bpf_map *map, u64 flags, void *meta, u64 meta_size,
+		     void *ctx, u64 ctx_size, bpf_ctx_copy_t ctx_copy);
 
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
index d638062..03fd23d 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -1054,9 +1054,11 @@ const struct bpf_func_proto * __weak bpf_get_trace_printk_proto(void)
 	return NULL;
 }
 
-const struct bpf_func_proto * __weak bpf_get_event_output_proto(void)
+u64 __weak
+bpf_event_output(struct bpf_map *map, u64 flags, void *meta, u64 meta_size,
+		 void *ctx, u64 ctx_size, bpf_ctx_copy_t ctx_copy)
 {
-	return NULL;
+	return -ENOTSUPP;
 }
 
 /* Always built-in helper functions. */
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index c35883a..ebfbb7d 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -298,29 +298,26 @@ static const struct bpf_func_proto bpf_perf_event_output_proto = {
 
 static DEFINE_PER_CPU(struct pt_regs, bpf_pt_regs);
 
-static u64 bpf_event_output(u64 r1, u64 r2, u64 flags, u64 r4, u64 size)
+u64 bpf_event_output(struct bpf_map *map, u64 flags, void *meta, u64 meta_size,
+		     void *ctx, u64 ctx_size, bpf_ctx_copy_t ctx_copy)
 {
 	struct pt_regs *regs = this_cpu_ptr(&bpf_pt_regs);
+	struct perf_raw_frag frag = {
+		.copy		= ctx_copy,
+		.size		= ctx_size,
+		.data		= ctx,
+	};
+	struct perf_raw_record raw = {
+		.frag = {
+			.next	= ctx_size ? &frag : NULL,
+			.size	= meta_size,
+			.data	= meta,
+		},
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
index 10c4a2f..22e3992 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2025,6 +2025,47 @@ bool bpf_helper_changes_skb_data(void *func)
 	return false;
 }
 
+static unsigned long bpf_skb_copy(void *dst_buff, const void *skb,
+				  unsigned long len)
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
+				u64 meta_size)
+{
+	struct sk_buff *skb = (struct sk_buff *)(long) r1;
+	struct bpf_map *map = (struct bpf_map *)(long) r2;
+	u64 skb_size = (flags & BPF_F_CTXLEN_MASK) >> 32;
+	void *meta = (void *)(long) r4;
+
+	if (unlikely(flags & ~(BPF_F_CTXLEN_MASK | BPF_F_INDEX_MASK)))
+		return -EINVAL;
+	if (unlikely(skb_size > skb->len))
+		return -EFAULT;
+
+	return bpf_event_output(map, flags, meta, meta_size, skb, skb_size,
+				bpf_skb_copy);
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
