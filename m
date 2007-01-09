From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 2/12] forcedeth: ring access
Date: Tue, 09 Jan 2007 13:30:07 -0500
Message-ID: <45A3DF2F.10202@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010902000107090908060002"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate02.nvidia.com ([216.228.112.143]:2334 "EHLO
	HQEMGATE02.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932402AbXAIVXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 16:23:46 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010902000107090908060002
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch modifys ring access by using pointers. This avoids computing 
the current index and avoids accessing the base address of the rings.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------010902000107090908060002
Content-Type: text/plain;
 name="patch-ring-pointers"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-ring-pointers"

--- orig/drivers/net/forcedeth.c	2007-01-08 13:31:01.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-01-08 13:30:55.000000000 -0500
@@ -691,6 +691,12 @@
 	{ 0,0 }
 };
 
+struct nv_skb_map {
+	struct sk_buff *skb;
+	dma_addr_t dma;
+	unsigned int dma_len;
+};
+
 /*
  * SMP locking:
  * All hardware access under dev->priv->lock, except the performance
@@ -741,10 +747,12 @@
 	/* rx specific fields.
 	 * Locking: Within irq hander or disable_irq+spin_lock(&np->lock);
 	 */
+	union ring_type get_rx, put_rx, first_rx, last_rx;
+	struct nv_skb_map *get_rx_ctx, *put_rx_ctx;
+	struct nv_skb_map *first_rx_ctx, *last_rx_ctx;
+	struct nv_skb_map *rx_skb;
+
 	union ring_type rx_ring;
-	unsigned int cur_rx, refill_rx;
-	struct sk_buff **rx_skbuff;
-	dma_addr_t *rx_dma;
 	unsigned int rx_buf_sz;
 	unsigned int pkt_limit;
 	struct timer_list oom_kick;
@@ -761,11 +769,12 @@
 	/*
 	 * tx specific fields.
 	 */
+	union ring_type get_tx, put_tx, first_tx, last_tx;
+	struct nv_skb_map *get_tx_ctx, *put_tx_ctx;
+	struct nv_skb_map *first_tx_ctx, *last_tx_ctx;
+	struct nv_skb_map *tx_skb;
+
 	union ring_type tx_ring;
-	unsigned int next_tx, nic_tx;
-	struct sk_buff **tx_skbuff;
-	dma_addr_t *tx_dma;
-	unsigned int *tx_dma_len;
 	u32 tx_flags;
 	int tx_ring_size;
 	int tx_limit_start;
@@ -921,16 +930,10 @@
 			pci_free_consistent(np->pci_dev, sizeof(struct ring_desc_ex) * (np->rx_ring_size + np->tx_ring_size),
 					    np->rx_ring.ex, np->ring_addr);
 	}
-	if (np->rx_skbuff)
-		kfree(np->rx_skbuff);
-	if (np->rx_dma)
-		kfree(np->rx_dma);
-	if (np->tx_skbuff)
-		kfree(np->tx_skbuff);
-	if (np->tx_dma)
-		kfree(np->tx_dma);
-	if (np->tx_dma_len)
-		kfree(np->tx_dma_len);
+	if (np->rx_skb)
+		kfree(np->rx_skb);
+	if (np->tx_skb)
+		kfree(np->tx_skb);
 }
 
 static int using_multi_irqs(struct net_device *dev)
@@ -1304,43 +1307,60 @@
 static int nv_alloc_rx(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
-	unsigned int refill_rx = np->refill_rx;
-	int nr;
+	union ring_type less_rx;
 
-	while (np->cur_rx != refill_rx) {
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+		less_rx.orig = np->get_rx.orig;
+		if (less_rx.orig-- == np->first_rx.orig)
+			less_rx.orig = np->last_rx.orig;
+	} else {
+		less_rx.ex = np->get_rx.ex;
+		if (less_rx.ex-- == np->first_rx.ex)
+			less_rx.ex = np->last_rx.ex;
+	}
+
+	while (1) {
 		struct sk_buff *skb;
 
-		nr = refill_rx % np->rx_ring_size;
-		if (np->rx_skbuff[nr] == NULL) {
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+			if (np->put_rx.orig == less_rx.orig)
+				break;
+		} else {
+			if (np->put_rx.ex == less_rx.ex)
+				break;
+		}
+
+		if (np->put_rx_ctx->skb == NULL) {
 
 			skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
 			if (!skb)
-				break;
+				return 1;
 
 			skb->dev = dev;
-			np->rx_skbuff[nr] = skb;
+			np->put_rx_ctx->skb = skb;
 		} else {
-			skb = np->rx_skbuff[nr];
+			skb = np->put_rx_ctx->skb;
 		}
-		np->rx_dma[nr] = pci_map_single(np->pci_dev, skb->data,
+		np->put_rx_ctx->dma = pci_map_single(np->pci_dev, skb->data,
 					skb->end-skb->data, PCI_DMA_FROMDEVICE);
+		np->put_rx_ctx->dma_len = skb->end-skb->data;
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-			np->rx_ring.orig[nr].buf = cpu_to_le32(np->rx_dma[nr]);
+			np->put_rx.orig->buf = cpu_to_le32(np->put_rx_ctx->dma);
 			wmb();
-			np->rx_ring.orig[nr].flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX_AVAIL);
+			np->put_rx.orig->flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX_AVAIL);
+			if (np->put_rx.orig++ == np->last_rx.orig)
+				np->put_rx.orig = np->first_rx.orig;
 		} else {
-			np->rx_ring.ex[nr].bufhigh = cpu_to_le64(np->rx_dma[nr]) >> 32;
-			np->rx_ring.ex[nr].buflow = cpu_to_le64(np->rx_dma[nr]) & 0x0FFFFFFFF;
+			np->put_rx.ex->bufhigh = cpu_to_le64(np->put_rx_ctx->dma) >> 32;
+			np->put_rx.ex->buflow = cpu_to_le64(np->put_rx_ctx->dma) & 0x0FFFFFFFF;
 			wmb();
-			np->rx_ring.ex[nr].flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX2_AVAIL);
+			np->put_rx.ex->flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX2_AVAIL);
+			if (np->put_rx.ex++ == np->last_rx.ex)
+				np->put_rx.ex = np->first_rx.ex;
 		}
