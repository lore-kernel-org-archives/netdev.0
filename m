From: Brice Goglin <brice@myri.com>
Subject: [PATCH 4/7] myri10ge: drop contiguous skb routines
Date: Mon, 11 Dec 2006 11:26:12 +0100
Message-ID: <457D3244.2050906@myri.com>
References: <457D31B2.30505@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:42223 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762731AbWLKK0d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 05:26:33 -0500
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
In-Reply-To: <457D31B2.30505@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Drop the old routines that used the physically contigous skb now
that we use the physical pages. And rename myri10ge_page_rx_done()
to myri10ge_rx_done() as it was previously.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |  212 +---------------------------------------
 1 file changed, 8 insertions(+), 204 deletions(-)

Index: linux-git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-git.orig/drivers/net/myri10ge/myri10ge.c	2006-12-11 10:52:35.000000000 +0100
+++ linux-git/drivers/net/myri10ge/myri10ge.c	2006-12-11 10:52:44.000000000 +0100
@@ -97,7 +97,6 @@
 #define MYRI10GE_MAX_FRAGS_PER_FRAME (MYRI10GE_MAX_ETHER_MTU/MYRI10GE_ALLOC_SIZE + 1)
 
 struct myri10ge_rx_buffer_state {
-	struct sk_buff *skb;
 	struct page *page;
 	int page_offset;
 	 DECLARE_PCI_UNMAP_ADDR(bus)
@@ -250,11 +249,6 @@
 MODULE_PARM_DESC(myri10ge_force_firmware,
 		 "Force firmware to assume aligned completions\n");
 
-static int myri10ge_skb_cross_4k = 0;
-module_param(myri10ge_skb_cross_4k, int, S_IRUGO | S_IWUSR);
-MODULE_PARM_DESC(myri10ge_skb_cross_4k,
-		 "Can a small skb cross a 4KB boundary?\n");
-
 static int myri10ge_initial_mtu = MYRI10GE_MAX_ETHER_MTU - ETH_HLEN;
 module_param(myri10ge_initial_mtu, int, S_IRUGO);
 MODULE_PARM_DESC(myri10ge_initial_mtu, "Initial MTU\n");
@@ -820,148 +814,6 @@
 	mb();
 }
 
