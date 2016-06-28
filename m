From: Jon Mason <jon.mason@broadcom.com>
Subject: [RFC 4/7] net: ethernet: bgmac: convert to feature flags
Date: Tue, 28 Jun 2016 15:34:41 -0400
Message-ID: <1467142484-11161-5-git-send-email-jon.mason@broadcom.com>
References: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
Cc: davem@davemloft.net, f.fainelli@gmail.com, hauke@hauke-m.de,
	bcm-kernel-feedback-list@broadcom.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: zajec5@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:33043 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752613AbcF1TfW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2016 15:35:22 -0400
Received: by mail-pa0-f47.google.com with SMTP id b13so9265156pat.0
        for <netdev@vger.kernel.org>; Tue, 28 Jun 2016 12:35:21 -0700 (PDT)
In-Reply-To: <1467142484-11161-1-git-send-email-jon.mason@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bgmac driver is using the bcma provides device ID and revision, as
well as the SoC ID and package, to determine which features are
necessary to enable, reset, etc in the driver.   In anticipation of
removing the bcma requirement for this driver, these must be changed to
not reference that struct.  In place of that, each "feature" has been
given a flag, and the flags are enabled for their respective device and
SoC.

Signed-off-by: Jon Mason <jon.mason@broadcom.com>
---
 drivers/net/ethernet/broadcom/bgmac.c | 167 ++++++++++++++++++++++++----------
 drivers/net/ethernet/broadcom/bgmac.h |  21 ++++-
 2 files changed, 140 insertions(+), 48 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bgmac.c b/drivers/net/ethernet/broadcom/bgmac.c
index 88b9513..4346994 100644
--- a/drivers/net/ethernet/broadcom/bgmac.c
+++ b/drivers/net/ethernet/broadcom/bgmac.c
@@ -109,7 +109,7 @@ static void bgmac_dma_tx_enable(struct bgmac *bgmac,
 	u32 ctl;
 
 	ctl = bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_TX_CTL);