-		dprintk(KERN_DEBUG "%s: nv_alloc_rx: Packet %d marked as Available\n",
-					dev->name, refill_rx);
-		refill_rx++;
+		if (np->put_rx_ctx++ == np->last_rx_ctx)
+			np->put_rx_ctx = np->first_rx_ctx;
 	}
-	np->refill_rx = refill_rx;
-	if (np->cur_rx - refill_rx == np->rx_ring_size)
-		return 1;
 	return 0;
 }
 
@@ -1388,29 +1408,53 @@
 {
 	struct fe_priv *np = netdev_priv(dev);
 	int i;
+	np->get_rx = np->put_rx = np->first_rx = np->rx_ring;
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		np->last_rx.orig = &np->rx_ring.orig[np->rx_ring_size-1];
+	else
+		np->last_rx.ex = &np->rx_ring.ex[np->rx_ring_size-1];
+	np->get_rx_ctx = np->put_rx_ctx = np->first_rx_ctx = np->rx_skb;
+	np->last_rx_ctx = &np->rx_skb[np->rx_ring_size-1];
 
-	np->cur_rx = np->rx_ring_size;
-	np->refill_rx = 0;
-	for (i = 0; i < np->rx_ring_size; i++)
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+	for (i = 0; i < np->rx_ring_size; i++) {
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
 			np->rx_ring.orig[i].flaglen = 0;
-	        else
+			np->rx_ring.orig[i].buf = 0;
+		} else {
 			np->rx_ring.ex[i].flaglen = 0;
+			np->rx_ring.ex[i].txvlan = 0;
+			np->rx_ring.ex[i].bufhigh = 0;
+			np->rx_ring.ex[i].buflow = 0;
+		}
+		np->rx_skb[i].skb = NULL;
+		np->rx_skb[i].dma = 0;
+	}
 }
 
 static void nv_init_tx(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
 	int i;
+	np->get_tx = np->put_tx = np->first_tx = np->tx_ring;
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		np->last_tx.orig = &np->tx_ring.orig[np->tx_ring_size-1];
+	else
+		np->last_tx.ex = &np->tx_ring.ex[np->tx_ring_size-1];
+	np->get_tx_ctx = np->put_tx_ctx = np->first_tx_ctx = np->tx_skb;
+	np->last_tx_ctx = &np->tx_skb[np->tx_ring_size-1];
 
-	np->next_tx = np->nic_tx = 0;
 	for (i = 0; i < np->tx_ring_size; i++) {
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
 			np->tx_ring.orig[i].flaglen = 0;
-	        else
+			np->tx_ring.orig[i].buf = 0;
+		} else {
 			np->tx_ring.ex[i].flaglen = 0;
-		np->tx_skbuff[i] = NULL;
-		np->tx_dma[i] = 0;
+			np->tx_ring.ex[i].txvlan = 0;
+			np->tx_ring.ex[i].bufhigh = 0;
+			np->tx_ring.ex[i].buflow = 0;
+		}
+		np->tx_skb[i].skb = NULL;
+		np->tx_skb[i].dma = 0;
 	}
 }
 
@@ -1421,23 +1465,19 @@
 	return nv_alloc_rx(dev);
 }
 
