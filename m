From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 9/9] e1000: make ioport free
Date: Fri, 11 Jul 2008 15:17:44 -0700
Message-ID: <20080711221744.3255.78358.stgit@localhost.localdomain>
References: <20080711221442.3255.16180.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>,
	Auke Kok <auke-jan.h.kok@intel.com>,
	Taku Izumi <izumi.taku@jp.fujitsu.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:63952 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756899AbYGKWRz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2008 18:17:55 -0400
In-Reply-To: <20080711221442.3255.16180.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Taku Izumi <izumi.taku@jp.fugitsu.com>

This patch makes e1000 driver ioport-free.
This corrects behavior in probe function so as not to request ioport
resources as long as they are not really needed.  This is based on the
ioport-free patch of e1000 driver from Auke Kok and Tomohiro Kusumi.

Signed-off-by: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
Signed-off-by: Jeff Kirsher<jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000.h      |    4 ++
 drivers/net/e1000/e1000_main.c |   83 ++++++++++++++++++++++++++++++++++------
 2 files changed, 74 insertions(+), 13 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 583b823..19e317e 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -340,6 +340,10 @@ struct e1000_adapter {
 	bool quad_port_a;
 	unsigned long flags;
 	u32 eeprom_wol;
+
+	/* for ioport free */
+	int bars;
+	int need_ioport;
 };
 
 enum e1000_state_t {
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 19ac606..a7d6249 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -859,6 +859,42 @@ static void e1000_dump_eeprom(struct e1000_adapter *adapter)
 }
 
 /**
+ * e1000_is_need_ioport - determine if an adapter needs ioport resources or not
+ * @pdev: PCI device information struct
+ *
+ * Return true if an adapter needs ioport resources
+ **/
+static int e1000_is_need_ioport(struct pci_dev *pdev)
+{
+	switch (pdev->device) {
+	case E1000_DEV_ID_82540EM:
+	case E1000_DEV_ID_82540EM_LOM:
+	case E1000_DEV_ID_82540EP:
+	case E1000_DEV_ID_82540EP_LOM:
+	case E1000_DEV_ID_82540EP_LP:
+	case E1000_DEV_ID_82541EI:
+	case E1000_DEV_ID_82541EI_MOBILE:
+	case E1000_DEV_ID_82541ER:
+	case E1000_DEV_ID_82541ER_LOM:
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
@@ -869,7 +905,6 @@ static void e1000_dump_eeprom(struct e1000_adapter *adapter)
  * The OS initialization, configuring of the adapter private structure,
  * and a hardware reset occur.
  **/
-
 static int __devinit e1000_probe(struct pci_dev *pdev,
 				 const struct pci_device_id *ent)
 {
@@ -882,9 +917,18 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	int i, err, pci_using_dac;
 	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = E1000_EEPROM_APME;
+	int bars, need_ioport;
 	DECLARE_MAC_BUF(mac);
 
-	err = pci_enable_device(pdev);
+	/* do not allocate ioport bars when not needed */
+	need_ioport = e1000_is_need_ioport(pdev);
+	if (need_ioport) {
+		bars = pci_select_bars(pdev, IORESOURCE_MEM | IORESOURCE_IO);
+		err = pci_enable_device(pdev);
+	} else {
+		bars = pci_select_bars(pdev, IORESOURCE_MEM);
+		err = pci_enable_device(pdev);
+	}
 	if (err)
 		return err;
 
@@ -904,7 +948,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		pci_using_dac = 0;
 	}
 
-	err = pci_request_regions(pdev, e1000_driver_name);
+	err = pci_request_selected_regions(pdev, bars, e1000_driver_name);
 	if (err)
 		goto err_pci_reg;
 
@@ -922,6 +966,8 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	adapter->netdev = netdev;
 	adapter->pdev = pdev;
 	adapter->msg_enable = (1 << debug) - 1;
+	adapter->bars = bars;
+	adapter->need_ioport = need_ioport;
 
 	hw = &adapter->hw;
 	hw->back = adapter;
@@ -932,12 +978,14 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	if (!hw->hw_addr)
 		goto err_ioremap;
 
-	for (i = BAR_1; i <= BAR_5; i++) {
-		if (pci_resource_len(pdev, i) == 0)
-			continue;
-		if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
-			hw->io_base = pci_resource_start(pdev, i);
-			break;
+	if (adapter->need_ioport) {
+		for (i = BAR_1; i <= BAR_5; i++) {
+			if (pci_resource_len(pdev, i) == 0)
+				continue;
+			if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
+				hw->io_base = pci_resource_start(pdev, i);
+				break;
+			}
 		}
 	}
 
@@ -1202,7 +1250,7 @@ err_sw_init:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, bars);
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -1249,7 +1297,7 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	iounmap(hw->hw_addr);
 	if (hw->flash_address)
 		iounmap(hw->flash_address);
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, adapter->bars);
 
 	free_netdev(netdev);
 
@@ -5038,7 +5086,11 @@ static int e1000_resume(struct pci_dev *pdev)
 
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	err = pci_enable_device(pdev);
+
+	if (adapter->need_ioport)
+		err = pci_enable_device(pdev);
+	else
+		err = pci_enable_device_mem(pdev);
 	if (err) {
 		printk(KERN_ERR "e1000: Cannot enable PCI device from suspend\n");
 		return err;
@@ -5134,8 +5186,13 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev->priv;
 	struct e1000_hw *hw = &adapter->hw;
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

