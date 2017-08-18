From: David Daney <david.daney@cavium.com>
Subject: [PATCH 2/3] MIPS,bpf: Implement JLT, JLE, JSLT and JSLE ops in the eBPF JIT.
Date: Fri, 18 Aug 2017 16:40:32 -0700
Message-ID: <20170818234033.5990-3-david.daney@cavium.com>
References: <20170818234033.5990-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
        David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170818234033.5990-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/mips/net/ebpf_jit.c | 101 +++++++++++++++++++++++++++++++++--------------
 1 file changed, 72 insertions(+), 29 deletions(-)

diff --git a/arch/mips/net/ebpf_jit.c b/arch/mips/net/ebpf_jit.c
index 721216b..c1e21cb 100644
--- a/arch/mips/net/ebpf_jit.c
+++ b/arch/mips/net/ebpf_jit.c
@@ -990,8 +990,12 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 		goto jeq_common;
 	case BPF_JMP | BPF_JEQ | BPF_X: /* JMP_REG */
 	case BPF_JMP | BPF_JNE | BPF_X:
+	case BPF_JMP | BPF_JSLT | BPF_X:
+	case BPF_JMP | BPF_JSLE | BPF_X:
 	case BPF_JMP | BPF_JSGT | BPF_X:
 	case BPF_JMP | BPF_JSGE | BPF_X:
+	case BPF_JMP | BPF_JLT | BPF_X:
+	case BPF_JMP | BPF_JLE | BPF_X:
 	case BPF_JMP | BPF_JGT | BPF_X:
 	case BPF_JMP | BPF_JGE | BPF_X:
 	case BPF_JMP | BPF_JSET | BPF_X:
@@ -1013,28 +1017,34 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 			cmp_eq = false;
 			dst = MIPS_R_AT;
 			src = MIPS_R_ZERO;
-		} else if (BPF_OP(insn->code) == BPF_JSGT) {
+		} else if (BPF_OP(insn->code) == BPF_JSGT || BPF_OP(insn->code) == BPF_JSLE) {
 			emit_instr(ctx, dsubu, MIPS_R_AT, dst, src);
 			if ((insn + 1)->code == (BPF_JMP | BPF_EXIT) && insn->off == 1) {
 				b_off = b_imm(exit_idx, ctx);
 				if (is_bad_offset(b_off))
 					return -E2BIG;
-				emit_instr(ctx, blez, MIPS_R_AT, b_off);
+				if (BPF_OP(insn->code) == BPF_JSGT)
+					emit_instr(ctx, blez, MIPS_R_AT, b_off);
+				else
+					emit_instr(ctx, bgtz, MIPS_R_AT, b_off);
 				emit_instr(ctx, nop);
 				return 2; /* We consumed the exit. */
 			}
 			b_off = b_imm(this_idx + insn->off + 1, ctx);
 			if (is_bad_offset(b_off))
 				return -E2BIG;
-			emit_instr(ctx, bgtz, MIPS_R_AT, b_off);
+			if (BPF_OP(insn->code) == BPF_JSGT)
+				emit_instr(ctx, bgtz, MIPS_R_AT, b_off);
+			else
+				emit_instr(ctx, blez, MIPS_R_AT, b_off);
 			emit_instr(ctx, nop);
 			break;
-		} else if (BPF_OP(insn->code) == BPF_JSGE) {
+		} else if (BPF_OP(insn->code) == BPF_JSGE || BPF_OP(insn->code) == BPF_JSLT) {
 			emit_instr(ctx, slt, MIPS_R_AT, dst, src);
-			cmp_eq = true;
+			cmp_eq = BPF_OP(insn->code) == BPF_JSGE;
 			dst = MIPS_R_AT;
 			src = MIPS_R_ZERO;
-		} else if (BPF_OP(insn->code) == BPF_JGT) {
+		} else if (BPF_OP(insn->code) == BPF_JGT || BPF_OP(insn->code) == BPF_JLE) {
 			/* dst or src could be AT */
 			emit_instr(ctx, dsubu, MIPS_R_T8, dst, src);
 			emit_instr(ctx, sltu, MIPS_R_AT, dst, src);
@@ -1042,12 +1052,12 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 			emit_instr(ctx, movz, MIPS_R_T9, MIPS_R_SP, MIPS_R_T8);
 			emit_instr(ctx, movn, MIPS_R_T9, MIPS_R_ZERO, MIPS_R_T8);
 			emit_instr(ctx, or, MIPS_R_AT, MIPS_R_T9, MIPS_R_AT);
-			cmp_eq = true;
+			cmp_eq = BPF_OP(insn->code) == BPF_JGT;
 			dst = MIPS_R_AT;
 			src = MIPS_R_ZERO;
-		} else if (BPF_OP(insn->code) == BPF_JGE) {
+		} else if (BPF_OP(insn->code) == BPF_JGE || BPF_OP(insn->code) == BPF_JLT) {
 			emit_instr(ctx, sltu, MIPS_R_AT, dst, src);
-			cmp_eq = true;
+			cmp_eq = BPF_OP(insn->code) == BPF_JGE;
 			dst = MIPS_R_AT;
 			src = MIPS_R_ZERO;
 		} else { /* JNE/JEQ case */
@@ -1110,6 +1120,8 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 		break;
 	case BPF_JMP | BPF_JSGT | BPF_K: /* JMP_IMM */
 	case BPF_JMP | BPF_JSGE | BPF_K: /* JMP_IMM */
+	case BPF_JMP | BPF_JSLT | BPF_K: /* JMP_IMM */
+	case BPF_JMP | BPF_JSLE | BPF_K: /* JMP_IMM */
 		cmp_eq = (BPF_OP(insn->code) == BPF_JSGE);
 		dst = ebpf_to_mips_reg(ctx, insn, dst_reg_fp_ok);
 		if (dst < 0)
@@ -1120,65 +1132,92 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 				b_off = b_imm(exit_idx, ctx);
 				if (is_bad_offset(b_off))
 					return -E2BIG;
-				if (cmp_eq)
-					emit_instr(ctx, bltz, dst, b_off);
-				else
+				switch (BPF_OP(insn->code)) {
+				case BPF_JSGT:
 					emit_instr(ctx, blez, dst, b_off);
+					break;
+				case BPF_JSGE:
+					emit_instr(ctx, bltz, dst, b_off);
+					break;
+				case BPF_JSLT:
+					emit_instr(ctx, bgez, dst, b_off);
+					break;
+				case BPF_JSLE:
+					emit_instr(ctx, bgtz, dst, b_off);
+					break;
+				}
 				emit_instr(ctx, nop);
 				return 2; /* We consumed the exit. */
 			}
 			b_off = b_imm(this_idx + insn->off + 1, ctx);
 			if (is_bad_offset(b_off))
 				return -E2BIG;
