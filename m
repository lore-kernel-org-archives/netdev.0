From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH 4/4] e1000e: remove inapplicable test for ioport
Date: Mon, 04 Aug 2008 17:21:53 -0700
Message-ID: <20080805002145.24137.80353.stgit@localhost.localdomain>
References: <20080805002030.24137.10360.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	akpm@linux-foundation.org, Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:63177 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755399AbYHEAVy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 20:21:54 -0400
In-Reply-To: <20080805002030.24137.10360.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

There are currently no devices supported by the e1000e driver which need
ioport resources, remove the test for it and all unnecessary code
associated with it (struct e1000_adapter elements, local variables, etc.)

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/e1000.h  |    4 ----
 drivers/net/e1000e/netdev.c |   48 +++++++++----------------------------------
 2 files changed, 10 insertions(+), 42 deletions(-)

diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index d3ed1ed..cf57050 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -284,10 +284,6 @@ struct e1000_adapter {
 	unsigned long led_status;
 
 	unsigned int flags;
-
-	/* for ioport free */
-	int bars;
-	int need_ioport;
 };
 
 struct e1000_info {
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 18f076c..05b0b2f 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3991,10 +3991,7 @@ static int e1000_resume(struct pci_dev *pdev)
 	pci_restore_state(pdev);
 	e1000e_disable_l1aspm(pdev);
 
-	if (adapter->need_ioport)
-		err = pci_enable_device(pdev);
-	else
-		err = pci_enable_device_mem(pdev);
+	err = pci_enable_device_mem(pdev);
 	if (err) {
 		dev_err(&pdev->dev,
 			"Cannot enable PCI device from suspend\n");
@@ -4096,10 +4093,7 @@ static pci_ers_result_t e1000_io_slot_reset(struct pci_dev *pdev)
 	int err;
 
 	e1000e_disable_l1aspm(pdev);
-	if (adapter->need_ioport)
-		err = pci_enable_device(pdev);
-	else
-		err = pci_enable_device_mem(pdev);
+	err = pci_enable_device_mem(pdev);
 	if (err) {
 		dev_err(&pdev->dev,
 			"Cannot re-enable PCI device after reset.\n");
@@ -4197,21 +4191,6 @@ static void e1000_eeprom_checks(struct e1000_adapter *adapter)
 }
 
 /**
- * e1000e_is_need_ioport - determine if an adapter needs ioport resources or not
- * @pdev: PCI device information struct
- *
- * Returns true if an adapters needs ioport resources
- **/
-static int e1000e_is_need_ioport(struct pci_dev *pdev)
-{
-	switch (pdev->device) {
-	/* Currently there are no adapters that need ioport resources */
-	default:
-		return false;
-	}
-}
-
-/**
  * e1000_probe - Device Initialization Routine
  * @pdev: PCI device information struct
  * @ent: entry in e1000_pci_tbl
@@ -4236,19 +4215,10 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	int i, err, pci_using_dac;
 	u16 eeprom_data = 0;
 	u16 eeprom_apme_mask = E1000_EEPROM_APME;
-	int bars, need_ioport;
 
 	e1000e_disable_l1aspm(pdev);
 
-	/* do not allocate ioport bars when not needed */
-	need_ioport = e1000e_is_need_ioport(pdev);
-	if (need_ioport) {
-		bars = pci_select_bars(pdev, IORESOURCE_MEM | IORESOURCE_IO);
-		err = pci_enable_device(pdev);
-	} else {
-		bars = pci_select_bars(pdev, IORESOURCE_MEM);
-		err = pci_enable_device_mem(pdev);
-	}
+	err = pci_enable_device_mem(pdev);
 	if (err)
 		return err;
 
@@ -4271,7 +4241,9 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 		}
 	}
 
-	err = pci_request_selected_regions(pdev, bars, e1000e_driver_name);
+	err = pci_request_selected_regions(pdev,
+	                                  pci_select_bars(pdev, IORESOURCE_MEM),
+	                                  e1000e_driver_name);
 	if (err)
 		goto err_pci_reg;
 
@@ -4296,8 +4268,6 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	adapter->hw.adapter = adapter;
 	adapter->hw.mac.type = ei->mac;
 	adapter->msg_enable = (1 << NETIF_MSG_DRV | NETIF_MSG_PROBE) - 1;
-	adapter->bars = bars;
-	adapter->need_ioport = need_ioport;
 
 	mmio_start = pci_resource_start(pdev, 0);
 	mmio_len = pci_resource_len(pdev, 0);
@@ -4536,7 +4506,8 @@ err_flashmap:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_selected_regions(pdev, bars);
+	pci_release_selected_regions(pdev,
+	                             pci_select_bars(pdev, IORESOURCE_MEM));
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -4584,7 +4555,8 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 	iounmap(adapter->hw.hw_addr);
 	if (adapter->hw.flash_address)
 		iounmap(adapter->hw.flash_address);
-	pci_release_selected_regions(pdev, adapter->bars);
+	pci_release_selected_regions(pdev,
+	                             pci_select_bars(pdev, IORESOURCE_MEM));
 
 	free_netdev(netdev);
 

