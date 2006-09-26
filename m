From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 7/8] sky2: fragmented receive for large MTU
Date: Tue, 26 Sep 2006 16:15:57 -0700
Message-ID: <20060926161557.02314762@freekitty>
References: <20060926160814.79750148@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:35507 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965142AbWIZXRd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 19:17:33 -0400
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id k8QNHJnW026373
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 16:17:20 -0700
Received: from freekitty (freekitty.pdx.osdl.net [10.8.0.54])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id k8QNHIT3006577
	for <netdev@vger.kernel.org>; Tue, 26 Sep 2006 16:17:18 -0700
To: netdev@vger.kernel.org
In-Reply-To: <20060926160814.79750148@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use hardware support for chained receive to break up large frames
into multiple pages. This avoids having to do a mult-page allocation
that can fail on a busy system due to fragmented memory.

For normal size MTU, this code behaves the same.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 drivers/net/sky2.c |  290 ++++++++++++++++++++++++++++++++++++++---------------
 drivers/net/sky2.h |   10 +
 2 files changed, 219 insertions(+), 81 deletions(-)

--- netdev-2.6.orig/drivers/net/sky2.c	2006-09-25 15:23:25.000000000 -0700
+++ netdev-2.6/drivers/net/sky2.c	2006-09-25 15:23:26.000000000 -0700
@@ -56,13 +56,12 @@
 /*
  * The Yukon II chipset takes 64 bit command blocks (called list elements)
  * that are organized into three (receive, transmit, status) different rings
- * similar to Tigon3. A transmit can require several elements;
- * a receive requires one (or two if using 64 bit dma).
+ * similar to Tigon3.
  */
 
-#define RX_LE_SIZE	    	512
+#define RX_LE_SIZE	    	1024
 #define RX_LE_BYTES		(RX_LE_SIZE*sizeof(struct sky2_rx_le))
-#define RX_MAX_PENDING		(RX_LE_SIZE/2 - 2)
+#define RX_MAX_PENDING		(RX_LE_SIZE/6 - 2)
 #define RX_DEF_PENDING		RX_MAX_PENDING
 #define RX_SKB_ALIGN		8
 #define RX_BUF_WRITE		16
@@ -74,7 +73,6 @@
 
 #define STATUS_RING_SIZE	2048	/* 2 ports * (TX + 2*RX) */
 #define STATUS_LE_BYTES		(STATUS_RING_SIZE*sizeof(struct sky2_status_le))
-#define ETH_JUMBO_MTU		9000
 #define TX_WATCHDOG		(5 * HZ)
 #define NAPI_WEIGHT		64
 #define PHY_RETRIES		1000
@@ -90,7 +88,7 @@
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
-static int copybreak __read_mostly = 256;
+static int copybreak __read_mostly = 128;
 module_param(copybreak, int, 0);
 MODULE_PARM_DESC(copybreak, "Receive copy threshold");
 
@@ -803,12 +801,12 @@
 	return sizeof(a) > sizeof(u32) ? (a >> 16) >> 16 : 0;
 }
 
