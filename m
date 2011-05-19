From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 02/13] tg3: Cleanup transmit error path
Date: Thu, 19 May 2011 15:12:45 -0700
Message-ID: <1305843176-32358-3-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1085 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933350Ab1ESVxY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2011 17:53:24 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch consolidates the skb cleanup code into a function named
tg3_skb_error_unmap().  The modification addresses a long-standing bug
where pci_unmap_single() was incorrectly being called instead of
pci_unmap_page() in tigon3_dma_hwbug_workaround().

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |   98 ++++++++++++++++++++--------------------------------
 1 files changed, 38 insertions(+), 60 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4c44168..b2b1ba1 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -5758,16 +5758,39 @@ static void tg3_set_txd(struct tg3_napi *tnapi, int entry,
 	txd->vlan_tag = vlan_tag << TXD_VLAN_TAG_SHIFT;
 }
 
+static void tg3_skb_error_unmap(struct tg3_napi *tnapi,
+				struct sk_buff *skb, int last)
+{
+	int i;
+	u32 entry = tnapi->tx_prod;
+	struct ring_info *txb = &tnapi->tx_buffers[entry];
+
+	pci_unmap_single(tnapi->tp->pdev,
+			 dma_unmap_addr(txb, mapping),
+			 skb_headlen(skb),
+			 PCI_DMA_TODEVICE);
+	for (i = 0; i <= last; i++) {
+		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+
+		entry = NEXT_TX(entry);
+		txb = &tnapi->tx_buffers[entry];
+
+		pci_unmap_page(tnapi->tp->pdev,
+			       dma_unmap_addr(txb, mapping),
+			       frag->size, PCI_DMA_TODEVICE);
+	}
+}
+
 /* Workaround 4GB and 40-bit hardware DMA bugs. */
 static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
-				       struct sk_buff *skb, u32 last_plus_one,
-				       u32 *start, u32 base_flags, u32 mss)
+				       struct sk_buff *skb,
+				       u32 base_flags, u32 mss)
 {
 	struct tg3 *tp = tnapi->tp;
 	struct sk_buff *new_skb;
 	dma_addr_t new_addr = 0;
-	u32 entry = *start;
-	int i, ret = 0;
+	u32 entry = tnapi->tx_prod;
+	int ret = 0;
 
 	if (GET_ASIC_REV(tp->pci_chip_rev_id) != ASIC_REV_5701)
 		new_skb = skb_copy(skb, GFP_ATOMIC);
@@ -5783,14 +5806,12 @@ static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
 		ret = -1;
 	} else {
 		/* New SKB is guaranteed to be linear. */
-		entry = *start;
 		new_addr = pci_map_single(tp->pdev, new_skb->data, new_skb->len,
 					  PCI_DMA_TODEVICE);
 		/* Make sure the mapping succeeded */
 		if (pci_dma_mapping_error(tp->pdev, new_addr)) {
 			ret = -1;
 			dev_kfree_skb(new_skb);
-			new_skb = NULL;
 
 		/* Make sure new skb does not cross any 4G boundaries.
 		 * Drop the packet if it does.
@@ -5801,39 +5822,16 @@ static int tigon3_dma_hwbug_workaround(struct tg3_napi *tnapi,
 					 PCI_DMA_TODEVICE);
 			ret = -1;
 			dev_kfree_skb(new_skb);
-			new_skb = NULL;
 		} else {
+			tnapi->tx_buffers[entry].skb = new_skb;
+			dma_unmap_addr_set(&tnapi->tx_buffers[entry],
+					   mapping, new_addr);
+
 			tg3_set_txd(tnapi, entry, new_addr, new_skb->len,
 				    base_flags, 1 | (mss << 1));
-			*start = NEXT_TX(entry);
 		}
 	}
 
-	/* Now clean up the sw ring entries. */
-	i = 0;
-	while (entry != last_plus_one) {
-		int len;
-
-		if (i == 0)
-			len = skb_headlen(skb);
-		else
-			len = skb_shinfo(skb)->frags[i-1].size;
-
-		pci_unmap_single(tp->pdev,
-				 dma_unmap_addr(&tnapi->tx_buffers[entry],
-						mapping),
-				 len, PCI_DMA_TODEVICE);
-		if (i == 0) {
-			tnapi->tx_buffers[entry].skb = new_skb;
-			dma_unmap_addr_set(&tnapi->tx_buffers[entry], mapping,
-					   new_addr);
-		} else {
-			tnapi->tx_buffers[entry].skb = NULL;
-		}
-		entry = NEXT_TX(entry);
-		i++;
-	}
-
 	dev_kfree_skb(skb);
 
 	return ret;
@@ -5889,11 +5887,11 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct tg3 *tp = netdev_priv(dev);
 	u32 len, entry, base_flags, mss;
-	int would_hit_hwbug;
+	int i = -1, would_hit_hwbug;
 	dma_addr_t mapping;
 	struct tg3_napi *tnapi;
 	struct netdev_queue *txq;
-	unsigned int i, last;
+	unsigned int last;
 
 	txq = netdev_get_tx_queue(dev, skb_get_queue_mapping(skb));
 	tnapi = &tp->napi[skb_get_queue_mapping(skb)];
@@ -6074,20 +6072,15 @@ static netdev_tx_t tg3_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	if (would_hit_hwbug) {
-		u32 last_plus_one = entry;
-		u32 start;
-
-		start = entry - 1 - skb_shinfo(skb)->nr_frags;
-		start &= (TG3_TX_RING_SIZE - 1);
+		tg3_skb_error_unmap(tnapi, skb, i);
 
 		/* If the workaround fails due to memory/mapping
 		 * failure, silently drop this packet.
 		 */
-		if (tigon3_dma_hwbug_workaround(tnapi, skb, last_plus_one,
-						&start, base_flags, mss))
+		if (tigon3_dma_hwbug_workaround(tnapi, skb, base_flags, mss))
 			goto out_unlock;
 
-		entry = start;
+		entry = NEXT_TX(tnapi->tx_prod);
 	}
 
 	/* Packets are ready, update Tx producer idx local and on card. */
@@ -6113,24 +6106,9 @@ out_unlock:
 	return NETDEV_TX_OK;
 
 dma_error:
-	last = i;
-	entry = tnapi->tx_prod;
-	tnapi->tx_buffers[entry].skb = NULL;
-	pci_unmap_single(tp->pdev,
-			 dma_unmap_addr(&tnapi->tx_buffers[entry], mapping),
-			 skb_headlen(skb),
-			 PCI_DMA_TODEVICE);
-	for (i = 0; i <= last; i++) {
-		skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
-		entry = NEXT_TX(entry);
-
-		pci_unmap_page(tp->pdev,
-			       dma_unmap_addr(&tnapi->tx_buffers[entry],
-					      mapping),
-			       frag->size, PCI_DMA_TODEVICE);
-	}
-
+	tg3_skb_error_unmap(tnapi, skb, i);
 	dev_kfree_skb(skb);
+	tnapi->tx_buffers[tnapi->tx_prod].skb = NULL;
 	return NETDEV_TX_OK;
 }
 
-- 
1.7.3.4


