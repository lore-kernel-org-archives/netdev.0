From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 1/5] bnx2x: Generalize KR work-around
Date: Sun, 22 Sep 2013 14:59:22 +0300
Message-ID: <1379851166-11959-2-git-send-email-yanivr@broadcom.com>
References: <1379851166-11959-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Yaniv Rosner" <yanivr@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4919 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753159Ab3IVL77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 22 Sep 2013 07:59:59 -0400
In-Reply-To: <1379851166-11959-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, in case of KR link down, the driver would reset the PHY and restart
auto negotiation only when old Warpcore microcode was used (below D108).
This patch comes to generalize this by keep trying to restart KR link,
regardless of Warpcore microcode, since it was found that it solves another link
issue which source is a link-partner. As part of this change, the signal
detect is no longer a condition to apply the work-around to cover this new case.
Like before, as long as the link is down, AN will be restarted every 2 seconds.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   32 +++++----------------
 1 files changed, 8 insertions(+), 24 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index d60a2ea..12ef8e1 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -3715,7 +3715,6 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 					struct link_params *params,
 					struct link_vars *vars) {
 	u16 lane, i, cl72_ctrl, an_adv = 0;
-	u16 ucode_ver;
 	struct bnx2x *bp = params->bp;
 	static struct bnx2x_reg_set reg_set[] = {
 		{MDIO_WC_DEVAD, MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X2, 0x7},
@@ -3806,15 +3805,7 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 
 	/* Advertise pause */
 	bnx2x_ext_phy_set_pause(params, phy, vars);
-	/* Set KR Autoneg Work-Around flag for Warpcore version older than D108
-	 */
-	bnx2x_cl45_read(bp, phy, MDIO_WC_DEVAD,
-			MDIO_WC_REG_UC_INFO_B1_VERSION, &ucode_ver);
-	if (ucode_ver < 0xd108) {
-		DP(NETIF_MSG_LINK, "Enable AN KR work-around. WC ver:0x%x\n",
-			       ucode_ver);
-		vars->rx_tx_asic_rst = MAX_KR_LINK_RETRY;
-	}
+	vars->rx_tx_asic_rst = MAX_KR_LINK_RETRY;
 	bnx2x_cl45_read_or_write(bp, phy, MDIO_WC_DEVAD,
 				 MDIO_WC_REG_DIGITAL5_MISC7, 0x100);
 
@@ -4347,20 +4338,14 @@ static void bnx2x_warpcore_config_runtime(struct bnx2x_phy *phy,
 	struct bnx2x *bp = params->bp;
 	u32 serdes_net_if;
 	u16 gp_status1 = 0, lnkup = 0, lnkup_kr = 0;
-	u16 lane = bnx2x_get_warpcore_lane(phy, params);
 
 	vars->turn_to_run_wc_rt = vars->turn_to_run_wc_rt ? 0 : 1;
 
 	if (!vars->turn_to_run_wc_rt)
 		return;
 
-	/* Return if there is no link partner */
-	if (!(bnx2x_warpcore_get_sigdet(phy, params))) {
-		DP(NETIF_MSG_LINK, "bnx2x_warpcore_get_sigdet false\n");
-		return;
-	}
-
 	if (vars->rx_tx_asic_rst) {
+		u16 lane = bnx2x_get_warpcore_lane(phy, params);
 		serdes_net_if = (REG_RD(bp, params->shmem_base +
 				offsetof(struct shmem_region, dev_info.
 				port_hw_config[params->port].default_cfg)) &
@@ -4375,14 +4360,8 @@ static void bnx2x_warpcore_config_runtime(struct bnx2x_phy *phy,
 				/*10G KR*/
 			lnkup_kr = (gp_status1 >> (12+lane)) & 0x1;
 
-			DP(NETIF_MSG_LINK,
-				"gp_status1 0x%x\n", gp_status1);
-
 			if (lnkup_kr || lnkup) {
-					vars->rx_tx_asic_rst = 0;
-					DP(NETIF_MSG_LINK,
-					"link up, rx_tx_asic_rst 0x%x\n",
-					vars->rx_tx_asic_rst);
+				vars->rx_tx_asic_rst = 0;
 			} else {
 				/* Reset the lane to see if link comes up.*/
 				bnx2x_warpcore_reset_lane(bp, phy, 1);
@@ -5757,6 +5736,11 @@ static int bnx2x_warpcore_read_status(struct bnx2x_phy *phy,
 	rc = bnx2x_get_link_speed_duplex(phy, params, vars, link_up, gp_speed,
 					 duplex);
 
+	/* In case of KR link down, start up the recovering procedure */
+	if ((!link_up) && (phy->media_type == ETH_PHY_KR) &&
+	    (!(phy->flags & FLAGS_WC_DUAL_MODE)))
+		vars->rx_tx_asic_rst = MAX_KR_LINK_RETRY;
+
 	DP(NETIF_MSG_LINK, "duplex %x  flow_ctrl 0x%x link_status 0x%x\n",
 		   vars->duplex, vars->flow_ctrl, vars->link_status);
 	return rc;
-- 
1.7.1
