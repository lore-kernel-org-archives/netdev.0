From: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
Subject: Re: [PATCH][Take2] PCI legacy I/O port free driver - Making Intel
 e1000 driver legacy I/O port free
Date: Fri, 10 Aug 2007 14:40:45 +0900
Message-ID: <46BBFA5D.3040000@jp.fujitsu.com>
References: <46BBF49F.6060701@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: auke-jan.h.kok@intel.com, cramerj@intel.com,
	john.ronciak@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:35186 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751304AbXHJFkq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Aug 2007 01:40:46 -0400
In-Reply-To: <46BBF49F.6060701@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Auke

Sorry I sent the wrong patch.
I resubmit the patch.

Tomohiro Kusumi

Signed-off-by: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>

---
diff -Nurp linux-2.6.22.org/drivers/net/e1000/e1000.h linux-2.6.22/drivers/net/e1000/e1000.h
--- linux-2.6.22.org/drivers/net/e1000/e1000.h	2007-07-09 08:32:17.000000000 +0900
+++ linux-2.6.22/drivers/net/e1000/e1000.h	2007-08-10 09:56:03.000000000 +0900
@@ -342,6 +342,9 @@ struct e1000_adapter {
 	boolean_t quad_port_a;
 	unsigned long flags;
 	uint32_t eeprom_wol;
+
+	int use_ioport;
+	int bars;
 };

 enum e1000_state_t {
diff -Nurp linux-2.6.22.org/drivers/net/e1000/e1000_main.c linux-2.6.22/drivers/net/e1000/e1000_main.c
--- linux-2.6.22.org/drivers/net/e1000/e1000_main.c	2007-07-09 08:32:17.000000000 +0900
+++ linux-2.6.22/drivers/net/e1000/e1000_main.c	2007-08-10 14:27:41.000000000 +0900
@@ -222,6 +222,11 @@ static pci_ers_result_t e1000_io_error_d
 static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev);
 static void e1000_io_resume(struct pci_dev *pdev);

+static unsigned int enable_legacy_ioport_free = 0;
+module_param(enable_legacy_ioport_free, uint, 0644);
+MODULE_PARM_DESC(enable_legacy_ioport_free, "Enable legacy I/O port free (default:0)");
+static int e1000_test_legacy_ioport(struct pci_dev *pdev);
+
 static struct pci_error_handlers e1000_err_handler = {
 	.error_detected = e1000_io_error_detected,
 	.slot_reset = e1000_io_slot_reset,
@@ -868,8 +873,25 @@ e1000_probe(struct pci_dev *pdev,
 	int i, err, pci_using_dac;
 	uint16_t eeprom_data = 0;
 	uint16_t eeprom_apme_mask = E1000_EEPROM_APME;
-	if ((err = pci_enable_device(pdev)))
+	int bars = 0;
+	int use_ioport = 0;
+
+	if (enable_legacy_ioport_free) {
+		if ((use_ioport = e1000_test_legacy_ioport(pdev)) < 0) {
+			E1000_ERR("e1000_test_legacy_ioport failed, aborting\n");
+			return -1;
+		}
+		if (use_ioport)
+			bars = pci_select_bars(pdev, IORESOURCE_MEM | IORESOURCE_IO);
+		else
+			bars = pci_select_bars(pdev, IORESOURCE_MEM);
+
+		if ((err = pci_enable_device_bars(pdev, bars)))
+			return err;
+	}
+	else if ((err = pci_enable_device(pdev))) {
 		return err;
+	}

 	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
 	    !(err = pci_set_consistent_dma_mask(pdev, DMA_64BIT_MASK))) {
@@ -883,7 +905,8 @@ e1000_probe(struct pci_dev *pdev,
 		pci_using_dac = 0;
 	}

-	if ((err = pci_request_regions(pdev, e1000_driver_name)))
+	if ((enable_legacy_ioport_free && (err = pci_request_selected_regions(pdev, bars, e1000_driver_name))) ||
+	    (err = pci_request_regions(pdev, e1000_driver_name)))
 		goto err_pci_reg;

 	pci_set_master(pdev);
@@ -902,6 +925,10 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->pdev = pdev;
 	adapter->hw.back = adapter;
 	adapter->msg_enable = (1 << debug) - 1;
+	if (enable_legacy_ioport_free) {
+		adapter->use_ioport = use_ioport;
+		adapter->bars = bars;
+	}

 	mmio_start = pci_resource_start(pdev, BAR_0);
 	mmio_len = pci_resource_len(pdev, BAR_0);
@@ -911,12 +938,14 @@ e1000_probe(struct pci_dev *pdev,
 	if (!adapter->hw.hw_addr)
 		goto err_ioremap;

-	for (i = BAR_1; i <= BAR_5; i++) {
-		if (pci_resource_len(pdev, i) == 0)
-			continue;
-		if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
-			adapter->hw.io_base = pci_resource_start(pdev, i);
-			break;
+	if (!enable_legacy_ioport_free || adapter->use_ioport) {
+		for (i = BAR_1; i <= BAR_5; i++) {
+			if (pci_resource_len(pdev, i) == 0)
+				continue;
+			if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
+				adapter->hw.io_base = pci_resource_start(pdev, i);
+				break;
+			}
 		}
 	}

@@ -1182,7 +1211,10 @@ err_sw_init:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_regions(pdev);
+	if (enable_legacy_ioport_free)
+		pci_release_selected_regions(pdev, bars);
+	else
+		pci_release_regions(pdev);
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -1234,7 +1266,10 @@ e1000_remove(struct pci_dev *pdev)
 	iounmap(adapter->hw.hw_addr);
 	if (adapter->hw.flash_address)
 		iounmap(adapter->hw.flash_address);
-	pci_release_regions(pdev);
+	if (enable_legacy_ioport_free)
+		pci_release_selected_regions(pdev, adapter->bars);
+	else
+		pci_release_regions(pdev);

 	free_netdev(netdev);

@@ -5175,7 +5210,8 @@ e1000_resume(struct pci_dev *pdev)

 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	if ((err = pci_enable_device(pdev))) {
+	if ((enable_legacy_ioport_free && (err = pci_enable_device_bars(pdev, adapter->bars))) ||
+	    (err = pci_enable_device(pdev))) {
 		printk(KERN_ERR "e1000: Cannot enable PCI device from suspend\n");
 		return err;
 	}
@@ -5320,4 +5356,43 @@ static void e1000_io_resume(struct pci_d

 }

+/*
+ * e1000_test_legacy_ioport - see if the device uses legacy I/O port
+ * @pdev: Pointer to PCI device
+ *
+ * This function tests if the PCI device uses I/O port.
+ * If yes the function returns 1, if no the function returns 0.
+ * The function returns -1 if there is an error.
+ */
+
+static int e1000_test_legacy_ioport(struct pci_dev *pdev)
+{
+	int ret;
+	struct e1000_hw hw;
+	memset(&hw, 0, sizeof(hw));
+	
+	hw.mac_type = e1000_undefined;
+	hw.device_id = pdev->device;
+	pci_read_config_byte(pdev, PCI_REVISION_ID, &hw.revision_id);
+
+	if (e1000_set_mac_type(&hw) < 0)
+		return -1;
+
+	switch (hw.mac_type) {
+	case e1000_82540:
+	case e1000_82541:
+	case e1000_82541_rev_2:
+	case e1000_82544:
+	case e1000_82545:
+	case e1000_82546:
+		ret = 1;
+		break;
+	default:
+		ret = 0;
+		break;
+	}
+	
+	return ret;
+}
+
 /* e1000_main.c */

