From: Roger Luethi <rl@hellgate.ch>
Subject: [1/3] via-rhine: suspend/resume support
Date: Sun, 8 Aug 2004 16:02:47 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040808140247.GA8542@k3.hellgate.ch>
References: <20040808140216.GA8181@k3.hellgate.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20040808140216.GA8181@k3.hellgate.ch>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

From: Arkadiusz Miskiewicz

Signed-off-by: Arkadiusz Miskiewicz <arekm@pld-linux.org>
Signed-off-by: Roger Luethi <rl@hellgate.ch>

--- linux-2.6.8-rc2-mm1/drivers/net/via-rhine.c	2004-07-30 19:19:19.000000000 +0200
+++ linux-2.6.8-rc2/drivers/net/via-rhine.c	2004-08-06 19:19:07.931310552 +0200
@@ -485,6 +485,9 @@
 	dma_addr_t tx_bufs_dma;
 
 	struct pci_dev *pdev;
+#ifdef CONFIG_PM
+	long pioaddr;
+#endif
 	struct net_device_stats stats;
 	spinlock_t lock;
 
@@ -825,6 +828,9 @@
 	dev->base_addr = ioaddr;
 	rp = netdev_priv(dev);
 	rp->quirks = quirks;
+#ifdef CONFIG_PM
+	rp->pioaddr = pioaddr;
+#endif
 
 	/* Get chip registers into a sane state */
 	rhine_power_init(dev);
@@ -1951,11 +1957,70 @@
 
 }
 
+#ifdef CONFIG_PM
+static int rhine_suspend(struct pci_dev *pdev, u32 state)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct rhine_private *rp = netdev_priv(dev);
+	unsigned long flags;
+
+	if (!netif_running(dev))
+		return 0;
+
+	netif_device_detach(dev);
+	pci_save_state(pdev, pdev->saved_config_space);
+
+	spin_lock_irqsave(&rp->lock, flags);
+	rhine_shutdown(&pdev->dev);
+	spin_unlock_irqrestore(&rp->lock, flags);
+
+	return 0;
+}
+
+static int rhine_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+	struct rhine_private *rp = netdev_priv(dev);
+	unsigned long flags;
+	int ret;
+
+	if (!netif_running(dev))
+		return 0;
+
+	ret = pci_set_power_state(pdev, 0);
+	if (debug > 1)
+		printk(KERN_INFO "%s: Entering power state D0 %s (%d).\n",
+			dev->name, ret ? "failed" : "succeeded", ret);
+
+	pci_restore_state(pdev, pdev->saved_config_space);
+
+	spin_lock_irqsave(&rp->lock, flags);
+#ifdef USE_MMIO
+	enable_mmio(rp->pioaddr, rp->quirks);
+#endif
+	rhine_power_init(dev);
+	free_tbufs(dev);
+	free_rbufs(dev);
+	alloc_tbufs(dev);
+	alloc_rbufs(dev);
+	init_registers(dev);
+	spin_unlock_irqrestore(&rp->lock, flags);
+	
+	netif_device_attach(dev);
+
+	return 0;
+}
+#endif /* CONFIG_PM */
+
 static struct pci_driver rhine_driver = {
 	.name		= DRV_NAME,
 	.id_table	= rhine_pci_tbl,
 	.probe		= rhine_init_one,
 	.remove		= __devexit_p(rhine_remove_one),
+#ifdef CONFIG_PM
+	.suspend	= rhine_suspend,
+	.resume		= rhine_resume,
+#endif /* CONFIG_PM */
 	.driver = {
 		.shutdown = rhine_shutdown,
 	}
