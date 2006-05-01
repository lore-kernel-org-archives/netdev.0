From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH 5/5] orinoco: don't put PCI resource data to the network device
Date: Mon, 01 May 2006 02:13:33 -0400
Message-ID: <20060501061332.13342.71693.stgit@dv.roinet.com>
References: <20060501061324.13342.58195.stgit@dv.roinet.com>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:58848 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1751279AbWEAGNe
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 May 2006 02:13:34 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1FaRf3-0007Gb-LH
	for netdev@vger.kernel.org; Mon, 01 May 2006 02:13:33 -0400
To: netdev@vger.kernel.org, linville@tuxdriver.com
In-Reply-To: <20060501061324.13342.58195.stgit@dv.roinet.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Roskin <proski@gnu.org>

The resource data in the network device is intended for ISA and other
older busses, but not for PCI.  Don't put PCI data there.  Don't (ab)use
the network device for keeping the IRQ number.

Retire orinoco_pci_setup_netdev(), and print some minimal information to
the kernel log instead, identifying the network device and the driver
mostly to identify problems at startup.  Scripts should rely on sysfs.

Signed-off-by: Pavel Roskin <proski@gnu.org>
---

 drivers/net/wireless/orinoco_nortel.c |    5 +++--
 drivers/net/wireless/orinoco_pci.c    |    5 +++--
 drivers/net/wireless/orinoco_pci.h    |   26 --------------------------
 drivers/net/wireless/orinoco_plx.c    |    5 +++--
 drivers/net/wireless/orinoco_tmd.c    |    5 +++--
 5 files changed, 12 insertions(+), 34 deletions(-)

diff --git a/drivers/net/wireless/orinoco_nortel.c b/drivers/net/wireless/orinoco_nortel.c
index 1596182..74b9d5b 100644
--- a/drivers/net/wireless/orinoco_nortel.c
+++ b/drivers/net/wireless/orinoco_nortel.c
@@ -206,7 +206,6 @@ static int orinoco_nortel_init_one(struc
 		err = -EBUSY;
 		goto fail_irq;
 	}
