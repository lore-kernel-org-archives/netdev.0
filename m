From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 2/3] qlge: Size RX buffers based on MTU (Add API).
Date: Fri, 16 Oct 2009 13:15:35 -0700
Message-ID: <1255724136-27264-3-git-send-email-ron.mercer@qlogic.com>
References: <1255724136-27264-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:55516 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751854AbZJPUVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 16:21:32 -0400
In-Reply-To: <1255724136-27264-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change RX large buffer size based on MTU. If pages are larger
than the MTU the page is divided up into multiple chunks and passed to
the hardware.  When pages are smaller than MTU each RX buffer can
contain be comprised of up to 2 pages.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |  124 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 124 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 9eefb11..5c0dbda 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1025,6 +1025,11 @@ end:
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
@@ -1036,6 +1041,28 @@ static struct bq_desc *ql_get_curr_lbuf(struct rx_ring *rx_ring)
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
@@ -1063,6 +1090,53 @@ static void ql_write_cq_idx(struct rx_ring *rx_ring)
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
@@ -3592,6 +3666,56 @@ error_up:
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
+	lbq_buf_len = (qdev->ndev->mtu > 1500) ?
+		LARGE_BUFFER_MAX_SIZE : LARGE_BUFFER_MIN_SIZE;
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
+	set_bit(QL_ADAPTER_UP, &qdev->flags);
+	dev_close(qdev->ndev);
+	return status;
+}
+
 static int qlge_change_mtu(struct net_device *ndev, int new_mtu)
 {
 	struct ql_adapter *qdev = netdev_priv(ndev);
-- 
1.6.0.2