-static int nv_release_txskb(struct net_device *dev, unsigned int skbnr)
+static int nv_release_txskb(struct net_device *dev, struct nv_skb_map* tx_skb)
 {
 	struct fe_priv *np = netdev_priv(dev);
 
-	dprintk(KERN_INFO "%s: nv_release_txskb for skbnr %d\n",
-		dev->name, skbnr);
-
-	if (np->tx_dma[skbnr]) {
-		pci_unmap_page(np->pci_dev, np->tx_dma[skbnr],
-			       np->tx_dma_len[skbnr],
+	if (tx_skb->dma) {
+		pci_unmap_page(np->pci_dev, tx_skb->dma,
+			       tx_skb->dma_len,
 			       PCI_DMA_TODEVICE);
-		np->tx_dma[skbnr] = 0;
+		tx_skb->dma = 0;
 	}
-
-	if (np->tx_skbuff[skbnr]) {
-		dev_kfree_skb_any(np->tx_skbuff[skbnr]);
-		np->tx_skbuff[skbnr] = NULL;
+	if (tx_skb->skb) {
+		dev_kfree_skb_any(tx_skb->skb);
+		tx_skb->skb = NULL;
 		return 1;
 	} else {
 		return 0;
@@ -1450,11 +1490,16 @@
 	unsigned int i;
 
 	for (i = 0; i < np->tx_ring_size; i++) {
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
 			np->tx_ring.orig[i].flaglen = 0;
-		else
+			np->tx_ring.orig[i].buf = 0;
+		} else {
 			np->tx_ring.ex[i].flaglen = 0;
-		if (nv_release_txskb(dev, i))
+			np->tx_ring.ex[i].txvlan = 0;
+			np->tx_ring.ex[i].bufhigh = 0;
+			np->tx_ring.ex[i].buflow = 0;
+		}
+		if (nv_release_txskb(dev, &np->tx_skb[i]))
 			np->stats.tx_dropped++;
 	}
 }
@@ -1463,18 +1508,24 @@
 {
 	struct fe_priv *np = netdev_priv(dev);
 	int i;
+
 	for (i = 0; i < np->rx_ring_size; i++) {
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
 			np->rx_ring.orig[i].flaglen = 0;
-		else
+			np->rx_ring.orig[i].buf = 0;
+		} else {
 			np->rx_ring.ex[i].flaglen = 0;
+			np->rx_ring.ex[i].txvlan = 0;
+			np->rx_ring.ex[i].bufhigh = 0;
+			np->rx_ring.ex[i].buflow = 0;
+		}
 		wmb();
-		if (np->rx_skbuff[i]) {
-			pci_unmap_single(np->pci_dev, np->rx_dma[i],
-						np->rx_skbuff[i]->end-np->rx_skbuff[i]->data,
+		if (np->rx_skb[i].skb) {
+			pci_unmap_single(np->pci_dev, np->rx_skb[i].dma,
+						np->rx_skb[i].skb->end-np->rx_skb[i].skb->data,
 						PCI_DMA_FROMDEVICE);
-			dev_kfree_skb(np->rx_skbuff[i]);
-			np->rx_skbuff[i] = NULL;
+			dev_kfree_skb(np->rx_skb[i].skb);
+			np->rx_skb[i].skb = NULL;
 		}
 	}
 }
@@ -1485,6 +1536,11 @@
 	nv_drain_rx(dev);
 }
 
+static inline u32 nv_get_empty_tx_slots(struct fe_priv *np)
+{
+	return (u32)(np->tx_ring_size - ((np->tx_ring_size + (np->put_tx_ctx - np->get_tx_ctx)) % np->tx_ring_size));
+}
+
 /*
  * nv_start_xmit: dev->hard_start_xmit function
  * Called with netif_tx_lock held.
@@ -1495,14 +1551,17 @@
 	u32 tx_flags = 0;
 	u32 tx_flags_extra = (np->desc_ver == DESC_VER_1 ? NV_TX_LASTPACKET : NV_TX2_LASTPACKET);
 	unsigned int fragments = skb_shinfo(skb)->nr_frags;
-	unsigned int nr = (np->next_tx - 1) % np->tx_ring_size;
-	unsigned int start_nr = np->next_tx % np->tx_ring_size;
 	unsigned int i;
 	u32 offset = 0;
 	u32 bcnt;
 	u32 size = skb->len-skb->data_len;
 	u32 entries = (size >> NV_TX2_TSO_MAX_SHIFT) + ((size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
+	u32 empty_slots;
 	u32 tx_flags_vlan = 0;
+	union ring_type put_tx;
+	union ring_type start_tx;
+	union ring_type prev_tx;
+	struct nv_skb_map* prev_tx_ctx;
 
 	/* add fragments to entries count */
 	for (i = 0; i < fragments; i++) {
@@ -1512,32 +1571,46 @@
 
 	spin_lock_irq(&np->lock);
 
-	if ((np->next_tx - np->nic_tx + entries - 1) > np->tx_limit_stop) {
+	empty_slots = nv_get_empty_tx_slots(np);
+	if ((empty_slots - np->tx_limit_stop) <= entries) {
 		spin_unlock_irq(&np->lock);
 		netif_stop_queue(dev);
 		return NETDEV_TX_BUSY;
 	}
 
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		start_tx.orig = put_tx.orig = np->put_tx.orig;
+	else
+		start_tx.ex = put_tx.ex = np->put_tx.ex;
+
 	/* setup the header buffer */
 	do {
+		prev_tx = put_tx;
+		prev_tx_ctx = np->put_tx_ctx;
 		bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
-		nr = (nr + 1) % np->tx_ring_size;
-
-		np->tx_dma[nr] = pci_map_single(np->pci_dev, skb->data + offset, bcnt,
+		np->put_tx_ctx->dma = pci_map_single(np->pci_dev, skb->data + offset, bcnt,
 						PCI_DMA_TODEVICE);
-		np->tx_dma_len[nr] = bcnt;
-
+		np->put_tx_ctx->dma_len = bcnt;
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-			np->tx_ring.orig[nr].buf = cpu_to_le32(np->tx_dma[nr]);
-			np->tx_ring.orig[nr].flaglen = cpu_to_le32((bcnt-1) | tx_flags);
+			put_tx.orig->buf = cpu_to_le32(np->put_tx_ctx->dma);
+			put_tx.orig->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
 		} else {
-			np->tx_ring.ex[nr].bufhigh = cpu_to_le64(np->tx_dma[nr]) >> 32;
-			np->tx_ring.ex[nr].buflow = cpu_to_le64(np->tx_dma[nr]) & 0x0FFFFFFFF;
-			np->tx_ring.ex[nr].flaglen = cpu_to_le32((bcnt-1) | tx_flags);
+			put_tx.ex->bufhigh = cpu_to_le64(np->put_tx_ctx->dma) >> 32;
+			put_tx.ex->buflow = cpu_to_le64(np->put_tx_ctx->dma) & 0x0FFFFFFFF;
+			put_tx.ex->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
 		}
 		tx_flags = np->tx_flags;
 		offset += bcnt;
 		size -= bcnt;
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+			if (put_tx.orig++ == np->last_tx.orig)
+				put_tx.orig = np->first_tx.orig;
+		} else {
+			if (put_tx.ex++ == np->last_tx.ex)
+				put_tx.ex = np->first_tx.ex;
+		}
+		if (np->put_tx_ctx++ == np->last_tx_ctx)
+			np->put_tx_ctx = np->first_tx_ctx;
 	} while (size);
 
 	/* setup the fragments */
@@ -1547,34 +1620,43 @@
 		offset = 0;
 
 		do {
+			prev_tx = put_tx;
+			prev_tx_ctx = np->put_tx_ctx;
 			bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
-			nr = (nr + 1) % np->tx_ring_size;
-
-			np->tx_dma[nr] = pci_map_page(np->pci_dev, frag->page, frag->page_offset+offset, bcnt,
-						      PCI_DMA_TODEVICE);
-			np->tx_dma_len[nr] = bcnt;
+			np->put_tx_ctx->dma = pci_map_page(np->pci_dev, frag->page, frag->page_offset+offset, bcnt,
+							   PCI_DMA_TODEVICE);
+			np->put_tx_ctx->dma_len = bcnt;
 
 			if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-				np->tx_ring.orig[nr].buf = cpu_to_le32(np->tx_dma[nr]);
-				np->tx_ring.orig[nr].flaglen = cpu_to_le32((bcnt-1) | tx_flags);
+				put_tx.orig->buf = cpu_to_le32(np->put_tx_ctx->dma);
+				put_tx.orig->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
 			} else {
-				np->tx_ring.ex[nr].bufhigh = cpu_to_le64(np->tx_dma[nr]) >> 32;
-				np->tx_ring.ex[nr].buflow = cpu_to_le64(np->tx_dma[nr]) & 0x0FFFFFFFF;
-				np->tx_ring.ex[nr].flaglen = cpu_to_le32((bcnt-1) | tx_flags);
+				put_tx.ex->bufhigh = cpu_to_le64(np->put_tx_ctx->dma) >> 32;
+				put_tx.ex->buflow = cpu_to_le64(np->put_tx_ctx->dma) & 0x0FFFFFFFF;
+				put_tx.ex->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
 			}
 			offset += bcnt;
 			size -= bcnt;
+			if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+				if (put_tx.orig++ == np->last_tx.orig)
+					put_tx.orig = np->first_tx.orig;
+			} else {
+				if (put_tx.ex++ == np->last_tx.ex)
+					put_tx.ex = np->first_tx.ex;
+			}
+			if (np->put_tx_ctx++ == np->last_tx_ctx)
+				np->put_tx_ctx = np->first_tx_ctx;
 		} while (size);
 	}
 
 	/* set last fragment flag  */
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-		np->tx_ring.orig[nr].flaglen |= cpu_to_le32(tx_flags_extra);
-	} else {
-		np->tx_ring.ex[nr].flaglen |= cpu_to_le32(tx_flags_extra);
-	}
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		prev_tx.orig->flaglen |= cpu_to_le32(tx_flags_extra);
+	else
+		prev_tx.ex->flaglen |= cpu_to_le32(tx_flags_extra);
 
