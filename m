From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-2.6 1/8] bnx2x: Swap BCM8073 PHY polarity if
 required
Date: Tue, 18 Jan 2011 16:33:18 +0200
Message-ID: <1295361198.5281.84.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2770 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069Ab1AROcn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Jan 2011 09:32:43 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable controlling BCM8073 PN polarity swap through nvm configuration, which is required in certain systems

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_hsi.h  |    4 +++
 drivers/net/bnx2x/bnx2x_link.c |   42 ++++++++++++++++++++++++++++++++++++++++
 2 files changed, 46 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index 6238d4f..548f563 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -352,6 +352,10 @@ struct port_hw_cfg {			    /* port 0: 0x12c  port 1: 0x2bc */
 #define PORT_HW_CFG_LANE_SWAP_CFG_31203120	    0x0000d8d8
 	/* forced only */
 #define PORT_HW_CFG_LANE_SWAP_CFG_32103210	    0x0000e4e4
+    /*	Indicate whether to swap the external phy polarity */
+#define PORT_HW_CFG_SWAP_PHY_POLARITY_MASK	       0x00010000
+#define PORT_HW_CFG_SWAP_PHY_POLARITY_DISABLED	    0x00000000
+#define PORT_HW_CFG_SWAP_PHY_POLARITY_ENABLED	    0x00010000
 
 	u32 external_phy_config;
 #define PORT_HW_CFG_SERDES_EXT_PHY_TYPE_MASK	    0xff000000
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 43b0de2..77f9eb1 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -4108,6 +4108,25 @@ static u8 bnx2x_8073_config_init(struct bnx2x_phy *phy,
 
 	DP(NETIF_MSG_LINK, "Before rom RX_ALARM(port1): 0x%x\n", tmp1);
 
+	/**
+	 * If this is forced speed, set to KR or KX (all other are not
+	 * supported)
+	 */
+	/* Swap polarity if required - Must be done only in non-1G mode */
+	if (params->lane_config & PORT_HW_CFG_SWAP_PHY_POLARITY_ENABLED) {
+		/* Configure the 8073 to swap _P and _N of the KR lines */
+		DP(NETIF_MSG_LINK, "Swapping polarity for the 8073\n");
+		/* 10G Rx/Tx and 1G Tx signal polarity swap */
+		bnx2x_cl45_read(bp, phy,
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_8073_OPT_DIGITAL_CTRL, &val);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_8073_OPT_DIGITAL_CTRL,
+				 (val | (3<<9)));
+	}
+
+
 	/* Enable CL37 BAM */
 	if (REG_RD(bp, params->shmem_base +
 			 offsetof(struct shmem_region, dev_info.
@@ -4314,6 +4333,29 @@ static u8 bnx2x_8073_read_status(struct bnx2x_phy *phy,
 	}
 
 	if (link_up) {
+		/* Swap polarity if required */
+		if (params->lane_config &
+		    PORT_HW_CFG_SWAP_PHY_POLARITY_ENABLED) {
+			/* Configure the 8073 to swap P and N of the KR lines */
+			bnx2x_cl45_read(bp, phy,
+					MDIO_XS_DEVAD,
+					MDIO_XS_REG_8073_RX_CTRL_PCIE, &val1);
+			/**
+			* Set bit 3 to invert Rx in 1G mode and clear this bit
+			* when it`s in 10G mode.
+			*/
+			if (vars->line_speed == SPEED_1000) {
+				DP(NETIF_MSG_LINK, "Swapping 1G polarity for"
+					      "the 8073\n");
+				val1 |= (1<<3);
+			} else
+				val1 &= ~(1<<3);
+
+			bnx2x_cl45_write(bp, phy,
+					 MDIO_XS_DEVAD,
+					 MDIO_XS_REG_8073_RX_CTRL_PCIE,
+					 val1);
+		}
 		bnx2x_ext_phy_10G_an_resolve(bp, phy, vars);
 		bnx2x_8073_resolve_fc(phy, params, vars);
 	}
-- 
1.7.1








