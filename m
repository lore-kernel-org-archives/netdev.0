From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH RFC 2/2] tg3: Convert to get_pauseparamext
Date: Fri, 14 Oct 2011 13:54:02 -0700
Message-ID: <1318625642-9668-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	bhutchings@solarflare.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3473 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754191Ab1JNUyL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Oct 2011 16:54:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts the tg3 driver to the get_pauseparamext ethtool
command.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   28 ++++++++++++++++++++--------
 1 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index fe712f9..a7b7ddd 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -10576,24 +10576,36 @@ static int tg3_set_ringparam(struct net_device *dev, struct ethtool_ringparam *e
 	return err;
 }
 
-static void tg3_get_pauseparam(struct net_device *dev, struct ethtool_pauseparam *epause)
+static void tg3_get_pauseparamext(struct net_device *dev,
+				  struct ethtool_pauseparamext *epause)
 {
 	struct tg3 *tp = netdev_priv(dev);
 
-	epause->autoneg = !!tg3_flag(tp, PAUSE_AUTONEG);
+	epause->cfg.autoneg = !!tg3_flag(tp, PAUSE_AUTONEG);
+
+	if (tp->link_config.flowctrl & FLOW_CTRL_RX)
+		epause->cfg.rx_pause = 1;
+	else
+		epause->cfg.rx_pause = 0;
+
+	if (tp->link_config.flowctrl & FLOW_CTRL_TX)
+		epause->cfg.tx_pause = 1;
+	else
+		epause->cfg.tx_pause = 0;
 
 	if (tp->link_config.active_flowctrl & FLOW_CTRL_RX)
-		epause->rx_pause = 1;
+		epause->rx_pause_status = 1;
 	else
-		epause->rx_pause = 0;
+		epause->rx_pause_status = 0;
 
 	if (tp->link_config.active_flowctrl & FLOW_CTRL_TX)
-		epause->tx_pause = 1;
+		epause->tx_pause_status = 1;
 	else
-		epause->tx_pause = 0;
+		epause->tx_pause_status = 0;
 }
 
-static int tg3_set_pauseparam(struct net_device *dev, struct ethtool_pauseparam *epause)
+static int tg3_set_pauseparam(struct net_device *dev,
+			      struct ethtool_pauseparam *epause)
 {
 	struct tg3 *tp = netdev_priv(dev);
 	int err = 0;
@@ -11926,7 +11938,7 @@ static const struct ethtool_ops tg3_ethtool_ops = {
 	.set_eeprom		= tg3_set_eeprom,
 	.get_ringparam		= tg3_get_ringparam,
 	.set_ringparam		= tg3_set_ringparam,
-	.get_pauseparam		= tg3_get_pauseparam,
+	.get_pauseparamext	= tg3_get_pauseparamext,
 	.set_pauseparam		= tg3_set_pauseparam,
 	.self_test		= tg3_self_test,
 	.get_strings		= tg3_get_strings,
-- 
1.7.3.4
