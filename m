From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 4/5] qlge: Fix sparse warning regarding rx buffer queues.
Date: Mon,  5 Jan 2009 14:27:31 -0800
Message-ID: <1231194452-10671-4-git-send-email-ron.mercer@qlogic.com>
References: <20090105222600.GA4232@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:42213 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbZAEW1h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jan 2009 17:27:37 -0500
In-Reply-To: <20090105222600.GA4232@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Warnings:
drivers/net/qlge/qlge_main.c:909:17: warning: incorrect type in assignment (different base types)
drivers/net/qlge/qlge_main.c:909:17:    expected unsigned int [unsigned] [usertype] addr_lo
drivers/net/qlge/qlge_main.c:909:17:    got restricted unsigned int [usertype] <noident>
drivers/net/qlge/qlge_main.c:911:17: warning: incorrect type in assignment (different base types)
drivers/net/qlge/qlge_main.c:911:17:    expected unsigned int [unsigned] [usertype] addr_hi
drivers/net/qlge/qlge_main.c:911:17:    got restricted unsigned int [usertype] <noident>
drivers/net/qlge/qlge_main.c:974:17: warning: incorrect type in assignment (different base types)
drivers/net/qlge/qlge_main.c:974:17:    expected unsigned int [unsigned] [usertype] addr_lo
drivers/net/qlge/qlge_main.c:974:17:    got restricted unsigned int [usertype] <noident>
drivers/net/qlge/qlge_main.c:975:17: warning: incorrect type in assignment (different base types)
drivers/net/qlge/qlge_main.c:975:17:    expected unsigned int [unsigned] [usertype] addr_hi
drivers/net/qlge/qlge_main.c:975:17:    got restricted unsigned int [usertype] <noident>
drivers/net/qlge/qlge_main.c:2132:16: warning: incorrect type in assignment (different base types)
drivers/net/qlge/qlge_main.c:2132:16:    expected unsigned int [unsigned] [usertype] addr_lo
drivers/net/qlge/qlge_main.c:2132:16:    got restricted unsigned int [usertype] <noident>
drivers/net/qlge/qlge_main.c:2133:16: warning: incorrect type in assignment (different base types)
drivers/net/qlge/qlge_main.c:2133:16:    expected unsigned int [unsigned] [usertype] addr_hi
drivers/net/qlge/qlge_main.c:2133:16:    got restricted unsigned int [usertype] <noident>
drivers/net/qlge/qlge_main.c:2212:15: warning: incorrect type in assignment (different base types)
drivers/net/qlge/qlge_main.c:2212:15:    expected unsigned int [unsigned] [usertype] addr_lo
drivers/net/qlge/qlge_main.c:2212:15:    got restricted unsigned int [usertype] <noident>
drivers/net/qlge/qlge_main.c:2214:15: warning: incorrect type in assignment (different base types)
drivers/net/qlge/qlge_main.c:2214:15:    expected unsigned int [unsigned] [usertype] addr_hi
drivers/net/qlge/qlge_main.c:2214:15:    got restricted unsigned int [usertype] <noident>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |   11 +-------
 drivers/net/qlge/qlge_main.c |   55 ++++++++++-------------------------------
 2 files changed, 15 insertions(+), 51 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 71cc487..76ef2bc 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -818,15 +818,6 @@ struct tx_doorbell_context {
 };
 
 /* DATA STRUCTURES SHARED WITH HARDWARE. */
