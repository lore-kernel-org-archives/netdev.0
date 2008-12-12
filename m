From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 22/33] sfc: Add support for Solarflare 10Xpress SFT9001
Date: Fri, 12 Dec 2008 12:56:06 +0000
Message-ID: <20081212125605.GV10372@solarflare.com>
References: <cover.1229085672.git.bhutchings@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:55420 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757643AbYLLM4K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 07:56:10 -0500
Content-Disposition: inline
In-Reply-To: <20081212124622.GK32518@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add type codes for the new PHY and rename the SFX7101 type code.

Add definition of clause 22 extension MMD.

Adapt the 10Xpress SFX7101 code to support the SFT9001 as well.
Clean up register definitions.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/enum.h        |    3 +
 drivers/net/sfc/ethtool.c     |    3 +
 drivers/net/sfc/falcon.c      |   10 +-
 drivers/net/sfc/mdio_10g.h    |    8 +
 drivers/net/sfc/net_driver.h  |    4 +-
 drivers/net/sfc/phy.h         |    7 +-
 drivers/net/sfc/tenxpress.c   |  528 +++++++++++++++++++++++++++++++++--------
 drivers/net/sfc/workarounds.h |    9 +-
 8 files changed, 467 insertions(+), 105 deletions(-)

diff --git a/drivers/net/sfc/enum.h b/drivers/net/sfc/enum.h
index 0c2e41c..60cbc6e 100644
--- a/drivers/net/sfc/enum.h
+++ b/drivers/net/sfc/enum.h
@@ -58,6 +58,9 @@ extern const char *efx_loopback_mode_names[];
 #define LOOPBACK_INTERNAL(_efx)				\
 	(!!(LOOPBACKS_INTERNAL & LOOPBACK_MASK(_efx)))
 
+#define LOOPBACK_CHANGED(_from, _to, _mask)				\
+	(!!((LOOPBACK_MASK(_from) ^ LOOPBACK_MASK(_to)) & (_mask)))
+
 #define LOOPBACK_OUT_OF(_from, _to, _mask)				\
 	((LOOPBACK_MASK(_from) & (_mask)) && !(LOOPBACK_MASK(_to) & (_mask)))
 
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 0e81af6..aad0d1b 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -219,6 +219,9 @@ int efx_ethtool_set_settings(struct net_device *net_dev,
 	struct efx_nic *efx = netdev_priv(net_dev);
 	int rc;
 
+	if (EFX_WORKAROUND_13963(efx) && !ecmd->autoneg)
+		return -EINVAL;
+
 	/* Falcon GMAC does not support 1000Mbps HD */
 	if (ecmd->speed == SPEED_1000 && ecmd->duplex != DUPLEX_FULL) {
 		EFX_LOG(efx, "rejecting unsupported 1000Mbps HD"
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 734add1..68747c8 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -826,7 +826,7 @@ static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 #endif
 
 	if (unlikely(rx_ev_eth_crc_err && EFX_WORKAROUND_10750(efx) &&
-		     efx->phy_type == PHY_TYPE_10XPRESS))
+		     efx->phy_type == PHY_TYPE_SFX7101))
 		tenxpress_crc_err(efx);
 }
 
