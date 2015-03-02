From: Florian Westphal <fw@strlen.de>
Subject: [PATCH RFC 04/14] drivers: wireless: rt2x00: move skb_dma to queue entry
Date: Mon,  2 Mar 2015 18:40:18 +0100
Message-ID: <1425318028-26531-5-git-send-email-fw@strlen.de>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>, linux-wireless@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54108 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753962AbbCBRkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:40:43 -0500
In-Reply-To: <1425318028-26531-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

... to shrink size needed for the skb frame desc.

Note that this is just the lowest hanging fruit I found, if you find
better/other means to shrink the space needed in skb->cb
(or to shrink it even further) -- great.

Cc: linux-wireless@vger.kernel.org
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/net/wireless/rt2x00/rt2400pci.c   |  5 ++---
 drivers/net/wireless/rt2x00/rt2500pci.c   |  5 ++---
 drivers/net/wireless/rt2x00/rt2800mmio.c  |  7 +++----
 drivers/net/wireless/rt2x00/rt2x00queue.c | 10 +++++-----
 drivers/net/wireless/rt2x00/rt2x00queue.h | 17 ++++++++---------
 drivers/net/wireless/rt2x00/rt61pci.c     |  5 ++---
 6 files changed, 22 insertions(+), 27 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2400pci.c b/drivers/net/wireless/rt2x00/rt2400pci.c
