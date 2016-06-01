From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 12/12] nfp: bpf: add denser mode of execution
Date: Wed,  1 Jun 2016 17:50:14 +0100
Message-ID: <1464799814-4453-13-git-send-email-jakub.kicinski@netronome.com>
References: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Cc: ast@kernel.org, daniel@iogearbox.net,
	dinan.gunawardena@netronome.com,
	Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:35324 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932690AbcFAQwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 12:52:03 -0400
Received: by mail-wm0-f45.google.com with SMTP id a136so191961447wme.0
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 09:52:01 -0700 (PDT)
In-Reply-To: <1464799814-4453-1-git-send-email-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If BPF uses less than 7 registers programmable engines
can process twice as many packets in parallel.  Signal
this denser mode of operation to FW by setting the lowest
bit in DMA address of the machine code buffer.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Dinan Gunawardena <dgunawardena@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_bpf.h       | 24 ++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c   | 51 +++++++++++-----------
 .../net/ethernet/netronome/nfp/nfp_net_offload.c   |  9 ++--
 3 files changed, 54 insertions(+), 30 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
index 8fa9ff28ba80..bec766cd072f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf.h
@@ -52,6 +52,24 @@ enum br_special {
 	OP_BR_GO_ABORT,
 };
 
+enum static_regs {
+	STATIC_REG_PKT		= 1,
+#define REG_PKT_BANK	ALU_DST_A
+	STATIC_REG_LEN		= 1,
+#define REG_LEN_BANK	ALU_DST_B
+	STATIC_REG_IMM		= 2, /* Bank AB */
+	STATIC_REG_QNUM		= 3, /* Bank AB */
+	STATIC_REG_MARK		= 4, /* Bank A */
+	STATIC_REG_MARK_SET	= 4, /* Bank B */
+};
+
+#define r_pkt(np)	((np)->regs_per_thread - STATIC_REG_PKT)
+#define r_len(np)	((np)->regs_per_thread - STATIC_REG_LEN)
+#define r_imm(np)	((np)->regs_per_thread - STATIC_REG_IMM)
+#define r_qnum(np)	((np)->regs_per_thread - STATIC_REG_QNUM)
+#define r_mark(np)	((np)->regs_per_thread - STATIC_REG_MARK)
+#define r_mark_s(np)	((np)->regs_per_thread - STATIC_REG_MARK_SET)
+
 struct nfp_prog;
 struct nfp_insn_meta;
 typedef int (*instr_cb_t)(struct nfp_prog *, struct nfp_insn_meta *);