@@ -2256,8 +2256,12 @@ static void falcon_init_mdio(struct mii_if_info *gmii)
 static int falcon_probe_phy(struct efx_nic *efx)
 {
 	switch (efx->phy_type) {
-	case PHY_TYPE_10XPRESS:
-		efx->phy_op = &falcon_tenxpress_phy_ops;
+	case PHY_TYPE_SFX7101:
+		efx->phy_op = &falcon_sfx7101_phy_ops;
+		break;
+	case PHY_TYPE_SFT9001A:
+	case PHY_TYPE_SFT9001B:
+		efx->phy_op = &falcon_sft9001_phy_ops;
 		break;
 	case PHY_TYPE_XFP:
 		efx->phy_op = &falcon_xfp_phy_ops;
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index 80c63dd..4091182 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -33,6 +33,8 @@
 #define MDIO_MMD_TC	(6)
 /* Auto negotiation */
 #define MDIO_MMD_AN	(7)
+/* Clause 22 extension */
+#define MDIO_MMD_C22EXT	29
 
 /* Generic register locations */
 #define MDIO_MMDREG_CTRL1	(0)
@@ -82,6 +84,7 @@
 #define MDIO_MMDREG_DEVS_PCS	DEV_PRESENT_BIT(MDIO_MMD_PCS)
 #define MDIO_MMDREG_DEVS_PMAPMD	DEV_PRESENT_BIT(MDIO_MMD_PMAPMD)
 #define MDIO_MMDREG_DEVS_AN	DEV_PRESENT_BIT(MDIO_MMD_AN)
+#define MDIO_MMDREG_DEVS_C22EXT	DEV_PRESENT_BIT(MDIO_MMD_C22EXT)
 
 /* Bits in MMDREG_SPEED */
 #define MDIO_MMDREG_SPEED_10G_LBN	0
@@ -125,6 +128,11 @@
 #define MDIO_PMAPMD_CTRL2_10_BT		(0xf)
 #define MDIO_PMAPMD_CTRL2_TYPE_MASK	(0xf)
 
+/* PMA 10GBT registers */
+#define MDIO_PMAPMD_10GBT_TXPWR		(131)
+#define MDIO_PMAPMD_10GBT_TXPWR_SHORT_LBN (0)
+#define MDIO_PMAPMD_10GBT_TXPWR_SHORT_WIDTH (1)
+
 /* PHY XGXS lane state */
 #define MDIO_PHYXS_LANE_STATE		(0x18)
 #define MDIO_PHYXS_LANE_ALIGNED_LBN	(12)
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 61d09a2..1728329 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -455,9 +455,11 @@ enum phy_type {
 	PHY_TYPE_NONE = 0,
 	PHY_TYPE_CX4_RTMR = 1,
 	PHY_TYPE_1G_ALASKA = 2,
-	PHY_TYPE_10XPRESS = 3,
+	PHY_TYPE_SFX7101 = 3,
 	PHY_TYPE_XFP = 4,
 	PHY_TYPE_PM8358 = 6,
+	PHY_TYPE_SFT9001A = 8,
+	PHY_TYPE_SFT9001B = 10,
 	PHY_TYPE_MAX	/* Insert any new items before this */
 };
 
diff --git a/drivers/net/sfc/phy.h b/drivers/net/sfc/phy.h
index f746536..58c493e 100644
--- a/drivers/net/sfc/phy.h
+++ b/drivers/net/sfc/phy.h
@@ -1,6 +1,6 @@
 /****************************************************************************
  * Driver for Solarflare Solarstorm network controllers and boards
- * Copyright 2007 Solarflare Communications Inc.
+ * Copyright 2007-2008 Solarflare Communications Inc.
  *
  * This program is free software; you can redistribute it and/or modify it
  * under the terms of the GNU General Public License version 2 as published
@@ -11,9 +11,10 @@
 #define EFX_PHY_H
 
 /****************************************************************************
- * 10Xpress (SFX7101) PHY
+ * 10Xpress (SFX7101 and SFT9001) PHYs
  */
-extern struct efx_phy_operations falcon_tenxpress_phy_ops;
+extern struct efx_phy_operations falcon_sfx7101_phy_ops;
+extern struct efx_phy_operations falcon_sft9001_phy_ops;
 
 extern void tenxpress_phy_blink(struct efx_nic *efx, bool blink);
 extern void tenxpress_crc_err(struct efx_nic *efx);
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 7256ea4..b3ca2dc 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -15,38 +15,71 @@
 #include "phy.h"
 #include "falcon_hwdefs.h"
 #include "boards.h"
+#include "workarounds.h"
+#include "selftest.h"
 
-/* We expect these MMDs to be in the package */
+/* We expect these MMDs to be in the package.  SFT9001 also has a
+ * clause 22 extension MMD, but since it doesn't have all the generic
+ * MMD registers it is pointless to include it here.
+ */
 #define TENXPRESS_REQUIRED_DEVS (MDIO_MMDREG_DEVS_PMAPMD	| \
 				 MDIO_MMDREG_DEVS_PCS		| \
 				 MDIO_MMDREG_DEVS_PHYXS		| \
 				 MDIO_MMDREG_DEVS_AN)
 
-#define TENXPRESS_LOOPBACKS ((1 << LOOPBACK_PHYXS) |	\
-			     (1 << LOOPBACK_PCS) |	\
-			     (1 << LOOPBACK_PMAPMD) |	\
-			     (1 << LOOPBACK_NETWORK))
+#define SFX7101_LOOPBACKS ((1 << LOOPBACK_PHYXS) |	\
+			   (1 << LOOPBACK_PCS) |	\
+			   (1 << LOOPBACK_PMAPMD) |	\
+			   (1 << LOOPBACK_NETWORK))
+
+#define SFT9001_LOOPBACKS ((1 << LOOPBACK_GPHY) |	\
+			   (1 << LOOPBACK_PHYXS) |	\
+			   (1 << LOOPBACK_PCS) |	\
+			   (1 << LOOPBACK_PMAPMD) |	\
+			   (1 << LOOPBACK_NETWORK))
 
 /* We complain if we fail to see the link partner as 10G capable this many
  * times in a row (must be > 1 as sampling the autoneg. registers is racy)
  */
 #define MAX_BAD_LP_TRIES	(5)
 
+/* LASI Control */
+#define PMA_PMD_LASI_CTRL	36866
+#define PMA_PMD_LASI_STATUS	36869
+#define PMA_PMD_LS_ALARM_LBN	0
+#define PMA_PMD_LS_ALARM_WIDTH	1
+#define PMA_PMD_TX_ALARM_LBN	1
+#define PMA_PMD_TX_ALARM_WIDTH	1
+#define PMA_PMD_RX_ALARM_LBN	2
+#define PMA_PMD_RX_ALARM_WIDTH	1
+#define PMA_PMD_AN_ALARM_LBN	3
+#define PMA_PMD_AN_ALARM_WIDTH	1
+
 /* Extended control register */
-#define	PMA_PMD_XCONTROL_REG 0xc000
-#define	PMA_PMD_LNPGA_POWERDOWN_LBN 8
-#define	PMA_PMD_LNPGA_POWERDOWN_WIDTH 1
+#define PMA_PMD_XCONTROL_REG	49152
+#define PMA_PMD_EXT_GMII_EN_LBN	1
+#define PMA_PMD_EXT_GMII_EN_WIDTH 1
+#define PMA_PMD_EXT_CLK_OUT_LBN	2
+#define PMA_PMD_EXT_CLK_OUT_WIDTH 1
+#define PMA_PMD_LNPGA_POWERDOWN_LBN 8	/* SFX7101 only */
+#define PMA_PMD_LNPGA_POWERDOWN_WIDTH 1
+#define PMA_PMD_EXT_CLK312_LBN	8	/* SFT9001 only */
+#define PMA_PMD_EXT_CLK312_WIDTH 1
+#define PMA_PMD_EXT_LPOWER_LBN  12
+#define PMA_PMD_EXT_LPOWER_WIDTH 1
+#define PMA_PMD_EXT_SSR_LBN	15
+#define PMA_PMD_EXT_SSR_WIDTH	1
 
 /* extended status register */
