From: David Miller <davem@davemloft.net>
Subject: [PATCH] sparc64: Support cbcond instructions in eBPF JIT.
Date: Mon, 24 Apr 2017 19:02:28 -0400 (EDT)
Message-ID: <20170424.190228.571734658408906331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, daniel@iogearbox.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58938 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S976790AbdDXXD0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Apr 2017 19:03:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


cbcond combines a compare with a branch into a single instruction.

The limitations are:

1) Only newer chips support it

2) For immediate compares we are limited to 5-bit signed immediate
   values

3) The branch displacement is limited to 10-bit signed

4) We cannot use it for JSET

Also, cbcond (unlike all other sparc control transfers) lacks a delay
slot.

Currently we don't have a useful instruction we can push into the
delay slot of normal branches.  So using cbcond pretty much always
increases code density, and is therefore a win.

Signed-off-by: David S. Miller <davem@davemloft.net>
---

Example output from "ALU_ADD_K: 0 + 0x80008000 = 0xffffffff80008000":

0000000000000000 <foo>:
   0:   9d e3 bf 50     save  %sp, -176, %sp
   4:   01 00 00 00     nop
   8:   90 10 00 18     mov  %i0, %o0
   c:   03 00 00 00     sethi  %hi(0), %g1
  10:   82 10 60 00     mov  %g1, %g1   ! 0 <foo>
  14:   13 00 00 00     sethi  %hi(0), %o1
  18:   92 12 60 00     mov  %o1, %o1   ! 0 <foo>
  1c:   83 28 70 20     sllx  %g1, 0x20, %g1
  20:   92 12 40 01     or  %o1, %g1, %o1
  24:   03 3f ff ff     sethi  %hi(0xfffffc00), %g1
  28:   82 10 63 ff     or  %g1, 0x3ff, %g1     ! ffffffff <foo+0xffffffff>
  2c:   15 20 00 20     sethi  %hi(0x80008000), %o2
  30:   94 12 a0 00     mov  %o2, %o2   ! 80008000 <foo+0x80008000>
  34:   83 28 70 20     sllx  %g1, 0x20, %g1
  38:   94 12 80 01     or  %o2, %g1, %o2
  3c:   03 1f ff df     sethi  %hi(0x7fff7c00), %g1
  40:   82 18 7c 00     xor  %g1, -1024, %g1
  44:   92 02 40 01     add  %o1, %g1, %o1
  48:   12 e2 40 8a     cxbe  %o1, %o2, 58 <foo+0x58>
  4c:   9a 10 20 02     mov  2, %o5
  50:   10 60 00 03     b,pn   %xcc, 5c <foo+0x5c>
  54:   01 00 00 00     nop
  58:   9a 10 20 01     mov  1, %o5     ! 1 <foo+0x1>
  5c:   81 c7 e0 08     ret
  60:   91 eb 40 00     restore  %o5, %g0, %o0

 arch/sparc/net/bpf_jit_comp_64.c | 238 ++++++++++++++++++++++++++++++---------
 1 file changed, 184 insertions(+), 54 deletions(-)

diff --git a/arch/sparc/net/bpf_jit_comp_64.c b/arch/sparc/net/bpf_jit_comp_64.c
index 43bef1c..2b2f3c3 100644
--- a/arch/sparc/net/bpf_jit_comp_64.c
+++ b/arch/sparc/net/bpf_jit_comp_64.c
@@ -18,6 +18,16 @@ static inline bool is_simm13(unsigned int value)
 	return value + 0x1000 < 0x2000;
 }
 
