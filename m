From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 1/2] bpf: pass original insn directly to convert_ctx_access
Date: Thu, 12 Jan 2017 11:51:32 +0100
Message-ID: <7a892bbeb4e52b42c2d83a25190e5fc91535b32c.1484214889.git.daniel@iogearbox.net>
References: <cover.1484214889.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33539 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751181AbdALKv4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 05:51:56 -0500
In-Reply-To: <cover.1484214889.git.daniel@iogearbox.net>
In-Reply-To: <cover.1484214889.git.daniel@iogearbox.net>
References: <cover.1484214889.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, when calling convert_ctx_access() callback for the various
program types, we pass in insn->dst_reg, insn->src_reg, insn->off from
the original instruction. This information is needed to rewrite the
instruction that is based on the user ctx structure into a kernel
representation for the ctx. As we'd like to allow access size beyond
just BPF_W, we'd need also insn->code for that in order to decode the
original access size. Given that, lets just pass insn directly to the
convert_ctx_access() callback and work on that to not clutter the
callback with even more arguments we need to pass when everything is
already contained in insn. So lets go through that once, no functional
change.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h      |   7 ++-
 kernel/bpf/verifier.c    |   3 +-
 kernel/trace/bpf_trace.c |  15 ++---
 net/core/filter.c        | 139 +++++++++++++++++++++++++----------------------
 4 files changed, 87 insertions(+), 77 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 94ea8d2..f8c3560 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -161,9 +161,10 @@ struct bpf_verifier_ops {
 				enum bpf_reg_type *reg_type);
 	int (*gen_prologue)(struct bpf_insn *insn, bool direct_write,
 			    const struct bpf_prog *prog);
-	u32 (*convert_ctx_access)(enum bpf_access_type type, int dst_reg,
-				  int src_reg, int ctx_off,
-				  struct bpf_insn *insn, struct bpf_prog *prog);
+	u32 (*convert_ctx_access)(enum bpf_access_type type,
+				  const struct bpf_insn *src,
+				  struct bpf_insn *dst,
+				  struct bpf_prog *prog);
 };
 
 struct bpf_prog_type_list {
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 2efdc91..df7e472 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -3177,8 +3177,7 @@ static int convert_ctx_accesses(struct bpf_verifier_env *env)
 		if (env->insn_aux_data[i].ptr_type != PTR_TO_CTX)
 			continue;
 
-		cnt = ops->convert_ctx_access(type, insn->dst_reg, insn->src_reg,
-					      insn->off, insn_buf, env->prog);
+		cnt = ops->convert_ctx_access(type, insn, insn_buf, env->prog);
 		if (cnt == 0 || cnt >= ARRAY_SIZE(insn_buf)) {
 			verbose("bpf verifier is misconfigured\n");
 			return -EINVAL;
diff --git a/kernel/trace/bpf_trace.c b/kernel/trace/bpf_trace.c
index f883c43..1860e7f 100644
--- a/kernel/trace/bpf_trace.c
+++ b/kernel/trace/bpf_trace.c
@@ -572,28 +572,29 @@ static bool pe_prog_is_valid_access(int off, int size, enum bpf_access_type type
 	return true;
 }
 
-static u32 pe_prog_convert_ctx_access(enum bpf_access_type type, int dst_reg,
-				      int src_reg, int ctx_off,
+static u32 pe_prog_convert_ctx_access(enum bpf_access_type type,
+				      const struct bpf_insn *si,
 				      struct bpf_insn *insn_buf,
 				      struct bpf_prog *prog)
 {
 	struct bpf_insn *insn = insn_buf;
 
-	switch (ctx_off) {
+	switch (si->off) {
 	case offsetof(struct bpf_perf_event_data, sample_period):
 		BUILD_BUG_ON(FIELD_SIZEOF(struct perf_sample_data, period) != sizeof(u64));
 
 		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct bpf_perf_event_data_kern,
-						       data), dst_reg, src_reg,
+						       data), si->dst_reg, si->src_reg,
 				      offsetof(struct bpf_perf_event_data_kern, data));
-		*insn++ = BPF_LDX_MEM(BPF_DW, dst_reg, dst_reg,
+		*insn++ = BPF_LDX_MEM(BPF_DW, si->dst_reg, si->dst_reg,
 				      offsetof(struct perf_sample_data, period));
 		break;
 	default:
 		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct bpf_perf_event_data_kern,
-						       regs), dst_reg, src_reg,
+						       regs), si->dst_reg, si->src_reg,
 				      offsetof(struct bpf_perf_event_data_kern, regs));
-		*insn++ = BPF_LDX_MEM(BPF_SIZEOF(long), dst_reg, dst_reg, ctx_off);
+		*insn++ = BPF_LDX_MEM(BPF_SIZEOF(long), si->dst_reg, si->dst_reg,
+				      si->off);
 		break;
 	}
 
