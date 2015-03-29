From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 1/3] bnx2x: Configure IFir et al. according to nvram
Date: Sun, 29 Mar 2015 10:04:59 +0300
Message-ID: <1427612701-13469-2-git-send-email-Yuval.Mintz@qlogic.com>
References: <1427612701-13469-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yaniv Rosner <Yaniv.Rosner@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:37991 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751057AbbC2HF6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Mar 2015 03:05:58 -0400
In-Reply-To: <1427612701-13469-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <Yaniv.Rosner@qlogic.com>

Enable controlling Post2, coeff, IPreDriver and IFir according to NVRAM setup.

Signed-off-by: Yaniv Rosner <Yaniv.Rosner@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h  | 11 +++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c | 57 +++++++++++++++++-------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |  2 +
 3 files changed, 55 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index 583591d..06df560 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -521,6 +521,17 @@ struct port_hw_cfg {		    /* port 0: 0x12c  port 1: 0x2bc */
 	 */
 	#define PORT_HW_CFG_TX_DRV_BROADCAST_MASK                     0x000F0000
 	#define PORT_HW_CFG_TX_DRV_BROADCAST_SHIFT                    16
+	/*  Set non-default values for TXFIR in SFP mode. */
+	#define PORT_HW_CFG_TX_DRV_IFIR_MASK                          0x00F00000
+	#define PORT_HW_CFG_TX_DRV_IFIR_SHIFT                         20
+
+	/*  Set non-default values for IPREDRIVER in SFP mode. */
+	#define PORT_HW_CFG_TX_DRV_IPREDRIVER_MASK                    0x0F000000
+	#define PORT_HW_CFG_TX_DRV_IPREDRIVER_SHIFT                   24
+
+	/*  Set non-default values for POST2 in SFP mode. */
+	#define PORT_HW_CFG_TX_DRV_POST2_MASK                         0xF0000000
+	#define PORT_HW_CFG_TX_DRV_POST2_SHIFT                        28
 
 	u32 reserved0[5];				    /* 0x17c */
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index b7c77b2..a5b1743 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -195,6 +195,10 @@ typedef int (*read_sfp_module_eeprom_func_p)(struct bnx2x_phy *phy,
 
 #define MAX_PACKET_SIZE					(9700)
 #define MAX_KR_LINK_RETRY				4
+#define DEFAULT_TX_DRV_BRDCT		2
+#define DEFAULT_TX_DRV_IFIR		0
+#define DEFAULT_TX_DRV_POST2		3
+#define DEFAULT_TX_DRV_IPRE_DRIVER	6
 
 /**********************************************************/
 /*                     INTERFACE                          */
@@ -3595,10 +3599,11 @@ static u8 bnx2x_ext_phy_resolve_fc(struct bnx2x_phy *phy,
  * init configuration, and set/clear SGMII flag. Internal
  * phy init is done purely in phy_init stage.
  */
-#define WC_TX_DRIVER(post2, idriver, ipre) \
+#define WC_TX_DRIVER(post2, idriver, ipre, ifir) \
 	((post2 << MDIO_WC_REG_TX0_TX_DRIVER_POST2_COEFF_OFFSET) | \
 	 (idriver << MDIO_WC_REG_TX0_TX_DRIVER_IDRIVER_OFFSET) | \
-	 (ipre << MDIO_WC_REG_TX0_TX_DRIVER_IPRE_DRIVER_OFFSET))
+	 (ipre << MDIO_WC_REG_TX0_TX_DRIVER_IPRE_DRIVER_OFFSET) | \
+	 (ifir << MDIO_WC_REG_TX0_TX_DRIVER_IFIR_OFFSET))
 
 #define WC_TX_FIR(post, main, pre) \
 	((post << MDIO_WC_REG_TX_FIR_TAP_POST_TAP_OFFSET) | \
@@ -3765,12 +3770,12 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 	lane = bnx2x_get_warpcore_lane(phy, params);
 	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
 			 MDIO_WC_REG_TX0_TX_DRIVER + 0x10*lane,
-			 WC_TX_DRIVER(0x02, 0x06, 0x09));
+			 WC_TX_DRIVER(0x02, 0x06, 0x09, 0));
 	/* Configure the next lane if dual mode */
 	if (phy->flags & FLAGS_WC_DUAL_MODE)
 		bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
 				 MDIO_WC_REG_TX0_TX_DRIVER + 0x10*(lane+1),
-				 WC_TX_DRIVER(0x02, 0x06, 0x09));
+				 WC_TX_DRIVER(0x02, 0x06, 0x09, 0));
 	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
 			 MDIO_WC_REG_CL72_USERB0_CL72_OS_DEF_CTRL,
 			 0x03f0);
