From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/7] sky2: optimize transmit completion
Date: Tue, 18 Aug 2009 18:17:09 -0700
Message-ID: <20090819011738.913627761@vyatta.com>
References: <20090819011704.685802801@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:50671 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750888AbZHSBWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 21:22:45 -0400
Content-Disposition: inline; filename=sky2-tx-re.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't reference the list element in hardware transmit ring on transmit
completion. The list element is updated by hardware, therefore
it causes a cache miss. Do book keeping in software structure.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/sky2.c	2009-08-18 10:50:35.096988776 -0700
+++ b/drivers/net/sky2.c	2009-08-18 11:27:05.272209365 -0700
@@ -1001,8 +1001,11 @@ static void sky2_prefetch_init(struct sk
 static inline struct sky2_tx_le *get_tx_le(struct sky2_port *sky2, u16 *slot)
 {
 	struct sky2_tx_le *le = sky2->tx_le + *slot;
+	struct tx_ring_info *re = sky2->tx_ring + *slot;
 
 	*slot = RING_NEXT(*slot, sky2->tx_ring_size);
+	re->flags = 0;
+	re->skb = NULL;
 	le->ctrl = 0;
 	return le;
 }
@@ -1021,12 +1024,6 @@ static void tx_init(struct sky2_port *sk
 	sky2->tx_last_upper = 0;
 }
 
-static inline struct tx_ring_info *tx_le_re(struct sky2_port *sky2,
-					    struct sky2_tx_le *le)
-{
-	return sky2->tx_ring + (le - sky2->tx_le);
-}
-
 /* Update chip's next pointer */
 static inline void sky2_put_idx(struct sky2_hw *hw, unsigned q, u16 idx)
 {
@@ -1563,6 +1560,19 @@ static unsigned tx_le_req(const struct s
 	return count;
 }
 
+static void sky2_tx_unmap(struct pci_dev *pdev,
+			  const struct tx_ring_info *re)
+{
+	if (re->flags & TX_MAP_SINGLE)
+		pci_unmap_single(pdev, pci_unmap_addr(re, mapaddr),
+				 pci_unmap_len(re, maplen),
+				 PCI_DMA_TODEVICE);
+	else if (re->flags & TX_MAP_PAGE)
+		pci_unmap_page(pdev, pci_unmap_addr(re, mapaddr),
+			       pci_unmap_len(re, maplen),
+			       PCI_DMA_TODEVICE);
+}
+
 /*
  * Put one packet in ring for transmit.
  * A single packet can generate multiple list elements, and
@@ -1667,16 +1677,17 @@ static int sky2_xmit_frame(struct sk_buf
 		}
 	}
 
+	re = sky2->tx_ring + slot;
+	re->flags = TX_MAP_SINGLE;
+	pci_unmap_addr_set(re, mapaddr, mapping);
+	pci_unmap_len_set(re, maplen, len);
+
 	le = get_tx_le(sky2, &slot);
 	le->addr = cpu_to_le32(lower_32_bits(mapping));
 	le->length = cpu_to_le16(len);
 	le->ctrl = ctrl;
 	le->opcode = mss ? (OP_LARGESEND | HW_OWNER) : (OP_PACKET | HW_OWNER);
 
-	re = tx_le_re(sky2, le);
-	re->skb = skb;
-	pci_unmap_addr_set(re, mapaddr, mapping);
-	pci_unmap_len_set(re, maplen, len);
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
@@ -1695,18 +1706,19 @@ static int sky2_xmit_frame(struct sk_buf
 			le->opcode = OP_ADDR64 | HW_OWNER;
 		}
 
+		re = sky2->tx_ring + slot;
+		re->flags = TX_MAP_PAGE;
+		pci_unmap_addr_set(re, mapaddr, mapping);
+		pci_unmap_len_set(re, maplen, frag->size);
+
 		le = get_tx_le(sky2, &slot);
 		le->addr = cpu_to_le32(lower_32_bits(mapping));
 		le->length = cpu_to_le16(frag->size);
 		le->ctrl = ctrl;
 		le->opcode = OP_BUFFER | HW_OWNER;
-
-		re = tx_le_re(sky2, le);
-		re->skb = skb;
-		pci_unmap_addr_set(re, mapaddr, mapping);
-		pci_unmap_len_set(re, maplen, frag->size);
 	}
 
+	re->skb = skb;
 	le->ctrl |= EOP;
 
 	sky2->tx_prod = slot;
@@ -1720,23 +1732,9 @@ static int sky2_xmit_frame(struct sk_buf
 
 mapping_unwind:
 	for (i = sky2->tx_prod; i != slot; i = RING_NEXT(i, sky2->tx_ring_size)) {
-		le = sky2->tx_le + i;
 		re = sky2->tx_ring + i;
 
-		switch(le->opcode & ~HW_OWNER) {
-		case OP_LARGESEND:
-		case OP_PACKET:
-			pci_unmap_single(hw->pdev,
-					 pci_unmap_addr(re, mapaddr),
-					 pci_unmap_len(re, maplen),
-					 PCI_DMA_TODEVICE);
-			break;
-		case OP_BUFFER:
-			pci_unmap_page(hw->pdev, pci_unmap_addr(re, mapaddr),
-				       pci_unmap_len(re, maplen),
-				       PCI_DMA_TODEVICE);
-			break;
-		}
+		sky2_tx_unmap(hw->pdev, re);
 	}
 
 mapping_error:
@@ -1759,34 +1757,18 @@ mapping_error:
 static void sky2_tx_complete(struct sky2_port *sky2, u16 done)
 {
 	struct net_device *dev = sky2->netdev;
-	struct pci_dev *pdev = sky2->hw->pdev;
 	unsigned idx;
 
 	BUG_ON(done >= sky2->tx_ring_size);
 
 	for (idx = sky2->tx_cons; idx != done;
 	     idx = RING_NEXT(idx, sky2->tx_ring_size)) {
-		struct sky2_tx_le *le = sky2->tx_le + idx;
 		struct tx_ring_info *re = sky2->tx_ring + idx;
+		struct sk_buff *skb = re->skb;
 
-		switch(le->opcode & ~HW_OWNER) {
-		case OP_LARGESEND:
-		case OP_PACKET:
-			pci_unmap_single(pdev,
-					 pci_unmap_addr(re, mapaddr),
-					 pci_unmap_len(re, maplen),
-					 PCI_DMA_TODEVICE);
-			break;
-		case OP_BUFFER:
-			pci_unmap_page(pdev, pci_unmap_addr(re, mapaddr),
-				       pci_unmap_len(re, maplen),
-				       PCI_DMA_TODEVICE);
-			break;
-		}
-
-		if (le->ctrl & EOP) {
-			struct sk_buff *skb = re->skb;
+		sky2_tx_unmap(sky2->hw->pdev, re);
 
+		if (skb) {
 			if (unlikely(netif_msg_tx_done(sky2)))
 				printk(KERN_DEBUG "%s: tx done %u\n",
 				       dev->name, idx);
--- a/drivers/net/sky2.h	2009-08-18 10:50:35.110991954 -0700
+++ b/drivers/net/sky2.h	2009-08-18 11:09:06.181966221 -0700
@@ -1984,6 +1984,9 @@ struct sky2_status_le {
 
 struct tx_ring_info {
 	struct sk_buff	*skb;
+	unsigned long flags;
+#define TX_MAP_SINGLE   0x0001
+#define TX_MAP_PAGE     000002
 	DECLARE_PCI_UNMAP_ADDR(mapaddr);
 	DECLARE_PCI_UNMAP_LEN(maplen);
 };

-- 