-#define PMA_PMD_XSTATUS_REG 0xc001
+#define PMA_PMD_XSTATUS_REG	49153
 #define PMA_PMD_XSTAT_FLP_LBN   (12)
 
 /* LED control register */
-#define PMA_PMD_LED_CTRL_REG	(0xc007)
+#define PMA_PMD_LED_CTRL_REG	49159
 #define PMA_PMA_LED_ACTIVITY_LBN	(3)
 
 /* LED function override register */
-#define PMA_PMD_LED_OVERR_REG	(0xc009)
+#define PMA_PMD_LED_OVERR_REG	49161
 /* Bit positions for different LEDs (there are more but not wired on SFE4001)*/
 #define PMA_PMD_LED_LINK_LBN	(0)
 #define PMA_PMD_LED_SPEED_LBN	(2)
@@ -63,36 +96,74 @@
 /* Green and Amber under hardware control, Red off */
 #define PMA_PMD_LED_DEFAULT	(PMA_PMD_LED_OFF << PMA_PMD_LED_RX_LBN)
 
-
-/* Special Software reset register */
-#define PMA_PMD_EXT_CTRL_REG 49152
-#define PMA_PMD_EXT_SSR_LBN 15
-
-/* Misc register defines */
-#define PCS_CLOCK_CTRL_REG 0xd801
+#define PMA_PMD_SPEED_ENABLE_REG 49192
+#define PMA_PMD_100TX_ADV_LBN    1
+#define PMA_PMD_100TX_ADV_WIDTH  1
+#define PMA_PMD_1000T_ADV_LBN    2
+#define PMA_PMD_1000T_ADV_WIDTH  1
+#define PMA_PMD_10000T_ADV_LBN   3
+#define PMA_PMD_10000T_ADV_WIDTH 1
+#define PMA_PMD_SPEED_LBN        4
+#define PMA_PMD_SPEED_WIDTH      4
+
+/* Serdes control registers - SFT9001 only */
+#define PMA_PMD_CSERDES_CTRL_REG 64258
+/* Set the 156.25 MHz output to 312.5 MHz to drive Falcon's XMAC */
+#define PMA_PMD_CSERDES_DEFAULT	0x000f
+
+/* Misc register defines - SFX7101 only */
+#define PCS_CLOCK_CTRL_REG	55297
 #define PLL312_RST_N_LBN 2
 
-#define PCS_SOFT_RST2_REG 0xd806
+#define PCS_SOFT_RST2_REG	55302
 #define SERDES_RST_N_LBN 13
 #define XGXS_RST_N_LBN 12
 
-#define	PCS_TEST_SELECT_REG 0xd807	/* PRM 10.5.8 */
+#define	PCS_TEST_SELECT_REG	55303	/* PRM 10.5.8 */
 #define	CLK312_EN_LBN 3
 
 /* PHYXS registers */
+#define PHYXS_XCONTROL_REG	49152
+#define PHYXS_RESET_LBN		15
+#define PHYXS_RESET_WIDTH	1
+
 #define PHYXS_TEST1         (49162)
 #define LOOPBACK_NEAR_LBN   (8)
 #define LOOPBACK_NEAR_WIDTH (1)
 
+#define PCS_10GBASET_STAT1       32
+#define PCS_10GBASET_BLKLK_LBN   0
+#define PCS_10GBASET_BLKLK_WIDTH 1
+
 /* Boot status register */
-#define PCS_BOOT_STATUS_REG	(0xd000)
+#define PCS_BOOT_STATUS_REG	53248
 #define PCS_BOOT_FATAL_ERR_LBN	(0)
 #define PCS_BOOT_PROGRESS_LBN	(1)
 #define PCS_BOOT_PROGRESS_WIDTH	(2)
 #define PCS_BOOT_COMPLETE_LBN	(3)
+
 #define PCS_BOOT_MAX_DELAY	(100)
 #define PCS_BOOT_POLL_DELAY	(10)
 
+/* 100M/1G PHY registers */
+#define GPHY_XCONTROL_REG	49152
+#define GPHY_ISOLATE_LBN	10
+#define GPHY_ISOLATE_WIDTH	1
+#define GPHY_DUPLEX_LBN	  	8
+#define GPHY_DUPLEX_WIDTH	1
+#define GPHY_LOOPBACK_NEAR_LBN	14
+#define GPHY_LOOPBACK_NEAR_WIDTH 1
+
+#define C22EXT_STATUS_REG       49153
+#define C22EXT_STATUS_LINK_LBN  2
+#define C22EXT_STATUS_LINK_WIDTH 1
+
+#define C22EXT_MSTSLV_REG       49162
+#define C22EXT_MSTSLV_1000_HD_LBN 10
+#define C22EXT_MSTSLV_1000_HD_WIDTH 1
+#define C22EXT_MSTSLV_1000_FD_LBN 11
+#define C22EXT_MSTSLV_1000_FD_WIDTH 1
+
 /* Time to wait between powering down the LNPGA and turning off the power
  * rails */
 #define LNPGA_PDOWN_WAIT	(HZ / 5)
