From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 03/13] i40e: Cleanup Tx buffer info layout
Date: Wed,  9 Oct 2013 23:41:01 -0700
Message-ID: <1381387271-29605-4-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1381387271-29605-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:46635 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752717Ab3JJGlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Oct 2013 02:41:18 -0400
In-Reply-To: <1381387271-29605-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

- drop the mapped_as_page u8 from the Tx buffer info as it was unused
- use the DMA unmap accessors for Tx DMA
- replace checks of DMA with checks of the unmap length to verify if an
  unmap is needed
- update the Tx buffer layout to make it consistent with igb, ixgbe

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 16 ++++++++--------
 drivers/net/ethernet/intel/i40e/i40e_txrx.h | 13 ++++++-------
 2 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 32c9aeb..3bc3efa 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -195,20 +195,20 @@ static void i40e_fd_handle_status(struct i40e_ring *rx_ring, u32 qw, u8 prog_id)
 static inline void i40e_unmap_tx_resource(struct i40e_ring *ring,
 					  struct i40e_tx_buffer *tx_buffer)
 {
-	if (tx_buffer->dma) {
+	if (dma_unmap_len(tx_buffer, len)) {
 		if (tx_buffer->tx_flags & I40E_TX_FLAGS_MAPPED_AS_PAGE)
 			dma_unmap_page(ring->dev,
-				       tx_buffer->dma,
-				       tx_buffer->length,
+				       dma_unmap_addr(tx_buffer, dma),
+				       dma_unmap_len(tx_buffer, len),
 				       DMA_TO_DEVICE);
 		else
 			dma_unmap_single(ring->dev,
-					 tx_buffer->dma,
-					 tx_buffer->length,
+					 dma_unmap_addr(tx_buffer, dma),
+					 dma_unmap_len(tx_buffer, len),
 					 DMA_TO_DEVICE);
 	}
-	tx_buffer->dma = 0;
 	tx_buffer->time_stamp = 0;
+	dma_unmap_len_set(tx_buffer, len, 0);
 }
 
 /**
@@ -1554,9 +1554,9 @@ static void i40e_tx_map(struct i40e_ring *tx_ring, struct sk_buff *skb,
 		}
 
 		tx_bi = &tx_ring->tx_bi[i];
-		tx_bi->length = buf_offset + size;
+		dma_unmap_len_set(tx_bi, len, buf_offset + size);
+		dma_unmap_addr_set(tx_bi, dma, dma);
 		tx_bi->tx_flags = tx_flags;
-		tx_bi->dma = dma;
 
 		tx_desc->buffer_addr = cpu_to_le64(dma + buf_offset);
 		tx_desc->cmd_type_offset_bsz = build_ctob(td_cmd, td_offset,
diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.h b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
index 2fbacaf..711f549 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.h
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.h
@@ -110,15 +110,14 @@
 #define I40E_TX_FLAGS_VLAN_SHIFT	16
 
 struct i40e_tx_buffer {
-	struct sk_buff *skb;
-	dma_addr_t dma;
-	unsigned long time_stamp;
-	u16 length;
-	u32 tx_flags;
 	struct i40e_tx_desc *next_to_watch;
+	unsigned long time_stamp;
+	struct sk_buff *skb;
 	unsigned int bytecount;
-	u16 gso_segs;
-	u8 mapped_as_page;
+	unsigned short gso_segs;
+	DEFINE_DMA_UNMAP_ADDR(dma);
+	DEFINE_DMA_UNMAP_LEN(len);
+	u32 tx_flags;
 };
 
 struct i40e_rx_buffer {
-- 
1.8.3.1
