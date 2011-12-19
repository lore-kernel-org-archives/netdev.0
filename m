From: Rob Herring <robherring2@gmail.com>
Subject: Re: [PATCH] ARM: net: JIT compiler for packet filters
Date: Sun, 18 Dec 2011 20:49:40 -0600
Message-ID: <4EEEA644.5010008@gmail.com>
References: <1324252185-15894-1-git-send-email-mgherzan@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org
To: Mircea Gherzan <mgherzan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:52483 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752053Ab1LSCt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Dec 2011 21:49:56 -0500
Received: by yenm11 with SMTP id m11so3117156yen.19
        for <netdev@vger.kernel.org>; Sun, 18 Dec 2011 18:49:55 -0800 (PST)
In-Reply-To: <1324252185-15894-1-git-send-email-mgherzan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/18/2011 05:49 PM, Mircea Gherzan wrote:
> Based of Matt Evans's PPC64 implementation.
> 
> Supports only ARM mode with EABI.
> 
> Supports both little and big endian. Depends on the support for
> unaligned loads on ARMv7. Does not support all the BPF opcodes
> that deal with ancillary data. The scratch memory of the filter
> lives on the stack.

ARMv6 supports unaligned accesses too.

> 
> Enabled in the same way as for x86-64 and PPC64:
> 
> 	echo 1 > /proc/sys/net/core/bpf_jit_enable
> 
> A value greater than 1 enables opcode output.

Any performance data for ARM?

> 
> Signed-off-by: Mircea Gherzan <mgherzan@gmail.com>
> ---
>  arch/arm/Kconfig          |    1 +
>  arch/arm/Makefile         |    1 +
>  arch/arm/net/Makefile     |    3 +
>  arch/arm/net/bpf_jit_32.c |  840 +++++++++++++++++++++++++++++++++++++++++++++
>  arch/arm/net/bpf_jit_32.h |  174 ++++++++++
>  5 files changed, 1019 insertions(+), 0 deletions(-)
>  create mode 100644 arch/arm/net/Makefile
>  create mode 100644 arch/arm/net/bpf_jit_32.c
>  create mode 100644 arch/arm/net/bpf_jit_32.h
> 
> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> index abba5b8..ea65c41 100644
> --- a/arch/arm/Kconfig
> +++ b/arch/arm/Kconfig
> @@ -30,6 +30,7 @@ config ARM
>  	select HAVE_SPARSE_IRQ
>  	select GENERIC_IRQ_SHOW
>  	select CPU_PM if (SUSPEND || CPU_IDLE)
> +	select HAVE_BPF_JIT if (!THUMB2_KERNEL && AEABI)

No thumb2. That's a shame...

