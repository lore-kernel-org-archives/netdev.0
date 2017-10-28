From: Zhu Yanjun <yanjun.zhu@oracle.com>
Subject: [PATCH net-next 1/1] forcedeth: replace pci_alloc_consistent with dma_alloc_coherent
Date: Sat, 28 Oct 2017 08:25:30 -0400
Message-ID: <1509193530-25321-1-git-send-email-yanjun.zhu@oracle.com>
To: keescook@chromium.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39169 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751000AbdJ1MXC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 28 Oct 2017 08:23:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The functions pci_alloc_consistent is obsolete. So it is replaced
with dma_alloc_coherent

Signed-off-by: Zhu Yanjun <yanjun.zhu@oracle.com>
---
 drivers/net/ethernet/nvidia/forcedeth.c | 61 ++++++++++++++++++++++-----------
 1 file changed, 41 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/nvidia/forcedeth.c b/drivers/net/ethernet/nvidia/forcedeth.c
index 88128ce..31a9438 100644
--- a/drivers/net/ethernet/nvidia/forcedeth.c
+++ b/drivers/net/ethernet/nvidia/forcedeth.c
@@ -1024,12 +1024,18 @@ static void free_rings(struct net_device *dev)
 
 	if (!nv_optimized(np)) {
 		if (np->rx_ring.orig)
-			pci_free_consistent(np->pci_dev, sizeof(struct ring_desc) * (np->rx_ring_size + np->tx_ring_size),
-					    np->rx_ring.orig, np->ring_addr);
+			dma_free_coherent(&np->pci_dev->dev,
+					  sizeof(struct ring_desc) *
+					  (np->rx_ring_size +
+					  np->tx_ring_size),
+					  np->rx_ring.orig, np->ring_addr);
 	} else {
 		if (np->rx_ring.ex)
-			pci_free_consistent(np->pci_dev, sizeof(struct ring_desc_ex) * (np->rx_ring_size + np->tx_ring_size),
-					    np->rx_ring.ex, np->ring_addr);
+			dma_free_coherent(&np->pci_dev->dev,
+					  sizeof(struct ring_desc_ex) *
+					  (np->rx_ring_size +
+					  np->tx_ring_size),
+					  np->rx_ring.ex, np->ring_addr);
 	}
 	kfree(np->rx_skb);
 	kfree(np->tx_skb);
@@ -4596,13 +4602,17 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
 
 	/* allocate new rings */
 	if (!nv_optimized(np)) {
-		rxtx_ring = pci_alloc_consistent(np->pci_dev,
-					    sizeof(struct ring_desc) * (ring->rx_pending + ring->tx_pending),
-					    &ring_addr);
+		rxtx_ring = dma_alloc_coherent(&np->pci_dev->dev,
+					       sizeof(struct ring_desc) *
+					       (ring->rx_pending +
+					       ring->tx_pending),
+					       &ring_addr, GFP_ATOMIC);
 	} else {
-		rxtx_ring = pci_alloc_consistent(np->pci_dev,
-					    sizeof(struct ring_desc_ex) * (ring->rx_pending + ring->tx_pending),
-					    &ring_addr);
+		rxtx_ring = dma_alloc_coherent(&np->pci_dev->dev,
+					       sizeof(struct ring_desc_ex) *
+					       (ring->rx_pending +
+					       ring->tx_pending),
+					       &ring_addr, GFP_ATOMIC);
 	}
 	rx_skbuff = kmalloc(sizeof(struct nv_skb_map) * ring->rx_pending, GFP_KERNEL);
 	tx_skbuff = kmalloc(sizeof(struct nv_skb_map) * ring->tx_pending, GFP_KERNEL);
@@ -4610,12 +4620,18 @@ static int nv_set_ringparam(struct net_device *dev, struct ethtool_ringparam* ri
 		/* fall back to old rings */
 		if (!nv_optimized(np)) {
 			if (rxtx_ring)
-				pci_free_consistent(np->pci_dev, sizeof(struct ring_desc) * (ring->rx_pending + ring->tx_pending),
-						    rxtx_ring, ring_addr);
+				dma_free_coherent(&np->pci_dev->dev,
+						  sizeof(struct ring_desc) *
+						  (ring->rx_pending +
+						  ring->tx_pending),
+						  rxtx_ring, ring_addr);
 		} else {
 			if (rxtx_ring)
-				pci_free_consistent(np->pci_dev, sizeof(struct ring_desc_ex) * (ring->rx_pending + ring->tx_pending),
-						    rxtx_ring, ring_addr);
+				dma_free_coherent(&np->pci_dev->dev,
+						  sizeof(struct ring_desc_ex) *
+						  (ring->rx_pending +
+						  ring->tx_pending),
+						  rxtx_ring, ring_addr);
 		}
 
 		kfree(rx_skbuff);
@@ -5740,16 +5756,21 @@ static int nv_probe(struct pci_dev *pci_dev, const struct pci_device_id *id)
 	np->tx_ring_size = TX_RING_DEFAULT;
 
 	if (!nv_optimized(np)) {
-		np->rx_ring.orig = pci_alloc_consistent(pci_dev,
-					sizeof(struct ring_desc) * (np->rx_ring_size + np->tx_ring_size),
-					&np->ring_addr);
+		np->rx_ring.orig = dma_alloc_coherent(&pci_dev->dev,
+						      sizeof(struct ring_desc) *
+						      (np->rx_ring_size +
+						      np->tx_ring_size),
+						      &np->ring_addr,
+						      GFP_ATOMIC);
 		if (!np->rx_ring.orig)
 			goto out_unmap;
 		np->tx_ring.orig = &np->rx_ring.orig[np->rx_ring_size];
 	} else {
-		np->rx_ring.ex = pci_alloc_consistent(pci_dev,
-					sizeof(struct ring_desc_ex) * (np->rx_ring_size + np->tx_ring_size),
-					&np->ring_addr);
+		np->rx_ring.ex = dma_alloc_coherent(&pci_dev->dev,
+						    sizeof(struct ring_desc_ex) *
+						    (np->rx_ring_size +
+						    np->tx_ring_size),
+						    &np->ring_addr, GFP_ATOMIC);
 		if (!np->rx_ring.ex)
 			goto out_unmap;
 		np->tx_ring.ex = &np->rx_ring.ex[np->rx_ring_size];
-- 
2.7.4
