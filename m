From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH] ucc_geth: add support for netpoll
Date: Thu, 11 Oct 2007 16:48:42 +0400
Message-ID: <20071011124842.GB13963@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: leoli@freescale.com, linuxppc-dev@ozlabs.org,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:62409 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1758455AbXJKMsY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 08:48:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds netpoll support for the QE UCC Gigabit Ethernet
driver. The approach is very similar to the gianfar driver.

Tested using netconsole.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---
 drivers/net/ucc_geth.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 18a6f48..06807ce 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3691,6 +3691,22 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
 	return IRQ_HANDLED;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+/*
+ * Polling 'interrupt' - used by things like netconsole to send skbs
+ * without having to re-enable interrupts. It's not called while
+ * the interrupt routine is executing.
+ */
+static void ucc_netpoll(struct net_device *dev)
+{
+	struct ucc_geth_private *ugeth = netdev_priv(dev);
+
+	disable_irq(ugeth->ug_info->uf_info.irq);
+	ucc_geth_irq_handler(ugeth->ug_info->uf_info.irq, dev);
+	enable_irq(ugeth->ug_info->uf_info.irq);
+}
+#endif /* CONFIG_NET_POLL_CONTROLLER */
+
 /* Called when something needs to use the ethernet device */
 /* Returns 0 for success. */
 static int ucc_geth_open(struct net_device *dev)
@@ -3969,6 +3985,9 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 	dev->poll = ucc_geth_poll;
 	dev->weight = UCC_GETH_DEV_WEIGHT;
 #endif				/* CONFIG_UGETH_NAPI */
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = ucc_netpoll;
+#endif
 	dev->stop = ucc_geth_close;
 	dev->get_stats = ucc_geth_get_stats;
 //    dev->change_mtu = ucc_geth_change_mtu;
-- 
1.5.0.6