-/* Build description to hardware about buffer */
-static void sky2_rx_add(struct sky2_port *sky2, dma_addr_t map)
+/* Build description to hardware for one receive segment */
+static void sky2_rx_add(struct sky2_port *sky2,  u8 op,
+			dma_addr_t map, unsigned len)
 {
 	struct sky2_rx_le *le;
 	u32 hi = high32(map);
-	u16 len = sky2->rx_bufsize;
 
 	if (sky2->rx_addr64 != hi) {
 		le = sky2_next_rx(sky2);
@@ -820,10 +818,53 @@
 	le = sky2_next_rx(sky2);
 	le->addr = cpu_to_le32((u32) map);
 	le->length = cpu_to_le16(len);
-	le->opcode = OP_PACKET | HW_OWNER;
+	le->opcode = op | HW_OWNER;
+}
+
+/* Build description to hardware for one possibly fragmented skb */
+static void sky2_rx_submit(struct sky2_port *sky2,
+			   const struct rx_ring_info *re)
+{
+	int i;
+
+	sky2_rx_add(sky2, OP_PACKET, re->data_addr, sky2->rx_data_size);
+
+	for (i = 0; i < skb_shinfo(re->skb)->nr_frags; i++)
+		sky2_rx_add(sky2, OP_BUFFER, re->frag_addr[i], PAGE_SIZE);
 }
 
 
+static void sky2_rx_map_skb(struct pci_dev *pdev, struct rx_ring_info *re,
+			    unsigned size)
+{
+	struct sk_buff *skb = re->skb;
+	int i;
+
+	re->data_addr = pci_map_single(pdev, skb->data, size, PCI_DMA_FROMDEVICE);
+	pci_unmap_len_set(re, data_size, size);
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
+		re->frag_addr[i] = pci_map_page(pdev,
+						skb_shinfo(skb)->frags[i].page,
+						skb_shinfo(skb)->frags[i].page_offset,
+						skb_shinfo(skb)->frags[i].size,
+						PCI_DMA_FROMDEVICE);
+}
+
+static void sky2_rx_unmap_skb(struct pci_dev *pdev, struct rx_ring_info *re)
+{
+	struct sk_buff *skb = re->skb;
+	int i;
+
+	pci_unmap_single(pdev, re->data_addr, pci_unmap_len(re, data_size),
+			 PCI_DMA_FROMDEVICE);
+
+	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++)
+		pci_unmap_page(pdev, re->frag_addr[i],
+			       skb_shinfo(skb)->frags[i].size,
+			       PCI_DMA_FROMDEVICE);
+}
+
 /* Tell chip where to start receive checksum.
  * Actually has two checksums, but set both same to avoid possible byte
  * order problems.
@@ -886,9 +927,7 @@
 		struct rx_ring_info *re = sky2->rx_ring + i;
 
 		if (re->skb) {
-			pci_unmap_single(sky2->hw->pdev,
-					 re->mapaddr, sky2->rx_bufsize,
-					 PCI_DMA_FROMDEVICE);
+			sky2_rx_unmap_skb(sky2->hw->pdev, re);
 			kfree_skb(re->skb);
 			re->skb = NULL;
 		}
@@ -969,38 +1008,57 @@
 #endif
 
 /*
+ * Allocate an skb for receiving. If the MTU is large enough
+ * make the skb non-linear with a fragment list of pages.
+ *
  * It appears the hardware has a bug in the FIFO logic that
  * cause it to hang if the FIFO gets overrun and the receive buffer
  * is not 64 byte aligned. The buffer returned from netdev_alloc_skb is
  * aligned except if slab debugging is enabled.
  */
