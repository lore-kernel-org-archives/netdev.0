From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: [PATCH v3] macb: Add support of the netpoll API
Date: Mon,  4 May 2009 13:54:44 +0200
Message-ID: <1241438084-17350-1-git-send-email-haavard.skinnemoen@atmel.com>
References: <20090421.015414.259541482.davem@davemloft.net>
Cc: thomas.petazzoni@free-electrons.com, michael@free-electrons.com,
	netdev@vger.kernel.org,
	Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.atmel.no ([80.232.32.139]:62322 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753554AbZEDLyx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2009 07:54:53 -0400
In-Reply-To: <20090421.015414.259541482.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

With this patch in place, I'm successfully able to use the netconsole
mechanism with the Calao USB-A9263 board, which uses the AT91SAM9263
CPU, which in terms of Ethernet controller is supported by the macb
driver.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
[haavard.skinnemoen@atmel.com: disable_irq() -> local_irq_save()]
[haavard.skinnemoen@atmel.com: convert to net_device_ops]
Signed-off-by: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
---
This should apply to the current tree with the net_device_ops change
applied. Sorry about the delay.

 drivers/net/macb.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index e82aee4..7222659 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -599,6 +599,21 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling receive - used by netconsole and other diagnostic tools
+ * to allow network i/o with interrupts disabled.
+ */
+static void macb_poll_controller(struct net_device *dev)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	macb_interrupt(dev->irq, dev);
+	local_irq_restore(flags);
+}
+#endif
+
 static int macb_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct macb *bp = netdev_priv(dev);
@@ -1094,6 +1109,9 @@ static const struct net_device_ops macb_netdev_ops = {
 	.ndo_validate_addr	= eth_validate_addr,
 	.ndo_change_mtu		= eth_change_mtu,
 	.ndo_set_mac_address	= eth_mac_addr,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_poll_controller	= macb_poll_controller,
+#endif
 };
 
 static int __init macb_probe(struct platform_device *pdev)
-- 
1.6.0.4