@@ -78,6 +96,8 @@ struct nfp_insn_meta {
  * @prog: machine code
  * @prog_len: number of valid instructions in @prog array
  * @__prog_alloc_len: alloc size of @prog array
+ * @num_regs: numer of registers used by this program
+ * @regs_per_thread: number of basic registers allocated per thread
  * @start_off: address of the first instruction in the memory
  * @tgt_out: jump target for normal exit
  * @tgt_abort: jump target for abort (e.g. access outside of packet buffer)
@@ -90,6 +110,9 @@ struct nfp_prog {
 	unsigned int prog_len;
 	unsigned int __prog_alloc_len;
 
+	unsigned int num_regs;
+	unsigned int regs_per_thread;
+
 	unsigned int start_off;
 	unsigned int tgt_out;
 	unsigned int tgt_abort;
@@ -102,6 +125,7 @@ struct nfp_prog {
 
 struct nfp_bpf_result {
 	unsigned int n_instr;
+	bool dense_mode;
 };
 
 int
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
index b4dd04f4c653..666dee54fe77 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_bpf_jit.c
@@ -39,16 +39,6 @@
 #include "nfp_asm.h"
 #include "nfp_bpf.h"
 
-#define REG_PKT_N	31
-#define REG_PKT_BANK	ALU_DST_A
-#define REG_LEN_N	31
-#define REG_LEN_BANK	ALU_DST_B
-
-#define REG_IMM0_N	30 /* Bank AB */
-#define REG_QNUM	29 /* Bank AB */
-#define REG_MARK	28 /* Bank A */
-#define REG_MARK_STS	28 /* Bank B */
-
 /* --- NFP prog --- */
 /* Foreach "multiple" entries macros provide pos and next<n> pointers.
  * It's safe to modify the next pointers (but not pos).
@@ -372,31 +362,32 @@ construct_data_ind_ld(struct nfp_prog *nfp_prog, u16 offset,
 	if (src_valid) {
 		/* Calculate the true offset (src_reg + imm) */
 		imm_reg = ur_load_imm_any(nfp_prog, offset,
-					  REG_IMM0_N, ALU_DST_B);
-		__emit_alu(nfp_prog, REG_IMM0_N, ALU_DST_A,
+					  r_imm(nfp_prog), ALU_DST_B);
+		__emit_alu(nfp_prog, r_imm(nfp_prog), ALU_DST_A,
 			   src, ALU_OP_ADD, imm_reg, false, true);
 		/* Check packet length (size guaranteed to fit b/c it's u8) */
-		__emit_alu(nfp_prog, REG_IMM0_N, ALU_DST_A,
-			   REG_IMM0_N, ALU_OP_ADD, UR_REG_IMM | size,
+		__emit_alu(nfp_prog, r_imm(nfp_prog), ALU_DST_A,
+			   r_imm(nfp_prog), ALU_OP_ADD, UR_REG_IMM | size,
 			   false, false);
 		__emit_alu(nfp_prog, UR_REG_NO_DST, ALU_DST_A,
-			   REG_IMM0_N, ALU_OP_SUB, REG_LEN_N, true, false);
+			   r_imm(nfp_prog), ALU_OP_SUB, r_len(nfp_prog),
+			   true, false);
 		wrp_br_special(nfp_prog, BR_BLO, OP_BR_GO_ABORT);
 		/* Load data */
 		__emit_cmd(nfp_prog, CMD_TGT_READ8, CMD_MODE_32b, 0,
-			   REG_PKT_N, REG_IMM0_N, sz - 1, true);
+			   r_pkt(nfp_prog), r_imm(nfp_prog), sz - 1, true);
 	} else {
 		/* Check packet length */
 		imm_reg = ur_load_imm_any(nfp_prog, offset + size,
-					  REG_IMM0_N, ALU_DST_A);
+					  r_imm(nfp_prog), ALU_DST_A);
 		__emit_alu(nfp_prog, UR_REG_NO_DST, ALU_DST_A,
-			   imm_reg, ALU_OP_SUB, REG_LEN_N, true, false);
+			   imm_reg, ALU_OP_SUB, r_len(nfp_prog), true, false);
 		wrp_br_special(nfp_prog, BR_BLO, OP_BR_GO_ABORT);
 		/* Load data */
 		imm_reg = re_load_imm_any(nfp_prog, offset,
-					  REG_IMM0_N, ALU_DST_B);
+					  r_imm(nfp_prog), ALU_DST_B);
 		__emit_cmd(nfp_prog, CMD_TGT_READ8, CMD_MODE_32b, 0,
-			   REG_PKT_N, imm_reg, sz - 1, true);
+			   r_pkt(nfp_prog), imm_reg, sz - 1, true);
 	}
 
 	i = 0;
@@ -420,9 +411,9 @@ static int construct_data_ld(struct nfp_prog *nfp_prog, u16 offset, u8 size)
 
 static int wrp_skb_mark(struct nfp_prog *nfp_prog, u16 src)
 {
-	__emit_alu(nfp_prog, REG_MARK, ALU_DST_A, REG_NONE, ALU_OP_NONE, src,
-		   false, false);
-	__emit_immed(nfp_prog, REG_MARK_STS, ALU_DST_B, 1, false);
+	__emit_alu(nfp_prog, r_mark(nfp_prog), ALU_DST_A,
+		   REG_NONE, ALU_OP_NONE, src, false, false);
+	__emit_immed(nfp_prog, r_mark_s(nfp_prog), ALU_DST_B, 1, false);
 
 	return 0;
 }
