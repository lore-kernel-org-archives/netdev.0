From: Rask Ingemann Lambertsen <rask@sygehus.dk>
Subject: Re: [EXPERIMENTAL PATCH] 2.4 tulip jumbo frames
Date: Sat, 13 Dec 2003 18:29:28 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031213182925.A1791@sygehus.dk>
References: <20031209160632.D1345@sygehus.dk> <3FD5FC36.5090405@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="k1lZvvs/B4yU6o8G"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3FD5FC36.5090405@pobox.com>; from jgarzik@pobox.com on Tue, Dec 09, 2003 at 11:45:42AM -0500
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Dec 09, 2003 at 11:45:42AM -0500, Jeff Garzik wrote:
> Two questions and a comment...
> 
> Would you split this into two patches?  The first simply adds, and uses, 
> tp->rx_buf_sz.  The second adds PKT_BUF_SZ_MAX and mtu-related changes.

The first patch is attached to this message. I'm not happy with the second
part yet because it is too hackish and I would prefer to have a look at the
tulip documentation first.

> Have you looked at Donald Becker's changes to tulip.c?  He went through 
> most of his drivers and made the changes necessary to support larger 
> MTUs.  IIRC his tulip.c changes (which should be easily translate-able 
> to 2.6.x tulip) were a bit more minimal than your patch, but still 
> served the purpose.

I've just tested Becker's tulip.c v0.97 (7/22/2003) and it fails to receive
packets larger than the standard 1514 bytes. "ping -s 1472" works while
"ping -s 1473" doesn't (when pinging from another box).

-- 
Regards,
Rask Ingemann Lambertsen

--k1lZvvs/B4yU6o8G
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="tulip-rxbufsz.patch"

--- linux-2.4.22/drivers/net/tulip/tulip.h-orig	Mon Dec  1 21:58:11 2003
+++ linux-2.4.22/drivers/net/tulip/tulip.h	Mon Dec  1 22:09:14 2003
@@ -347,6 +353,7 @@ struct tulip_private {
 	struct ring_info tx_buffers[TX_RING_SIZE];
 	/* The addresses of receive-in-place skbuffs. */
 	struct ring_info rx_buffers[RX_RING_SIZE];
+	uint rx_buf_sz;
 	u16 setup_frame[96];	/* Pseudo-Tx frame to init address table. */
 	int chip_id;
 	int revision;
--- linux-2.4.22/drivers/net/tulip/interrupt.c-orig	Mon Dec  1 21:52:10 2003
+++ linux-2.4.22/drivers/net/tulip/interrupt.c	Mon Dec  1 22:03:50 2003
@@ -74,11 +74,11 @@ int tulip_refill_rx(struct net_device *d
 			struct sk_buff *skb;
 			dma_addr_t mapping;
 
-			skb = tp->rx_buffers[entry].skb = dev_alloc_skb(PKT_BUF_SZ);
+			skb = tp->rx_buffers[entry].skb = dev_alloc_skb(tp->rx_buf_sz);
 			if (skb == NULL)
 				break;
 
-			mapping = pci_map_single(tp->pdev, skb->tail, PKT_BUF_SZ,
+			mapping = pci_map_single(tp->pdev, skb->tail, tp->rx_buf_sz,
 						 PCI_DMA_FROMDEVICE);
 			tp->rx_buffers[entry].mapping = mapping;
 
@@ -203,7 +202,7 @@ static int tulip_rx(struct net_device *d
 #endif
 
 				pci_unmap_single(tp->pdev, tp->rx_buffers[entry].mapping,
-						 PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
+						 tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 
 				tp->rx_buffers[entry].skb = NULL;
 				tp->rx_buffers[entry].mapping = 0;
--- linux-2.4.22/drivers/net/tulip/tulip_core.c-orig	Mon Dec  1 21:34:32 2003
+++ linux-2.4.22/drivers/net/tulip/tulip_core.c	Mon Dec  1 22:10:53 2003
@@ -518,9 +521,7 @@ void tulip_xon(struct net_device *dev)
 static int
 tulip_open(struct net_device *dev)
 {
-#ifdef CONFIG_NET_HW_FLOWCONTROL
         struct tulip_private *tp = (struct tulip_private *)dev->priv;
-#endif
 	int retval;
 	MOD_INC_USE_COUNT;
 
@@ -529,6 +530,7 @@ tulip_open(struct net_device *dev)
 		return retval;
 	}
 
+ 	tp->rx_buf_sz = PKT_BUF_SZ;
 	tulip_init_ring (dev);
 
 	tulip_up (dev);
@@ -673,13 +678,13 @@ static void tulip_init_ring(struct net_d
 
 	for (i = 0; i < RX_RING_SIZE; i++) {
 		tp->rx_ring[i].status = 0x00000000;
-		tp->rx_ring[i].length = cpu_to_le32(PKT_BUF_SZ);
+		tp->rx_ring[i].length = cpu_to_le32(tp->rx_buf_sz);
 		tp->rx_ring[i].buffer2 = cpu_to_le32(tp->rx_ring_dma + sizeof(struct tulip_rx_desc) * (i + 1));
 		tp->rx_buffers[i].skb = NULL;
 		tp->rx_buffers[i].mapping = 0;
 	}
 	/* Mark the last entry as wrapping the ring. */
-	tp->rx_ring[i-1].length = cpu_to_le32(PKT_BUF_SZ | DESC_RING_WRAP);
+	tp->rx_ring[i-1].length = cpu_to_le32(tp->rx_buf_sz | DESC_RING_WRAP);
 	tp->rx_ring[i-1].buffer2 = cpu_to_le32(tp->rx_ring_dma);
 
 	for (i = 0; i < RX_RING_SIZE; i++) {
@@ -688,12 +693,12 @@ static void tulip_init_ring(struct net_d
 		/* Note the receive buffer must be longword aligned.
 		   dev_alloc_skb() provides 16 byte alignment.  But do *not*
 		   use skb_reserve() to align the IP header! */
-		struct sk_buff *skb = dev_alloc_skb(PKT_BUF_SZ);
+		struct sk_buff *skb = dev_alloc_skb(tp->rx_buf_sz);
 		tp->rx_buffers[i].skb = skb;
 		if (skb == NULL)
 			break;
 		mapping = pci_map_single(tp->pdev, skb->tail,
-					 PKT_BUF_SZ, PCI_DMA_FROMDEVICE);
+					 tp->rx_buf_sz, PCI_DMA_FROMDEVICE);
 		tp->rx_buffers[i].mapping = mapping;
 		skb->dev = dev;			/* Mark as being used by this device. */
 		tp->rx_ring[i].status = cpu_to_le32(DescOwned);	/* Owned by Tulip chip */
@@ -876,7 +881,7 @@ static int tulip_close (struct net_devic
 		tp->rx_ring[i].length = 0;
 		tp->rx_ring[i].buffer1 = 0xBADF00D0;	/* An invalid address. */
 		if (skb) {
-			pci_unmap_single(tp->pdev, mapping, PKT_BUF_SZ,
+			pci_unmap_single(tp->pdev, mapping, tp->rx_buf_sz,
 					 PCI_DMA_FROMDEVICE);
 			dev_kfree_skb (skb);
 		}

--k1lZvvs/B4yU6o8G--
