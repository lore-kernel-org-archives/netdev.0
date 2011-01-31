From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 05/10] bnx2x: Add and change some net_dev
 messages
Date: Mon, 31 Jan 2011 16:22:20 +0200
Message-ID: <1296483740.17181.115.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3424 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753853Ab1AaOZR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jan 2011 09:25:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add and modify some net dev prints to improve error control

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   41 +++++++++++++++++++++++++++------------
 1 files changed, 28 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index a394092..c02f744 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -1422,6 +1422,7 @@ static u8 bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
 	}
 	if (tmp & EMAC_MDIO_COMM_START_BUSY) {
 		DP(NETIF_MSG_LINK, "write phy register failed\n");
+		netdev_err(bp->dev,  "MDC/MDIO access timeout\n");
 		rc = -EFAULT;
 	} else {
 		/* data */
@@ -1442,6 +1443,7 @@ static u8 bnx2x_cl45_write(struct bnx2x *bp, struct bnx2x_phy *phy,
 		}
 		if (tmp & EMAC_MDIO_COMM_START_BUSY) {
 			DP(NETIF_MSG_LINK, "write phy register failed\n");
+			netdev_err(bp->dev,  "MDC/MDIO access timeout\n");
 			rc = -EFAULT;
 		}
 	}
@@ -1489,7 +1491,7 @@ static u8 bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
 	}
 	if (val & EMAC_MDIO_COMM_START_BUSY) {
 		DP(NETIF_MSG_LINK, "read phy register failed\n");
-
+		netdev_err(bp->dev,  "MDC/MDIO access timeout\n");
 		*ret_val = 0;
 		rc = -EFAULT;
 
@@ -1512,7 +1514,7 @@ static u8 bnx2x_cl45_read(struct bnx2x *bp, struct bnx2x_phy *phy,
 		}
 		if (val & EMAC_MDIO_COMM_START_BUSY) {
 			DP(NETIF_MSG_LINK, "read phy register failed\n");
-
+			netdev_err(bp->dev,  "MDC/MDIO access timeout\n");
 			*ret_val = 0;
 			rc = -EFAULT;
 		}
@@ -1827,6 +1829,9 @@ static u8 bnx2x_reset_unicore(struct link_params *params,
 		}
 	}
 
+	netdev_err(bp->dev,  "Warning: PHY was not initialized,"
+			      " Port %d\n",
+			 params->port);
 	DP(NETIF_MSG_LINK, "BUG! XGXS is still in reset!\n");
 	return -EINVAL;
 
@@ -2846,7 +2851,8 @@ static u8 bnx2x_init_xgxs(struct bnx2x_phy *phy,
 }
 
 static u16 bnx2x_wait_reset_complete(struct bnx2x *bp,
-				     struct bnx2x_phy *phy)
+				     struct bnx2x_phy *phy,
+				     struct link_params *params)
 {
 	u16 cnt, ctrl;
 	/* Wait for soft reset to get cleared upto 1 sec */
@@ -2857,6 +2863,11 @@ static u16 bnx2x_wait_reset_complete(struct bnx2x *bp,
 			break;
 		msleep(1);
 	}
+
+	if (cnt == 1000)
+		netdev_err(bp->dev,  "Warning: PHY was not initialized,"
+				      " Port %d\n",
+			 params->port);
 	DP(NETIF_MSG_LINK, "control reg 0x%x (after %d ms)\n", ctrl, cnt);
 	return cnt;
 }
@@ -4446,7 +4457,7 @@ static u8 bnx2x_8705_config_init(struct bnx2x_phy *phy,
 	/* HW reset */
 	bnx2x_ext_phy_hw_reset(bp, params->port);
 	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0xa040);
-	bnx2x_wait_reset_complete(bp, phy);
+	bnx2x_wait_reset_complete(bp, phy, params);
 
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD, MDIO_PMA_REG_MISC_CTRL, 0x8288);
@@ -4841,9 +4852,9 @@ static u8 bnx2x_verify_sfp_module(struct bnx2x_phy *phy,
 	else
 		vendor_pn[SFP_EEPROM_PART_NO_SIZE] = '\0';
 
-	netdev_info(bp->dev, "Warning: Unqualified SFP+ module detected,"
-			     " Port %d from %s part number %s\n",
-		    params->port, vendor_name, vendor_pn);
+	netdev_err(bp->dev,  "Warning: Unqualified SFP+ module detected,"
+			      " Port %d from %s part number %s\n",
+			 params->port, vendor_name, vendor_pn);
 	phy->flags |= FLAGS_SFP_NOT_APPROVED;
 	return -EINVAL;
 }
@@ -5186,7 +5197,7 @@ static u8 bnx2x_8706_config_init(struct bnx2x_phy *phy,
 	/* HW reset */
 	bnx2x_ext_phy_hw_reset(bp, params->port);
 	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 0xa040);
-	bnx2x_wait_reset_complete(bp, phy);
+	bnx2x_wait_reset_complete(bp, phy, params);
 
 	/* Wait until fw is loaded */
 	for (cnt = 0; cnt < 100; cnt++) {
@@ -5349,7 +5360,7 @@ static u8 bnx2x_8726_config_init(struct bnx2x_phy *phy,
 			    MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
 
 	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 1<<15);
-	bnx2x_wait_reset_complete(bp, phy);
+	bnx2x_wait_reset_complete(bp, phy, params);
 
 	bnx2x_8726_external_rom_boot(phy, params);
 
@@ -5539,7 +5550,7 @@ static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	/* Enable PMD link, MOD_ABS_FLT, and 1G link alarm */
 
-	bnx2x_wait_reset_complete(bp, phy);
+	bnx2x_wait_reset_complete(bp, phy, params);
 	rx_alarm_ctrl_val = (1<<2) | (1<<5) ;
 	lasi_ctrl_val = 0x0004;
 
@@ -6161,7 +6172,7 @@ static u8 bnx2x_8481_config_init(struct bnx2x_phy *phy,
 
 	/* HW reset */
 	bnx2x_ext_phy_hw_reset(bp, params->port);
-	bnx2x_wait_reset_complete(bp, phy);
+	bnx2x_wait_reset_complete(bp, phy, params);
 
 	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_CTRL, 1<<15);
 	return bnx2x_848xx_cmn_config_init(phy, params, vars);
@@ -6188,7 +6199,7 @@ static u8 bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
 		       MISC_REGISTERS_GPIO_OUTPUT_HIGH,
 		       port);
-	bnx2x_wait_reset_complete(bp, phy);
+	bnx2x_wait_reset_complete(bp, phy, params);
 	/* Wait for GPHY to come out of reset */
 	msleep(50);
 	/*
@@ -6576,7 +6587,7 @@ static u8 bnx2x_7101_config_init(struct bnx2x_phy *phy,
 		       MISC_REGISTERS_GPIO_OUTPUT_HIGH, params->port);
 	/* HW reset */
 	bnx2x_ext_phy_hw_reset(bp, params->port);
-	bnx2x_wait_reset_complete(bp, phy);
+	bnx2x_wait_reset_complete(bp, phy, params);
 
 	bnx2x_cl45_write(bp, phy,
 			 MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL, 0x1);
@@ -8029,6 +8040,10 @@ static u8 bnx2x_ext_phy_common_init(struct bnx2x *bp, u32 shmem_base_path[],
 		break;
 	}
 
+	if (rc != 0)
+		netdev_err(bp->dev,  "Warning: PHY was not initialized,"
+				      " Port %d\n",
+			 0);
 	return rc;
 }
 
-- 
1.7.1








