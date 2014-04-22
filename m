From: Alexey Charkov <alchark@gmail.com>
Subject: [PATCH 1/3] net: via-rhine: switch to generic DMA functions
Date: Tue, 22 Apr 2014 19:28:07 +0400
Message-ID: <1398180489-20230-2-git-send-email-alchark@gmail.com>
References: <1390823503-24087-1-git-send-email-alchark@gmail.com>
 <1398180489-20230-1-git-send-email-alchark@gmail.com>
Cc: Alexey Charkov <alchark@gmail.com>
To: rl@hellgate.ch, netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux@prisktech.co.nz,
	robh+dt@kernel.org, davem@davemloft.net, ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:36527 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756743AbaDVP2n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 11:28:43 -0400
In-Reply-To: <1398180489-20230-1-git-send-email-alchark@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove legacy PCI DMA wrappers and instead use generic DMA functions
directly in preparation for OF bus binding

Signed-off-by: Alexey Charkov <alchark@gmail.com>
---
 drivers/net/ethernet/via/via-rhine.c | 84 ++++++++++++++++++------------------
 1 file changed, 43 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ethernet/via/via-rhine.c
index f61dc2b..0674d0f 100644
--- a/drivers/net/ethernet/via/via-rhine.c
+++ b/drivers/net/ethernet/via/via-rhine.c
@@ -919,10 +919,10 @@ static int rhine_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		goto err_out;
 
 	/* this should always be supported */
-	rc = pci_set_dma_mask(pdev, DMA_BIT_MASK(32));
+	rc = dma_set_mask(&pdev->dev, DMA_BIT_MASK(32));
 	if (rc) {
 		dev_err(&pdev->dev,
-			"32-bit PCI DMA addresses not supported by the card!?\n");
+			"32-bit DMA addresses not supported by the card!?\n");
 		goto err_out_pci_disable;
 	}
 
@@ -1096,23 +1096,25 @@ static int alloc_ring(struct net_device* dev)
 	void *ring;
 	dma_addr_t ring_dma;
 
-	ring = pci_alloc_consistent(rp->pdev,
-				    RX_RING_SIZE * sizeof(struct rx_desc) +
-				    TX_RING_SIZE * sizeof(struct tx_desc),
-				    &ring_dma);
+	ring = dma_alloc_coherent(&rp->pdev->dev,
+				  RX_RING_SIZE * sizeof(struct rx_desc) +
+				  TX_RING_SIZE * sizeof(struct tx_desc),
+				  &ring_dma,
+				  GFP_ATOMIC);
 	if (!ring) {
 		netdev_err(dev, "Could not allocate DMA memory\n");
 		return -ENOMEM;
 	}
 	if (rp->quirks & rqRhineI) {
-		rp->tx_bufs = pci_alloc_consistent(rp->pdev,
-						   PKT_BUF_SZ * TX_RING_SIZE,
-						   &rp->tx_bufs_dma);
+		rp->tx_bufs = dma_alloc_coherent(&rp->pdev->dev,
+						 PKT_BUF_SZ * TX_RING_SIZE,
+						 &rp->tx_bufs_dma,
+						 GFP_ATOMIC);
 		if (rp->tx_bufs == NULL) {
-			pci_free_consistent(rp->pdev,
-				    RX_RING_SIZE * sizeof(struct rx_desc) +
-				    TX_RING_SIZE * sizeof(struct tx_desc),
-				    ring, ring_dma);
+			dma_free_coherent(&rp->pdev->dev,
+					  RX_RING_SIZE * sizeof(struct rx_desc) +
+					  TX_RING_SIZE * sizeof(struct tx_desc),
+					  ring, ring_dma);
 			return -ENOMEM;
 		}
 	}
