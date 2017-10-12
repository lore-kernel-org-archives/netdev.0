From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 11/12] nfp: bpf: direct packet access - write
Date: Thu, 12 Oct 2017 10:34:17 -0700
Message-ID: <20171012173418.4029-12-jakub.kicinski@netronome.com>
References: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:56090 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752881AbdJLRe6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:34:58 -0400
Received: by mail-pf0-f181.google.com with SMTP id 17so5824695pfn.12
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:34:58 -0700 (PDT)
In-Reply-To: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds ability to write packet contents using pre-validated
packet pointers (direct packet access).

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c | 114 +++++++++++++++++++++++++--
 drivers/net/ethernet/netronome/nfp/nfp_asm.c |   2 +-
 drivers/net/ethernet/netronome/nfp/nfp_asm.h |   2 +-
 3 files changed, 109 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 975d63fbc1d5..139a4ebdc774 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -607,6 +607,35 @@ static int construct_data_ld(struct nfp_prog *nfp_prog, u16 offset, u8 size)
 	return data_ld(nfp_prog, tmp_reg, 0, size);
 }
 
+static int
+data_stx_host_order(struct nfp_prog *nfp_prog, u8 dst_gpr, swreg offset,
+		    u8 src_gpr, u8 size)
+{
+	unsigned int i;
+
+	for (i = 0; i * 4 < size; i++)
+		wrp_mov(nfp_prog, reg_xfer(i), reg_a(src_gpr + i));
+
+	emit_cmd(nfp_prog, CMD_TGT_WRITE8_SWAP, CMD_MODE_32b, 0,
+		 reg_a(dst_gpr), offset, size - 1, true);
+
+	return 0;
+}
+
+static int
+data_st_host_order(struct nfp_prog *nfp_prog, u8 dst_gpr, swreg offset,
+		   u64 imm, u8 size)
+{
+	wrp_immed(nfp_prog, reg_xfer(0), imm);
+	if (size == 8)
+		wrp_immed(nfp_prog, reg_xfer(1), imm >> 32);
+
+	emit_cmd(nfp_prog, CMD_TGT_WRITE8_SWAP, CMD_MODE_32b, 0,
+		 reg_a(dst_gpr), offset, size - 1, true);
+
+	return 0;
+}
+
 static void
 wrp_alu_imm(struct nfp_prog *nfp_prog, u8 dst, enum alu_op alu_op, u32 imm)
 {
@@ -1196,24 +1225,88 @@ static int mem_ldx8(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	return mem_ldx(nfp_prog, meta, 8);
 }
 
-static int mem_stx4_skb(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+static int
+mem_st_data(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
+	    unsigned int size)
+{
+	u64 imm = meta->insn.imm; /* sign extend */
+	swreg off_reg;
+
+	off_reg = re_load_imm_any(nfp_prog, meta->insn.off, imm_b(nfp_prog));
+
+	return data_st_host_order(nfp_prog, meta->insn.dst_reg * 2, off_reg,
+				  imm, size);
+}
+
+static int mem_st(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
+		  unsigned int size)
 {
+	if (meta->ptr.type == PTR_TO_PACKET)
+		return mem_st_data(nfp_prog, meta, size);
+
 	return -EOPNOTSUPP;
 }
 
-static int mem_stx4_xdp(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+static int mem_st1(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return mem_st(nfp_prog, meta, 1);
+}
+
+static int mem_st2(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return mem_st(nfp_prog, meta, 2);
+}
+
+static int mem_st4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return mem_st(nfp_prog, meta, 4);
+}
+
+static int mem_st8(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
+	return mem_st(nfp_prog, meta, 8);
+}
+
+static int
+mem_stx_data(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
+	     unsigned int size)
+{
+	swreg off_reg;
+
+	off_reg = re_load_imm_any(nfp_prog, meta->insn.off, imm_b(nfp_prog));
+
+	return data_stx_host_order(nfp_prog, meta->insn.dst_reg * 2, off_reg,
+				   meta->insn.src_reg * 2, size);
+}
+
+static int
+mem_stx(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
+	unsigned int size)
+{
+	if (meta->ptr.type == PTR_TO_PACKET)
+		return mem_stx_data(nfp_prog, meta, size);
+
 	return -EOPNOTSUPP;
 }
 
+static int mem_stx1(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return mem_stx(nfp_prog, meta, 1);
+}
+
+static int mem_stx2(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return mem_stx(nfp_prog, meta, 2);
+}
+
 static int mem_stx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
-	if (meta->ptr.type == PTR_TO_PACKET)
-		return -EOPNOTSUPP;
+	return mem_stx(nfp_prog, meta, 4);
+}
 
-	if (nfp_prog->act == NN_ACT_XDP)
-		return mem_stx4_xdp(nfp_prog, meta);
-	return mem_stx4_skb(nfp_prog, meta);
+static int mem_stx8(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return mem_stx(nfp_prog, meta, 8);
 }
 
 static int jump(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
@@ -1432,7 +1525,14 @@ static const instr_cb_t instr_cb[256] = {
 	[BPF_LDX | BPF_MEM | BPF_H] =	mem_ldx2,
 	[BPF_LDX | BPF_MEM | BPF_W] =	mem_ldx4,
 	[BPF_LDX | BPF_MEM | BPF_DW] =	mem_ldx8,
+	[BPF_STX | BPF_MEM | BPF_B] =	mem_stx1,
+	[BPF_STX | BPF_MEM | BPF_H] =	mem_stx2,
 	[BPF_STX | BPF_MEM | BPF_W] =	mem_stx4,
+	[BPF_STX | BPF_MEM | BPF_DW] =	mem_stx8,
+	[BPF_ST | BPF_MEM | BPF_B] =	mem_st1,
+	[BPF_ST | BPF_MEM | BPF_H] =	mem_st2,
+	[BPF_ST | BPF_MEM | BPF_W] =	mem_st4,
+	[BPF_ST | BPF_MEM | BPF_DW] =	mem_st8,
 	[BPF_JMP | BPF_JA | BPF_K] =	jump,
 	[BPF_JMP | BPF_JEQ | BPF_K] =	jeq_imm,
 	[BPF_JMP | BPF_JGT | BPF_K] =	jgt_imm,
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_asm.c b/drivers/net/ethernet/netronome/nfp/nfp_asm.c
index 7cae99b3e00a..830f6de25f47 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_asm.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_asm.c
@@ -40,7 +40,7 @@
 #include "nfp_asm.h"
 
 const struct cmd_tgt_act cmd_tgt_act[__CMD_TGT_MAP_SIZE] = {
-	[CMD_TGT_WRITE8] =		{ 0x00, 0x42 },
+	[CMD_TGT_WRITE8_SWAP] =		{ 0x02, 0x42 },
 	[CMD_TGT_READ8] =		{ 0x01, 0x43 },
 	[CMD_TGT_READ32] =		{ 0x00, 0x5c },
 	[CMD_TGT_READ32_LE] =		{ 0x01, 0x5c },
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_asm.h b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
index e3df7a26724f..c26aa7e4a839 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_asm.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
@@ -217,7 +217,7 @@ struct cmd_tgt_act {
 
 enum cmd_tgt_map {
 	CMD_TGT_READ8,
-	CMD_TGT_WRITE8,
+	CMD_TGT_WRITE8_SWAP,
 	CMD_TGT_READ32,
 	CMD_TGT_READ32_LE,
 	CMD_TGT_READ32_SWAP,
-- 
2.14.1
