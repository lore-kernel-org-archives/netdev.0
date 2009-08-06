From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/8] sky2: Avoid rewinding sky2->tx_prod
Date: Thu, 06 Aug 2009 09:12:15 -0700
Message-ID: <20090806161232.601728020@vyatta.com>
References: <20090806161213.148382653@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:38262 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756206AbZHFQon (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2009 12:44:43 -0400
Content-Disposition: inline; filename=sky2-tx1.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather than moving the next used transmit ring index forward
then backing it up in the case of DMA mapping failure, cleaner
to use local variable.

Signed-off-by: Mike McCormack <mikem@ring3k.org>
Acked-by: Stephen Hemminger <shemminger@vyatta.com>

---
 drivers/net/sky2.c |   34 ++++++++++++++++++----------------
 1 files changed, 18 insertions(+), 16 deletions(-)

--- a/drivers/net/sky2.c	2009-08-03 08:43:26.300080050 -0700
+++ b/drivers/net/sky2.c	2009-08-03 09:12:07.929961591 -0700
@@ -989,11 +989,11 @@ static void sky2_prefetch_init(struct sk
 	sky2_read32(hw, Y2_QADDR(qaddr, PREF_UNIT_CTRL));
 }
 
-static inline struct sky2_tx_le *get_tx_le(struct sky2_port *sky2)
+static inline struct sky2_tx_le *get_tx_le(struct sky2_port *sky2, u16 *slot)
 {
-	struct sky2_tx_le *le = sky2->tx_le + sky2->tx_prod;
+	struct sky2_tx_le *le = sky2->tx_le + *slot;
 
-	sky2->tx_prod = RING_NEXT(sky2->tx_prod, TX_RING_SIZE);
+	*slot = RING_NEXT(*slot, TX_RING_SIZE);
 	le->ctrl = 0;
 	return le;
 }
@@ -1006,7 +1006,7 @@ static void tx_init(struct sky2_port *sk
 	sky2->tx_tcpsum = 0;
 	sky2->tx_last_mss = 0;
 
-	le = get_tx_le(sky2);
+	le = get_tx_le(sky2, &sky2->tx_prod);
 	le->addr = 0;
 	le->opcode = OP_ADDR64 | HW_OWNER;
 }
@@ -1565,7 +1565,8 @@ static int sky2_xmit_frame(struct sk_buf
 	struct sky2_hw *hw = sky2->hw;
 	struct sky2_tx_le *le = NULL;
 	struct tx_ring_info *re;
-	unsigned i, len, first_slot;
+	unsigned i, len;
+	u16 slot;
 	dma_addr_t mapping;
 	u16 mss;
 	u8 ctrl;
@@ -1579,14 +1580,14 @@ static int sky2_xmit_frame(struct sk_buf
 	if (pci_dma_mapping_error(hw->pdev, mapping))
 		goto mapping_error;
 
-	first_slot = sky2->tx_prod;
+	slot = sky2->tx_prod;
 	if (unlikely(netif_msg_tx_queued(sky2)))
 		printk(KERN_DEBUG "%s: tx queued, slot %u, len %d\n",
-		       dev->name, first_slot, skb->len);
+		       dev->name, slot, skb->len);
 
 	/* Send high bits if needed */
 	if (sizeof(dma_addr_t) > sizeof(u32)) {
-		le = get_tx_le(sky2);
+		le = get_tx_le(sky2, &slot);
 		le->addr = cpu_to_le32(upper_32_bits(mapping));
 		le->opcode = OP_ADDR64 | HW_OWNER;
 	}
@@ -1599,7 +1600,7 @@ static int sky2_xmit_frame(struct sk_buf
 			mss += ETH_HLEN + ip_hdrlen(skb) + tcp_hdrlen(skb);
 
   		if (mss != sky2->tx_last_mss) {
-  			le = get_tx_le(sky2);
+			le = get_tx_le(sky2, &slot);
   			le->addr = cpu_to_le32(mss);
 
 			if (hw->flags & SKY2_HW_NEW_LE)
@@ -1615,7 +1616,7 @@ static int sky2_xmit_frame(struct sk_buf
 	/* Add VLAN tag, can piggyback on LRGLEN or ADDR64 */
 	if (sky2->vlgrp && vlan_tx_tag_present(skb)) {
 		if (!le) {
-			le = get_tx_le(sky2);
+			le = get_tx_le(sky2, &slot);
 			le->addr = 0;
 			le->opcode = OP_VLAN|HW_OWNER;
 		} else
@@ -1644,7 +1645,7 @@ static int sky2_xmit_frame(struct sk_buf
 			if (tcpsum != sky2->tx_tcpsum) {
 				sky2->tx_tcpsum = tcpsum;
 
-				le = get_tx_le(sky2);
+				le = get_tx_le(sky2, &slot);
 				le->addr = cpu_to_le32(tcpsum);
 				le->length = 0;	/* initial checksum value */
 				le->ctrl = 1;	/* one packet */
@@ -1653,7 +1654,7 @@ static int sky2_xmit_frame(struct sk_buf
 		}
 	}
 
-	le = get_tx_le(sky2);
+	le = get_tx_le(sky2, &slot);
 	le->addr = cpu_to_le32((u32) mapping);
 	le->length = cpu_to_le16(len);
 	le->ctrl = ctrl;
@@ -1674,13 +1675,13 @@ static int sky2_xmit_frame(struct sk_buf
 			goto mapping_unwind;
 
 		if (sizeof(dma_addr_t) > sizeof(u32)) {
-			le = get_tx_le(sky2);
+			le = get_tx_le(sky2, &slot);
 			le->addr = cpu_to_le32(upper_32_bits(mapping));
 			le->ctrl = 0;
 			le->opcode = OP_ADDR64 | HW_OWNER;
 		}
 
-		le = get_tx_le(sky2);
+		le = get_tx_le(sky2, &slot);
 		le->addr = cpu_to_le32((u32) mapping);
 		le->length = cpu_to_le16(frag->size);
 		le->ctrl = ctrl;
@@ -1694,6 +1695,8 @@ static int sky2_xmit_frame(struct sk_buf
 
 	le->ctrl |= EOP;
 
+	sky2->tx_prod = slot;
+
 	if (tx_avail(sky2) <= MAX_SKB_TX_LE)
 		netif_stop_queue(dev);
 
@@ -1702,7 +1705,7 @@ static int sky2_xmit_frame(struct sk_buf
 	return NETDEV_TX_OK;
 
 mapping_unwind:
-	for (i = first_slot; i != sky2->tx_prod; i = RING_NEXT(i, TX_RING_SIZE)) {
+	for (i = sky2->tx_prod; i != slot; i = RING_NEXT(i, TX_RING_SIZE)) {
 		le = sky2->tx_le + i;
 		re = sky2->tx_ring + i;
 
@@ -1722,7 +1725,6 @@ mapping_unwind:
 		}
 	}
 
-	sky2->tx_prod = first_slot;
 mapping_error:
 	if (net_ratelimit())
 		dev_warn(&hw->pdev->dev, "%s: tx mapping error\n", dev->name);

-- 

