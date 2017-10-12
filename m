From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 05/12] nfp: bpf: add mov helper
Date: Thu, 12 Oct 2017 10:34:11 -0700
Message-ID: <20171012173418.4029-6-jakub.kicinski@netronome.com>
References: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:51574 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752246AbdJLRex (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:34:53 -0400
Received: by mail-pf0-f169.google.com with SMTP id n14so5839196pfh.8
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:34:53 -0700 (PDT)
In-Reply-To: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Register move operation is encoded as alu no op.  This means
that one has to specify number of unused/none parameters to
the emit_alu().  Add a helper.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 31 ++++++++++++++--------------
 1 file changed, 15 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index e970f284c8a4..4f7cfa6adfc1 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -504,9 +504,14 @@ wrp_br_special(struct nfp_prog *nfp_prog, enum br_mask mask,
 		FIELD_PREP(OP_BR_SPECIAL, special);
 }
 
+static void wrp_mov(struct nfp_prog *nfp_prog, swreg dst, swreg src)
+{
+	emit_alu(nfp_prog, dst, reg_none(), ALU_OP_NONE, src);
+}
+
 static void wrp_reg_mov(struct nfp_prog *nfp_prog, u16 dst, u16 src)
 {
-	emit_alu(nfp_prog, reg_both(dst), reg_none(), ALU_OP_NONE, reg_b(src));
+	wrp_mov(nfp_prog, reg_both(dst), reg_b(src));
 }
 
 static int
@@ -556,8 +561,7 @@ construct_data_ind_ld(struct nfp_prog *nfp_prog, u16 offset,
 			 reg_xfer(0), SHF_SC_R_SHF, shift * 8);
 	else
 		for (; i * 4 < size; i++)
-			emit_alu(nfp_prog, reg_both(i),
-				 reg_none(), ALU_OP_NONE, reg_xfer(i));
+			wrp_mov(nfp_prog, reg_both(i), reg_xfer(i));
 
 	if (i < 2)
 		wrp_immed(nfp_prog, reg_both(1), 0);
@@ -1032,8 +1036,8 @@ static int data_ind_ld4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 static int mem_ldx4_skb(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
 	if (meta->insn.off == offsetof(struct sk_buff, len))
-		emit_alu(nfp_prog, reg_both(meta->insn.dst_reg * 2),
-			 reg_none(), ALU_OP_NONE, plen_reg(nfp_prog));
+		wrp_mov(nfp_prog,
+			reg_both(meta->insn.dst_reg * 2), plen_reg(nfp_prog));
 	else
 		return -EOPNOTSUPP;
 
@@ -1048,7 +1052,7 @@ static int mem_ldx4_xdp(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	    meta->insn.off != offsetof(struct xdp_md, data_end))
 		return -EOPNOTSUPP;
 
-	emit_alu(nfp_prog, dst, reg_none(), ALU_OP_NONE, pptr_reg(nfp_prog));
+	wrp_mov(nfp_prog, dst, pptr_reg(nfp_prog));
 
 	if (meta->insn.off == offsetof(struct xdp_md, data))
 		return 0;
@@ -1438,8 +1442,7 @@ static void nfp_outro_tc_legacy(struct nfp_prog *nfp_prog)
 	 *  ife + tx  0x24 -> redir, count as stat1
 	 */
 	emit_br_byte_neq(nfp_prog, reg_b(0), 0xff, 0, nfp_prog->tgt_done, 2);
-	emit_alu(nfp_prog, reg_a(0),
-		 reg_none(), ALU_OP_NONE, NFP_BPF_ABI_FLAGS);
+	wrp_mov(nfp_prog, reg_a(0), NFP_BPF_ABI_FLAGS);
 	emit_ld_field(nfp_prog, reg_a(0), 0xc, reg_imm(0x11), SHF_SC_L_SHF, 16);
 
 	emit_br(nfp_prog, BR_UNC, nfp_prog->tgt_done, 1);
@@ -1466,8 +1469,7 @@ static void nfp_outro_tc_da(struct nfp_prog *nfp_prog)
 
 	emit_br_def(nfp_prog, nfp_prog->tgt_done, 2);
 
-	emit_alu(nfp_prog, reg_a(0),
-		 reg_none(), ALU_OP_NONE, NFP_BPF_ABI_FLAGS);
+	wrp_mov(nfp_prog, reg_a(0), NFP_BPF_ABI_FLAGS);
 	emit_ld_field(nfp_prog, reg_a(0), 0xc, reg_imm(0x11), SHF_SC_L_SHF, 16);
 
 	/* Target for normal exits */
@@ -1476,8 +1478,7 @@ static void nfp_outro_tc_da(struct nfp_prog *nfp_prog)
 	/* if R0 > 7 jump to abort */
 	emit_alu(nfp_prog, reg_none(), reg_imm(7), ALU_OP_SUB, reg_b(0));
 	emit_br(nfp_prog, BR_BLO, nfp_prog->tgt_abort, 0);
-	emit_alu(nfp_prog, reg_a(0),
-		 reg_none(), ALU_OP_NONE, NFP_BPF_ABI_FLAGS);
+	wrp_mov(nfp_prog, reg_a(0), NFP_BPF_ABI_FLAGS);
 
 	wrp_immed(nfp_prog, reg_b(2), 0x41221211);
 	wrp_immed(nfp_prog, reg_b(3), 0x41001211);
@@ -1514,8 +1515,7 @@ static void nfp_outro_xdp(struct nfp_prog *nfp_prog)
 
 	emit_br_def(nfp_prog, nfp_prog->tgt_done, 2);
 
-	emit_alu(nfp_prog, reg_a(0),
-		 reg_none(), ALU_OP_NONE, NFP_BPF_ABI_FLAGS);
+	wrp_mov(nfp_prog, reg_a(0), NFP_BPF_ABI_FLAGS);
 	emit_ld_field(nfp_prog, reg_a(0), 0xc, reg_imm(0x82), SHF_SC_L_SHF, 16);
 
 	/* Target for normal exits */
@@ -1536,8 +1536,7 @@ static void nfp_outro_xdp(struct nfp_prog *nfp_prog)
 
 	emit_br_def(nfp_prog, nfp_prog->tgt_done, 2);
 
-	emit_alu(nfp_prog, reg_a(0),
-		 reg_none(), ALU_OP_NONE, NFP_BPF_ABI_FLAGS);
+	wrp_mov(nfp_prog, reg_a(0), NFP_BPF_ABI_FLAGS);
 	emit_ld_field(nfp_prog, reg_a(0), 0xc, reg_b(2), SHF_SC_L_SHF, 16);
 }
 
-- 
2.14.1
