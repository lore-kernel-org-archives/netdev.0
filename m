From: Ayaz Abdulla <aabdulla@nvidia.com>
Subject: [PATCH 7/12] forcedeth: tx data path optimization
Date: Tue, 09 Jan 2007 13:30:20 -0500
Message-ID: <45A3DF3C.9060507@nvidia.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060204020006050305090808"
Return-path: <netdev-owner@vger.kernel.org>
Received: from hqemgate01.nvidia.com ([216.228.112.170]:5138 "EHLO
	HQEMGATE01.nvidia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932390AbXAIVXR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jan 2007 16:23:17 -0500
To: Jeff Garzik <jgarzik@pobox.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060204020006050305090808
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

This patch optimizes the tx data paths and cleans up the code (removes 
vlan from descr1/2 since only valid for desc3, changes to make code 
easier to read, etc).

Signed-Off-By: Ayaz Abdulla <aabdulla@nvidia.com>


--------------060204020006050305090808
Content-Type: text/plain;
 name="patch-tx-opti-cleanup"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch-tx-opti-cleanup"

--- orig/drivers/net/forcedeth.c	2007-01-08 14:05:28.000000000 -0500
+++ new/drivers/net/forcedeth.c	2007-01-08 14:05:19.000000000 -0500
@@ -1563,7 +1563,6 @@
 	u32 size = skb->len-skb->data_len;
 	u32 entries = (size >> NV_TX2_TSO_MAX_SHIFT) + ((size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	u32 empty_slots;
-	u32 tx_flags_vlan = 0;
 	struct ring_desc* put_tx;
 	struct ring_desc* start_tx;
 	struct ring_desc* prev_tx;
@@ -1576,7 +1575,7 @@
 	}
 
 	empty_slots = nv_get_empty_tx_slots(np);
-	if (empty_slots <= entries) {
+	if (unlikely(empty_slots <= entries)) {
 		spin_lock_irq(&np->lock);
 		netif_stop_queue(dev);
 		np->tx_stop = 1;
@@ -1596,12 +1595,13 @@
 		np->put_tx_ctx->dma_len = bcnt;
 		put_tx->buf = cpu_to_le32(np->put_tx_ctx->dma);
 		put_tx->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
+
 		tx_flags = np->tx_flags;
 		offset += bcnt;
 		size -= bcnt;
-		if (put_tx++ == np->last_tx.orig)
+		if (unlikely(put_tx++ == np->last_tx.orig))
 			put_tx = np->first_tx.orig;
-		if (np->put_tx_ctx++ == np->last_tx_ctx)
+		if (unlikely(np->put_tx_ctx++ == np->last_tx_ctx))
 			np->put_tx_ctx = np->first_tx_ctx;
 	} while (size);
 
@@ -1618,14 +1618,14 @@
 			np->put_tx_ctx->dma = pci_map_page(np->pci_dev, frag->page, frag->page_offset+offset, bcnt,
 							   PCI_DMA_TODEVICE);
 			np->put_tx_ctx->dma_len = bcnt;
-
 			put_tx->buf = cpu_to_le32(np->put_tx_ctx->dma);
 			put_tx->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
+
 			offset += bcnt;
 			size -= bcnt;
-			if (put_tx++ == np->last_tx.orig)
+			if (unlikely(put_tx++ == np->last_tx.orig))
 				put_tx = np->first_tx.orig;
-			if (np->put_tx_ctx++ == np->last_tx_ctx)
+			if (unlikely(np->put_tx_ctx++ == np->last_tx_ctx))
 				np->put_tx_ctx = np->first_tx_ctx;
 		} while (size);
 	}
@@ -1642,11 +1642,6 @@
 		tx_flags_extra = skb->ip_summed == CHECKSUM_PARTIAL ?
 			 NV_TX2_CHECKSUM_L3 | NV_TX2_CHECKSUM_L4 : 0;
 
-	/* vlan tag */
-	if (np->vlangrp && vlan_tx_tag_present(skb)) {
-		tx_flags_vlan = NV_TX3_VLAN_TAG_PRESENT | vlan_tx_tag_get(skb);
-	}
-
 	spin_lock_irq(&np->lock);
 
 	/* set tx flags */
@@ -1669,7 +1664,6 @@
 
 	dev->trans_start = jiffies;
 	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
-	pci_push(get_hwbase(dev));
 	return NETDEV_TX_OK;
 }
 
