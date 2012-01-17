From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 3/5] bnx2x: Remove 100Mb force speed for BCM84833
Date: Tue, 17 Jan 2012 14:33:27 +0200
Message-ID: <1326803609-25526-4-git-send-email-yanivr@broadcom.com>
References: <1326803609-25526-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3458 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753091Ab2AQKez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 05:34:55 -0500
In-Reply-To: <1326803609-25526-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove unsupported speed of 100Mb force for BCM84833 due to hardware limitation.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    7 ++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c   |   20 +++++++++++++++-----
 2 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index a688b9d..f99c6e3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -365,13 +365,18 @@ static int bnx2x_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	DP(NETIF_MSG_LINK, "cfg_idx = %x\n", cfg_idx);
 
 	if (cmd->autoneg == AUTONEG_ENABLE) {
+		u32 an_supported_speed = bp->port.supported[cfg_idx];
+		if (bp->link_params.phy[EXT_PHY1].type ==
+		    PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833)
+			an_supported_speed |= (SUPPORTED_100baseT_Half |
+					       SUPPORTED_100baseT_Full);
 		if (!(bp->port.supported[cfg_idx] & SUPPORTED_Autoneg)) {
 			DP(NETIF_MSG_LINK, "Autoneg not supported\n");
 			return -EINVAL;
 		}
 
 		/* advertise the requested speed and duplex if supported */
-		if (cmd->advertising & ~(bp->port.supported[cfg_idx])) {
+		if (cmd->advertising & ~an_supported_speed) {
 			DP(NETIF_MSG_LINK, "Advertisement parameters "
 					   "are not supported\n");
 			return -EINVAL;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index cc80637..1d1a809 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -9454,13 +9454,10 @@ static int bnx2x_848xx_cmn_config_init(struct bnx2x_phy *phy,
 			 an_1000_val);
 
 	/* set 100 speed advertisement */
-	if (((phy->req_line_speed == SPEED_AUTO_NEG) &&
+	if ((phy->req_line_speed == SPEED_AUTO_NEG) &&
 	     (phy->speed_cap_mask &
 	      (PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_FULL |
-	       PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF)) &&
-	     (phy->supported &
-	      (SUPPORTED_100baseT_Half |
-	       SUPPORTED_100baseT_Full)))) {
+	       PORT_HW_CFG_SPEED_CAPABILITY_D0_100M_HALF))) {
 		an_10_100_val |= (1<<7);
 		/* Enable autoneg and restart autoneg for legacy speeds */
 		autoneg_val |= (1<<9 | 1<<12);
@@ -11528,6 +11525,19 @@ static int bnx2x_populate_ext_phy(struct bnx2x *bp,
 	}
 	phy->mdio_ctrl = bnx2x_get_emac_base(bp, mdc_mdio_access, port);
 
+	if ((phy->type == PORT_HW_CFG_XGXS_EXT_PHY_TYPE_BCM84833) &&
+	    (phy->ver_addr)) {
+		/*
+		 * Remove 100Mb link supported for BCM84833 when phy fw
+		 * version lower than or equal to 1.39
+		 */
+		u32 raw_ver = REG_RD(bp, phy->ver_addr);
+		if (((raw_ver & 0x7F) <= 39) &&
+		    (((raw_ver & 0xF80) >> 7) <= 1))
+			phy->supported &= ~(SUPPORTED_100baseT_Half |
+					    SUPPORTED_100baseT_Full);
+	}
+
 	/*
 	 * In case mdc/mdio_access of the external phy is different than the
 	 * mdc/mdio access of the XGXS, a HW lock must be taken in each access
-- 
1.7.7.1
