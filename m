From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 10/12] nfp: bpf: add support for direct packet access - read
Date: Thu, 12 Oct 2017 10:34:16 -0700
Message-ID: <20171012173418.4029-11-jakub.kicinski@netronome.com>
References: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:56088 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752704AbdJLRe5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 13:34:57 -0400
Received: by mail-pf0-f181.google.com with SMTP id 17so5824644pfn.12
        for <netdev@vger.kernel.org>; Thu, 12 Oct 2017 10:34:57 -0700 (PDT)
In-Reply-To: <20171012173418.4029-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In direct packet access bound checks are already done, we can
simply dereference the packet pointer.

Verifier/parser logic needs to record pointer type.  Note that
although verifier does protect us from CTX vs other pointer
changes we will also want to differentiate between PACKET vs
MAP_VALUE or STACK, so we can add the check already.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c      | 85 +++++++++++++++++++++--
 drivers/net/ethernet/netronome/nfp/bpf/main.h     |  3 +
 drivers/net/ethernet/netronome/nfp/bpf/verifier.c | 21 ++++--
 drivers/net/ethernet/netronome/nfp/nfp_asm.c      |  3 +
 drivers/net/ethernet/netronome/nfp/nfp_asm.h      |  4 ++
 5 files changed, 105 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 3e173da16428..975d63fbc1d5 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -543,6 +543,36 @@ data_ld(struct nfp_prog *nfp_prog, swreg offset, u8 dst_gpr, int size)
 	return 0;
 }
 
