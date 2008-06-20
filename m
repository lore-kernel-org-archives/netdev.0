From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 3/3] igb: make ioport free
Date: Fri, 20 Jun 2008 12:10:30 +0900
Message-ID: <485B1FA6.4040707@jp.fujitsu.com>
References: <485B1B8E.1060108@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>,
	auke-jan.h.kok@intel.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:38043 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751657AbYFTDK5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 23:10:57 -0400
In-Reply-To: <485B1B8E.1060108@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes igb driver ioport-free.
This corrects behavior in probe function so as not to request ioport
resources as long as they are not really needed.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/igb/igb.h      |    4 +++
 drivers/net/igb/igb_main.c |   47 +++++++++++++++++++++++++++++++++++++++------
 2 files changed, 45 insertions(+), 6 deletions(-)

Index: linux-2.6.25.7/drivers/net/igb/igb.h
===================================================================
--- linux-2.6.25.7.orig/drivers/net/igb/igb.h
+++ linux-2.6.25.7/drivers/net/igb/igb.h
@@ -271,6 +271,10 @@ struct igb_adapter {
 	unsigned int msi_enabled;

 	u32 eeprom_wol;
+
+	/* for ioport free */
+	int bars;
+	int need_ioport;
 };

 enum e1000_state_t {
Index: linux-2.6.25.7/drivers/net/igb/igb_main.c
===================================================================
--- linux-2.6.25.7.orig/drivers/net/igb/igb_main.c
+++ linux-2.6.25.7/drivers/net/igb/igb_main.c
@@ -820,6 +820,21 @@ void igb_reset(struct igb_adapter *adapt
 }

 /**
+ * igb_is_need_ioport - determine if an adapter needs ioport resources or not
+ * @pdev: PCI device information struct
+ *
+ * Returns true if an adapter needs ioport resources
+ **/
+static int igb_is_need_ioport(struct pci_dev *pdev)
+{
+	switch (pdev->device) {
+	/* Currently there are no adapters that need ioport resources */
+	default:
+		return false;
+	}
+}
+
+/**
  * igb_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in igb_pci_tbl
@@ -843,8 +858,17 @@ static int __devinit igb_probe(struct pc
 	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = IGB_EEPROM_APME;
 	u32 part_num;
+	int bars, need_ioport;

-	err = pci_enable_device(pdev);
+	/* do not allocate ioport bars when not needed */
+	need_ioport = igb_is_need_ioport(pdev);
+	if (need_ioport) {
+		bars = pci_select_bars(pdev, IORESOURCE_MEM | IORESOURCE_IO);
+		err = pci_enable_device(pdev);
+	} else {
+		bars = pci_select_bars(pdev, IORESOURCE_MEM);
+		err = pci_enable_device_mem(pdev);
+	}
 	if (err)
 		return err;

@@ -866,7 +890,7 @@ static int __devinit igb_probe(struct pc
 		}
 	}

-	err = pci_request_regions(pdev, igb_driver_name);
+	err = pci_request_selected_regions(pdev, bars, igb_driver_name);
 	if (err)
 		goto err_pci_reg;

@@ -886,6 +910,8 @@ static int __devinit igb_probe(struct pc
 	hw = &adapter->hw;
 	hw->back = adapter;
 	adapter->msg_enable = NETIF_MSG_DRV | NETIF_MSG_PROBE;
+	adapter->bars = bars;
+	adapter->need_ioport = need_ioport;

 	mmio_start = pci_resource_start(pdev, 0);
 	mmio_len = pci_resource_len(pdev, 0);
@@ -1121,7 +1147,7 @@ err_hw_init:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, bars);
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -1168,7 +1194,7 @@ static void __devexit igb_remove(struct
 	iounmap(adapter->hw.hw_addr);
 	if (adapter->hw.flash_address)
 		iounmap(adapter->hw.flash_address);
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, adapter->bars);

 	free_netdev(netdev);

@@ -3969,7 +3995,11 @@ static int igb_resume(struct pci_dev *pd

 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
-	err = pci_enable_device(pdev);
+
+	if (adapter->need_ioport)
+		err = pci_enable_device(pdev);
+	else
+		err = pci_enable_device_mem(pdev);
 	if (err) {
 		dev_err(&pdev->dev,
 			"igb: Cannot enable PCI device from suspend\n");
@@ -4072,8 +4102,13 @@ static pci_ers_result_t igb_io_slot_rese
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	int err;

-	if (pci_enable_device(pdev)) {
+	if (adapter->need_ioport)
+		err = pci_enable_device(pdev);
+	else
+		err = pci_enable_device_mem(pdev);
+	if (err) {
 		dev_err(&pdev->dev,
 			"Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;


