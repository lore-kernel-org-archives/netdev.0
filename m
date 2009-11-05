From: <jie.yang@atheros.com>
Subject: [PATCH net-next]atl1c:change atl1c_buffer struct and restructure clean atl1c_buffer procedure
Date: Thu, 5 Nov 2009 22:39:13 +0800
Message-ID: <12574319533672-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Jie Yang <jie.yang@atheros.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.atheros.com ([12.36.123.2]:27099 "EHLO mail.atheros.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752380AbZKFFyO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Nov 2009 00:54:14 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

change atl1c_buffer struct, use "u16 flags" instead of "u16 state"
to store more infomation for atl1c_buffer, and restructure clean
atl1c_buffer procedure, add common api atl1c_clean_buffer.

Signed-off-by: Jie Yang <jie.yang@atheros.com>
---

drivers/net/atl1c/atl1c.h      |   22 +++++++++-
drivers/net/atl1c/atl1c_main.c |   84 ++++++++++++++++++++--------------------
2 files changed, 61 insertions(+), 45 deletions(-)

diff --git a/drivers/net/atl1c/Makefile b/drivers/net/atl1c/Makefile
diff --git a/drivers/net/atl1c/atl1c.h b/drivers/net/atl1c/atl1c.h
index 2a1120a..a348a22 100644
--- a/drivers/net/atl1c/atl1c.h
+++ b/drivers/net/atl1c/atl1c.h
@@ -470,12 +470,28 @@ struct atl1c_ring_header {
 struct atl1c_buffer {
 	struct sk_buff *skb;	/* socket buffer */
 	u16 length;		/* rx buffer length */
-	u16 state;		/* state of buffer */
-#define ATL1_BUFFER_FREE	0
-#define ATL1_BUFFER_BUSY	1
+	u16 flags;		/* information of buffer */
+#define ATL1C_BUFFER_FREE		0x0001
+#define ATL1C_BUFFER_BUSY		0x0002
+#define ATL1C_BUFFER_STATE_MASK		0x0003
+
+#define ATL1C_PCIMAP_SINGLE		0x0004
+#define ATL1C_PCIMAP_PAGE		0x0008
+#define ATL1C_PCIMAP_TYPE_MASK		0x000C
+
 	dma_addr_t dma;
 };
 
+#define ATL1C_SET_BUFFER_STATE(buff, state) do {	\
+	((buff)->flags) &= ~ATL1C_BUFFER_STATE_MASK;	\
+	((buff)->flags) |= (state);			\
+	} while (0)
+
+#define ATL1C_SET_PCIMAP_TYPE(buff, type) do {		\
+	((buff)->flags) &= ~ATL1C_PCIMAP_TYPE_MASK;	\
+	((buff)->flags) |= (type);			\
+	} while (0)
+
 /* transimit packet descriptor (tpd) ring */
 struct atl1c_tpd_ring {
 	void *desc;		/* descriptor ring virtual address */
diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
index 3b8801a..5ef9e23 100644
--- a/drivers/net/atl1c/atl1c_main.c
+++ b/drivers/net/atl1c/atl1c_main.c
@@ -710,6 +710,29 @@ static int __devinit atl1c_sw_init(struct atl1c_adapter *adapter)
 	return 0;
 }
 
