From: David Daney <david.daney@cavium.com>
Subject: [PATCH 3/3] MIPS,bpf: Cache value of BPF_OP(insn->code) in eBPF JIT.
Date: Fri, 18 Aug 2017 16:40:33 -0700
Message-ID: <20170818234033.5990-4-david.daney@cavium.com>
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

The code looks a little cleaner if we replace BPF_OP(insn->code) with
the local variable bpf_op.  Caching the value this way also saves 300
bytes (about 1%) in the code size of the JIT.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/mips/net/ebpf_jit.c | 67 ++++++++++++++++++++++++------------------------
 1 file changed, 34 insertions(+), 33 deletions(-)

diff --git a/arch/mips/net/ebpf_jit.c b/arch/mips/net/ebpf_jit.c
index c1e21cb..44ddc12 100644
--- a/arch/mips/net/ebpf_jit.c
+++ b/arch/mips/net/ebpf_jit.c
@@ -670,6 +670,7 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 	unsigned int target;
 	u64 t64;
 	s64 t64s;
+	int bpf_op = BPF_OP(insn->code);
 
 	switch (insn->code) {
 	case BPF_ALU64 | BPF_ADD | BPF_K: /* ALU64_IMM */
@@ -758,13 +759,13 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 			emit_instr(ctx, sll, dst, dst, 0);
 		if (insn->imm == 1) {
 			/* div by 1 is a nop, mod by 1 is zero */
-			if (BPF_OP(insn->code) == BPF_MOD)
+			if (bpf_op == BPF_MOD)
 				emit_instr(ctx, addu, dst, MIPS_R_ZERO, MIPS_R_ZERO);
 			break;
 		}
 		gen_imm_to_reg(insn, MIPS_R_AT, ctx);
 		emit_instr(ctx, divu, dst, MIPS_R_AT);
-		if (BPF_OP(insn->code) == BPF_DIV)
+		if (bpf_op == BPF_DIV)
 			emit_instr(ctx, mflo, dst);
 		else
 			emit_instr(ctx, mfhi, dst);
@@ -786,13 +787,13 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 
 		if (insn->imm == 1) {
 			/* div by 1 is a nop, mod by 1 is zero */
-			if (BPF_OP(insn->code) == BPF_MOD)
+			if (bpf_op == BPF_MOD)
 				emit_instr(ctx, addu, dst, MIPS_R_ZERO, MIPS_R_ZERO);
 			break;
 		}
 		gen_imm_to_reg(insn, MIPS_R_AT, ctx);
 		emit_instr(ctx, ddivu, dst, MIPS_R_AT);
-		if (BPF_OP(insn->code) == BPF_DIV)
+		if (bpf_op == BPF_DIV)
 			emit_instr(ctx, mflo, dst);
 		else
 			emit_instr(ctx, mfhi, dst);
@@ -817,7 +818,7 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 			emit_instr(ctx, dinsu, dst, MIPS_R_ZERO, 32, 32);
 		did_move = false;
 		if (insn->src_reg == BPF_REG_10) {
-			if (BPF_OP(insn->code) == BPF_MOV) {
+			if (bpf_op == BPF_MOV) {
 				emit_instr(ctx, daddiu, dst, MIPS_R_SP, MAX_BPF_STACK);
 				did_move = true;
 			} else {
@@ -827,7 +828,7 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 		} else if (get_reg_val_type(ctx, this_idx, insn->src_reg) == REG_32BIT) {
 			int tmp_reg = MIPS_R_AT;
 
-			if (BPF_OP(insn->code) == BPF_MOV) {
+			if (bpf_op == BPF_MOV) {
 				tmp_reg = dst;
 				did_move = true;
 			}
@@ -835,7 +836,7 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 			emit_instr(ctx, dinsu, tmp_reg, MIPS_R_ZERO, 32, 32);
 			src = MIPS_R_AT;
 		}
-		switch (BPF_OP(insn->code)) {
+		switch (bpf_op) {
 		case BPF_MOV:
 			if (!did_move)
 				emit_instr(ctx, daddu, dst, src, MIPS_R_ZERO);
@@ -867,7 +868,7 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 			emit_instr(ctx, beq, src, MIPS_R_ZERO, b_off);
 			emit_instr(ctx, movz, MIPS_R_V0, MIPS_R_ZERO, src);
 			emit_instr(ctx, ddivu, dst, src);
-			if (BPF_OP(insn->code) == BPF_DIV)
+			if (bpf_op == BPF_DIV)
 				emit_instr(ctx, mflo, dst);
 			else
 				emit_instr(ctx, mfhi, dst);
@@ -911,7 +912,7 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 		if (ts == REG_64BIT || ts == REG_32BIT_ZERO_EX) {
 			int tmp_reg = MIPS_R_AT;
 
-			if (BPF_OP(insn->code) == BPF_MOV) {
+			if (bpf_op == BPF_MOV) {
 				tmp_reg = dst;
 				did_move = true;
 			}
@@ -919,7 +920,7 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 			emit_instr(ctx, sll, tmp_reg, src, 0);
 			src = MIPS_R_AT;
 		}
-		switch (BPF_OP(insn->code)) {
+		switch (bpf_op) {
 		case BPF_MOV:
 			if (!did_move)
 				emit_instr(ctx, addu, dst, src, MIPS_R_ZERO);
@@ -950,7 +951,7 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 			emit_instr(ctx, beq, src, MIPS_R_ZERO, b_off);
 			emit_instr(ctx, movz, MIPS_R_V0, MIPS_R_ZERO, src);
 			emit_instr(ctx, divu, dst, src);
-			if (BPF_OP(insn->code) == BPF_DIV)
+			if (bpf_op == BPF_DIV)
 				emit_instr(ctx, mflo, dst);
 			else
 				emit_instr(ctx, mfhi, dst);
@@ -977,7 +978,7 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 		break;
 	case BPF_JMP | BPF_JEQ | BPF_K: /* JMP_IMM */
 	case BPF_JMP | BPF_JNE | BPF_K: /* JMP_IMM */
-		cmp_eq = (BPF_OP(insn->code) == BPF_JEQ);
+		cmp_eq = (bpf_op == BPF_JEQ);
 		dst = ebpf_to_mips_reg(ctx, insn, dst_reg_fp_ok);
 		if (dst < 0)
 			return dst;
@@ -1012,18 +1013,18 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 			emit_instr(ctx, sll, MIPS_R_AT, dst, 0);
 			dst = MIPS_R_AT;
 		}
-		if (BPF_OP(insn->code) == BPF_JSET) {
+		if (bpf_op == BPF_JSET) {
 			emit_instr(ctx, and, MIPS_R_AT, dst, src);
 			cmp_eq = false;
 			dst = MIPS_R_AT;
 			src = MIPS_R_ZERO;
-		} else if (BPF_OP(insn->code) == BPF_JSGT || BPF_OP(insn->code) == BPF_JSLE) {
+		} else if (bpf_op == BPF_JSGT || bpf_op == BPF_JSLE) {
 			emit_instr(ctx, dsubu, MIPS_R_AT, dst, src);
 			if ((insn + 1)->code == (BPF_JMP | BPF_EXIT) && insn->off == 1) {
 				b_off = b_imm(exit_idx, ctx);
 				if (is_bad_offset(b_off))
 					return -E2BIG;
-				if (BPF_OP(insn->code) == BPF_JSGT)
+				if (bpf_op == BPF_JSGT)
 					emit_instr(ctx, blez, MIPS_R_AT, b_off);
 				else
 					emit_instr(ctx, bgtz, MIPS_R_AT, b_off);
@@ -1033,18 +1034,18 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 			b_off = b_imm(this_idx + insn->off + 1, ctx);
 			if (is_bad_offset(b_off))
 				return -E2BIG;
-			if (BPF_OP(insn->code) == BPF_JSGT)
+			if (bpf_op == BPF_JSGT)
 				emit_instr(ctx, bgtz, MIPS_R_AT, b_off);
 			else
 				emit_instr(ctx, blez, MIPS_R_AT, b_off);
 			emit_instr(ctx, nop);
 			break;
-		} else if (BPF_OP(insn->code) == BPF_JSGE || BPF_OP(insn->code) == BPF_JSLT) {
+		} else if (bpf_op == BPF_JSGE || bpf_op == BPF_JSLT) {
 			emit_instr(ctx, slt, MIPS_R_AT, dst, src);
-			cmp_eq = BPF_OP(insn->code) == BPF_JSGE;
+			cmp_eq = bpf_op == BPF_JSGE;
 			dst = MIPS_R_AT;
 			src = MIPS_R_ZERO;
-		} else if (BPF_OP(insn->code) == BPF_JGT || BPF_OP(insn->code) == BPF_JLE) {
+		} else if (bpf_op == BPF_JGT || bpf_op == BPF_JLE) {
 			/* dst or src could be AT */
 			emit_instr(ctx, dsubu, MIPS_R_T8, dst, src);
 			emit_instr(ctx, sltu, MIPS_R_AT, dst, src);
@@ -1052,16 +1053,16 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 			emit_instr(ctx, movz, MIPS_R_T9, MIPS_R_SP, MIPS_R_T8);
 			emit_instr(ctx, movn, MIPS_R_T9, MIPS_R_ZERO, MIPS_R_T8);
 			emit_instr(ctx, or, MIPS_R_AT, MIPS_R_T9, MIPS_R_AT);
-			cmp_eq = BPF_OP(insn->code) == BPF_JGT;
+			cmp_eq = bpf_op == BPF_JGT;
 			dst = MIPS_R_AT;
 			src = MIPS_R_ZERO;
-		} else if (BPF_OP(insn->code) == BPF_JGE || BPF_OP(insn->code) == BPF_JLT) {
+		} else if (bpf_op == BPF_JGE || bpf_op == BPF_JLT) {
 			emit_instr(ctx, sltu, MIPS_R_AT, dst, src);
-			cmp_eq = BPF_OP(insn->code) == BPF_JGE;
+			cmp_eq = bpf_op == BPF_JGE;
 			dst = MIPS_R_AT;
 			src = MIPS_R_ZERO;
 		} else { /* JNE/JEQ case */
-			cmp_eq = (BPF_OP(insn->code) == BPF_JEQ);
+			cmp_eq = (bpf_op == BPF_JEQ);
 		}
 jeq_common:
 		/*
@@ -1122,7 +1123,7 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 	case BPF_JMP | BPF_JSGE | BPF_K: /* JMP_IMM */
 	case BPF_JMP | BPF_JSLT | BPF_K: /* JMP_IMM */
 	case BPF_JMP | BPF_JSLE | BPF_K: /* JMP_IMM */
-		cmp_eq = (BPF_OP(insn->code) == BPF_JSGE);
+		cmp_eq = (bpf_op == BPF_JSGE);
 		dst = ebpf_to_mips_reg(ctx, insn, dst_reg_fp_ok);
 		if (dst < 0)
 			return dst;
@@ -1132,7 +1133,7 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 				b_off = b_imm(exit_idx, ctx);
 				if (is_bad_offset(b_off))
 					return -E2BIG;
-				switch (BPF_OP(insn->code)) {
+				switch (bpf_op) {
 				case BPF_JSGT:
 					emit_instr(ctx, blez, dst, b_off);
 					break;
@@ -1152,7 +1153,7 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 			b_off = b_imm(this_idx + insn->off + 1, ctx);
 			if (is_bad_offset(b_off))
 				return -E2BIG;
-			switch (BPF_OP(insn->code)) {
+			switch (bpf_op) {
 			case BPF_JSGT:
 				emit_instr(ctx, bgtz, dst, b_off);
 				break;
@@ -1173,14 +1174,14 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 		 * only "LT" compare available, so we must use imm + 1
 		 * to generate "GT" and imm -1 to generate LE
 		 */
-		if (BPF_OP(insn->code) == BPF_JSGT)
+		if (bpf_op == BPF_JSGT)
 			t64s = insn->imm + 1;
-		else if (BPF_OP(insn->code) == BPF_JSLE)
+		else if (bpf_op == BPF_JSLE)
 			t64s = insn->imm + 1;
 		else
 			t64s = insn->imm;
 
-		cmp_eq = BPF_OP(insn->code) == BPF_JSGT || BPF_OP(insn->code) == BPF_JSGE;
+		cmp_eq = bpf_op == BPF_JSGT || bpf_op == BPF_JSGE;
 		if (t64s >= S16_MIN && t64s <= S16_MAX) {
 			emit_instr(ctx, slti, MIPS_R_AT, dst, (int)t64s);
 			src = MIPS_R_AT;
@@ -1197,7 +1198,7 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 	case BPF_JMP | BPF_JGE | BPF_K:
 	case BPF_JMP | BPF_JLT | BPF_K:
 	case BPF_JMP | BPF_JLE | BPF_K:
-		cmp_eq = (BPF_OP(insn->code) == BPF_JGE);
+		cmp_eq = (bpf_op == BPF_JGE);
 		dst = ebpf_to_mips_reg(ctx, insn, dst_reg_fp_ok);
 		if (dst < 0)
 			return dst;
@@ -1205,14 +1206,14 @@ static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
 		 * only "LT" compare available, so we must use imm + 1
 		 * to generate "GT" and imm -1 to generate LE
 		 */
-		if (BPF_OP(insn->code) == BPF_JGT)
+		if (bpf_op == BPF_JGT)
 			t64s = (u64)(u32)(insn->imm) + 1;
-		else if (BPF_OP(insn->code) == BPF_JLE)
+		else if (bpf_op == BPF_JLE)
 			t64s = (u64)(u32)(insn->imm) + 1;
 		else
 			t64s = (u64)(u32)(insn->imm);
 
-		cmp_eq = BPF_OP(insn->code) == BPF_JGT || BPF_OP(insn->code) == BPF_JGE;
+		cmp_eq = bpf_op == BPF_JGT || bpf_op == BPF_JGE;
 
 		emit_const_to_reg(ctx, MIPS_R_AT, (u64)t64s);
 		emit_instr(ctx, sltu, MIPS_R_AT, dst, MIPS_R_AT);
-- 
2.9.5
