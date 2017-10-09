From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 11/15] nfp: bpf: move to datapath ABI version 2
Date: Sun,  8 Oct 2017 21:04:13 -0700
Message-ID: <20171009040417.22172-12-jakub.kicinski@netronome.com>
References: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:53942 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751343AbdJIEF4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 00:05:56 -0400
Received: by mail-pf0-f174.google.com with SMTP id n73so5855466pfg.10
        for <netdev@vger.kernel.org>; Sun, 08 Oct 2017 21:05:56 -0700 (PDT)
In-Reply-To: <20171009040417.22172-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Datapath ABI version 2 stores the packet information in LMEM
instead of NNRs.  We also have strict restrictions on which
GPRs we can use.  Only GPRs 0-23 are reserved for BPF.

Adjust the static register locations and "ABI" registers.
Note that packet length is packed with other info so we have
to extract it into one of the scratch registers, OTOH since
LMEM can be used in restricted operands we don't have to
extract packet pointer.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c      | 19 +++++++++---------
 drivers/net/ethernet/netronome/nfp/bpf/main.h     | 24 ++++++++++++++---------
 drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h |  2 +-
 3 files changed, 26 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index d7dc19feba8d..9b6c98ccebfe 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -526,22 +526,22 @@ construct_data_ind_ld(struct nfp_prog *nfp_prog, u16 offset,
 		emit_alu(nfp_prog, imm_a(nfp_prog),
 			 imm_a(nfp_prog), ALU_OP_ADD, reg_imm(size));
 		emit_alu(nfp_prog, reg_none(),
-			 NFP_BPF_ABI_LEN, ALU_OP_SUB, imm_a(nfp_prog));
+			 plen_reg(nfp_prog), ALU_OP_SUB, imm_a(nfp_prog));
 		wrp_br_special(nfp_prog, BR_BLO, OP_BR_GO_ABORT);
 		/* Load data */
 		emit_cmd(nfp_prog, CMD_TGT_READ8, CMD_MODE_32b, 0,
-			 pkt_reg(nfp_prog), imm_b(nfp_prog), sz - 1, true);
+			 pptr_reg(nfp_prog), imm_b(nfp_prog), sz - 1, true);
 	} else {
 		/* Check packet length */
 		tmp_reg = ur_load_imm_any(nfp_prog, offset + size,
 					  imm_a(nfp_prog));
 		emit_alu(nfp_prog, reg_none(),
-			 NFP_BPF_ABI_LEN, ALU_OP_SUB, tmp_reg);
+			 plen_reg(nfp_prog), ALU_OP_SUB, tmp_reg);
 		wrp_br_special(nfp_prog, BR_BLO, OP_BR_GO_ABORT);
 		/* Load data */
 		tmp_reg = re_load_imm_any(nfp_prog, offset, imm_b(nfp_prog));
 		emit_cmd(nfp_prog, CMD_TGT_READ8, CMD_MODE_32b, 0,
-			 pkt_reg(nfp_prog), tmp_reg, sz - 1, true);
+			 pptr_reg(nfp_prog), tmp_reg, sz - 1, true);
 	}
 
 	i = 0;
@@ -1024,7 +1024,7 @@ static int mem_ldx4_skb(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
 	if (meta->insn.off == offsetof(struct sk_buff, len))
 		emit_alu(nfp_prog, reg_both(meta->insn.dst_reg * 2),
-			 reg_none(), ALU_OP_NONE, NFP_BPF_ABI_LEN);
+			 reg_none(), ALU_OP_NONE, plen_reg(nfp_prog));
 	else
 		return -EOPNOTSUPP;
 
@@ -1039,12 +1039,12 @@ static int mem_ldx4_xdp(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	    meta->insn.off != offsetof(struct xdp_md, data_end))
 		return -EOPNOTSUPP;
 
-	emit_alu(nfp_prog, dst, reg_none(), ALU_OP_NONE, NFP_BPF_ABI_PKT);
+	emit_alu(nfp_prog, dst, reg_none(), ALU_OP_NONE, pptr_reg(nfp_prog));
 
 	if (meta->insn.off == offsetof(struct xdp_md, data))
 		return 0;
 
