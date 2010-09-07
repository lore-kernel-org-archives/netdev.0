From: "Yaniv Rosner" <yaniv.rosner@broadcom.com>
Subject: [PATCH net-next 08/10] bnx2x: Add dual-media changes
Date: Wed, 8 Sep 2010 00:41:20 +0300
Message-ID: <1283895680.5452.68.camel@lb-tlvb-yanivr.il.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3992 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932449Ab0IGSXK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 14:23:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add required changes in order to support dual-media boards.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com> 
---
 drivers/net/bnx2x/bnx2x.h         |   10 +-
 drivers/net/bnx2x/bnx2x_cmn.c     |   14 +-
 drivers/net/bnx2x/bnx2x_cmn.h     |    3 +-
 drivers/net/bnx2x/bnx2x_ethtool.c |  176 +++++++---
 drivers/net/bnx2x/bnx2x_hsi.h     |  111 ++++++-
 drivers/net/bnx2x/bnx2x_link.c    |  695 ++++++++++++++++++++++++++++---------
 drivers/net/bnx2x/bnx2x_link.h    |   62 +++--
 drivers/net/bnx2x/bnx2x_main.c    |  354 +++++++++++++------
 drivers/net/bnx2x/bnx2x_reg.h     |   25 ++
 9 files changed, 1074 insertions(+), 376 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index a019c67..1371876 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -566,13 +566,13 @@ struct bnx2x_common {
 struct bnx2x_port {
 	u32			pmf;
 
-	u32			link_config;
+	u32			link_config[LINK_CONFIG_SIZE];
 
-	u32			supported;
+	u32			supported[LINK_CONFIG_SIZE];
 /* link settings - missing defines */
 #define SUPPORTED_2500baseX_Full	(1 << 15)
 
-	u32			advertising;
+	u32			advertising[LINK_CONFIG_SIZE];
 /* link settings - missing defines */
 #define ADVERTISED_2500baseX_Full	(1 << 15)
 
@@ -931,7 +931,7 @@ void bnx2x_write_dmae(struct bnx2x *bp, dma_addr_t dma_addr, u32 dst_addr,
 int bnx2x_get_gpio(struct bnx2x *bp, int gpio_num, u8 port);
 int bnx2x_set_gpio(struct bnx2x *bp, int gpio_num, u32 mode, u8 port);
 int bnx2x_set_gpio_int(struct bnx2x *bp, int gpio_num, u32 mode, u8 port);
-u32 bnx2x_fw_command(struct bnx2x *bp, u32 command);
+u32 bnx2x_fw_command(struct bnx2x *bp, u32 command, u32 param);
 void bnx2x_reg_wr_ind(struct bnx2x *bp, u32 addr, u32 val);
 void bnx2x_write_dmae_phys_len(struct bnx2x *bp, dma_addr_t phys_addr,
 			       u32 addr, u32 len);
@@ -939,7 +939,7 @@ void bnx2x_calc_fc_adv(struct bnx2x *bp);
 int bnx2x_sp_post(struct bnx2x *bp, int command, int cid,
 		  u32 data_hi, u32 data_lo, int common);
 void bnx2x_update_coalesce(struct bnx2x *bp);
-
+int bnx2x_get_link_cfg_idx(struct bnx2x *bp);
 static inline u32 reg_poll(struct bnx2x *bp, u32 reg, u32 expected, int ms,
 			   int wait)
 {
diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 0e4caf4..7f1d291 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1283,7 +1283,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	   common blocks should be initialized, otherwise - not
 	*/
 	if (!BP_NOMCP(bp)) {
-		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ);
+		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_REQ, 0);
 		if (!load_code) {
 			BNX2X_ERR("MCP response failure, aborting\n");
 			rc = -EBUSY;
@@ -1322,9 +1322,9 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 	rc = bnx2x_init_hw(bp, load_code);
 	if (rc) {
 		BNX2X_ERR("HW init failed, aborting\n");
-		bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE);
-		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP);
-		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
+		bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE, 0);
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP, 0);
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE, 0);
 		goto load_error2;
 	}
 
@@ -1339,7 +1339,7 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode)
 
 	/* Send LOAD_DONE command to MCP */
 	if (!BP_NOMCP(bp)) {
-		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE);
+		load_code = bnx2x_fw_command(bp, DRV_MSG_CODE_LOAD_DONE, 0);
 		if (!load_code) {
 			BNX2X_ERR("MCP response failure, aborting\n");
 			rc = -EBUSY;
@@ -1455,8 +1455,8 @@ load_error4:
 load_error3:
 	bnx2x_int_disable_sync(bp, 1);
 	if (!BP_NOMCP(bp)) {
-		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP);
-		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_REQ_WOL_MCP, 0);
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE, 0);
 	}
 	bp->port.pmf = 0;
 	/* Free SKBs, SGEs, TPA pool and driver internals */
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 32543c3..d1e6a8c 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -49,10 +49,11 @@ void bnx2x_link_set(struct bnx2x *bp);
  * Query link status
  *
  * @param bp
+ * @param is_serdes
  *
  * @return 0 - link is UP
  */
-u8 bnx2x_link_test(struct bnx2x *bp);
+u8 bnx2x_link_test(struct bnx2x *bp, u8 is_serdes);
 
 /**
  * Handles link status change
diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index dbcfa7a..d058f97 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -29,9 +29,12 @@
 static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-
-	cmd->supported = bp->port.supported;
-	cmd->advertising = bp->port.advertising;
+	int cfg_idx = bnx2x_get_link_cfg_idx(bp);
+	/* Dual Media boards present all available port types */
+	cmd->supported = bp->port.supported[cfg_idx] |
+		(bp->port.supported[cfg_idx ^ 1] &
+		 (SUPPORTED_TP | SUPPORTED_FIBRE));
+	cmd->advertising = bp->port.advertising[cfg_idx];
 
 	if ((bp->state == BNX2X_STATE_OPEN) &&
 	    !(bp->flags & MF_FUNC_DIS) &&
@@ -48,22 +51,21 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				cmd->speed = vn_max_rate;
 		}
 	} else {
-		cmd->speed = -1;
-		cmd->duplex = -1;
+		cmd->speed = bp->link_params.req_line_speed[cfg_idx];
+		cmd->duplex = bp->link_params.req_duplex[cfg_idx];
 	}
 
-	if (bp->link_params.num_phys > 0) {
-		if (bp->link_params.phy[bp->link_params.num_phys - 1].
-		    supported &	SUPPORTED_FIBRE)
-			cmd->port = PORT_FIBRE;
-		else
-			cmd->port = PORT_TP;
-	} else
-		DP(NETIF_MSG_LINK, "No media found\n");
+	if (bp->port.supported[cfg_idx] & SUPPORTED_TP)
+		cmd->port = PORT_TP;
+	else if (bp->port.supported[cfg_idx] & SUPPORTED_FIBRE)
+		cmd->port = PORT_FIBRE;
+	else
+		BNX2X_ERR("XGXS PHY Failure detected\n");
+
 	cmd->phy_address = bp->mdio.prtad;
 	cmd->transceiver = XCVR_INTERNAL;
 
-	if (bp->link_params.req_line_speed == SPEED_AUTO_NEG)
+	if (bp->link_params.req_line_speed[cfg_idx] == SPEED_AUTO_NEG)
 		cmd->autoneg = AUTONEG_ENABLE;
 	else
 		cmd->autoneg = AUTONEG_DISABLE;
@@ -85,7 +87,7 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-	u32 advertising;
+	u32 advertising, cfg_idx, old_multi_phy_config, new_multi_phy_config;
 
 	if (IS_E1HMF(bp))
 		return 0;
@@ -98,26 +100,81 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	   cmd->duplex, cmd->port, cmd->phy_address, cmd->transceiver,
 	   cmd->autoneg, cmd->maxtxpkt, cmd->maxrxpkt);
 
