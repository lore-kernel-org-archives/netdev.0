From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 5/8] qlge: Remove inline math for small rx buf mapping.
Date: Sat, 10 Oct 2009 12:35:07 -0700
Message-ID: <1255203310-18114-6-git-send-email-ron.mercer@qlogic.com>
References: <1255203310-18114-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:55225 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934782AbZJJTnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2009 15:43:00 -0400
In-Reply-To: <1255203310-18114-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

rx_ring->sbq_buf_len now holds the length of the mapped portion of the
buffer rather than the overall length.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    3 ++-
 drivers/net/qlge/qlge_main.c |   14 +++++++-------
 2 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index e7285f0..633fcd1 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -54,7 +54,8 @@
 #define RX_RING_SHADOW_SPACE	(sizeof(u64) + \
 		MAX_DB_PAGES_PER_BQ(NUM_SMALL_BUFFERS) * sizeof(u64) + \
 		MAX_DB_PAGES_PER_BQ(NUM_LARGE_BUFFERS) * sizeof(u64))
-#define SMALL_BUFFER_SIZE 256
+#define SMALL_BUFFER_SIZE 512
+#define SMALL_BUF_MAP_SIZE (SMALL_BUFFER_SIZE / 2)
 #define LARGE_BUFFER_SIZE	PAGE_SIZE
 #define MAX_SPLIT_SIZE 1023
 #define QLGE_SB_PAD 32
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index aeb0104..09247ab 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1147,7 +1147,7 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 					sbq_desc->index);
 				sbq_desc->p.skb =
 				    netdev_alloc_skb(qdev->ndev,
-						     rx_ring->sbq_buf_size);
+						     SMALL_BUFFER_SIZE);
 				if (sbq_desc->p.skb == NULL) {
 					QPRINTK(qdev, PROBE, ERR,
 						"Couldn't get an skb.\n");
@@ -1157,8 +1157,8 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
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
@@ -1168,7 +1168,7 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 				}
 				pci_unmap_addr_set(sbq_desc, mapaddr, map);
 				pci_unmap_len_set(sbq_desc, maplen,
-						  rx_ring->sbq_buf_size / 2);
+						  rx_ring->sbq_buf_size);
 				*sbq_desc->addr = cpu_to_le64(map);
 			}
 
@@ -2692,7 +2692,7 @@ static int ql_start_rx_ring(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 		cqicb->sbq_addr =
 		    cpu_to_le64(rx_ring->sbq_base_indirect_dma);
 		cqicb->sbq_buf_size =
-		    cpu_to_le16((u16)(rx_ring->sbq_buf_size/2));
+		    cpu_to_le16((u16)(rx_ring->sbq_buf_size));
 		bq_len = (rx_ring->sbq_len == 65536) ? 0 :
 			(u16) rx_ring->sbq_len;
 		cqicb->sbq_len = cpu_to_le16(bq_len);
@@ -3268,7 +3268,7 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 	ql_write32(qdev, FSC, mask | value);
 
 	ql_write32(qdev, SPLT_HDR, SPLT_HDR_EP |
-		min(SMALL_BUFFER_SIZE, MAX_SPLIT_SIZE));
+		min(SMALL_BUF_MAP_SIZE, MAX_SPLIT_SIZE));
 
 	/* Set RX packet routing to use port/pci function on which the
 	 * packet arrived on in addition to usual frame routing.
@@ -3548,7 +3548,7 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 			rx_ring->sbq_len = NUM_SMALL_BUFFERS;
 			rx_ring->sbq_size =
 			    rx_ring->sbq_len * sizeof(__le64);
-			rx_ring->sbq_buf_size = SMALL_BUFFER_SIZE * 2;
+			rx_ring->sbq_buf_size = SMALL_BUF_MAP_SIZE;
 			rx_ring->type = RX_Q;
 		} else {
 			/*
-- 
1.6.0.2

