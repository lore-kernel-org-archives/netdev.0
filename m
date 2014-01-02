From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: [PATCH 5/5] bgmac: add support for Northstar SoC (BCM4707, BCM53018)
Date: Thu,  2 Jan 2014 20:19:02 +0100
Message-ID: <1388690342-27213-5-git-send-email-hauke@hauke-m.de>
References: <1388690342-27213-1-git-send-email-hauke@hauke-m.de>
Cc: zajec5@gmail.com, netdev@vger.kernel.org,
	Hauke Mehrtens <hauke@hauke-m.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from server19320154104.serverpool.info ([193.201.54.104]:51601 "EHLO
	hauke-m.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751406AbaABTTW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Jan 2014 14:19:22 -0500
In-Reply-To: <1388690342-27213-1-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for the Northstar SoC. This SoC does not have a PMU in
bcma and no register on it should be called. In addition it support 2.5
GBit/s Ethernet to the PHY.

This GMAC core is not fully working there are still problems with the
DMA controller.

Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
---
 drivers/net/ethernet/broadcom/bgmac.c |   46 +++++++++++++++++++++++----------
 drivers/net/ethernet/broadcom/bgmac.h |    1 +
 2 files changed, 34 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 2cdacb8..cf7e1ff 100644
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
@@ -860,12 +863,24 @@ static void bgmac_mac_speed(struct bgmac *bgmac)
 
 static void bgmac_miiconfig(struct bgmac *bgmac)
 {
-	u8 imode = (bgmac_read(bgmac, BGMAC_DEV_STATUS) & BGMAC_DS_MM_MASK) >>
-			BGMAC_DS_MM_SHIFT;
-	if (imode == 0 || imode == 1) {
-		bgmac->mac_speed = SPEED_100;
-		bgmac->mac_duplex = DUPLEX_FULL;
-		bgmac_mac_speed(bgmac);
+	struct bcma_device *core = bgmac->core;
+	struct bcma_chipinfo *ci = &core->bus->chipinfo;
+
+	if (ci->id == BCMA_CHIP_ID_BCM4707 ||
+	    ci->id == BCMA_CHIP_ID_BCM53018) {
+		bcma_awrite32(core, BCMA_IOCTL,
+			      bcma_aread32(core, BCMA_IOCTL) | 0x44);
+			bgmac->mac_speed = SPEED_2500;
+			bgmac->mac_duplex = DUPLEX_FULL;
+			bgmac_mac_speed(bgmac);
+	} else {
+		u8 imode = (bgmac_read(bgmac, BGMAC_DEV_STATUS) &
+			    BGMAC_DS_MM_MASK) >> BGMAC_DS_MM_SHIFT;
+		if (imode == 0 || imode == 1) {
+			bgmac->mac_speed = SPEED_100;
+			bgmac->mac_duplex = DUPLEX_FULL;
+			bgmac_mac_speed(bgmac);
+		}
 	}
 }
 
@@ -911,7 +926,8 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 
 	bcma_core_enable(core, flags);
 
-	if (core->id.rev > 2) {
+	if (core->id.rev > 2 && ci->id != BCMA_CHIP_ID_BCM4707 &&
+	    ci->id != BCMA_CHIP_ID_BCM53018) {
 		bgmac_set(bgmac, BCMA_CLKCTLST,
 			  BGMAC_BCMA_CLKCTLST_MISC_PLL_REQ);
 		bgmac_wait_value(bgmac->core, BCMA_CLKCTLST,
@@ -1049,12 +1065,16 @@ static void bgmac_enable(struct bgmac *bgmac)
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
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index ceeaac6..8f71056 100644
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