-
-struct bq_element {
-	u32 addr_lo;
-#define BQ_END	0x00000001
-#define BQ_CONT	0x00000002
-#define BQ_MASK	0x00000003
-	u32 addr_hi;
-} __attribute((packed));
-
 struct tx_buf_desc {
 	__le64 addr;
 	__le32 len;
@@ -1139,7 +1130,7 @@ struct bq_desc {
 		struct page *lbq_page;
 		struct sk_buff *skb;
 	} p;
-	struct bq_element *bq;
+	__le64 *addr;
 	int index;
 	 DECLARE_PCI_UNMAP_ADDR(mapaddr);
 	 DECLARE_PCI_UNMAP_LEN(maplen);
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index d7894aa..f4c0160 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -874,7 +874,6 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 {
 	int clean_idx = rx_ring->lbq_clean_idx;
 	struct bq_desc *lbq_desc;
-	struct bq_element *bq;
 	u64 map;
 	int i;
 
@@ -884,7 +883,6 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 				"lbq: try cleaning clean_idx = %d.\n",
 				clean_idx);
 			lbq_desc = &rx_ring->lbq[clean_idx];
-			bq = lbq_desc->bq;
 			if (lbq_desc->p.lbq_page == NULL) {
 				QPRINTK(qdev, RX_STATUS, DEBUG,
 					"lbq: getting new page for index %d.\n",
@@ -906,10 +904,7 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 				}
 				pci_unmap_addr_set(lbq_desc, mapaddr, map);
 				pci_unmap_len_set(lbq_desc, maplen, PAGE_SIZE);
-				bq->addr_lo =	/*lbq_desc->addr_lo = */
-				    cpu_to_le32(map);
-				bq->addr_hi =	/*lbq_desc->addr_hi = */
-				    cpu_to_le32(map >> 32);
+				*lbq_desc->addr = cpu_to_le64(map);
 			}
 			clean_idx++;
 			if (clean_idx == rx_ring->lbq_len)
@@ -934,7 +929,6 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 {
 	int clean_idx = rx_ring->sbq_clean_idx;
 	struct bq_desc *sbq_desc;
-	struct bq_element *bq;
 	u64 map;
 	int i;
 
@@ -944,7 +938,6 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 			QPRINTK(qdev, RX_STATUS, DEBUG,
 				"sbq: try cleaning clean_idx = %d.\n",
 				clean_idx);
-			bq = sbq_desc->bq;
 			if (sbq_desc->p.skb == NULL) {
 				QPRINTK(qdev, RX_STATUS, DEBUG,
 					"sbq: getting new skb for index %d.\n",
@@ -971,8 +964,7 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 				pci_unmap_addr_set(sbq_desc, mapaddr, map);
 				pci_unmap_len_set(sbq_desc, maplen,
 						  rx_ring->sbq_buf_size / 2);
-				bq->addr_lo = cpu_to_le32(map);
-				bq->addr_hi = cpu_to_le32(map >> 32);
+				*sbq_desc->addr = cpu_to_le64(map);
 			}
 
 			clean_idx++;
@@ -1340,7 +1332,7 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 		 *          eventually be in trouble.
 		 */
 		int size, offset, i = 0;
-		struct bq_element *bq, bq_array[8];
+		__le64 *bq, bq_array[8];
 		sbq_desc = ql_get_curr_sbuf(rx_ring);
 		pci_unmap_single(qdev->pdev,
 				 pci_unmap_addr(sbq_desc, mapaddr),
@@ -1366,16 +1358,10 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 		} else {
 			QPRINTK(qdev, RX_STATUS, DEBUG,
 				"Headers in small, %d bytes of data in chain of large.\n", length);
-			bq = (struct bq_element *)sbq_desc->p.skb->data;
+			bq = (__le64 *)sbq_desc->p.skb->data;
 		}
 		while (length > 0) {
 			lbq_desc = ql_get_curr_lbuf(rx_ring);
-			if ((bq->addr_lo & ~BQ_MASK) != lbq_desc->bq->addr_lo) {
-				QPRINTK(qdev, RX_STATUS, ERR,
-					"Panic!!! bad large buffer address, expected 0x%.08x, got 0x%.08x.\n",
-					lbq_desc->bq->addr_lo, bq->addr_lo);
-				return NULL;
-			}
 			pci_unmap_page(qdev->pdev,
 				       pci_unmap_addr(lbq_desc,
 						      mapaddr),
@@ -2093,8 +2079,6 @@ static void ql_free_lbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring
 			put_page(lbq_desc->p.lbq_page);
 			lbq_desc->p.lbq_page = NULL;
 		}
-		lbq_desc->bq->addr_lo = 0;
-		lbq_desc->bq->addr_hi = 0;
 	}
 }
 
@@ -2107,12 +2091,12 @@ static int ql_alloc_lbq_buffers(struct ql_adapter *qdev,
 	int i;
 	struct bq_desc *lbq_desc;
 	u64 map;
-	struct bq_element *bq = rx_ring->lbq_base;
+	__le64 *bq = rx_ring->lbq_base;
 
 	for (i = 0; i < rx_ring->lbq_len; i++) {
 		lbq_desc = &rx_ring->lbq[i];
 		memset(lbq_desc, 0, sizeof(lbq_desc));
-		lbq_desc->bq = bq;
+		lbq_desc->addr = bq;
 		lbq_desc->index = i;
 		lbq_desc->p.lbq_page = alloc_page(GFP_ATOMIC);
 		if (unlikely(!lbq_desc->p.lbq_page)) {
@@ -2129,8 +2113,7 @@ static int ql_alloc_lbq_buffers(struct ql_adapter *qdev,
 			}
 			pci_unmap_addr_set(lbq_desc, mapaddr, map);
 			pci_unmap_len_set(lbq_desc, maplen, PAGE_SIZE);
-			bq->addr_lo = cpu_to_le32(map);
-			bq->addr_hi = cpu_to_le32(map >> 32);
+			*lbq_desc->addr = cpu_to_le64(map);
 		}
 		bq++;
 	}
@@ -2159,13 +2142,6 @@ static void ql_free_sbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring
 			dev_kfree_skb(sbq_desc->p.skb);
 			sbq_desc->p.skb = NULL;
 		}
-		if (sbq_desc->bq == NULL) {
-			QPRINTK(qdev, IFUP, ERR, "sbq_desc->bq %d is NULL.\n",
-				i);
-			return;
-		}
-		sbq_desc->bq->addr_lo = 0;
-		sbq_desc->bq->addr_hi = 0;
 	}
 }
 
