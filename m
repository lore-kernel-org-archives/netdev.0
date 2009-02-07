From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 04/26] igb: remove check for needing an io port
Date: Sat, 07 Feb 2009 01:16:04 -0800
Message-ID: <20090207091604.15697.40178.stgit@lost.foo-projects.org>
References: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:37234
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751657AbZBGJQZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2009 04:16:25 -0500
In-Reply-To: <20090207091504.15697.26667.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

Since igb supports only pci-e nics and there is no plan to support any
legacy pci parts in the driver there isn't really much need for checking to
see if an io port is needed.

In the unlikely event that we do begin supporting legacy pci parts then we
can see about adding this code back to the driver.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h      |    4 ----
 drivers/net/igb/igb_main.c |   50 +++++++++-----------------------------------
 2 files changed, 10 insertions(+), 44 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 30657dd..530d7aa 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -273,10 +273,6 @@ struct igb_adapter {
 	unsigned int flags;
 	u32 eeprom_wol;
 
-	/* for ioport free */
-	int bars;
-	int need_ioport;
-
 	struct igb_ring *multi_tx_table[IGB_MAX_TX_QUEUES];
 	unsigned int tx_ring_count;
 	unsigned int rx_ring_count;
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 6ef0adb..13b10ba 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -974,21 +974,6 @@ void igb_reset(struct igb_adapter *adapter)
 	igb_get_phy_info(&adapter->hw);
 }
 
-/**
- * igb_is_need_ioport - determine if an adapter needs ioport resources or not
- * @pdev: PCI device information struct
- *
- * Returns true if an adapter needs ioport resources
- **/
-static int igb_is_need_ioport(struct pci_dev *pdev)
-{
-	switch (pdev->device) {
-	/* Currently there are no adapters that need ioport resources */
-	default:
-		return false;
-	}
-}
-
 static const struct net_device_ops igb_netdev_ops = {
 	.ndo_open 		= igb_open,
 	.ndo_stop		= igb_close,
@@ -1032,17 +1017,8 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	u16 eeprom_data = 0, state = 0;
 	u16 eeprom_apme_mask = IGB_EEPROM_APME;
 	u32 part_num;
-	int bars, need_ioport;
 
-	/* do not allocate ioport bars when not needed */
-	need_ioport = igb_is_need_ioport(pdev);
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
 
@@ -1085,7 +1061,9 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 		break;
 	}
 
-	err = pci_request_selected_regions(pdev, bars, igb_driver_name);
+	err = pci_request_selected_regions(pdev, pci_select_bars(pdev,
+	                                   IORESOURCE_MEM),
+	                                   igb_driver_name);
 	if (err)
 		goto err_pci_reg;
 
@@ -1113,8 +1091,6 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	hw = &adapter->hw;
 	hw->back = adapter;
 	adapter->msg_enable = NETIF_MSG_DRV | NETIF_MSG_PROBE;
-	adapter->bars = bars;
-	adapter->need_ioport = need_ioport;
 
 	mmio_start = pci_resource_start(pdev, 0);
 	mmio_len = pci_resource_len(pdev, 0);
@@ -1361,7 +1337,8 @@ err_hw_init:
 err_ioremap:
 	free_netdev(netdev);
 err_alloc_etherdev:
-	pci_release_selected_regions(pdev, bars);
+	pci_release_selected_regions(pdev, pci_select_bars(pdev,
+	                             IORESOURCE_MEM));
 err_pci_reg:
 err_dma:
 	pci_disable_device(pdev);
@@ -1420,7 +1397,8 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 	iounmap(adapter->hw.hw_addr);
 	if (adapter->hw.flash_address)
 		iounmap(adapter->hw.flash_address);
-	pci_release_selected_regions(pdev, adapter->bars);
+	pci_release_selected_regions(pdev, pci_select_bars(pdev,
+	                             IORESOURCE_MEM));
 
 	free_netdev(netdev);
 
@@ -4309,10 +4287,7 @@ static int igb_resume(struct pci_dev *pdev)
 	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
 
-	if (adapter->need_ioport)
-		err = pci_enable_device(pdev);
-	else
-		err = pci_enable_device_mem(pdev);
+	err = pci_enable_device_mem(pdev);
 	if (err) {
 		dev_err(&pdev->dev,
 			"igb: Cannot enable PCI device from suspend\n");
@@ -4423,12 +4398,7 @@ static pci_ers_result_t igb_io_slot_reset(struct pci_dev *pdev)
 	pci_ers_result_t result;
 	int err;
 
-	if (adapter->need_ioport)
-		err = pci_enable_device(pdev);
-	else
-		err = pci_enable_device_mem(pdev);
-
-	if (err) {
+	if (pci_enable_device_mem(pdev)) {
 		dev_err(&pdev->dev,
 			"Cannot re-enable PCI device after reset.\n");
 		result = PCI_ERS_RESULT_DISCONNECT;