+static inline void atl1c_clean_buffer(struct pci_dev *pdev,
+				struct atl1c_buffer *buffer_info, int in_irq)
+{
+	if (buffer_info->flags & ATL1C_BUFFER_FREE)
+		return;
+	if (buffer_info->dma) {
+		if (buffer_info->flags & ATL1C_PCIMAP_SINGLE)
+			pci_unmap_single(pdev, buffer_info->dma,
+					buffer_info->length, PCI_DMA_TODEVICE);
+		else if (buffer_info->flags & ATL1C_PCIMAP_PAGE)
+			pci_unmap_page(pdev, buffer_info->dma,
+					buffer_info->length, PCI_DMA_TODEVICE);
+	}
+	if (buffer_info->skb) {
+		if (in_irq)
+			dev_kfree_skb_irq(buffer_info->skb);
+		else
+			dev_kfree_skb(buffer_info->skb);
+	}
+	buffer_info->dma = 0;
+	buffer_info->skb = NULL;
+	ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_FREE);
+}
 /*
  * atl1c_clean_tx_ring - Free Tx-skb
  * @adapter: board private structure
@@ -725,22 +748,12 @@ static void atl1c_clean_tx_ring(struct atl1c_adapter *adapter,
 	ring_count = tpd_ring->count;
 	for (index = 0; index < ring_count; index++) {
 		buffer_info = &tpd_ring->buffer_info[index];
-		if (buffer_info->state == ATL1_BUFFER_FREE)
-			continue;
-		if (buffer_info->dma)
-			pci_unmap_single(pdev, buffer_info->dma,
-					buffer_info->length,
-					PCI_DMA_TODEVICE);
-		if (buffer_info->skb)
-			dev_kfree_skb(buffer_info->skb);
-		buffer_info->dma = 0;
-		buffer_info->skb = NULL;
-		buffer_info->state = ATL1_BUFFER_FREE;
+		atl1c_clean_buffer(pdev, buffer_info, 0);
 	}
 
 	/* Zero out Tx-buffers */
 	memset(tpd_ring->desc, 0, sizeof(struct atl1c_tpd_desc) *
-				ring_count);
+		ring_count);
 	atomic_set(&tpd_ring->next_to_clean, 0);
 	tpd_ring->next_to_use = 0;
 }
@@ -760,16 +773,7 @@ static void atl1c_clean_rx_ring(struct atl1c_adapter *adapter)
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		for (j = 0; j < rfd_ring[i].count; j++) {
 			buffer_info = &rfd_ring[i].buffer_info[j];
-			if (buffer_info->state == ATL1_BUFFER_FREE)
-				continue;
-			if (buffer_info->dma)
-				pci_unmap_single(pdev, buffer_info->dma,
-						buffer_info->length,
-						PCI_DMA_FROMDEVICE);
-			if (buffer_info->skb)
-				dev_kfree_skb(buffer_info->skb);
-			buffer_info->state = ATL1_BUFFER_FREE;
-			buffer_info->skb = NULL;
+			atl1c_clean_buffer(pdev, buffer_info, 0);
 		}
 		/* zero out the descriptor ring */
 		memset(rfd_ring[i].desc, 0, rfd_ring[i].size);
@@ -796,7 +800,8 @@ static void atl1c_init_ring_ptrs(struct atl1c_adapter *adapter)
 		atomic_set(&tpd_ring[i].next_to_clean, 0);
 		buffer_info = tpd_ring[i].buffer_info;
 		for (j = 0; j < tpd_ring->count; j++)
-			buffer_info[i].state = ATL1_BUFFER_FREE;
+			ATL1C_SET_BUFFER_STATE(&buffer_info[i],
+					ATL1C_BUFFER_FREE);
 	}
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		rfd_ring[i].next_to_use = 0;
@@ -805,7 +810,7 @@ static void atl1c_init_ring_ptrs(struct atl1c_adapter *adapter)
 		rrd_ring[i].next_to_clean = 0;
 		for (j = 0; j < rfd_ring[i].count; j++) {
 			buffer_info = &rfd_ring[i].buffer_info[j];
-			buffer_info->state = ATL1_BUFFER_FREE;
+			ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_FREE);
 		}
 	}
 }
