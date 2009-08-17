From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [RFC net-next PATCH 4/4] qlge: Change large rx buffer logic.
Date: Mon, 17 Aug 2009 14:08:49 -0700
Message-ID: <1250543329-15123-5-git-send-email-ron.mercer@qlogic.com>
References: <1250543329-15123-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:39434 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758034AbZHQVO3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 17:14:29 -0400
In-Reply-To: <1250543329-15123-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we use a single page per large rx buffer.  This patch changes
this to use either chunks of pages for small MTU or multiple pages for
jumbo MTU depending on the page size.
Examples:
64k pages at 1500 MTU:
	large buffers will be 2048 bytes in length and there will be 32
	per page.
4k pages at 9000 MTU:
	large buffer will use 4 pages as one large buffer.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |   16 ++-
 drivers/net/qlge/qlge_main.c |  302 +++++++++++++++++++++++++++++-------------
 2 files changed, 224 insertions(+), 94 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 5559c80..c731a05 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -53,8 +53,8 @@
 #define RX_RING_SHADOW_SPACE	(sizeof(u64) + \
 		MAX_DB_PAGES_PER_BQ(NUM_SMALL_BUFFERS) * sizeof(u64) + \
 		MAX_DB_PAGES_PER_BQ(NUM_LARGE_BUFFERS) * sizeof(u64))
-#define SMALL_BUFFER_SIZE 256
-#define LARGE_BUFFER_SIZE	PAGE_SIZE
+#define SMALL_BUFFER_SIZE 512
+#define SMALL_BUF_MAP_SIZE (SMALL_BUFFER_SIZE / 2)
 #define MAX_SPLIT_SIZE 1023
 #define QLGE_SB_PAD 32
 
@@ -1193,9 +1193,17 @@ struct tx_ring_desc {
 	struct tx_ring_desc *next;
 };
 
