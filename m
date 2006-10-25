From: Brice Goglin <brice@myri.com>
Subject: [PATCH 1/1] myri10ge: use physical pages for skb allocation
Date: Wed, 25 Oct 2006 15:29:38 +0200
Message-ID: <453F66C2.1090900@myri.com>
References: <453F6673.2040002@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:5588 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S965216AbWJYN36 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 09:29:58 -0400
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
In-Reply-To: <453F6673.2040002@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Physical pages are used instead of 16kB contiguous buffers for the
skb frags. And we also put as much fragments as possible in any page
so that we do not have to allocate a page for every fragments.

Signed-off-by: Brice Goglin <brice@myri.com>
Signed-off-by: Andrew J. Gallatin <gallatin@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |  499 ++++++++++++++++++++--------------------
 1 file changed, 254 insertions(+), 245 deletions(-)

Index: linux-rc/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-rc.orig/drivers/net/myri10ge/myri10ge.c	2006-10-25 14:14:59.000000000 +0200
+++ linux-rc/drivers/net/myri10ge/myri10ge.c	2006-10-25 14:15:18.000000000 +0200
@@ -61,6 +61,8 @@
 #include <linux/moduleparam.h>
 #include <linux/io.h>
 #include <net/checksum.h>
+#include <net/ip.h>
+#include <net/tcp.h>
 #include <asm/byteorder.h>
 #include <asm/io.h>
 #include <asm/processor.h>
@@ -71,7 +73,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.0.0"
+#define MYRI10GE_VERSION_STR "1.1.0"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -91,9 +93,13 @@
 
 #define MYRI10GE_NO_CONFIRM_DATA 0xffffffff
 #define MYRI10GE_NO_RESPONSE_RESULT 0xffffffff
+#define MYRI10GE_ALLOC_ORDER 0
+#define MYRI10GE_ALLOC_SIZE ((1 << MYRI10GE_ALLOC_ORDER) * PAGE_SIZE)
+#define MYRI10GE_MAX_FRAGS_PER_FRAME (MYRI10GE_MAX_ETHER_MTU/MYRI10GE_ALLOC_SIZE + 1)
 
 struct myri10ge_rx_buffer_state {
-	struct sk_buff *skb;
+	struct page *page;
+	int page_offset;
 	 DECLARE_PCI_UNMAP_ADDR(bus)
 	 DECLARE_PCI_UNMAP_LEN(len)
 };
@@ -116,9 +122,14 @@
 	u8 __iomem *wc_fifo;	/* w/c rx dma addr fifo address */
 	struct mcp_kreq_ether_recv *shadow;	/* host shadow of recv ring */
 	struct myri10ge_rx_buffer_state *info;
+	struct page *page;
+	dma_addr_t bus;
+	int page_offset;
 	int cnt;
+	int fill_cnt;
 	int alloc_fail;
 	int mask;		/* number of rx slots -1 */
