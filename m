From: "John W. Linville" <linville@tuxdriver.com>
Subject: [patch 2.6.11] b44: allocate tx bounce bufs as needed
Date: Mon, 14 Mar 2005 15:24:01 -0500
Message-ID: <20050314202355.GA12298@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com, pp@netppl.fi, jgarzik@pobox.com, davem@davemloft.net
To: linux-kernel@vger.kernel.org
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Allocate tx bounce buffers one at a time as needed, rather than in
a single allocation.  This limits usage of the GFP_DMA memory pool.

Acked-by: Pekka Pietik=E4inen <pp@netppl.fi>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
The b44 hardware has a DMA mask that only covers 1GB.  On x86, a DMA
mask <4GB results in allocations using GFP_DMA.  The GFP_DMA pool
(16MB) gets exhausted very quickly in some configurations.

The b44 driver has been pre-allocating bounce buffers in a single
large (~750k) contiguous block.  On boxes w/ limited GFP_DMA memory,
this allocation can fail.  Such failure results in the driver being
unable to load and function.

The solution here is to check each tx skb against the DMA mask.
If it is outside the allowable range, a single buffer is allocated
from the GFP_DMA range and discarded after the tx completes.
This behaviour mimics what is done for bounce buffers on the rx side.

The pre-allocation of tx bounce buffers is, of course, removed.

 drivers/net/b44.c |   36 +++++++++++++++++++++---------------
 drivers/net/b44.h |    3 +--
 2 files changed, 22 insertions(+), 17 deletions(-)

--- linux-2.6.11/drivers/net/b44.h.orig	2005-03-14 14:22:55.640858983 -05=
00
+++ linux-2.6.11/drivers/net/b44.h	2005-03-14 14:25:00.972718022 -0500
@@ -383,7 +383,6 @@ struct b44 {
=20
 	struct ring_info	*rx_buffers;
 	struct ring_info	*tx_buffers;
-	unsigned char		*tx_bufs;=20
=20
 	u32			dma_offset;
 	u32			flags;
@@ -415,7 +414,7 @@ struct b44 {
 	struct pci_dev		*pdev;
 	struct net_device	*dev;
=20
-	dma_addr_t		rx_ring_dma, tx_ring_dma,tx_bufs_dma;
+	dma_addr_t		rx_ring_dma, tx_ring_dma;
=20
 	u32			rx_pending;
 	u32			tx_pending;
--- linux-2.6.11/drivers/net/b44.c.orig	2005-03-14 14:22:17.000000000 -05=
00
+++ linux-2.6.11/drivers/net/b44.c	2005-03-14 14:25:00.991715423 -0500
@@ -907,6 +907,7 @@ static void b44_tx_timeout(struct net_de
 static int b44_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct b44 *bp =3D netdev_priv(dev);
+	struct sk_buff *bounce_skb;
 	dma_addr_t mapping;
 	u32 len, entry, ctrl;
=20
@@ -922,15 +923,31 @@ static int b44_start_xmit(struct sk_buff
 		return 1;
 	}
=20
-	entry =3D bp->tx_prod;
 	mapping =3D pci_map_single(bp->pdev, skb->data, len, PCI_DMA_TODEVICE);
 	if(mapping+len > B44_DMA_MASK) {
 		/* Chip can't handle DMA to/from >1GB, use bounce buffer */
-		pci_unmap_single(bp->pdev, mapping, len,PCI_DMA_TODEVICE);
-		memcpy(bp->tx_bufs+entry*TX_PKT_BUF_SZ,skb->data,skb->len);
-		mapping =3D pci_map_single(bp->pdev, bp->tx_bufs+entry*TX_PKT_BUF_SZ, =
len, PCI_DMA_TODEVICE);
+		pci_unmap_single(bp->pdev, mapping, len, PCI_DMA_TODEVICE);
+
+		bounce_skb =3D __dev_alloc_skb(TX_PKT_BUF_SZ,
+					     GFP_ATOMIC|GFP_DMA);
+		if (!bounce_skb)
+			return NETDEV_TX_BUSY;
+
+		mapping =3D pci_map_single(bp->pdev, bounce_skb->data,
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
+		skb =3D bounce_skb;
 	}
=20
+	entry =3D bp->tx_prod;
 	bp->tx_buffers[entry].skb =3D skb;
 	pci_unmap_addr_set(&bp->tx_buffers[entry], mapping, mapping);
=20
@@ -1077,11 +1094,6 @@ static void b44_free_consistent(struct b
 				    bp->tx_ring, bp->tx_ring_dma);
 		bp->tx_ring =3D NULL;
 	}
-	if (bp->tx_bufs) {
-		pci_free_consistent(bp->pdev, B44_TX_RING_SIZE * TX_PKT_BUF_SZ,
-				    bp->tx_bufs, bp->tx_bufs_dma);
-		bp->tx_bufs =3D NULL;
-	}
 }
=20
 /*
@@ -1104,12 +1116,6 @@ static int b44_alloc_consistent(struct b
 		goto out_err;
 	memset(bp->tx_buffers, 0, size);
=20
-	size =3D B44_TX_RING_SIZE * TX_PKT_BUF_SZ;
-	bp->tx_bufs =3D pci_alloc_consistent(bp->pdev, size, &bp->tx_bufs_dma);
-	if (!bp->tx_bufs)
-		goto out_err;
-	memset(bp->tx_bufs, 0, size);
-
 	size =3D DMA_TABLE_BYTES;
 	bp->rx_ring =3D pci_alloc_consistent(bp->pdev, size, &bp->rx_ring_dma);
 	if (!bp->rx_ring)
--=20
John W. Linville
linville@tuxdriver.com
