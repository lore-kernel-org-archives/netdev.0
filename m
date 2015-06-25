From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 2/9] bnx2x: Correct speed from baseT into KR.
Date: Thu, 25 Jun 2015 15:19:22 +0300
Message-ID: <1435234769-5625-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Yaniv Rosner <Yaniv.Rosner@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:36134 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750968AbbFYMUB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 08:20:01 -0400
In-Reply-To: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ethtool shows KR supported/advertised speeds incorrectly as baseT
in cases the board is in fact KR-base.

Signed-off-by: Yaniv Rosner <Yaniv.Rosner@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    | 55 ++++++++++++++++------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   | 10 ++--
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c   | 13 +++++
 3 files changed, 59 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 48ed005..733b0fc 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -257,14 +257,15 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 {
 	struct bnx2x *bp = netdev_priv(dev);
 	int cfg_idx = bnx2x_get_link_cfg_idx(bp);
+	u32 media_type;
 
 	/* Dual Media boards present all available port types */
 	cmd->supported = bp->port.supported[cfg_idx] |
 		(bp->port.supported[cfg_idx ^ 1] &
 		 (SUPPORTED_TP | SUPPORTED_FIBRE));
 	cmd->advertising = bp->port.advertising[cfg_idx];
-	if (bp->link_params.phy[bnx2x_get_cur_phy_idx(bp)].media_type ==
-	    ETH_PHY_SFP_1G_FIBER) {
+	media_type = bp->link_params.phy[bnx2x_get_cur_phy_idx(bp)].media_type;
+	if (media_type == ETH_PHY_SFP_1G_FIBER) {
 		cmd->supported &= ~(SUPPORTED_10000baseT_Full);
 		cmd->advertising &= ~(ADVERTISED_10000baseT_Full);
 	}
@@ -312,12 +313,26 @@ static int bnx2x_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 			cmd->lp_advertising |= ADVERTISED_100baseT_Full;
 		if (status & LINK_STATUS_LINK_PARTNER_1000THD_CAPABLE)
 			cmd->lp_advertising |= ADVERTISED_1000baseT_Half;
-		if (status & LINK_STATUS_LINK_PARTNER_1000TFD_CAPABLE)
-			cmd->lp_advertising |= ADVERTISED_1000baseT_Full;
+		if (status & LINK_STATUS_LINK_PARTNER_1000TFD_CAPABLE) {
+			if (media_type == ETH_PHY_KR) {
+				cmd->lp_advertising |=
+					ADVERTISED_1000baseKX_Full;
+			} else {
+				cmd->lp_advertising |=
+					ADVERTISED_1000baseT_Full;
+			}
+		}
 		if (status & LINK_STATUS_LINK_PARTNER_2500XFD_CAPABLE)
 			cmd->lp_advertising |= ADVERTISED_2500baseX_Full;
-		if (status & LINK_STATUS_LINK_PARTNER_10GXFD_CAPABLE)
-			cmd->lp_advertising |= ADVERTISED_10000baseT_Full;
+		if (status & LINK_STATUS_LINK_PARTNER_10GXFD_CAPABLE) {
+			if (media_type == ETH_PHY_KR) {
+				cmd->lp_advertising |=
+					ADVERTISED_10000baseKR_Full;
+			} else {
+				cmd->lp_advertising |=
+					ADVERTISED_10000baseT_Full;
+			}
+		}
 		if (status & LINK_STATUS_LINK_PARTNER_20GXFD_CAPABLE)
 			cmd->lp_advertising |= ADVERTISED_20000baseKR2_Full;
 	}
@@ -564,15 +579,20 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				return -EINVAL;
 			}
 
-			if (!(bp->port.supported[cfg_idx] &
-			      SUPPORTED_1000baseT_Full)) {
+			if (bp->port.supported[cfg_idx] &
+			     SUPPORTED_1000baseT_Full) {
+				advertising = (ADVERTISED_1000baseT_Full |
+					       ADVERTISED_TP);
+
+			} else if (bp->port.supported[cfg_idx] &
+				   SUPPORTED_1000baseKX_Full) {
+				advertising = ADVERTISED_1000baseKX_Full;
+			} else {
 				DP(BNX2X_MSG_ETHTOOL,
 				   "1G full not supported\n");
 				return -EINVAL;
 			}
 
-			advertising = (ADVERTISED_1000baseT_Full |
-				       ADVERTISED_TP);
 			break;
 
 		case SPEED_2500:
@@ -600,17 +620,22 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 				return -EINVAL;
 			}
 			phy_idx = bnx2x_get_cur_phy_idx(bp);