>  	help
>  	  The ARM series is a line of low-power-consumption RISC chip designs
>  	  licensed by ARM Ltd and targeted at embedded applications and
> diff --git a/arch/arm/Makefile b/arch/arm/Makefile
> index dfcf3b0..8810a10 100644
> --- a/arch/arm/Makefile
> +++ b/arch/arm/Makefile
> @@ -255,6 +255,7 @@ core-$(CONFIG_VFP)		+= arch/arm/vfp/
>  
>  # If we have a machine-specific directory, then include it in the build.
>  core-y				+= arch/arm/kernel/ arch/arm/mm/ arch/arm/common/
> +core-y				+= arch/arm/net/
>  core-y				+= $(machdirs) $(platdirs)
>  
>  drivers-$(CONFIG_OPROFILE)      += arch/arm/oprofile/
> diff --git a/arch/arm/net/Makefile b/arch/arm/net/Makefile
> new file mode 100644
> index 0000000..c2c1084
> --- /dev/null
> +++ b/arch/arm/net/Makefile
> @@ -0,0 +1,3 @@
> +# ARM-specific networking code
> +
> +obj-$(CONFIG_BPF_JIT) += bpf_jit_32.o
> diff --git a/arch/arm/net/bpf_jit_32.c b/arch/arm/net/bpf_jit_32.c
> new file mode 100644
> index 0000000..4d4c2a0
> --- /dev/null
> +++ b/arch/arm/net/bpf_jit_32.c
> @@ -0,0 +1,840 @@
> +/*
> + * Just-In-Time compiler for BPF filters on 32bit ARM
> + *
> + * Copyright (c) 2011 Mircea Gherzan <mgherzan@gmail.com>
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License as published by the
> + * Free Software Foundation; version 2 of the License.
> + */
> +
> +#include <linux/bitops.h>
> +#include <linux/compiler.h>
> +#include <linux/filter.h>
> +#include <linux/moduleloader.h>
> +#include <linux/netdevice.h>
> +#include <linux/string.h>
> +#include <linux/slab.h>
> +#include <asm/cacheflush.h>
> +
> +#include "bpf_jit_32.h"
> +
> +/*
> + * ABI:
> + *
> + * r0	scratch register
> + * r4	BPF register A
> + * r5	BPF register X
> + * r6	pointer to the skb
> + * r7	skb->data
> + * r8	skb_headlen(skb)
> + */
> +
> +#define r_scratch	ARM_R0
> +/* r1-r3 are (also) used for the unaligned loads on the non-ARMv7 slowpath */
> +#define r_off		ARM_R1
> +#define r_A		ARM_R4
> +#define r_X		ARM_R5
> +#define r_skb		ARM_R6
> +#define r_skb_data	ARM_R7
> +#define r_skb_hl	ARM_R8
> +
> +#define SCRATCH_SP_OFFSET	0
> +#define SCRATCH_OFF(k)		(SCRATCH_SP_OFFSET + (k))
> +
> +#define SEEN_MEM		0xff
> +#define SEEN_MEM_WORD(k)	(1 << (k))
> +#define SEEN_X			(1 << 16)
> +#define SEEN_CALL		(1 << 17)
> +#define SEEN_DATA		(1 << 18)
> +#define SEEN_LEN		(1 << 19)
> +
> +struct jit_ctx {
> +	const struct sk_filter *skf;
> +	unsigned idx;
> +	unsigned prologue_bytes;
> +	int ret0_fp_idx;
> +	u32 seen;
> +	u32 *offsets;
> +	u32 *target;
> +#if __LINUX_ARM_ARCH__ < 7
> +	u16 epilogue_bytes;
> +	u16 imm_count;
> +	u32 *imms;
> +#endif
> +};
> +
> +int bpf_jit_enable __read_mostly;
> +
> +static u8 jit_get_skb_b(struct sk_buff *skb, unsigned offset)
> +{
> +	u8 ret;
> +	skb_copy_bits(skb, offset, &ret, 1);
> +	return ret;
> +}
> +
> +static u16 jit_get_skb_h(struct sk_buff *skb, unsigned offset)
> +{
> +	u16 ret;
> +	skb_copy_bits(skb, offset, &ret, 2);
> +	return ntohs(ret);
> +}
> +
> +static u32 jit_get_skb_w(struct sk_buff *skb, unsigned offset)
> +{
> +	u32 ret;
> +	skb_copy_bits(skb, offset, &ret, 4);
> +	return ntohl(ret);
> +}
> +
> +static inline void _emit(int cond, u32 inst, struct jit_ctx *ctx)
> +{
> +	if (ctx->target != NULL)
> +		ctx->target[ctx->idx] = inst | (cond << 28);
> +
> +	ctx->idx++;
> +}
> +
> +/*
> + * Emit an instruction that will be executed unconditionally.
> + */
> +static inline void emit(u32 inst, struct jit_ctx *ctx)
> +{
> +	_emit(ARM_COND_AL, inst, ctx);
> +}
> +
> +static u16 saved_regs(struct jit_ctx *ctx)
> +{
> +	u16 ret = 0;
> +
> +	if (ctx->skf->len > 1)
> +		ret |= 1 << r_A;
> +
> +#ifdef CONFIG_FRAME_POINTER
> +	ret |= (1 << ARM_FP) | (1 << ARM_IP) | (1 << ARM_LR) | (1 << ARM_PC);
> +#else
> +	if (ctx->seen & SEEN_CALL)
> +		ret |= 1 << ARM_LR;
> +#endif
> +	if (ctx->seen & (SEEN_DATA | SEEN_LEN))
> +		ret |= 1 << r_skb;
> +	if (ctx->seen & SEEN_DATA)
> +		ret |= (1 << r_skb_data) | (1 << r_skb_hl);
> +	if (ctx->seen & SEEN_X)
> +		ret |= 1 << r_X;
> +
> +	return ret;
> +}
> +
> +static inline int mem_words_used(struct jit_ctx *ctx)
> +{
> +	u32 words = ctx->seen & SEEN_MEM;
> +	/* yes, we do waste some stack space IF there are "holes" in the set" */
> +	return (words) ? 16 - __builtin_clz(words) : 0;
> +}
> +
> +static inline bool is_load_to_a(u16 inst)
> +{
> +	switch (inst) {
> +	case BPF_S_LD_W_LEN:
> +	case BPF_S_LD_W_ABS:
> +	case BPF_S_LD_H_ABS:
> +	case BPF_S_LD_B_ABS:
> +	case BPF_S_ANC_CPU:
> +	case BPF_S_ANC_IFINDEX:
> +	case BPF_S_ANC_MARK:
> +	case BPF_S_ANC_PROTOCOL:
> +	case BPF_S_ANC_RXHASH:
> +	case BPF_S_ANC_QUEUE:
> +		return true;
> +	default:
> +		return false;
> +	}
> +}
> +
> +static void build_prologue(struct jit_ctx *ctx)
> +{
> +	u16 reg_set = saved_regs(ctx);
> +	u16 first_inst = ctx->skf->insns[0].code;
> +	u16 off;
> +
> +#ifdef CONFIG_FRAME_POINTER
> +	emit(ARM_MOV_R(ARM_IP, ARM_SP), ctx);
> +	emit(ARM_PUSH(reg_set), ctx);
> +	emit(ARM_SUB_I(ARM_FP, ARM_IP, 4), ctx);
> +#else
> +	if (reg_set)
> +		emit(ARM_PUSH(reg_set), ctx);
> +#endif
> +
> +	if (ctx->seen & (SEEN_DATA | SEEN_LEN))
> +		emit(ARM_MOV_R(r_skb, ARM_R0), ctx);
> +
> +	if (ctx->seen & SEEN_DATA) {
> +		off = offsetof(struct sk_buff, data);
> +		emit(ARM_LDR_I(r_skb_data, r_skb, off), ctx);
> +		/* headlen = len - data_len */
> +		off = offsetof(struct sk_buff, len);
> +		emit(ARM_LDR_I(r_skb_hl, r_skb, off), ctx);
> +		off = offsetof(struct sk_buff, data_len);
> +		emit(ARM_LDR_I(r_scratch, r_skb, off), ctx);
> +		emit(ARM_SUB_R(r_skb_hl, r_skb_hl, r_scratch), ctx);
> +	}
> +
> +	if (ctx->seen & SEEN_X)
> +		emit(ARM_MOV_I(r_X, 0), ctx);
> +
> +	/* do not leak kernel data to userspace */
> +	if ((first_inst != BPF_S_RET_K) && !(is_load_to_a(first_inst)))
> +		emit(ARM_MOV_I(r_A, 0), ctx);
> +
> +	/* stack space for the BPF_MEM words */
> +	if (ctx->seen & SEEN_MEM)
> +		emit(ARM_SUB_I(ARM_SP, ARM_SP, mem_words_used(ctx) * 4), ctx);
> +}
> +
> +static void build_epilogue(struct jit_ctx *ctx)
> +{
> +	u16 reg_set = saved_regs(ctx);
> +
> +	if (ctx->seen & SEEN_MEM)
> +		emit(ARM_ADD_I(ARM_SP, ARM_SP, mem_words_used(ctx) * 4), ctx);
> +
> +	reg_set &= ~(1 << ARM_LR);
> +
> +#ifdef CONFIG_FRAME_POINTER
> +	/* the first instruction of the prologue was: mov ip, sp */
> +	reg_set &= ~(1 << ARM_IP);
> +	reg_set |= (1 << ARM_SP);
> +	emit(ARM_LDM(ARM_SP, reg_set), ctx);
> +#else
> +	if (ctx->seen)
> +		emit(ARM_POP(reg_set | (1 << ARM_PC)), ctx);
> +	else
> +		emit(ARM_BX(ARM_LR), ctx);
> +#endif
> +}
> +
> +static int16_t imm8m(u32 x)
> +{
> +	u32 rot;
> +
> +	for (rot = 0; rot < 16; rot++)
> +		if ((x & ~ror32(0xff, 2 * rot)) == 0)
> +			return rol32(x, 2 * rot) | (rot << 8);
> +
> +	return -1;
> +}
> +
> +#if __LINUX_ARM_ARCH__ < 7
> +static u16 imm_offset(u32 k, struct jit_ctx *ctx)
> +{
> +	unsigned i = 0, offset;
> +	u16 imm;
> +
> +	/* on the "fake" run we just count them (duplicates included) */
> +	if (ctx->target == NULL) {
> +		ctx->imm_count++;
> +		return 0;
> +	}
> +
> +	while ((i < ctx->imm_count) && ctx->imms[i]) {
> +		if (ctx->imms[i] == k)
> +			break;
> +		i++;
> +	}
> +
> +	if (ctx->imms[i] == 0)
> +		ctx->imms[i] = k;
> +
> +	/* constants go just after the epilogue */
> +	offset =  ctx->offsets[ctx->skf->len];
> +	offset += ctx->prologue_bytes;
> +	offset += ctx->epilogue_bytes;
> +	offset += i * 4;
> +
> +	ctx->target[offset / 4] = k;
> +
> +	/* PC in ARM mode == address of the instruction + 8 */
> +	imm = offset - (8 + ctx->idx * 4);
> +
> +	return imm;
> +}
> +#endif /* __LINUX_ARM_ARCH__ */
> +
> +
> +/*
> + * Move an immediate that's not an imm8m to a core register.
> + */
> +static inline void emit_mov_i_no8m(int rd, u32 val, struct jit_ctx *ctx)
> +{
> +#if __LINUX_ARM_ARCH__ >= 7
> +	emit(ARM_MOVW(rd, val & 0xffff), ctx);
> +	if (val > 0xffff)
> +		emit(ARM_MOVT(rd, val >> 16), ctx);
> +#else
> +	emit(ARM_LDR_I(rd, ARM_PC, imm_offset(val, ctx)), ctx);
> +#endif
> +}
> +
> +static inline void emit_mov_i(int rd, u32 val, struct jit_ctx *ctx)
> +{
> +	int imm12 = imm8m(val);
> +
> +	if (imm12 >= 0)
> +		emit(ARM_MOV_I(rd, imm12), ctx);
> +	else
> +		emit_mov_i_no8m(rd, val, ctx);
> +}
> +
> +#if __LINUX_ARM_ARCH__ < 7
> +
> +static void emit_load_be32(u8 cond, u8 r_res, u8 r_addr, struct jit_ctx *ctx)
> +{
> +	_emit(cond, ARM_LDRB_I(ARM_R3, r_addr, 1), ctx);
> +	_emit(cond, ARM_LDRB_I(ARM_R1, r_addr, 0), ctx);
> +	_emit(cond, ARM_LDRB_I(ARM_R2, r_addr, 3), ctx);
> +	_emit(cond, ARM_LSL_I(ARM_R3, ARM_R3, 16), ctx);
> +	_emit(cond, ARM_LDRB_I(ARM_R0, r_addr, 2), ctx);

byte at a time is for alignment? ARMv6 can do misaligned accesses.

> +	_emit(cond, ARM_ORR_S(ARM_R3, ARM_R3, ARM_R1, SRTYPE_LSL, 24), ctx);
> +	_emit(cond, ARM_ORR_R(ARM_R3, ARM_R3, ARM_R2), ctx);
> +	_emit(cond, ARM_ORR_S(r_res, ARM_R3, ARM_R0, SRTYPE_LSL, 8), ctx);
> +}
> +
> +static void emit_load_be16(u8 cond, u8 r_res, u8 r_addr, struct jit_ctx *ctx)
> +{
> +	_emit(cond, ARM_LDRB_I(ARM_R1, r_addr, 0), ctx);
> +	_emit(cond, ARM_LDRB_I(ARM_R2, r_addr, 1), ctx);
> +	_emit(cond, ARM_ORR_S(r_res, ARM_R2, ARM_R1, SRTYPE_LSL, 8), ctx);
> +}
> +
> +
> +#else  /* ARMv7 */
> +
> +static void emit_load_be32(u8 cond, u8 r_res, u8 r_addr, struct jit_ctx *ctx)
> +{
> +	_emit(cond, ARM_LDR_I(r_res, r_addr, 0), ctx);
> +#ifdef __LITTLE_ENDIAN
> +	_emit(cond, ARM_REV(r_res, r_res), ctx);
> +#endif
> +}
> +
> +static void emit_load_be16(u8 cond, u8 r_res, u8 r_addr, struct jit_ctx *ctx)
> +{
> +	_emit(cond, ARM_LDRH_I(r_res, r_addr, 0), ctx);
> +#ifdef __LITTLE_ENDIAN
> +	_emit(cond, ARM_REV16(r_res, r_res), ctx);
> +#endif
> +}
> +
> +
> +#endif /* __LINUX_ARM_ARCH__ < 6 */
> +
> +#if __LINUX_ARM_ARCH__ >= 6
> +

