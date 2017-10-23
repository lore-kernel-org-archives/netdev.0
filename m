From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 3/9] nfp: bpf: add stack write support
Date: Mon, 23 Oct 2017 11:58:08 -0700
Message-ID: <20171023185814.4797-4-jakub.kicinski@netronome.com>
References: <20171023185814.4797-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:52133 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751673AbdJWS63 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Oct 2017 14:58:29 -0400
Received: by mail-pg0-f66.google.com with SMTP id p9so12477295pgc.8
        for <netdev@vger.kernel.org>; Mon, 23 Oct 2017 11:58:28 -0700 (PDT)
In-Reply-To: <20171023185814.4797-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stack is implemented by the LMEM register file.  Unaligned accesses
to LMEM are not allowed.  Accesses also have to be 4B wide.

To support stack we need to make sure offsets of pointers are known
at translation time (for now) and perform correct load/mask/shift
operations.

Since we can access first 64B of LMEM without much effort support
only stacks not bigger than 64B.  Following commits will extend
the possible sizes beyond that.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/bpf/jit.c      | 105 ++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/bpf/main.h     |   3 +
 drivers/net/ethernet/netronome/nfp/bpf/offload.c  |  14 +++
 drivers/net/ethernet/netronome/nfp/bpf/verifier.c |  30 +++++--
 4 files changed, 147 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/bpf/jit.c b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
index eb8c905936ac..d2a3e9065dbe 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/jit.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/jit.c
@@ -642,6 +642,100 @@ data_st_host_order(struct nfp_prog *nfp_prog, u8 dst_gpr, swreg offset,
 	return 0;
 }
 
+typedef int
+(*lmem_step)(struct nfp_prog *nfp_prog, u8 gpr, u8 gpr_byte, s32 off,
+	     unsigned int size);
+
+static int
+wrp_lmem_store(struct nfp_prog *nfp_prog, u8 src, u8 src_byte, s32 off,
+	       unsigned int size)
+{
+	u32 idx, dst_byte;
+	enum shf_sc sc;
+	swreg reg;
+	int shf;
+	u8 mask;
+
+	if (WARN_ON_ONCE(src_byte + size > 4 || off % 4 + size > 4))
+		return -EOPNOTSUPP;
+
+	idx = off / 4;
+
+	/* Move the entire word */
+	if (size == 4) {
+		wrp_mov(nfp_prog, reg_lm(0, idx), reg_b(src));
+		return 0;
+	}
+
+	dst_byte = off % 4;
+
+	mask = (1 << size) - 1;
+	mask <<= dst_byte;
+
+	if (WARN_ON_ONCE(mask > 0xf))
+		return -EOPNOTSUPP;
+
+	shf = abs(src_byte - dst_byte) * 8;
+	if (src_byte == dst_byte) {
+		sc = SHF_SC_NONE;
+	} else if (src_byte < dst_byte) {
+		shf = 32 - shf;
+		sc = SHF_SC_L_SHF;
+	} else {
+		sc = SHF_SC_R_SHF;
+	}
+
+	/* ld_field can address fewer indexes, if offset too large do RMW.
+	 * Because we RMV twice we waste 2 cycles on unaligned 8 byte writes.
+	 */
+	if (idx <= RE_REG_LM_IDX_MAX) {
+		reg = reg_lm(0, idx);
+	} else {
+		reg = imm_a(nfp_prog);
+		wrp_mov(nfp_prog, reg, reg_lm(0, idx));
+	}
+
+	emit_ld_field(nfp_prog, reg, mask, reg_b(src), sc, shf);
+
+	if (idx > RE_REG_LM_IDX_MAX)
+		wrp_mov(nfp_prog, reg_lm(0, idx), reg);
+
+	return 0;
+}
+
+static int
+mem_op_stack(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
+	     unsigned int size, u8 gpr, lmem_step step)
+{
+	s32 off = nfp_prog->stack_depth + meta->insn.off;
+	u32 gpr_byte = 0;
+	int ret;
+
+	while (size) {
+		u32 slice_end;
+		u8 slice_size;
+
+		slice_size = min(size, 4 - gpr_byte);
+		slice_end = min(off + slice_size, round_up(off + 1, 4));
+		slice_size = slice_end - off;
+
+		ret = step(nfp_prog, gpr, gpr_byte, off, slice_size);
+		if (ret)
+			return ret;
+
+		gpr_byte += slice_size;
+		if (gpr_byte >= 4) {
+			gpr_byte -= 4;
+			gpr++;
+		}
+
+		size -= slice_size;
+		off += slice_size;
+	}
+
+	return 0;
+}
+
 static void
 wrp_alu_imm(struct nfp_prog *nfp_prog, u8 dst, enum alu_op alu_op, u32 imm)
 {
@@ -1298,6 +1392,14 @@ mem_stx_data(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 				   meta->insn.src_reg * 2, size);
 }
 
+static int
+mem_stx_stack(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
+	      unsigned int size)
+{
+	return mem_op_stack(nfp_prog, meta, size, meta->insn.src_reg * 2,
+			    wrp_lmem_store);
+}
+
 static int
 mem_stx(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 	unsigned int size)
