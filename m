From: Zi Shen Lim <zlim.lnx@gmail.com>
Subject: Re: [PATCH RFCv3 01/14] arm64: introduce
 aarch64_insn_gen_comp_branch_imm()
Date: Wed, 16 Jul 2014 14:19:31 -0700
Message-ID: <20140716211931.GA18109@gup76>
References: <1405405512-4423-1-git-send-email-zlim.lnx@gmail.com>
 <1405405512-4423-2-git-send-email-zlim.lnx@gmail.com>
 <20140716160450.GT29414@arm.com>
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
To: Will Deacon <will.deacon@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:37017 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415AbaGPVTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jul 2014 17:19:36 -0400
Content-Disposition: inline
In-Reply-To: <20140716160450.GT29414@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 16, 2014 at 05:04:50PM +0100, Will Deacon wrote:
> On Tue, Jul 15, 2014 at 07:24:59AM +0100, Zi Shen Lim wrote:
[...]
> > +enum aarch64_insn_register {
> > +	AARCH64_INSN_REG_0  = 0,
> > +	AARCH64_INSN_REG_1  = 1,
> > +	AARCH64_INSN_REG_2  = 2,
> > +	AARCH64_INSN_REG_3  = 3,
> > +	AARCH64_INSN_REG_4  = 4,
> > +	AARCH64_INSN_REG_5  = 5,
> > +	AARCH64_INSN_REG_6  = 6,
> > +	AARCH64_INSN_REG_7  = 7,
> > +	AARCH64_INSN_REG_8  = 8,
> > +	AARCH64_INSN_REG_9  = 9,
> > +	AARCH64_INSN_REG_10 = 10,
> > +	AARCH64_INSN_REG_11 = 11,
> > +	AARCH64_INSN_REG_12 = 12,
> > +	AARCH64_INSN_REG_13 = 13,
> > +	AARCH64_INSN_REG_14 = 14,
> > +	AARCH64_INSN_REG_15 = 15,
> > +	AARCH64_INSN_REG_16 = 16,
> > +	AARCH64_INSN_REG_17 = 17,
> > +	AARCH64_INSN_REG_18 = 18,
> > +	AARCH64_INSN_REG_19 = 19,
> > +	AARCH64_INSN_REG_20 = 20,
> > +	AARCH64_INSN_REG_21 = 21,
> > +	AARCH64_INSN_REG_22 = 22,
> > +	AARCH64_INSN_REG_23 = 23,
> > +	AARCH64_INSN_REG_24 = 24,
> > +	AARCH64_INSN_REG_25 = 25,
> > +	AARCH64_INSN_REG_26 = 26,
> > +	AARCH64_INSN_REG_27 = 27,
> > +	AARCH64_INSN_REG_28 = 28,
> > +	AARCH64_INSN_REG_29 = 29,
> > +	AARCH64_INSN_REG_FP = 29, /* Frame pointer */
> > +	AARCH64_INSN_REG_30 = 30,
> > +	AARCH64_INSN_REG_LR = 30, /* Link register */
> > +	AARCH64_INSN_REG_ZR = 31, /* Zero: as source register */
> > +	AARCH64_INSN_REG_SP = 31  /* Stack pointer: as load/store base reg */
> 
> Can you just #define AARCH64_INSN_REG(x) instead, then have some magic
> values like ARM64_REG_LR which are defined as the appropriate numbers?

I actually had something like what you mentioned in the beginning, but
decided to go with the above - thinking that it's clearer to present
the complete set of valid register definitions.

The #define can still be added for convenience, though I think it's also a
potential source of errors - it's much easier to typo something like
AARCH64_INSN_REG(32) and not get caught.

[...]
> > +	switch (variant) {
> > +	case AARCH64_INSN_VARIANT_32BIT:
> > +		break;
> > +	case AARCH64_INSN_VARIANT_64BIT:
> > +		insn |= BIT(31);
> 
> FWIW, that bit (31) is referred to as the `SF' bit in the instruction
> encodings (for Sixty-Four). You could have a #define for that to help people
> match up the bitfield, if you like.

Something like this?

	#define AARCH64_INSN_SF_BIT  BIT(31)

	...

	case AARCH64_INSN_VARIANT_64BIT:
		insn |= AARCH64_INSN_SF_BIT;

In the case of bitfield instruction, there's also an "N" bit.
So something like this?

	#define AARCH64_INSN_N_BIT  BIT(22)

	...

	case AARCH64_INSN_VARIANT_64BIT:
		insn |= AARCH64_INSN_SF_BIT | AARCH64_INSN_N_BIT;

> 
> > +		break;
> > +	default:
> > +		BUG_ON(1);
> 
> Is a BUG_ON justifiable here? Is there not a nicer way to fail?

In general, it'd be nice if we returned something like -EINVAL and
have all callers handle failures. Today all code gen functions return
the u32 instruction and there's no error handling by callers.
I think following the precedence (aarch64_insn_gen_branch_imm())
of failing with BUG_ON is a reasonable tradeoff.

In this case here, when we hit the default (failure) case, that means
there's a serious error of attempting to use an unsupported
variant. I think we're better off failing hard here than trying to
arbitrarily "fallback" on a default choice.

One potential option instead of switch (variant) is:

	if (variant == AARCH64_INSN_VARIANT_64BIT)
		/* do something */
	else
		/* do something else */

which would be quite reasonable to do as we only have VARIANT_{32,64}BIT
today.

However, consider the case where we add VARIANT_128BIT or other flavors
in the future. The if/else option (basically defaulting to VARIANT_32BIT)
would then make much less sense.

> 
> Will
