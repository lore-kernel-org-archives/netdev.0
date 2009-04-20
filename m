From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: [PATCH] macb: Add support of the netpoll API
Date: Mon, 20 Apr 2009 12:57:07 +0200
Message-ID: <1240225027-14721-1-git-send-email-haavard.skinnemoen@atmel.com>
References: <20090417.043945.67766586.davem@davemloft.net>
Cc: thomas.petazzoni@free-electrons.com, michael@free-electrons.com,
	netdev@vger.kernel.org,
	Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.atmel.no ([80.232.32.139]:58190 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752075AbZDTK5U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 20 Apr 2009 06:57:20 -0400
In-Reply-To: <20090417.043945.67766586.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

With this patch in place, I'm successfully able to use the netconsole
mechanism with the Calao USB-A9263 board, which uses the AT91SAM9263
CPU, which in terms of Ethernet controller is supported by the macb
driver.

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
[haavard.skinnemoen@atmel.com: disable_irq() -> local_irq_save()]
Signed-off-by: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
---
 drivers/net/macb.c |   18 ++++++++++++++++++
 1 files changed, 18 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macb.c b/drivers/net/macb.c
index f505010..dd7a1c3 100644
--- a/drivers/net/macb.c
+++ b/drivers/net/macb.c
@@ -615,6 +615,21 @@ static irqreturn_t macb_interrupt(int irq, void *dev_id)
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
@@ -1183,6 +1198,9 @@ static int __init macb_probe(struct platform_device *pdev)
 	dev->do_ioctl = macb_ioctl;
 	netif_napi_add(dev, &bp->napi, macb_poll, 64);
 	dev->ethtool_ops = &macb_ethtool_ops;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = macb_poll_controller;
+#endif
 
 	dev->base_addr = regs->start;
 
-- 
1.6.0.4