@@ -1129,15 +1131,15 @@ static void free_ring(struct net_device* dev)
 {
 	struct rhine_private *rp = netdev_priv(dev);
 
-	pci_free_consistent(rp->pdev,
-			    RX_RING_SIZE * sizeof(struct rx_desc) +
-			    TX_RING_SIZE * sizeof(struct tx_desc),
-			    rp->rx_ring, rp->rx_ring_dma);
+	dma_free_coherent(&rp->pdev->dev,
+			  RX_RING_SIZE * sizeof(struct rx_desc) +
+			  TX_RING_SIZE * sizeof(struct tx_desc),
+			  rp->rx_ring, rp->rx_ring_dma);
 	rp->tx_ring = NULL;
 
 	if (rp->tx_bufs)
-		pci_free_consistent(rp->pdev, PKT_BUF_SZ * TX_RING_SIZE,
-				    rp->tx_bufs, rp->tx_bufs_dma);
+		dma_free_coherent(&rp->pdev->dev, PKT_BUF_SZ * TX_RING_SIZE,
+				  rp->tx_bufs, rp->tx_bufs_dma);
 
 	rp->tx_bufs = NULL;
 
@@ -1174,8 +1176,8 @@ static void alloc_rbufs(struct net_device *dev)
 			break;
 
 		rp->rx_skbuff_dma[i] =
-			pci_map_single(rp->pdev, skb->data, rp->rx_buf_sz,
-				       PCI_DMA_FROMDEVICE);
+			dma_map_single(&rp->pdev->dev, skb->data, rp->rx_buf_sz,
+				       DMA_FROM_DEVICE);
 		if (dma_mapping_error(&rp->pdev->dev, rp->rx_skbuff_dma[i])) {
 			rp->rx_skbuff_dma[i] = 0;
 			dev_kfree_skb(skb);
@@ -1197,9 +1199,9 @@ static void free_rbufs(struct net_device* dev)
 		rp->rx_ring[i].rx_status = 0;
 		rp->rx_ring[i].addr = cpu_to_le32(0xBADF00D0); /* An invalid address. */
 		if (rp->rx_skbuff[i]) {
-			pci_unmap_single(rp->pdev,
+			dma_unmap_single(&rp->pdev->dev,
 					 rp->rx_skbuff_dma[i],
-					 rp->rx_buf_sz, PCI_DMA_FROMDEVICE);
+					 rp->rx_buf_sz, DMA_FROM_DEVICE);
 			dev_kfree_skb(rp->rx_skbuff[i]);
 		}
 		rp->rx_skbuff[i] = NULL;
@@ -1238,10 +1240,10 @@ static void free_tbufs(struct net_device* dev)
 		rp->tx_ring[i].addr = cpu_to_le32(0xBADF00D0); /* An invalid address. */
 		if (rp->tx_skbuff[i]) {
 			if (rp->tx_skbuff_dma[i]) {
-				pci_unmap_single(rp->pdev,
+				dma_unmap_single(&rp->pdev->dev,
 						 rp->tx_skbuff_dma[i],
 						 rp->tx_skbuff[i]->len,
-						 PCI_DMA_TODEVICE);
+						 DMA_TO_DEVICE);
 			}
 			dev_kfree_skb(rp->tx_skbuff[i]);
 		}
@@ -1695,8 +1697,8 @@ static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
 						       rp->tx_bufs));
 	} else {
 		rp->tx_skbuff_dma[entry] =
-			pci_map_single(rp->pdev, skb->data, skb->len,
-				       PCI_DMA_TODEVICE);
+			dma_map_single(&rp->pdev->dev, skb->data, skb->len,
+				       DMA_TO_DEVICE);
 		if (dma_mapping_error(&rp->pdev->dev, rp->tx_skbuff_dma[entry])) {
 			dev_kfree_skb_any(skb);
 			rp->tx_skbuff_dma[entry] = 0;
@@ -1831,10 +1833,10 @@ static void rhine_tx(struct net_device *dev)
 		}
 		/* Free the original skb. */
 		if (rp->tx_skbuff_dma[entry]) {
-			pci_unmap_single(rp->pdev,
+			dma_unmap_single(&rp->pdev->dev,
 					 rp->tx_skbuff_dma[entry],
 					 rp->tx_skbuff[entry]->len,
-					 PCI_DMA_TODEVICE);
+					 DMA_TO_DEVICE);
 		}
 		dev_consume_skb_any(rp->tx_skbuff[entry]);
 		rp->tx_skbuff[entry] = NULL;
@@ -1924,19 +1926,19 @@ static int rhine_rx(struct net_device *dev, int limit)
 			if (pkt_len < rx_copybreak)
 				skb = netdev_alloc_skb_ip_align(dev, pkt_len);
 			if (skb) {
-				pci_dma_sync_single_for_cpu(rp->pdev,
-							    rp->rx_skbuff_dma[entry],
-							    rp->rx_buf_sz,
-							    PCI_DMA_FROMDEVICE);
+				dma_sync_single_for_cpu(&rp->pdev->dev,
+							rp->rx_skbuff_dma[entry],
+							rp->rx_buf_sz,
+							DMA_FROM_DEVICE);
 
 				skb_copy_to_linear_data(skb,
 						 rp->rx_skbuff[entry]->data,
 						 pkt_len);
 				skb_put(skb, pkt_len);
-				pci_dma_sync_single_for_device(rp->pdev,
-							       rp->rx_skbuff_dma[entry],
-							       rp->rx_buf_sz,
-							       PCI_DMA_FROMDEVICE);
+				dma_sync_single_for_device(&rp->pdev->dev,
+							   rp->rx_skbuff_dma[entry],
+							   rp->rx_buf_sz,
+							   DMA_FROM_DEVICE);
 			} else {
 				skb = rp->rx_skbuff[entry];
 				if (skb == NULL) {
@@ -1945,10 +1947,10 @@ static int rhine_rx(struct net_device *dev, int limit)
 				}
 				rp->rx_skbuff[entry] = NULL;
 				skb_put(skb, pkt_len);
-				pci_unmap_single(rp->pdev,
+				dma_unmap_single(&rp->pdev->dev,
 						 rp->rx_skbuff_dma[entry],
 						 rp->rx_buf_sz,
-						 PCI_DMA_FROMDEVICE);
+						 DMA_FROM_DEVICE);
 			}
 
 			if (unlikely(desc_length & DescTag))
@@ -1979,9 +1981,9 @@ static int rhine_rx(struct net_device *dev, int limit)
 			if (skb == NULL)
 				break;	/* Better luck next round. */
 			rp->rx_skbuff_dma[entry] =
-				pci_map_single(rp->pdev, skb->data,
+				dma_map_single(&rp->pdev->dev, skb->data,
 					       rp->rx_buf_sz,
-					       PCI_DMA_FROMDEVICE);
+					       DMA_FROM_DEVICE);
 			if (dma_mapping_error(&rp->pdev->dev, rp->rx_skbuff_dma[entry])) {
 				dev_kfree_skb(skb);
 				rp->rx_skbuff_dma[entry] = 0;
-- 
1.9.1
