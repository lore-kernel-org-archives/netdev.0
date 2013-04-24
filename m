From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 2/5] bnx2x: Allow RX/TX pause control in
 autoneg
Date: Wed, 24 Apr 2013 14:44:59 +0300
Message-ID: <1366803902-17870-3-git-send-email-yuvalmin@broadcom.com>
References: <1366803902-17870-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: ariele@broadcom.com, eilong@broadcom.com,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1044 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757853Ab3DXMq3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Apr 2013 08:46:29 -0400
In-Reply-To: <1366803902-17870-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yaniv Rosner <yanivr@broadcom.com>

Currently, when link is configured to auto-negotiate the flow control,
disabling RX/TX pause via ethtool doesn't work.

This fixes the behaviour, advertising asymmetric pause in case either one
is exclusively enabled.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c |  5 ++++-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c    | 14 ++++++++++----
 2 files changed, 14 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index 88e9b47..397537b 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1889,12 +1889,15 @@ static int bnx2x_set_pauseparam(struct net_device *dev,
 			bp->link_params.req_flow_ctrl[cfg_idx] =
 				BNX2X_FLOW_CTRL_AUTO;
 		}
-		bp->link_params.req_fc_auto_adv = BNX2X_FLOW_CTRL_NONE;
+		bp->link_params.req_fc_auto_adv = 0;
 		if (epause->rx_pause)
 			bp->link_params.req_fc_auto_adv |= BNX2X_FLOW_CTRL_RX;
 
 		if (epause->tx_pause)
 			bp->link_params.req_fc_auto_adv |= BNX2X_FLOW_CTRL_TX;
+
+		if (!bp->link_params.req_fc_auto_adv)
+			bp->link_params.req_fc_auto_adv |= BNX2X_FLOW_CTRL_NONE;
 	}
 
 	DP(BNX2X_MSG_ETHTOOL,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 40f58d7..9d64b98 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -3426,13 +3426,19 @@ static void bnx2x_calc_ieee_aneg_adv(struct bnx2x_phy *phy,
 
 	switch (phy->req_flow_ctrl) {
 	case BNX2X_FLOW_CTRL_AUTO:
-		if (params->req_fc_auto_adv == BNX2X_FLOW_CTRL_BOTH)
+		switch (params->req_fc_auto_adv) {
+		case BNX2X_FLOW_CTRL_BOTH:
 			*ieee_fc |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_BOTH;
-		else
+			break;
+		case BNX2X_FLOW_CTRL_RX:
+		case BNX2X_FLOW_CTRL_TX:
 			*ieee_fc |=
-			MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
+				MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
+			break;
+		default:
+			break;
+		}
 		break;
-
 	case BNX2X_FLOW_CTRL_TX:
 		*ieee_fc |= MDIO_COMBO_IEEE0_AUTO_NEG_ADV_PAUSE_ASYMMETRIC;
 		break;
-- 
1.8.1.227.g44fe835
