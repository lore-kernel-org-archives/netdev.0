From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 5/12] forcedeth: optimized routines
Date: Sun, 21 Jan 2007 18:10:37 -0500
Message-ID: <45B3F2ED.8080402@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060904070201070709050203"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:6989 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751846AbXAVBGT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Jan 2007 20:06:19 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060904070201070709050203
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch breaks up the routines into two versions, one for legacy
descriptor versions (ver 1 and ver 2) and one for desc ver 3. This will
make the new desc functions more leaner and further reductions will be
made in next few patches.

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------060904070201070709050203
Content-Type: text/plain;
 name="patch-optimized-functions"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-optimized-functions"

--- orig/drivers/net/forcedeth.c	2007-01-19 10:54:32.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-01-19 10:54:14.000000000 -0500
@@ -1307,50 +1307,57 @@
 static int nv_alloc_rx(struct net_device *dev)
 {
 	struct fe_priv *np = netdev_priv(dev);
-	union ring_type less_rx;
+	struct ring_desc* less_rx;
 
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-		less_rx.orig = np->get_rx.orig;
-		if (less_rx.orig-- == np->first_rx.orig)
-			less_rx.orig = np->last_rx.orig;
-	} else {
-		less_rx.ex = np->get_rx.ex;
-		if (less_rx.ex-- == np->first_rx.ex)
-			less_rx.ex = np->last_rx.ex;
-	}
+	less_rx = np->get_rx.orig;
+	if (less_rx-- == np->first_rx.orig)
+		less_rx = np->last_rx.orig;
 
