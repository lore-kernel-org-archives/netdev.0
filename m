From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v2 5/9] ftgmac100: Add netpoll support
Date: Thu, 13 Apr 2017 14:39:12 +1000
Message-ID: <20170413043916.7793-6-benh@kernel.crashing.org>
References: <20170413043916.7793-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:57836 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751697AbdDMEkA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 13 Apr 2017 00:40:00 -0400
In-Reply-To: <20170413043916.7793-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just call the interrupt handler with interrupts locally disabled

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 08fe228..b1fb729 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1586,6 +1586,17 @@ static int ftgmac100_set_features(struct net_device *netdev,
 	return 0;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static void ftgmac100_poll_controller(struct net_device *netdev)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	ftgmac100_interrupt(netdev->irq, netdev);
+	local_irq_restore(flags);
+}
+#endif
+
 static const struct net_device_ops ftgmac100_netdev_ops = {
 	.ndo_open		= ftgmac100_open,
 	.ndo_stop		= ftgmac100_stop,
@@ -1596,6 +1607,9 @@ static const struct net_device_ops ftgmac100_netdev_ops = {
 	.ndo_tx_timeout		= ftgmac100_tx_timeout,
 	.ndo_set_rx_mode	= ftgmac100_set_rx_mode,
 	.ndo_set_features	= ftgmac100_set_features,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= ftgmac100_poll_controller,
+#endif
 };
 
 static int ftgmac100_setup_mdio(struct net_device *netdev)
-- 
2.9.3
