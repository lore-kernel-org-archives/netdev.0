From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 13/13] nfp: add support for offload of XDP programs
Date: Thu,  3 Nov 2016 13:58:58 +0000
Message-ID: <1478181538-20778-14-git-send-email-jakub.kicinski@netronome.com>
References: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
Cc: Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:36322 "EHLO
        mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757841AbcKCN73 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 09:59:29 -0400
Received: by mail-wm0-f49.google.com with SMTP id p190so335329574wmp.1
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 06:59:28 -0700 (PDT)
In-Reply-To: <1478181538-20778-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Most infrastructure can be reused, provide separate handling
of context offsets and exit codes.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_bpf.h       |  1 +
 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c   | 92 +++++++++++++++++++++-
 .../net/ethernet/netronome/nfp/nfp_bpf_verifier.c  |  3 +
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  2 +
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 44 ++++++++++-
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   |  3 +
 6 files changed, 139 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
index 87aa8a3e9112..76a19f1796af 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
@@ -62,6 +62,7 @@ enum nfp_bpf_action_type {
 	NN_ACT_TC_DROP,
 	NN_ACT_TC_REDIR,
 	NN_ACT_DIRECT,
+	NN_ACT_XDP,
 };
 
 /* Software register representation, hardware encoding in asm.h */
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
index f8df5300f49c..335beb8b8b45 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
@@ -1126,7 +1126,7 @@ static int data_ind_ld4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 				     meta->insn.src_reg * 2, true, 4);
 }
 
-static int mem_ldx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+static int mem_ldx4_skb(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
 	if (meta->insn.off == offsetof(struct sk_buff, len))
 		emit_alu(nfp_prog, reg_both(meta->insn.dst_reg * 2),
@@ -1134,12 +1134,42 @@ static int mem_ldx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	else
 		return -ENOTSUPP;
 
-	wrp_immed(nfp_prog, reg_both(meta->insn.dst_reg * 2 + 1), 0);
+	return 0;
+}
+
+static int mem_ldx4_xdp(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	u32 dst = reg_both(meta->insn.dst_reg * 2);
+
+	if (meta->insn.off != offsetof(struct xdp_md, data) &&
+	    meta->insn.off != offsetof(struct xdp_md, data_end))
+		return -ENOTSUPP;
+
+	emit_alu(nfp_prog, dst, reg_none(), ALU_OP_NONE, NFP_BPF_ABI_PKT);
+
+	if (meta->insn.off == offsetof(struct xdp_md, data))
+		return 0;
+
+	emit_alu(nfp_prog, dst,	dst, ALU_OP_ADD, NFP_BPF_ABI_LEN);
 
 	return 0;
 }
 
-static int mem_stx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+static int mem_ldx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	int ret;
+
+	if (nfp_prog->act == NN_ACT_XDP)
+		ret = mem_ldx4_xdp(nfp_prog, meta);
+	else
+		ret = mem_ldx4_skb(nfp_prog, meta);
+
+	wrp_immed(nfp_prog, reg_both(meta->insn.dst_reg * 2 + 1), 0);
+
+	return ret;
+}
+
+static int mem_stx4_skb(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
 	if (meta->insn.off == offsetof(struct sk_buff, mark))
 		return wrp_set_mark(nfp_prog, meta->insn.src_reg * 2);
@@ -1147,6 +1177,18 @@ static int mem_stx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	return -ENOTSUPP;
 }
 
+static int mem_stx4_xdp(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return -ENOTSUPP;
+}
+
+static int mem_stx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	if (nfp_prog->act == NN_ACT_XDP)
+		return mem_stx4_xdp(nfp_prog, meta);
+	return mem_stx4_skb(nfp_prog, meta);
+}
+
 static int jump(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
 	if (meta->insn.off < 0) /* TODO */
@@ -1530,6 +1572,47 @@ static void nfp_outro_tc_da(struct nfp_prog *nfp_prog)
 	emit_ld_field(nfp_prog, reg_a(0), 0xc, reg_b(2), SHF_SC_L_SHF, 16);
 }
 