@@ -1677,7 +1671,7 @@
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 tx_flags = 0;
-	u32 tx_flags_extra = NV_TX2_LASTPACKET;
+	u32 tx_flags_extra;
 	unsigned int fragments = skb_shinfo(skb)->nr_frags;
 	unsigned int i;
 	u32 offset = 0;
@@ -1685,7 +1679,6 @@
 	u32 size = skb->len-skb->data_len;
 	u32 entries = (size >> NV_TX2_TSO_MAX_SHIFT) + ((size & (NV_TX2_TSO_MAX_SIZE-1)) ? 1 : 0);
 	u32 empty_slots;
-	u32 tx_flags_vlan = 0;
 	struct ring_desc_ex* put_tx;
 	struct ring_desc_ex* start_tx;
 	struct ring_desc_ex* prev_tx;
@@ -1698,7 +1691,7 @@
 	}
 
 	empty_slots = nv_get_empty_tx_slots(np);
-	if (empty_slots <= entries) {
+	if (unlikely(empty_slots <= entries)) {
 		spin_lock_irq(&np->lock);
 		netif_stop_queue(dev);
 		np->tx_stop = 1;
@@ -1719,12 +1712,13 @@
 		put_tx->bufhigh = cpu_to_le64(np->put_tx_ctx->dma) >> 32;
 		put_tx->buflow = cpu_to_le64(np->put_tx_ctx->dma) & 0x0FFFFFFFF;
 		put_tx->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
-		tx_flags = np->tx_flags;
+
+		tx_flags = NV_TX2_VALID;
 		offset += bcnt;
 		size -= bcnt;
-		if (put_tx++ == np->last_tx.ex)
+		if (unlikely(put_tx++ == np->last_tx.ex))
 			put_tx = np->first_tx.ex;
-		if (np->put_tx_ctx++ == np->last_tx_ctx)
+		if (unlikely(np->put_tx_ctx++ == np->last_tx_ctx))
 			np->put_tx_ctx = np->first_tx_ctx;
 	} while (size);
 
@@ -1741,21 +1735,21 @@
 			np->put_tx_ctx->dma = pci_map_page(np->pci_dev, frag->page, frag->page_offset+offset, bcnt,
 							   PCI_DMA_TODEVICE);
 			np->put_tx_ctx->dma_len = bcnt;
-
 			put_tx->bufhigh = cpu_to_le64(np->put_tx_ctx->dma) >> 32;
 			put_tx->buflow = cpu_to_le64(np->put_tx_ctx->dma) & 0x0FFFFFFFF;
 			put_tx->flaglen = cpu_to_le32((bcnt-1) | tx_flags);
+
 			offset += bcnt;
 			size -= bcnt;
-			if (put_tx++ == np->last_tx.ex)
+			if (unlikely(put_tx++ == np->last_tx.ex))
 				put_tx = np->first_tx.ex;
-			if (np->put_tx_ctx++ == np->last_tx_ctx)
+			if (unlikely(np->put_tx_ctx++ == np->last_tx_ctx))
 				np->put_tx_ctx = np->first_tx_ctx;
 		} while (size);
 	}
 
 	/* set last fragment flag  */
-	prev_tx->flaglen |= cpu_to_le32(tx_flags_extra);
+	prev_tx->flaglen |= cpu_to_le32(NV_TX2_LASTPACKET);
 
 	/* save skb in this slot's context area */
 	prev_tx_ctx->skb = skb;
