From: Geoff Levand <geoffrey.levand@am.sony.com>
Subject: [patch 2/2] net/ps3: Add support for gelic link negotiation
Date: Tue, 1 Dec 2009 14:15:58 -0800
Message-ID: <4B15959E.7070708@am.sony.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"cbe-oss-dev@ozlabs.org" <cbe-oss-dev@ozlabs.org>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:31520 "EHLO
	TX2EHSOBE008.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430AbZLAWQk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Dec 2009 17:16:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


From: Hideyuki Sasaki <Hideyuki_Sasaki@hq.scei.sony.co.jp>

Add ethtool_ops.set_settings support to the PS3 gelic network driver.
Allows manual setting of ethernet link speed.

Signed-off-by: Hideyuki Sasaki <xhide@rd.scei.sony.co.jp>
Signed-off-by: Geoff Levand <geoffrey.levand@am.sony.com>
---
 drivers/net/ps3_gelic_net.c |   72 ++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/ps3_gelic_net.h |    2 +
 2 files changed, 72 insertions(+), 2 deletions(-)

--- a/drivers/net/ps3_gelic_net.c
+++ b/drivers/net/ps3_gelic_net.c
@@ -107,6 +107,24 @@ static void gelic_card_get_ether_port_st
 	}
 }
 
+static int gelic_card_set_link_mode(struct gelic_card *card, int mode)
+{
+	int status;
+	u64 v1, v2;
+
+	status = lv1_net_control(bus_id(card), dev_id(card),
+				 GELIC_LV1_SET_NEGOTIATION_MODE,
+				 GELIC_LV1_PHY_ETHERNET_0, mode, 0, &v1, &v2);
+	if (status) {
+		pr_info("%s: failed setting negotiation mode %d\n", __func__,
+			status);
+		return -EBUSY;
+	}
+
+	card->link_mode = mode;
+	return 0;
+}
+
 void gelic_card_up(struct gelic_card *card)
 {
 	pr_debug("%s: called\n", __func__);
@@ -1244,14 +1262,58 @@ static int gelic_ether_get_settings(stru
 	cmd->supported = SUPPORTED_TP | SUPPORTED_Autoneg |
 			SUPPORTED_10baseT_Half | SUPPORTED_10baseT_Full |
 			SUPPORTED_100baseT_Half | SUPPORTED_100baseT_Full |
-			SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full;
+			SUPPORTED_1000baseT_Full;
 	cmd->advertising = cmd->supported;
-	cmd->autoneg = AUTONEG_ENABLE; /* always enabled */
+	if (card->link_mode & GELIC_LV1_ETHER_AUTO_NEG) {
+		cmd->autoneg = AUTONEG_ENABLE;
+	} else {
+		cmd->autoneg = AUTONEG_DISABLE;
+		cmd->advertising &= ~ADVERTISED_Autoneg;
+	}
 	cmd->port = PORT_TP;
 
 	return 0;
 }
 
+static int gelic_ether_set_settings(struct net_device *netdev,
+				    struct ethtool_cmd *cmd)
+{
+	struct gelic_card *card = netdev_card(netdev);
+	u64 mode;
+	int ret;
+
+	if (cmd->autoneg == AUTONEG_ENABLE) {
+		mode = GELIC_LV1_ETHER_AUTO_NEG;
+	} else {
+		switch (cmd->speed) {
+		case SPEED_10:
+			mode = GELIC_LV1_ETHER_SPEED_10;
+			break;
+		case SPEED_100:
+			mode = GELIC_LV1_ETHER_SPEED_100;
+			break;
+		case SPEED_1000:
+			mode = GELIC_LV1_ETHER_SPEED_1000;
+			break;
+		default:
+			return -EINVAL;
+		}
+		if (cmd->duplex == DUPLEX_FULL)
+			mode |= GELIC_LV1_ETHER_FULL_DUPLEX;
+		else if (cmd->speed == SPEED_1000) {
+			pr_info("1000 half duplex is not supported.\n");
+			return -EINVAL;
+		}
+	}
+
+	ret = gelic_card_set_link_mode(card, mode);
+
+	if (ret)
+		return ret;
+
+	return 0;
+}
+
 u32 gelic_net_get_rx_csum(struct net_device *netdev)
 {
 	struct gelic_card *card = netdev_card(netdev);
@@ -1349,6 +1411,7 @@ done:
 static const struct ethtool_ops gelic_ether_ethtool_ops = {
 	.get_drvinfo	= gelic_net_get_drvinfo,
 	.get_settings	= gelic_ether_get_settings,
+	.set_settings	= gelic_ether_set_settings,
 	.get_link	= ethtool_op_get_link,
 	.get_tx_csum	= ethtool_op_get_tx_csum,
 	.set_tx_csum	= ethtool_op_set_tx_csum,
@@ -1657,6 +1720,8 @@ static int __devinit ps3_gelic_driver_pr
 	/* get internal vlan info */
 	gelic_card_get_vlan_info(card);
 
+	card->link_mode = GELIC_LV1_ETHER_AUTO_NEG;
+
 	/* setup interrupt */
 	result = lv1_net_set_interrupt_status_indicator(bus_id(card),
 							dev_id(card),
@@ -1773,6 +1838,9 @@ static int ps3_gelic_driver_remove(struc
 	struct net_device *netdev0;
 	pr_debug("%s: called\n", __func__);
 
+	/* set auto-negotiation */
+	gelic_card_set_link_mode(card, GELIC_LV1_ETHER_AUTO_NEG);
+
 #ifdef CONFIG_GELIC_WIRELESS
 	gelic_wl_driver_remove(card);
 #endif
--- a/drivers/net/ps3_gelic_net.h
+++ b/drivers/net/ps3_gelic_net.h
@@ -307,6 +307,8 @@ struct gelic_card {
 	atomic_t users;
 
 	u64 ether_port_status;
+	int link_mode;
+
 	/* original address returned by kzalloc */
 	void *unalign;
 