@@ -1447,6 +1452,7 @@ static bool atl1c_clean_tx_irq(struct atl1c_adapter *adapter,
 	struct atl1c_tpd_ring *tpd_ring = (struct atl1c_tpd_ring *)
 				&adapter->tpd_ring[type];
 	struct atl1c_buffer *buffer_info;
+	struct pci_dev *pdev = adapter->pdev;
 	u16 next_to_clean = atomic_read(&tpd_ring->next_to_clean);
 	u16 hw_next_to_clean;
 	u16 shift;
@@ -1462,16 +1468,7 @@ static bool atl1c_clean_tx_irq(struct atl1c_adapter *adapter,
 
 	while (next_to_clean != hw_next_to_clean) {
 		buffer_info = &tpd_ring->buffer_info[next_to_clean];
-		if (buffer_info->state == ATL1_BUFFER_BUSY) {
-			pci_unmap_page(adapter->pdev, buffer_info->dma,
-					buffer_info->length, PCI_DMA_TODEVICE);
-			buffer_info->dma = 0;
-			if (buffer_info->skb) {
-				dev_kfree_skb_irq(buffer_info->skb);
-				buffer_info->skb = NULL;
-			}
-			buffer_info->state = ATL1_BUFFER_FREE;
-		}
+		atl1c_clean_buffer(pdev, buffer_info, 1);
 		if (++next_to_clean == tpd_ring->count)
 			next_to_clean = 0;
 		atomic_set(&tpd_ring->next_to_clean, next_to_clean);
@@ -1587,7 +1584,7 @@ static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter, const int ringid
 	buffer_info = &rfd_ring->buffer_info[rfd_next_to_use];
 	next_info = &rfd_ring->buffer_info[next_next];
 
-	while (next_info->state == ATL1_BUFFER_FREE) {
+	while (next_info->flags & ATL1C_BUFFER_FREE) {
 		rfd_desc = ATL1C_RFD_DESC(rfd_ring, rfd_next_to_use);
 
 		skb = dev_alloc_skb(adapter->rx_buffer_len);
@@ -1603,12 +1600,13 @@ static int atl1c_alloc_rx_buffer(struct atl1c_adapter *adapter, const int ringid
 		 * the 14 byte MAC header is removed
 		 */
 		vir_addr = skb->data;
-		buffer_info->state = ATL1_BUFFER_BUSY;
+		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_BUSY);
 		buffer_info->skb = skb;
 		buffer_info->length = adapter->rx_buffer_len;
 		buffer_info->dma = pci_map_single(pdev, vir_addr,
 						buffer_info->length,
 						PCI_DMA_FROMDEVICE);
+		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_SINGLE);
 		rfd_desc->buffer_addr = cpu_to_le64(buffer_info->dma);
 		rfd_next_to_use = next_next;
 		if (++next_next == rfd_ring->count)
@@ -1653,7 +1651,8 @@ static void atl1c_clean_rfd(struct atl1c_rfd_ring *rfd_ring,
 			RRS_RX_RFD_INDEX_MASK;
 	for (i = 0; i < num; i++) {
 		buffer_info[rfd_index].skb = NULL;
-		buffer_info[rfd_index].state = ATL1_BUFFER_FREE;
+		ATL1C_SET_BUFFER_STATE(&buffer_info[rfd_index],
+					ATL1C_BUFFER_FREE);
 		if (++rfd_index == rfd_ring->count)
 			rfd_index = 0;
 	}
@@ -1967,7 +1966,8 @@ static void atl1c_tx_map(struct atl1c_adapter *adapter,
 		buffer_info->length = map_len;
 		buffer_info->dma = pci_map_single(adapter->pdev,
 					skb->data, hdr_len, PCI_DMA_TODEVICE);
-		buffer_info->state = ATL1_BUFFER_BUSY;
+		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_BUSY);
+		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_SINGLE);
 		mapped_len += map_len;
 		use_tpd->buffer_addr = cpu_to_le64(buffer_info->dma);
 		use_tpd->buffer_len = cpu_to_le16(buffer_info->length);
@@ -1987,8 +1987,8 @@ static void atl1c_tx_map(struct atl1c_adapter *adapter,
 		buffer_info->dma =
 			pci_map_single(adapter->pdev, skb->data + mapped_len,
 					buffer_info->length, PCI_DMA_TODEVICE);
-		buffer_info->state = ATL1_BUFFER_BUSY;
-
+		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_BUSY);
+		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_SINGLE);
 		use_tpd->buffer_addr = cpu_to_le64(buffer_info->dma);
 		use_tpd->buffer_len  = cpu_to_le16(buffer_info->length);
 	}
@@ -2008,8 +2008,8 @@ static void atl1c_tx_map(struct atl1c_adapter *adapter,
 					frag->page_offset,
 					buffer_info->length,
 					PCI_DMA_TODEVICE);
-		buffer_info->state = ATL1_BUFFER_BUSY;
-
+		ATL1C_SET_BUFFER_STATE(buffer_info, ATL1C_BUFFER_BUSY);
+		ATL1C_SET_PCIMAP_TYPE(buffer_info, ATL1C_PCIMAP_PAGE);
 		use_tpd->buffer_addr = cpu_to_le64(buffer_info->dma);
 		use_tpd->buffer_len  = cpu_to_le16(buffer_info->length);
 	}


