From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: 4.4 stable request for net: macb: fix default configuration for GMAC
 on AT91
Date: Thu, 23 Jun 2016 11:27:00 +0200
Message-ID: <576BAB64.5050104@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Nicolas.FERRE@atmel.com" <Nicolas.FERRE@atmel.com>,
	<romain.henriet@l-acoustics.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eusmtp01.atmel.com ([212.144.249.243]:25637 "EHLO
	eusmtp01.atmel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601AbcFWJ1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2016 05:27:05 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

For 4.4 -stable, can you please consider commit:

commit 6bdaa5e9ed39b3b3328f35d218e8ad5a99cfc4d2
Author: Nicolas Ferre <nicolas.ferre@atmel.com>
Date:   Thu Mar 10 16:44:32 2016 +0100

    net: macb: fix default configuration for GMAC on AT91
    
    On AT91 SoCs, the User Register (USRIO) exposes a switch to configure the
    "Reduced" or "Traditional" version of the Media Independent Interface
    (RMII vs. MII or RGMII vs. GMII).
    As on the older EMAC version, on GMAC, this switch is set by default to the
    non-reduced type of interface, so use the existing capability and extend it to
    GMII as well. We then keep the current logic in the macb_init() function.
    
    The capabilities of sama5d2, sama5d4 and sama5d3 GEM interface are updated in
    the macb_config structure to be able to properly enable them with a traditional
    interface (GMII or MII).
    
    Reported-by: Romain HENRIET <romain.henriet@l-acoustics.com>
    Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>




Without this patch, the macb ethernet controller is always configured to be
connected to a RMII phy on sama5dx SoCs. Hence the network doesn't work on
boards embedding such SoCs and MII phy.


A backport to 4.4.13 is below.

Best regards,

Cyrille

From: Nicolas Ferre <nicolas.ferre@atmel.com>
Date: Thu, 10 Mar 2016 16:44:32 +0100
Subject: [PATCH] net: macb: fix default configuration for GMAC on AT91

commit: 6bdaa5e9ed39b3b3328f35d218e8ad5a99cfc4d2

On AT91 SoCs, the User Register (USRIO) exposes a switch to configure the
"Reduced" or "Traditional" version of the Media Independent Interface
(RMII vs. MII or RGMII vs. GMII).
As on the older EMAC version, on GMAC, this switch is set by default to the
non-reduced type of interface, so use the existing capability and extend it to
GMII as well. We then keep the current logic in the macb_init() function.

The capabilities of sama5d2, sama5d4 and sama5d3 GEM interface are updated in
the macb_config structure to be able to properly enable them with a traditional
interface (GMII or MII).

Reported-by: Romain HENRIET <romain.henriet@l-acoustics.com>
Signed-off-by: Nicolas Ferre <nicolas.ferre@atmel.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
[cyrille.pitchen@atmel.com: backported to 4.4.y]
Signed-off-by: Cyrille Pitchen <cyrille.pitchen@atmel.com>
---
 drivers/net/ethernet/cadence/macb.c | 13 +++++++------
 drivers/net/ethernet/cadence/macb.h |  2 +-
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/cadence/macb.c b/drivers/net/ethernet/cadence/macb.c
index 169059c92f80..8d54e7b41bbf 100644
--- a/drivers/net/ethernet/cadence/macb.c
+++ b/drivers/net/ethernet/cadence/macb.c
@@ -2405,9 +2405,9 @@ static int macb_init(struct platform_device *pdev)
 	if (bp->phy_interface == PHY_INTERFACE_MODE_RGMII)
 		val = GEM_BIT(RGMII);
 	else if (bp->phy_interface == PHY_INTERFACE_MODE_RMII &&
-		 (bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
+		 (bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII))
 		val = MACB_BIT(RMII);
-	else if (!(bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII))
+	else if (!(bp->caps & MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII))
 		val = MACB_BIT(MII);
 
 	if (bp->caps & MACB_CAPS_USRIO_HAS_CLKEN)
@@ -2738,7 +2738,7 @@ static int at91ether_init(struct platform_device *pdev)
 }
 
 static const struct macb_config at91sam9260_config = {
-	.caps = MACB_CAPS_USRIO_HAS_CLKEN | MACB_CAPS_USRIO_DEFAULT_IS_MII,
+	.caps = MACB_CAPS_USRIO_HAS_CLKEN | MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII,
 	.clk_init = macb_clk_init,
 	.init = macb_init,
 };
@@ -2751,21 +2751,22 @@ static const struct macb_config pc302gem_config = {
 };
 
 static const struct macb_config sama5d2_config = {
-	.caps = 0,
+	.caps = MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII,
 	.dma_burst_length = 16,
 	.clk_init = macb_clk_init,
 	.init = macb_init,
 };
 
 static const struct macb_config sama5d3_config = {
-	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE,
+	.caps = MACB_CAPS_SG_DISABLED | MACB_CAPS_GIGABIT_MODE_AVAILABLE
+	      | MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII,
 	.dma_burst_length = 16,
 	.clk_init = macb_clk_init,
 	.init = macb_init,
 };
 
 static const struct macb_config sama5d4_config = {
-	.caps = 0,
+	.caps = MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII,
 	.dma_burst_length = 4,
 	.clk_init = macb_clk_init,
 	.init = macb_init,
diff --git a/drivers/net/ethernet/cadence/macb.h b/drivers/net/ethernet/cadence/macb.h
index d83b0db77821..3f385ab94988 100644
--- a/drivers/net/ethernet/cadence/macb.h
+++ b/drivers/net/ethernet/cadence/macb.h
@@ -398,7 +398,7 @@
 /* Capability mask bits */
 #define MACB_CAPS_ISR_CLEAR_ON_WRITE		0x00000001
 #define MACB_CAPS_USRIO_HAS_CLKEN		0x00000002
-#define MACB_CAPS_USRIO_DEFAULT_IS_MII		0x00000004
+#define MACB_CAPS_USRIO_DEFAULT_IS_MII_GMII	0x00000004
 #define MACB_CAPS_NO_GIGABIT_HALF		0x00000008
 #define MACB_CAPS_FIFO_MODE			0x10000000
 #define MACB_CAPS_GIGABIT_MODE_AVAILABLE	0x20000000
-- 
1.8.2.2