-	np->tx_skbuff[nr] = skb;
+	/* save skb in this slot's context area */
+	prev_tx_ctx->skb = skb;
 
 	if (skb_is_gso(skb))
 		tx_flags_extra = NV_TX2_TSO | (skb_shinfo(skb)->gso_size << NV_TX2_TSO_SHIFT);
@@ -1589,14 +1671,17 @@
 
 	/* set tx flags */
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-		np->tx_ring.orig[start_nr].flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
+		start_tx.orig->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
+		np->put_tx.orig = put_tx.orig;
 	} else {
-		np->tx_ring.ex[start_nr].txvlan = cpu_to_le32(tx_flags_vlan);
-		np->tx_ring.ex[start_nr].flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
+		start_tx.ex->txvlan = cpu_to_le32(tx_flags_vlan);
+		start_tx.ex->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
+		np->put_tx.ex = put_tx.ex;
 	}
 
-	dprintk(KERN_DEBUG "%s: nv_start_xmit: packet %d (entries %d) queued for transmission. tx_flags_extra: %x\n",
-		dev->name, np->next_tx, entries, tx_flags_extra);
+
+	dprintk(KERN_DEBUG "%s: nv_start_xmit: entries %d queued for transmission. tx_flags_extra: %x\n",
+		dev->name, entries, tx_flags_extra);
 	{
 		int j;
 		for (j=0; j<64; j++) {
@@ -1607,8 +1692,6 @@
 		dprintk("\n");
 	}
 
-	np->next_tx += entries;
-
 	dev->trans_start = jiffies;
 	spin_unlock_irq(&np->lock);
 	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
@@ -1625,24 +1708,26 @@
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
-	unsigned int i;
 	struct sk_buff *skb;
 
-	while (np->nic_tx != np->next_tx) {
-		i = np->nic_tx % np->tx_ring_size;
-
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
-			flags = le32_to_cpu(np->tx_ring.orig[i].flaglen);
-		else
-			flags = le32_to_cpu(np->tx_ring.ex[i].flaglen);
+ 	while (1) {
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+			if (np->get_tx.orig == np->put_tx.orig)
+				break;
+			flags = le32_to_cpu(np->get_tx.orig->flaglen);
+		} else {
+			if (np->get_tx.ex == np->put_tx.ex)
+				break;
+			flags = le32_to_cpu(np->get_tx.ex->flaglen);
+		}
 
-		dprintk(KERN_DEBUG "%s: nv_tx_done: looking at packet %d, flags 0x%x.\n",
-					dev->name, np->nic_tx, flags);
+		dprintk(KERN_DEBUG "%s: nv_tx_done: flags 0x%x.\n",
+					dev->name, flags);
 		if (flags & NV_TX_VALID)
 			break;
 		if (np->desc_ver == DESC_VER_1) {
 			if (flags & NV_TX_LASTPACKET) {
-				skb = np->tx_skbuff[i];
+				skb = np->get_tx_ctx->skb;
 				if (flags & (NV_TX_RETRYERROR|NV_TX_CARRIERLOST|NV_TX_LATECOLLISION|
 					     NV_TX_UNDERFLOW|NV_TX_ERROR)) {
 					if (flags & NV_TX_UNDERFLOW)
@@ -1657,7 +1742,7 @@
 			}
 		} else {
 			if (flags & NV_TX2_LASTPACKET) {
-				skb = np->tx_skbuff[i];
+				skb = np->get_tx_ctx->skb;
 				if (flags & (NV_TX2_RETRYERROR|NV_TX2_CARRIERLOST|NV_TX2_LATECOLLISION|
 					     NV_TX2_UNDERFLOW|NV_TX2_ERROR)) {
 					if (flags & NV_TX2_UNDERFLOW)
@@ -1671,10 +1756,18 @@
 				}
 			}
 		}
-		nv_release_txskb(dev, i);
-		np->nic_tx++;
+		nv_release_txskb(dev, np->get_tx_ctx);
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+			if (np->get_tx.orig++ == np->last_tx.orig)
+				np->get_tx.orig = np->first_tx.orig;
+		} else {
+			if (np->get_tx.ex++ == np->last_tx.ex)
+				np->get_tx.ex = np->first_tx.ex;
+		}
+		if (np->get_tx_ctx++ == np->last_tx_ctx)
+			np->get_tx_ctx = np->first_tx_ctx;
 	}
-	if (np->next_tx - np->nic_tx < np->tx_limit_start)
+	if (nv_get_empty_tx_slots(np) > np->tx_limit_start)
 		netif_wake_queue(dev);
 }
 
