From: Martin KaFai Lau <kafai@fb.com>
Subject: [PATCH v3 net-next 1/4] bpf: xdp: Allow head adjustment in XDP prog
Date: Tue, 6 Dec 2016 21:31:51 -0800
Message-ID: <1481088714-54512-2-git-send-email-kafai@fb.com>
References: <1481088714-54512-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Alexei Starovoitov <ast@fb.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>,
        Jakub Kicinski <kubakici@wp.pl>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Kernel Team <kernel-team@fb.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:35714 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S932132AbcLGFcB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 00:32:01 -0500
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
        by m0089730.ppops.net (8.16.0.17/8.16.0.17) with SMTP id uB75T3CD028105
        for <netdev@vger.kernel.org>; Tue, 6 Dec 2016 21:32:00 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
        by m0089730.ppops.net with ESMTP id 276760m9hf-9
        (version=TLSv1 cipher=ECDHE-RSA-AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 21:32:00 -0800
Received: from facebook.com (2401:db00:11:d0a6:face:0:33:0)     by
 mx-out.facebook.com (10.212.232.59) with ESMTP id
 779cd434bc3e11e69c590002c991e86a-ff3fca50 for <netdev@vger.kernel.org>;        Tue,
 06 Dec 2016 21:31:56 -0800
In-Reply-To: <1481088714-54512-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch allows XDP prog to extend/remove the packet
data at the head (like adding or removing header).  It is
done by adding a new XDP helper bpf_xdp_adjust_head().

It also renames bpf_helper_changes_skb_data() to
bpf_helper_changes_pkt_data() to better reflect
that XDP prog does not work on skb.

To avoid breaking unsupported drivers, this patch
also does the needed checking before setting
the xdp_prog fd to the device.  It is done by
1) Adding a XDP_QUERY_FEATURES command
2) Adding one "xdp_adjust_head" bit to bpf_prog

Acked-by: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
---
 arch/powerpc/net/bpf_jit_comp64.c                  |  4 ++--
 arch/s390/net/bpf_jit_comp.c                       |  2 +-
 arch/x86/net/bpf_jit_comp.c                        |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c     |  3 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |  3 +++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  3 +++
 drivers/net/ethernet/qlogic/qede/qede_main.c       |  3 +++
 include/linux/filter.h                             |  6 +++--
 include/linux/netdevice.h                          | 12 ++++++++++
 include/uapi/linux/bpf.h                           | 11 ++++++++-
 kernel/bpf/core.c                                  |  2 +-
 kernel/bpf/syscall.c                               |  2 ++
 kernel/bpf/verifier.c                              |  2 +-
 net/core/dev.c                                     |  9 +++++++
 net/core/filter.c                                  | 28 ++++++++++++++++++++--
 15 files changed, 81 insertions(+), 11 deletions(-)

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
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 49a81f1fc1d6..6261157f444e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2794,6 +2794,9 @@ static int mlx4_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 	case XDP_QUERY_PROG:
 		xdp->prog_attached = mlx4_xdp_attached(dev);
 		return 0;
+	case XDP_QUERY_FEATURES:
+		xdp->features = 0;
+		return 0;
 	default:
 		return -EINVAL;
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 9def5cc378a3..f7a6b6b56d30 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -3262,6 +3262,9 @@ static int mlx5e_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 	case XDP_QUERY_PROG:
 		xdp->prog_attached = mlx5e_xdp_attached(dev);
 		return 0;
+	case XDP_QUERY_FEATURES:
+		xdp->features = 0;
+		return 0;
 	default:
 		return -EINVAL;
 	}
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 00d9a03be31d..89c95bb91503 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2981,6 +2981,9 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
 	case XDP_QUERY_PROG:
 		xdp->prog_attached = !!nn->xdp_prog;
 		return 0;
+	case XDP_QUERY_FEATURES:
+		xdp->features = 0;
+		return 0;
 	default:
 		return -EINVAL;
 	}
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index cf1dd1436d93..d52dd83ae8a1 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -2525,6 +2525,9 @@ static int qede_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 	case XDP_QUERY_PROG:
 		xdp->prog_attached = !!edev->xdp_prog;
 		return 0;
+	case XDP_QUERY_FEATURES:
+		xdp->features = 0;
+		return 0;
 	default:
 		return -EINVAL;
 	}