-	while (1) {
-		struct sk_buff *skb;
-
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-			if (np->put_rx.orig == less_rx.orig)
-				break;
+	while (np->put_rx.orig != less_rx) {
+		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
+		if (skb) {
+			skb->dev = dev;
+			np->put_rx_ctx->skb = skb;
+			np->put_rx_ctx->dma = pci_map_single(np->pci_dev, skb->data,
+							     skb->end-skb->data, PCI_DMA_FROMDEVICE);
+			np->put_rx_ctx->dma_len = skb->end-skb->data;
+			np->put_rx.orig->buf = cpu_to_le32(np->put_rx_ctx->dma);
+			wmb();
+			np->put_rx.orig->flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX_AVAIL);
+			if (np->put_rx.orig++ == np->last_rx.orig)
+				np->put_rx.orig = np->first_rx.orig;
+			if (np->put_rx_ctx++ == np->last_rx_ctx)
+				np->put_rx_ctx = np->first_rx_ctx;
 		} else {
-			if (np->put_rx.ex == less_rx.ex)
-				break;
+			return 1;
 		}
+	}
+	return 0;
+}
+
+static int nv_alloc_rx_optimized(struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	struct ring_desc_ex* less_rx;
+
+	less_rx = np->get_rx.ex;
+	if (less_rx-- == np->first_rx.ex)
+		less_rx = np->last_rx.ex;
 
-		skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
+	while (np->put_rx.ex != less_rx) {
+		struct sk_buff *skb = dev_alloc_skb(np->rx_buf_sz + NV_RX_ALLOC_PAD);
 		if (skb) {
 			skb->dev = dev;
 			np->put_rx_ctx->skb = skb;
 			np->put_rx_ctx->dma = pci_map_single(np->pci_dev, skb->data,
 							     skb->end-skb->data, PCI_DMA_FROMDEVICE);
 			np->put_rx_ctx->dma_len = skb->end-skb->data;
-			if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-				np->put_rx.orig->buf = cpu_to_le32(np->put_rx_ctx->dma);
-				wmb();
-				np->put_rx.orig->flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX_AVAIL);
-				if (np->put_rx.orig++ == np->last_rx.orig)
-					np->put_rx.orig = np->first_rx.orig;
-			} else {
-				np->put_rx.ex->bufhigh = cpu_to_le64(np->put_rx_ctx->dma) >> 32;
-				np->put_rx.ex->buflow = cpu_to_le64(np->put_rx_ctx->dma) & 0x0FFFFFFFF;
-				wmb();
-				np->put_rx.ex->flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX2_AVAIL);
-				if (np->put_rx.ex++ == np->last_rx.ex)
-					np->put_rx.ex = np->first_rx.ex;
-			}
+			np->put_rx.ex->bufhigh = cpu_to_le64(np->put_rx_ctx->dma) >> 32;
+			np->put_rx.ex->buflow = cpu_to_le64(np->put_rx_ctx->dma) & 0x0FFFFFFFF;
+			wmb();
+			np->put_rx.ex->flaglen = cpu_to_le32(np->rx_buf_sz | NV_RX2_AVAIL);
+			if (np->put_rx.ex++ == np->last_rx.ex)
+				np->put_rx.ex = np->first_rx.ex;
 			if (np->put_rx_ctx++ == np->last_rx_ctx)
 				np->put_rx_ctx = np->first_rx_ctx;
 		} else {
@@ -1374,6 +1381,7 @@
 {
 	struct net_device *dev = (struct net_device *) data;
 	struct fe_priv *np = netdev_priv(dev);
+	int retcode;
 
 	if (!using_multi_irqs(dev)) {
 		if (np->msi_flags & NV_MSI_X_ENABLED)
@@ -1383,7 +1391,11 @@
 	} else {
 		disable_irq(np->msi_x_entry[NV_MSI_X_VECTOR_RX].vector);
 	}
-	if (nv_alloc_rx(dev)) {
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		retcode = nv_alloc_rx(dev);
+	else
+		retcode = nv_alloc_rx_optimized(dev);
+	if (retcode) {
 		spin_lock_irq(&np->lock);
 		if (!np->in_shutdown)
 			mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
@@ -1456,9 +1468,14 @@
 
 static int nv_init_ring(struct net_device *dev)
 {
+	struct fe_priv *np = netdev_priv(dev);
+
 	nv_init_tx(dev);
 	nv_init_rx(dev);
-	return nv_alloc_rx(dev);
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		return nv_alloc_rx(dev);
+	else
+		return nv_alloc_rx_optimized(dev);
 }
 
 static int nv_release_txskb(struct net_device *dev, struct nv_skb_map* tx_skb)
@@ -1554,9 +1571,9 @@
 	u32 entries = (size >> NV_TX2_TSO_MAX_SHIFT) + ((size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	u32 empty_slots;
 	u32 tx_flags_vlan = 0;
-	union ring_type put_tx;
-	union ring_type start_tx;
-	union ring_type prev_tx;
+	struct ring_desc* put_tx;
+	struct ring_desc* start_tx;
+	struct ring_desc* prev_tx;
 	struct nv_skb_map* prev_tx_ctx;
 
 	/* add fragments to entries count */
@@ -1573,10 +1590,7 @@
 		return NETDEV_TX_BUSY;
 	}
 
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
-		start_tx.orig = put_tx.orig = np->put_tx.orig;
-	else
-		start_tx.ex = put_tx.ex = np->put_tx.ex;
+	start_tx = put_tx = np->put_tx.orig;
 
 	/* setup the header buffer */
 	do {
@@ -1586,24 +1600,13 @@
 		np->put_tx_ctx->dma = pci_map_single(np->pci_dev, skb->data + offset, bcnt,
 						PCI_DMA_TODEVICE);
 		np->put_tx_ctx->dma_len = bcnt;
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-			put_tx.orig->buf = cpu_to_le32(np->put_tx_ctx->dma);
-			put_tx.orig->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
-		} else {
-			put_tx.ex->bufhigh = cpu_to_le64(np->put_tx_ctx->dma) >> 32;
-			put_tx.ex->buflow = cpu_to_le64(np->put_tx_ctx->dma) & 0x0FFFFFFFF;
-			put_tx.ex->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
-		}
+		put_tx->buf = cpu_to_le32(np->put_tx_ctx->dma);
+		put_tx->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
 		tx_flags = np->tx_flags;
 		offset += bcnt;
 		size -= bcnt;
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-			if (put_tx.orig++ == np->last_tx.orig)
-				put_tx.orig = np->first_tx.orig;
-		} else {
-			if (put_tx.ex++ == np->last_tx.ex)
-				put_tx.ex = np->first_tx.ex;
-		}
+		if (put_tx++ == np->last_tx.orig)
+			put_tx = np->first_tx.orig;
 		if (np->put_tx_ctx++ == np->last_tx_ctx)
 			np->put_tx_ctx = np->first_tx_ctx;
 	} while (size);
@@ -1622,33 +1625,19 @@
 							   PCI_DMA_TODEVICE);
 			np->put_tx_ctx->dma_len = bcnt;
 
-			if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-				put_tx.orig->buf = cpu_to_le32(np->put_tx_ctx->dma);
-				put_tx.orig->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
-			} else {
-				put_tx.ex->bufhigh = cpu_to_le64(np->put_tx_ctx->dma) >> 32;
-				put_tx.ex->buflow = cpu_to_le64(np->put_tx_ctx->dma) & 0x0FFFFFFFF;
-				put_tx.ex->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
-			}
+			put_tx->buf = cpu_to_le32(np->put_tx_ctx->dma);
+			put_tx->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
 			offset += bcnt;
 			size -= bcnt;
-			if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-				if (put_tx.orig++ == np->last_tx.orig)
-					put_tx.orig = np->first_tx.orig;
-			} else {
-				if (put_tx.ex++ == np->last_tx.ex)
-					put_tx.ex = np->first_tx.ex;
-			}
+			if (put_tx++ == np->last_tx.orig)
+				put_tx = np->first_tx.orig;
 			if (np->put_tx_ctx++ == np->last_tx_ctx)
 				np->put_tx_ctx = np->first_tx_ctx;
 		} while (size);
 	}
 
 	/* set last fragment flag  */
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
-		prev_tx.orig->flaglen |= cpu_to_le32(tx_flags_extra);
-	else
-		prev_tx.ex->flaglen |= cpu_to_le32(tx_flags_extra);
+	prev_tx->flaglen |= cpu_to_le32(tx_flags_extra);
 
 	/* save skb in this slot's context area */
 	prev_tx_ctx->skb = skb;
