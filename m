From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: [PATCH 14/14] arm64: eBPF JIT compiler
Date: Fri, 18 Jul 2014 11:28:20 -0700
Message-ID: <1405708100-13604-15-git-send-email-zlim.lnx@gmail.com>
References: <1405708100-13604-1-git-send-email-zlim.lnx@gmail.com>
Cc: Zi Shen Lim <zlim.lnx@gmail.com>, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Chema Gonzalez <chema@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1405708100-13604-1-git-send-email-zlim.lnx@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The JIT compiler emits A64 instructions. It supports eBPF only.
Legacy BPF is supported thanks to conversion by BPF core.

JIT is enabled in the same way as for other architectures:

	echo 1 > /proc/sys/net/core/bpf_jit_enable

Or for additional compiler output:

	echo 2 > /proc/sys/net/core/bpf_jit_enable

See Documentation/networking/filter.txt for more information.

The implementation passes all 57 tests in lib/test_bpf.c
on ARMv8 Foundation Model :)

Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>

---
RFCv3->v1:

  Addressed review comments from Will wrt codegen bits:
  - define and use {SF,N}_BIT
  - use masks for limit checks

  Also:
  - rebase onto net-next

RFCv2->RFCv3:

  - clarify 16B stack alignment requirement - I missed one reference
  - fixed a couple checks for immediate bits
  - make bpf_jit.h checkpatch clean
  - remove stale DW case in LD_IND and LD_ABS (good catch by Alexei)
  - add Alexei's Acked-by
  - rebase onto net-next

  Also, per discussion with Will, consolidated bpf_jit.h into
  arch/arm64/.../insn.{c,h}:
  - instruction encoding stuff moved into arch/arm64/kernel/insn.c
  - bpf_jit.h uses arch/arm64/include/asm/insn.h

RFCv1->RFCv2:

  Addressed review comments from Alexei:
  - use core-$(CONFIG_NET)
  - use GENMASK
  - lower-case function names in header file
  - drop LD_ABS+DW and LD_IND+DW, which do not exist in eBPF yet
  - use pr_xxx_once() to prevent spamming logs
  - clarify 16B stack alignment requirement
  - drop usage of EMIT macro which was saving just one argument,
    turns out having additional argument wasn't too much of an eyesore

  Also, per discussion with Alexei, and additional suggestion from
  Daniel:
  - moved load_pointer() from net/core/filter.c into filter.h
    as bpf_load_pointer()
  which is done as a separate preparatory patch. [1]

[1] http://patchwork.ozlabs.org/patch/366906/

NOTES:

* The preparatory patch [1] has been merged into net-next
  9f12fbe603f7 ("net: filter: move load_pointer() into filter.h").

* This patch applies on top of net-next @ da388973d4a1
  ("iw_cxgb4: fix for 64-bit integer division")

* bpf_jit_comp.c and bpf_jit.h is checkpatch clean.

* The following sparse warning is not applicable:
  warning: symbol 'bpf_jit_enable' was not declared. Should it be static?

FUTURE WORK:

1. Implement remaining classes of eBPF instructions: ST|MEM, STX|XADD
   which currently do not have corresponding test cases in test_bpf.

2. Further compiler optimization, such as optimization for small
   immediates.
---
 Documentation/networking/filter.txt |   2 +-
 arch/arm64/Kconfig                  |   1 +
 arch/arm64/Makefile                 |   1 +
 arch/arm64/net/Makefile             |   4 +
 arch/arm64/net/bpf_jit.h            | 169 +++++++++
 arch/arm64/net/bpf_jit_comp.c       | 677 ++++++++++++++++++++++++++++++++++++
 6 files changed, 853 insertions(+), 1 deletion(-)
 create mode 100644 arch/arm64/net/Makefile
 create mode 100644 arch/arm64/net/bpf_jit.h
 create mode 100644 arch/arm64/net/bpf_jit_comp.c

diff --git a/Documentation/networking/filter.txt b/Documentation/networking/filter.txt
index ee78eba..d71e616 100644
--- a/Documentation/networking/filter.txt
+++ b/Documentation/networking/filter.txt
@@ -462,7 +462,7 @@ JIT compiler
 ------------
 
 The Linux kernel has a built-in BPF JIT compiler for x86_64, SPARC, PowerPC,
-ARM and s390 and can be enabled through CONFIG_BPF_JIT. The JIT compiler is
+ARM, ARM64 and s390 and can be enabled through CONFIG_BPF_JIT. The JIT compiler is
 transparently invoked for each attached filter from user space or for internal
 kernel users if it has been previously enabled by root:
 
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index a474de34..b0a4ff8 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -32,6 +32,7 @@ config ARM64
 	select HAVE_ARCH_KGDB
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_C_RECORDMCOUNT
+	select HAVE_BPF_JIT
 	select HAVE_DEBUG_BUGVERBOSE
 	select HAVE_DEBUG_KMEMLEAK
 	select HAVE_DMA_API_DEBUG
diff --git a/arch/arm64/Makefile b/arch/arm64/Makefile
index 8185a91..9820fa7 100644
--- a/arch/arm64/Makefile
+++ b/arch/arm64/Makefile
@@ -43,6 +43,7 @@ TEXT_OFFSET := 0x00080000
 export	TEXT_OFFSET GZFLAGS
 
 core-y		+= arch/arm64/kernel/ arch/arm64/mm/
+core-$(CONFIG_NET) += arch/arm64/net/
 core-$(CONFIG_KVM) += arch/arm64/kvm/
 core-$(CONFIG_XEN) += arch/arm64/xen/
 core-$(CONFIG_CRYPTO) += arch/arm64/crypto/