@@ -116,6 +187,38 @@ void tenxpress_crc_err(struct efx_nic *efx)
 		atomic_inc(&phy_data->bad_crc_count);
 }
 
+static ssize_t show_phy_short_reach(struct device *dev,
+				    struct device_attribute *attr, char *buf)
+{
+	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+	int reg;
+
+	reg = mdio_clause45_read(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
+				 MDIO_PMAPMD_10GBT_TXPWR);
+	return sprintf(buf, "%d\n",
+		       !!(reg & (1 << MDIO_PMAPMD_10GBT_TXPWR_SHORT_LBN)));
+}
+
+static ssize_t set_phy_short_reach(struct device *dev,
+				   struct device_attribute *attr,
+				   const char *buf, size_t count)
+{
+	struct efx_nic *efx = pci_get_drvdata(to_pci_dev(dev));
+
+	rtnl_lock();
+	mdio_clause45_set_flag(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
+			       MDIO_PMAPMD_10GBT_TXPWR,
+			       MDIO_PMAPMD_10GBT_TXPWR_SHORT_LBN,
+			       count != 0 && *buf != '0');
+	efx_reconfigure_port(efx);
+	rtnl_unlock();
+
+	return count;
+}
+
+static DEVICE_ATTR(phy_short_reach, 0644, show_phy_short_reach,
+		   set_phy_short_reach);
+
 /* Check that the C166 has booted successfully */
 static int tenxpress_phy_check(struct efx_nic *efx)
 {
@@ -147,27 +250,42 @@ static int tenxpress_phy_check(struct efx_nic *efx)
 
 static int tenxpress_init(struct efx_nic *efx)
 {
-	int rc, reg;
+	int phy_id = efx->mii.phy_id;
+	int reg;
+	int rc;
 
-	/* Turn on the clock  */
-	reg = (1 << CLK312_EN_LBN);
-	mdio_clause45_write(efx, efx->mii.phy_id,
-			    MDIO_MMD_PCS, PCS_TEST_SELECT_REG, reg);
+	if (efx->phy_type == PHY_TYPE_SFX7101) {
+		/* Enable 312.5 MHz clock */
+		mdio_clause45_write(efx, phy_id,
+				    MDIO_MMD_PCS, PCS_TEST_SELECT_REG,
+				    1 << CLK312_EN_LBN);
+	} else {
+		/* Enable 312.5 MHz clock and GMII */
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
+					 PMA_PMD_XCONTROL_REG);
+		reg |= ((1 << PMA_PMD_EXT_GMII_EN_LBN) |
+			(1 << PMA_PMD_EXT_CLK_OUT_LBN) |
+			(1 << PMA_PMD_EXT_CLK312_LBN));
+		mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
+				    PMA_PMD_XCONTROL_REG, reg);
+		mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_C22EXT,
+				       GPHY_XCONTROL_REG, GPHY_ISOLATE_LBN,
+				       false);
+	}
 
 	rc = tenxpress_phy_check(efx);
 	if (rc < 0)
 		return rc;
 
 	/* Set the LEDs up as: Green = Link, Amber = Link/Act, Red = Off */
-	reg = mdio_clause45_read(efx, efx->mii.phy_id,
-				 MDIO_MMD_PMAPMD, PMA_PMD_LED_CTRL_REG);
-	reg |= (1 << PMA_PMA_LED_ACTIVITY_LBN);
-	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
-			    PMA_PMD_LED_CTRL_REG, reg);
-
-	reg = PMA_PMD_LED_DEFAULT;
-	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
-			    PMA_PMD_LED_OVERR_REG, reg);
+	if (efx->phy_type == PHY_TYPE_SFX7101) {
+		mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_PMAPMD,
+				       PMA_PMD_LED_CTRL_REG,
+				       PMA_PMA_LED_ACTIVITY_LBN,
+				       true);
+		mdio_clause45_write(efx, phy_id, MDIO_MMD_PMAPMD,
+				    PMA_PMD_LED_OVERR_REG, PMA_PMD_LED_DEFAULT);
+	}
 
 	return rc;
 }
@@ -183,22 +301,43 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	efx->phy_data = phy_data;
 	phy_data->phy_mode = efx->phy_mode;
 
-	rc = mdio_clause45_wait_reset_mmds(efx,
-					   TENXPRESS_REQUIRED_DEVS);
-	if (rc < 0)
-		goto fail;
+	if (!(efx->phy_mode & PHY_MODE_SPECIAL)) {
+		if (efx->phy_type == PHY_TYPE_SFT9001A) {
+			int reg;
+			reg = mdio_clause45_read(efx, efx->mii.phy_id,
+						 MDIO_MMD_PMAPMD,
+						 PMA_PMD_XCONTROL_REG);
+			reg |= (1 << PMA_PMD_EXT_SSR_LBN);
+			mdio_clause45_write(efx, efx->mii.phy_id,
+					    MDIO_MMD_PMAPMD,
+					    PMA_PMD_XCONTROL_REG, reg);
+			mdelay(200);
+		}
 
-	rc = mdio_clause45_check_mmds(efx, TENXPRESS_REQUIRED_DEVS, 0);
-	if (rc < 0)
-		goto fail;
+		rc = mdio_clause45_wait_reset_mmds(efx,
+						   TENXPRESS_REQUIRED_DEVS);
+		if (rc < 0)
+			goto fail;
+
+		rc = mdio_clause45_check_mmds(efx, TENXPRESS_REQUIRED_DEVS, 0);
+		if (rc < 0)
+			goto fail;
+	}
 
 	rc = tenxpress_init(efx);
 	if (rc < 0)
 		goto fail;
 