-			if (cmp_eq)
-				emit_instr(ctx, bgez, dst, b_off);
-			else
+			switch (BPF_OP(insn->code)) {
+			case BPF_JSGT:
 				emit_instr(ctx, bgtz, dst, b_off);
+				break;
+			case BPF_JSGE:
+				emit_instr(ctx, bgez, dst, b_off);
+				break;
+			case BPF_JSLT:
+				emit_instr(ctx, bltz, dst, b_off);
+				break;
+			case BPF_JSLE:
+				emit_instr(ctx, blez, dst, b_off);
+				break;
+			}
 			emit_instr(ctx, nop);
 			break;
 		}
 		/*
 		 * only "LT" compare available, so we must use imm + 1
-		 * to generate "GT"
+		 * to generate "GT" and imm -1 to generate LE
 		 */
-		t64s = insn->imm + (cmp_eq ? 0 : 1);
+		if (BPF_OP(insn->code) == BPF_JSGT)
+			t64s = insn->imm + 1;
+		else if (BPF_OP(insn->code) == BPF_JSLE)
+			t64s = insn->imm + 1;
+		else
+			t64s = insn->imm;
+
+		cmp_eq = BPF_OP(insn->code) == BPF_JSGT || BPF_OP(insn->code) == BPF_JSGE;
 		if (t64s >= S16_MIN && t64s <= S16_MAX) {
 			emit_instr(ctx, slti, MIPS_R_AT, dst, (int)t64s);
 			src = MIPS_R_AT;
 			dst = MIPS_R_ZERO;
-			cmp_eq = true;
 			goto jeq_common;
 		}
 		emit_const_to_reg(ctx, MIPS_R_AT, (u64)t64s);
 		emit_instr(ctx, slt, MIPS_R_AT, dst, MIPS_R_AT);
 		src = MIPS_R_AT;
 		dst = MIPS_R_ZERO;
-		cmp_eq = true;
 		goto jeq_common;
 
 	case BPF_JMP | BPF_JGT | BPF_K:
 	case BPF_JMP | BPF_JGE | BPF_K:
+	case BPF_JMP | BPF_JLT | BPF_K:
+	case BPF_JMP | BPF_JLE | BPF_K:
 		cmp_eq = (BPF_OP(insn->code) == BPF_JGE);
 		dst = ebpf_to_mips_reg(ctx, insn, dst_reg_fp_ok);
 		if (dst < 0)
 			return dst;
 		/*
 		 * only "LT" compare available, so we must use imm + 1
-		 * to generate "GT"
+		 * to generate "GT" and imm -1 to generate LE
 		 */
-		t64s = (u64)(u32)(insn->imm) + (cmp_eq ? 0 : 1);
-		if (t64s >= 0 && t64s <= S16_MAX) {
-			emit_instr(ctx, sltiu, MIPS_R_AT, dst, (int)t64s);
-			src = MIPS_R_AT;
-			dst = MIPS_R_ZERO;
-			cmp_eq = true;
-			goto jeq_common;
-		}
+		if (BPF_OP(insn->code) == BPF_JGT)
+			t64s = (u64)(u32)(insn->imm) + 1;
+		else if (BPF_OP(insn->code) == BPF_JLE)
+			t64s = (u64)(u32)(insn->imm) + 1;
+		else
+			t64s = (u64)(u32)(insn->imm);
+
+		cmp_eq = BPF_OP(insn->code) == BPF_JGT || BPF_OP(insn->code) == BPF_JGE;
+
 		emit_const_to_reg(ctx, MIPS_R_AT, (u64)t64s);
 		emit_instr(ctx, sltu, MIPS_R_AT, dst, MIPS_R_AT);
 		src = MIPS_R_AT;
 		dst = MIPS_R_ZERO;
-		cmp_eq = true;
 		goto jeq_common;
 
 	case BPF_JMP | BPF_JSET | BPF_K: /* JMP_IMM */
@@ -1712,10 +1751,14 @@ static int reg_val_propagate_range(struct jit_ctx *ctx, u64 initial_rvt,
 			case BPF_JEQ:
 			case BPF_JGT:
 			case BPF_JGE:
+			case BPF_JLT:
+			case BPF_JLE:
 			case BPF_JSET:
 			case BPF_JNE:
 			case BPF_JSGT:
 			case BPF_JSGE:
+			case BPF_JSLT:
+			case BPF_JSLE:
 				if (follow_taken) {
 					rvt[idx] |= RVT_BRANCH_TAKEN;
 					idx += insn->off;
-- 
2.9.5
