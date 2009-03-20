From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 5/5] igb: cleanup tx dma so map & unmap use matching
	calls
Date: Fri, 20 Mar 2009 03:17:43 -0700
Message-ID: <20090320101743.17663.8177.stgit@lost.foo-projects.org>
References: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta06.emeryville.ca.mail.comcast.net ([76.96.30.56]:46402 "EHLO
	QMTA06.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750945AbZCTKSD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 06:18:03 -0400
In-Reply-To: <20090320101631.17663.63853.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The igb driver was using map_single to map the skbs and then unmap_page to
unmap them.  This update changes that so instead uses skb_dma_map and
skb_dma_unmap.

In addition the next_to_watch member of the buffer_info struct was being
set uneccesarily.  I removed the spots where it was set without being needed.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   66 +++++++++++++++++++++++---------------------
 1 files changed, 35 insertions(+), 31 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index a977bd7..d6f7af8 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -2257,19 +2257,14 @@ static void igb_free_all_tx_resources(struct igb_adapter *adapter)
 static void igb_unmap_and_free_tx_resource(struct igb_adapter *adapter,
 					   struct igb_buffer *buffer_info)
 {
-	if (buffer_info->dma) {
-		pci_unmap_page(adapter->pdev,
-				buffer_info->dma,
-				buffer_info->length,
-				PCI_DMA_TODEVICE);
-		buffer_info->dma = 0;
-	}
+	buffer_info->dma = 0;
 	if (buffer_info->skb) {
+		skb_dma_unmap(&adapter->pdev->dev, buffer_info->skb,
+		              DMA_TO_DEVICE);
 		dev_kfree_skb_any(buffer_info->skb);
 		buffer_info->skb = NULL;
 	}
 	buffer_info->time_stamp = 0;
-	buffer_info->next_to_watch = 0;
 	/* buffer_info must be completely set up in the transmit path */
 }
 
@@ -3078,25 +3073,33 @@ static inline int igb_tx_map_adv(struct igb_adapter *adapter,
 	unsigned int len = skb_headlen(skb);
 	unsigned int count = 0, i;
 	unsigned int f;
+	dma_addr_t *map;
 
 	i = tx_ring->next_to_use;
 
+	if (skb_dma_map(&adapter->pdev->dev, skb, DMA_TO_DEVICE)) {
+		dev_err(&adapter->pdev->dev, "TX DMA map failed\n");
+		return 0;
+	}
+
+	map = skb_shinfo(skb)->dma_maps;
+
 	buffer_info = &tx_ring->buffer_info[i];
 	BUG_ON(len >= IGB_MAX_DATA_PER_TXD);
 	buffer_info->length = len;
 	/* set time_stamp *before* dma to help avoid a possible race */
 	buffer_info->time_stamp = jiffies;
 	buffer_info->next_to_watch = i;
-	buffer_info->dma = pci_map_single(adapter->pdev, skb->data, len,
-					  PCI_DMA_TODEVICE);
+	buffer_info->dma = map[count];
 	count++;
-	i++;
-	if (i == tx_ring->count)
-		i = 0;
 
 	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++) {
 		struct skb_frag_struct *frag;
 
+		i++;
+		if (i == tx_ring->count)
+			i = 0;
+
 		frag = &skb_shinfo(skb)->frags[f];
 		len = frag->size;
 
@@ -3105,19 +3108,10 @@ static inline int igb_tx_map_adv(struct igb_adapter *adapter,
 		buffer_info->length = len;
 		buffer_info->time_stamp = jiffies;
 		buffer_info->next_to_watch = i;
-		buffer_info->dma = pci_map_page(adapter->pdev,
-						frag->page,
-						frag->page_offset,
-						len,
-						PCI_DMA_TODEVICE);
-
+		buffer_info->dma = map[count];
 		count++;
-		i++;
-		if (i == tx_ring->count)
-			i = 0;
 	}
 
-	i = ((i == 0) ? tx_ring->count - 1 : i - 1);
 	tx_ring->buffer_info[i].skb = skb;
 	tx_ring->buffer_info[first].next_to_watch = i;
 
@@ -3230,6 +3224,7 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 	unsigned int first;
 	unsigned int tx_flags = 0;
 	u8 hdr_len = 0;
+	int count = 0;
 	int tso = 0;
 	union skb_shared_tx *shtx;
 
@@ -3291,14 +3286,23 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 	         (skb->ip_summed == CHECKSUM_PARTIAL))
 		tx_flags |= IGB_TX_FLAGS_CSUM;
 
-	igb_tx_queue_adv(adapter, tx_ring, tx_flags,
-			 igb_tx_map_adv(adapter, tx_ring, skb, first),
-			 skb->len, hdr_len);
-
-	netdev->trans_start = jiffies;
-
-	/* Make sure there is space in the ring for the next send. */
-	igb_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 4);
+	/*
+	 * count reflects descriptors mapped, if 0 then mapping error
+	 * has occured and we need to rewind the descriptor queue
+	 */
+	count = igb_tx_map_adv(adapter, tx_ring, skb, first);
+
+	if (count) {
+		igb_tx_queue_adv(adapter, tx_ring, tx_flags, count,
+			         skb->len, hdr_len);
+		netdev->trans_start = jiffies;
+		/* Make sure there is space in the ring for the next send. */
+		igb_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 4);
+	} else {
+		dev_kfree_skb_any(skb);
+		tx_ring->buffer_info[first].time_stamp = 0;
+		tx_ring->next_to_use = first;
+	}
 
 	return NETDEV_TX_OK;
 }

