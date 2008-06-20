From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH 2/3] e1000e: make ioport free
Date: Fri, 20 Jun 2008 11:57:02 +0900
Message-ID: <485B1C7E.90203@jp.fujitsu.com>
References: <485B1B8E.1060108@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>,
	auke-jan.h.kok@intel.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:37009 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751966AbYFTC5P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jun 2008 22:57:15 -0400
In-Reply-To: <485B1B8E.1060108@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes e1000e driver ioport-free.
This corrects behavior in probe function so as not to request ioport
resources as long as they are not really needed.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/e1000e/e1000.h  |    4 +++
 drivers/net/e1000e/netdev.c |   48 ++++++++++++++++++++++++++++++++++++++------
 2 files changed, 46 insertions(+), 6 deletions(-)

Index: linux-2.6.25.7/drivers/net/e1000e/e1000.h
===================================================================
--- linux-2.6.25.7.orig/drivers/net/e1000e/e1000.h
+++ linux-2.6.25.7/drivers/net/e1000e/e1000.h
@@ -266,6 +266,10 @@ struct e1000_adapter {
 	unsigned long led_status;

 	unsigned int flags;
+
+	/* for ioport free */
+	int bars;
+	int need_ioport;
 };

 struct e1000_info {
Index: linux-2.6.25.7/drivers/net/e1000e/netdev.c
===================================================================
--- linux-2.6.25.7.orig/drivers/net/e1000e/netdev.c
+++ linux-2.6.25.7/drivers/net/e1000e/netdev.c
@@ -3523,7 +3523,11 @@ static int e1000_resume(struct pci_dev *
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 	e1000e_disable_l1aspm(pdev);
-	err = pci_enable_device(pdev);
+
+	if (adapter->need_ioport)
+		err = pci_enable_device(pdev);
+	else
+		err = pci_enable_device_mem(pdev);
 	if (err) {
 		dev_err(&pdev->dev,
 			"Cannot enable PCI device from suspend\n");
@@ -3622,9 +3626,14 @@ static pci_ers_result_t e1000_io_slot_re
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	int err;

 	e1000e_disable_l1aspm(pdev);
-	if (pci_enable_device(pdev)) {
+	if (adapter->need_ioport)
+		err = pci_enable_device(pdev);
+	else
+		err = pci_enable_device_mem(pdev);
+	if (err) {
 		dev_err(&pdev->dev,
 			"Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
@@ -3700,6 +3709,21 @@ static void e1000_print_device_info(stru
 }

 /**
+ * e1000e_is_need_ioport - determine if an adapter needs ioport resources or not
+ * @pdev: PCI device information struct
+ *
+ * Returns true if an adapters needs ioport resources
+ **/
+static int e1000e_is_need_ioport(struct pci_dev *pdev)
+{
+	switch (pdev->device) {
+	/* Currently there are no adapters that need ioport resources */
+	default:
+		return false;
+	}
+}
+
+/**
  * e1000_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in e1000_pci_tbl
@@ -3724,9 +3748,19 @@ static int __devinit e1000_probe(struct
 	int i, err, pci_using_dac;
 	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = E1000_EEPROM_APME;
+	int bars, need_ioport;

 	e1000e_disable_l1aspm(pdev);
-	err = pci_enable_device(pdev);
+
+	/* do not allocate ioport bars when not needed */
+	need_ioport = e1000e_is_need_ioport(pdev);
+	if (need_ioport) {
+		bars = pci_select_bars(pdev, IORESOURCE_MEM | IORESOURCE_IO);
+		err = pci_enable_device(pdev);
+	} else {
+		bars = pci_select_bars(pdev, IORESOURCE_MEM);
+		err = pci_enable_device_mem(pdev);
+	}
 	if (err)
 		return err;

@@ -3749,7 +3783,7 @@ static int __devinit e1000_probe(struct
 		}
 	}

-	err = pci_request_regions(pdev, e1000e_driver_name);
+	err = pci_request_selected_regions(pdev, bars, e1000e_driver_name);
 	if (err)
 		goto err_pci_reg;

@@ -3773,6 +3807,8 @@ static int __devinit e1000_probe(struct
 	adapter->hw.adapter = adapter;
 	adapter->hw.mac.type = ei->mac;
 	adapter->msg_enable = (1 << NETIF_MSG_DRV | NETIF_MSG_PROBE) - 1;
+	adapter->bars = bars;
+	adapter->need_ioport = need_ioport;

 	mmio_start = pci_resource_start(pdev, 0);
 	mmio_len = pci_resource_len(pdev, 0);
@@ -4001,7 +4037,7 @@ err_sw_init:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, bars);
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -4045,7 +4081,7 @@ static void __devexit e1000_remove(struc
 	iounmap(adapter->hw.hw_addr);
 	if (adapter->hw.flash_address)
 		iounmap(adapter->hw.flash_address);
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, adapter->bars);

 	free_netdev(netdev);