+	cfg_idx = bnx2x_get_link_cfg_idx(bp);
+	old_multi_phy_config = bp->link_params.multi_phy_config;
+	switch (cmd->port) {
+	case PORT_TP:
+		if (bp->port.supported[cfg_idx] & SUPPORTED_TP)
+			break; /* no port change */
+
+		if (!(bp->port.supported[0] & SUPPORTED_TP ||
+		      bp->port.supported[1] & SUPPORTED_TP)) {
+			DP(NETIF_MSG_LINK, "Unsupported port type\n");
+			return -EINVAL;
+		}
+		bp->link_params.multi_phy_config &=
+			~PORT_HW_CFG_PHY_SELECTION_MASK;
+		if (bp->link_params.multi_phy_config &
+		    PORT_HW_CFG_PHY_SWAPPED_ENABLED)
+			bp->link_params.multi_phy_config |=
+			PORT_HW_CFG_PHY_SELECTION_SECOND_PHY;
+		else
+			bp->link_params.multi_phy_config |=
+			PORT_HW_CFG_PHY_SELECTION_FIRST_PHY;
+		break;
+	case PORT_FIBRE:
+		if (bp->port.supported[cfg_idx] & SUPPORTED_FIBRE)
+			break; /* no port change */
+
+		if (!(bp->port.supported[0] & SUPPORTED_FIBRE ||
+		      bp->port.supported[1] & SUPPORTED_FIBRE)) {
+			DP(NETIF_MSG_LINK, "Unsupported port type\n");
+			return -EINVAL;
+		}
+		bp->link_params.multi_phy_config &=
+			~PORT_HW_CFG_PHY_SELECTION_MASK;
+		if (bp->link_params.multi_phy_config &
+		    PORT_HW_CFG_PHY_SWAPPED_ENABLED)
+			bp->link_params.multi_phy_config |=
+			PORT_HW_CFG_PHY_SELECTION_FIRST_PHY;
+		else
+			bp->link_params.multi_phy_config |=
+			PORT_HW_CFG_PHY_SELECTION_SECOND_PHY;
+		break;
+	default:
+		DP(NETIF_MSG_LINK, "Unsupported port type\n");
+		return -EINVAL;
+	}
+	/* Save new config in case command complete successuly */
+	new_multi_phy_config = bp->link_params.multi_phy_config;
+	/* Get the new cfg_idx */
+	cfg_idx = bnx2x_get_link_cfg_idx(bp);
+	/* Restore old config in case command failed */
+	bp->link_params.multi_phy_config = old_multi_phy_config;
+	DP(NETIF_MSG_LINK, "cfg_idx = %x\n", cfg_idx);
+
 	if (cmd->autoneg == AUTONEG_ENABLE) {
-		if (!(bp->port.supported & SUPPORTED_Autoneg)) {
+		if (!(bp->port.supported[cfg_idx] & SUPPORTED_Autoneg)) {
 			DP(NETIF_MSG_LINK, "Autoneg not supported\n");
 			return -EINVAL;
 		}
 
 		/* advertise the requested speed and duplex if supported */
-		cmd->advertising &= bp->port.supported;
+		cmd->advertising &= bp->port.supported[cfg_idx];
 
-		bp->link_params.req_line_speed = SPEED_AUTO_NEG;
-		bp->link_params.req_duplex = DUPLEX_FULL;
-		bp->port.advertising |= (ADVERTISED_Autoneg |
+		bp->link_params.req_line_speed[cfg_idx] = SPEED_AUTO_NEG;
+		bp->link_params.req_duplex[cfg_idx] = DUPLEX_FULL;
+		bp->port.advertising[cfg_idx] |= (ADVERTISED_Autoneg |
 					 cmd->advertising);
 
 	} else { /* forced speed */
 		/* advertise the requested speed and duplex if supported */
-		switch (cmd->speed) {
+		u32 speed = cmd->speed;
+		speed |= (cmd->speed_hi << 16);
+		switch (speed) {
 		case SPEED_10:
 			if (cmd->duplex == DUPLEX_FULL) {
-				if (!(bp->port.supported &
+				if (!(bp->port.supported[cfg_idx] &
 				      SUPPORTED_10baseT_Full)) {
 					DP(NETIF_MSG_LINK,
 					   "10M full not supported\n");
@@ -127,7 +184,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				advertising = (ADVERTISED_10baseT_Full |
 					       ADVERTISED_TP);
 			} else {
-				if (!(bp->port.supported &
+				if (!(bp->port.supported[cfg_idx] &
 				      SUPPORTED_10baseT_Half)) {
 					DP(NETIF_MSG_LINK,
 					   "10M half not supported\n");
@@ -141,7 +198,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 		case SPEED_100:
 			if (cmd->duplex == DUPLEX_FULL) {
-				if (!(bp->port.supported &
+				if (!(bp->port.supported[cfg_idx] &
 						SUPPORTED_100baseT_Full)) {
 					DP(NETIF_MSG_LINK,
 					   "100M full not supported\n");
@@ -151,7 +208,7 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				advertising = (ADVERTISED_100baseT_Full |
 					       ADVERTISED_TP);
 			} else {
-				if (!(bp->port.supported &
+				if (!(bp->port.supported[cfg_idx] &
 						SUPPORTED_100baseT_Half)) {
 					DP(NETIF_MSG_LINK,
 					   "100M half not supported\n");
@@ -169,7 +226,8 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				return -EINVAL;
 			}
 
-			if (!(bp->port.supported & SUPPORTED_1000baseT_Full)) {
+			if (!(bp->port.supported[cfg_idx] &
+			      SUPPORTED_1000baseT_Full)) {
 				DP(NETIF_MSG_LINK, "1G full not supported\n");
 				return -EINVAL;
 			}
@@ -185,7 +243,8 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				return -EINVAL;
 			}
 
-			if (!(bp->port.supported & SUPPORTED_2500baseX_Full)) {
+			if (!(bp->port.supported[cfg_idx]
+			      & SUPPORTED_2500baseX_Full)) {
 				DP(NETIF_MSG_LINK,
 				   "2.5G full not supported\n");
 				return -EINVAL;
@@ -201,7 +260,8 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				return -EINVAL;
 			}
 
-			if (!(bp->port.supported & SUPPORTED_10000baseT_Full)) {
+			if (!(bp->port.supported[cfg_idx]
+			      & SUPPORTED_10000baseT_Full)) {
 				DP(NETIF_MSG_LINK, "10G full not supported\n");
 				return -EINVAL;
 			}
@@ -211,20 +271,23 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			break;
 
 		default:
-			DP(NETIF_MSG_LINK, "Unsupported speed\n");
+			DP(NETIF_MSG_LINK, "Unsupported speed %d\n", speed);
 			return -EINVAL;
 		}
 
-		bp->link_params.req_line_speed = cmd->speed;
-		bp->link_params.req_duplex = cmd->duplex;
-		bp->port.advertising = advertising;
+		bp->link_params.req_line_speed[cfg_idx] = speed;
+		bp->link_params.req_duplex[cfg_idx] = cmd->duplex;
+		bp->port.advertising[cfg_idx] = advertising;
 	}
 
 	DP(NETIF_MSG_LINK, "req_line_speed %d\n"
 	   DP_LEVEL "  req_duplex %d  advertising 0x%x\n",
-	   bp->link_params.req_line_speed, bp->link_params.req_duplex,
-	   bp->port.advertising);
+	   bp->link_params.req_line_speed[cfg_idx],
+	   bp->link_params.req_duplex[cfg_idx],
+	   bp->port.advertising[cfg_idx]);
 
+	/* Set new config */
+	bp->link_params.multi_phy_config = new_multi_phy_config;
 	if (netif_running(dev)) {
 		bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 		bnx2x_link_set(bp);
@@ -937,10 +1000,9 @@ static void bnx2x_get_pauseparam(struct net_device *dev,
 				 struct ethtool_pauseparam *epause)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-
-	epause->autoneg = (bp->link_params.req_flow_ctrl ==
-			   BNX2X_FLOW_CTRL_AUTO) &&
-			  (bp->link_params.req_line_speed == SPEED_AUTO_NEG);
+	int cfg_idx = bnx2x_get_link_cfg_idx(bp);
+	epause->autoneg = (bp->link_params.req_flow_ctrl[cfg_idx] ==
+			   BNX2X_FLOW_CTRL_AUTO);
 
 	epause->rx_pause = ((bp->link_vars.flow_ctrl & BNX2X_FLOW_CTRL_RX) ==
 			    BNX2X_FLOW_CTRL_RX);
@@ -956,7 +1018,7 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 				struct ethtool_pauseparam *epause)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-
+	u32 cfg_idx = bnx2x_get_link_cfg_idx(bp);
 	if (IS_E1HMF(bp))
 		return 0;
 
@@ -964,29 +1026,31 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 	   DP_LEVEL "  autoneg %d  rx_pause %d  tx_pause %d\n",
 	   epause->cmd, epause->autoneg, epause->rx_pause, epause->tx_pause);
 
-	bp->link_params.req_flow_ctrl = BNX2X_FLOW_CTRL_AUTO;
+	bp->link_params.req_flow_ctrl[cfg_idx] = BNX2X_FLOW_CTRL_AUTO;
 
 	if (epause->rx_pause)
-		bp->link_params.req_flow_ctrl |= BNX2X_FLOW_CTRL_RX;
+		bp->link_params.req_flow_ctrl[cfg_idx] |= BNX2X_FLOW_CTRL_RX;
 
 	if (epause->tx_pause)
-		bp->link_params.req_flow_ctrl |= BNX2X_FLOW_CTRL_TX;
+		bp->link_params.req_flow_ctrl[cfg_idx] |= BNX2X_FLOW_CTRL_TX;
 
-	if (bp->link_params.req_flow_ctrl == BNX2X_FLOW_CTRL_AUTO)
-		bp->link_params.req_flow_ctrl = BNX2X_FLOW_CTRL_NONE;
+	if (bp->link_params.req_flow_ctrl[cfg_idx] == BNX2X_FLOW_CTRL_AUTO)
+		bp->link_params.req_flow_ctrl[cfg_idx] = BNX2X_FLOW_CTRL_NONE;
 
 	if (epause->autoneg) {
-		if (!(bp->port.supported & SUPPORTED_Autoneg)) {
+		if (!(bp->port.supported[cfg_idx] & SUPPORTED_Autoneg)) {
 			DP(NETIF_MSG_LINK, "autoneg not supported\n");
 			return -EINVAL;
 		}
 
-		if (bp->link_params.req_line_speed == SPEED_AUTO_NEG)
-			bp->link_params.req_flow_ctrl = BNX2X_FLOW_CTRL_AUTO;
+		if (bp->link_params.req_line_speed[cfg_idx] == SPEED_AUTO_NEG) {
+			bp->link_params.req_flow_ctrl[cfg_idx] =
+				BNX2X_FLOW_CTRL_AUTO;
+		}
 	}
 
 	DP(NETIF_MSG_LINK,
-	   "req_flow_ctrl 0x%x\n", bp->link_params.req_flow_ctrl);
+	   "req_flow_ctrl 0x%x\n", bp->link_params.req_flow_ctrl[cfg_idx]);
 
 	if (netif_running(dev)) {
 		bnx2x_stats_handle(bp, STATS_EVENT_STOP);
@@ -1250,12 +1314,12 @@ test_mem_exit:
 	return rc;
 }
 
-static void bnx2x_wait_for_link(struct bnx2x *bp, u8 link_up)
+static void bnx2x_wait_for_link(struct bnx2x *bp, u8 link_up, u8 is_serdes)
 {
 	int cnt = 1000;
 
 	if (link_up)
-		while (bnx2x_link_test(bp) && cnt--)
+		while (bnx2x_link_test(bp, is_serdes) && cnt--)
 			msleep(10);
 }
 
@@ -1527,7 +1591,7 @@ static void bnx2x_self_test(struct net_device *dev,
 			    struct ethtool_test *etest, u64 *buf)
 {
 	struct bnx2x *bp = netdev_priv(dev);
-
+	u8 is_serdes;
 	if (bp->recovery_state != BNX2X_RECOVERY_DONE) {
 		printk(KERN_ERR "Handling parity error recovery. Try again later\n");
 		etest->flags |= ETH_TEST_FL_FAILED;
@@ -1542,6 +1606,7 @@ static void bnx2x_self_test(struct net_device *dev,
 	/* offline tests are not supported in MF mode */
 	if (IS_E1HMF(bp))
 		etest->flags &= ~ETH_TEST_FL_OFFLINE;
+	is_serdes = (bp->link_vars.link_status & LINK_STATUS_SERDES_LINK) > 0;
 
 	if (etest->flags & ETH_TEST_FL_OFFLINE) {
 		int port = BP_PORT(bp);
@@ -1553,11 +1618,12 @@ static void bnx2x_self_test(struct net_device *dev,
 		/* disable input for TX port IF */
 		REG_WR(bp, NIG_REG_EGRESS_UMP0_IN_EN + port*4, 0);
 
-		link_up = (bnx2x_link_test(bp) == 0);
+		link_up = bp->link_vars.link_up;
+
 		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
 		bnx2x_nic_load(bp, LOAD_DIAG);
 		/* wait until link state is restored */
-		bnx2x_wait_for_link(bp, link_up);
+		bnx2x_wait_for_link(bp, link_up, is_serdes);
 
 		if (bnx2x_test_registers(bp) != 0) {
 			buf[0] = 1;
@@ -1578,7 +1644,7 @@ static void bnx2x_self_test(struct net_device *dev,
 
 		bnx2x_nic_load(bp, LOAD_NORMAL);
 		/* wait until link state is restored */
-		bnx2x_wait_for_link(bp, link_up);
+		bnx2x_wait_for_link(bp, link_up, is_serdes);
 	}
 	if (bnx2x_test_nvram(bp) != 0) {
 		buf[3] = 1;
@@ -1589,7 +1655,7 @@ static void bnx2x_self_test(struct net_device *dev,
 		etest->flags |= ETH_TEST_FL_FAILED;
 	}
 	if (bp->port.pmf)
-		if (bnx2x_link_test(bp) != 0) {
+		if (bnx2x_link_test(bp, is_serdes) != 0) {
 			buf[5] = 1;
 			etest->flags |= ETH_TEST_FL_FAILED;
 		}
diff --git a/drivers/net/bnx2x/bnx2x_hsi.h b/drivers/net/bnx2x/bnx2x_hsi.h
index f494bc3..bab3b2d 100644
--- a/drivers/net/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/bnx2x/bnx2x_hsi.h
@@ -238,7 +238,88 @@ struct port_hw_cfg {			    /* port 0: 0x12c  port 1: 0x2bc */
 
 	u16 xgxs_config_tx[4];				    /* 0x1A0 */
 
-	u32 Reserved1[64];				    /* 0x1A8 */
+	u32 Reserved1[57];				    /* 0x1A8 */
+	u32 speed_capability_mask2;			    /* 0x28C */
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D3_MASK		      0x0000FFFF
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D3_SHIFT		      0
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D3_10M_FULL	      0x00000001
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D3__		      0x00000002
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D3___		      0x00000004
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D3_100M_FULL	      0x00000008
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D3_1G		      0x00000010
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D3_2_DOT_5G	      0x00000020
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D3_10G		      0x00000040
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D3_12G		      0x00000080
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D3_12_DOT_5G	      0x00000100
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D3_13G		      0x00000200
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D3_15G		      0x00000400
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D3_16G		      0x00000800
+
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D0_MASK		      0xFFFF0000
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D0_SHIFT		      16
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D0_10M_FULL	      0x00010000
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D0__		      0x00020000
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D0___		      0x00040000
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D0_100M_FULL	      0x00080000
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D0_1G		      0x00100000
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D0_2_DOT_5G	      0x00200000
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D0_10G		      0x00400000
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D0_12G		      0x00800000
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D0_12_DOT_5G	      0x01000000
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D0_13G		      0x02000000
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D0_15G		      0x04000000
+#define PORT_HW_CFG_SPEED_CAPABILITY2_D0_16G		      0x08000000
+
+	/* In the case where two media types (e.g. copper and fiber) are
+	  present and electrically active at the same time, PHY Selection
+	  will determine which of the two PHYs will be designated as the
+	  Active PHY and used for a connection to the network.	*/
+	u32 multi_phy_config;				/* 0x290 */
+#define PORT_HW_CFG_PHY_SELECTION_MASK		     0x00000007
+#define PORT_HW_CFG_PHY_SELECTION_SHIFT		     0
+#define PORT_HW_CFG_PHY_SELECTION_HARDWARE_DEFAULT   0x00000000
+#define PORT_HW_CFG_PHY_SELECTION_FIRST_PHY	     0x00000001
+#define PORT_HW_CFG_PHY_SELECTION_SECOND_PHY	     0x00000002
+#define PORT_HW_CFG_PHY_SELECTION_FIRST_PHY_PRIORITY 0x00000003
+#define PORT_HW_CFG_PHY_SELECTION_SECOND_PHY_PRIORITY 0x00000004
+
+	/* When enabled, all second phy nvram parameters will be swapped
+	  with the first phy parameters */
+#define PORT_HW_CFG_PHY_SWAPPED_MASK		     0x00000008
+#define PORT_HW_CFG_PHY_SWAPPED_SHIFT		     3
+#define PORT_HW_CFG_PHY_SWAPPED_DISABLED	     0x00000000
+#define PORT_HW_CFG_PHY_SWAPPED_ENABLED		     0x00000008
+
+
+	/* Address of the second external phy */
+	u32 external_phy_config2;				/* 0x294 */
+#define PORT_HW_CFG_XGXS_EXT_PHY2_ADDR_MASK	    0x000000FF
+#define PORT_HW_CFG_XGXS_EXT_PHY2_ADDR_SHIFT	    0
+
+	/* The second XGXS external PHY type */
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_MASK	    0x0000FF00
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_SHIFT	    8
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_DIRECT	    0x00000000
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM8071	    0x00000100
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM8072	    0x00000200
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM8073	    0x00000300
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM8705	    0x00000400
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM8706	    0x00000500
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM8726	    0x00000600
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM8481	    0x00000700
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_SFX7101	    0x00000800
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM8727	    0x00000900
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM8727_NOC  0x00000a00
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM84823     0x00000b00
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM54640     0x00000c00
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_BCM84833     0x00000d00
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_FAILURE	    0x0000fd00
+#define PORT_HW_CFG_XGXS_EXT_PHY2_TYPE_NOT_CONN     0x0000ff00
+
+	/* 4 times 16 bits for all 4 lanes. For some external PHYs (such as
+	  8706, 8726 and 8727) not all 4 values are needed. */
+	u16 xgxs_config2_rx[4];				/* 0x296 */
+	u16 xgxs_config2_tx[4];				/* 0x2A0 */
 
 	u32 lane_config;
 #define PORT_HW_CFG_LANE_SWAP_CFG_MASK		    0x0000ffff
@@ -532,10 +613,17 @@ struct port_feat_cfg {			    /* port 0: 0x454  port 1: 0x4c8 */
 #define PORT_FEATURE_FLOW_CONTROL_NONE		    0x00000400
 
 	/* The default for MCP link configuration,
-	   uses the same defines as link_config */
+	uses the same defines as link_config */
 	u32 mfw_wol_link_cfg;
+	/* The default for the driver of the second external phy,
+	uses the same defines as link_config */
+	u32 link_config2;					/* 0x47C */
 
-	u32 reserved[19];
+	/* The default for MCP of the second external phy,
+	uses the same defines as link_config */
+	u32 mfw_wol_link_cfg2;				/* 0x480 */
+
+	u32 Reserved2[17];					/* 0x484 */
 
 };
 
@@ -703,8 +791,14 @@ struct drv_func_mb {
 	 * The optic module verification commands require bootcode
 	 * v5.0.6 or later
 	 */
-#define DRV_MSG_CODE_VRFY_OPT_MDL			0xa0000000
-#define REQ_BC_VER_4_VRFY_OPT_MDL			0x00050006
+#define DRV_MSG_CODE_VRFY_FIRST_PHY_OPT_MDL	0xa0000000
+#define REQ_BC_VER_4_VRFY_FIRST_PHY_OPT_MDL	0x00050006
+	/*
+	 * The specific optic module verification command requires bootcode
+	 * v5.2.12 or later
+	 */
+#define DRV_MSG_CODE_VRFY_SPECIFIC_PHY_OPT_MDL	    0xa1000000
+#define REQ_BC_VER_4_VRFY_SPECIFIC_PHY_OPT_MDL	    0x00050234
 
 #define BIOS_MSG_CODE_LIC_CHALLENGE			0xff010000
 #define BIOS_MSG_CODE_LIC_RESPONSE			0xff020000
@@ -939,7 +1033,12 @@ struct shmem2_region {
 #define SHMEM_DCC_SUPPORT_SET_PROTOCOL_TLV	    0x00000040
 #define SHMEM_DCC_SUPPORT_SET_PRIORITY_TLV	    0x00000080
 #define SHMEM_DCC_SUPPORT_DEFAULT		    SHMEM_DCC_SUPPORT_NONE
-
+	u32 ext_phy_fw_version2[PORT_MAX];
+	/*
+	 * For backwards compatibility, if the mf_cfg_addr does not exist
+	 * (the size filed is smaller than 0xc) the mf_cfg resides at the
+	 * end of struct shmem_region
+	 */
 };
 

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index 5ff8268..f095dbb 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -899,6 +899,7 @@ static void bnx2x_xgxs_deassert(struct link_params *params)
 		     params->phy[INT_PHY].def_md_devad);
 }
 
+
 void bnx2x_link_status_update(struct link_params *params,
 			    struct link_vars   *vars)
 {
@@ -906,10 +907,6 @@ void bnx2x_link_status_update(struct link_params *params,
 	u8 link_10g;
 	u8 port = params->port;
 
-	if (params->switch_cfg ==  SWITCH_CFG_1G)
-		vars->phy_flags = PHY_SERDES_FLAG;
-	else
-		vars->phy_flags = PHY_XGXS_FLAG;
 	vars->link_status = REG_RD(bp, params->shmem_base +
 					  offsetof(struct shmem_region,
 					   port_mb[port].link_status));
@@ -1880,12 +1877,8 @@ static u8 bnx2x_link_settings_status(struct bnx2x_phy *phy,
 
 	DP(NETIF_MSG_LINK, "gp_status 0x%x  phy_link_up %x line_speed %x\n",
 		 gp_status, vars->phy_link_up, vars->line_speed);
-	DP(NETIF_MSG_LINK, "duplex %x  flow_ctrl 0x%x"
-		 " autoneg 0x%x\n",
-		 vars->duplex,
-		 vars->flow_ctrl, vars->autoneg);
-	DP(NETIF_MSG_LINK, "link_status 0x%x\n", vars->link_status);
-
+	DP(NETIF_MSG_LINK, "duplex %x  flow_ctrl 0x%x link_status 0x%x\n",
+		   vars->duplex, vars->flow_ctrl, vars->link_status);
 	return rc;
 }
 
@@ -2164,45 +2157,43 @@ static void bnx2x_link_int_enable(struct link_params *params)
 	   REG_RD(bp, NIG_REG_XGXS0_STATUS_LINK_STATUS + port*0x68));
 }
 
-static void bnx2x_8481_rearm_latch_signal(struct bnx2x *bp, u8 port,
-					  u8 is_mi_int)
+static void bnx2x_rearm_latch_signal(struct bnx2x *bp, u8 port,
+				     u8 exp_mi_int)
 {
-	u32 latch_status = 0, is_mi_int_status;
-	/* Disable the MI INT ( external phy int )
-	 * by writing 1 to the status register. Link down indication
-	 * is high-active-signal, so in this case we need to write the
-	 * status to clear the XOR
+	u32 latch_status = 0;
+
+	/**
+	 * Disable the MI INT ( external phy int ) by writing 1 to the
+	 * status register. Link down indication is high-active-signal,
+	 * so in this case we need to write the status to clear the XOR
 	 */
 	/* Read Latched signals */
 	latch_status = REG_RD(bp,
-				  NIG_REG_LATCH_STATUS_0 + port*8);
-	is_mi_int_status = REG_RD(bp,
-				  NIG_REG_STATUS_INTERRUPT_PORT0 + port*4);
-	DP(NETIF_MSG_LINK, "original_signal = 0x%x, nig_status = 0x%x,"
-		     "latch_status = 0x%x\n",
-		 is_mi_int, is_mi_int_status, latch_status);
+				    NIG_REG_LATCH_STATUS_0 + port*8);
+	DP(NETIF_MSG_LINK, "latch_status = 0x%x\n", latch_status);
 	/* Handle only those with latched-signal=up.*/
+	if (exp_mi_int)
+		bnx2x_bits_en(bp,
+			      NIG_REG_STATUS_INTERRUPT_PORT0
+			      + port*4,
+			      NIG_STATUS_EMAC0_MI_INT);
+	else
+		bnx2x_bits_dis(bp,
+			       NIG_REG_STATUS_INTERRUPT_PORT0
+			       + port*4,
+			       NIG_STATUS_EMAC0_MI_INT);
+
 	if (latch_status & 1) {
-		/* For all latched-signal=up,Write original_signal to status */
-		if (is_mi_int)
-			bnx2x_bits_en(bp,
-				    NIG_REG_STATUS_INTERRUPT_PORT0
-				    + port*4,
-				    NIG_STATUS_EMAC0_MI_INT);
-		else
-			bnx2x_bits_dis(bp,
-				     NIG_REG_STATUS_INTERRUPT_PORT0
-				     + port*4,
-				     NIG_STATUS_EMAC0_MI_INT);
+
 		/* For all latched-signal=up : Re-Arm Latch signals */
 		REG_WR(bp, NIG_REG_LATCH_STATUS_0 + port*8,
 			   (latch_status & 0xfffe) | (latch_status & 1));
 	}
+	/* For all latched-signal=up,Write original_signal to status */
 }
 
 static void bnx2x_link_int_ack(struct link_params *params,
-			     struct link_vars *vars, u8 is_10g,
-			     u8 is_mi_int)
+			     struct link_vars *vars, u8 is_10g)
 {
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
@@ -2213,12 +2204,6 @@ static void bnx2x_link_int_ack(struct link_params *params,
 		     (NIG_STATUS_XGXS0_LINK10G |
 		      NIG_STATUS_XGXS0_LINK_STATUS |
 		      NIG_STATUS_SERDES0_LINK_STATUS));
-	if ((params->phy[EXT_PHY1].type
-		== PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481) ||
-	(params->phy[EXT_PHY1].type
-		== PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823)) {
-		bnx2x_8481_rearm_latch_signal(bp, port, is_mi_int);
-	}
 	if (vars->phy_link_up) {
 		if (is_10g) {
 			/* Disable the 10G link interrupt
@@ -2264,30 +2249,39 @@ static u8 bnx2x_format_ver(u32 num, u8 *str, u16 *len)
 	u32 mask = 0xf0000000;
 	u8 shift = 8*4;
 	u8 digit;
+	u8 remove_leading_zeros = 1;
 	if (*len < 10) {
 		/* Need more than 10chars for this format */
 		*str_ptr = '\0';
+		(*len)--;
 		return -EINVAL;
 	}
 	while (shift > 0) {
 
 		shift -= 4;
 		digit = ((num & mask) >> shift);
-		if (digit < 0xa)
+		if (digit == 0 && remove_leading_zeros) {
+			mask = mask >> 4;
+			continue;
+		} else if (digit < 0xa)
 			*str_ptr = digit + '0';
 		else
 			*str_ptr = digit - 0xa + 'a';
+		remove_leading_zeros = 0;
 		str_ptr++;
+		(*len)--;
 		mask = mask >> 4;
 		if (shift == 4*4) {
-			*str_ptr = ':';
+			*str_ptr = '.';
 			str_ptr++;
+			(*len)--;
+			remove_leading_zeros = 1;
 		}
 	}
-	*str_ptr = '\0';
 	return 0;
 }
 
+
 static u8 bnx2x_null_format_ver(u32 spirom_ver, u8 *str, u16 *len)
 {
 	str[0] = '\0';
@@ -2302,6 +2296,7 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 	u32 spirom_ver = 0;
 	u8 status = 0;
 	u8 *ver_p = version;
+	u16 remain_len = len;
 	if (version == NULL || params == NULL)
 		return -EINVAL;
 	bp = params->bp;
@@ -2310,10 +2305,28 @@ u8 bnx2x_get_ext_phy_fw_version(struct link_params *params, u8 driver_loaded,
 	version[0] = '\0';
 	spirom_ver = REG_RD(bp, params->phy[EXT_PHY1].ver_addr);
 
-	if (params->phy[EXT_PHY1].format_fw_ver)
+	if (params->phy[EXT_PHY1].format_fw_ver) {
 		status |= params->phy[EXT_PHY1].format_fw_ver(spirom_ver,
 							      ver_p,
-							      &len);
+							      &remain_len);
+		ver_p += (len - remain_len);
+	}
+	if ((params->num_phys == MAX_PHYS) &&
+	    (params->phy[EXT_PHY2].ver_addr != 0)) {
+		spirom_ver = REG_RD(bp,
+					  params->phy[EXT_PHY2].ver_addr);
+		if (params->phy[EXT_PHY2].format_fw_ver) {
+			*ver_p = '/';
+			ver_p++;
+			remain_len--;
+			status |= params->phy[EXT_PHY2].format_fw_ver(
+				spirom_ver,
+				ver_p,
+				&remain_len);
+			ver_p = version + (len - remain_len);
+		}
+	}
+	*ver_p = '\0';
 	return status;
 }
 
@@ -2550,30 +2563,56 @@ u8 bnx2x_set_led(struct link_params *params, u8 mode, u32 speed)
 
 }
 
-u8 bnx2x_test_link(struct link_params *params, struct link_vars *vars)
+/**
+ * This function comes to reflect the actual link state read DIRECTLY from the
+ * HW
+ */
+u8 bnx2x_test_link(struct link_params *params, struct link_vars *vars,
+		   u8 is_serdes)
 {
 	struct bnx2x *bp = params->bp;
 	u16 gp_status = 0, phy_index = 0;
+	u8 ext_phy_link_up = 0, serdes_phy_type;
+	struct link_vars temp_vars;
 
 	CL45_RD_OVER_CL22(bp, &params->phy[INT_PHY],
 			      MDIO_REG_BANK_GP_STATUS,
 			      MDIO_GP_STATUS_TOP_AN_STATUS1,
 			      &gp_status);
 	/* link is up only if both local phy and external phy are up */
-	if (gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS) {
-		u8 ext_phy_link_up = 1;
-		struct link_vars temp_vars;
+	if (!(gp_status & MDIO_GP_STATUS_TOP_AN_STATUS1_LINK_STATUS))
+		return -ESRCH;
+
+	switch (params->num_phys) {
+	case 1:
+		/* No external PHY */
+		return 0;
+	case 2:
+		ext_phy_link_up = params->phy[EXT_PHY1].read_status(
+			&params->phy[EXT_PHY1],
+			params, &temp_vars);
+		break;
+	case 3: /* Dual Media */
 		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
 		      phy_index++) {
-			if (params->phy[phy_index].read_status)
-				ext_phy_link_up &=
+			serdes_phy_type = ((params->phy[phy_index].media_type ==
+					    ETH_PHY_SFP_FIBER) ||
+					   (params->phy[phy_index].media_type ==
+					    ETH_PHY_XFP_FIBER));
+
+			if (is_serdes != serdes_phy_type)
+				continue;
+			if (params->phy[phy_index].read_status) {
+				ext_phy_link_up |=
 					params->phy[phy_index].read_status(
 						&params->phy[phy_index],
 						params, &temp_vars);
+			}
 		}
-		if (ext_phy_link_up)
-			return 0;
+		break;
 	}
+	if (ext_phy_link_up)
+		return 0;
 	return -ESRCH;
 }
 
@@ -2619,6 +2658,19 @@ static u8 bnx2x_link_initialize(struct link_params *params,
 	if (!non_ext_phy)
 		for (phy_index = EXT_PHY1; phy_index < params->num_phys;
 		      phy_index++) {
+			/**
+			 * No need to initialize second phy in case of first
+			 * phy only selection. In case of second phy, we do
+			 * need to initialize the first phy, since they are
+			 * connected.
+			 **/
+			if (phy_index == EXT_PHY2 &&
+			    (bnx2x_phy_selection(params) ==
+			     PORT_HW_CFG_PHY_SELECTION_FIRST_PHY)) {
+				DP(NETIF_MSG_LINK, "Not initializing"
+						   "second phy\n");
+				continue;
+			}
 			params->phy[phy_index].config_init(
 				&params->phy[phy_index],
 				params, vars);
@@ -2816,6 +2868,40 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 		if (!ext_phy_link_up) {
 			ext_phy_link_up = 1;
 			active_external_phy = phy_index;
+		} else {
+			switch (bnx2x_phy_selection(params)) {
+			case PORT_HW_CFG_PHY_SELECTION_HARDWARE_DEFAULT:
+			case PORT_HW_CFG_PHY_SELECTION_FIRST_PHY_PRIORITY:
+			/**
+			 * In this option, the first PHY makes sure to pass the
+			 * traffic through itself only.
+			 * Its not clear how to reset the link on the second phy
+			 **/
+				active_external_phy = EXT_PHY1;
+				break;
+			case PORT_HW_CFG_PHY_SELECTION_SECOND_PHY_PRIORITY:
+			/**
+			 * In this option, the first PHY makes sure to pass the
+			 * traffic through the second PHY.
+			 **/
+				active_external_phy = EXT_PHY2;
+				break;
+			default:
+			/**
+			 * Link indication on both PHYs with the following cases
+			 * is invalid:
+			 * - FIRST_PHY means that second phy wasn't initialized,
+			 * hence its link is expected to be down
+			 * - SECOND_PHY means that first phy should not be able
+			 * to link up by itself (using configuration)
+			 * - DEFAULT should be overriden during initialiazation
+			 **/
+				DP(NETIF_MSG_LINK, "Invalid link indication"
+					   "mpc=0x%x. DISABLING LINK !!!\n",
+					   params->multi_phy_config);
+				ext_phy_link_up = 0;
+				break;
+			}
 		}
 	}
 	prev_line_speed = vars->line_speed;
@@ -2845,6 +2931,21 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 		 * the external phy.
 		 */
 		vars->link_status |= phy_vars[active_external_phy].link_status;
+
+		/**
+		 * if active_external_phy is first PHY and link is up - disable
+		 * disable TX on second external PHY
+		 */
+		if (active_external_phy == EXT_PHY1) {
+			if (params->phy[EXT_PHY2].phy_specific_func) {
+				DP(NETIF_MSG_LINK, "Disabling TX on"
+						   " EXT_PHY2\n");
+				params->phy[EXT_PHY2].phy_specific_func(
+					&params->phy[EXT_PHY2],
+					params, DISABLE_TX);
+			}
+		}
+
 		ext_phy_line_speed = phy_vars[active_external_phy].line_speed;
 		vars->duplex = phy_vars[active_external_phy].duplex;
 		if (params->phy[active_external_phy].supported &
@@ -2853,6 +2954,17 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 		DP(NETIF_MSG_LINK, "Active external phy selected: %x\n",
 			   active_external_phy);
 	}
+
+	for (phy_index = EXT_PHY1; phy_index < params->num_phys;
+	      phy_index++) {
+		if (params->phy[phy_index].flags &
+		    FLAGS_REARM_LATCH_SIGNAL) {
+			bnx2x_rearm_latch_signal(bp, port,
+						 phy_index ==
+						 active_external_phy);
+			break;
+		}
+	}
 	DP(NETIF_MSG_LINK, "vars->flow_ctrl = 0x%x, vars->link_status = 0x%x,"
 		   " ext_phy_line_speed = %d\n", vars->flow_ctrl,
 		   vars->link_status, ext_phy_line_speed);
@@ -2885,7 +2997,7 @@ u8 bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 		    (vars->line_speed == SPEED_15000) ||
 		    (vars->line_speed == SPEED_16000));
 
-	bnx2x_link_int_ack(params, vars, link_10g, is_mi_int);
+	bnx2x_link_int_ack(params, vars, link_10g);
 
 	/**
 	* In case external phy link is up, and internal link is down
@@ -3898,11 +4010,11 @@ static u8 bnx2x_verify_sfp_module(struct bnx2x_phy *phy,
 				  struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
-	u32 val;
-	u32 fw_resp;
+	u32 val, cmd;
+	u32 fw_resp, fw_cmd_param;
 	char vendor_name[SFP_EEPROM_VENDOR_NAME_SIZE+1];
 	char vendor_pn[SFP_EEPROM_PART_NO_SIZE+1];
-
+	phy->flags &= ~FLAGS_SFP_NOT_APPROVED;
 	val = REG_RD(bp, params->shmem_base +
 			 offsetof(struct shmem_region, dev_info.
 				  port_feature_config[params->port].config));
@@ -3912,15 +4024,27 @@ static u8 bnx2x_verify_sfp_module(struct bnx2x_phy *phy,
 		return 0;
 	}
 
-	/* Ask the FW to validate the module */
-	if (!(params->feature_config_flags &
-	      FEATURE_CONFIG_BC_SUPPORTS_OPT_MDL_VRFY)) {
+	if (params->feature_config_flags &
+	    FEATURE_CONFIG_BC_SUPPORTS_DUAL_PHY_OPT_MDL_VRFY) {
+		/* Use specific phy request */
+		cmd = DRV_MSG_CODE_VRFY_SPECIFIC_PHY_OPT_MDL;
+	} else if (params->feature_config_flags &
+		   FEATURE_CONFIG_BC_SUPPORTS_OPT_MDL_VRFY) {
+		/* Use first phy request only in case of non-dual media*/
+		if (DUAL_MEDIA(params)) {
+			DP(NETIF_MSG_LINK, "FW does not support OPT MDL "
+			   "verification\n");
+			return -EINVAL;
+		}
+		cmd = DRV_MSG_CODE_VRFY_FIRST_PHY_OPT_MDL;
+	} else {
+		/* No support in OPT MDL detection */
 		DP(NETIF_MSG_LINK, "FW does not support OPT MDL "
-			    "verification\n");
+			  "verification\n");
 		return -EINVAL;
 	}
-
-	fw_resp = bnx2x_fw_command(bp, DRV_MSG_CODE_VRFY_OPT_MDL);
+	fw_cmd_param = FW_PARAM_SET(phy->addr, phy->type, phy->mdio_ctrl);
+	fw_resp = bnx2x_fw_command(bp, cmd, fw_cmd_param);
 	if (fw_resp == FW_MSG_CODE_VRFY_OPT_MDL_SUCCESS) {
 		DP(NETIF_MSG_LINK, "Approved module\n");
 		return 0;
@@ -3947,6 +4071,7 @@ static u8 bnx2x_verify_sfp_module(struct bnx2x_phy *phy,
 	netdev_info(bp->dev, "Warning: Unqualified SFP+ module detected,"
 			     " Port %d from %s part number %s\n",
 		    params->port, vendor_name, vendor_pn);
+	phy->flags |= FLAGS_SFP_NOT_APPROVED;
 	return -EINVAL;
 }
 
@@ -4092,6 +4217,27 @@ static u8 bnx2x_8727_set_limiting_mode(struct bnx2x *bp,
 	return 0;
 }
 
+static void bnx2x_8727_specific_func(struct bnx2x_phy *phy,
+				     struct link_params *params,
+				     u32 action)
+{
+	struct bnx2x *bp = params->bp;
+
+	switch (action) {
+	case DISABLE_TX:
+		bnx2x_sfp_set_transmitter(bp, phy, params->port, 0);
+		break;
+	case ENABLE_TX:
+		if (!(phy->flags & FLAGS_SFP_NOT_APPROVED))
+			bnx2x_sfp_set_transmitter(bp, phy, params->port, 1);
+		break;
+	default:
+		DP(NETIF_MSG_LINK, "Function 0x%x not supported by 8727\n",
+		   action);
+		return;
+	}
+}
+
 static u8 bnx2x_sfp_module_detection(struct bnx2x_phy *phy,
 				     struct link_params *params)
 {
@@ -4625,6 +4771,19 @@ static u8 bnx2x_8727_config_init(struct bnx2x_phy *phy,
 		bnx2x_cl45_read(bp, phy,
 				MDIO_PMA_DEVAD, MDIO_PMA_REG_10G_CTRL2, &tmp1);
 		DP(NETIF_MSG_LINK, "1.7 = 0x%x\n", tmp1);
+		/**
+		 * Power down the XAUI until link is up in case of dual-media
+		 * and 1G
+		 */
+		if (DUAL_MEDIA(params)) {
+			bnx2x_cl45_read(bp, phy,
+					MDIO_PMA_DEVAD,
+					MDIO_PMA_REG_8727_PCS_GP, &val);
+			val |= (3<<10);
+			bnx2x_cl45_write(bp, phy,
+					 MDIO_PMA_DEVAD,
+					 MDIO_PMA_REG_8727_PCS_GP, val);
+		}
 	} else if ((phy->req_line_speed == SPEED_AUTO_NEG) &&
 		   ((phy->speed_cap_mask &
 		     PORT_HW_CFG_SPEED_CAPABILITY_D0_1G)) &&
@@ -4766,7 +4925,15 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u8 link_up = 0;
 	u16 link_status = 0;
-	u16 rx_alarm_status, val1;
+	u16 rx_alarm_status, lasi_ctrl, val1;
+
+	/* If PHY is not initialized, do not check link status */
+	bnx2x_cl45_read(bp, phy,
+			MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL,
+			&lasi_ctrl);
+	if (!lasi_ctrl)
+		return 0;
+
 	/* Check the LASI */
 	bnx2x_cl45_read(bp, phy,
 			MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM,
@@ -4837,7 +5004,8 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 				 MDIO_PMA_DEVAD, MDIO_PMA_REG_RX_ALARM_CTRL,
 				 ((1<<5) | (1<<2)));
 	}
-
+	DP(NETIF_MSG_LINK, "Enabling 8727 TX laser if SFP is approved\n");
+	bnx2x_8727_specific_func(phy, params, ENABLE_TX);
 	/* If transmitter is disabled, ignore false link up indication */
 	bnx2x_cl45_read(bp, phy,
 			MDIO_PMA_DEVAD, MDIO_PMA_REG_PHY_IDENTIFIER, &val1);
@@ -4867,6 +5035,24 @@ static u8 bnx2x_8727_read_status(struct bnx2x_phy *phy,
 	}
 	if (link_up)
 		bnx2x_ext_phy_resolve_fc(phy, params, vars);
+
+	if ((DUAL_MEDIA(params)) &&
+	    (phy->req_line_speed == SPEED_1000)) {
+		bnx2x_cl45_read(bp, phy,
+				MDIO_PMA_DEVAD,
+				MDIO_PMA_REG_8727_PCS_GP, &val1);
+		/**
+		 * In case of dual-media board and 1G, power up the XAUI side,
+		 * otherwise power it down. For 10G it is done automatically
+		 */
+		if (link_up)
+			val1 &= ~(3<<10);
+		else
+			val1 |= (3<<10);
+		bnx2x_cl45_write(bp, phy,
+				 MDIO_PMA_DEVAD,
+				 MDIO_PMA_REG_8727_PCS_GP, val1);
+	}
 	return link_up;
 }
 
@@ -4876,6 +5062,9 @@ static void bnx2x_8727_link_reset(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	/* Disable Transmitter */
 	bnx2x_sfp_set_transmitter(bp, phy, params->port, 0);
+	/* Clear LASI */
+	bnx2x_cl45_write(bp, phy, MDIO_PMA_DEVAD, MDIO_PMA_REG_LASI_CTRL, 0);
+
 }
 
 /******************************************************************/
@@ -4973,16 +5162,11 @@ static void bnx2x_848xx_set_led(struct bnx2x *bp,
 }
 
 static u8 bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
-				       struct link_params *params,
-				       struct link_vars *vars)
+				      struct link_params *params,
+				      struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
 	u16 autoneg_val, an_1000_val, an_10_100_val;
-	/**
-	* This phy uses the NIG latch mechanism since link indication
-	* arrives through its LED4 and not via its LASI signal, so we
-	* get steady signal instead of clear on read
-	*/
 	bnx2x_wait_reset_complete(bp, phy);
 	bnx2x_bits_en(bp, NIG_REG_LATCH_BC_0 + params->port*4,
 		      1 << NIG_LATCH_BC_ENABLE_MI_INT);
@@ -5122,7 +5306,11 @@ static u8 bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 				  struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
+	u8 initialize = 1;
+	u16 val;
 	u16 temp;
+	u32 actual_phy_selection;
+	u8 rc = 0;
 	msleep(1);
 	bnx2x_set_gpio(bp, MISC_REGISTERS_GPIO_3,
 		       MISC_REGISTERS_GPIO_OUTPUT_HIGH,
@@ -5135,10 +5323,55 @@ static u8 bnx2x_848x3_config_init(struct bnx2x_phy *phy,
 	 */
 	temp = vars->line_speed;
 	vars->line_speed = SPEED_10000;
-	bnx2x_set_autoneg(phy, params, vars, 0);
-	bnx2x_program_serdes(phy, params, vars);
+	bnx2x_set_autoneg(&params->phy[INT_PHY], params, vars, 0);
+	bnx2x_program_serdes(&params->phy[INT_PHY], params, vars);
 	vars->line_speed = temp;
-	return bnx2x_848xx_cmn_config_init(phy, params, vars);
+
+	/* Set dual-media configuration according to configuration */
+
+	bnx2x_cl45_read(bp, phy, MDIO_CTL_DEVAD,
+			MDIO_CTL_REG_84823_MEDIA, &val);
+	val &= ~(MDIO_CTL_REG_84823_MEDIA_MAC_MASK |
+		 MDIO_CTL_REG_84823_MEDIA_LINE_MASK |
+		 MDIO_CTL_REG_84823_MEDIA_COPPER_CORE_DOWN |
+		 MDIO_CTL_REG_84823_MEDIA_PRIORITY_MASK |
+		 MDIO_CTL_REG_84823_MEDIA_FIBER_1G);
+	val |= MDIO_CTL_REG_84823_CTRL_MAC_XFI |
+		MDIO_CTL_REG_84823_MEDIA_LINE_XAUI_L;
+
+	actual_phy_selection = bnx2x_phy_selection(params);
+
+	switch (actual_phy_selection) {
+	case PORT_HW_CFG_PHY_SELECTION_HARDWARE_DEFAULT:
+		/* Do nothing. Essentialy this is like the priority copper */
+		break;
+	case PORT_HW_CFG_PHY_SELECTION_FIRST_PHY_PRIORITY:
+		val |= MDIO_CTL_REG_84823_MEDIA_PRIORITY_COPPER;
+		break;
+	case PORT_HW_CFG_PHY_SELECTION_SECOND_PHY_PRIORITY:
+		val |= MDIO_CTL_REG_84823_MEDIA_PRIORITY_FIBER;
+		break;
+	case PORT_HW_CFG_PHY_SELECTION_FIRST_PHY:
+		/* Do nothing here. The first PHY won't be initialized at all */
+		break;
+	case PORT_HW_CFG_PHY_SELECTION_SECOND_PHY:
+		val |= MDIO_CTL_REG_84823_MEDIA_COPPER_CORE_DOWN;
+		initialize = 0;
+		break;
+	}
+	if (params->phy[EXT_PHY2].req_line_speed == SPEED_1000)
+		val |= MDIO_CTL_REG_84823_MEDIA_FIBER_1G;
+
+	bnx2x_cl45_write(bp, phy, MDIO_CTL_DEVAD,
+			 MDIO_CTL_REG_84823_MEDIA, val);
+	DP(NETIF_MSG_LINK, "Multi_phy config = 0x%x, Media control = 0x%x\n",
+		   params->multi_phy_config, val);
+
+	if (initialize)
+		rc = bnx2x_848xx_cmn_config_init(phy, params, vars);
+	else
+		bnx2x_save_848xx_spirom_version(phy, params);
+	return rc;
 }
 
 static u8 bnx2x_848xx_read_status(struct bnx2x_phy *phy,
@@ -5426,7 +5659,8 @@ static struct bnx2x_phy phy_null = {
 	.config_loopback = (config_loopback_t)NULL,
 	.format_fw_ver	= (format_fw_ver_t)NULL,
 	.hw_reset	= (hw_reset_t)NULL,
-	.set_link_led	= (set_link_led_t)NULL
+	.set_link_led	= (set_link_led_t)NULL,
+	.phy_specific_func = (phy_specific_func_t)NULL
 };
 
 static struct bnx2x_phy phy_serdes = {
@@ -5461,7 +5695,8 @@ static struct bnx2x_phy phy_serdes = {
 	.config_loopback = (config_loopback_t)NULL,
 	.format_fw_ver	= (format_fw_ver_t)NULL,
 	.hw_reset	= (hw_reset_t)NULL,
-	.set_link_led	= (set_link_led_t)NULL
+	.set_link_led	= (set_link_led_t)NULL,
+	.phy_specific_func = (phy_specific_func_t)NULL
 };
 
 static struct bnx2x_phy phy_xgxs = {
@@ -5497,7 +5732,8 @@ static struct bnx2x_phy phy_xgxs = {
 	.config_loopback = (config_loopback_t)bnx2x_set_xgxs_loopback,
 	.format_fw_ver	= (format_fw_ver_t)NULL,
 	.hw_reset	= (hw_reset_t)NULL,
-	.set_link_led	= (set_link_led_t)NULL
+	.set_link_led	= (set_link_led_t)NULL,
+	.phy_specific_func = (phy_specific_func_t)NULL
 };
 
 static struct bnx2x_phy phy_7101 = {
@@ -5527,7 +5763,8 @@ static struct bnx2x_phy phy_7101 = {
 	.config_loopback = (config_loopback_t)bnx2x_7101_config_loopback,
 	.format_fw_ver	= (format_fw_ver_t)bnx2x_7101_format_ver,
 	.hw_reset	= (hw_reset_t)bnx2x_7101_hw_reset,
-	.set_link_led	= (set_link_led_t)NULL
+	.set_link_led	= (set_link_led_t)NULL,
+	.phy_specific_func = (phy_specific_func_t)NULL
 };
 static struct bnx2x_phy phy_8073 = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073,
@@ -5558,7 +5795,8 @@ static struct bnx2x_phy phy_8073 = {
 	.config_loopback = (config_loopback_t)NULL,
 	.format_fw_ver	= (format_fw_ver_t)bnx2x_format_ver,
 	.hw_reset	= (hw_reset_t)NULL,
-	.set_link_led	= (set_link_led_t)NULL
+	.set_link_led	= (set_link_led_t)NULL,
+	.phy_specific_func = (phy_specific_func_t)NULL
 };
 static struct bnx2x_phy phy_8705 = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8705,
@@ -5586,7 +5824,8 @@ static struct bnx2x_phy phy_8705 = {
 	.config_loopback = (config_loopback_t)NULL,
 	.format_fw_ver	= (format_fw_ver_t)bnx2x_null_format_ver,
 	.hw_reset	= (hw_reset_t)NULL,
-	.set_link_led	= (set_link_led_t)NULL
+	.set_link_led	= (set_link_led_t)NULL,
+	.phy_specific_func = (phy_specific_func_t)NULL
 };
 static struct bnx2x_phy phy_8706 = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8706,
@@ -5615,7 +5854,8 @@ static struct bnx2x_phy phy_8706 = {
 	.config_loopback = (config_loopback_t)NULL,
 	.format_fw_ver	= (format_fw_ver_t)bnx2x_format_ver,
 	.hw_reset	= (hw_reset_t)NULL,
-	.set_link_led	= (set_link_led_t)NULL
+	.set_link_led	= (set_link_led_t)NULL,
+	.phy_specific_func = (phy_specific_func_t)NULL
 };
 
 static struct bnx2x_phy phy_8726 = {
@@ -5647,7 +5887,8 @@ static struct bnx2x_phy phy_8726 = {
 	.config_loopback = (config_loopback_t)bnx2x_8726_config_loopback,
 	.format_fw_ver	= (format_fw_ver_t)bnx2x_format_ver,
 	.hw_reset	= (hw_reset_t)NULL,
-	.set_link_led	= (set_link_led_t)NULL
+	.set_link_led	= (set_link_led_t)NULL,
+	.phy_specific_func = (phy_specific_func_t)NULL
 };
 
 static struct bnx2x_phy phy_8727 = {
@@ -5677,12 +5918,14 @@ static struct bnx2x_phy phy_8727 = {
 	.config_loopback = (config_loopback_t)NULL,
 	.format_fw_ver	= (format_fw_ver_t)bnx2x_format_ver,
 	.hw_reset	= (hw_reset_t)bnx2x_8727_hw_reset,
-	.set_link_led	= (set_link_led_t)NULL
+	.set_link_led	= (set_link_led_t)NULL,
+	.phy_specific_func = (phy_specific_func_t)bnx2x_8727_specific_func
 };
 static struct bnx2x_phy phy_8481 = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8481,
 	.addr		= 0xff,
-	.flags		= FLAGS_FAN_FAILURE_DET_REQ,
+	.flags		= FLAGS_FAN_FAILURE_DET_REQ |
+			  FLAGS_REARM_LATCH_SIGNAL,
 	.def_md_devad	= 0,
 	.reserved	= 0,
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
@@ -5711,13 +5954,15 @@ static struct bnx2x_phy phy_8481 = {
 	.config_loopback = (config_loopback_t)NULL,
 	.format_fw_ver	= (format_fw_ver_t)bnx2x_848xx_format_ver,
 	.hw_reset	= (hw_reset_t)bnx2x_8481_hw_reset,
-	.set_link_led	= (set_link_led_t)NULL
+	.set_link_led	= (set_link_led_t)NULL,
+	.phy_specific_func = (phy_specific_func_t)NULL
 };
 
 static struct bnx2x_phy phy_84823 = {
 	.type		= PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84823,
 	.addr		= 0xff,
-	.flags		= FLAGS_FAN_FAILURE_DET_REQ,
+	.flags		= FLAGS_FAN_FAILURE_DET_REQ |
+			  FLAGS_REARM_LATCH_SIGNAL,
 	.def_md_devad	= 0,
 	.reserved	= 0,
 	.rx_preemphasis	= {0xffff, 0xffff, 0xffff, 0xffff},
@@ -5746,7 +5991,8 @@ static struct bnx2x_phy phy_84823 = {
 	.config_loopback = (config_loopback_t)NULL,
 	.format_fw_ver	= (format_fw_ver_t)bnx2x_848xx_format_ver,
 	.hw_reset	= (hw_reset_t)NULL,
-	.set_link_led	= (set_link_led_t)NULL
+	.set_link_led	= (set_link_led_t)NULL,
+	.phy_specific_func = (phy_specific_func_t)NULL
 };
 
 /*****************************************************************/
@@ -5767,14 +6013,23 @@ static void bnx2x_populate_preemphasis(struct bnx2x *bp, u32 shmem_base,
 		 * shmem. When num_phys is greater than 1, than this value
 		 * applies only to EXT_PHY1
 		 */
+		if (phy_index == INT_PHY || phy_index == EXT_PHY1) {
+			rx = REG_RD(bp, shmem_base +
+				    offsetof(struct shmem_region,
+			   dev_info.port_hw_config[port].xgxs_config_rx[i<<1]));
+
+			tx = REG_RD(bp, shmem_base +
+				    offsetof(struct shmem_region,
+			   dev_info.port_hw_config[port].xgxs_config_tx[i<<1]));
+		} else {
+			rx = REG_RD(bp, shmem_base +
+				    offsetof(struct shmem_region,
+			  dev_info.port_hw_config[port].xgxs_config2_rx[i<<1]));
 
-		rx = REG_RD(bp, shmem_base +
-				  offsetof(struct shmem_region,
-		  dev_info.port_hw_config[port].xgxs_config_rx[i<<1]));
-
-		tx = REG_RD(bp, shmem_base +
-				  offsetof(struct shmem_region,
-		  dev_info.port_hw_config[port].xgxs_config_tx[i<<1]));
+			tx = REG_RD(bp, shmem_base +
+				    offsetof(struct shmem_region,
+			  dev_info.port_hw_config[port].xgxs_config2_rx[i<<1]));
+		}
 
 		phy->rx_preemphasis[i << 1] = ((rx>>16) & 0xffff);
 		phy->rx_preemphasis[(i << 1) + 1] = (rx & 0xffff);
@@ -5794,6 +6049,11 @@ static u32 bnx2x_get_ext_phy_config(struct bnx2x *bp, u32 shmem_base,
 					      offsetof(struct shmem_region,
 			dev_info.port_hw_config[port].external_phy_config));
 		break;
+	case EXT_PHY2:
+		ext_phy_config = REG_RD(bp, shmem_base +
+					      offsetof(struct shmem_region,
+			dev_info.port_hw_config[port].external_phy_config2));
+		break;
 	default:
 		DP(NETIF_MSG_LINK, "Invalid phy_index %d\n", phy_index);
 		return -EINVAL;
@@ -5844,6 +6104,7 @@ static u8 bnx2x_populate_int_phy(struct bnx2x *bp, u32 shmem_base, u8 port,
 static u8 bnx2x_populate_ext_phy(struct bnx2x *bp,
 				 u8 phy_index,
 				 u32 shmem_base,
+				 u32 shmem2_base,
 				 u8 port,
 				 struct bnx2x_phy *phy)
 {
@@ -5905,15 +6166,30 @@ static u8 bnx2x_populate_ext_phy(struct bnx2x *bp,
 	*/
 	config2 = REG_RD(bp, shmem_base + offsetof(struct shmem_region,
 					dev_info.shared_hw_config.config2));
-
-	phy->ver_addr = shmem_base + offsetof(struct shmem_region,
-			port_mb[port].ext_phy_fw_version);
+	if (phy_index == EXT_PHY1) {
+		phy->ver_addr = shmem_base + offsetof(struct shmem_region,
+				port_mb[port].ext_phy_fw_version);
 
 	/* Check specific mdc mdio settings */
 	if (config2 & SHARED_HW_CFG_MDC_MDIO_ACCESS1_MASK)
 		mdc_mdio_access = config2 &
 		SHARED_HW_CFG_MDC_MDIO_ACCESS1_MASK;
+	} else {
+		u32 size = REG_RD(bp, shmem2_base);
 
+		if (size >
+		    offsetof(struct shmem2_region, ext_phy_fw_version2)) {
+			phy->ver_addr = shmem2_base +
+			    offsetof(struct shmem2_region,
+				     ext_phy_fw_version2[port]);
+		}
+		/* Check specific mdc mdio settings */
+		if (config2 & SHARED_HW_CFG_MDC_MDIO_ACCESS2_MASK)
+			mdc_mdio_access = (config2 &
+			SHARED_HW_CFG_MDC_MDIO_ACCESS2_MASK) >>
+			(SHARED_HW_CFG_MDC_MDIO_ACCESS2_SHIFT -
+			 SHARED_HW_CFG_MDC_MDIO_ACCESS1_SHIFT);
+	}
 	phy->mdio_ctrl = bnx2x_get_emac_base(bp, mdc_mdio_access, port);
 
 	/**
@@ -5931,30 +6207,41 @@ static u8 bnx2x_populate_ext_phy(struct bnx2x *bp,
 }
 
 static u8 bnx2x_populate_phy(struct bnx2x *bp, u8 phy_index, u32 shmem_base,
-			     u8 port, struct bnx2x_phy *phy)
+			     u32 shmem2_base, u8 port, struct bnx2x_phy *phy)
 {
 	u8 status = 0;
 	phy->type = PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN;
 	if (phy_index == INT_PHY)
 		return bnx2x_populate_int_phy(bp, shmem_base, port, phy);
-	status = bnx2x_populate_ext_phy(bp, phy_index, shmem_base,
+	status = bnx2x_populate_ext_phy(bp, phy_index, shmem_base, shmem2_base,
 					port, phy);
 	return status;
 }
 
 static void bnx2x_phy_def_cfg(struct link_params *params,
 			      struct bnx2x_phy *phy,
-			      u8 actual_phy_idx)
+			      u8 phy_index)
 {
 	struct bnx2x *bp = params->bp;
 	u32 link_config;
 	/* Populate the default phy configuration for MF mode */
-	link_config = REG_RD(bp, params->shmem_base +
-			offsetof(struct shmem_region, dev_info.
-			port_feature_config[params->port].link_config));
-	phy->speed_cap_mask = REG_RD(bp, params->shmem_base +
+	if (phy_index == EXT_PHY2) {
+		link_config = REG_RD(bp, params->shmem_base +
+					 offsetof(struct shmem_region, dev_info.
+			port_feature_config[params->port].link_config2));
+		phy->speed_cap_mask = REG_RD(bp, params->shmem_base +
+					offsetof(struct shmem_region, dev_info.
+			port_hw_config[params->port].speed_capability_mask2));
+	} else {
+		link_config = REG_RD(bp, params->shmem_base +
+				offsetof(struct shmem_region, dev_info.
+				port_feature_config[params->port].link_config));
+		phy->speed_cap_mask = REG_RD(bp, params->shmem_base +
 				offsetof(struct shmem_region, dev_info.
-			port_hw_config[params->port].speed_capability_mask));
+			   port_hw_config[params->port].speed_capability_mask));
+	}
+	DP(NETIF_MSG_LINK, "Default config phy idx %x cfg 0x%x speed_cap_mask"
+		       " 0x%x\n", phy_index, link_config, phy->speed_cap_mask);
 
 	phy->req_duplex = DUPLEX_FULL;
 	switch (link_config  & PORT_FEATURE_LINK_SPEED_MASK) {
@@ -6001,23 +6288,66 @@ static void bnx2x_phy_def_cfg(struct link_params *params,
 	}
 }
 
+u32 bnx2x_phy_selection(struct link_params *params)
+{
+	u32 phy_config_swapped, prio_cfg;
+	u32 return_cfg = PORT_HW_CFG_PHY_SELECTION_HARDWARE_DEFAULT;
+
+	phy_config_swapped = params->multi_phy_config &
+		PORT_HW_CFG_PHY_SWAPPED_ENABLED;
+
+	prio_cfg = params->multi_phy_config &
+			PORT_HW_CFG_PHY_SELECTION_MASK;
+
+	if (phy_config_swapped) {
+		switch (prio_cfg) {
+		case PORT_HW_CFG_PHY_SELECTION_FIRST_PHY_PRIORITY:
+		     return_cfg = PORT_HW_CFG_PHY_SELECTION_SECOND_PHY_PRIORITY;
+		     break;
+		case PORT_HW_CFG_PHY_SELECTION_SECOND_PHY_PRIORITY:
+		     return_cfg = PORT_HW_CFG_PHY_SELECTION_FIRST_PHY_PRIORITY;
+		     break;
+		case PORT_HW_CFG_PHY_SELECTION_SECOND_PHY:
+		     return_cfg = PORT_HW_CFG_PHY_SELECTION_FIRST_PHY;
+		     break;
+		case PORT_HW_CFG_PHY_SELECTION_FIRST_PHY:
+		     return_cfg = PORT_HW_CFG_PHY_SELECTION_SECOND_PHY;
+		     break;
+		}
+	} else
+		return_cfg = prio_cfg;
+
+	return return_cfg;
+}
+
+
 u8 bnx2x_phy_probe(struct link_params *params)
 {
 	u8 phy_index, actual_phy_idx, link_cfg_idx;
-
+	u32 phy_config_swapped;
 	struct bnx2x *bp = params->bp;
 	struct bnx2x_phy *phy;
 	params->num_phys = 0;
 	DP(NETIF_MSG_LINK, "Begin phy probe\n");
+	phy_config_swapped = params->multi_phy_config &
+		PORT_HW_CFG_PHY_SWAPPED_ENABLED;
 
 	for (phy_index = INT_PHY; phy_index < MAX_PHYS;
 	      phy_index++) {
 		link_cfg_idx = LINK_CONFIG_IDX(phy_index);
 		actual_phy_idx = phy_index;
-
+		if (phy_config_swapped) {
+			if (phy_index == EXT_PHY1)
+				actual_phy_idx = EXT_PHY2;
+			else if (phy_index == EXT_PHY2)
+				actual_phy_idx = EXT_PHY1;
+		}
+		DP(NETIF_MSG_LINK, "phy_config_swapped %x, phy_index %x,"
+			       " actual_phy_idx %x\n", phy_config_swapped,
+			   phy_index, actual_phy_idx);
 		phy = &params->phy[actual_phy_idx];
 		if (bnx2x_populate_phy(bp, phy_index, params->shmem_base,
-				       params->port,
+				       params->shmem2_base, params->port,
 				       phy) != 0) {
 			params->num_phys = 0;
 			DP(NETIF_MSG_LINK, "phy probe failed in phy index %d\n",
@@ -6031,7 +6361,7 @@ u8 bnx2x_phy_probe(struct link_params *params)
 		if (phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN)
 			break;
 
-		bnx2x_phy_def_cfg(params, phy, actual_phy_idx);
+		bnx2x_phy_def_cfg(params, phy, phy_index);
 		params->num_phys++;
 	}
 
@@ -6049,23 +6379,30 @@ u32 bnx2x_supported_attr(struct link_params *params, u8 phy_idx)
 static void set_phy_vars(struct link_params *params)
 {
 	struct bnx2x *bp = params->bp;
-	u8 actual_phy_idx, phy_index;
-
+	u8 actual_phy_idx, phy_index, link_cfg_idx;
+	u8 phy_config_swapped = params->multi_phy_config &
+			PORT_HW_CFG_PHY_SWAPPED_ENABLED;
 	for (phy_index = INT_PHY; phy_index < params->num_phys;
 	      phy_index++) {
-
+		link_cfg_idx = LINK_CONFIG_IDX(phy_index);
 		actual_phy_idx = phy_index;
+		if (phy_config_swapped) {
+			if (phy_index == EXT_PHY1)
+				actual_phy_idx = EXT_PHY2;
+			else if (phy_index == EXT_PHY2)
+				actual_phy_idx = EXT_PHY1;
+		}
 		params->phy[actual_phy_idx].req_flow_ctrl  =
-			params->req_flow_ctrl;
+			params->req_flow_ctrl[link_cfg_idx];
 
 		params->phy[actual_phy_idx].req_line_speed =
-			params->req_line_speed;
+			params->req_line_speed[link_cfg_idx];
 
 		params->phy[actual_phy_idx].speed_cap_mask =
-			params->speed_cap_mask;
+			params->speed_cap_mask[link_cfg_idx];
 
 		params->phy[actual_phy_idx].req_duplex =
-			params->req_duplex;
+			params->req_duplex[link_cfg_idx];
 
 		DP(NETIF_MSG_LINK, "req_flow_ctrl %x, req_line_speed %x,"
 			   " speed_cap_mask %x\n",
@@ -6078,11 +6415,11 @@ static void set_phy_vars(struct link_params *params)
 u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 {
 	struct bnx2x *bp = params->bp;
-	u32 val;
-
 	DP(NETIF_MSG_LINK, "Phy Initialization started\n");
-	DP(NETIF_MSG_LINK, "req_speed %d, req_flowctrl %d\n",
-		 params->req_line_speed, params->req_flow_ctrl);
+	DP(NETIF_MSG_LINK, "(1) req_speed %d, req_flowctrl %d\n",
+		   params->req_line_speed[0], params->req_flow_ctrl[0]);
+	DP(NETIF_MSG_LINK, "(2) req_speed %d, req_flowctrl %d\n",
+		   params->req_line_speed[1], params->req_flow_ctrl[1]);
 	vars->link_status = 0;
 	vars->phy_link_up = 0;
 	vars->link_up = 0;
@@ -6196,21 +6533,23 @@ u8 bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 		   (params->loopback_mode == LOOPBACK_EXT_PHY)) {
 
 		vars->link_up = 1;
-		vars->line_speed = SPEED_10000;
-		vars->duplex = DUPLEX_FULL;
 		vars->flow_ctrl = BNX2X_FLOW_CTRL_NONE;
-
-		vars->phy_flags = PHY_XGXS_FLAG;
-
-		val = REG_RD(bp,
-				 NIG_REG_XGXS0_CTRL_PHY_ADDR+
-				 params->port*0x18);
+		vars->duplex = DUPLEX_FULL;
+		if (params->req_line_speed[0] == SPEED_1000) {
+			vars->line_speed = SPEED_1000;
+			vars->mac_type = MAC_TYPE_EMAC;
+		} else {
+			vars->line_speed = SPEED_10000;
+			vars->mac_type = MAC_TYPE_BMAC;
+		}
 
 		bnx2x_xgxs_deassert(params);
 		bnx2x_link_initialize(params, vars);
 
-		vars->mac_type = MAC_TYPE_BMAC;
-
+		if (params->req_line_speed[0] == SPEED_1000) {
+			bnx2x_emac_program(params, vars);
+			bnx2x_emac_enable(params, vars, 0);
+		} else
 		bnx2x_bmac_enable(params, vars, 0);
 
 		if (params->loopback_mode == LOOPBACK_XGXS) {
@@ -6311,7 +6650,7 @@ u8 bnx2x_link_reset(struct link_params *params, struct link_vars *vars,
 /****************************************************************************/
 /*				Common function				    */
 /****************************************************************************/
-static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
+static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base, u32 shmem2_base, u8 phy_index)
 {
 	struct bnx2x_phy phy[PORT_MAX];
 	struct bnx2x_phy *phy_blk[PORT_MAX];
@@ -6321,7 +6660,7 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	/* PART1 - Reset both phys */
 	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
 		/* Extract the ext phy address for the port */
-		if (bnx2x_populate_phy(bp, EXT_PHY1, shmem_base,
+		if (bnx2x_populate_phy(bp, phy_index, shmem_base, shmem2_base,
 				       port, &phy[port]) !=
 		    0) {
 			DP(NETIF_MSG_LINK, "populate_phy failed\n");
@@ -6419,7 +6758,8 @@ static u8 bnx2x_8073_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	return 0;
 }
 
-static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp, u32 shmem_base)
+static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp, u32 shmem_base,
+				     u32 shmem2_base, u8 phy_index)
 {
 	u32 val;
 	s8 port;
@@ -6435,7 +6775,7 @@ static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	msleep(5);
 	for (port = 0; port < PORT_MAX; port++) {
 		/* Extract the ext phy address for the port */
-		if (bnx2x_populate_phy(bp, EXT_PHY1, shmem_base,
+		if (bnx2x_populate_phy(bp, phy_index, shmem_base, shmem2_base,
 				       port, &phy) !=
 		    0) {
 			DP(NETIF_MSG_LINK, "populate phy failed\n");
@@ -6455,10 +6795,10 @@ static u8 bnx2x_8726_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 
 	return 0;
 }
-
-static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base)
+static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base,
+				     u32 shmem2_base, u8 phy_index)
 {
-	s8 port, first_port, i;
+	s8 port;
 	u32 swap_val, swap_override;
 	struct bnx2x_phy phy[PORT_MAX];
 	struct bnx2x_phy *phy_blk[PORT_MAX];
@@ -6466,18 +6806,19 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	swap_val = REG_RD(bp,  NIG_REG_PORT_SWAP);
 	swap_override = REG_RD(bp,  NIG_REG_STRAP_OVERRIDE);
 
-	bnx2x_ext_phy_hw_reset(bp, 1 ^ (swap_val && swap_override));
-	msleep(5);
+	port = 1;
 
-	if (swap_val && swap_override)
-		first_port = PORT_0;
-	else
-		first_port = PORT_1;
+	bnx2x_ext_phy_hw_reset(bp, port ^ (swap_val && swap_override));
+
+	/* Calculate the port based on port swap */
+	port ^= (swap_val && swap_override);
+
+	msleep(5);
 
 	/* PART1 - Reset both phys */
-	for (i = 0, port = first_port; i < PORT_MAX; i++, port = !port) {
+	for (port = PORT_MAX - 1; port >= PORT_0; port--) {
 		/* Extract the ext phy address for the port */
-		if (bnx2x_populate_phy(bp, EXT_PHY1, shmem_base,
+		if (bnx2x_populate_phy(bp, phy_index, shmem_base, shmem2_base,
 				       port, &phy[port]) !=
 				       0) {
 			DP(NETIF_MSG_LINK, "populate phy failed\n");
@@ -6528,35 +6869,32 @@ static u8 bnx2x_8727_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	return 0;
 }
 
-u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base)
+static u8 bnx2x_ext_phy_common_init(struct bnx2x *bp, u32 shmem_base,
+				    u32 shmem2_base, u8 phy_index,
+				    u32 ext_phy_type)
 {
 	u8 rc = 0;
-	u32 ext_phy_type;
-
-	DP(NETIF_MSG_LINK, "Begin common phy init\n");
-
-	/* Read the ext_phy_type for arbitrary port(0) */
-	ext_phy_type = XGXS_EXT_PHY_TYPE(
-			REG_RD(bp, shmem_base +
-			   offsetof(struct shmem_region,
-			     dev_info.port_hw_config[0].external_phy_config)));
 
 	switch (ext_phy_type) {
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8073:
-	{
-		rc = bnx2x_8073_common_init_phy(bp, shmem_base);
+		rc = bnx2x_8073_common_init_phy(bp, shmem_base,
+						shmem2_base, phy_index);
 		break;
-	}
 
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727:
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8727_NOC:
-		rc = bnx2x_8727_common_init_phy(bp, shmem_base);
+		rc = bnx2x_8727_common_init_phy(bp, shmem_base,
+						shmem2_base, phy_index);
 		break;
 
 	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM8726:
 		/* GPIO1 affects both ports, so there's need to pull
 		it for single port alone */
-		rc = bnx2x_8726_common_init_phy(bp, shmem_base);
+		rc = bnx2x_8726_common_init_phy(bp, shmem_base,
+						shmem2_base, phy_index);
+		break;
+	case PORT_HW_CFG_XGXS_EXT_PHY_TYPE_FAILURE:
+		rc = -EINVAL;
 		break;
 	default:
 		DP(NETIF_MSG_LINK,
@@ -6568,14 +6906,38 @@ u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base)
 	return rc;
 }
 
+u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base,
+			 u32 shmem2_base)
+{
+	u8 rc = 0;
+	u8 phy_index;
+	u32 ext_phy_type, ext_phy_config;
+	DP(NETIF_MSG_LINK, "Begin common phy init\n");
+
+	if (CHIP_REV_IS_EMUL(bp))
+		return 0;
+
+	/* Read the ext_phy_type for arbitrary port(0) */
+	for (phy_index = EXT_PHY1; phy_index < MAX_PHYS;
+	      phy_index++) {
+		ext_phy_config = bnx2x_get_ext_phy_config(bp,
+							  shmem_base,
+							  phy_index, 0);
+		ext_phy_type = XGXS_EXT_PHY_TYPE(ext_phy_config);
+		rc |= bnx2x_ext_phy_common_init(bp, shmem_base,
+						shmem2_base,
+						phy_index, ext_phy_type);
+	}
+	return rc;
+}
 
-u8 bnx2x_hw_lock_required(struct bnx2x *bp, u32 shmem_base)
+u8 bnx2x_hw_lock_required(struct bnx2x *bp, u32 shmem_base, u32 shmem2_base)
 {
 	u8 phy_index;
 	struct bnx2x_phy phy;
 	for (phy_index = INT_PHY; phy_index < MAX_PHYS;
 	      phy_index++) {
-		if (bnx2x_populate_phy(bp, phy_index, shmem_base,
+		if (bnx2x_populate_phy(bp, phy_index, shmem_base, shmem2_base,
 				       0, &phy) != 0) {
 			DP(NETIF_MSG_LINK, "populate phy failed\n");
 			return 0;
@@ -6589,13 +6951,14 @@ u8 bnx2x_hw_lock_required(struct bnx2x *bp, u32 shmem_base)
 
 u8 bnx2x_fan_failure_det_req(struct bnx2x *bp,
 			     u32 shmem_base,
+			     u32 shmem2_base,
 			     u8 port)
 {
 	u8 phy_index, fan_failure_det_req = 0;
 	struct bnx2x_phy phy;
 	for (phy_index = EXT_PHY1; phy_index < MAX_PHYS;
 	      phy_index++) {
-		if (bnx2x_populate_phy(bp, phy_index, shmem_base,
+		if (bnx2x_populate_phy(bp, phy_index, shmem_base, shmem2_base,
 				       port, &phy)
 		    != 0) {
 			DP(NETIF_MSG_LINK, "populate phy failed\n");
diff --git a/drivers/net/bnx2x/bnx2x_link.h b/drivers/net/bnx2x/bnx2x_link.h
index 35f665f..9115c12 100644
--- a/drivers/net/bnx2x/bnx2x_link.h
+++ b/drivers/net/bnx2x/bnx2x_link.h
@@ -59,13 +59,18 @@
 #define SINGLE_MEDIA_DIRECT(params)	(params->num_phys == 1)
 /* Single Media board contains single external phy */
 #define SINGLE_MEDIA(params)		(params->num_phys == 2)
+/* Dual Media board contains two external phy with different media */
+#define DUAL_MEDIA(params)		(params->num_phys == 3)
+#define FW_PARAM_MDIO_CTRL_OFFSET 16
+#define FW_PARAM_SET(phy_addr, phy_type, mdio_access) \
+	(phy_addr | phy_type | mdio_access << FW_PARAM_MDIO_CTRL_OFFSET)
 /***********************************************************/
 /*                         Structs                         */
 /***********************************************************/
 #define INT_PHY		0
 #define EXT_PHY1	1
-
-#define MAX_PHYS	2
+#define EXT_PHY2	2
+#define MAX_PHYS	3
 
 /* Same configuration is shared between the XGXS and the first external phy */
 #define LINK_CONFIG_SIZE (MAX_PHYS - 1)
@@ -91,6 +96,8 @@ typedef u8 (*format_fw_ver_t)(u32 raw, u8 *str, u16 *len);
 typedef void (*hw_reset_t)(struct bnx2x_phy *phy, struct link_params *params);
 typedef void (*set_link_led_t)(struct bnx2x_phy *phy,
 			       struct link_params *params, u8 mode);
+typedef void (*phy_specific_func_t)(struct bnx2x_phy *phy,
+				    struct link_params *params, u32 action);
 
 struct bnx2x_phy {
 	u32 type;
@@ -106,7 +113,9 @@ struct bnx2x_phy {
 	/* Fan failure detection required */
 #define FLAGS_FAN_FAILURE_DET_REQ	(1<<2)
 	/* Initialize first the XGXS and only then the phy itself */
-#define FLAGS_INIT_XGXS_FIRST	(1<<3)
+#define FLAGS_INIT_XGXS_FIRST		(1<<3)
+#define FLAGS_REARM_LATCH_SIGNAL	(1<<6)
+#define FLAGS_SFP_NOT_APPROVED		(1<<7)
 
 	u8 def_md_devad;
 	u8 reserved;
@@ -161,6 +170,11 @@ struct bnx2x_phy {
 
 	/* Set link led mode (on/off/oper)*/
 	set_link_led_t set_link_led;
+
+	/* PHY Specific tasks */
+	phy_specific_func_t phy_specific_func;
+#define DISABLE_TX	1
+#define ENABLE_TX	2
 };
 
 /* Inputs parameters to the CLC */
@@ -177,18 +191,18 @@ struct link_params {
 #define LOOPBACK_EXT_PHY	4
 #define LOOPBACK_EXT 	5
 
-	u16 req_duplex;
-	u16 req_flow_ctrl;
-	u16 req_fc_auto_adv; /* Should be set to TX / BOTH when
-	req_flow_ctrl is set to AUTO */
-	u16 req_line_speed; /* Also determine AutoNeg */
-
 	/* Device parameters */
 	u8 mac_addr[6];
 
+	u16 req_duplex[LINK_CONFIG_SIZE];
+	u16 req_flow_ctrl[LINK_CONFIG_SIZE];
+
+	u16 req_line_speed[LINK_CONFIG_SIZE]; /* Also determine AutoNeg */
+
 	/* shmem parameters */
 	u32 shmem_base;
-	u32 speed_cap_mask;
+	u32 shmem2_base;
+	u32 speed_cap_mask[LINK_CONFIG_SIZE];
 	u32 switch_cfg;
 #define SWITCH_CFG_1G		PORT_FEATURE_CON_SWITCH_1G_SWITCH
 #define SWITCH_CFG_10G		PORT_FEATURE_CON_SWITCH_10G_SWITCH
@@ -202,6 +216,7 @@ struct link_params {
 	u32 feature_config_flags;
 #define FEATURE_CONFIG_OVERRIDE_PREEMPHASIS_ENABLED (1<<0)
 #define FEATURE_CONFIG_BC_SUPPORTS_OPT_MDL_VRFY	(1<<2)
+#define FEATURE_CONFIG_BC_SUPPORTS_DUAL_PHY_OPT_MDL_VRFY	(1<<3)
 	/* Will be populated during common init */
 	struct bnx2x_phy phy[MAX_PHYS];
 
@@ -210,9 +225,12 @@ struct link_params {
 
 	u8 rsrv;
 	u16 hw_led_mode; /* part of the hw_config read from the shmem */
+	u32 multi_phy_config;
 
 	/* Device pointer passed to all callback functions */
 	struct bnx2x *bp;
+	u16 req_fc_auto_adv; /* Should be set to TX / BOTH when
+				req_flow_ctrl is set to AUTO */
 };
 
 /* Output parameters */
@@ -233,12 +251,6 @@ struct link_vars {
 	u16 flow_ctrl;
 	u16 ieee_fc;
 
-	u32 autoneg;
-#define AUTO_NEG_DISABLED			0x0
-#define AUTO_NEG_ENABLED			0x1
-#define AUTO_NEG_COMPLETE			0x2
-#define AUTO_NEG_PARALLEL_DETECTION_USED	0x3
-
 	/* The same definitions as the shmem parameter */
 	u32 link_status;
 };
@@ -246,8 +258,6 @@ struct link_vars {
 /***********************************************************/
 /*                         Functions                       */
 /***********************************************************/
-
-/* Initialize the phy */
 u8 bnx2x_phy_init(struct link_params *input, struct link_vars *output);
 
 /* Reset the link. Should be called when driver or interface goes down
@@ -298,10 +308,11 @@ void bnx2x_handle_module_detect_int(struct link_params *params);
 
 /* Get the actual link status. In case it returns 0, link is up,
 	otherwise link is down*/
-u8 bnx2x_test_link(struct link_params *input, struct link_vars *vars);
+u8 bnx2x_test_link(struct link_params *input, struct link_vars *vars,
+		   u8 is_serdes);
 
 /* One-time initialization for external phy after power up */
-u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base);
+u8 bnx2x_common_init_phy(struct bnx2x *bp, u32 shmem_base, u32 shmem2_base);
 
 /* Reset the external PHY using GPIO */
 void bnx2x_ext_phy_hw_reset(struct bnx2x *bp, u8 port);
@@ -316,12 +327,19 @@ u8 bnx2x_read_sfp_module_eeprom(struct bnx2x_phy *phy,
 void bnx2x_hw_reset_phy(struct link_params *params);
 
 /* Checks if HW lock is required for this phy/board type */
-u8 bnx2x_hw_lock_required(struct bnx2x *bp, u32 shmem_base);
+u8 bnx2x_hw_lock_required(struct bnx2x *bp, u32 shmem_base,
+			  u32 shmem2_base);
+
 /* Returns the aggregative supported attributes of the phys on board */
 u32 bnx2x_supported_attr(struct link_params *params, u8 phy_idx);
+
+/* Check swap bit and adjust PHY order */
+u32 bnx2x_phy_selection(struct link_params *params);
+
 /* Probe the phys on board, and populate them in "params" */
 u8 bnx2x_phy_probe(struct link_params *params);
 /* Checks if fan failure detection is required on one of the phys on board */
-u8 bnx2x_fan_failure_det_req(struct bnx2x *bp, u32 shmem_base, u8 port);
+u8 bnx2x_fan_failure_det_req(struct bnx2x *bp, u32 shmem_base,
+			     u32 shmem2_base, u8 port);
 
 #endif /* BNX2X_LINK_H */
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 30618c7..f0a7884 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -1227,26 +1227,66 @@ static int bnx2x_set_spio(struct bnx2x *bp, int spio_num, u32 mode)
 	return 0;
 }
 
+int bnx2x_get_link_cfg_idx(struct bnx2x *bp)
+{
+	u32 sel_phy_idx = 0;
+	if (bp->link_vars.link_up) {
+		sel_phy_idx = EXT_PHY1;
+		/* In case link is SERDES, check if the EXT_PHY2 is the one */
+		if ((bp->link_vars.link_status & LINK_STATUS_SERDES_LINK) &&
+		    (bp->link_params.phy[EXT_PHY2].supported & SUPPORTED_FIBRE))
+			sel_phy_idx = EXT_PHY2;
+	} else {
+
+		switch (bnx2x_phy_selection(&bp->link_params)) {
+		case PORT_HW_CFG_PHY_SELECTION_HARDWARE_DEFAULT:
+		case PORT_HW_CFG_PHY_SELECTION_FIRST_PHY:
+		case PORT_HW_CFG_PHY_SELECTION_FIRST_PHY_PRIORITY:
+		       sel_phy_idx = EXT_PHY1;
+		       break;
+		case PORT_HW_CFG_PHY_SELECTION_SECOND_PHY:
+		case PORT_HW_CFG_PHY_SELECTION_SECOND_PHY_PRIORITY:
+		       sel_phy_idx = EXT_PHY2;
+		       break;
+		}
+	}
+	/*
+	* The selected actived PHY is always after swapping (in case PHY
+	* swapping is enabled). So when swapping is enabled, we need to reverse
+	* the configuration
+	*/
+
+	if (bp->link_params.multi_phy_config &
+	    PORT_HW_CFG_PHY_SWAPPED_ENABLED) {
+		if (sel_phy_idx == EXT_PHY1)
+			sel_phy_idx = EXT_PHY2;
+		else if (sel_phy_idx == EXT_PHY2)
+			sel_phy_idx = EXT_PHY1;
+	}
+	return LINK_CONFIG_IDX(sel_phy_idx);
+}
+
 void bnx2x_calc_fc_adv(struct bnx2x *bp)
 {
+	u8 cfg_idx = bnx2x_get_link_cfg_idx(bp);
 	switch (bp->link_vars.ieee_fc &
 		MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_MASK) {
 	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE:
-		bp->port.advertising &= ~(ADVERTISED_Asym_Pause |
+		bp->port.advertising[cfg_idx] &= ~(ADVERTISED_Asym_Pause |
 					  ADVERTISED_Pause);
 		break;
 
 	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH:
-		bp->port.advertising |= (ADVERTISED_Asym_Pause |
+		bp->port.advertising[cfg_idx] |= (ADVERTISED_Asym_Pause |
 					 ADVERTISED_Pause);
 		break;
 
 	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC:
-		bp->port.advertising |= ADVERTISED_Asym_Pause;
+		bp->port.advertising[cfg_idx] |= ADVERTISED_Asym_Pause;
 		break;
 
 	default:
-		bp->port.advertising &= ~(ADVERTISED_Asym_Pause |
+		bp->port.advertising[cfg_idx] &= ~(ADVERTISED_Asym_Pause |
 					  ADVERTISED_Pause);
 		break;
 	}
@@ -1257,7 +1297,8 @@ u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 {
 	if (!BP_NOMCP(bp)) {
 		u8 rc;
-
+		int cfx_idx = bnx2x_get_link_cfg_idx(bp);
+		u16 req_line_speed = bp->link_params.req_line_speed[cfx_idx];
 		/* Initialize link parameters structure variables */
 		/* It is recommended to turn off RX FC for jumbo frames
 		   for better performance */
@@ -1268,8 +1309,10 @@ u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 
 		bnx2x_acquire_phy_lock(bp);
 
-		if (load_mode == LOAD_DIAG)
+		if (load_mode == LOAD_DIAG) {
 			bp->link_params.loopback_mode = LOOPBACK_XGXS;
+			bp->link_params.req_line_speed[cfx_idx] = SPEED_10000;
+		}
 
 		rc = bnx2x_phy_init(&bp->link_params, &bp->link_vars);
 
@@ -1281,7 +1324,7 @@ u8 bnx2x_initial_phy_init(struct bnx2x *bp, int load_mode)
 			bnx2x_stats_handle(bp, STATS_EVENT_LINK_UP);
 			bnx2x_link_report(bp);
 		}
-
+		bp->link_params.req_line_speed[cfx_idx] = req_line_speed;
 		return rc;
 	}
 	BNX2X_ERR("Bootcode is missing - can not initialize link\n");
@@ -1311,13 +1354,14 @@ static void bnx2x__link_reset(struct bnx2x *bp)
 		BNX2X_ERR("Bootcode is missing - can not reset link\n");
 }
 
-u8 bnx2x_link_test(struct bnx2x *bp)
+u8 bnx2x_link_test(struct bnx2x *bp, u8 is_serdes)
 {
 	u8 rc = 0;
 
 	if (!BP_NOMCP(bp)) {
 		bnx2x_acquire_phy_lock(bp);
-		rc = bnx2x_test_link(&bp->link_params, &bp->link_vars);
+		rc = bnx2x_test_link(&bp->link_params, &bp->link_vars,
+				     is_serdes);
 		bnx2x_release_phy_lock(bp);
 	} else
 		BNX2X_ERR("Bootcode is missing - can not test link\n");
@@ -1586,7 +1630,7 @@ static void bnx2x_pmf_update(struct bnx2x *bp)
  */
 
 /* send the MCP a request, block until there is a reply */
-u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
+u32 bnx2x_fw_command(struct bnx2x *bp, u32 command, u32 param)
 {
 	int func = BP_FUNC(bp);
 	u32 seq = ++bp->fw_seq;
@@ -1595,6 +1639,7 @@ u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
 	u8 delay = CHIP_REV_IS_SLOW(bp) ? 100 : 10;
 
 	mutex_lock(&bp->fw_mb_mutex);
+	SHMEM_WR(bp, func_mb[func].drv_mb_param, param);
 	SHMEM_WR(bp, func_mb[func].drv_mb_header, (command | seq));
 	DP(BNX2X_MSG_MCP, "wrote command (%x) to FW MB\n", (command | seq));
 
@@ -1716,9 +1761,9 @@ static void bnx2x_dcc_event(struct bnx2x *bp, u32 dcc_event)
 
 	/* Report results to MCP */
 	if (dcc_event)
-		bnx2x_fw_command(bp, DRV_MSG_CODE_DCC_FAILURE);
+		bnx2x_fw_command(bp, DRV_MSG_CODE_DCC_FAILURE, 0);
 	else
-		bnx2x_fw_command(bp, DRV_MSG_CODE_DCC_OK);
+		bnx2x_fw_command(bp, DRV_MSG_CODE_DCC_OK, 0);
 }
 
 /* must be called under the spq lock */
@@ -3848,6 +3893,7 @@ static void bnx2x_setup_fan_failure_detection(struct bnx2x *bp)
 				bnx2x_fan_failure_det_req(
 					bp,
 					bp->common.shmem_base,
+					bp->common.shmem2_base,
 					port);
 		}
 
@@ -4116,7 +4162,8 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	}
 
 	bp->port.need_hw_lock = bnx2x_hw_lock_required(bp,
-						       bp->common.shmem_base);
+						       bp->common.shmem_base,
+						       bp->common.shmem2_base);
 
 	bnx2x_setup_fan_failure_detection(bp);
 
@@ -4129,7 +4176,8 @@ static int bnx2x_init_common(struct bnx2x *bp)
 
 	if (!BP_NOMCP(bp)) {
 		bnx2x_acquire_phy_lock(bp);
-		bnx2x_common_init_phy(bp, bp->common.shmem_base);
+		bnx2x_common_init_phy(bp, bp->common.shmem_base,
+				      bp->common.shmem2_base);
 		bnx2x_release_phy_lock(bp);
 	} else
 		BNX2X_ERR("Bootcode is missing - can not initialize link\n");
@@ -4265,10 +4313,10 @@ static int bnx2x_init_port(struct bnx2x *bp)
 	bnx2x_init_block(bp, MCP_BLOCK, init_stage);
 	bnx2x_init_block(bp, DMAE_BLOCK, init_stage);
 	bp->port.need_hw_lock = bnx2x_hw_lock_required(bp,
-						       bp->common.shmem_base);
-
+						       bp->common.shmem_base,
+						       bp->common.shmem2_base);
 	if (bnx2x_fan_failure_det_req(bp, bp->common.shmem_base,
-				      port)) {
+				      bp->common.shmem2_base, port)) {
 		u32 reg_addr = (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0 :
 				       MISC_REG_AEU_ENABLE1_FUNC_0_OUT_0);
 		val = REG_RD(bp, reg_addr);
@@ -5226,7 +5274,7 @@ void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode)
 
 unload_error:
 	if (!BP_NOMCP(bp))
-		reset_code = bnx2x_fw_command(bp, reset_code);
+		reset_code = bnx2x_fw_command(bp, reset_code, 0);
 	else {
 		DP(NETIF_MSG_IFDOWN, "NO MCP - load counts      %d, %d, %d\n",
 		   load_count[0], load_count[1], load_count[2]);
@@ -5251,7 +5299,7 @@ unload_error:
 
 	/* Report UNLOAD_DONE to MCP */
 	if (!BP_NOMCP(bp))
-		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
+		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE, 0);
 
 }
 
@@ -5816,13 +5864,14 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 			bp->fw_seq =
 			       (SHMEM_RD(bp, func_mb[bp->func].drv_mb_header) &
 				DRV_MSG_SEQ_NUMBER_MASK);
-			reset_code = bnx2x_fw_command(bp, reset_code);
+			reset_code = bnx2x_fw_command(bp, reset_code, 0);
 
 			/* if UNDI is loaded on the other port */
 			if (reset_code != FW_MSG_CODE_DRV_UNLOAD_COMMON) {
 
 				/* send "DONE" for previous unload */
-				bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
+				bnx2x_fw_command(bp,
+						 DRV_MSG_CODE_UNLOAD_DONE, 0);
 
 				/* unload UNDI on port 1 */
 				bp->func = 1;
@@ -5831,7 +5880,7 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 					DRV_MSG_SEQ_NUMBER_MASK);
 				reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
 
-				bnx2x_fw_command(bp, reset_code);
+				bnx2x_fw_command(bp, reset_code, 0);
 			}
 
 			/* now it's safe to release the lock */
@@ -5873,7 +5922,7 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 			REG_WR(bp, NIG_REG_STRAP_OVERRIDE, swap_en);
 
 			/* send unload done to the MCP */
-			bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
+			bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE, 0);
 
 			/* restore our func and fw_seq */
 			bp->func = func;
@@ -5921,6 +5970,7 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 	bp->common.shmem_base = REG_RD(bp, MISC_REG_SHARED_MEM_ADDR);
 	bp->common.shmem2_base = REG_RD(bp, MISC_REG_GENERIC_CR_0);
 	bp->link_params.shmem_base = bp->common.shmem_base;
+	bp->link_params.shmem2_base = bp->common.shmem2_base;
 	BNX2X_DEV_INFO("shmem offset 0x%x  shmem2 offset 0x%x\n",
 		       bp->common.shmem_base, bp->common.shmem2_base);
 
@@ -5963,8 +6013,11 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 			    "please upgrade BC\n", BNX2X_BC_VER, val);
 	}
 	bp->link_params.feature_config_flags |=
-		(val >= REQ_BC_VER_4_VRFY_OPT_MDL) ?
+				(val >= REQ_BC_VER_4_VRFY_FIRST_PHY_OPT_MDL) ?
 		FEATURE_CONFIG_BC_SUPPORTS_OPT_MDL_VRFY : 0;
+	bp->link_params.feature_config_flags |=
+		(val >= REQ_BC_VER_4_VRFY_SPECIFIC_PHY_OPT_MDL) ?
+		FEATURE_CONFIG_BC_SUPPORTS_DUAL_PHY_OPT_MDL_VRFY : 0;
 
 	if (BP_E1HVN(bp) == 0) {
 		pci_read_config_word(bp->pdev, bp->pm_cap + PCI_PM_PMC, &pmc);
@@ -5988,22 +6041,44 @@ static void __devinit bnx2x_get_common_hwinfo(struct bnx2x *bp)
 static void __devinit bnx2x_link_settings_supported(struct bnx2x *bp,
 						    u32 switch_cfg)
 {
-	int port = BP_PORT(bp);
-	bp->port.supported = 0;
+	int cfg_size = 0, idx, port = BP_PORT(bp);
+
+	/* Aggregation of supported attributes of all external phys */
+	bp->port.supported[0] = 0;
+	bp->port.supported[1] = 0;
 	switch (bp->link_params.num_phys) {
 	case 1:
-		bp->port.supported = bp->link_params.phy[INT_PHY].supported;
-			break;
+		bp->port.supported[0] = bp->link_params.phy[INT_PHY].supported;
+		cfg_size = 1;
+		break;
 	case 2:
-		bp->port.supported = bp->link_params.phy[EXT_PHY1].supported;
-			break;
+		bp->port.supported[0] = bp->link_params.phy[EXT_PHY1].supported;
+		cfg_size = 1;
+		break;
+	case 3:
+		if (bp->link_params.multi_phy_config &
+		    PORT_HW_CFG_PHY_SWAPPED_ENABLED) {
+			bp->port.supported[1] =
+				bp->link_params.phy[EXT_PHY1].supported;
+			bp->port.supported[0] =
+				bp->link_params.phy[EXT_PHY2].supported;
+		} else {
+			bp->port.supported[0] =
+				bp->link_params.phy[EXT_PHY1].supported;
+			bp->port.supported[1] =
+				bp->link_params.phy[EXT_PHY2].supported;
+		}
+		cfg_size = 2;
+		break;
 	}
 
-	if (!(bp->port.supported)) {
+	if (!(bp->port.supported[0] || bp->port.supported[1])) {
 		BNX2X_ERR("NVRAM config error. BAD phy config."
-			  "PHY1 config 0x%x\n",
+			  "PHY1 config 0x%x, PHY2 config 0x%x\n",
 			   SHMEM_RD(bp,
-			   dev_info.port_hw_config[port].external_phy_config));
+			   dev_info.port_hw_config[port].external_phy_config),
+			   SHMEM_RD(bp,
+			   dev_info.port_hw_config[port].external_phy_config2));
 			return;
 		}
 
@@ -6023,147 +6098,183 @@ static void __devinit bnx2x_link_settings_supported(struct bnx2x *bp,
 
 	default:
 		BNX2X_ERR("BAD switch_cfg link_config 0x%x\n",
-			  bp->port.link_config);
+			  bp->port.link_config[0]);
 		return;
 	}
-	/* mask what we support according to speed_cap_mask */
-	if (!(bp->link_params.speed_cap_mask &
+	/* mask what we support according to speed_cap_mask per configuration */
+	for (idx = 0; idx < cfg_size; idx++) {
+		if (!(bp->link_params.speed_cap_mask[idx] &
 				PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF))
-		bp->port.supported &= ~SUPPORTED_10baseT_Half;
+			bp->port.supported[idx] &= ~SUPPORTED_10baseT_Half;
 
-	if (!(bp->link_params.speed_cap_mask &
+		if (!(bp->link_params.speed_cap_mask[idx] &
 				PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL))
-		bp->port.supported &= ~SUPPORTED_10baseT_Full;
+			bp->port.supported[idx] &= ~SUPPORTED_10baseT_Full;
 
-	if (!(bp->link_params.speed_cap_mask &
+		if (!(bp->link_params.speed_cap_mask[idx] &
 				PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF))
-		bp->port.supported &= ~SUPPORTED_100baseT_Half;
+			bp->port.supported[idx] &= ~SUPPORTED_100baseT_Half;
 
-	if (!(bp->link_params.speed_cap_mask &
+		if (!(bp->link_params.speed_cap_mask[idx] &
 				PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL))
-		bp->port.supported &= ~SUPPORTED_100baseT_Full;
+			bp->port.supported[idx] &= ~SUPPORTED_100baseT_Full;
 
-	if (!(bp->link_params.speed_cap_mask &
+		if (!(bp->link_params.speed_cap_mask[idx] &
 					PORT_HW_CFG_SPEED_CAPABILITY_D0_1G))
-		bp->port.supported &= ~(SUPPORTED_1000baseT_Half |
+			bp->port.supported[idx] &= ~(SUPPORTED_1000baseT_Half |
 					SUPPORTED_1000baseT_Full);
 
-	if (!(bp->link_params.speed_cap_mask &
+		if (!(bp->link_params.speed_cap_mask[idx] &
 					PORT_HW_CFG_SPEED_CAPABILITY_D0_2_5G))
-		bp->port.supported &= ~SUPPORTED_2500baseX_Full;
+			bp->port.supported[idx] &= ~SUPPORTED_2500baseX_Full;
 
-	if (!(bp->link_params.speed_cap_mask &
+		if (!(bp->link_params.speed_cap_mask[idx] &
 					PORT_HW_CFG_SPEED_CAPABILITY_D0_10G))
-		bp->port.supported &= ~SUPPORTED_10000baseT_Full;
+			bp->port.supported[idx] &= ~SUPPORTED_10000baseT_Full;
+
+	}
 
-	BNX2X_DEV_INFO("supported 0x%x\n", bp->port.supported);
+	BNX2X_DEV_INFO("supported 0x%x 0x%x\n", bp->port.supported[0],
+		       bp->port.supported[1]);
 }
 
 static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 {
-	bp->link_params.req_duplex = DUPLEX_FULL;
-
-	switch (bp->port.link_config & PORT_FEATURE_LINK_SPEED_MASK) {
+	u32 link_config, idx, cfg_size = 0;
+	bp->port.advertising[0] = 0;
+	bp->port.advertising[1] = 0;
+	switch (bp->link_params.num_phys) {
+	case 1:
+	case 2:
+		cfg_size = 1;
+		break;
+	case 3:
+		cfg_size = 2;
+		break;
+	}
+	for (idx = 0; idx < cfg_size; idx++) {
+		bp->link_params.req_duplex[idx] = DUPLEX_FULL;
+		link_config = bp->port.link_config[idx];
+		switch (link_config & PORT_FEATURE_LINK_SPEED_MASK) {
 	case PORT_FEATURE_LINK_SPEED_AUTO:
-		if (bp->port.supported & SUPPORTED_Autoneg) {
-			bp->link_params.req_line_speed = SPEED_AUTO_NEG;
-			bp->port.advertising = bp->port.supported;
+			if (bp->port.supported[idx] & SUPPORTED_Autoneg) {
+				bp->link_params.req_line_speed[idx] =
+					SPEED_AUTO_NEG;
+				bp->port.advertising[idx] |=
+					bp->port.supported[idx];
 		} else {
-				/* force 10G, no AN */
-				bp->link_params.req_line_speed = SPEED_10000;
-			bp->port.advertising =	(ADVERTISED_10000baseT_Full |
+			/* force 10G, no AN */
+				bp->link_params.req_line_speed[idx] =
+					SPEED_10000;
+				bp->port.advertising[idx] |=
+					(ADVERTISED_10000baseT_Full |
 						 ADVERTISED_FIBRE);
+				continue;
 		}
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_10M_FULL:
-		if (bp->port.supported & SUPPORTED_10baseT_Full) {
-			bp->link_params.req_line_speed = SPEED_10;
-			bp->port.advertising = (ADVERTISED_10baseT_Full |
+			if (bp->port.supported[idx] & SUPPORTED_10baseT_Full) {
+				bp->link_params.req_line_speed[idx] =
+					SPEED_10;
+				bp->port.advertising[idx] |=
+					(ADVERTISED_10baseT_Full |
 						ADVERTISED_TP);
 		} else {
 			BNX2X_ERROR("NVRAM config error. "
 				    "Invalid link_config 0x%x"
 				    "  speed_cap_mask 0x%x\n",
-				    bp->port.link_config,
-				    bp->link_params.speed_cap_mask);
+				    link_config,
+				    bp->link_params.speed_cap_mask[idx]);
 			return;
 		}
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_10M_HALF:
-		if (bp->port.supported & SUPPORTED_10baseT_Half) {
-			bp->link_params.req_line_speed = SPEED_10;
-			bp->link_params.req_duplex = DUPLEX_HALF;
-			bp->port.advertising = (ADVERTISED_10baseT_Half |
+			if (bp->port.supported[idx] & SUPPORTED_10baseT_Half) {
+				bp->link_params.req_line_speed[idx] =
+					SPEED_10;
+				bp->link_params.req_duplex[idx] =
+					DUPLEX_HALF;
+				bp->port.advertising[idx] |=
+					(ADVERTISED_10baseT_Half |
 						ADVERTISED_TP);
 		} else {
 			BNX2X_ERROR("NVRAM config error. "
 				    "Invalid link_config 0x%x"
 				    "  speed_cap_mask 0x%x\n",
-				    bp->port.link_config,
-				    bp->link_params.speed_cap_mask);
+				    link_config,
+				    bp->link_params.speed_cap_mask[idx]);
 			return;
 		}
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_100M_FULL:
-		if (bp->port.supported & SUPPORTED_100baseT_Full) {
-			bp->link_params.req_line_speed = SPEED_100;
-			bp->port.advertising = (ADVERTISED_100baseT_Full |
+			if (bp->port.supported[idx] & SUPPORTED_100baseT_Full) {
+				bp->link_params.req_line_speed[idx] =
+					SPEED_100;
+				bp->port.advertising[idx] |=
+					(ADVERTISED_100baseT_Full |
 						ADVERTISED_TP);
 		} else {
 			BNX2X_ERROR("NVRAM config error. "
 				    "Invalid link_config 0x%x"
 				    "  speed_cap_mask 0x%x\n",
-				    bp->port.link_config,
-				    bp->link_params.speed_cap_mask);
+				    link_config,
+				    bp->link_params.speed_cap_mask[idx]);
 			return;
 		}
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_100M_HALF:
-		if (bp->port.supported & SUPPORTED_100baseT_Half) {
-			bp->link_params.req_line_speed = SPEED_100;
-			bp->link_params.req_duplex = DUPLEX_HALF;
-			bp->port.advertising = (ADVERTISED_100baseT_Half |
+			if (bp->port.supported[idx] & SUPPORTED_100baseT_Half) {
+				bp->link_params.req_line_speed[idx] = SPEED_100;
+				bp->link_params.req_duplex[idx] = DUPLEX_HALF;
+				bp->port.advertising[idx] |=
+					(ADVERTISED_100baseT_Half |
 						ADVERTISED_TP);
 		} else {
 			BNX2X_ERROR("NVRAM config error. "
 				    "Invalid link_config 0x%x"
 				    "  speed_cap_mask 0x%x\n",
-				    bp->port.link_config,
-				    bp->link_params.speed_cap_mask);
+				    link_config,
+				    bp->link_params.speed_cap_mask[idx]);
 			return;
 		}
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_1G:
-		if (bp->port.supported & SUPPORTED_1000baseT_Full) {
-			bp->link_params.req_line_speed = SPEED_1000;
-			bp->port.advertising = (ADVERTISED_1000baseT_Full |
+			if (bp->port.supported[idx] &
+			    SUPPORTED_1000baseT_Full) {
+				bp->link_params.req_line_speed[idx] =
+					SPEED_1000;
+				bp->port.advertising[idx] |=
+					(ADVERTISED_1000baseT_Full |
 						ADVERTISED_TP);
 		} else {
 			BNX2X_ERROR("NVRAM config error. "
 				    "Invalid link_config 0x%x"
 				    "  speed_cap_mask 0x%x\n",
-				    bp->port.link_config,
-				    bp->link_params.speed_cap_mask);
+				    link_config,
+				    bp->link_params.speed_cap_mask[idx]);
 			return;
 		}
 		break;
 
 	case PORT_FEATURE_LINK_SPEED_2_5G:
-		if (bp->port.supported & SUPPORTED_2500baseX_Full) {
-			bp->link_params.req_line_speed = SPEED_2500;
-			bp->port.advertising = (ADVERTISED_2500baseX_Full |
+			if (bp->port.supported[idx] &
+			    SUPPORTED_2500baseX_Full) {
+				bp->link_params.req_line_speed[idx] =
+					SPEED_2500;
+				bp->port.advertising[idx] |=
+					(ADVERTISED_2500baseX_Full |
 						ADVERTISED_TP);
 		} else {
 			BNX2X_ERROR("NVRAM config error. "
 				    "Invalid link_config 0x%x"
 				    "  speed_cap_mask 0x%x\n",
-				    bp->port.link_config,
-				    bp->link_params.speed_cap_mask);
+				    link_config,
+				     bp->link_params.speed_cap_mask[idx]);
 			return;
 		}
 		break;
@@ -6171,16 +6282,19 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 	case PORT_FEATURE_LINK_SPEED_10G_CX4:
 	case PORT_FEATURE_LINK_SPEED_10G_KX4:
 	case PORT_FEATURE_LINK_SPEED_10G_KR:
-		if (bp->port.supported & SUPPORTED_10000baseT_Full) {
-			bp->link_params.req_line_speed = SPEED_10000;
-			bp->port.advertising = (ADVERTISED_10000baseT_Full |
+			if (bp->port.supported[idx] &
+			    SUPPORTED_10000baseT_Full) {
+				bp->link_params.req_line_speed[idx] =
+					SPEED_10000;
+				bp->port.advertising[idx] |=
+					(ADVERTISED_10000baseT_Full |
 						ADVERTISED_FIBRE);
 		} else {
 			BNX2X_ERROR("NVRAM config error. "
 				    "Invalid link_config 0x%x"
 				    "  speed_cap_mask 0x%x\n",
-				    bp->port.link_config,
-				    bp->link_params.speed_cap_mask);
+				    link_config,
+				     bp->link_params.speed_cap_mask[idx]);
 			return;
 		}
 		break;
@@ -6188,23 +6302,28 @@ static void __devinit bnx2x_link_settings_requested(struct bnx2x *bp)
 	default:
 		BNX2X_ERROR("NVRAM config error. "
 			    "BAD link speed link_config 0x%x\n",
-			    bp->port.link_config);
-		bp->link_params.req_line_speed = SPEED_AUTO_NEG;
-		bp->port.advertising = bp->port.supported;
+				  link_config);
+			bp->link_params.req_line_speed[idx] = SPEED_AUTO_NEG;
+			bp->port.advertising[idx] = bp->port.supported[idx];
 		break;
 	}
 
-	bp->link_params.req_flow_ctrl = (bp->port.link_config &
+		bp->link_params.req_flow_ctrl[idx] = (link_config &
 					 PORT_FEATURE_FLOW_CONTROL_MASK);
-	if ((bp->link_params.req_flow_ctrl == BNX2X_FLOW_CTRL_AUTO) &&
-	    !(bp->port.supported & SUPPORTED_Autoneg))
-		bp->link_params.req_flow_ctrl = BNX2X_FLOW_CTRL_NONE;
+		if ((bp->link_params.req_flow_ctrl[idx] ==
+		     BNX2X_FLOW_CTRL_AUTO) &&
+		    !(bp->port.supported[idx] & SUPPORTED_Autoneg)) {
+			bp->link_params.req_flow_ctrl[idx] =
+				BNX2X_FLOW_CTRL_NONE;
+		}
 
-	BNX2X_DEV_INFO("req_line_speed %d  req_duplex %d  req_flow_ctrl 0x%x"
-		       "  advertising 0x%x\n",
-		       bp->link_params.req_line_speed,
-		       bp->link_params.req_duplex,
-		       bp->link_params.req_flow_ctrl, bp->port.advertising);
+		BNX2X_DEV_INFO("req_line_speed %d  req_duplex %d req_flow_ctrl"
+			       " 0x%x advertising 0x%x\n",
+			       bp->link_params.req_line_speed[idx],
+			       bp->link_params.req_duplex[idx],
+			       bp->link_params.req_flow_ctrl[idx],
+			       bp->port.advertising[idx]);
+	}
 }
 
 static void __devinit bnx2x_set_mac_buf(u8 *mac_buf, u32 mac_lo, u16 mac_hi)
@@ -6228,14 +6347,20 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 	bp->link_params.lane_config =
 		SHMEM_RD(bp, dev_info.port_hw_config[port].lane_config);
 
-	bp->link_params.speed_cap_mask =
+	bp->link_params.speed_cap_mask[0] =
 		SHMEM_RD(bp,
 			 dev_info.port_hw_config[port].speed_capability_mask);
-
-	bp->port.link_config =
+	bp->link_params.speed_cap_mask[1] =
+		SHMEM_RD(bp,
+			 dev_info.port_hw_config[port].speed_capability_mask2);
+	bp->port.link_config[0] =
 		SHMEM_RD(bp, dev_info.port_feature_config[port].link_config);
 
+	bp->port.link_config[1] =
+		SHMEM_RD(bp, dev_info.port_feature_config[port].link_config2);
 
+	bp->link_params.multi_phy_config =
+		SHMEM_RD(bp, dev_info.port_hw_config[port].multi_phy_config);
 	/* If the device is capable of WoL, set the default state according
 	 * to the HW
 	 */
@@ -6244,11 +6369,12 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 		   (config & PORT_FEATURE_WOL_ENABLED));
 
 	BNX2X_DEV_INFO("lane_config 0x%08x"
-		       "  speed_cap_mask 0x%08x  link_config 0x%08x\n",
+		       "speed_cap_mask0 0x%08x  link_config0 0x%08x\n",
 		       bp->link_params.lane_config,
-		       bp->link_params.speed_cap_mask, bp->port.link_config);
+		       bp->link_params.speed_cap_mask[0],
+		       bp->port.link_config[0]);
 
-	bp->link_params.switch_cfg |= (bp->port.link_config &
+	bp->link_params.switch_cfg = (bp->port.link_config[0] &
 				       PORT_FEATURE_CONNECTED_SWITCH_MASK);
 	bnx2x_phy_probe(&bp->link_params);
 	bnx2x_link_settings_supported(bp, bp->link_params.switch_cfg);
diff --git a/drivers/net/bnx2x/bnx2x_reg.h b/drivers/net/bnx2x/bnx2x_reg.h
index 398cf55..f0a6956 100644
--- a/drivers/net/bnx2x/bnx2x_reg.h
+++ b/drivers/net/bnx2x/bnx2x_reg.h
@@ -4964,6 +4964,8 @@
 #define MDIO_SERDES_DIGITAL_A_1000X_CONTROL2_PRL_DT_EN			0x0001
 #define MDIO_SERDES_DIGITAL_A_1000X_CONTROL2_AN_FST_TMR 		0x0040
 #define MDIO_SERDES_DIGITAL_A_1000X_STATUS1			0x14
+#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SGMII			0x0001
+#define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_LINK			0x0002
 #define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_DUPLEX			0x0004
 #define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SPEED_MASK			0x0018
 #define MDIO_SERDES_DIGITAL_A_1000X_STATUS1_SPEED_SHIFT 		3
@@ -5192,6 +5194,8 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_XS_8706_REG_BANK_RX3	0x80ec
 #define MDIO_XS_8706_REG_BANK_RXA	0x80fc
 
+#define MDIO_XS_REG_8073_RX_CTRL_PCIE	0x80FA
+
 #define MDIO_AN_DEVAD			0x7
 /*ieee*/
 #define MDIO_AN_REG_CTRL		0x0000
@@ -5227,6 +5231,27 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_AN_REG_8481_AUX_CTRL		0xfff8
 #define MDIO_AN_REG_8481_LEGACY_SHADOW		0xfffc
 
+/* BCM84823 only */
+#define MDIO_CTL_DEVAD			0x1e
+#define MDIO_CTL_REG_84823_MEDIA		0x401a
+#define MDIO_CTL_REG_84823_MEDIA_MAC_MASK		0x0018
+	/* These pins configure the BCM84823 interface to MAC after reset. */
+#define MDIO_CTL_REG_84823_CTRL_MAC_XFI			0x0008
+#define MDIO_CTL_REG_84823_MEDIA_MAC_XAUI_M		0x0010
+	/* These pins configure the BCM84823 interface to Line after reset. */
+#define MDIO_CTL_REG_84823_MEDIA_LINE_MASK		0x0060
+#define MDIO_CTL_REG_84823_MEDIA_LINE_XAUI_L		0x0020
+#define MDIO_CTL_REG_84823_MEDIA_LINE_XFI		0x0040
+	/* When this pin is active high during reset, 10GBASE-T core is power
+	 * down, When it is active low the 10GBASE-T is power up
+	 */
+#define MDIO_CTL_REG_84823_MEDIA_COPPER_CORE_DOWN	0x0080
+#define MDIO_CTL_REG_84823_MEDIA_PRIORITY_MASK		0x0100
+#define MDIO_CTL_REG_84823_MEDIA_PRIORITY_COPPER	0x0000
+#define MDIO_CTL_REG_84823_MEDIA_PRIORITY_FIBER		0x0100
+#define MDIO_CTL_REG_84823_MEDIA_FIBER_1G			0x1000
+
+
 #define IGU_FUNC_BASE			0x0400
 
 #define IGU_ADDR_MSIX			0x0000
-- 
1.7.1




