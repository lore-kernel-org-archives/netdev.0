From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH RFCv3 01/14] arm64: introduce
 aarch64_insn_gen_comp_branch_imm()
Date: Wed, 16 Jul 2014 17:04:50 +0100
Message-ID: <20140716160450.GT29414@arm.com>
References: <1405405512-4423-1-git-send-email-zlim.lnx@gmail.com>
 <1405405512-4423-2-git-send-email-zlim.lnx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Catalin Marinas <Catalin.Marinas@arm.com>,
	Jiang Liu <liuj97@gmail.com>,
	AKASHI Takahiro <takahiro.akashi@linaro.org>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Alexei Starovoitov <ast@plumgrid.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Zi Shen Lim <zlim.lnx@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1405405512-4423-2-git-send-email-zlim.lnx@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jul 15, 2014 at 07:24:59AM +0100, Zi Shen Lim wrote:
> Introduce function to generate compare & branch (immediate)
> instructions.
> 
> Signed-off-by: Zi Shen Lim <zlim.lnx@gmail.com>
> ---
>  arch/arm64/include/asm/insn.h | 57 ++++++++++++++++++++++++++++
>  arch/arm64/kernel/insn.c      | 86 ++++++++++++++++++++++++++++++++++++++++---
>  2 files changed, 138 insertions(+), 5 deletions(-)
> 
> diff --git a/arch/arm64/include/asm/insn.h b/arch/arm64/include/asm/insn.h
> index dc1f73b..a98c495 100644
> --- a/arch/arm64/include/asm/insn.h
> +++ b/arch/arm64/include/asm/insn.h
> @@ -2,6 +2,8 @@
>   * Copyright (C) 2013 Huawei Ltd.
>   * Author: Jiang Liu <liuj97@gmail.com>
>   *
> + * Copyright (C) 2014 Zi Shen Lim <zlim.lnx@gmail.com>
> + *
>   * This program is free software; you can redistribute it and/or modify
>   * it under the terms of the GNU General Public License version 2 as
>   * published by the Free Software Foundation.
> @@ -67,9 +69,58 @@ enum aarch64_insn_imm_type {
>  	AARCH64_INSN_IMM_MAX
>  };
>  
> +enum aarch64_insn_register_type {
> +	AARCH64_INSN_REGTYPE_RT,
> +};
> +
> +enum aarch64_insn_register {
> +	AARCH64_INSN_REG_0  = 0,
> +	AARCH64_INSN_REG_1  = 1,
> +	AARCH64_INSN_REG_2  = 2,
> +	AARCH64_INSN_REG_3  = 3,
> +	AARCH64_INSN_REG_4  = 4,
> +	AARCH64_INSN_REG_5  = 5,
> +	AARCH64_INSN_REG_6  = 6,
> +	AARCH64_INSN_REG_7  = 7,
> +	AARCH64_INSN_REG_8  = 8,
> +	AARCH64_INSN_REG_9  = 9,
> +	AARCH64_INSN_REG_10 = 10,
> +	AARCH64_INSN_REG_11 = 11,
> +	AARCH64_INSN_REG_12 = 12,
> +	AARCH64_INSN_REG_13 = 13,
> +	AARCH64_INSN_REG_14 = 14,
> +	AARCH64_INSN_REG_15 = 15,
> +	AARCH64_INSN_REG_16 = 16,
> +	AARCH64_INSN_REG_17 = 17,
> +	AARCH64_INSN_REG_18 = 18,
> +	AARCH64_INSN_REG_19 = 19,
> +	AARCH64_INSN_REG_20 = 20,
> +	AARCH64_INSN_REG_21 = 21,
> +	AARCH64_INSN_REG_22 = 22,
> +	AARCH64_INSN_REG_23 = 23,
> +	AARCH64_INSN_REG_24 = 24,
> +	AARCH64_INSN_REG_25 = 25,
> +	AARCH64_INSN_REG_26 = 26,
> +	AARCH64_INSN_REG_27 = 27,
> +	AARCH64_INSN_REG_28 = 28,
> +	AARCH64_INSN_REG_29 = 29,
> +	AARCH64_INSN_REG_FP = 29, /* Frame pointer */
> +	AARCH64_INSN_REG_30 = 30,
> +	AARCH64_INSN_REG_LR = 30, /* Link register */
> +	AARCH64_INSN_REG_ZR = 31, /* Zero: as source register */
> +	AARCH64_INSN_REG_SP = 31  /* Stack pointer: as load/store base reg */

Can you just #define AARCH64_INSN_REG(x) instead, then have some magic
values like ARM64_REG_LR which are defined as the appropriate numbers?

> +};
> +
> +enum aarch64_insn_variant {
> +	AARCH64_INSN_VARIANT_32BIT,
> +	AARCH64_INSN_VARIANT_64BIT
> +};
> +
>  enum aarch64_insn_branch_type {
>  	AARCH64_INSN_BRANCH_NOLINK,
>  	AARCH64_INSN_BRANCH_LINK,
> +	AARCH64_INSN_BRANCH_COMP_ZERO,
> +	AARCH64_INSN_BRANCH_COMP_NONZERO,
>  };
>  
>  #define	__AARCH64_INSN_FUNCS(abbr, mask, val)	\
> @@ -80,6 +131,8 @@ static __always_inline u32 aarch64_insn_get_##abbr##_value(void) \
>  
>  __AARCH64_INSN_FUNCS(b,		0xFC000000, 0x14000000)
>  __AARCH64_INSN_FUNCS(bl,	0xFC000000, 0x94000000)
> +__AARCH64_INSN_FUNCS(cbz,	0xFE000000, 0x34000000)
> +__AARCH64_INSN_FUNCS(cbnz,	0xFE000000, 0x35000000)
>  __AARCH64_INSN_FUNCS(svc,	0xFFE0001F, 0xD4000001)
>  __AARCH64_INSN_FUNCS(hvc,	0xFFE0001F, 0xD4000002)
>  __AARCH64_INSN_FUNCS(smc,	0xFFE0001F, 0xD4000003)
> @@ -97,6 +150,10 @@ u32 aarch64_insn_encode_immediate(enum aarch64_insn_imm_type type,
>  				  u32 insn, u64 imm);
>  u32 aarch64_insn_gen_branch_imm(unsigned long pc, unsigned long addr,
>  				enum aarch64_insn_branch_type type);
> +u32 aarch64_insn_gen_comp_branch_imm(unsigned long pc, unsigned long addr,
> +				     enum aarch64_insn_register reg,
> +				     enum aarch64_insn_variant variant,
> +				     enum aarch64_insn_branch_type type);
>  u32 aarch64_insn_gen_hint(enum aarch64_insn_hint_op op);
>  u32 aarch64_insn_gen_nop(void);
>  
> diff --git a/arch/arm64/kernel/insn.c b/arch/arm64/kernel/insn.c
> index 92f3683..d01bb4e 100644
> --- a/arch/arm64/kernel/insn.c
> +++ b/arch/arm64/kernel/insn.c
> @@ -2,6 +2,8 @@
>   * Copyright (C) 2013 Huawei Ltd.
>   * Author: Jiang Liu <liuj97@gmail.com>
>   *
> + * Copyright (C) 2014 Zi Shen Lim <zlim.lnx@gmail.com>
> + *
>   * This program is free software; you can redistribute it and/or modify
>   * it under the terms of the GNU General Public License version 2 as
>   * published by the Free Software Foundation.
> @@ -264,10 +266,36 @@ u32 __kprobes aarch64_insn_encode_immediate(enum aarch64_insn_imm_type type,
>  	return insn;
>  }
>  
> -u32 __kprobes aarch64_insn_gen_branch_imm(unsigned long pc, unsigned long addr,
> -					  enum aarch64_insn_branch_type type)
> +static u32 aarch64_insn_encode_register(enum aarch64_insn_register_type type,
> +					u32 insn,
> +					enum aarch64_insn_register reg)
> +{
> +	int shift;
> +
> +	if (reg < AARCH64_INSN_REG_0 || reg > AARCH64_INSN_REG_SP) {
> +		pr_err("%s: unknown register encoding %d\n", __func__, reg);
> +		return 0;
> +	}
> +
> +	switch (type) {
> +	case AARCH64_INSN_REGTYPE_RT:
> +		shift = 0;
> +		break;
> +	default:
> +		pr_err("%s: unknown register type encoding %d\n", __func__,
> +		       type);
> +		return 0;
> +	}
> +
> +	insn &= ~(GENMASK(4, 0) << shift);
> +	insn |= reg << shift;
> +
> +	return insn;
> +}
> +
> +static inline long branch_imm_common(unsigned long pc, unsigned long addr,
> +				     long range)
>  {
> -	u32 insn;
>  	long offset;
>  
>  	/*
> @@ -276,13 +304,24 @@ u32 __kprobes aarch64_insn_gen_branch_imm(unsigned long pc, unsigned long addr,
>  	 */
>  	BUG_ON((pc & 0x3) || (addr & 0x3));
>  
> +	offset = ((long)addr - (long)pc);
> +	BUG_ON(offset < -range || offset >= range);
> +
> +	return offset;
> +}
> +
> +u32 __kprobes aarch64_insn_gen_branch_imm(unsigned long pc, unsigned long addr,
> +					  enum aarch64_insn_branch_type type)
> +{
> +	u32 insn;
> +	long offset;
> +
>  	/*
>  	 * B/BL support [-128M, 128M) offset
>  	 * ARM64 virtual address arrangement guarantees all kernel and module
>  	 * texts are within +/-128M.
>  	 */
> -	offset = ((long)addr - (long)pc);
> -	BUG_ON(offset < -SZ_128M || offset >= SZ_128M);
> +	offset = branch_imm_common(pc, addr, SZ_128M);
>  
>  	if (type == AARCH64_INSN_BRANCH_LINK)
>  		insn = aarch64_insn_get_bl_value();
> @@ -293,6 +332,43 @@ u32 __kprobes aarch64_insn_gen_branch_imm(unsigned long pc, unsigned long addr,
>  					     offset >> 2);
>  }
>  
> +u32 aarch64_insn_gen_comp_branch_imm(unsigned long pc, unsigned long addr,
> +				     enum aarch64_insn_register reg,
> +				     enum aarch64_insn_variant variant,
> +				     enum aarch64_insn_branch_type type)
> +{
> +	u32 insn;
> +	long offset;
> +
> +	offset = branch_imm_common(pc, addr, SZ_1M);
> +
> +	switch (type) {
> +	case AARCH64_INSN_BRANCH_COMP_ZERO:
> +		insn = aarch64_insn_get_cbz_value();
> +		break;
> +	case AARCH64_INSN_BRANCH_COMP_NONZERO:
> +		insn = aarch64_insn_get_cbnz_value();
> +		break;
> +	default:
> +		BUG_ON(1);
> +	}
> +
> +	switch (variant) {
> +	case AARCH64_INSN_VARIANT_32BIT:
> +		break;
> +	case AARCH64_INSN_VARIANT_64BIT:
> +		insn |= BIT(31);

FWIW, that bit (31) is referred to as the `SF' bit in the instruction
encodings (for Sixty-Four). You could have a #define for that to help people
match up the bitfield, if you like.

> +		break;
> +	default:
> +		BUG_ON(1);

Is a BUG_ON justifiable here? Is there not a nicer way to fail?

Will
