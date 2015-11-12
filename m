From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] stmmac: avoid ipq806x constant overflow warning
Date: Thu, 12 Nov 2015 21:52:30 +0100
Message-ID: <3729464.5X0HBxzvx5@wuerfel>
References: <4391788.dtYArQ4mVi@wuerfel> <20151112.122528.1794206832971213176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, mathieu@codeaurora.org,
	peppe.cavallaro@st.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151112.122528.1794206832971213176.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 12 November 2015 12:25:28 David Miller wrote:
> From: Arnd Bergmann <arnd@arndb.de>
> Date: Thu, 12 Nov 2015 15:12:48 +0100
> 
> > Building dwmac-ipq806x on a 64-bit architecture produces a harmless
> > warning from gcc:
> > 
> > stmmac/dwmac-ipq806x.c: In function 'ipq806x_gmac_probe':
> > include/linux/bitops.h:6:19: warning: overflow in implicit constant conversion [-Woverflow]
> >   val = QSGMII_PHY_CDR_EN |
> > stmmac/dwmac-ipq806x.c:333:8: note: in expansion of macro 'QSGMII_PHY_CDR_EN'
> >  #define QSGMII_PHY_CDR_EN   BIT(0)
> >  #define BIT(nr)   (1UL << (nr))
> > 
> > The compiler warns about the fact that a 64-bit literal is passed
> > into a function that takes a 32-bit argument. I could not fully understand
> > why it warns despite the fact that this number is always small enough
> > to fit, but changing the use of BIT() macros into the equivalent hexadecimal
> > representation avoids the warning
> > 
> > Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> > Fixes: b1c17215d718 ("stmmac: add ipq806x glue layer")
> 
> I've seen this warning too on x86_64 and had been meaning to look
> into it, thanks for taking the initiative. 
> 
> Moving away from using BIT() is somewhat disappointing, because we
> want to encourage people to use these macros.

Ok, I never really liked that macro, so I didn't mind removing it. ;-)

I spent too much time working at IBM where all internal documentation
uses bit numbers that call the MSB bit 0, and drivers use randomly
either the IBM notation or the one that everyone else uses, so I always
found the hex numbers way more intuitive.

> Also I don't even understand the compiler's behavior, it's warning
> about QSGMII_PHY_CDR_EN but if you define only that to "0x1u" it still
> warns about QSGMII_PHY_CDR_EN.
> 
> The warning goes away only if you change all 5 BIT() uses.

Yes, I have spent the time to analyze the problem now and it all makes
sense. A proper patch follows.

	Arnd
