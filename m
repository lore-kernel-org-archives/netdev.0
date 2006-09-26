From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 5/8] sky2: incremental transmit completion
Date: Tue, 26 Sep 2006 16:14:54 -0700
Message-ID: <20060926161454.20840676@freekitty>
References: <20060926160814.79750148@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:47795 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965147AbWIZXRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 19:17:55 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k8QNHInW026370
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 16:17:20 -0700
Received: from freekitty (freekitty.pdx.osdl.net [10.8.0.54])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k8QNHIT2006577
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 16:17:18 -0700
To: netdev@vger.kernel.org
In-Reply-To: <20060926160814.79750148@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since a transmit can take several control blocks, the old code waited
until the last control block was marked as done. This code processes
the return values incrementally. This makes slots in the tx ring available
and less chance of getting stuck.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |   95 ++++++++++++++++++++++++++---------------------------
 drivers/net/sky2.h |    6 +--
 2 files changed, 50 insertions(+), 51 deletions(-)

--- netdev-2.6.orig/drivers/net/sky2.c	2006-09-25 15:23:16.000000000 -0700
+++ netdev-2.6/drivers/net/sky2.c	2006-09-25 15:23:23.000000000 -0700
@@ -769,9 +769,16 @@
 	struct sky2_tx_le *le = sky2->tx_le + sky2->tx_prod;
 
 	sky2->tx_prod = RING_NEXT(sky2->tx_prod, TX_RING_SIZE);
+	le->ctrl = 0;
 	return le;
 }
 
+static inline struct tx_ring_info *tx_le_re(struct sky2_port *sky2,
+					    struct sky2_tx_le *le)
+{
+	return sky2->tx_ring + (le - sky2->tx_le);
+}
+
 /* Update chip's next pointer */
 static inline void sky2_put_idx(struct sky2_hw *hw, unsigned q, u16 idx)
 {
@@ -786,6 +793,7 @@
 {
 	struct sky2_rx_le *le = sky2->rx_le + sky2->rx_put;
 	sky2->rx_put = RING_NEXT(sky2->rx_put, RX_LE_SIZE);
+	le->ctrl = 0;
 	return le;
 }
 
@@ -805,7 +813,6 @@
 	if (sky2->rx_addr64 != hi) {
 		le = sky2_next_rx(sky2);
 		le->addr = cpu_to_le32(hi);
-		le->ctrl = 0;
 		le->opcode = OP_ADDR64 | HW_OWNER;
 		sky2->rx_addr64 = high32(map + len);
 	}
@@ -813,7 +820,6 @@
 	le = sky2_next_rx(sky2);
 	le->addr = cpu_to_le32((u32) map);
 	le->length = cpu_to_le16(len);
-	le->ctrl = 0;
 	le->opcode = OP_PACKET | HW_OWNER;
 }
 
