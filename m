From: Shubham Bansal <illusionist.neo@gmail.com>
Subject: [PATCH v4 net-next] arm: eBPF JIT compiler
Date: Tue, 22 Aug 2017 12:06:12 +0530
Message-ID: <1503383772-5788-1-git-send-email-illusionist.neo@gmail.com>
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org,
        keescook@chromium.org, Shubham Bansal <illusionist.neo@gmail.com>
To: linux@armlinux.org.uk, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The JIT compiler emits ARM 32 bit instructions. Currently, It supports
eBPF only. Classic BPF is supported because of the conversion by BPF core.

This patch is essentially changing the current implementation of JIT compiler
of Berkeley Packet Filter from classic to internal with almost all
instructions from eBPF ISA supported except the following
	BPF_ALU64 | BPF_DIV | BPF_K
	BPF_ALU64 | BPF_DIV | BPF_X
	BPF_ALU64 | BPF_MOD | BPF_K
	BPF_ALU64 | BPF_MOD | BPF_X
	BPF_STX | BPF_XADD | BPF_W
	BPF_STX | BPF_XADD | BPF_DW

Implementation is using scratch space to emulate 64 bit eBPF ISA on 32 bit
ARM because of deficiency of general purpose registers on ARM. Currently,
only LITTLE ENDIAN machines are supported in this eBPF JIT Compiler.

Tested on ARMv7 with QEMU by me (Shubham Bansal).

Testing results on ARMv7:

1) test_bpf: Summary: 341 PASSED, 0 FAILED, [312/333 JIT'ed]
2) test_tag: OK (40945 tests)
3) test_progs: Summary: 30 PASSED, 0 FAILED
4) test_lpm: OK
5) test_lru_map: OK

Above tests are all done with following flags enabled discreatly.

1) bpf_jit_enable=1
	a) CONFIG_FRAME_POINTER enabled
	b) CONFIG_FRAME_POINTER disabled
2) bpf_jit_enable=1 and bpf_jit_harden=2
	a) CONFIG_FRAME_POINTER enabled
	b) CONFIG_FRAME_POINTER disabled

See Documentation/networking/filter.txt for more information.

Signed-off-by: Shubham Bansal <illusionist.neo@gmail.com>
---
v2
- Solved many bugs for ARMv5 and ARMv6 support.

v3
- Implemented BPF_JMP | BPF_CALL.
- Changed tail call opcode to BPF_JMP | BPF_TAIL_CALL.
- Filled prog->jited_len value.
- Implemented BPF_JLT, BPF_JLE, BPF_JSLT, BPF_JSLE.
- Solved many bugs noticed by bpf selftests.

v4
- Proper ENDIANNESS handling in kconfig.
- Changed alignment from 16 bytes to 4 bytes.
- Setup ctx->stack_size for optimization.
- Removed unnecessary bpf_jit_free from the JIT compiler.
---
 arch/arm/Kconfig          |    2 +-
 arch/arm/net/bpf_jit_32.c | 2448 ++++++++++++++++++++++++++++++---------------
 arch/arm/net/bpf_jit_32.h |  108 +-
 3 files changed, 1747 insertions(+), 811 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 61a0cb1..f1b3f1d 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -50,7 +50,7 @@ config ARM
 	select HAVE_ARCH_SECCOMP_FILTER if (AEABI && !OABI_COMPAT)
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_ARM_SMCCC if CPU_V7
-	select HAVE_CBPF_JIT
+	select HAVE_EBPF_JIT if !CPU_ENDIAN_BE32
 	select HAVE_CC_STACKPROTECTOR
 	select HAVE_CONTEXT_TRACKING
 	select HAVE_C_RECORDMCOUNT
diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
index d5b9fa1..c199990 100644
--- a/arch/arm/net/bpf_jit_32.c
+++ b/arch/arm/net/bpf_jit_32.c
@@ -1,6 +1,7 @@
 /*
- * Just-In-Time compiler for BPF filters on 32bit ARM
+ * Just-In-Time compiler for eBPF filters on 32bit ARM
  *
+ * Copyright (c) 2017 Shubham Bansal <illusionist.neo@gmail.com>
  * Copyright (c) 2011 Mircea Gherzan <mgherzan@gmail.com>
  *
  * This program is free software; you can redistribute it and/or modify it
@@ -8,6 +9,7 @@
  * Free Software Foundation; version 2 of the License.
  */
 
+#include <linux/bpf.h>
 #include <linux/bitops.h>
 #include <linux/compiler.h>
 #include <linux/errno.h>
@@ -18,54 +20,101 @@
 #include <linux/if_vlan.h>
 
 #include <asm/cacheflush.h>
-#include <asm/set_memory.h>
 #include <asm/hwcap.h>
 #include <asm/opcodes.h>
 
 #include "bpf_jit_32.h"
 
+int bpf_jit_enable __read_mostly;
+
+#define STACK_OFFSET(k)	(k)
+#define TMP_REG_1	(MAX_BPF_JIT_REG + 0)	/* TEMP Register 1 */
+#define TMP_REG_2	(MAX_BPF_JIT_REG + 1)	/* TEMP Register 2 */
+#define TCALL_CNT	(MAX_BPF_JIT_REG + 2)	/* Tail Call Count */
+
+/* Flags used for JIT optimization */
+#define SEEN_CALL	(1 << 0)
+
+#define FLAG_IMM_OVERFLOW	(1 << 0)
+
 /*
- * ABI:
+ * Map eBPF registers to ARM 32bit registers or stack scratch space.
+ *
+ * 1. First argument is passed using the arm 32bit registers and rest of the
+ * arguments are passed on stack scratch space.
+ * 2. First callee-saved arugument is mapped to arm 32 bit registers and rest
+ * arguments are mapped to scratch space on stack.
+ * 3. We need two 64 bit temp registers to do complex operations on eBPF
+ * registers.
+ *
+ * As the eBPF registers are all 64 bit registers and arm has only 32 bit
+ * registers, we have to map each eBPF registers with two arm 32 bit regs or
+ * scratch memory space and we have to build eBPF 64 bit register from those.
  *
- * r0	scratch register
- * r4	BPF register A
- * r5	BPF register X
- * r6	pointer to the skb
- * r7	skb->data
- * r8	skb_headlen(skb)
  */
+static const u8 bpf2a32[][2] = {
+	/* return value from in-kernel function, and exit value from eBPF */
+	[BPF_REG_0] = {ARM_R1, ARM_R0},
+	/* arguments from eBPF program to in-kernel function */
+	[BPF_REG_1] = {ARM_R3, ARM_R2},
+	/* Stored on stack scratch space */
+	[BPF_REG_2] = {STACK_OFFSET(0), STACK_OFFSET(4)},
+	[BPF_REG_3] = {STACK_OFFSET(8), STACK_OFFSET(12)},
+	[BPF_REG_4] = {STACK_OFFSET(16), STACK_OFFSET(20)},
+	[BPF_REG_5] = {STACK_OFFSET(24), STACK_OFFSET(28)},
+	/* callee saved registers that in-kernel function will preserve */
+	[BPF_REG_6] = {ARM_R5, ARM_R4},
+	/* Stored on stack scratch space */
+	[BPF_REG_7] = {STACK_OFFSET(32), STACK_OFFSET(36)},
+	[BPF_REG_8] = {STACK_OFFSET(40), STACK_OFFSET(44)},
+	[BPF_REG_9] = {STACK_OFFSET(48), STACK_OFFSET(52)},
+	/* Read only Frame Pointer to access Stack */
+	[BPF_REG_FP] = {STACK_OFFSET(56), STACK_OFFSET(60)},
+	/* Temporary Register for internal BPF JIT, can be used
+	 * for constant blindings and others.
+	 */
+	[TMP_REG_1] = {ARM_R7, ARM_R6},
+	[TMP_REG_2] = {ARM_R10, ARM_R8},
+	/* Tail call count. Stored on stack scratch space. */
+	[TCALL_CNT] = {STACK_OFFSET(64), STACK_OFFSET(68)},
+	/* temporary register for blinding constants.
+	 * Stored on stack scratch space.
+	 */
+	[BPF_REG_AX] = {STACK_OFFSET(72), STACK_OFFSET(76)},
+};
 
-#define r_scratch	ARM_R0
-/* r1-r3 are (also) used for the unaligned loads on the non-ARMv7 slowpath */
-#define r_off		ARM_R1
-#define r_A		ARM_R4
-#define r_X		ARM_R5
-#define r_skb		ARM_R6
-#define r_skb_data	ARM_R7
-#define r_skb_hl	ARM_R8
-
-#define SCRATCH_SP_OFFSET	0
-#define SCRATCH_OFF(k)		(SCRATCH_SP_OFFSET + 4 * (k))
-
-#define SEEN_MEM		((1 << BPF_MEMWORDS) - 1)
-#define SEEN_MEM_WORD(k)	(1 << (k))
-#define SEEN_X			(1 << BPF_MEMWORDS)
-#define SEEN_CALL		(1 << (BPF_MEMWORDS + 1))
-#define SEEN_SKB		(1 << (BPF_MEMWORDS + 2))
-#define SEEN_DATA		(1 << (BPF_MEMWORDS + 3))
+#define	dst_lo	dst[1]
+#define dst_hi	dst[0]
+#define src_lo	src[1]
+#define src_hi	src[0]
 
-#define FLAG_NEED_X_RESET	(1 << 0)
-#define FLAG_IMM_OVERFLOW	(1 << 1)
+/*
+ * JIT Context:
+ *
+ * prog			:	bpf_prog
+ * idx			:	index of current last JITed instruction.
+ * prologue_bytes	:	bytes used in prologue.
+ * epilogue_offset	:	offset of epilogue starting.
+ * seen			:	bit mask used for JIT optimization.
+ * offsets		:	array of eBPF instruction offsets in
+ *				JITed code.
+ * target		:	final JITed code.
+ * epilogue_bytes	:	no of bytes used in epilogue.
+ * imm_count		:	no of immediate counts used for global
+ *				variables.
+ * imms			:	array of global variable addresses.
+ */
 
 struct jit_ctx {
-	const struct bpf_prog *skf;
-	unsigned idx;
-	unsigned prologue_bytes;
-	int ret0_fp_idx;
+	const struct bpf_prog *prog;
+	unsigned int idx;
+	unsigned int prologue_bytes;
+	unsigned int epilogue_offset;
 	u32 seen;
 	u32 flags;
 	u32 *offsets;
 	u32 *target;
+	u32 stack_size;
 #if __LINUX_ARM_ARCH__ < 7
 	u16 epilogue_bytes;
 	u16 imm_count;
@@ -73,68 +122,16 @@ struct jit_ctx {
 #endif
 };
 
-int bpf_jit_enable __read_mostly;
-
-static inline int call_neg_helper(struct sk_buff *skb, int offset, void *ret,
-		      unsigned int size)
-{
-	void *ptr = bpf_internal_load_pointer_neg_helper(skb, offset, size);
-
-	if (!ptr)
-		return -EFAULT;
-	memcpy(ret, ptr, size);
-	return 0;
-}
-
-static u64 jit_get_skb_b(struct sk_buff *skb, int offset)
-{
-	u8 ret;
-	int err;
-
-	if (offset < 0)
-		err = call_neg_helper(skb, offset, &ret, 1);
-	else
-		err = skb_copy_bits(skb, offset, &ret, 1);
-
-	return (u64)err << 32 | ret;
-}
-
-static u64 jit_get_skb_h(struct sk_buff *skb, int offset)
-{
-	u16 ret;
-	int err;
-
-	if (offset < 0)
-		err = call_neg_helper(skb, offset, &ret, 2);
-	else
-		err = skb_copy_bits(skb, offset, &ret, 2);
-
-	return (u64)err << 32 | ntohs(ret);
-}
-
-static u64 jit_get_skb_w(struct sk_buff *skb, int offset)
-{
-	u32 ret;
-	int err;
-
-	if (offset < 0)
-		err = call_neg_helper(skb, offset, &ret, 4);
-	else
-		err = skb_copy_bits(skb, offset, &ret, 4);
-
-	return (u64)err << 32 | ntohl(ret);
-}
-
 /*
  * Wrappers which handle both OABI and EABI and assures Thumb2 interworking
  * (where the assembly routines like __aeabi_uidiv could cause problems).
  */
-static u32 jit_udiv(u32 dividend, u32 divisor)
+static u32 jit_udiv32(u32 dividend, u32 divisor)
 {
 	return dividend / divisor;
 }
 
-static u32 jit_mod(u32 dividend, u32 divisor)
+static u32 jit_mod32(u32 dividend, u32 divisor)
 {
 	return dividend % divisor;
 }
@@ -158,36 +155,22 @@ static inline void emit(u32 inst, struct jit_ctx *ctx)
 	_emit(ARM_COND_AL, inst, ctx);
 }
 
-static u16 saved_regs(struct jit_ctx *ctx)
+/*
+ * Checks if immediate value can be converted to imm12(12 bits) value.
+ */
+static int16_t imm8m(u32 x)
 {
-	u16 ret = 0;
-
-	if ((ctx->skf->len > 1) ||
-	    (ctx->skf->insns[0].code == (BPF_RET | BPF_A)))
-		ret |= 1 << r_A;
-
-#ifdef CONFIG_FRAME_POINTER
-	ret |= (1 << ARM_FP) | (1 << ARM_IP) | (1 << ARM_LR) | (1 << ARM_PC);
-#else
-	if (ctx->seen & SEEN_CALL)
-		ret |= 1 << ARM_LR;
-#endif
-	if (ctx->seen & (SEEN_DATA | SEEN_SKB))
-		ret |= 1 << r_skb;
-	if (ctx->seen & SEEN_DATA)
-		ret |= (1 << r_skb_data) | (1 << r_skb_hl);
-	if (ctx->seen & SEEN_X)
-		ret |= 1 << r_X;
-
-	return ret;
-}
+	u32 rot;
 
-static inline int mem_words_used(struct jit_ctx *ctx)
-{
-	/* yes, we do waste some stack space IF there are "holes" in the set" */
-	return fls(ctx->seen & SEEN_MEM);
+	for (rot = 0; rot < 16; rot++)
+		if ((x & ~ror32(0xff, 2 * rot)) == 0)
+			return rol32(x, 2 * rot) | (rot << 8);
+	return -1;
 }
 
+/*
+ * Initializes the JIT space with undefined instructions.
+ */
 static void jit_fill_hole(void *area, unsigned int size)
 {
 	u32 *ptr;
@@ -196,88 +179,34 @@ static void jit_fill_hole(void *area, unsigned int size)
 		*ptr++ = __opcode_to_mem_arm(ARM_INST_UDF);
 }
 
-static void build_prologue(struct jit_ctx *ctx)
-{
-	u16 reg_set = saved_regs(ctx);
-	u16 off;
-
-#ifdef CONFIG_FRAME_POINTER
-	emit(ARM_MOV_R(ARM_IP, ARM_SP), ctx);
-	emit(ARM_PUSH(reg_set), ctx);
-	emit(ARM_SUB_I(ARM_FP, ARM_IP, 4), ctx);
-#else
-	if (reg_set)
-		emit(ARM_PUSH(reg_set), ctx);
-#endif
-
-	if (ctx->seen & (SEEN_DATA | SEEN_SKB))
-		emit(ARM_MOV_R(r_skb, ARM_R0), ctx);
-
-	if (ctx->seen & SEEN_DATA) {
-		off = offsetof(struct sk_buff, data);
-		emit(ARM_LDR_I(r_skb_data, r_skb, off), ctx);
-		/* headlen = len - data_len */
-		off = offsetof(struct sk_buff, len);
-		emit(ARM_LDR_I(r_skb_hl, r_skb, off), ctx);
-		off = offsetof(struct sk_buff, data_len);
-		emit(ARM_LDR_I(r_scratch, r_skb, off), ctx);
-		emit(ARM_SUB_R(r_skb_hl, r_skb_hl, r_scratch), ctx);
-	}
-
-	if (ctx->flags & FLAG_NEED_X_RESET)
-		emit(ARM_MOV_I(r_X, 0), ctx);
-
-	/* do not leak kernel data to userspace */
-	if (bpf_needs_clear_a(&ctx->skf->insns[0]))
-		emit(ARM_MOV_I(r_A, 0), ctx);
-
-	/* stack space for the BPF_MEM words */
-	if (ctx->seen & SEEN_MEM)
-		emit(ARM_SUB_I(ARM_SP, ARM_SP, mem_words_used(ctx) * 4), ctx);
-}
-
-static void build_epilogue(struct jit_ctx *ctx)
-{
-	u16 reg_set = saved_regs(ctx);
-
-	if (ctx->seen & SEEN_MEM)
-		emit(ARM_ADD_I(ARM_SP, ARM_SP, mem_words_used(ctx) * 4), ctx);
-
-	reg_set &= ~(1 << ARM_LR);
+/* Stack must be multiples of 16 Bytes */
+#define STACK_ALIGN(sz) (((sz) + 3) & ~3)
 
-#ifdef CONFIG_FRAME_POINTER
-	/* the first instruction of the prologue was: mov ip, sp */
-	reg_set &= ~(1 << ARM_IP);
-	reg_set |= (1 << ARM_SP);
-	emit(ARM_LDM(ARM_SP, reg_set), ctx);
-#else
-	if (reg_set) {
-		if (ctx->seen & SEEN_CALL)
-			reg_set |= 1 << ARM_PC;
-		emit(ARM_POP(reg_set), ctx);
-	}
+/* Stack space for BPF_REG_2, BPF_REG_3, BPF_REG_4,
+ * BPF_REG_5, BPF_REG_7, BPF_REG_8, BPF_REG_9,
+ * BPF_REG_FP and Tail call counts.
+ */
+#define SCRATCH_SIZE 80
 
-	if (!(ctx->seen & SEEN_CALL))
-		emit(ARM_BX(ARM_LR), ctx);
-#endif
-}
+/* total stack size used in JITed code */
+#define _STACK_SIZE \
+	(ctx->prog->aux->stack_depth + \
+	 + SCRATCH_SIZE + \
+	 + 4 /* extra for skb_copy_bits buffer */)
 
