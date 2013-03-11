From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 10/13] bnx2x: Control SFP+ tap values via nvm
 config
Date: Mon, 11 Mar 2013 17:17:50 +0200
Message-ID: <1363015073-25743-11-git-send-email-yuvalmin@broadcom.com>
References: <1363015073-25743-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3895 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754011Ab3CKQZx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Mar 2013 12:25:53 -0400
In-Reply-To: <1363015073-25743-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

Configure SFP+ tap values to optimize link signal according to NVRAM setup.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  |   17 +++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   77 ++++++++++++---------
 2 files changed, 60 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 037860e..a7a3504 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -508,7 +508,22 @@ struct port_hw_cfg {		    /* port 0: 0x12c  port 1: 0x2bc */
 	#define PORT_HW_CFG_PAUSE_ON_HOST_RING_DISABLED               0x00000000
 	#define PORT_HW_CFG_PAUSE_ON_HOST_RING_ENABLED                0x00000001
 
-	u32 reserved0[6];				    /* 0x178 */
+	/* SFP+ Tx Equalization: NIC recommended and tested value is 0xBEB2
+	 * LOM recommended and tested value is 0xBEB2. Using a different
+	 * value means using a value not tested by BRCM
+	 */
+	u32 sfi_tap_values;                                 /* 0x178 */
+	#define PORT_HW_CFG_TX_EQUALIZATION_MASK                      0x0000FFFF
+	#define PORT_HW_CFG_TX_EQUALIZATION_SHIFT                     0
+
+	/* SFP+ Tx driver broadcast IDRIVER: NIC recommended and tested
+	 * value is 0x2. LOM recommended and tested value is 0x2. Using a
+	 * different value means using a value not tested by BRCM
+	 */
+	#define PORT_HW_CFG_TX_DRV_BROADCAST_MASK                     0x000F0000
+	#define PORT_HW_CFG_TX_DRV_BROADCAST_SHIFT                    16
+
+	u32 reserved0[5];				    /* 0x17c */
 
 	u32 aeu_int_mask;				    /* 0x190 */
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index fa027d8..2d5bac8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -3630,6 +3630,16 @@ static u8 bnx2x_ext_phy_resolve_fc(struct bnx2x_phy *phy,
  * init configuration, and set/clear SGMII flag. Internal
  * phy init is done purely in phy_init stage.
  */
+#define WC_TX_DRIVER(post2, idriver, ipre) \
+	((post2 << MDIO_WC_REG_TX0_TX_DRIVER_POST2_COEFF_OFFSET) | \
+	 (idriver << MDIO_WC_REG_TX0_TX_DRIVER_IDRIVER_OFFSET) | \
+	 (ipre << MDIO_WC_REG_TX0_TX_DRIVER_IPRE_DRIVER_OFFSET))
+
+#define WC_TX_FIR(post, main, pre) \
+	((post << MDIO_WC_REG_TX_FIR_TAP_POST_TAP_OFFSET) | \
+	 (main << MDIO_WC_REG_TX_FIR_TAP_MAIN_TAP_OFFSET) | \
+	 (pre << MDIO_WC_REG_TX_FIR_TAP_PRE_TAP_OFFSET))
+
 static void bnx2x_warpcore_enable_AN_KR2(struct bnx2x_phy *phy,
 					 struct link_params *params,
 					 struct link_vars *vars)
@@ -3754,20 +3764,13 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 	/* Set Transmit PMD settings */
 	lane = bnx2x_get_warpcore_lane(phy, params);
 	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-		      MDIO_WC_REG_TX0_TX_DRIVER + 0x10*lane,
-		     ((0x02 << MDIO_WC_REG_TX0_TX_DRIVER_POST2_COEFF_OFFSET) |
-		      (0x06 << MDIO_WC_REG_TX0_TX_DRIVER_IDRIVER_OFFSET) |
-		      (0x09 << MDIO_WC_REG_TX0_TX_DRIVER_IPRE_DRIVER_OFFSET)));
+			 MDIO_WC_REG_TX0_TX_DRIVER + 0x10*lane,
+			 WC_TX_DRIVER(0x02, 0x06, 0x09));
 	/* Configure the next lane if dual mode */
 	if (phy->flags & FLAGS_WC_DUAL_MODE)
 		bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
 				 MDIO_WC_REG_TX0_TX_DRIVER + 0x10*(lane+1),
-				 ((0x02 <<
-				 MDIO_WC_REG_TX0_TX_DRIVER_POST2_COEFF_OFFSET) |
-				  (0x06 <<
-				   MDIO_WC_REG_TX0_TX_DRIVER_IDRIVER_OFFSET) |
-				  (0x09 <<
-				MDIO_WC_REG_TX0_TX_DRIVER_IPRE_DRIVER_OFFSET)));
+				 WC_TX_DRIVER(0x02, 0x06, 0x09));
 	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
 			 MDIO_WC_REG_CL72_USERB0_CL72_OS_DEF_CTRL,
 			 0x03f0);