-static inline struct sk_buff *sky2_alloc_skb(struct net_device *dev,
-					     unsigned int length,
-					     gfp_t gfp_mask)
+static struct sk_buff *sky2_rx_alloc(struct sky2_port *sky2)
 {
 	struct sk_buff *skb;
+	unsigned long p;
+	int i;
 
-	skb = __netdev_alloc_skb(dev, length + RX_SKB_ALIGN, gfp_mask);
-	if (likely(skb)) {
-		unsigned long p	= (unsigned long) skb->data;
-		skb_reserve(skb, ALIGN(p, RX_SKB_ALIGN) - p);
+	skb = netdev_alloc_skb(sky2->netdev, sky2->rx_data_size + RX_SKB_ALIGN);
+	if (!skb)
+		goto nomem;
+
+	p = (unsigned long) skb->data;
+	skb_reserve(skb, ALIGN(p, RX_SKB_ALIGN) - p);
+
+	for (i = 0; i < sky2->rx_nfrags; i++) {
+		struct page *page = alloc_page(GFP_ATOMIC);
+
+		if (!page)
+			goto free_partial;
+		skb_fill_page_desc(skb, i, page, 0, PAGE_SIZE);
 	}
 
 	return skb;
+free_partial:
+	kfree_skb(skb);
+nomem:
+	return NULL;
 }
 
 /*
  * Allocate and setup receiver buffer pool.
- * In case of 64 bit dma, there are 2X as many list elements
- * available as ring entries
- * and need to reserve one list element so we don't wrap around.
+ * Normal case this ends up creating one list element for skb
+ * in the receive ring. Worst case if using large MTU and each
+ * allocation falls on a different 64 bit region, that results
+ * in 6 list elements per ring entry.
+ * One element is used for checksum enable/disable, and one
+ * extra to avoid wrap.
  */
 static int sky2_rx_start(struct sky2_port *sky2)
 {
 	struct sky2_hw *hw = sky2->hw;
+	struct rx_ring_info *re;
 	unsigned rxq = rxqaddr[sky2->port];
-	int i;
-	unsigned thresh;
+	unsigned i, size, space, thresh;
 
 	sky2->rx_put = sky2->rx_next = 0;
 	sky2_qset(hw, rxq);
@@ -1013,27 +1071,56 @@
 	sky2_prefetch_init(hw, rxq, sky2->rx_le_map, RX_LE_SIZE - 1);
 
 	rx_set_checksum(sky2);
+
+	/* Space needed for frame data + headers rounded up */
+	size = ALIGN(sky2->netdev->mtu + ETH_HLEN + VLAN_HLEN, 8)
+		+ 8;
+
+	/* Stopping point for hardware truncation */
+	thresh = (size - 8) / sizeof(u32);
+
+	/* Account for overhead of skb - to avoid order > 0 allocation */
+	space = SKB_DATA_ALIGN(size) + NET_SKB_PAD
+		+ sizeof(struct skb_shared_info);
+
+	sky2->rx_nfrags = space >> PAGE_SHIFT;
+	BUG_ON(sky2->rx_nfrags > ARRAY_SIZE(re->frag_addr));
+
+	if (sky2->rx_nfrags != 0) {
+		/* Compute residue after pages */
+		space = sky2->rx_nfrags << PAGE_SHIFT;
+
+		if (space < size)
+			size -= space;
+		else
+			size = 0;
+
+		/* Optimize to handle small packets and headers */
+		if (size < copybreak)
+			size = copybreak;
+		if (size < ETH_HLEN)
+			size = ETH_HLEN;
+	}
+	sky2->rx_data_size = size;
+
+	/* Fill Rx ring */
 	for (i = 0; i < sky2->rx_pending; i++) {
-		struct rx_ring_info *re = sky2->rx_ring + i;
+		re = sky2->rx_ring + i;
 
-		re->skb = sky2_alloc_skb(sky2->netdev, sky2->rx_bufsize,
-					 GFP_KERNEL);
+		re->skb = sky2_rx_alloc(sky2);
 		if (!re->skb)
 			goto nomem;
 
-		re->mapaddr = pci_map_single(hw->pdev, re->skb->data,
-					     sky2->rx_bufsize, PCI_DMA_FROMDEVICE);
-		sky2_rx_add(sky2, re->mapaddr);
+		sky2_rx_map_skb(hw->pdev, re, sky2->rx_data_size);
+		sky2_rx_submit(sky2, re);
 	}
 
-
 	/*
 	 * The receiver hangs if it receives frames larger than the
 	 * packet buffer. As a workaround, truncate oversize frames, but
 	 * the register is limited to 9 bits, so if you do frames > 2052
 	 * you better get the MTU right!
 	 */
-	thresh = (sky2->rx_bufsize - 8) / sizeof(u32);
 	if (thresh > 0x1ff)
 		sky2_write32(hw, SK_REG(sky2->port, RX_GMF_CTRL_T), RX_TRUNC_OFF);
 	else {
@@ -1041,7 +1128,6 @@
 		sky2_write32(hw, SK_REG(sky2->port, RX_GMF_CTRL_T), RX_TRUNC_ON);
 	}
 
-
 	/* Tell chip about available buffers */
 	sky2_write16(hw, Y2_QADDR(rxq, PREF_UNIT_PUT_IDX), sky2->rx_put);
 	return 0;
@@ -1743,15 +1829,6 @@
 	}
 }
 
