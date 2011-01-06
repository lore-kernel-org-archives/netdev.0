From: Sakari Ailus <sakari.ailus@iki.fi>
Subject: [PATCH 3/3] tlan: add suspend/resume support
Date: Thu,  6 Jan 2011 20:50:17 +0200
Message-ID: <1294339817-31434-3-git-send-email-sakari.ailus@iki.fi>
References: <4D260ED0.5040301@iki.fi>
 <1294339817-31434-1-git-send-email-sakari.ailus@iki.fi>
 <1294339817-31434-2-git-send-email-sakari.ailus@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-68.nebula.fi ([83.145.220.68]:52984 "EHLO
	smtp-68.nebula.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753455Ab1AFS7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 13:59:12 -0500
Received: from hillosipuli.localdomain (nblzone-211-213.nblnetworks.fi [83.145.211.213])
	(using TLSv1 with cipher ADH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp-68.nebula.fi (Postfix) with ESMTP id A566343F0B46
	for <netdev@vger.kernel.org>; Thu,  6 Jan 2011 20:50:20 +0200 (EET)
Received: from retiisi.localdomain (unknown [192.168.3.254])
	by hillosipuli.localdomain (Postfix) with ESMTP id 02F036009D
	for <netdev@vger.kernel.org>; Thu,  6 Jan 2011 20:50:17 +0200 (EET)
Received: from masiina.localdomain (masiina.localdomain [192.168.1.1])
	by retiisi.localdomain (Postfix) with ESMTP id 963B720D07
	for <netdev@vger.kernel.org>; Thu,  6 Jan 2011 20:50:17 +0200 (EET)
Received: from masiina.localdomain (localhost [127.0.0.1])
	by masiina.localdomain (8.14.3/8.14.3/Debian-5+lenny1) with ESMTP id p06IoH39031478
	for <netdev@vger.kernel.org>; Thu, 6 Jan 2011 20:50:17 +0200
Received: (from sakke@localhost)
	by masiina.localdomain (8.14.3/8.14.3/Submit) id p06IoHDH031477
	for netdev@vger.kernel.org; Thu, 6 Jan 2011 20:50:17 +0200
In-Reply-To: <1294339817-31434-2-git-send-email-sakari.ailus@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add suspend/resume support to tlan driver. This allows not unloading the
driver over suspend/resume.

Also, start (or now, wake) the queue after resetting the adapter --- not the
other way around.

Signed-off-by: Sakari Ailus <sakari.ailus@iki.fi>
---
 drivers/net/tlan.c |   88 ++++++++++++++++++++++++++++++++++++++++++---------
 1 files changed, 72 insertions(+), 16 deletions(-)

diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 090ce21..bbb0b12 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -168,6 +168,7 @@
  *
  *	v1.15a Dec 15 2008   - Remove bbuf support, it doesn't work anyway.
  *	v1.16  Jan 6  2011   - Make checkpatch.pl happy.
+ *	v1.17  Jan 6  2011   - Add suspend/resume support.
  *
  ******************************************************************************/
 
@@ -219,7 +220,7 @@ module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "ThunderLAN debug mask");
 
 static	const char tlan_signature[] = "TLAN";
-static  const char tlan_banner[] = "ThunderLAN driver v1.16\n";
+static  const char tlan_banner[] = "ThunderLAN driver v1.17\n";
 static  int tlan_have_pci;
 static  int tlan_have_eisa;
 
@@ -462,11 +463,79 @@ static void __devexit tlan_remove_one(struct pci_dev *pdev)
 	pci_set_drvdata(pdev, NULL);
 }
 
+static void tlan_start(struct net_device *dev)
+{
+	tlan_reset_lists(dev);
+	/* NOTE: It might not be necessary to read the stats before a
+	   reset if you don't care what the values are.
+	*/
+	tlan_read_and_clear_stats(dev, TLAN_IGNORE);
+	tlan_reset_adapter(dev);
+	netif_wake_queue(dev);
+}
+
+static void tlan_stop(struct net_device *dev)
+{
+	struct tlan_priv *priv = netdev_priv(dev);
+
+	tlan_read_and_clear_stats(dev, TLAN_RECORD);
+	outl(TLAN_HC_AD_RST, dev->base_addr + TLAN_HOST_CMD);
+	/* Reset and power down phy */
+	tlan_reset_adapter(dev);
+	if (priv->timer.function != NULL) {
+		del_timer_sync(&priv->timer);
+		priv->timer.function = NULL;
+	}
+}
+
+#ifdef CONFIG_PM
+
+static int tlan_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+
+	if (netif_running(dev))
+		tlan_stop(dev);
+
+	netif_device_detach(dev);
+	pci_save_state(pdev);
+	pci_disable_device(pdev);
+	pci_wake_from_d3(pdev, false);
+	pci_set_power_state(pdev, PCI_D3hot);
+
+	return 0;
+}
+
+static int tlan_resume(struct pci_dev *pdev)
+{
+	struct net_device *dev = pci_get_drvdata(pdev);
+
+	pci_set_power_state(pdev, PCI_D0);
+	pci_restore_state(pdev);
+	pci_enable_wake(pdev, 0, 0);
+	netif_device_attach(dev);
+
+	if (netif_running(dev))
+		tlan_start(dev);
+
+	return 0;
+}
+
+#else /* CONFIG_PM */
+
+#define tlan_suspend   NULL
+#define tlan_resume    NULL
+
+#endif /* CONFIG_PM */
+
+
 static struct pci_driver tlan_driver = {
 	.name		= "tlan",
 	.id_table	= tlan_pci_tbl,
 	.probe		= tlan_init_one,
 	.remove		= __devexit_p(tlan_remove_one),
+	.suspend	= tlan_suspend,
+	.resume		= tlan_resume,
 };
 
 static int __init tlan_probe(void)
@@ -965,14 +1034,8 @@ static int tlan_open(struct net_device *dev)
 	}
 
 	init_timer(&priv->timer);
-	netif_start_queue(dev);
 
-	/* NOTE: It might not be necessary to read the stats before a
-	   reset if you don't care what the values are.
-	*/
-	tlan_reset_lists(dev);
-	tlan_read_and_clear_stats(dev, TLAN_IGNORE);
-	tlan_reset_adapter(dev);
+	tlan_start(dev);
 
 	TLAN_DBG(TLAN_DEBUG_GNRL, "%s: Opened.  TLAN Chip Rev: %x\n",
 		 dev->name, priv->tlan_rev);
@@ -1243,15 +1306,8 @@ static int tlan_close(struct net_device *dev)
 {
 	struct tlan_priv *priv = netdev_priv(dev);
 
-	netif_stop_queue(dev);
 	priv->neg_be_verbose = 0;
-
-	tlan_read_and_clear_stats(dev, TLAN_RECORD);
-	outl(TLAN_HC_AD_RST, dev->base_addr + TLAN_HOST_CMD);
-	if (priv->timer.function != NULL) {
-		del_timer_sync(&priv->timer);
-		priv->timer.function = NULL;
-	}
+	tlan_stop(dev);
 
 	free_irq(dev->irq, dev);
 	tlan_free_lists(dev);
-- 
1.5.6.5