+static inline bool is_simm10(unsigned int value)
+{
+	return value + 0x200 < 0x400;
+}
+
+static inline bool is_simm5(unsigned int value)
+{
+	return value + 0x10 < 0x20;
+}
+
 static void bpf_flush_icache(void *start_, void *end_)
 {
 	/* Cheetah's I-cache is fully coherent.  */
@@ -39,6 +49,7 @@ static void bpf_flush_icache(void *start_, void *end_)
 #define SEEN_MEM     4 /* use mem[] for temporary storage */
 
 #define S13(X)		((X) & 0x1fff)
+#define S5(X)		((X) & 0x1f)
 #define IMMED		0x00002000
 #define RD(X)		((X) << 25)
 #define RS1(X)		((X) << 14)
@@ -46,7 +57,8 @@ static void bpf_flush_icache(void *start_, void *end_)
 #define OP(X)		((X) << 30)
 #define OP2(X)		((X) << 22)
 #define OP3(X)		((X) << 19)
-#define COND(X)		((X) << 25)
+#define COND(X)		(((X) & 0xf) << 25)
+#define CBCOND(X)	(((X) & 0x1f) << 25)
 #define F1(X)		OP(X)
 #define F2(X, Y)	(OP(X) | OP2(Y))
 #define F3(X, Y)	(OP(X) | OP3(Y))
@@ -75,10 +87,39 @@ static void bpf_flush_icache(void *start_, void *end_)
 #define WDISP22(X)	(((X) >> 2) & 0x3fffff)
 #define WDISP19(X)	(((X) >> 2) & 0x7ffff)
 
+/* The 10-bit branch displacement for CBCOND is split into two fields */
+static u32 WDISP10(u32 off)
+{
+	u32 ret = ((off >> 2) & 0xff) << 5;
+
+	ret |= ((off >> (2 + 8)) & 0x03) << 19;
+
+	return ret;
+}
+
+#define CBCONDE		CBCOND(0x09)
+#define CBCONDLE	CBCOND(0x0a)
+#define CBCONDL		CBCOND(0x0b)
+#define CBCONDLEU	CBCOND(0x0c)
+#define CBCONDCS	CBCOND(0x0d)
+#define CBCONDN		CBCOND(0x0e)
+#define CBCONDVS	CBCOND(0x0f)
+#define CBCONDNE	CBCOND(0x19)
+#define CBCONDG		CBCOND(0x1a)
+#define CBCONDGE	CBCOND(0x1b)
+#define CBCONDGU	CBCOND(0x1c)
+#define CBCONDCC	CBCOND(0x1d)
+#define CBCONDPOS	CBCOND(0x1e)
+#define CBCONDVC	CBCOND(0x1f)
+
+#define CBCONDGEU	CBCONDCC
+#define CBCONDLU	CBCONDCS
+
 #define ANNUL		(1 << 29)
 #define XCC		(1 << 21)
 
 #define BRANCH		(F2(0, 1) | XCC)
+#define CBCOND_OP	(F2(0, 3) | XCC)
 
 #define BA		(BRANCH | CONDA)
 #define BG		(BRANCH | CONDG)
@@ -351,6 +392,22 @@ static void emit_branch(unsigned int br_opc, unsigned int from_idx, unsigned int
 		emit(br_opc | WDISP22(off << 2), ctx);
 }
 
+static void emit_cbcond(unsigned int cb_opc, unsigned int from_idx, unsigned int to_idx,
+			const u8 dst, const u8 src, struct jit_ctx *ctx)
+{
+	unsigned int off = to_idx - from_idx;
+
+	emit(cb_opc | WDISP10(off << 2) | RS1(dst) | RS2(src), ctx);
+}
+
+static void emit_cbcondi(unsigned int cb_opc, unsigned int from_idx, unsigned int to_idx,
+			 const u8 dst, s32 imm, struct jit_ctx *ctx)
+{
+	unsigned int off = to_idx - from_idx;
+
+	emit(cb_opc | IMMED | WDISP10(off << 2) | RS1(dst) | S5(imm), ctx);
+}
+
 #define emit_read_y(REG, CTX)	emit(RD_Y | RD(REG), CTX)
 #define emit_write_y(REG, CTX)	emit(WR_Y | IMMED | RS1(REG) | S13(0), CTX)
 
@@ -358,7 +415,7 @@ static void emit_branch(unsigned int br_opc, unsigned int from_idx, unsigned int
 	emit(SUBCC | RS1(R1) | RS2(R2) | RD(G0), CTX)
 
 #define emit_cmpi(R1, IMM, CTX)				\
-	emit(SUBCC | IMMED | RS1(R1) | S13(IMM) | RD(G0), CTX);
+	emit(SUBCC | IMMED | RS1(R1) | S13(IMM) | RD(G0), CTX)
 
 #define emit_btst(R1, R2, CTX)				\
 	emit(ANDCC | RS1(R1) | RS2(R2) | RD(G0), CTX)
@@ -366,6 +423,117 @@ static void emit_branch(unsigned int br_opc, unsigned int from_idx, unsigned int
 #define emit_btsti(R1, IMM, CTX)			\
 	emit(ANDCC | IMMED | RS1(R1) | S13(IMM) | RD(G0), CTX)
 
+static int emit_compare_and_branch(const u8 code, const u8 dst, u8 src,
+				   const s32 imm, bool is_imm, int branch_dst,
+				   struct jit_ctx *ctx)
+{
+	bool use_cbcond = (sparc64_elf_hwcap & AV_SPARC_CBCOND) != 0;
+	const u8 tmp = bpf2sparc[TMP_REG_1];
+
+	branch_dst = ctx->offset[branch_dst];
+
+	if (!is_simm10(branch_dst - ctx->idx) ||
+	    BPF_OP(code) == BPF_JSET)
+		use_cbcond = false;
+
+	if (is_imm) {
+		bool fits = true;
+
+		if (use_cbcond) {
+			if (!is_simm5(imm))
+				fits = false;
+		} else if (!is_simm13(imm)) {
+			fits = false;
+		}
+		if (!fits) {
+			ctx->tmp_1_used = true;
+			emit_loadimm_sext(imm, tmp, ctx);
+			src = tmp;
+			is_imm = false;
+		}
+	}
+
+	if (!use_cbcond) {
+		u32 br_opcode;
+
+		if (BPF_OP(code) == BPF_JSET) {
+			if (is_imm)
+				emit_btsti(dst, imm, ctx);
+			else
+				emit_btst(dst, src, ctx);
+		} else {
+			if (is_imm)
+				emit_cmpi(dst, imm, ctx);
+			else
+				emit_cmp(dst, src, ctx);
+		}
+		switch (BPF_OP(code)) {
+		case BPF_JEQ:
+			br_opcode = BE;
+			break;
+		case BPF_JGT:
+			br_opcode = BGU;
+			break;
+		case BPF_JGE:
+			br_opcode = BGEU;
+			break;
+		case BPF_JSET:
+		case BPF_JNE:
+			br_opcode = BNE;
+			break;
+		case BPF_JSGT:
+			br_opcode = BG;
+			break;
+		case BPF_JSGE:
+			br_opcode = BGE;
+			break;
+		default:
+			/* Make sure we dont leak kernel information to the
+			 * user.
+			 */
+			return -EFAULT;
+		}
+		emit_branch(br_opcode, ctx->idx, branch_dst, ctx);
+		emit_nop(ctx);
+	} else {
+		u32 cbcond_opcode;
+
+		switch (BPF_OP(code)) {
+		case BPF_JEQ:
+			cbcond_opcode = CBCONDE;
+			break;
+		case BPF_JGT:
+			cbcond_opcode = CBCONDGU;
+			break;
+		case BPF_JGE:
+			cbcond_opcode = CBCONDGEU;
+			break;
+		case BPF_JNE:
+			cbcond_opcode = CBCONDNE;
+			break;
+		case BPF_JSGT:
+			cbcond_opcode = CBCONDG;
+			break;
+		case BPF_JSGE:
+			cbcond_opcode = CBCONDGE;
+			break;
+		default:
+			/* Make sure we dont leak kernel information to the
+			 * user.
+			 */
+			return -EFAULT;
+		}
+		cbcond_opcode |= CBCOND_OP;
+		if (is_imm)
+			emit_cbcondi(cbcond_opcode, ctx->idx, branch_dst,
+				     dst, imm, ctx);
+		else
+			emit_cbcond(cbcond_opcode, ctx->idx, branch_dst,
+				    dst, src, ctx);
+	}
+	return 0;
+}
+
 static void load_skb_regs(struct jit_ctx *ctx, u8 r_skb)
 {
 	const u8 r_headlen = bpf2sparc[SKB_HLEN_REG];
@@ -765,44 +933,15 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
 	case BPF_JMP | BPF_JGE | BPF_X:
 	case BPF_JMP | BPF_JNE | BPF_X:
 	case BPF_JMP | BPF_JSGT | BPF_X:
-	case BPF_JMP | BPF_JSGE | BPF_X: {
-		u32 br_opcode;
+	case BPF_JMP | BPF_JSGE | BPF_X:
+	case BPF_JMP | BPF_JSET | BPF_X: {
+		int err;
 
-		emit_cmp(dst, src, ctx);
-emit_cond_jmp:
-		switch (BPF_OP(code)) {
-		case BPF_JEQ:
-			br_opcode = BE;
-			break;
-		case BPF_JGT:
-			br_opcode = BGU;
-			break;
-		case BPF_JGE:
-			br_opcode = BGEU;
-			break;
-		case BPF_JSET:
-		case BPF_JNE:
-			br_opcode = BNE;
-			break;
-		case BPF_JSGT:
-			br_opcode = BG;
-			break;
-		case BPF_JSGE:
-			br_opcode = BGE;
-			break;
-		default:
-			/* Make sure we dont leak kernel information to the
-			 * user.
-			 */
-			return -EFAULT;
-		}
-		emit_branch(br_opcode, ctx->idx, ctx->offset[i + off], ctx);
-		emit_nop(ctx);
+		err = emit_compare_and_branch(code, dst, src, 0, false, i + off, ctx);
+		if (err)
+			return err;
 		break;
 	}
-	case BPF_JMP | BPF_JSET | BPF_X:
-		emit_btst(dst, src, ctx);
-		goto emit_cond_jmp;
 	/* IF (dst COND imm) JUMP off */
 	case BPF_JMP | BPF_JEQ | BPF_K:
 	case BPF_JMP | BPF_JGT | BPF_K:
@@ -810,23 +949,14 @@ static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
 	case BPF_JMP | BPF_JNE | BPF_K:
 	case BPF_JMP | BPF_JSGT | BPF_K:
 	case BPF_JMP | BPF_JSGE | BPF_K:
-		if (is_simm13(imm)) {
-			emit_cmpi(dst, imm, ctx);
-		} else {
-			ctx->tmp_1_used = true;
-			emit_loadimm_sext(imm, bpf2sparc[TMP_REG_1], ctx);
-			emit_cmp(dst, bpf2sparc[TMP_REG_1], ctx);
-		}
-		goto emit_cond_jmp;
-	case BPF_JMP | BPF_JSET | BPF_K:
-		if (is_simm13(imm)) {
-			emit_btsti(dst, imm, ctx);
-		} else {
-			ctx->tmp_1_used = true;
-			emit_loadimm_sext(imm, bpf2sparc[TMP_REG_1], ctx);
-			emit_btst(dst, bpf2sparc[TMP_REG_1], ctx);
-		}
-		goto emit_cond_jmp;
+	case BPF_JMP | BPF_JSET | BPF_K: {
+		int err;
+
+		err = emit_compare_and_branch(code, dst, 0, imm, true, i + off, ctx);
+		if (err)
+			return err;
+		break;
+	}
 
 	/* function call */
 	case BPF_JMP | BPF_CALL:
-- 
2.1.2.532.g19b5d50
