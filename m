From: "Feldman, Scott" <scott.feldman@intel.com>
Subject: [e1000 2.6 3/4] better propagation of error codes
Date: Thu, 25 Sep 2003 22:51:34 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0309252249040.6939-100000@localhost.localdomain>
Reply-To: "Feldman, Scott" <scott.feldman@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, "Feldman, Scott" <scott.feldman@intel.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


* Better propagation of error codes during probe/open paths.
  {Janice Girouard (janiceg@us.ibm.com)]

---------------

diff -Naurp net-drivers-2.5/drivers/net/e1000/e1000_main.c net-drivers-2.5/drivers/net/e1000.mod/e1000_main.c
--- net-drivers-2.5/drivers/net/e1000/e1000_main.c	2003-09-24 21:24:23.000000000 -0700
+++ net-drivers-2.5/drivers/net/e1000.mod/e1000_main.c	2003-09-24 21:26:33.000000000 -0700
@@ -250,6 +250,7 @@ int
 e1000_up(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
+	int err;
 
 	/* hardware has been reset, we need to reload some things */
 
@@ -262,9 +263,10 @@ e1000_up(struct e1000_adapter *adapter)
 	e1000_configure_rx(adapter);
 	e1000_alloc_rx_buffers(adapter);
 
-	if(request_irq(netdev->irq, &e1000_intr, SA_SHIRQ | SA_SAMPLE_RANDOM,
-		       netdev->name, netdev))
-		return -1;
+	if((err = request_irq(netdev->irq, &e1000_intr,
+		              SA_SHIRQ | SA_SAMPLE_RANDOM,
+		              netdev->name, netdev)))
+		return err;
 
 	mod_timer(&adapter->watchdog_timer, jiffies);
 	e1000_irq_enable(adapter);
@@ -356,29 +358,32 @@ e1000_probe(struct pci_dev *pdev,
 	int mmio_len;
 	int pci_using_dac;
 	int i;
+	int err;
 	uint16_t eeprom_data;
 
-	if((i = pci_enable_device(pdev)))
-		return i;
+	if((err = pci_enable_device(pdev)))
+		return err;
 
-	if(!(i = pci_set_dma_mask(pdev, PCI_DMA_64BIT))) {
+	if(!(err = pci_set_dma_mask(pdev, PCI_DMA_64BIT))) {
 		pci_using_dac = 1;
 	} else {
-		if((i = pci_set_dma_mask(pdev, PCI_DMA_32BIT))) {
+		if((err = pci_set_dma_mask(pdev, PCI_DMA_32BIT))) {
 			E1000_ERR("No usable DMA configuration, aborting\n");
-			return i;
+			return err;
 		}
 		pci_using_dac = 0;
 	}
 
-	if((i = pci_request_regions(pdev, e1000_driver_name)))
-		return i;
+	if((err = pci_request_regions(pdev, e1000_driver_name)))
+		return err;
 
 	pci_set_master(pdev);
 
 	netdev = alloc_etherdev(sizeof(struct e1000_adapter));
-	if(!netdev)
+	if(!netdev) {
+		err = -ENOMEM;
 		goto err_alloc_etherdev;
+	}
 
 	SET_MODULE_OWNER(netdev);
 	SET_NETDEV_DEV(netdev, &pdev->dev);
@@ -393,8 +398,10 @@ e1000_probe(struct pci_dev *pdev,
 	mmio_len = pci_resource_len(pdev, BAR_0);
 
 	adapter->hw.hw_addr = ioremap(mmio_start, mmio_len);
-	if(!adapter->hw.hw_addr)
+	if(!adapter->hw.hw_addr) {
+		err = -EIO;
 		goto err_ioremap;
+	}
 
 	for(i = BAR_1; i <= BAR_5; i++) {
 		if(pci_resource_len(pdev, i) == 0)
@@ -432,7 +439,7 @@ e1000_probe(struct pci_dev *pdev,
 
 	/* setup the private structure */
 
-	if(e1000_sw_init(adapter))
+	if((err = e1000_sw_init(adapter)))
 		goto err_sw_init;
 
 	if(adapter->hw.mac_type >= e1000_82543) {
@@ -463,6 +470,7 @@ e1000_probe(struct pci_dev *pdev,
 
 	if(e1000_validate_eeprom_checksum(&adapter->hw) < 0) {
 		printk(KERN_ERR "The EEPROM Checksum Is Not Valid\n");
+		err = -EIO;
 		goto err_eeprom;
 	}
 
@@ -471,8 +479,10 @@ e1000_probe(struct pci_dev *pdev,
 	e1000_read_mac_addr(&adapter->hw);
 	memcpy(netdev->dev_addr, adapter->hw.mac_addr, netdev->addr_len);
 
-	if(!is_valid_ether_addr(netdev->dev_addr))
+	if(!is_valid_ether_addr(netdev->dev_addr)) {
+		err = -EIO;
 		goto err_eeprom;
+	}
 
 	e1000_read_part_num(&adapter->hw, &(adapter->part_num));
 
@@ -545,7 +555,7 @@ err_ioremap:
 	kfree(netdev);
 err_alloc_etherdev:
 	pci_release_regions(pdev);
-	return -ENOMEM;
+	return err;
 }
 
 /**
@@ -620,7 +630,7 @@ e1000_sw_init(struct e1000_adapter *adap
 
 	if (e1000_set_mac_type(hw)) {
 		E1000_ERR("Unknown MAC Type\n");
-		return -1;
+		return -EIO;
 	}
 
 	/* initialize eeprom parameters */
@@ -675,18 +685,19 @@ static int
 e1000_open(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev->priv;
+	int err;
 
 	/* allocate transmit descriptors */
 
-	if(e1000_setup_tx_resources(adapter))
+	if((err = e1000_setup_tx_resources(adapter)))
 		goto err_setup_tx;
 
 	/* allocate receive descriptors */
 
-	if(e1000_setup_rx_resources(adapter))
+	if((err = e1000_setup_rx_resources(adapter)))
 		goto err_setup_rx;
 
-	if(e1000_up(adapter))
+	if((err = e1000_up(adapter)))
 		goto err_up;
 
 	return 0;
@@ -698,7 +709,7 @@ err_setup_rx:
 err_setup_tx:
 	e1000_reset(adapter);
 
-	return -EBUSY;
+	return err;
 }
 
 /**