index bdf5590..5c7927c 100644
--- a/drivers/net/wireless/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/rt2x00/rt2400pci.c
@@ -739,7 +739,6 @@ static bool rt2400pci_get_entry_state(struct queue_entry *entry)
 static void rt2400pci_clear_entry(struct queue_entry *entry)
 {
 	struct queue_entry_priv_mmio *entry_priv = entry->priv_data;
-	struct skb_frame_desc *skbdesc = get_skb_frame_desc(entry->skb);
 	u32 word;
 
 	if (entry->queue->qid == QID_RX) {
@@ -748,7 +747,7 @@ static void rt2400pci_clear_entry(struct queue_entry *entry)
 		rt2x00_desc_write(entry_priv->desc, 2, word);
 
 		rt2x00_desc_read(entry_priv->desc, 1, &word);
-		rt2x00_set_field32(&word, RXD_W1_BUFFER_ADDRESS, skbdesc->skb_dma);
+		rt2x00_set_field32(&word, RXD_W1_BUFFER_ADDRESS, entry->skb_dma);
 		rt2x00_desc_write(entry_priv->desc, 1, word);
 
 		rt2x00_desc_read(entry_priv->desc, 0, &word);
@@ -1111,7 +1110,7 @@ static void rt2400pci_write_tx_desc(struct queue_entry *entry,
 	 * Start writing the descriptor words.
 	 */
 	rt2x00_desc_read(txd, 1, &word);
-	rt2x00_set_field32(&word, TXD_W1_BUFFER_ADDRESS, skbdesc->skb_dma);
+	rt2x00_set_field32(&word, TXD_W1_BUFFER_ADDRESS, entry->skb_dma);
 	rt2x00_desc_write(txd, 1, word);
 
 	rt2x00_desc_read(txd, 2, &word);
diff --git a/drivers/net/wireless/rt2x00/rt2500pci.c b/drivers/net/wireless/rt2x00/rt2500pci.c
index 79f4fe6..907d7c2 100644
--- a/drivers/net/wireless/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/rt2x00/rt2500pci.c
@@ -828,12 +828,11 @@ static bool rt2500pci_get_entry_state(struct queue_entry *entry)
 static void rt2500pci_clear_entry(struct queue_entry *entry)
 {
 	struct queue_entry_priv_mmio *entry_priv = entry->priv_data;
-	struct skb_frame_desc *skbdesc = get_skb_frame_desc(entry->skb);
 	u32 word;
 
 	if (entry->queue->qid == QID_RX) {
 		rt2x00_desc_read(entry_priv->desc, 1, &word);
-		rt2x00_set_field32(&word, RXD_W1_BUFFER_ADDRESS, skbdesc->skb_dma);
+		rt2x00_set_field32(&word, RXD_W1_BUFFER_ADDRESS, entry->skb_dma);
 		rt2x00_desc_write(entry_priv->desc, 1, word);
 
 		rt2x00_desc_read(entry_priv->desc, 0, &word);
@@ -1264,7 +1263,7 @@ static void rt2500pci_write_tx_desc(struct queue_entry *entry,
 	 * Start writing the descriptor words.
 	 */
 	rt2x00_desc_read(txd, 1, &word);
-	rt2x00_set_field32(&word, TXD_W1_BUFFER_ADDRESS, skbdesc->skb_dma);
+	rt2x00_set_field32(&word, TXD_W1_BUFFER_ADDRESS, entry->skb_dma);
 	rt2x00_desc_write(txd, 1, word);
 
 	rt2x00_desc_read(txd, 2, &word);
diff --git a/drivers/net/wireless/rt2x00/rt2800mmio.c b/drivers/net/wireless/rt2x00/rt2800mmio.c
index de4790b..45772a1 100644
--- a/drivers/net/wireless/rt2x00/rt2800mmio.c
+++ b/drivers/net/wireless/rt2x00/rt2800mmio.c
@@ -66,7 +66,7 @@ void rt2800mmio_write_tx_desc(struct queue_entry *entry,
 	 * Initialize TX descriptor
 	 */
 	word = 0;
-	rt2x00_set_field32(&word, TXD_W0_SD_PTR0, skbdesc->skb_dma);
+	rt2x00_set_field32(&word, TXD_W0_SD_PTR0, entry->skb_dma);
 	rt2x00_desc_write(txd, 0, word);
 
 	word = 0;
@@ -82,7 +82,7 @@ void rt2800mmio_write_tx_desc(struct queue_entry *entry,
 
 	word = 0;
 	rt2x00_set_field32(&word, TXD_W2_SD_PTR1,
-			   skbdesc->skb_dma + txwi_size);
+			   entry->skb_dma + txwi_size);
 	rt2x00_desc_write(txd, 2, word);
 
 	word = 0;
@@ -710,13 +710,12 @@ EXPORT_SYMBOL_GPL(rt2800mmio_get_entry_state);
 void rt2800mmio_clear_entry(struct queue_entry *entry)
 {
 	struct queue_entry_priv_mmio *entry_priv = entry->priv_data;
-	struct skb_frame_desc *skbdesc = get_skb_frame_desc(entry->skb);
 	struct rt2x00_dev *rt2x00dev = entry->queue->rt2x00dev;
 	u32 word;
 
 	if (entry->queue->qid == QID_RX) {
 		rt2x00_desc_read(entry_priv->desc, 0, &word);
-		rt2x00_set_field32(&word, RXD_W0_SDP0, skbdesc->skb_dma);
+		rt2x00_set_field32(&word, RXD_W0_SDP0, entry->skb_dma);
 		rt2x00_desc_write(entry_priv->desc, 0, word);
 
 		rt2x00_desc_read(entry_priv->desc, 1, &word);
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wireless/rt2x00/rt2x00queue.c
index 68b620b..6c79266 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -95,7 +95,7 @@ struct sk_buff *rt2x00queue_alloc_rxskb(struct queue_entry *entry, gfp_t gfp)
 			return NULL;
 		}
 
-		skbdesc->skb_dma = skb_dma;
+		entry->skb_dma = skb_dma;
 		skbdesc->flags |= SKBDESC_DMA_MAPPED_RX;
 	}
 
@@ -107,10 +107,10 @@ int rt2x00queue_map_txskb(struct queue_entry *entry)
 	struct device *dev = entry->queue->rt2x00dev->dev;
 	struct skb_frame_desc *skbdesc = get_skb_frame_desc(entry->skb);
 
-	skbdesc->skb_dma =
+	entry->skb_dma =
 	    dma_map_single(dev, entry->skb->data, entry->skb->len, DMA_TO_DEVICE);
 
-	if (unlikely(dma_mapping_error(dev, skbdesc->skb_dma)))
+	if (unlikely(dma_mapping_error(dev, entry->skb_dma)))
 		return -ENOMEM;
 
 	skbdesc->flags |= SKBDESC_DMA_MAPPED_TX;
@@ -124,11 +124,11 @@ void rt2x00queue_unmap_skb(struct queue_entry *entry)
 	struct skb_frame_desc *skbdesc = get_skb_frame_desc(entry->skb);
 
 	if (skbdesc->flags & SKBDESC_DMA_MAPPED_RX) {
-		dma_unmap_single(dev, skbdesc->skb_dma, entry->skb->len,
+		dma_unmap_single(dev, entry->skb_dma, entry->skb->len,
 				 DMA_FROM_DEVICE);
 		skbdesc->flags &= ~SKBDESC_DMA_MAPPED_RX;
 	} else if (skbdesc->flags & SKBDESC_DMA_MAPPED_TX) {
-		dma_unmap_single(dev, skbdesc->skb_dma, entry->skb->len,
+		dma_unmap_single(dev, entry->skb_dma, entry->skb->len,
 				 DMA_TO_DEVICE);
 		skbdesc->flags &= ~SKBDESC_DMA_MAPPED_TX;
 	}
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.h b/drivers/net/wireless/rt2x00/rt2x00queue.h
index 2233b91..e6f6a2e 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.h
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.h
@@ -101,23 +101,19 @@ enum skb_frame_desc_flags {
  *	Note that this pointer could point to something outside
  *	of the scope of the skb->data pointer.
  * @iv: IV/EIV data used during encryption/decryption.
- * @skb_dma: (PCI-only) the DMA address associated with the sk buffer.
  * @entry: The entry to which this sk buffer belongs.
  */
 struct skb_frame_desc {
-	u8 flags;
-
-	u8 desc_len;
-	u8 tx_rate_idx;
-	u8 tx_rate_flags;
-
+	struct queue_entry *entry;
 	void *desc;
 
 	__le32 iv[2];
 
-	dma_addr_t skb_dma;
+	u8 flags;
 
-	struct queue_entry *entry;
+	u8 desc_len;
+	u8 tx_rate_idx;
+	u8 tx_rate_flags;
 };
 
 /**
@@ -372,6 +368,7 @@ enum queue_entry_flags {
  * @entry_idx: The entry index number.
  * @priv_data: Private data belonging to this queue entry. The pointer
  *	points to data specific to a particular driver and queue type.
+ * @skb_dma: (PCI-only) the DMA address associated with the sk buffer.
  * @status: Device specific status
  */
 struct queue_entry {
@@ -386,6 +383,8 @@ struct queue_entry {
 
 	u32 status;
 
+	dma_addr_t skb_dma;
+
 	void *priv_data;
 };
 
diff --git a/drivers/net/wireless/rt2x00/rt61pci.c b/drivers/net/wireless/rt2x00/rt61pci.c
index 8194550..a0c8de1 100644
--- a/drivers/net/wireless/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/rt2x00/rt61pci.c
@@ -1397,13 +1397,12 @@ static bool rt61pci_get_entry_state(struct queue_entry *entry)
 static void rt61pci_clear_entry(struct queue_entry *entry)
 {
 	struct queue_entry_priv_mmio *entry_priv = entry->priv_data;
-	struct skb_frame_desc *skbdesc = get_skb_frame_desc(entry->skb);
 	u32 word;
 
 	if (entry->queue->qid == QID_RX) {
 		rt2x00_desc_read(entry_priv->desc, 5, &word);
 		rt2x00_set_field32(&word, RXD_W5_BUFFER_PHYSICAL_ADDRESS,
-				   skbdesc->skb_dma);
+				   entry->skb_dma);
 		rt2x00_desc_write(entry_priv->desc, 5, word);
 
 		rt2x00_desc_read(entry_priv->desc, 0, &word);
@@ -1913,7 +1912,7 @@ static void rt61pci_write_tx_desc(struct queue_entry *entry,
 	if (entry->queue->qid != QID_BEACON) {
 		rt2x00_desc_read(txd, 6, &word);
 		rt2x00_set_field32(&word, TXD_W6_BUFFER_PHYSICAL_ADDRESS,
-				   skbdesc->skb_dma);
+				   entry->skb_dma);
 		rt2x00_desc_write(txd, 6, word);
 
 		rt2x00_desc_read(txd, 11, &word);
-- 
2.0.5