@@ -433,7 +424,7 @@ construct_br_imm(struct nfp_prog *nfp_prog, u32 imm, u16 dst, u8 br, u16 off,
 {
 	u16 imm_reg;
 
-	imm_reg = ur_load_imm_any(nfp_prog, imm, REG_IMM0_N, ALU_DST_B);
+	imm_reg = ur_load_imm_any(nfp_prog, imm, r_imm(nfp_prog), ALU_DST_B);
 
 	__emit_alu(nfp_prog, UR_REG_NO_DST, ALU_DST_A,
 		   dst, alu_op, imm_reg, sw, false);
@@ -524,7 +515,7 @@ static int mem_ld4(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 {
 	if (meta->insn.off == offsetof(struct sk_buff, len))
 		__emit_alu(nfp_prog, meta->insn.dst_reg * 2, ALU_DST_A,
-			   REG_NONE, ALU_OP_NONE, REG_LEN_N, false, true);
+			   REG_NONE, ALU_OP_NONE, r_len(nfp_prog), false, true);
 	else
 		return -ENOTSUPP;
 
@@ -562,7 +553,8 @@ static int and_immX(struct nfp_prog *nfp_prog, struct nfp_insn_meta *meta)
 	const struct bpf_insn *insn = &meta->insn;
 	u16 imm_reg;
 
-	imm_reg = ur_load_imm_any(nfp_prog, insn->imm, REG_IMM0_N, ALU_DST_B);
+	imm_reg = ur_load_imm_any(nfp_prog, insn->imm,
+				  r_imm(nfp_prog), ALU_DST_B);
 
 	__emit_alu(nfp_prog, insn->dst_reg * 2, ALU_DST_A,
 		   insn->dst_reg * 2, ALU_OP_AND, imm_reg, false, true);
@@ -874,6 +866,7 @@ static int nfp_bpf_opt_reg_rename(struct nfp_prog *nfp_prog)
 
 		tgt_reg[i] = j++;
 	}
+	nfp_prog->num_regs = j;
 
 	list_for_each_entry(meta, &nfp_prog->insns, l) {
 		meta->insn.src_reg = tgt_reg[meta->insn.src_reg];
@@ -1010,6 +1003,11 @@ nfp_bpf_jit(struct bpf_prog *filter, void *prog_mem, unsigned int prog_start,
 	if (ret)
 		goto out;
 
+	if (nfp_prog->num_regs <= 6)
+		nfp_prog->regs_per_thread = 16;
+	else
+		nfp_prog->regs_per_thread = 32;
+
 	nfp_prog->prog = prog_mem;
 	nfp_prog->__prog_alloc_len = prog_sz;
 
@@ -1021,6 +1019,7 @@ nfp_bpf_jit(struct bpf_prog *filter, void *prog_mem, unsigned int prog_start,
 	}
 
 	res->n_instr = nfp_prog->prog_len;
+	res->dense_mode = nfp_prog->num_regs <= 6;
 out:
 	nfp_prog_free(nfp_prog);
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
index caada9d61913..62c7725e489c 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_offload.c
@@ -147,14 +147,15 @@ out:
 static void
 nfp_net_bpf_load_and_start(struct nfp_net *nn, u32 tc_flags,
 			   void *code, dma_addr_t dma_addr,
-			   unsigned int code_sz, unsigned int n_instr)
+			   unsigned int code_sz, unsigned int n_instr,
+			   bool dense_mode)
 {
 	int err;
 
 	nn->bpf_offload_skip_sw = !!(tc_flags & TCA_CLS_FLAGS_SKIP_SW);
 
 	nn_writel(nn, NFP_NET_CFG_BPF_SIZE, n_instr * sizeof(u64));
-	nn_writeq(nn, NFP_NET_CFG_BPF_ADDR, dma_addr);
+	nn_writeq(nn, NFP_NET_CFG_BPF_ADDR, dma_addr | dense_mode);
 
 	/* Load up the JITed code */
 	nn_info(nn, "Reloading BPF code (%d instr)\n", n_instr);
@@ -226,7 +227,7 @@ nfp_net_bpf_offload(struct nfp_net *nn, u32 handle, __be16 proto,
 		nfp_net_bpf_stop(nn);
 		nfp_net_bpf_load_and_start(nn, cls_bpf->gen_flags, code,
 					   dma_addr, max_instr * sizeof(u64),
-					   res.n_instr);
+					   res.n_instr, res.dense_mode);
 		return 0;
 
 	case TC_CLSBPF_ADD:
@@ -240,7 +241,7 @@ nfp_net_bpf_offload(struct nfp_net *nn, u32 handle, __be16 proto,
 
 		nfp_net_bpf_load_and_start(nn, cls_bpf->gen_flags, code,
 					   dma_addr, max_instr * sizeof(u64),
-					   res.n_instr);
+					   res.n_instr, res.dense_mode);
 		return 0;
 
 	case TC_CLSBPF_DESTROY:
-- 
1.9.1