diff --git a/net/core/filter.c b/net/core/filter.c
index f4d16a9..8cfbdef 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2972,32 +2972,33 @@ void bpf_warn_invalid_xdp_action(u32 act)
 }
 EXPORT_SYMBOL_GPL(bpf_warn_invalid_xdp_action);
 
-static u32 sk_filter_convert_ctx_access(enum bpf_access_type type, int dst_reg,
-					int src_reg, int ctx_off,
+static u32 sk_filter_convert_ctx_access(enum bpf_access_type type,
+					const struct bpf_insn *si,
 					struct bpf_insn *insn_buf,
 					struct bpf_prog *prog)
 {
 	struct bpf_insn *insn = insn_buf;
+	int off;
 
-	switch (ctx_off) {
+	switch (si->off) {
 	case offsetof(struct __sk_buff, len):
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);
 
-		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->src_reg,
 				      offsetof(struct sk_buff, len));
 		break;
 
 	case offsetof(struct __sk_buff, protocol):
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, protocol) != 2);
 
-		*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg,
+		*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg, si->src_reg,
 				      offsetof(struct sk_buff, protocol));
 		break;
 
 	case offsetof(struct __sk_buff, vlan_proto):
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_proto) != 2);
 
-		*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg,
+		*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg, si->src_reg,
 				      offsetof(struct sk_buff, vlan_proto));
 		break;
 
@@ -3005,17 +3006,17 @@ static u32 sk_filter_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, priority) != 4);
 
 		if (type == BPF_WRITE)
-			*insn++ = BPF_STX_MEM(BPF_W, dst_reg, src_reg,
+			*insn++ = BPF_STX_MEM(BPF_W, si->dst_reg, si->src_reg,
 					      offsetof(struct sk_buff, priority));
 		else
-			*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+			*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->src_reg,
 					      offsetof(struct sk_buff, priority));
 		break;
 
 	case offsetof(struct __sk_buff, ingress_ifindex):
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, skb_iif) != 4);
 
-		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->src_reg,
 				      offsetof(struct sk_buff, skb_iif));
 		break;
 
@@ -3023,17 +3024,17 @@ static u32 sk_filter_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 		BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, ifindex) != 4);
 
 		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct sk_buff, dev),
-				      dst_reg, src_reg,
+				      si->dst_reg, si->src_reg,
 				      offsetof(struct sk_buff, dev));
-		*insn++ = BPF_JMP_IMM(BPF_JEQ, dst_reg, 0, 1);
-		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, dst_reg,
+		*insn++ = BPF_JMP_IMM(BPF_JEQ, si->dst_reg, 0, 1);
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
 				      offsetof(struct net_device, ifindex));
 		break;
 
 	case offsetof(struct __sk_buff, hash):
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, hash) != 4);
 
-		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->src_reg,
 				      offsetof(struct sk_buff, hash));
 		break;
 
@@ -3041,63 +3042,74 @@ static u32 sk_filter_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
 
 		if (type == BPF_WRITE)
-			*insn++ = BPF_STX_MEM(BPF_W, dst_reg, src_reg,
+			*insn++ = BPF_STX_MEM(BPF_W, si->dst_reg, si->src_reg,
 					      offsetof(struct sk_buff, mark));
 		else
-			*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+			*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->src_reg,
 					      offsetof(struct sk_buff, mark));
 		break;
 
 	case offsetof(struct __sk_buff, pkt_type):
-		return convert_skb_access(SKF_AD_PKTTYPE, dst_reg, src_reg, insn);
+		return convert_skb_access(SKF_AD_PKTTYPE, si->dst_reg,
+					  si->src_reg, insn);
 
 	case offsetof(struct __sk_buff, queue_mapping):
-		return convert_skb_access(SKF_AD_QUEUE, dst_reg, src_reg, insn);
+		return convert_skb_access(SKF_AD_QUEUE, si->dst_reg,
+					  si->src_reg, insn);
 
 	case offsetof(struct __sk_buff, vlan_present):
 		return convert_skb_access(SKF_AD_VLAN_TAG_PRESENT,
-					  dst_reg, src_reg, insn);
+					  si->dst_reg, si->src_reg, insn);
 
 	case offsetof(struct __sk_buff, vlan_tci):
 		return convert_skb_access(SKF_AD_VLAN_TAG,
-					  dst_reg, src_reg, insn);
+					  si->dst_reg, si->src_reg, insn);
 
 	case offsetof(struct __sk_buff, cb[0]) ...
 	     offsetof(struct __sk_buff, cb[4]):
 		BUILD_BUG_ON(FIELD_SIZEOF(struct qdisc_skb_cb, data) < 20);
 
 		prog->cb_access = 1;
