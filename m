From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 1/3] e1000: make ioport free
Date: Fri, 20 Jun 2008 11:55:45 +0900
Message-ID: <485B1C31.4020507@jp.fujitsu.com>
References: <485B1B8E.1060108@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>,
	auke-jan.h.kok@intel.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:41172 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751227AbYFTC4N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 22:56:13 -0400
In-Reply-To: <485B1B8E.1060108@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes e1000 driver ioport-free.
This corrects behavior in probe function so as not to request ioport
resources as long as they are not really needed. This is based on the
ioport-free patch of e1000 driver from Auke Kok and Tomohiro Kusumi.


Signed-off-by: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/e1000/e1000.h      |    4 +
 drivers/net/e1000/e1000_main.c |   88 +++++++++++++++++++++++++++++++++++------
 2 files changed, 80 insertions(+), 12 deletions(-)

Index: linux-2.6.25.7/drivers/net/e1000/e1000.h
===================================================================
--- linux-2.6.25.7.orig/drivers/net/e1000/e1000.h
+++ linux-2.6.25.7/drivers/net/e1000/e1000.h
@@ -343,6 +343,10 @@ struct e1000_adapter {
 	boolean_t quad_port_a;
 	unsigned long flags;
 	uint32_t eeprom_wol;
+
+	/* for ioport free */
+	int	bars;
+	int	need_ioport;
 };

 enum e1000_state_t {
Index: linux-2.6.25.7/drivers/net/e1000/e1000_main.c
===================================================================
--- linux-2.6.25.7.orig/drivers/net/e1000/e1000_main.c
+++ linux-2.6.25.7/drivers/net/e1000/e1000_main.c
@@ -909,6 +909,44 @@ static void e1000_dump_eeprom(struct e10
 }

 /**
+ * e1000_is_need_ioport - determine if an adapter needs ioport resources or not
+ * @pdev: PCI device information struct
+ *
+ * Returns true if an adapter needs ioport resources
+ **/
+
+static int
+e1000_is_need_ioport(struct pci_dev *pdev)
+{
+	switch (pdev->device) {
+	case E1000_DEV_ID_82540EM:
+	case E1000_DEV_ID_82540EM_LOM:
+	case E1000_DEV_ID_82540EP:
+	case E1000_DEV_ID_82540EP_LOM:
+	case E1000_DEV_ID_82540EP_LP:
+	case E1000_DEV_ID_82541EI:
+	case E1000_DEV_ID_82541EI_MOBILE:
+	case E1000_DEV_ID_82541ER_LOM:
+	case E1000_DEV_ID_82541ER:
+	case E1000_DEV_ID_82541GI:
+	case E1000_DEV_ID_82541GI_LF:
+	case E1000_DEV_ID_82541GI_MOBILE:
+	case E1000_DEV_ID_82544EI_COPPER:
+	case E1000_DEV_ID_82544EI_FIBER:
+	case E1000_DEV_ID_82544GC_COPPER:
+	case E1000_DEV_ID_82544GC_LOM:
+	case E1000_DEV_ID_82545EM_COPPER:
+	case E1000_DEV_ID_82545EM_FIBER:
+	case E1000_DEV_ID_82546EB_COPPER:
+	case E1000_DEV_ID_82546EB_FIBER:
+	case E1000_DEV_ID_82546EB_QUAD_COPPER:
+		return true;
+	default:
+		return false;
+	}
+}
+
+/**
  * e1000_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in e1000_pci_tbl
@@ -932,9 +970,19 @@ e1000_probe(struct pci_dev *pdev,
 	int i, err, pci_using_dac;
 	uint16_t eeprom_data = 0;
 	uint16_t eeprom_apme_mask = E1000_EEPROM_APME;
+	int bars, need_ioport;
 	DECLARE_MAC_BUF(mac);

-	if ((err = pci_enable_device(pdev)))
+	/* do not allocate ioport bars when not needed */
+	need_ioport = e1000_is_need_ioport(pdev);
+	if (need_ioport) {
+		bars = pci_select_bars(pdev, IORESOURCE_MEM | IORESOURCE_IO);
+		err = pci_enable_device(pdev);
+	} else {
+		bars = pci_select_bars(pdev, IORESOURCE_MEM);
+		err = pci_enable_device_mem(pdev);
+	}
+	if (err)
 		return err;

 	if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
@@ -949,7 +997,8 @@ e1000_probe(struct pci_dev *pdev,
 		pci_using_dac = 0;
 	}

-	if ((err = pci_request_regions(pdev, e1000_driver_name)))
+	err = pci_request_selected_regions(pdev, bars, e1000_driver_name);
+	if (err)
 		goto err_pci_reg;

 	pci_set_master(pdev);
@@ -967,6 +1016,8 @@ e1000_probe(struct pci_dev *pdev,
 	adapter->pdev = pdev;
 	adapter->hw.back = adapter;
 	adapter->msg_enable = (1 << debug) - 1;
+	adapter->bars = bars;
+	adapter->need_ioport = need_ioport;

 	err = -EIO;
 	adapter->hw.hw_addr = ioremap(pci_resource_start(pdev, BAR_0),
@@ -974,12 +1025,15 @@ e1000_probe(struct pci_dev *pdev,
 	if (!adapter->hw.hw_addr)
 		goto err_ioremap;

-	for (i = BAR_1; i <= BAR_5; i++) {
-		if (pci_resource_len(pdev, i) == 0)
-			continue;
-		if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
-			adapter->hw.io_base = pci_resource_start(pdev, i);
-			break;
+	if (adapter->need_ioport) {
+		for (i = BAR_1; i <= BAR_5; i++) {
+			if (pci_resource_len(pdev, i) == 0)
+				continue;
+			if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
+				adapter->hw.io_base =
+					pci_resource_start(pdev, i);
+				break;
+			}
 		}
 	}

@@ -1251,7 +1305,7 @@ err_sw_init:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, bars);
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -1304,7 +1358,7 @@ e1000_remove(struct pci_dev *pdev)
 	iounmap(adapter->hw.hw_addr);
 	if (adapter->hw.flash_address)
 		iounmap(adapter->hw.flash_address);
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, adapter->bars);

 	free_netdev(netdev);

@@ -5242,7 +5296,12 @@ e1000_resume(struct pci_dev *pdev)

 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	if ((err = pci_enable_device(pdev))) {
+
+	if (adapter->need_ioport)
+		err = pci_enable_device(pdev);
+	else
+		err = pci_enable_device_mem(pdev);
+	if (err) {
 		printk(KERN_ERR "e1000: Cannot enable PCI device from suspend\n");
 		return err;
 	}
@@ -5337,8 +5396,13 @@ static pci_ers_result_t e1000_io_slot_re
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev->priv;
+	int err;

-	if (pci_enable_device(pdev)) {
+	if (adapter->need_ioport)
+		err = pci_enable_device(pdev);
+	else
+		err = pci_enable_device_mem(pdev);
+	if (err) {
 		printk(KERN_ERR "e1000: Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}