diff --git a/arch/arm64/net/Makefile b/arch/arm64/net/Makefile
new file mode 100644
index 0000000..da97633
--- /dev/null
+++ b/arch/arm64/net/Makefile
@@ -0,0 +1,4 @@
+#
+# ARM64 networking code
+#
+obj-$(CONFIG_BPF_JIT) += bpf_jit_comp.o
diff --git a/arch/arm64/net/bpf_jit.h b/arch/arm64/net/bpf_jit.h
new file mode 100644
index 0000000..2134f7e
--- /dev/null
+++ b/arch/arm64/net/bpf_jit.h
@@ -0,0 +1,169 @@
+/*
+ * BPF JIT compiler for ARM64
+ *
+ * Copyright (C) 2014 Zi Shen Lim <zlim.lnx@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+#ifndef _BPF_JIT_H
+#define _BPF_JIT_H
+
+#include <asm/insn.h>
+
+/* 5-bit Register Operand */
+#define A64_R(x)	AARCH64_INSN_REG_##x
+#define A64_FP		AARCH64_INSN_REG_FP
+#define A64_LR		AARCH64_INSN_REG_LR
+#define A64_ZR		AARCH64_INSN_REG_ZR
+#define A64_SP		AARCH64_INSN_REG_SP
+
+#define A64_VARIANT(sf) \
+	((sf) ? AARCH64_INSN_VARIANT_64BIT : AARCH64_INSN_VARIANT_32BIT)
+
+/* Compare & branch (immediate) */
+#define A64_COMP_BRANCH(sf, Rt, offset, type) \
+	aarch64_insn_gen_comp_branch_imm(0, offset, Rt, A64_VARIANT(sf), \
+		AARCH64_INSN_BRANCH_COMP_##type)
+#define A64_CBZ(sf, Rt, imm19) A64_COMP_BRANCH(sf, Rt, (imm19) << 2, ZERO)
+
+/* Conditional branch (immediate) */
+#define A64_COND_BRANCH(cond, offset) \
+	aarch64_insn_gen_cond_branch_imm(0, offset, cond)
+#define A64_COND_EQ	AARCH64_INSN_COND_EQ /* == */
+#define A64_COND_NE	AARCH64_INSN_COND_NE /* != */
+#define A64_COND_CS	AARCH64_INSN_COND_CS /* unsigned >= */
+#define A64_COND_HI	AARCH64_INSN_COND_HI /* unsigned > */
+#define A64_COND_GE	AARCH64_INSN_COND_GE /* signed >= */
+#define A64_COND_GT	AARCH64_INSN_COND_GT /* signed > */
+#define A64_B_(cond, imm19) A64_COND_BRANCH(cond, (imm19) << 2)
+
+/* Unconditional branch (immediate) */
+#define A64_BRANCH(offset, type) aarch64_insn_gen_branch_imm(0, offset, \
+	AARCH64_INSN_BRANCH_##type)
+#define A64_B(imm26)  A64_BRANCH((imm26) << 2, NOLINK)
+#define A64_BL(imm26) A64_BRANCH((imm26) << 2, LINK)
+
+/* Unconditional branch (register) */
+#define A64_BLR(Rn) aarch64_insn_gen_branch_reg(Rn, AARCH64_INSN_BRANCH_LINK)
+#define A64_RET(Rn) aarch64_insn_gen_branch_reg(Rn, AARCH64_INSN_BRANCH_RETURN)
+
+/* Load/store register (register offset) */
+#define A64_LS_REG(Rt, Rn, Rm, size, type) \
+	aarch64_insn_gen_load_store_reg(Rt, Rn, Rm, \
+		AARCH64_INSN_SIZE_##size, \
+		AARCH64_INSN_LDST_##type##_REG_OFFSET)
+#define A64_STRB(Wt, Xn, Xm)  A64_LS_REG(Wt, Xn, Xm, 8, STORE)
+#define A64_LDRB(Wt, Xn, Xm)  A64_LS_REG(Wt, Xn, Xm, 8, LOAD)
+#define A64_STRH(Wt, Xn, Xm)  A64_LS_REG(Wt, Xn, Xm, 16, STORE)
+#define A64_LDRH(Wt, Xn, Xm)  A64_LS_REG(Wt, Xn, Xm, 16, LOAD)
+#define A64_STR32(Wt, Xn, Xm) A64_LS_REG(Wt, Xn, Xm, 32, STORE)
+#define A64_LDR32(Wt, Xn, Xm) A64_LS_REG(Wt, Xn, Xm, 32, LOAD)
+#define A64_STR64(Xt, Xn, Xm) A64_LS_REG(Xt, Xn, Xm, 64, STORE)
+#define A64_LDR64(Xt, Xn, Xm) A64_LS_REG(Xt, Xn, Xm, 64, LOAD)
+
+/* Load/store register pair */
+#define A64_LS_PAIR(Rt, Rt2, Rn, offset, ls, type) \
+	aarch64_insn_gen_load_store_pair(Rt, Rt2, Rn, offset, \
+		AARCH64_INSN_VARIANT_64BIT, \
+		AARCH64_INSN_LDST_##ls##_PAIR_##type)
+/* Rn -= 16; Rn[0] = Rt; Rn[8] = Rt2; */
+#define A64_PUSH(Rt, Rt2, Rn) A64_LS_PAIR(Rt, Rt2, Rn, -16, STORE, PRE_INDEX)
+/* Rt = Rn[0]; Rt2 = Rn[8]; Rn += 16; */
+#define A64_POP(Rt, Rt2, Rn)  A64_LS_PAIR(Rt, Rt2, Rn, 16, LOAD, POST_INDEX)
+
+/* Add/subtract (immediate) */
+#define A64_ADDSUB_IMM(sf, Rd, Rn, imm12, type) \
+	aarch64_insn_gen_add_sub_imm(Rd, Rn, imm12, \
+		A64_VARIANT(sf), AARCH64_INSN_ADSB_##type)
+/* Rd = Rn OP imm12 */
+#define A64_ADD_I(sf, Rd, Rn, imm12) A64_ADDSUB_IMM(sf, Rd, Rn, imm12, ADD)
+#define A64_SUB_I(sf, Rd, Rn, imm12) A64_ADDSUB_IMM(sf, Rd, Rn, imm12, SUB)
+/* Rd = Rn */
+#define A64_MOV(sf, Rd, Rn) A64_ADD_I(sf, Rd, Rn, 0)
+
+/* Bitfield move */
+#define A64_BITFIELD(sf, Rd, Rn, immr, imms, type) \
+	aarch64_insn_gen_bitfield(Rd, Rn, immr, imms, \
+		A64_VARIANT(sf), AARCH64_INSN_BITFIELD_MOVE_##type)
+/* Signed, with sign replication to left and zeros to right */
+#define A64_SBFM(sf, Rd, Rn, ir, is) A64_BITFIELD(sf, Rd, Rn, ir, is, SIGNED)
+/* Unsigned, with zeros to left and right */
+#define A64_UBFM(sf, Rd, Rn, ir, is) A64_BITFIELD(sf, Rd, Rn, ir, is, UNSIGNED)
+
+/* Rd = Rn << shift */
+#define A64_LSL(sf, Rd, Rn, shift) ({	\
+	int sz = (sf) ? 64 : 32;	\
+	A64_UBFM(sf, Rd, Rn, (unsigned)-(shift) % sz, sz - 1 - (shift)); \
+})
+/* Rd = Rn >> shift */
+#define A64_LSR(sf, Rd, Rn, shift) A64_UBFM(sf, Rd, Rn, shift, (sf) ? 63 : 31)
+/* Rd = Rn >> shift; signed */
+#define A64_ASR(sf, Rd, Rn, shift) A64_SBFM(sf, Rd, Rn, shift, (sf) ? 63 : 31)
+
+/* Move wide (immediate) */
+#define A64_MOVEW(sf, Rd, imm16, shift, type) \
+	aarch64_insn_gen_movewide(Rd, imm16, shift, \
+		A64_VARIANT(sf), AARCH64_INSN_MOVEWIDE_##type)
+/* Rd = Zeros (for MOVZ);
+ * Rd |= imm16 << shift (where shift is {0, 16, 32, 48});
+ * Rd = ~Rd; (for MOVN); */
+#define A64_MOVN(sf, Rd, imm16, shift) A64_MOVEW(sf, Rd, imm16, shift, INVERSE)
+#define A64_MOVZ(sf, Rd, imm16, shift) A64_MOVEW(sf, Rd, imm16, shift, ZERO)
+#define A64_MOVK(sf, Rd, imm16, shift) A64_MOVEW(sf, Rd, imm16, shift, KEEP)
+
+/* Add/subtract (shifted register) */
+#define A64_ADDSUB_SREG(sf, Rd, Rn, Rm, type) \
+	aarch64_insn_gen_add_sub_shifted_reg(Rd, Rn, Rm, 0, \
+		A64_VARIANT(sf), AARCH64_INSN_ADSB_##type)
+/* Rd = Rn OP Rm */
+#define A64_ADD(sf, Rd, Rn, Rm)  A64_ADDSUB_SREG(sf, Rd, Rn, Rm, ADD)
+#define A64_SUB(sf, Rd, Rn, Rm)  A64_ADDSUB_SREG(sf, Rd, Rn, Rm, SUB)
+#define A64_SUBS(sf, Rd, Rn, Rm) A64_ADDSUB_SREG(sf, Rd, Rn, Rm, SUB_SETFLAGS)
+/* Rd = -Rm */
+#define A64_NEG(sf, Rd, Rm) A64_SUB(sf, Rd, A64_ZR, Rm)
+/* Rn - Rm; set condition flags */
+#define A64_CMP(sf, Rn, Rm) A64_SUBS(sf, A64_ZR, Rn, Rm)
+
+/* Data-processing (1 source) */
+#define A64_DATA1(sf, Rd, Rn, type) aarch64_insn_gen_data1(Rd, Rn, \
+	A64_VARIANT(sf), AARCH64_INSN_DATA1_##type)
+/* Rd = BSWAPx(Rn) */
+#define A64_REV16(sf, Rd, Rn) A64_DATA1(sf, Rd, Rn, REVERSE_16)
+#define A64_REV32(sf, Rd, Rn) A64_DATA1(sf, Rd, Rn, REVERSE_32)
+#define A64_REV64(Rd, Rn)     A64_DATA1(1, Rd, Rn, REVERSE_64)
+
+/* Data-processing (2 source) */
+/* Rd = Rn OP Rm */
+#define A64_UDIV(sf, Rd, Rn, Rm) aarch64_insn_gen_data2(Rd, Rn, Rm, \
+	A64_VARIANT(sf), AARCH64_INSN_DATA2_UDIV)
+
+/* Data-processing (3 source) */
+/* Rd = Ra + Rn * Rm */
+#define A64_MADD(sf, Rd, Ra, Rn, Rm) aarch64_insn_gen_data3(Rd, Ra, Rn, Rm, \
+	A64_VARIANT(sf), AARCH64_INSN_DATA3_MADD)
+/* Rd = Rn * Rm */
+#define A64_MUL(sf, Rd, Rn, Rm) A64_MADD(sf, Rd, A64_ZR, Rn, Rm)
+
+/* Logical (shifted register) */
+#define A64_LOGIC_SREG(sf, Rd, Rn, Rm, type) \
+	aarch64_insn_gen_logical_shifted_reg(Rd, Rn, Rm, 0, \
+		A64_VARIANT(sf), AARCH64_INSN_LOGIC_##type)
+/* Rd = Rn OP Rm */
+#define A64_AND(sf, Rd, Rn, Rm)  A64_LOGIC_SREG(sf, Rd, Rn, Rm, AND)
+#define A64_ORR(sf, Rd, Rn, Rm)  A64_LOGIC_SREG(sf, Rd, Rn, Rm, ORR)
+#define A64_EOR(sf, Rd, Rn, Rm)  A64_LOGIC_SREG(sf, Rd, Rn, Rm, EOR)
+#define A64_ANDS(sf, Rd, Rn, Rm) A64_LOGIC_SREG(sf, Rd, Rn, Rm, AND_SETFLAGS)
+/* Rn & Rm; set condition flags */
+#define A64_TST(sf, Rn, Rm) A64_ANDS(sf, A64_ZR, Rn, Rm)
+
+#endif /* _BPF_JIT_H */
diff --git a/arch/arm64/net/bpf_jit_comp.c b/arch/arm64/net/bpf_jit_comp.c
new file mode 100644
index 0000000..85f318f
--- /dev/null
+++ b/arch/arm64/net/bpf_jit_comp.c
@@ -0,0 +1,677 @@
+/*
+ * BPF JIT compiler for ARM64
+ *
+ * Copyright (C) 2014 Zi Shen Lim <zlim.lnx@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program.  If not, see <http://www.gnu.org/licenses/>.
+ */
+
+#define pr_fmt(fmt) "bpf_jit: " fmt
+
+#include <linux/filter.h>
+#include <linux/moduleloader.h>
+#include <linux/printk.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <asm/byteorder.h>
+#include <asm/cacheflush.h>
+
+#include "bpf_jit.h"
+
+int bpf_jit_enable __read_mostly;
+
+#define TMP_REG_1 (MAX_BPF_REG + 0)
+#define TMP_REG_2 (MAX_BPF_REG + 1)
+
+/* Map BPF registers to A64 registers */
+static const int bpf2a64[] = {
+	/* return value from in-kernel function, and exit value from eBPF */
+	[BPF_REG_0] = A64_R(7),
+	/* arguments from eBPF program to in-kernel function */
+	[BPF_REG_1] = A64_R(0),
+	[BPF_REG_2] = A64_R(1),
+	[BPF_REG_3] = A64_R(2),
+	[BPF_REG_4] = A64_R(3),
+	[BPF_REG_5] = A64_R(4),
+	/* callee saved registers that in-kernel function will preserve */
+	[BPF_REG_6] = A64_R(19),
+	[BPF_REG_7] = A64_R(20),
+	[BPF_REG_8] = A64_R(21),
+	[BPF_REG_9] = A64_R(22),
+	/* read-only frame pointer to access stack */
+	[BPF_REG_FP] = A64_FP,
+	/* temporary register for internal BPF JIT */
+	[TMP_REG_1] = A64_R(23),
+	[TMP_REG_2] = A64_R(24),
+};
+
+struct jit_ctx {
+	const struct sk_filter *prog;
+	int idx;
+	int tmp_used;
+	int body_offset;
+	int *offset;
+	u32 *image;
+};
+
+static inline void emit(const u32 insn, struct jit_ctx *ctx)
+{
+	if (ctx->image != NULL)
+		ctx->image[ctx->idx] = cpu_to_le32(insn);
+
+	ctx->idx++;
+}
+
+static inline void emit_a64_mov_i64(const int reg, const u64 val,
+				    struct jit_ctx *ctx)
+{
+	u64 tmp = val;
+	int shift = 0;
+
+	emit(A64_MOVZ(1, reg, tmp & 0xffff, shift), ctx);
+	tmp >>= 16;
+	shift += 16;
+	while (tmp) {
+		if (tmp & 0xffff)
+			emit(A64_MOVK(1, reg, tmp & 0xffff, shift), ctx);
+		tmp >>= 16;
+		shift += 16;
+	}
+}
+
+static inline void emit_a64_mov_i(const int is64, const int reg,
+				  const s32 val, struct jit_ctx *ctx)
+{
+	u16 hi = val >> 16;
+	u16 lo = val & 0xffff;
+
+	if (hi & 0x8000) {
+		if (hi == 0xffff) {
+			emit(A64_MOVN(is64, reg, (u16)~lo, 0), ctx);
+		} else {
+			emit(A64_MOVN(is64, reg, (u16)~hi, 16), ctx);
+			emit(A64_MOVK(is64, reg, lo, 0), ctx);
+		}
+	} else {
+		emit(A64_MOVZ(is64, reg, lo, 0), ctx);
+		if (hi)
+			emit(A64_MOVK(is64, reg, hi, 16), ctx);
+	}
+}
+
+static inline int bpf2a64_offset(int bpf_to, int bpf_from,
+				 const struct jit_ctx *ctx)
+{
+	int to = ctx->offset[bpf_to + 1];
+	/* -1 to account for the Branch instruction */
+	int from = ctx->offset[bpf_from + 1] - 1;
+
+	return to - from;
+}
+
+static inline int epilogue_offset(const struct jit_ctx *ctx)
+{
+	int to = ctx->offset[ctx->prog->len - 1];
+	int from = ctx->idx - ctx->body_offset;
+
+	return to - from;
+}
+
+/* Stack must be multiples of 16B */
+#define STACK_ALIGN(sz) (((sz) + 15) & ~15)
+
+static void build_prologue(struct jit_ctx *ctx)
+{
+	const u8 r6 = bpf2a64[BPF_REG_6];
+	const u8 r7 = bpf2a64[BPF_REG_7];
+	const u8 r8 = bpf2a64[BPF_REG_8];
+	const u8 r9 = bpf2a64[BPF_REG_9];
+	const u8 fp = bpf2a64[BPF_REG_FP];
+	const u8 ra = bpf2a64[BPF_REG_A];
+	const u8 rx = bpf2a64[BPF_REG_X];
+	const u8 tmp1 = bpf2a64[TMP_REG_1];
+	const u8 tmp2 = bpf2a64[TMP_REG_2];
+	int stack_size = MAX_BPF_STACK;
+
+	stack_size += 4; /* extra for skb_copy_bits buffer */
+	stack_size = STACK_ALIGN(stack_size);
+
+	/* Save callee-saved register */
+	emit(A64_PUSH(r6, r7, A64_SP), ctx);
+	emit(A64_PUSH(r8, r9, A64_SP), ctx);
+	if (ctx->tmp_used)
+		emit(A64_PUSH(tmp1, tmp2, A64_SP), ctx);
+
+	/* Set up BPF stack */
+	emit(A64_SUB_I(1, A64_SP, A64_SP, stack_size), ctx);
+
+	/* Set up frame pointer */
+	emit(A64_MOV(1, fp, A64_SP), ctx);
+
+	/* Clear registers A and X */
+	emit_a64_mov_i64(ra, 0, ctx);
+	emit_a64_mov_i64(rx, 0, ctx);
+}
+
+static void build_epilogue(struct jit_ctx *ctx)
+{
+	const u8 r0 = bpf2a64[BPF_REG_0];
+	const u8 r6 = bpf2a64[BPF_REG_6];
+	const u8 r7 = bpf2a64[BPF_REG_7];
+	const u8 r8 = bpf2a64[BPF_REG_8];
+	const u8 r9 = bpf2a64[BPF_REG_9];
+	const u8 fp = bpf2a64[BPF_REG_FP];
+	const u8 tmp1 = bpf2a64[TMP_REG_1];
+	const u8 tmp2 = bpf2a64[TMP_REG_2];
+	int stack_size = MAX_BPF_STACK;
+
+	stack_size += 4; /* extra for skb_copy_bits buffer */
+	stack_size = STACK_ALIGN(stack_size);
+
+	/* We're done with BPF stack */
+	emit(A64_ADD_I(1, A64_SP, A64_SP, stack_size), ctx);
+
+	/* Restore callee-saved register */
+	if (ctx->tmp_used)
+		emit(A64_POP(tmp1, tmp2, A64_SP), ctx);
+	emit(A64_POP(r8, r9, A64_SP), ctx);
+	emit(A64_POP(r6, r7, A64_SP), ctx);
+
+	/* Restore frame pointer */
+	emit(A64_MOV(1, fp, A64_SP), ctx);
+
+	/* Set return value */
+	emit(A64_MOV(1, A64_R(0), r0), ctx);
+
+	emit(A64_RET(A64_LR), ctx);
+}
+
+static int build_insn(const struct sock_filter_int *insn, struct jit_ctx *ctx)
+{
+	const u8 code = insn->code;
+	const u8 dst = bpf2a64[insn->dst_reg];
+	const u8 src = bpf2a64[insn->src_reg];
+	const u8 tmp = bpf2a64[TMP_REG_1];
+	const u8 tmp2 = bpf2a64[TMP_REG_2];
+	const s16 off = insn->off;
+	const s32 imm = insn->imm;
+	const int i = insn - ctx->prog->insnsi;
+	const bool is64 = BPF_CLASS(code) == BPF_ALU64;
+	u8 jmp_cond;
+	s32 jmp_offset;
+
+	switch (code) {
+	/* dst = src */
+	case BPF_ALU | BPF_MOV | BPF_X:
+	case BPF_ALU64 | BPF_MOV | BPF_X:
+		emit(A64_MOV(is64, dst, src), ctx);
+		break;
+	/* dst = dst OP src */
+	case BPF_ALU | BPF_ADD | BPF_X:
+	case BPF_ALU64 | BPF_ADD | BPF_X:
+		emit(A64_ADD(is64, dst, dst, src), ctx);
+		break;
+	case BPF_ALU | BPF_SUB | BPF_X:
+	case BPF_ALU64 | BPF_SUB | BPF_X:
+		emit(A64_SUB(is64, dst, dst, src), ctx);
+		break;
+	case BPF_ALU | BPF_AND | BPF_X:
+	case BPF_ALU64 | BPF_AND | BPF_X:
+		emit(A64_AND(is64, dst, dst, src), ctx);
+		break;
+	case BPF_ALU | BPF_OR | BPF_X:
+	case BPF_ALU64 | BPF_OR | BPF_X:
+		emit(A64_ORR(is64, dst, dst, src), ctx);
+		break;
+	case BPF_ALU | BPF_XOR | BPF_X:
+	case BPF_ALU64 | BPF_XOR | BPF_X:
+		emit(A64_EOR(is64, dst, dst, src), ctx);
+		break;
+	case BPF_ALU | BPF_MUL | BPF_X:
+	case BPF_ALU64 | BPF_MUL | BPF_X:
+		emit(A64_MUL(is64, dst, dst, src), ctx);
+		break;
+	case BPF_ALU | BPF_DIV | BPF_X:
+	case BPF_ALU64 | BPF_DIV | BPF_X:
+		emit(A64_UDIV(is64, dst, dst, src), ctx);
+		break;
+	case BPF_ALU | BPF_MOD | BPF_X:
+	case BPF_ALU64 | BPF_MOD | BPF_X:
+		ctx->tmp_used = 1;
+		emit(A64_UDIV(is64, tmp, dst, src), ctx);
+		emit(A64_MUL(is64, tmp, tmp, src), ctx);
+		emit(A64_SUB(is64, dst, dst, tmp), ctx);
+		break;
+	/* dst = -dst */
+	case BPF_ALU | BPF_NEG:
+	case BPF_ALU64 | BPF_NEG:
+		emit(A64_NEG(is64, dst, dst), ctx);
+		break;
+	/* dst = BSWAP##imm(dst) */
+	case BPF_ALU | BPF_END | BPF_FROM_LE:
+	case BPF_ALU | BPF_END | BPF_FROM_BE:
+#ifdef CONFIG_CPU_BIG_ENDIAN
+		if (BPF_SRC(code) == BPF_FROM_BE)
+			break;
+#else /* !CONFIG_CPU_BIG_ENDIAN */
+		if (BPF_SRC(code) == BPF_FROM_LE)
+			break;
+#endif
+		switch (imm) {
+		case 16:
+			emit(A64_REV16(is64, dst, dst), ctx);
+			break;
+		case 32:
+			emit(A64_REV32(is64, dst, dst), ctx);
+			break;
+		case 64:
+			emit(A64_REV64(dst, dst), ctx);
+			break;
+		}
+		break;
+	/* dst = imm */
+	case BPF_ALU | BPF_MOV | BPF_K:
+	case BPF_ALU64 | BPF_MOV | BPF_K:
+		emit_a64_mov_i(is64, dst, imm, ctx);
+		break;
+	/* dst = dst OP imm */
+	case BPF_ALU | BPF_ADD | BPF_K:
+	case BPF_ALU64 | BPF_ADD | BPF_K:
+		ctx->tmp_used = 1;
+		emit_a64_mov_i(is64, tmp, imm, ctx);
+		emit(A64_ADD(is64, dst, dst, tmp), ctx);
+		break;
+	case BPF_ALU | BPF_SUB | BPF_K:
+	case BPF_ALU64 | BPF_SUB | BPF_K:
+		ctx->tmp_used = 1;
+		emit_a64_mov_i(is64, tmp, imm, ctx);
+		emit(A64_SUB(is64, dst, dst, tmp), ctx);
+		break;
+	case BPF_ALU | BPF_AND | BPF_K:
+	case BPF_ALU64 | BPF_AND | BPF_K:
+		ctx->tmp_used = 1;
+		emit_a64_mov_i(is64, tmp, imm, ctx);
+		emit(A64_AND(is64, dst, dst, tmp), ctx);
+		break;
+	case BPF_ALU | BPF_OR | BPF_K:
+	case BPF_ALU64 | BPF_OR | BPF_K:
+		ctx->tmp_used = 1;
+		emit_a64_mov_i(is64, tmp, imm, ctx);
+		emit(A64_ORR(is64, dst, dst, tmp), ctx);
+		break;
+	case BPF_ALU | BPF_XOR | BPF_K:
+	case BPF_ALU64 | BPF_XOR | BPF_K:
+		ctx->tmp_used = 1;
+		emit_a64_mov_i(is64, tmp, imm, ctx);
+		emit(A64_EOR(is64, dst, dst, tmp), ctx);
+		break;
+	case BPF_ALU | BPF_MUL | BPF_K:
+	case BPF_ALU64 | BPF_MUL | BPF_K:
+		ctx->tmp_used = 1;
+		emit_a64_mov_i(is64, tmp, imm, ctx);
+		emit(A64_MUL(is64, dst, dst, tmp), ctx);
+		break;
+	case BPF_ALU | BPF_DIV | BPF_K:
+	case BPF_ALU64 | BPF_DIV | BPF_K:
+		ctx->tmp_used = 1;
+		emit_a64_mov_i(is64, tmp, imm, ctx);
+		emit(A64_UDIV(is64, dst, dst, tmp), ctx);
+		break;
+	case BPF_ALU | BPF_MOD | BPF_K:
+	case BPF_ALU64 | BPF_MOD | BPF_K:
+		ctx->tmp_used = 1;
+		emit_a64_mov_i(is64, tmp2, imm, ctx);
+		emit(A64_UDIV(is64, tmp, dst, tmp2), ctx);
+		emit(A64_MUL(is64, tmp, tmp, tmp2), ctx);
+		emit(A64_SUB(is64, dst, dst, tmp), ctx);
+		break;
+	case BPF_ALU | BPF_LSH | BPF_K:
+	case BPF_ALU64 | BPF_LSH | BPF_K:
+		emit(A64_LSL(is64, dst, dst, imm), ctx);
+		break;
+	case BPF_ALU | BPF_RSH | BPF_K:
+	case BPF_ALU64 | BPF_RSH | BPF_K:
+		emit(A64_LSR(is64, dst, dst, imm), ctx);
+		break;
+	case BPF_ALU | BPF_ARSH | BPF_K:
+	case BPF_ALU64 | BPF_ARSH | BPF_K:
+		emit(A64_ASR(is64, dst, dst, imm), ctx);
+		break;
+
+#define check_imm(bits, imm) do {				\
+	if ((((imm) > 0) && ((imm) >> (bits))) ||		\
+	    (((imm) < 0) && (~(imm) >> (bits)))) {		\
+		pr_info("[%2d] imm=%d(0x%x) out of range\n",	\
+			i, imm, imm);				\
+		return -EINVAL;					\
+	}							\
+} while (0)
+#define check_imm19(imm) check_imm(19, imm)
+#define check_imm26(imm) check_imm(26, imm)
+
+	/* JUMP off */
+	case BPF_JMP | BPF_JA:
+		jmp_offset = bpf2a64_offset(i + off, i, ctx);
+		check_imm26(jmp_offset);
+		emit(A64_B(jmp_offset), ctx);
+		break;
+	/* IF (dst COND src) JUMP off */
+	case BPF_JMP | BPF_JEQ | BPF_X:
+	case BPF_JMP | BPF_JGT | BPF_X:
+	case BPF_JMP | BPF_JGE | BPF_X:
+	case BPF_JMP | BPF_JNE | BPF_X:
+	case BPF_JMP | BPF_JSGT | BPF_X:
+	case BPF_JMP | BPF_JSGE | BPF_X:
+		emit(A64_CMP(1, dst, src), ctx);
+emit_cond_jmp:
+		jmp_offset = bpf2a64_offset(i + off, i, ctx);
+		check_imm19(jmp_offset);
+		switch (BPF_OP(code)) {
+		case BPF_JEQ:
+			jmp_cond = A64_COND_EQ;
+			break;
+		case BPF_JGT:
+			jmp_cond = A64_COND_HI;
+			break;
+		case BPF_JGE:
+			jmp_cond = A64_COND_CS;
+			break;
+		case BPF_JNE:
+			jmp_cond = A64_COND_NE;
+			break;
+		case BPF_JSGT:
+			jmp_cond = A64_COND_GT;
+			break;
+		case BPF_JSGE:
+			jmp_cond = A64_COND_GE;
+			break;
+		default:
+			return -EFAULT;
+		}
+		emit(A64_B_(jmp_cond, jmp_offset), ctx);
+		break;
+	case BPF_JMP | BPF_JSET | BPF_X:
+		emit(A64_TST(1, dst, src), ctx);
+		goto emit_cond_jmp;
+	/* IF (dst COND imm) JUMP off */
+	case BPF_JMP | BPF_JEQ | BPF_K:
+	case BPF_JMP | BPF_JGT | BPF_K:
+	case BPF_JMP | BPF_JGE | BPF_K:
+	case BPF_JMP | BPF_JNE | BPF_K:
+	case BPF_JMP | BPF_JSGT | BPF_K:
+	case BPF_JMP | BPF_JSGE | BPF_K:
+		ctx->tmp_used = 1;
+		emit_a64_mov_i(1, tmp, imm, ctx);
+		emit(A64_CMP(1, dst, tmp), ctx);
+		goto emit_cond_jmp;
+	case BPF_JMP | BPF_JSET | BPF_K:
+		ctx->tmp_used = 1;
+		emit_a64_mov_i(1, tmp, imm, ctx);
+		emit(A64_TST(1, dst, tmp), ctx);
+		goto emit_cond_jmp;
+	/* function call */
+	case BPF_JMP | BPF_CALL:
+	{
+		const u8 r0 = bpf2a64[BPF_REG_0];
+		const u64 func = (u64)__bpf_call_base + imm;
+
+		ctx->tmp_used = 1;
+		emit_a64_mov_i64(tmp, func, ctx);
+		emit(A64_PUSH(A64_FP, A64_LR, A64_SP), ctx);
+		emit(A64_MOV(1, A64_FP, A64_SP), ctx);
+		emit(A64_BLR(tmp), ctx);
+		emit(A64_MOV(1, r0, A64_R(0)), ctx);
+		emit(A64_POP(A64_FP, A64_LR, A64_SP), ctx);
+		break;
+	}
+	/* function return */
+	case BPF_JMP | BPF_EXIT:
+		if (i == ctx->prog->len - 1)
+			break;
+		jmp_offset = epilogue_offset(ctx);
+		check_imm26(jmp_offset);
+		emit(A64_B(jmp_offset), ctx);
+		break;
+
+	/* LDX: dst = *(size *)(src + off) */
+	case BPF_LDX | BPF_MEM | BPF_W:
+	case BPF_LDX | BPF_MEM | BPF_H:
+	case BPF_LDX | BPF_MEM | BPF_B:
+	case BPF_LDX | BPF_MEM | BPF_DW:
+		ctx->tmp_used = 1;
+		emit_a64_mov_i(1, tmp, off, ctx);
+		switch (BPF_SIZE(code)) {
+		case BPF_W:
+			emit(A64_LDR32(dst, src, tmp), ctx);
+			break;
+		case BPF_H:
+			emit(A64_LDRH(dst, src, tmp), ctx);
+			break;
+		case BPF_B:
+			emit(A64_LDRB(dst, src, tmp), ctx);
+			break;
+		case BPF_DW:
+			emit(A64_LDR64(dst, src, tmp), ctx);
+			break;
+		}
+		break;
+
+	/* ST: *(size *)(dst + off) = imm */
+	case BPF_ST | BPF_MEM | BPF_W:
+	case BPF_ST | BPF_MEM | BPF_H:
+	case BPF_ST | BPF_MEM | BPF_B:
+	case BPF_ST | BPF_MEM | BPF_DW:
+		goto notyet;
+
+	/* STX: *(size *)(dst + off) = src */
+	case BPF_STX | BPF_MEM | BPF_W:
+	case BPF_STX | BPF_MEM | BPF_H:
+	case BPF_STX | BPF_MEM | BPF_B:
+	case BPF_STX | BPF_MEM | BPF_DW:
+		ctx->tmp_used = 1;
+		emit_a64_mov_i(1, tmp, off, ctx);
+		switch (BPF_SIZE(code)) {
+		case BPF_W:
+			emit(A64_STR32(src, dst, tmp), ctx);
+			break;
+		case BPF_H:
+			emit(A64_STRH(src, dst, tmp), ctx);
+			break;
+		case BPF_B:
+			emit(A64_STRB(src, dst, tmp), ctx);
+			break;
+		case BPF_DW:
+			emit(A64_STR64(src, dst, tmp), ctx);
+			break;
+		}
+		break;
+	/* STX XADD: lock *(u32 *)(dst + off) += src */
+	case BPF_STX | BPF_XADD | BPF_W:
+	/* STX XADD: lock *(u64 *)(dst + off) += src */
+	case BPF_STX | BPF_XADD | BPF_DW:
+		goto notyet;
+
+	/* R0 = ntohx(*(size *)(((struct sk_buff *)R6)->data + imm)) */
+	case BPF_LD | BPF_ABS | BPF_W:
+	case BPF_LD | BPF_ABS | BPF_H:
+	case BPF_LD | BPF_ABS | BPF_B:
+	/* R0 = ntohx(*(size *)(((struct sk_buff *)R6)->data + src + imm)) */
+	case BPF_LD | BPF_IND | BPF_W:
+	case BPF_LD | BPF_IND | BPF_H:
+	case BPF_LD | BPF_IND | BPF_B:
+	{
+		const u8 r0 = bpf2a64[BPF_REG_0]; /* r0 = return value */
+		const u8 r6 = bpf2a64[BPF_REG_6]; /* r6 = pointer to sk_buff */
+		const u8 fp = bpf2a64[BPF_REG_FP];
+		const u8 r1 = bpf2a64[BPF_REG_1]; /* r1: struct sk_buff *skb */
+		const u8 r2 = bpf2a64[BPF_REG_2]; /* r2: int k */
+		const u8 r3 = bpf2a64[BPF_REG_3]; /* r3: unsigned int size */
+		const u8 r4 = bpf2a64[BPF_REG_4]; /* r4: void *buffer */
+		const u8 r5 = bpf2a64[BPF_REG_5]; /* r5: void *(*func)(...) */
+		int size;
+
+		emit(A64_MOV(1, r1, r6), ctx);
+		emit_a64_mov_i(0, r2, imm, ctx);
+		if (BPF_MODE(code) == BPF_IND)
+			emit(A64_ADD(0, r2, r2, src), ctx);
+		switch (BPF_SIZE(code)) {
+		case BPF_W:
+			size = 4;
+			break;
+		case BPF_H:
+			size = 2;
+			break;
+		case BPF_B:
+			size = 1;
+			break;
+		default:
+			return -EINVAL;
+		}
+		emit_a64_mov_i64(r3, size, ctx);
+		emit(A64_ADD_I(1, r4, fp, MAX_BPF_STACK), ctx);
+		emit_a64_mov_i64(r5, (unsigned long)bpf_load_pointer, ctx);
+		emit(A64_PUSH(A64_FP, A64_LR, A64_SP), ctx);
+		emit(A64_MOV(1, A64_FP, A64_SP), ctx);
+		emit(A64_BLR(r5), ctx);
+		emit(A64_MOV(1, r0, A64_R(0)), ctx);
+		emit(A64_POP(A64_FP, A64_LR, A64_SP), ctx);
+
+		jmp_offset = epilogue_offset(ctx);
+		check_imm19(jmp_offset);
+		emit(A64_CBZ(1, r0, jmp_offset), ctx);
+		emit(A64_MOV(1, r5, r0), ctx);
+		switch (BPF_SIZE(code)) {
+		case BPF_W:
+			emit(A64_LDR32(r0, r5, A64_ZR), ctx);
+#ifndef CONFIG_CPU_BIG_ENDIAN
+			emit(A64_REV32(0, r0, r0), ctx);
+#endif
+			break;
+		case BPF_H:
+			emit(A64_LDRH(r0, r5, A64_ZR), ctx);
+#ifndef CONFIG_CPU_BIG_ENDIAN
+			emit(A64_REV16(0, r0, r0), ctx);
+#endif
+			break;
+		case BPF_B:
+			emit(A64_LDRB(r0, r5, A64_ZR), ctx);
+			break;
+		}
+		break;
+	}
+notyet:
+		pr_info_once("*** NOT YET: opcode %02x ***\n", code);
+		return -EFAULT;
+
+	default:
+		pr_err_once("unknown opcode %02x\n", code);
+		return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int build_body(struct jit_ctx *ctx)
+{
+	const struct sk_filter *prog = ctx->prog;
+	int i;
+
+	for (i = 0; i < prog->len; i++) {
+		const struct sock_filter_int *insn = &prog->insnsi[i];
+		int ret;
+
+		if (ctx->image == NULL)
+			ctx->offset[i] = ctx->idx;
+
+		ret = build_insn(insn, ctx);
+		if (ret)
+			return ret;
+	}
+
+	return 0;
+}
+
+static inline void bpf_flush_icache(void *start, void *end)
+{
+	flush_icache_range((unsigned long)start, (unsigned long)end);
+}
+
+void bpf_jit_compile(struct sk_filter *prog)
+{
+	/* Nothing to do here. We support Internal BPF. */
+}
+
+void bpf_int_jit_compile(struct sk_filter *prog)
+{
+	struct jit_ctx ctx;
+	int image_size;
+
+	if (!bpf_jit_enable)
+		return;
+
+	if (!prog || !prog->len)
+		return;
+
+	memset(&ctx, 0, sizeof(ctx));
+	ctx.prog = prog;
+
+	ctx.offset = kcalloc(prog->len, sizeof(int), GFP_KERNEL);
+	if (ctx.offset == NULL)
+		return;
+
+	/* 1. Initial fake pass to compute ctx->idx. */
+
+	/* Fake pass to fill in ctx->offset. */
+	if (build_body(&ctx))
+		goto out;
+
+	build_prologue(&ctx);
+
+	build_epilogue(&ctx);
+
+	/* Now we know the actual image size. */
+	image_size = sizeof(u32) * ctx.idx;
+	ctx.image = module_alloc(image_size);
+	if (unlikely(ctx.image == NULL))
+		goto out;
+
+	/* 2. Now, the actual pass. */
+
+	ctx.idx = 0;
+	build_prologue(&ctx);
+
+	ctx.body_offset = ctx.idx;
+	if (build_body(&ctx))
+		goto out;
+
+	build_epilogue(&ctx);
+
+	/* And we're done. */
+	if (bpf_jit_enable > 1)
+		bpf_jit_dump(prog->len, image_size, 2, ctx.image);
+
+	bpf_flush_icache(ctx.image, ctx.image + ctx.idx);
+	prog->bpf_func = (void *)ctx.image;
+	prog->jited = 1;
+
+out:
+	kfree(ctx.offset);
+}
+
+void bpf_jit_free(struct sk_filter *prog)
+{
+	if (prog->jited)
+		module_free(NULL, prog->bpf_func);
+
+	kfree(prog);
+}
-- 
1.9.1
