From: Doug Berger <opendmb@gmail.com>
Subject: [PATCH net-next 12/12] net: bcmgenet: add support for the GENETv5 hardware
Date: Mon, 13 Mar 2017 17:41:42 -0700
Message-ID: <20170314004142.4746-13-opendmb@gmail.com>
References: <20170314004142.4746-1-opendmb@gmail.com>
Cc: robh+dt@kernel.org, mark.rutland@arm.com, davem@davemloft.net,
        rafal@milecki.pl, xow@google.com, joel@jms.id.au,
        jon.mason@broadcom.com, netdev@vger.kernel.org,
        devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
        pgynther@google.com, jaedon.shin@gmail.com,
        Doug Berger <opendmb@gmail.com>
To: f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314004142.4746-1-opendmb@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This commit adds support for the GENETv5 implementation.

The GENETv5 reports a major version of 6 instead of 5 so compensate
for this when verifying the configuration of the driver.  Also the
EPHY revision is now contained in the MDIO registers of the PHY so
the EPHY revision of 0 in GENET_VER_FMT is expected for GENETv5.

Signed-off-by: Doug Berger <opendmb@gmail.com>
---
 drivers/net/ethernet/broadcom/genet/bcmgenet.c | 91 ++++++++++++++++++++------
 drivers/net/ethernet/broadcom/genet/bcmgenet.h | 12 +++-
 drivers/net/ethernet/broadcom/genet/bcmmii.c   | 62 ++++++++++--------
 drivers/net/phy/mdio-bcm-unimac.c              |  3 +-
 4 files changed, 118 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.c b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
