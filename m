From: Magnus Damm <magnus.damm@gmail.com>
Subject: [PATCH] net: add Runtime PM to the sh_eth driver
Date: Fri, 09 Oct 2009 19:20:04 +0900
Message-ID: <20091009102004.31062.83095.sendpatchset@rxone.opensource.se>
Cc: Magnus Damm <magnus.damm@gmail.com>, lethal@linux-sh.org,
	davem@davemloft.net, linux-sh@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f212.google.com ([209.85.217.212]:34743 "EHLO
	mail-gx0-f212.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760587AbZJIKZ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 06:25:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Magnus Damm <damm@opensource.se>

Add Runtime PM support to the sh_eth driver.

The clock to the ethernet hardware block will be
enabled as long as the network device is up.

Signed-off-by: Magnus Damm <damm@opensource.se>
Tested-by: Kuninori Morimoto <morimoto.kuninori@renesas.com>
---

 drivers/net/sh_eth.c |   35 +++++++++++++++++++++++++++++++++--
 drivers/net/sh_eth.h |    1 +
 2 files changed, 34 insertions(+), 2 deletions(-)

--- 0003/drivers/net/sh_eth.c
+++ work/drivers/net/sh_eth.c	2009-10-07 17:25:34.000000000 +0900
@@ -30,7 +30,7 @@
 #include <linux/phy.h>
 #include <linux/cache.h>
 #include <linux/io.h>
-
+#include <linux/pm_runtime.h>
 #include "sh_eth.h"
 
 /* There is CPU dependent code */
@@ -1012,6 +1012,8 @@ static int sh_eth_open(struct net_device
 	int ret = 0;
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 
+	pm_runtime_get_sync(&mdp->pdev->dev);
+
 	ret = request_irq(ndev->irq, &sh_eth_interrupt,
 #if defined(CONFIG_CPU_SUBTYPE_SH7763) || defined(CONFIG_CPU_SUBTYPE_SH7764)
 				IRQF_SHARED,
@@ -1048,6 +1050,7 @@ static int sh_eth_open(struct net_device
 
 out_free_irq:
 	free_irq(ndev->irq, ndev);
+	pm_runtime_put_sync(&mdp->pdev->dev);
 	return ret;
 }
 
@@ -1179,6 +1182,8 @@ static int sh_eth_close(struct net_devic
 	ringsize = sizeof(struct sh_eth_txdesc) * TX_RING_SIZE;
 	dma_free_coherent(NULL, ringsize, mdp->tx_ring, mdp->tx_desc_dma);
 
+	pm_runtime_put_sync(&mdp->pdev->dev);
+
 	return 0;
 }
 
@@ -1187,6 +1192,8 @@ static struct net_device_stats *sh_eth_g
 	struct sh_eth_private *mdp = netdev_priv(ndev);
 	u32 ioaddr = ndev->base_addr;
 
+	pm_runtime_get_sync(&mdp->pdev->dev);
+
 	mdp->stats.tx_dropped += ctrl_inl(ioaddr + TROCR);
 	ctrl_outl(0, ioaddr + TROCR);	/* (write clear) */
 	mdp->stats.collisions += ctrl_inl(ioaddr + CDCR);
@@ -1202,6 +1209,8 @@ static struct net_device_stats *sh_eth_g
 	mdp->stats.tx_carrier_errors += ctrl_inl(ioaddr + CNDCR);
 	ctrl_outl(0, ioaddr + CNDCR);	/* (write clear) */
 #endif
+	pm_runtime_put_sync(&mdp->pdev->dev);
+
 	return &mdp->stats;
 }
 
@@ -1410,6 +1419,9 @@ static int sh_eth_drv_probe(struct platf
 
 	mdp = netdev_priv(ndev);
 	spin_lock_init(&mdp->lock);
+	mdp->pdev = pdev;
+	pm_runtime_enable(&pdev->dev);
+	pm_runtime_resume(&pdev->dev);
 
 	pd = (struct sh_eth_plat_data *)(pdev->dev.platform_data);
 	/* get PHY ID */
@@ -1485,18 +1497,37 @@ static int sh_eth_drv_remove(struct plat
 	sh_mdio_release(ndev);
 	unregister_netdev(ndev);
 	flush_scheduled_work();
-
+	pm_runtime_disable(&pdev->dev);
 	free_netdev(ndev);
 	platform_set_drvdata(pdev, NULL);
 
 	return 0;
 }
 
+static int sh_eth_runtime_nop(struct device *dev)
+{
+	/*
+	 * Runtime PM callback shared between ->runtime_suspend()
+	 * and ->runtime_resume(). Simply returns success.
+	 *
+	 * This driver re-initializes all registers after
+	 * pm_runtime_get_sync() anyway so there is no need
+	 * to save and restore registers here.
+	 */
+	return 0;
+}
+
+static struct dev_pm_ops sh_eth_dev_pm_ops = {
+	.runtime_suspend = sh_eth_runtime_nop,
+	.runtime_resume = sh_eth_runtime_nop,
+};
+
 static struct platform_driver sh_eth_driver = {
 	.probe = sh_eth_drv_probe,
 	.remove = sh_eth_drv_remove,
 	.driver = {
 		   .name = CARDNAME,
+		   .pm = &sh_eth_dev_pm_ops,
 	},
 };
 
--- 0001/drivers/net/sh_eth.h
+++ work/drivers/net/sh_eth.h	2009-10-07 17:22:24.000000000 +0900
@@ -703,6 +703,7 @@ struct sh_eth_cpu_data {
 };
 
 struct sh_eth_private {
+	struct platform_device *pdev;
 	struct sh_eth_cpu_data *cd;
 	dma_addr_t rx_desc_dma;
 	dma_addr_t tx_desc_dma;
