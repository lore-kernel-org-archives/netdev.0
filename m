From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/15] e1000e: Modify Tx/Rx configurations to avoid null pointer dereferences in e1000_open
Date: Tue, 18 Aug 2015 14:09:17 -0700
Message-ID: <1439932162-1995-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jia-Ju Bai <baijiaju1990@163.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:5294 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753608AbbHRVJa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 17:09:30 -0400
In-Reply-To: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jia-Ju Bai <baijiaju1990@163.com>

When e1000e_setup_rx_resources is failed in e1000_open,
e1000e_free_tx_resources in "err_setup_rx" segment is executed.
"writel(0, tx_ring->head)" statement in e1000_clean_tx_ring
in e1000e_free_tx_resources will cause a null poonter dereference(crash),
because "tx_ring->head" is only assigned in e1000_configure_tx
in e1000_configure, but it is after e1000e_setup_rx_resources.

This patch moves head/tail register writing to e1000_configure_tx/rx,
which can fix this problem. It is inspired by igb_configure_tx_ring
in the igb driver.

Specially, thank Alexander Duyck for his valuable suggestion.

Signed-off-by: Jia-Ju Bai <baijiaju1990@163.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 546b5da..faf4b3f 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -1737,12 +1737,6 @@ static void e1000_clean_rx_ring(struct e1000_ring *rx_ring)
 	rx_ring->next_to_clean = 0;
 	rx_ring->next_to_use = 0;
 	adapter->flags2 &= ~FLAG2_IS_DISCARDING;
-
-	writel(0, rx_ring->head);
-	if (adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
-		e1000e_update_rdt_wa(rx_ring, 0);
-	else
-		writel(0, rx_ring->tail);
 }
 
 static void e1000e_downshift_workaround(struct work_struct *work)
@@ -2447,12 +2441,6 @@ static void e1000_clean_tx_ring(struct e1000_ring *tx_ring)
 
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
-
-	writel(0, tx_ring->head);
-	if (adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
-		e1000e_update_tdt_wa(tx_ring, 0);
-	else
-		writel(0, tx_ring->tail);
 }
 
 /**
@@ -2954,6 +2942,12 @@ static void e1000_configure_tx(struct e1000_adapter *adapter)
 	tx_ring->head = adapter->hw.hw_addr + E1000_TDH(0);
 	tx_ring->tail = adapter->hw.hw_addr + E1000_TDT(0);
 
+	writel(0, tx_ring->head);
+	if (adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
+		e1000e_update_tdt_wa(tx_ring, 0);
+	else
+		writel(0, tx_ring->tail);
+
 	/* Set the Tx Interrupt Delay register */
 	ew32(TIDV, adapter->tx_int_delay);
 	/* Tx irq moderation */
@@ -3275,6 +3269,12 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 	rx_ring->head = adapter->hw.hw_addr + E1000_RDH(0);
 	rx_ring->tail = adapter->hw.hw_addr + E1000_RDT(0);
 
+	writel(0, rx_ring->head);
+	if (adapter->flags2 & FLAG2_PCIM2PCI_ARBITER_WA)
+		e1000e_update_rdt_wa(rx_ring, 0);
+	else
+		writel(0, rx_ring->tail);
+
 	/* Enable Receive Checksum Offload for TCP and UDP */
 	rxcsum = er32(RXCSUM);
 	if (adapter->netdev->features & NETIF_F_RXCSUM)
-- 
2.4.3
