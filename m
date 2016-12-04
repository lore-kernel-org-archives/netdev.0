From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v2 net-next 1/4] bpf: xdp: Allow head adjustment in XDP prog
Date: Sat, 3 Dec 2016 19:17:23 -0800
Message-ID: <1480821446-4122277-2-git-send-email-kafai@fb.com>
References: <1480821446-4122277-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41353 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752008AbcLDDRc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 22:17:32 -0500
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
        by mx0a-00082601.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uB43EGgE001249
        for <netdev@vger.kernel.org>; Sat, 3 Dec 2016 19:17:32 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by mx0a-00082601.pphosted.com with ESMTP id 273t84karc-1
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Sat, 03 Dec 2016 19:17:32 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.103.99.97) with ESMTP  id
 31330f92b9d011e683280002c9931860-ebbfca50 for <netdev@vger.kernel.org>;        Sat,
 03 Dec 2016 19:17:31 -0800
In-Reply-To: <1480821446-4122277-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows XDP prog to extend/remove the packet
data at the head (like adding or removing header).  It is
done by adding a new XDP helper bpf_xdp_adjust_head().

It also renames bpf_helper_changes_skb_data() to
bpf_helper_changes_pkt_data() to better reflect
that XDP prog does not work on skb.

Acked-by: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 arch/powerpc/net/bpf_jit_comp64.c |  4 ++--
 arch/s390/net/bpf_jit_comp.c      |  2 +-
 arch/x86/net/bpf_jit_comp.c       |  2 +-
 include/linux/filter.h            |  2 +-
 include/uapi/linux/bpf.h          | 11 ++++++++++-
 kernel/bpf/core.c                 |  2 +-
 kernel/bpf/verifier.c             |  2 +-
 net/core/filter.c                 | 34 ++++++++++++++++++++++++++++++++--
 8 files changed, 49 insertions(+), 10 deletions(-)

diff --git a/arch/powerpc/net/bpf_jit_comp64.c b/arch/powerpc/net/bpf_jit_comp64.c
index 0fe98a567125..73a5cf18fd84 100644
--- a/arch/powerpc/net/bpf_jit_comp64.c
+++ b/arch/powerpc/net/bpf_jit_comp64.c
@@ -766,7 +766,7 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 			func = (u8 *) __bpf_call_base + imm;
 
 			/* Save skb pointer if we need to re-cache skb data */
-			if (bpf_helper_changes_skb_data(func))
+			if (bpf_helper_changes_pkt_data(func))
 				PPC_BPF_STL(3, 1, bpf_jit_stack_local(ctx));
 
 			bpf_jit_emit_func_call(image, ctx, (u64)func);
