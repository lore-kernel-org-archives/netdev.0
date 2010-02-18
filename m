From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 04/12] tg3: Allow phylib flowctrl changes
 anytime
Date: Wed, 17 Feb 2010 17:16:57 -0800
Message-ID: <1266455825-16150-5-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3068 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754537Ab0BRBRU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 20:17:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch loosens the restriction that the phylib interface must be up
and running to change the flow control parameters.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   94 +++++++++++++++++++++++++++++-----------------------
 1 files changed, 52 insertions(+), 42 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index f08e4b8..11ee44b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -10093,56 +10093,66 @@ static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam
 	int err = 0;
 
 	if (tp->tg3_flags3 & TG3_FLG3_USE_PHYLIB) {
-		if (!(tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED))
-			return -EAGAIN;
+		u32 newadv;
+		struct phy_device *phydev;
 
-		if (epause->autoneg) {
-			u32 newadv;
-			struct phy_device *phydev;
+		phydev = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR];
 
-			phydev = tp->mdio_bus->phy_map[TG3_PHY_MII_ADDR];
+		if (!(phydev->supported & SUPPORTED_Pause) ||
+		    (!(phydev->supported & SUPPORTED_Asym_Pause) &&
+		     ((epause->rx_pause && !epause->tx_pause) ||
+		      (!epause->rx_pause && epause->tx_pause))))
+			return -EINVAL;
 
-			if (epause->rx_pause) {
-				if (epause->tx_pause)
-					newadv = ADVERTISED_Pause;
-				else
-					newadv = ADVERTISED_Pause |
-						 ADVERTISED_Asym_Pause;
-			} else if (epause->tx_pause) {
-				newadv = ADVERTISED_Asym_Pause;
+		tp->link_config.flowctrl = 0;
+		if (epause->rx_pause) {
+			tp->link_config.flowctrl |= FLOW_CTRL_RX;
+
+			if (epause->tx_pause) {
+				tp->link_config.flowctrl |= FLOW_CTRL_TX;
+				newadv = ADVERTISED_Pause;
 			} else
-				newadv = 0;
-
-			if (tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED) {
-				u32 oldadv = phydev->advertising &
-					     (ADVERTISED_Pause |
-					      ADVERTISED_Asym_Pause);
-				if (oldadv != newadv) {
-					phydev->advertising &=
-						~(ADVERTISED_Pause |
-						  ADVERTISED_Asym_Pause);
-					phydev->advertising |= newadv;
-					err = phy_start_aneg(phydev);
+				newadv = ADVERTISED_Pause |
+					 ADVERTISED_Asym_Pause;
+		} else if (epause->tx_pause) {
+			tp->link_config.flowctrl |= FLOW_CTRL_TX;
+			newadv = ADVERTISED_Asym_Pause;
+		} else
+			newadv = 0;
+
+		if (epause->autoneg)
+			tp->tg3_flags |= TG3_FLAG_PAUSE_AUTONEG;
+		else
+			tp->tg3_flags &= ~TG3_FLAG_PAUSE_AUTONEG;
+
+		if (tp->tg3_flags3 & TG3_FLG3_PHY_CONNECTED) {
+			u32 oldadv = phydev->advertising &
+				     (ADVERTISED_Pause | ADVERTISED_Asym_Pause);
+			if (oldadv != newadv) {
+				phydev->advertising &=
+					~(ADVERTISED_Pause |
+					  ADVERTISED_Asym_Pause);
+				phydev->advertising |= newadv;
+				if (phydev->autoneg) {
+					/*
+					 * Always renegotiate the link to
+					 * inform our link partner of our
+					 * flow control settings, even if the
+					 * flow control is forced.  Let
+					 * tg3_adjust_link() do the final
+					 * flow control setup.
+					 */
+					return phy_start_aneg(phydev);
 				}
-			} else {
-				tp->link_config.advertising &=
-						~(ADVERTISED_Pause |
-						  ADVERTISED_Asym_Pause);
-				tp->link_config.advertising |= newadv;
 			}
-		} else {
-			if (epause->rx_pause)
-				tp->link_config.flowctrl |= FLOW_CTRL_RX;
-			else
-				tp->link_config.flowctrl &= ~FLOW_CTRL_RX;
-
-			if (epause->tx_pause)
-				tp->link_config.flowctrl |= FLOW_CTRL_TX;
-			else
-				tp->link_config.flowctrl &= ~FLOW_CTRL_TX;
 
-			if (netif_running(dev))
+			if (!epause->autoneg)
 				tg3_setup_flow_control(tp, 0, 0);
+		} else {
+			tp->link_config.orig_advertising &=
+					~(ADVERTISED_Pause |
+					  ADVERTISED_Asym_Pause);
+			tp->link_config.orig_advertising |= newadv;
 		}
 	} else {
 		int irq_sync = 0;
-- 
1.6.4.4