@@ -3933,6 +3938,7 @@ static void bnx2x_warpcore_set_10G_XFI(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u16 misc1_val, tap_val, tx_driver_val, lane, val;
 	u32 cfg_tap_val, tx_drv_brdct, tx_equal;
+	u32 ifir_val, ipost2_val, ipre_driver_val;
 
 	/* Hold rxSeqStart */
 	bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
@@ -3978,7 +3984,7 @@ static void bnx2x_warpcore_set_10G_XFI(struct bnx2x_phy *phy,
 	if (is_xfi) {
 		misc1_val |= 0x5;
 		tap_val = WC_TX_FIR(0x08, 0x37, 0x00);
-		tx_driver_val = WC_TX_DRIVER(0x00, 0x02, 0x03);
+		tx_driver_val = WC_TX_DRIVER(0x00, 0x02, 0x03, 0);
 	} else {
 		cfg_tap_val = REG_RD(bp, params->shmem_base +
 				     offsetof(struct shmem_region, dev_info.
@@ -3987,10 +3993,6 @@ static void bnx2x_warpcore_set_10G_XFI(struct bnx2x_phy *phy,
 
 		tx_equal = cfg_tap_val & PORT_HW_CFG_TX_EQUALIZATION_MASK;
 
-		tx_drv_brdct = (cfg_tap_val &
-				PORT_HW_CFG_TX_DRV_BROADCAST_MASK) >>
-			       PORT_HW_CFG_TX_DRV_BROADCAST_SHIFT;
-
 		misc1_val |= 0x9;
 
 		/* TAP values are controlled by nvram, if value there isn't 0 */
@@ -3999,11 +4001,36 @@ static void bnx2x_warpcore_set_10G_XFI(struct bnx2x_phy *phy,
 		else
 			tap_val = WC_TX_FIR(0x0f, 0x2b, 0x02);
 
-		if (tx_drv_brdct)
-			tx_driver_val = WC_TX_DRIVER(0x03, (u16)tx_drv_brdct,
-						     0x06);
-		else
-			tx_driver_val = WC_TX_DRIVER(0x03, 0x02, 0x06);
+		ifir_val = DEFAULT_TX_DRV_IFIR;
+		ipost2_val = DEFAULT_TX_DRV_POST2;
+		ipre_driver_val = DEFAULT_TX_DRV_IPRE_DRIVER;
+		tx_drv_brdct = DEFAULT_TX_DRV_BRDCT;
+
+		/* If any of the IFIR/IPRE_DRIVER/POST@ is set, apply all
+		 * configuration.
+		 */
+		if (cfg_tap_val & (PORT_HW_CFG_TX_DRV_IFIR_MASK |
+				   PORT_HW_CFG_TX_DRV_IPREDRIVER_MASK |
+				   PORT_HW_CFG_TX_DRV_POST2_MASK)) {
+			ifir_val = (cfg_tap_val &
+				    PORT_HW_CFG_TX_DRV_IFIR_MASK) >>
+				PORT_HW_CFG_TX_DRV_IFIR_SHIFT;
+			ipre_driver_val = (cfg_tap_val &
+					   PORT_HW_CFG_TX_DRV_IPREDRIVER_MASK)
+			>> PORT_HW_CFG_TX_DRV_IPREDRIVER_SHIFT;
+			ipost2_val = (cfg_tap_val &
+				      PORT_HW_CFG_TX_DRV_POST2_MASK) >>
+				PORT_HW_CFG_TX_DRV_POST2_SHIFT;
+		}
+
+		if (cfg_tap_val & PORT_HW_CFG_TX_DRV_BROADCAST_MASK) {
+			tx_drv_brdct = (cfg_tap_val &
+					PORT_HW_CFG_TX_DRV_BROADCAST_MASK) >>
+				PORT_HW_CFG_TX_DRV_BROADCAST_SHIFT;
+		}
+
+		tx_driver_val = WC_TX_DRIVER(ipost2_val, tx_drv_brdct,
+					     ipre_driver_val, ifir_val);
 	}
 	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
 			 MDIO_WC_REG_SERDESDIGITAL_MISC1, misc1_val);
@@ -4144,7 +4171,7 @@ static void bnx2x_warpcore_set_20G_DXGXS(struct bnx2x *bp,
 			  MDIO_WC_REG_TX_FIR_TAP_ENABLE));
 	bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
 			 MDIO_WC_REG_TX0_TX_DRIVER + 0x10*lane,
-			 WC_TX_DRIVER(0x02, 0x02, 0x02));
+			 WC_TX_DRIVER(0x02, 0x02, 0x02, 0));
 }
 
 static void bnx2x_warpcore_set_sgmii_speed(struct bnx2x_phy *phy,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 0770e4b..49d5110 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -7341,6 +7341,8 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_WC_REG_TX2_ANA_CTRL0			0x8081
 #define MDIO_WC_REG_TX3_ANA_CTRL0			0x8091
 #define MDIO_WC_REG_TX0_TX_DRIVER			0x8067
+#define MDIO_WC_REG_TX0_TX_DRIVER_IFIR_OFFSET			0x01
+#define MDIO_WC_REG_TX0_TX_DRIVER_IFIR_MASK				0x000e
 #define MDIO_WC_REG_TX0_TX_DRIVER_IPRE_DRIVER_OFFSET		0x04
 #define MDIO_WC_REG_TX0_TX_DRIVER_IPRE_DRIVER_MASK			0x00f0
 #define MDIO_WC_REG_TX0_TX_DRIVER_IDRIVER_OFFSET		0x08
-- 
1.9.3