@@ -3910,6 +3913,8 @@ static void bnx2x_warpcore_set_10G_XFI(struct bnx2x_phy *phy,
 {
 	struct bnx2x *bp = params->bp;
 	u16 misc1_val, tap_val, tx_driver_val, lane, val;
+	u32 cfg_tap_val, tx_drv_brdct, tx_equal;
+
 	/* Hold rxSeqStart */
 	bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
 				 MDIO_WC_REG_DSC2B0_DSC_MISC_CTRL0, 0x8000);
@@ -3953,23 +3958,33 @@ static void bnx2x_warpcore_set_10G_XFI(struct bnx2x_phy *phy,
 
 	if (is_xfi) {
 		misc1_val |= 0x5;
-		tap_val = ((0x08 << MDIO_WC_REG_TX_FIR_TAP_POST_TAP_OFFSET) |
-			   (0x37 << MDIO_WC_REG_TX_FIR_TAP_MAIN_TAP_OFFSET) |
-			   (0x00 << MDIO_WC_REG_TX_FIR_TAP_PRE_TAP_OFFSET));
-		tx_driver_val =
-		      ((0x00 << MDIO_WC_REG_TX0_TX_DRIVER_POST2_COEFF_OFFSET) |
-		       (0x02 << MDIO_WC_REG_TX0_TX_DRIVER_IDRIVER_OFFSET) |
-		       (0x03 << MDIO_WC_REG_TX0_TX_DRIVER_IPRE_DRIVER_OFFSET));
-
+		tap_val = WC_TX_FIR(0x08, 0x37, 0x00);
+		tx_driver_val = WC_TX_DRIVER(0x00, 0x02, 0x03);
 	} else {
+		cfg_tap_val = REG_RD(bp, params->shmem_base +
+				     offsetof(struct shmem_region, dev_info.
+					      port_hw_config[params->port].
+					      sfi_tap_values));
+
+		tx_equal = cfg_tap_val & PORT_HW_CFG_TX_EQUALIZATION_MASK;
+
+		tx_drv_brdct = (cfg_tap_val &
+				PORT_HW_CFG_TX_DRV_BROADCAST_MASK) >>
+			       PORT_HW_CFG_TX_DRV_BROADCAST_SHIFT;
+
 		misc1_val |= 0x9;
-		tap_val = ((0x0f << MDIO_WC_REG_TX_FIR_TAP_POST_TAP_OFFSET) |
-			   (0x2b << MDIO_WC_REG_TX_FIR_TAP_MAIN_TAP_OFFSET) |
-			   (0x02 << MDIO_WC_REG_TX_FIR_TAP_PRE_TAP_OFFSET));
-		tx_driver_val =
-		      ((0x03 << MDIO_WC_REG_TX0_TX_DRIVER_POST2_COEFF_OFFSET) |
-		       (0x02 << MDIO_WC_REG_TX0_TX_DRIVER_IDRIVER_OFFSET) |
-		       (0x06 << MDIO_WC_REG_TX0_TX_DRIVER_IPRE_DRIVER_OFFSET));
+
+		/* TAP values are controlled by nvram, if value there isn't 0 */
+		if (tx_equal)
+			tap_val = (u16)tx_equal;
+		else
+			tap_val = WC_TX_FIR(0x0f, 0x2b, 0x02);
+
+		if (tx_drv_brdct)
+			tx_driver_val = WC_TX_DRIVER(0x03, (u16)tx_drv_brdct,
+						     0x06);
+		else
+			tx_driver_val = WC_TX_DRIVER(0x03, 0x02, 0x06);
 	}
 	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
 			 MDIO_WC_REG_SERDESDIGITAL_MISC1, misc1_val);
@@ -4106,15 +4121,11 @@ static void bnx2x_warpcore_set_20G_DXGXS(struct bnx2x *bp,
 	/* Set Transmit PMD settings */
 	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
 			 MDIO_WC_REG_TX_FIR_TAP,
-			((0x12 << MDIO_WC_REG_TX_FIR_TAP_POST_TAP_OFFSET) |
-			 (0x2d << MDIO_WC_REG_TX_FIR_TAP_MAIN_TAP_OFFSET) |
-			 (0x00 << MDIO_WC_REG_TX_FIR_TAP_PRE_TAP_OFFSET) |
-			 MDIO_WC_REG_TX_FIR_TAP_ENABLE));
+			 (WC_TX_FIR(0x12, 0x2d, 0x00) |
+			  MDIO_WC_REG_TX_FIR_TAP_ENABLE));
 	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
-		      MDIO_WC_REG_TX0_TX_DRIVER + 0x10*lane,
-		     ((0x02 << MDIO_WC_REG_TX0_TX_DRIVER_POST2_COEFF_OFFSET) |
-		      (0x02 << MDIO_WC_REG_TX0_TX_DRIVER_IDRIVER_OFFSET) |
-		      (0x02 << MDIO_WC_REG_TX0_TX_DRIVER_IPRE_DRIVER_OFFSET)));
+			 MDIO_WC_REG_TX0_TX_DRIVER + 0x10*lane,
+			 WC_TX_DRIVER(0x02, 0x02, 0x02));
 }
 
 static void bnx2x_warpcore_set_sgmii_speed(struct bnx2x_phy *phy,
-- 
1.7.7.2
