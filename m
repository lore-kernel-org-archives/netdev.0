From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH v2 5/5] bgmac: add support for Northstar SoC (BCM4707, BCM53018)
Date: Sat,  4 Jan 2014 19:13:58 +0100
Message-ID: <1388859238-22808-6-git-send-email-hauke@hauke-m.de>
References: <1388859238-22808-1-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:59482 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754987AbaADSOk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 4 Jan 2014 13:14:40 -0500
In-Reply-To: <1388859238-22808-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for the Northstar SoC. This SoC does not have a PMU in
bcma and no register on it should be called. In addition it support 2.5
GBit/s Ethernet to the PHY.

This GMAC core is not fully working there are still problems with the
DMA controller.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/bgmac.c |   63 +++++++++++++++++++++++++--------
 drivers/net/ethernet/broadcom/bgmac.h |    1 +
 2 files changed, 50 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 2cdacb8..06ce958 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -848,6 +848,9 @@ static void bgmac_mac_speed(struct bgmac *bgmac)
 	case SPEED_1000:
 		set |= BGMAC_CMDCFG_ES_1000;
 		break;
+	case SPEED_2500:
+		set |= BGMAC_CMDCFG_ES_2500;
+		break;
 	default:
 		bgmac_err(bgmac, "Unsupported speed: %d\n", bgmac->mac_speed);
 	}
@@ -860,12 +863,26 @@ static void bgmac_mac_speed(struct bgmac *bgmac)
 
 static void bgmac_miiconfig(struct bgmac *bgmac)
 {
-	u8 imode = (bgmac_read(bgmac, BGMAC_DEV_STATUS) & BGMAC_DS_MM_MASK) >>
-			BGMAC_DS_MM_SHIFT;
-	if (imode == 0 || imode == 1) {
-		bgmac->mac_speed = SPEED_100;
+	struct bcma_device *core = bgmac->core;
+	struct bcma_chipinfo *ci = &core->bus->chipinfo;
+	u8 imode;
+
+	if (ci->id == BCMA_CHIP_ID_BCM4707 ||
+	    ci->id == BCMA_CHIP_ID_BCM53018) {
+		bcma_awrite32(core, BCMA_IOCTL,
+			      bcma_aread32(core, BCMA_IOCTL) | 0x40 |
+			      BGMAC_BCMA_IOCTL_SW_CLKEN);
+		bgmac->mac_speed = SPEED_2500;
 		bgmac->mac_duplex = DUPLEX_FULL;
 		bgmac_mac_speed(bgmac);
+	} else {
+		imode = (bgmac_read(bgmac, BGMAC_DEV_STATUS) &
+			BGMAC_DS_MM_MASK) >> BGMAC_DS_MM_SHIFT;
+		if (imode == 0 || imode == 1) {
+			bgmac->mac_speed = SPEED_100;
+			bgmac->mac_duplex = DUPLEX_FULL;
+			bgmac_mac_speed(bgmac);
+		}
 	}
 }
 
@@ -909,9 +926,14 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 			flags |= BGMAC_BCMA_IOCTL_SW_RESET;
 	}
 
-	bcma_core_enable(core, flags);
+	/* 3GMAC: for BCM4707, only do core reset at bgmac_probe() */
+	if (ci->id != BCMA_CHIP_ID_BCM4707)
+		bcma_core_enable(core, flags);
 
-	if (core->id.rev > 2) {
+	/* Request Misc PLL for corerev > 2 */
+	if (core->id.rev > 2 &&
+	    ci->id != BCMA_CHIP_ID_BCM4707 &&
+	    ci->id != BCMA_CHIP_ID_BCM53018) {
 		bgmac_set(bgmac, BCMA_CLKCTLST,
 			  BGMAC_BCMA_CLKCTLST_MISC_PLL_REQ);
 		bgmac_wait_value(bgmac->core, BCMA_CLKCTLST,
@@ -1049,12 +1071,16 @@ static void bgmac_enable(struct bgmac *bgmac)
 		break;
 	}
 
-	rxq_ctl = bgmac_read(bgmac, BGMAC_RXQ_CTL);
-	rxq_ctl &= ~BGMAC_RXQ_CTL_MDP_MASK;
-	bp_clk = bcma_pmu_get_bus_clock(&bgmac->core->bus->drv_cc) / 1000000;
-	mdp = (bp_clk * 128 / 1000) - 3;
-	rxq_ctl |= (mdp << BGMAC_RXQ_CTL_MDP_SHIFT);
-	bgmac_write(bgmac, BGMAC_RXQ_CTL, rxq_ctl);
+	if (ci->id != BCMA_CHIP_ID_BCM4707 &&
+	    ci->id != BCMA_CHIP_ID_BCM53018) {
+		rxq_ctl = bgmac_read(bgmac, BGMAC_RXQ_CTL);
+		rxq_ctl &= ~BGMAC_RXQ_CTL_MDP_MASK;
+		bp_clk = bcma_pmu_get_bus_clock(&bgmac->core->bus->drv_cc) /
+				1000000;
+		mdp = (bp_clk * 128 / 1000) - 3;
+		rxq_ctl |= (mdp << BGMAC_RXQ_CTL_MDP_SHIFT);
+		bgmac_write(bgmac, BGMAC_RXQ_CTL, rxq_ctl);
+	}
 }
 
 /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/chipinit */
@@ -1389,6 +1415,7 @@ static int bgmac_probe(struct bcma_device *core)
 	struct bgmac *bgmac;
 	struct ssb_sprom *sprom = &core->bus->sprom;
 	u8 *mac = core->core_unit ? sprom->et1mac : sprom->et0mac;
+	struct bcma_chipinfo *ci = &core->bus->chipinfo;
 	int err;
 
 	/* We don't support 2nd, 3rd, ... units, SPROM has to be adjusted */
@@ -1427,8 +1454,16 @@ static int bgmac_probe(struct bcma_device *core)
 	}
 	bgmac->cmn = core->bus->drv_gmac_cmn.core;
 
-	bgmac->phyaddr = core->core_unit ? sprom->et1phyaddr :
-			 sprom->et0phyaddr;
+	/*
+	 * Too much can go wrong in scanning MDC/MDIO playing "whos my phy?" .
+	 * Instead, explicitly use the phy address 30.
+	 */
+	if (ci->id == BCMA_CHIP_ID_BCM4707 || ci->id == BCMA_CHIP_ID_BCM53018)
+		bgmac->phyaddr = BGMAC_PHY_NOREGS;
+	else
+		bgmac->phyaddr = core->core_unit ? sprom->et1phyaddr :
+				 sprom->et0phyaddr;
+
 	bgmac->phyaddr &= BGMAC_PHY_MASK;
 	if (bgmac->phyaddr == BGMAC_PHY_MASK) {
 		bgmac_err(bgmac, "No PHY found\n");
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index 2da12ed..89fa5bc 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -189,6 +189,7 @@
 #define   BGMAC_CMDCFG_ES_10			0x00000000
 #define   BGMAC_CMDCFG_ES_100			0x00000004
 #define   BGMAC_CMDCFG_ES_1000			0x00000008
+#define   BGMAC_CMDCFG_ES_2500			0x0000000C
 #define  BGMAC_CMDCFG_PROM			0x00000010	/* Set to activate promiscuous mode */
 #define  BGMAC_CMDCFG_PAD_EN			0x00000020
 #define  BGMAC_CMDCFG_CF			0x00000040
-- 
1.7.10.4