@@ -1305,6 +1407,9 @@ mem_stx(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 	if (meta->ptr.type == PTR_TO_PACKET)
 		return mem_stx_data(nfp_prog, meta, size);
 
+	if (meta->ptr.type == PTR_TO_STACK)
+		return mem_stx_stack(nfp_prog, meta, size);
+
 	return -EOPNOTSUPP;
 }
 
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/main.h b/drivers/net/ethernet/netronome/nfp/bpf/main.h
index d77e88a45409..a31632681e79 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/main.h
+++ b/drivers/net/ethernet/netronome/nfp/bpf/main.h
@@ -151,6 +151,7 @@ static inline u8 mbpf_mode(const struct nfp_insn_meta *meta)
  * @tgt_done: jump target to get the next packet
  * @n_translated: number of successfully translated instructions (for errors)
  * @error: error code if something went wrong
+ * @stack_depth: max stack depth from the verifier
  * @insns: list of BPF instruction wrappers (struct nfp_insn_meta)
  */
 struct nfp_prog {
@@ -171,6 +172,8 @@ struct nfp_prog {
 	unsigned int n_translated;
 	int error;
 
+	unsigned int stack_depth;
+
 	struct list_head insns;
 };
 
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/offload.c b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
index a88bb5bc0082..f215abcbc18e 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/offload.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/offload.c
@@ -146,6 +146,7 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 {
 	unsigned int code_sz = max_instr * sizeof(u64);
 	enum nfp_bpf_action_type act;
+	unsigned int stack_size;
 	u16 start_off, done_off;
 	unsigned int max_mtu;
 	int ret;
@@ -167,6 +168,19 @@ nfp_net_bpf_offload_prepare(struct nfp_net *nn,
 	start_off = nn_readw(nn, NFP_NET_CFG_BPF_START);
 	done_off = nn_readw(nn, NFP_NET_CFG_BPF_DONE);
 
+	if (cls_bpf->prog->aux->stack_depth > 64) {
+		nn_info(nn, "large stack not supported: program %dB > 64B\n",
+			cls_bpf->prog->aux->stack_depth);
+		return -EOPNOTSUPP;
+	}
+
+	stack_size = nn_readb(nn, NFP_NET_CFG_BPF_STACK_SZ) * 64;
+	if (cls_bpf->prog->aux->stack_depth > stack_size) {
+		nn_info(nn, "stack too large: program %dB > FW stack %dB\n",
+			cls_bpf->prog->aux->stack_depth, stack_size);
+		return -EOPNOTSUPP;
+	}
+
 	*code = dma_zalloc_coherent(nn->dp.dev, code_sz, dma_addr, GFP_KERNEL);
 	if (!*code)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
index 4d2ed84a82e0..376d9938b823 100644
--- a/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
+++ b/drivers/net/ethernet/netronome/nfp/bpf/verifier.c
@@ -111,18 +111,41 @@ nfp_bpf_check_exit(struct nfp_prog *nfp_prog,
 	return 0;
 }
 
+static int nfp_bpf_check_stack_access(const struct bpf_reg_state *reg)
+{
+	if (!tnum_is_const(reg->var_off)) {
+		pr_info("variable ptr stack access\n");
+		return -EINVAL;
+	}
+
+	if (reg->var_off.value || reg->off) {
+		pr_info("stack access via modified register\n");
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
 static int
 nfp_bpf_check_ptr(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta,
 		  const struct bpf_verifier_env *env, u8 reg_no)
 {
 	const struct bpf_reg_state *reg = &env->cur_state.regs[reg_no];
+	int err;
 
 	if (reg->type != PTR_TO_CTX &&
+	    reg->type != PTR_TO_STACK &&
 	    reg->type != PTR_TO_PACKET) {
 		pr_info("unsupported ptr type: %d\n", reg->type);
 		return -EINVAL;
 	}
 
+	if (reg->type == PTR_TO_STACK) {
+		err = nfp_bpf_check_stack_access(reg);
+		if (err)
+			return err;
+	}
+
 	if (meta->ptr.type != NOT_INIT && meta->ptr.type != reg->type) {
 		pr_info("ptr type changed for instruction %d -> %d\n",
 			meta->ptr.type, reg->type);
@@ -143,11 +166,6 @@ nfp_verify_insn(struct bpf_verifier_env *env, int insn_idx, int prev_insn_idx)
 	meta = nfp_bpf_goto_meta(priv->prog, meta, insn_idx, env->prog->len);
 	priv->meta = meta;
 
-	if (meta->insn.src_reg == BPF_REG_10 ||
-	    meta->insn.dst_reg == BPF_REG_10) {
-		pr_err("stack not yet supported\n");
-		return -EINVAL;
-	}
 	if (meta->insn.src_reg >= MAX_BPF_REG ||
 	    meta->insn.dst_reg >= MAX_BPF_REG) {
 		pr_err("program uses extended registers - jit hardening?\n");
@@ -176,6 +194,8 @@ int nfp_prog_verify(struct nfp_prog *nfp_prog, struct bpf_prog *prog)
 	struct nfp_bpf_analyzer_priv *priv;
 	int ret;
 
+	nfp_prog->stack_depth = prog->aux->stack_depth;
+
 	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
 	if (!priv)
 		return -ENOMEM;
-- 
2.14.1