diff --git a/include/linux/filter.h b/include/linux/filter.h
index f078d2b1cff6..6a1658308612 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -406,7 +406,8 @@ struct bpf_prog {
 	u16			jited:1,	/* Is our filter JIT'ed? */
 				gpl_compatible:1, /* Is filter GPL compatible? */
 				cb_access:1,	/* Is control block accessed? */
-				dst_needed:1;	/* Do we need dst entry? */
+				dst_needed:1,	/* Do we need dst entry? */
+				xdp_adjust_head:1; /* Adjusting pkt head? */
 	kmemcheck_bitfield_end(meta);
 	enum bpf_prog_type	type;		/* Type of BPF program */
 	u32			len;		/* Number of filter blocks */
@@ -440,6 +441,7 @@ struct bpf_skb_data_end {
 struct xdp_buff {
 	void *data;
 	void *data_end;
+	void *data_hard_start;
 };
 
 /* compute the linear packet data range [data, data_end) which
@@ -595,7 +597,7 @@ void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp);
 u64 __bpf_call_base(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5);
 
 struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog);
-bool bpf_helper_changes_skb_data(void *func);
+bool bpf_helper_changes_pkt_data(void *func);
 
 struct bpf_prog *bpf_patch_insn_single(struct bpf_prog *prog, u32 off,
 				       const struct bpf_insn *patch, u32 len);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 1ff5ea6e1221..786ad7c67215 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -30,6 +30,7 @@
 #include <linux/delay.h>
 #include <linux/atomic.h>
 #include <linux/prefetch.h>
+#include <linux/bitops.h>
 #include <asm/cache.h>
 #include <asm/byteorder.h>
 
@@ -805,6 +806,13 @@ struct tc_to_netdev {
 	bool egress_dev;
 };
 
+/* Driver must allow a XDP prog to extend header by
+ * up to XDP_PACKET_HEADROOM.  It must also fill out
+ * the data_hard_start value in struct xdp_buff
+ * before calling out the xdp_prog.
+ */
+#define XDP_F_ADJUST_HEAD	BIT(0)
+
 /* These structures hold the attributes of xdp state that are being passed
  * to the netdevice through the xdp op.
  */
@@ -821,6 +829,8 @@ enum xdp_netdev_command {
 	 * return true if a program is currently attached and running.
 	 */
 	XDP_QUERY_PROG,
+	/* Check what XDP features are supported by a device */
+	XDP_QUERY_FEATURES,
 };
 
 struct netdev_xdp {
@@ -830,6 +840,8 @@ struct netdev_xdp {
 		struct bpf_prog *prog;
 		/* XDP_QUERY_PROG */
 		bool prog_attached;
+		/* XDP_QUERY_FEATURES */
+		u32 features;
 	};
 };
 
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
index bdcc9f4ba767..83e0d153b0b4 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -1143,7 +1143,7 @@ struct bpf_prog * __weak bpf_int_jit_compile(struct bpf_prog *prog)
 	return prog;
 }
 
-bool __weak bpf_helper_changes_skb_data(void *func)
+bool __weak bpf_helper_changes_pkt_data(void *func)
 {
 	return false;
 }
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index c0d2b423ce93..add93ecd7e69 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -579,6 +579,8 @@ static void fixup_bpf_calls(struct bpf_prog *prog)
 				prog->dst_needed = 1;
 			if (insn->imm == BPF_FUNC_get_prandom_u32)
 				bpf_user_rnd_init_once();
+			if (insn->imm == BPF_FUNC_xdp_adjust_head)
+				prog->xdp_adjust_head = 1;
 			if (insn->imm == BPF_FUNC_tail_call) {
 				/* mark bpf_tail_call as different opcode
 				 * to avoid conditional branch in
diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index cb37339ca0da..f5fa326518c9 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -1216,7 +1216,7 @@ static int check_call(struct bpf_verifier_env *env, int func_id)
 		return -EINVAL;
 	}
 
-	changes_data = bpf_helper_changes_skb_data(fn->func);
+	changes_data = bpf_helper_changes_pkt_data(fn->func);
 
 	memset(&meta, 0, sizeof(meta));
 	meta.pkt_access = fn->pkt_access;
diff --git a/net/core/dev.c b/net/core/dev.c
index bffb5253e778..90696f7e6b59 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6722,6 +6722,15 @@ int dev_change_xdp_fd(struct net_device *dev, int fd, u32 flags)
 		prog = bpf_prog_get_type(fd, BPF_PROG_TYPE_XDP);
 		if (IS_ERR(prog))
 			return PTR_ERR(prog);
+
+		xdp.command = XDP_QUERY_FEATURES;
+		err = ops->ndo_xdp(dev, &xdp);
+		if (err)
+			return err;
+
+		if (prog->xdp_adjust_head &&
+		    !(xdp.features & XDP_F_ADJUST_HEAD))
+			return -ENOTSUPP;
 	}
 
 	memset(&xdp, 0, sizeof(xdp));
diff --git a/net/core/filter.c b/net/core/filter.c
index b751202e12f8..b1461708a977 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2234,7 +2234,28 @@ static const struct bpf_func_proto bpf_skb_change_head_proto = {
 	.arg3_type	= ARG_ANYTHING,
 };
 
-bool bpf_helper_changes_skb_data(void *func)
+BPF_CALL_2(bpf_xdp_adjust_head, struct xdp_buff *, xdp, int, offset)
+{
+	void *data = xdp->data + offset;
+
+	if (unlikely(data < xdp->data_hard_start ||
+		     data > xdp->data_end - ETH_HLEN))
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
@@ -2244,7 +2265,8 @@ bool bpf_helper_changes_skb_data(void *func)
 	    func == bpf_skb_change_tail ||
 	    func == bpf_skb_pull_data ||
 	    func == bpf_l3_csum_replace ||
-	    func == bpf_l4_csum_replace)
+	    func == bpf_l4_csum_replace ||
+	    func == bpf_xdp_adjust_head)
 		return true;
 
 	return false;
@@ -2670,6 +2692,8 @@ xdp_func_proto(enum bpf_func_id func_id)
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
