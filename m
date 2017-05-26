From: David Daney <david.daney@cavium.com>
Subject: [PATCH 5/5] MIPS: Add support for eBPF JIT.
Date: Thu, 25 May 2017 17:38:26 -0700
Message-ID: <20170526003826.10834-6-david.daney@cavium.com>
References: <20170526003826.10834-1-david.daney@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Markos Chandras <markos.chandras@imgtec.com>,
        David Daney <david.daney@cavium.com>
To: Alexei Starovoitov <ast@kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-mips@linux-mips.org,
        ralf@linux-mips.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170526003826.10834-1-david.daney@cavium.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the eBPF machine has 64-bit registers, we only support this in
64-bit kernels.  As of the writing of this commit log test-bpf is showing:

  test_bpf: Summary: 316 PASSED, 0 FAILED, [308/308 JIT'ed]

All current test cases are successfully compiled.

Signed-off-by: David Daney <david.daney@cavium.com>
---
 arch/mips/Kconfig       |    1 +
 arch/mips/net/bpf_jit.c | 1627 ++++++++++++++++++++++++++++++++++++++++++++++-
 arch/mips/net/bpf_jit.h |    7 +
 3 files changed, 1633 insertions(+), 2 deletions(-)

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 2828ecd..81e764a 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -19,6 +19,7 @@ config MIPS
 	select HAVE_ARCH_SECCOMP_FILTER
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_CBPF_JIT if !CPU_MICROMIPS
+	select HAVE_EBPF_JIT if (64BIT && !CPU_MICROMIPS)
 	select HAVE_FUNCTION_TRACER
 	select HAVE_DYNAMIC_FTRACE
 	select HAVE_FTRACE_MCOUNT_RECORD
diff --git a/arch/mips/net/bpf_jit.c b/arch/mips/net/bpf_jit.c
index 44b9250..a5cf184 100644
--- a/arch/mips/net/bpf_jit.c
+++ b/arch/mips/net/bpf_jit.c
@@ -13,6 +13,7 @@
 #include <linux/compiler.h>
 #include <linux/errno.h>
 #include <linux/filter.h>
+#include <linux/bpf.h>
 #include <linux/if_vlan.h>
 #include <linux/moduleloader.h>
 #include <linux/netdevice.h>
@@ -21,6 +22,7 @@
 #include <linux/types.h>
 #include <asm/asm.h>
 #include <asm/bitops.h>
+#include <asm/byteorder.h>
 #include <asm/cacheflush.h>
 #include <asm/cpu-features.h>
 #include <asm/uasm.h>
@@ -85,24 +87,72 @@
 
 #define SBIT(x)			(1 << (x)) /* Signed version of BIT() */
 
+/* eBPF uses different flags */
+#define EBPF_SAVE_S0	BIT(0)
+#define EBPF_SAVE_S1	BIT(1)
+#define EBPF_SAVE_S2	BIT(2)
+#define EBPF_SAVE_S3	BIT(3)
+#define EBPF_SAVE_RA	BIT(4)
+#define EBPF_SEEN_FP	BIT(5)
+
+/*
+ * For the mips64 ISA, we need to track the value range or type for
+ * each JIT register.  The BPF machine requires zero extended 32-bit
+ * values, but the mips64 ISA requires sign extended 32-bit values.
+ * At each point in the BPF program we track the state of every
+ * register so that we can zero extend or sign extend as the BPF
+ * semantics require.
+ */
+enum reg_val_type {
+	/* uninitialized */
+	REG_UNKNOWN,
+	/* not known to be 32-bit compatible. */
+	REG_64BIT,
+	/* 32-bit compatible, no truncation needed for 64-bit ops. */
+	REG_64BIT_32BIT,
+	/* 32-bit compatible, need truncation for 64-bit ops. */
+	REG_32BIT,
+	/* 32-bit zero extended. */
+	REG_32BIT_ZERO_EX,
+	/* 32-bit no sign/zero extension needed. */
+	REG_32BIT_POS
+};
+
 /**
  * struct jit_ctx - JIT context
  * @skf:		The sk_filter
  * @prologue_bytes:	Number of bytes for prologue
+ * @stack_size:		eBPF stack size
+ * @tmp_offset:		eBPF $sp offset to 8-byte temporary memory
  * @idx:		Instruction index
  * @flags:		JIT flags
  * @offsets:		Instruction offsets
  * @target:		Memory location for the compiled filter
+ * @reg_val_types	Packed enum reg_val_type for each register.
  */
 struct jit_ctx {
 	const struct bpf_prog *skf;
 	unsigned int prologue_bytes;
+	int stack_size;
+	int tmp_offset;
 	u32 idx;
 	u32 flags;
 	u32 *offsets;
 	u32 *target;
+	u64 *reg_val_types;
 };
 
+static void set_reg_val_type(u64 *rvt, int reg, enum reg_val_type type)
+{
+	*rvt &= ~(7ull << (reg * 3));
+	*rvt |= ((u64)type << (reg * 3));
+}
+
+static enum reg_val_type get_reg_val_type(const struct jit_ctx *ctx,
+					  int index, int reg)
+{
+	return (ctx->reg_val_types[index] >> (reg * 3)) & 7;
+}
 
 static inline int optimize_div(u32 *k)
 {
@@ -462,8 +512,7 @@ static inline u32 b_imm(unsigned int tgt, struct jit_ctx *ctx)
 		return 0;
 
 	/*
-	 * We want a pc-relative branch. We only do forward branches
-	 * so tgt is always after pc. tgt is the instruction offset
+	 * We want a pc-relative branch.  tgt is the instruction offset
 	 * we want to jump to.
 
 	 * Branch on MIPS:
@@ -1270,3 +1319,1577 @@ void bpf_jit_free(struct bpf_prog *fp)
 
 	bpf_prog_unlock_free(fp);
 }
+
+enum which_ebpf_reg {
+	src_reg,
+	src_reg_no_fp,
+	dst_reg,
+	dst_reg_fp_ok
+};
+
+/*
+ * For eBPF, the register mapping naturally falls out of the
+ * requirements of eBPF and the MIPS n64 ABI.  We don't maintain a
+ * separate frame pointer, so BPF_REG_10 relative accesses are
+ * adjusted to be $sp relative.
+ */
+int ebpf_to_mips_reg(struct jit_ctx *ctx, const struct bpf_insn *insn,
+		     enum which_ebpf_reg w)
+{
+	int ebpf_reg = (w == src_reg || w == src_reg_no_fp) ?
+		insn->src_reg : insn->dst_reg;
+
+	switch (ebpf_reg) {
+	case BPF_REG_0:
+		return MIPS_R_V0;
+	case BPF_REG_1:
+		return MIPS_R_A0;
+	case BPF_REG_2:
+		return MIPS_R_A1;
+	case BPF_REG_3:
+		return MIPS_R_A2;
+	case BPF_REG_4:
+		return MIPS_R_A3;
+	case BPF_REG_5:
+		return MIPS_R_A4;
+	case BPF_REG_6:
+		ctx->flags |= EBPF_SAVE_S0;
+		return MIPS_R_S0;
+	case BPF_REG_7:
+		ctx->flags |= EBPF_SAVE_S1;
+		return MIPS_R_S1;
+	case BPF_REG_8:
+		ctx->flags |= EBPF_SAVE_S2;
+		return MIPS_R_S2;
+	case BPF_REG_9:
+		ctx->flags |= EBPF_SAVE_S3;
+		return MIPS_R_S3;
+	case BPF_REG_10:
+		if (w == dst_reg || w == src_reg_no_fp)
+			goto bad_reg;
+		ctx->flags |= EBPF_SEEN_FP;
+		/*
+		 * Needs special handling, return something that
+		 * cannot be clobbered just in case.
+		 */
+		return MIPS_R_ZERO;
+	default:
+bad_reg:
+		WARN(1, "Illegal bpf reg: %d\n", ebpf_reg);
+		return -EINVAL;
+	}
+}
+/*
+ * eBPF stack frame will be something like:
+ *
+ *  Entry $sp ------>   +--------------------------------+
+ *                      |   $ra  (optional)              |
+ *                      +--------------------------------+
+ *                      |   $s0  (optional)              |
+ *                      +--------------------------------+
+ *                      |   $s1  (optional)              |
+ *                      +--------------------------------+
+ *                      |   $s2  (optional)              |
+ *                      +--------------------------------+
+ *                      |   $s3  (optional)              |
+ *                      +--------------------------------+
+ *                      |   tmp-storage  (if $ra saved)  |
+ * $sp + tmp_offset --> +--------------------------------+ <--BPF_REG_10
+ *                      |   BPF_REG_10 relative storage  |
+ *                      |    MAX_BPF_STACK (optional)    |
+ *                      |      .                         |
+ *                      |      .                         |
+ *                      |      .                         |
+ *     $sp -------->    +--------------------------------+
+ *
+ * If BPF_REG_10 is never referenced, then the MAX_BPF_STACK sized
+ * area is not allocated.
+ */
+static int gen_int_prologue(struct jit_ctx *ctx)
+{
+	int stack_adjust = 0;
+	int store_offset;
+	int locals_size;
+
+	if (ctx->flags & EBPF_SAVE_RA)
+		/*
+		 * If RA we are doing a function call and may need
+		 * extra 8-byte tmp area.
+		 */
+		stack_adjust += 16;
+	if (ctx->flags & EBPF_SAVE_S0)
+		stack_adjust += 8;
+	if (ctx->flags & EBPF_SAVE_S1)
+		stack_adjust += 8;
+	if (ctx->flags & EBPF_SAVE_S2)
+		stack_adjust += 8;
+	if (ctx->flags & EBPF_SAVE_S3)
+		stack_adjust += 8;
+
+	BUILD_BUG_ON(MAX_BPF_STACK & 7);
+	locals_size = (ctx->flags & EBPF_SEEN_FP) ? MAX_BPF_STACK : 0;
+
+	stack_adjust += locals_size;
+	ctx->tmp_offset = locals_size;
+
+	ctx->stack_size = stack_adjust;
+	if (stack_adjust)
+		emit_instr(ctx, daddiu, MIPS_R_SP, MIPS_R_SP, -stack_adjust);
+	else
+		return 0;
+
+	store_offset = stack_adjust - 8;
+
+	if (ctx->flags & EBPF_SAVE_RA) {
+		emit_instr(ctx, sd, MIPS_R_RA, store_offset, MIPS_R_SP);
+		store_offset -= 8;
+	}
+	if (ctx->flags & EBPF_SAVE_S0) {
+		emit_instr(ctx, sd, MIPS_R_S0, store_offset, MIPS_R_SP);
+		store_offset -= 8;
+	}
+	if (ctx->flags & EBPF_SAVE_S1) {
+		emit_instr(ctx, sd, MIPS_R_S1, store_offset, MIPS_R_SP);
+		store_offset -= 8;
+	}
+	if (ctx->flags & EBPF_SAVE_S2) {
+		emit_instr(ctx, sd, MIPS_R_S2, store_offset, MIPS_R_SP);
+		store_offset -= 8;
+	}
+	if (ctx->flags & EBPF_SAVE_S3) {
+		emit_instr(ctx, sd, MIPS_R_S3, store_offset, MIPS_R_SP);
+		store_offset -= 8;
+	}
+
+	return 0;
+}
+
+static int build_int_epilogue(struct jit_ctx *ctx)
+{
+	const struct bpf_prog *prog = ctx->skf;
+	int stack_adjust = ctx->stack_size;
+	int store_offset = stack_adjust - 8;
+	int r0 = MIPS_R_V0;
+
+	if (get_reg_val_type(ctx, prog->len, BPF_REG_0) == REG_32BIT_ZERO_EX)
+		/* Don't let zero extended value escape. */
+		emit_instr(ctx, sll, r0, r0, 0);
+
+	if (ctx->flags & EBPF_SAVE_RA) {
+		emit_instr(ctx, ld, MIPS_R_RA, store_offset, MIPS_R_SP);
+		store_offset -= 8;
+	}
+	if (ctx->flags & EBPF_SAVE_S0) {
+		emit_instr(ctx, ld, MIPS_R_S0, store_offset, MIPS_R_SP);
+		store_offset -= 8;
+	}
+	if (ctx->flags & EBPF_SAVE_S1) {
+		emit_instr(ctx, ld, MIPS_R_S1, store_offset, MIPS_R_SP);
+		store_offset -= 8;
+	}
+	if (ctx->flags & EBPF_SAVE_S2) {
+		emit_instr(ctx, ld, MIPS_R_S2, store_offset, MIPS_R_SP);
+		store_offset -= 8;
+	}
+	if (ctx->flags & EBPF_SAVE_S3) {
+		emit_instr(ctx, ld, MIPS_R_S3, store_offset, MIPS_R_SP);
+		store_offset -= 8;
+	}
+	emit_jr(MIPS_R_RA, ctx);
+
+	if (stack_adjust)
+		emit_instr(ctx, daddiu, MIPS_R_SP, MIPS_R_SP, stack_adjust);
+	else
+		emit_nop(ctx);
+
+	return 0;
+}
+
+static void gen_imm_to_reg(const struct bpf_insn *insn, int reg,
+			   struct jit_ctx *ctx)
+{
+	if (insn->imm >= S16_MIN && insn->imm <= S16_MAX) {
+		emit_instr(ctx, addiu, reg, MIPS_R_ZERO, insn->imm);
+	} else {
+		int lower = (s16)(insn->imm & 0xffff);
+		int upper = insn->imm - lower;
+
+		emit_instr(ctx, lui, reg, upper >> 16);
+		emit_instr(ctx, addiu, reg, reg, lower);
+	}
+
+}
+
+static int gen_imm_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
+			int idx)
+{
+	int upper_bound, lower_bound;
+	int dst = ebpf_to_mips_reg(ctx, insn, dst_reg);
+
+	if (dst < 0)
+		return dst;
+
+	switch (BPF_OP(insn->code)) {
+	case BPF_MOV:
+	case BPF_ADD:
+		upper_bound = S16_MAX;
+		lower_bound = S16_MIN;
+		break;
+	case BPF_SUB:
+		upper_bound = -(int)S16_MIN;
+		lower_bound = -(int)S16_MAX;
+		break;
+	case BPF_AND:
+	case BPF_OR:
+	case BPF_XOR:
+		upper_bound = 0xffff;
+		lower_bound = 0;
+		break;
+	case BPF_RSH:
+	case BPF_LSH:
+	case BPF_ARSH:
+		upper_bound = (BPF_CLASS(insn->code) == BPF_ALU64) ? 63 : 31;
+		lower_bound = 0;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	/*
+	 * Immediate move clobbers the register, so no sign/zero
+	 * extension needed.
+	 */
+	if (BPF_CLASS(insn->code) == BPF_ALU64 &&
+	    BPF_OP(insn->code) != BPF_MOV &&
+	    get_reg_val_type(ctx, idx, insn->dst_reg) == REG_32BIT)
+		emit_instr(ctx, dinsu, dst, MIPS_R_ZERO, 32, 32);
+	/* BPF_ALU | BPF_LSH doesn't need separate sign extension */
+	if (BPF_CLASS(insn->code) == BPF_ALU &&
+	    BPF_OP(insn->code) != BPF_LSH &&
+	    BPF_OP(insn->code) != BPF_MOV &&
+	    get_reg_val_type(ctx, idx, insn->dst_reg) != REG_32BIT)
+		emit_instr(ctx, sll, dst, dst, 0);
+
+	if (insn->imm >= lower_bound && insn->imm <= upper_bound) {
+		/* single insn immediate case */
+		switch (BPF_OP(insn->code) | BPF_CLASS(insn->code)) {
+		case BPF_ALU64 | BPF_MOV:
+			emit_instr(ctx, daddiu, dst, MIPS_R_ZERO, insn->imm);
+			break;
+		case BPF_ALU64 | BPF_AND:
+		case BPF_ALU | BPF_AND:
+			emit_instr(ctx, andi, dst, dst, insn->imm);
+			break;
+		case BPF_ALU64 | BPF_OR:
+		case BPF_ALU | BPF_OR:
+			emit_instr(ctx, ori, dst, dst, insn->imm);
+			break;
+		case BPF_ALU64 | BPF_XOR:
+		case BPF_ALU | BPF_XOR:
+			emit_instr(ctx, xori, dst, dst, insn->imm);
+			break;
+		case BPF_ALU64 | BPF_ADD:
+			emit_instr(ctx, daddiu, dst, dst, insn->imm);
+			break;
+		case BPF_ALU64 | BPF_SUB:
+			emit_instr(ctx, daddiu, dst, dst, -insn->imm);
+			break;
+		case BPF_ALU64 | BPF_RSH:
+			emit_instr(ctx, dsrl_safe, dst, dst, insn->imm);
+			break;
+		case BPF_ALU | BPF_RSH:
+			emit_instr(ctx, srl, dst, dst, insn->imm);
+			break;
+		case BPF_ALU64 | BPF_LSH:
+			emit_instr(ctx, dsll_safe, dst, dst, insn->imm);
+			break;
+		case BPF_ALU | BPF_LSH:
+			emit_instr(ctx, sll, dst, dst, insn->imm);
+			break;
+		case BPF_ALU64 | BPF_ARSH:
+			emit_instr(ctx, dsra_safe, dst, dst, insn->imm);
+			break;
+		case BPF_ALU | BPF_ARSH:
+			emit_instr(ctx, sra, dst, dst, insn->imm);
+			break;
+		case BPF_ALU | BPF_MOV:
+			emit_instr(ctx, addiu, dst, MIPS_R_ZERO, insn->imm);
+			break;
+		case BPF_ALU | BPF_ADD:
+			emit_instr(ctx, addiu, dst, dst, insn->imm);
+			break;
+		case BPF_ALU | BPF_SUB:
+			emit_instr(ctx, addiu, dst, dst, -insn->imm);
+			break;
+		default:
+			return -EINVAL;
+		}
+	} else {
+		/* multi insn immediate case */
+		if (BPF_OP(insn->code) == BPF_MOV) {
+			gen_imm_to_reg(insn, dst, ctx);
+		} else {
+			gen_imm_to_reg(insn, MIPS_R_AT, ctx);
+			switch (BPF_OP(insn->code) | BPF_CLASS(insn->code)) {
+			case BPF_ALU64 | BPF_AND:
+			case BPF_ALU | BPF_AND:
+				emit_instr(ctx, and, dst, dst, MIPS_R_AT);
+				break;
+			case BPF_ALU64 | BPF_OR:
+			case BPF_ALU | BPF_OR:
+				emit_instr(ctx, or, dst, dst, MIPS_R_AT);
+				break;
+			case BPF_ALU64 | BPF_XOR:
+			case BPF_ALU | BPF_XOR:
+				emit_instr(ctx, xor, dst, dst, MIPS_R_AT);
+				break;
+			case BPF_ALU64 | BPF_ADD:
+				emit_instr(ctx, daddu, dst, dst, MIPS_R_AT);
+				break;
+			case BPF_ALU64 | BPF_SUB:
+				emit_instr(ctx, dsubu, dst, dst, MIPS_R_AT);
+				break;
+			case BPF_ALU | BPF_ADD:
+				emit_instr(ctx, addu, dst, dst, MIPS_R_AT);
+				break;
+			case BPF_ALU | BPF_SUB:
+				emit_instr(ctx, subu, dst, dst, MIPS_R_AT);
+				break;
+			default:
+				return -EINVAL;
+			}
+		}
+	}
+
+	return 0;
+}
+
+static void * __must_check
+ool_skb_header_pointer(const struct sk_buff *skb, int offset,
+		       int len, void *buffer)
+{
+	return skb_header_pointer(skb, offset, len, buffer);
+}
+
+static int size_to_len(const struct bpf_insn *insn)
+{
+	switch (BPF_SIZE(insn->code)) {
+	case BPF_B:
+		return 1;
+	case BPF_H:
+		return 2;
+	case BPF_W:
+		return 4;
+	case BPF_DW:
+		return 8;
+	}
+	return 0;
+}
+
+static void emit_const_to_reg(struct jit_ctx *ctx, int dst, u64 value)
+{
+	if (value >= 0xffffffffffff8000ull || value < 0x8000ull) {
+		emit_instr(ctx, daddiu, dst, MIPS_R_ZERO, (int)value);
+	} else if (value >= 0xffffffff80000000ull ||
+		   (value < 0x80000000 && value > 0xffff)) {
+		emit_instr(ctx, lui, dst, (int)(value >> 16));
+		emit_instr(ctx, ori, dst, dst, (unsigned int)(value & 0xffff));
+	} else {
+		int i;
+		bool seen_part = false;
+		int needed_shift = 0;
+
+		for (i = 0; i < 4; i++) {
+			u64 part = (value >> (16 * (3 - i))) & 0xffff;
+
+			if (seen_part && needed_shift > 0 && (part || i == 3)) {
+				emit_instr(ctx, dsll_safe, dst, dst, needed_shift);
+				needed_shift = 0;
+			}
+			if (part) {
+				emit_instr(ctx, ori, dst, seen_part ? dst : MIPS_R_ZERO, (unsigned int)part);
+				seen_part = true;
+			}
+			if (seen_part)
+				needed_shift += 16;
+		}
+	}
+}
+
+static bool use_bbit_insns(void)
+{
+	switch (current_cpu_type()) {
+	case CPU_CAVIUM_OCTEON:
+	case CPU_CAVIUM_OCTEON_PLUS:
+	case CPU_CAVIUM_OCTEON2:
+	case CPU_CAVIUM_OCTEON3:
+		return true;
+	default:
+		return false;
+	}
+}
+
+static bool is_bad_offset(int b_off)
+{
+	return b_off > 0x1ffff || b_off < -0x20000;
+}
+
+/* Returns the number of insn slots consumed. */
+static int build_one_insn(const struct bpf_insn *insn, struct jit_ctx *ctx,
+			  int this_idx, int exit_idx)
+{
+	int src, dst, r, td, ts, mem_off, b_off;
+	bool need_swap, did_move, cmp_eq;
+	u64 t64;
+	s64 t64s;
+
+	switch (insn->code) {
+	case BPF_ALU64 | BPF_ADD | BPF_K: /* ALU64_IMM */
+	case BPF_ALU64 | BPF_SUB | BPF_K: /* ALU64_IMM */
+	case BPF_ALU64 | BPF_OR | BPF_K: /* ALU64_IMM */
+	case BPF_ALU64 | BPF_AND | BPF_K: /* ALU64_IMM */
+	case BPF_ALU64 | BPF_LSH | BPF_K: /* ALU64_IMM */
+	case BPF_ALU64 | BPF_RSH | BPF_K: /* ALU64_IMM */
+	case BPF_ALU64 | BPF_XOR | BPF_K: /* ALU64_IMM */
+	case BPF_ALU64 | BPF_ARSH | BPF_K: /* ALU64_IMM */
+	case BPF_ALU64 | BPF_MOV | BPF_K: /* ALU64_IMM */
+	case BPF_ALU | BPF_MOV | BPF_K: /* ALU32_IMM */
+	case BPF_ALU | BPF_ADD | BPF_K: /* ALU32_IMM */
+	case BPF_ALU | BPF_SUB | BPF_K: /* ALU32_IMM */
+	case BPF_ALU | BPF_OR | BPF_K: /* ALU64_IMM */
+	case BPF_ALU | BPF_AND | BPF_K: /* ALU64_IMM */
+	case BPF_ALU | BPF_LSH | BPF_K: /* ALU64_IMM */
+	case BPF_ALU | BPF_RSH | BPF_K: /* ALU64_IMM */
+	case BPF_ALU | BPF_XOR | BPF_K: /* ALU64_IMM */
+	case BPF_ALU | BPF_ARSH | BPF_K: /* ALU64_IMM */
+		r = gen_imm_insn(insn, ctx, this_idx);
+		if (r < 0)
+			return r;
+		break;
+	case BPF_ALU64 | BPF_MUL | BPF_K: /* ALU64_IMM */
+		dst = ebpf_to_mips_reg(ctx, insn, dst_reg);
+		if (dst < 0)
+			return dst;
+		if (get_reg_val_type(ctx, this_idx, insn->dst_reg) == REG_32BIT)
+			emit_instr(ctx, dinsu, dst, MIPS_R_ZERO, 32, 32);
+		if (insn->imm == 1) /* Mult by 1 is a nop */
+			break;
+		gen_imm_to_reg(insn, MIPS_R_AT, ctx);
+		emit_instr(ctx, dmultu, MIPS_R_AT, dst);
+		emit_instr(ctx, mflo, dst);
+		break;
+	case BPF_ALU64 | BPF_NEG | BPF_K: /* ALU64_IMM */
+		dst = ebpf_to_mips_reg(ctx, insn, dst_reg);
+		if (dst < 0)
+			return dst;
+		if (get_reg_val_type(ctx, this_idx, insn->dst_reg) == REG_32BIT)
+			emit_instr(ctx, dinsu, dst, MIPS_R_ZERO, 32, 32);
+		emit_instr(ctx, dsubu, dst, MIPS_R_ZERO, dst);
+		break;
+	case BPF_ALU | BPF_MUL | BPF_K: /* ALU_IMM */
+		dst = ebpf_to_mips_reg(ctx, insn, dst_reg);
+		if (dst < 0)
+			return dst;
+		td = get_reg_val_type(ctx, this_idx, insn->dst_reg);
+		if (td == REG_64BIT || td == REG_32BIT_ZERO_EX) {
+			/* sign extend */
+			emit_instr(ctx, sll, dst, dst, 0);
+		}
+		if (insn->imm == 1) /* Mult by 1 is a nop */
+			break;
+		gen_imm_to_reg(insn, MIPS_R_AT, ctx);
+		emit_instr(ctx, multu, dst, MIPS_R_AT);
+		emit_instr(ctx, mflo, dst);
+		break;
+	case BPF_ALU | BPF_NEG | BPF_K: /* ALU_IMM */
+		dst = ebpf_to_mips_reg(ctx, insn, dst_reg);
+		if (dst < 0)
+			return dst;
+		td = get_reg_val_type(ctx, this_idx, insn->dst_reg);
+		if (td == REG_64BIT || td == REG_32BIT_ZERO_EX) {
+			/* sign extend */
+			emit_instr(ctx, sll, dst, dst, 0);
+		}
+		emit_instr(ctx, subu, dst, MIPS_R_ZERO, dst);
+		break;
+	case BPF_ALU | BPF_DIV | BPF_K: /* ALU_IMM */
+	case BPF_ALU | BPF_MOD | BPF_K: /* ALU_IMM */
+		dst = ebpf_to_mips_reg(ctx, insn, dst_reg);
+		if (dst < 0)
+			return dst;
+		if (insn->imm == 0) { /* Div by zero */
+			b_off = b_imm(exit_idx, ctx);
+			if (is_bad_offset(b_off))
+				return -E2BIG;
+			emit_instr(ctx, beq, MIPS_R_ZERO, MIPS_R_ZERO, b_off);
+			emit_instr(ctx, addu, MIPS_R_V0, MIPS_R_ZERO, MIPS_R_ZERO);
+		}
+		td = get_reg_val_type(ctx, this_idx, insn->dst_reg);
+		if (td == REG_64BIT || td == REG_32BIT_ZERO_EX)
+			/* sign extend */
+			emit_instr(ctx, sll, dst, dst, 0);
+		if (insn->imm == 1) {
+			/* div by 1 is a nop, mod by 1 is zero */
+			if (BPF_OP(insn->code) == BPF_MOD)
+				emit_instr(ctx, addu, dst, MIPS_R_ZERO, MIPS_R_ZERO);
+			break;
+		}
+		gen_imm_to_reg(insn, MIPS_R_AT, ctx);
+		emit_instr(ctx, divu, dst, MIPS_R_AT);
+		if (BPF_OP(insn->code) == BPF_DIV)
+			emit_instr(ctx, mflo, dst);
+		else
+			emit_instr(ctx, mfhi, dst);
+		break;
+	case BPF_ALU64 | BPF_DIV | BPF_K: /* ALU_IMM */
+	case BPF_ALU64 | BPF_MOD | BPF_K: /* ALU_IMM */
+		dst = ebpf_to_mips_reg(ctx, insn, dst_reg);
+		if (dst < 0)
+			return dst;
+		if (insn->imm == 0) { /* Div by zero */
+			b_off = b_imm(exit_idx, ctx);
+			if (is_bad_offset(b_off))
+				return -E2BIG;
+			emit_instr(ctx, beq, MIPS_R_ZERO, MIPS_R_ZERO, b_off);
+			emit_instr(ctx, addu, MIPS_R_V0, MIPS_R_ZERO, MIPS_R_ZERO);
+		}
+		if (get_reg_val_type(ctx, this_idx, insn->dst_reg) == REG_32BIT)
+			emit_instr(ctx, dinsu, dst, MIPS_R_ZERO, 32, 32);
+
+		if (insn->imm == 1) {
+			/* div by 1 is a nop, mod by 1 is zero */
+			if (BPF_OP(insn->code) == BPF_MOD)
+				emit_instr(ctx, addu, dst, MIPS_R_ZERO, MIPS_R_ZERO);
+			break;
+		}
+		gen_imm_to_reg(insn, MIPS_R_AT, ctx);
+		emit_instr(ctx, ddivu, dst, MIPS_R_AT);
+		if (BPF_OP(insn->code) == BPF_DIV)
+			emit_instr(ctx, mflo, dst);
+		else
+			emit_instr(ctx, mfhi, dst);
+		break;
+	case BPF_ALU64 | BPF_MOV | BPF_X: /* ALU64_REG */
+	case BPF_ALU64 | BPF_ADD | BPF_X: /* ALU64_REG */
+	case BPF_ALU64 | BPF_SUB | BPF_X: /* ALU64_REG */
+	case BPF_ALU64 | BPF_XOR | BPF_X: /* ALU64_REG */
+	case BPF_ALU64 | BPF_OR | BPF_X: /* ALU64_REG */
+	case BPF_ALU64 | BPF_AND | BPF_X: /* ALU64_REG */
+	case BPF_ALU64 | BPF_MUL | BPF_X: /* ALU64_REG */
+	case BPF_ALU64 | BPF_DIV | BPF_X: /* ALU64_REG */
+	case BPF_ALU64 | BPF_MOD | BPF_X: /* ALU64_REG */
+	case BPF_ALU64 | BPF_LSH | BPF_X: /* ALU64_REG */
+	case BPF_ALU64 | BPF_RSH | BPF_X: /* ALU64_REG */
+	case BPF_ALU64 | BPF_ARSH | BPF_X: /* ALU64_REG */
+		src = ebpf_to_mips_reg(ctx, insn, src_reg);
+		dst = ebpf_to_mips_reg(ctx, insn, dst_reg);
+		if (src < 0 || dst < 0)
+			return -EINVAL;
+		if (get_reg_val_type(ctx, this_idx, insn->dst_reg) == REG_32BIT)
+			emit_instr(ctx, dinsu, dst, MIPS_R_ZERO, 32, 32);
+		did_move = false;
+		if (insn->src_reg == BPF_REG_10) {
+			if (BPF_OP(insn->code) == BPF_MOV) {
+				emit_instr(ctx, daddiu, dst, MIPS_R_SP, MAX_BPF_STACK);
+				did_move = true;
+			} else {
+				emit_instr(ctx, daddiu, MIPS_R_AT, MIPS_R_SP, MAX_BPF_STACK);
+				src = MIPS_R_AT;
+			}
+		} else if (get_reg_val_type(ctx, this_idx, insn->src_reg) == REG_32BIT) {
+			int tmp_reg = MIPS_R_AT;
+
+			if (BPF_OP(insn->code) == BPF_MOV) {
+				tmp_reg = dst;
+				did_move = true;
+			}
+			emit_instr(ctx, daddu, tmp_reg, src, MIPS_R_ZERO);
+			emit_instr(ctx, dinsu, tmp_reg, MIPS_R_ZERO, 32, 32);
+			src = MIPS_R_AT;
+		}
+		switch (BPF_OP(insn->code)) {
+		case BPF_MOV:
+			if (!did_move)
+				emit_instr(ctx, daddu, dst, src, MIPS_R_ZERO);
+			break;
+		case BPF_ADD:
+			emit_instr(ctx, daddu, dst, dst, src);
+			break;
+		case BPF_SUB:
+			emit_instr(ctx, dsubu, dst, dst, src);
+			break;
+		case BPF_XOR:
+			emit_instr(ctx, xor, dst, dst, src);
+			break;
+		case BPF_OR:
+			emit_instr(ctx, or, dst, dst, src);
+			break;
+		case BPF_AND:
+			emit_instr(ctx, and, dst, dst, src);
+			break;
+		case BPF_MUL:
+			emit_instr(ctx, dmultu, dst, src);
+			emit_instr(ctx, mflo, dst);
+			break;
+		case BPF_DIV:
+		case BPF_MOD:
+			b_off = b_imm(exit_idx, ctx);
+			if (is_bad_offset(b_off))
+				return -E2BIG;
+			emit_instr(ctx, beq, src, MIPS_R_ZERO, b_off);
+			emit_instr(ctx, movz, MIPS_R_V0, MIPS_R_ZERO, src);
+			emit_instr(ctx, ddivu, dst, src);
+			if (BPF_OP(insn->code) == BPF_DIV)
+				emit_instr(ctx, mflo, dst);
+			else
+				emit_instr(ctx, mfhi, dst);
+			break;
+		case BPF_LSH:
+			emit_instr(ctx, dsllv, dst, dst, src);
+			break;
+		case BPF_RSH:
+			emit_instr(ctx, dsrlv, dst, dst, src);
+			break;
+		case BPF_ARSH:
+			emit_instr(ctx, dsrav, dst, dst, src);
+			break;
+		default:
+			pr_err("ALU64_REG NOT HANDLED\n");
+			return -EINVAL;
+		}
+		break;
+	case BPF_ALU | BPF_MOV | BPF_X: /* ALU_REG */
+	case BPF_ALU | BPF_ADD | BPF_X: /* ALU_REG */
+	case BPF_ALU | BPF_SUB | BPF_X: /* ALU_REG */
+	case BPF_ALU | BPF_XOR | BPF_X: /* ALU_REG */
+	case BPF_ALU | BPF_OR | BPF_X: /* ALU_REG */
+	case BPF_ALU | BPF_AND | BPF_X: /* ALU_REG */
+	case BPF_ALU | BPF_MUL | BPF_X: /* ALU_REG */
+	case BPF_ALU | BPF_DIV | BPF_X: /* ALU_REG */
+	case BPF_ALU | BPF_MOD | BPF_X: /* ALU_REG */
+	case BPF_ALU | BPF_LSH | BPF_X: /* ALU_REG */
+	case BPF_ALU | BPF_RSH | BPF_X: /* ALU_REG */
+		src = ebpf_to_mips_reg(ctx, insn, src_reg_no_fp);
+		dst = ebpf_to_mips_reg(ctx, insn, dst_reg);
+		if (src < 0 || dst < 0)
+			return -EINVAL;
+		td = get_reg_val_type(ctx, this_idx, insn->dst_reg);
+		if (td == REG_64BIT || td == REG_32BIT_ZERO_EX) {
+			/* sign extend */
+			emit_instr(ctx, sll, dst, dst, 0);
+		}
+		did_move = false;
+		ts = get_reg_val_type(ctx, this_idx, insn->src_reg);
+		if (ts == REG_64BIT || ts == REG_32BIT_ZERO_EX) {
+			int tmp_reg = MIPS_R_AT;
+
+			if (BPF_OP(insn->code) == BPF_MOV) {
+				tmp_reg = dst;
+				did_move = true;
+			}
+			/* sign extend */
+			emit_instr(ctx, sll, tmp_reg, src, 0);
+			src = MIPS_R_AT;
+		}
+		switch (BPF_OP(insn->code)) {
+		case BPF_MOV:
+			if (!did_move)
+				emit_instr(ctx, addu, dst, src, MIPS_R_ZERO);
+			break;
+		case BPF_ADD:
+			emit_instr(ctx, addu, dst, dst, src);
+			break;
+		case BPF_SUB:
+			emit_instr(ctx, subu, dst, dst, src);
+			break;
+		case BPF_XOR:
+			emit_instr(ctx, xor, dst, dst, src);
+			break;
+		case BPF_OR:
+			emit_instr(ctx, or, dst, dst, src);
+			break;
+		case BPF_AND:
+			emit_instr(ctx, and, dst, dst, src);
+			break;
+		case BPF_MUL:
+			emit_instr(ctx, mul, dst, dst, src);
+			break;
+		case BPF_DIV:
+		case BPF_MOD:
+			b_off = b_imm(exit_idx, ctx);
+			if (is_bad_offset(b_off))
+				return -E2BIG;
+			emit_instr(ctx, beq, src, MIPS_R_ZERO, b_off);
+			emit_instr(ctx, movz, MIPS_R_V0, MIPS_R_ZERO, src);
+			emit_instr(ctx, divu, dst, src);
+			if (BPF_OP(insn->code) == BPF_DIV)
+				emit_instr(ctx, mflo, dst);
+			else
+				emit_instr(ctx, mfhi, dst);
+			break;
+		case BPF_LSH:
+			emit_instr(ctx, sllv, dst, dst, src);
+			break;
+		case BPF_RSH:
+			emit_instr(ctx, srlv, dst, dst, src);
+			break;
+		default:
+			pr_err("ALU_REG NOT HANDLED\n");
+			return -EINVAL;
+		}
+		break;
+	case BPF_JMP | BPF_EXIT:
+		if (this_idx + 1 < exit_idx) {
+			b_off = b_imm(exit_idx, ctx);
+			if (is_bad_offset(b_off))
+				return -E2BIG;
+			emit_instr(ctx, beq, MIPS_R_ZERO, MIPS_R_ZERO, b_off);
+			emit_nop(ctx);
+		}
+		break;
+	case BPF_JMP | BPF_JEQ | BPF_K: /* JMP_IMM */
+	case BPF_JMP | BPF_JNE | BPF_K: /* JMP_IMM */
+		cmp_eq = (BPF_OP(insn->code) == BPF_JEQ);
+		dst = ebpf_to_mips_reg(ctx, insn, dst_reg_fp_ok);
+		if (dst < 0)
+			return dst;
+		if (insn->imm == 0) {
+			src = MIPS_R_ZERO;
+		} else {
+			gen_imm_to_reg(insn, MIPS_R_AT, ctx);
+			src = MIPS_R_AT;
+		}
+		goto jeq_common;
+	case BPF_JMP | BPF_JEQ | BPF_X: /* JMP_REG */
+	case BPF_JMP | BPF_JNE | BPF_X:
+	case BPF_JMP | BPF_JSGT | BPF_X:
+	case BPF_JMP | BPF_JSGE | BPF_X:
+	case BPF_JMP | BPF_JGT | BPF_X:
+	case BPF_JMP | BPF_JGE | BPF_X:
+	case BPF_JMP | BPF_JSET | BPF_X:
+		src = ebpf_to_mips_reg(ctx, insn, src_reg_no_fp);
+		dst = ebpf_to_mips_reg(ctx, insn, dst_reg);
+		if (src < 0 || dst < 0)
+			return -EINVAL;
+		td = get_reg_val_type(ctx, this_idx, insn->dst_reg);
+		ts = get_reg_val_type(ctx, this_idx, insn->src_reg);
+		if (td == REG_32BIT && ts != REG_32BIT) {
+			emit_instr(ctx, sll, MIPS_R_AT, src, 0);
+			src = MIPS_R_AT;
+		} else if (ts == REG_32BIT && td != REG_32BIT) {
+			emit_instr(ctx, sll, MIPS_R_AT, dst, 0);
+			dst = MIPS_R_AT;
+		}
+		if (BPF_OP(insn->code) == BPF_JSET) {
+			emit_instr(ctx, and, MIPS_R_AT, dst, src);
+			cmp_eq = false;
+			dst = MIPS_R_AT;
+			src = MIPS_R_ZERO;
+		} else if (BPF_OP(insn->code) == BPF_JSGT) {
+			emit_instr(ctx, dsubu, MIPS_R_AT, dst, src);
+			if ((insn + 1)->code == (BPF_JMP | BPF_EXIT) && insn->off == 1) {
+				b_off = b_imm(exit_idx, ctx);
+				if (is_bad_offset(b_off))
+					return -E2BIG;
+				emit_instr(ctx, blez, MIPS_R_AT, b_off);
+				emit_nop(ctx);
+				return 2; /* We consumed the exit. */
+			}
+			b_off = b_imm(this_idx + insn->off + 1, ctx);
+			if (is_bad_offset(b_off))
+				return -E2BIG;
+			emit_instr(ctx, bgtz, MIPS_R_AT, b_off);
+			emit_nop(ctx);
+			break;
+		} else if (BPF_OP(insn->code) == BPF_JSGE) {
+			emit_instr(ctx, slt, MIPS_R_AT, dst, src);
+			cmp_eq = true;
+			dst = MIPS_R_AT;
+			src = MIPS_R_ZERO;
+		} else if (BPF_OP(insn->code) == BPF_JGT) {
+			/* dst or src could be AT */
+			emit_instr(ctx, dsubu, MIPS_R_T8, dst, src);
+			emit_instr(ctx, sltu, MIPS_R_AT, dst, src);
+			/* SP known to be non-zero, movz becomes boolean not */
+			emit_instr(ctx, movz, MIPS_R_T9, MIPS_R_SP, MIPS_R_T8);
+			emit_instr(ctx, movn, MIPS_R_T9, MIPS_R_ZERO, MIPS_R_T8);
+			emit_instr(ctx, or, MIPS_R_AT, MIPS_R_T9, MIPS_R_AT);
+			cmp_eq = true;
+			dst = MIPS_R_AT;
+			src = MIPS_R_ZERO;
+		} else if (BPF_OP(insn->code) == BPF_JGE) {
+			emit_instr(ctx, sltu, MIPS_R_AT, dst, src);
+			cmp_eq = true;
+			dst = MIPS_R_AT;
+			src = MIPS_R_ZERO;
+		} else { /* JNE/JEQ case */
+			cmp_eq = (BPF_OP(insn->code) == BPF_JEQ);
+		}
+jeq_common:
+		/*
+		 * If the next insn is EXIT and we are jumping arround
+		 * only it, invert the sense of the compare and
+		 * conditionally jump to the exit.  Poor man's branch
+		 * chaining.
+		 */
+		if ((insn + 1)->code == (BPF_JMP | BPF_EXIT) && insn->off == 1) {
+			b_off = b_imm(exit_idx, ctx);
+			if (is_bad_offset(b_off))
+				return -E2BIG;
+			if (cmp_eq)
+				emit_instr(ctx, bne, dst, src, b_off);
+			else
+				emit_instr(ctx, beq, dst, src, b_off);
+			emit_nop(ctx);
+			return 2; /* We consumed the exit. */
+		}
+		b_off = b_imm(this_idx + insn->off + 1, ctx);
+		if (is_bad_offset(b_off))
+			return -E2BIG;
+		if (cmp_eq)
+			emit_instr(ctx, beq, dst, src, b_off);
+		else
+			emit_instr(ctx, bne, dst, src, b_off);
+		emit_nop(ctx);
+		break;
+	case BPF_JMP | BPF_JSGT | BPF_K: /* JMP_IMM */
+	case BPF_JMP | BPF_JSGE | BPF_K: /* JMP_IMM */
+		cmp_eq = (BPF_OP(insn->code) == BPF_JSGE);
+		dst = ebpf_to_mips_reg(ctx, insn, dst_reg_fp_ok);
+		if (dst < 0)
+			return dst;
+
+		if (insn->imm == 0) {
+			if ((insn + 1)->code == (BPF_JMP | BPF_EXIT) && insn->off == 1) {
+				b_off = b_imm(exit_idx, ctx);
+				if (is_bad_offset(b_off))
+					return -E2BIG;
+				if (cmp_eq)
+					emit_instr(ctx, bltz, dst, b_off);
+				else
+					emit_instr(ctx, blez, dst, b_off);
+				emit_nop(ctx);
+				return 2; /* We consumed the exit. */
+			}
+			b_off = b_imm(this_idx + insn->off + 1, ctx);
+			if (is_bad_offset(b_off))
+				return -E2BIG;
+			if (cmp_eq)
+				emit_instr(ctx, bgez, dst, b_off);
+			else
+				emit_instr(ctx, bgtz, dst, b_off);
+			emit_nop(ctx);
+			break;
+		}
+		/*
+		 * only "LT" compare available, so we must use imm + 1
+		 * to generate "GT"
+		 */
+		t64s = insn->imm + (cmp_eq ? 0 : 1);
+		if (t64s >= S16_MIN && t64s <= S16_MAX) {
+			emit_instr(ctx, slti, MIPS_R_AT, dst, (int)t64s);
+			src = MIPS_R_AT;
+			dst = MIPS_R_ZERO;
+			cmp_eq = true;
+			goto jeq_common;
+		}
+		emit_const_to_reg(ctx, MIPS_R_AT, (u64)t64s);
+		emit_instr(ctx, slt, MIPS_R_AT, dst, MIPS_R_AT);
+		src = MIPS_R_AT;
+		dst = MIPS_R_ZERO;
+		cmp_eq = true;
+		goto jeq_common;
+
+	case BPF_JMP | BPF_JGT | BPF_K:
+	case BPF_JMP | BPF_JGE | BPF_K:
+		cmp_eq = (BPF_OP(insn->code) == BPF_JGE);
+		dst = ebpf_to_mips_reg(ctx, insn, dst_reg_fp_ok);
+		if (dst < 0)
+			return dst;
+		/*
+		 * only "LT" compare available, so we must use imm + 1
+		 * to generate "GT"
+		 */
+		t64s = (u64)(u32)(insn->imm) + (cmp_eq ? 0 : 1);
+		if (t64s >= 0 && t64s <= S16_MAX) {
+			emit_instr(ctx, sltiu, MIPS_R_AT, dst, (int)t64s);
+			src = MIPS_R_AT;
+			dst = MIPS_R_ZERO;
+			cmp_eq = true;
+			goto jeq_common;
+		}
+		emit_const_to_reg(ctx, MIPS_R_AT, (u64)t64s);
+		emit_instr(ctx, sltu, MIPS_R_AT, dst, MIPS_R_AT);
+		src = MIPS_R_AT;
+		dst = MIPS_R_ZERO;
+		cmp_eq = true;
+		goto jeq_common;
+
+	case BPF_JMP | BPF_JSET | BPF_K: /* JMP_IMM */
+		dst = ebpf_to_mips_reg(ctx, insn, dst_reg_fp_ok);
+		if (dst < 0)
+			return dst;
+
+		if (use_bbit_insns() && hweight32((u32)insn->imm) == 1) {
+			if ((insn + 1)->code == (BPF_JMP | BPF_EXIT) && insn->off == 1) {
+				b_off = b_imm(exit_idx, ctx);
+				if (is_bad_offset(b_off))
+					return -E2BIG;
+				emit_instr(ctx, bbit0, dst, ffs((u32)insn->imm) - 1, b_off);
+				emit_nop(ctx);
+				return 2; /* We consumed the exit. */
+			}
+			b_off = b_imm(this_idx + insn->off + 1, ctx);
+			if (is_bad_offset(b_off))
+				return -E2BIG;
+			emit_instr(ctx, bbit1, dst, ffs((u32)insn->imm) - 1, b_off);
+			emit_nop(ctx);
+			break;
+		}
+		t64 = (u32)insn->imm;
+		emit_const_to_reg(ctx, MIPS_R_AT, t64);
+		emit_instr(ctx, and, MIPS_R_AT, dst, MIPS_R_AT);
+		src = MIPS_R_AT;
+		dst = MIPS_R_ZERO;
+		cmp_eq = false;
+		goto jeq_common;
+
+	case BPF_JMP | BPF_JA:
+		b_off = b_imm(this_idx + insn->off + 1, ctx);
+		if (is_bad_offset(b_off))
+			return -E2BIG;
+		emit_instr(ctx, b, b_off);
+		emit_nop(ctx);
+		break;
+	case BPF_LD | BPF_DW | BPF_IMM:
+		if (insn->src_reg != 0)
+			return -EINVAL;
+		dst = ebpf_to_mips_reg(ctx, insn, dst_reg);
+		if (dst < 0)
+			return dst;
+		t64 = ((u64)(u32)insn->imm) | ((u64)(insn + 1)->imm << 32);
+		emit_const_to_reg(ctx, dst, t64);
+		return 2; /* Double slot insn */
+
+	case BPF_JMP | BPF_CALL:
+		ctx->flags |= EBPF_SAVE_RA;
+		t64s = (s64)insn->imm + (s64)__bpf_call_base;
+		emit_const_to_reg(ctx, MIPS_R_T9, (u64)t64s);
+		emit_jalr(MIPS_R_RA, MIPS_R_T9, ctx);
+		/* delay slot */
+		emit_instr(ctx, nop);
+		break;
+
+	case BPF_LD | BPF_B | BPF_ABS:
+	case BPF_LD | BPF_H | BPF_ABS:
+	case BPF_LD | BPF_W | BPF_ABS:
+	case BPF_LD | BPF_DW | BPF_ABS:
+		ctx->flags |= EBPF_SAVE_RA;
+
+		gen_imm_to_reg(insn, MIPS_R_A1, ctx);
+		emit_instr(ctx, addiu, MIPS_R_A2, MIPS_R_ZERO, size_to_len(insn));
+
+		if (insn->imm < 0) {
+			emit_const_to_reg(ctx, MIPS_R_T9, (u64)bpf_internal_load_pointer_neg_helper);
+		} else {
+			emit_const_to_reg(ctx, MIPS_R_T9, (u64)ool_skb_header_pointer);
+			emit_instr(ctx, daddiu, MIPS_R_A3, MIPS_R_SP, ctx->tmp_offset);
+		}
+		goto ld_skb_common;
+
+	case BPF_LD | BPF_B | BPF_IND:
+	case BPF_LD | BPF_H | BPF_IND:
+	case BPF_LD | BPF_W | BPF_IND:
+	case BPF_LD | BPF_DW | BPF_IND:
+		ctx->flags |= EBPF_SAVE_RA;
+		src = ebpf_to_mips_reg(ctx, insn, src_reg_no_fp);
+		if (src < 0)
+			return src;
+		ts = get_reg_val_type(ctx, this_idx, insn->src_reg);
+		if (ts == REG_32BIT_ZERO_EX) {
+			/* sign extend */
+			emit_instr(ctx, sll, MIPS_R_A1, src, 0);
+			src = MIPS_R_A1;
+		}
+		if (insn->imm >= S16_MIN && insn->imm <= S16_MAX) {
+			emit_instr(ctx, daddiu, MIPS_R_A1, src, insn->imm);
+		} else {
+			gen_imm_to_reg(insn, MIPS_R_AT, ctx);
+			emit_instr(ctx, daddu, MIPS_R_A1, MIPS_R_AT, src);
+		}
+		/* truncate to 32-bit int */
+		emit_instr(ctx, sll, MIPS_R_A1, MIPS_R_A1, 0);
+		emit_instr(ctx, daddiu, MIPS_R_A3, MIPS_R_SP, ctx->tmp_offset);
+		emit_instr(ctx, slt, MIPS_R_AT, MIPS_R_A1, MIPS_R_ZERO);
+
+		emit_const_to_reg(ctx, MIPS_R_T8, (u64)bpf_internal_load_pointer_neg_helper);
+		emit_const_to_reg(ctx, MIPS_R_T9, (u64)ool_skb_header_pointer);
+		emit_instr(ctx, addiu, MIPS_R_A2, MIPS_R_ZERO, size_to_len(insn));
+		emit_instr(ctx, movn, MIPS_R_T9, MIPS_R_T8, MIPS_R_AT);
+
+ld_skb_common:
+		emit_jalr(MIPS_R_RA, MIPS_R_T9, ctx);
+		/* delay slot */
+		emit_reg_move(MIPS_R_A0, MIPS_R_S0, ctx);
+
+		/* Check the error value */
+		b_off = b_imm(exit_idx, ctx);
+		if (is_bad_offset(b_off))
+			return -E2BIG;
+		emit_instr(ctx, beq, MIPS_R_V0, MIPS_R_ZERO, b_off);
+		emit_nop(ctx);
+
+#ifdef __BIG_ENDIAN
+		need_swap = false;
+#else
+		need_swap = true;
+#endif
+		dst = MIPS_R_V0;
+		switch (BPF_SIZE(insn->code)) {
+		case BPF_B:
+			emit_instr(ctx, lbu, dst, 0, MIPS_R_V0);
+			break;
+		case BPF_H:
+			emit_instr(ctx, lhu, dst, 0, MIPS_R_V0);
+			if (need_swap)
+				emit_instr(ctx, wsbh, dst, dst);
+			break;
+		case BPF_W:
+			emit_instr(ctx, lw, dst, 0, MIPS_R_V0);
+			if (need_swap) {
+				emit_instr(ctx, wsbh, dst, dst);
+				emit_instr(ctx, rotr, dst, dst, 16);
+			}
+			break;
+		case BPF_DW:
+			emit_instr(ctx, ld, dst, 0, MIPS_R_V0);
+			if (need_swap) {
+				emit_instr(ctx, dsbh, dst, dst);
+				emit_instr(ctx, dshd, dst, dst);
+			}
+			break;
+		}
+
+		break;
+	case BPF_ALU | BPF_END | BPF_FROM_BE:
+	case BPF_ALU | BPF_END | BPF_FROM_LE:
+		dst = ebpf_to_mips_reg(ctx, insn, dst_reg);
+		if (dst < 0)
+			return dst;
+		td = get_reg_val_type(ctx, this_idx, insn->dst_reg);
+		if (insn->imm == 64 && td == REG_32BIT)
+			emit_instr(ctx, dinsu, dst, MIPS_R_ZERO, 32, 32);
+
+		if (insn->imm != 64 &&
+		    (td == REG_64BIT || td == REG_32BIT_ZERO_EX)) {
+			/* sign extend */
+			emit_instr(ctx, sll, dst, dst, 0);
+		}
+
+#ifdef __BIG_ENDIAN
+		need_swap = (BPF_SRC(insn->code) == BPF_FROM_LE);
+#else
+		need_swap = (BPF_SRC(insn->code) == BPF_FROM_BE);
+#endif
+		if (insn->imm == 16) {
+			if (need_swap)
+				emit_instr(ctx, wsbh, dst, dst);
+			emit_instr(ctx, andi, dst, dst, 0xffff);
+		} else if (insn->imm == 32) {
+			if (need_swap) {
+				emit_instr(ctx, wsbh, dst, dst);
+				emit_instr(ctx, rotr, dst, dst, 16);
+			}
+		} else { /* 64-bit*/
+			if (need_swap) {
+				emit_instr(ctx, dsbh, dst, dst);
+				emit_instr(ctx, dshd, dst, dst);
+			}
+		}
+		break;
+
+	case BPF_ST | BPF_B | BPF_MEM:
+	case BPF_ST | BPF_H | BPF_MEM:
+	case BPF_ST | BPF_W | BPF_MEM:
+	case BPF_ST | BPF_DW | BPF_MEM:
+		if (insn->dst_reg == BPF_REG_10) {
+			ctx->flags |= EBPF_SEEN_FP;
+			dst = MIPS_R_SP;
+			mem_off = insn->off - MAX_BPF_STACK;
+		} else {
+			dst = ebpf_to_mips_reg(ctx, insn, dst_reg);
+			if (dst < 0)
+				return dst;
+			mem_off = insn->off;
+		}
+		gen_imm_to_reg(insn, MIPS_R_AT, ctx);
+		switch (BPF_SIZE(insn->code)) {
+		case BPF_B:
+			emit_instr(ctx, sb, MIPS_R_AT, mem_off, dst);
+			break;
+		case BPF_H:
+			emit_instr(ctx, sh, MIPS_R_AT, mem_off, dst);
+			break;
+		case BPF_W:
+			emit_instr(ctx, sw, MIPS_R_AT, mem_off, dst);
+			break;
+		case BPF_DW:
+			emit_instr(ctx, sd, MIPS_R_AT, mem_off, dst);
+			break;
+		}
+		break;
+
+	case BPF_LDX | BPF_B | BPF_MEM:
+	case BPF_LDX | BPF_H | BPF_MEM:
+	case BPF_LDX | BPF_W | BPF_MEM:
+	case BPF_LDX | BPF_DW | BPF_MEM:
+		if (insn->src_reg == BPF_REG_10) {
+			ctx->flags |= EBPF_SEEN_FP;
+			src = MIPS_R_SP;
+			mem_off = insn->off - MAX_BPF_STACK;
+		} else {
+			src = ebpf_to_mips_reg(ctx, insn, src_reg_no_fp);
+			if (src < 0)
+				return src;
+			mem_off = insn->off;
+		}
+		dst = ebpf_to_mips_reg(ctx, insn, dst_reg);
+		if (dst < 0)
+			return dst;
+		switch (BPF_SIZE(insn->code)) {
+		case BPF_B:
+			emit_instr(ctx, lbu, dst, mem_off, src);
+			break;
+		case BPF_H:
+			emit_instr(ctx, lhu, dst, mem_off, src);
+			break;
+		case BPF_W:
+			emit_instr(ctx, lw, dst, mem_off, src);
+			break;
+		case BPF_DW:
+			emit_instr(ctx, ld, dst, mem_off, src);
+			break;
+		}
+		break;
+
+	case BPF_STX | BPF_B | BPF_MEM:
+	case BPF_STX | BPF_H | BPF_MEM:
+	case BPF_STX | BPF_W | BPF_MEM:
+	case BPF_STX | BPF_DW | BPF_MEM:
+	case BPF_STX | BPF_W | BPF_XADD:
+	case BPF_STX | BPF_DW | BPF_XADD:
+		if (insn->dst_reg == BPF_REG_10) {
+			ctx->flags |= EBPF_SEEN_FP;
+			dst = MIPS_R_SP;
+			mem_off = insn->off - MAX_BPF_STACK;
+		} else {
+			dst = ebpf_to_mips_reg(ctx, insn, dst_reg);
+			if (dst < 0)
+				return dst;
+			mem_off = insn->off;
+		}
+		src = ebpf_to_mips_reg(ctx, insn, src_reg_no_fp);
+		if (src < 0)
+			return dst;
+		if (BPF_MODE(insn->code) == BPF_XADD) {
+			switch (BPF_SIZE(insn->code)) {
+			case BPF_W:
+				if (get_reg_val_type(ctx, this_idx, insn->src_reg) == REG_32BIT) {
+					emit_instr(ctx, sll, MIPS_R_AT, src, 0);
+					src = MIPS_R_AT;
+				}
+				emit_instr(ctx, ll, MIPS_R_T8, mem_off, dst);
+				emit_instr(ctx, addu, MIPS_R_T8, MIPS_R_T8, src);
+				emit_instr(ctx, sc, MIPS_R_T8, mem_off, dst);
+				/*
+				 * On failure back up to LL (-4
+				 * instructions of 4 bytes each
+				 */
+				emit_instr(ctx, beq, MIPS_R_T8, MIPS_R_ZERO, -4 * 4);
+				emit_instr(ctx, nop);
+				break;
+			case BPF_DW:
+				if (get_reg_val_type(ctx, this_idx, insn->src_reg) == REG_32BIT) {
+					emit_instr(ctx, daddu, MIPS_R_AT, src, MIPS_R_ZERO);
+					emit_instr(ctx, dinsu, MIPS_R_AT, MIPS_R_ZERO, 32, 32);
+					src = MIPS_R_AT;
+				}
+				emit_instr(ctx, lld, MIPS_R_T8, mem_off, dst);
+				emit_instr(ctx, daddu, MIPS_R_T8, MIPS_R_T8, src);
+				emit_instr(ctx, scd, MIPS_R_T8, mem_off, dst);
+				emit_instr(ctx, beq, MIPS_R_T8, MIPS_R_ZERO, -4 * 4);
+				emit_instr(ctx, nop);
+				break;
+			}
+		} else { /* BPF_MEM */
+			switch (BPF_SIZE(insn->code)) {
+			case BPF_B:
+				emit_instr(ctx, sb, src, mem_off, dst);
+				break;
+			case BPF_H:
+				emit_instr(ctx, sh, src, mem_off, dst);
+				break;
+			case BPF_W:
+				emit_instr(ctx, sw, src, mem_off, dst);
+				break;
+			case BPF_DW:
+				if (get_reg_val_type(ctx, this_idx, insn->src_reg) == REG_32BIT) {
+					emit_instr(ctx, daddu, MIPS_R_AT, src, MIPS_R_ZERO);
+					emit_instr(ctx, dinsu, MIPS_R_AT, MIPS_R_ZERO, 32, 32);
+					src = MIPS_R_AT;
+				}
+				emit_instr(ctx, sd, src, mem_off, dst);
+				break;
+			}
+		}
+		break;
+
+	default:
+		pr_err("NOT HANDLED %d - (%02x)\n",
+		       this_idx, (unsigned int)insn->code);
+		return -EINVAL;
+	}
+	return 1;
+}
+
+#define RVT_VISITED_MASK 0xc000000000000000ull
+#define RVT_FALL_THROUGH 0x4000000000000000ull
+#define RVT_BRANCH_TAKEN 0x8000000000000000ull
+#define RVT_DONE (RVT_FALL_THROUGH | RVT_BRANCH_TAKEN)
+
+static int build_int_body(struct jit_ctx *ctx)
+{
+	const struct bpf_prog *prog = ctx->skf;
+	const struct bpf_insn *insn;
+	int i, r;
+
+	for (i = 0; i < prog->len; ) {
+		insn = prog->insnsi + i;
+		if ((ctx->reg_val_types[i] & RVT_VISITED_MASK) == 0) {
+			/* dead instruction, don't emit it. */
+			i++;
+			continue;
+		}
+
+		if (ctx->target == NULL)
+			ctx->offsets[i] = ctx->idx * 4;
+
+		r = build_one_insn(insn, ctx, i, prog->len);
+		if (r < 0)
+			return r;
+		i += r;
+	}
+	/* epilogue offset */
+	if (ctx->target == NULL)
+		ctx->offsets[i] = ctx->idx * 4;
+
+	/*
+	 * All exits have an offset of the epilogue, some offsets may
+	 * not have been set due to banch-around threading, so set
+	 * them now.
+	 */
+	if (ctx->target == NULL)
+		for (i = 0; i < prog->len; i++) {
+			insn = prog->insnsi + i;
+			if (insn->code == (BPF_JMP | BPF_EXIT))
+				ctx->offsets[i] = ctx->idx * 4;
+		}
+	return 0;
+}
+
+/* return the last idx processed, or negative for error */
+static int reg_val_propagate_range(struct jit_ctx *ctx, u64 initial_rvt,
+				   int start_idx, bool follow_taken)
+{
+	const struct bpf_prog *prog = ctx->skf;
+	const struct bpf_insn *insn;
+	u64 exit_rvt = initial_rvt;
+	u64 *rvt = ctx->reg_val_types;
+	int idx;
+	int reg;
+
+	for (idx = start_idx; idx < prog->len; idx++) {
+		rvt[idx] = (rvt[idx] & RVT_VISITED_MASK) | exit_rvt;
+		insn = prog->insnsi + idx;
+		switch (BPF_CLASS(insn->code)) {
+		case BPF_ALU:
+			switch (BPF_OP(insn->code)) {
+			case BPF_ADD:
+			case BPF_SUB:
+			case BPF_MUL:
+			case BPF_DIV:
+			case BPF_OR:
+			case BPF_AND:
+			case BPF_LSH:
+			case BPF_RSH:
+			case BPF_NEG:
+			case BPF_MOD:
+			case BPF_XOR:
+				set_reg_val_type(&exit_rvt, insn->dst_reg, REG_32BIT);
+				break;
+			case BPF_MOV:
+				if (BPF_SRC(insn->code)) {
+					set_reg_val_type(&exit_rvt, insn->dst_reg, REG_32BIT);
+				} else {
+					/* IMM to REG move*/
+					if (insn->imm >= 0)
+						set_reg_val_type(&exit_rvt, insn->dst_reg, REG_32BIT_POS);
+					else
+						set_reg_val_type(&exit_rvt, insn->dst_reg, REG_32BIT);
+				}
+				break;
+			case BPF_END:
+				if (insn->imm == 64)
+					set_reg_val_type(&exit_rvt, insn->dst_reg, REG_64BIT);
+				else if (insn->imm == 32)
+					set_reg_val_type(&exit_rvt, insn->dst_reg, REG_32BIT);
+				else /* insn->imm == 16 */
+					set_reg_val_type(&exit_rvt, insn->dst_reg, REG_32BIT_POS);
+				break;
+			}
+			rvt[idx] |= RVT_DONE;
+			break;
+		case BPF_ALU64:
+			switch (BPF_OP(insn->code)) {
+			case BPF_MOV:
+				if (BPF_SRC(insn->code)) {
+					/* REG to REG move*/
+					set_reg_val_type(&exit_rvt, insn->dst_reg, REG_64BIT);
+				} else {
+					/* IMM to REG move*/
+					if (insn->imm >= 0)
+						set_reg_val_type(&exit_rvt, insn->dst_reg, REG_32BIT_POS);
+					else
+						set_reg_val_type(&exit_rvt, insn->dst_reg, REG_64BIT_32BIT);
+				}
+				break;
+			default:
+				set_reg_val_type(&exit_rvt, insn->dst_reg, REG_64BIT);
+			}
+			rvt[idx] |= RVT_DONE;
+			break;
+		case BPF_LD:
+			switch (BPF_SIZE(insn->code)) {
+			case BPF_DW:
+				if (BPF_MODE(insn->code) == BPF_IMM) {
+					s64 val;
+
+					val = (s64)((u32)insn->imm | ((u64)(insn + 1)->imm << 32));
+					if (val > 0 && val <= S32_MAX)
+						set_reg_val_type(&exit_rvt, insn->dst_reg, REG_32BIT_POS);
+					else if (val >= S32_MIN && val <= S32_MAX)
+						set_reg_val_type(&exit_rvt, insn->dst_reg, REG_64BIT_32BIT);
+					else
+						set_reg_val_type(&exit_rvt, insn->dst_reg, REG_64BIT);
+					rvt[idx] |= RVT_DONE;
+					idx++;
+				} else {
+					set_reg_val_type(&exit_rvt, insn->dst_reg, REG_64BIT);
+				}
+				break;
+			case BPF_B:
+			case BPF_H:
+				set_reg_val_type(&exit_rvt, insn->dst_reg, REG_32BIT_POS);
+				break;
+			case BPF_W:
+				if (BPF_MODE(insn->code) == BPF_IMM)
+					set_reg_val_type(&exit_rvt, insn->dst_reg,
+							 insn->imm >= 0 ? REG_32BIT_POS : REG_32BIT);
+				else
+					set_reg_val_type(&exit_rvt, insn->dst_reg, REG_32BIT);
+				break;
+			}
+			rvt[idx] |= RVT_DONE;
+			break;
+		case BPF_LDX:
+			switch (BPF_SIZE(insn->code)) {
+			case BPF_DW:
+				set_reg_val_type(&exit_rvt, insn->dst_reg, REG_64BIT);
+				break;
+			case BPF_B:
+			case BPF_H:
+				set_reg_val_type(&exit_rvt, insn->dst_reg, REG_32BIT_POS);
+				break;
+			case BPF_W:
+				set_reg_val_type(&exit_rvt, insn->dst_reg, REG_32BIT);
+				break;
+			}
+			rvt[idx] |= RVT_DONE;
+			break;
+		case BPF_JMP:
+			switch (BPF_OP(insn->code)) {
+			case BPF_EXIT:
+				rvt[idx] = RVT_DONE | exit_rvt;
+				rvt[prog->len] = exit_rvt;
+				return idx;
+			case BPF_JA:
+				rvt[idx] |= RVT_DONE;
+				idx += insn->off;
+				break;
+			case BPF_JEQ:
+			case BPF_JGT:
+			case BPF_JGE:
+			case BPF_JSET:
+			case BPF_JNE:
+			case BPF_JSGT:
+			case BPF_JSGE:
+				if (follow_taken) {
+					rvt[idx] |= RVT_BRANCH_TAKEN;
+					idx += insn->off;
+					follow_taken = false;
+				} else {
+					rvt[idx] |= RVT_FALL_THROUGH;
+				}
+				break;
+			case BPF_CALL:
+				set_reg_val_type(&exit_rvt, BPF_REG_0, REG_64BIT);
+				/* Upon call return, argument registers are clobbered. */
+				for (reg = BPF_REG_0; reg <= BPF_REG_5; reg++)
+					set_reg_val_type(&exit_rvt, reg, REG_64BIT);
+
+				rvt[idx] |= RVT_DONE;
+				break;
+			default:
+				WARN(1, "Unhandled BPF_JMP case.\n");
+				rvt[idx] |= RVT_DONE;
+				break;
+			}
+			break;
+		default:
+			rvt[idx] |= RVT_DONE;
+			break;
+		}
+	}
+	return idx;
+}
+
+/*
+ * Track the value range (i.e. 32-bit vs. 64-bit) of each register at
+ * each eBPF insn.  This allows unneeded sign and zero extension
+ * operations to be omitted.
+ *
+ * Doesn't handle yet confluence of control paths with conflicting
+ * ranges, but it is good enough for most sane code.
+ */
+static int reg_val_propagate(struct jit_ctx *ctx)
+{
+	const struct bpf_prog *prog = ctx->skf;
+	u64 exit_rvt;
+	int reg;
+	int i;
+
+	/*
+	 * 11 registers * 3 bits/reg leaves top bits free for other
+	 * uses.  Bit-62..63 used to see if we have visited an insn.
+	 */
+	exit_rvt = 0;
+
+	/* Upon entry, argument registers are 64-bit. */
+	for (reg = BPF_REG_1; reg <= BPF_REG_5; reg++)
+		set_reg_val_type(&exit_rvt, reg, REG_64BIT);
+
+	/*
+	 * First follow all conditional branches on the fall-through
+	 * edge of control flow..
+	 */
+	reg_val_propagate_range(ctx, exit_rvt, 0, false);
+restart_search:
+	/*
+	 * Then repeatedly find the first conditional branch where
+	 * both edges of control flow have not been taken, and follow
+	 * the branch taken edge.  We will end up restarting the
+	 * search once per conditional branch insn.
+	 */
+	for (i = 0; i < prog->len; i++) {
+		u64 rvt = ctx->reg_val_types[i];
+
+		if ((rvt & RVT_VISITED_MASK) == RVT_DONE ||
+		    (rvt & RVT_VISITED_MASK) == 0)
+			continue;
+		if ((rvt & RVT_VISITED_MASK) == RVT_FALL_THROUGH) {
+			reg_val_propagate_range(ctx, rvt & ~RVT_VISITED_MASK, i, true);
+		} else { /* RVT_BRANCH_TAKEN */
+			WARN(1, "Unexpected RVT_BRANCH_TAKEN case.\n");
+			reg_val_propagate_range(ctx, rvt & ~RVT_VISITED_MASK, i, false);
+		}
+		goto restart_search;
+	}
+	/*
+	 * Eventually all conditional branches have been followed on
+	 * both branches and we are done.  Any insn that has not been
+	 * visited at this point is dead.
+	 */
+
+	return 0;
+}
+
+struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
+{
+	struct jit_ctx ctx;
+	unsigned int alloc_size;
+
+	/* Only 64-bit kernel supports eBPF */
+	if (!IS_ENABLED(CONFIG_64BIT) || !bpf_jit_enable)
+		return prog;
+
+	memset(&ctx, 0, sizeof(ctx));
+
+	ctx.offsets = kcalloc(prog->len + 1, sizeof(*ctx.offsets), GFP_KERNEL);
+	if (ctx.offsets == NULL)
+		goto out;
+
+	ctx.reg_val_types = kcalloc(prog->len + 1, sizeof(*ctx.reg_val_types), GFP_KERNEL);
+	if (ctx.reg_val_types == NULL)
+		goto out;
+
+	ctx.skf = prog;
+
+	if (reg_val_propagate(&ctx))
+		goto out;
+
+	/* First pass discovers used resources */
+	if (build_int_body(&ctx))
+		goto out;
+
+	/* Second pass generates offsets */
+	ctx.idx = 0;
+	if (gen_int_prologue(&ctx))
+		goto out;
+	if (build_int_body(&ctx))
+		goto out;
+	if (build_int_epilogue(&ctx))
+		goto out;
+
+	alloc_size = 4 * ctx.idx;
+
+	ctx.target = module_alloc(alloc_size);
+	if (ctx.target == NULL)
+		goto out;
+
+	/* Clean it */
+	memset(ctx.target, 0, alloc_size);
+
+	/* Third pass generates the code */
+	ctx.idx = 0;
+	if (gen_int_prologue(&ctx))
+		goto out;
+	if (build_int_body(&ctx))
+		goto out;
+	if (build_int_epilogue(&ctx))
+		goto out;
+	/* Update the icache */
+	flush_icache_range((ptr)ctx.target, (ptr)(ctx.target + ctx.idx));
+
+	if (bpf_jit_enable > 1)
+		/* Dump JIT code */
+		bpf_jit_dump(prog->len, alloc_size, 2, ctx.target);
+
+	prog->bpf_func = (void *)ctx.target;
+	prog->jited = 1;
+
+out:
+	kfree(ctx.offsets);
+	kfree(ctx.reg_val_types);
+
+	return prog;
+}
diff --git a/arch/mips/net/bpf_jit.h b/arch/mips/net/bpf_jit.h
index 8f9f548..fa5351f 100644
--- a/arch/mips/net/bpf_jit.h
+++ b/arch/mips/net/bpf_jit.h
@@ -14,9 +14,14 @@
 
 /* Registers used by JIT */
 #define MIPS_R_ZERO	0
+#define MIPS_R_AT	1
 #define MIPS_R_V0	2
+#define MIPS_R_V1	3
 #define MIPS_R_A0	4
 #define MIPS_R_A1	5
+#define MIPS_R_A2	6
+#define MIPS_R_A3	7
+#define MIPS_R_A4	8
 #define MIPS_R_T4	12
 #define MIPS_R_T5	13
 #define MIPS_R_T6	14
@@ -29,6 +34,8 @@
 #define MIPS_R_S5	21
 #define MIPS_R_S6	22
 #define MIPS_R_S7	23
+#define MIPS_R_T8	24
+#define MIPS_R_T9	25
 #define MIPS_R_SP	29
 #define MIPS_R_RA	31
 
-- 
2.9.4
