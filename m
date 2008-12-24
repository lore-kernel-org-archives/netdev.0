From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 1/2] igb: defeature tx head writeback
Date: Wed, 24 Dec 2008 14:31:42 -0800
Message-ID: <20081224223142.12176.9916.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta01.emeryville.ca.mail.comcast.net ([76.96.30.16]:59972 "EHLO
	QMTA01.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751188AbYLXWcB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Dec 2008 17:32:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This patch removes tx head writeback as it was found to not provide a
significant improvement in tx performance and on some systems has been seen
to cause a performance degredation due to partial cache line writes.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/e1000_defines.h |    1 
 drivers/net/igb/igb.h           |    5 +-
 drivers/net/igb/igb_main.c      |   85 +++++++++++++++++----------------------
 3 files changed, 39 insertions(+), 52 deletions(-)

diff --git a/drivers/net/igb/e1000_defines.h b/drivers/net/igb/e1000_defines.h
index c5fe784..40d0342 100644
--- a/drivers/net/igb/e1000_defines.h
+++ b/drivers/net/igb/e1000_defines.h
@@ -323,6 +323,7 @@
 #define E1000_TXD_CMD_IFCS   0x02000000 /* Insert FCS (Ethernet CRC) */
 #define E1000_TXD_CMD_RS     0x08000000 /* Report Status */
 #define E1000_TXD_CMD_DEXT   0x20000000 /* Descriptor extension (0 = legacy) */
+#define E1000_TXD_STAT_DD    0x00000001 /* Descriptor Done */
 /* Extended desc bits for Linksec and timesync */
 
 /* Transmit Control */
diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 2121b8b..c906325 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -43,8 +43,6 @@ struct igb_adapter;
 #endif
 
 /* Interrupt defines */
-#define IGB_MAX_TX_CLEAN 72
-
 #define IGB_MIN_DYN_ITR 3000
 #define IGB_MAX_DYN_ITR 96000
 
@@ -127,7 +125,8 @@ struct igb_buffer {
 		/* TX */
 		struct {
 			unsigned long time_stamp;
-			u32 length;
+			u16 length;
+			u16 next_to_watch;
 		};
 		/* RX */
 		struct {
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 6a40d94..4962cdf 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1575,8 +1575,7 @@ int igb_setup_tx_resources(struct igb_adapter *adapter,
 	memset(tx_ring->buffer_info, 0, size);
 
 	/* round up to nearest 4K */
-	tx_ring->size = tx_ring->count * sizeof(struct e1000_tx_desc)
-			+ sizeof(u32);
+	tx_ring->size = tx_ring->count * sizeof(struct e1000_tx_desc);
 	tx_ring->size = ALIGN(tx_ring->size, 4096);
 
 	tx_ring->desc = pci_alloc_consistent(pdev, tx_ring->size,
@@ -1635,7 +1634,7 @@ static int igb_setup_all_tx_resources(struct igb_adapter *adapter)
  **/
 static void igb_configure_tx(struct igb_adapter *adapter)
 {
-	u64 tdba, tdwba;
+	u64 tdba;
 	struct e1000_hw *hw = &adapter->hw;
 	u32 tctl;
 	u32 txdctl, txctrl;
@@ -1651,12 +1650,6 @@ static void igb_configure_tx(struct igb_adapter *adapter)
 				tdba & 0x00000000ffffffffULL);
 		wr32(E1000_TDBAH(i), tdba >> 32);
 
-		tdwba = ring->dma + ring->count * sizeof(struct e1000_tx_desc);
-		tdwba |= 1; /* enable head wb */
-		wr32(E1000_TDWBAL(i),
-				tdwba & 0x00000000ffffffffULL);
-		wr32(E1000_TDWBAH(i), tdwba >> 32);
-
 		ring->head = E1000_TDH(i);
 		ring->tail = E1000_TDT(i);
 		writel(0, hw->hw_addr + ring->tail);
@@ -2710,6 +2703,7 @@ static inline int igb_tso_adv(struct igb_adapter *adapter,
 	context_desc->seqnum_seed = 0;
 
 	buffer_info->time_stamp = jiffies;
+	buffer_info->next_to_watch = i;
 	buffer_info->dma = 0;
 	i++;
 	if (i == tx_ring->count)
@@ -2773,6 +2767,7 @@ static inline bool igb_tx_csum_adv(struct igb_adapter *adapter,
 				cpu_to_le32(tx_ring->queue_index << 4);
 
 		buffer_info->time_stamp = jiffies;
+		buffer_info->next_to_watch = i;
 		buffer_info->dma = 0;
 
 		i++;
@@ -2791,8 +2786,8 @@ static inline bool igb_tx_csum_adv(struct igb_adapter *adapter,
 #define IGB_MAX_DATA_PER_TXD	(1<<IGB_MAX_TXD_PWR)
 
 static inline int igb_tx_map_adv(struct igb_adapter *adapter,
-				 struct igb_ring *tx_ring,
-				 struct sk_buff *skb)
+				 struct igb_ring *tx_ring, struct sk_buff *skb,
+				 unsigned int first)
 {
 	struct igb_buffer *buffer_info;
 	unsigned int len = skb_headlen(skb);
@@ -2806,6 +2801,7 @@ static inline int igb_tx_map_adv(struct igb_adapter *adapter,
 	buffer_info->length = len;
 	/* set time_stamp *before* dma to help avoid a possible race */
 	buffer_info->time_stamp = jiffies;
+	buffer_info->next_to_watch = i;
 	buffer_info->dma = pci_map_single(adapter->pdev, skb->data, len,
 					  PCI_DMA_TODEVICE);
 	count++;
@@ -2823,6 +2819,7 @@ static inline int igb_tx_map_adv(struct igb_adapter *adapter,
 		BUG_ON(len >= IGB_MAX_DATA_PER_TXD);
 		buffer_info->length = len;
 		buffer_info->time_stamp = jiffies;
+		buffer_info->next_to_watch = i;
 		buffer_info->dma = pci_map_page(adapter->pdev,
 						frag->page,
 						frag->page_offset,
@@ -2835,8 +2832,9 @@ static inline int igb_tx_map_adv(struct igb_adapter *adapter,
 			i = 0;
 	}
 
-	i = (i == 0) ? tx_ring->count - 1 : i - 1;
+	i = ((i == 0) ? tx_ring->count - 1 : i - 1);
 	tx_ring->buffer_info[i].skb = skb;
+	tx_ring->buffer_info[first].next_to_watch = i;
 
 	return count;
 }
@@ -2943,6 +2941,7 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 				   struct igb_ring *tx_ring)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
+	unsigned int first;
 	unsigned int tx_flags = 0;
 	unsigned int len;
 	u8 hdr_len = 0;
@@ -2979,6 +2978,8 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 	if (skb->protocol == htons(ETH_P_IP))
 		tx_flags |= IGB_TX_FLAGS_IPV4;
 
+	first = tx_ring->next_to_use;
+
 	tso = skb_is_gso(skb) ? igb_tso_adv(adapter, tx_ring, skb, tx_flags,
 					      &hdr_len) : 0;
 
@@ -2994,7 +2995,7 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 				tx_flags |= IGB_TX_FLAGS_CSUM;
 
 	igb_tx_queue_adv(adapter, tx_ring, tx_flags,
-			 igb_tx_map_adv(adapter, tx_ring, skb),
+			 igb_tx_map_adv(adapter, tx_ring, skb, first),
 			 skb->len, hdr_len);
 
 	netdev->trans_start = jiffies;
@@ -3617,12 +3618,6 @@ static int igb_clean_rx_ring_msix(struct napi_struct *napi, int budget)
 	return 1;
 }
 
-static inline u32 get_head(struct igb_ring *tx_ring)
-{
-	void *end = (struct e1000_tx_desc *)tx_ring->desc + tx_ring->count;
-	return le32_to_cpu(*(volatile __le32 *)end);
-}
-
 /**
  * igb_clean_tx_irq - Reclaim resources after transmit completes
  * @adapter: board private structure
@@ -3631,24 +3626,25 @@ static inline u32 get_head(struct igb_ring *tx_ring)
 static bool igb_clean_tx_irq(struct igb_ring *tx_ring)
 {
 	struct igb_adapter *adapter = tx_ring->adapter;
-	struct e1000_hw *hw = &adapter->hw;
 	struct net_device *netdev = adapter->netdev;
-	struct e1000_tx_desc *tx_desc;
+	struct e1000_hw *hw = &adapter->hw;
 	struct igb_buffer *buffer_info;
 	struct sk_buff *skb;
-	unsigned int i;
-	u32 head, oldhead;
-	unsigned int count = 0;
+	union e1000_adv_tx_desc *tx_desc, *eop_desc;
 	unsigned int total_bytes = 0, total_packets = 0;
-	bool retval = true;
+	unsigned int i, eop, count = 0;
+	bool cleaned = false;
 
-	rmb();
-	head = get_head(tx_ring);
 	i = tx_ring->next_to_clean;
-	while (1) {
-		while (i != head) {
-			tx_desc = E1000_TX_DESC(*tx_ring, i);
+	eop = tx_ring->buffer_info[i].next_to_watch;
+	eop_desc = E1000_TX_DESC_ADV(*tx_ring, eop);
+
+	while ((eop_desc->wb.status & cpu_to_le32(E1000_TXD_STAT_DD)) &&
+	       (count < tx_ring->count)) {
+		for (cleaned = false; !cleaned; count++) {
+			tx_desc = E1000_TX_DESC_ADV(*tx_ring, i);
 			buffer_info = &tx_ring->buffer_info[i];
+			cleaned = (i == eop);
 			skb = buffer_info->skb;
 
 			if (skb) {
@@ -3663,25 +3659,17 @@ static bool igb_clean_tx_irq(struct igb_ring *tx_ring)
 			}
 
 			igb_unmap_and_free_tx_resource(adapter, buffer_info);
+			tx_desc->wb.status = 0;
 
 			i++;
 			if (i == tx_ring->count)
 				i = 0;
-
-			count++;
-			if (count == IGB_MAX_TX_CLEAN) {
-				retval = false;
-				goto done_cleaning;
-			}
 		}
-		oldhead = head;
-		rmb();
-		head = get_head(tx_ring);
-		if (head == oldhead)
-			goto done_cleaning;
-	}  /* while (1) */
-
-done_cleaning:
+
+		eop = tx_ring->buffer_info[i].next_to_watch;
+		eop_desc = E1000_TX_DESC_ADV(*tx_ring, eop);
+	}
+
 	tx_ring->next_to_clean = i;
 
 	if (unlikely(count &&
@@ -3708,7 +3696,6 @@ done_cleaning:
 		    && !(rd32(E1000_STATUS) &
 			 E1000_STATUS_TXOFF)) {
 
-			tx_desc = E1000_TX_DESC(*tx_ring, i);
 			/* detected Tx unit hang */
 			dev_err(&adapter->pdev->dev,
 				"Detected Tx Unit Hang\n"
@@ -3717,9 +3704,9 @@ done_cleaning:
 				"  TDT                  <%x>\n"
 				"  next_to_use          <%x>\n"
 				"  next_to_clean        <%x>\n"
-				"  head (WB)            <%x>\n"
 				"buffer_info[next_to_clean]\n"
 				"  time_stamp           <%lx>\n"
+				"  next_to_watch        <%x>\n"
 				"  jiffies              <%lx>\n"
 				"  desc.status          <%x>\n",
 				tx_ring->queue_index,
@@ -3727,10 +3714,10 @@ done_cleaning:
 				readl(adapter->hw.hw_addr + tx_ring->tail),
 				tx_ring->next_to_use,
 				tx_ring->next_to_clean,
-				head,
 				tx_ring->buffer_info[i].time_stamp,
+				eop,
 				jiffies,
-				tx_desc->upper.fields.status);
+				eop_desc->wb.status);
 			netif_stop_subqueue(netdev, tx_ring->queue_index);
 		}
 	}
@@ -3740,7 +3727,7 @@ done_cleaning:
 	tx_ring->tx_stats.packets += total_packets;
 	adapter->net_stats.tx_bytes += total_bytes;
 	adapter->net_stats.tx_packets += total_packets;
-	return retval;
+	return (count < tx_ring->count);
 }
 
 #ifdef CONFIG_IGB_LRO

