From: varkabhadram@gmail.com
Subject: [PATCH net-next v2 3/6] ethernet: amd: dynamic debug fixes
Date: Mon, 14 Jul 2014 11:55:44 +0530
Message-ID: <1405319147-5212-4-git-send-email-varkabhadram@gmail.com>
References: <1405319147-5212-1-git-send-email-varkabhadram@gmail.com>
Cc: Thomas.Lendacky@amd.com, geert+renesas@linux-m68k.org,
	ebiederm@xmission.com, macro@linux-mips.org,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	Varka Bhadram <varkab@cdac.in>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:51923 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbaGNG1o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 02:27:44 -0400
In-Reply-To: <1405319147-5212-1-git-send-email-varkabhadram@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Varka Bhadram <varkab@cdac.in>

This patch convert printk() to netdev_dbg/info/err or dev_info/err/dbg

Signed-off-by: Varka Bhadram <varkab@cdac.in>
---
 drivers/net/ethernet/amd/amd8111e.c |   58 ++++++++++++++++-------------------
 1 file changed, 26 insertions(+), 32 deletions(-)

diff --git a/drivers/net/ethernet/amd/amd8111e.c b/drivers/net/ethernet/amd/amd8111e.c
index 433107c..2d3a55e 100644
--- a/drivers/net/ethernet/amd/amd8111e.c
+++ b/drivers/net/ethernet/amd/amd8111e.c
@@ -501,8 +501,7 @@ static int amd8111e_restart(struct net_device *dev)
 
 	/* Enable interrupt coalesce */
 	if(lp->options & OPTION_INTR_COAL_ENABLE){
-		printk(KERN_INFO "%s: Interrupt Coalescing Enabled.\n",
-								dev->name);
+		netdev_info(dev, "Interrupt Coalescing Enabled");
 		amd8111e_set_coalesce(dev,ENABLE_COAL);
 	}
 
@@ -860,16 +859,19 @@ static int amd8111e_link_change(struct net_device* dev)
 		else if(speed == PHY_SPEED_100)
 			lp->link_config.speed = SPEED_100;
 
-		printk(KERN_INFO "%s: Link is Up. Speed is %s Mbps %s Duplex\n",			dev->name,
-		       (lp->link_config.speed == SPEED_100) ? "100": "10",
-		       (lp->link_config.duplex == DUPLEX_FULL)? "Full": "Half");
+		netdev_info(dev, "Link is Up. Speed is %s Mbps %s Duplex\n",
+			    (lp->link_config.speed == SPEED_100) ?
+							"100" : "10",
+			    (lp->link_config.duplex == DUPLEX_FULL) ?
+							"Full" : "Half");
+
 		netif_carrier_on(dev);
 	}
 	else{
 		lp->link_config.speed = SPEED_INVALID;
 		lp->link_config.duplex = DUPLEX_INVALID;
 		lp->link_config.autoneg = AUTONEG_INVALID;
-		printk(KERN_INFO "%s: Link is Down.\n",dev->name);
+		netdev_info(dev, "Link is Down.\n");
 		netif_carrier_off(dev);
 	}
 
@@ -1168,7 +1170,7 @@ static irqreturn_t amd8111e_interrupt(int irq, void *dev_id)
 			/* Schedule a polling routine */
 			__napi_schedule(&lp->napi);
 		} else if (intren0 & RINTEN0) {
-			printk("************Driver bug! interrupt while in poll\n");
+			netdev_dbg(dev, "************Driver bug! interrupt while in poll\n");
 			/* Fix by disable receive interrupts */
 			writel(RINTEN0, mmio + INTEN0);
 		}
@@ -1264,7 +1266,7 @@ static int amd8111e_open(struct net_device * dev )
 	/* Start ipg timer */
 	if(lp->options & OPTION_DYN_IPG_ENABLE){
 		add_timer(&lp->ipg_data.ipg_timer);
-		printk(KERN_INFO "%s: Dynamic IPG Enabled.\n",dev->name);
+		netdev_info(dev, "Dynamic IPG Enabled\n");
 	}
 
 	lp->opened = 1;
@@ -1623,8 +1625,8 @@ static void amd8111e_tx_timeout(struct net_device *dev)
 	struct amd8111e_priv* lp = netdev_priv(dev);
 	int err;
 
