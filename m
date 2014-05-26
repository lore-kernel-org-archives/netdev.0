From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: [PATCH 2/6] pch_gbe: Add module parameter for RGMII/GMII PHY mode selection
Date: Mon, 26 May 2014 15:40:35 +0200
Message-ID: <1401111639-11507-2-git-send-email-alexander.stein@systec-electronic.com>
References: <1401111639-11507-1-git-send-email-alexander.stein@systec-electronic.com>
Cc: Alexander Stein <alexander.stein@systec-electronic.com>,
	netdev@vger.kernel.org,
	Daniel Krueger <daniel.krueger@systec-electronic.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webbox1416.server-home.net ([77.236.96.61]:58894 "EHLO
	webbox1416.server-home.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752564AbaEZNm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 May 2014 09:42:28 -0400
In-Reply-To: <1401111639-11507-1-git-send-email-alexander.stein@systec-electronic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mode register has to be set even in GMII mode. Otherwise the 125 MHz
RXCLK is not detected after MAC reset.

Signed-off-by: Daniel Krueger <daniel.krueger@systec-electronic.com>
Signed-off-by: Alexander Stein <alexander.stein@systec-electronic.com>
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |  1 +
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c    |  6 +--
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 47 ++++++++++++----------
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h    |  1 -
 4 files changed, 30 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
index 2a55d6d..956dc68 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
@@ -390,6 +390,7 @@ struct pch_gbe_phy_info {
 	u32 revision;
 	u32 reset_delay_us;
 	u16 autoneg_advertised;
+	bool is_rgmii;
 };
 
 /*!
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c
index 5125036..c97e738 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_api.c
@@ -77,9 +77,9 @@ static s32 pch_gbe_plat_init_hw(struct pch_gbe_hw *hw)
 	}
 	pch_gbe_phy_init_setting(hw);
 	/* Setup Mac interface option RGMII */
-#ifdef PCH_GBE_MAC_IFOP_RGMII
-	pch_gbe_phy_set_rgmii(hw);
-#endif
+	if (hw->phy.is_rgmii)
+		pch_gbe_phy_set_rgmii(hw);
+
 	return ret_val;
 }
 
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 42fa431..693ee50 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -114,6 +114,7 @@ const char pch_driver_version[] = DRV_VERSION;
 #define MINNOW_PHY_RESET_GPIO		13
 
 static unsigned int copybreak __read_mostly = PCH_GBE_COPYBREAK_DEFAULT;
+static bool is_rgmii __read_mostly = 1;
 
 static int pch_gbe_mdio_read(struct net_device *netdev, int addr, int reg);
 static void pch_gbe_mdio_write(struct net_device *netdev, int addr, int reg,
@@ -369,9 +370,7 @@ static void pch_gbe_mac_reset_hw(struct pch_gbe_hw *hw)
 	/* Read the MAC address. and store to the private data */
 	pch_gbe_mac_read_mac_addr(hw);
 	iowrite32(PCH_GBE_ALL_RST, &hw->reg->RESET);
-#ifdef PCH_GBE_MAC_IFOP_RGMII
 	iowrite32(PCH_GBE_MODE_GMII_ETHER, &hw->reg->MODE);
-#endif
 	pch_gbe_wait_clr_bit(&hw->reg->RESET, PCH_GBE_ALL_RST);
 	/* Setup the receive addresses */
 	pch_gbe_mac_mar_set(hw, hw->mac.addr, 0);
@@ -1039,26 +1038,26 @@ static void pch_gbe_set_rgmii_ctrl(struct pch_gbe_adapter *adapter, u16 speed,
 	unsigned long rgmii = 0;
 
 	/* Set the RGMII control. */
-#ifdef PCH_GBE_MAC_IFOP_RGMII
-	switch (speed) {
-	case SPEED_10:
-		rgmii = (PCH_GBE_RGMII_RATE_2_5M |
-			 PCH_GBE_MAC_RGMII_CTRL_SETTING);
-		break;
-	case SPEED_100:
-		rgmii = (PCH_GBE_RGMII_RATE_25M |
-			 PCH_GBE_MAC_RGMII_CTRL_SETTING);
-		break;
-	case SPEED_1000:
-		rgmii = (PCH_GBE_RGMII_RATE_125M |
-			 PCH_GBE_MAC_RGMII_CTRL_SETTING);
-		break;
-	}
-	iowrite32(rgmii, &hw->reg->RGMII_CTRL);
-#else	/* GMII */
-	rgmii = 0;
+	if (hw->phy.is_rgmii) {
+		switch (speed) {
+		case SPEED_10:
+			rgmii = (PCH_GBE_RGMII_RATE_2_5M |
+				PCH_GBE_MAC_RGMII_CTRL_SETTING);
+			break;
+		case SPEED_100:
+			rgmii = (PCH_GBE_RGMII_RATE_25M |
+				PCH_GBE_MAC_RGMII_CTRL_SETTING);
+			break;
+		case SPEED_1000:
+			rgmii = (PCH_GBE_RGMII_RATE_125M |
+				PCH_GBE_MAC_RGMII_CTRL_SETTING);
+			break;
+		}
+	} else
+		/* GMII */
+		rgmii = 0;
+
 	iowrite32(rgmii, &hw->reg->RGMII_CTRL);
-#endif
 }
 static void pch_gbe_set_mode(struct pch_gbe_adapter *adapter, u16 speed,
 			      u16 duplex)
@@ -2629,6 +2628,8 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 	if (adapter->pdata && adapter->pdata->platform_init)
 		adapter->pdata->platform_init(pdev);
 
+	adapter->hw.phy.is_rgmii = is_rgmii;
+
 	adapter->ptp_pdev = pci_get_bus_and_slot(adapter->pdev->bus->number,
 					       PCI_DEVFN(12, 4));
 
@@ -2843,4 +2844,8 @@ module_param(copybreak, uint, 0644);
 MODULE_PARM_DESC(copybreak,
 	"Maximum size of packet that is copied to a new buffer on receive");
 
+module_param(is_rgmii, bool, 0644);
+MODULE_PARM_DESC(is_rgmii,
+		 "Selection of RGMII/GMII PHY mode. true: RGMII (default). false: GMII");
+
 /* pch_gbe_main.c */
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h
index 95ad015..1c1e711 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_phy.h
@@ -21,7 +21,6 @@
 
 #define PCH_GBE_PHY_REGS_LEN		32
 #define	PCH_GBE_PHY_RESET_DELAY_US	10
-#define PCH_GBE_MAC_IFOP_RGMII
 
 s32 pch_gbe_phy_get_id(struct pch_gbe_hw *hw);
 s32 pch_gbe_phy_read_reg_miic(struct pch_gbe_hw *hw, u32 offset, u16 *data);
-- 
1.8.5.5
