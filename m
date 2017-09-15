From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCH 1/1] forcedeth: replace pci_map_single with dma_map_single functions
Date: Thu, 14 Sep 2017 23:01:51 -0400
Message-ID: <1505444511-27231-1-git-send-email-yanjun.zhu@oracle.com>
To: jarod@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:41194 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751733AbdIOC7V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 14 Sep 2017 22:59:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

pci_map_single functions are obsolete. So replace them with
dma_map_single functions.

Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c | 70 +++++++++++++++++----------------
 1 file changed, 36 insertions(+), 34 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index e6e0de4..0a7ba3a 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -1812,12 +1812,12 @@ static int nv_alloc_rx(struct net_device *dev)
 		struct sk_buff *skb = netdev_alloc_skb(dev, np->rx_buf_sz + NV_RX_ALLOC_PAD);
 		if (skb) {
 			np->put_rx_ctx->skb = skb;
-			np->put_rx_ctx->dma = pci_map_single(np->pci_dev,
+			np->put_rx_ctx->dma = dma_map_single(&np->pci_dev->dev,
 							     skb->data,
 							     skb_tailroom(skb),
-							     PCI_DMA_FROMDEVICE);
-			if (pci_dma_mapping_error(np->pci_dev,
-						  np->put_rx_ctx->dma)) {
+							     DMA_FROM_DEVICE);
+			if (dma_mapping_error(&np->pci_dev->dev,
+					      np->put_rx_ctx->dma)) {
 				kfree_skb(skb);
 				goto packet_dropped;
 			}
@@ -1853,12 +1853,12 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 		struct sk_buff *skb = netdev_alloc_skb(dev, np->rx_buf_sz + NV_RX_ALLOC_PAD);
 		if (skb) {
 			np->put_rx_ctx->skb = skb;
-			np->put_rx_ctx->dma = pci_map_single(np->pci_dev,
+			np->put_rx_ctx->dma = dma_map_single(&np->pci_dev->dev,
 							     skb->data,
 							     skb_tailroom(skb),
-							     PCI_DMA_FROMDEVICE);
-			if (pci_dma_mapping_error(np->pci_dev,
-						  np->put_rx_ctx->dma)) {
+							     DMA_FROM_DEVICE);
+			if (dma_mapping_error(&np->pci_dev->dev,
+					      np->put_rx_ctx->dma)) {
 				kfree_skb(skb);
 				goto packet_dropped;
 			}
@@ -1975,9 +1975,9 @@ static void nv_unmap_txskb(struct fe_priv *np, struct nv_skb_map *tx_skb)
 {
 	if (tx_skb->dma) {
 		if (tx_skb->dma_single)
-			pci_unmap_single(np->pci_dev, tx_skb->dma,
+			dma_unmap_single(&np->pci_dev->dev, tx_skb->dma,
 					 tx_skb->dma_len,
-					 PCI_DMA_TODEVICE);
+					 DMA_TO_DEVICE);
 		else
 			pci_unmap_page(np->pci_dev, tx_skb->dma,
 				       tx_skb->dma_len,
@@ -2045,10 +2045,10 @@ static void nv_drain_rx(struct net_device *dev)
 		}
 		wmb();
 		if (np->rx_skb[i].skb) {
-			pci_unmap_single(np->pci_dev, np->rx_skb[i].dma,
+			dma_unmap_single(&np->pci_dev->dev, np->rx_skb[i].dma,
 					 (skb_end_pointer(np->rx_skb[i].skb) -
-					  np->rx_skb[i].skb->data),
-					 PCI_DMA_FROMDEVICE);
+					 np->rx_skb[i].skb->data),
+					 DMA_FROM_DEVICE);
 			dev_kfree_skb(np->rx_skb[i].skb);
 			np->rx_skb[i].skb = NULL;
 		}
@@ -2221,10 +2221,11 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		prev_tx = put_tx;
 		prev_tx_ctx = np->put_tx_ctx;
 		bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
-		np->put_tx_ctx->dma = pci_map_single(np->pci_dev, skb->data + offset, bcnt,
-						PCI_DMA_TODEVICE);
-		if (pci_dma_mapping_error(np->pci_dev,
-					  np->put_tx_ctx->dma)) {
+		np->put_tx_ctx->dma = dma_map_single(&np->pci_dev->dev,
+						     skb->data + offset, bcnt,
+						     DMA_TO_DEVICE);
+		if (dma_mapping_error(&np->pci_dev->dev,
+				      np->put_tx_ctx->dma)) {
 			/* on DMA mapping error - drop the packet */
 			dev_kfree_skb_any(skb);
 			u64_stats_update_begin(&np->swstats_tx_syncp);
@@ -2369,10 +2370,11 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 		prev_tx = put_tx;
 		prev_tx_ctx = np->put_tx_ctx;
 		bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
-		np->put_tx_ctx->dma = pci_map_single(np->pci_dev, skb->data + offset, bcnt,
-						PCI_DMA_TODEVICE);
-		if (pci_dma_mapping_error(np->pci_dev,
-					  np->put_tx_ctx->dma)) {
+		np->put_tx_ctx->dma = dma_map_single(&np->pci_dev->dev,
+						     skb->data + offset, bcnt,
+						     DMA_TO_DEVICE);
+		if (dma_mapping_error(&np->pci_dev->dev,
+				      np->put_tx_ctx->dma)) {
 			/* on DMA mapping error - drop the packet */
 			dev_kfree_skb_any(skb);
 			u64_stats_update_begin(&np->swstats_tx_syncp);
@@ -2805,9 +2807,9 @@ static int nv_rx_process(struct net_device *dev, int limit)
 		 * TODO: check if a prefetch of the first cacheline improves
 		 * the performance.
 		 */
-		pci_unmap_single(np->pci_dev, np->get_rx_ctx->dma,
-				np->get_rx_ctx->dma_len,
-				PCI_DMA_FROMDEVICE);
+		dma_unmap_single(&np->pci_dev->dev, np->get_rx_ctx->dma,
+				 np->get_rx_ctx->dma_len,
+				 DMA_FROM_DEVICE);
 		skb = np->get_rx_ctx->skb;
 		np->get_rx_ctx->skb = NULL;
 
@@ -2911,9 +2913,9 @@ static int nv_rx_process_optimized(struct net_device *dev, int limit)
 		 * TODO: check if a prefetch of the first cacheline improves
 		 * the performance.
 		 */
-		pci_unmap_single(np->pci_dev, np->get_rx_ctx->dma,
-				np->get_rx_ctx->dma_len,
-				PCI_DMA_FROMDEVICE);
+		dma_unmap_single(&np->pci_dev->dev, np->get_rx_ctx->dma,
+				 np->get_rx_ctx->dma_len,
+				 DMA_FROM_DEVICE);
 		skb = np->get_rx_ctx->skb;
 		np->get_rx_ctx->skb = NULL;
 
@@ -5065,11 +5067,11 @@ static int nv_loopback_test(struct net_device *dev)
 		ret = 0;
 		goto out;
 	}
-	test_dma_addr = pci_map_single(np->pci_dev, tx_skb->data,
+	test_dma_addr = dma_map_single(&np->pci_dev->dev, tx_skb->data,
 				       skb_tailroom(tx_skb),
-				       PCI_DMA_FROMDEVICE);
-	if (pci_dma_mapping_error(np->pci_dev,
-				  test_dma_addr)) {
+				       DMA_FROM_DEVICE);
+	if (dma_mapping_error(&np->pci_dev->dev,
+			      test_dma_addr)) {
 		dev_kfree_skb_any(tx_skb);
 		goto out;
 	}
@@ -5124,9 +5126,9 @@ static int nv_loopback_test(struct net_device *dev)
 		}
 	}
 
-	pci_unmap_single(np->pci_dev, test_dma_addr,
-		       (skb_end_pointer(tx_skb) - tx_skb->data),
-		       PCI_DMA_TODEVICE);
+	dma_unmap_single(&np->pci_dev->dev, test_dma_addr,
+			 (skb_end_pointer(tx_skb) - tx_skb->data),
+			 DMA_TO_DEVICE);
 	dev_kfree_skb_any(tx_skb);
  out:
 	/* stop engines */
-- 
2.7.4