-		ctx_off -= offsetof(struct __sk_buff, cb[0]);
-		ctx_off += offsetof(struct sk_buff, cb);
-		ctx_off += offsetof(struct qdisc_skb_cb, data);
+		off  = si->off;
+		off -= offsetof(struct __sk_buff, cb[0]);
+		off += offsetof(struct sk_buff, cb);
+		off += offsetof(struct qdisc_skb_cb, data);
 		if (type == BPF_WRITE)
-			*insn++ = BPF_STX_MEM(BPF_W, dst_reg, src_reg, ctx_off);
+			*insn++ = BPF_STX_MEM(BPF_W, si->dst_reg,
+					      si->src_reg, off);
 		else
-			*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg, ctx_off);
+			*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg,
+					      si->src_reg, off);
 		break;
 
 	case offsetof(struct __sk_buff, tc_classid):
-		ctx_off -= offsetof(struct __sk_buff, tc_classid);
-		ctx_off += offsetof(struct sk_buff, cb);
-		ctx_off += offsetof(struct qdisc_skb_cb, tc_classid);
+		BUILD_BUG_ON(FIELD_SIZEOF(struct qdisc_skb_cb, tc_classid) != 2);
+
+		off  = si->off;
+		off -= offsetof(struct __sk_buff, tc_classid);
+		off += offsetof(struct sk_buff, cb);
+		off += offsetof(struct qdisc_skb_cb, tc_classid);
 		if (type == BPF_WRITE)
-			*insn++ = BPF_STX_MEM(BPF_H, dst_reg, src_reg, ctx_off);
+			*insn++ = BPF_STX_MEM(BPF_H, si->dst_reg,
+					      si->src_reg, off);
 		else
-			*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg, ctx_off);
+			*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg,
+					      si->src_reg, off);
 		break;
 
 	case offsetof(struct __sk_buff, data):
 		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct sk_buff, data),
-				      dst_reg, src_reg,
+				      si->dst_reg, si->src_reg,
 				      offsetof(struct sk_buff, data));
 		break;
 
 	case offsetof(struct __sk_buff, data_end):
-		ctx_off -= offsetof(struct __sk_buff, data_end);
-		ctx_off += offsetof(struct sk_buff, cb);
-		ctx_off += offsetof(struct bpf_skb_data_end, data_end);
-		*insn++ = BPF_LDX_MEM(BPF_SIZEOF(void *), dst_reg, src_reg,
-				      ctx_off);
+		off  = si->off;
+		off -= offsetof(struct __sk_buff, data_end);
+		off += offsetof(struct sk_buff, cb);
+		off += offsetof(struct bpf_skb_data_end, data_end);
+		*insn++ = BPF_LDX_MEM(BPF_SIZEOF(void *), si->dst_reg,
+				      si->src_reg, off);
 		break;
 
 	case offsetof(struct __sk_buff, tc_index):
@@ -3105,110 +3117,107 @@ static u32 sk_filter_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, tc_index) != 2);
 
 		if (type == BPF_WRITE)
-			*insn++ = BPF_STX_MEM(BPF_H, dst_reg, src_reg,
+			*insn++ = BPF_STX_MEM(BPF_H, si->dst_reg, si->src_reg,
 					      offsetof(struct sk_buff, tc_index));
 		else
-			*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg,
+			*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg, si->src_reg,
 					      offsetof(struct sk_buff, tc_index));
-		break;
 #else
 		if (type == BPF_WRITE)
-			*insn++ = BPF_MOV64_REG(dst_reg, dst_reg);
+			*insn++ = BPF_MOV64_REG(si->dst_reg, si->dst_reg);
 		else
-			*insn++ = BPF_MOV64_IMM(dst_reg, 0);
-		break;
+			*insn++ = BPF_MOV64_IMM(si->dst_reg, 0);
 #endif
