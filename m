From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] igb: reduce cache misses on tx cleanup
Date: Wed, 05 May 2010 00:58:07 -0700
Message-ID: <20100505075733.5474.37834.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Nicholas Nunley <nicholasx.d.nunley@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:44032 "EHLO
	qmta02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755446Ab0EEH6Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 May 2010 03:58:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nick Nunley <nicholasx.d.nunley@intel.com>

This patch reduces the number of skb cache misses in the
clean_tx_irq path, and results in an overall increase
in tx packet throughput.

Signed-off-by: Nicholas Nunley <nicholasx.d.nunley@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb.h      |    4 +++-
 drivers/net/igb/igb_main.c |   45 +++++++++++++++++++-------------------------
 2 files changed, 22 insertions(+), 27 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 735ede9..6e63d9a 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -141,8 +141,10 @@ struct igb_buffer {
 			unsigned long time_stamp;
 			u16 length;
 			u16 next_to_watch;
-			u16 mapped_as_page;
+			unsigned int bytecount;
 			u16 gso_segs;
+			union skb_shared_tx shtx;
+			u8 mapped_as_page;
 		};
 		/* RX */
 		struct {
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 438737d..589cf4a 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -3899,34 +3899,33 @@ static inline int igb_tx_map_adv(struct igb_ring *tx_ring, struct sk_buff *skb,
 {
 	struct igb_buffer *buffer_info;
 	struct device *dev = tx_ring->dev;
-	unsigned int len = skb_headlen(skb);
+	unsigned int hlen = skb_headlen(skb);
 	unsigned int count = 0, i;
 	unsigned int f;
+	u16 gso_segs = skb_shinfo(skb)->gso_segs ?: 1;
 
 	i = tx_ring->next_to_use;
 
 	buffer_info = &tx_ring->buffer_info[i];
-	BUG_ON(len >= IGB_MAX_DATA_PER_TXD);
-	buffer_info->length = len;
+	BUG_ON(hlen >= IGB_MAX_DATA_PER_TXD);
+	buffer_info->length = hlen;
 	/* set time_stamp *before* dma to help avoid a possible race */
 	buffer_info->time_stamp = jiffies;
 	buffer_info->next_to_watch = i;
-	buffer_info->dma = dma_map_single(dev, skb->data, len,
+	buffer_info->dma = dma_map_single(dev, skb->data, hlen,
 					  DMA_TO_DEVICE);
 	if (dma_mapping_error(dev, buffer_info->dma))
 		goto dma_error;
 
 	for (f = 0; f < skb_shinfo(skb)->nr_frags; f++) {
-		struct skb_frag_struct *frag;
+		struct skb_frag_struct *frag = &skb_shinfo(skb)->frags[f];
+		unsigned int len = frag->size;
 
 		count++;
 		i++;
 		if (i == tx_ring->count)
 			i = 0;
 
-		frag = &skb_shinfo(skb)->frags[f];
-		len = frag->size;
-
 		buffer_info = &tx_ring->buffer_info[i];
 		BUG_ON(len >= IGB_MAX_DATA_PER_TXD);
 		buffer_info->length = len;
@@ -3944,7 +3943,10 @@ static inline int igb_tx_map_adv(struct igb_ring *tx_ring, struct sk_buff *skb,
 	}
 
 	tx_ring->buffer_info[i].skb = skb;
-	tx_ring->buffer_info[i].gso_segs = skb_shinfo(skb)->gso_segs ?: 1;
+	tx_ring->buffer_info[i].shtx = skb_shinfo(skb)->tx_flags;
+	/* multiply data chunks by size of headers */
+	tx_ring->buffer_info[i].bytecount = ((gso_segs - 1) * hlen) + skb->len;
+	tx_ring->buffer_info[i].gso_segs = gso_segs;
 	tx_ring->buffer_info[first].next_to_watch = i;
 
 	return ++count;
@@ -5288,22 +5290,21 @@ static void igb_systim_to_hwtstamp(struct igb_adapter *adapter,
 /**
  * igb_tx_hwtstamp - utility function which checks for TX time stamp
  * @q_vector: pointer to q_vector containing needed info
- * @skb: packet that was just sent
+ * @buffer: pointer to igb_buffer structure
  *
  * If we were asked to do hardware stamping and such a time stamp is
  * available, then it must have been for this skb here because we only
  * allow only one such packet into the queue.
  */
-static void igb_tx_hwtstamp(struct igb_q_vector *q_vector, struct sk_buff *skb)
+static void igb_tx_hwtstamp(struct igb_q_vector *q_vector, struct igb_buffer *buffer_info)
 {
 	struct igb_adapter *adapter = q_vector->adapter;
-	union skb_shared_tx *shtx = skb_tx(skb);
 	struct e1000_hw *hw = &adapter->hw;
 	struct skb_shared_hwtstamps shhwtstamps;
 	u64 regval;
 
 	/* if skb does not support hw timestamp or TX stamp not valid exit */
-	if (likely(!shtx->hardware) ||
+	if (likely(!buffer_info->shtx.hardware) ||
 	    !(rd32(E1000_TSYNCTXCTL) & E1000_TSYNCTXCTL_VALID))
 		return;
 
@@ -5311,7 +5312,7 @@ static void igb_tx_hwtstamp(struct igb_q_vector *q_vector, struct sk_buff *skb)
 	regval |= (u64)rd32(E1000_TXSTMPH) << 32;
 
 	igb_systim_to_hwtstamp(adapter, &shhwtstamps, regval);
-	skb_tstamp_tx(skb, &shhwtstamps);
+	skb_tstamp_tx(buffer_info->skb, &shhwtstamps);
 }
 
 /**
@@ -5326,7 +5327,6 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 	struct net_device *netdev = tx_ring->netdev;
 	struct e1000_hw *hw = &adapter->hw;
 	struct igb_buffer *buffer_info;
-	struct sk_buff *skb;
 	union e1000_adv_tx_desc *tx_desc, *eop_desc;
 	unsigned int total_bytes = 0, total_packets = 0;
 	unsigned int i, eop, count = 0;
@@ -5342,19 +5342,12 @@ static bool igb_clean_tx_irq(struct igb_q_vector *q_vector)
 			tx_desc = E1000_TX_DESC_ADV(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
 			cleaned = (i == eop);
-			skb = buffer_info->skb;
 
-			if (skb) {
-				unsigned int segs, bytecount;
+			if (buffer_info->skb) {
+				total_bytes += buffer_info->bytecount;
 				/* gso_segs is currently only valid for tcp */
-				segs = buffer_info->gso_segs;
-				/* multiply data chunks by size of headers */
-				bytecount = ((segs - 1) * skb_headlen(skb)) +
-					    skb->len;
-				total_packets += segs;
-				total_bytes += bytecount;
-
-				igb_tx_hwtstamp(q_vector, skb);
+				total_packets += buffer_info->gso_segs;
+				igb_tx_hwtstamp(q_vector, buffer_info);
 			}
 
 			igb_unmap_and_free_tx_resource(tx_ring, buffer_info);

