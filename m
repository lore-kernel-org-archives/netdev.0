From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 3/3] qlge: Size RX buffers based on MTU changes.
Date: Fri, 16 Oct 2009 13:15:36 -0700
Message-ID: <1255724136-27264-4-git-send-email-ron.mercer@qlogic.com>
References: <1255724136-27264-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:55516 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751003AbZJPUVb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 16:21:31 -0400
In-Reply-To: <1255724136-27264-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change RX large buffer size based on MTU. If pages are larger
than the MTU the page is divided up into multiple chunks and passed to
the hardware.  When pages are smaller than MTU each RX buffer can
contain be comprised of up to 2 pages.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |  149 ++++++++++++++++++++++--------------------
 1 files changed, 77 insertions(+), 72 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 5c0dbda..4935710 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1146,39 +1146,28 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
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
+
+			map = lbq_desc->p.pg_chunk.map +
+				lbq_desc->p.pg_chunk.offset;
 				pci_unmap_addr_set(lbq_desc, mapaddr, map);
-				pci_unmap_len_set(lbq_desc, maplen, PAGE_SIZE);
+			pci_unmap_len_set(lbq_desc, maplen,
+					rx_ring->lbq_buf_size);
 				*lbq_desc->addr = cpu_to_le64(map);
-			}
+
+			pci_dma_sync_single_for_device(qdev->pdev, map,
+						rx_ring->lbq_buf_size,
+						PCI_DMA_FROMDEVICE);
 			clean_idx++;
 			if (clean_idx == rx_ring->lbq_len)
 				clean_idx = 0;
@@ -1554,27 +1543,24 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
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
 				QPRINTK(qdev, PROBE, DEBUG,
@@ -1589,13 +1575,14 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
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
@@ -1612,8 +1599,7 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 		 *         frames.  If the MTU goes up we could
 		 *          eventually be in trouble.
 		 */
-		int size, offset, i = 0;
-		__le64 *bq, bq_array[8];
+		int size, i = 0;
 		sbq_desc = ql_get_curr_sbuf(rx_ring);
 		pci_unmap_single(qdev->pdev,
 				 pci_unmap_addr(sbq_desc, mapaddr),
@@ -1632,37 +1618,25 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
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
@@ -2378,20 +2352,29 @@ err:
 
 static void ql_free_lbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 {
-	int i;
 	struct bq_desc *lbq_desc;
 
-	for (i = 0; i < rx_ring->lbq_len; i++) {
-		lbq_desc = &rx_ring->lbq[i];
-		if (lbq_desc->p.lbq_page) {
+	uint32_t  curr_idx, clean_idx;
+
+	curr_idx = rx_ring->lbq_curr_idx;
+	clean_idx = rx_ring->lbq_clean_idx;
+	while (curr_idx != clean_idx) {
+		lbq_desc = &rx_ring->lbq[curr_idx];
+
+		if (lbq_desc->p.pg_chunk.last_flag) {
 			pci_unmap_page(qdev->pdev,
-				       pci_unmap_addr(lbq_desc, mapaddr),
-				       pci_unmap_len(lbq_desc, maplen),
+				lbq_desc->p.pg_chunk.map,
+				ql_lbq_block_size(qdev),
 				       PCI_DMA_FROMDEVICE);
-
-			put_page(lbq_desc->p.lbq_page);
-			lbq_desc->p.lbq_page = NULL;
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
 
@@ -2689,6 +2672,7 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 	/* Set up the shadow registers for this ring. */
 	rx_ring->prod_idx_sh_reg = shadow_reg;
 	rx_ring->prod_idx_sh_reg_dma = shadow_reg_dma;
+	*rx_ring->prod_idx_sh_reg = 0;
 	shadow_reg += sizeof(u64);
 	shadow_reg_dma += sizeof(u64);
 	rx_ring->lbq_base_indirect = shadow_reg;
@@ -3569,6 +3553,10 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 	struct rx_ring *rx_ring;
 	struct tx_ring *tx_ring;
 	int cpu_cnt = min(MAX_CPUS, (int)num_online_cpus());
+	unsigned int lbq_buf_len = (qdev->ndev->mtu > 1500) ?
+		LARGE_BUFFER_MAX_SIZE : LARGE_BUFFER_MIN_SIZE;
+
+	qdev->lbq_buf_order = get_order(lbq_buf_len);
 
 	/* In a perfect world we have one RSS ring for each CPU
 	 * and each has it's own vector.  To do that we ask for
@@ -3616,7 +3604,10 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 			rx_ring->lbq_len = NUM_LARGE_BUFFERS;
 			rx_ring->lbq_size =
 			    rx_ring->lbq_len * sizeof(__le64);
-			rx_ring->lbq_buf_size = LARGE_BUFFER_SIZE;
+			rx_ring->lbq_buf_size = (u16)lbq_buf_len;
+			QPRINTK(qdev, IFUP, DEBUG,
+				"lbq_buf_size %d, order = %d\n",
+				rx_ring->lbq_buf_size, qdev->lbq_buf_order);
 			rx_ring->sbq_len = NUM_SMALL_BUFFERS;
 			rx_ring->sbq_size =
 			    rx_ring->sbq_len * sizeof(__le64);
@@ -3719,11 +3710,10 @@ error:
 static int qlge_change_mtu(struct net_device *ndev, int new_mtu)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
+	int status;
 
 	if (ndev->mtu == 1500 && new_mtu == 9000) {
 		QPRINTK(qdev, IFUP, ERR, "Changing to jumbo MTU.\n");
-		queue_delayed_work(qdev->workqueue,
-				&qdev->mpi_port_cfg_work, 0);
 	} else if (ndev->mtu == 9000 && new_mtu == 1500) {
 		QPRINTK(qdev, IFUP, ERR, "Changing to normal MTU.\n");
 	} else if ((ndev->mtu == 1500 && new_mtu == 1500) ||
@@ -3731,8 +3721,23 @@ static int qlge_change_mtu(struct net_device *ndev, int new_mtu)
 		return 0;
 	} else
 		return -EINVAL;
+
+	queue_delayed_work(qdev->workqueue,
+			&qdev->mpi_port_cfg_work, 3*HZ);
+
+	if (!netif_running(qdev->ndev)) {
+		ndev->mtu = new_mtu;
+		return 0;
+	}
+
 	ndev->mtu = new_mtu;
-	return 0;
+	status = ql_change_rx_buffers(qdev);
+	if (status) {
+		QPRINTK(qdev, IFUP, ERR,
+			"Changing MTU failed.\n");
+	}
+
+	return status;
 }
 
 static struct net_device_stats *qlge_get_stats(struct net_device
-- 
1.6.0.2