@@ -1767,14 +1761,18 @@
 			 NV_TX2_CHECKSUM_L3 | NV_TX2_CHECKSUM_L4 : 0;
 
 	/* vlan tag */
-	if (np->vlangrp && vlan_tx_tag_present(skb)) {
-		tx_flags_vlan = NV_TX3_VLAN_TAG_PRESENT | vlan_tx_tag_get(skb);
+	if (likely(!np->vlangrp)) {
+		start_tx->txvlan = 0;
+	} else {
+		if (vlan_tx_tag_present(skb))
+			start_tx->txvlan = cpu_to_le32(NV_TX3_VLAN_TAG_PRESENT | vlan_tx_tag_get(skb));
+		else
+			start_tx->txvlan = 0;
 	}
 
 	spin_lock_irq(&np->lock);
 
 	/* set tx flags */
-	start_tx->txvlan = cpu_to_le32(tx_flags_vlan);
 	start_tx->flaglen |= cpu_to_le32(tx_flags | tx_flags_extra);
 	np->put_tx.ex = put_tx;
 
@@ -1794,7 +1792,6 @@
 
 	dev->trans_start = jiffies;
 	writel(NVREG_TXRXCTL_KICK|np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
-	pci_push(get_hwbase(dev));
 	return NETDEV_TX_OK;
 }
 
@@ -1807,21 +1804,22 @@
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
-	struct sk_buff *skb;
 	struct ring_desc* orig_get_tx = np->get_tx.orig;
 
- 	while (np->get_tx.orig != np->put_tx.orig) {
-		flags = le32_to_cpu(np->get_tx.orig->flaglen);
+	while ((np->get_tx.orig != np->put_tx.orig) &&
+	       !((flags = le32_to_cpu(np->get_tx.orig->flaglen)) & NV_TX_VALID)) {
 
 		dprintk(KERN_DEBUG "%s: nv_tx_done: flags 0x%x.\n",
 					dev->name, flags);
-		if (flags & NV_TX_VALID)
-			break;
+
+		pci_unmap_page(np->pci_dev, np->get_tx_ctx->dma,
+			       np->get_tx_ctx->dma_len,
+			       PCI_DMA_TODEVICE);
+		np->get_tx_ctx->dma = 0;
+
 		if (np->desc_ver == DESC_VER_1) {
 			if (flags & NV_TX_LASTPACKET) {
-				skb = np->get_tx_ctx->skb;
-				if (flags & (NV_TX_RETRYERROR|NV_TX_CARRIERLOST|NV_TX_LATECOLLISION|
-					     NV_TX_UNDERFLOW|NV_TX_ERROR)) {
+				if (flags & NV_TX_ERROR) {
 					if (flags & NV_TX_UNDERFLOW)
 						np->stats.tx_fifo_errors++;
 					if (flags & NV_TX_CARRIERLOST)
@@ -1829,14 +1827,14 @@
 					np->stats.tx_errors++;
 				} else {
 					np->stats.tx_packets++;
-					np->stats.tx_bytes += skb->len;
+					np->stats.tx_bytes += np->get_tx_ctx->skb->len;
 				}
+				dev_kfree_skb_any(np->get_tx_ctx->skb);
+				np->get_tx_ctx->skb = NULL;
 			}
 		} else {
 			if (flags & NV_TX2_LASTPACKET) {
-				skb = np->get_tx_ctx->skb;
-				if (flags & (NV_TX2_RETRYERROR|NV_TX2_CARRIERLOST|NV_TX2_LATECOLLISION|
-					     NV_TX2_UNDERFLOW|NV_TX2_ERROR)) {
+				if (flags & NV_TX2_ERROR) {
 					if (flags & NV_TX2_UNDERFLOW)
 						np->stats.tx_fifo_errors++;
 					if (flags & NV_TX2_CARRIERLOST)
@@ -1844,17 +1842,18 @@
 					np->stats.tx_errors++;
 				} else {
 					np->stats.tx_packets++;
-					np->stats.tx_bytes += skb->len;
+					np->stats.tx_bytes += np->get_tx_ctx->skb->len;
 				}
+				dev_kfree_skb_any(np->get_tx_ctx->skb);
+				np->get_tx_ctx->skb = NULL;
 			}
 		}
-		nv_release_txskb(dev, np->get_tx_ctx);
-		if (np->get_tx.orig++ == np->last_tx.orig)
+		if (unlikely(np->get_tx.orig++ == np->last_tx.orig))
 			np->get_tx.orig = np->first_tx.orig;
-		if (np->get_tx_ctx++ == np->last_tx_ctx)
+		if (unlikely(np->get_tx_ctx++ == np->last_tx_ctx))
 			np->get_tx_ctx = np->first_tx_ctx;
 	}
-	if ((np->tx_stop == 1) && (np->get_tx.orig != orig_get_tx)) {
+	if (unlikely((np->tx_stop == 1) && (np->get_tx.orig != orig_get_tx))) {
 		np->tx_stop = 0;
 		netif_wake_queue(dev);
 	}
@@ -1864,20 +1863,21 @@
 {
 	struct fe_priv *np = netdev_priv(dev);
 	u32 flags;
-	struct sk_buff *skb;
 	struct ring_desc_ex* orig_get_tx = np->get_tx.ex;
 
- 	while (np->get_tx.ex == np->put_tx.ex) {
-		flags = le32_to_cpu(np->get_tx.ex->flaglen);
+	while ((np->get_tx.ex != np->put_tx.ex) &&
+	       !((flags = le32_to_cpu(np->get_tx.ex->flaglen)) & NV_TX_VALID)) {
 
 		dprintk(KERN_DEBUG "%s: nv_tx_done_optimized: flags 0x%x.\n",
 					dev->name, flags);
-		if (flags & NV_TX_VALID)
-			break;
+
+		pci_unmap_page(np->pci_dev, np->get_tx_ctx->dma,
+			       np->get_tx_ctx->dma_len,
+			       PCI_DMA_TODEVICE);
+		np->get_tx_ctx->dma = 0;
+
 		if (flags & NV_TX2_LASTPACKET) {
-			skb = np->get_tx_ctx->skb;
-			if (flags & (NV_TX2_RETRYERROR|NV_TX2_CARRIERLOST|NV_TX2_LATECOLLISION|
-				     NV_TX2_UNDERFLOW|NV_TX2_ERROR)) {
+			if (flags & NV_TX2_ERROR) {
 				if (flags & NV_TX2_UNDERFLOW)
 					np->stats.tx_fifo_errors++;
 				if (flags & NV_TX2_CARRIERLOST)
@@ -1885,16 +1885,17 @@
 				np->stats.tx_errors++;
 			} else {
 				np->stats.tx_packets++;
-				np->stats.tx_bytes += skb->len;
+				np->stats.tx_bytes += np->get_tx_ctx->skb->len;
 			}
+			dev_kfree_skb_any(np->get_tx_ctx->skb);
+			np->get_tx_ctx->skb = NULL;
 		}
-		nv_release_txskb(dev, np->get_tx_ctx);
-		if (np->get_tx.ex++ == np->last_tx.ex)
+		if (unlikely(np->get_tx.ex++ == np->last_tx.ex))
 			np->get_tx.ex = np->first_tx.ex;
-		if (np->get_tx_ctx++ == np->last_tx_ctx)
+		if (unlikely(np->get_tx_ctx++ == np->last_tx_ctx))
 			np->get_tx_ctx = np->first_tx_ctx;
 	}
-	if ((np->tx_stop == 1) && (np->get_tx.ex != orig_get_tx)) {
+	if (unlikely((np->tx_stop == 1) && (np->get_tx.ex != orig_get_tx))) {
 		np->tx_stop = 0;
 		netif_wake_queue(dev);
 	}

--------------060204020006050305090808--
