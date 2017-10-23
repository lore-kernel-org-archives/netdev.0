From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 8/9] nfp: bpf: support stack accesses via non-constant pointers
Date: Mon, 23 Oct 2017 11:58:13 -0700
Message-ID: <20171023185814.4797-9-jakub.kicinski@netronome.com>
References: <20171023185814.4797-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:57182 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751809AbdJWS6d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 14:58:33 -0400
Received: by mail-pf0-f194.google.com with SMTP id b85so17760944pfj.13
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 11:58:33 -0700 (PDT)
In-Reply-To: <20171023185814.4797-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If stack pointer has a different value on different paths
but the alignment to words (4B) remains the same, we can
set a new LMEM access pointer to the calculated value and
access whichever word it's pointing to.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c      | 41 +++++++++++++++++++----
 drivers/net/ethernet/netronome/nfp/bpf/main.h     |  2 ++
 drivers/net/ethernet/netronome/nfp/bpf/verifier.c | 12 +++++--
 3 files changed, 45 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 5105b9247839..d84f00b80aac 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -832,8 +832,8 @@ wrp_lmem_store(struct nfp_prog *nfp_prog, u8 src, u8 src_byte, s32 off,
 
 static int
 mem_op_stack(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
-	     unsigned int size, unsigned int ptr_off, u8 gpr, bool clr_gpr,
-	     lmem_step step)
+	     unsigned int size, unsigned int ptr_off, u8 gpr, u8 ptr_gpr,
+	     bool clr_gpr, lmem_step step)
 {
 	s32 off = nfp_prog->stack_depth + meta->insn.off + ptr_off;
 	bool first = true, last;
@@ -844,7 +844,19 @@ mem_op_stack(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 	bool lm3 = true;
 	int ret;
 
-	if (off + size <= 64) {
+	if (meta->ptr_not_const) {
+		/* Use of the last encountered ptr_off is OK, they all have
+		 * the same alignment.  Depend on low bits of value being
+		 * discarded when written to LMaddr register.
+		 */
+		stack_off_reg = ur_load_imm_any(nfp_prog, meta->insn.off,
+						stack_imm(nfp_prog));
+
+		emit_alu(nfp_prog, imm_b(nfp_prog),
+			 reg_a(ptr_gpr), ALU_OP_ADD, stack_off_reg);
+
+		needs_inc = true;
+	} else if (off + size <= 64) {
 		/* We can reach bottom 64B with LMaddr0 */
 		lm3 = false;
 	} else if (round_down(off, 32) == round_down(off + size - 1, 32)) {
@@ -1096,9 +1108,22 @@ static void wrp_end32(struct nfp_prog *nfp_prog, swreg reg_in, u8 gpr_out)
 static int mov_reg64(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
 	const struct bpf_insn *insn = &meta->insn;
+	u8 dst = insn->dst_reg * 2;
+	u8 src = insn->src_reg * 2;
+
+	if (insn->src_reg == BPF_REG_10) {
+		swreg stack_depth_reg;
 
-	wrp_reg_mov(nfp_prog, insn->dst_reg * 2, insn->src_reg * 2);
-	wrp_reg_mov(nfp_prog, insn->dst_reg * 2 + 1, insn->src_reg * 2 + 1);
+		stack_depth_reg = ur_load_imm_any(nfp_prog,
+						  nfp_prog->stack_depth,
+						  stack_imm(nfp_prog));
+		emit_alu(nfp_prog, reg_both(dst),
+			 stack_reg(nfp_prog), ALU_OP_ADD, stack_depth_reg);
+		wrp_immed(nfp_prog, reg_both(dst + 1), 0);
+	} else {
+		wrp_reg_mov(nfp_prog, dst, src);
+		wrp_reg_mov(nfp_prog, dst + 1, src + 1);
+	}
 
 	return 0;
 }
@@ -1413,7 +1438,8 @@ mem_ldx_stack(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 	      unsigned int size, unsigned int ptr_off)
 {
 	return mem_op_stack(nfp_prog, meta, size, ptr_off,
-			    meta->insn.dst_reg * 2, true, wrp_lmem_load);
+			    meta->insn.dst_reg * 2, meta->insn.src_reg * 2,
+			    true, wrp_lmem_load);
 }
 
 static int mem_ldx_skb(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
@@ -1585,7 +1611,8 @@ mem_stx_stack(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 	      unsigned int size, unsigned int ptr_off)
 {
 	return mem_op_stack(nfp_prog, meta, size, ptr_off,
-			    meta->insn.src_reg * 2, false, wrp_lmem_store);
+			    meta->insn.src_reg * 2, meta->insn.dst_reg * 2,
+			    false, wrp_lmem_store);
 }
 
 static int
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.h b/drivers/net/ethernet/netronome/nfp/bpf/main.h
index d4f144a62f0f..86edc0691a5f 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.h
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.h
@@ -101,6 +101,7 @@ typedef int (*instr_cb_t)(struct nfp_prog *, struct nfp_insn_meta *);
  * struct nfp_insn_meta - BPF instruction wrapper
  * @insn: BPF instruction
  * @ptr: pointer type for memory operations
+ * @ptr_not_const: pointer is not always constant
  * @off: index of first generated machine instruction (in nfp_prog.prog)
  * @n: eBPF instruction number
  * @skip: skip this instruction (optimized out)
@@ -110,6 +111,7 @@ typedef int (*instr_cb_t)(struct nfp_prog *, struct nfp_insn_meta *);
 struct nfp_insn_meta {
 	struct bpf_insn insn;
 	struct bpf_reg_state ptr;
+	bool ptr_not_const;
 	unsigned int off;
 	unsigned short n;
 	bool skip;
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
index 633db3e1a11e..3d3dcac1c942 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
@@ -112,7 +112,8 @@ nfp_bpf_check_exit(struct nfp_prog *nfp_prog,
 }
 
 static int
-nfp_bpf_check_stack_access(struct nfp_insn_meta *meta,
+nfp_bpf_check_stack_access(struct nfp_prog *nfp_prog,
+			   struct nfp_insn_meta *meta,
 			   const struct bpf_reg_state *reg)
 {
 	s32 old_off, new_off;
@@ -128,7 +129,12 @@ nfp_bpf_check_stack_access(struct nfp_insn_meta *meta,
 	old_off = meta->ptr.off + meta->ptr.var_off.value;
 	new_off = reg->off + reg->var_off.value;
 
-	if (old_off == new_off)
+	meta->ptr_not_const |= old_off != new_off;
+
+	if (!meta->ptr_not_const)
+		return 0;
+
+	if (old_off % 4 == new_off % 4)
 		return 0;
 
 	pr_info("stack access changed location was:%d is:%d\n",
@@ -151,7 +157,7 @@ nfp_bpf_check_ptr(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 	}
 
 	if (reg->type == PTR_TO_STACK) {
-		err = nfp_bpf_check_stack_access(meta, reg);
+		err = nfp_bpf_check_stack_access(nfp_prog, meta, reg);
 		if (err)
 			return err;
 	}
-- 
2.14.1
