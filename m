From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next] net: systemport: Check DSA notifier master against ourself
Date: Wed, 25 Oct 2017 18:01:05 -0700
Message-ID: <20171026010105.13931-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:51266 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751868AbdJZBBL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 21:01:11 -0400
Received: by mail-qt0-f193.google.com with SMTP id h4so2370220qtk.8
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 18:01:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Check that the master network device that is signaled through the DSA
notifier is actually going to be ourself, otherwise, we could just be
de-referencing garbage from other drivers.

Fixes: 84ff33eeb23d ("net: systemport: Establish DSA network device queue mapping")
Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 drivers/net/ethernet/broadcom/bcmsysport.c | 33 ++++++++++++++++--------------
 1 file changed, 18 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bcmsysport.c b/drivers/net/ethernet/broadcom/bcmsysport.c
index 1d9d5f986e14..dcee843d05d7 100644
--- a/drivers/net/ethernet/broadcom/bcmsysport.c
+++ b/drivers/net/ethernet/broadcom/bcmsysport.c
@@ -2046,6 +2046,21 @@ static u16 bcm_sysport_select_queue(struct net_device *dev, struct sk_buff *skb,
 	return tx_ring->index;
 }
 
+static const struct net_device_ops bcm_sysport_netdev_ops = {
+	.ndo_start_xmit		= bcm_sysport_xmit,
+	.ndo_tx_timeout		= bcm_sysport_tx_timeout,
+	.ndo_open		= bcm_sysport_open,
+	.ndo_stop		= bcm_sysport_stop,
+	.ndo_set_features	= bcm_sysport_set_features,
+	.ndo_set_rx_mode	= bcm_sysport_set_rx_mode,
+	.ndo_set_mac_address	= bcm_sysport_change_mac,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= bcm_sysport_poll_controller,
+#endif
+	.ndo_get_stats64	= bcm_sysport_get_stats64,
+	.ndo_select_queue	= bcm_sysport_select_queue,
+};
+
 static int bcm_sysport_map_queues(struct net_device *dev,
 				  struct dsa_notifier_register_info *info)
 {
@@ -2061,6 +2076,9 @@ static int bcm_sysport_map_queues(struct net_device *dev,
 	if (info->switch_number)
 		return 0;
 
+	if (dev->netdev_ops != &bcm_sysport_netdev_ops)
+		return 0;
+
 	port = info->port_number;
 	slave_dev = info->info.dev;
 
@@ -2112,21 +2130,6 @@ static int bcm_sysport_dsa_notifier(struct notifier_block *unused,
 	return notifier_from_errno(bcm_sysport_map_queues(info->master, info));
 }
 
-static const struct net_device_ops bcm_sysport_netdev_ops = {
-	.ndo_start_xmit		= bcm_sysport_xmit,
-	.ndo_tx_timeout		= bcm_sysport_tx_timeout,
-	.ndo_open		= bcm_sysport_open,
-	.ndo_stop		= bcm_sysport_stop,
-	.ndo_set_features	= bcm_sysport_set_features,
-	.ndo_set_rx_mode	= bcm_sysport_set_rx_mode,
-	.ndo_set_mac_address	= bcm_sysport_change_mac,
-#ifdef CONFIG_NET_POLL_CONTROLLER
-	.ndo_poll_controller	= bcm_sysport_poll_controller,
-#endif
-	.ndo_get_stats64	= bcm_sysport_get_stats64,
-	.ndo_select_queue	= bcm_sysport_select_queue,
-};
-
 #define REV_FMT	"v%2x.%02x"
 
 static const struct bcm_sysport_hw_params bcm_sysport_params[] = {
-- 
2.9.3
