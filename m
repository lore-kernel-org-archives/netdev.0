From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 01/10] bnx2x: PFC fix
Date: Wed, 4 Apr 2012 14:28:54 +0300
Message-ID: <1333538942-9904-2-git-send-email-yanivr@broadcom.com>
References: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2061 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756090Ab2DDJ3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 05:29:35 -0400
In-Reply-To: <1333538942-9904-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a problem in which PFC frames are not honored, due to incorrect link
attributes synchronization following PMF migration, and verify PFC XON is not
stuck from previous link change.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   18 +++++++++++++++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |    1 +
 2 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index efa557b..7e2ebba 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -1371,7 +1371,14 @@ static void bnx2x_update_pfc_xmac(struct link_params *params,
 		pfc1_val |= XMAC_PFC_CTRL_HI_REG_PFC_REFRESH_EN |
 			XMAC_PFC_CTRL_HI_REG_PFC_STATS_EN |
 			XMAC_PFC_CTRL_HI_REG_RX_PFC_EN |
-			XMAC_PFC_CTRL_HI_REG_TX_PFC_EN;
+			XMAC_PFC_CTRL_HI_REG_TX_PFC_EN |
+			XMAC_PFC_CTRL_HI_REG_FORCE_PFC_XON;
+		/* Write pause and PFC registers */
+		REG_WR(bp, xmac_base + XMAC_REG_PAUSE_CTRL, pause_val);
+		REG_WR(bp, xmac_base + XMAC_REG_PFC_CTRL, pfc0_val);
+		REG_WR(bp, xmac_base + XMAC_REG_PFC_CTRL_HI, pfc1_val);
+		pfc1_val &= ~XMAC_PFC_CTRL_HI_REG_FORCE_PFC_XON;
+
 	}
 
 	/* Write pause and PFC registers */
@@ -6843,6 +6850,12 @@ int bnx2x_link_update(struct link_params *params, struct link_vars *vars)
 			  SINGLE_MEDIA_DIRECT(params)) &&
 			 (phy_vars[active_external_phy].fault_detected == 0));
 
+	/* Update the PFC configuration in case it was changed */
+	if (params->feature_config_flags & FEATURE_CONFIG_PFC_ENABLED)
+		vars->link_status |= LINK_STATUS_PFC_ENABLED;
+	else
+		vars->link_status &= ~LINK_STATUS_PFC_ENABLED;
+
 	if (vars->link_up)
 		rc = bnx2x_update_link_up(params, vars, link_10g_plus);
 	else
@@ -12049,6 +12062,9 @@ int bnx2x_phy_init(struct link_params *params, struct link_vars *vars)
 
 	bnx2x_emac_init(params, vars);
 
+	if (params->feature_config_flags & FEATURE_CONFIG_PFC_ENABLED)
+		vars->link_status |= LINK_STATUS_PFC_ENABLED;
+
 	if (params->num_phys == 0) {
 		DP(NETIF_MSG_LINK, "No phy found for initialization !!\n");
 		return -EINVAL;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index ab0a250..ecc7fa6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -5354,6 +5354,7 @@
 #define XMAC_CTRL_REG_TX_EN					 (0x1<<0)
 #define XMAC_PAUSE_CTRL_REG_RX_PAUSE_EN				 (0x1<<18)
 #define XMAC_PAUSE_CTRL_REG_TX_PAUSE_EN				 (0x1<<17)
+#define XMAC_PFC_CTRL_HI_REG_FORCE_PFC_XON			 (0x1<<1)
 #define XMAC_PFC_CTRL_HI_REG_PFC_REFRESH_EN			 (0x1<<0)
 #define XMAC_PFC_CTRL_HI_REG_PFC_STATS_EN			 (0x1<<3)
 #define XMAC_PFC_CTRL_HI_REG_RX_PFC_EN				 (0x1<<4)
-- 
1.7.7.1