+	if (efx->phy_type == PHY_TYPE_SFT9001B) {
+		rc = device_create_file(&efx->pci_dev->dev,
+					&dev_attr_phy_short_reach);
+		if (rc)
+			goto fail;
+	}
+
 	schedule_timeout_uninterruptible(HZ / 5); /* 200ms */
 
-	/* Let XGXS and SerDes out of reset and resets 10XPress */
+	/* Let XGXS and SerDes out of reset */
 	falcon_reset_xaui(efx);
 
 	return 0;
@@ -209,21 +348,24 @@ static int tenxpress_phy_init(struct efx_nic *efx)
 	return rc;
 }
 
+/* Perform a "special software reset" on the PHY. The caller is
+ * responsible for saving and restoring the PHY hardware registers
+ * properly, and masking/unmasking LASI */
 static int tenxpress_special_reset(struct efx_nic *efx)
 {
 	int rc, reg;
 
 	/* The XGMAC clock is driven from the SFC7101/SFT9001 312MHz clock, so
 	 * a special software reset can glitch the XGMAC sufficiently for stats
-	 * requests to fail. Since we don't ofen special_reset, just lock. */
+	 * requests to fail. Since we don't often special_reset, just lock. */
 	spin_lock(&efx->stats_lock);
 
 	/* Initiate reset */
 	reg = mdio_clause45_read(efx, efx->mii.phy_id,
-				 MDIO_MMD_PMAPMD, PMA_PMD_EXT_CTRL_REG);
+				 MDIO_MMD_PMAPMD, PMA_PMD_XCONTROL_REG);
 	reg |= (1 << PMA_PMD_EXT_SSR_LBN);
 	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
-			    PMA_PMD_EXT_CTRL_REG, reg);
+			    PMA_PMD_XCONTROL_REG, reg);
 
 	mdelay(200);
 
@@ -238,12 +380,14 @@ static int tenxpress_special_reset(struct efx_nic *efx)
 	if (rc < 0)
 		goto unlock;
 
+	/* Wait for the XGXS state machine to churn */
+	mdelay(10);
 unlock:
 	spin_unlock(&efx->stats_lock);
 	return rc;
 }
 
-static void tenxpress_check_bad_lp(struct efx_nic *efx, bool link_ok)
+static void sfx7101_check_bad_lp(struct efx_nic *efx, bool link_ok)
 {
 	struct tenxpress_phy_data *pd = efx->phy_data;
 	int phy_id = efx->mii.phy_id;
@@ -288,63 +432,142 @@ static void tenxpress_check_bad_lp(struct efx_nic *efx, bool link_ok)
 	}
 }
 
-static bool tenxpress_link_ok(struct efx_nic *efx)
+static bool sfx7101_link_ok(struct efx_nic *efx)
 {
-	if (efx->loopback_mode == LOOPBACK_NONE)
-		return mdio_clause45_links_ok(efx, MDIO_MMDREG_DEVS_AN);
-	else
+	return mdio_clause45_links_ok(efx,
+				      MDIO_MMDREG_DEVS_PMAPMD |
+				      MDIO_MMDREG_DEVS_PCS |
+				      MDIO_MMDREG_DEVS_PHYXS);
+}
+
+static bool sft9001_link_ok(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+{
+	int phy_id = efx->mii.phy_id;
+	u32 reg;
+
+	if (efx->loopback_mode == LOOPBACK_GPHY)
+		return true;
+	else if (efx_phy_mode_disabled(efx->phy_mode))
+		return false;
+	else if (efx->loopback_mode)
 		return mdio_clause45_links_ok(efx,
 					      MDIO_MMDREG_DEVS_PMAPMD |
 					      MDIO_MMDREG_DEVS_PCS |
 					      MDIO_MMDREG_DEVS_PHYXS);
+
+	/* We must use the same definition of link state as LASI,
+	 * otherwise we can miss a link state transition
+	 */
+	if (ecmd->speed == 10000) {
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PCS,
+					 PCS_10GBASET_STAT1);
+		return reg & (1 << PCS_10GBASET_BLKLK_LBN);
+	} else {
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_C22EXT,
+					 C22EXT_STATUS_REG);
+		return reg & (1 << C22EXT_STATUS_LINK_LBN);
+	}
 }
 
-static void tenxpress_phyxs_loopback(struct efx_nic *efx)
+static void tenxpress_ext_loopback(struct efx_nic *efx)
 {
 	int phy_id = efx->mii.phy_id;
-	int ctrl1, ctrl2;
 
-	ctrl1 = ctrl2 = mdio_clause45_read(efx, phy_id, MDIO_MMD_PHYXS,
-					   PHYXS_TEST1);
-	if (efx->loopback_mode == LOOPBACK_PHYXS)
-		ctrl2 |= (1 << LOOPBACK_NEAR_LBN);
+	mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_PHYXS,
+			       PHYXS_TEST1, LOOPBACK_NEAR_LBN,
+			       efx->loopback_mode == LOOPBACK_PHYXS);
+	if (efx->phy_type != PHY_TYPE_SFX7101)
+		mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_C22EXT,
+				       GPHY_XCONTROL_REG,
+				       GPHY_LOOPBACK_NEAR_LBN,
+				       efx->loopback_mode == LOOPBACK_GPHY);
+}
+
+static void tenxpress_low_power(struct efx_nic *efx)
+{
+	int phy_id = efx->mii.phy_id;
+
+	if (efx->phy_type == PHY_TYPE_SFX7101)
+		mdio_clause45_set_mmds_lpower(
+			efx, !!(efx->phy_mode & PHY_MODE_LOW_POWER),
+			TENXPRESS_REQUIRED_DEVS);
 	else
-		ctrl2 &= ~(1 << LOOPBACK_NEAR_LBN);
-	if (ctrl1 != ctrl2)
-		mdio_clause45_write(efx, phy_id, MDIO_MMD_PHYXS,
-				    PHYXS_TEST1, ctrl2);
+		mdio_clause45_set_flag(
+			efx, phy_id, MDIO_MMD_PMAPMD,
+			PMA_PMD_XCONTROL_REG, PMA_PMD_EXT_LPOWER_LBN,
+			!!(efx->phy_mode & PHY_MODE_LOW_POWER));
 }
 
 static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data = efx->phy_data;
