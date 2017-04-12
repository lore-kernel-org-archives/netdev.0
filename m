From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH 5/8] ftgmac100: Add netpoll support
Date: Thu, 13 Apr 2017 08:44:40 +1000
Message-ID: <20170412224443.17906-6-benh@kernel.crashing.org>
References: <20170412224443.17906-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:33747 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752851AbdDLWro (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Apr 2017 18:47:44 -0400
In-Reply-To: <20170412224443.17906-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just call the interrupt handler with interrupts locally disabled

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index ded3447..e71b9c4 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1593,6 +1593,17 @@ static int ftgmac100_set_features(struct net_device *netdev,
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
@@ -1603,6 +1614,9 @@ static const struct net_device_ops ftgmac100_netdev_ops = {
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