@@ -1698,9 +1791,8 @@
 	{
 		int i;
 
-		printk(KERN_INFO "%s: Ring at %lx: next %d nic %d\n",
-				dev->name, (unsigned long)np->ring_addr,
-				np->next_tx, np->nic_tx);
+		printk(KERN_INFO "%s: Ring at %lx\n",
+		       dev->name, (unsigned long)np->ring_addr);
 		printk(KERN_INFO "%s: Dumping tx registers\n", dev->name);
 		for (i=0;i<=np->register_size;i+= 32) {
 			printk(KERN_INFO "%3x: %08x %08x %08x %08x %08x %08x %08x %08x\n",
@@ -1751,10 +1843,10 @@
 	nv_tx_done(dev);
 
 	/* 3) if there are dead entries: clear everything */
-	if (np->next_tx != np->nic_tx) {
+	if (np->get_tx_ctx != np->put_tx_ctx) {
 		printk(KERN_DEBUG "%s: tx_timeout: dead entries!\n", dev->name);
 		nv_drain_tx(dev);
-		np->next_tx = np->nic_tx = 0;
+		nv_init_tx(dev);
 		setup_hw_rings(dev, NV_SETUP_TX_RING);
 		netif_wake_queue(dev);
 	}
@@ -1827,22 +1919,22 @@
  	for (count = 0; count < limit; ++count) {
 		struct sk_buff *skb;
 		int len;
-		int i;
-		if (np->cur_rx - np->refill_rx >= np->rx_ring_size)
-			break;	/* we scanned the whole ring - do not continue */
 
-		i = np->cur_rx % np->rx_ring_size;
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-			flags = le32_to_cpu(np->rx_ring.orig[i].flaglen);
-			len = nv_descr_getlength(&np->rx_ring.orig[i], np->desc_ver);
+			if (np->get_rx.orig == np->put_rx.orig)
+				break;	/* we scanned the whole ring - do not continue */
+			flags = le32_to_cpu(np->get_rx.orig->flaglen);
+			len = nv_descr_getlength(np->get_rx.orig, np->desc_ver);
 		} else {
-			flags = le32_to_cpu(np->rx_ring.ex[i].flaglen);
-			len = nv_descr_getlength_ex(&np->rx_ring.ex[i], np->desc_ver);
-			vlanflags = le32_to_cpu(np->rx_ring.ex[i].buflow);
+			if (np->get_rx.ex == np->put_rx.ex)
+				break;	/* we scanned the whole ring - do not continue */
+			flags = le32_to_cpu(np->get_rx.ex->flaglen);
+			len = nv_descr_getlength_ex(np->get_rx.ex, np->desc_ver);
+			vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
 		}
 
-		dprintk(KERN_DEBUG "%s: nv_rx_process: looking at packet %d, flags 0x%x.\n",
-					dev->name, np->cur_rx, flags);
+		dprintk(KERN_DEBUG "%s: nv_rx_process: flags 0x%x.\n",
+					dev->name, flags);
 
 		if (flags & NV_RX_AVAIL)
 			break;	/* still owned by hardware, */
@@ -1852,8 +1944,8 @@
 		 * TODO: check if a prefetch of the first cacheline improves
 		 * the performance.
 		 */
-		pci_unmap_single(np->pci_dev, np->rx_dma[i],
-				np->rx_skbuff[i]->end-np->rx_skbuff[i]->data,
+		pci_unmap_single(np->pci_dev, np->get_rx_ctx->dma,
+				np->get_rx_ctx->dma_len,
 				PCI_DMA_FROMDEVICE);
 
 		{
@@ -1862,7 +1954,7 @@
 			for (j=0; j<64; j++) {
 				if ((j%16) == 0)
 					dprintk("\n%03x:", j);
-				dprintk(" %02x", ((unsigned char*)np->rx_skbuff[i]->data)[j]);
+				dprintk(" %02x", ((unsigned char*)np->get_rx_ctx->skb->data)[j]);
 			}
 			dprintk("\n");
 		}
@@ -1892,7 +1984,7 @@
 					goto next_pkt;
 				}
 				if (flags & NV_RX_ERROR4) {
-					len = nv_getlen(dev, np->rx_skbuff[i]->data, len);
+					len = nv_getlen(dev, np->get_rx_ctx->skb->data, len);
 					if (len < 0) {
 						np->stats.rx_errors++;
 						goto next_pkt;
@@ -1925,7 +2017,7 @@
 					goto next_pkt;
 				}
 				if (flags & NV_RX2_ERROR4) {
-					len = nv_getlen(dev, np->rx_skbuff[i]->data, len);
+					len = nv_getlen(dev, np->get_rx_ctx->skb->data, len);
 					if (len < 0) {
 						np->stats.rx_errors++;
 						goto next_pkt;
@@ -1944,20 +2036,20 @@
 				    flags == NV_RX2_CHECKSUMOK2 ||
 				    flags == NV_RX2_CHECKSUMOK3) {
 					dprintk(KERN_DEBUG "%s: hw checksum hit!.\n", dev->name);
-					np->rx_skbuff[i]->ip_summed = CHECKSUM_UNNECESSARY;
+					np->get_rx_ctx->skb->ip_summed = CHECKSUM_UNNECESSARY;
 				} else {
 					dprintk(KERN_DEBUG "%s: hwchecksum miss!.\n", dev->name);
 				}
 			}
 		}
 		/* got a valid packet - forward it to the network core */
-		skb = np->rx_skbuff[i];
-		np->rx_skbuff[i] = NULL;
+		skb = np->get_rx_ctx->skb;
+		np->get_rx_ctx->skb = NULL;
 
 		skb_put(skb, len);
 		skb->protocol = eth_type_trans(skb, dev);
-		dprintk(KERN_DEBUG "%s: nv_rx_process: packet %d with %d bytes, proto %d accepted.\n",
-					dev->name, np->cur_rx, len, skb->protocol);
+		dprintk(KERN_DEBUG "%s: nv_rx_process: %d bytes, proto %d accepted.\n",
+					dev->name, len, skb->protocol);
 #ifdef CONFIG_FORCEDETH_NAPI
 		if (np->vlangrp && (vlanflags & NV_RX3_VLAN_TAG_PRESENT))
 			vlan_hwaccel_receive_skb(skb, np->vlangrp,
@@ -1975,7 +2067,15 @@
 		np->stats.rx_packets++;
 		np->stats.rx_bytes += len;
 next_pkt:
-		np->cur_rx++;
+		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
+			if (np->get_rx.orig++ == np->last_rx.orig)
+				np->get_rx.orig = np->first_rx.orig;
+		} else {
+			if (np->get_rx.ex++ == np->last_rx.ex)
+				np->get_rx.ex = np->first_rx.ex;
+		}
+		if (np->get_rx_ctx++ == np->last_rx_ctx)
+			np->get_rx_ctx = np->first_rx_ctx;
 	}
 
 	return count;
@@ -3463,7 +3563,7 @@
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u8 __iomem *base = get_hwbase(dev);
-	u8 *rxtx_ring, *rx_skbuff, *tx_skbuff, *rx_dma, *tx_dma, *tx_dma_len;
+	u8 *rxtx_ring, *rx_skbuff, *tx_skbuff;
 	dma_addr_t ring_addr;
 
 	if (ring->rx_pending < RX_RING_MIN ||
@@ -3489,12 +3589,9 @@
 					    sizeof(struct ring_desc_ex) * (ring->rx_pending + ring->tx_pending),
 					    &ring_addr);
 	}
-	rx_skbuff = kmalloc(sizeof(struct sk_buff*) * ring->rx_pending, GFP_KERNEL);
-	rx_dma = kmalloc(sizeof(dma_addr_t) * ring->rx_pending, GFP_KERNEL);
-	tx_skbuff = kmalloc(sizeof(struct sk_buff*) * ring->tx_pending, GFP_KERNEL);
-	tx_dma = kmalloc(sizeof(dma_addr_t) * ring->tx_pending, GFP_KERNEL);
-	tx_dma_len = kmalloc(sizeof(unsigned int) * ring->tx_pending, GFP_KERNEL);
-	if (!rxtx_ring || !rx_skbuff || !rx_dma || !tx_skbuff || !tx_dma || !tx_dma_len) {
+	rx_skbuff = kmalloc(sizeof(struct nv_skb_map) * ring->rx_pending, GFP_KERNEL);
+	tx_skbuff = kmalloc(sizeof(struct nv_skb_map) * ring->tx_pending, GFP_KERNEL);
+	if (!rxtx_ring || !rx_skbuff || !tx_skbuff) {
 		/* fall back to old rings */
 		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
 			if (rxtx_ring)
@@ -3507,14 +3604,8 @@
 		}
 		if (rx_skbuff)
 			kfree(rx_skbuff);
-		if (rx_dma)
-			kfree(rx_dma);
 		if (tx_skbuff)
 			kfree(tx_skbuff);
-		if (tx_dma)
-			kfree(tx_dma);
-		if (tx_dma_len)
-			kfree(tx_dma_len);
 		goto exit;
 	}
 
@@ -3536,8 +3627,8 @@
 	/* set new values */
 	np->rx_ring_size = ring->rx_pending;
 	np->tx_ring_size = ring->tx_pending;
-	np->tx_limit_stop = ring->tx_pending - TX_LIMIT_DIFFERENCE;
-	np->tx_limit_start = ring->tx_pending - TX_LIMIT_DIFFERENCE - 1;
+	np->tx_limit_stop = TX_LIMIT_DIFFERENCE;
+	np->tx_limit_start = TX_LIMIT_DIFFERENCE;
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
 		np->rx_ring.orig = (struct ring_desc*)rxtx_ring;
 		np->tx_ring.orig = &np->rx_ring.orig[np->rx_ring_size];
@@ -3545,18 +3636,12 @@
 		np->rx_ring.ex = (struct ring_desc_ex*)rxtx_ring;
 		np->tx_ring.ex = &np->rx_ring.ex[np->rx_ring_size];
 	}
-	np->rx_skbuff = (struct sk_buff**)rx_skbuff;
-	np->rx_dma = (dma_addr_t*)rx_dma;
-	np->tx_skbuff = (struct sk_buff**)tx_skbuff;
-	np->tx_dma = (dma_addr_t*)tx_dma;
-	np->tx_dma_len = (unsigned int*)tx_dma_len;
+	np->rx_skb = (struct nv_skb_map*)rx_skbuff;
+	np->tx_skb = (struct nv_skb_map*)tx_skbuff;
 	np->ring_addr = ring_addr;
 
-	memset(np->rx_skbuff, 0, sizeof(struct sk_buff*) * np->rx_ring_size);
-	memset(np->rx_dma, 0, sizeof(dma_addr_t) * np->rx_ring_size);
-	memset(np->tx_skbuff, 0, sizeof(struct sk_buff*) * np->tx_ring_size);
-	memset(np->tx_dma, 0, sizeof(dma_addr_t) * np->tx_ring_size);
-	memset(np->tx_dma_len, 0, sizeof(unsigned int) * np->tx_ring_size);
+	memset(np->rx_skb, 0, sizeof(struct nv_skb_map) * np->rx_ring_size);
+	memset(np->tx_skb, 0, sizeof(struct nv_skb_map) * np->tx_ring_size);
 
 	if (netif_running(dev)) {
 		/* reinit driver view of the queues */
@@ -3953,7 +4038,7 @@
 			dprintk(KERN_DEBUG "%s: loopback len mismatch %d vs %d\n",
 				dev->name, len, pkt_len);
 		} else {
-			rx_skb = np->rx_skbuff[0];
+			rx_skb = np->rx_skb[0].skb;
 			for (i = 0; i < pkt_len; i++) {
 				if (rx_skb->data[i] != (u8)(i & 0xff)) {
 					ret = 0;
@@ -4508,8 +4593,8 @@
 
 	np->rx_ring_size = RX_RING_DEFAULT;
 	np->tx_ring_size = TX_RING_DEFAULT;
-	np->tx_limit_stop = np->tx_ring_size - TX_LIMIT_DIFFERENCE;
-	np->tx_limit_start = np->tx_ring_size - TX_LIMIT_DIFFERENCE - 1;
+	np->tx_limit_stop = TX_LIMIT_DIFFERENCE;
+	np->tx_limit_start = TX_LIMIT_DIFFERENCE;
 
 	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
 		np->rx_ring.orig = pci_alloc_consistent(pci_dev,
@@ -4526,18 +4611,12 @@
 			goto out_unmap;
 		np->tx_ring.ex = &np->rx_ring.ex[np->rx_ring_size];
 	}
-	np->rx_skbuff = kmalloc(sizeof(struct sk_buff*) * np->rx_ring_size, GFP_KERNEL);
-	np->rx_dma = kmalloc(sizeof(dma_addr_t) * np->rx_ring_size, GFP_KERNEL);
-	np->tx_skbuff = kmalloc(sizeof(struct sk_buff*) * np->tx_ring_size, GFP_KERNEL);
-	np->tx_dma = kmalloc(sizeof(dma_addr_t) * np->tx_ring_size, GFP_KERNEL);
-	np->tx_dma_len = kmalloc(sizeof(unsigned int) * np->tx_ring_size, GFP_KERNEL);
-	if (!np->rx_skbuff || !np->rx_dma || !np->tx_skbuff || !np->tx_dma || !np->tx_dma_len)
+	np->rx_skb = kmalloc(sizeof(struct nv_skb_map) * np->rx_ring_size, GFP_KERNEL);
+	np->tx_skb = kmalloc(sizeof(struct nv_skb_map) * np->tx_ring_size, GFP_KERNEL);
+	if (!np->rx_skb || !np->tx_skb)
 		goto out_freering;
-	memset(np->rx_skbuff, 0, sizeof(struct sk_buff*) * np->rx_ring_size);
-	memset(np->rx_dma, 0, sizeof(dma_addr_t) * np->rx_ring_size);
-	memset(np->tx_skbuff, 0, sizeof(struct sk_buff*) * np->tx_ring_size);
-	memset(np->tx_dma, 0, sizeof(dma_addr_t) * np->tx_ring_size);
-	memset(np->tx_dma_len, 0, sizeof(unsigned int) * np->tx_ring_size);
+	memset(np->rx_skb, 0, sizeof(struct nv_skb_map) * np->rx_ring_size);
+	memset(np->tx_skb, 0, sizeof(struct nv_skb_map) * np->tx_ring_size);
 
 	dev->open = nv_open;
 	dev->stop = nv_close;

--------------010902000107090908060002--
