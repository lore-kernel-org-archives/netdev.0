From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 06/12] nfp: bpf: implement byte swap instruction
Date: Thu, 12 Oct 2017 10:34:12 -0700
Message-ID: <20171012173418.4029-7-jakub.kicinski@netronome.com>
References: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:43253 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752786AbdJLRex (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:34:53 -0400
Received: by mail-pf0-f174.google.com with SMTP id a8so5395387pfc.0
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:34:53 -0700 (PDT)
In-Reply-To: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement byte swaps with rotations, shifts and byte loads.
Remember to clear upper parts of the 64 bit registers.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 38 ++++++++++++++++++++++++++++
 1 file changed, 38 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 4f7cfa6adfc1..5e8a6b766790 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -746,6 +746,14 @@ wrp_cmp_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 	return 0;
 }
 
+static void wrp_end32(struct nfp_prog *nfp_prog, swreg reg_in, u8 gpr_out)
+{
+	emit_ld_field(nfp_prog, reg_both(gpr_out), 0xf, reg_in,
+		      SHF_SC_R_ROT, 8);
+	emit_ld_field(nfp_prog, reg_both(gpr_out), 0x5, reg_a(gpr_out),
+		      SHF_SC_R_ROT, 16);
+}
+
 /* --- Callbacks --- */
 static int mov_reg64(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
@@ -982,6 +990,35 @@ static int shl_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	return 0;
 }
 
+static int end_reg32(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	const struct bpf_insn *insn = &meta->insn;
+	u8 gpr = insn->dst_reg * 2;
+
+	switch (insn->imm) {
+	case 16:
+		emit_ld_field(nfp_prog, reg_both(gpr), 0x9, reg_b(gpr),
+			      SHF_SC_R_ROT, 8);
+		emit_ld_field(nfp_prog, reg_both(gpr), 0xe, reg_a(gpr),
+			      SHF_SC_R_SHF, 16);
+
+		wrp_immed(nfp_prog, reg_both(gpr + 1), 0);
+		break;
+	case 32:
+		wrp_end32(nfp_prog, reg_a(gpr), gpr);
+		wrp_immed(nfp_prog, reg_both(gpr + 1), 0);
+		break;
+	case 64:
+		wrp_mov(nfp_prog, imm_a(nfp_prog), reg_b(gpr + 1));
+
+		wrp_end32(nfp_prog, reg_a(gpr), gpr + 1);
+		wrp_end32(nfp_prog, imm_a(nfp_prog), gpr);
+		break;
+	}
+
+	return 0;
+}
+
 static int imm_ld8_part2(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
 	wrp_immed(nfp_prog, reg_both(nfp_meta_prev(meta)->insn.dst_reg * 2 + 1),
@@ -1297,6 +1334,7 @@ static const instr_cb_t instr_cb[256] = {
 	[BPF_ALU | BPF_SUB | BPF_X] =	sub_reg,
 	[BPF_ALU | BPF_SUB | BPF_K] =	sub_imm,
 	[BPF_ALU | BPF_LSH | BPF_K] =	shl_imm,
+	[BPF_ALU | BPF_END | BPF_X] =	end_reg32,
 	[BPF_LD | BPF_IMM | BPF_DW] =	imm_ld8,
 	[BPF_LD | BPF_ABS | BPF_B] =	data_ld1,
 	[BPF_LD | BPF_ABS | BPF_H] =	data_ld2,
-- 
2.14.1
