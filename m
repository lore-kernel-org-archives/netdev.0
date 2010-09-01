From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-next 4/8] bnx2x: Change BCM848xx configuration
 according to IEEE
Date: Wed, 1 Sep 2010 22:51:25 +0300
Message-ID: <1283370685.4403.135.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4778 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755177Ab0IAQdP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 12:33:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change BCM848xx behavior to fit IEEE such that setting 10Mb/100Mb will
use force speed, and setting 1Gb/10Gb will use auto-negotiation with the
specific speed advertised 

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x_link.c |  288 +++++++++++++++++-----------------------
 drivers/net/bnx2x/bnx2x_reg.h  |    3 +-
 2 files changed, 127 insertions(+), 164 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index cbacf8a..7a8df7a 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -4354,197 +4354,159 @@ static u8 bnx2x_ext_phy_init(struct link_params *params, struct link_vars *vars)
 		}
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481:
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823:
+		{
 			/* This phy uses the NIG latch mechanism since link
 				indication arrives through its LED4 and not via
 				its LASI signal, so we get steady signal
 				instead of clear on read */
+			u16 autoneg_val, an_1000_val, an_10_100_val;
 			bnx2x_bits_en(bp, NIG_REG_LATCH_BC_0 + params->port*4,
-				    1 << NIG_LATCH_BC_ENABLE_MI_INT);
+				      1 << NIG_LATCH_BC_ENABLE_MI_INT);
 
 			bnx2x_cl45_write(bp, params->port,
-				       PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
-				       ext_phy_addr,
-				       MDIO_PMA_DEVAD,
-				       MDIO_PMA_REG_CTRL, 0x0000);
+					 ext_phy_type,
+					 ext_phy_addr,
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_CTRL, 0x0000);
 
 			bnx2x_8481_set_led4(params, ext_phy_type, ext_phy_addr);
-			if (params->req_line_speed == SPEED_AUTO_NEG) {
 
-				u16 autoneg_val, an_1000_val, an_10_100_val;
-				/* set 1000 speed advertisement */
-				bnx2x_cl45_read(bp, params->port,
-					      ext_phy_type,
-					      ext_phy_addr,
-					      MDIO_AN_DEVAD,
-					      MDIO_AN_REG_8481_1000T_CTRL,
-					      &an_1000_val);
-
-				if (params->speed_cap_mask &
-				    PORT_HW_CFG_SPEED_CAPABILITY_D0_1G) {
-					an_1000_val |= (1<<8);
-					if (params->req_duplex == DUPLEX_FULL)
-						an_1000_val |= (1<<9);
-					DP(NETIF_MSG_LINK, "Advertising 1G\n");
-				} else
-					an_1000_val &= ~((1<<8) | (1<<9));
-
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
-					       MDIO_AN_DEVAD,
-					       MDIO_AN_REG_8481_1000T_CTRL,
-					       an_1000_val);
-
-				/* set 100 speed advertisement */
-				bnx2x_cl45_read(bp, params->port,
-					      ext_phy_type,
-					      ext_phy_addr,
-					      MDIO_AN_DEVAD,
-					      MDIO_AN_REG_8481_LEGACY_AN_ADV,
-					      &an_10_100_val);
-
-				if (params->speed_cap_mask &
-				 (PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL |
-				  PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF)) {
-					an_10_100_val |= (1<<7);
-					if (params->req_duplex == DUPLEX_FULL)
-						an_10_100_val |= (1<<8);
-					DP(NETIF_MSG_LINK,
-						"Advertising 100M\n");
-				} else
-					an_10_100_val &= ~((1<<7) | (1<<8));
-
-				/* set 10 speed advertisement */
-				if (params->speed_cap_mask &
-				  (PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL |
-				   PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF)) {
-					an_10_100_val |= (1<<5);
-					if (params->req_duplex == DUPLEX_FULL)
-						an_10_100_val |= (1<<6);
-					DP(NETIF_MSG_LINK, "Advertising 10M\n");
-				     }
-				else
-					an_10_100_val &= ~((1<<5) | (1<<6));
-
-				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
-					       MDIO_AN_DEVAD,
-					       MDIO_AN_REG_8481_LEGACY_AN_ADV,
-					       an_10_100_val);
-
-				bnx2x_cl45_read(bp, params->port,
-					      ext_phy_type,
-					      ext_phy_addr,
-					      MDIO_AN_DEVAD,
-					      MDIO_AN_REG_8481_LEGACY_MII_CTRL,
-					      &autoneg_val);
-
-				/* Disable forced speed */
-				autoneg_val &= ~(1<<6|1<<13);
+			bnx2x_cl45_read(bp, params->port,
+					ext_phy_type,
+					ext_phy_addr,
+					MDIO_AN_DEVAD,
+					MDIO_AN_REG_8481_1000T_CTRL,
+					&an_1000_val);
+			bnx2x_ext_phy_set_pause(params, vars);
+			bnx2x_cl45_read(bp, params->port, ext_phy_type,
+					ext_phy_addr, MDIO_AN_DEVAD,
+					MDIO_AN_REG_8481_LEGACY_AN_ADV,
+					&an_10_100_val);
+			bnx2x_cl45_read(bp, params->port, ext_phy_type,
+					ext_phy_addr, MDIO_AN_DEVAD,
+					MDIO_AN_REG_8481_LEGACY_MII_CTRL,
+					&autoneg_val);
+			/* Disable forced speed */
+			autoneg_val &= ~((1<<6) | (1<<8) | (1<<9) | (1<<12) |
+					 (1<<13));
+			an_10_100_val &= ~((1<<5) | (1<<6) | (1<<7) | (1<<8));
+
+			if (((params->req_line_speed == SPEED_AUTO_NEG) &&
+			     (params->speed_cap_mask &
+			      PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)) ||
+			    (params->req_line_speed == SPEED_1000)) {
+				an_1000_val |= (1<<8);
+				autoneg_val |= (1<<9 | 1<<12);
+				if (params->req_duplex == DUPLEX_FULL)
+					an_1000_val |= (1<<9);
+				DP(NETIF_MSG_LINK, "Advertising 1G\n");
+			} else
+				an_1000_val &= ~((1<<8) | (1<<9));
 