@@ -775,7 +775,7 @@ static int bpf_jit_build_body(struct bpf_prog *fp, u32 *image,
 			PPC_MR(b2p[BPF_REG_0], 3);
 
 			/* refresh skb cache */
-			if (bpf_helper_changes_skb_data(func)) {
+			if (bpf_helper_changes_pkt_data(func)) {
 				/* reload skb pointer to r3 */
 				PPC_BPF_LL(3, 1, bpf_jit_stack_local(ctx));
 				bpf_jit_emit_skb_loads(image, ctx);
diff --git a/arch/s390/net/bpf_jit_comp.c b/arch/s390/net/bpf_jit_comp.c
index bee281f3163d..167b31b186c1 100644
--- a/arch/s390/net/bpf_jit_comp.c
+++ b/arch/s390/net/bpf_jit_comp.c
@@ -981,7 +981,7 @@ static noinline int bpf_jit_insn(struct bpf_jit *jit, struct bpf_prog *fp, int i
 		EMIT2(0x0d00, REG_14, REG_W1);
 		/* lgr %b0,%r2: load return value into %b0 */
 		EMIT4(0xb9040000, BPF_REG_0, REG_2);
-		if (bpf_helper_changes_skb_data((void *)func)) {
+		if (bpf_helper_changes_pkt_data((void *)func)) {
 			jit->seen |= SEEN_SKB_CHANGE;
 			/* lg %b1,ST_OFF_SKBP(%r15) */
 			EMIT6_DISP_LH(0xe3000000, 0x0004, BPF_REG_1, REG_0,
diff --git a/arch/x86/net/bpf_jit_comp.c b/arch/x86/net/bpf_jit_comp.c
index fe04a04dab8e..e76d1af60f7a 100644
--- a/arch/x86/net/bpf_jit_comp.c
+++ b/arch/x86/net/bpf_jit_comp.c
@@ -853,7 +853,7 @@ xadd:			if (is_imm8(insn->off))
 			func = (u8 *) __bpf_call_base + imm32;
 			jmp_offset = func - (image + addrs[i]);
 			if (seen_ld_abs) {
-				reload_skb_data = bpf_helper_changes_skb_data(func);
+				reload_skb_data = bpf_helper_changes_pkt_data(func);
 				if (reload_skb_data) {
 					EMIT1(0x57); /* push %rdi */
 					jmp_offset += 22; /* pop, mov, sub, mov */
diff --git a/include/linux/filter.h b/include/linux/filter.h
index 97338134398f..3c02de77ad6a 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -590,7 +590,7 @@ void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp);
 u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 
 struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog);
-bool bpf_helper_changes_skb_data(void *func);
+bool bpf_helper_changes_pkt_data(void *func);
 
 struct bpf_prog *bpf_patch_insn_single(struct bpf_prog *prog, u32 off,
 				       const struct bpf_insn *patch, u32 len);
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 6123d9b8e828..0eb0e87dbe9f 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -424,6 +424,12 @@ union bpf_attr {
  *     @len: length of header to be pushed in front
  *     @flags: Flags (unused for now)
  *     Return: 0 on success or negative error
+ *
+ * int bpf_xdp_adjust_head(xdp_md, delta)
+ *     Adjust the xdp_md.data by delta
+ *     @xdp_md: pointer to xdp_md
+ *     @delta: An positive/negative integer to be added to xdp_md.data
+ *     Return: 0 on success or negative on error
  */
 #define __BPF_FUNC_MAPPER(FN)		\
 	FN(unspec),			\
@@ -469,7 +475,8 @@ union bpf_attr {
 	FN(csum_update),		\
 	FN(set_hash_invalid),		\
 	FN(get_numa_node_id),		\
-	FN(skb_change_head),
+	FN(skb_change_head),		\
+	FN(xdp_adjust_head),
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
  * function eBPF program intends to call
@@ -576,6 +583,8 @@ struct bpf_sock {
 	__u32 protocol;
 };
 
+#define XDP_PACKET_HEADROOM 256
+
 /* User return codes for XDP prog type.
  * A valid XDP program must return one of these defined values. All other
  * return codes are reserved for future use. Unknown return codes will result
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 82a04143368e..871e2f398cf5 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -1078,7 +1078,7 @@ struct bpf_prog * __weak bpf_int_jit_compile(struct bpf_prog *prog)
 	return prog;
 }
 
-bool __weak bpf_helper_changes_skb_data(void *func)
+bool __weak bpf_helper_changes_pkt_data(void *func)
 {
 	return false;
 }
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 0e742210750e..e6ce4d664521 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1216,7 +1216,7 @@ static int check_call(struct bpf_verifier_env *env, int func_id)
 		return -EINVAL;
 	}
 
-	changes_data = bpf_helper_changes_skb_data(fn->func);
+	changes_data = bpf_helper_changes_pkt_data(fn->func);
 
 	memset(&meta, 0, sizeof(meta));
 	meta.pkt_access = fn->pkt_access;
diff --git a/net/core/filter.c b/net/core/filter.c
index 56b43587d200..ccef948cf58a 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2234,7 +2234,34 @@ static const struct bpf_func_proto bpf_skb_change_head_proto = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
-bool bpf_helper_changes_skb_data(void *func)
+BPF_CALL_2(bpf_xdp_adjust_head, struct xdp_buff *, xdp, int, offset)
+{
+	/* Both mlx4 and mlx5 driver align each packet to PAGE_SIZE when
+	 * XDP prog is set.
+	 * If the above is not true for the other drivers to support
+	 * bpf_xdp_adjust_head, struct xdp_buff can be extended.
+	 */
+	unsigned long addr = (unsigned long)xdp->data & PAGE_MASK;
+	void *data_hard_start = (void *)addr;
+	void *data = xdp->data + offset;
+
+	if (unlikely(data < data_hard_start || data > xdp->data_end - ETH_HLEN))
+		return -EINVAL;
+
+	xdp->data = data;
+
+	return 0;
+}
+
+static const struct bpf_func_proto bpf_xdp_adjust_head_proto = {
+	.func		= bpf_xdp_adjust_head,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_PTR_TO_CTX,
+	.arg2_type	= ARG_ANYTHING,
+};
+
+bool bpf_helper_changes_pkt_data(void *func)
 {
 	if (func == bpf_skb_vlan_push ||
 	    func == bpf_skb_vlan_pop ||
@@ -2244,7 +2271,8 @@ bool bpf_helper_changes_skb_data(void *func)
 	    func == bpf_skb_change_tail ||
 	    func == bpf_skb_pull_data ||
 	    func == bpf_l3_csum_replace ||
-	    func == bpf_l4_csum_replace)
+	    func == bpf_l4_csum_replace ||
+	    func == bpf_xdp_adjust_head)
 		return true;
 
 	return false;
@@ -2670,6 +2698,8 @@ xdp_func_proto(enum bpf_func_id func_id)
 		return &bpf_xdp_event_output_proto;
 	case BPF_FUNC_get_smp_processor_id:
 		return &bpf_get_smp_processor_id_proto;
+	case BPF_FUNC_xdp_adjust_head:
+		return &bpf_xdp_adjust_head_proto;
 	default:
 		return sk_filter_func_proto(func_id);
 	}
-- 
2.5.1
