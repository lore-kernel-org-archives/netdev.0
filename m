From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCH 1/1] forcedeth: optimize the xmit/rx with unlikely
Date: Fri, 22 Sep 2017 10:20:21 -0400
Message-ID: <1506090021-16489-1-git-send-email-yanjun.zhu@oracle.com>
To: davem@davemloft.net, jarod@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:21929 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751979AbdIVOSV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 10:18:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the xmit/rx fastpath, the function dma_map_single rarely fails.
Therefore, add an unlikely() optimization to this error check
conditional.

Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c | 26 ++++++++++++++------------
 1 file changed, 14 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 0a7ba3a..63a9e1e 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -1816,8 +1816,8 @@ static int nv_alloc_rx(struct net_device *dev)
 							     skb->data,
 							     skb_tailroom(skb),
 							     DMA_FROM_DEVICE);
-			if (dma_mapping_error(&np->pci_dev->dev,
-					      np->put_rx_ctx->dma)) {
+			if (unlikely(dma_mapping_error(&np->pci_dev->dev,
+						       np->put_rx_ctx->dma))) {
 				kfree_skb(skb);
 				goto packet_dropped;
 			}
@@ -1857,8 +1857,8 @@ static int nv_alloc_rx_optimized(struct net_device *dev)
 							     skb->data,
 							     skb_tailroom(skb),
 							     DMA_FROM_DEVICE);
-			if (dma_mapping_error(&np->pci_dev->dev,
-					      np->put_rx_ctx->dma)) {
+			if (unlikely(dma_mapping_error(&np->pci_dev->dev,
+						       np->put_rx_ctx->dma))) {
 				kfree_skb(skb);
 				goto packet_dropped;
 			}
@@ -2224,8 +2224,8 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		np->put_tx_ctx->dma = dma_map_single(&np->pci_dev->dev,
 						     skb->data + offset, bcnt,
 						     DMA_TO_DEVICE);
-		if (dma_mapping_error(&np->pci_dev->dev,
-				      np->put_tx_ctx->dma)) {
+		if (unlikely(dma_mapping_error(&np->pci_dev->dev,
+					       np->put_tx_ctx->dma))) {
 			/* on DMA mapping error - drop the packet */
 			dev_kfree_skb_any(skb);
 			u64_stats_update_begin(&np->swstats_tx_syncp);
@@ -2265,7 +2265,8 @@ static netdev_tx_t nv_start_xmit(struct sk_buff *skb, struct net_device *dev)
 							frag, offset,
 							bcnt,
 							DMA_TO_DEVICE);
-			if (dma_mapping_error(&np->pci_dev->dev, np->put_tx_ctx->dma)) {
+			if (unlikely(dma_mapping_error(&np->pci_dev->dev,
+						       np->put_tx_ctx->dma))) {
 
 				/* Unwind the mapped fragments */
 				do {
@@ -2373,8 +2374,8 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 		np->put_tx_ctx->dma = dma_map_single(&np->pci_dev->dev,
 						     skb->data + offset, bcnt,
 						     DMA_TO_DEVICE);
-		if (dma_mapping_error(&np->pci_dev->dev,
-				      np->put_tx_ctx->dma)) {
+		if (unlikely(dma_mapping_error(&np->pci_dev->dev,
+					       np->put_tx_ctx->dma))) {
 			/* on DMA mapping error - drop the packet */
 			dev_kfree_skb_any(skb);
 			u64_stats_update_begin(&np->swstats_tx_syncp);
@@ -2415,7 +2416,8 @@ static netdev_tx_t nv_start_xmit_optimized(struct sk_buff *skb,
 							bcnt,
 							DMA_TO_DEVICE);
 
-			if (dma_mapping_error(&np->pci_dev->dev, np->put_tx_ctx->dma)) {
+			if (unlikely(dma_mapping_error(&np->pci_dev->dev,
+						       np->put_tx_ctx->dma))) {
 
 				/* Unwind the mapped fragments */
 				do {
@@ -5070,8 +5072,8 @@ static int nv_loopback_test(struct net_device *dev)
 	test_dma_addr = dma_map_single(&np->pci_dev->dev, tx_skb->data,
 				       skb_tailroom(tx_skb),
 				       DMA_FROM_DEVICE);
-	if (dma_mapping_error(&np->pci_dev->dev,
-			      test_dma_addr)) {
+	if (unlikely(dma_mapping_error(&np->pci_dev->dev,
+				       test_dma_addr))) {
 		dev_kfree_skb_any(tx_skb);
 		goto out;
 	}
-- 
2.7.4
