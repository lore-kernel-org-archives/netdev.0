From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 39/39] ipw2100: remove useless tests in the PCI device remove path.
Date: Fri,  6 Apr 2012 12:06:53 +0200
Message-ID: <6165c337223fb787abc2dfc1f8c5605ec3ba9950.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43482 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756015Ab2DFKKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:40 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Everything has been set up in the PCI probe function.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Stanislav Yakovlev <stas.yakovlev@gmail.com>
---
 drivers/net/wireless/ipw2x00/ipw2100.c |   56 +++++++++++++++-----------------
 1 files changed, 26 insertions(+), 30 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index 3352993..3c06c6b 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -6421,50 +6421,46 @@ out:
 static void __devexit ipw2100_pci_remove_one(struct pci_dev *pci_dev)
 {
 	struct ipw2100_priv *priv = pci_get_drvdata(pci_dev);
-	struct net_device *dev;
+	struct net_device *dev = priv->net_dev;
 
-	if (priv) {
-		mutex_lock(&priv->action_mutex);
+	mutex_lock(&priv->action_mutex);
 
-		priv->status &= ~STATUS_INITIALIZED;
+	priv->status &= ~STATUS_INITIALIZED;
 
-		dev = priv->net_dev;
-		sysfs_remove_group(&pci_dev->dev.kobj,
-				   &ipw2100_attribute_group);
+	sysfs_remove_group(&pci_dev->dev.kobj, &ipw2100_attribute_group);
 
 #ifdef CONFIG_PM
-		if (ipw2100_firmware.version)
-			ipw2100_release_firmware(priv, &ipw2100_firmware);
+	if (ipw2100_firmware.version)
+		ipw2100_release_firmware(priv, &ipw2100_firmware);
 #endif
-		/* Take down the hardware */
-		ipw2100_down(priv);
+	/* Take down the hardware */
+	ipw2100_down(priv);
 
-		/* Release the mutex so that the network subsystem can
-		 * complete any needed calls into the driver... */
-		mutex_unlock(&priv->action_mutex);
+	/* Release the mutex so that the network subsystem can
+	 * complete any needed calls into the driver... */
+	mutex_unlock(&priv->action_mutex);
 
-		/* Unregister the device first - this results in close()
-		 * being called if the device is open.  If we free storage
-		 * first, then close() will crash. */
-		unregister_netdev(dev);
+	/* Unregister the device first - this results in close()
+	 * being called if the device is open.  If we free storage
+	 * first, then close() will crash.
+	 * FIXME: remove the comment above. */
+	unregister_netdev(dev);
 
-		ipw2100_kill_works(priv);
+	ipw2100_kill_works(priv);
 
-		ipw2100_queues_free(priv);
+	ipw2100_queues_free(priv);
 
-		/* Free potential debugging firmware snapshot */
-		ipw2100_snapshot_free(priv);
+	/* Free potential debugging firmware snapshot */
+	ipw2100_snapshot_free(priv);
 
-		if (dev->irq)
-			free_irq(dev->irq, priv);
+	free_irq(dev->irq, priv);
 
-		pci_iounmap(pci_dev, priv->ioaddr);
+	pci_iounmap(pci_dev, priv->ioaddr);
 
-		/* wiphy_unregister needs to be here, before free_libipw */
-		wiphy_unregister(priv->ieee->wdev.wiphy);
-		kfree(priv->ieee->bg_band.channels);
-		free_libipw(dev, 0);
-	}
+	/* wiphy_unregister needs to be here, before free_libipw */
+	wiphy_unregister(priv->ieee->wdev.wiphy);
+	kfree(priv->ieee->bg_band.channels);
+	free_libipw(dev, 0);
 
 	pci_release_regions(pci_dev);
 	pci_disable_device(pci_dev);
-- 
1.7.7.6