-	if (bgmac->core->id.rev >= 4) {
+	if (bgmac->feature_flags & BGMAC_FEAT_TX_MASK_SETUP) {
 		ctl &= ~BGMAC_DMA_TX_BL_MASK;
 		ctl |= BGMAC_DMA_TX_BL_128 << BGMAC_DMA_TX_BL_SHIFT;
 
@@ -330,7 +330,7 @@ static void bgmac_dma_rx_enable(struct bgmac *bgmac,
 	u32 ctl;
 
 	ctl = bgmac_read(bgmac, ring->mmio_base + BGMAC_DMA_RX_CTL);
-	if (bgmac->core->id.rev >= 4) {
+	if (bgmac->feature_flags & BGMAC_FEAT_RX_MASK_SETUP) {
 		ctl &= ~BGMAC_DMA_RX_BL_MASK;
 		ctl |= BGMAC_DMA_RX_BL_128 << BGMAC_DMA_RX_BL_SHIFT;
 
@@ -768,14 +768,20 @@ static void bgmac_cmdcfg_maskset(struct bgmac *bgmac, u32 mask, u32 set,
 {
 	u32 cmdcfg = bgmac_read(bgmac, BGMAC_CMDCFG);
 	u32 new_val = (cmdcfg & mask) | set;
+	u32 cmdcfg_sr;
 
-	bgmac_set(bgmac, BGMAC_CMDCFG, BGMAC_CMDCFG_SR(bgmac->core->id.rev));
+	if (bgmac->feature_flags & BGMAC_FEAT_CMDCFG_SR_REV4)
+		cmdcfg_sr = BGMAC_CMDCFG_SR_REV4;
+	else
+		cmdcfg_sr = BGMAC_CMDCFG_SR_REV0;
+
+	bgmac_set(bgmac, BGMAC_CMDCFG, cmdcfg_sr);
 	udelay(2);
 
 	if (new_val != cmdcfg || force)
 		bgmac_write(bgmac, BGMAC_CMDCFG, new_val);
 
-	bgmac_mask(bgmac, BGMAC_CMDCFG, ~BGMAC_CMDCFG_SR(bgmac->core->id.rev));
+	bgmac_mask(bgmac, BGMAC_CMDCFG, ~cmdcfg_sr);
 	udelay(2);
 }
 
@@ -804,7 +810,7 @@ static void bgmac_chip_stats_update(struct bgmac *bgmac)
 {
 	int i;
 
-	if (bgmac->core->id.id != BCMA_CORE_4706_MAC_GBIT) {
+	if (!(bgmac->feature_flags & BGMAC_FEAT_NO_CLR_MIB)) {
 		for (i = 0; i < BGMAC_NUM_MIB_TX_REGS; i++)
 			bgmac->mib_tx_regs[i] =
 				bgmac_read(bgmac,
@@ -823,7 +829,7 @@ static void bgmac_clear_mib(struct bgmac *bgmac)
 {
 	int i;
 
-	if (bgmac->core->id.id == BCMA_CORE_4706_MAC_GBIT)
+	if (bgmac->feature_flags & BGMAC_FEAT_NO_CLR_MIB)
 		return;
 
 	bgmac_set(bgmac, BGMAC_DEV_CTL, BGMAC_DC_MROR);
@@ -866,9 +872,8 @@ static void bgmac_mac_speed(struct bgmac *bgmac)
 static void bgmac_miiconfig(struct bgmac *bgmac)
 {
 	struct bcma_device *core = bgmac->core;
-	u8 imode;
 
-	if (bgmac_is_bcm4707_family(bgmac)) {
+	if (bgmac->feature_flags & BGMAC_FEAT_FORCE_SPEED_2500) {
 		bcma_awrite32(core, BCMA_IOCTL,
 			      bcma_aread32(core, BCMA_IOCTL) | 0x40 |
 			      BGMAC_BCMA_IOCTL_SW_CLKEN);
@@ -876,6 +881,8 @@ static void bgmac_miiconfig(struct bgmac *bgmac)
 		bgmac->mac_duplex = DUPLEX_FULL;
 		bgmac_mac_speed(bgmac);
 	} else {
+		u8 imode;
+
 		imode = (bgmac_read(bgmac, BGMAC_DEV_STATUS) &
 			BGMAC_DS_MM_MASK) >> BGMAC_DS_MM_SHIFT;
 		if (imode == 0 || imode == 1) {
@@ -890,9 +897,7 @@ static void bgmac_miiconfig(struct bgmac *bgmac)
 static void bgmac_chip_reset(struct bgmac *bgmac)
 {
 	struct bcma_device *core = bgmac->core;
-	struct bcma_bus *bus = core->bus;
-	struct bcma_chipinfo *ci = &bus->chipinfo;
-	u32 flags;
+	u32 cmdcfg_sr;
 	u32 iost;
 	int i;
 
@@ -915,15 +920,12 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 	}
 
 	iost = bcma_aread32(core, BCMA_IOST);
-	if ((ci->id == BCMA_CHIP_ID_BCM5357 && ci->pkg == BCMA_PKG_ID_BCM47186) ||
-	    (ci->id == BCMA_CHIP_ID_BCM4749 && ci->pkg == 10) ||
-	    (ci->id == BCMA_CHIP_ID_BCM53572 && ci->pkg == BCMA_PKG_ID_BCM47188))
+	if (bgmac->feature_flags & BGMAC_FEAT_IOST_ATTACHED)
 		iost &= ~BGMAC_BCMA_IOST_ATTACHED;
 
 	/* 3GMAC: for BCM4707 & BCM47094, only do core reset at bgmac_probe() */
-	if (ci->id != BCMA_CHIP_ID_BCM4707 &&
-	    ci->id != BCMA_CHIP_ID_BCM47094) {
-		flags = 0;
+	if (!(bgmac->feature_flags & BGMAC_FEAT_NO_RESET)) {
+		u32 flags = 0;
 		if (iost & BGMAC_BCMA_IOST_ATTACHED) {
 			flags = BGMAC_BCMA_IOCTL_SW_CLKEN;
 			if (!bgmac->has_robosw)
@@ -933,7 +935,7 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 	}
 
 	/* Request Misc PLL for corerev > 2 */
-	if (core->id.rev > 2 && !bgmac_is_bcm4707_family(bgmac)) {
+	if (bgmac->feature_flags & BGMAC_FEAT_MISC_PLL_REQ) {
 		bgmac_set(bgmac, BCMA_CLKCTLST,
 			  BGMAC_BCMA_CLKCTLST_MISC_PLL_REQ);
 		bgmac_wait_value(bgmac->core, BCMA_CLKCTLST,
@@ -942,9 +944,7 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 				 1000);
 	}
 
-	if (ci->id == BCMA_CHIP_ID_BCM5357 ||
-	    ci->id == BCMA_CHIP_ID_BCM4749 ||
-	    ci->id == BCMA_CHIP_ID_BCM53572) {
+	if (bgmac->feature_flags & BGMAC_FEAT_SW_TYPE_PHY) {
 		struct bcma_drv_cc *cc = &bgmac->core->bus->drv_cc;
 		u8 et_swtype = 0;
 		u8 sw_type = BGMAC_CHIPCTL_1_SW_TYPE_EPHY |
@@ -958,11 +958,9 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 			et_swtype &= 0x0f;
 			et_swtype <<= 4;
 			sw_type = et_swtype;
-		} else if (ci->id == BCMA_CHIP_ID_BCM5357 && ci->pkg == BCMA_PKG_ID_BCM5358) {
+		} else if (bgmac->feature_flags & BGMAC_FEAT_SW_TYPE_EPHYRMII) {
 			sw_type = BGMAC_CHIPCTL_1_SW_TYPE_EPHYRMII;
-		} else if ((ci->id == BCMA_CHIP_ID_BCM5357 && ci->pkg == BCMA_PKG_ID_BCM47186) ||
-			   (ci->id == BCMA_CHIP_ID_BCM4749 && ci->pkg == 10) ||
-			   (ci->id == BCMA_CHIP_ID_BCM53572 && ci->pkg == BCMA_PKG_ID_BCM47188)) {
+		} else if (bgmac->feature_flags & BGMAC_FEAT_SW_TYPE_RGMII) {
 			sw_type = BGMAC_CHIPCTL_1_IF_TYPE_RGMII |
 				  BGMAC_CHIPCTL_1_SW_TYPE_RGMII;
 		}
@@ -982,6 +980,11 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 	 * BGMAC_CMDCFG is read _after_ putting chip in a reset. So it has to
 	 * be keps until taking MAC out of the reset.
 	 */
+	if (bgmac->feature_flags & BGMAC_FEAT_CMDCFG_SR_REV4)
+		cmdcfg_sr = BGMAC_CMDCFG_SR_REV4;
+	else
+		cmdcfg_sr = BGMAC_CMDCFG_SR_REV0;
+
 	bgmac_cmdcfg_maskset(bgmac,
 			     ~(BGMAC_CMDCFG_TE |
 			       BGMAC_CMDCFG_RE |
@@ -999,13 +1002,13 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
 			     BGMAC_CMDCFG_PROM |
 			     BGMAC_CMDCFG_NLC |
 			     BGMAC_CMDCFG_CFE |
-			     BGMAC_CMDCFG_SR(core->id.rev),
+			     cmdcfg_sr,
 			     false);
 	bgmac->mac_speed = SPEED_UNKNOWN;
 	bgmac->mac_duplex = DUPLEX_UNKNOWN;
 
 	bgmac_clear_mib(bgmac);
-	if (core->id.id == BCMA_CORE_4706_MAC_GBIT)
+	if (bgmac->feature_flags & BGMAC_FEAT_CMN_PHY_CTL)
 		bcma_maskset32(bgmac->cmn, BCMA_GMAC_CMN_PHY_CTL, ~0,
 			       BCMA_GMAC_CMN_PC_MTE);
 	else
@@ -1031,46 +1034,48 @@ static void bgmac_chip_intrs_off(struct bgmac *bgmac)
 /* http://bcm-v4.sipsolutions.net/mac-gbit/gmac/gmac_enable */
 static void bgmac_enable(struct bgmac *bgmac)
 {
-	struct bcma_chipinfo *ci = &bgmac->core->bus->chipinfo;
+	u32 cmdcfg_sr;
 	u32 cmdcfg;
 	u32 mode;
-	u32 rxq_ctl;
-	u32 fl_ctl;
-	u16 bp_clk;
-	u8 mdp;
+
+	if (bgmac->feature_flags & BGMAC_FEAT_CMDCFG_SR_REV4)
+		cmdcfg_sr = BGMAC_CMDCFG_SR_REV4;
+	else
+		cmdcfg_sr = BGMAC_CMDCFG_SR_REV0;
 
 	cmdcfg = bgmac_read(bgmac, BGMAC_CMDCFG);
 	bgmac_cmdcfg_maskset(bgmac, ~(BGMAC_CMDCFG_TE | BGMAC_CMDCFG_RE),
-			     BGMAC_CMDCFG_SR(bgmac->core->id.rev), true);
+			     cmdcfg_sr, true);
 	udelay(2);
 	cmdcfg |= BGMAC_CMDCFG_TE | BGMAC_CMDCFG_RE;
 	bgmac_write(bgmac, BGMAC_CMDCFG, cmdcfg);
 
 	mode = (bgmac_read(bgmac, BGMAC_DEV_STATUS) & BGMAC_DS_MM_MASK) >>
 		BGMAC_DS_MM_SHIFT;
-	if (ci->id != BCMA_CHIP_ID_BCM47162 || mode != 0)
+	if (bgmac->feature_flags & BGMAC_FEAT_CLKCTLST || mode != 0)
 		bgmac_set(bgmac, BCMA_CLKCTLST, BCMA_CLKCTLST_FORCEHT);
-	if (ci->id == BCMA_CHIP_ID_BCM47162 && mode == 2)
+	if (bgmac->feature_flags & BGMAC_FEAT_CLKCTLST && mode == 2)
 		bcma_chipco_chipctl_maskset(&bgmac->core->bus->drv_cc, 1, ~0,
 					    BGMAC_CHIPCTL_1_RXC_DLL_BYPASS);
 
-	switch (ci->id) {
-	case BCMA_CHIP_ID_BCM5357:
-	case BCMA_CHIP_ID_BCM4749:
-	case BCMA_CHIP_ID_BCM53572:
-	case BCMA_CHIP_ID_BCM4716:
-	case BCMA_CHIP_ID_BCM47162:
-		fl_ctl = 0x03cb04cb;
-		if (ci->id == BCMA_CHIP_ID_BCM5357 ||
-		    ci->id == BCMA_CHIP_ID_BCM4749 ||
-		    ci->id == BCMA_CHIP_ID_BCM53572)
+	if (bgmac->feature_flags & (BGMAC_FEAT_FLW_CTRL1 |
+				    BGMAC_FEAT_FLW_CTRL2)) {
+		u32 fl_ctl;
+
+		if (bgmac->feature_flags & BGMAC_FEAT_FLW_CTRL1)
 			fl_ctl = 0x2300e1;
+		else
+			fl_ctl = 0x03cb04cb;
+
 		bgmac_write(bgmac, BGMAC_FLOW_CTL_THRESH, fl_ctl);
 		bgmac_write(bgmac, BGMAC_PAUSE_CTL, 0x27fff);
-		break;
 	}
 
-	if (!bgmac_is_bcm4707_family(bgmac)) {
+	if (bgmac->feature_flags & BGMAC_FEAT_SET_RXQ_CLK) {
+		u32 rxq_ctl;
+		u16 bp_clk;
+		u8 mdp;
+
 		rxq_ctl = bgmac_read(bgmac, BGMAC_RXQ_CTL);
 		rxq_ctl &= ~BGMAC_RXQ_CTL_MDP_MASK;
 		bp_clk = bcma_pmu_get_bus_clock(&bgmac->core->bus->drv_cc) /
@@ -1585,6 +1590,74 @@ static int bgmac_probe(struct bcma_device *core)
 	if (core->bus->sprom.boardflags_lo & BGMAC_BFL_ENETADM)
 		dev_warn(bgmac->dev, "Support for ADMtek ethernet switch not implemented\n");
 
+	/* Feature Flags */
+	switch (core->bus->chipinfo.id) {
+	case BCMA_CHIP_ID_BCM5357:
+		bgmac->feature_flags |= BGMAC_FEAT_SET_RXQ_CLK;
+		bgmac->feature_flags |= BGMAC_FEAT_CLKCTLST;
+		bgmac->feature_flags |= BGMAC_FEAT_FLW_CTRL1;
+		bgmac->feature_flags |= BGMAC_FEAT_SW_TYPE_PHY;
+		if (core->bus->chipinfo.pkg == BCMA_PKG_ID_BCM47186) {
+			bgmac->feature_flags |= BGMAC_FEAT_IOST_ATTACHED;
+			bgmac->feature_flags |= BGMAC_FEAT_SW_TYPE_RGMII;
+		}
+		if (core->bus->chipinfo.pkg == BCMA_PKG_ID_BCM5358)
+			bgmac->feature_flags |= BGMAC_FEAT_SW_TYPE_EPHYRMII;
+		break;
+	case BCMA_CHIP_ID_BCM53572:
+		bgmac->feature_flags |= BGMAC_FEAT_SET_RXQ_CLK;
+		bgmac->feature_flags |= BGMAC_FEAT_CLKCTLST;
+		bgmac->feature_flags |= BGMAC_FEAT_FLW_CTRL1;
+		bgmac->feature_flags |= BGMAC_FEAT_SW_TYPE_PHY;
+		if (core->bus->chipinfo.pkg == BCMA_PKG_ID_BCM47188) {
+			bgmac->feature_flags |= BGMAC_FEAT_SW_TYPE_RGMII;
+			bgmac->feature_flags |= BGMAC_FEAT_IOST_ATTACHED;
+		}
+		break;
+	case BCMA_CHIP_ID_BCM4749:
+		bgmac->feature_flags |= BGMAC_FEAT_SET_RXQ_CLK;
+		bgmac->feature_flags |= BGMAC_FEAT_CLKCTLST;
+		bgmac->feature_flags |= BGMAC_FEAT_FLW_CTRL1;
+		bgmac->feature_flags |= BGMAC_FEAT_SW_TYPE_PHY;
+		if (core->bus->chipinfo.pkg == 10) {
+			bgmac->feature_flags |= BGMAC_FEAT_SW_TYPE_RGMII;
+			bgmac->feature_flags |= BGMAC_FEAT_IOST_ATTACHED;
+		}
+		break;
+	case BCMA_CHIP_ID_BCM4716:
+		bgmac->feature_flags |= BGMAC_FEAT_CLKCTLST;
+		/* fallthrough */
+	case BCMA_CHIP_ID_BCM47162:
+		bgmac->feature_flags |= BGMAC_FEAT_FLW_CTRL2;
+		bgmac->feature_flags |= BGMAC_FEAT_SET_RXQ_CLK;
+		break;
+	/* bcm4707_family */
+	case BCMA_CHIP_ID_BCM4707:
+	case BCMA_CHIP_ID_BCM47094:
+	case BCMA_CHIP_ID_BCM53018:
+		bgmac->feature_flags |= BGMAC_FEAT_CLKCTLST;
+		bgmac->feature_flags |= BGMAC_FEAT_NO_RESET;
+		bgmac->feature_flags |= BGMAC_FEAT_FORCE_SPEED_2500;
+		break;
+	default:
+		bgmac->feature_flags |= BGMAC_FEAT_CLKCTLST;
+		bgmac->feature_flags |= BGMAC_FEAT_SET_RXQ_CLK;
+	}
+
+	if (!bgmac_is_bcm4707_family(bgmac) && core->id.rev > 2)
+		bgmac->feature_flags |= BGMAC_FEAT_MISC_PLL_REQ;
+
+	if (core->id.id == BCMA_CORE_4706_MAC_GBIT) {
+		bgmac->feature_flags |= BGMAC_FEAT_CMN_PHY_CTL;
+		bgmac->feature_flags |= BGMAC_FEAT_NO_CLR_MIB;
+	}
+
+	if (core->id.rev >= 4) {
+		bgmac->feature_flags |= BGMAC_FEAT_CMDCFG_SR_REV4;
+		bgmac->feature_flags |= BGMAC_FEAT_TX_MASK_SETUP;
+		bgmac->feature_flags |= BGMAC_FEAT_RX_MASK_SETUP;
+	}
+
 	netif_napi_add(net_dev, &bgmac->napi, bgmac_poll, BGMAC_WEIGHT);
 
 	if (!bgmac_is_bcm4707_family(bgmac)) {
diff --git a/drivers/net/ethernet/broadcom/bgmac.h b/drivers/net/ethernet/broadcom/bgmac.h
index 191e64a..89dfee1 100644
--- a/drivers/net/ethernet/broadcom/bgmac.h
+++ b/drivers/net/ethernet/broadcom/bgmac.h
@@ -190,7 +190,6 @@
 #define  BGMAC_CMDCFG_HD_SHIFT			10
 #define  BGMAC_CMDCFG_SR_REV0			0x00000800	/* Set to reset mode, for core rev 0-3 */
 #define  BGMAC_CMDCFG_SR_REV4			0x00002000	/* Set to reset mode, for core rev >= 4 */
-#define  BGMAC_CMDCFG_SR(rev)  ((rev >= 4) ? BGMAC_CMDCFG_SR_REV4 : BGMAC_CMDCFG_SR_REV0)
 #define  BGMAC_CMDCFG_ML			0x00008000	/* Set to activate mac loopback mode */
 #define  BGMAC_CMDCFG_AE			0x00400000
 #define  BGMAC_CMDCFG_CFE			0x00800000
@@ -376,6 +375,24 @@
 
 #define ETHER_MAX_LEN   1518
 
+/* Feature Flags */
+#define BGMAC_FEAT_TX_MASK_SETUP	BIT(0)
+#define BGMAC_FEAT_RX_MASK_SETUP	BIT(1)
+#define BGMAC_FEAT_IOST_ATTACHED	BIT(2)
+#define BGMAC_FEAT_NO_RESET		BIT(3)
+#define BGMAC_FEAT_MISC_PLL_REQ		BIT(4)
+#define BGMAC_FEAT_SW_TYPE_PHY		BIT(5)
+#define BGMAC_FEAT_SW_TYPE_EPHYRMII	BIT(6)
+#define BGMAC_FEAT_SW_TYPE_RGMII	BIT(7)
+#define BGMAC_FEAT_CMN_PHY_CTL		BIT(8)
+#define BGMAC_FEAT_FLW_CTRL1		BIT(9)
+#define BGMAC_FEAT_FLW_CTRL2		BIT(10)
+#define BGMAC_FEAT_SET_RXQ_CLK		BIT(11)
+#define BGMAC_FEAT_CLKCTLST		BIT(12)
+#define BGMAC_FEAT_NO_CLR_MIB		BIT(13)
+#define BGMAC_FEAT_FORCE_SPEED_2500	BIT(14)
+#define BGMAC_FEAT_CMDCFG_SR_REV4	BIT(15)
+
 struct bgmac_slot_info {
 	union {
 		struct sk_buff *skb;
@@ -430,6 +447,8 @@ struct bgmac {
 
 	struct device *dev;
 	struct device *dma_dev;
+	u32 feature_flags;
+
 	struct net_device *net_dev;
 	struct napi_struct napi;
 	struct mii_bus *mii_bus;
-- 
1.9.1
