From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] ixgb fixes
Date: Thu, 15 Jan 2004 14:02:48 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040115140248.170a3ee3.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ganesh Venkatesan <Ganesh.Venkatesan@intel.com>,
        "Feldman, Scott"
 <scott.feldman@intel.com>,
        Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ixgb driver in 2.6.1 (possibly 2.4) has several problems:
	* register_netdev error never handled
	* returns -ENOMEM for errors like bad eeprom etc
	* keeps copy of device name in the private data structure
	  which is never used, and would be wrong anyway if
	  the device was renamed.

diff -Nru a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
--- a/drivers/net/ixgb/ixgb.h	Thu Jan 15 13:58:48 2004
+++ b/drivers/net/ixgb/ixgb.h	Thu Jan 15 13:58:48 2004
@@ -179,7 +179,6 @@
 	struct ixgb_hw hw;
 	struct ixgb_hw_stats stats;
 	u32 pci_state[16];
-	char ifname[IFNAMSIZ];
 };
 
 #endif				/* _IXGB_H_ */
diff -Nru a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
--- a/drivers/net/ixgb/ixgb_main.c	Thu Jan 15 13:58:48 2004
+++ b/drivers/net/ixgb/ixgb_main.c	Thu Jan 15 13:58:48 2004
@@ -299,28 +299,28 @@
 	unsigned long mmio_start;
 	int mmio_len;
 	int pci_using_dac;
-	int i;
+	int i, err;
 
 	IXGB_DBG("ixgb_probe\n");
 
-	if ((i = pci_enable_device(pdev))) {
+	if ((err = pci_enable_device(pdev))) {
 		IXGB_ERR("pci_enable_device failed\n");
-		return i;
+		goto err_out;
 	}
 
-	if (!(i = pci_set_dma_mask(pdev, PCI_DMA_64BIT))) {
+	if (!(err = pci_set_dma_mask(pdev, PCI_DMA_64BIT))) {
 		pci_using_dac = 1;
 	} else {
-		if ((i = pci_set_dma_mask(pdev, PCI_DMA_32BIT))) {
+		if ((err = pci_set_dma_mask(pdev, PCI_DMA_32BIT))) {
 			IXGB_ERR("No usable DMA configuration, aborting\n");
-			return i;
+			goto err_out;
 		}
 		pci_using_dac = 0;
 	}
 
-	if ((i = pci_request_regions(pdev, ixgb_driver_name))) {
+	if ((err = pci_request_regions(pdev, ixgb_driver_name))) {
 		IXGB_ERR("Failed to reserve PCI I/O and Memory resources.\n");
-		return i;
+		goto err_out;
 	}
 
 	pci_set_master(pdev);
@@ -329,7 +329,8 @@
 	netdev = alloc_etherdev(sizeof (struct ixgb_adapter));
 	if (!netdev) {
 		IXGB_ERR("Unable to allocate net_device struct\n");
-		goto err_alloc_etherdev;
+		err = -ENOMEM;
+		goto err_out;
 	}
 
 	SET_MODULE_OWNER(netdev);
@@ -345,8 +346,10 @@
 	mmio_len = pci_resource_len(pdev, BAR_0);
 
 	adapter->hw.hw_addr = ioremap(mmio_start, mmio_len);
-	if (!adapter->hw.hw_addr)
+	if (!adapter->hw.hw_addr) {
+		err = -EIO;
 		goto err_ioremap;
+	}
 
 	for (i = BAR_1; i <= BAR_5; i++) {
 		if (pci_resource_len(pdev, i) == 0)
@@ -404,6 +407,7 @@
 
 	if (!ixgb_validate_eeprom_checksum(&adapter->hw)) {
 		IXGB_DBG("Invalid EEPROM checksum.\n");
+		err = -EIO;
 		goto err_eeprom;
 	}
 
@@ -411,6 +415,7 @@
 
 	if (!is_valid_ether_addr(netdev->dev_addr)) {
 		IXGB_DBG("Invalid MAC address in EEPROM.\n");
+		err = -EIO;
 		goto err_eeprom;
 	}
 
@@ -424,9 +429,9 @@
 	INIT_WORK(&adapter->tx_timeout_task,
 		  (void (*)(void *)) ixgb_tx_timeout_task, netdev);
 
-	register_netdev(netdev);
-	memcpy(adapter->ifname, netdev->name, IFNAMSIZ);
-	adapter->ifname[IFNAMSIZ - 1] = 0;
+	err = register_netdev(netdev);
+	if (err)
+		goto err_eeprom;
 
 	/* we're going to reset, so assume we have no link for now */
 
@@ -447,8 +452,8 @@
       err_ioremap:
 	pci_release_regions(pdev);
 	kfree(netdev);
-      err_alloc_etherdev:
-	return -ENOMEM;
+       err_out:
+	return err;
 }
 
 /**