@@ -877,7 +883,7 @@
 
 	memset(sky2->rx_le, 0, RX_LE_BYTES);
 	for (i = 0; i < sky2->rx_pending; i++) {
-		struct ring_info *re = sky2->rx_ring + i;
+		struct rx_ring_info *re = sky2->rx_ring + i;
 
 		if (re->skb) {
 			pci_unmap_single(sky2->hw->pdev,
@@ -1008,7 +1014,7 @@
 
 	rx_set_checksum(sky2);
 	for (i = 0; i < sky2->rx_pending; i++) {
-		struct ring_info *re = sky2->rx_ring + i;
+		struct rx_ring_info *re = sky2->rx_ring + i;
 
 		re->skb = sky2_alloc_skb(sky2->netdev, sky2->rx_bufsize,
 					 GFP_KERNEL);
@@ -1094,7 +1100,7 @@
 		goto err_out;
 	memset(sky2->rx_le, 0, RX_LE_BYTES);
 
-	sky2->rx_ring = kcalloc(sky2->rx_pending, sizeof(struct ring_info),
+	sky2->rx_ring = kcalloc(sky2->rx_pending, sizeof(struct rx_ring_info),
 				GFP_KERNEL);
 	if (!sky2->rx_ring)
 		goto err_out;
@@ -1241,13 +1247,10 @@
 	mapping = pci_map_single(hw->pdev, skb->data, len, PCI_DMA_TODEVICE);
 	addr64 = high32(mapping);
 
-	re = sky2->tx_ring + sky2->tx_prod;
-
 	/* Send high bits if changed or crosses boundary */
 	if (addr64 != sky2->tx_addr64 || high32(mapping + len) != sky2->tx_addr64) {
 		le = get_tx_le(sky2);
 		le->addr = cpu_to_le32(addr64);
-		le->ctrl = 0;
 		le->opcode = OP_ADDR64 | HW_OWNER;
 		sky2->tx_addr64 = high32(mapping + len);
 	}
@@ -1263,7 +1266,6 @@
 			le = get_tx_le(sky2);
 			le->addr = cpu_to_le32(mss);
 			le->opcode = OP_LRGLEN | HW_OWNER;
-			le->ctrl = 0;
 			sky2->tx_last_mss = mss;
 		}
 	}
@@ -1276,7 +1278,6 @@
 			le = get_tx_le(sky2);
 			le->addr = 0;
 			le->opcode = OP_VLAN|HW_OWNER;
-			le->ctrl = 0;
 		} else
 			le->opcode |= OP_VLAN;
 		le->length = cpu_to_be16(vlan_tx_tag_get(skb));
@@ -1313,13 +1314,13 @@
 	le->ctrl = ctrl;
 	le->opcode = mss ? (OP_LARGESEND | HW_OWNER) : (OP_PACKET | HW_OWNER);
 
-	/* Record the transmit mapping info */
+	re = tx_le_re(sky2, le);
 	re->skb = skb;
 	pci_unmap_addr_set(re, mapaddr, mapping);
+	pci_unmap_len_set(re, maplen, len);
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-		struct tx_ring_info *fre;
+		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
 
 		mapping = pci_map_page(hw->pdev, frag->page, frag->page_offset,
 				       frag->size, PCI_DMA_TODEVICE);
@@ -1338,12 +1339,12 @@
 		le->ctrl = ctrl;
 		le->opcode = OP_BUFFER | HW_OWNER;
 
-		fre = sky2->tx_ring
-			+ RING_NEXT((re - sky2->tx_ring) + i, TX_RING_SIZE);
-		pci_unmap_addr_set(fre, mapaddr, mapping);
+		re = tx_le_re(sky2, le);
+		re->skb = skb;
+		pci_unmap_addr_set(re, mapaddr, mapping);
+		pci_unmap_len_set(re, maplen, frag->size);
 	}
 
-	re->idx = sky2->tx_prod;
 	le->ctrl |= EOP;
 
 	if (tx_avail(sky2) <= MAX_SKB_TX_LE)
@@ -1361,49 +1362,47 @@
  * Free ring elements from starting at tx_cons until "done"
  *
  * NB: the hardware will tell us about partial completion of multi-part
- *     buffers; these are deferred until completion.
+ *     buffers so make sure not to free skb to early.
  */
 static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
 {
 	struct net_device *dev = sky2->netdev;
 	struct pci_dev *pdev = sky2->hw->pdev;
-	u16 nxt, put;
-	unsigned i;
+	unsigned idx;
 
 	BUG_ON(done >= TX_RING_SIZE);
 
-	if (unlikely(netif_msg_tx_done(sky2)))
-		printk(KERN_DEBUG "%s: tx done, up to %u\n",
-		       dev->name, done);
-
-	for (put = sky2->tx_cons; put != done; put = nxt) {
-		struct tx_ring_info *re = sky2->tx_ring + put;
-		struct sk_buff *skb = re->skb;
-
-		nxt = re->idx;
-		BUG_ON(nxt >= TX_RING_SIZE);
-		prefetch(sky2->tx_ring + nxt);
-
-		/* Check for partial status */
-		if (tx_dist(put, done) < tx_dist(put, nxt))
+	for (idx = sky2->tx_cons; idx != done;
+	     idx = RING_NEXT(idx, TX_RING_SIZE)) {
+		struct sky2_tx_le *le = sky2->tx_le + idx;
+		struct tx_ring_info *re = sky2->tx_ring + idx;
+
+		switch(le->opcode & ~HW_OWNER) {
+		case OP_LARGESEND:
+		case OP_PACKET:
+			pci_unmap_single(pdev,
+					 pci_unmap_addr(re, mapaddr),
+					 pci_unmap_len(re, maplen),
+					 PCI_DMA_TODEVICE);
 			break;
-
-		skb = re->skb;
-		pci_unmap_single(pdev, pci_unmap_addr(re, mapaddr),
-				 skb_headlen(skb), PCI_DMA_TODEVICE);
-
-		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
-			struct tx_ring_info *fre;
-			fre = sky2->tx_ring + RING_NEXT(put + i, TX_RING_SIZE);
-			pci_unmap_page(pdev, pci_unmap_addr(fre, mapaddr),
-				       skb_shinfo(skb)->frags[i].size,
+		case OP_BUFFER:
+			pci_unmap_page(pdev, pci_unmap_addr(re, mapaddr),
+				       pci_unmap_len(re, maplen),
 				       PCI_DMA_TODEVICE);
+			break;
+		}
+
+		if (le->ctrl & EOP) {
+			if (unlikely(netif_msg_tx_done(sky2)))
+				printk(KERN_DEBUG "%s: tx done %u\n",
+				       dev->name, idx);
+			dev_kfree_skb(re->skb);
 		}
 
-		dev_kfree_skb(skb);
+		le->opcode = 0;	/* paranoia */
 	}
 
-	sky2->tx_cons = put;
+	sky2->tx_cons = idx;
 	if (tx_avail(sky2) > MAX_SKB_TX_LE + 4)
 		netif_wake_queue(dev);
 }
@@ -1843,7 +1842,7 @@
 				    u16 length, u32 status)
 {
  	struct sky2_port *sky2 = netdev_priv(dev);
-	struct ring_info *re = sky2->rx_ring + sky2->rx_next;
+	struct rx_ring_info *re = sky2->rx_ring + sky2->rx_next;
 	struct sk_buff *skb = NULL;
 
 	if (unlikely(netif_msg_rx_status(sky2)))
@@ -1889,7 +1888,7 @@
 		prefetch(skb->data);
 
 		re->mapaddr = pci_map_single(sky2->hw->pdev, nskb->data,
-					     sky2->rx_bufsize, PCI_DMA_FROMDEVICE);
+					 sky2->rx_bufsize, PCI_DMA_FROMDEVICE);
 	}
 
 	skb_put(skb, length);
--- netdev-2.6.orig/drivers/net/sky2.h	2006-09-25 15:23:02.000000000 -0700
+++ netdev-2.6/drivers/net/sky2.h	2006-09-25 15:23:23.000000000 -0700
@@ -1774,10 +1774,10 @@
 struct tx_ring_info {
 	struct sk_buff	*skb;
 	DECLARE_PCI_UNMAP_ADDR(mapaddr);
-	u16		idx;
+	DECLARE_PCI_UNMAP_ADDR(maplen);
 };
 
-struct ring_info {
+struct rx_ring_info {
 	struct sk_buff	*skb;
 	dma_addr_t	mapaddr;
 };
@@ -1799,7 +1799,7 @@
 	u16		     tx_last_mss;
 	u32		     tx_tcpsum;
 
-	struct ring_info     *rx_ring ____cacheline_aligned_in_smp;
+	struct rx_ring_info  *rx_ring ____cacheline_aligned_in_smp;
 	struct sky2_rx_le    *rx_le;
 	u32		     rx_addr64;
 	u16		     rx_next;		/* next re to check */
