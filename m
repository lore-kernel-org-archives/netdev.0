From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 6/6] bnx2x: Fix ethtool advertisement
Date: Tue, 6 Sep 2011 09:47:25 +0300
Message-ID: <1315291645.28564.20.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3538 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752961Ab1IFGrh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Sep 2011 02:47:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Enable changing advertisement settings via ethtool and fix flow-control advertisement when autoneg flow-control is disabled.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_ethtool.c |   45 +++++++++++++++++++++++++++++++++---
 drivers/net/bnx2x/bnx2x_main.c    |    6 +++++
 2 files changed, 47 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_ethtool.c b/drivers/net/bnx2x/bnx2x_ethtool.c
index 2218630..6aa94d3 100644
--- a/drivers/net/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/bnx2x/bnx2x_ethtool.c
@@ -363,13 +363,50 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 		}
 
 		/* advertise the requested speed and duplex if supported */
-		cmd->advertising &= bp->port.supported[cfg_idx];
+		if (cmd->advertising & ~(bp->port.supported[cfg_idx])) {
+			DP(NETIF_MSG_LINK, "Advertisement parameters "
+					   "are not supported\n");
+			return -EINVAL;
+		}
 
 		bp->link_params.req_line_speed[cfg_idx] = SPEED_AUTO_NEG;
-		bp->link_params.req_duplex[cfg_idx] = DUPLEX_FULL;
-		bp->port.advertising[cfg_idx] |= (ADVERTISED_Autoneg |
+		bp->link_params.req_duplex[cfg_idx] = cmd->duplex;
+		bp->port.advertising[cfg_idx] = (ADVERTISED_Autoneg |
 					 cmd->advertising);
+		if (cmd->advertising) {
+
+			bp->link_params.speed_cap_mask[cfg_idx] = 0;
+			if (cmd->advertising & ADVERTISED_10baseT_Half) {
+				bp->link_params.speed_cap_mask[cfg_idx] |=
+				PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_HALF;
+			}
+			if (cmd->advertising & ADVERTISED_10baseT_Full)
+				bp->link_params.speed_cap_mask[cfg_idx] |=
+				PORT_HW_CFG_SPEED_CAPABILITY_D0_10M_FULL;
 
+			if (cmd->advertising & ADVERTISED_100baseT_Full)
+				bp->link_params.speed_cap_mask[cfg_idx] |=
+				PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL;
+
+			if (cmd->advertising & ADVERTISED_100baseT_Half) {
+				bp->link_params.speed_cap_mask[cfg_idx] |=
+				     PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF;
+			}
+			if (cmd->advertising & ADVERTISED_1000baseT_Half) {
+				bp->link_params.speed_cap_mask[cfg_idx] |=
+					PORT_HW_CFG_SPEED_CAPABILITY_D0_1G;
+			}
+			if (cmd->advertising & (ADVERTISED_1000baseT_Full |
+						ADVERTISED_1000baseKX_Full))
+				bp->link_params.speed_cap_mask[cfg_idx] |=
+					PORT_HW_CFG_SPEED_CAPABILITY_D0_1G;
+
+			if (cmd->advertising & (ADVERTISED_10000baseT_Full |
+						ADVERTISED_10000baseKX4_Full |
+						ADVERTISED_10000baseKR_Full))
+				bp->link_params.speed_cap_mask[cfg_idx] |=
+					PORT_HW_CFG_SPEED_CAPABILITY_D0_10G;
+		}
 	} else { /* forced speed */
 		/* advertise the requested speed and duplex if supported */
 		switch (speed) {
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index f74582a..42c7be1 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -2125,6 +2125,12 @@ static int bnx2x_set_spio(struct bnx2x *bp, int spio_num, u32 mode)
 void bnx2x_calc_fc_adv(struct bnx2x *bp)
 {
 	u8 cfg_idx = bnx2x_get_link_cfg_idx(bp);
+	if (bp->link_params.req_flow_ctrl[cfg_idx] != BNX2X_FLOW_CTRL_AUTO) {
+		bp->port.advertising[cfg_idx] &= ~(ADVERTISED_Asym_Pause |
+						   ADVERTISED_Pause);
+		return;
+	}
+
 	switch (bp->link_vars.ieee_fc &
 		MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_MASK) {
 	case MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_NONE:
-- 
1.7.1