+struct page_chunk {
+	struct page *page;	/* master page */
+	char *va;		/* virt addr for this chunk */
+	u64 map;		/* mapping for master */
+	unsigned int offset;	/* offset for this chunk */
+	unsigned int last_flag; /* flag set for last chunk in page */
+};
+
 struct bq_desc {
 	union {
-		struct page *lbq_page;
+		struct page_chunk pg_chunk;
 		struct sk_buff *skb;
 	} p;
 	__le64 *addr;
@@ -1264,6 +1272,7 @@ struct rx_ring {
 	dma_addr_t lbq_base_dma;
 	void *lbq_base_indirect;
 	dma_addr_t lbq_base_indirect_dma;
+	struct page_chunk pg_chunk; /* current page for chunks */
 	struct bq_desc *lbq;	/* array of control blocks */
 	void __iomem *lbq_prod_idx_db_reg;	/* PCI doorbell mem area + 0x18 */
 	u32 lbq_prod_idx;	/* current sw prod idx */
@@ -1497,6 +1506,7 @@ struct ql_adapter {
 
 	struct rx_ring rx_ring[MAX_RX_RINGS];
 	struct tx_ring tx_ring[MAX_TX_RINGS];
+	unsigned int lbq_buf_order;
 
 	int rx_csum;
 
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index dcac9f2..a057ae1 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -996,6 +996,11 @@ end:
 	return status;
 }
 
+static inline unsigned int ql_lbq_block_size(struct ql_adapter *qdev)
+{
+	return PAGE_SIZE << qdev->lbq_buf_order;
+}
+
 /* Get the next large buffer. */
 static struct bq_desc *ql_get_curr_lbuf(struct rx_ring *rx_ring)
 {
@@ -1007,6 +1012,28 @@ static struct bq_desc *ql_get_curr_lbuf(struct rx_ring *rx_ring)
 	return lbq_desc;
 }
 
+static struct bq_desc *ql_get_curr_lchunk(struct ql_adapter *qdev,
+		struct rx_ring *rx_ring)
+{
+	struct bq_desc *lbq_desc = ql_get_curr_lbuf(rx_ring);
+
+	pci_dma_sync_single_for_cpu(qdev->pdev,
+					pci_unmap_addr(lbq_desc, mapaddr),
+				    rx_ring->lbq_buf_size,
+					PCI_DMA_FROMDEVICE);
+
+	/* If it's the last chunk of our master page then
+	 * we unmap it.
+	 */
+	if ((lbq_desc->p.pg_chunk.offset + rx_ring->lbq_buf_size)
+					== ql_lbq_block_size(qdev))
+		pci_unmap_page(qdev->pdev,
+				lbq_desc->p.pg_chunk.map,
+				ql_lbq_block_size(qdev),
+				PCI_DMA_FROMDEVICE);
+	return lbq_desc;
+}
+
 /* Get the next small buffer. */
 static struct bq_desc *ql_get_curr_sbuf(struct rx_ring *rx_ring)
 {
@@ -1034,6 +1061,53 @@ static void ql_write_cq_idx(struct rx_ring *rx_ring)
 	ql_write_db_reg(rx_ring->cnsmr_idx, rx_ring->cnsmr_idx_db_reg);
 }
 
+static int ql_get_next_chunk(struct ql_adapter *qdev, struct rx_ring *rx_ring,
+						struct bq_desc *lbq_desc)
+{
+	if (!rx_ring->pg_chunk.page) {
+		u64 map;
+		rx_ring->pg_chunk.page = alloc_pages(__GFP_COLD | __GFP_COMP |
+						GFP_ATOMIC,
+						qdev->lbq_buf_order);
+		if (unlikely(!rx_ring->pg_chunk.page)) {
+			QPRINTK(qdev, DRV, ERR,
+				"page allocation failed.\n");
+			return -ENOMEM;
+		}
+		rx_ring->pg_chunk.offset = 0;
+		map = pci_map_page(qdev->pdev, rx_ring->pg_chunk.page,
+					0, ql_lbq_block_size(qdev),
+					PCI_DMA_FROMDEVICE);
+		if (pci_dma_mapping_error(qdev->pdev, map)) {
+			__free_pages(rx_ring->pg_chunk.page,
+					qdev->lbq_buf_order);
+			QPRINTK(qdev, DRV, ERR,
+				"PCI mapping failed.\n");
+			return -ENOMEM;
+		}
+		rx_ring->pg_chunk.map = map;
+		rx_ring->pg_chunk.va = page_address(rx_ring->pg_chunk.page);
+	}
+
+	/* Copy the current master pg_chunk info
+	 * to the current descriptor.
+	 */
+	lbq_desc->p.pg_chunk = rx_ring->pg_chunk;
+
+	/* Adjust the master page chunk for next
+	 * buffer get.
+	 */
+	rx_ring->pg_chunk.offset += rx_ring->lbq_buf_size;
+	if (rx_ring->pg_chunk.offset == ql_lbq_block_size(qdev)) {
+		rx_ring->pg_chunk.page = NULL;
+		lbq_desc->p.pg_chunk.last_flag = 1;
+	} else {
+		rx_ring->pg_chunk.va += rx_ring->lbq_buf_size;
+		get_page(rx_ring->pg_chunk.page);
+		lbq_desc->p.pg_chunk.last_flag = 0;
+	}
+	return 0;
+}
 /* Process (refill) a large buffer queue. */
 static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 {
@@ -1043,39 +1117,30 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	u64 map;
 	int i;
 
-	while (rx_ring->lbq_free_cnt > 16) {
+	while (rx_ring->lbq_free_cnt > 32) {
 		for (i = 0; i < 16; i++) {
 			QPRINTK(qdev, RX_STATUS, DEBUG,
 				"lbq: try cleaning clean_idx = %d.\n",
 				clean_idx);
 			lbq_desc = &rx_ring->lbq[clean_idx];
-			if (lbq_desc->p.lbq_page == NULL) {
-				QPRINTK(qdev, RX_STATUS, DEBUG,
-					"lbq: getting new page for index %d.\n",
-					lbq_desc->index);
-				lbq_desc->p.lbq_page = alloc_page(GFP_ATOMIC);
-				if (lbq_desc->p.lbq_page == NULL) {
-					rx_ring->lbq_clean_idx = clean_idx;
-					QPRINTK(qdev, RX_STATUS, ERR,
-						"Couldn't get a page.\n");
-					return;
-				}
-				map = pci_map_page(qdev->pdev,
-						   lbq_desc->p.lbq_page,
-						   0, PAGE_SIZE,
-						   PCI_DMA_FROMDEVICE);
-				if (pci_dma_mapping_error(qdev->pdev, map)) {
-					rx_ring->lbq_clean_idx = clean_idx;
-					put_page(lbq_desc->p.lbq_page);
-					lbq_desc->p.lbq_page = NULL;
-					QPRINTK(qdev, RX_STATUS, ERR,
-						"PCI mapping failed.\n");
+			if (ql_get_next_chunk(qdev, rx_ring, lbq_desc)) {
+				QPRINTK(qdev, IFUP, ERR,
+					"Could not get a page chunk.\n");
 					return;
 				}
-				pci_unmap_addr_set(lbq_desc, mapaddr, map);
-				pci_unmap_len_set(lbq_desc, maplen, PAGE_SIZE);
-				*lbq_desc->addr = cpu_to_le64(map);
-			}
+
+			map = lbq_desc->p.pg_chunk.map +
+				lbq_desc->p.pg_chunk.offset;
+			pci_unmap_addr_set(lbq_desc, mapaddr, map);
+			pci_unmap_len_set(lbq_desc,
+						maplen,
+						rx_ring->lbq_buf_size);
+
+			*lbq_desc->addr = cpu_to_le64(map);
+
+			pci_dma_sync_single_for_device(qdev->pdev, map,
+						rx_ring->lbq_buf_size,
+						PCI_DMA_FROMDEVICE);
 			clean_idx++;
 			if (clean_idx == rx_ring->lbq_len)
 				clean_idx = 0;
@@ -1118,7 +1183,7 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 					sbq_desc->index);
 				sbq_desc->p.skb =
 				    netdev_alloc_skb(qdev->ndev,
-						     rx_ring->sbq_buf_size);
+						     SMALL_BUFFER_SIZE);
 				if (sbq_desc->p.skb == NULL) {
 					QPRINTK(qdev, PROBE, ERR,
 						"Couldn't get an skb.\n");
@@ -1128,8 +1193,8 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 				skb_reserve(sbq_desc->p.skb, QLGE_SB_PAD);
 				map = pci_map_single(qdev->pdev,
 						     sbq_desc->p.skb->data,
-						     rx_ring->sbq_buf_size /
-						     2, PCI_DMA_FROMDEVICE);
+						     rx_ring->sbq_buf_size,
+						     PCI_DMA_FROMDEVICE);
 				if (pci_dma_mapping_error(qdev->pdev, map)) {
 					QPRINTK(qdev, IFUP, ERR, "PCI mapping failed.\n");
 					rx_ring->sbq_clean_idx = clean_idx;
@@ -1139,7 +1204,7 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 				}
 				pci_unmap_addr_set(sbq_desc, mapaddr, map);
 				pci_unmap_len_set(sbq_desc, maplen,
-						  rx_ring->sbq_buf_size / 2);
+						  rx_ring->sbq_buf_size);
 				*sbq_desc->addr = cpu_to_le64(map);
 			}
 
@@ -1451,48 +1516,41 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 			 * chain it to the header buffer's skb and let
 			 * it rip.
 			 */
-			lbq_desc = ql_get_curr_lbuf(rx_ring);
-			pci_unmap_page(qdev->pdev,
-				       pci_unmap_addr(lbq_desc,
-						      mapaddr),
-				       pci_unmap_len(lbq_desc, maplen),
-				       PCI_DMA_FROMDEVICE);
+			lbq_desc = ql_get_curr_lchunk(qdev, rx_ring);
 			QPRINTK(qdev, RX_STATUS, DEBUG,
-				"Chaining page to skb.\n");
-			skb_fill_page_desc(skb, 0, lbq_desc->p.lbq_page,
-					   0, length);
+				"Chaining page at offset = %d,"
+				"for %d bytes  to skb.\n",
+				lbq_desc->p.pg_chunk.offset, length);
+			skb_fill_page_desc(skb, 0, lbq_desc->p.pg_chunk.page,
+						lbq_desc->p.pg_chunk.offset,
+						length);
 			skb->len += length;
 			skb->data_len += length;
 			skb->truesize += length;
-			lbq_desc->p.lbq_page = NULL;
 		} else {
 			/*
 			 * The headers and data are in a single large buffer. We
 			 * copy it to a new skb and let it go. This can happen with
 			 * jumbo mtu on a non-TCP/UDP frame.
 			 */
-			lbq_desc = ql_get_curr_lbuf(rx_ring);
+			lbq_desc = ql_get_curr_lchunk(qdev, rx_ring);
 			skb = netdev_alloc_skb(qdev->ndev, length);
 			if (skb == NULL) {
-				QPRINTK(qdev, PROBE, DEBUG,
+				QPRINTK(qdev, PROBE, ERR,
 					"No skb available, drop the packet.\n");
 				return NULL;
 			}
-			pci_unmap_page(qdev->pdev,
-				       pci_unmap_addr(lbq_desc,
-						      mapaddr),
-				       pci_unmap_len(lbq_desc, maplen),
-				       PCI_DMA_FROMDEVICE);
 			skb_reserve(skb, NET_IP_ALIGN);
 			QPRINTK(qdev, RX_STATUS, DEBUG,
 				"%d bytes of headers and data in large. Chain page to new skb and pull tail.\n", length);
-			skb_fill_page_desc(skb, 0, lbq_desc->p.lbq_page,
-					   0, length);
+			skb_fill_page_desc(skb, 0,
+						lbq_desc->p.pg_chunk.page,
+						lbq_desc->p.pg_chunk.offset,
+						length);
 			skb->len += length;
 			skb->data_len += length;
 			skb->truesize += length;
 			length -= length;
-			lbq_desc->p.lbq_page = NULL;
 			__pskb_pull_tail(skb,
 				(ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) ?
 				VLAN_ETH_HLEN : ETH_HLEN);
@@ -1509,8 +1567,7 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 		 *         frames.  If the MTU goes up we could
 		 *          eventually be in trouble.
 		 */
-		int size, offset, i = 0;
-		__le64 *bq, bq_array[8];
+		int size, i = 0;
 		sbq_desc = ql_get_curr_sbuf(rx_ring);
 		pci_unmap_single(qdev->pdev,
 				 pci_unmap_addr(sbq_desc, mapaddr),
@@ -1529,37 +1586,25 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 			QPRINTK(qdev, RX_STATUS, DEBUG,
 				"%d bytes of headers & data in chain of large.\n", length);
 			skb = sbq_desc->p.skb;
-			bq = &bq_array[0];
-			memcpy(bq, skb->data, sizeof(bq_array));
 			sbq_desc->p.skb = NULL;
 			skb_reserve(skb, NET_IP_ALIGN);
-		} else {
-			QPRINTK(qdev, RX_STATUS, DEBUG,
-				"Headers in small, %d bytes of data in chain of large.\n", length);
-			bq = (__le64 *)sbq_desc->p.skb->data;
 		}
 		while (length > 0) {
-			lbq_desc = ql_get_curr_lbuf(rx_ring);
-			pci_unmap_page(qdev->pdev,
-				       pci_unmap_addr(lbq_desc,
-						      mapaddr),
-				       pci_unmap_len(lbq_desc,
-						     maplen),
-				       PCI_DMA_FROMDEVICE);
-			size = (length < PAGE_SIZE) ? length : PAGE_SIZE;
-			offset = 0;
+			lbq_desc = ql_get_curr_lchunk(qdev, rx_ring);
+			size = (length < rx_ring->lbq_buf_size) ? length :
+				rx_ring->lbq_buf_size;
 
 			QPRINTK(qdev, RX_STATUS, DEBUG,
 				"Adding page %d to skb for %d bytes.\n",
 				i, size);
-			skb_fill_page_desc(skb, i, lbq_desc->p.lbq_page,
-					   offset, size);
+			skb_fill_page_desc(skb, i,
+						lbq_desc->p.pg_chunk.page,
+						lbq_desc->p.pg_chunk.offset,
+						size);
 			skb->len += size;
 			skb->data_len += size;
 			skb->truesize += size;
 			length -= size;
-			lbq_desc->p.lbq_page = NULL;
-			bq++;
 			i++;
 		}
 		__pskb_pull_tail(skb, (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) ?
@@ -1576,7 +1621,7 @@ static void ql_process_mac_rx_intr(struct ql_adapter *qdev,
 	struct net_device *ndev = qdev->ndev;
 	struct sk_buff *skb = NULL;
 	u16 vlan_id = (le16_to_cpu(ib_mac_rsp->vlan_id) &
-			IB_MAC_IOCB_RSP_VLAN_MASK)
+			IB_MAC_IOCB_RSP_VLAN_MASK);
 
 	QL_DUMP_IB_MAC_RSP(ib_mac_rsp);
 
@@ -2322,25 +2367,34 @@ err:
 	return -ENOMEM;
 }
 
-static void ql_free_lbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring)
+static void ql_free_lbq_buffers(struct ql_adapter *qdev,
+					struct rx_ring *rx_ring)
 {
-	int i;
 	struct bq_desc *lbq_desc;
 
-	for (i = 0; i < rx_ring->lbq_len; i++) {
-		lbq_desc = &rx_ring->lbq[i];
-		if (lbq_desc->p.lbq_page) {
-			pci_unmap_page(qdev->pdev,
-				       pci_unmap_addr(lbq_desc, mapaddr),
-				       pci_unmap_len(lbq_desc, maplen),
-				       PCI_DMA_FROMDEVICE);
+	uint32_t curr_idx, clean_idx;
+
+	curr_idx = rx_ring->lbq_curr_idx;
+	clean_idx = rx_ring->lbq_clean_idx;
+	while (curr_idx != clean_idx) {
+		lbq_desc = &rx_ring->lbq[curr_idx];
 
-			put_page(lbq_desc->p.lbq_page);
-			lbq_desc->p.lbq_page = NULL;
+		if (lbq_desc->p.pg_chunk.last_flag) {
+			pci_unmap_page(qdev->pdev,
+				lbq_desc->p.pg_chunk.map,
+				ql_lbq_block_size(qdev),
+				PCI_DMA_FROMDEVICE);
+			lbq_desc->p.pg_chunk.last_flag = 0;
 		}
+
+		put_page(lbq_desc->p.pg_chunk.page);
+		lbq_desc->p.pg_chunk.page = NULL;
+
+		if (++curr_idx == rx_ring->lbq_len)
+			curr_idx = 0;
+
 	}
 }
-
 static void ql_free_sbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 {
 	int i;
@@ -2713,7 +2767,7 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		cqicb->sbq_addr =
 		    cpu_to_le64(rx_ring->sbq_base_indirect_dma);
 		cqicb->sbq_buf_size =
-		    cpu_to_le16((u16)(rx_ring->sbq_buf_size/2));
+		    cpu_to_le16((u16)(rx_ring->sbq_buf_size));
 		bq_len = (rx_ring->sbq_len == 65536) ? 0 :
 			(u16) rx_ring->sbq_len;
 		cqicb->sbq_len = cpu_to_le16(bq_len);
@@ -2732,6 +2786,7 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		/* Inbound completion handling rx_rings run in
 		 * separate NAPI contexts.
 		 */
+		rx_ring->napi.dev = qdev->ndev;
 		netif_napi_add(qdev->ndev, &rx_ring->napi, ql_napi_poll_msix,
 			       64);
 		cqicb->irq_delay = cpu_to_le16(qdev->rx_coalesce_usecs);
@@ -3210,7 +3265,7 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 	ql_write32(qdev, FSC, mask | value);
 
 	ql_write32(qdev, SPLT_HDR, SPLT_HDR_EP |
-		min(SMALL_BUFFER_SIZE, MAX_SPLIT_SIZE));
+		min(SMALL_BUF_MAP_SIZE, MAX_SPLIT_SIZE));
 
 	/* Start up the rx queues. */
 	for (i = 0; i < qdev->rx_ring_count; i++) {
@@ -3435,6 +3490,10 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 	struct rx_ring *rx_ring;
 	struct tx_ring *tx_ring;
 	int cpu_cnt = min(MAX_CPUS, (int)num_online_cpus());
+	unsigned int lbq_buf_len =
+		(qdev->ndev->mtu > 1500) ? 16384 : 2048;
+
+	qdev->lbq_buf_order = get_order(lbq_buf_len);
 
 	/* Allocate outbound completion ring for each CPU. */
 	qdev->tx_ring_count = cpu_cnt;
@@ -3483,11 +3542,11 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 			rx_ring->lbq_len = NUM_LARGE_BUFFERS;
 			rx_ring->lbq_size =
 			    rx_ring->lbq_len * sizeof(__le64);
-			rx_ring->lbq_buf_size = LARGE_BUFFER_SIZE;
+			rx_ring->lbq_buf_size = (u16)lbq_buf_len;
 			rx_ring->sbq_len = NUM_SMALL_BUFFERS;
 			rx_ring->sbq_size =
 			    rx_ring->sbq_len * sizeof(__le64);
-			rx_ring->sbq_buf_size = SMALL_BUFFER_SIZE * 2;
+			rx_ring->sbq_buf_size = SMALL_BUF_MAP_SIZE;
 			rx_ring->type = RX_Q;
 		} else {
 			/*
@@ -3532,14 +3591,64 @@ error_up:
 	return err;
 }
 
+static int ql_change_rx_buffers(struct ql_adapter *qdev)
+{
+	struct rx_ring *rx_ring;
+	int i, status;
+	u32 lbq_buf_len;
+
+	/* Wait for an oustanding reset to complete. */
+	if (!test_bit(QL_ADAPTER_UP, &qdev->flags)) {
+		int i = 3;
+		while (i-- && !test_bit(QL_ADAPTER_UP, &qdev->flags)) {
+			QPRINTK(qdev, IFUP, ERR,
+				 "Waiting for adapter UP...\n");
+			ssleep(1);
+		}
+
+		if (!i) {
+			QPRINTK(qdev, IFUP, ERR,
+			 "Timed out waiting for adapter UP\n");
+			return -ETIMEDOUT;
+		}
+	}
+
+	status = ql_adapter_down(qdev);
+	if (status)
+		goto error;
+
+	/* Get the new rx buffer size. */
+	lbq_buf_len = (qdev->ndev->mtu > 1500) ? 16384 : 2048;
+	qdev->lbq_buf_order = get_order(lbq_buf_len);
+
+	for (i = 0; i < qdev->rss_ring_count; i++) {
+		rx_ring = &qdev->rx_ring[i];
+		/* Set the new size. */
+		rx_ring->lbq_buf_size = lbq_buf_len;
+	}
+
+	status = ql_adapter_up(qdev);
+	if (status)
+		goto error;
+
+	return status;
+error:
+	QPRINTK(qdev, IFUP, ALERT,
+		"Driver up/down cycle failed, closing device.\n");
+	rtnl_lock();
+	set_bit(QL_ADAPTER_UP, &qdev->flags);
+	dev_close(qdev->ndev);
+	rtnl_unlock();
+	return status;
+}
+
 static int qlge_change_mtu(struct net_device *ndev, int new_mtu)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
+	int status = 0;
 
 	if (ndev->mtu == 1500 && new_mtu == 9000) {
 		QPRINTK(qdev, IFUP, ERR, "Changing to jumbo MTU.\n");
-		queue_delayed_work(qdev->workqueue,
-				&qdev->mpi_port_cfg_work, 0);
 	} else if (ndev->mtu == 9000 && new_mtu == 1500) {
 		QPRINTK(qdev, IFUP, ERR, "Changing to normal MTU.\n");
 	} else if ((ndev->mtu == 1500 && new_mtu == 1500) ||
@@ -3547,8 +3656,19 @@ static int qlge_change_mtu(struct net_device *ndev, int new_mtu)
 		return 0;
 	} else
 		return -EINVAL;
+
+	if (!netif_running(qdev->ndev)) {
+		ndev->mtu = new_mtu;
+		return 0;
+	}
+
 	ndev->mtu = new_mtu;
-	return 0;
+	status = ql_change_rx_buffers(qdev);
+	if (status)
+		QPRINTK(qdev, IFUP, ERR,
+			"Changing MTU failed.\n");
+
+	return status;
 }
 
 static struct net_device_stats *qlge_get_stats(struct net_device
-- 
1.6.0.2

