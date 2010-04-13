From: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Subject: [PATCH] qlge: use the DMA state API instead of the pci equivalents
Date: Tue, 13 Apr 2010 09:32:14 +0900
Message-ID: <1271118734-28353-6-git-send-email-fujita.tomonori@lab.ntt.co.jp>
References: <1271118734-28353-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Cc: fujita.tomonori@lab.ntt.co.jp, Ron Mercer <ron.mercer@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from sh.osrg.net ([192.16.179.4]:38869 "EHLO sh.osrg.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754441Ab0DMAde (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Apr 2010 20:33:34 -0400
In-Reply-To: <1271118734-28353-1-git-send-email-fujita.tomonori@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This replace the PCI DMA state API (include/linux/pci-dma.h) with the
DMA equivalents since the PCI DMA state API will be obsolete.

No functional change.

For further information about the background:

http://marc.info/?l=linux-netdev&m=127037540020276&w=2

Signed-off-by: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Cc: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    8 +++---
 drivers/net/qlge/qlge_main.c |   58 +++++++++++++++++++++---------------------
 2 files changed, 33 insertions(+), 33 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index 8b742b6..20624ba 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1344,8 +1344,8 @@ struct oal {
 };
 
 struct map_list {
-	DECLARE_PCI_UNMAP_ADDR(mapaddr);
-	DECLARE_PCI_UNMAP_LEN(maplen);
+	DEFINE_DMA_UNMAP_ADDR(mapaddr);
+	DEFINE_DMA_UNMAP_LEN(maplen);
 };
 
 struct tx_ring_desc {
@@ -1373,8 +1373,8 @@ struct bq_desc {
 	} p;
 	__le64 *addr;
 	u32 index;
-	 DECLARE_PCI_UNMAP_ADDR(mapaddr);
-	 DECLARE_PCI_UNMAP_LEN(maplen);
+	DEFINE_DMA_UNMAP_ADDR(mapaddr);
+	DEFINE_DMA_UNMAP_LEN(maplen);
 };
 
 #define QL_TXQ_IDX(qdev, skb) (smp_processor_id()%(qdev->tx_ring_count))
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 76df968..fa4b24c 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1057,7 +1057,7 @@ static struct bq_desc *ql_get_curr_lchunk(struct ql_adapter *qdev,
 	struct bq_desc *lbq_desc = ql_get_curr_lbuf(rx_ring);
 
 	pci_dma_sync_single_for_cpu(qdev->pdev,
-					pci_unmap_addr(lbq_desc, mapaddr),
+					dma_unmap_addr(lbq_desc, mapaddr),
 				    rx_ring->lbq_buf_size,
 					PCI_DMA_FROMDEVICE);
 
@@ -1170,8 +1170,8 @@ static void ql_update_lbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 
 			map = lbq_desc->p.pg_chunk.map +
 				lbq_desc->p.pg_chunk.offset;
-				pci_unmap_addr_set(lbq_desc, mapaddr, map);
-			pci_unmap_len_set(lbq_desc, maplen,
+				dma_unmap_addr_set(lbq_desc, mapaddr, map);
+			dma_unmap_len_set(lbq_desc, maplen,
 					rx_ring->lbq_buf_size);
 				*lbq_desc->addr = cpu_to_le64(map);
 
@@ -1241,8 +1241,8 @@ static void ql_update_sbq(struct ql_adapter *qdev, struct rx_ring *rx_ring)
 					sbq_desc->p.skb = NULL;
 					return;
 				}
-				pci_unmap_addr_set(sbq_desc, mapaddr, map);
-				pci_unmap_len_set(sbq_desc, maplen,
+				dma_unmap_addr_set(sbq_desc, mapaddr, map);
+				dma_unmap_len_set(sbq_desc, maplen,
 						  rx_ring->sbq_buf_size);
 				*sbq_desc->addr = cpu_to_le64(map);
 			}
@@ -1298,18 +1298,18 @@ static void ql_unmap_send(struct ql_adapter *qdev,
 					     "unmapping OAL area.\n");
 			}
 			pci_unmap_single(qdev->pdev,
-					 pci_unmap_addr(&tx_ring_desc->map[i],
+					 dma_unmap_addr(&tx_ring_desc->map[i],
 							mapaddr),
-					 pci_unmap_len(&tx_ring_desc->map[i],
+					 dma_unmap_len(&tx_ring_desc->map[i],
 						       maplen),
 					 PCI_DMA_TODEVICE);
 		} else {
 			netif_printk(qdev, tx_done, KERN_DEBUG, qdev->ndev,
 				     "unmapping frag %d.\n", i);
 			pci_unmap_page(qdev->pdev,
-				       pci_unmap_addr(&tx_ring_desc->map[i],
+				       dma_unmap_addr(&tx_ring_desc->map[i],
 						      mapaddr),
-				       pci_unmap_len(&tx_ring_desc->map[i],
+				       dma_unmap_len(&tx_ring_desc->map[i],
 						     maplen), PCI_DMA_TODEVICE);
 		}
 	}
@@ -1348,8 +1348,8 @@ static int ql_map_send(struct ql_adapter *qdev,
 
 	tbd->len = cpu_to_le32(len);
 	tbd->addr = cpu_to_le64(map);
-	pci_unmap_addr_set(&tx_ring_desc->map[map_idx], mapaddr, map);
-	pci_unmap_len_set(&tx_ring_desc->map[map_idx], maplen, len);
+	dma_unmap_addr_set(&tx_ring_desc->map[map_idx], mapaddr, map);
+	dma_unmap_len_set(&tx_ring_desc->map[map_idx], maplen, len);
 	map_idx++;
 
 	/*
@@ -1402,9 +1402,9 @@ static int ql_map_send(struct ql_adapter *qdev,
 			tbd->len =
 			    cpu_to_le32((sizeof(struct tx_buf_desc) *
 					 (frag_cnt - frag_idx)) | TX_DESC_C);
-			pci_unmap_addr_set(&tx_ring_desc->map[map_idx], mapaddr,
+			dma_unmap_addr_set(&tx_ring_desc->map[map_idx], mapaddr,
 					   map);
-			pci_unmap_len_set(&tx_ring_desc->map[map_idx], maplen,
+			dma_unmap_len_set(&tx_ring_desc->map[map_idx], maplen,
 					  sizeof(struct oal));
 			tbd = (struct tx_buf_desc *)&tx_ring_desc->oal;
 			map_idx++;
@@ -1425,8 +1425,8 @@ static int ql_map_send(struct ql_adapter *qdev,
 
 		tbd->addr = cpu_to_le64(map);
 		tbd->len = cpu_to_le32(frag->size);
-		pci_unmap_addr_set(&tx_ring_desc->map[map_idx], mapaddr, map);
-		pci_unmap_len_set(&tx_ring_desc->map[map_idx], maplen,
+		dma_unmap_addr_set(&tx_ring_desc->map[map_idx], mapaddr, map);
+		dma_unmap_len_set(&tx_ring_desc->map[map_idx], maplen,
 				  frag->size);
 
 	}
@@ -1742,8 +1742,8 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 		 */
 		sbq_desc = ql_get_curr_sbuf(rx_ring);
 		pci_unmap_single(qdev->pdev,
-				pci_unmap_addr(sbq_desc, mapaddr),
-				pci_unmap_len(sbq_desc, maplen),
+				dma_unmap_addr(sbq_desc, mapaddr),
+				dma_unmap_len(sbq_desc, maplen),
 				PCI_DMA_FROMDEVICE);
 		skb = sbq_desc->p.skb;
 		ql_realign_skb(skb, hdr_len);
@@ -1774,18 +1774,18 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 			 */
 			sbq_desc = ql_get_curr_sbuf(rx_ring);
 			pci_dma_sync_single_for_cpu(qdev->pdev,
-						    pci_unmap_addr
+						    dma_unmap_addr
 						    (sbq_desc, mapaddr),
-						    pci_unmap_len
+						    dma_unmap_len
 						    (sbq_desc, maplen),
 						    PCI_DMA_FROMDEVICE);
 			memcpy(skb_put(skb, length),
 			       sbq_desc->p.skb->data, length);
 			pci_dma_sync_single_for_device(qdev->pdev,
-						       pci_unmap_addr
+						       dma_unmap_addr
 						       (sbq_desc,
 							mapaddr),
-						       pci_unmap_len
+						       dma_unmap_len
 						       (sbq_desc,
 							maplen),
 						       PCI_DMA_FROMDEVICE);
@@ -1798,9 +1798,9 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 			ql_realign_skb(skb, length);
 			skb_put(skb, length);
 			pci_unmap_single(qdev->pdev,
-					 pci_unmap_addr(sbq_desc,
+					 dma_unmap_addr(sbq_desc,
 							mapaddr),
-					 pci_unmap_len(sbq_desc,
+					 dma_unmap_len(sbq_desc,
 						       maplen),
 					 PCI_DMA_FROMDEVICE);
 			sbq_desc->p.skb = NULL;
@@ -1839,9 +1839,9 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 				return NULL;
 			}
 			pci_unmap_page(qdev->pdev,
-				       pci_unmap_addr(lbq_desc,
+				       dma_unmap_addr(lbq_desc,
 						      mapaddr),
-				       pci_unmap_len(lbq_desc, maplen),
+				       dma_unmap_len(lbq_desc, maplen),
 				       PCI_DMA_FROMDEVICE);
 			skb_reserve(skb, NET_IP_ALIGN);
 			netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
@@ -1874,8 +1874,8 @@ static struct sk_buff *ql_build_rx_skb(struct ql_adapter *qdev,
 		int size, i = 0;
 		sbq_desc = ql_get_curr_sbuf(rx_ring);
 		pci_unmap_single(qdev->pdev,
-				 pci_unmap_addr(sbq_desc, mapaddr),
-				 pci_unmap_len(sbq_desc, maplen),
+				 dma_unmap_addr(sbq_desc, mapaddr),
+				 dma_unmap_len(sbq_desc, maplen),
 				 PCI_DMA_FROMDEVICE);
 		if (!(ib_mac_rsp->flags4 & IB_MAC_IOCB_RSP_HS)) {
 			/*
@@ -2737,8 +2737,8 @@ static void ql_free_sbq_buffers(struct ql_adapter *qdev, struct rx_ring *rx_ring
 		}
 		if (sbq_desc->p.skb) {
 			pci_unmap_single(qdev->pdev,
-					 pci_unmap_addr(sbq_desc, mapaddr),
-					 pci_unmap_len(sbq_desc, maplen),
+					 dma_unmap_addr(sbq_desc, mapaddr),
+					 dma_unmap_len(sbq_desc, maplen),
 					 PCI_DMA_FROMDEVICE);
 			dev_kfree_skb(sbq_desc->p.skb);
 			sbq_desc->p.skb = NULL;
-- 
1.6.5

