From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH] r6040: use (dev|netdev)_<level> macros helpers
Date: Thu, 8 Apr 2010 09:39:27 +0200
Message-ID: <201004080939.27917.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f178.google.com ([209.85.223.178]:57068 "EHLO
	mail-iw0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932183Ab0DHHkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Apr 2010 03:40:35 -0400
Received: by iwn8 with SMTP id 8so1181041iwn.16
        for <netdev@vger.kernel.org>; Thu, 08 Apr 2010 00:40:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 83ebc75..c1f203b 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -331,7 +331,7 @@ static int r6040_alloc_rxbufs(struct net_device *dev)
 	do {
 		skb = netdev_alloc_skb(dev, MAX_BUF_SIZE);
 		if (!skb) {
-			printk(KERN_ERR DRV_NAME "%s: failed to alloc skb for rx\n", dev->name);
+			netdev_err(dev, "failed to alloc skb for rx\n");
 			rc = -ENOMEM;
 			goto err_exit;
 		}
@@ -411,9 +411,9 @@ static void r6040_tx_timeout(struct net_device *dev)
 	struct r6040_private *priv = netdev_priv(dev);
 	void __iomem *ioaddr = priv->base;
 
-	printk(KERN_WARNING "%s: transmit timed out, int enable %4.4x "
+	netdev_warn(dev, "transmit timed out, int enable %4.4x "
 		"status %4.4x, PHY status %4.4x\n",
-		dev->name, ioread16(ioaddr + MIER),
+		ioread16(ioaddr + MIER),
 		ioread16(ioaddr + MISR),
 		r6040_mdio_read(dev, priv->mii_if.phy_id, MII_BMSR));
 
@@ -898,7 +898,7 @@ static netdev_tx_t r6040_start_xmit(struct sk_buff *skb,
 	if (!lp->tx_free_desc) {
 		spin_unlock_irqrestore(&lp->lock, flags);
 		netif_stop_queue(dev);
-		printk(KERN_ERR DRV_NAME ": no tx descriptor\n");
+		netdev_err(dev, ": no tx descriptor\n");
 		return NETDEV_TX_BUSY;
 	}
 
@@ -1091,20 +1091,20 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	/* this should always be supported */
 	err = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err) {
-		printk(KERN_ERR DRV_NAME ": 32-bit PCI DMA addresses"
+		dev_err(&pdev->dev, "32-bit PCI DMA addresses"
 				"not supported by the card\n");
 		goto err_out;
 	}
 	err = pci_set_consistent_dma_mask(pdev, DMA_BIT_MASK(32));
 	if (err) {
-		printk(KERN_ERR DRV_NAME ": 32-bit PCI DMA addresses"
+		dev_err(&pdev->dev, "32-bit PCI DMA addresses"
 				"not supported by the card\n");
 		goto err_out;
 	}
 
 	/* IO Size check */
 	if (pci_resource_len(pdev, bar) < io_size) {
-		printk(KERN_ERR DRV_NAME ": Insufficient PCI resources, aborting\n");
+		dev_err(&pdev->dev, "Insufficient PCI resources, aborting\n");
 		err = -EIO;
 		goto err_out;
 	}
@@ -1113,7 +1113,7 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 
 	dev = alloc_etherdev(sizeof(struct r6040_private));
 	if (!dev) {
-		printk(KERN_ERR DRV_NAME ": Failed to allocate etherdev\n");
+		dev_err(&pdev->dev, "Failed to allocate etherdev\n");
 		err = -ENOMEM;
 		goto err_out;
 	}
@@ -1123,14 +1123,13 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	err = pci_request_regions(pdev, DRV_NAME);
 
 	if (err) {
-		printk(KERN_ERR DRV_NAME ": Failed to request PCI regions\n");
+		dev_err(&pdev->dev, "Failed to request PCI regions\n");
 		goto err_out_free_dev;
 	}
 
 	ioaddr = pci_iomap(pdev, bar, io_size);
 	if (!ioaddr) {
-		printk(KERN_ERR DRV_NAME ": ioremap failed for device %s\n",
-			pci_name(pdev));
+		dev_err(&pdev->dev, "ioremap failed for device\n");
 		err = -EIO;
 		goto err_out_free_res;
 	}
@@ -1157,7 +1156,7 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	/* Some bootloader/BIOSes do not initialize
 	 * MAC address, warn about that */
 	if (!(adrp[0] || adrp[1] || adrp[2])) {
-		printk(KERN_WARNING DRV_NAME ": MAC address not initialized, generating random\n");
+		netdev_warn(dev, "MAC address not initialized, generating random\n");
 		random_ether_addr(dev->dev_addr);
 	}
 
@@ -1185,7 +1184,7 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 
 	/* Check the vendor ID on the PHY, if 0xffff assume none attached */
 	if (r6040_phy_read(ioaddr, lp->phy_addr, 2) == 0xffff) {
-		printk(KERN_ERR DRV_NAME ": Failed to detect an attached PHY\n");
+		dev_err(&pdev->dev, "Failed to detect an attached PHY\n");
 		err = -ENODEV;
 		goto err_out_unmap;
 	}
@@ -1193,7 +1192,7 @@ static int __devinit r6040_init_one(struct pci_dev *pdev,
 	/* Register net device. After this dev->name assign */
 	err = register_netdev(dev);
 	if (err) {
-		printk(KERN_ERR DRV_NAME ": Failed to register net device\n");
+		dev_err(&pdev->dev, "Failed to register net device\n");
 		goto err_out_unmap;
 	}
 	return 0;
