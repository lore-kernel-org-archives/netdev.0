From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 07/12] ixgbe: Focus config of head, tail ntc, and ntu all into a single function
Date: Tue, 10 Dec 2013 02:22:36 -0800
Message-ID: <1386670961-20392-8-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1386670961-20392-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Don Skidmore <donald.c.skidmore@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:30241 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522Ab3LJKXP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Dec 2013 05:23:15 -0500
In-Reply-To: <1386670961-20392-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

This patch makes it so that head, tail, next to clean, and next to use are
all reset in a single function for the Tx or Rx path. Previously the code
for this was spread out over several areas which could make it difficult to
track what the values for these were.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      |  4 +-
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 55 ++++++++---------------
 2 files changed, 19 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 8971e2d..eaaa3ec 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -86,9 +86,7 @@ struct ixgbevf_ring {
 	u64 bp_misses;
 	u64 bp_cleaned;
 #endif
-
-	u16 head;
-	u16 tail;
+	u8 __iomem *tail;
 
 	u16 reg_idx; /* holds the special value that gets the hardware register
 		      * offset associated with this ring, which is different
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 92ef4cb..84b55fe 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -98,10 +98,11 @@ MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 static void ixgbevf_set_itr(struct ixgbevf_q_vector *q_vector);
 static void ixgbevf_free_all_rx_resources(struct ixgbevf_adapter *adapter);
 
-static inline void ixgbevf_release_rx_desc(struct ixgbe_hw *hw,
-					   struct ixgbevf_ring *rx_ring,
+static inline void ixgbevf_release_rx_desc(struct ixgbevf_ring *rx_ring,
 					   u32 val)
 {
+	rx_ring->next_to_use = val;
+
 	/*
 	 * Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
@@ -109,7 +110,7 @@ static inline void ixgbevf_release_rx_desc(struct ixgbe_hw *hw,
 	 * such as IA-64).
 	 */
 	wmb();
-	IXGBE_WRITE_REG(hw, IXGBE_VFRDT(rx_ring->reg_idx), val);
+	writel(val, rx_ring->tail);
 }
 
 /**
@@ -406,10 +407,8 @@ static void ixgbevf_alloc_rx_buffers(struct ixgbevf_adapter *adapter,
 	}
 
 no_buffers:
-	if (rx_ring->next_to_use != i) {
-		rx_ring->next_to_use = i;
-		ixgbevf_release_rx_desc(&adapter->hw, rx_ring, i);
-	}
+	if (rx_ring->next_to_use != i)
+		ixgbevf_release_rx_desc(rx_ring, i);
 }
 
 static inline void ixgbevf_irq_enable_queues(struct ixgbevf_adapter *adapter,
@@ -1110,8 +1109,9 @@ static void ixgbevf_configure_tx(struct ixgbevf_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_VFTDLEN(j), tdlen);
 		IXGBE_WRITE_REG(hw, IXGBE_VFTDH(j), 0);
 		IXGBE_WRITE_REG(hw, IXGBE_VFTDT(j), 0);
-		adapter->tx_ring[i].head = IXGBE_VFTDH(j);
-		adapter->tx_ring[i].tail = IXGBE_VFTDT(j);
+		ring->tail = hw->hw_addr + IXGBE_VFTDT(j);
+		ring->next_to_clean = 0;
+		ring->next_to_use = 0;
 		/* Disable Tx Head Writeback RO bit, since this hoses
 		 * bookkeeping if things aren't delivered in order.
 		 */
@@ -1208,20 +1208,22 @@ static void ixgbevf_configure_rx(struct ixgbevf_adapter *adapter)
 	/* set_rx_buffer_len must be called before ring initialization */
 	ixgbevf_set_rx_buffer_len(adapter);
 
