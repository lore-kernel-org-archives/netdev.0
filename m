From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/10] ixgbe: Improve performance and reduce size of ixgbe_tx_map
Date: Sat, 19 Jan 2013 05:14:54 -0800
Message-ID: <1358601299-10404-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1358601299-10404-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:4331 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750940Ab3ASNPH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Jan 2013 08:15:07 -0500
In-Reply-To: <1358601299-10404-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to both improve the performance and reduce the size of
ixgbe_tx_map.  To do this I have expanded the work done in the main loop by
pushing first into tx_buffer.  This allows us to pull in the dma_mapping_error
check, the tx_buffer value assignment, and the initial DMA value assignment to
the Tx descriptor.  The net result is that the function reduces in size by a
little over a 100 bytes and is about 1% or 2% faster.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 42 ++++++++++++---------------
 1 file changed, 19 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index f7a314f..e7109de 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -6091,21 +6091,22 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 			 struct ixgbe_tx_buffer *first,
 			 const u8 hdr_len)
 {
-	dma_addr_t dma;
 	struct sk_buff *skb = first->skb;
 	struct ixgbe_tx_buffer *tx_buffer;
 	union ixgbe_adv_tx_desc *tx_desc;
-	struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[0];
-	unsigned int data_len = skb->data_len;
-	unsigned int size = skb_headlen(skb);
-	unsigned int paylen = skb->len - hdr_len;
+	struct skb_frag_struct *frag;
+	dma_addr_t dma;
+	unsigned int data_len, size;
 	u32 tx_flags = first->tx_flags;
 	u32 cmd_type = ixgbe_tx_cmd_type(skb, tx_flags);
 	u16 i = tx_ring->next_to_use;
 
 	tx_desc = IXGBE_TX_DESC(tx_ring, i);
 
-	ixgbe_tx_olinfo_status(tx_desc, tx_flags, paylen);
+	ixgbe_tx_olinfo_status(tx_desc, tx_flags, skb->len - hdr_len);
+
+	size = skb_headlen(skb);
+	data_len = skb->data_len;
 
 #ifdef IXGBE_FCOE
 	if (tx_flags & IXGBE_TX_FLAGS_FCOE) {
@@ -6119,16 +6120,19 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 
 #endif
 	dma = dma_map_single(tx_ring->dev, skb->data, size, DMA_TO_DEVICE);
-	if (dma_mapping_error(tx_ring->dev, dma))
-		goto dma_error;
 
-	/* record length, and DMA address */
-	dma_unmap_len_set(first, len, size);
-	dma_unmap_addr_set(first, dma, dma);
+	tx_buffer = first;
+
+	for (frag = &skb_shinfo(skb)->frags[0];; frag++) {
+		if (dma_mapping_error(tx_ring->dev, dma))
+			goto dma_error;
+
+		/* record length, and DMA address */
+		dma_unmap_len_set(tx_buffer, len, size);
+		dma_unmap_addr_set(tx_buffer, dma, dma);
 
-	tx_desc->read.buffer_addr = cpu_to_le64(dma);
+		tx_desc->read.buffer_addr = cpu_to_le64(dma);
 
-	for (;;) {
 		while (unlikely(size > IXGBE_MAX_DATA_PER_TXD)) {
 			tx_desc->read.cmd_type_len =
 				cpu_to_le32(cmd_type ^ IXGBE_MAX_DATA_PER_TXD);
@@ -6139,12 +6143,12 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 				tx_desc = IXGBE_TX_DESC(tx_ring, 0);
 				i = 0;
 			}
+			tx_desc->read.olinfo_status = 0;
 
 			dma += IXGBE_MAX_DATA_PER_TXD;
 			size -= IXGBE_MAX_DATA_PER_TXD;
 
 			tx_desc->read.buffer_addr = cpu_to_le64(dma);
-			tx_desc->read.olinfo_status = 0;
 		}
 
 		if (likely(!data_len))
@@ -6158,6 +6162,7 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 			tx_desc = IXGBE_TX_DESC(tx_ring, 0);
 			i = 0;
 		}
+		tx_desc->read.olinfo_status = 0;
 
 #ifdef IXGBE_FCOE
 		size = min_t(unsigned int, data_len, skb_frag_size(frag));
@@ -6168,17 +6173,8 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
 
 		dma = skb_frag_dma_map(tx_ring->dev, frag, 0, size,
 				       DMA_TO_DEVICE);
-		if (dma_mapping_error(tx_ring->dev, dma))
-			goto dma_error;
 
 		tx_buffer = &tx_ring->tx_buffer_info[i];
-		dma_unmap_len_set(tx_buffer, len, size);
-		dma_unmap_addr_set(tx_buffer, dma, dma);
-
-		tx_desc->read.buffer_addr = cpu_to_le64(dma);
-		tx_desc->read.olinfo_status = 0;
-
-		frag++;
 	}
 
 	/* write last descriptor with RS and EOP bits */
-- 
1.7.11.7
