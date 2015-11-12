From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH v2] stmmac: avoid ipq806x constant overflow warning
Date: Thu, 12 Nov 2015 22:03:40 +0100
Message-ID: <3825178.3luTQFAgny@wuerfel>
References: <4391788.dtYArQ4mVi@wuerfel> <20151112.122528.1794206832971213176.davem@davemloft.net> <3729464.5X0HBxzvx5@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	mathieu@codeaurora.org, linux-kernel@vger.kernel.org,
	peppe.cavallaro@st.com
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <3729464.5X0HBxzvx5@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Building dwmac-ipq806x on a 64-bit architecture produces a harmless
warning from gcc:

stmmac/dwmac-ipq806x.c: In function 'ipq806x_gmac_probe':
include/linux/bitops.h:6:19: warning: overflow in implicit constant conversion [-Woverflow]
  val = QSGMII_PHY_CDR_EN |
stmmac/dwmac-ipq806x.c:333:8: note: in expansion of macro 'QSGMII_PHY_CDR_EN'
 #define QSGMII_PHY_CDR_EN   BIT(0)
 #define BIT(nr)   (1UL << (nr))

This is a result of the type conversion rules in C, when we take the
logical OR of multiple different types. In particular, we have
and unsigned long

	QSGMII_PHY_CDR_EN == BIT(0) == (1ul << 0) == 0x0000000000000001ul

and a signed int

	0xC << QSGMII_PHY_TX_DRV_AMP_OFFSET == 0xc0000000

which together gives a signed long value

	0xffffffffc0000001l

and when this is passed into a function that takes an unsigned int type,
gcc warns about the signed overflow and the loss of the upper 32-bits that
are all ones.

This patch adds 'ul' type modifiers to the literal numbers passed in
here, so now the expression remains an 'unsigned long' with the upper
bits all zero, and that avoids the signed overflow and the warning.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
Fixes: b1c17215d718 ("stmmac: add ipq806x glue layer")

diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c b/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
index 9d89bdbf029f..82de68b1a452 100644
--- a/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
+++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-ipq806x.c
@@ -337,11 +337,11 @@ static int ipq806x_gmac_probe(struct platform_device *pdev)
 			     QSGMII_PHY_RX_SIGNAL_DETECT_EN |
 			     QSGMII_PHY_TX_DRIVER_EN |
 			     QSGMII_PHY_QSGMII_EN |
-			     0x4 << QSGMII_PHY_PHASE_LOOP_GAIN_OFFSET |
-			     0x3 << QSGMII_PHY_RX_DC_BIAS_OFFSET |
-			     0x1 << QSGMII_PHY_RX_INPUT_EQU_OFFSET |
-			     0x2 << QSGMII_PHY_CDR_PI_SLEW_OFFSET |
-			     0xC << QSGMII_PHY_TX_DRV_AMP_OFFSET);
+			     0x4ul << QSGMII_PHY_PHASE_LOOP_GAIN_OFFSET |
+			     0x3ul << QSGMII_PHY_RX_DC_BIAS_OFFSET |
+			     0x1ul << QSGMII_PHY_RX_INPUT_EQU_OFFSET |
+			     0x2ul << QSGMII_PHY_CDR_PI_SLEW_OFFSET |
+			     0xCul << QSGMII_PHY_TX_DRV_AMP_OFFSET);
 	}
 
 	plat_dat->has_gmac = true;
