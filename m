From: Brice Goglin <brice@myri.com>
Subject: [PATCH 2/7] myri10ge: add page-based skb routines
Date: Mon, 11 Dec 2006 11:25:09 +0100
Message-ID: <457D3205.6000203@myri.com>
References: <457D31B2.30505@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:42178 "EHLO
	myri.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762753AbWLKKZ2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Dec 2006 05:25:28 -0500
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
In-Reply-To: <457D31B2.30505@myri.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add physical page skb allocation routines and page based rx_done,
to be used by upcoming patches.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |  190 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 190 insertions(+)

Index: linux-git/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-git.orig/drivers/net/myri10ge/myri10ge.c	2006-12-11 10:52:08.000000000 +0100
+++ linux-git/drivers/net/myri10ge/myri10ge.c	2006-12-11 10:52:26.000000000 +0100
@@ -92,8 +92,14 @@
 #define MYRI10GE_NO_CONFIRM_DATA htonl(0xffffffff)
 #define MYRI10GE_NO_RESPONSE_RESULT 0xffffffff
 
+#define MYRI10GE_ALLOC_ORDER 0
+#define MYRI10GE_ALLOC_SIZE ((1 << MYRI10GE_ALLOC_ORDER) * PAGE_SIZE)
+#define MYRI10GE_MAX_FRAGS_PER_FRAME (MYRI10GE_MAX_ETHER_MTU/MYRI10GE_ALLOC_SIZE + 1)
+
 struct myri10ge_rx_buffer_state {
 	struct sk_buff *skb;
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
@@ -266,6 +278,10 @@
 module_param(myri10ge_debug, int, 0);
 MODULE_PARM_DESC(myri10ge_debug, "Debug level (0=none,...,16=all)");
 
+static int myri10ge_fill_thresh = 256;
+module_param(myri10ge_fill_thresh, int, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(myri10ge_fill_thresh, "Number of empty rx slots allowed\n");
+
 #define MYRI10GE_FW_OFFSET 1024*1024
 #define MYRI10GE_HIGHPART_TO_U32(X) \
 (sizeof (X) == 8) ? ((u32)((u64)(X) >> 32)) : (0)
@@ -958,6 +974,180 @@
 	}
 }
 
+static inline void
+myri10ge_rx_skb_build(struct sk_buff *skb, u8 * va,
+		      struct skb_frag_struct *rx_frags, int len, int hlen)
+{
+	struct skb_frag_struct *skb_frags;
+
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
+}
+
+static void
+myri10ge_alloc_rx_pages(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
+			int bytes, int watchdog)
+{
+	struct page *page;
+	int idx;
+
+	if (unlikely(rx->watchdog_needed && !watchdog))
+		return;
+
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
+		}
+	}
+}
+
+static inline void
+myri10ge_unmap_rx_page(struct pci_dev *pdev,
+		       struct myri10ge_rx_buffer_state *info, int bytes)
+{
+	/* unmap the recvd page if we're the only or last user of it */
+	if (bytes >= MYRI10GE_ALLOC_SIZE / 2 ||
+	    (info->page_offset + 2 * bytes) > MYRI10GE_ALLOC_SIZE) {
+		pci_unmap_page(pdev, (pci_unmap_addr(info, bus)
+				      & ~(MYRI10GE_ALLOC_SIZE - 1)),
+			       MYRI10GE_ALLOC_SIZE, PCI_DMA_FROMDEVICE);
+	}
+}
+
+#define MYRI10GE_HLEN 64	/* The number of bytes to copy from a
+				 * page into an skb */
+
+static inline int
+myri10ge_page_rx_done(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
+		      int bytes, int len, __wsum csum)
+{
+	struct sk_buff *skb;
+	struct skb_frag_struct rx_frags[MYRI10GE_MAX_FRAGS_PER_FRAME];
+	int i, idx, hlen, remainder;
+	struct pci_dev *pdev = mgp->pdev;
+	struct net_device *dev = mgp->dev;
+	u8 *va;
+
+	len += MXGEFW_PAD;
+	idx = rx->cnt & rx->mask;
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
+	}
+
+	hlen = MYRI10GE_HLEN > len ? len : MYRI10GE_HLEN;
+
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
+
+	/* Attach the pages to the skb, and trim off any padding */
+	myri10ge_rx_skb_build(skb, va, rx_frags, len, hlen);
+	if (skb_shinfo(skb)->frags[0].size <= 0) {
+		put_page(skb_shinfo(skb)->frags[0].page);
+		skb_shinfo(skb)->nr_frags = 0;
+	}
+	skb->protocol = eth_type_trans(skb, dev);
+	skb->dev = dev;
+
+	if (mgp->csum_flag) {
+		if ((skb->protocol == htons(ETH_P_IP)) ||
+		    (skb->protocol == htons(ETH_P_IPV6))) {
+			skb->csum = csum;
+			skb->ip_summed = CHECKSUM_COMPLETE;
+		} else
+			myri10ge_vlan_ip_csum(skb, csum);
+	}
+	netif_receive_skb(skb);
+	dev->last_rx = jiffies;
+	return 1;
+}
+
 static inline unsigned long
 myri10ge_rx_done(struct myri10ge_priv *mgp, struct myri10ge_rx_buf *rx,
 		 int bytes, int len, __wsum csum)


