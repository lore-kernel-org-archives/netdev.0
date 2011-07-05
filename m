From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 5/8] bnx2x: Fix false link indication at link
 partner when DAC is used
Date: Tue, 5 Jul 2011 14:06:53 +0300
Message-ID: <1309864013.4050.84.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4107 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755943Ab1GELHE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2011 07:07:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When driver is unloaded, disable PMD in addition to TX laser, provided that the management firmware will be able to enable it back.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_hsi.h  |    1 +
 drivers/net/bnx2x/bnx2x_link.c |   35 +++++++++++++++++++++++++++++++++++
 drivers/net/bnx2x/bnx2x_link.h |    1 +
 drivers/net/bnx2x/bnx2x_main.c |    4 ++++
 drivers/net/bnx2x/bnx2x_reg.h  |    1 +
 5 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index e6f816d..52c190f 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -1236,6 +1236,7 @@ struct drv_func_mb {
 	#define REQ_BC_VER_4_VRFY_FIRST_PHY_OPT_MDL     0x00050006
 	#define DRV_MSG_CODE_VRFY_SPECIFIC_PHY_OPT_MDL  0xa1000000
 	#define REQ_BC_VER_4_VRFY_SPECIFIC_PHY_OPT_MDL  0x00050234
+	#define REQ_BC_VER_4_SFP_TX_DISABLE_SUPPORTED   0x00070014
 
 	#define DRV_MSG_CODE_DCBX_ADMIN_PMF_MSG         0xb0000000
 	#define DRV_MSG_CODE_DCBX_PMF_DRV_OK            0xb2000000
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index a04fa13..144cfae 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -7195,6 +7195,30 @@ static u8 bnx2x_8705_read_status(struct bnx2x_phy *phy,
 /******************************************************************/
 /*			SFP+ module Section			  */
 /******************************************************************/
+static void bnx2x_set_disable_pmd_transmit(struct link_params *params,
+					   struct bnx2x_phy *phy,
+					   u8 pmd_dis)
+{
+	struct bnx2x *bp = params->bp;
+	/*
+	 * Disable transmitter only for bootcodes which can enable it afterwards
+	 * (for D3 link)
+	 */
+	if (pmd_dis) {
+		if (params->feature_config_flags &
+		     FEATURE_CONFIG_BC_SUPPORTS_SFP_TX_DISABLED)
+			DP(NETIF_MSG_LINK, "Disabling PMD transmitter\n");
+		else {
+			DP(NETIF_MSG_LINK, "NOT disabling PMD transmitter\n");
+			return;
+		}
+	} else
+		DP(NETIF_MSG_LINK, "Enabling PMD transmitter\n");
+	bnx2x_cl45_write(bp, phy,
+			 MDIO_PMA_DEVAD,
+			 MDIO_PMA_REG_TX_DISABLE, pmd_dis);
+}
+
 static u8 bnx2x_get_gpio_port(struct link_params *params)
 {
 	u8 gpio_port;
@@ -8598,6 +8622,9 @@ static int bnx2x_8727_config_init(struct bnx2x_phy *phy,
 			 MDIO_PMA_DEVAD, MDIO_PMA_REG_PHY_IDENTIFIER, mod_abs);
 

+	/* Enable/Disable PHY transmitter output */
+	bnx2x_set_disable_pmd_transmit(params, phy, 0);
+
 	/* Make MOD_ABS give interrupt on change */
 	bnx2x_cl45_read(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_8727_PCS_OPT_CTRL,
 			&val);
@@ -8972,6 +8999,10 @@ static void bnx2x_8727_link_reset(struct bnx2x_phy *phy,
 				  struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
+
+	/* Enable/Disable PHY transmitter output */
+	bnx2x_set_disable_pmd_transmit(params, phy, 1);
+
 	/* Disable Transmitter */
 	bnx2x_sfp_set_transmitter(params, phy, 0);
 	/* Clear LASI */
@@ -11895,6 +11926,10 @@ static int bnx2x_8727_common_init_phy(struct bnx2x *bp,
 		if (bnx2x_8073_8727_external_rom_boot(bp, phy_blk[port],
 						      port_of_path))
 			return -EINVAL;
+		/* Disable PHY transmitter output */
+		bnx2x_cl45_write(bp, phy_blk[port],
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_TX_DISABLE, 1);
 
 	}
 	return 0;
diff --git a/drivers/net/bnx2x/bnx2x_link.h b/drivers/net/bnx2x/bnx2x_link.h
index 6f299c2..ba4d1f7 100644
--- a/drivers/net/bnx2x/bnx2x_link.h
+++ b/drivers/net/bnx2x/bnx2x_link.h
@@ -250,6 +250,7 @@ struct link_params {
 #define FEATURE_CONFIG_PFC_ENABLED			(1<<1)
 #define FEATURE_CONFIG_BC_SUPPORTS_OPT_MDL_VRFY		(1<<2)
 #define FEATURE_CONFIG_BC_SUPPORTS_DUAL_PHY_OPT_MDL_VRFY	(1<<3)
+#define FEATURE_CONFIG_BC_SUPPORTS_SFP_TX_DISABLED		(1<<10)
 	/* Will be populated during common init */
 	struct bnx2x_phy phy[MAX_PHYS];
 
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index b6f82eb..9860435 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -8349,6 +8349,10 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 		(val >= REQ_BC_VER_4_VRFY_SPECIFIC_PHY_OPT_MDL) ?
 		FEATURE_CONFIG_BC_SUPPORTS_DUAL_PHY_OPT_MDL_VRFY : 0;
 
+	bp->link_params.feature_config_flags |=
+		(val >= REQ_BC_VER_4_SFP_TX_DISABLE_SUPPORTED) ?
+		FEATURE_CONFIG_BC_SUPPORTS_SFP_TX_DISABLED : 0;
+
 	pci_read_config_word(bp->pdev, bp->pm_cap + PCI_PM_PMC, &pmc);
 	bp->flags |= (pmc & PCI_PM_CAP_PME_D3cold) ? 0 : NO_WOL_FLAG;
 
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index c97ce37..3c7702e 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -6618,6 +6618,7 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_PMA_REG_CTRL		0x0
 #define MDIO_PMA_REG_STATUS		0x1
 #define MDIO_PMA_REG_10G_CTRL2		0x7
+#define MDIO_PMA_REG_TX_DISABLE		0x0009
 #define MDIO_PMA_REG_RX_SD		0xa
 /*bcm*/
 #define MDIO_PMA_REG_BCM_CTRL		0x0096
-- 
1.7.1







