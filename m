From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: [PATCH v3 5/9] ftgmac100: Add netpoll support
Date: Tue, 18 Apr 2017 08:37:02 +1000
Message-ID: <20170417223706.16483-6-benh@kernel.crashing.org>
References: <20170417223706.16483-1-benh@kernel.crashing.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:51407 "EHLO gate.crashing.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755275AbdDQWlK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Apr 2017 18:41:10 -0400
In-Reply-To: <20170417223706.16483-1-benh@kernel.crashing.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just call the interrupt handler with interrupts locally disabled

Signed-off-by: Benjamin Herrenschmidt <benh@kernel.crashing.org>
---
 drivers/net/ethernet/faraday/ftgmac100.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/faraday/ftgmac100.c b/drivers/net/ethernet/faraday/ftgmac100.c
index 40a03d5..f76765e 100644
--- a/drivers/net/ethernet/faraday/ftgmac100.c
+++ b/drivers/net/ethernet/faraday/ftgmac100.c
@@ -1588,6 +1588,17 @@ static int ftgmac100_set_features(struct net_device *netdev,
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
@@ -1598,6 +1609,9 @@ static const struct net_device_ops ftgmac100_netdev_ops = {
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
