From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 3/8] e1000e: cleanup NAPI routine
Date: Wed,  4 Apr 2012 00:55:55 -0700
Message-ID: <1333526160-24937-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1333526160-24937-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:39155 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754391Ab2DDH4E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Apr 2012 03:56:04 -0400
In-Reply-To: <1333526160-24937-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

Rename NAPI polling routine and a parameter with more appropriate names,
refactor a conditional branch to get rid of an unnecessary goto/label and
fix a line exceeding 80 columns.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c |   28 +++++++++++++---------------
 1 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 6b63388..d88445d 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -2524,33 +2524,31 @@ err:
 }
 
 /**
- * e1000_clean - NAPI Rx polling callback
+ * e1000e_poll - NAPI Rx polling callback
  * @napi: struct associated with this polling callback
- * @budget: amount of packets driver is allowed to process this poll
+ * @weight: number of packets driver is allowed to process this poll
  **/
-static int e1000_clean(struct napi_struct *napi, int budget)
+static int e1000e_poll(struct napi_struct *napi, int weight)
 {
-	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter, napi);
+	struct e1000_adapter *adapter = container_of(napi, struct e1000_adapter,
+						     napi);
 	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *poll_dev = adapter->netdev;
 	int tx_cleaned = 1, work_done = 0;
 
 	adapter = netdev_priv(poll_dev);
 
-	if (adapter->msix_entries &&
-	    !(adapter->rx_ring->ims_val & adapter->tx_ring->ims_val))
-		goto clean_rx;
+	if (!adapter->msix_entries ||
+	    (adapter->rx_ring->ims_val & adapter->tx_ring->ims_val))
+		tx_cleaned = e1000_clean_tx_irq(adapter->tx_ring);
 
-	tx_cleaned = e1000_clean_tx_irq(adapter->tx_ring);
-
-clean_rx:
-	adapter->clean_rx(adapter->rx_ring, &work_done, budget);
+	adapter->clean_rx(adapter->rx_ring, &work_done, weight);
 
 	if (!tx_cleaned)
-		work_done = budget;
+		work_done = weight;
 
-	/* If budget not fully consumed, exit the polling mode */
-	if (work_done < budget) {
+	/* If weight not fully consumed, exit the polling mode */
+	if (work_done < weight) {
 		if (adapter->itr_setting & 3)
 			e1000_set_itr(adapter);
 		napi_complete(napi);
@@ -6201,7 +6199,7 @@ static int __devinit e1000_probe(struct pci_dev *pdev,
 	netdev->netdev_ops		= &e1000e_netdev_ops;
 	e1000e_set_ethtool_ops(netdev);
 	netdev->watchdog_timeo		= 5 * HZ;
-	netif_napi_add(netdev, &adapter->napi, e1000_clean, 64);
+	netif_napi_add(netdev, &adapter->napi, e1000e_poll, 64);
 	strlcpy(netdev->name, pci_name(pdev), sizeof(netdev->name));
 
 	netdev->mem_start = mmio_start;
-- 
1.7.7.6
