From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] stmmac: avoid ipq806x constant overflow warning
Date: Thu, 12 Nov 2015 12:25:28 -0500 (EST)
Message-ID: <20151112.122528.1794206832971213176.davem@davemloft.net>
References: <4391788.dtYArQ4mVi@wuerfel>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org, mathieu@codeaurora.org,
	peppe.cavallaro@st.com
To: arnd@arndb.de
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4391788.dtYArQ4mVi@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 12 Nov 2015 15:12:48 +0100

> Building dwmac-ipq806x on a 64-bit architecture produces a harmless
> warning from gcc:
> 
> stmmac/dwmac-ipq806x.c: In function 'ipq806x_gmac_probe':
> include/linux/bitops.h:6:19: warning: overflow in implicit constant conversion [-Woverflow]
>   val = QSGMII_PHY_CDR_EN |
> stmmac/dwmac-ipq806x.c:333:8: note: in expansion of macro 'QSGMII_PHY_CDR_EN'
>  #define QSGMII_PHY_CDR_EN   BIT(0)
>  #define BIT(nr)   (1UL << (nr))
> 
> The compiler warns about the fact that a 64-bit literal is passed
> into a function that takes a 32-bit argument. I could not fully understand
> why it warns despite the fact that this number is always small enough
> to fit, but changing the use of BIT() macros into the equivalent hexadecimal
> representation avoids the warning
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
> Fixes: b1c17215d718 ("stmmac: add ipq806x glue layer")

I've seen this warning too on x86_64 and had been meaning to look
into it, thanks for taking the initiative. :)

Moving away from using BIT() is somewhat disappointing, because we
want to encourage people to use these macros.

I think it's also easier from a driver author and auditing
perspective, you can see that something is being defined as bit X and
then check the documentation for the chip to see if bit X is correct
or not.

With the hex values there is more mental work and room for... mistakes.

Also I don't even understand the compiler's behavior, it's warning
about QSGMII_PHY_CDR_EN but if you define only that to "0x1u" it still
warns about QSGMII_PHY_CDR_EN.

The warning goes away only if you change all 5 BIT() uses.

This makes me like the change even less, something foul is going on
here and I'd rather figure out what that is than install this patch.

Thanks.
