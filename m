From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/13] igb: Combine all flag info fields into a single tx_flags structure
Date: Fri,  7 Oct 2011 00:18:45 -0700
Message-ID: <1317971926-23145-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34234 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759329Ab1JGHSy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Oct 2011 03:18:54 -0400
In-Reply-To: <1317971926-23145-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change is meant to combine all of the TX flags fields into one u32
flags field so that it can be stored into the tx_buffer_info structure.
This includes the time stamp flag as well as mapped_as_page flag info.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Tested-by:  Aaron Brown  <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb.h      |    9 +++++++++
 drivers/net/ethernet/intel/igb/igb_main.c |   24 ++++++++----------------
 2 files changed, 17 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 1608110..b71d186 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -130,6 +130,15 @@ struct vf_data_storage {
 
 #define IGB_MNG_VLAN_NONE -1
 
+#define IGB_TX_FLAGS_CSUM		0x00000001
+#define IGB_TX_FLAGS_VLAN		0x00000002
+#define IGB_TX_FLAGS_TSO		0x00000004
+#define IGB_TX_FLAGS_IPV4		0x00000008
+#define IGB_TX_FLAGS_TSTAMP		0x00000010
+#define IGB_TX_FLAGS_MAPPED_AS_PAGE	0x00000020
+#define IGB_TX_FLAGS_VLAN_MASK		0xffff0000
+#define IGB_TX_FLAGS_VLAN_SHIFT	16
+
 /* wrapper around a pointer to a socket buffer,
  * so a DMA handle can be stored along with the buffer */
 struct igb_tx_buffer {
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 3ebeb3e..dc93d64 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -3143,7 +3143,7 @@ void igb_unmap_and_free_tx_resource(struct igb_ring *tx_ring,
 				    struct igb_tx_buffer *buffer_info)
 {
 	if (buffer_info->dma) {
-		if (buffer_info->mapped_as_page)
+		if (buffer_info->tx_flags & IGB_TX_FLAGS_MAPPED_AS_PAGE)
 			dma_unmap_page(tx_ring->dev,
 					buffer_info->dma,
 					buffer_info->length,
@@ -3162,7 +3162,6 @@ void igb_unmap_and_free_tx_resource(struct igb_ring *tx_ring,
 	buffer_info->time_stamp = 0;
 	buffer_info->length = 0;
 	buffer_info->next_to_watch = NULL;
-	buffer_info->mapped_as_page = false;
 }
 
 /**
@@ -3955,14 +3954,6 @@ set_itr_now:
 	}
 }
 
-#define IGB_TX_FLAGS_CSUM		0x00000001
-#define IGB_TX_FLAGS_VLAN		0x00000002
-#define IGB_TX_FLAGS_TSO		0x00000004
-#define IGB_TX_FLAGS_IPV4		0x00000008
-#define IGB_TX_FLAGS_TSTAMP		0x00000010
-#define IGB_TX_FLAGS_VLAN_MASK		0xffff0000
-#define IGB_TX_FLAGS_VLAN_SHIFT		        16
-
 void igb_tx_ctxtdesc(struct igb_ring *tx_ring, u32 vlan_macip_lens,
 		     u32 type_tucmd, u32 mss_l4len_idx)
 {
@@ -4151,7 +4142,7 @@ static __le32 igb_tx_olinfo_status(u32 tx_flags, unsigned int paylen,
 #define IGB_MAX_DATA_PER_TXD	(1<<IGB_MAX_TXD_PWR)
 
 static inline int igb_tx_map(struct igb_ring *tx_ring, struct sk_buff *skb,
-			     struct igb_tx_buffer *first)
+			     struct igb_tx_buffer *first, u32 tx_flags)
 {
 	struct igb_tx_buffer *buffer_info;
 	struct device *dev = tx_ring->dev;
@@ -4165,11 +4156,14 @@ static inline int igb_tx_map(struct igb_ring *tx_ring, struct sk_buff *skb,
 	buffer_info = &tx_ring->tx_buffer_info[i];
 	BUG_ON(hlen >= IGB_MAX_DATA_PER_TXD);
 	buffer_info->length = hlen;
+	buffer_info->tx_flags = tx_flags;
 	buffer_info->dma = dma_map_single(dev, skb->data, hlen,
 					  DMA_TO_DEVICE);
 	if (dma_mapping_error(dev, buffer_info->dma))
 		goto dma_error;
 
+	tx_flags |= IGB_TX_FLAGS_MAPPED_AS_PAGE;
+
 	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++) {
 		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[f];
 		unsigned int len = frag->size;
@@ -4182,7 +4176,7 @@ static inline int igb_tx_map(struct igb_ring *tx_ring, struct sk_buff *skb,
 		buffer_info = &tx_ring->tx_buffer_info[i];
 		BUG_ON(len >= IGB_MAX_DATA_PER_TXD);
 		buffer_info->length = len;
-		buffer_info->mapped_as_page = true;
+		buffer_info->tx_flags = tx_flags;
 		buffer_info->dma = skb_frag_dma_map(dev, frag, 0, len,
 						DMA_TO_DEVICE);
 		if (dma_mapping_error(dev, buffer_info->dma))
@@ -4191,7 +4185,6 @@ static inline int igb_tx_map(struct igb_ring *tx_ring, struct sk_buff *skb,
 	}
 
 	buffer_info->skb = skb;
-	buffer_info->tx_flags = skb_shinfo(skb)->tx_flags;
 	/* multiply data chunks by size of headers */
 	buffer_info->bytecount = ((gso_segs - 1) * hlen) + skb->len;
 	buffer_info->gso_segs = gso_segs;
@@ -4211,7 +4204,6 @@ dma_error:
 	buffer_info->dma = 0;
 	buffer_info->time_stamp = 0;
 	buffer_info->length = 0;
-	buffer_info->mapped_as_page = false;
 
 	/* clear timestamp and dma mappings for remaining portion of packet */
 	while (count--) {
@@ -4347,7 +4339,7 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	 * count reflects descriptors mapped, if 0 or less then mapping error
 	 * has occurred and we need to rewind the descriptor queue
 	 */
-	count = igb_tx_map(tx_ring, skb, first);
+	count = igb_tx_map(tx_ring, skb, first, tx_flags);
 	if (!count) {
 		dev_kfree_skb_any(skb);
 		first->time_stamp = 0;
@@ -5567,7 +5559,7 @@ static void igb_tx_hwtstamp(struct igb_q_vector *q_vector,
 	u64 regval;
 
 	/* if skb does not support hw timestamp or TX stamp not valid exit */
-	if (likely(!(buffer_info->tx_flags & SKBTX_HW_TSTAMP)) ||
+	if (likely(!(buffer_info->tx_flags & IGB_TX_FLAGS_TSTAMP)) ||
 	    !(rd32(E1000_TSYNCTXCTL) & E1000_TSYNCTXCTL_VALID))
 		return;
 
-- 
1.7.6.4