-	bool loop_change = LOOPBACK_OUT_OF(phy_data, efx,
-					   TENXPRESS_LOOPBACKS);
+	struct ethtool_cmd ecmd;
+	bool phy_mode_change, loop_reset, loop_toggle, loopback;
 
-	if (efx->phy_mode & PHY_MODE_SPECIAL) {
+	if (efx->phy_mode & (PHY_MODE_OFF | PHY_MODE_SPECIAL)) {
 		phy_data->phy_mode = efx->phy_mode;
 		return;
 	}
 
-	/* When coming out of transmit disable, coming out of low power
-	 * mode, or moving out of any PHY internal loopback mode,
-	 * perform a special software reset */
-	if ((efx->phy_mode == PHY_MODE_NORMAL &&
-	     phy_data->phy_mode != PHY_MODE_NORMAL) ||
-	    loop_change) {
-		tenxpress_special_reset(efx);
-		falcon_reset_xaui(efx);
+	tenxpress_low_power(efx);
+
+	phy_mode_change = (efx->phy_mode == PHY_MODE_NORMAL &&
+			   phy_data->phy_mode != PHY_MODE_NORMAL);
+	loopback = LOOPBACK_MASK(efx) & efx->phy_op->loopbacks;
+	loop_toggle = LOOPBACK_CHANGED(phy_data, efx, efx->phy_op->loopbacks);
+	loop_reset = (LOOPBACK_OUT_OF(phy_data, efx, efx->phy_op->loopbacks) ||
+		      LOOPBACK_CHANGED(phy_data, efx, 1 << LOOPBACK_GPHY));
+
+	if (loop_reset || loop_toggle || loopback || phy_mode_change) {
+		int rc;
+
+		efx->phy_op->get_settings(efx, &ecmd);
+
+		if (loop_reset || phy_mode_change) {
+			tenxpress_special_reset(efx);
+
+			/* Reset XAUI if we were in 10G, and are staying
+			 * in 10G. If we're moving into and out of 10G
+			 * then xaui will be reset anyway */
+			if (EFX_IS10G(efx))
+				falcon_reset_xaui(efx);
+		}
+
+		if (efx->phy_type != PHY_TYPE_SFX7101) {
+			/* Only change autoneg once, on coming out or
+			 * going into loopback */
+			if (loop_toggle)
+				ecmd.autoneg = !loopback;
+			if (loopback) {
+				ecmd.duplex = DUPLEX_FULL;
+				if (efx->loopback_mode == LOOPBACK_GPHY)
+					ecmd.speed = SPEED_1000;
+				else
+					ecmd.speed = SPEED_10000;
+			}
+		}
+
+		rc = efx->phy_op->set_settings(efx, &ecmd);
+		WARN_ON(rc);
 	}
 
 	mdio_clause45_transmit_disable(efx);
 	mdio_clause45_phy_reconfigure(efx);
-	tenxpress_phyxs_loopback(efx);
+	tenxpress_ext_loopback(efx);
 
 	phy_data->loopback_mode = efx->loopback_mode;
 	phy_data->phy_mode = efx->phy_mode;
-	efx->link_up = tenxpress_link_ok(efx);
-	efx->link_speed = 10000;
-	efx->link_fd = true;
+
+	if (efx->phy_type == PHY_TYPE_SFX7101) {
+		efx->link_speed = 10000;
+		efx->link_fd = true;
+		efx->link_up = sfx7101_link_ok(efx);
+	} else {
+		efx->phy_op->get_settings(efx, &ecmd);
+		efx->link_speed = ecmd.speed;
+		efx->link_fd = ecmd.duplex == DUPLEX_FULL;
+		efx->link_up = sft9001_link_ok(efx, &ecmd);
+	}
 	efx->link_fc = mdio_clause45_get_pause(efx);
 }
 
@@ -355,15 +578,23 @@ static void tenxpress_phy_poll(struct efx_nic *efx)
 	bool change = false, link_ok;
 	unsigned link_fc;
 
-	link_ok = tenxpress_link_ok(efx);
-	if (link_ok != efx->link_up) {
-		change = true;
+	if (efx->phy_type == PHY_TYPE_SFX7101) {
+		link_ok = sfx7101_link_ok(efx);
+		if (link_ok != efx->link_up) {
+			change = true;
+		} else {
+			link_fc = mdio_clause45_get_pause(efx);
+			if (link_fc != efx->link_fc)
+				change = true;
+		}
+		sfx7101_check_bad_lp(efx, link_ok);
 	} else {
-		link_fc = mdio_clause45_get_pause(efx);
-		if (link_fc != efx->link_fc)
+		u32 status = mdio_clause45_read(efx, efx->mii.phy_id,
+						MDIO_MMD_PMAPMD,
+						PMA_PMD_LASI_STATUS);
+		if (status & (1 << PMA_PMD_LS_ALARM_LBN))
 			change = true;
 	}
-	tenxpress_check_bad_lp(efx, link_ok);
 
 	if (change)
 		falcon_sim_phy_event(efx);
@@ -371,7 +602,8 @@ static void tenxpress_phy_poll(struct efx_nic *efx)
 	if (phy_data->phy_mode != PHY_MODE_NORMAL)
 		return;
 
-	if (atomic_read(&phy_data->bad_crc_count) > crc_error_reset_threshold) {
+	if (EFX_WORKAROUND_10750(efx) &&
+	    atomic_read(&phy_data->bad_crc_count) > crc_error_reset_threshold) {
 		EFX_ERR(efx, "Resetting XAUI due to too many CRC errors\n");
 		falcon_reset_xaui(efx);
 		atomic_set(&phy_data->bad_crc_count, 0);
@@ -382,15 +614,20 @@ static void tenxpress_phy_fini(struct efx_nic *efx)
 {
 	int reg;
 
-	/* Power down the LNPGA */
-	reg = (1 << PMA_PMD_LNPGA_POWERDOWN_LBN);
-	mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
-			    PMA_PMD_XCONTROL_REG, reg);
-
-	/* Waiting here ensures that the board fini, which can turn off the
-	 * power to the PHY, won't get run until the LNPGA powerdown has been
-	 * given long enough to complete. */
-	schedule_timeout_uninterruptible(LNPGA_PDOWN_WAIT); /* 200 ms */
+	if (efx->phy_type == PHY_TYPE_SFT9001B) {
+		device_remove_file(&efx->pci_dev->dev,
+				   &dev_attr_phy_short_reach);
+	} else {
+		/* Power down the LNPGA */
+		reg = (1 << PMA_PMD_LNPGA_POWERDOWN_LBN);
+		mdio_clause45_write(efx, efx->mii.phy_id, MDIO_MMD_PMAPMD,
+				    PMA_PMD_XCONTROL_REG, reg);
+
+		/* Waiting here ensures that the board fini, which can turn
+		 * off the power to the PHY, won't get run until the LNPGA
+		 * powerdown has been given long enough to complete. */
+		schedule_timeout_uninterruptible(LNPGA_PDOWN_WAIT); /* 200 ms */
+	}
 
 	kfree(efx->phy_data);
 	efx->phy_data = NULL;
@@ -426,14 +663,21 @@ static u32 tenxpress_get_xnp_lpa(struct efx_nic *efx)
 	u32 lpa = 0;
 	int reg;
 
+	if (efx->phy_type != PHY_TYPE_SFX7101) {
+		reg = mdio_clause45_read(efx, phy, MDIO_MMD_C22EXT,
+					 C22EXT_MSTSLV_REG);
+		if (reg & (1 << C22EXT_MSTSLV_1000_HD_LBN))
+			lpa |= ADVERTISED_1000baseT_Half;
+		if (reg & (1 << C22EXT_MSTSLV_1000_FD_LBN))
+			lpa |= ADVERTISED_1000baseT_Full;
+	}
 	reg = mdio_clause45_read(efx, phy, MDIO_MMD_AN, MDIO_AN_10GBT_STATUS);
 	if (reg & (1 << MDIO_AN_10GBT_STATUS_LP_10G_LBN))
 		lpa |= ADVERTISED_10000baseT_Full;
 	return lpa;
 }
 
-static void
-tenxpress_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+static void sfx7101_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 {
 	mdio_clause45_get_settings_ext(efx, ecmd, ADVERTISED_10000baseT_Full,
 				       tenxpress_get_xnp_lpa(efx));
@@ -441,7 +685,82 @@ tenxpress_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
 	ecmd->advertising |= ADVERTISED_10000baseT_Full;
 }
 
-struct efx_phy_operations falcon_tenxpress_phy_ops = {
+static void sft9001_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+{
+	int phy_id = efx->mii.phy_id;
+	u32 xnp_adv = 0;
+	int reg;
+
+	reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_PMAPMD,
+				 PMA_PMD_SPEED_ENABLE_REG);
+	if (EFX_WORKAROUND_13204(efx) && (reg & (1 << PMA_PMD_100TX_ADV_LBN)))
+		xnp_adv |= ADVERTISED_100baseT_Full;
+	if (reg & (1 << PMA_PMD_1000T_ADV_LBN))
+		xnp_adv |= ADVERTISED_1000baseT_Full;
+	if (reg & (1 << PMA_PMD_10000T_ADV_LBN))
+		xnp_adv |= ADVERTISED_10000baseT_Full;
+
+	mdio_clause45_get_settings_ext(efx, ecmd, xnp_adv,
+				       tenxpress_get_xnp_lpa(efx));
+
+	ecmd->supported |= (SUPPORTED_100baseT_Half |
+			    SUPPORTED_100baseT_Full |
+			    SUPPORTED_1000baseT_Full);
+
+	/* Use the vendor defined C22ext register for duplex settings */
+	if (ecmd->speed != SPEED_10000 && !ecmd->autoneg) {
+		reg = mdio_clause45_read(efx, phy_id, MDIO_MMD_C22EXT,
+					 GPHY_XCONTROL_REG);
+		ecmd->duplex = (reg & (1 << GPHY_DUPLEX_LBN) ?
+				DUPLEX_FULL : DUPLEX_HALF);
+	}
+}
+
+static int sft9001_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+{
+	int phy_id = efx->mii.phy_id;
+	int rc;
+
+	rc = mdio_clause45_set_settings(efx, ecmd);
+	if (rc)
+		return rc;
+
+	if (ecmd->speed != SPEED_10000 && !ecmd->autoneg)
+		mdio_clause45_set_flag(efx, phy_id, MDIO_MMD_C22EXT,
+				       GPHY_XCONTROL_REG, GPHY_DUPLEX_LBN,
+				       ecmd->duplex == DUPLEX_FULL);
+
+	return rc;
+}
+
+static bool sft9001_set_xnp_advertise(struct efx_nic *efx, u32 advertising)
+{
+	int phy = efx->mii.phy_id;
+	int reg = mdio_clause45_read(efx, phy, MDIO_MMD_PMAPMD,
+				     PMA_PMD_SPEED_ENABLE_REG);
+	bool enabled;
+
+	reg &= ~((1 << 2) | (1 << 3));
+	if (EFX_WORKAROUND_13204(efx) &&
+	    (advertising & ADVERTISED_100baseT_Full))
+		reg |= 1 << PMA_PMD_100TX_ADV_LBN;
+	if (advertising & ADVERTISED_1000baseT_Full)
+		reg |= 1 << PMA_PMD_1000T_ADV_LBN;
+	if (advertising & ADVERTISED_10000baseT_Full)
+		reg |= 1 << PMA_PMD_10000T_ADV_LBN;
+	mdio_clause45_write(efx, phy, MDIO_MMD_PMAPMD,
+			    PMA_PMD_SPEED_ENABLE_REG, reg);
+
+	enabled = (advertising &
+		   (ADVERTISED_1000baseT_Half |
+		    ADVERTISED_1000baseT_Full |
+		    ADVERTISED_10000baseT_Full));
+	if (EFX_WORKAROUND_13204(efx))
+		enabled |= (advertising & ADVERTISED_100baseT_Full);
+	return enabled;
+}
+
+struct efx_phy_operations falcon_sfx7101_phy_ops = {
 	.macs		  = EFX_XMAC,
 	.init             = tenxpress_phy_init,
 	.reconfigure      = tenxpress_phy_reconfigure,
@@ -449,8 +768,23 @@ struct efx_phy_operations falcon_tenxpress_phy_ops = {
 	.fini             = tenxpress_phy_fini,
 	.clear_interrupt  = efx_port_dummy_op_void,
 	.test             = tenxpress_phy_test,
-	.get_settings	  = tenxpress_get_settings,
+	.get_settings	  = sfx7101_get_settings,
 	.set_settings	  = mdio_clause45_set_settings,
 	.mmds             = TENXPRESS_REQUIRED_DEVS,
-	.loopbacks        = TENXPRESS_LOOPBACKS,
+	.loopbacks        = SFX7101_LOOPBACKS,
+};
+
+struct efx_phy_operations falcon_sft9001_phy_ops = {
+	.macs		  = EFX_GMAC | EFX_XMAC,
+	.init             = tenxpress_phy_init,
+	.reconfigure      = tenxpress_phy_reconfigure,
+	.poll             = tenxpress_phy_poll,
+	.fini             = tenxpress_phy_fini,
+	.clear_interrupt  = efx_port_dummy_op_void,
+	.test             = tenxpress_phy_test,
+	.get_settings	  = sft9001_get_settings,
+	.set_settings	  = sft9001_set_settings,
+	.set_xnp_advertise = sft9001_set_xnp_advertise,
+	.mmds             = TENXPRESS_REQUIRED_DEVS,
+	.loopbacks        = SFT9001_LOOPBACKS,
 };
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index ec50b90..ecebff2 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -17,6 +17,8 @@
 
 #define EFX_WORKAROUND_ALWAYS(efx) 1
 #define EFX_WORKAROUND_FALCON_A(efx) (falcon_rev(efx) <= FALCON_REV_A1)
+#define EFX_WORKAROUND_SFX7101(efx) ((efx)->phy_type == PHY_TYPE_SFX7101)
+#define EFX_WORKAROUND_SFT9001A(efx) ((efx)->phy_type == PHY_TYPE_SFT9001A)
 
 /* XAUI resets if link not detected */
 #define EFX_WORKAROUND_5147 EFX_WORKAROUND_ALWAYS
@@ -27,7 +29,7 @@
 /* TX pkt parser problem with <= 16 byte TXes */
 #define EFX_WORKAROUND_9141 EFX_WORKAROUND_ALWAYS
 /* Low rate CRC errors require XAUI reset */
-#define EFX_WORKAROUND_10750 EFX_WORKAROUND_ALWAYS
+#define EFX_WORKAROUND_10750 EFX_WORKAROUND_SFX7101
 /* TX_EV_PKT_ERR can be caused by a dangling TX descriptor
  * or a PCIe error (bug 11028) */
 #define EFX_WORKAROUND_10727 EFX_WORKAROUND_ALWAYS
@@ -51,4 +53,9 @@
 /* Leak overlength packets rather than free */
 #define EFX_WORKAROUND_8071 EFX_WORKAROUND_FALCON_A
 
+/* Need to send XNP pages for 100BaseT */
+#define EFX_WORKAROUND_13204 EFX_WORKAROUND_SFT9001A
+/* Need to keep AN enabled */
+#define EFX_WORKAROUND_13963 EFX_WORKAROUND_SFT9001A
+
 #endif /* EFX_WORKAROUNDS_H */
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
