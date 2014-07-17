From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH RFCv3 08/14] arm64: introduce aarch64_insn_gen_movewide()
Date: Thu, 17 Jul 2014 10:41:02 +0100
Message-ID: <20140717094101.GD21153@arm.com>
References: <1405405512-4423-1-git-send-email-zlim.lnx@gmail.com>
 <1405405512-4423-9-git-send-email-zlim.lnx@gmail.com>
 <20140716161715.GU29414@arm.com>
 <20140716220422.GB18109@gup76>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from cam-admin0.cambridge.arm.com ([217.140.96.50]:53977 "EHLO
	cam-admin0.cambridge.arm.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756064AbaGQJlj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 05:41:39 -0400
Content-Disposition: inline
In-Reply-To: <20140716220422.GB18109@gup76>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 16, 2014 at 11:04:22PM +0100, Zi Shen Lim wrote:
> On Wed, Jul 16, 2014 at 05:17:15PM +0100, Will Deacon wrote:
> > On Tue, Jul 15, 2014 at 07:25:06AM +0100, Zi Shen Lim wrote:
> > > Introduce function to generate move wide (immediate) instructions.
> > 
> > [...]
> > 
> > > +u32 aarch64_insn_gen_movewide(enum aarch64_insn_register dst,
> > > +			      int imm, int shift,
> > > +			      enum aarch64_insn_variant variant,
> > > +			      enum aarch64_insn_movewide_type type)
> > > +{
> > > +	u32 insn;
> > > +
> > > +	switch (type) {
> > > +	case AARCH64_INSN_MOVEWIDE_ZERO:
> > > +		insn = aarch64_insn_get_movz_value();
> > > +		break;
> > > +	case AARCH64_INSN_MOVEWIDE_KEEP:
> > > +		insn = aarch64_insn_get_movk_value();
> > > +		break;
> > > +	case AARCH64_INSN_MOVEWIDE_INVERSE:
> > > +		insn = aarch64_insn_get_movn_value();
> > > +		break;
> > > +	default:
> > > +		BUG_ON(1);
> > > +	}
> > > +
> > > +	BUG_ON(imm < 0 || imm > 65535);
> > 
> > Do this check with masking instead?
> 
> Ok, if you prefer, I can change it to:
> 
> 	BUG_ON(imm & ~GENMASK(15, 0));

Sure, that or use a named constant for the upper-bound (SZ_64K - 1).

> > > +	switch (variant) {
> > > +	case AARCH64_INSN_VARIANT_32BIT:
> > > +		BUG_ON(shift != 0 && shift != 16);
> > > +		break;
> > > +	case AARCH64_INSN_VARIANT_64BIT:
> > > +		insn |= BIT(31);
> > > +		BUG_ON(shift != 0 && shift != 16 && shift != 32 &&
> > > +		       shift != 48);
> > 
> > Would be neater as a nested switch, perhaps? If you reorder the
> > outer-switch, you could probably fall-through too and combine the shift
> > checks.
> 
> Not sure I picture what you had in mind... I couldn't come up with a
> neater version with the properties you described.
> 
> The alternative I had was using masks instead of integer values, but
> one could argue that while neater, it could also be harder to read:
> 
> 	switch (variant) {
> 	case AARCH64_INSN_VARIANT_32BIT:
> 		BUG_ON(shift & ~BIT(4));
> 		break;
> 	case AARCH64_INSN_VARIANT_64BIT:
> 		insn |= BIT(31);
> 		BUG_ON(shift & ~GENMASK(5, 4));
> 	...

I was thinking of using nested switches, but that doesn't fall out like I
hoped. How about:

	switch (variant) {
	case AARCH64_INSN_VARIANT_64BIT:
		BUG_ON(shift != 32 && shift != 48);
	case AARCH64_INSN_VARIANT_32BIT:
		BUG_ON(shift != 0 && shift != 16);
	};

?

Will
