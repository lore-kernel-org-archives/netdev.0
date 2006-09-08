From: Valerie Henson <val_henson@linux.intel.com>
Subject: [patch 08/10] [TULIP] Handle pci_enable_device() errors in resume
Date: Fri, 08 Sep 2006 11:15:41 -0700
Message-ID: <20060908182024.372546000@linux.intel.com>
References: <20060908181533.771856000@linux.intel.com>
Cc: Valerie Henson <val_henson@linux.intel.com>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751089AbWIHSWA@vger.kernel.org>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Disposition: inline; filename=tulip-handle-pci_enable_device-errors
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Valerie Henson <val_henson@linux.intel.com>
Cc: Jeff Garzik <jeff@garzik.org>

---
 drivers/net/tulip/de2104x.c     |   16 ++++++++++------
 drivers/net/tulip/tulip_core.c  |    5 ++++-
 drivers/net/tulip/winbond-840.c |   12 ++++++++----
 3 files changed, 22 insertions(+), 11 deletions(-)

--- linux-2.6.18-rc4-mm1-tulip.orig/drivers/net/tulip/tulip_core.c
+++ linux-2.6.18-rc4-mm1-tulip/drivers/net/tulip/tulip_core.c
@@ -1780,7 +1780,10 @@ static int tulip_resume(struct pci_dev *
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 
-	pci_enable_device(pdev);
+	if ((retval = pci_enable_device(pdev))) {
+		printk (KERN_ERR "tulip: pci_enable_device failed in resume\n");
+		return retval;
+	}
 
 	if ((retval = request_irq(dev->irq, &tulip_interrupt, IRQF_SHARED, dev->name, dev))) {
 		printk (KERN_ERR "tulip: request_irq failed in resume\n");
--- linux-2.6.18-rc4-mm1-tulip.orig/drivers/net/tulip/winbond-840.c
+++ linux-2.6.18-rc4-mm1-tulip/drivers/net/tulip/winbond-840.c
@@ -1626,14 +1626,18 @@ static int w840_resume (struct pci_dev *
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
 	struct netdev_private *np = netdev_priv(dev);
+	int retval = 0;
 
 	rtnl_lock();
 	if (netif_device_present(dev))
 		goto out; /* device not suspended */
 	if (netif_running(dev)) {
-		pci_enable_device(pdev);
-	/*	pci_power_on(pdev); */
-
+		if ((retval = pci_enable_device(pdev))) {
+			printk (KERN_ERR
+				"%s: pci_enable_device failed in resume\n",
+				dev->name);
+			goto out;
+		}
 		spin_lock_irq(&np->lock);
 		iowrite32(1, np->base_addr+PCIBusCfg);
 		ioread32(np->base_addr+PCIBusCfg);
@@ -1651,7 +1655,7 @@ static int w840_resume (struct pci_dev *
 	}
 out:
 	rtnl_unlock();
-	return 0;
+	return retval;
 }
 #endif
 
--- linux-2.6.18-rc4-mm1-tulip.orig/drivers/net/tulip/de2104x.c
+++ linux-2.6.18-rc4-mm1-tulip/drivers/net/tulip/de2104x.c
@@ -2138,17 +2138,21 @@ static int de_resume (struct pci_dev *pd
 {
 	struct net_device *dev = pci_get_drvdata (pdev);
 	struct de_private *de = dev->priv;
+	int retval = 0;
 
 	rtnl_lock();
 	if (netif_device_present(dev))
 		goto out;
-	if (netif_running(dev)) {
-		pci_enable_device(pdev);
-		de_init_hw(de);
-		netif_device_attach(dev);
-	} else {
-		netif_device_attach(dev);
+	if (!netif_running(dev))
+		goto out_attach;
+	if ((retval = pci_enable_device(pdev))) {
+		printk (KERN_ERR "%s: pci_enable_device failed in resume\n",
+			dev->name);
+		goto out;
 	}
+	de_init_hw(de);
+out_attach:
+	netif_device_attach(dev);
 out:
 	rtnl_unlock();
 	return 0;

--
