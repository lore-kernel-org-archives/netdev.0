From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/2] ixgbe: Defeature Tx Head writeback
Date: Fri, 06 Feb 2009 14:44:47 -0800
Message-ID: <20090206224447.28541.40271.stgit@lost.foo-projects.org>
References: <20090206224424.28541.494.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:33700
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756278AbZBFWu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2009 17:50:57 -0500
In-Reply-To: <20090206224424.28541.494.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>

Tx Head writeback is causing multi-microsecond stalls on PCIe chipsets, due
to partial cacheline writebacks.  Removing this feature removes these
issues.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   60 +++++++++++++++-------------------------
 1 files changed, 23 insertions(+), 37 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 850361a..8e270b6 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -204,9 +204,6 @@ static inline bool ixgbe_check_tx_hang(struct ixgbe_adapter *adapter,
 #define DESC_NEEDED (TXD_USE_COUNT(IXGBE_MAX_DATA_PER_TXD) /* skb->data */ + \
 	MAX_SKB_FRAGS * TXD_USE_COUNT(PAGE_SIZE) + 1) /* for context */
 
-#define GET_TX_HEAD_FROM_RING(ring) (\
-	*(volatile u32 *) \
-	((union ixgbe_adv_tx_desc *)(ring)->desc + (ring)->count))
 static void ixgbe_tx_timeout(struct net_device *netdev);
 
 /**
@@ -217,26 +214,27 @@ static void ixgbe_tx_timeout(struct net_device *netdev);
 static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
                                struct ixgbe_ring *tx_ring)
 {
-	union ixgbe_adv_tx_desc *tx_desc;
-	struct ixgbe_tx_buffer *tx_buffer_info;
 	struct net_device *netdev = adapter->netdev;
-	struct sk_buff *skb;
-	unsigned int i;
-	u32 head, oldhead;
-	unsigned int count = 0;
+	union ixgbe_adv_tx_desc *tx_desc, *eop_desc;
+	struct ixgbe_tx_buffer *tx_buffer_info;
+	unsigned int i, eop, count = 0;
 	unsigned int total_bytes = 0, total_packets = 0;
 
-	rmb();
-	head = GET_TX_HEAD_FROM_RING(tx_ring);
-	head = le32_to_cpu(head);
 	i = tx_ring->next_to_clean;
-	while (1) {
-		while (i != head) {
+	eop = tx_ring->tx_buffer_info[i].next_to_watch;
+	eop_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
+
+	while ((eop_desc->wb.status & cpu_to_le32(IXGBE_TXD_STAT_DD)) &&
+	       (count < tx_ring->count)) {
+		bool cleaned = false;
+		for ( ; !cleaned; count++) {
+			struct sk_buff *skb;
 			tx_desc = IXGBE_TX_DESC_ADV(*tx_ring, i);
 			tx_buffer_info = &tx_ring->tx_buffer_info[i];
+			cleaned = (i == eop);
 			skb = tx_buffer_info->skb;
 
-			if (skb) {
+			if (cleaned && skb) {
 				unsigned int segs, bytecount;
 
 				/* gso_segs is currently only valid for tcp */
@@ -251,23 +249,17 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 			ixgbe_unmap_and_free_tx_resource(adapter,
 			                                 tx_buffer_info);
 
+			tx_desc->wb.status = 0;
+
 			i++;
 			if (i == tx_ring->count)
 				i = 0;
-
-			count++;
-			if (count == tx_ring->count)
-				goto done_cleaning;
 		}
-		oldhead = head;
-		rmb();
-		head = GET_TX_HEAD_FROM_RING(tx_ring);
-		head = le32_to_cpu(head);
-		if (head == oldhead)
-			goto done_cleaning;
-	} /* while (1) */
-
-done_cleaning:
+
+		eop = tx_ring->tx_buffer_info[i].next_to_watch;
+		eop_desc = IXGBE_TX_DESC_ADV(*tx_ring, eop);
+	}
+
 	tx_ring->next_to_clean = i;
 
 #define TX_WAKE_THRESHOLD (DESC_NEEDED * 2)
@@ -301,8 +293,8 @@ done_cleaning:
 
 	tx_ring->total_bytes += total_bytes;
 	tx_ring->total_packets += total_packets;
-	tx_ring->stats.bytes += total_bytes;
 	tx_ring->stats.packets += total_packets;
+	tx_ring->stats.bytes += total_bytes;
 	adapter->net_stats.tx_bytes += total_bytes;
 	adapter->net_stats.tx_packets += total_packets;
 	return (total_packets ? true : false);
@@ -1484,7 +1476,7 @@ static void ixgbe_configure_msi_and_legacy(struct ixgbe_adapter *adapter)
  **/
 static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 {
-	u64 tdba, tdwba;
+	u64 tdba;
 	struct ixgbe_hw *hw = &adapter->hw;
 	u32 i, j, tdlen, txctrl;
 
@@ -1497,11 +1489,6 @@ static void ixgbe_configure_tx(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_TDBAL(j),
 		                (tdba & DMA_32BIT_MASK));
 		IXGBE_WRITE_REG(hw, IXGBE_TDBAH(j), (tdba >> 32));
-		tdwba = ring->dma +
-		        (ring->count * sizeof(union ixgbe_adv_tx_desc));
-		tdwba |= IXGBE_TDWBAL_HEAD_WB_ENABLE;
-		IXGBE_WRITE_REG(hw, IXGBE_TDWBAL(j), tdwba & DMA_32BIT_MASK);
-		IXGBE_WRITE_REG(hw, IXGBE_TDWBAH(j), (tdwba >> 32));
 		IXGBE_WRITE_REG(hw, IXGBE_TDLEN(j), tdlen);
 		IXGBE_WRITE_REG(hw, IXGBE_TDH(j), 0);
 		IXGBE_WRITE_REG(hw, IXGBE_TDT(j), 0);
@@ -2880,8 +2867,7 @@ int ixgbe_setup_tx_resources(struct ixgbe_adapter *adapter,
 	memset(tx_ring->tx_buffer_info, 0, size);
 
 	/* round up to nearest 4K */
-	tx_ring->size = tx_ring->count * sizeof(union ixgbe_adv_tx_desc) +
-	                sizeof(u32);
+	tx_ring->size = tx_ring->count * sizeof(union ixgbe_adv_tx_desc);
 	tx_ring->size = ALIGN(tx_ring->size, 4096);
 
 	tx_ring->desc = pci_alloc_consistent(pdev, tx_ring->size,

