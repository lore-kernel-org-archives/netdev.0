From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next 7/7] via-rhine: rework suspend and resume.
Date: Sat, 7 Jan 2012 23:52:41 +0100
Message-ID: <20120107225241.GG25021@electric-eye.fr.zoreil.com>
References: <20120107224856.GA24928@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rl@hellgate.ch, Bjarke Istrup Pedersen <gurligebis@gentoo.org>,
	David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:50398 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751695Ab2AGXCC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Jan 2012 18:02:02 -0500
Content-Disposition: inline
In-Reply-To: <20120107224856.GA24928@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cover of 861ab44059350e5cab350238606cf8814abab93b.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/via/via-rhine.c |   41 ++++++++++++++++-----------------
 1 files changed, 20 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index e39802f..10b18eb 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -2291,17 +2291,18 @@ static void rhine_shutdown (struct pci_dev *pdev)
 
 	spin_unlock(&rp->lock);
 
-	/* Hit power state D3 (sleep) */
-	if (!avoid_D3)
+	if (system_state == SYSTEM_POWER_OFF && !avoid_D3) {
 		iowrite8(ioread8(ioaddr + StickyHW) | 0x03, ioaddr + StickyHW);
 
-	/* TODO: Check use of pci_enable_wake() */
-
+		pci_wake_from_d3(pdev, true);
+		pci_set_power_state(pdev, PCI_D3hot);
+	}
 }
 
-#ifdef CONFIG_PM
-static int rhine_suspend(struct pci_dev *pdev, pm_message_t state)
+#ifdef CONFIG_PM_SLEEP
+static int rhine_suspend(struct device *device)
 {
+	struct pci_dev *pdev = to_pci_dev(device);
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rhine_private *rp = netdev_priv(dev);
 
@@ -2313,28 +2314,21 @@ static int rhine_suspend(struct pci_dev *pdev, pm_message_t state)
 	napi_disable(&rp->napi);
 
 	netif_device_detach(dev);
-	pci_save_state(pdev);
 
 	rhine_shutdown(pdev);
 
 	return 0;
 }
 
-static int rhine_resume(struct pci_dev *pdev)
+static int rhine_resume(struct device *device)
 {
+	struct pci_dev *pdev = to_pci_dev(device);
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rhine_private *rp = netdev_priv(dev);
-	int ret;
 
 	if (!netif_running(dev))
 		return 0;
 
-	ret = pci_set_power_state(pdev, PCI_D0);
-	netif_info(rp, drv, dev, "Entering power state D0 %s (%d)\n",
-		   ret ? "failed" : "succeeded", ret);
-
-	pci_restore_state(pdev);
-
 #ifdef USE_MMIO
 	enable_mmio(rp->pioaddr, rp->quirks);
 #endif
@@ -2352,18 +2346,23 @@ static int rhine_resume(struct pci_dev *pdev)
 
 	return 0;
 }
-#endif /* CONFIG_PM */
+
+static SIMPLE_DEV_PM_OPS(rhine_pm_ops, rhine_suspend, rhine_resume);
+#define RHINE_PM_OPS	(&rhine_pm_ops)
+
+#else
+
+#define RHINE_PM_OPS	NULL
+
+#endif /* !CONFIG_PM_SLEEP */
 
 static struct pci_driver rhine_driver = {
 	.name		= DRV_NAME,
 	.id_table	= rhine_pci_tbl,
 	.probe		= rhine_init_one,
 	.remove		= __devexit_p(rhine_remove_one),
-#ifdef CONFIG_PM
-	.suspend	= rhine_suspend,
-	.resume		= rhine_resume,
-#endif /* CONFIG_PM */
-	.shutdown =	rhine_shutdown,
+	.shutdown	= rhine_shutdown,
+	.driver.pm	= RHINE_PM_OPS,
 };
 
 static struct dmi_system_id __initdata rhine_dmi_table[] = {
-- 
1.7.6.4
