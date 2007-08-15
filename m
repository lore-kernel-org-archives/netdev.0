From: Brandon Philips <bphilips@suse.de>
Subject: [patch 4/4] Update e1000 driver to use devres.
Date: Wed, 15 Aug 2007 12:00:14 -0700
Message-ID: <20070815190014.GE7294@ifup.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: teheo@suse.de, Brandon Philips <bphilips@suse.de>
To: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline; filename="e1000-devres.patch"
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Conversion of e1000 probe() and remove() to devres.

Signed-off-by: Brandon Philips <bphilips@suse.de>
---
 drivers/net/e1000/e1000.h      |    1 
 drivers/net/e1000/e1000_main.c |   92 ++++++++++++-----------------------------
 2 files changed, 28 insertions(+), 65 deletions(-)

Index: linux-2.6/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6/drivers/net/e1000/e1000_main.c
@@ -860,15 +860,14 @@ e1000_probe(struct pci_dev *pdev,
 {
 	struct net_device *netdev;
 	struct e1000_adapter *adapter;
-	unsigned long mmio_start, mmio_len;
-	unsigned long flash_start, flash_len;
+	unsigned long mmio_len, flash_len;
 
 	static int cards_found = 0;
 	static int global_quad_port_a = 0; /* global ksp3 port a indication */
 	int i, err, pci_using_dac;
 	uint16_t eeprom_data = 0;
 	uint16_t eeprom_apme_mask = E1000_EEPROM_APME;
-	if ((err = pci_enable_device(pdev)))
+	if ((err = pcim_enable_device(pdev)))
 		return err;
 
 	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
@@ -878,20 +877,19 @@ e1000_probe(struct pci_dev *pdev,
 		if ((err = pci_set_dma_mask(pdev, DMA_32BIT_MASK)) &&
 		    (err = pci_set_consistent_dma_mask(pdev, DMA_32BIT_MASK))) {
 			E1000_ERR("No usable DMA configuration, aborting\n");
-			goto err_dma;
+			return err;
 		}
 		pci_using_dac = 0;
 	}
 
 	if ((err = pci_request_regions(pdev, e1000_driver_name)))
-		goto err_pci_reg;
+		return err;
 
 	pci_set_master(pdev);
 
-	err = -ENOMEM;
-	netdev = alloc_etherdev(sizeof(struct e1000_adapter));
+	netdev = devm_alloc_etherdev(&pdev->dev, sizeof(struct e1000_adapter));
 	if (!netdev)
-		goto err_alloc_etherdev;
+		return -ENOMEM;
 
 	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &pdev->dev);
@@ -903,13 +901,11 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->hw.back = adapter;
 	adapter->msg_enable = (1 << debug) - 1;
 
-	mmio_start = pci_resource_start(pdev, BAR_0);
 	mmio_len = pci_resource_len(pdev, BAR_0);
 
-	err = -EIO;
-	adapter->hw.hw_addr = ioremap(mmio_start, mmio_len);
+	adapter->hw.hw_addr = pcim_iomap(pdev, BAR_0, mmio_len);
 	if (!adapter->hw.hw_addr)
-		goto err_ioremap;
+		return -EIO;
 
 	for (i = BAR_1; i <= BAR_5; i++) {
 		if (pci_resource_len(pdev, i) == 0)
@@ -943,8 +939,8 @@ e1000_probe(struct pci_dev *pdev,
 #endif
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
-	netdev->mem_start = mmio_start;
-	netdev->mem_end = mmio_start + mmio_len;
+	netdev->mem_start = pci_resource_start(pdev, BAR_0);
+	netdev->mem_end = netdev->mem_start + mmio_len;
 	netdev->base_addr = adapter->hw.io_base;
 
 	adapter->bd_number = cards_found;
@@ -952,16 +948,15 @@ e1000_probe(struct pci_dev *pdev,
 	/* setup the private structure */
 
 	if ((err = e1000_sw_init(adapter)))
-		goto err_sw_init;
+		return err;
 
 	err = -EIO;
 	/* Flash BAR mapping must happen after e1000_sw_init
 	 * because it depends on mac_type */
 	if ((adapter->hw.mac_type == e1000_ich8lan) &&
 	   (pci_resource_flags(pdev, 1) & IORESOURCE_MEM)) {
-		flash_start = pci_resource_start(pdev, 1);
 		flash_len = pci_resource_len(pdev, 1);
-		adapter->hw.flash_address = ioremap(flash_start, flash_len);
+		adapter->hw.flash_address = pcim_iomap(pdev, 1, flash_len);
 		if (!adapter->hw.flash_address)
 			goto err_flashmap;
 	}
@@ -1163,29 +1158,11 @@ err_register:
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
-err_dma:
-	pci_disable_device(pdev);
 	return err;
 }
 
@@ -1224,21 +1201,6 @@ e1000_remove(struct pci_dev *pdev)
 
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
@@ -1350,27 +1312,27 @@ e1000_sw_init(struct e1000_adapter *adap
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
@@ -5174,7 +5136,7 @@ e1000_resume(struct pci_dev *pdev)
 
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

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
