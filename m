From: Pekka Pietikainen <pp@ee.oulu.fi>
Subject: b44 and 4g4g
Date: Mon, 31 May 2004 23:21:04 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040531202104.GA8301@ee.oulu.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

After diagnosing 
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=118165
for a while

it seems that bcm4401 is quite broken when DMA:ing from/to
addresses that are > 1GB. This only is a problem with > 1GB of physical
memory and when using a 4:4 split.

It appears the network core code doesn't have a way of dealing with 
this situation cleanly, Arjan found this:

static inline int illegal_highdma(struct net_device *dev, struct sk_buff
*skb)
{
        int i;
 
        if (dev->features & NETIF_F_HIGHDMA)
                return 0;
 
        for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
                if (skb_shinfo(skb)->frags[i].page >= highmem_start_page)
                        return 1;
 
        return 0;
}

which doesn't take the pci dma mask into account at all, which it probably
should.

(Please correct me if I got details wrong, this is a bit over my head :-) )

Now, close your eyes and imagine you never saw this patch (which
does go a bit overkill with the GFP_DMA's just-in-case), which 
demonstrates what's required to make even receives work :-(
(trying to transmit causes the chip to do a link down/link up thing after a
few packets, which would suggest it gets very confused).

--- ../linux-2.6.6-1.391/net/core/dev.c	2004-05-26 15:29:13.000000000 +0300
+++ net/core/dev.c	2004-05-31 20:05:45.000000000 +0300
@@ -1197,7 +1197,7 @@
 	skb->ip_summed = CHECKSUM_NONE;
 	return skb;
 }
-
+#if 0
 #ifdef CONFIG_HIGHMEM
 /* Actually, we should eliminate this check as soon as we know, that:
  * 1. IOMMU is present and allows to map all the memory.
@@ -1220,7 +1220,8 @@
 #else
 #define illegal_highdma(dev, skb)	(0)
 #endif
-
+#endif
+#define illegal_highdma(dev, skb)	(1)
 extern void skb_release_data(struct sk_buff *);
 
 /* Keep head the same: replace data */
--- ../linux-2.6.6-1.391/drivers/net/b44.c	2004-05-26 15:29:11.000000000 +0300
+++ drivers/net/b44.c	2004-05-31 22:38:20.249808096 +0300
@@ -634,7 +634,7 @@
 		src_map = &bp->rx_buffers[src_idx];
 	dest_idx = dest_idx_unmasked & (B44_RX_RING_SIZE - 1);
 	map = &bp->rx_buffers[dest_idx];
-	skb = dev_alloc_skb(RX_PKT_BUF_SZ);
+	skb = __dev_alloc_skb(RX_PKT_BUF_SZ,GFP_DMA);
 	if (skb == NULL)
 		return -ENOMEM;
 
@@ -762,7 +762,7 @@
 			struct sk_buff *copy_skb;
 
 			b44_recycle_rx(bp, cons, bp->rx_prod);
-			copy_skb = dev_alloc_skb(len + 2);
+			copy_skb = __dev_alloc_skb(len + 2,GFP_DMA);
 			if (copy_skb == NULL)
 				goto drop_it_no_recycle;
 
@@ -1077,13 +1077,13 @@
 	int size;
 
 	size  = B44_RX_RING_SIZE * sizeof(struct ring_info);
-	bp->rx_buffers = kmalloc(size, GFP_KERNEL);
+	bp->rx_buffers = kmalloc(size, GFP_DMA|GFP_KERNEL);
 	if (!bp->rx_buffers)
 		goto out_err;
 	memset(bp->rx_buffers, 0, size);
 
 	size = B44_TX_RING_SIZE * sizeof(struct ring_info);
-	bp->tx_buffers = kmalloc(size, GFP_KERNEL);
+	bp->tx_buffers = kmalloc(size, GFP_DMA|GFP_KERNEL);
 	if (!bp->tx_buffers)
 		goto out_err;
 	memset(bp->tx_buffers, 0, size);
@@ -1727,7 +1727,13 @@
 
 	pci_set_master(pdev);
 
-	err = pci_set_dma_mask(pdev, (u64) 0xffffffff);
+	err = pci_set_dma_mask(pdev, (u64) 0x3fffffff);
+	if (err) {
+		printk(KERN_ERR PFX "No usable DMA configuration, "
+		       "aborting.\n");
+		goto err_out_free_res;
+	}
+	err = pci_set_consistent_dma_mask(pdev, (u64) 0x3fffffff);
 	if (err) {
 		printk(KERN_ERR PFX "No usable DMA configuration, "
 		       "aborting.\n");