-
-/* Want receive buffer size to be multiple of 64 bits
- * and incl room for vlan and truncation
- */
-static inline unsigned sky2_buf_size(int mtu)
-{
-	return ALIGN(mtu + ETH_HLEN + VLAN_HLEN, 8) + 8;
-}
-
 static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 {
 	struct sky2_port *sky2 = netdev_priv(dev);
@@ -1786,7 +1863,7 @@
 	sky2_rx_clean(sky2);
 
 	dev->mtu = new_mtu;
-	sky2->rx_bufsize = sky2_buf_size(new_mtu);
+
 	mode = DATA_BLIND_VAL(DATA_BLIND_DEF) |
 		GM_SMOD_VLAN_ENA | IPG_DATA_VAL(IPG_DATA_DEF);
 
@@ -1812,9 +1889,93 @@
 	return err;
 }
 
+/* For small just reuse existing skb for next receive */
+static struct sk_buff *receive_copy(struct sky2_port *sky2,
+				    const struct rx_ring_info *re,
+				    unsigned length)
+{
+	struct sk_buff *skb;
+
+	skb = netdev_alloc_skb(sky2->netdev, length + 2);
+	if (likely(skb)) {
+		skb_reserve(skb, 2);
+		pci_dma_sync_single_for_cpu(sky2->hw->pdev, re->data_addr,
+					    length, PCI_DMA_FROMDEVICE);
+		memcpy(skb->data, re->skb->data, length);
+		skb->ip_summed = re->skb->ip_summed;
+		skb->csum = re->skb->csum;
+		pci_dma_sync_single_for_device(sky2->hw->pdev, re->data_addr,
+					       length, PCI_DMA_FROMDEVICE);
+		re->skb->ip_summed = CHECKSUM_NONE;
+		__skb_put(skb, length);
+	}
+	return skb;
+}
+
+/* Adjust length of skb with fragments to match received data */
+static void skb_put_frags(struct sk_buff *skb, unsigned int hdr_space,
+			  unsigned int length)
+{
+	int i, num_frags;
+	unsigned int size;
+
+	/* put header into skb */
+	size = min(length, hdr_space);
+	skb->tail += size;
+	skb->len += size;
+	length -= size;
+
+	num_frags = skb_shinfo(skb)->nr_frags;
+	for (i = 0; i < num_frags; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+		if (length == 0) {
+			/* don't need this page */
+			__free_page(frag->page);
+			--skb_shinfo(skb)->nr_frags;
+		} else {
+			size = min(length, (unsigned) PAGE_SIZE);
+
+			frag->size = size;
+			skb->data_len += size;
+			skb->truesize += size;
+			skb->len += size;
+			length -= size;
+		}
+	}
+}
+
+/* Normal packet - take skb from ring element and put in a new one  */
+static struct sk_buff *receive_new(struct sky2_port *sky2,
+				   struct rx_ring_info *re,
+				   unsigned int length)
+{
+	struct sk_buff *skb, *nskb;
+	unsigned hdr_space = sky2->rx_data_size;
+
+	pr_debug(PFX "receive new length=%d\n", length);
+
+	/* Don't be tricky about reusing pages (yet) */
+	nskb = sky2_rx_alloc(sky2);
+	if (unlikely(!nskb))
+		return NULL;
+
+	skb = re->skb;
+	sky2_rx_unmap_skb(sky2->hw->pdev, re);
+
+	prefetch(skb->data);
+	re->skb = nskb;
+	sky2_rx_map_skb(sky2->hw->pdev, re, hdr_space);
+
+	if (skb_shinfo(skb)->nr_frags)
+		skb_put_frags(skb, hdr_space, length);
+	else
+		skb_put(skb, hdr_space);
+	return skb;
+}
+
 /*
  * Receive one packet.
- * For small packets or errors, just reuse existing skb.
  * For larger packets, get new buffer.
  */
 static struct sk_buff *sky2_receive(struct net_device *dev,
@@ -1840,40 +2001,12 @@
 	if (length > dev->mtu + ETH_HLEN)
 		goto oversize;
 
-	if (length < copybreak) {
-		skb = netdev_alloc_skb(dev, length + 2);
-		if (!skb)
-			goto resubmit;
-
-		skb_reserve(skb, 2);
-		pci_dma_sync_single_for_cpu(sky2->hw->pdev, re->mapaddr,
-					    length, PCI_DMA_FROMDEVICE);
-		memcpy(skb->data, re->skb->data, length);
-		skb->ip_summed = re->skb->ip_summed;
-		skb->csum = re->skb->csum;
-		pci_dma_sync_single_for_device(sky2->hw->pdev, re->mapaddr,
-					       length, PCI_DMA_FROMDEVICE);
-	} else {
-		struct sk_buff *nskb;
-
-		nskb = sky2_alloc_skb(dev, sky2->rx_bufsize, GFP_ATOMIC);
-		if (!nskb)
-			goto resubmit;
-
-		skb = re->skb;
-		re->skb = nskb;
-		pci_unmap_single(sky2->hw->pdev, re->mapaddr,
-				 sky2->rx_bufsize, PCI_DMA_FROMDEVICE);
-		prefetch(skb->data);
-
-		re->mapaddr = pci_map_single(sky2->hw->pdev, nskb->data,
-					 sky2->rx_bufsize, PCI_DMA_FROMDEVICE);
-	}
-
-	skb_put(skb, length);
+	if (length < copybreak)
+		skb = receive_copy(sky2, re, length);
+	else
+		skb = receive_new(sky2, re, length);
 resubmit:
-	re->skb->ip_summed = CHECKSUM_NONE;
-	sky2_rx_add(sky2, re->mapaddr);
+	sky2_rx_submit(sky2, re);
 
 	return skb;
 
@@ -3125,7 +3258,6 @@
 	spin_lock_init(&sky2->phy_lock);
 	sky2->tx_pending = TX_DEF_PENDING;
 	sky2->rx_pending = RX_DEF_PENDING;
-	sky2->rx_bufsize = sky2_buf_size(ETH_DATA_LEN);
 
 	hw->dev[port] = dev;
 
--- netdev-2.6.orig/drivers/net/sky2.h	2006-09-25 15:23:25.000000000 -0700
+++ netdev-2.6/drivers/net/sky2.h	2006-09-25 15:23:26.000000000 -0700
@@ -4,6 +4,8 @@
 #ifndef _SKY2_H
 #define _SKY2_H
 
+#define ETH_JUMBO_MTU		9000	/* Maximum MTU supported */
+
 /* PCI device specific config registers */
 enum {
 	PCI_DEV_REG1	= 0x40,
@@ -1779,7 +1781,9 @@
 
 struct rx_ring_info {
 	struct sk_buff	*skb;
-	dma_addr_t	mapaddr;
+	dma_addr_t	data_addr;
+	DECLARE_PCI_UNMAP_ADDR(data_size);
+	dma_addr_t	frag_addr[ETH_JUMBO_MTU >> PAGE_SHIFT];
 };
 
 struct sky2_port {
@@ -1804,7 +1808,9 @@
 	u16		     rx_next;		/* next re to check */
 	u16		     rx_put;		/* next le index to use */
 	u16		     rx_pending;
-	u16		     rx_bufsize;
+	u16		     rx_data_size;
+	u16		     rx_nfrags;
+
 #ifdef SKY2_VLAN_TAG_USED
 	u16		     rx_tag;
 	struct vlan_group    *vlgrp;