-	emit_alu(nfp_prog, dst,	dst, ALU_OP_ADD, NFP_BPF_ABI_LEN);
+	emit_alu(nfp_prog, dst,	dst, ALU_OP_ADD, plen_reg(nfp_prog));
 
 	return 0;
 }
@@ -1403,8 +1403,9 @@ static int nfp_fixup_branches(struct nfp_prog *nfp_prog)
 
 static void nfp_intro(struct nfp_prog *nfp_prog)
 {
-	emit_alu(nfp_prog, pkt_reg(nfp_prog),
-		 reg_none(), ALU_OP_NONE, NFP_BPF_ABI_PKT);
+	wrp_immed(nfp_prog, plen_reg(nfp_prog), GENMASK(13, 0));
+	emit_alu(nfp_prog, plen_reg(nfp_prog),
+		 plen_reg(nfp_prog), ALU_OP_AND, pv_len(nfp_prog));
 }
 
 static void nfp_outro_tc_legacy(struct nfp_prog *nfp_prog)
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.h b/drivers/net/ethernet/netronome/nfp/bpf/main.h
index 7d959757a51a..b7a112acbdb7 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.h
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.h
@@ -54,9 +54,13 @@ enum br_special {
 };
 
 enum static_regs {
-	STATIC_REG_PKT		= 1,
-#define REG_PKT_BANK	ALU_DST_A
-	STATIC_REG_IMM		= 2, /* Bank AB */
+	STATIC_REG_IMM		= 21, /* Bank AB */
+	STATIC_REG_PKT_LEN	= 22, /* Bank B */
+};
+
+enum pkt_vec {
+	PKT_VEC_PKT_LEN		= 0,
+	PKT_VEC_PKT_PTR		= 2,
 };
 
 enum nfp_bpf_action_type {
@@ -66,15 +70,17 @@ enum nfp_bpf_action_type {
 	NN_ACT_XDP,
 };
 
-#define pkt_reg(np)	reg_a((np)->regs_per_thread - STATIC_REG_PKT)
-#define imm_a(np)	reg_a((np)->regs_per_thread - STATIC_REG_IMM)
-#define imm_b(np)	reg_b((np)->regs_per_thread - STATIC_REG_IMM)
-#define imm_both(np)	reg_both((np)->regs_per_thread - STATIC_REG_IMM)
+#define pv_len(np)	reg_lm(1, PKT_VEC_PKT_LEN)
+#define pv_ctm_ptr(np)	reg_lm(1, PKT_VEC_PKT_PTR)
+
+#define plen_reg(np)	reg_b(STATIC_REG_PKT_LEN)
+#define pptr_reg(np)	pv_ctm_ptr(np)
+#define imm_a(np)	reg_a(STATIC_REG_IMM)
+#define imm_b(np)	reg_b(STATIC_REG_IMM)
+#define imm_both(np)	reg_both(STATIC_REG_IMM)
 
 #define NFP_BPF_ABI_FLAGS	reg_imm(0)
 #define   NFP_BPF_ABI_FLAG_MARK	1
-#define NFP_BPF_ABI_PKT		reg_nnr(2)
-#define NFP_BPF_ABI_LEN		reg_nnr(3)
 
 struct nfp_prog;
 struct nfp_insn_meta;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
index b0a452ba9039..782d452e0fc2 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ctrl.h
@@ -255,7 +255,7 @@
  * @NFP_NET_CFG_BPF_ADDR:	DMA address of the buffer with JITed BPF code
  */
 #define NFP_NET_CFG_BPF_ABI		0x0080
-#define   NFP_NET_BPF_ABI		1
+#define   NFP_NET_BPF_ABI		2
 #define NFP_NET_CFG_BPF_CAP		0x0081
 #define   NFP_NET_BPF_CAP_RELO		(1 << 0) /* seamless reload */
 #define NFP_NET_CFG_BPF_MAX_LEN		0x0082
-- 
2.14.1
