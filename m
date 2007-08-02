From: Brandon Philips <brandon@suse.de>
Subject: [patch 5/5][RFC] Update e1000 driver to use devres.
Date: Thu, 2 Aug 2007 15:45:52 -0700
Message-ID: <20070802224552.GG5181@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: teheo@suse.de, Brandon Philips <bphilips@suse.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:48711 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756334AbXHBWp4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Aug 2007 18:45:56 -0400
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 8E8AD2170D
	for <netdev@vger.kernel.org>; Fri,  3 Aug 2007 00:45:55 +0200 (CEST)
Content-Disposition: inline; filename="e1000-devres.patch"
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Conversion of e1000 probe() and remove() to devres.

Signed-off-by: Brandon Philips <bphilips@suse.de>
---
 drivers/net/e1000/e1000.h      |    1 
 drivers/net/e1000/e1000_main.c |   79 ++++++++++++-----------------------------
 2 files changed, 26 insertions(+), 54 deletions(-)

Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -868,7 +868,7 @@ e1000_probe(struct pci_dev *pdev,
 	int i, err, pci_using_dac;
 	uint16_t eeprom_data = 0;
 	uint16_t eeprom_apme_mask = E1000_EEPROM_APME;
-	if ((err = pci_enable_device(pdev)))
+	if ((err = pcim_enable_device(pdev)))
 		return err;
 
 	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
@@ -884,14 +884,14 @@ e1000_probe(struct pci_dev *pdev,
 	}
 
 	if ((err = pci_request_regions(pdev, e1000_driver_name)))
-		goto err_pci_reg;
+		goto err_dma;
 
 	pci_set_master(pdev);
 
 	err = -ENOMEM;
-	netdev = alloc_etherdev(sizeof(struct e1000_adapter));
+	netdev = devm_alloc_etherdev(&pdev->dev, sizeof(struct e1000_adapter));
 	if (!netdev)
-		goto err_alloc_etherdev;
+		goto err_dma;
 
 	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &pdev->dev);
@@ -907,9 +907,9 @@ e1000_probe(struct pci_dev *pdev,
 	mmio_len = pci_resource_len(pdev, BAR_0);
 
 	err = -EIO;
-	adapter->hw.hw_addr = ioremap(mmio_start, mmio_len);
+	adapter->hw.hw_addr = devm_ioremap(&pdev->dev, mmio_start, mmio_len);
 	if (!adapter->hw.hw_addr)
-		goto err_ioremap;
+		goto err_dma;
 
 	for (i = BAR_1; i <= BAR_5; i++) {
 		if (pci_resource_len(pdev, i) == 0)
@@ -952,7 +952,7 @@ e1000_probe(struct pci_dev *pdev,
 	/* setup the private structure */
 
 	if ((err = e1000_sw_init(adapter)))
-		goto err_sw_init;
+		goto err_dma;
 
 	err = -EIO;
 	/* Flash BAR mapping must happen after e1000_sw_init
@@ -961,7 +961,9 @@ e1000_probe(struct pci_dev *pdev,
 	   (pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
 		flash_start = pci_resource_start(pdev, 1);
 		flash_len = pci_resource_len(pdev, 1);
-		adapter->hw.flash_address = ioremap(flash_start, flash_len);
+		adapter->hw.flash_address = devm_ioremap(&pdev->dev,
+							flash_start,
+							flash_len);
 		if (!adapter->hw.flash_address)
 			goto err_flashmap;
 	}
@@ -1163,27 +1165,11 @@ err_register:
 err_eeprom:
 	if (!e1000_check_phy_reset_block(&adapter->hw))
 		e1000_phy_hw_reset(&adapter->hw);
-
-	if (adapter->hw.flash_address)
-		iounmap(adapter->hw.flash_address);
 err_flashmap:
 #ifdef CONFIG_E1000_NAPI
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		dev_put(&adapter->polling_netdev[i]);
 #endif
-
-	kfree(adapter->tx_ring);
-	kfree(adapter->rx_ring);
-#ifdef CONFIG_E1000_NAPI
-	kfree(adapter->polling_netdev);
-#endif
-err_sw_init:
-	iounmap(adapter->hw.hw_addr);
-err_ioremap:
-	free_netdev(netdev);
-err_alloc_etherdev:
-	pci_release_regions(pdev);
-err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
 	return err;
@@ -1224,21 +1210,6 @@ e1000_remove(struct pci_dev *pdev)
 
 	if (!e1000_check_phy_reset_block(&adapter->hw))
 		e1000_phy_hw_reset(&adapter->hw);
-
-	kfree(adapter->tx_ring);
-	kfree(adapter->rx_ring);
-#ifdef CONFIG_E1000_NAPI
-	kfree(adapter->polling_netdev);
-#endif
-
-	iounmap(adapter->hw.hw_addr);
-	if (adapter->hw.flash_address)
-		iounmap(adapter->hw.flash_address);
-	pci_release_regions(pdev);
-
-	free_netdev(netdev);
-
-	pci_disable_device(pdev);
 }
 
 /**
@@ -1350,27 +1321,27 @@ e1000_sw_init(struct e1000_adapter *adap
 static int __devinit
 e1000_alloc_queues(struct e1000_adapter *adapter)
 {
-	adapter->tx_ring = kcalloc(adapter->num_tx_queues,
-	                           sizeof(struct e1000_tx_ring), GFP_KERNEL);
+	adapter->tx_ring = devm_kcalloc(&adapter->pdev->dev,
+					adapter->num_tx_queues,
+					sizeof(struct e1000_tx_ring),
+					GFP_KERNEL);
 	if (!adapter->tx_ring)
 		return -ENOMEM;
 
-	adapter->rx_ring = kcalloc(adapter->num_rx_queues,
-	                           sizeof(struct e1000_rx_ring), GFP_KERNEL);
-	if (!adapter->rx_ring) {
-		kfree(adapter->tx_ring);
+	adapter->rx_ring = devm_kcalloc(&adapter->pdev->dev,
+					adapter->num_rx_queues,
+					sizeof(struct e1000_rx_ring),
+					GFP_KERNEL);
+	if (!adapter->rx_ring)
 		return -ENOMEM;
-	}
 
 #ifdef CONFIG_E1000_NAPI
-	adapter->polling_netdev = kcalloc(adapter->num_rx_queues,
-	                                  sizeof(struct net_device),
-	                                  GFP_KERNEL);
-	if (!adapter->polling_netdev) {
-		kfree(adapter->tx_ring);
-		kfree(adapter->rx_ring);
+	adapter->polling_netdev = devm_kcalloc(&adapter->pdev->dev,
+					       adapter->num_rx_queues,
+					       sizeof(struct net_device),
+					       GFP_KERNEL);
+	if (!adapter->polling_netdev)
 		return -ENOMEM;
-	}
 #endif
 
 	return E1000_SUCCESS;
@@ -5174,7 +5145,7 @@ e1000_resume(struct pci_dev *pdev)
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	if ((err = pci_enable_device(pdev))) {
+	if ((err = pcim_enable_device(pdev))) {
 		printk(KERN_ERR "e1000: Cannot enable PCI device from suspend\n");
 		return err;
 	}
Index: linux-2.6/drivers/net/e1000/e1000.h
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000.h
+++ linux-2.6/drivers/net/e1000/e1000.h
@@ -41,6 +41,7 @@
 #include <linux/errno.h>
 #include <linux/ioport.h>
 #include <linux/pci.h>
+#include <linux/io.h>
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>

-- 
