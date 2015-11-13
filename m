From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [PATCH v2] stmmac: avoid ipq806x constant overflow warning
Date: Fri, 13 Nov 2015 08:37:57 +0100
Message-ID: <CAMuHMdXp67RwBATtoqfs=XVza7UAOu+GByZ9a8CLsvntXqM2tw@mail.gmail.com>
References: <4391788.dtYArQ4mVi@wuerfel>
	<20151112.122528.1794206832971213176.davem@davemloft.net>
	<3729464.5X0HBxzvx5@wuerfel>
	<3825178.3luTQFAgny@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	mathieu@codeaurora.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:34893 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751594AbbKMHh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2015 02:37:58 -0500
In-Reply-To: <3825178.3luTQFAgny@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Nov 12, 2015 at 10:03 PM, Arnd Bergmann <arnd@arndb.de> wrote:
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
> This is a result of the type conversion rules in C, when we take the
> logical OR of multiple different types. In particular, we have
> and unsigned long
>
>         QSGMII_PHY_CDR_EN == BIT(0) == (1ul << 0) == 0x0000000000000001ul
>
> and a signed int
>
>         0xC << QSGMII_PHY_TX_DRV_AMP_OFFSET == 0xc0000000
>
> which together gives a signed long value
>
>         0xffffffffc0000001l
>
> and when this is passed into a function that takes an unsigned int type,
> gcc warns about the signed overflow and the loss of the upper 32-bits that
> are all ones.
>
> This patch adds 'ul' type modifiers to the literal numbers passed in
> here, so now the expression remains an 'unsigned long' with the upper
> bits all zero, and that avoids the signed overflow and the warning.

FWIW, the 64-bitness of BIT() on 64-bit platforms is also causing subtle
warnings in other places, e.g. when inverting them to create bit mask, cfr.
https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=a9efeca613a8fe5281d7c91f5c8c9ea46f2312f6

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