+static int
+data_ld_host_order(struct nfp_prog *nfp_prog, u8 src_gpr, swreg offset,
+		   u8 dst_gpr, int size)
+{
+	unsigned int i;
+	u8 mask, sz;
+
+	/* We load the value from the address indicated in @offset and then
+	 * mask out the data we don't need.  Note: this is little endian!
+	 */
+	sz = max(size, 4);
+	mask = size < 4 ? GENMASK(size - 1, 0) : 0;
+
+	emit_cmd(nfp_prog, CMD_TGT_READ32_SWAP, CMD_MODE_32b, 0,
+		 reg_a(src_gpr), offset, sz / 4 - 1, true);
+
+	i = 0;
+	if (mask)
+		emit_ld_field_any(nfp_prog, reg_both(dst_gpr), mask,
+				  reg_xfer(0), SHF_SC_NONE, 0, true);
+	else
+		for (; i * 4 < size; i++)
+			wrp_mov(nfp_prog, reg_both(dst_gpr + i), reg_xfer(i));
+
+	if (i < 2)
+		wrp_immed(nfp_prog, reg_both(dst_gpr + 1), 0);
+
+	return 0;
+}
+
 static int
 construct_data_ind_ld(struct nfp_prog *nfp_prog, u16 offset, u16 src, u8 size)
 {
@@ -1117,12 +1147,53 @@ static int mem_ldx_xdp(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 	return 0;
 }
 
+static int
+mem_ldx_data(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
+	     unsigned int size)
+{
+	swreg tmp_reg;
+
+	tmp_reg = re_load_imm_any(nfp_prog, meta->insn.off, imm_b(nfp_prog));
+
+	return data_ld_host_order(nfp_prog, meta->insn.src_reg * 2, tmp_reg,
+				  meta->insn.dst_reg * 2, size);
+}
+
+static int
+mem_ldx(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
+	unsigned int size)
+{
+	if (meta->ptr.type == PTR_TO_CTX) {
+		if (nfp_prog->act == NN_ACT_XDP)
+			return mem_ldx_xdp(nfp_prog, meta, size);
+		else
+			return mem_ldx_skb(nfp_prog, meta, size);
+	}
+
+	if (meta->ptr.type == PTR_TO_PACKET)
+		return mem_ldx_data(nfp_prog, meta, size);
+
+	return -EOPNOTSUPP;
+}
+
+static int mem_ldx1(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return mem_ldx(nfp_prog, meta, 1);
+}
+
+static int mem_ldx2(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return mem_ldx(nfp_prog, meta, 2);
+}
+
 static int mem_ldx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
-	if (nfp_prog->act == NN_ACT_XDP)
-		return mem_ldx_xdp(nfp_prog, meta, 4);
-	else
-		return mem_ldx_skb(nfp_prog, meta, 4);
+	return mem_ldx(nfp_prog, meta, 4);
+}
+
+static int mem_ldx8(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
+{
+	return mem_ldx(nfp_prog, meta, 8);
 }
 
 static int mem_stx4_skb(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
@@ -1137,6 +1208,9 @@ static int mem_stx4_xdp(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 
 static int mem_stx4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
+	if (meta->ptr.type == PTR_TO_PACKET)
+		return -EOPNOTSUPP;
+
 	if (nfp_prog->act == NN_ACT_XDP)
 		return mem_stx4_xdp(nfp_prog, meta);
 	return mem_stx4_skb(nfp_prog, meta);
@@ -1354,7 +1428,10 @@ static const instr_cb_t instr_cb[256] = {
 	[BPF_LD | BPF_IND | BPF_B] =	data_ind_ld1,
 	[BPF_LD | BPF_IND | BPF_H] =	data_ind_ld2,
 	[BPF_LD | BPF_IND | BPF_W] =	data_ind_ld4,
+	[BPF_LDX | BPF_MEM | BPF_B] =	mem_ldx1,
+	[BPF_LDX | BPF_MEM | BPF_H] =	mem_ldx2,
 	[BPF_LDX | BPF_MEM | BPF_W] =	mem_ldx4,
+	[BPF_LDX | BPF_MEM | BPF_DW] =	mem_ldx8,
 	[BPF_STX | BPF_MEM | BPF_W] =	mem_stx4,
 	[BPF_JMP | BPF_JA | BPF_K] =	jump,
 	[BPF_JMP | BPF_JEQ | BPF_K] =	jeq_imm,
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.h b/drivers/net/ethernet/netronome/nfp/bpf/main.h
index b7a112acbdb7..d77e88a45409 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.h
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.h
@@ -36,6 +36,7 @@
 
 #include <linux/bitfield.h>
 #include <linux/bpf.h>
+#include <linux/bpf_verifier.h>
 #include <linux/list.h>
 #include <linux/types.h>
 
@@ -96,6 +97,7 @@ typedef int (*instr_cb_t)(struct nfp_prog *, struct nfp_insn_meta *);
 /**
  * struct nfp_insn_meta - BPF instruction wrapper
  * @insn: BPF instruction
+ * @ptr: pointer type for memory operations
  * @off: index of first generated machine instruction (in nfp_prog.prog)
  * @n: eBPF instruction number
  * @skip: skip this instruction (optimized out)
@@ -104,6 +106,7 @@ typedef int (*instr_cb_t)(struct nfp_prog *, struct nfp_insn_meta *);
  */
 struct nfp_insn_meta {
 	struct bpf_insn insn;
+	struct bpf_reg_state ptr;
 	unsigned int off;
 	unsigned short n;
 	bool skip;
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
index 5b783a91b115..e361c0e3b788 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
@@ -112,12 +112,19 @@ nfp_bpf_check_exit(struct nfp_prog *nfp_prog,
 }
 
 static int
-nfp_bpf_check_ctx_ptr(struct nfp_prog *nfp_prog,
-		      const struct bpf_verifier_env *env, u8 reg)
+nfp_bpf_check_ptr(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
+		  const struct bpf_verifier_env *env, u8 reg)
 {
-	if (env->cur_state.regs[reg].type != PTR_TO_CTX)
+	if (env->cur_state.regs[reg].type != PTR_TO_CTX &&
+	    env->cur_state.regs[reg].type != PTR_TO_PACKET)
 		return -EINVAL;
 
+	if (meta->ptr.type != NOT_INIT &&
+	    meta->ptr.type != env->cur_state.regs[reg].type)
+		return -EINVAL;
+
+	meta->ptr = env->cur_state.regs[reg];
+
 	return 0;
 }
 
@@ -145,11 +152,11 @@ nfp_verify_insn(struct bpf_verifier_env *env, int insn_idx, int prev_insn_idx)
 		return nfp_bpf_check_exit(priv->prog, env);
 
 	if ((meta->insn.code & ~BPF_SIZE_MASK) == (BPF_LDX | BPF_MEM))
-		return nfp_bpf_check_ctx_ptr(priv->prog, env,
-					     meta->insn.src_reg);
+		return nfp_bpf_check_ptr(priv->prog, meta, env,
+					 meta->insn.src_reg);
 	if ((meta->insn.code & ~BPF_SIZE_MASK) == (BPF_STX | BPF_MEM))
-		return nfp_bpf_check_ctx_ptr(priv->prog, env,
-					     meta->insn.dst_reg);
+		return nfp_bpf_check_ptr(priv->prog, meta, env,
+					 meta->insn.dst_reg);
 
 	return 0;
 }
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_asm.c b/drivers/net/ethernet/netronome/nfp/nfp_asm.c
index de76e7444fc2..7cae99b3e00a 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_asm.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_asm.c
@@ -42,6 +42,9 @@
 const struct cmd_tgt_act cmd_tgt_act[__CMD_TGT_MAP_SIZE] = {
 	[CMD_TGT_WRITE8] =		{ 0x00, 0x42 },
 	[CMD_TGT_READ8] =		{ 0x01, 0x43 },
+	[CMD_TGT_READ32] =		{ 0x00, 0x5c },
+	[CMD_TGT_READ32_LE] =		{ 0x01, 0x5c },
+	[CMD_TGT_READ32_SWAP] =		{ 0x02, 0x5c },
 	[CMD_TGT_READ_LE] =		{ 0x01, 0x40 },
 	[CMD_TGT_READ_SWAP_LE] =	{ 0x03, 0x40 },
 };
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_asm.h b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
index c4c18dd5630a..e3df7a26724f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_asm.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_asm.h
@@ -153,6 +153,7 @@ enum shf_op {
 
 enum shf_sc {
 	SHF_SC_R_ROT = 0,
+	SHF_SC_NONE = SHF_SC_R_ROT,
 	SHF_SC_R_SHF = 1,
 	SHF_SC_L_SHF = 2,
 	SHF_SC_R_DSHF = 3,
@@ -217,6 +218,9 @@ struct cmd_tgt_act {
 enum cmd_tgt_map {
 	CMD_TGT_READ8,
 	CMD_TGT_WRITE8,
+	CMD_TGT_READ32,
+	CMD_TGT_READ32_LE,
+	CMD_TGT_READ32_SWAP,
 	CMD_TGT_READ_LE,
 	CMD_TGT_READ_SWAP_LE,
 	__CMD_TGT_MAP_SIZE,
-- 
2.14.1