-/*
- * Set of routines to get a new receive buffer.  Any buffer which
- * crosses a 4KB boundary must start on a 4KB boundary due to PCIe
- * wdma restrictions. We also try to align any smaller allocation to
- * at least a 16 byte boundary for efficiency.  We assume the linux
- * memory allocator works by powers of 2, and will not return memory
- * smaller than 2KB which crosses a 4KB boundary.  If it does, we fall
- * back to allocating 2x as much space as required.
- *
- * We intend to replace large (>4KB) skb allocations by using
- * pages directly and building a fraglist in the near future.
- */
-
-static inline struct sk_buff *myri10ge_alloc_big(struct net_device *dev,
-						 int bytes)
-{
-	struct sk_buff *skb;
-	unsigned long data, roundup;
-
-	skb = netdev_alloc_skb(dev, bytes + 4096 + MXGEFW_PAD);
-	if (skb == NULL)
-		return NULL;
-
-	/* Correct skb->truesize so that socket buffer
-	 * accounting is not confused the rounding we must
-	 * do to satisfy alignment constraints.
-	 */
-	skb->truesize -= 4096;
-
-	data = (unsigned long)(skb->data);
-	roundup = (-data) & (4095);
-	skb_reserve(skb, roundup);
-	return skb;
-}
-
-/* Allocate 2x as much space as required and use whichever portion
- * does not cross a 4KB boundary */
-static inline struct sk_buff *myri10ge_alloc_small_safe(struct net_device *dev,
-							unsigned int bytes)
-{
-	struct sk_buff *skb;
-	unsigned long data, boundary;
-
-	skb = netdev_alloc_skb(dev, 2 * (bytes + MXGEFW_PAD) - 1);
-	if (unlikely(skb == NULL))
-		return NULL;
-
-	/* Correct skb->truesize so that socket buffer
-	 * accounting is not confused the rounding we must
-	 * do to satisfy alignment constraints.
-	 */
-	skb->truesize -= bytes + MXGEFW_PAD;
-
-	data = (unsigned long)(skb->data);
-	boundary = (data + 4095UL) & ~4095UL;
-	if ((boundary - data) >= (bytes + MXGEFW_PAD))
-		return skb;
-
-	skb_reserve(skb, boundary - data);
-	return skb;
-}
-
-/* Allocate just enough space, and verify that the allocated
- * space does not cross a 4KB boundary */
-static inline struct sk_buff *myri10ge_alloc_small(struct net_device *dev,
-						   int bytes)
-{
-	struct sk_buff *skb;
-	unsigned long roundup, data, end;
-
-	skb = netdev_alloc_skb(dev, bytes + 16 + MXGEFW_PAD);
-	if (unlikely(skb == NULL))
-		return NULL;
-
-	/* Round allocated buffer to 16 byte boundary */
-	data = (unsigned long)(skb->data);
-	roundup = (-data) & 15UL;
-	skb_reserve(skb, roundup);
-	/* Verify that the data buffer does not cross a page boundary */
-	data = (unsigned long)(skb->data);
-	end = data + bytes + MXGEFW_PAD - 1;
-	if (unlikely(((end >> 12) != (data >> 12)) && (data & 4095UL))) {
-		printk(KERN_NOTICE
-		       "myri10ge_alloc_small: small skb crossed 4KB boundary\n");
-		myri10ge_skb_cross_4k = 1;
-		dev_kfree_skb_any(skb);
-		skb = myri10ge_alloc_small_safe(dev, bytes);
-	}
-	return skb;
-}
-
-static inline int
-myri10ge_getbuf(struct myri10ge_rx_buf *rx, struct myri10ge_priv *mgp,
-		int bytes, int idx)
-{
-	struct net_device *dev = mgp->dev;
-	struct pci_dev *pdev = mgp->pdev;
-	struct sk_buff *skb;
-	dma_addr_t bus;
-	int len, retval = 0;
-
-	bytes += VLAN_HLEN;	/* account for 802.1q vlan tag */
-
-	if ((bytes + MXGEFW_PAD) > (4096 - 16) /* linux overhead */ )
-		skb = myri10ge_alloc_big(dev, bytes);
-	else if (myri10ge_skb_cross_4k)
-		skb = myri10ge_alloc_small_safe(dev, bytes);
-	else
-		skb = myri10ge_alloc_small(dev, bytes);
-
-	if (unlikely(skb == NULL)) {
-		rx->alloc_fail++;
-		retval = -ENOBUFS;
-		goto done;
-	}
-
-	/* set len so that it only covers the area we
-	 * need mapped for DMA */
-	len = bytes + MXGEFW_PAD;
-
-	bus = pci_map_single(pdev, skb->data, len, PCI_DMA_FROMDEVICE);
-	rx->info[idx].skb = skb;
-	pci_unmap_addr_set(&rx->info[idx], bus, bus);
-	pci_unmap_len_set(&rx->info[idx], len, len);
-	rx->shadow[idx].addr_low = htonl(MYRI10GE_LOWPART_TO_U32(bus));
-	rx->shadow[idx].addr_high = htonl(MYRI10GE_HIGHPART_TO_U32(bus));
-
-done:
-	/* copy 8 descriptors (64-bytes) to the mcp at a time */
-	if ((idx & 7) == 7) {
-		if (rx->wc_fifo == NULL)
-			myri10ge_submit_8rx(&rx->lanai[idx - 7],
-					    &rx->shadow[idx - 7]);
-		else {
-			mb();
-			myri10ge_pio_copy(rx->wc_fifo,
-					  &rx->shadow[idx - 7], 64);
-		}
-	}
-	return retval;
-}
-
 static inline void myri10ge_vlan_ip_csum(struct sk_buff *skb, __wsum hw_csum)
 {
 	struct vlan_hdr *vh = (struct vlan_hdr *)(skb->data);
@@ -1084,8 +936,8 @@
 				 * page into an skb */
 
 static inline int
-myri10ge_page_rx_done(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
-		      int bytes, int len, __wsum csum)
+myri10ge_rx_done(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
+		 int bytes, int len, __wsum csum)
 {
 	struct sk_buff *skb;
 	struct skb_frag_struct rx_frags[MYRI10GE_MAX_FRAGS_PER_FRAME];
@@ -1148,54 +1000,6 @@
 	return 1;
 }
 
-static inline unsigned long
-myri10ge_rx_done(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
-		 int bytes, int len, __wsum csum)
-{
-	dma_addr_t bus;
-	struct sk_buff *skb;
-	int idx, unmap_len;
-
-	idx = rx->cnt & rx->mask;
-	rx->cnt++;
-
-	/* save a pointer to the received skb */
-	skb = rx->info[idx].skb;
-	bus = pci_unmap_addr(&rx->info[idx], bus);
-	unmap_len = pci_unmap_len(&rx->info[idx], len);
-
-	/* try to replace the received skb */
-	if (myri10ge_getbuf(rx, mgp, bytes, idx)) {
-		/* drop the frame -- the old skbuf is re-cycled */
-		mgp->stats.rx_dropped += 1;
-		return 0;
-	}
-
-	/* unmap the recvd skb */
-	pci_unmap_single(mgp->pdev, bus, unmap_len, PCI_DMA_FROMDEVICE);
-
-	/* mcp implicitly skips 1st bytes so that packet is properly
-	 * aligned */
-	skb_reserve(skb, MXGEFW_PAD);
-
-	/* set the length of the frame */
-	skb_put(skb, len);
-
-	skb->protocol = eth_type_trans(skb, mgp->dev);
-	if (mgp->csum_flag) {
-		if ((skb->protocol == htons(ETH_P_IP)) ||
-		    (skb->protocol == htons(ETH_P_IPV6))) {
-			skb->csum = csum;
-			skb->ip_summed = CHECKSUM_COMPLETE;
-		} else
-			myri10ge_vlan_ip_csum(skb, csum);
-	}
-
-	netif_receive_skb(skb);
-	mgp->dev->last_rx = jiffies;
-	return 1;
-}
-
 static inline void myri10ge_tx_done(struct myri10ge_priv *mgp, int mcp_index)
 {
 	struct pci_dev *pdev = mgp->pdev;
@@ -1264,13 +1068,13 @@
 		rx_done->entry[idx].length = 0;
 		checksum = csum_unfold(rx_done->entry[idx].checksum);
 		if (length <= mgp->small_bytes)
-			rx_ok = myri10ge_page_rx_done(mgp, &mgp->rx_small,
-						      mgp->small_bytes,
-						      length, checksum);
+			rx_ok = myri10ge_rx_done(mgp, &mgp->rx_small,
+						 mgp->small_bytes,
+						 length, checksum);
 		else
-			rx_ok = myri10ge_page_rx_done(mgp, &mgp->rx_big,
-						      mgp->big_bytes,
-						      length, checksum);
+			rx_ok = myri10ge_rx_done(mgp, &mgp->rx_big,
+						 mgp->big_bytes,
+						 length, checksum);
 		rx_packets += rx_ok;
 		rx_bytes += rx_ok * (unsigned long)length;
 		cnt++;