-				/* Enable autoneg and restart autoneg
-				for legacy speeds */
-				autoneg_val |= (1<<9|1<<12);
+			bnx2x_cl45_write(bp, params->port,
+					 ext_phy_type,
+					 ext_phy_addr,
+					 MDIO_AN_DEVAD,
+					 MDIO_AN_REG_8481_1000T_CTRL,
+					 an_1000_val);
+
+			/* set 10 speed advertisement */
+			if (((params->req_line_speed == SPEED_AUTO_NEG) &&
+			     (params->speed_cap_mask &
+			      (PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL |
+			       PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF)))) {
+				an_10_100_val |= (1<<7);
+				/*
+				 * Enable autoneg and restart autoneg for
+				 * legacy speeds
+				 */
+				autoneg_val |= (1<<9 | 1<<12);
 
 				if (params->req_duplex == DUPLEX_FULL)
-					autoneg_val |= (1<<8);
-				else
-					autoneg_val &= ~(1<<8);
+					an_10_100_val |= (1<<8);
+				DP(NETIF_MSG_LINK, "Advertising 100M\n");
+			}
+			/* set 10 speed advertisement */
+			if (((params->req_line_speed == SPEED_AUTO_NEG) &&
+			     (params->speed_cap_mask &
+			      (PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL |
+			       PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF)))) {
+				an_10_100_val |= (1<<5);
+				autoneg_val |= (1<<9 | 1<<12);
+				if (params->req_duplex == DUPLEX_FULL)
+					an_10_100_val |= (1<<6);
+				DP(NETIF_MSG_LINK, "Advertising 10M\n");
+			}
 
+			/* Only 10/100 are allowed to work in FORCE mode */
+			if (params->req_line_speed == SPEED_100) {
+				autoneg_val |= (1<<13);
+				/* Enabled AUTO-MDIX when autoneg is disabled */
 				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
-					       MDIO_AN_DEVAD,
-					       MDIO_AN_REG_8481_LEGACY_MII_CTRL,
-					       autoneg_val);
-
-				if (params->speed_cap_mask &
-				    PORT_HW_CFG_SPEED_CAPABILITY_D0_10G) {
-					DP(NETIF_MSG_LINK, "Advertising 10G\n");
-					/* Restart autoneg for 10G*/
+						 ext_phy_type,
+						 ext_phy_addr,
+						 MDIO_AN_DEVAD,
+						 MDIO_AN_REG_8481_AUX_CTRL,
+						 (1<<15 | 1<<9 | 7<<0));
+				DP(NETIF_MSG_LINK, "Setting 100M force\n");
+			}
+			if (params->req_line_speed == SPEED_10) {
+				/* Enabled AUTO-MDIX when autoneg is disabled */
+				bnx2x_cl45_write(bp, params->port,
+						 ext_phy_type,
+						 ext_phy_addr,
+						 MDIO_AN_DEVAD,
+						 MDIO_AN_REG_8481_AUX_CTRL,
+						 (1<<15 | 1<<9 | 7<<0));
+				DP(NETIF_MSG_LINK, "Setting 10M force\n");
+			}
 
 			bnx2x_cl45_write(bp, params->port,
-				       ext_phy_type,
-				       ext_phy_addr,
-				       MDIO_AN_DEVAD,
-				       MDIO_AN_REG_CTRL, 0x3200);
-				}
-			} else {
-				/* Force speed */
-				u16 autoneg_ctrl, pma_ctrl;
-				bnx2x_cl45_read(bp, params->port,
-					      ext_phy_type,
-					      ext_phy_addr,
-					      MDIO_AN_DEVAD,
-					      MDIO_AN_REG_8481_LEGACY_MII_CTRL,
-					      &autoneg_ctrl);
+					 ext_phy_type,
+					 ext_phy_addr,
+					 MDIO_AN_DEVAD,
+					 MDIO_AN_REG_8481_LEGACY_AN_ADV,
+					 an_10_100_val);
 