@@ -2177,13 +2153,13 @@ static int ql_alloc_sbq_buffers(struct ql_adapter *qdev,
 	struct bq_desc *sbq_desc;
 	struct sk_buff *skb;
 	u64 map;
-	struct bq_element *bq = rx_ring->sbq_base;
+	__le64 *bq = rx_ring->sbq_base;
 
 	for (i = 0; i < rx_ring->sbq_len; i++) {
 		sbq_desc = &rx_ring->sbq[i];
 		memset(sbq_desc, 0, sizeof(sbq_desc));
 		sbq_desc->index = i;
-		sbq_desc->bq = bq;
+		sbq_desc->addr = bq;
 		skb = netdev_alloc_skb(qdev->ndev, rx_ring->sbq_buf_size);
 		if (unlikely(!skb)) {
 			/* Better luck next round */
@@ -2209,10 +2185,7 @@ static int ql_alloc_sbq_buffers(struct ql_adapter *qdev,
 		}
 		pci_unmap_addr_set(sbq_desc, mapaddr, map);
 		pci_unmap_len_set(sbq_desc, maplen, rx_ring->sbq_buf_size / 2);
-		bq->addr_lo =	/*sbq_desc->addr_lo = */
-		    cpu_to_le32(map);
-		bq->addr_hi =	/*sbq_desc->addr_hi = */
-		    cpu_to_le32(map >> 32);
+		*sbq_desc->addr = cpu_to_le64(map);
 		bq++;
 	}
 	return 0;
@@ -3356,11 +3329,11 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 			    rx_ring->cq_len * sizeof(struct ql_net_rsp_iocb);
 			rx_ring->lbq_len = NUM_LARGE_BUFFERS;
 			rx_ring->lbq_size =
-			    rx_ring->lbq_len * sizeof(struct bq_element);
+			    rx_ring->lbq_len * sizeof(__le64);
 			rx_ring->lbq_buf_size = LARGE_BUFFER_SIZE;
 			rx_ring->sbq_len = NUM_SMALL_BUFFERS;
 			rx_ring->sbq_size =
-			    rx_ring->sbq_len * sizeof(struct bq_element);
+			    rx_ring->sbq_len * sizeof(__le64);
 			rx_ring->sbq_buf_size = SMALL_BUFFER_SIZE * 2;
 			rx_ring->type = DEFAULT_Q;
 		} else if (i < qdev->rss_ring_first_cq_id) {
@@ -3387,11 +3360,11 @@ static int ql_configure_rings(struct ql_adapter *qdev)
 			    rx_ring->cq_len * sizeof(struct ql_net_rsp_iocb);
 			rx_ring->lbq_len = NUM_LARGE_BUFFERS;
 			rx_ring->lbq_size =
-			    rx_ring->lbq_len * sizeof(struct bq_element);
+			    rx_ring->lbq_len * sizeof(__le64);
 			rx_ring->lbq_buf_size = LARGE_BUFFER_SIZE;
 			rx_ring->sbq_len = NUM_SMALL_BUFFERS;
 			rx_ring->sbq_size =
-			    rx_ring->sbq_len * sizeof(struct bq_element);
+			    rx_ring->sbq_len * sizeof(__le64);
 			rx_ring->sbq_buf_size = SMALL_BUFFER_SIZE * 2;
 			rx_ring->type = RX_Q;
 		}
-- 
1.6.0