Should be < 6.

It would be easier to read and less error prone if you group functions
into fewer #if or at least make the logic the same (i.e. all < or all >=).

> +static inline void emit_swap16(u8 r_dst, u8 r_src, struct jit_ctx *ctx)
> +{
> +	emit(ARM_LSL_R(ARM_R1, r_src, 8), ctx);
> +	emit(ARM_ORR_S(r_dst, ARM_R1, r_src, SRTYPE_LSL, 8), ctx);
> +	emit(ARM_LSL_I(r_dst, r_dst, 8), ctx);
> +	emit(ARM_LSL_R(r_dst, r_dst, 8), ctx);
> +}
> +
> +#else /* ARMv6 or ARMv7 */
> +
> +static inline void emit_swap16(u8 r_dst __maybe_unused,
> +			       u8 r_src __maybe_unused,
> +			       struct jit_ctx *ctx __maybe_unused)
> +{
> +#ifdef __LITTLE_ENDIAN
> +	emit(ARM_REV16(r_dst, r_src), ctx);
> +#endif
> +}
> +
> +#endif /* __LINUX_ARM_ARCH__ < 6 */
> +
> +
> +/* Compute the immediate value for a PC-relative branch. */
> +static inline u32 b_imm(unsigned tgt, struct jit_ctx *ctx)
> +{
> +	u32 imm;
> +
> +	if (ctx->target == NULL)
> +		return 0;
> +	/*
> +	 * BPF allows only forward jumps and the offset of the target is
> +	 * still the one computed during the first pass.
> +	 */
> +	imm  = ctx->offsets[tgt] + ctx->prologue_bytes - (ctx->idx * 4 + 8);
> +
> +	return imm >> 2;
> +}
> +
> +#define OP_IMM3(op, r1, r2, imm_val, ctx)				\
> +	do {								\
> +		imm12 = imm8m(imm_val);					\
> +		if (imm12 < 0) {					\
> +			emit_mov_i_no8m(r_scratch, imm_val, ctx);	\
> +			emit(op ## _R((r1), (r2), r_scratch), ctx);	\
> +		} else {						\
> +			emit(op ## _I((r1), (r2), imm12), ctx);		\
> +		}							\
> +	} while (0)
> +
> +static inline void emit_err_ret(u8 cond, struct jit_ctx *ctx)
> +{
> +	if (ctx->ret0_fp_idx >= 0) {
> +		_emit(cond, ARM_B(b_imm(ctx->ret0_fp_idx, ctx)), ctx);
> +		/* NOP to keep the size constant between passes */
> +		emit(ARM_MOV_R(ARM_R0, ARM_R0), ctx);
> +	} else {
> +		_emit(cond, ARM_MOV_I(ARM_R0, 0), ctx);
> +		_emit(cond, ARM_B(b_imm(ctx->skf->len, ctx)), ctx);
> +	}
> +}
> +
> +static int build_body(struct jit_ctx *ctx)
> +{
> +	void  *load_func[] = {jit_get_skb_b, jit_get_skb_h, jit_get_skb_w};
> +	const struct sk_filter *prog = ctx->skf;
> +	const struct sock_filter *inst;
> +	unsigned i, load_order, off, condt, condf;
> +	int imm12;
> +	u32 k;
> +
> +	for (i = 0; i < prog->len; i++) {
> +		inst = &(prog->insns[i]);
> +		/* K as an immediate value operand */
> +		k = inst->k;
> +
> +		/* compute offsets only in the fake pass */
> +		if (ctx->target == NULL)
> +			ctx->offsets[i] = ctx->idx * 4;
> +
> +		switch (inst->code) {
> +		case BPF_S_LD_IMM:
> +			emit_mov_i(r_A, k, ctx);
> +			break;
> +		case BPF_S_LD_W_LEN:
> +			ctx->seen |= SEEN_LEN;
> +			BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, len) != 4);
> +			emit(ARM_LDR_I(r_A, r_skb,
> +				       offsetof(struct sk_buff, len)), ctx);
> +			break;
> +		case BPF_S_LD_MEM:
> +			/* A = scratch[k] */
> +			ctx->seen |= SEEN_MEM_WORD(k);
> +			emit(ARM_LDR_I(r_A, ARM_SP, SCRATCH_OFF(k)), ctx);
> +			break;
> +		case BPF_S_LD_W_ABS:
> +			load_order = 2;
> +			goto load;
> +		case BPF_S_LD_H_ABS:
> +			load_order = 1;
> +			goto load;
> +		case BPF_S_LD_B_ABS:
> +			load_order = 0;
> +load:
> +			emit_mov_i(r_off, k, ctx);
> +load_common:
> +			ctx->seen |= SEEN_DATA | SEEN_CALL;
> +
> +			if (load_order > 0) {
> +				emit(ARM_SUB_I(r_scratch, r_skb_hl,
> +					       1 << load_order), ctx);
> +				emit(ARM_CMP_R(r_scratch, r_off), ctx);
> +				condt = ARM_COND_HS;
> +			} else {
> +				emit(ARM_CMP_R(r_skb_hl, r_off), ctx);
> +				condt = ARM_COND_HI;
> +			}
> +
> +			_emit(condt, ARM_ADD_R(r_scratch, r_off, r_skb_data),
> +			      ctx);
> +
> +			if (load_order == 0)
> +				_emit(condt, ARM_LDRB_I(r_A, r_scratch, 0),
> +				      ctx);
> +			else if (load_order == 1)
> +				emit_load_be16(condt, r_A, r_scratch, ctx);
> +			else if (load_order == 2)
> +				emit_load_be32(condt, r_A, r_scratch, ctx);
> +
> +			_emit(condt, ARM_B(b_imm(i + 1, ctx)), ctx);
> +
> +			/* the slowpath */
> +			emit_mov_i(ARM_R3, (u32)load_func[load_order], ctx);
> +			emit(ARM_MOV_R(ARM_R0, r_skb), ctx);
> +			/* the offset is already in R1 */
> +			emit(ARM_BLX_R(ARM_R3), ctx);

BLX is v5+ only. It probably fine to make the JIT v5+ only. There's
probably not much v4 h/w that would use this.

Rob