-	orinoco_pci_setup_netdev(dev, pdev, 2);
 
 	err = orinoco_nortel_hw_init(card);
 	if (err) {
@@ -227,6 +226,8 @@ static int orinoco_nortel_init_one(struc
 	}
 
 	pci_set_drvdata(pdev, dev);
+	printk(KERN_DEBUG "%s: " DRIVER_NAME " at %s\n", dev->name,
+	       pci_name(pdev));
 
 	return 0;
 
@@ -265,7 +266,7 @@ static void __devexit orinoco_nortel_rem
 	iowrite16(0, card->bridge_io + 10);
 
 	unregister_netdev(dev);
-	free_irq(dev->irq, dev);
+	free_irq(pdev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
 	free_orinocodev(dev);
 	pci_iounmap(pdev, priv->hw.iobase);
diff --git a/drivers/net/wireless/orinoco_pci.c b/drivers/net/wireless/orinoco_pci.c
index df37b95..1c105f4 100644
--- a/drivers/net/wireless/orinoco_pci.c
+++ b/drivers/net/wireless/orinoco_pci.c
@@ -161,7 +161,6 @@ static int orinoco_pci_init_one(struct p
 		err = -EBUSY;
 		goto fail_irq;
 	}
-	orinoco_pci_setup_netdev(dev, pdev, 0);
 
 	err = orinoco_pci_cor_reset(priv);
 	if (err) {
@@ -176,6 +175,8 @@ static int orinoco_pci_init_one(struct p
 	}
 
 	pci_set_drvdata(pdev, dev);
+	printk(KERN_DEBUG "%s: " DRIVER_NAME " at %s\n", dev->name,
+	       pci_name(pdev));
 
 	return 0;
 
@@ -204,7 +205,7 @@ static void __devexit orinoco_pci_remove
 	struct orinoco_private *priv = netdev_priv(dev);
 
 	unregister_netdev(dev);
-	free_irq(dev->irq, dev);
+	free_irq(pdev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
 	free_orinocodev(dev);
 	pci_iounmap(pdev, priv->hw.iobase);
diff --git a/drivers/net/wireless/orinoco_pci.h b/drivers/net/wireless/orinoco_pci.h
index 4e8da4e..7eb1e08 100644
--- a/drivers/net/wireless/orinoco_pci.h
+++ b/drivers/net/wireless/orinoco_pci.h
@@ -18,32 +18,6 @@ struct orinoco_pci_card {
 	void __iomem *attr_io;
 };
 
-/* Set base address or memory range of the network device based on
- * the PCI device it's using.  Specify BAR of the "main" resource.
- * To be used after request_irq().  */
-static inline void orinoco_pci_setup_netdev(struct net_device *dev,
-					    struct pci_dev *pdev, int bar)
-{
-	char *range_type;
-	unsigned long start = pci_resource_start(pdev, bar);
-	unsigned long len = pci_resource_len(pdev, bar);
-	unsigned long flags = pci_resource_flags(pdev, bar);
-	unsigned long end = start + len - 1;
-
-	dev->irq = pdev->irq;
-	if (flags & IORESOURCE_IO) {
-		dev->base_addr = start;
-		range_type = "ports";
-	} else {
-		dev->mem_start = start;
-		dev->mem_end = end;
-		range_type = "memory";
-	}
-
-	printk(KERN_DEBUG PFX "%s: irq %d, %s 0x%lx-0x%lx\n",
-	       pci_name(pdev), pdev->irq, range_type, start, end);
-}
-
 #ifdef CONFIG_PM
 static int orinoco_pci_suspend(struct pci_dev *pdev, pm_message_t state)
 {
diff --git a/drivers/net/wireless/orinoco_plx.c b/drivers/net/wireless/orinoco_plx.c
index 7b94050..84f696c 100644
--- a/drivers/net/wireless/orinoco_plx.c
+++ b/drivers/net/wireless/orinoco_plx.c
@@ -245,7 +245,6 @@ static int orinoco_plx_init_one(struct p
 		err = -EBUSY;
 		goto fail_irq;
 	}
-	orinoco_pci_setup_netdev(dev, pdev, 2);
 
 	err = orinoco_plx_hw_init(card);
 	if (err) {
@@ -266,6 +265,8 @@ static int orinoco_plx_init_one(struct p
 	}
 
 	pci_set_drvdata(pdev, dev);
+	printk(KERN_DEBUG "%s: " DRIVER_NAME " at %s\n", dev->name,
+	       pci_name(pdev));
 
 	return 0;
 
@@ -301,7 +302,7 @@ static void __devexit orinoco_plx_remove
 	struct orinoco_pci_card *card = priv->card;
 
 	unregister_netdev(dev);
-	free_irq(dev->irq, dev);
+	free_irq(pdev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
 	free_orinocodev(dev);
 	pci_iounmap(pdev, priv->hw.iobase);
diff --git a/drivers/net/wireless/orinoco_tmd.c b/drivers/net/wireless/orinoco_tmd.c
index 0496663..d2b4dec 100644
--- a/drivers/net/wireless/orinoco_tmd.c
+++ b/drivers/net/wireless/orinoco_tmd.c
@@ -147,7 +147,6 @@ static int orinoco_tmd_init_one(struct p
 		err = -EBUSY;
 		goto fail_irq;
 	}
-	orinoco_pci_setup_netdev(dev, pdev, 2);
 
 	err = orinoco_tmd_cor_reset(priv);
 	if (err) {
@@ -162,6 +161,8 @@ static int orinoco_tmd_init_one(struct p
 	}
 
 	pci_set_drvdata(pdev, dev);
+	printk(KERN_DEBUG "%s: " DRIVER_NAME " at %s\n", dev->name,
+	       pci_name(pdev));
 
 	return 0;
 
@@ -194,7 +195,7 @@ static void __devexit orinoco_tmd_remove
 	struct orinoco_pci_card *card = priv->card;
 
 	unregister_netdev(dev);
-	free_irq(dev->irq, dev);
+	free_irq(pdev->irq, dev);
 	pci_set_drvdata(pdev, NULL);
 	free_orinocodev(dev);
 	pci_iounmap(pdev, priv->hw.iobase);