-	printk(KERN_ERR "%s: transmit timed out, resetting\n",
-	 					      dev->name);
+	netdev_err(dev, "transmit timed out, resetting\n");
+
 	spin_lock_irq(&lp->lock);
 	err = amd8111e_restart(dev);
 	spin_unlock_irq(&lp->lock);
@@ -1807,22 +1809,19 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 
 	err = pci_enable_device(pdev);
 	if(err){
-		printk(KERN_ERR "amd8111e: Cannot enable new PCI device, "
-			"exiting.\n");
+		dev_err(&pdev->dev, "Cannot enable new PCI device\n");
 		return err;
 	}
 
 	if(!(pci_resource_flags(pdev, 0) & IORESOURCE_MEM)){
-		printk(KERN_ERR "amd8111e: Cannot find PCI base address, "
-		       "exiting.\n");
+		dev_err(&pdev->dev, "Cannot find PCI base address\n");
 		err = -ENODEV;
 		goto err_disable_pdev;
 	}
 
 	err = pci_request_regions(pdev, MODULE_NAME);
 	if(err){
-		printk(KERN_ERR "amd8111e: Cannot obtain PCI resources, "
-		       "exiting.\n");
+		dev_err(&pdev->dev, "Cannot obtain PCI resources\n");
 		goto err_disable_pdev;
 	}
 
@@ -1830,16 +1829,14 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 
 	/* Find power-management capability. */
 	if (!pdev->pm_cap) {
-		printk(KERN_ERR "amd8111e: No Power Management capability, "
-		       "exiting.\n");
+		dev_err(&pdev->dev, "No Power Management capability\n");
 		err = -ENODEV;
 		goto err_free_reg;
 	}
 
 	/* Initialize DMA */
 	if (pci_set_dma_mask(pdev, DMA_BIT_MASK(32)) < 0) {
-		printk(KERN_ERR "amd8111e: DMA not supported,"
-			"exiting.\n");
+		dev_err(&pdev->dev, "DMA not supported\n");
 		err = -ENODEV;
 		goto err_free_reg;
 	}
@@ -1868,8 +1865,7 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 
 	lp->mmio = devm_ioremap(&pdev->dev, reg_addr, reg_len);
 	if (!lp->mmio) {
-		printk(KERN_ERR "amd8111e: Cannot map device registers, "
-		       "exiting\n");
+		dev_err(&pdev->dev, "Cannot map device registers\n");
 		err = -ENOMEM;
 		goto err_free_dev;
 	}
@@ -1911,8 +1907,7 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 
 	err = register_netdev(dev);
 	if (err) {
-		printk(KERN_ERR "amd8111e: Cannot register net device, "
-		       "exiting.\n");
+		dev_err(&pdev->dev, "Cannot register net device\n");
 		goto err_free_dev;
 	}
 
@@ -1932,16 +1927,15 @@ static int amd8111e_probe_one(struct pci_dev *pdev,
 	/*  display driver and device information */
 
     	chip_version = (readl(lp->mmio + CHIPID) & 0xf0000000)>>28;
-	printk(KERN_INFO "%s: AMD-8111e Driver Version: %s\n",
-	       dev->name,MODULE_VERS);
-	printk(KERN_INFO "%s: [ Rev %x ] PCI 10/100BaseT Ethernet %pM\n",
-	       dev->name, chip_version, dev->dev_addr);
+	dev_info(&pdev->dev, "AMD-8111e Driver Version: %s\n", MODULE_VERS);
+	dev_info(&pdev->dev, "[ Rev %x ] PCI 10/100BaseT Ethernet %pM\n",
+		 chip_version, dev->dev_addr);
 	if (lp->ext_phy_id)
-		printk(KERN_INFO "%s: Found MII PHY ID 0x%08x at address 0x%02x\n",
-		       dev->name, lp->ext_phy_id, lp->ext_phy_addr);
+		dev_info(&pdev->dev, "Found MII PHY ID 0x%08x at address 0x%02x\n",
+			 lp->ext_phy_id, lp->ext_phy_addr);
 	else
-		printk(KERN_INFO "%s: Couldn't detect MII PHY, assuming address 0x01\n",
-		       dev->name);
+		dev_info(&pdev->dev, "Couldn't detect MII PHY, assuming address 0x01\n");
+
     	return 0;
 
 err_free_dev:
-- 
1.7.9.5