-			if (!(bp->port.supported[cfg_idx]
-			      & SUPPORTED_10000baseT_Full) ||
-			    (bp->link_params.phy[phy_idx].media_type ==
+			if ((bp->port.supported[cfg_idx] &
+			     SUPPORTED_10000baseT_Full) &&
+			    (bp->link_params.phy[phy_idx].media_type !=
 			     ETH_PHY_SFP_1G_FIBER)) {
+				advertising = (ADVERTISED_10000baseT_Full |
+					       ADVERTISED_FIBRE);
+			} else if (bp->port.supported[cfg_idx] &
+			       SUPPORTED_10000baseKR_Full) {
+				advertising = (ADVERTISED_10000baseKR_Full |
+					       ADVERTISED_FIBRE);
+			} else {
 				DP(BNX2X_MSG_ETHTOOL,
 				   "10G full not supported\n");
 				return -EINVAL;
 			}
 
-			advertising = (ADVERTISED_10000baseT_Full |
-				       ADVERTISED_FIBRE);
 			break;
 
 		default:
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index b287fc8..a0b03c2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -11493,7 +11493,9 @@ static const struct bnx2x_phy phy_warpcore = {
 			   SUPPORTED_100baseT_Half |
 			   SUPPORTED_100baseT_Full |
 			   SUPPORTED_1000baseT_Full |
+			   SUPPORTED_1000baseKX_Full |
 			   SUPPORTED_10000baseT_Full |
+			   SUPPORTED_10000baseKR_Full |
 			   SUPPORTED_20000baseKR2_Full |
 			   SUPPORTED_20000baseMLD2_Full |
 			   SUPPORTED_FIBRE |
@@ -11999,8 +12001,8 @@ static int bnx2x_populate_int_phy(struct bnx2x *bp, u32 shmem_base, u8 port,
 			break;
 		case PORT_HW_CFG_NET_SERDES_IF_KR:
 			phy->media_type = ETH_PHY_KR;
-			phy->supported &= (SUPPORTED_1000baseT_Full |
-					   SUPPORTED_10000baseT_Full |
+			phy->supported &= (SUPPORTED_1000baseKX_Full |
+					   SUPPORTED_10000baseKR_Full |
 					   SUPPORTED_FIBRE |
 					   SUPPORTED_Autoneg |
 					   SUPPORTED_Pause |
@@ -12018,8 +12020,8 @@ static int bnx2x_populate_int_phy(struct bnx2x *bp, u32 shmem_base, u8 port,
 			phy->media_type = ETH_PHY_KR;
 			phy->flags |= FLAGS_WC_DUAL_MODE;
 			phy->supported &= (SUPPORTED_20000baseKR2_Full |
-					   SUPPORTED_10000baseT_Full |
-					   SUPPORTED_1000baseT_Full |
+					   SUPPORTED_10000baseKR_Full |
+					   SUPPORTED_1000baseKX_Full |
 					   SUPPORTED_Autoneg |
 					   SUPPORTED_FIBRE |
 					   SUPPORTED_Pause |
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index a03a9f2..bf5f5df 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -11143,6 +11143,12 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 				bp->port.advertising[idx] |=
 					(ADVERTISED_1000baseT_Full |
 					 ADVERTISED_TP);
+			} else if (bp->port.supported[idx] &
+				   SUPPORTED_1000baseKX_Full) {
+				bp->link_params.req_line_speed[idx] =
+					SPEED_1000;
+				bp->port.advertising[idx] |=
+					ADVERTISED_1000baseKX_Full;
 			} else {
 				BNX2X_ERR("NVRAM config error. Invalid link_config 0x%x  speed_cap_mask 0x%x\n",
 				    link_config,
@@ -11175,6 +11181,13 @@ static void bnx2x_link_settings_requested(struct bnx2x *bp)
 				bp->port.advertising[idx] |=
 					(ADVERTISED_10000baseT_Full |
 						ADVERTISED_FIBRE);
+			} else if (bp->port.supported[idx] &
+				   SUPPORTED_10000baseKR_Full) {
+				bp->link_params.req_line_speed[idx] =
+					SPEED_10000;
+				bp->port.advertising[idx] |=
+					(ADVERTISED_10000baseKR_Full |
+						ADVERTISED_FIBRE);
 			} else {
 				BNX2X_ERR("NVRAM config error. Invalid link_config 0x%x  speed_cap_mask 0x%x\n",
 				    link_config,
-- 
1.9.3
