From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/4] [RFC] e1000: make ioport free for supported devices
Date: Mon, 03 Mar 2008 14:37:37 -0800
Message-ID: <20080303223737.16344.16498.stgit@localhost.localdomain>
References: <20080303223731.16344.94975.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:4659 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754496AbYCCWnn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Mar 2008 17:43:43 -0500
In-Reply-To: <20080303223731.16344.94975.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>

Most e1000 devices do not need ioport access to function properly.
This is desirable for a few massive homed systems where ioport
resources become constrained.

This patch is based on the code from Tomohiro Kusumi, heavily
modified to fit PCI API changes and e1000 driver changes.

Signed-off-by: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000.h      |    3 +
 drivers/net/e1000/e1000_main.c |   90 +++++++++++++++++++++++++++++++++++-----
 2 files changed, 81 insertions(+), 12 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 3b84028..47e153f 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -343,6 +343,9 @@ struct e1000_adapter {
 	boolean_t quad_port_a;
 	unsigned long flags;
 	uint32_t eeprom_wol;
+
+	int bars;
+	int need_ioport;
 };
 
 enum e1000_state_t {
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 0991648..e8f51c4 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -909,6 +909,44 @@ static void e1000_dump_eeprom(struct e1000_adapter *adapter)
 }
 
 /**
+ * e1000_require_ioport - determine if adapter type requires ioport resources
+ * @pdev: PCI device struct
+ *
+ * returns true for devices that require IOport access to the PCI device.
+ **/
+static int e1000_require_ioport(struct pci_dev *pdev)
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
+		return 1;
+		break;
+	default:
+		return 0;
+		break;
+	}
+}
+
+/**
  * e1000_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in e1000_pci_tbl
@@ -932,9 +970,20 @@ e1000_probe(struct pci_dev *pdev,
 	int i, err, pci_using_dac;
 	uint16_t eeprom_data = 0;
 	uint16_t eeprom_apme_mask = E1000_EEPROM_APME;
+	int bars;
+	int need_ioport;
 	DECLARE_MAC_BUF(mac);
 
-	if ((err = pci_enable_device(pdev)))
+	/* do not allocate IOport bars when not needed */
+	need_ioport = e1000_require_ioport(pdev);
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
@@ -949,7 +998,8 @@ e1000_probe(struct pci_dev *pdev,
 		pci_using_dac = 0;
 	}
 
-	if ((err = pci_request_regions(pdev, e1000_driver_name)))
+	err = pci_request_selected_regions(pdev, bars, e1000_driver_name);
+	if (err)
 		goto err_pci_reg;
 
 	pci_set_master(pdev);
@@ -963,6 +1013,8 @@ e1000_probe(struct pci_dev *pdev,
 
 	pci_set_drvdata(pdev, netdev);
 	adapter = netdev_priv(netdev);
+	adapter->bars = bars;
+	adapter->need_ioport = need_ioport;
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
 	adapter->hw.back = adapter;
@@ -974,12 +1026,15 @@ e1000_probe(struct pci_dev *pdev,
 	if (!adapter->hw.hw_addr)
 		goto err_ioremap;
 
-	for (i = BAR_1; i <= BAR_5; i++) {
-		if (pci_resource_len(pdev, i) == 0)
-			continue;
-		if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
-			adapter->hw.io_base = pci_resource_start(pdev, i);
-			break;
+	if (adapter->need_ioport) {
+		for (i = 1; i <= 5; i++) {
+			if (pci_resource_len(pdev, i) == 0)
+				continue;
+			if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
+				adapter->hw.io_base = pci_resource_start(pdev,
+									 i);
+				break;
+			}
 		}
 	}
 
@@ -1251,7 +1306,7 @@ err_sw_init:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, bars);
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -1304,7 +1359,7 @@ e1000_remove(struct pci_dev *pdev)
 	iounmap(adapter->hw.hw_addr);
 	if (adapter->hw.flash_address)
 		iounmap(adapter->hw.flash_address);
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, adapter->bars);
 
 	free_netdev(netdev);
 
@@ -5242,7 +5297,12 @@ e1000_resume(struct pci_dev *pdev)
 
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
@@ -5337,8 +5397,14 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 {
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev->priv;
+	int err;
 
-	if (pci_enable_device(pdev)) {
+	if (adapter->need_ioport)
+		err = pci_enable_device(pdev);
+	else
+		err = pci_enable_device_mem(pdev);
+
+	if (err) {
 		printk(KERN_ERR "e1000: Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
 	}