-static int16_t imm8m(u32 x)
-{
-	u32 rot;
+#define STACK_SIZE STACK_ALIGN(_STACK_SIZE)
 
-	for (rot = 0; rot < 16; rot++)
-		if ((x & ~ror32(0xff, 2 * rot)) == 0)
-			return rol32(x, 2 * rot) | (rot << 8);
+/* Get the offset of eBPF REGISTERs stored on scratch space. */
+#define STACK_VAR(off) (STACK_SIZE-off-4)
 
-	return -1;
-}
+/* Offset of skb_copy_bits buffer */
+#define SKB_BUFFER STACK_VAR(SCRATCH_SIZE)
 
 #if __LINUX_ARM_ARCH__ < 7
 
 static u16 imm_offset(u32 k, struct jit_ctx *ctx)
 {
-	unsigned i = 0, offset;
+	unsigned int i = 0, offset;
 	u16 imm;
 
 	/* on the "fake" run we just count them (duplicates included) */
@@ -296,7 +225,7 @@ static u16 imm_offset(u32 k, struct jit_ctx *ctx)
 		ctx->imms[i] = k;
 
 	/* constants go just after the epilogue */
-	offset =  ctx->offsets[ctx->skf->len];
+	offset =  ctx->offsets[ctx->prog->len - 1] * 4;
 	offset += ctx->prologue_bytes;
 	offset += ctx->epilogue_bytes;
 	offset += i * 4;
@@ -320,10 +249,22 @@ static u16 imm_offset(u32 k, struct jit_ctx *ctx)
 
 #endif /* __LINUX_ARM_ARCH__ */
 
+static inline int bpf2a32_offset(int bpf_to, int bpf_from,
+				 const struct jit_ctx *ctx) {
+	int to, from;
+
+	if (ctx->target == NULL)
+		return 0;
+	to = ctx->offsets[bpf_to];
+	from = ctx->offsets[bpf_from];
+
+	return to - from - 1;
+}
+
 /*
  * Move an immediate that's not an imm8m to a core register.
  */
-static inline void emit_mov_i_no8m(int rd, u32 val, struct jit_ctx *ctx)
+static inline void emit_mov_i_no8m(const u8 rd, u32 val, struct jit_ctx *ctx)
 {
 #if __LINUX_ARM_ARCH__ < 7
 	emit(ARM_LDR_I(rd, ARM_PC, imm_offset(val, ctx)), ctx);
@@ -334,7 +275,7 @@ static inline void emit_mov_i_no8m(int rd, u32 val, struct jit_ctx *ctx)
 #endif
 }
 
-static inline void emit_mov_i(int rd, u32 val, struct jit_ctx *ctx)
+static inline void emit_mov_i(const u8 rd, u32 val, struct jit_ctx *ctx)
 {
 	int imm12 = imm8m(val);
 
@@ -344,676 +285,1594 @@ static inline void emit_mov_i(int rd, u32 val, struct jit_ctx *ctx)
 		emit_mov_i_no8m(rd, val, ctx);
 }
 
-#if __LINUX_ARM_ARCH__ < 6
-
-static void emit_load_be32(u8 cond, u8 r_res, u8 r_addr, struct jit_ctx *ctx)
+static inline void emit_blx_r(u8 tgt_reg, struct jit_ctx *ctx)
 {
-	_emit(cond, ARM_LDRB_I(ARM_R3, r_addr, 1), ctx);
-	_emit(cond, ARM_LDRB_I(ARM_R1, r_addr, 0), ctx);
-	_emit(cond, ARM_LDRB_I(ARM_R2, r_addr, 3), ctx);
-	_emit(cond, ARM_LSL_I(ARM_R3, ARM_R3, 16), ctx);
-	_emit(cond, ARM_LDRB_I(ARM_R0, r_addr, 2), ctx);
-	_emit(cond, ARM_ORR_S(ARM_R3, ARM_R3, ARM_R1, SRTYPE_LSL, 24), ctx);
-	_emit(cond, ARM_ORR_R(ARM_R3, ARM_R3, ARM_R2), ctx);
-	_emit(cond, ARM_ORR_S(r_res, ARM_R3, ARM_R0, SRTYPE_LSL, 8), ctx);
+	ctx->seen |= SEEN_CALL;
+#if __LINUX_ARM_ARCH__ < 5
+	emit(ARM_MOV_R(ARM_LR, ARM_PC), ctx);
+
+	if (elf_hwcap & HWCAP_THUMB)
+		emit(ARM_BX(tgt_reg), ctx);
+	else
+		emit(ARM_MOV_R(ARM_PC, tgt_reg), ctx);
+#else
+	emit(ARM_BLX_R(tgt_reg), ctx);
+#endif
 }
 
-static void emit_load_be16(u8 cond, u8 r_res, u8 r_addr, struct jit_ctx *ctx)
+static inline int epilogue_offset(const struct jit_ctx *ctx)
 {
-	_emit(cond, ARM_LDRB_I(ARM_R1, r_addr, 0), ctx);
-	_emit(cond, ARM_LDRB_I(ARM_R2, r_addr, 1), ctx);
-	_emit(cond, ARM_ORR_S(r_res, ARM_R2, ARM_R1, SRTYPE_LSL, 8), ctx);
+	int to, from;
+	/* No need for 1st dummy run */
+	if (ctx->target == NULL)
+		return 0;
+	to = ctx->epilogue_offset;
+	from = ctx->idx;
+
+	return to - from - 2;
 }
 
-static inline void emit_swap16(u8 r_dst, u8 r_src, struct jit_ctx *ctx)
+static inline void emit_udivmod(u8 rd, u8 rm, u8 rn, struct jit_ctx *ctx, u8 op)
 {
-	/* r_dst = (r_src << 8) | (r_src >> 8) */
-	emit(ARM_LSL_I(ARM_R1, r_src, 8), ctx);
-	emit(ARM_ORR_S(r_dst, ARM_R1, r_src, SRTYPE_LSR, 8), ctx);
+	const u8 *tmp = bpf2a32[TMP_REG_1];
+	s32 jmp_offset;
+
+	/* checks if divisor is zero or not. If it is, then
+	 * exit directly.
+	 */
+	emit(ARM_CMP_I(rn, 0), ctx);
+	_emit(ARM_COND_EQ, ARM_MOV_I(ARM_R0, 0), ctx);
+	jmp_offset = epilogue_offset(ctx);
+	_emit(ARM_COND_EQ, ARM_B(jmp_offset), ctx);
+#if __LINUX_ARM_ARCH__ == 7
+	if (elf_hwcap & HWCAP_IDIVA) {
+		if (op == BPF_DIV)
+			emit(ARM_UDIV(rd, rm, rn), ctx);
+		else {
+			emit(ARM_UDIV(ARM_IP, rm, rn), ctx);
+			emit(ARM_MLS(rd, rn, ARM_IP, rm), ctx);
+		}
+		return;
+	}
+#endif
 
 	/*
-	 * we need to mask out the bits set in r_dst[23:16] due to
-	 * the first shift instruction.
-	 *
-	 * note that 0x8ff is the encoded immediate 0x00ff0000.
+	 * For BPF_ALU | BPF_DIV | BPF_K instructions
+	 * As ARM_R1 and ARM_R0 contains 1st argument of bpf
+	 * function, we need to save it on caller side to save
+	 * it from getting destroyed within callee.
+	 * After the return from the callee, we restore ARM_R0
+	 * ARM_R1.
 	 */
-	emit(ARM_BIC_I(r_dst, r_dst, 0x8ff), ctx);
-}
+	if (rn != ARM_R1) {
+		emit(ARM_MOV_R(tmp[0], ARM_R1), ctx);
+		emit(ARM_MOV_R(ARM_R1, rn), ctx);
+	}
+	if (rm != ARM_R0) {
+		emit(ARM_MOV_R(tmp[1], ARM_R0), ctx);
+		emit(ARM_MOV_R(ARM_R0, rm), ctx);
+	}
 
-#else  /* ARMv6+ */
+	/* Call appropriate function */
+	ctx->seen |= SEEN_CALL;
+	emit_mov_i(ARM_IP, op == BPF_DIV ?
+		   (u32)jit_udiv32 : (u32)jit_mod32, ctx);
+	emit_blx_r(ARM_IP, ctx);
 
-static void emit_load_be32(u8 cond, u8 r_res, u8 r_addr, struct jit_ctx *ctx)
-{
-	_emit(cond, ARM_LDR_I(r_res, r_addr, 0), ctx);
-#ifdef __LITTLE_ENDIAN
-	_emit(cond, ARM_REV(r_res, r_res), ctx);
-#endif
+	/* Save return value */
+	if (rd != ARM_R0)
+		emit(ARM_MOV_R(rd, ARM_R0), ctx);
+
+	/* Restore ARM_R0 and ARM_R1 */
+	if (rn != ARM_R1)
+		emit(ARM_MOV_R(ARM_R1, tmp[0]), ctx);
+	if (rm != ARM_R0)
+		emit(ARM_MOV_R(ARM_R0, tmp[1]), ctx);
 }
 
-static void emit_load_be16(u8 cond, u8 r_res, u8 r_addr, struct jit_ctx *ctx)
+/* Checks whether BPF register is on scratch stack space or not. */
+static inline bool is_on_stack(u8 bpf_reg)
 {
-	_emit(cond, ARM_LDRH_I(r_res, r_addr, 0), ctx);
-#ifdef __LITTLE_ENDIAN
-	_emit(cond, ARM_REV16(r_res, r_res), ctx);
-#endif
+	static u8 stack_regs[] = {BPF_REG_AX, BPF_REG_3, BPF_REG_4, BPF_REG_5,
+				BPF_REG_7, BPF_REG_8, BPF_REG_9, TCALL_CNT,
+				BPF_REG_2, BPF_REG_FP};
+	int i, reg_len = sizeof(stack_regs);
+
+	for (i = 0 ; i < reg_len ; i++) {
+		if (bpf_reg == stack_regs[i])
+			return true;
+	}
+	return false;
 }
 
-static inline void emit_swap16(u8 r_dst __maybe_unused,
-			       u8 r_src __maybe_unused,
-			       struct jit_ctx *ctx __maybe_unused)
+static inline void emit_a32_mov_i(const u8 dst, const u32 val,
+				  bool dstk, struct jit_ctx *ctx)
 {
-#ifdef __LITTLE_ENDIAN
-	emit(ARM_REV16(r_dst, r_src), ctx);
-#endif
+	const u8 *tmp = bpf2a32[TMP_REG_1];
+
+	if (dstk) {
+		emit_mov_i(tmp[1], val, ctx);
+		emit(ARM_STR_I(tmp[1], ARM_SP, STACK_VAR(dst)), ctx);
+	} else {
+		emit_mov_i(dst, val, ctx);
+	}
 }
 
-#endif /* __LINUX_ARM_ARCH__ < 6 */
+/* Sign extended move */
+static inline void emit_a32_mov_i64(const bool is64, const u8 dst[],
+				  const u32 val, bool dstk,
+				  struct jit_ctx *ctx) {
+	u32 hi = 0;
 
+	if (is64 && (val & (1<<31)))
+		hi = (u32)~0;
+	emit_a32_mov_i(dst_lo, val, dstk, ctx);
+	emit_a32_mov_i(dst_hi, hi, dstk, ctx);
+}
 
-/* Compute the immediate value for a PC-relative branch. */
-static inline u32 b_imm(unsigned tgt, struct jit_ctx *ctx)
-{
-	u32 imm;
+static inline void emit_a32_add_r(const u8 dst, const u8 src,
+			      const bool is64, const bool hi,
+			      struct jit_ctx *ctx) {
+	/* 64 bit :
+	 *	adds dst_lo, dst_lo, src_lo
+	 *	adc dst_hi, dst_hi, src_hi
+	 * 32 bit :
+	 *	add dst_lo, dst_lo, src_lo
+	 */
+	if (!hi && is64)
+		emit(ARM_ADDS_R(dst, dst, src), ctx);
+	else if (hi && is64)
+		emit(ARM_ADC_R(dst, dst, src), ctx);
+	else
+		emit(ARM_ADD_R(dst, dst, src), ctx);
+}
 
-	if (ctx->target == NULL)
-		return 0;
-	/*
-	 * BPF allows only forward jumps and the offset of the target is
-	 * still the one computed during the first pass.
+static inline void emit_a32_sub_r(const u8 dst, const u8 src,
+				  const bool is64, const bool hi,
+				  struct jit_ctx *ctx) {
+	/* 64 bit :
+	 *	subs dst_lo, dst_lo, src_lo
+	 *	sbc dst_hi, dst_hi, src_hi
+	 * 32 bit :
+	 *	sub dst_lo, dst_lo, src_lo
 	 */
-	imm  = ctx->offsets[tgt] + ctx->prologue_bytes - (ctx->idx * 4 + 8);
+	if (!hi && is64)
+		emit(ARM_SUBS_R(dst, dst, src), ctx);
+	else if (hi && is64)
+		emit(ARM_SBC_R(dst, dst, src), ctx);
+	else
+		emit(ARM_SUB_R(dst, dst, src), ctx);
+}
 
-	return imm >> 2;
+static inline void emit_alu_r(const u8 dst, const u8 src, const bool is64,
+			      const bool hi, const u8 op, struct jit_ctx *ctx){
+	switch (BPF_OP(op)) {
+	/* dst = dst + src */
+	case BPF_ADD:
+		emit_a32_add_r(dst, src, is64, hi, ctx);
+		break;
+	/* dst = dst - src */
+	case BPF_SUB:
+		emit_a32_sub_r(dst, src, is64, hi, ctx);
+		break;
+	/* dst = dst | src */
+	case BPF_OR:
+		emit(ARM_ORR_R(dst, dst, src), ctx);
+		break;
+	/* dst = dst & src */
+	case BPF_AND:
+		emit(ARM_AND_R(dst, dst, src), ctx);
+		break;
+	/* dst = dst ^ src */
+	case BPF_XOR:
+		emit(ARM_EOR_R(dst, dst, src), ctx);
+		break;
+	/* dst = dst * src */
+	case BPF_MUL:
+		emit(ARM_MUL(dst, dst, src), ctx);
+		break;
+	/* dst = dst << src */
+	case BPF_LSH:
+		emit(ARM_LSL_R(dst, dst, src), ctx);
+		break;
+	/* dst = dst >> src */
+	case BPF_RSH:
+		emit(ARM_LSR_R(dst, dst, src), ctx);
+		break;
+	/* dst = dst >> src (signed)*/
+	case BPF_ARSH:
+		emit(ARM_MOV_SR(dst, dst, SRTYPE_ASR, src), ctx);
+		break;
+	}
 }
 
-#define OP_IMM3(op, r1, r2, imm_val, ctx)				\
-	do {								\
-		imm12 = imm8m(imm_val);					\
-		if (imm12 < 0) {					\
-			emit_mov_i_no8m(r_scratch, imm_val, ctx);	\
-			emit(op ## _R((r1), (r2), r_scratch), ctx);	\
-		} else {						\
-			emit(op ## _I((r1), (r2), imm12), ctx);		\
-		}							\
-	} while (0)
-
-static inline void emit_err_ret(u8 cond, struct jit_ctx *ctx)
-{
-	if (ctx->ret0_fp_idx >= 0) {
-		_emit(cond, ARM_B(b_imm(ctx->ret0_fp_idx, ctx)), ctx);
-		/* NOP to keep the size constant between passes */
-		emit(ARM_MOV_R(ARM_R0, ARM_R0), ctx);
+/* ALU operation (32 bit)
+ * dst = dst (op) src
+ */
+static inline void emit_a32_alu_r(const u8 dst, const u8 src,
+				  bool dstk, bool sstk,
+				  struct jit_ctx *ctx, const bool is64,
+				  const bool hi, const u8 op) {
+	const u8 *tmp = bpf2a32[TMP_REG_1];
+	u8 rn = sstk ? tmp[1] : src;
+
+	if (sstk)
+		emit(ARM_LDR_I(rn, ARM_SP, STACK_VAR(src)), ctx);
+
+	/* ALU operation */
+	if (dstk) {
+		emit(ARM_LDR_I(tmp[0], ARM_SP, STACK_VAR(dst)), ctx);
+		emit_alu_r(tmp[0], rn, is64, hi, op, ctx);
+		emit(ARM_STR_I(tmp[0], ARM_SP, STACK_VAR(dst)), ctx);
 	} else {
-		_emit(cond, ARM_MOV_I(ARM_R0, 0), ctx);
-		_emit(cond, ARM_B(b_imm(ctx->skf->len, ctx)), ctx);
+		emit_alu_r(dst, rn, is64, hi, op, ctx);
 	}
 }
 
-static inline void emit_blx_r(u8 tgt_reg, struct jit_ctx *ctx)
-{
-#if __LINUX_ARM_ARCH__ < 5
-	emit(ARM_MOV_R(ARM_LR, ARM_PC), ctx);
+/* ALU operation (64 bit) */
+static inline void emit_a32_alu_r64(const bool is64, const u8 dst[],
+				  const u8 src[], bool dstk,
+				  bool sstk, struct jit_ctx *ctx,
+				  const u8 op) {
+	emit_a32_alu_r(dst_lo, src_lo, dstk, sstk, ctx, is64, false, op);
+	if (is64)
+		emit_a32_alu_r(dst_hi, src_hi, dstk, sstk, ctx, is64, true, op);
+	else
+		emit_a32_mov_i(dst_hi, 0, dstk, ctx);
+}
 
-	if (elf_hwcap & HWCAP_THUMB)
-		emit(ARM_BX(tgt_reg), ctx);
+/* dst = imm (4 bytes)*/
+static inline void emit_a32_mov_r(const u8 dst, const u8 src,
+				  bool dstk, bool sstk,
+				  struct jit_ctx *ctx) {
+	const u8 *tmp = bpf2a32[TMP_REG_1];
+	u8 rt = sstk ? tmp[0] : src;
+
+	if (sstk)
+		emit(ARM_LDR_I(tmp[0], ARM_SP, STACK_VAR(src)), ctx);
+	if (dstk)
+		emit(ARM_STR_I(rt, ARM_SP, STACK_VAR(dst)), ctx);
 	else
-		emit(ARM_MOV_R(ARM_PC, tgt_reg), ctx);
-#else
-	emit(ARM_BLX_R(tgt_reg), ctx);
-#endif
+		emit(ARM_MOV_R(dst, rt), ctx);
 }
 
-static inline void emit_udivmod(u8 rd, u8 rm, u8 rn, struct jit_ctx *ctx,
-				int bpf_op)
-{
-#if __LINUX_ARM_ARCH__ == 7
-	if (elf_hwcap & HWCAP_IDIVA) {
-		if (bpf_op == BPF_DIV)
-			emit(ARM_UDIV(rd, rm, rn), ctx);
-		else {
-			emit(ARM_UDIV(ARM_R3, rm, rn), ctx);
-			emit(ARM_MLS(rd, rn, ARM_R3, rm), ctx);
-		}
-		return;
+/* dst = src */
+static inline void emit_a32_mov_r64(const bool is64, const u8 dst[],
+				  const u8 src[], bool dstk,
+				  bool sstk, struct jit_ctx *ctx) {
+	emit_a32_mov_r(dst_lo, src_lo, dstk, sstk, ctx);
+	if (is64) {
+		/* complete 8 byte move */
+		emit_a32_mov_r(dst_hi, src_hi, dstk, sstk, ctx);
+	} else {
+		/* Zero out high 4 bytes */
+		emit_a32_mov_i(dst_hi, 0, dstk, ctx);
 	}
-#endif
+}
 
-	/*
-	 * For BPF_ALU | BPF_DIV | BPF_K instructions, rm is ARM_R4
-	 * (r_A) and rn is ARM_R0 (r_scratch) so load rn first into
-	 * ARM_R1 to avoid accidentally overwriting ARM_R0 with rm
-	 * before using it as a source for ARM_R1.
-	 *
-	 * For BPF_ALU | BPF_DIV | BPF_X rm is ARM_R4 (r_A) and rn is
-	 * ARM_R5 (r_X) so there is no particular register overlap
-	 * issues.
-	 */
-	if (rn != ARM_R1)
-		emit(ARM_MOV_R(ARM_R1, rn), ctx);
-	if (rm != ARM_R0)
-		emit(ARM_MOV_R(ARM_R0, rm), ctx);
+/* Shift operations */
+static inline void emit_a32_alu_i(const u8 dst, const u32 val, bool dstk,
+				struct jit_ctx *ctx, const u8 op) {
+	const u8 *tmp = bpf2a32[TMP_REG_1];
+	u8 rd = dstk ? tmp[0] : dst;
+
+	if (dstk)
+		emit(ARM_LDR_I(rd, ARM_SP, STACK_VAR(dst)), ctx);
+
+	/* Do shift operation */
+	switch (op) {
+	case BPF_LSH:
+		emit(ARM_LSL_I(rd, rd, val), ctx);
+		break;
+	case BPF_RSH:
+		emit(ARM_LSR_I(rd, rd, val), ctx);
+		break;
+	case BPF_NEG:
+		emit(ARM_RSB_I(rd, rd, val), ctx);
+		break;
+	}
 
+	if (dstk)
+		emit(ARM_STR_I(rd, ARM_SP, STACK_VAR(dst)), ctx);
+}
+
+/* dst = ~dst (64 bit) */
+static inline void emit_a32_neg64(const u8 dst[], bool dstk,
+				struct jit_ctx *ctx){
+	const u8 *tmp = bpf2a32[TMP_REG_1];
+	u8 rd = dstk ? tmp[1] : dst[1];
+	u8 rm = dstk ? tmp[0] : dst[0];
+
+	/* Setup Operand */
+	if (dstk) {
+		emit(ARM_LDR_I(rd, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		emit(ARM_LDR_I(rm, ARM_SP, STACK_VAR(dst_hi)), ctx);
+	}
+
+	/* Do Negate Operation */
+	emit(ARM_RSBS_I(rd, rd, 0), ctx);
+	emit(ARM_RSC_I(rm, rm, 0), ctx);
+
+	if (dstk) {
+		emit(ARM_STR_I(rd, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		emit(ARM_STR_I(rm, ARM_SP, STACK_VAR(dst_hi)), ctx);
+	}
+}
+
+/* dst = dst << src */
+static inline void emit_a32_lsh_r64(const u8 dst[], const u8 src[], bool dstk,
+				    bool sstk, struct jit_ctx *ctx) {
+	const u8 *tmp = bpf2a32[TMP_REG_1];
+	const u8 *tmp2 = bpf2a32[TMP_REG_2];
+
+	/* Setup Operands */
+	u8 rt = sstk ? tmp2[1] : src_lo;
+	u8 rd = dstk ? tmp[1] : dst_lo;
+	u8 rm = dstk ? tmp[0] : dst_hi;
+
+	if (sstk)
+		emit(ARM_LDR_I(rt, ARM_SP, STACK_VAR(src_lo)), ctx);
+	if (dstk) {
+		emit(ARM_LDR_I(rd, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		emit(ARM_LDR_I(rm, ARM_SP, STACK_VAR(dst_hi)), ctx);
+	}
+
+	/* Do LSH operation */
+	emit(ARM_SUB_I(ARM_IP, rt, 32), ctx);
+	emit(ARM_RSB_I(tmp2[0], rt, 32), ctx);
+	/* As we are using ARM_LR */
 	ctx->seen |= SEEN_CALL;
-	emit_mov_i(ARM_R3, bpf_op == BPF_DIV ? (u32)jit_udiv : (u32)jit_mod,
-		   ctx);
-	emit_blx_r(ARM_R3, ctx);
+	emit(ARM_MOV_SR(ARM_LR, rm, SRTYPE_ASL, rt), ctx);
+	emit(ARM_ORR_SR(ARM_LR, ARM_LR, rd, SRTYPE_ASL, ARM_IP), ctx);
+	emit(ARM_ORR_SR(ARM_IP, ARM_LR, rd, SRTYPE_LSR, tmp2[0]), ctx);
+	emit(ARM_MOV_SR(ARM_LR, rd, SRTYPE_ASL, rt), ctx);
+
+	if (dstk) {
+		emit(ARM_STR_I(ARM_LR, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		emit(ARM_STR_I(ARM_IP, ARM_SP, STACK_VAR(dst_hi)), ctx);
+	} else {
+		emit(ARM_MOV_R(rd, ARM_LR), ctx);
+		emit(ARM_MOV_R(rm, ARM_IP), ctx);
+	}
+}
 
-	if (rd != ARM_R0)
-		emit(ARM_MOV_R(rd, ARM_R0), ctx);
+/* dst = dst >> src (signed)*/
+static inline void emit_a32_arsh_r64(const u8 dst[], const u8 src[], bool dstk,
+				    bool sstk, struct jit_ctx *ctx) {
+	const u8 *tmp = bpf2a32[TMP_REG_1];
+	const u8 *tmp2 = bpf2a32[TMP_REG_2];
+	/* Setup Operands */
+	u8 rt = sstk ? tmp2[1] : src_lo;
+	u8 rd = dstk ? tmp[1] : dst_lo;
+	u8 rm = dstk ? tmp[0] : dst_hi;
+
+	if (sstk)
+		emit(ARM_LDR_I(rt, ARM_SP, STACK_VAR(src_lo)), ctx);
+	if (dstk) {
+		emit(ARM_LDR_I(rd, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		emit(ARM_LDR_I(rm, ARM_SP, STACK_VAR(dst_hi)), ctx);
+	}
+
+	/* Do the ARSH operation */
+	emit(ARM_RSB_I(ARM_IP, rt, 32), ctx);
+	emit(ARM_SUBS_I(tmp2[0], rt, 32), ctx);
+	/* As we are using ARM_LR */
+	ctx->seen |= SEEN_CALL;
+	emit(ARM_MOV_SR(ARM_LR, rd, SRTYPE_LSR, rt), ctx);
+	emit(ARM_ORR_SR(ARM_LR, ARM_LR, rm, SRTYPE_ASL, ARM_IP), ctx);
+	_emit(ARM_COND_MI, ARM_B(0), ctx);
+	emit(ARM_ORR_SR(ARM_LR, ARM_LR, rm, SRTYPE_ASR, tmp2[0]), ctx);
+	emit(ARM_MOV_SR(ARM_IP, rm, SRTYPE_ASR, rt), ctx);
+	if (dstk) {
+		emit(ARM_STR_I(ARM_LR, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		emit(ARM_STR_I(ARM_IP, ARM_SP, STACK_VAR(dst_hi)), ctx);
+	} else {
+		emit(ARM_MOV_R(rd, ARM_LR), ctx);
+		emit(ARM_MOV_R(rm, ARM_IP), ctx);
+	}
+}
+
+/* dst = dst >> src */
+static inline void emit_a32_lsr_r64(const u8 dst[], const u8 src[], bool dstk,
+				     bool sstk, struct jit_ctx *ctx) {
+	const u8 *tmp = bpf2a32[TMP_REG_1];
+	const u8 *tmp2 = bpf2a32[TMP_REG_2];
+	/* Setup Operands */
+	u8 rt = sstk ? tmp2[1] : src_lo;
+	u8 rd = dstk ? tmp[1] : dst_lo;
+	u8 rm = dstk ? tmp[0] : dst_hi;
+
+	if (sstk)
+		emit(ARM_LDR_I(rt, ARM_SP, STACK_VAR(src_lo)), ctx);
+	if (dstk) {
+		emit(ARM_LDR_I(rd, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		emit(ARM_LDR_I(rm, ARM_SP, STACK_VAR(dst_hi)), ctx);
+	}
+
+	/* Do LSH operation */
+	emit(ARM_RSB_I(ARM_IP, rt, 32), ctx);
+	emit(ARM_SUBS_I(tmp2[0], rt, 32), ctx);
+	/* As we are using ARM_LR */
+	ctx->seen |= SEEN_CALL;
+	emit(ARM_MOV_SR(ARM_LR, rd, SRTYPE_LSR, rt), ctx);
+	emit(ARM_ORR_SR(ARM_LR, ARM_LR, rm, SRTYPE_ASL, ARM_IP), ctx);
+	emit(ARM_ORR_SR(ARM_LR, ARM_LR, rm, SRTYPE_LSR, tmp2[0]), ctx);
+	emit(ARM_MOV_SR(ARM_IP, rm, SRTYPE_LSR, rt), ctx);
+	if (dstk) {
+		emit(ARM_STR_I(ARM_LR, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		emit(ARM_STR_I(ARM_IP, ARM_SP, STACK_VAR(dst_hi)), ctx);
+	} else {
+		emit(ARM_MOV_R(rd, ARM_LR), ctx);
+		emit(ARM_MOV_R(rm, ARM_IP), ctx);
+	}
 }
 
-static inline void update_on_xread(struct jit_ctx *ctx)
+/* dst = dst << val */
+static inline void emit_a32_lsh_i64(const u8 dst[], bool dstk,
+				     const u32 val, struct jit_ctx *ctx){
+	const u8 *tmp = bpf2a32[TMP_REG_1];
+	const u8 *tmp2 = bpf2a32[TMP_REG_2];
+	/* Setup operands */
+	u8 rd = dstk ? tmp[1] : dst_lo;
+	u8 rm = dstk ? tmp[0] : dst_hi;
+
+	if (dstk) {
+		emit(ARM_LDR_I(rd, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		emit(ARM_LDR_I(rm, ARM_SP, STACK_VAR(dst_hi)), ctx);
+	}
+
+	/* Do LSH operation */
+	if (val < 32) {
+		emit(ARM_MOV_SI(tmp2[0], rm, SRTYPE_ASL, val), ctx);
+		emit(ARM_ORR_SI(rm, tmp2[0], rd, SRTYPE_LSR, 32 - val), ctx);
+		emit(ARM_MOV_SI(rd, rd, SRTYPE_ASL, val), ctx);
+	} else {
+		if (val == 32)
+			emit(ARM_MOV_R(rm, rd), ctx);
+		else
+			emit(ARM_MOV_SI(rm, rd, SRTYPE_ASL, val - 32), ctx);
+		emit(ARM_EOR_R(rd, rd, rd), ctx);
+	}
+
+	if (dstk) {
+		emit(ARM_STR_I(rd, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		emit(ARM_STR_I(rm, ARM_SP, STACK_VAR(dst_hi)), ctx);
+	}
+}
+
+/* dst = dst >> val */
+static inline void emit_a32_lsr_i64(const u8 dst[], bool dstk,
+				    const u32 val, struct jit_ctx *ctx) {
+	const u8 *tmp = bpf2a32[TMP_REG_1];
+	const u8 *tmp2 = bpf2a32[TMP_REG_2];
+	/* Setup operands */
+	u8 rd = dstk ? tmp[1] : dst_lo;
+	u8 rm = dstk ? tmp[0] : dst_hi;
+
+	if (dstk) {
+		emit(ARM_LDR_I(rd, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		emit(ARM_LDR_I(rm, ARM_SP, STACK_VAR(dst_hi)), ctx);
+	}
+
+	/* Do LSR operation */
+	if (val < 32) {
+		emit(ARM_MOV_SI(tmp2[1], rd, SRTYPE_LSR, val), ctx);
+		emit(ARM_ORR_SI(rd, tmp2[1], rm, SRTYPE_ASL, 32 - val), ctx);
+		emit(ARM_MOV_SI(rm, rm, SRTYPE_LSR, val), ctx);
+	} else if (val == 32) {
+		emit(ARM_MOV_R(rd, rm), ctx);
+		emit(ARM_MOV_I(rm, 0), ctx);
+	} else {
+		emit(ARM_MOV_SI(rd, rm, SRTYPE_LSR, val - 32), ctx);
+		emit(ARM_MOV_I(rm, 0), ctx);
+	}
+
+	if (dstk) {
+		emit(ARM_STR_I(rd, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		emit(ARM_STR_I(rm, ARM_SP, STACK_VAR(dst_hi)), ctx);
+	}
+}
+
+/* dst = dst >> val (signed) */
+static inline void emit_a32_arsh_i64(const u8 dst[], bool dstk,
+				     const u32 val, struct jit_ctx *ctx){
+	const u8 *tmp = bpf2a32[TMP_REG_1];
+	const u8 *tmp2 = bpf2a32[TMP_REG_2];
+	 /* Setup operands */
+	u8 rd = dstk ? tmp[1] : dst_lo;
+	u8 rm = dstk ? tmp[0] : dst_hi;
+
+	if (dstk) {
+		emit(ARM_LDR_I(rd, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		emit(ARM_LDR_I(rm, ARM_SP, STACK_VAR(dst_hi)), ctx);
+	}
+
+	/* Do ARSH operation */
+	if (val < 32) {
+		emit(ARM_MOV_SI(tmp2[1], rd, SRTYPE_LSR, val), ctx);
+		emit(ARM_ORR_SI(rd, tmp2[1], rm, SRTYPE_ASL, 32 - val), ctx);
+		emit(ARM_MOV_SI(rm, rm, SRTYPE_ASR, val), ctx);
+	} else if (val == 32) {
+		emit(ARM_MOV_R(rd, rm), ctx);
+		emit(ARM_MOV_SI(rm, rm, SRTYPE_ASR, 31), ctx);
+	} else {
+		emit(ARM_MOV_SI(rd, rm, SRTYPE_ASR, val - 32), ctx);
+		emit(ARM_MOV_SI(rm, rm, SRTYPE_ASR, 31), ctx);
+	}
+
+	if (dstk) {
+		emit(ARM_STR_I(rd, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		emit(ARM_STR_I(rm, ARM_SP, STACK_VAR(dst_hi)), ctx);
+	}
+}
+
+static inline void emit_a32_mul_r64(const u8 dst[], const u8 src[], bool dstk,
+				    bool sstk, struct jit_ctx *ctx) {
+	const u8 *tmp = bpf2a32[TMP_REG_1];
+	const u8 *tmp2 = bpf2a32[TMP_REG_2];
+	/* Setup operands for multiplication */
+	u8 rd = dstk ? tmp[1] : dst_lo;
+	u8 rm = dstk ? tmp[0] : dst_hi;
+	u8 rt = sstk ? tmp2[1] : src_lo;
+	u8 rn = sstk ? tmp2[0] : src_hi;
+
+	if (dstk) {
+		emit(ARM_LDR_I(rd, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		emit(ARM_LDR_I(rm, ARM_SP, STACK_VAR(dst_hi)), ctx);
+	}
+	if (sstk) {
+		emit(ARM_LDR_I(rt, ARM_SP, STACK_VAR(src_lo)), ctx);
+		emit(ARM_LDR_I(rn, ARM_SP, STACK_VAR(src_hi)), ctx);
+	}
+
+	/* Do Multiplication */
+	emit(ARM_MUL(ARM_IP, rd, rn), ctx);
+	emit(ARM_MUL(ARM_LR, rm, rt), ctx);
+	/* As we are using ARM_LR */
+	ctx->seen |= SEEN_CALL;
+	emit(ARM_ADD_R(ARM_LR, ARM_IP, ARM_LR), ctx);
+
+	emit(ARM_UMULL(ARM_IP, rm, rd, rt), ctx);
+	emit(ARM_ADD_R(rm, ARM_LR, rm), ctx);
+	if (dstk) {
+		emit(ARM_STR_I(ARM_IP, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		emit(ARM_STR_I(rm, ARM_SP, STACK_VAR(dst_hi)), ctx);
+	} else {
+		emit(ARM_MOV_R(rd, ARM_IP), ctx);
+	}
+}
+
+/* *(size *)(dst + off) = src */
+static inline void emit_str_r(const u8 dst, const u8 src, bool dstk,
+			      const s32 off, struct jit_ctx *ctx, const u8 sz){
+	const u8 *tmp = bpf2a32[TMP_REG_1];
+	u8 rd = dstk ? tmp[1] : dst;
+
+	if (dstk)
+		emit(ARM_LDR_I(rd, ARM_SP, STACK_VAR(dst)), ctx);
+	if (off) {
+		emit_a32_mov_i(tmp[0], off, false, ctx);
+		emit(ARM_ADD_R(tmp[0], rd, tmp[0]), ctx);
+		rd = tmp[0];
+	}
+	switch (sz) {
+	case BPF_W:
+		/* Store a Word */
+		emit(ARM_STR_I(src, rd, 0), ctx);
+		break;
+	case BPF_H:
+		/* Store a HalfWord */
+		emit(ARM_STRH_I(src, rd, 0), ctx);
+		break;
+	case BPF_B:
+		/* Store a Byte */
+		emit(ARM_STRB_I(src, rd, 0), ctx);
+		break;
+	}
+}
+
+/* dst = *(size*)(src + off) */
+static inline void emit_ldx_r(const u8 dst, const u8 src, bool dstk,
+			      const s32 off, struct jit_ctx *ctx, const u8 sz){
+	const u8 *tmp = bpf2a32[TMP_REG_1];
+	u8 rd = dstk ? tmp[1] : dst;
+	u8 rm = src;
+
+	if (off) {
+		emit_a32_mov_i(tmp[0], off, false, ctx);
+		emit(ARM_ADD_R(tmp[0], tmp[0], src), ctx);
+		rm = tmp[0];
+	}
+	switch (sz) {
+	case BPF_W:
+		/* Load a Word */
+		emit(ARM_LDR_I(rd, rm, 0), ctx);
+		break;
+	case BPF_H:
+		/* Load a HalfWord */
+		emit(ARM_LDRH_I(rd, rm, 0), ctx);
+		break;
+	case BPF_B:
+		/* Load a Byte */
+		emit(ARM_LDRB_I(rd, rm, 0), ctx);
+		break;
+	}
+	if (dstk)
+		emit(ARM_STR_I(rd, ARM_SP, STACK_VAR(dst)), ctx);
+}
+
+/* Arithmatic Operation */
+static inline void emit_ar_r(const u8 rd, const u8 rt, const u8 rm,
+			     const u8 rn, struct jit_ctx *ctx, u8 op) {
+	switch (op) {
+	case BPF_JSET:
+		ctx->seen |= SEEN_CALL;
+		emit(ARM_AND_R(ARM_IP, rt, rn), ctx);
+		emit(ARM_AND_R(ARM_LR, rd, rm), ctx);
+		emit(ARM_ORRS_R(ARM_IP, ARM_LR, ARM_IP), ctx);
+		break;
+	case BPF_JEQ:
+	case BPF_JNE:
+	case BPF_JGT:
+	case BPF_JGE:
+	case BPF_JLE:
+	case BPF_JLT:
+		emit(ARM_CMP_R(rd, rm), ctx);
+		_emit(ARM_COND_EQ, ARM_CMP_R(rt, rn), ctx);
+		break;
+	case BPF_JSLE:
+	case BPF_JSGT:
+		emit(ARM_CMP_R(rn, rt), ctx);
+		emit(ARM_SBCS_R(ARM_IP, rm, rd), ctx);
+		break;
+	case BPF_JSLT:
+	case BPF_JSGE:
+		emit(ARM_CMP_R(rt, rn), ctx);
+		emit(ARM_SBCS_R(ARM_IP, rd, rm), ctx);
+		break;
+	}
+}
+
+static int out_offset = -1; /* initialized on the first pass of build_body() */
+static int emit_bpf_tail_call(struct jit_ctx *ctx)
 {
-	if (!(ctx->seen & SEEN_X))
-		ctx->flags |= FLAG_NEED_X_RESET;
 
-	ctx->seen |= SEEN_X;
+	/* bpf_tail_call(void *prog_ctx, struct bpf_array *array, u64 index) */
+	const u8 *r2 = bpf2a32[BPF_REG_2];
+	const u8 *r3 = bpf2a32[BPF_REG_3];
+	const u8 *tmp = bpf2a32[TMP_REG_1];
+	const u8 *tmp2 = bpf2a32[TMP_REG_2];
+	const u8 *tcc = bpf2a32[TCALL_CNT];
+	const int idx0 = ctx->idx;
+#define cur_offset (ctx->idx - idx0)
+#define jmp_offset (out_offset - (cur_offset))
+	u32 off, lo, hi;
+
+	/* if (index >= array->map.max_entries)
+	 *	goto out;
+	 */
+	off = offsetof(struct bpf_array, map.max_entries);
+	/* array->map.max_entries */
+	emit_a32_mov_i(tmp[1], off, false, ctx);
+	emit(ARM_LDR_I(tmp2[1], ARM_SP, STACK_VAR(r2[1])), ctx);
+	emit(ARM_LDR_R(tmp[1], tmp2[1], tmp[1]), ctx);
+	/* index (64 bit) */
+	emit(ARM_LDR_I(tmp2[1], ARM_SP, STACK_VAR(r3[1])), ctx);
+	/* index >= array->map.max_entries */
+	emit(ARM_CMP_R(tmp2[1], tmp[1]), ctx);
+	_emit(ARM_COND_CS, ARM_B(jmp_offset), ctx);
+
+	/* if (tail_call_cnt > MAX_TAIL_CALL_CNT)
+	 *	goto out;
+	 * tail_call_cnt++;
+	 */
+	lo = (u32)MAX_TAIL_CALL_CNT;
+	hi = (u32)((u64)MAX_TAIL_CALL_CNT >> 32);
+	emit(ARM_LDR_I(tmp[1], ARM_SP, STACK_VAR(tcc[1])), ctx);
+	emit(ARM_LDR_I(tmp[0], ARM_SP, STACK_VAR(tcc[0])), ctx);
+	emit(ARM_CMP_I(tmp[0], hi), ctx);
+	_emit(ARM_COND_EQ, ARM_CMP_I(tmp[1], lo), ctx);
+	_emit(ARM_COND_HI, ARM_B(jmp_offset), ctx);
+	emit(ARM_ADDS_I(tmp[1], tmp[1], 1), ctx);
+	emit(ARM_ADC_I(tmp[0], tmp[0], 0), ctx);
+	emit(ARM_STR_I(tmp[1], ARM_SP, STACK_VAR(tcc[1])), ctx);
+	emit(ARM_STR_I(tmp[0], ARM_SP, STACK_VAR(tcc[0])), ctx);
+
+	/* prog = array->ptrs[index]
+	 * if (prog == NULL)
+	 *	goto out;
+	 */
+	off = offsetof(struct bpf_array, ptrs);
+	emit_a32_mov_i(tmp[1], off, false, ctx);
+	emit(ARM_LDR_I(tmp2[1], ARM_SP, STACK_VAR(r2[1])), ctx);
+	emit(ARM_ADD_R(tmp[1], tmp2[1], tmp[1]), ctx);
+	emit(ARM_LDR_I(tmp2[1], ARM_SP, STACK_VAR(r3[1])), ctx);
+	emit(ARM_MOV_SI(tmp[0], tmp2[1], SRTYPE_ASL, 2), ctx);
+	emit(ARM_LDR_R(tmp[1], tmp[1], tmp[0]), ctx);
+	emit(ARM_CMP_I(tmp[1], 0), ctx);
+	_emit(ARM_COND_EQ, ARM_B(jmp_offset), ctx);
+
+	/* goto *(prog->bpf_func + prologue_size); */
+	off = offsetof(struct bpf_prog, bpf_func);
+	emit_a32_mov_i(tmp2[1], off, false, ctx);
+	emit(ARM_LDR_R(tmp[1], tmp[1], tmp2[1]), ctx);
+	emit(ARM_ADD_I(tmp[1], tmp[1], ctx->prologue_bytes), ctx);
+	emit(ARM_BX(tmp[1]), ctx);
+
+	/* out: */
+	if (out_offset == -1)
+		out_offset = cur_offset;
+	if (cur_offset != out_offset) {
+		pr_err_once("tail_call out_offset = %d, expected %d!\n",
+			    cur_offset, out_offset);
+		return -1;
+	}
+	return 0;
+#undef cur_offset
+#undef jmp_offset
 }
 
-static int build_body(struct jit_ctx *ctx)
+/* 0xabcd => 0xcdab */
+static inline void emit_rev16(const u8 rd, const u8 rn, struct jit_ctx *ctx)
 {
-	void *load_func[] = {jit_get_skb_b, jit_get_skb_h, jit_get_skb_w};
-	const struct bpf_prog *prog = ctx->skf;
-	const struct sock_filter *inst;
-	unsigned i, load_order, off, condt;
-	int imm12;
-	u32 k;
+#if __LINUX_ARM_ARCH__ < 6
+	const u8 *tmp2 = bpf2a32[TMP_REG_2];
+
+	emit(ARM_AND_I(tmp2[1], rn, 0xff), ctx);
+	emit(ARM_MOV_SI(tmp2[0], rn, SRTYPE_LSR, 8), ctx);
+	emit(ARM_AND_I(tmp2[0], tmp2[0], 0xff), ctx);
+	emit(ARM_ORR_SI(rd, tmp2[0], tmp2[1], SRTYPE_LSL, 8), ctx);
+#else /* ARMv6+ */
+	emit(ARM_REV16(rd, rn), ctx);
+#endif
+}
 
-	for (i = 0; i < prog->len; i++) {
-		u16 code;
+/* 0xabcdefgh => 0xghefcdab */
+static inline void emit_rev32(const u8 rd, const u8 rn, struct jit_ctx *ctx)
+{
+#if __LINUX_ARM_ARCH__ < 6
+	const u8 *tmp2 = bpf2a32[TMP_REG_2];
+
+	emit(ARM_AND_I(tmp2[1], rn, 0xff), ctx);
+	emit(ARM_MOV_SI(tmp2[0], rn, SRTYPE_LSR, 24), ctx);
+	emit(ARM_ORR_SI(ARM_IP, tmp2[0], tmp2[1], SRTYPE_LSL, 24), ctx);
+
+	emit(ARM_MOV_SI(tmp2[1], rn, SRTYPE_LSR, 8), ctx);
+	emit(ARM_AND_I(tmp2[1], tmp2[1], 0xff), ctx);
+	emit(ARM_MOV_SI(tmp2[0], rn, SRTYPE_LSR, 16), ctx);
+	emit(ARM_AND_I(tmp2[0], tmp2[0], 0xff), ctx);
+	emit(ARM_MOV_SI(tmp2[0], tmp2[0], SRTYPE_LSL, 8), ctx);
+	emit(ARM_ORR_SI(tmp2[0], tmp2[0], tmp2[1], SRTYPE_LSL, 16), ctx);
+	emit(ARM_ORR_R(rd, ARM_IP, tmp2[0]), ctx);
+
+#else /* ARMv6+ */
+	emit(ARM_REV(rd, rn), ctx);
+#endif
+}
 
-		inst = &(prog->insns[i]);
-		/* K as an immediate value operand */
-		k = inst->k;
-		code = bpf_anc_helper(inst);
+// push the scratch stack register on top of the stack
+static inline void emit_push_r64(const u8 src[], const u8 shift,
+		struct jit_ctx *ctx)
+{
+	const u8 *tmp2 = bpf2a32[TMP_REG_2];
+	u16 reg_set = 0;
 
-		/* compute offsets only in the fake pass */
-		if (ctx->target == NULL)
-			ctx->offsets[i] = ctx->idx * 4;
+	emit(ARM_LDR_I(tmp2[1], ARM_SP, STACK_VAR(src[1]+shift)), ctx);
+	emit(ARM_LDR_I(tmp2[0], ARM_SP, STACK_VAR(src[0]+shift)), ctx);
+
+	reg_set = (1 << tmp2[1]) | (1 << tmp2[0]);
+	emit(ARM_PUSH(reg_set), ctx);
+}
+
+static void build_prologue(struct jit_ctx *ctx)
+{
+	const u8 r0 = bpf2a32[BPF_REG_0][1];
+	const u8 r2 = bpf2a32[BPF_REG_1][1];
+	const u8 r3 = bpf2a32[BPF_REG_1][0];
+	const u8 r4 = bpf2a32[BPF_REG_6][1];
+	const u8 r5 = bpf2a32[BPF_REG_6][0];
+	const u8 r6 = bpf2a32[TMP_REG_1][1];
+	const u8 r7 = bpf2a32[TMP_REG_1][0];
+	const u8 r8 = bpf2a32[TMP_REG_2][1];
+	const u8 r10 = bpf2a32[TMP_REG_2][0];
+	const u8 fplo = bpf2a32[BPF_REG_FP][1];
+	const u8 fphi = bpf2a32[BPF_REG_FP][0];
+	const u8 sp = ARM_SP;
+	const u8 *tcc = bpf2a32[TCALL_CNT];
+
+	u16 reg_set = 0;
+
+	/*
+	 * eBPF prog stack layout
+	 *
+	 *                         high
+	 * original ARM_SP =>     +-----+ eBPF prologue
+	 *                        |FP/LR|
+	 * current ARM_FP =>      +-----+
+	 *                        | ... | callee saved registers
+	 * eBPF fp register =>    +-----+ <= (BPF_FP)
+	 *                        | ... | eBPF JIT scratch space
+	 *                        |     | eBPF prog stack
+	 *                        +-----+
+	 *			  |RSVD | JIT scratchpad
+	 * current A64_SP =>      +-----+ <= (BPF_FP - STACK_SIZE)
+	 *                        |     |
+	 *                        | ... | Function call stack
+	 *                        |     |
+	 *                        +-----+
+	 *                          low
+	 */
+
+	/* Save callee saved registers. */
+	reg_set |= (1<<r4) | (1<<r5) | (1<<r6) | (1<<r7) | (1<<r8) | (1<<r10);
+#ifdef CONFIG_FRAME_POINTER
+	reg_set |= (1<<ARM_FP) | (1<<ARM_IP) | (1<<ARM_LR) | (1<<ARM_PC);
+	emit(ARM_MOV_R(ARM_IP, sp), ctx);
+	emit(ARM_PUSH(reg_set), ctx);
+	emit(ARM_SUB_I(ARM_FP, ARM_IP, 4), ctx);
+#else
+	/* Check if call instruction exists in BPF body */
+	if (ctx->seen & SEEN_CALL)
+		reg_set |= (1<<ARM_LR);
+	emit(ARM_PUSH(reg_set), ctx);
+#endif
+	/* Save frame pointer for later */
+	emit(ARM_SUB_I(ARM_IP, sp, SCRATCH_SIZE), ctx);
+
+	ctx->stack_size = imm8m(STACK_SIZE);
+
+	/* Set up function call stack */
+	emit(ARM_SUB_I(ARM_SP, ARM_SP, ctx->stack_size), ctx);
 
-		switch (code) {
-		case BPF_LD | BPF_IMM:
-			emit_mov_i(r_A, k, ctx);
+	/* Set up BPF prog stack base register */
+	emit_a32_mov_r(fplo, ARM_IP, true, false, ctx);
+	emit_a32_mov_i(fphi, 0, true, ctx);
+
+	/* mov r4, 0 */
+	emit(ARM_MOV_I(r4, 0), ctx);
+
+	/* Move BPF_CTX to BPF_R1 */
+	emit(ARM_MOV_R(r3, r4), ctx);
+	emit(ARM_MOV_R(r2, r0), ctx);
+	/* Initialize Tail Count */
+	emit(ARM_STR_I(r4, ARM_SP, STACK_VAR(tcc[0])), ctx);
+	emit(ARM_STR_I(r4, ARM_SP, STACK_VAR(tcc[1])), ctx);
+	/* end of prologue */
+}
+
+static void build_epilogue(struct jit_ctx *ctx)
+{
+	const u8 r4 = bpf2a32[BPF_REG_6][1];
+	const u8 r5 = bpf2a32[BPF_REG_6][0];
+	const u8 r6 = bpf2a32[TMP_REG_1][1];
+	const u8 r7 = bpf2a32[TMP_REG_1][0];
+	const u8 r8 = bpf2a32[TMP_REG_2][1];
+	const u8 r10 = bpf2a32[TMP_REG_2][0];
+	u16 reg_set = 0;
+
+	/* unwind function call stack */
+	emit(ARM_ADD_I(ARM_SP, ARM_SP, ctx->stack_size), ctx);
+
+	/* restore callee saved registers. */
+	reg_set |= (1<<r4) | (1<<r5) | (1<<r6) | (1<<r7) | (1<<r8) | (1<<r10);
+#ifdef CONFIG_FRAME_POINTER
+	/* the first instruction of the prologue was: mov ip, sp */
+	reg_set |= (1<<ARM_FP) | (1<<ARM_SP) | (1<<ARM_PC);
+	emit(ARM_LDM(ARM_SP, reg_set), ctx);
+#else
+	if (ctx->seen & SEEN_CALL)
+		reg_set |= (1<<ARM_PC);
+	/* Restore callee saved registers. */
+	emit(ARM_POP(reg_set), ctx);
+	/* Return back to the callee function */
+	if (!(ctx->seen & SEEN_CALL))
+		emit(ARM_BX(ARM_LR), ctx);
+#endif
+}
+
+/*
+ * Convert an eBPF instruction to native instruction, i.e
+ * JITs an eBPF instruction.
+ * Returns :
+ *	0  - Successfully JITed an 8-byte eBPF instruction
+ *	>0 - Successfully JITed a 16-byte eBPF instruction
+ *	<0 - Failed to JIT.
+ */
+static int build_insn(const struct bpf_insn *insn, struct jit_ctx *ctx)
+{
+	const u8 code = insn->code;
+	const u8 *dst = bpf2a32[insn->dst_reg];
+	const u8 *src = bpf2a32[insn->src_reg];
+	const u8 *tmp = bpf2a32[TMP_REG_1];
+	const u8 *tmp2 = bpf2a32[TMP_REG_2];
+	const s16 off = insn->off;
+	const s32 imm = insn->imm;
+	const int i = insn - ctx->prog->insnsi;
+	const bool is64 = BPF_CLASS(code) == BPF_ALU64;
+	const bool dstk = is_on_stack(insn->dst_reg);
+	const bool sstk = is_on_stack(insn->src_reg);
+	u8 rd, rt, rm, rn;
+	s32 jmp_offset;
+
+#define check_imm(bits, imm) do {				\
+	if ((((imm) > 0) && ((imm) >> (bits))) ||		\
+	    (((imm) < 0) && (~(imm) >> (bits)))) {		\
+		pr_info("[%2d] imm=%d(0x%x) out of range\n",	\
+			i, imm, imm);				\
+		return -EINVAL;					\
+	}							\
+} while (0)
+#define check_imm24(imm) check_imm(24, imm)
+
+	switch (code) {
+	/* ALU operations */
+
+	/* dst = src */
+	case BPF_ALU | BPF_MOV | BPF_K:
+	case BPF_ALU | BPF_MOV | BPF_X:
+	case BPF_ALU64 | BPF_MOV | BPF_K:
+	case BPF_ALU64 | BPF_MOV | BPF_X:
+		switch (BPF_SRC(code)) {
+		case BPF_X:
+			emit_a32_mov_r64(is64, dst, src, dstk, sstk, ctx);
 			break;
-		case BPF_LD | BPF_W | BPF_LEN:
-			ctx->seen |= SEEN_SKB;
-			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);
-			emit(ARM_LDR_I(r_A, r_skb,
-				       offsetof(struct sk_buff, len)), ctx);
+		case BPF_K:
+			/* Sign-extend immediate value to destination reg */
+			emit_a32_mov_i64(is64, dst, imm, dstk, ctx);
 			break;
-		case BPF_LD | BPF_MEM:
-			/* A = scratch[k] */
-			ctx->seen |= SEEN_MEM_WORD(k);
-			emit(ARM_LDR_I(r_A, ARM_SP, SCRATCH_OFF(k)), ctx);
+		}
+		break;
+	/* dst = dst + src/imm */
+	/* dst = dst - src/imm */
+	/* dst = dst | src/imm */
+	/* dst = dst & src/imm */
+	/* dst = dst ^ src/imm */
+	/* dst = dst * src/imm */
+	/* dst = dst << src */
+	/* dst = dst >> src */
+	case BPF_ALU | BPF_ADD | BPF_K:
+	case BPF_ALU | BPF_ADD | BPF_X:
+	case BPF_ALU | BPF_SUB | BPF_K:
+	case BPF_ALU | BPF_SUB | BPF_X:
+	case BPF_ALU | BPF_OR | BPF_K:
+	case BPF_ALU | BPF_OR | BPF_X:
+	case BPF_ALU | BPF_AND | BPF_K:
+	case BPF_ALU | BPF_AND | BPF_X:
+	case BPF_ALU | BPF_XOR | BPF_K:
+	case BPF_ALU | BPF_XOR | BPF_X:
+	case BPF_ALU | BPF_MUL | BPF_K:
+	case BPF_ALU | BPF_MUL | BPF_X:
+	case BPF_ALU | BPF_LSH | BPF_X:
+	case BPF_ALU | BPF_RSH | BPF_X:
+	case BPF_ALU | BPF_ARSH | BPF_K:
+	case BPF_ALU | BPF_ARSH | BPF_X:
+	case BPF_ALU64 | BPF_ADD | BPF_K:
+	case BPF_ALU64 | BPF_ADD | BPF_X:
+	case BPF_ALU64 | BPF_SUB | BPF_K:
+	case BPF_ALU64 | BPF_SUB | BPF_X:
+	case BPF_ALU64 | BPF_OR | BPF_K:
+	case BPF_ALU64 | BPF_OR | BPF_X:
+	case BPF_ALU64 | BPF_AND | BPF_K:
+	case BPF_ALU64 | BPF_AND | BPF_X:
+	case BPF_ALU64 | BPF_XOR | BPF_K:
+	case BPF_ALU64 | BPF_XOR | BPF_X:
+		switch (BPF_SRC(code)) {
+		case BPF_X:
+			emit_a32_alu_r64(is64, dst, src, dstk, sstk,
+					 ctx, BPF_OP(code));
 			break;
-		case BPF_LD | BPF_W | BPF_ABS:
-			load_order = 2;
-			goto load;
-		case BPF_LD | BPF_H | BPF_ABS:
-			load_order = 1;
-			goto load;
-		case BPF_LD | BPF_B | BPF_ABS:
-			load_order = 0;
-load:
-			emit_mov_i(r_off, k, ctx);
-load_common:
-			ctx->seen |= SEEN_DATA | SEEN_CALL;
-
-			if (load_order > 0) {
-				emit(ARM_SUB_I(r_scratch, r_skb_hl,
-					       1 << load_order), ctx);
-				emit(ARM_CMP_R(r_scratch, r_off), ctx);
-				condt = ARM_COND_GE;
-			} else {
-				emit(ARM_CMP_R(r_skb_hl, r_off), ctx);
-				condt = ARM_COND_HI;
-			}
-
-			/*
-			 * test for negative offset, only if we are
-			 * currently scheduled to take the fast
-			 * path. this will update the flags so that
-			 * the slowpath instruction are ignored if the
-			 * offset is negative.
-			 *
-			 * for loard_order == 0 the HI condition will
-			 * make loads at offset 0 take the slow path too.
+		case BPF_K:
+			/* Move immediate value to the temporary register
+			 * and then do the ALU operation on the temporary
+			 * register as this will sign-extend the immediate
+			 * value into temporary reg and then it would be
+			 * safe to do the operation on it.
 			 */
-			_emit(condt, ARM_CMP_I(r_off, 0), ctx);
-
-			_emit(condt, ARM_ADD_R(r_scratch, r_off, r_skb_data),
-			      ctx);
-
-			if (load_order == 0)
-				_emit(condt, ARM_LDRB_I(r_A, r_scratch, 0),
-				      ctx);
-			else if (load_order == 1)
-				emit_load_be16(condt, r_A, r_scratch, ctx);
-			else if (load_order == 2)
-				emit_load_be32(condt, r_A, r_scratch, ctx);
-
-			_emit(condt, ARM_B(b_imm(i + 1, ctx)), ctx);
-
-			/* the slowpath */
-			emit_mov_i(ARM_R3, (u32)load_func[load_order], ctx);
-			emit(ARM_MOV_R(ARM_R0, r_skb), ctx);
-			/* the offset is already in R1 */
-			emit_blx_r(ARM_R3, ctx);
-			/* check the result of skb_copy_bits */
-			emit(ARM_CMP_I(ARM_R1, 0), ctx);
-			emit_err_ret(ARM_COND_NE, ctx);
-			emit(ARM_MOV_R(r_A, ARM_R0), ctx);
+			emit_a32_mov_i64(is64, tmp2, imm, false, ctx);
+			emit_a32_alu_r64(is64, dst, tmp2, dstk, false,
+					 ctx, BPF_OP(code));
 			break;
-		case BPF_LD | BPF_W | BPF_IND:
-			load_order = 2;
-			goto load_ind;
-		case BPF_LD | BPF_H | BPF_IND:
-			load_order = 1;
-			goto load_ind;
-		case BPF_LD | BPF_B | BPF_IND:
-			load_order = 0;
-load_ind:
-			update_on_xread(ctx);
-			OP_IMM3(ARM_ADD, r_off, r_X, k, ctx);
-			goto load_common;
-		case BPF_LDX | BPF_IMM:
-			ctx->seen |= SEEN_X;
-			emit_mov_i(r_X, k, ctx);
+		}
+		break;
+	/* dst = dst / src(imm) */
+	/* dst = dst % src(imm) */
+	case BPF_ALU | BPF_DIV | BPF_K:
+	case BPF_ALU | BPF_DIV | BPF_X:
+	case BPF_ALU | BPF_MOD | BPF_K:
+	case BPF_ALU | BPF_MOD | BPF_X:
+		rt = src_lo;
+		rd = dstk ? tmp2[1] : dst_lo;
+		if (dstk)
+			emit(ARM_LDR_I(rd, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		switch (BPF_SRC(code)) {
+		case BPF_X:
+			rt = sstk ? tmp2[0] : rt;
+			if (sstk)
+				emit(ARM_LDR_I(rt, ARM_SP, STACK_VAR(src_lo)),
+				     ctx);
 			break;
-		case BPF_LDX | BPF_W | BPF_LEN:
-			ctx->seen |= SEEN_X | SEEN_SKB;
-			emit(ARM_LDR_I(r_X, r_skb,
-				       offsetof(struct sk_buff, len)), ctx);
+		case BPF_K:
+			rt = tmp2[0];
+			emit_a32_mov_i(rt, imm, false, ctx);
 			break;
-		case BPF_LDX | BPF_MEM:
-			ctx->seen |= SEEN_X | SEEN_MEM_WORD(k);
-			emit(ARM_LDR_I(r_X, ARM_SP, SCRATCH_OFF(k)), ctx);
+		}
+		emit_udivmod(rd, rd, rt, ctx, BPF_OP(code));
+		if (dstk)
+			emit(ARM_STR_I(rd, ARM_SP, STACK_VAR(dst_lo)), ctx);
+		emit_a32_mov_i(dst_hi, 0, dstk, ctx);
+		break;
+	case BPF_ALU64 | BPF_DIV | BPF_K:
+	case BPF_ALU64 | BPF_DIV | BPF_X:
+	case BPF_ALU64 | BPF_MOD | BPF_K:
+	case BPF_ALU64 | BPF_MOD | BPF_X:
+		goto notyet;
+	/* dst = dst >> imm */
+	/* dst = dst << imm */
+	case BPF_ALU | BPF_RSH | BPF_K:
+	case BPF_ALU | BPF_LSH | BPF_K:
+		if (unlikely(imm > 31))
+			return -EINVAL;
+		if (imm)
+			emit_a32_alu_i(dst_lo, imm, dstk, ctx, BPF_OP(code));
+		emit_a32_mov_i(dst_hi, 0, dstk, ctx);
+		break;
+	/* dst = dst << imm */
+	case BPF_ALU64 | BPF_LSH | BPF_K:
+		if (unlikely(imm > 63))
+			return -EINVAL;
+		emit_a32_lsh_i64(dst, dstk, imm, ctx);
+		break;
+	/* dst = dst >> imm */
+	case BPF_ALU64 | BPF_RSH | BPF_K:
+		if (unlikely(imm > 63))
+			return -EINVAL;
+		emit_a32_lsr_i64(dst, dstk, imm, ctx);
+		break;
+	/* dst = dst << src */
+	case BPF_ALU64 | BPF_LSH | BPF_X:
+		emit_a32_lsh_r64(dst, src, dstk, sstk, ctx);
+		break;
+	/* dst = dst >> src */
+	case BPF_ALU64 | BPF_RSH | BPF_X:
+		emit_a32_lsr_r64(dst, src, dstk, sstk, ctx);
+		break;
+	/* dst = dst >> src (signed) */
+	case BPF_ALU64 | BPF_ARSH | BPF_X:
+		emit_a32_arsh_r64(dst, src, dstk, sstk, ctx);
+		break;
+	/* dst = dst >> imm (signed) */
+	case BPF_ALU64 | BPF_ARSH | BPF_K:
+		if (unlikely(imm > 63))
+			return -EINVAL;
+		emit_a32_arsh_i64(dst, dstk, imm, ctx);
+		break;
+	/* dst = ~dst */
+	case BPF_ALU | BPF_NEG:
+		emit_a32_alu_i(dst_lo, 0, dstk, ctx, BPF_OP(code));
+		emit_a32_mov_i(dst_hi, 0, dstk, ctx);
+		break;
+	/* dst = ~dst (64 bit) */
+	case BPF_ALU64 | BPF_NEG:
+		emit_a32_neg64(dst, dstk, ctx);
+		break;
+	/* dst = dst * src/imm */
+	case BPF_ALU64 | BPF_MUL | BPF_X:
+	case BPF_ALU64 | BPF_MUL | BPF_K:
+		switch (BPF_SRC(code)) {
+		case BPF_X:
+			emit_a32_mul_r64(dst, src, dstk, sstk, ctx);
 			break;
-		case BPF_LDX | BPF_B | BPF_MSH:
-			/* x = ((*(frame + k)) & 0xf) << 2; */
-			ctx->seen |= SEEN_X | SEEN_DATA | SEEN_CALL;
-			/* the interpreter should deal with the negative K */
-			if ((int)k < 0)
-				return -1;
-			/* offset in r1: we might have to take the slow path */
-			emit_mov_i(r_off, k, ctx);
-			emit(ARM_CMP_R(r_skb_hl, r_off), ctx);
-
-			/* load in r0: common with the slowpath */
-			_emit(ARM_COND_HI, ARM_LDRB_R(ARM_R0, r_skb_data,
-						      ARM_R1), ctx);
-			/*
-			 * emit_mov_i() might generate one or two instructions,
-			 * the same holds for emit_blx_r()
+		case BPF_K:
+			/* Move immediate value to the temporary register
+			 * and then do the multiplication on it as this
+			 * will sign-extend the immediate value into temp
+			 * reg then it would be safe to do the operation
+			 * on it.
 			 */
-			_emit(ARM_COND_HI, ARM_B(b_imm(i + 1, ctx) - 2), ctx);
-
-			emit(ARM_MOV_R(ARM_R0, r_skb), ctx);
-			/* r_off is r1 */
-			emit_mov_i(ARM_R3, (u32)jit_get_skb_b, ctx);
-			emit_blx_r(ARM_R3, ctx);
-			/* check the return value of skb_copy_bits */
-			emit(ARM_CMP_I(ARM_R1, 0), ctx);
-			emit_err_ret(ARM_COND_NE, ctx);
-
-			emit(ARM_AND_I(r_X, ARM_R0, 0x00f), ctx);
-			emit(ARM_LSL_I(r_X, r_X, 2), ctx);
-			break;
-		case BPF_ST:
-			ctx->seen |= SEEN_MEM_WORD(k);
-			emit(ARM_STR_I(r_A, ARM_SP, SCRATCH_OFF(k)), ctx);
-			break;
-		case BPF_STX:
-			update_on_xread(ctx);
-			ctx->seen |= SEEN_MEM_WORD(k);
-			emit(ARM_STR_I(r_X, ARM_SP, SCRATCH_OFF(k)), ctx);
-			break;
-		case BPF_ALU | BPF_ADD | BPF_K:
-			/* A += K */
-			OP_IMM3(ARM_ADD, r_A, r_A, k, ctx);
-			break;
-		case BPF_ALU | BPF_ADD | BPF_X:
-			update_on_xread(ctx);
-			emit(ARM_ADD_R(r_A, r_A, r_X), ctx);
-			break;
-		case BPF_ALU | BPF_SUB | BPF_K:
-			/* A -= K */
-			OP_IMM3(ARM_SUB, r_A, r_A, k, ctx);
-			break;
-		case BPF_ALU | BPF_SUB | BPF_X:
-			update_on_xread(ctx);
-			emit(ARM_SUB_R(r_A, r_A, r_X), ctx);
-			break;
-		case BPF_ALU | BPF_MUL | BPF_K:
-			/* A *= K */
-			emit_mov_i(r_scratch, k, ctx);
-			emit(ARM_MUL(r_A, r_A, r_scratch), ctx);
-			break;
-		case BPF_ALU | BPF_MUL | BPF_X:
-			update_on_xread(ctx);
-			emit(ARM_MUL(r_A, r_A, r_X), ctx);
+			emit_a32_mov_i64(is64, tmp2, imm, false, ctx);
+			emit_a32_mul_r64(dst, tmp2, dstk, false, ctx);
 			break;
-		case BPF_ALU | BPF_DIV | BPF_K:
-			if (k == 1)
-				break;
-			emit_mov_i(r_scratch, k, ctx);
-			emit_udivmod(r_A, r_A, r_scratch, ctx, BPF_DIV);
-			break;
-		case BPF_ALU | BPF_DIV | BPF_X:
-			update_on_xread(ctx);
-			emit(ARM_CMP_I(r_X, 0), ctx);
-			emit_err_ret(ARM_COND_EQ, ctx);
-			emit_udivmod(r_A, r_A, r_X, ctx, BPF_DIV);
+		}
+		break;
+	/* dst = htole(dst) */
+	/* dst = htobe(dst) */
+	case BPF_ALU | BPF_END | BPF_FROM_LE:
+	case BPF_ALU | BPF_END | BPF_FROM_BE:
+		rd = dstk ? tmp[0] : dst_hi;
+		rt = dstk ? tmp[1] : dst_lo;
+		if (dstk) {
+			emit(ARM_LDR_I(rt, ARM_SP, STACK_VAR(dst_lo)), ctx);
+			emit(ARM_LDR_I(rd, ARM_SP, STACK_VAR(dst_hi)), ctx);
+		}
+		if (BPF_SRC(code) == BPF_FROM_LE)
+			goto emit_bswap_uxt;
+		switch (imm) {
+		case 16:
+			emit_rev16(rt, rt, ctx);
+			goto emit_bswap_uxt;
+		case 32:
+			emit_rev32(rt, rt, ctx);
+			goto emit_bswap_uxt;
+		case 64:
+			/* Because of the usage of ARM_LR */
+			ctx->seen |= SEEN_CALL;
+			emit_rev32(ARM_LR, rt, ctx);
+			emit_rev32(rt, rd, ctx);
+			emit(ARM_MOV_R(rd, ARM_LR), ctx);
 			break;
-		case BPF_ALU | BPF_MOD | BPF_K:
-			if (k == 1) {
-				emit_mov_i(r_A, 0, ctx);
-				break;
-			}
-			emit_mov_i(r_scratch, k, ctx);
-			emit_udivmod(r_A, r_A, r_scratch, ctx, BPF_MOD);
+		}
+		goto exit;
+emit_bswap_uxt:
+		switch (imm) {
+		case 16:
+			/* zero-extend 16 bits into 64 bits */
+#if __LINUX_ARM_ARCH__ < 6
+			emit_a32_mov_i(tmp2[1], 0xffff, false, ctx);
+			emit(ARM_AND_R(rt, rt, tmp2[1]), ctx);
+#else /* ARMv6+ */
+			emit(ARM_UXTH(rt, rt), ctx);
+#endif
+			emit(ARM_EOR_R(rd, rd, rd), ctx);
 			break;
-		case BPF_ALU | BPF_MOD | BPF_X:
-			update_on_xread(ctx);
-			emit(ARM_CMP_I(r_X, 0), ctx);
-			emit_err_ret(ARM_COND_EQ, ctx);
-			emit_udivmod(r_A, r_A, r_X, ctx, BPF_MOD);
+		case 32:
+			/* zero-extend 32 bits into 64 bits */
+			emit(ARM_EOR_R(rd, rd, rd), ctx);
 			break;
-		case BPF_ALU | BPF_OR | BPF_K:
-			/* A |= K */
-			OP_IMM3(ARM_ORR, r_A, r_A, k, ctx);
+		case 64:
+			/* nop */
 			break;
-		case BPF_ALU | BPF_OR | BPF_X:
-			update_on_xread(ctx);
-			emit(ARM_ORR_R(r_A, r_A, r_X), ctx);
+		}
+exit:
+		if (dstk) {
+			emit(ARM_STR_I(rt, ARM_SP, STACK_VAR(dst_lo)), ctx);
+			emit(ARM_STR_I(rd, ARM_SP, STACK_VAR(dst_hi)), ctx);
+		}
+		break;
+	/* dst = imm64 */
+	case BPF_LD | BPF_IMM | BPF_DW:
+	{
+		const struct bpf_insn insn1 = insn[1];
+		u32 hi, lo = imm;
+
+		hi = insn1.imm;
+		emit_a32_mov_i(dst_lo, lo, dstk, ctx);
+		emit_a32_mov_i(dst_hi, hi, dstk, ctx);
+
+		return 1;
+	}
+	/* LDX: dst = *(size *)(src + off) */
+	case BPF_LDX | BPF_MEM | BPF_W:
+	case BPF_LDX | BPF_MEM | BPF_H:
+	case BPF_LDX | BPF_MEM | BPF_B:
+	case BPF_LDX | BPF_MEM | BPF_DW:
+		rn = sstk ? tmp2[1] : src_lo;
+		if (sstk)
+			emit(ARM_LDR_I(rn, ARM_SP, STACK_VAR(src_lo)), ctx);
+		switch (BPF_SIZE(code)) {
+		case BPF_W:
+			/* Load a Word */
+		case BPF_H:
+			/* Load a Half-Word */
+		case BPF_B:
+			/* Load a Byte */
+			emit_ldx_r(dst_lo, rn, dstk, off, ctx, BPF_SIZE(code));
+			emit_a32_mov_i(dst_hi, 0, dstk, ctx);
 			break;
-		case BPF_ALU | BPF_XOR | BPF_K:
-			/* A ^= K; */
-			OP_IMM3(ARM_EOR, r_A, r_A, k, ctx);
+		case BPF_DW:
+			/* Load a double word */
+			emit_ldx_r(dst_lo, rn, dstk, off, ctx, BPF_W);
+			emit_ldx_r(dst_hi, rn, dstk, off+4, ctx, BPF_W);
 			break;
-		case BPF_ANC | SKF_AD_ALU_XOR_X:
-		case BPF_ALU | BPF_XOR | BPF_X:
-			/* A ^= X */
-			update_on_xread(ctx);
-			emit(ARM_EOR_R(r_A, r_A, r_X), ctx);
+		}
+		break;
+	/* R0 = ntohx(*(size *)(((struct sk_buff *)R6)->data + imm)) */
+	case BPF_LD | BPF_ABS | BPF_W:
+	case BPF_LD | BPF_ABS | BPF_H:
+	case BPF_LD | BPF_ABS | BPF_B:
+	/* R0 = ntohx(*(size *)(((struct sk_buff *)R6)->data + src + imm)) */
+	case BPF_LD | BPF_IND | BPF_W:
+	case BPF_LD | BPF_IND | BPF_H:
+	case BPF_LD | BPF_IND | BPF_B:
+	{
+		const u8 r4 = bpf2a32[BPF_REG_6][1]; /* r4 = ptr to sk_buff */
+		const u8 r0 = bpf2a32[BPF_REG_0][1]; /*r0: struct sk_buff *skb*/
+						     /* rtn value */
+		const u8 r1 = bpf2a32[BPF_REG_0][0]; /* r1: int k */
+		const u8 r2 = bpf2a32[BPF_REG_1][1]; /* r2: unsigned int size */
+		const u8 r3 = bpf2a32[BPF_REG_1][0]; /* r3: void *buffer */
+		const u8 r6 = bpf2a32[TMP_REG_1][1]; /* r6: void *(*func)(..) */
+		int size;
+
+		/* Setting up first argument */
+		emit(ARM_MOV_R(r0, r4), ctx);
+
+		/* Setting up second argument */
+		emit_a32_mov_i(r1, imm, false, ctx);
+		if (BPF_MODE(code) == BPF_IND)
+			emit_a32_alu_r(r1, src_lo, false, sstk, ctx,
+				       false, false, BPF_ADD);
+
+		/* Setting up third argument */
+		switch (BPF_SIZE(code)) {
+		case BPF_W:
+			size = 4;
 			break;
-		case BPF_ALU | BPF_AND | BPF_K:
-			/* A &= K */
-			OP_IMM3(ARM_AND, r_A, r_A, k, ctx);
+		case BPF_H:
+			size = 2;
 			break;
-		case BPF_ALU | BPF_AND | BPF_X:
-			update_on_xread(ctx);
-			emit(ARM_AND_R(r_A, r_A, r_X), ctx);
+		case BPF_B:
+			size = 1;
 			break;
-		case BPF_ALU | BPF_LSH | BPF_K:
-			if (unlikely(k > 31))
-				return -1;
-			emit(ARM_LSL_I(r_A, r_A, k), ctx);
+		default:
+			return -EINVAL;
+		}
+		emit_a32_mov_i(r2, size, false, ctx);
+
+		/* Setting up fourth argument */
+		emit(ARM_ADD_I(r3, ARM_SP, imm8m(SKB_BUFFER)), ctx);
+
+		/* Setting up function pointer to call */
+		emit_a32_mov_i(r6, (unsigned int)bpf_load_pointer, false, ctx);
+		emit_blx_r(r6, ctx);
+
+		emit(ARM_EOR_R(r1, r1, r1), ctx);
+		/* Check if return address is NULL or not.
+		 * if NULL then jump to epilogue
+		 * else continue to load the value from retn address
+		 */
+		emit(ARM_CMP_I(r0, 0), ctx);
+		jmp_offset = epilogue_offset(ctx);
+		check_imm24(jmp_offset);
+		_emit(ARM_COND_EQ, ARM_B(jmp_offset), ctx);
+
+		/* Load value from the address */
+		switch (BPF_SIZE(code)) {
+		case BPF_W:
+			emit(ARM_LDR_I(r0, r0, 0), ctx);
+			emit_rev32(r0, r0, ctx);
 			break;
-		case BPF_ALU | BPF_LSH | BPF_X:
-			update_on_xread(ctx);
-			emit(ARM_LSL_R(r_A, r_A, r_X), ctx);
+		case BPF_H:
+			emit(ARM_LDRH_I(r0, r0, 0), ctx);
+			emit_rev16(r0, r0, ctx);
 			break;
-		case BPF_ALU | BPF_RSH | BPF_K:
-			if (unlikely(k > 31))
-				return -1;
-			if (k)
-				emit(ARM_LSR_I(r_A, r_A, k), ctx);
+		case BPF_B:
+			emit(ARM_LDRB_I(r0, r0, 0), ctx);
+			/* No need to reverse */
 			break;
-		case BPF_ALU | BPF_RSH | BPF_X:
-			update_on_xread(ctx);
-			emit(ARM_LSR_R(r_A, r_A, r_X), ctx);
+		}
+		break;
+	}
+	/* ST: *(size *)(dst + off) = imm */
+	case BPF_ST | BPF_MEM | BPF_W:
+	case BPF_ST | BPF_MEM | BPF_H:
+	case BPF_ST | BPF_MEM | BPF_B:
+	case BPF_ST | BPF_MEM | BPF_DW:
+		switch (BPF_SIZE(code)) {
+		case BPF_DW:
+			/* Sign-extend immediate value into temp reg */
+			emit_a32_mov_i64(true, tmp2, imm, false, ctx);
+			emit_str_r(dst_lo, tmp2[1], dstk, off, ctx, BPF_W);
+			emit_str_r(dst_lo, tmp2[0], dstk, off+4, ctx, BPF_W);
 			break;
-		case BPF_ALU | BPF_NEG:
-			/* A = -A */
-			emit(ARM_RSB_I(r_A, r_A, 0), ctx);
+		case BPF_W:
+		case BPF_H:
+		case BPF_B:
+			emit_a32_mov_i(tmp2[1], imm, false, ctx);
+			emit_str_r(dst_lo, tmp2[1], dstk, off, ctx,
+				   BPF_SIZE(code));
 			break;
-		case BPF_JMP | BPF_JA:
-			/* pc += K */
-			emit(ARM_B(b_imm(i + k + 1, ctx)), ctx);
+		}
+		break;
+	/* STX XADD: lock *(u32 *)(dst + off) += src */
+	case BPF_STX | BPF_XADD | BPF_W:
+	/* STX XADD: lock *(u64 *)(dst + off) += src */
+	case BPF_STX | BPF_XADD | BPF_DW:
+		goto notyet;
+	/* STX: *(size *)(dst + off) = src */
+	case BPF_STX | BPF_MEM | BPF_W:
+	case BPF_STX | BPF_MEM | BPF_H:
+	case BPF_STX | BPF_MEM | BPF_B:
+	case BPF_STX | BPF_MEM | BPF_DW:
+	{
+		u8 sz = BPF_SIZE(code);
+
+		rn = sstk ? tmp2[1] : src_lo;
+		rm = sstk ? tmp2[0] : src_hi;
+		if (sstk) {
+			emit(ARM_LDR_I(rn, ARM_SP, STACK_VAR(src_lo)), ctx);
+			emit(ARM_LDR_I(rm, ARM_SP, STACK_VAR(src_hi)), ctx);
+		}
+
+		/* Store the value */
+		if (BPF_SIZE(code) == BPF_DW) {
+			emit_str_r(dst_lo, rn, dstk, off, ctx, BPF_W);
+			emit_str_r(dst_lo, rm, dstk, off+4, ctx, BPF_W);
+		} else {
+			emit_str_r(dst_lo, rn, dstk, off, ctx, sz);
+		}
+		break;
+	}
+	/* PC += off if dst == src */
+	/* PC += off if dst > src */
+	/* PC += off if dst >= src */
+	/* PC += off if dst < src */
+	/* PC += off if dst <= src */
+	/* PC += off if dst != src */
+	/* PC += off if dst > src (signed) */
+	/* PC += off if dst >= src (signed) */
+	/* PC += off if dst < src (signed) */
+	/* PC += off if dst <= src (signed) */
+	/* PC += off if dst & src */
+	case BPF_JMP | BPF_JEQ | BPF_X:
+	case BPF_JMP | BPF_JGT | BPF_X:
+	case BPF_JMP | BPF_JGE | BPF_X:
+	case BPF_JMP | BPF_JNE | BPF_X:
+	case BPF_JMP | BPF_JSGT | BPF_X:
+	case BPF_JMP | BPF_JSGE | BPF_X:
+	case BPF_JMP | BPF_JSET | BPF_X:
+	case BPF_JMP | BPF_JLE | BPF_X:
+	case BPF_JMP | BPF_JLT | BPF_X:
+	case BPF_JMP | BPF_JSLT | BPF_X:
+	case BPF_JMP | BPF_JSLE | BPF_X:
+		/* Setup source registers */
+		rm = sstk ? tmp2[0] : src_hi;
+		rn = sstk ? tmp2[1] : src_lo;
+		if (sstk) {
+			emit(ARM_LDR_I(rn, ARM_SP, STACK_VAR(src_lo)), ctx);
+			emit(ARM_LDR_I(rm, ARM_SP, STACK_VAR(src_hi)), ctx);
+		}
+		goto go_jmp;
+	/* PC += off if dst == imm */
+	/* PC += off if dst > imm */
+	/* PC += off if dst >= imm */
+	/* PC += off if dst < imm */
+	/* PC += off if dst <= imm */
+	/* PC += off if dst != imm */
+	/* PC += off if dst > imm (signed) */
+	/* PC += off if dst >= imm (signed) */
+	/* PC += off if dst < imm (signed) */
+	/* PC += off if dst <= imm (signed) */
+	/* PC += off if dst & imm */
+	case BPF_JMP | BPF_JEQ | BPF_K:
+	case BPF_JMP | BPF_JGT | BPF_K:
+	case BPF_JMP | BPF_JGE | BPF_K:
+	case BPF_JMP | BPF_JNE | BPF_K:
+	case BPF_JMP | BPF_JSGT | BPF_K:
+	case BPF_JMP | BPF_JSGE | BPF_K:
+	case BPF_JMP | BPF_JSET | BPF_K:
+	case BPF_JMP | BPF_JLT | BPF_K:
+	case BPF_JMP | BPF_JLE | BPF_K:
+	case BPF_JMP | BPF_JSLT | BPF_K:
+	case BPF_JMP | BPF_JSLE | BPF_K:
+		if (off == 0)
 			break;
-		case BPF_JMP | BPF_JEQ | BPF_K:
-			/* pc += (A == K) ? pc->jt : pc->jf */
-			condt  = ARM_COND_EQ;
-			goto cmp_imm;
-		case BPF_JMP | BPF_JGT | BPF_K:
-			/* pc += (A > K) ? pc->jt : pc->jf */
-			condt  = ARM_COND_HI;
-			goto cmp_imm;
-		case BPF_JMP | BPF_JGE | BPF_K:
-			/* pc += (A >= K) ? pc->jt : pc->jf */
-			condt  = ARM_COND_HS;
-cmp_imm:
-			imm12 = imm8m(k);
-			if (imm12 < 0) {
-				emit_mov_i_no8m(r_scratch, k, ctx);
-				emit(ARM_CMP_R(r_A, r_scratch), ctx);
-			} else {
-				emit(ARM_CMP_I(r_A, imm12), ctx);
-			}
-cond_jump:
-			if (inst->jt)
-				_emit(condt, ARM_B(b_imm(i + inst->jt + 1,
-						   ctx)), ctx);
-			if (inst->jf)
-				_emit(condt ^ 1, ARM_B(b_imm(i + inst->jf + 1,
-							     ctx)), ctx);
+		rm = tmp2[0];
+		rn = tmp2[1];
+		/* Sign-extend immediate value */
+		emit_a32_mov_i64(true, tmp2, imm, false, ctx);
+go_jmp:
+		/* Setup destination register */
+		rd = dstk ? tmp[0] : dst_hi;
+		rt = dstk ? tmp[1] : dst_lo;
+		if (dstk) {
+			emit(ARM_LDR_I(rt, ARM_SP, STACK_VAR(dst_lo)), ctx);
+			emit(ARM_LDR_I(rd, ARM_SP, STACK_VAR(dst_hi)), ctx);
+		}
+
+		/* Check for the condition */
+		emit_ar_r(rd, rt, rm, rn, ctx, BPF_OP(code));
+
+		/* Setup JUMP instruction */
+		jmp_offset = bpf2a32_offset(i+off, i, ctx);
+		switch (BPF_OP(code)) {
+		case BPF_JNE:
+		case BPF_JSET:
+			_emit(ARM_COND_NE, ARM_B(jmp_offset), ctx);
 			break;
-		case BPF_JMP | BPF_JEQ | BPF_X:
-			/* pc += (A == X) ? pc->jt : pc->jf */
-			condt   = ARM_COND_EQ;
-			goto cmp_x;
-		case BPF_JMP | BPF_JGT | BPF_X:
-			/* pc += (A > X) ? pc->jt : pc->jf */
-			condt   = ARM_COND_HI;
-			goto cmp_x;
-		case BPF_JMP | BPF_JGE | BPF_X:
-			/* pc += (A >= X) ? pc->jt : pc->jf */
-			condt   = ARM_COND_CS;
-cmp_x:
-			update_on_xread(ctx);
-			emit(ARM_CMP_R(r_A, r_X), ctx);
-			goto cond_jump;
-		case BPF_JMP | BPF_JSET | BPF_K:
-			/* pc += (A & K) ? pc->jt : pc->jf */
-			condt  = ARM_COND_NE;
-			/* not set iff all zeroes iff Z==1 iff EQ */
-
-			imm12 = imm8m(k);
-			if (imm12 < 0) {
-				emit_mov_i_no8m(r_scratch, k, ctx);
-				emit(ARM_TST_R(r_A, r_scratch), ctx);
-			} else {
-				emit(ARM_TST_I(r_A, imm12), ctx);
-			}
-			goto cond_jump;
-		case BPF_JMP | BPF_JSET | BPF_X:
-			/* pc += (A & X) ? pc->jt : pc->jf */
-			update_on_xread(ctx);
-			condt  = ARM_COND_NE;
-			emit(ARM_TST_R(r_A, r_X), ctx);
-			goto cond_jump;
-		case BPF_RET | BPF_A:
-			emit(ARM_MOV_R(ARM_R0, r_A), ctx);
-			goto b_epilogue;
-		case BPF_RET | BPF_K:
-			if ((k == 0) && (ctx->ret0_fp_idx < 0))
-				ctx->ret0_fp_idx = i;
-			emit_mov_i(ARM_R0, k, ctx);
-b_epilogue:
-			if (i != ctx->skf->len - 1)
-				emit(ARM_B(b_imm(prog->len, ctx)), ctx);
+		case BPF_JEQ:
+			_emit(ARM_COND_EQ, ARM_B(jmp_offset), ctx);
 			break;
-		case BPF_MISC | BPF_TAX:
-			/* X = A */
-			ctx->seen |= SEEN_X;
-			emit(ARM_MOV_R(r_X, r_A), ctx);
+		case BPF_JGT:
+			_emit(ARM_COND_HI, ARM_B(jmp_offset), ctx);
 			break;
-		case BPF_MISC | BPF_TXA:
-			/* A = X */
-			update_on_xread(ctx);
-			emit(ARM_MOV_R(r_A, r_X), ctx);
+		case BPF_JGE:
+			_emit(ARM_COND_CS, ARM_B(jmp_offset), ctx);
 			break;
-		case BPF_ANC | SKF_AD_PROTOCOL:
-			/* A = ntohs(skb->protocol) */
-			ctx->seen |= SEEN_SKB;
-			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
-						  protocol) != 2);
-			off = offsetof(struct sk_buff, protocol);
-			emit(ARM_LDRH_I(r_scratch, r_skb, off), ctx);
-			emit_swap16(r_A, r_scratch, ctx);
+		case BPF_JSGT:
+			_emit(ARM_COND_LT, ARM_B(jmp_offset), ctx);
 			break;
-		case BPF_ANC | SKF_AD_CPU:
-			/* r_scratch = current_thread_info() */
-			OP_IMM3(ARM_BIC, r_scratch, ARM_SP, THREAD_SIZE - 1, ctx);
-			/* A = current_thread_info()->cpu */
-			BUILD_BUG_ON(FIELD_SIZEOF(struct thread_info, cpu) != 4);
-			off = offsetof(struct thread_info, cpu);
-			emit(ARM_LDR_I(r_A, r_scratch, off), ctx);
+		case BPF_JSGE:
+			_emit(ARM_COND_GE, ARM_B(jmp_offset), ctx);
 			break;
-		case BPF_ANC | SKF_AD_IFINDEX:
-		case BPF_ANC | SKF_AD_HATYPE:
-			/* A = skb->dev->ifindex */
-			/* A = skb->dev->type */
-			ctx->seen |= SEEN_SKB;
-			off = offsetof(struct sk_buff, dev);
-			emit(ARM_LDR_I(r_scratch, r_skb, off), ctx);
-
-			emit(ARM_CMP_I(r_scratch, 0), ctx);
-			emit_err_ret(ARM_COND_EQ, ctx);
-
-			BUILD_BUG_ON(FIELD_SIZEOF(struct net_device,
-						  ifindex) != 4);
-			BUILD_BUG_ON(FIELD_SIZEOF(struct net_device,
-						  type) != 2);
-
-			if (code == (BPF_ANC | SKF_AD_IFINDEX)) {
-				off = offsetof(struct net_device, ifindex);
-				emit(ARM_LDR_I(r_A, r_scratch, off), ctx);
-			} else {
-				/*
-				 * offset of field "type" in "struct
-				 * net_device" is above what can be
-				 * used in the ldrh rd, [rn, #imm]
-				 * instruction, so load the offset in
-				 * a register and use ldrh rd, [rn, rm]
-				 */
-				off = offsetof(struct net_device, type);
-				emit_mov_i(ARM_R3, off, ctx);
-				emit(ARM_LDRH_R(r_A, r_scratch, ARM_R3), ctx);
-			}
+		case BPF_JLE:
+			_emit(ARM_COND_LS, ARM_B(jmp_offset), ctx);
 			break;
-		case BPF_ANC | SKF_AD_MARK:
-			ctx->seen |= SEEN_SKB;
-			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, mark) != 4);
-			off = offsetof(struct sk_buff, mark);
-			emit(ARM_LDR_I(r_A, r_skb, off), ctx);
+		case BPF_JLT:
+			_emit(ARM_COND_CC, ARM_B(jmp_offset), ctx);
 			break;
-		case BPF_ANC | SKF_AD_RXHASH:
-			ctx->seen |= SEEN_SKB;
-			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, hash) != 4);
-			off = offsetof(struct sk_buff, hash);
-			emit(ARM_LDR_I(r_A, r_skb, off), ctx);
+		case BPF_JSLT:
+			_emit(ARM_COND_LT, ARM_B(jmp_offset), ctx);
 			break;
-		case BPF_ANC | SKF_AD_VLAN_TAG:
-		case BPF_ANC | SKF_AD_VLAN_TAG_PRESENT:
-			ctx->seen |= SEEN_SKB;
-			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, vlan_tci) != 2);
-			off = offsetof(struct sk_buff, vlan_tci);
-			emit(ARM_LDRH_I(r_A, r_skb, off), ctx);
-			if (code == (BPF_ANC | SKF_AD_VLAN_TAG))
-				OP_IMM3(ARM_AND, r_A, r_A, ~VLAN_TAG_PRESENT, ctx);
-			else {
-				OP_IMM3(ARM_LSR, r_A, r_A, 12, ctx);
-				OP_IMM3(ARM_AND, r_A, r_A, 0x1, ctx);
-			}
+		case BPF_JSLE:
+			_emit(ARM_COND_GE, ARM_B(jmp_offset), ctx);
 			break;
-		case BPF_ANC | SKF_AD_PKTTYPE:
-			ctx->seen |= SEEN_SKB;
-			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
-						  __pkt_type_offset[0]) != 1);
-			off = PKT_TYPE_OFFSET();
-			emit(ARM_LDRB_I(r_A, r_skb, off), ctx);
-			emit(ARM_AND_I(r_A, r_A, PKT_TYPE_MAX), ctx);
-#ifdef __BIG_ENDIAN_BITFIELD
-			emit(ARM_LSR_I(r_A, r_A, 5), ctx);
-#endif
+		}
+		break;
+	/* JMP OFF */
+	case BPF_JMP | BPF_JA:
+	{
+		if (off == 0)
 			break;
-		case BPF_ANC | SKF_AD_QUEUE:
-			ctx->seen |= SEEN_SKB;
-			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff,
-						  queue_mapping) != 2);
-			BUILD_BUG_ON(offsetof(struct sk_buff,
-					      queue_mapping) > 0xff);
-			off = offsetof(struct sk_buff, queue_mapping);
-			emit(ARM_LDRH_I(r_A, r_skb, off), ctx);
+		jmp_offset = bpf2a32_offset(i+off, i, ctx);
+		check_imm24(jmp_offset);
+		emit(ARM_B(jmp_offset), ctx);
+		break;
+	}
+	/* tail call */
+	case BPF_JMP | BPF_TAIL_CALL:
+		if (emit_bpf_tail_call(ctx))
+			return -EFAULT;
+		break;
+	/* function call */
+	case BPF_JMP | BPF_CALL:
+	{
+		const u8 *r0 = bpf2a32[BPF_REG_0];
+		const u8 *r1 = bpf2a32[BPF_REG_1];
+		const u8 *r2 = bpf2a32[BPF_REG_2];
+		const u8 *r3 = bpf2a32[BPF_REG_3];
+		const u8 *r4 = bpf2a32[BPF_REG_4];
+		const u8 *r5 = bpf2a32[BPF_REG_5];
+		const u32 func = (u32)__bpf_call_base + (u32)imm;
+
+		emit_a32_mov_r64(true, r0, r1, false, false, ctx);
+		emit_a32_mov_r64(true, r1, r2, false, true, ctx);
+		emit_push_r64(r5, 0, ctx);
+		emit_push_r64(r4, 8, ctx);
+		emit_push_r64(r3, 16, ctx);
+
+		emit_a32_mov_i(tmp[1], func, false, ctx);
+		emit_blx_r(tmp[1], ctx);
+
+		emit(ARM_ADD_I(ARM_SP, ARM_SP, imm8m(24)), ctx); // callee clean
+		break;
+	}
+	/* function return */
+	case BPF_JMP | BPF_EXIT:
+		/* Optimization: when last instruction is EXIT
+		 * simply fallthrough to epilogue.
+		 */
+		if (i == ctx->prog->len - 1)
 			break;
-		case BPF_ANC | SKF_AD_PAY_OFFSET:
-			ctx->seen |= SEEN_SKB | SEEN_CALL;
+		jmp_offset = epilogue_offset(ctx);
+		check_imm24(jmp_offset);
+		emit(ARM_B(jmp_offset), ctx);
+		break;
+notyet:
+		pr_info_once("*** NOT YET: opcode %02x ***\n", code);
+		return -EFAULT;
+	default:
+		pr_err_once("unknown opcode %02x\n", code);
+		return -EINVAL;
+	}
 
-			emit(ARM_MOV_R(ARM_R0, r_skb), ctx);
-			emit_mov_i(ARM_R3, (unsigned int)skb_get_poff, ctx);
-			emit_blx_r(ARM_R3, ctx);
-			emit(ARM_MOV_R(r_A, ARM_R0), ctx);
-			break;
-		case BPF_LDX | BPF_W | BPF_ABS:
-			/*
-			 * load a 32bit word from struct seccomp_data.
-			 * seccomp_check_filter() will already have checked
-			 * that k is 32bit aligned and lies within the
-			 * struct seccomp_data.
-			 */
-			ctx->seen |= SEEN_SKB;
-			emit(ARM_LDR_I(r_A, r_skb, k), ctx);
-			break;
-		default:
-			return -1;
+	if (ctx->flags & FLAG_IMM_OVERFLOW)
+		/*
+		 * this instruction generated an overflow when
+		 * trying to access the literal pool, so
+		 * delegate this filter to the kernel interpreter.
+		 */
+		return -1;
+	return 0;
+}
+
+static int build_body(struct jit_ctx *ctx)
+{
+	const struct bpf_prog *prog = ctx->prog;
+	unsigned int i;
+
+	for (i = 0; i < prog->len; i++) {
+		const struct bpf_insn *insn = &(prog->insnsi[i]);
+		int ret;
+
+		ret = build_insn(insn, ctx);
+
+		/* It's used with loading the 64 bit immediate value. */
+		if (ret > 0) {
+			i++;
+			if (ctx->target == NULL)
+				ctx->offsets[i] = ctx->idx;
+			continue;
 		}
 
-		if (ctx->flags & FLAG_IMM_OVERFLOW)
-			/*
-			 * this instruction generated an overflow when
-			 * trying to access the literal pool, so
-			 * delegate this filter to the kernel interpreter.
-			 */
-			return -1;
+		if (ctx->target == NULL)
+			ctx->offsets[i] = ctx->idx;
+
+		/* If unsuccesfull, return with error code */
+		if (ret)
+			return ret;
 	}
+	return 0;
+}
 
-	/* compute offsets only during the first pass */
-	if (ctx->target == NULL)
-		ctx->offsets[i] = ctx->idx * 4;
+static int validate_code(struct jit_ctx *ctx)
+{
+	int i;
+
+	for (i = 0; i < ctx->idx; i++) {
+		if (ctx->target[i] == __opcode_to_mem_arm(ARM_INST_UDF))
+			return -1;
+	}
 
 	return 0;
 }
 
+void bpf_jit_compile(struct bpf_prog *prog)
+{
+	/* Nothing to do here. We support Internal BPF. */
+}
 
-void bpf_jit_compile(struct bpf_prog *fp)
+struct bpf_prog *bpf_int_jit_compile(struct bpf_prog *prog)
 {
+	struct bpf_prog *tmp, *orig_prog = prog;
 	struct bpf_binary_header *header;
+	bool tmp_blinded = false;
 	struct jit_ctx ctx;
-	unsigned tmp_idx;
-	unsigned alloc_size;
-	u8 *target_ptr;
+	unsigned int tmp_idx;
+	unsigned int image_size;
+	u8 *image_ptr;
 
+	/* If BPF JIT was not enabled then we must fall back to
+	 * the interpreter.
+	 */
 	if (!bpf_jit_enable)
-		return;
+		return orig_prog;
 
-	memset(&ctx, 0, sizeof(ctx));
-	ctx.skf		= fp;
-	ctx.ret0_fp_idx = -1;
+	/* If constant blinding was enabled and we failed during blinding
+	 * then we must fall back to the interpreter. Otherwise, we save
+	 * the new JITed code.
+	 */
+	tmp = bpf_jit_blind_constants(prog);
 
-	ctx.offsets = kzalloc(4 * (ctx.skf->len + 1), GFP_KERNEL);
-	if (ctx.offsets == NULL)
-		return;
+	if (IS_ERR(tmp))
+		return orig_prog;
+	if (tmp != prog) {
+		tmp_blinded = true;
+		prog = tmp;
+	}
 
-	/* fake pass to fill in the ctx->seen */
-	if (unlikely(build_body(&ctx)))
+	memset(&ctx, 0, sizeof(ctx));
+	ctx.prog = prog;
+
+	/* Not able to allocate memory for offsets[] , then
+	 * we must fall back to the interpreter
+	 */
+	ctx.offsets = kcalloc(prog->len, sizeof(int), GFP_KERNEL);
+	if (ctx.offsets == NULL) {
+		prog = orig_prog;
 		goto out;
+	}
+
+	/* 1) fake pass to find in the length of the JITed code,
+	 * to compute ctx->offsets and other context variables
+	 * needed to compute final JITed code.
+	 * Also, calculate random starting pointer/start of JITed code
+	 * which is prefixed by random number of fault instructions.
+	 *
+	 * If the first pass fails then there is no chance of it
+	 * being successful in the second pass, so just fall back
+	 * to the interpreter.
+	 */
+	if (build_body(&ctx)) {
+		prog = orig_prog;
+		goto out_off;
+	}
 
 	tmp_idx = ctx.idx;
 	build_prologue(&ctx);
 	ctx.prologue_bytes = (ctx.idx - tmp_idx) * 4;
 
+	ctx.epilogue_offset = ctx.idx;
+
 #if __LINUX_ARM_ARCH__ < 7
 	tmp_idx = ctx.idx;
 	build_epilogue(&ctx);
@@ -1021,64 +1880,83 @@ void bpf_jit_compile(struct bpf_prog *fp)
 
 	ctx.idx += ctx.imm_count;
 	if (ctx.imm_count) {
-		ctx.imms = kzalloc(4 * ctx.imm_count, GFP_KERNEL);
-		if (ctx.imms == NULL)
-			goto out;
+		ctx.imms = kcalloc(ctx.imm_count, sizeof(u32), GFP_KERNEL);
+		if (ctx.imms == NULL) {
+			prog = orig_prog;
+			goto out_off;
+		}
 	}
 #else
-	/* there's nothing after the epilogue on ARMv7 */
+	/* there's nothing about the epilogue on ARMv7 */
 	build_epilogue(&ctx);
 #endif
-	alloc_size = 4 * ctx.idx;
-	header = bpf_jit_binary_alloc(alloc_size, &target_ptr,
-				      4, jit_fill_hole);
-	if (header == NULL)
-		goto out;
+	/* Now we can get the actual image size of the JITed arm code.
+	 * Currently, we are not considering the THUMB-2 instructions
+	 * for jit, although it can decrease the size of the image.
+	 *
+	 * As each arm instruction is of length 32bit, we are translating
+	 * number of JITed intructions into the size required to store these
+	 * JITed code.
+	 */
+	image_size = sizeof(u32) * ctx.idx;
 
-	ctx.target = (u32 *) target_ptr;
+	/* Now we know the size of the structure to make */
+	header = bpf_jit_binary_alloc(image_size, &image_ptr,
+				      sizeof(u32), jit_fill_hole);
+	/* Not able to allocate memory for the structure then
+	 * we must fall back to the interpretation
+	 */
+	if (header == NULL) {
+		prog = orig_prog;
+		goto out_imms;
+	}
+
+	/* 2.) Actual pass to generate final JIT code */
+	ctx.target = (u32 *) image_ptr;
 	ctx.idx = 0;
 
 	build_prologue(&ctx);
+
+	/* If building the body of the JITed code fails somehow,
+	 * we fall back to the interpretation.
+	 */
 	if (build_body(&ctx) < 0) {
-#if __LINUX_ARM_ARCH__ < 7
-		if (ctx.imm_count)
-			kfree(ctx.imms);
-#endif
+		image_ptr = NULL;
 		bpf_jit_binary_free(header);
-		goto out;
+		prog = orig_prog;
+		goto out_imms;
 	}
 	build_epilogue(&ctx);
 
+	/* 3.) Extra pass to validate JITed Code */
+	if (validate_code(&ctx)) {
+		image_ptr = NULL;
+		bpf_jit_binary_free(header);
+		prog = orig_prog;
+		goto out_imms;
+	}
 	flush_icache_range((u32)header, (u32)(ctx.target + ctx.idx));
 
-#if __LINUX_ARM_ARCH__ < 7
-	if (ctx.imm_count)
-		kfree(ctx.imms);
-#endif
-
 	if (bpf_jit_enable > 1)
 		/* there are 2 passes here */
-		bpf_jit_dump(fp->len, alloc_size, 2, ctx.target);
+		bpf_jit_dump(prog->len, image_size, 2, ctx.target);
 
 	set_memory_ro((unsigned long)header, header->pages);
-	fp->bpf_func = (void *)ctx.target;
-	fp->jited = 1;
-out:
+	prog->bpf_func = (void *)ctx.target;
+	prog->jited = 1;
+	prog->jited_len = image_size;
+
+out_imms:
+#if __LINUX_ARM_ARCH__ < 7
+	if (ctx.imm_count)
+		kfree(ctx.imms);
+#endif
+out_off:
 	kfree(ctx.offsets);
-	return;
+out:
+	if (tmp_blinded)
+		bpf_jit_prog_release_other(prog, prog == orig_prog ?
+					   tmp : orig_prog);
+	return prog;
 }
 
-void bpf_jit_free(struct bpf_prog *fp)
-{
-	unsigned long addr = (unsigned long)fp->bpf_func & PAGE_MASK;
-	struct bpf_binary_header *header = (void *)addr;
-
-	if (!fp->jited)
-		goto free_filter;
-
-	set_memory_rw(addr, header->pages);
-	bpf_jit_binary_free(header);
-
-free_filter:
-	bpf_prog_unlock_free(fp);
-}
diff --git a/arch/arm/net/bpf_jit_32.h b/arch/arm/net/bpf_jit_32.h
index c46fca2..d5cf5f6 100644
--- a/arch/arm/net/bpf_jit_32.h
+++ b/arch/arm/net/bpf_jit_32.h
@@ -11,6 +11,7 @@
 #ifndef PFILTER_OPCODES_ARM_H
 #define PFILTER_OPCODES_ARM_H
 
+/* ARM 32bit Registers */
 #define ARM_R0	0
 #define ARM_R1	1
 #define ARM_R2	2
@@ -22,38 +23,43 @@
 #define ARM_R8	8
 #define ARM_R9	9
 #define ARM_R10	10
-#define ARM_FP	11
-#define ARM_IP	12
-#define ARM_SP	13
-#define ARM_LR	14
-#define ARM_PC	15
-
-#define ARM_COND_EQ		0x0
-#define ARM_COND_NE		0x1
-#define ARM_COND_CS		0x2
+#define ARM_FP	11	/* Frame Pointer */
+#define ARM_IP	12	/* Intra-procedure scratch register */
+#define ARM_SP	13	/* Stack pointer: as load/store base reg */
+#define ARM_LR	14	/* Link Register */
+#define ARM_PC	15	/* Program counter */
+
+#define ARM_COND_EQ		0x0	/* == */
+#define ARM_COND_NE		0x1	/* != */
+#define ARM_COND_CS		0x2	/* unsigned >= */
 #define ARM_COND_HS		ARM_COND_CS
-#define ARM_COND_CC		0x3
+#define ARM_COND_CC		0x3	/* unsigned < */
 #define ARM_COND_LO		ARM_COND_CC
-#define ARM_COND_MI		0x4
-#define ARM_COND_PL		0x5
-#define ARM_COND_VS		0x6
-#define ARM_COND_VC		0x7
-#define ARM_COND_HI		0x8
-#define ARM_COND_LS		0x9
-#define ARM_COND_GE		0xa
-#define ARM_COND_LT		0xb
-#define ARM_COND_GT		0xc
-#define ARM_COND_LE		0xd
-#define ARM_COND_AL		0xe
+#define ARM_COND_MI		0x4	/* < 0 */
+#define ARM_COND_PL		0x5	/* >= 0 */
+#define ARM_COND_VS		0x6	/* Signed Overflow */
+#define ARM_COND_VC		0x7	/* No Signed Overflow */
+#define ARM_COND_HI		0x8	/* unsigned > */
+#define ARM_COND_LS		0x9	/* unsigned <= */
+#define ARM_COND_GE		0xa	/* Signed >= */
+#define ARM_COND_LT		0xb	/* Signed < */
+#define ARM_COND_GT		0xc	/* Signed > */
+#define ARM_COND_LE		0xd	/* Signed <= */
+#define ARM_COND_AL		0xe	/* None */
 
 /* register shift types */
 #define SRTYPE_LSL		0
 #define SRTYPE_LSR		1
 #define SRTYPE_ASR		2
 #define SRTYPE_ROR		3
+#define SRTYPE_ASL		(SRTYPE_LSL)
 
 #define ARM_INST_ADD_R		0x00800000
+#define ARM_INST_ADDS_R		0x00900000
+#define ARM_INST_ADC_R		0x00a00000
+#define ARM_INST_ADC_I		0x02a00000
 #define ARM_INST_ADD_I		0x02800000
+#define ARM_INST_ADDS_I		0x02900000
 
 #define ARM_INST_AND_R		0x00000000
 #define ARM_INST_AND_I		0x02000000
@@ -76,8 +82,10 @@
 #define ARM_INST_LDRH_I		0x01d000b0
 #define ARM_INST_LDRH_R		0x019000b0
 #define ARM_INST_LDR_I		0x05900000
+#define ARM_INST_LDR_R		0x07900000
 
 #define ARM_INST_LDM		0x08900000
+#define ARM_INST_LDM_IA		0x08b00000
 
 #define ARM_INST_LSL_I		0x01a00000
 #define ARM_INST_LSL_R		0x01a00010
@@ -86,6 +94,7 @@
 #define ARM_INST_LSR_R		0x01a00030
 
 #define ARM_INST_MOV_R		0x01a00000
+#define ARM_INST_MOVS_R		0x01b00000
 #define ARM_INST_MOV_I		0x03a00000
 #define ARM_INST_MOVW		0x03000000
 #define ARM_INST_MOVT		0x03400000
@@ -96,17 +105,28 @@
 #define ARM_INST_PUSH		0x092d0000
 
 #define ARM_INST_ORR_R		0x01800000
+#define ARM_INST_ORRS_R		0x01900000
 #define ARM_INST_ORR_I		0x03800000
 
 #define ARM_INST_REV		0x06bf0f30
 #define ARM_INST_REV16		0x06bf0fb0
 
 #define ARM_INST_RSB_I		0x02600000
+#define ARM_INST_RSBS_I		0x02700000
+#define ARM_INST_RSC_I		0x02e00000
 
 #define ARM_INST_SUB_R		0x00400000
+#define ARM_INST_SUBS_R		0x00500000
+#define ARM_INST_RSB_R		0x00600000
 #define ARM_INST_SUB_I		0x02400000
+#define ARM_INST_SUBS_I		0x02500000
+#define ARM_INST_SBC_I		0x02c00000
+#define ARM_INST_SBC_R		0x00c00000
+#define ARM_INST_SBCS_R		0x00d00000
 
 #define ARM_INST_STR_I		0x05800000
+#define ARM_INST_STRB_I		0x05c00000
+#define ARM_INST_STRH_I		0x01c000b0
 
 #define ARM_INST_TST_R		0x01100000
 #define ARM_INST_TST_I		0x03100000
@@ -117,6 +137,8 @@
 
 #define ARM_INST_MLS		0x00600090
 
+#define ARM_INST_UXTH		0x06ff0070
+
 /*
  * Use a suitable undefined instruction to use for ARM/Thumb2 faulting.
  * We need to be careful not to conflict with those used by other modules
@@ -135,9 +157,15 @@
 #define _AL3_R(op, rd, rn, rm)	((op ## _R) | (rd) << 12 | (rn) << 16 | (rm))
 /* immediate */
 #define _AL3_I(op, rd, rn, imm)	((op ## _I) | (rd) << 12 | (rn) << 16 | (imm))
+/* register with register-shift */
+#define _AL3_SR(inst)	(inst | (1 << 4))
 
 #define ARM_ADD_R(rd, rn, rm)	_AL3_R(ARM_INST_ADD, rd, rn, rm)
+#define ARM_ADDS_R(rd, rn, rm)	_AL3_R(ARM_INST_ADDS, rd, rn, rm)
 #define ARM_ADD_I(rd, rn, imm)	_AL3_I(ARM_INST_ADD, rd, rn, imm)
+#define ARM_ADDS_I(rd, rn, imm)	_AL3_I(ARM_INST_ADDS, rd, rn, imm)
+#define ARM_ADC_R(rd, rn, rm)	_AL3_R(ARM_INST_ADC, rd, rn, rm)
+#define ARM_ADC_I(rd, rn, imm)	_AL3_I(ARM_INST_ADC, rd, rn, imm)
 
 #define ARM_AND_R(rd, rn, rm)	_AL3_R(ARM_INST_AND, rd, rn, rm)
 #define ARM_AND_I(rd, rn, imm)	_AL3_I(ARM_INST_AND, rd, rn, imm)
@@ -156,7 +184,9 @@
 #define ARM_EOR_I(rd, rn, imm)	_AL3_I(ARM_INST_EOR, rd, rn, imm)
 
 #define ARM_LDR_I(rt, rn, off)	(ARM_INST_LDR_I | (rt) << 12 | (rn) << 16 \
-				 | (off))
+				 | ((off) & 0xfff))
+#define ARM_LDR_R(rt, rn, rm)	(ARM_INST_LDR_R | (rt) << 12 | (rn) << 16 \
+				 | (rm))
 #define ARM_LDRB_I(rt, rn, off)	(ARM_INST_LDRB_I | (rt) << 12 | (rn) << 16 \
 				 | (off))
 #define ARM_LDRB_R(rt, rn, rm)	(ARM_INST_LDRB_R | (rt) << 12 | (rn) << 16 \
@@ -167,15 +197,23 @@
 				 | (rm))
 
 #define ARM_LDM(rn, regs)	(ARM_INST_LDM | (rn) << 16 | (regs))
+#define ARM_LDM_IA(rn, regs)	(ARM_INST_LDM_IA | (rn) << 16 | (regs))
 
 #define ARM_LSL_R(rd, rn, rm)	(_AL3_R(ARM_INST_LSL, rd, 0, rn) | (rm) << 8)
 #define ARM_LSL_I(rd, rn, imm)	(_AL3_I(ARM_INST_LSL, rd, 0, rn) | (imm) << 7)
 
 #define ARM_LSR_R(rd, rn, rm)	(_AL3_R(ARM_INST_LSR, rd, 0, rn) | (rm) << 8)
 #define ARM_LSR_I(rd, rn, imm)	(_AL3_I(ARM_INST_LSR, rd, 0, rn) | (imm) << 7)
+#define ARM_ASR_R(rd, rn, rm)   (_AL3_R(ARM_INST_ASR, rd, 0, rn) | (rm) << 8)
+#define ARM_ASR_I(rd, rn, imm)  (_AL3_I(ARM_INST_ASR, rd, 0, rn) | (imm) << 7)
 
 #define ARM_MOV_R(rd, rm)	_AL3_R(ARM_INST_MOV, rd, 0, rm)
+#define ARM_MOVS_R(rd, rm)	_AL3_R(ARM_INST_MOVS, rd, 0, rm)
 #define ARM_MOV_I(rd, imm)	_AL3_I(ARM_INST_MOV, rd, 0, imm)
+#define ARM_MOV_SR(rd, rm, type, rs)	\
+	(_AL3_SR(ARM_MOV_R(rd, rm)) | (type) << 5 | (rs) << 8)
+#define ARM_MOV_SI(rd, rm, type, imm6)	\
+	(ARM_MOV_R(rd, rm) | (type) << 5 | (imm6) << 7)
 
 #define ARM_MOVW(rd, imm)	\
 	(ARM_INST_MOVW | ((imm) >> 12) << 16 | (rd) << 12 | ((imm) & 0x0fff))
@@ -190,19 +228,38 @@
 
 #define ARM_ORR_R(rd, rn, rm)	_AL3_R(ARM_INST_ORR, rd, rn, rm)
 #define ARM_ORR_I(rd, rn, imm)	_AL3_I(ARM_INST_ORR, rd, rn, imm)
-#define ARM_ORR_S(rd, rn, rm, type, rs)	\
-	(ARM_ORR_R(rd, rn, rm) | (type) << 5 | (rs) << 7)
+#define ARM_ORR_SR(rd, rn, rm, type, rs)	\
+	(_AL3_SR(ARM_ORR_R(rd, rn, rm)) | (type) << 5 | (rs) << 8)
+#define ARM_ORRS_R(rd, rn, rm)	_AL3_R(ARM_INST_ORRS, rd, rn, rm)
+#define ARM_ORRS_SR(rd, rn, rm, type, rs)	\
+	(_AL3_SR(ARM_ORRS_R(rd, rn, rm)) | (type) << 5 | (rs) << 8)
+#define ARM_ORR_SI(rd, rn, rm, type, imm6)	\
+	(ARM_ORR_R(rd, rn, rm) | (type) << 5 | (imm6) << 7)
+#define ARM_ORRS_SI(rd, rn, rm, type, imm6)	\
+	(ARM_ORRS_R(rd, rn, rm) | (type) << 5 | (imm6) << 7)
 
 #define ARM_REV(rd, rm)		(ARM_INST_REV | (rd) << 12 | (rm))
 #define ARM_REV16(rd, rm)	(ARM_INST_REV16 | (rd) << 12 | (rm))
 
 #define ARM_RSB_I(rd, rn, imm)	_AL3_I(ARM_INST_RSB, rd, rn, imm)
+#define ARM_RSBS_I(rd, rn, imm)	_AL3_I(ARM_INST_RSBS, rd, rn, imm)
+#define ARM_RSC_I(rd, rn, imm)	_AL3_I(ARM_INST_RSC, rd, rn, imm)
 
 #define ARM_SUB_R(rd, rn, rm)	_AL3_R(ARM_INST_SUB, rd, rn, rm)
+#define ARM_SUBS_R(rd, rn, rm)	_AL3_R(ARM_INST_SUBS, rd, rn, rm)
+#define ARM_RSB_R(rd, rn, rm)	_AL3_R(ARM_INST_RSB, rd, rn, rm)
+#define ARM_SBC_R(rd, rn, rm)	_AL3_R(ARM_INST_SBC, rd, rn, rm)
+#define ARM_SBCS_R(rd, rn, rm)	_AL3_R(ARM_INST_SBCS, rd, rn, rm)
 #define ARM_SUB_I(rd, rn, imm)	_AL3_I(ARM_INST_SUB, rd, rn, imm)
+#define ARM_SUBS_I(rd, rn, imm)	_AL3_I(ARM_INST_SUBS, rd, rn, imm)
+#define ARM_SBC_I(rd, rn, imm)	_AL3_I(ARM_INST_SBC, rd, rn, imm)
 
 #define ARM_STR_I(rt, rn, off)	(ARM_INST_STR_I | (rt) << 12 | (rn) << 16 \
-				 | (off))
+				 | ((off) & 0xfff))
+#define ARM_STRH_I(rt, rn, off)	(ARM_INST_STRH_I | (rt) << 12 | (rn) << 16 \
+				 | (((off) & 0xf0) << 4) | ((off) & 0xf))
+#define ARM_STRB_I(rt, rn, off)	(ARM_INST_STRB_I | (rt) << 12 | (rn) << 16 \
+				 | (((off) & 0xf0) << 4) | ((off) & 0xf))
 
 #define ARM_TST_R(rn, rm)	_AL3_R(ARM_INST_TST, 0, rn, rm)
 #define ARM_TST_I(rn, imm)	_AL3_I(ARM_INST_TST, 0, rn, imm)
@@ -214,5 +271,6 @@
 
 #define ARM_MLS(rd, rn, rm, ra)	(ARM_INST_MLS | (rd) << 16 | (rn) | (rm) << 8 \
 				 | (ra) << 12)
+#define ARM_UXTH(rd, rm)	(ARM_INST_UXTH | (rd) << 12 | (rm))
 
 #endif /* PFILTER_OPCODES_ARM_H */
-- 
2.7.4
