From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v2] pch_gbe: Switch to new PCI IRQ allocation API
Date: Sat, 14 Oct 2017 17:04:40 +0300
Message-ID: <20171014140440.21439-1-andriy.shevchenko@linux.intel.com>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
To: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:42568 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753570AbdJNOFn (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 14 Oct 2017 10:05:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes custom flag handling.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |  3 +-
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   | 42 +++++++++-------------
 2 files changed, 17 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
index 8d710a3b4db0..697e29dd4bd3 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
@@ -613,7 +613,6 @@ struct pch_gbe_privdata {
  * @rx_ring:		Pointer of Rx descriptor ring structure
  * @rx_buffer_len:	Receive buffer length
  * @tx_queue_len:	Transmit queue length
- * @have_msi:		PCI MSI mode flag
  * @pch_gbe_privdata:	PCI Device ID driver_data
  */
 
@@ -623,6 +622,7 @@ struct pch_gbe_adapter {
 	atomic_t irq_sem;
 	struct net_device *netdev;
 	struct pci_dev *pdev;
+	int irq;
 	struct net_device *polling_netdev;
 	struct napi_struct napi;
 	struct pch_gbe_hw hw;
@@ -637,7 +637,6 @@ struct pch_gbe_adapter {
 	struct pch_gbe_rx_ring *rx_ring;
 	unsigned long rx_buffer_len;
 	unsigned long tx_queue_len;
-	bool have_msi;
 	bool rx_stop_flag;
 	int hwts_tx_en;
 	int hwts_rx_en;
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 5ae9681a2da7..457ee80307ea 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -781,11 +781,8 @@ static void pch_gbe_free_irq(struct pch_gbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 
-	free_irq(adapter->pdev->irq, netdev);
-	if (adapter->have_msi) {
-		pci_disable_msi(adapter->pdev);
-		netdev_dbg(netdev, "call pci_disable_msi\n");
-	}
+	free_irq(adapter->irq, netdev);
+	pci_free_irq_vectors(adapter->pdev);
 }
 
 /**
@@ -799,7 +796,7 @@ static void pch_gbe_irq_disable(struct pch_gbe_adapter *adapter)
 	atomic_inc(&adapter->irq_sem);
 	iowrite32(0, &hw->reg->INT_EN);
 	ioread32(&hw->reg->INT_ST);
-	synchronize_irq(adapter->pdev->irq);
+	synchronize_irq(adapter->irq);
 
 	netdev_dbg(adapter->netdev, "INT_EN reg : 0x%08x\n",
 		   ioread32(&hw->reg->INT_EN));
@@ -1903,30 +1900,23 @@ static int pch_gbe_request_irq(struct pch_gbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
 	int err;
-	int flags;
 
-	flags = IRQF_SHARED;
-	adapter->have_msi = false;
-	err = pci_enable_msi(adapter->pdev);
-	netdev_dbg(netdev, "call pci_enable_msi\n");
-	if (err) {
-		netdev_dbg(netdev, "call pci_enable_msi - Error: %d\n", err);
-	} else {
-		flags = 0;
-		adapter->have_msi = true;
-	}
-	err = request_irq(adapter->pdev->irq, &pch_gbe_intr,
-			  flags, netdev->name, netdev);
+	err = pci_alloc_irq_vectors(adapter->pdev, 1, 1, PCI_IRQ_ALL_TYPES);
+	if (err < 0)
+		return err;
+
+	adapter->irq = pci_irq_vector(adapter->pdev, 0);
+
+	err = request_irq(adapter->irq, &pch_gbe_intr, IRQF_SHARED,
+			  netdev->name, netdev);
 	if (err)
 		netdev_err(netdev, "Unable to allocate interrupt Error: %d\n",
 			   err);
-	netdev_dbg(netdev,
-		   "adapter->have_msi : %d  flags : 0x%04x  return : 0x%04x\n",
-		   adapter->have_msi, flags, err);
+	netdev_dbg(netdev, "have_msi : %d  return : 0x%04x\n",
+		   pci_dev_msi_enabled(adapter->pdev), err);
 	return err;
 }
 
-
 /**
  * pch_gbe_up - Up GbE network device
  * @adapter:  Board private structure
@@ -2399,9 +2389,9 @@ static void pch_gbe_netpoll(struct net_device *netdev)
 {
 	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
 
-	disable_irq(adapter->pdev->irq);
-	pch_gbe_intr(adapter->pdev->irq, netdev);
-	enable_irq(adapter->pdev->irq);
+	disable_irq(adapter->irq);
+	pch_gbe_intr(adapter->irq, netdev);
+	enable_irq(adapter->irq);
 }
 #endif
 
-- 
2.14.2
