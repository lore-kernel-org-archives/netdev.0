From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH for 2.6.25 2/2] [NET] ucc_geth: add support for netpoll
Date: Fri, 1 Feb 2008 16:22:54 +0300
Message-ID: <20080201132254.GB1790@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf8
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Li Yang <leoli@freescale.com>, Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:33428 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755828AbYBANWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2008 08:22:51 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds netpoll support for the QE UCC Gigabit Ethernet
driver. Tested using netconsole and KGDBoE.

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---

Just resending this.

 drivers/net/ucc_geth.c |   20 ++++++++++++++++++++
 1 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index e41da46..fba0811 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3666,6 +3666,23 @@ static irqreturn_t ucc_geth_irq_handler(int irq, void *info)
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
+	int irq = ugeth->ug_info->uf_info.irq;
+
+	disable_irq(irq);
+	ucc_geth_irq_handler(irq, dev);
+	enable_irq(irq);
+}
+#endif /* CONFIG_NET_POLL_CONTROLLER */
+
 /* Called when something needs to use the ethernet device */
 /* Returns 0 for success. */
 static int ucc_geth_open(struct net_device *dev)
@@ -4008,6 +4025,9 @@ static int ucc_geth_probe(struct of_device* ofdev, const struct of_device_id *ma
 #ifdef CONFIG_UGETH_NAPI
 	netif_napi_add(dev, &ugeth->napi, ucc_geth_poll, UCC_GETH_DEV_WEIGHT);
 #endif				/* CONFIG_UGETH_NAPI */
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	dev->poll_controller = ucc_netpoll;
+#endif
 	dev->stop = ucc_geth_close;
 //    dev->change_mtu = ucc_geth_change_mtu;
 	dev->mtu = 1500;
-- 
1.5.2.2
