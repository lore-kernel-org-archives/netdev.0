From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/10] ixgbe: split Tx/Rx ring clearing for ethtool loopback test
Date: Mon,  9 Oct 2017 11:39:55 -0700
Message-ID: <20171009184000.80053-6-jeffrey.t.kirsher@intel.com>
References: <20171009184000.80053-1-jeffrey.t.kirsher@intel.com>
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:54649 "EHLO mga02.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755219AbdJISkX (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 14:40:23 -0400
In-Reply-To: <20171009184000.80053-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Commit: fed21bcee7a5
("ixgbe: Don't bother clearing buffer memory for descriptor rings)

exposed some issues with the logic in the current implementation of
ixgbe_clean_test_rings() that are being addressed in this patch:

- Split the clearing of the Tx and Rx rings in separate loops. Previously
both Tx and Rx rings were cleared in a rx_desc->wb.upper.length based
loop which could lead to issues if for w/e reason packets were received
outside of the frames transmitted for the loopback test.

- Add check for IXGBE_TXD_STAT_DD to avoid clearing the rings if the
transmits have not comlpeted by the time we enter ixgbe_clean_test_rings()

- Exit early on ixgbe_check_lbtest_frame() failure.

This change fixes a crash during ethtool diagnostic (ethtool -t).

Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 53 +++++++++++++++---------
 1 file changed, 34 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 72c565712a5f..6d89f28cae06 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -1916,8 +1916,6 @@ static u16 ixgbe_clean_test_rings(struct ixgbe_ring *rx_ring,
 				  unsigned int size)
 {
 	union ixgbe_adv_rx_desc *rx_desc;
-	struct ixgbe_rx_buffer *rx_buffer;
-	struct ixgbe_tx_buffer *tx_buffer;
 	u16 rx_ntc, tx_ntc, count = 0;
 
 	/* initialize next to clean and descriptor values */
@@ -1925,7 +1923,38 @@ static u16 ixgbe_clean_test_rings(struct ixgbe_ring *rx_ring,
 	tx_ntc = tx_ring->next_to_clean;
 	rx_desc = IXGBE_RX_DESC(rx_ring, rx_ntc);
 
+	while (tx_ntc != tx_ring->next_to_use) {
+		union ixgbe_adv_tx_desc *tx_desc;
+		struct ixgbe_tx_buffer *tx_buffer;
+
+		tx_desc = IXGBE_TX_DESC(tx_ring, tx_ntc);
+
+		/* if DD is not set transmit has not completed */
+		if (!(tx_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)))
+			return count;
+
+		/* unmap buffer on Tx side */
+		tx_buffer = &tx_ring->tx_buffer_info[tx_ntc];
+
+		/* Free all the Tx ring sk_buffs */
+		dev_kfree_skb_any(tx_buffer->skb);
+
+		/* unmap skb header data */
+		dma_unmap_single(tx_ring->dev,
+				 dma_unmap_addr(tx_buffer, dma),
+				 dma_unmap_len(tx_buffer, len),
+				 DMA_TO_DEVICE);
+		dma_unmap_len_set(tx_buffer, len, 0);
+
+		/* increment Tx next to clean counter */
+		tx_ntc++;
+		if (tx_ntc == tx_ring->count)
+			tx_ntc = 0;
+	}
+
 	while (rx_desc->wb.upper.length) {
+		struct ixgbe_rx_buffer *rx_buffer;
+
 		/* check Rx buffer */
 		rx_buffer = &rx_ring->rx_buffer_info[rx_ntc];
 
@@ -1938,6 +1967,8 @@ static u16 ixgbe_clean_test_rings(struct ixgbe_ring *rx_ring,
 		/* verify contents of skb */
 		if (ixgbe_check_lbtest_frame(rx_buffer, size))
 			count++;
+		else
+			break;
 
 		/* sync Rx buffer for device write */
 		dma_sync_single_for_device(rx_ring->dev,
@@ -1945,26 +1976,10 @@ static u16 ixgbe_clean_test_rings(struct ixgbe_ring *rx_ring,
 					   ixgbe_rx_bufsz(rx_ring),
 					   DMA_FROM_DEVICE);
 
-		/* unmap buffer on Tx side */
-		tx_buffer = &tx_ring->tx_buffer_info[tx_ntc];
-
-		/* Free all the Tx ring sk_buffs */
-		dev_kfree_skb_any(tx_buffer->skb);
-
-		/* unmap skb header data */
-		dma_unmap_single(tx_ring->dev,
-				 dma_unmap_addr(tx_buffer, dma),
-				 dma_unmap_len(tx_buffer, len),
-				 DMA_TO_DEVICE);
-		dma_unmap_len_set(tx_buffer, len, 0);
-
-		/* increment Rx/Tx next to clean counters */
+		/* increment Rx next to clean counter */
 		rx_ntc++;
 		if (rx_ntc == rx_ring->count)
 			rx_ntc = 0;
-		tx_ntc++;
-		if (tx_ntc == tx_ring->count)
-			tx_ntc = 0;
 
 		/* fetch next descriptor */
 		rx_desc = IXGBE_RX_DESC(rx_ring, rx_ntc);
-- 
2.14.2
