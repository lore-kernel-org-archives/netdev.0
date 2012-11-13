From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 10/11] igb: Improve performance and reduce size of igb_tx_map
Date: Tue, 13 Nov 2012 06:03:24 -0800
Message-ID: <1352815405-751-11-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55577 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754864Ab2KMOED (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 09:04:03 -0500
In-Reply-To: <1352815405-751-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to both improve the performance and reduce the size of
igb_tx_map.  To do this I have expanded the work done in the main loop by
pushing first into tx_buffer.  This allows us to pull in the dma_mapping_error
check, the tx_buffer value assignment, and the initial DMA value assignment to
the Tx descriptor.  The net result is that the function reduces in size by a
little over a 100 bytes and is about 1% or 2% faster.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 47 +++++++++++++++----------------
 1 file changed, 22 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 0a0bd81..7044aaa 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -4188,29 +4188,34 @@ static void igb_tx_map(struct igb_ring *tx_ring,
 	struct sk_buff *skb = first->skb;
 	struct igb_tx_buffer *tx_buffer;
 	union e1000_adv_tx_desc *tx_desc;
+	struct skb_frag_struct *frag;
 	dma_addr_t dma;
-	struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[0];
-	unsigned int data_len = skb->data_len;
-	unsigned int size = skb_headlen(skb);
-	unsigned int paylen = skb->len - hdr_len;
+	unsigned int data_len, size;
 	u32 tx_flags = first->tx_flags;
 	u32 cmd_type = igb_tx_cmd_type(skb, tx_flags);
 	u16 i = tx_ring->next_to_use;
 
 	tx_desc = IGB_TX_DESC(tx_ring, i);
 
-	igb_tx_olinfo_status(tx_ring, tx_desc, tx_flags, paylen);
+	igb_tx_olinfo_status(tx_ring, tx_desc, tx_flags, skb->len - hdr_len);
+
+	size = skb_headlen(skb);
+	data_len = skb->data_len;
 
 	dma = dma_map_single(tx_ring->dev, skb->data, size, DMA_TO_DEVICE);
-	if (dma_mapping_error(tx_ring->dev, dma))
-		goto dma_error;
 
-	/* record length, and DMA address */
-	dma_unmap_len_set(first, len, size);
-	dma_unmap_addr_set(first, dma, dma);
-	tx_desc->read.buffer_addr = cpu_to_le64(dma);
+	tx_buffer = first;
+
+	for (frag = &skb_shinfo(skb)->frags[0];; frag++) {
+		if (dma_mapping_error(tx_ring->dev, dma))
+			goto dma_error;
+
+		/* record length, and DMA address */
+		dma_unmap_len_set(tx_buffer, len, size);
+		dma_unmap_addr_set(tx_buffer, dma, dma);
+
+		tx_desc->read.buffer_addr = cpu_to_le64(dma);
 
-	for (;;) {
 		while (unlikely(size > IGB_MAX_DATA_PER_TXD)) {
 			tx_desc->read.cmd_type_len =
 				cpu_to_le32(cmd_type ^ IGB_MAX_DATA_PER_TXD);
@@ -4221,11 +4226,11 @@ static void igb_tx_map(struct igb_ring *tx_ring,
 				tx_desc = IGB_TX_DESC(tx_ring, 0);
 				i = 0;
 			}
+			tx_desc->read.olinfo_status = 0;
 
 			dma += IGB_MAX_DATA_PER_TXD;
 			size -= IGB_MAX_DATA_PER_TXD;
 
-			tx_desc->read.olinfo_status = 0;
 			tx_desc->read.buffer_addr = cpu_to_le64(dma);
 		}
 
@@ -4240,31 +4245,23 @@ static void igb_tx_map(struct igb_ring *tx_ring,
 			tx_desc = IGB_TX_DESC(tx_ring, 0);
 			i = 0;
 		}
+		tx_desc->read.olinfo_status = 0;
 
 		size = skb_frag_size(frag);
 		data_len -= size;
 
 		dma = skb_frag_dma_map(tx_ring->dev, frag, 0,
-				   size, DMA_TO_DEVICE);
-		if (dma_mapping_error(tx_ring->dev, dma))
-			goto dma_error;
+				       size, DMA_TO_DEVICE);
 
 		tx_buffer = &tx_ring->tx_buffer_info[i];
-		dma_unmap_len_set(tx_buffer, len, size);
-		dma_unmap_addr_set(tx_buffer, dma, dma);
-
-		tx_desc->read.olinfo_status = 0;
-		tx_desc->read.buffer_addr = cpu_to_le64(dma);
-
-		frag++;
 	}
 
-	netdev_tx_sent_queue(txring_txq(tx_ring), first->bytecount);
-
 	/* write last descriptor with RS and EOP bits */
 	cmd_type |= size | IGB_TXD_DCMD;
 	tx_desc->read.cmd_type_len = cpu_to_le32(cmd_type);
 
+	netdev_tx_sent_queue(txring_txq(tx_ring), first->bytecount);
+
 	/* set the timestamp */
 	first->time_stamp = jiffies;
 
-- 
1.7.11.7
