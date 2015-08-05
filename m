From: Jia-Ju Bai <baijiaju1990@163.com>
Subject: [PATCH v2] e1000e: Modify tx/rx configurations to avoid null pointer dereferences in e1000_open
Date: Wed,  5 Aug 2015 18:16:10 +0800
Message-ID: <1438769770-8887-1-git-send-email-baijiaju1990@163.com>
Cc: alexander.duyck@gmail.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jia-Ju Bai <baijiaju1990@163.com>
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
---
 drivers/net/ethernet/intel/e1000e/netdev.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 89d788d..3aee51b 100644
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
1.7.9.5