-				/* Disable autoneg */
-				autoneg_ctrl &= ~(1<<12);
+			if (params->req_duplex == DUPLEX_FULL)
+				autoneg_val |= (1<<8);
 
-				/* Set 1000 force */
-				switch (params->req_line_speed) {
-				case SPEED_10000:
-					DP(NETIF_MSG_LINK,
-						"Unable to set 10G force !\n");
-					break;
-				case SPEED_1000:
-					bnx2x_cl45_read(bp, params->port,
-						      ext_phy_type,
-						      ext_phy_addr,
-						      MDIO_PMA_DEVAD,
-						      MDIO_PMA_REG_CTRL,
-						      &pma_ctrl);
-					autoneg_ctrl &= ~(1<<13);
-					autoneg_ctrl |= (1<<6);
-					pma_ctrl &= ~(1<<13);
-					pma_ctrl |= (1<<6);
-					DP(NETIF_MSG_LINK,
-						"Setting 1000M force\n");
-					bnx2x_cl45_write(bp, params->port,
-						       ext_phy_type,
-						       ext_phy_addr,
-						       MDIO_PMA_DEVAD,
-						       MDIO_PMA_REG_CTRL,
-						       pma_ctrl);
-					break;
-				case SPEED_100:
-					autoneg_ctrl |= (1<<13);
-					autoneg_ctrl &= ~(1<<6);
-					DP(NETIF_MSG_LINK,
-						"Setting 100M force\n");
-					break;
-				case SPEED_10:
-					autoneg_ctrl &= ~(1<<13);
-					autoneg_ctrl &= ~(1<<6);
-					DP(NETIF_MSG_LINK,
-						"Setting 10M force\n");
-					break;
-				}
+			bnx2x_cl45_write(bp, params->port,
+					 ext_phy_type,
+					 ext_phy_addr,
+					 MDIO_AN_DEVAD,
+					 MDIO_AN_REG_8481_LEGACY_MII_CTRL,
+					 autoneg_val);
 
-				/* Duplex mode */
-				if (params->req_duplex == DUPLEX_FULL) {
-					autoneg_ctrl |= (1<<8);
-					DP(NETIF_MSG_LINK,
-						"Setting full duplex\n");
-				} else
-					autoneg_ctrl &= ~(1<<8);
+			if (((params->req_line_speed == SPEED_AUTO_NEG) &&
+			     (params->speed_cap_mask &
+			      PORT_HW_CFG_SPEED_CAPABILITY_D0_10G)) ||
+			    (params->req_line_speed == SPEED_10000)) {
+				DP(NETIF_MSG_LINK, "Advertising 10G\n");
+				/* Restart autoneg for 10G*/
 
-				/* Update autoneg ctrl and pma ctrl */
 				bnx2x_cl45_write(bp, params->port,
-					       ext_phy_type,
-					       ext_phy_addr,
-					       MDIO_AN_DEVAD,
-					       MDIO_AN_REG_8481_LEGACY_MII_CTRL,
-					       autoneg_ctrl);
-			}
+						 ext_phy_type,
+						 ext_phy_addr,
+						 MDIO_AN_DEVAD,
+						 MDIO_AN_REG_CTRL,
+						 0x3200);
+
+			} else if (params->req_line_speed != SPEED_10 &&
+				   params->req_line_speed != SPEED_100)
+				bnx2x_cl45_write(bp, params->port,
+					     ext_phy_type,
+					     ext_phy_addr,
+					     MDIO_AN_DEVAD,
+					     MDIO_AN_REG_8481_10GBASE_T_AN_CTRL,
+					     1);
 
 			/* Save spirom version */
 			bnx2x_save_8481_spirom_version(bp, params->port,
 						     ext_phy_addr,
 						     params->shmem_base);
 			break;
+		}
 		case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
 			DP(NETIF_MSG_LINK,
 				 "XGXS PHY Failure detected 0x%x\n",
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index c82e261..3989617 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -5212,12 +5212,13 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_AN_REG_8073_2_5G		0x8329
 
 #define MDIO_AN_REG_8727_MISC_CTRL	0x8309
-
+#define MDIO_AN_REG_8481_10GBASE_T_AN_CTRL	0x0020
 #define MDIO_AN_REG_8481_LEGACY_MII_CTRL	0xffe0
 #define MDIO_AN_REG_8481_LEGACY_AN_ADV		0xffe4
 #define MDIO_AN_REG_8481_1000T_CTRL		0xffe9
 #define MDIO_AN_REG_8481_EXPANSION_REG_RD_RW	0xfff5
 #define MDIO_AN_REG_8481_EXPANSION_REG_ACCESS	0xfff7
+#define MDIO_AN_REG_8481_AUX_CTRL		0xfff8
 #define MDIO_AN_REG_8481_LEGACY_SHADOW		0xfffc
 
 #define IGU_FUNC_BASE			0x0400
-- 
1.7.1




