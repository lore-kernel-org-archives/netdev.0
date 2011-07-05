From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-next 6/8] bnx2x: Fix BCM84833 initialization
Date: Tue, 5 Jul 2011 14:06:59 +0300
Message-ID: <1309864019.4050.85.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3865 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755943Ab1GELHJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Jul 2011 07:07:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_hsi.h  |    8 ++++++-
 drivers/net/bnx2x/bnx2x_link.c |   45 +++++++++++++++++++++++++++++----------
 2 files changed, 40 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index 52c190f..0692d75 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -538,7 +538,13 @@ struct port_hw_cfg {		    /* port 0: 0x12c  port 1: 0x2bc */
 	u32 fcoe_wwn_node_name_upper;
 	u32 fcoe_wwn_node_name_lower;
 
-	u32 Reserved1[50];					/* 0x1C0 */
+	u32 Reserved1[49];				    /* 0x1C0 */
+
+	/*  Enable RJ45 magjack pair swapping on 10GBase-T PHY (0=default),
+	      84833 only */
+	u32 xgbt_phy_cfg;				    /* 0x284 */
+	#define PORT_HW_CFG_RJ45_PAIR_SWAP_MASK             0x000000FF
+	#define PORT_HW_CFG_RJ45_PAIR_SWAP_SHIFT                     0
 
 		u32 default_cfg;			    /* 0x288 */
 	#define PORT_HW_CFG_GPIO0_CONFIG_MASK               0x00000003
diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 144cfae..d6684b3 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -9182,11 +9182,14 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 			 MDIO_AN_DEVAD, MDIO_AN_REG_8481_1000T_CTRL,
 			 an_1000_val);
 
-	/* set 10 speed advertisement */
+	/* set 100 speed advertisement */
 	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
 	     (phy->speed_cap_mask &
-	     (PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL |
-	      PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF)))) {
+	      (PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL |
+	       PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF)) &&
+	     (phy->supported &
+	      (SUPPORTED_100baseT_Half |
+	       SUPPORTED_100baseT_Full)))) {
 		an_10_100_val |= (1<<7);
 		/* Enable autoneg and restart autoneg for legacy speeds */
 		autoneg_val |= (1<<9 | 1<<12);
@@ -9197,9 +9200,12 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 	}
 	/* set 10 speed advertisement */
 	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
-	    (phy->speed_cap_mask &
-	  (PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL |
-	   PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF)))) {
+	     (phy->speed_cap_mask &
+	      (PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL |
+	       PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF)) &&
+	     (phy->supported &
+	      (SUPPORTED_10baseT_Half |
+	       SUPPORTED_10baseT_Full)))) {
 		an_10_100_val |= (1<<5);
 		autoneg_val |= (1<<9 | 1<<12);
 		if (phy->req_duplex == DUPLEX_FULL)
@@ -9208,7 +9214,10 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 	}
 
 	/* Only 10/100 are allowed to work in FORCE mode */
-	if (phy->req_line_speed == SPEED_100) {
+	if ((phy->req_line_speed == SPEED_100) &&
+	    (phy->supported &
+	     (SUPPORTED_100baseT_Half |
+	      SUPPORTED_100baseT_Full))) {
 		autoneg_val |= (1<<13);
 		/* Enabled AUTO-MDIX when autoneg is disabled */
 		bnx2x_cl45_write(bp, phy,
@@ -9216,7 +9225,10 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 				 (1<<15 | 1<<9 | 7<<0));
 		DP(NETIF_MSG_LINK, "Setting 100M force\n");
 	}
-	if (phy->req_line_speed == SPEED_10) {
+	if ((phy->req_line_speed == SPEED_10) &&
+	    (phy->supported &
+	     (SUPPORTED_10baseT_Half |
+	      SUPPORTED_10baseT_Full))) {
 		/* Enabled AUTO-MDIX when autoneg is disabled */
 		bnx2x_cl45_write(bp, phy,
 				 MDIO_AN_DEVAD, MDIO_AN_REG_8481_AUX_CTRL,
@@ -9284,11 +9296,22 @@ static int bnx2x_84833_pair_swap_cfg(struct bnx2x_phy *phy,
 				   struct link_vars *vars)
 {
 	u32 idx;
+	u32 pair_swap;
 	u16 val;
-	u16 data = 0x01b1;
+	u16 data;
 	struct bnx2x *bp = params->bp;
 	/* Do pair swap */
 
+	/* Check for configuration. */
+	pair_swap = REG_RD(bp, params->shmem_base +
+			   offsetof(struct shmem_region,
+			dev_info.port_hw_config[params->port].xgbt_phy_cfg)) &
+		PORT_HW_CFG_RJ45_PAIR_SWAP_MASK;
+
+	if (pair_swap == 0)
+		return 0;
+
+	data = (u16)pair_swap;
 
 	/* Write CMD_OPEN_OVERRIDE to STATUS reg */
 	bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
@@ -10787,9 +10810,7 @@ static struct bnx2x_phy phy_84833 = {
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.tx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
 	.mdio_ctrl	= 0,
-	.supported	= (SUPPORTED_10baseT_Half |
-			   SUPPORTED_10baseT_Full |
-			   SUPPORTED_100baseT_Half |
+	.supported	= (SUPPORTED_100baseT_Half |
 			   SUPPORTED_100baseT_Full |
 			   SUPPORTED_1000baseT_Full |
 			   SUPPORTED_10000baseT_Full |
-- 
1.7.1