+		break;
 	}
 
 	return insn - insn_buf;
 }
 
 static u32 sock_filter_convert_ctx_access(enum bpf_access_type type,
-					  int dst_reg, int src_reg,
-					  int ctx_off,
+					  const struct bpf_insn *si,
 					  struct bpf_insn *insn_buf,
 					  struct bpf_prog *prog)
 {
 	struct bpf_insn *insn = insn_buf;
 
-	switch (ctx_off) {
+	switch (si->off) {
 	case offsetof(struct bpf_sock, bound_dev_if):
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sock, sk_bound_dev_if) != 4);
 
 		if (type == BPF_WRITE)
-			*insn++ = BPF_STX_MEM(BPF_W, dst_reg, src_reg,
+			*insn++ = BPF_STX_MEM(BPF_W, si->dst_reg, si->src_reg,
 					offsetof(struct sock, sk_bound_dev_if));
 		else
-			*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+			*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->src_reg,
 				      offsetof(struct sock, sk_bound_dev_if));
 		break;
 
 	case offsetof(struct bpf_sock, family):
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sock, sk_family) != 2);
 
-		*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg,
+		*insn++ = BPF_LDX_MEM(BPF_H, si->dst_reg, si->src_reg,
 				      offsetof(struct sock, sk_family));
 		break;
 
 	case offsetof(struct bpf_sock, type):
-		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->src_reg,
 				      offsetof(struct sock, __sk_flags_offset));
-		*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, SK_FL_TYPE_MASK);
-		*insn++ = BPF_ALU32_IMM(BPF_RSH, dst_reg, SK_FL_TYPE_SHIFT);
+		*insn++ = BPF_ALU32_IMM(BPF_AND, si->dst_reg, SK_FL_TYPE_MASK);
+		*insn++ = BPF_ALU32_IMM(BPF_RSH, si->dst_reg, SK_FL_TYPE_SHIFT);
 		break;
 
 	case offsetof(struct bpf_sock, protocol):
-		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->src_reg,
 				      offsetof(struct sock, __sk_flags_offset));
-		*insn++ = BPF_ALU32_IMM(BPF_AND, dst_reg, SK_FL_PROTO_MASK);
-		*insn++ = BPF_ALU32_IMM(BPF_RSH, dst_reg, SK_FL_PROTO_SHIFT);
+		*insn++ = BPF_ALU32_IMM(BPF_AND, si->dst_reg, SK_FL_PROTO_MASK);
+		*insn++ = BPF_ALU32_IMM(BPF_RSH, si->dst_reg, SK_FL_PROTO_SHIFT);
 		break;
 	}
 
 	return insn - insn_buf;
 }
 
-static u32 tc_cls_act_convert_ctx_access(enum bpf_access_type type, int dst_reg,
-					 int src_reg, int ctx_off,
+static u32 tc_cls_act_convert_ctx_access(enum bpf_access_type type,
+					 const struct bpf_insn *si,
 					 struct bpf_insn *insn_buf,
 					 struct bpf_prog *prog)
 {
 	struct bpf_insn *insn = insn_buf;
 
-	switch (ctx_off) {
+	switch (si->off) {
 	case offsetof(struct __sk_buff, ifindex):
 		BUILD_BUG_ON(FIELD_SIZEOF(struct net_device, ifindex) != 4);
 
 		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct sk_buff, dev),
-				      dst_reg, src_reg,
+				      si->dst_reg, si->src_reg,
 				      offsetof(struct sk_buff, dev));
-		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, dst_reg,
+		*insn++ = BPF_LDX_MEM(BPF_W, si->dst_reg, si->dst_reg,
 				      offsetof(struct net_device, ifindex));
 		break;
 	default:
-		return sk_filter_convert_ctx_access(type, dst_reg, src_reg,
-						    ctx_off, insn_buf, prog);
+		return sk_filter_convert_ctx_access(type, si, insn_buf, prog);
 	}
 
 	return insn - insn_buf;
 }
 
-static u32 xdp_convert_ctx_access(enum bpf_access_type type, int dst_reg,
-				  int src_reg, int ctx_off,
+static u32 xdp_convert_ctx_access(enum bpf_access_type type,
+				  const struct bpf_insn *si,
 				  struct bpf_insn *insn_buf,
 				  struct bpf_prog *prog)
 {
 	struct bpf_insn *insn = insn_buf;
 
-	switch (ctx_off) {
+	switch (si->off) {
 	case offsetof(struct xdp_md, data):
 		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct xdp_buff, data),
-				      dst_reg, src_reg,
+				      si->dst_reg, si->src_reg,
 				      offsetof(struct xdp_buff, data));
 		break;
 	case offsetof(struct xdp_md, data_end):
 		*insn++ = BPF_LDX_MEM(BPF_FIELD_SIZEOF(struct xdp_buff, data_end),
-				      dst_reg, src_reg,
+				      si->dst_reg, si->src_reg,
 				      offsetof(struct xdp_buff, data_end));
 		break;
 	}
-- 
1.9.3
