From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: Re: Fw: b44 ifconfig fails with ENOMEM
Date: Sat, 8 Jan 2005 00:02:33 +0200
Message-ID: <20050107220233.GA9639@ee.oulu.fi>
References: <20050103191836.57f918e5.akpm@osdl.org> <20050104142026.000be2e8.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050104142026.000be2e8.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Jan 04, 2005 at 02:20:26PM -0800, David S. Miller wrote:
> On Mon, 3 Jan 2005 19:18:36 -0800
> Andrew Morton <akpm@osdl.org> wrote:
> 
> > b44 requires an order-8 allocation?  Good luck...
> 
> Yes, it allocates a full TX ring worth of bounce buffers
> to work around a DMA addressing limitation.  It should do
> a bunch of smaller consistent allocations instead of one
> huge one, that's for sure.
-ENOHARDWARE (Santa got me an Athlon64 with dual GigE) so someone else will
have to pick up the ball. Shouldn't be too difficult, quickly thinking
something like:

X-It-Compiles-Lets-Ship-It: pp@ee.oulu.fi
--- ./b44.c.orig	2005-01-05 12:15:30.000000000 +0200
+++ ./b44.c	2005-01-08 00:00:49.974949992 +0200
@@ -68,6 +68,8 @@
 	  (BP)->tx_cons - (BP)->tx_prod - TX_RING_GAP(BP))
 #define NEXT_TX(N)		(((N) + 1) & (B44_TX_RING_SIZE - 1))
 
+#define B44_BOUNCEBUF(ENTRY) (bp->tx_bufs[(ENTRY)&(B44_NUM_BOUNCEBUFS-1)]+((ENTRY)>>B44_BOUNCEBUF_SHIFT)*TX_PKT_BUF_SZ)
+
 #define RX_PKT_BUF_SZ		(1536 + bp->rx_offset + 64)
 #define TX_PKT_BUF_SZ		(B44_MAX_MTU + ETH_HLEN + 8)
 
@@ -927,8 +929,8 @@
 	if(mapping+len > B44_DMA_MASK) {
 		/* Chip can't handle DMA to/from >1GB, use bounce buffer */
 		pci_unmap_single(bp->pdev, mapping, len,PCI_DMA_TODEVICE);
-		memcpy(bp->tx_bufs+entry*TX_PKT_BUF_SZ,skb->data,skb->len);
-		mapping = pci_map_single(bp->pdev, bp->tx_bufs+entry*TX_PKT_BUF_SZ, len, PCI_DMA_TODEVICE);
+		memcpy(B44_BOUNCEBUF(entry),skb->data,skb->len);
+		mapping = pci_map_single(bp->pdev, B44_BOUNCEBUF(entry), len, PCI_DMA_TODEVICE);
 	}
 
 	bp->tx_buffers[entry].skb = skb;
@@ -1059,6 +1061,7 @@
  */
 static void b44_free_consistent(struct b44 *bp)
 {
+	int i;
 	if (bp->rx_buffers) {
 		kfree(bp->rx_buffers);
 		bp->rx_buffers = NULL;
@@ -1077,10 +1080,12 @@
 				    bp->tx_ring, bp->tx_ring_dma);
 		bp->tx_ring = NULL;
 	}
-	if (bp->tx_bufs) {
-		pci_free_consistent(bp->pdev, B44_TX_RING_SIZE * TX_PKT_BUF_SZ,
-				    bp->tx_bufs, bp->tx_bufs_dma);
-		bp->tx_bufs = NULL;
+	for(i = 0; i < B44_NUM_BOUNCEBUFS; i++) {
+		if (bp->tx_bufs[i]) {
+			pci_free_consistent(bp->pdev, B44_TX_RING_SIZE * TX_PKT_BUF_SZ / B44_NUM_BOUNCEBUFS,
+					    bp->tx_bufs[i], bp->tx_bufs_dma[i]);
+			bp->tx_bufs[i] = NULL;
+		}
 	}
 }
 
@@ -1090,7 +1095,7 @@
  */
 static int b44_alloc_consistent(struct b44 *bp)
 {
-	int size;
+	int i,size;
 
 	size  = B44_RX_RING_SIZE * sizeof(struct ring_info);
 	bp->rx_buffers = kmalloc(size, GFP_KERNEL);
@@ -1104,11 +1109,13 @@
 		goto out_err;
 	memset(bp->tx_buffers, 0, size);
 
-	size = B44_TX_RING_SIZE * TX_PKT_BUF_SZ;
-	bp->tx_bufs = pci_alloc_consistent(bp->pdev, size, &bp->tx_bufs_dma);
-	if (!bp->tx_bufs)
+	size = (B44_TX_RING_SIZE * TX_PKT_BUF_SZ) / B44_NUM_BOUNCEBUFS;
+	for(i = 0; i < B44_NUM_BOUNCEBUFS; i++) {
+	   bp->tx_bufs[i] = pci_alloc_consistent(bp->pdev, size, &bp->tx_bufs_dma[i]);
+	   if (!bp->tx_bufs[i])
 		goto out_err;
-	memset(bp->tx_bufs, 0, size);
+	   memset(bp->tx_bufs[i], 0, size);
+	}
 
 	size = DMA_TABLE_BYTES;
 	bp->rx_ring = pci_alloc_consistent(bp->pdev, size, &bp->rx_ring_dma);
--- ./b44.h.orig	2005-01-05 12:15:33.000000000 +0200
+++ ./b44.h	2005-01-07 23:53:07.234297264 +0200
@@ -359,6 +359,8 @@
 };
 
 #define B44_MCAST_TABLE_SIZE	32
+#define B44_BOUNCEBUF_SHIFT	3
+#define B44_NUM_BOUNCEBUFS	(1 << B44_BOUNCEBUF_SHIFT)
 
 /* SW copy of device statistics, kept up to date by periodic timer
  * which probes HW values.  Must have same relative layout as HW
@@ -397,7 +399,7 @@
 
 	struct ring_info	*rx_buffers;
 	struct ring_info	*tx_buffers;
-	unsigned char		*tx_bufs; 
+	unsigned char		*tx_bufs[B44_NUM_BOUNCEBUFS]; 
 
 	u32			dma_offset;
 	u32			flags;
@@ -429,7 +431,8 @@
 	struct pci_dev		*pdev;
 	struct net_device	*dev;
 
-	dma_addr_t		rx_ring_dma, tx_ring_dma,tx_bufs_dma;
+	dma_addr_t		rx_ring_dma, tx_ring_dma;
+	dma_addr_t		tx_bufs_dma[B44_NUM_BOUNCEBUFS];
 
 	u32			rx_pending;
 	u32			tx_pending;