-	rdlen = adapter->rx_ring[0].count * sizeof(union ixgbe_adv_rx_desc);
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
 	 * the Base and Length of the Rx Descriptor Ring */
 	for (i = 0; i < adapter->num_rx_queues; i++) {
-		rdba = adapter->rx_ring[i].dma;
-		j = adapter->rx_ring[i].reg_idx;
+		struct ixgbevf_ring *ring = &adapter->rx_ring[i];
+		rdba = ring->dma;
+		j = ring->reg_idx;
+		rdlen = ring->count * sizeof(union ixgbe_adv_rx_desc);
 		IXGBE_WRITE_REG(hw, IXGBE_VFRDBAL(j),
 				(rdba & DMA_BIT_MASK(32)));
 		IXGBE_WRITE_REG(hw, IXGBE_VFRDBAH(j), (rdba >> 32));
 		IXGBE_WRITE_REG(hw, IXGBE_VFRDLEN(j), rdlen);
 		IXGBE_WRITE_REG(hw, IXGBE_VFRDH(j), 0);
 		IXGBE_WRITE_REG(hw, IXGBE_VFRDT(j), 0);
-		adapter->rx_ring[i].head = IXGBE_VFRDH(j);
-		adapter->rx_ring[i].tail = IXGBE_VFRDT(j);
+		ring->tail = hw->hw_addr + IXGBE_VFRDT(j);
+		ring->next_to_clean = 0;
+		ring->next_to_use = 0;
 
 		ixgbevf_configure_srrctl(adapter, j);
 	}
@@ -1402,7 +1404,7 @@ static void ixgbevf_rx_desc_queue_enable(struct ixgbevf_adapter *adapter,
 		hw_dbg(hw, "RXDCTL.ENABLE queue %d not set while polling\n",
 		       rxr);
 
-	ixgbevf_release_rx_desc(&adapter->hw, &adapter->rx_ring[rxr],
+	ixgbevf_release_rx_desc(&adapter->rx_ring[rxr],
 				(adapter->rx_ring[rxr].count - 1));
 }
 
@@ -1680,14 +1682,6 @@ static void ixgbevf_clean_rx_ring(struct ixgbevf_adapter *adapter,
 
 	/* Zero out the descriptor ring */
 	memset(rx_ring->desc, 0, rx_ring->size);
-
-	rx_ring->next_to_clean = 0;
-	rx_ring->next_to_use = 0;
-
-	if (rx_ring->head)
-		writel(0, adapter->hw.hw_addr + rx_ring->head);
-	if (rx_ring->tail)
-		writel(0, adapter->hw.hw_addr + rx_ring->tail);
 }
 
 /**
@@ -1715,14 +1709,6 @@ static void ixgbevf_clean_tx_ring(struct ixgbevf_adapter *adapter,
 	memset(tx_ring->tx_buffer_info, 0, size);
 
 	memset(tx_ring->desc, 0, tx_ring->size);
-
-	tx_ring->next_to_use = 0;
-	tx_ring->next_to_clean = 0;
-
-	if (tx_ring->head)
-		writel(0, adapter->hw.hw_addr + tx_ring->head);
-	if (tx_ring->tail)
-		writel(0, adapter->hw.hw_addr + tx_ring->tail);
 }
 
 /**
@@ -2473,8 +2459,6 @@ int ixgbevf_setup_tx_resources(struct ixgbevf_adapter *adapter,
 	if (!tx_ring->desc)
 		goto err;
 
-	tx_ring->next_to_use = 0;
-	tx_ring->next_to_clean = 0;
 	return 0;
 
 err:
@@ -2542,9 +2526,6 @@ int ixgbevf_setup_rx_resources(struct ixgbevf_adapter *adapter,
 		goto alloc_failed;
 	}
 
-	rx_ring->next_to_clean = 0;
-	rx_ring->next_to_use = 0;
-
 	return 0;
 alloc_failed:
 	return -ENOMEM;
@@ -3181,7 +3162,7 @@ static int ixgbevf_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			 ixgbevf_tx_map(tx_ring, skb, tx_flags),
 			 first, skb->len, hdr_len);
 
-	writel(tx_ring->next_to_use, adapter->hw.hw_addr + tx_ring->tail);
+	writel(tx_ring->next_to_use, tx_ring->tail);
 
 	ixgbevf_maybe_stop_tx(tx_ring, DESC_NEEDED);
 
-- 
1.8.3.1
