From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] e1000e: make ioport free
Date: Mon, 23 Jun 2008 17:32:09 +0900
Message-ID: <485F5F89.7070104@jp.fujitsu.com>
References: <485B1B8E.1060108@jp.fujitsu.com> <485B1C7E.90203@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>,
	auke-jan.h.kok@intel.com
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:57593 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755327AbYFWIct (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 04:32:49 -0400
In-Reply-To: <485B1C7E.90203@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch makes e1000e driver ioport-free.
This corrects behavior in probe function so as not to request ioport
resources.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
---
 drivers/net/e1000e/e1000.h  |    3 +++
 drivers/net/e1000e/netdev.c |   20 ++++++++++++++------
 2 files changed, 17 insertions(+), 6 deletions(-)

Index: linux-2.6.25.7/drivers/net/e1000e/e1000.h
===================================================================
--- linux-2.6.25.7.orig/drivers/net/e1000e/e1000.h
+++ linux-2.6.25.7/drivers/net/e1000e/e1000.h
@@ -266,6 +266,9 @@ struct e1000_adapter {
 	unsigned long led_status;

 	unsigned int flags;
+
+	/* for ioport free */
+	int bars;
 };

 struct e1000_info {
Index: linux-2.6.25.7/drivers/net/e1000e/netdev.c
===================================================================
--- linux-2.6.25.7.orig/drivers/net/e1000e/netdev.c
+++ linux-2.6.25.7/drivers/net/e1000e/netdev.c
@@ -3523,7 +3523,8 @@ static int e1000_resume(struct pci_dev *
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 	e1000e_disable_l1aspm(pdev);
-	err = pci_enable_device(pdev);
+
+	err = pci_enable_device_mem(pdev);
 	if (err) {
 		dev_err(&pdev->dev,
 			"Cannot enable PCI device from suspend\n");
@@ -3622,9 +3623,11 @@ static pci_ers_result_t e1000_io_slot_re
 	struct net_device *netdev = pci_get_drvdata(pdev);
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
+	int err;

 	e1000e_disable_l1aspm(pdev);
-	if (pci_enable_device(pdev)) {
+	err = pci_enable_device_mem(pdev);
+	if (err) {
 		dev_err(&pdev->dev,
 			"Cannot re-enable PCI device after reset.\n");
 		return PCI_ERS_RESULT_DISCONNECT;
@@ -3724,9 +3727,13 @@ static int __devinit e1000_probe(struct
 	int i, err, pci_using_dac;
 	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = E1000_EEPROM_APME;
+	int bars;

 	e1000e_disable_l1aspm(pdev);
-	err = pci_enable_device(pdev);
+
+	/* do not allocate ioport bars when not needed */
+	bars = pci_select_bars(pdev, IORESOURCE_MEM);
+	err = pci_enable_device_mem(pdev);
 	if (err)
 		return err;

@@ -3749,7 +3756,7 @@ static int __devinit e1000_probe(struct
 		}
 	}

-	err = pci_request_regions(pdev, e1000e_driver_name);
+	err = pci_request_selected_regions(pdev, bars, e1000e_driver_name);
 	if (err)
 		goto err_pci_reg;

@@ -3773,6 +3780,7 @@ static int __devinit e1000_probe(struct
 	adapter->hw.adapter = adapter;
 	adapter->hw.mac.type = ei->mac;
 	adapter->msg_enable = (1 << NETIF_MSG_DRV | NETIF_MSG_PROBE) - 1;
+	adapter->bars = bars;

 	mmio_start = pci_resource_start(pdev, 0);
 	mmio_len = pci_resource_len(pdev, 0);
@@ -4001,7 +4009,7 @@ err_sw_init:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, bars);
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -4045,7 +4053,7 @@ static void __devexit e1000_remove(struc
 	iounmap(adapter->hw.hw_addr);
 	if (adapter->hw.flash_address)
 		iounmap(adapter->hw.flash_address);
-	pci_release_regions(pdev);
+	pci_release_selected_regions(pdev, adapter->bars);

 	free_netdev(netdev);



