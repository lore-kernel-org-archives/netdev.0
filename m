From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 2/2] nfp: bpf: support [BPF_ALU | BPF_ALU64] | BPF_NEG
Date: Wed,  1 Nov 2017 10:38:25 -0700
Message-ID: <20171101173825.7008-3-jakub.kicinski@netronome.com>
References: <20171101173825.7008-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, Jiong Wang <jiong.wang@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:47407 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751587AbdKARib (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2017 13:38:31 -0400
Received: by mail-pg0-f67.google.com with SMTP id r25so2692420pgn.4
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 10:38:31 -0700 (PDT)
In-Reply-To: <20171101173825.7008-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiong Wang <jiong.wang@netronome.com>

This patch supports BPF_NEG under both BPF_ALU64 and BPF_ALU. LLVM recently
starts to generate it.

NOTE: BPF_NEG takes single operand which is an register and serve as both
input and output.

Signed-off-by: Jiong Wang <jiong.wang@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 369173100fcf..2609a2487100 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -1218,6 +1218,18 @@ static int sub_imm64(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	return 0;
 }
 
+static int neg_reg64(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	const struct bpf_insn *insn = &meta->insn;
+
+	emit_alu(nfp_prog, reg_both(insn->dst_reg * 2), reg_imm(0),
+		 ALU_OP_SUB, reg_b(insn->dst_reg * 2));
+	emit_alu(nfp_prog, reg_both(insn->dst_reg * 2 + 1), reg_imm(0),
+		 ALU_OP_SUB_C, reg_b(insn->dst_reg * 2 + 1));
+
+	return 0;
+}
+
 static int shl_imm64(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
 	const struct bpf_insn *insn = &meta->insn;
@@ -1338,6 +1350,16 @@ static int sub_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	return wrp_alu32_imm(nfp_prog, meta, ALU_OP_SUB, !meta->insn.imm);
 }
 
+static int neg_reg(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	u8 dst = meta->insn.dst_reg * 2;
+
+	emit_alu(nfp_prog, reg_both(dst), reg_imm(0), ALU_OP_SUB, reg_b(dst));
+	wrp_immed(nfp_prog, reg_both(meta->insn.dst_reg * 2 + 1), 0);
+
+	return 0;
+}
+
 static int shl_imm(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
 	const struct bpf_insn *insn = &meta->insn;
@@ -1847,6 +1869,7 @@ static const instr_cb_t instr_cb[256] = {
 	[BPF_ALU64 | BPF_ADD | BPF_K] =	add_imm64,
 	[BPF_ALU64 | BPF_SUB | BPF_X] =	sub_reg64,
 	[BPF_ALU64 | BPF_SUB | BPF_K] =	sub_imm64,
+	[BPF_ALU64 | BPF_NEG] =		neg_reg64,
 	[BPF_ALU64 | BPF_LSH | BPF_K] =	shl_imm64,
 	[BPF_ALU64 | BPF_RSH | BPF_K] =	shr_imm64,
 	[BPF_ALU | BPF_MOV | BPF_X] =	mov_reg,
@@ -1861,6 +1884,7 @@ static const instr_cb_t instr_cb[256] = {
 	[BPF_ALU | BPF_ADD | BPF_K] =	add_imm,
 	[BPF_ALU | BPF_SUB | BPF_X] =	sub_reg,
 	[BPF_ALU | BPF_SUB | BPF_K] =	sub_imm,
+	[BPF_ALU | BPF_NEG] =		neg_reg,
 	[BPF_ALU | BPF_LSH | BPF_K] =	shl_imm,
 	[BPF_ALU | BPF_END | BPF_X] =	end_reg32,
 	[BPF_LD | BPF_IMM | BPF_DW] =	imm_ld8,
-- 
2.14.1