index 3b49c14128e2..d848ac58189c 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.c
@@ -1011,8 +1011,17 @@ static int bcmgenet_power_down(struct bcmgenet_priv *priv,
 		/* Power down LED */
 		if (priv->hw_params->flags & GENET_HAS_EXT) {
 			reg = bcmgenet_ext_readl(priv, EXT_EXT_PWR_MGMT);
-			reg |= (EXT_PWR_DOWN_PHY |
-				EXT_PWR_DOWN_DLL | EXT_PWR_DOWN_BIAS);
+			if (GENET_IS_V5(priv))
+				reg |= EXT_PWR_DOWN_PHY_EN |
+				       EXT_PWR_DOWN_PHY_RD |
+				       EXT_PWR_DOWN_PHY_SD |
+				       EXT_PWR_DOWN_PHY_RX |
+				       EXT_PWR_DOWN_PHY_TX |
+				       EXT_IDDQ_GLBL_PWR;
+			else
+				reg |= EXT_PWR_DOWN_PHY;
+
+			reg |= (EXT_PWR_DOWN_DLL | EXT_PWR_DOWN_BIAS);
 			bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
 
 			bcmgenet_phy_power_set(priv->dev, false);
@@ -1037,12 +1046,34 @@ static void bcmgenet_power_up(struct bcmgenet_priv *priv,
 
 	switch (mode) {
 	case GENET_POWER_PASSIVE:
-		reg &= ~(EXT_PWR_DOWN_DLL | EXT_PWR_DOWN_PHY |
-				EXT_PWR_DOWN_BIAS);
-		/* fallthrough */
+		reg &= ~(EXT_PWR_DOWN_DLL | EXT_PWR_DOWN_BIAS);
+		if (GENET_IS_V5(priv)) {
+			reg &= ~(EXT_PWR_DOWN_PHY_EN |
+				 EXT_PWR_DOWN_PHY_RD |
+				 EXT_PWR_DOWN_PHY_SD |
+				 EXT_PWR_DOWN_PHY_RX |
+				 EXT_PWR_DOWN_PHY_TX |
+				 EXT_IDDQ_GLBL_PWR);
+			reg |=   EXT_PHY_RESET;
+			bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
+			mdelay(1);
+
+			reg &=  ~EXT_PHY_RESET;
+		} else {
+			reg &= ~EXT_PWR_DOWN_PHY;
+			reg |= EXT_PWR_DN_EN_LD;
+		}
+		bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
+		bcmgenet_phy_power_set(priv->dev, true);
+		bcmgenet_mii_reset(priv->dev);
+		break;
+
 	case GENET_POWER_CABLE_SENSE:
 		/* enable APD */
-		reg |= EXT_PWR_DN_EN_LD;
+		if (!GENET_IS_V5(priv)) {
+			reg |= EXT_PWR_DN_EN_LD;
+			bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
+		}
 		break;
 	case GENET_POWER_WOL_MAGIC:
 		bcmgenet_wol_power_up_cfg(priv, mode);
@@ -1050,12 +1081,6 @@ static void bcmgenet_power_up(struct bcmgenet_priv *priv,
 	default:
 		break;
 	}
-
-	bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
-	if (mode == GENET_POWER_PASSIVE) {
-		bcmgenet_phy_power_set(priv->dev, true);
-		bcmgenet_mii_reset(priv->dev);
-	}
 }
 
 /* ioctl handle special commands that are not present in ethtool. */
@@ -3101,6 +3126,25 @@ static struct bcmgenet_hw_params bcmgenet_hw_params[] = {
 		.flags = GENET_HAS_40BITS | GENET_HAS_EXT |
 			 GENET_HAS_MDIO_INTR | GENET_HAS_MOCA_LINK_DET,
 	},
+	[GENET_V5] = {
+		.tx_queues = 4,
+		.tx_bds_per_q = 32,
+		.rx_queues = 0,
+		.rx_bds_per_q = 0,
+		.bp_in_en_shift = 17,
+		.bp_in_mask = 0x1ffff,
+		.hfb_filter_cnt = 48,
+		.hfb_filter_size = 128,
+		.qtag_mask = 0x3F,
+		.tbuf_offset = 0x0600,
+		.hfb_offset = 0x8000,
+		.hfb_reg_offset = 0xfc00,
+		.rdma_offset = 0x2000,
+		.tdma_offset = 0x4000,
+		.words_per_bd = 3,
+		.flags = GENET_HAS_40BITS | GENET_HAS_EXT |
+			 GENET_HAS_MDIO_INTR | GENET_HAS_MOCA_LINK_DET,
+	},
 };
 
 /* Infer hardware parameters from the detected GENET version */
@@ -3111,7 +3155,7 @@ static void bcmgenet_set_hw_params(struct bcmgenet_priv *priv)
 	u8 major;
 	u16 gphy_rev;
 
-	if (GENET_IS_V4(priv)) {
+	if (GENET_IS_V5(priv) || GENET_IS_V4(priv)) {
 		bcmgenet_dma_regs = bcmgenet_dma_regs_v3plus;
 		genet_dma_ring_regs = genet_dma_ring_regs_v4;
 		priv->dma_rx_chk_bit = DMA_RX_CHK_V3PLUS;
@@ -3136,7 +3180,9 @@ static void bcmgenet_set_hw_params(struct bcmgenet_priv *priv)
 	/* Read GENET HW version */
 	reg = bcmgenet_sys_readl(priv, SYS_REV_CTRL);
 	major = (reg >> 24 & 0x0f);
-	if (major == 5)
+	if (major == 6)
+		major = 5;
+	else if (major == 5)
 		major = 4;
 	else if (major == 0)
 		major = 1;
@@ -3164,16 +3210,22 @@ static void bcmgenet_set_hw_params(struct bcmgenet_priv *priv)
 	 */
 	gphy_rev = reg & 0xffff;
 
+	if (GENET_IS_V5(priv)) {
+		/* The EPHY revision should come from the MDIO registers of
+		 * the PHY not from GENET.
+		 */
+		if (gphy_rev != 0) {
+			pr_warn("GENET is reporting EPHY revision: 0x%04x\n",
+				gphy_rev);
+		}
 	/* This is the good old scheme, just GPHY major, no minor nor patch */
-	if ((gphy_rev & 0xf0) != 0)
+	} else if ((gphy_rev & 0xf0) != 0) {
 		priv->gphy_rev = gphy_rev << 8;
-
 	/* This is the new scheme, GPHY major rolls over with 0x10 = rev G0 */
-	else if ((gphy_rev & 0xff00) != 0)
+	} else if ((gphy_rev & 0xff00) != 0) {
 		priv->gphy_rev = gphy_rev;
-
 	/* This is reserved so should require special treatment */
-	else if (gphy_rev == 0 || gphy_rev == 0x01ff) {
+	} else if (gphy_rev == 0 || gphy_rev == 0x01ff) {
 		pr_warn("Invalid GPHY revision detected: 0x%04x\n", gphy_rev);
 		return;
 	}
@@ -3206,6 +3258,7 @@ static const struct of_device_id bcmgenet_match[] = {
 	{ .compatible = "brcm,genet-v2", .data = (void *)GENET_V2 },
 	{ .compatible = "brcm,genet-v3", .data = (void *)GENET_V3 },
 	{ .compatible = "brcm,genet-v4", .data = (void *)GENET_V4 },
+	{ .compatible = "brcm,genet-v5", .data = (void *)GENET_V5 },
 	{ },
 };
 MODULE_DEVICE_TABLE(of, bcmgenet_match);
diff --git a/drivers/net/ethernet/broadcom/genet/bcmgenet.h b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
index 1e2dc34d331a..1001d9131ba8 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmgenet.h
+++ b/drivers/net/ethernet/broadcom/genet/bcmgenet.h
@@ -1,5 +1,5 @@
 /*
- * Copyright (c) 2014 Broadcom Corporation
+ * Copyright (c) 2014-2017 Broadcom
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -351,8 +351,14 @@ struct bcmgenet_mib_counters {
 #define  EXT_PWR_DN_EN_LD		(1 << 3)
 #define  EXT_ENERGY_DET			(1 << 4)
 #define  EXT_IDDQ_FROM_PHY		(1 << 5)
+#define  EXT_IDDQ_GLBL_PWR		(1 << 7)
 #define  EXT_PHY_RESET			(1 << 8)
 #define  EXT_ENERGY_DET_MASK		(1 << 12)
+#define  EXT_PWR_DOWN_PHY_TX		(1 << 16)
+#define  EXT_PWR_DOWN_PHY_RX		(1 << 17)
+#define  EXT_PWR_DOWN_PHY_SD		(1 << 18)
+#define  EXT_PWR_DOWN_PHY_RD		(1 << 19)
+#define  EXT_PWR_DOWN_PHY_EN		(1 << 20)
 
 #define EXT_RGMII_OOB_CTRL		0x0C
 #define  RGMII_LINK			(1 << 4)
@@ -495,13 +501,15 @@ enum bcmgenet_version {
 	GENET_V1 = 1,
 	GENET_V2,
 	GENET_V3,
-	GENET_V4
+	GENET_V4,
+	GENET_V5
 };
 
 #define GENET_IS_V1(p)	((p)->version == GENET_V1)
 #define GENET_IS_V2(p)	((p)->version == GENET_V2)
 #define GENET_IS_V3(p)	((p)->version == GENET_V3)
 #define GENET_IS_V4(p)	((p)->version == GENET_V4)
+#define GENET_IS_V5(p)	((p)->version == GENET_V5)
 
 /* Hardware flags */
 #define GENET_HAS_40BITS	(1 << 0)
diff --git a/drivers/net/ethernet/broadcom/genet/bcmmii.c b/drivers/net/ethernet/broadcom/genet/bcmmii.c
index e87607621e62..8df47c90cfc5 100644
--- a/drivers/net/ethernet/broadcom/genet/bcmmii.c
+++ b/drivers/net/ethernet/broadcom/genet/bcmmii.c
@@ -1,7 +1,7 @@
 /*
  * Broadcom GENET MDIO routines
  *
- * Copyright (c) 2014 Broadcom Corporation
+ * Copyright (c) 2014-2017 Broadcom
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -195,29 +195,31 @@ void bcmgenet_phy_power_set(struct net_device *dev, bool enable)
 	u32 reg = 0;
 
 	/* EXT_GPHY_CTRL is only valid for GENETv4 and onward */
-	if (!GENET_IS_V4(priv))
-		return;
-
-	reg = bcmgenet_ext_readl(priv, EXT_GPHY_CTRL);
-	if (enable) {
-		reg &= ~EXT_CK25_DIS;
-		bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
-		mdelay(1);
-
-		reg &= ~(EXT_CFG_IDDQ_BIAS | EXT_CFG_PWR_DOWN);
-		reg |= EXT_GPHY_RESET;
+	if (GENET_IS_V4(priv)) {
+		reg = bcmgenet_ext_readl(priv, EXT_GPHY_CTRL);
+		if (enable) {
+			reg &= ~EXT_CK25_DIS;
+			bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
+			mdelay(1);
+
+			reg &= ~(EXT_CFG_IDDQ_BIAS | EXT_CFG_PWR_DOWN);
+			reg |= EXT_GPHY_RESET;
+			bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
+			mdelay(1);
+
+			reg &= ~EXT_GPHY_RESET;
+		} else {
+			reg |= EXT_CFG_IDDQ_BIAS | EXT_CFG_PWR_DOWN |
+			       EXT_GPHY_RESET;
+			bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
+			mdelay(1);
+			reg |= EXT_CK25_DIS;
+		}
 		bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
-		mdelay(1);
-
-		reg &= ~EXT_GPHY_RESET;
+		udelay(60);
 	} else {
-		reg |= EXT_CFG_IDDQ_BIAS | EXT_CFG_PWR_DOWN | EXT_GPHY_RESET;
-		bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
 		mdelay(1);
-		reg |= EXT_CK25_DIS;
 	}
-	bcmgenet_ext_writel(priv, reg, EXT_GPHY_CTRL);
-	udelay(60);
 }
 
 static void bcmgenet_internal_phy_setup(struct net_device *dev)
@@ -227,10 +229,12 @@ static void bcmgenet_internal_phy_setup(struct net_device *dev)
 
 	/* Power up PHY */
 	bcmgenet_phy_power_set(dev, true);
-	/* enable APD */
-	reg = bcmgenet_ext_readl(priv, EXT_EXT_PWR_MGMT);
-	reg |= EXT_PWR_DN_EN_LD;
-	bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
+	if (!GENET_IS_V5(priv)) {
+		/* enable APD */
+		reg = bcmgenet_ext_readl(priv, EXT_EXT_PWR_MGMT);
+		reg |= EXT_PWR_DN_EN_LD;
+		bcmgenet_ext_writel(priv, reg, EXT_EXT_PWR_MGMT);
+	}
 	bcmgenet_mii_reset(dev);
 }
 
@@ -238,10 +242,12 @@ static void bcmgenet_moca_phy_setup(struct bcmgenet_priv *priv)
 {
 	u32 reg;
 
-	/* Speed settings are set in bcmgenet_mii_setup() */
-	reg = bcmgenet_sys_readl(priv, SYS_PORT_CTRL);
-	reg |= LED_ACT_SOURCE_MAC;
-	bcmgenet_sys_writel(priv, reg, SYS_PORT_CTRL);
+	if (!GENET_IS_V5(priv)) {
+		/* Speed settings are set in bcmgenet_mii_setup() */
+		reg = bcmgenet_sys_readl(priv, SYS_PORT_CTRL);
+		reg |= LED_ACT_SOURCE_MAC;
+		bcmgenet_sys_writel(priv, reg, SYS_PORT_CTRL);
+	}
 
 	if (priv->hw_params->flags & GENET_HAS_MOCA_LINK_DET)
 		fixed_phy_set_link_update(priv->phydev,
diff --git a/drivers/net/phy/mdio-bcm-unimac.c b/drivers/net/phy/mdio-bcm-unimac.c
index 8c73b2e771dd..34395230ce70 100644
--- a/drivers/net/phy/mdio-bcm-unimac.c
+++ b/drivers/net/phy/mdio-bcm-unimac.c
@@ -1,7 +1,7 @@
 /*
  * Broadcom UniMAC MDIO bus controller driver
  *
- * Copyright (C) 2014, Broadcom Corporation
+ * Copyright (C) 2014-2017 Broadcom
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License as published by
@@ -228,6 +228,7 @@ static int unimac_mdio_remove(struct platform_device *pdev)
 }
 
 static const struct of_device_id unimac_mdio_ids[] = {
+	{ .compatible = "brcm,genet-mdio-v5", },
 	{ .compatible = "brcm,genet-mdio-v4", },
 	{ .compatible = "brcm,genet-mdio-v3", },
 	{ .compatible = "brcm,genet-mdio-v2", },
-- 
2.11.1