@@ -1667,14 +1656,8 @@
 	spin_lock_irq(&np->lock);
 
 	/* set tx flags */
-	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-		start_tx.orig->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
-		np->put_tx.orig = put_tx.orig;
-	} else {
-		start_tx.ex->txvlan = cpu_to_le32(tx_flags_vlan);
-		start_tx.ex->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
-		np->put_tx.ex = put_tx.ex;
-	}
+	start_tx->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
+	np->put_tx.orig = put_tx;
 
 	spin_unlock_irq(&np->lock);
 
@@ -1696,6 +1679,130 @@
 	return NETDEV_TX_OK;
 }
 
+static int nv_start_xmit_optimized(struct sk_buff *skb, struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	u32 tx_flags = 0;
+	u32 tx_flags_extra = NV_TX2_LASTPACKET;
+	unsigned int fragments = skb_shinfo(skb)->nr_frags;
+	unsigned int i;
+	u32 offset = 0;
+	u32 bcnt;
+	u32 size = skb->len-skb->data_len;
+	u32 entries = (size >> NV_TX2_TSO_MAX_SHIFT) + ((size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
+	u32 empty_slots;
+	u32 tx_flags_vlan = 0;
+	struct ring_desc_ex* put_tx;
+	struct ring_desc_ex* start_tx;
+	struct ring_desc_ex* prev_tx;
+	struct nv_skb_map* prev_tx_ctx;
+
+	/* add fragments to entries count */
+	for (i = 0; i < fragments; i++) {
+		entries += (skb_shinfo(skb)->frags[i].size >> NV_TX2_TSO_MAX_SHIFT) +
+			   ((skb_shinfo(skb)->frags[i].size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
+	}
+
+	empty_slots = nv_get_empty_tx_slots(np);
+	if ((empty_slots - np->tx_limit_stop) <= entries) {
+		spin_lock_irq(&np->lock);
+		netif_stop_queue(dev);
+		spin_unlock_irq(&np->lock);
+		return NETDEV_TX_BUSY;
+	}
+
+	start_tx = put_tx = np->put_tx.ex;
+
+	/* setup the header buffer */
+	do {
+		prev_tx = put_tx;
+		prev_tx_ctx = np->put_tx_ctx;
+		bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
+		np->put_tx_ctx->dma = pci_map_single(np->pci_dev, skb->data + offset, bcnt,
+						PCI_DMA_TODEVICE);
+		np->put_tx_ctx->dma_len = bcnt;
+		put_tx->bufhigh = cpu_to_le64(np->put_tx_ctx->dma) >> 32;
+		put_tx->buflow = cpu_to_le64(np->put_tx_ctx->dma) & 0x0FFFFFFFF;
+		put_tx->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
+		tx_flags = np->tx_flags;
+		offset += bcnt;
+		size -= bcnt;
+		if (put_tx++ == np->last_tx.ex)
+			put_tx = np->first_tx.ex;
+		if (np->put_tx_ctx++ == np->last_tx_ctx)
+			np->put_tx_ctx = np->first_tx_ctx;
+	} while (size);
+
+	/* setup the fragments */
+	for (i = 0; i < fragments; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		u32 size = frag->size;
+		offset = 0;
+
+		do {
+			prev_tx = put_tx;
+			prev_tx_ctx = np->put_tx_ctx;
+			bcnt = (size > NV_TX2_TSO_MAX_SIZE) ? NV_TX2_TSO_MAX_SIZE : size;
+			np->put_tx_ctx->dma = pci_map_page(np->pci_dev, frag->page, frag->page_offset+offset, bcnt,
+							   PCI_DMA_TODEVICE);
+			np->put_tx_ctx->dma_len = bcnt;
+
+			put_tx->bufhigh = cpu_to_le64(np->put_tx_ctx->dma) >> 32;
+			put_tx->buflow = cpu_to_le64(np->put_tx_ctx->dma) & 0x0FFFFFFFF;
+			put_tx->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
+			offset += bcnt;
+			size -= bcnt;
+			if (put_tx++ == np->last_tx.ex)
+				put_tx = np->first_tx.ex;
+			if (np->put_tx_ctx++ == np->last_tx_ctx)
+				np->put_tx_ctx = np->first_tx_ctx;
+		} while (size);
+	}
+
+	/* set last fragment flag  */
+	prev_tx->flaglen |= cpu_to_le32(tx_flags_extra);
+
+	/* save skb in this slot's context area */
+	prev_tx_ctx->skb = skb;
+
+	if (skb_is_gso(skb))
+		tx_flags_extra = NV_TX2_TSO | (skb_shinfo(skb)->gso_size << NV_TX2_TSO_SHIFT);
+	else
+		tx_flags_extra = skb->ip_summed == CHECKSUM_PARTIAL ?
+			 NV_TX2_CHECKSUM_L3 | NV_TX2_CHECKSUM_L4 : 0;
+
+	/* vlan tag */
+	if (np->vlangrp && vlan_tx_tag_present(skb)) {
+		tx_flags_vlan = NV_TX3_VLAN_TAG_PRESENT | vlan_tx_tag_get(skb);
+	}
+
+	spin_lock_irq(&np->lock);
+
+	/* set tx flags */
+	start_tx->txvlan = cpu_to_le32(tx_flags_vlan);
+	start_tx->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
+	np->put_tx.ex = put_tx;
+
+	spin_unlock_irq(&np->lock);
+
+	dprintk(KERN_DEBUG "%s: nv_start_xmit_optimized: entries %d queued for transmission. tx_flags_extra: %x\n",
+		dev->name, entries, tx_flags_extra);
+	{
+		int j;
+		for (j=0; j<64; j++) {
+			if ((j%16) == 0)
+				dprintk("\n%03x:", j);
+			dprintk(" %02x", ((unsigned char*)skb->data)[j]);
+		}
+		dprintk("\n");
+	}
+
+	dev->trans_start = jiffies;
+	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
+	pci_push(get_hwbase(dev));
+	return NETDEV_TX_OK;
+}
+
 /*
  * nv_tx_done: check for completed packets, release the skbs.
  *
@@ -1707,16 +1814,8 @@
 	u32 flags;
 	struct sk_buff *skb;
 
- 	while (1) {
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-			if (np->get_tx.orig == np->put_tx.orig)
-				break;
-			flags = le32_to_cpu(np->get_tx.orig->flaglen);
-		} else {
-			if (np->get_tx.ex == np->put_tx.ex)
-				break;
-			flags = le32_to_cpu(np->get_tx.ex->flaglen);
-		}
+	while (np->get_tx.orig != np->put_tx.orig) {
+		flags = le32_to_cpu(np->get_tx.orig->flaglen);
 
 		dprintk(KERN_DEBUG "%s: nv_tx_done: flags 0x%x.\n",
 					dev->name, flags);
@@ -1754,13 +1853,45 @@
 			}
 		}
 		nv_release_txskb(dev, np->get_tx_ctx);
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-			if (np->get_tx.orig++ == np->last_tx.orig)
-				np->get_tx.orig = np->first_tx.orig;
-		} else {
-			if (np->get_tx.ex++ == np->last_tx.ex)
-				np->get_tx.ex = np->first_tx.ex;
+		if (np->get_tx.orig++ == np->last_tx.orig)
+			np->get_tx.orig = np->first_tx.orig;
+		if (np->get_tx_ctx++ == np->last_tx_ctx)
+			np->get_tx_ctx = np->first_tx_ctx;
+	}
+	if (nv_get_empty_tx_slots(np) > np->tx_limit_start)
+		netif_wake_queue(dev);
+}
+
+static void nv_tx_done_optimized(struct net_device *dev)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	u32 flags;
+	struct sk_buff *skb;
+
+	while (np->get_tx.ex == np->put_tx.ex) {
+		flags = le32_to_cpu(np->get_tx.ex->flaglen);
+
+		dprintk(KERN_DEBUG "%s: nv_tx_done_optimized: flags 0x%x.\n",
+					dev->name, flags);
+		if (flags & NV_TX_VALID)
+			break;
+		if (flags & NV_TX2_LASTPACKET) {
+			skb = np->get_tx_ctx->skb;
+			if (flags & (NV_TX2_RETRYERROR|NV_TX2_CARRIERLOST|NV_TX2_LATECOLLISION|
+				     NV_TX2_UNDERFLOW|NV_TX2_ERROR)) {
+				if (flags & NV_TX2_UNDERFLOW)
+					np->stats.tx_fifo_errors++;
+				if (flags & NV_TX2_CARRIERLOST)
+					np->stats.tx_carrier_errors++;
+				np->stats.tx_errors++;
+			} else {
+				np->stats.tx_packets++;
+				np->stats.tx_bytes += skb->len;
+			}
 		}
+		nv_release_txskb(dev, np->get_tx_ctx);
+		if (np->get_tx.ex++ == np->last_tx.ex)
+			np->get_tx.ex = np->first_tx.ex;
 		if (np->get_tx_ctx++ == np->last_tx_ctx)
 			np->get_tx_ctx = np->first_tx_ctx;
 	}
@@ -1837,7 +1968,10 @@
 	nv_stop_tx(dev);
 
 	/* 2) check that the packets were not sent already: */
-	nv_tx_done(dev);
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		nv_tx_done(dev);
+	else
+		nv_tx_done_optimized(dev);
 
 	/* 3) if there are dead entries: clear everything */
 	if (np->get_tx_ctx != np->put_tx_ctx) {
@@ -1913,22 +2047,14 @@
 	u32 vlanflags = 0;
 	int count;
 
- 	for (count = 0; count < limit; ++count) {
+	for (count = 0; count < limit; ++count) {
 		struct sk_buff *skb;
 		int len;
 
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-			if (np->get_rx.orig == np->put_rx.orig)
-				break;	/* we scanned the whole ring - do not continue */
-			flags = le32_to_cpu(np->get_rx.orig->flaglen);
-			len = nv_descr_getlength(np->get_rx.orig, np->desc_ver);
-		} else {
-			if (np->get_rx.ex == np->put_rx.ex)
-				break;	/* we scanned the whole ring - do not continue */
-			flags = le32_to_cpu(np->get_rx.ex->flaglen);
-			len = nv_descr_getlength_ex(np->get_rx.ex, np->desc_ver);
-			vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
-		}
+		if (np->get_rx.orig == np->put_rx.orig)
+			break;	/* we scanned the whole ring - do not continue */
+		flags = le32_to_cpu(np->get_rx.orig->flaglen);
+		len = nv_descr_getlength(np->get_rx.orig, np->desc_ver);
 
 		dprintk(KERN_DEBUG "%s: nv_rx_process: flags 0x%x.\n",
 					dev->name, flags);
@@ -2076,13 +2202,133 @@
 		np->stats.rx_packets++;
 		np->stats.rx_bytes += len;
 next_pkt:
-		if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2) {
-			if (np->get_rx.orig++ == np->last_rx.orig)
-				np->get_rx.orig = np->first_rx.orig;
-		} else {
-			if (np->get_rx.ex++ == np->last_rx.ex)
-				np->get_rx.ex = np->first_rx.ex;
+		if (np->get_rx.orig++ == np->last_rx.orig)
+			np->get_rx.orig = np->first_rx.orig;
+		if (np->get_rx_ctx++ == np->last_rx_ctx)
+			np->get_rx_ctx = np->first_rx_ctx;
+	}
+
+	return count;
+}
+
+static int nv_rx_process_optimized(struct net_device *dev, int limit)
+{
+	struct fe_priv *np = netdev_priv(dev);
+	u32 flags;
+	u32 vlanflags = 0;
+	int count;
+
+	for (count = 0; count < limit; ++count) {
+		struct sk_buff *skb;
+		int len;
+
+		if (np->get_rx.ex == np->put_rx.ex)
+			break;	/* we scanned the whole ring - do not continue */
+		flags = le32_to_cpu(np->get_rx.ex->flaglen);
+		len = nv_descr_getlength_ex(np->get_rx.ex, np->desc_ver);
+		vlanflags = le32_to_cpu(np->get_rx.ex->buflow);
+
+		dprintk(KERN_DEBUG "%s: nv_rx_process_optimized: flags 0x%x.\n",
+					dev->name, flags);
+
+		if (flags & NV_RX_AVAIL)
+			break;	/* still owned by hardware, */
+
+		/*
+		 * the packet is for us - immediately tear down the pci mapping.
+		 * TODO: check if a prefetch of the first cacheline improves
+		 * the performance.
+		 */
+		pci_unmap_single(np->pci_dev, np->get_rx_ctx->dma,
+				np->get_rx_ctx->dma_len,
+				PCI_DMA_FROMDEVICE);
+		skb = np->get_rx_ctx->skb;
+		np->get_rx_ctx->skb = NULL;
+
+		{
+			int j;
+			dprintk(KERN_DEBUG "Dumping packet (flags 0x%x).",flags);
+			for (j=0; j<64; j++) {
+				if ((j%16) == 0)
+					dprintk("\n%03x:", j);
+				dprintk(" %02x", ((unsigned char*)skb->data)[j]);
+			}
+			dprintk("\n");
+		}
+		/* look at what we actually got: */
+		if (!(flags & NV_RX2_DESCRIPTORVALID)) {
+			dev_kfree_skb(skb);
+			goto next_pkt;
+		}
+
+		if (flags & NV_RX2_ERROR) {
+			if (flags & (NV_RX2_ERROR1|NV_RX2_ERROR2|NV_RX2_ERROR3)) {
+				np->stats.rx_errors++;
+				dev_kfree_skb(skb);
+				goto next_pkt;
+			}
+			if (flags & NV_RX2_CRCERR) {
+				np->stats.rx_crc_errors++;
+				np->stats.rx_errors++;
+				dev_kfree_skb(skb);
+				goto next_pkt;
+			}
+			if (flags & NV_RX2_OVERFLOW) {
+				np->stats.rx_over_errors++;
+				np->stats.rx_errors++;
+				dev_kfree_skb(skb);
+				goto next_pkt;
+			}
+			if (flags & NV_RX2_ERROR4) {
+				len = nv_getlen(dev, skb->data, len);
+				if (len < 0) {
+					np->stats.rx_errors++;
+					dev_kfree_skb(skb);
+					goto next_pkt;
+				}
+			}
+			/* framing errors are soft errors */
+			if (flags & NV_RX2_FRAMINGERR) {
+				if (flags & NV_RX2_SUBSTRACT1) {
+					len--;
+				}
+			}
 		}
+		if (np->rx_csum) {
+			flags &= NV_RX2_CHECKSUMMASK;
+			if (flags == NV_RX2_CHECKSUMOK1 ||
+			    flags == NV_RX2_CHECKSUMOK2 ||
+			    flags == NV_RX2_CHECKSUMOK3) {
+				dprintk(KERN_DEBUG "%s: hw checksum hit!.\n", dev->name);
+				skb->ip_summed = CHECKSUM_UNNECESSARY;
+			} else {
+				dprintk(KERN_DEBUG "%s: hwchecksum miss!.\n", dev->name);
+			}
+		}
+		/* got a valid packet - forward it to the network core */
+		skb_put(skb, len);
+		skb->protocol = eth_type_trans(skb, dev);
+		dprintk(KERN_DEBUG "%s: nv_rx_process: %d bytes, proto %d accepted.\n",
+					dev->name, len, skb->protocol);
+#ifdef CONFIG_FORCEDETH_NAPI
+		if (np->vlangrp && (vlanflags & NV_RX3_VLAN_TAG_PRESENT))
+			vlan_hwaccel_receive_skb(skb, np->vlangrp,
+						 vlanflags & NV_RX3_VLAN_TAG_MASK);
+		else
+			netif_receive_skb(skb);
+#else
+		if (np->vlangrp && (vlanflags & NV_RX3_VLAN_TAG_PRESENT))
+			vlan_hwaccel_rx(skb, np->vlangrp,
+					vlanflags & NV_RX3_VLAN_TAG_MASK);
+		else
+			netif_rx(skb);
+#endif
+		dev->last_rx = jiffies;
+		np->stats.rx_packets++;
+		np->stats.rx_bytes += len;
+next_pkt:
+		if (np->get_rx.ex++ == np->last_rx.ex)
+			np->get_rx.ex = np->first_rx.ex;
 		if (np->get_rx_ctx++ == np->last_rx_ctx)
 			np->get_rx_ctx = np->first_rx_ctx;
 	}
@@ -2655,6 +2901,117 @@
 	return IRQ_RETVAL(i);
 }
 
+static irqreturn_t nv_nic_irq_optimized(int foo, void *data)
+{
+	struct net_device *dev = (struct net_device *) data;
+	struct fe_priv *np = netdev_priv(dev);
+	u8 __iomem *base = get_hwbase(dev);
+	u32 events;
+	int i;
+
+	dprintk(KERN_DEBUG "%s: nv_nic_irq_optimized\n", dev->name);
+
+	for (i=0; ; i++) {
+		if (!(np->msi_flags & NV_MSI_X_ENABLED)) {
+			events = readl(base + NvRegIrqStatus) & NVREG_IRQSTAT_MASK;
+			writel(NVREG_IRQSTAT_MASK, base + NvRegIrqStatus);
+		} else {
+			events = readl(base + NvRegMSIXIrqStatus) & NVREG_IRQSTAT_MASK;
+			writel(NVREG_IRQSTAT_MASK, base + NvRegMSIXIrqStatus);
+		}
+		pci_push(base);
+		dprintk(KERN_DEBUG "%s: irq: %08x\n", dev->name, events);
+		if (!(events & np->irqmask))
+			break;
+
+		spin_lock(&np->lock);
+		nv_tx_done_optimized(dev);
+		spin_unlock(&np->lock);
+
+		if (events & NVREG_IRQ_LINK) {
+			spin_lock(&np->lock);
+			nv_link_irq(dev);
+			spin_unlock(&np->lock);
+		}
+		if (np->need_linktimer && time_after(jiffies, np->link_timeout)) {
+			spin_lock(&np->lock);
+			nv_linkchange(dev);
+			spin_unlock(&np->lock);
+			np->link_timeout = jiffies + LINK_TIMEOUT;
+		}
+		if (events & (NVREG_IRQ_TX_ERR)) {
+			dprintk(KERN_DEBUG "%s: received irq with events 0x%x. Probably TX fail.\n",
+						dev->name, events);
+		}
+		if (events & (NVREG_IRQ_UNKNOWN)) {
+			printk(KERN_DEBUG "%s: received irq with unknown events 0x%x. Please report\n",
+						dev->name, events);
+		}
+		if (unlikely(events & NVREG_IRQ_RECOVER_ERROR)) {
+			spin_lock(&np->lock);
+			/* disable interrupts on the nic */
+			if (!(np->msi_flags & NV_MSI_X_ENABLED))
+				writel(0, base + NvRegIrqMask);
+			else
+				writel(np->irqmask, base + NvRegIrqMask);
+			pci_push(base);
+
+			if (!np->in_shutdown) {
+				np->nic_poll_irq = np->irqmask;
+				np->recover_error = 1;
+				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
+			}
+			spin_unlock(&np->lock);
+			break;
+		}
+
+#ifdef CONFIG_FORCEDETH_NAPI
+		if (events & NVREG_IRQ_RX_ALL) {
+			netif_rx_schedule(dev);
+
+			/* Disable furthur receive irq's */
+			spin_lock(&np->lock);
+			np->irqmask &= ~NVREG_IRQ_RX_ALL;
+
+			if (np->msi_flags & NV_MSI_X_ENABLED)
+				writel(NVREG_IRQ_RX_ALL, base + NvRegIrqMask);
+			else
+				writel(np->irqmask, base + NvRegIrqMask);
+			spin_unlock(&np->lock);
+		}
+#else
+		nv_rx_process_optimized(dev, dev->weight);
+		if (nv_alloc_rx_optimized(dev)) {
+			spin_lock(&np->lock);
+			if (!np->in_shutdown)
+				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
+			spin_unlock(&np->lock);
+		}
+#endif
+		if (i > max_interrupt_work) {
+			spin_lock(&np->lock);
+			/* disable interrupts on the nic */
+			if (!(np->msi_flags & NV_MSI_X_ENABLED))
+				writel(0, base + NvRegIrqMask);
+			else
+				writel(np->irqmask, base + NvRegIrqMask);
+			pci_push(base);
+
+			if (!np->in_shutdown) {
+				np->nic_poll_irq = np->irqmask;
+				mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
+			}
+			printk(KERN_DEBUG "%s: too many iterations (%d) in nv_nic_irq.\n", dev->name, i);
+			spin_unlock(&np->lock);
+			break;
+		}
+
+	}
+	dprintk(KERN_DEBUG "%s: nv_nic_irq_optimized completed\n", dev->name);
+
+	return IRQ_RETVAL(i);
+}
+
 static irqreturn_t nv_nic_irq_tx(int foo, void *data)
 {
 	struct net_device *dev = (struct net_device *) data;
@@ -2675,7 +3032,7 @@
 			break;
 
 		spin_lock_irqsave(&np->lock, flags);
-		nv_tx_done(dev);
+		nv_tx_done_optimized(dev);
 		spin_unlock_irqrestore(&np->lock, flags);
 
 		if (events & (NVREG_IRQ_TX_ERR)) {
@@ -2711,7 +3068,10 @@
 	u8 __iomem *base = get_hwbase(dev);
 	unsigned long flags;
 
-	pkts = nv_rx_process(dev, limit);
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		pkts = nv_rx_process(dev, limit);
+	else
+		pkts = nv_rx_process_optimized(dev, limit);
 
 	if (nv_alloc_rx(dev)) {
 		spin_lock_irqsave(&np->lock, flags);
@@ -2782,8 +3142,8 @@
 		if (!(events & np->irqmask))
 			break;
 
-		nv_rx_process(dev, dev->weight);
-		if (nv_alloc_rx(dev)) {
+		nv_rx_process_optimized(dev, dev->weight);
+		if (nv_alloc_rx_optimized(dev)) {
 			spin_lock_irqsave(&np->lock, flags);
 			if (!np->in_shutdown)
 				mod_timer(&np->oom_kick, jiffies + OOM_REFILL);
@@ -2942,6 +3302,16 @@
 	u8 __iomem *base = get_hwbase(dev);
 	int ret = 1;
 	int i;
+	irqreturn_t (*handler)(int foo, void *data);
+
+	if (intr_test) {
+		handler = nv_nic_irq_test;
+	} else {
+		if (np->desc_ver == DESC_VER_3)
+			handler = nv_nic_irq_optimized;
+		else
+			handler = nv_nic_irq;
+	}
 
 	if (np->msi_flags & NV_MSI_X_CAPABLE) {
 		for (i = 0; i < (np->msi_flags & NV_MSI_X_VECTORS_MASK); i++) {
@@ -2979,10 +3349,7 @@
 				set_msix_vector_map(dev, NV_MSI_X_VECTOR_OTHER, NVREG_IRQ_OTHER);
 			} else {
 				/* Request irq for all interrupts */
-				if ((!intr_test &&
-				     request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector, &nv_nic_irq, IRQF_SHARED, dev->name, dev) != 0) ||
-				    (intr_test &&
-				     request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector, &nv_nic_irq_test, IRQF_SHARED, dev->name, dev) != 0)) {
+				if (request_irq(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector, handler, IRQF_SHARED, dev->name, dev) != 0) {
 					printk(KERN_INFO "forcedeth: request_irq failed %d\n", ret);
 					pci_disable_msix(np->pci_dev);
 					np->msi_flags &= ~NV_MSI_X_ENABLED;
@@ -2998,8 +3365,7 @@
 	if (ret != 0 && np->msi_flags & NV_MSI_CAPABLE) {
 		if ((ret = pci_enable_msi(np->pci_dev)) == 0) {
 			np->msi_flags |= NV_MSI_ENABLED;
-			if ((!intr_test && request_irq(np->pci_dev->irq, &nv_nic_irq, IRQF_SHARED, dev->name, dev) != 0) ||
-			    (intr_test && request_irq(np->pci_dev->irq, &nv_nic_irq_test, IRQF_SHARED, dev->name, dev) != 0)) {
+			if (request_irq(np->pci_dev->irq, handler, IRQF_SHARED, dev->name, dev) != 0) {
 				printk(KERN_INFO "forcedeth: request_irq failed %d\n", ret);
 				pci_disable_msi(np->pci_dev);
 				np->msi_flags &= ~NV_MSI_ENABLED;
@@ -3014,8 +3380,7 @@
 		}
 	}
 	if (ret != 0) {
-		if ((!intr_test && request_irq(np->pci_dev->irq, &nv_nic_irq, IRQF_SHARED, dev->name, dev) != 0) ||
-		    (intr_test && request_irq(np->pci_dev->irq, &nv_nic_irq_test, IRQF_SHARED, dev->name, dev) != 0))
+		if (request_irq(np->pci_dev->irq, handler, IRQF_SHARED, dev->name, dev) != 0)
 			goto out_err;
 
 	}
@@ -4629,7 +4994,10 @@
 
 	dev->open = nv_open;
 	dev->stop = nv_close;
-	dev->hard_start_xmit = nv_start_xmit;
+	if (np->desc_ver == DESC_VER_1 || np->desc_ver == DESC_VER_2)
+		dev->hard_start_xmit = nv_start_xmit;
+	else
+		dev->hard_start_xmit = nv_start_xmit_optimized;
 	dev->get_stats = nv_get_stats;
 	dev->change_mtu = nv_change_mtu;
 	dev->set_mac_address = nv_set_mac_address;

--------------060904070201070709050203--
