From: akpm@osdl.org
Subject: [patch 01/13] b44: allocate tx bounce bufs as needed
Date: Tue, 15 Mar 2005 14:22:37 -0800
Message-ID: <200503152222.j2FMMW2x016793@shell0.pdx.osdl.net>
Cc: jgarzik@pobox.com, netdev@oss.sgi.com, akpm@osdl.org,
        linville@tuxdriver.com, pp@netppl.fi
To: davem@davemloft.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


From: "John W. Linville" <linville@tuxdriver.com>

The b44 hardware has a DMA mask that only covers 1GB.  On x86, a DMA mask
<4GB results in allocations using GFP_DMA.  The GFP_DMA pool (16MB) gets
exhausted very quickly in some configurations.

The b44 driver has been pre-allocating bounce buffers in a single large
(~750k) contiguous block.  On boxes w/ limited GFP_DMA memory, this
allocation can fail.  Such failure results in the driver being unable to
load and function.

The solution here is to check each tx skb against the DMA mask.  If it is
outside the allowable range, a single buffer is allocated from the GFP_DMA
range and discarded after the tx completes.  This behaviour mimics what is
done for bounce buffers on the rx side.

The pre-allocation of tx bounce buffers is, of course, removed.

Acked-by: Pekka Pietikäinen <pp@netppl.fi>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 25-akpm/drivers/net/b44.c |   36 +++++++++++++++++++++---------------
 25-akpm/drivers/net/b44.h |    3 +--
 2 files changed, 22 insertions(+), 17 deletions(-)

diff -puN drivers/net/b44.c~b44-allocate-tx-bounce-bufs-as-needed drivers/net/b44.c
--- 25/drivers/net/b44.c~b44-allocate-tx-bounce-bufs-as-needed	Tue Mar 15 14:19:52 2005
+++ 25-akpm/drivers/net/b44.c	Tue Mar 15 14:19:52 2005
@@ -907,6 +907,7 @@ static void b44_tx_timeout(struct net_de
 static int b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct b44 *bp = netdev_priv(dev);
+	struct sk_buff *bounce_skb;
 	dma_addr_t mapping;
 	u32 len, entry, ctrl;
 
@@ -922,15 +923,31 @@ static int b44_start_xmit(struct sk_buff
 		return 1;
 	}
 
-	entry = bp->tx_prod;
 	mapping = pci_map_single(bp->pdev, skb->data, len, PCI_DMA_TODEVICE);
 	if(mapping+len > B44_DMA_MASK) {
 		/* Chip can't handle DMA to/from >1GB, use bounce buffer */
-		pci_unmap_single(bp->pdev, mapping, len,PCI_DMA_TODEVICE);
-		memcpy(bp->tx_bufs+entry*TX_PKT_BUF_SZ,skb->data,skb->len);
-		mapping = pci_map_single(bp->pdev, bp->tx_bufs+entry*TX_PKT_BUF_SZ, len, PCI_DMA_TODEVICE);
+		pci_unmap_single(bp->pdev, mapping, len, PCI_DMA_TODEVICE);
+
+		bounce_skb = __dev_alloc_skb(TX_PKT_BUF_SZ,
+					     GFP_ATOMIC|GFP_DMA);
+		if (!bounce_skb)
+			return NETDEV_TX_BUSY;
+
+		mapping = pci_map_single(bp->pdev, bounce_skb->data,
+					 len, PCI_DMA_TODEVICE);
+		if(mapping+len > B44_DMA_MASK) {
+			pci_unmap_single(bp->pdev, mapping,
+					 len, PCI_DMA_TODEVICE);
+			dev_kfree_skb_any(bounce_skb);
+			return NETDEV_TX_BUSY;
+		}
+
+		memcpy(skb_put(bounce_skb, len), skb->data, skb->len);
+		dev_kfree_skb_any(skb);
+		skb = bounce_skb;
 	}
 
+	entry = bp->tx_prod;
 	bp->tx_buffers[entry].skb = skb;
 	pci_unmap_addr_set(&bp->tx_buffers[entry], mapping, mapping);
 
@@ -1077,11 +1094,6 @@ static void b44_free_consistent(struct b
 				    bp->tx_ring, bp->tx_ring_dma);
 		bp->tx_ring = NULL;
 	}
-	if (bp->tx_bufs) {
-		pci_free_consistent(bp->pdev, B44_TX_RING_SIZE * TX_PKT_BUF_SZ,
-				    bp->tx_bufs, bp->tx_bufs_dma);
-		bp->tx_bufs = NULL;
-	}
 }
 
 /*
@@ -1104,12 +1116,6 @@ static int b44_alloc_consistent(struct b
 		goto out_err;
 	memset(bp->tx_buffers, 0, size);
 
-	size = B44_TX_RING_SIZE * TX_PKT_BUF_SZ;
-	bp->tx_bufs = pci_alloc_consistent(bp->pdev, size, &bp->tx_bufs_dma);
-	if (!bp->tx_bufs)
-		goto out_err;
-	memset(bp->tx_bufs, 0, size);
-
 	size = DMA_TABLE_BYTES;
 	bp->rx_ring = pci_alloc_consistent(bp->pdev, size, &bp->rx_ring_dma);
 	if (!bp->rx_ring)
diff -puN drivers/net/b44.h~b44-allocate-tx-bounce-bufs-as-needed drivers/net/b44.h
--- 25/drivers/net/b44.h~b44-allocate-tx-bounce-bufs-as-needed	Tue Mar 15 14:19:52 2005
+++ 25-akpm/drivers/net/b44.h	Tue Mar 15 14:19:52 2005
@@ -383,7 +383,6 @@ struct b44 {
 
 	struct ring_info	*rx_buffers;
 	struct ring_info	*tx_buffers;
-	unsigned char		*tx_bufs; 
 
 	u32			dma_offset;
 	u32			flags;
@@ -415,7 +414,7 @@ struct b44 {
 	struct pci_dev		*pdev;
 	struct net_device	*dev;
 
-	dma_addr_t		rx_ring_dma, tx_ring_dma,tx_bufs_dma;
+	dma_addr_t		rx_ring_dma, tx_ring_dma;
 
 	u32			rx_pending;
 	u32			tx_pending;
_
