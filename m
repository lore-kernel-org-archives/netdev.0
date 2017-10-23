From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 6/9] nfp: bpf: allow stack accesses via modified stack registers
Date: Mon, 23 Oct 2017 11:58:11 -0700
Message-ID: <20171023185814.4797-7-jakub.kicinski@netronome.com>
References: <20171023185814.4797-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:43526 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751810AbdJWS6b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 14:58:31 -0400
Received: by mail-pf0-f193.google.com with SMTP id a8so17779800pfc.0
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 11:58:31 -0700 (PDT)
In-Reply-To: <20171023185814.4797-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As long as the verifier tells us the stack offset exactly we
can render the LMEM reads quite easily.  Simply make sure that
the offset is constant for a given instruction and add it to
the instruction's offset.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c      | 23 ++++++++++++----------
 drivers/net/ethernet/netronome/nfp/bpf/main.h     |  3 +++
 drivers/net/ethernet/netronome/nfp/bpf/verifier.c | 24 ++++++++++++++++-------
 3 files changed, 33 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index 6730690cf9d8..073e382cba04 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -771,9 +771,10 @@ wrp_lmem_store(struct nfp_prog *nfp_prog, u8 src, u8 src_byte, s32 off,
 
 static int
 mem_op_stack(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
-	     unsigned int size, u8 gpr, bool clr_gpr, lmem_step step)
+	     unsigned int size, unsigned int ptr_off, u8 gpr, bool clr_gpr,
+	     lmem_step step)
 {
-	s32 off = nfp_prog->stack_depth + meta->insn.off;
+	s32 off = nfp_prog->stack_depth + meta->insn.off + ptr_off;
 	bool first = true, last;
 	u8 prev_gpr = 255;
 	u32 gpr_byte = 0;
@@ -1311,10 +1312,10 @@ static int data_ind_ld4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 
 static int
 mem_ldx_stack(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
-	      unsigned int size)
+	      unsigned int size, unsigned int ptr_off)
 {
-	return mem_op_stack(nfp_prog, meta, size, meta->insn.dst_reg * 2, true,
-			    wrp_lmem_load);
+	return mem_op_stack(nfp_prog, meta, size, ptr_off,
+			    meta->insn.dst_reg * 2, true, wrp_lmem_load);
 }
 
 static int mem_ldx_skb(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
@@ -1401,7 +1402,8 @@ mem_ldx(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 		return mem_ldx_data(nfp_prog, meta, size);
 
 	if (meta->ptr.type == PTR_TO_STACK)
-		return mem_ldx_stack(nfp_prog, meta, size);
+		return mem_ldx_stack(nfp_prog, meta, size,
+				     meta->ptr.off + meta->ptr.var_off.value);
 
 	return -EOPNOTSUPP;
 }
@@ -1482,10 +1484,10 @@ mem_stx_data(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 
 static int
 mem_stx_stack(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
-	      unsigned int size)
+	      unsigned int size, unsigned int ptr_off)
 {
-	return mem_op_stack(nfp_prog, meta, size, meta->insn.src_reg * 2, false,
-			    wrp_lmem_store);
+	return mem_op_stack(nfp_prog, meta, size, ptr_off,
+			    meta->insn.src_reg * 2, false, wrp_lmem_store);
 }
 
 static int
@@ -1496,7 +1498,8 @@ mem_stx(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 		return mem_stx_data(nfp_prog, meta, size);
 
 	if (meta->ptr.type == PTR_TO_STACK)
-		return mem_stx_stack(nfp_prog, meta, size);
+		return mem_stx_stack(nfp_prog, meta, size,
+				     meta->ptr.off + meta->ptr.var_off.value);
 
 	return -EOPNOTSUPP;
 }
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.h b/drivers/net/ethernet/netronome/nfp/bpf/main.h
index a31632681e79..d4f144a62f0f 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.h
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.h
@@ -56,6 +56,7 @@ enum br_special {
 
 enum static_regs {
 	STATIC_REG_IMM		= 21, /* Bank AB */
+	STATIC_REG_STACK	= 22, /* Bank A */
 	STATIC_REG_PKT_LEN	= 22, /* Bank B */
 };
 
@@ -74,6 +75,8 @@ enum nfp_bpf_action_type {
 #define pv_len(np)	reg_lm(1, PKT_VEC_PKT_LEN)
 #define pv_ctm_ptr(np)	reg_lm(1, PKT_VEC_PKT_PTR)
 
+#define stack_reg(np)	reg_a(STATIC_REG_STACK)
+#define stack_imm(np)	imm_b(np)
 #define plen_reg(np)	reg_b(STATIC_REG_PKT_LEN)
 #define pptr_reg(np)	pv_ctm_ptr(np)
 #define imm_a(np)	reg_a(STATIC_REG_IMM)
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
index 376d9938b823..633db3e1a11e 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
@@ -111,19 +111,29 @@ nfp_bpf_check_exit(struct nfp_prog *nfp_prog,
 	return 0;
 }
 
-static int nfp_bpf_check_stack_access(const struct bpf_reg_state *reg)
+static int
+nfp_bpf_check_stack_access(struct nfp_insn_meta *meta,
+			   const struct bpf_reg_state *reg)
 {
+	s32 old_off, new_off;
+
 	if (!tnum_is_const(reg->var_off)) {
 		pr_info("variable ptr stack access\n");
 		return -EINVAL;
 	}
 
-	if (reg->var_off.value || reg->off) {
-		pr_info("stack access via modified register\n");
-		return -EINVAL;
-	}
+	if (meta->ptr.type == NOT_INIT)
+		return 0;
 
-	return 0;
+	old_off = meta->ptr.off + meta->ptr.var_off.value;
+	new_off = reg->off + reg->var_off.value;
+
+	if (old_off == new_off)
+		return 0;
+
+	pr_info("stack access changed location was:%d is:%d\n",
+		old_off, new_off);
+	return -EINVAL;
 }
 
 static int
@@ -141,7 +151,7 @@ nfp_bpf_check_ptr(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 	}
 
 	if (reg->type == PTR_TO_STACK) {
-		err = nfp_bpf_check_stack_access(reg);
+		err = nfp_bpf_check_stack_access(meta, reg);
 		if (err)
 			return err;
 	}
-- 
2.14.1
