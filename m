From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH net-next #2 26/39] de2104x: stop using net_device.{base_addr, irq}.
Date: Fri,  6 Apr 2012 12:06:40 +0200
Message-ID: <3cebeb3c55c12a033d30603baf34d449df75d2c1.1333704409.git.romieu@fr.zoreil.com>
References: <1333704408.git.romieu@fr.zoreil.com>
Cc: "David Miller" <davem@davemloft.net>,
	Grant Grundler <grundler@parisc-linux.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:43489 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1756049Ab2DFKKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Apr 2012 06:10:43 -0400
In-Reply-To: <1333704408.git.romieu@fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Grant Grundler <grundler@parisc-linux.org>
---
 drivers/net/ethernet/dec/tulip/de2104x.c |   34 ++++++++++++++---------------
 1 files changed, 16 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/dec/tulip/de2104x.c b/drivers/net/ethernet/dec/tulip/de2104x.c
index 68f1c39..61cc093 100644
--- a/drivers/net/ethernet/dec/tulip/de2104x.c
+++ b/drivers/net/ethernet/dec/tulip/de2104x.c
@@ -1380,6 +1380,7 @@ static void de_free_rings (struct de_private *de)
 static int de_open (struct net_device *dev)
 {
 	struct de_private *de = netdev_priv(dev);
+	const int irq = de->pdev->irq;
 	int rc;
 
 	netif_dbg(de, ifup, dev, "enabling interface\n");
@@ -1394,10 +1395,9 @@ static int de_open (struct net_device *dev)
 
 	dw32(IntrMask, 0);
 
-	rc = request_irq(dev->irq, de_interrupt, IRQF_SHARED, dev->name, dev);
+	rc = request_irq(irq, de_interrupt, IRQF_SHARED, dev->name, dev);
 	if (rc) {
-		netdev_err(dev, "IRQ %d request failure, err=%d\n",
-			   dev->irq, rc);
+		netdev_err(dev, "IRQ %d request failure, err=%d\n", irq, rc);
 		goto err_out_free;
 	}
 
@@ -1413,7 +1413,7 @@ static int de_open (struct net_device *dev)
 	return 0;
 
 err_out_free_irq:
-	free_irq(dev->irq, dev);
+	free_irq(irq, dev);
 err_out_free:
 	de_free_rings(de);
 	return rc;
@@ -1434,7 +1434,7 @@ static int de_close (struct net_device *dev)
 	netif_carrier_off(dev);
 	spin_unlock_irqrestore(&de->lock, flags);
 
-	free_irq(dev->irq, dev);
+	free_irq(de->pdev->irq, dev);
 
 	de_free_rings(de);
 	de_adapter_sleep(de);
@@ -1444,6 +1444,7 @@ static int de_close (struct net_device *dev)
 static void de_tx_timeout (struct net_device *dev)
 {
 	struct de_private *de = netdev_priv(dev);
+	const int irq = de->pdev->irq;
 
 	netdev_dbg(dev, "NIC status %08x mode %08x sia %08x desc %u/%u/%u\n",
 		   dr32(MacStatus), dr32(MacMode), dr32(SIAStatus),
@@ -1451,7 +1452,7 @@ static void de_tx_timeout (struct net_device *dev)
 
 	del_timer_sync(&de->media_timer);
 
-	disable_irq(dev->irq);
+	disable_irq(irq);
 	spin_lock_irq(&de->lock);
 
 	de_stop_hw(de);
@@ -1459,12 +1460,12 @@ static void de_tx_timeout (struct net_device *dev)
 	netif_carrier_off(dev);
 
 	spin_unlock_irq(&de->lock);
-	enable_irq(dev->irq);
+	enable_irq(irq);
 
 	/* Update the error counts. */
 	__de_get_stats(de);
 
-	synchronize_irq(dev->irq);
+	synchronize_irq(irq);
 	de_clean_rings(de);
 
 	de_init_rings(de);
@@ -2024,8 +2025,6 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 		goto err_out_res;
 	}
 
-	dev->irq = pdev->irq;
-
 	/* obtain and check validity of PCI I/O address */
 	pciaddr = pci_resource_start(pdev, 1);
 	if (!pciaddr) {
@@ -2050,7 +2049,6 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 		       pciaddr, pci_name(pdev));
 		goto err_out_res;
 	}
-	dev->base_addr = (unsigned long) regs;
 	de->regs = regs;
 
 	de_adapter_wake(de);
@@ -2078,11 +2076,9 @@ static int __devinit de_init_one (struct pci_dev *pdev,
 		goto err_out_iomap;
 
 	/* print info about board and interface just registered */
-	netdev_info(dev, "%s at 0x%lx, %pM, IRQ %d\n",
+	netdev_info(dev, "%s at %p, %pM, IRQ %d\n",
 		    de->de21040 ? "21040" : "21041",
-		    dev->base_addr,
-		    dev->dev_addr,
-		    dev->irq);
+		    regs, dev->dev_addr, pdev->irq);
 
 	pci_set_drvdata(pdev, dev);
 
@@ -2130,9 +2126,11 @@ static int de_suspend (struct pci_dev *pdev, pm_message_t state)
 
 	rtnl_lock();
 	if (netif_running (dev)) {
+		const int irq = pdev->irq;
+
 		del_timer_sync(&de->media_timer);
 
-		disable_irq(dev->irq);
+		disable_irq(irq);
 		spin_lock_irq(&de->lock);
 
 		de_stop_hw(de);
@@ -2141,12 +2139,12 @@ static int de_suspend (struct pci_dev *pdev, pm_message_t state)
 		netif_carrier_off(dev);
 
 		spin_unlock_irq(&de->lock);
-		enable_irq(dev->irq);
+		enable_irq(irq);
 
 		/* Update the error counts. */
 		__de_get_stats(de);
 
-		synchronize_irq(dev->irq);
+		synchronize_irq(irq);
 		de_clean_rings(de);
 
 		de_adapter_sleep(de);
-- 
1.7.7.6