+static void nfp_outro_xdp(struct nfp_prog *nfp_prog)
+{
+	/* XDP return codes:
+	 *   0 aborted  0x82 -> drop,  count as stat3
+	 *   1    drop  0x22 -> drop,  count as stat1
+	 *   2    pass  0x11 -> pass,  count as stat0
+	 *   3      tx  0x44 -> redir, count as stat2
+	 *   * unknown  0x82 -> drop,  count as stat3
+	 */
+	/* Target for aborts */
+	nfp_prog->tgt_abort = nfp_prog_current_offset(nfp_prog);
+
+	emit_br_def(nfp_prog, nfp_prog->tgt_done, 2);
+
+	emit_alu(nfp_prog, reg_a(0),
+		 reg_none(), ALU_OP_NONE, NFP_BPF_ABI_FLAGS);
+	emit_ld_field(nfp_prog, reg_a(0), 0xc, reg_imm(0x82), SHF_SC_L_SHF, 16);
+
+	/* Target for normal exits */
+	nfp_prog->tgt_out = nfp_prog_current_offset(nfp_prog);
+
+	/* if R0 > 3 jump to abort */
+	emit_alu(nfp_prog, reg_none(), reg_imm(3), ALU_OP_SUB, reg_b(0));
+	emit_br(nfp_prog, BR_BLO, nfp_prog->tgt_abort, 0);
+
+	wrp_immed(nfp_prog, reg_b(2), 0x44112282);
+
+	emit_shf(nfp_prog, reg_a(1),
+		 reg_none(), SHF_OP_NONE, reg_b(0), SHF_SC_L_SHF, 3);
+
+	emit_alu(nfp_prog, reg_none(), reg_a(1), ALU_OP_OR, reg_imm(0));
+	emit_shf(nfp_prog, reg_b(2),
+		 reg_imm(0xff), SHF_OP_AND, reg_b(2), SHF_SC_R_SHF, 0);
+
+	emit_br_def(nfp_prog, nfp_prog->tgt_done, 2);
+
+	emit_alu(nfp_prog, reg_a(0),
+		 reg_none(), ALU_OP_NONE, NFP_BPF_ABI_FLAGS);
+	emit_ld_field(nfp_prog, reg_a(0), 0xc, reg_b(2), SHF_SC_L_SHF, 16);
+}
+
 static void nfp_outro(struct nfp_prog *nfp_prog)
 {
 	switch (nfp_prog->act) {
@@ -1540,6 +1623,9 @@ static void nfp_outro(struct nfp_prog *nfp_prog)
 	case NN_ACT_TC_REDIR:
 		nfp_outro_tc_legacy(nfp_prog);
 		break;
+	case NN_ACT_XDP:
+		nfp_outro_xdp(nfp_prog);
+		break;
 	}
 }
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_verifier.c b/drivers/net/ethernet/netronome/nfp/nfp_bpf_verifier.c
index 144cae87f63a..b3361f9b8e5c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf_verifier.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf_verifier.c
@@ -80,6 +80,9 @@ struct nfp_bpf_analyzer_priv {
 {
 	const struct bpf_reg_state *reg0 = &env->cur_state.regs[0];
 
+	if (nfp_prog->act == NN_ACT_XDP)
+		return 0;
+
 	if (reg0->type != CONST_IMM) {
 		pr_info("unsupported exit state: %d, imm: %llx\n",
 			reg0->type, reg0->imm);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index fd29a6306991..2115f446031e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -435,6 +435,7 @@ struct nfp_stat_pair {
  * @is_vf:              Is the driver attached to a VF?
  * @fw_loaded:          Is the firmware loaded?
  * @bpf_offload_skip_sw:  Offloaded BPF program will not be rerun by cls_bpf
+ * @bpf_offload_xdp:	Offloaded BPF program is XDP
  * @ctrl:               Local copy of the control register/word.
  * @fl_bufsz:           Currently configured size of the freelist buffers
  * @rx_offset:		Offset in the RX buffers where packet data starts
@@ -502,6 +503,7 @@ struct nfp_net {
 	unsigned is_vf:1;
 	unsigned fw_loaded:1;
 	unsigned bpf_offload_skip_sw:1;
+	unsigned bpf_offload_xdp:1;
 
 	u32 ctrl;
 	u32 fl_bufsz;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 1e8e00d25c51..99edb9fd84bf 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1600,7 +1600,8 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		r_vec->rx_bytes += pkt_len;
 		u64_stats_update_end(&r_vec->rx_sync);
 
-		if (xdp_prog) {
+		if (xdp_prog && !(rxd->rxd.flags & PCIE_DESC_RX_BPF &&
+				  nn->bpf_offload_xdp)) {
 			int act;
 
 			dma_sync_single_for_cpu(&nn->pdev->dev,
@@ -2693,8 +2694,12 @@ static bool nfp_net_ebpf_capable(struct nfp_net *nn)
 	if (proto != htons(ETH_P_ALL))
 		return -ENOTSUPP;
 
-	if (tc->type == TC_SETUP_CLSBPF && nfp_net_ebpf_capable(nn))
-		return nfp_net_bpf_offload(nn, tc->cls_bpf);
+	if (tc->type == TC_SETUP_CLSBPF && nfp_net_ebpf_capable(nn)) {
+		if (!nn->bpf_offload_xdp)
+			return nfp_net_bpf_offload(nn, tc->cls_bpf);
+		else
+			return -EBUSY;
+	}
 
 	return -EINVAL;
 }
@@ -2902,6 +2907,34 @@ static void nfp_net_del_vxlan_port(struct net_device *netdev,
 		nfp_net_set_vxlan_port(nn, idx, 0);
 }
 
+static int nfp_net_xdp_offload(struct nfp_net *nn, struct bpf_prog *prog)
+{
+	struct tc_cls_bpf_offload cmd = {
+		.prog = prog,
+	};
+	int ret;
+
+	if (!nfp_net_ebpf_capable(nn))
+		return -EINVAL;
+
+	if (nn->ctrl & NFP_NET_CFG_CTRL_BPF) {
+		if (!nn->bpf_offload_xdp)
+			return prog ? -EBUSY : 0;
+		cmd.command = prog ? TC_CLSBPF_REPLACE : TC_CLSBPF_DESTROY;
+	} else {
+		if (!prog)
+			return 0;
+		cmd.command = TC_CLSBPF_ADD;
+	}
+
+	ret = nfp_net_bpf_offload(nn, &cmd);
+	/* Stop offload if replace not possible */
+	if (ret && cmd.command == TC_CLSBPF_REPLACE)
+		nfp_net_xdp_offload(nn, NULL);
+	nn->bpf_offload_xdp = prog && !ret;
+	return ret;
+}
+
 static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 {
 	struct nfp_net_ring_set rx = {
@@ -2920,6 +2953,7 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 	if (prog && nn->xdp_prog) {
 		prog = xchg(&nn->xdp_prog, prog);
 		bpf_prog_put(prog);
+		nfp_net_xdp_offload(nn, nn->xdp_prog);
 		return 0;
 	}
 
@@ -2934,6 +2968,8 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 	if (prog)
 		bpf_prog_put(prog);
 
+	nfp_net_xdp_offload(nn, nn->xdp_prog);
+
 	return 0;
 }
 
@@ -3233,5 +3269,7 @@ void nfp_net_netdev_clean(struct net_device *netdev)
 
 	if (nn->xdp_prog)
 		bpf_prog_put(nn->xdp_prog);
+	if (nn->bpf_offload_xdp)
+		nfp_net_xdp_offload(nn, NULL);
 	unregister_netdev(nn->netdev);
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
index 4bb6f16e2a7a..18a851eb3508 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
@@ -111,6 +111,9 @@ static void nfp_net_bpf_stats_reset(struct nfp_net *nn)
 	const struct tc_action *a;
 	LIST_HEAD(actions);
 
+	if (!cls_bpf->exts)
+		return NN_ACT_XDP;
+
 	/* TC direct action */
 	if (cls_bpf->exts_integrated) {
 		if (tc_no_actions(cls_bpf->exts))
-- 
1.9.1