+	int watchdog_needed;
 };
 
 struct myri10ge_tx_buf {
@@ -150,6 +161,7 @@
 	struct myri10ge_rx_buf rx_big;
 	struct myri10ge_rx_done rx_done;
 	int small_bytes;
+	int big_bytes;
 	struct net_device *dev;
 	struct net_device_stats stats;
 	u8 __iomem *sram;
@@ -238,11 +250,6 @@
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
@@ -266,6 +273,10 @@
 module_param(myri10ge_debug, int, 0);
 MODULE_PARM_DESC(myri10ge_debug, "Debug level (0=none,...,16=all)");
 
+static int myri10ge_fill_thresh = 256;
+module_param(myri10ge_fill_thresh, int, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(myri10ge_fill_thresh, "Number of empty rx slots allowed\n");
+
 #define MYRI10GE_FW_OFFSET 1024*1024
 #define MYRI10GE_HIGHPART_TO_U32(X) \
 (sizeof (X) == 8) ? ((u32)((u64)(X) >> 32)) : (0)
@@ -797,194 +808,179 @@
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
+static inline void myri10ge_vlan_ip_csum(struct sk_buff *skb, u16 hw_csum)
 {
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
+	struct vlan_hdr *vh = (struct vlan_hdr *)(skb->data);
 
-	skb_reserve(skb, boundary - data);
-	return skb;
+	if ((skb->protocol == ntohs(ETH_P_8021Q)) &&
+	    (vh->h_vlan_encapsulated_proto == htons(ETH_P_IP) ||
+	     vh->h_vlan_encapsulated_proto == htons(ETH_P_IPV6))) {
+		skb->csum = hw_csum;
+		skb->ip_summed = CHECKSUM_COMPLETE;
+	}
 }
 
-/* Allocate just enough space, and verify that the allocated
- * space does not cross a 4KB boundary */
-static inline struct sk_buff *myri10ge_alloc_small(struct net_device *dev,
-						   int bytes)
+static inline void
+myri10ge_rx_skb_build(struct sk_buff *skb, u8 * va,
+		      struct skb_frag_struct *rx_frags, int len, int hlen)
 {
-	struct sk_buff *skb;
-	unsigned long roundup, data, end;
+	struct skb_frag_struct *skb_frags;
 
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
+	skb->len = skb->data_len = len;
+	skb->truesize = len + sizeof(struct sk_buff);
+	/* attach the page(s) */
+
+	skb_frags = skb_shinfo(skb)->frags;
+	while (len > 0) {
+		memcpy(skb_frags, rx_frags, sizeof(*skb_frags));
+		len -= rx_frags->size;
+		skb_frags++;
+		rx_frags++;
+		skb_shinfo(skb)->nr_frags++;
+	}
+
+	/* pskb_may_pull is not available in irq context, but
+	 * skb_pull() (for ether_pad and eth_type_trans()) requires
+	 * the beginning of the packet in skb_headlen(), move it
+	 * manually */
+	memcpy(skb->data, va, hlen);
+	skb_shinfo(skb)->frags[0].page_offset += hlen;
+	skb_shinfo(skb)->frags[0].size -= hlen;
+	skb->data_len -= hlen;
+	skb->tail += hlen;
+	skb_pull(skb, MXGEFW_PAD);
 }
 
-static inline int
-myri10ge_getbuf(struct myri10ge_rx_buf *rx, struct myri10ge_priv *mgp,
-		int bytes, int idx)
+static void
+myri10ge_alloc_rx_pages(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
+			int bytes, int watchdog)
 {
-	struct net_device *dev = mgp->dev;
-	struct pci_dev *pdev = mgp->pdev;
-	struct sk_buff *skb;
-	dma_addr_t bus;
-	int len, retval = 0;
-
-	bytes += VLAN_HLEN;	/* account for 802.1q vlan tag */
+	struct page *page;
+	int idx;
 
-	if ((bytes + MXGEFW_PAD) > (4096 - 16) /* linux overhead */ )
-		skb = myri10ge_alloc_big(dev, bytes);
-	else if (myri10ge_skb_cross_4k)
-		skb = myri10ge_alloc_small_safe(dev, bytes);
-	else
-		skb = myri10ge_alloc_small(dev, bytes);
+	if (unlikely(rx->watchdog_needed && !watchdog))
+		return;
 
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
+	/* try to refill entire ring */
+	while (rx->fill_cnt != (rx->cnt + rx->mask + 1)) {
+		idx = rx->fill_cnt & rx->mask;
+
+		if ((bytes < MYRI10GE_ALLOC_SIZE / 2) &&
+		    (rx->page_offset + bytes <= MYRI10GE_ALLOC_SIZE)) {
+			/* we can use part of previous page */
+			get_page(rx->page);
+		} else {
+			/* we need a new page */
+			page =
+			    alloc_pages(GFP_ATOMIC | __GFP_COMP,
+					MYRI10GE_ALLOC_ORDER);
+			if (unlikely(page == NULL)) {
+				if (rx->fill_cnt - rx->cnt < 16)
+					rx->watchdog_needed = 1;
+				return;
+			}
+			rx->page = page;
+			rx->page_offset = 0;
+			rx->bus = pci_map_page(mgp->pdev, page, 0,
+					       MYRI10GE_ALLOC_SIZE,
+					       PCI_DMA_FROMDEVICE);
+		}
+		rx->info[idx].page = rx->page;
+		rx->info[idx].page_offset = rx->page_offset;
+		/* note that this is the address of the start of the
+		 * page */
+		pci_unmap_addr_set(&rx->info[idx], bus, rx->bus);
+		rx->shadow[idx].addr_low =
+		    htonl(MYRI10GE_LOWPART_TO_U32(rx->bus) + rx->page_offset);
+		rx->shadow[idx].addr_high =
+		    htonl(MYRI10GE_HIGHPART_TO_U32(rx->bus));
+
+		/* start next packet on a cacheline boundary */
+		rx->page_offset += SKB_DATA_ALIGN(bytes);
+		rx->fill_cnt++;
+
+		/* copy 8 descriptors to the firmware at a time */
+		if ((idx & 7) == 7) {
+			if (rx->wc_fifo == NULL)
+				myri10ge_submit_8rx(&rx->lanai[idx - 7],
+						    &rx->shadow[idx - 7]);
+			else {
+				mb();
+				myri10ge_pio_copy(rx->wc_fifo,
+						  &rx->shadow[idx - 7], 64);
+			}
 		}
 	}
-	return retval;
 }
 
-static inline void myri10ge_vlan_ip_csum(struct sk_buff *skb, u16 hw_csum)
+static inline void
+myri10ge_unmap_rx_page(struct pci_dev *pdev,
+		       struct myri10ge_rx_buffer_state *info, int bytes)
 {
-	struct vlan_hdr *vh = (struct vlan_hdr *)(skb->data);
-
-	if ((skb->protocol == ntohs(ETH_P_8021Q)) &&
-	    (vh->h_vlan_encapsulated_proto == htons(ETH_P_IP) ||
-	     vh->h_vlan_encapsulated_proto == htons(ETH_P_IPV6))) {
-		skb->csum = hw_csum;
-		skb->ip_summed = CHECKSUM_COMPLETE;
+	/* unmap the recvd page if we're the only or last user of it */
+	if (bytes >= MYRI10GE_ALLOC_SIZE / 2 ||
+	    (info->page_offset + 2 * bytes) > MYRI10GE_ALLOC_SIZE) {
+		pci_unmap_page(pdev, (pci_unmap_addr(info, bus)
+				      & ~(MYRI10GE_ALLOC_SIZE - 1)),
+			       MYRI10GE_ALLOC_SIZE, PCI_DMA_FROMDEVICE);
 	}
 }
 
-static inline unsigned long
+#define MYRI10GE_HLEN 64	/* The number of bytes to copy from a
+				 * page into an skb */
+
+static inline int
 myri10ge_rx_done(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
 		 int bytes, int len, int csum)
 {
-	dma_addr_t bus;
 	struct sk_buff *skb;
-	int idx, unmap_len;
+	struct skb_frag_struct rx_frags[MYRI10GE_MAX_FRAGS_PER_FRAME];
+	int i, idx, hlen, remainder;
+	struct pci_dev *pdev = mgp->pdev;
+	struct net_device *dev = mgp->dev;
+	u8 *va;
 
+	len += MXGEFW_PAD;
 	idx = rx->cnt & rx->mask;
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
+	va = page_address(rx->info[idx].page) + rx->info[idx].page_offset;
+	prefetch(va);
+	/* Fill skb_frag_struct(s) with data from our receive */
+	for (i = 0, remainder = len; remainder > 0; i++) {
+		myri10ge_unmap_rx_page(pdev, &rx->info[idx], bytes);
+		rx_frags[i].page = rx->info[idx].page;
+		rx_frags[i].page_offset = rx->info[idx].page_offset;
+		if (remainder < MYRI10GE_ALLOC_SIZE)
+			rx_frags[i].size = remainder;
+		else
+			rx_frags[i].size = MYRI10GE_ALLOC_SIZE;
+		rx->cnt++;
+		idx = rx->cnt & rx->mask;
+		remainder -= MYRI10GE_ALLOC_SIZE;
 	}
 
-	/* unmap the recvd skb */
-	pci_unmap_single(mgp->pdev, bus, unmap_len, PCI_DMA_FROMDEVICE);
+	hlen = MYRI10GE_HLEN > len ? len : MYRI10GE_HLEN;
 
-	/* mcp implicitly skips 1st bytes so that packet is properly
-	 * aligned */
-	skb_reserve(skb, MXGEFW_PAD);
+	/* allocate an skb to attach the page(s) to. */
+
+	skb = netdev_alloc_skb(dev, MYRI10GE_HLEN + 16);
+	if (unlikely(skb == NULL)) {
+		mgp->stats.rx_dropped++;
+		do {
+			i--;
+			put_page(rx_frags[i].page);
+		} while (i != 0);
+		return 0;
+	}
 
-	/* set the length of the frame */
-	skb_put(skb, len);
+	/* Attach the pages to the skb, and trim off any padding */
+	myri10ge_rx_skb_build(skb, va, rx_frags, len, hlen);
+	if (skb_shinfo(skb)->frags[0].size <= 0) {
+		put_page(skb_shinfo(skb)->frags[0].page);
+		skb_shinfo(skb)->nr_frags = 0;
+	}
+	skb->protocol = eth_type_trans(skb, dev);
+	skb->dev = dev;
 
-	skb->protocol = eth_type_trans(skb, mgp->dev);
 	if (mgp->csum_flag) {
 		if ((skb->protocol == ntohs(ETH_P_IP)) ||
 		    (skb->protocol == ntohs(ETH_P_IPV6))) {
@@ -993,9 +989,8 @@
 		} else
 			myri10ge_vlan_ip_csum(skb, ntohs((u16) csum));
 	}
-
 	netif_receive_skb(skb);
-	mgp->dev->last_rx = jiffies;
+	dev->last_rx = jiffies;
 	return 1;
 }
 
@@ -1072,7 +1067,7 @@
 						 length, checksum);
 		else
 			rx_ok = myri10ge_rx_done(mgp, &mgp->rx_big,
-						 mgp->dev->mtu + ETH_HLEN,
+						 mgp->big_bytes,
 						 length, checksum);
 		rx_packets += rx_ok;
 		rx_bytes += rx_ok * (unsigned long)length;
@@ -1087,6 +1082,14 @@
 	rx_done->cnt = cnt;
 	mgp->stats.rx_packets += rx_packets;
 	mgp->stats.rx_bytes += rx_bytes;
+
+	/* restock receive rings if needed */
+	if (mgp->rx_small.fill_cnt - mgp->rx_small.cnt < myri10ge_fill_thresh)
+		myri10ge_alloc_rx_pages(mgp, &mgp->rx_small,
+					mgp->small_bytes + MXGEFW_PAD, 0);
+	if (mgp->rx_big.fill_cnt - mgp->rx_big.cnt < myri10ge_fill_thresh)
+		myri10ge_alloc_rx_pages(mgp, &mgp->rx_big, mgp->big_bytes, 0);
+
 }
 
 static inline void myri10ge_check_statblock(struct myri10ge_priv *mgp)
@@ -1477,56 +1480,48 @@
 		goto abort_with_rx_small_info;
 
 	/* Fill the receive rings */
-
-	for (i = 0; i <= mgp->rx_small.mask; i++) {
-		status = myri10ge_getbuf(&mgp->rx_small, mgp,
-					 mgp->small_bytes, i);
-		if (status) {
-			printk(KERN_ERR
-			       "myri10ge: %s: alloced only %d small bufs\n",
-			       dev->name, i);
-			goto abort_with_rx_small_ring;
-		}
-	}
-
-	for (i = 0; i <= mgp->rx_big.mask; i++) {
-		status =
-		    myri10ge_getbuf(&mgp->rx_big, mgp, dev->mtu + ETH_HLEN, i);
-		if (status) {
-			printk(KERN_ERR
-			       "myri10ge: %s: alloced only %d big bufs\n",
-			       dev->name, i);
-			goto abort_with_rx_big_ring;
-		}
+	mgp->rx_big.cnt = 0;
+	mgp->rx_small.cnt = 0;
+	mgp->rx_big.fill_cnt = 0;
+	mgp->rx_small.fill_cnt = 0;
+	mgp->rx_small.page_offset = MYRI10GE_ALLOC_SIZE;
+	mgp->rx_big.page_offset = MYRI10GE_ALLOC_SIZE;
+	mgp->rx_small.watchdog_needed = 0;
+	mgp->rx_big.watchdog_needed = 0;
+	myri10ge_alloc_rx_pages(mgp, &mgp->rx_small,
+				mgp->small_bytes + MXGEFW_PAD, 0);
+
+	if (mgp->rx_small.fill_cnt < mgp->rx_small.mask + 1) {
+		printk(KERN_ERR "myri10ge: %s: alloced only %d small bufs\n",
+		       dev->name, mgp->rx_small.fill_cnt);
+		goto abort_with_rx_small_ring;
+	}
+
+	myri10ge_alloc_rx_pages(mgp, &mgp->rx_big, mgp->big_bytes, 0);
+	if (mgp->rx_big.fill_cnt < mgp->rx_big.mask + 1) {
+		printk(KERN_ERR "myri10ge: %s: alloced only %d big bufs\n",
+		       dev->name, mgp->rx_big.fill_cnt);
+		goto abort_with_rx_big_ring;
 	}
 
 	return 0;
 
 abort_with_rx_big_ring:
-	for (i = 0; i <= mgp->rx_big.mask; i++) {
-		if (mgp->rx_big.info[i].skb != NULL)
-			dev_kfree_skb_any(mgp->rx_big.info[i].skb);
-		if (pci_unmap_len(&mgp->rx_big.info[i], len))
-			pci_unmap_single(mgp->pdev,
-					 pci_unmap_addr(&mgp->rx_big.info[i],
-							bus),
-					 pci_unmap_len(&mgp->rx_big.info[i],
-						       len),
-					 PCI_DMA_FROMDEVICE);
+	for (i = mgp->rx_big.cnt; i < mgp->rx_big.fill_cnt; i++) {
+		int idx = i & mgp->rx_big.mask;
+		myri10ge_unmap_rx_page(mgp->pdev, &mgp->rx_big.info[idx],
+				       mgp->big_bytes);
+		put_page(mgp->rx_big.info[idx].page);
 	}
 
 abort_with_rx_small_ring:
-	for (i = 0; i <= mgp->rx_small.mask; i++) {
-		if (mgp->rx_small.info[i].skb != NULL)
-			dev_kfree_skb_any(mgp->rx_small.info[i].skb);
-		if (pci_unmap_len(&mgp->rx_small.info[i], len))
-			pci_unmap_single(mgp->pdev,
-					 pci_unmap_addr(&mgp->rx_small.info[i],
-							bus),
-					 pci_unmap_len(&mgp->rx_small.info[i],
-						       len),
-					 PCI_DMA_FROMDEVICE);
+	for (i = mgp->rx_small.cnt; i < mgp->rx_small.fill_cnt; i++) {
+		int idx = i & mgp->rx_small.mask;
+		myri10ge_unmap_rx_page(mgp->pdev, &mgp->rx_small.info[idx],
+				       mgp->small_bytes + MXGEFW_PAD);
+		put_page(mgp->rx_small.info[idx].page);
 	}
+
 	kfree(mgp->rx_big.info);
 
 abort_with_rx_small_info:
@@ -1559,30 +1554,24 @@
 
 	mgp = netdev_priv(dev);
 
-	for (i = 0; i <= mgp->rx_big.mask; i++) {
-		if (mgp->rx_big.info[i].skb != NULL)
-			dev_kfree_skb_any(mgp->rx_big.info[i].skb);
-		if (pci_unmap_len(&mgp->rx_big.info[i], len))
-			pci_unmap_single(mgp->pdev,
-					 pci_unmap_addr(&mgp->rx_big.info[i],
-							bus),
-					 pci_unmap_len(&mgp->rx_big.info[i],
-						       len),
-					 PCI_DMA_FROMDEVICE);
-	}
-
-	for (i = 0; i <= mgp->rx_small.mask; i++) {
-		if (mgp->rx_small.info[i].skb != NULL)
-			dev_kfree_skb_any(mgp->rx_small.info[i].skb);
-		if (pci_unmap_len(&mgp->rx_small.info[i], len))
-			pci_unmap_single(mgp->pdev,
-					 pci_unmap_addr(&mgp->rx_small.info[i],
-							bus),
-					 pci_unmap_len(&mgp->rx_small.info[i],
-						       len),
-					 PCI_DMA_FROMDEVICE);
+	for (i = mgp->rx_big.cnt; i < mgp->rx_big.fill_cnt; i++) {
+		idx = i & mgp->rx_big.mask;
+		if (i == mgp->rx_big.fill_cnt - 1)
+			mgp->rx_big.info[idx].page_offset = MYRI10GE_ALLOC_SIZE;
+		myri10ge_unmap_rx_page(mgp->pdev, &mgp->rx_big.info[idx],
+				       mgp->big_bytes);
+		put_page(mgp->rx_big.info[idx].page);
+	}
+
+	for (i = mgp->rx_small.cnt; i < mgp->rx_small.fill_cnt; i++) {
+		idx = i & mgp->rx_small.mask;
+		if (i == mgp->rx_small.fill_cnt - 1)
+			mgp->rx_small.info[idx].page_offset =
+			    MYRI10GE_ALLOC_SIZE;
+		myri10ge_unmap_rx_page(mgp->pdev, &mgp->rx_small.info[idx],
+				       mgp->small_bytes + MXGEFW_PAD);
+		put_page(mgp->rx_small.info[idx].page);
 	}
-
 	tx = &mgp->tx;
 	while (tx->done != tx->req) {
 		idx = tx->done & tx->mask;
@@ -1650,19 +1639,18 @@
 	 */
 
 	if (dev->mtu <= ETH_DATA_LEN)
-		mgp->small_bytes = 128;	/* enough for a TCP header */
+		/* enough for a TCP header */
+		mgp->small_bytes = (128 > SMP_CACHE_BYTES)
+		    ? (128 - MXGEFW_PAD)
+		    : (SMP_CACHE_BYTES - MXGEFW_PAD);
 	else
-		mgp->small_bytes = ETH_FRAME_LEN;	/* enough for an ETH_DATA_LEN frame */
+		/* enough for an ETH_DATA_LEN frame */
+		mgp->small_bytes = ETH_FRAME_LEN;
 
 	/* Override the small buffer size? */
 	if (myri10ge_small_bytes > 0)
 		mgp->small_bytes = myri10ge_small_bytes;
 
-	/* If the user sets an obscenely small MTU, adjust the small
-	 * bytes down to nearly nothing */
-	if (mgp->small_bytes >= (dev->mtu + ETH_HLEN))
-		mgp->small_bytes = 64;
-
 	/* get the lanai pointers to the send and receive rings */
 
 	status |= myri10ge_send_cmd(mgp, MXGEFW_CMD_GET_SEND_OFFSET, &cmd, 0);
@@ -1698,17 +1686,23 @@
 		mgp->rx_big.wc_fifo = NULL;
 	}
 
-	status = myri10ge_allocate_rings(dev);
-	if (status != 0)
-		goto abort_with_nothing;
-
 	/* Firmware needs the big buff size as a power of 2.  Lie and
 	 * tell him the buffer is larger, because we only use 1
 	 * buffer/pkt, and the mtu will prevent overruns.
 	 */
 	big_pow2 = dev->mtu + ETH_HLEN + MXGEFW_PAD;
-	while ((big_pow2 & (big_pow2 - 1)) != 0)
-		big_pow2++;
+	if (big_pow2 < MYRI10GE_ALLOC_SIZE / 2) {
+		while ((big_pow2 & (big_pow2 - 1)) != 0)
+			big_pow2++;
+		mgp->big_bytes = dev->mtu + ETH_HLEN + MXGEFW_PAD;
+	} else {
+		big_pow2 = MYRI10GE_ALLOC_SIZE;
+		mgp->big_bytes = big_pow2;
+	}
+
+	status = myri10ge_allocate_rings(dev);
+	if (status != 0)
+		goto abort_with_nothing;
 
 	/* now give firmware buffers sizes, and MTU */
 	cmd.data0 = dev->mtu + ETH_HLEN + VLAN_HLEN;
@@ -2691,6 +2685,21 @@
 	struct myri10ge_priv *mgp;
 
 	mgp = (struct myri10ge_priv *)arg;
+
+	if (mgp->rx_small.watchdog_needed) {
+		myri10ge_alloc_rx_pages(mgp, &mgp->rx_small,
+					mgp->small_bytes + MXGEFW_PAD, 1);
+		if (mgp->rx_small.fill_cnt - mgp->rx_small.cnt >=
+		    myri10ge_fill_thresh)
+			mgp->rx_small.watchdog_needed = 0;
+	}
+	if (mgp->rx_big.watchdog_needed) {
+		myri10ge_alloc_rx_pages(mgp, &mgp->rx_big, mgp->big_bytes, 1);
+		if (mgp->rx_big.fill_cnt - mgp->rx_big.cnt >=
+		    myri10ge_fill_thresh)
+			mgp->rx_big.watchdog_needed = 0;
+	}
+
 	if (mgp->tx.req != mgp->tx.done &&
 	    mgp->tx.done == mgp->watchdog_tx_done &&
 	    mgp->watchdog_tx_req != mgp->watchdog_tx_done)


