From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 10/12] sky2: use upper_32_bits() macro
Date: Mon, 09 Jul 2007 15:33:42 -0700
Message-ID: <20070709223453.559682936@linux-foundation.org>
References: <20070709223332.966231494@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:35854 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755192AbXGIWpC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2007 18:45:02 -0400
Content-Disposition: inline; filename=sky2-high32.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use upper_32_bits() inline

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>


--- a/drivers/net/sky2.c	2007-07-09 15:30:13.000000000 -0700
+++ b/drivers/net/sky2.c	2007-07-09 15:30:14.000000000 -0700
@@ -893,24 +893,18 @@ static inline struct sky2_rx_le *sky2_ne
 	return le;
 }
 
-/* Return high part of DMA address (could be 32 or 64 bit) */
-static inline u32 high32(dma_addr_t a)
-{
-	return sizeof(a) > sizeof(u32) ? (a >> 16) >> 16 : 0;
-}
-
 /* Build description to hardware for one receive segment */
 static void sky2_rx_add(struct sky2_port *sky2,  u8 op,
 			dma_addr_t map, unsigned len)
 {
 	struct sky2_rx_le *le;
-	u32 hi = high32(map);
+	u32 hi = upper_32_bits(map);
 
 	if (sky2->rx_addr64 != hi) {
 		le = sky2_next_rx(sky2);
 		le->addr = cpu_to_le32(hi);
 		le->opcode = OP_ADDR64 | HW_OWNER;
-		sky2->rx_addr64 = high32(map + len);
+		sky2->rx_addr64 = upper_32_bits(map + len);
 	}
 
 	le = sky2_next_rx(sky2);
@@ -1424,14 +1418,15 @@ static int sky2_xmit_frame(struct sk_buf
 
 	len = skb_headlen(skb);
 	mapping = pci_map_single(hw->pdev, skb->data, len, PCI_DMA_TODEVICE);
-	addr64 = high32(mapping);
+	addr64 = upper_32_bits(mapping);
 
 	/* Send high bits if changed or crosses boundary */
-	if (addr64 != sky2->tx_addr64 || high32(mapping + len) != sky2->tx_addr64) {
+	if (addr64 != sky2->tx_addr64 ||
+	    upper_32_bits(mapping + len) != sky2->tx_addr64) {
 		le = get_tx_le(sky2);
 		le->addr = cpu_to_le32(addr64);
 		le->opcode = OP_ADDR64 | HW_OWNER;
-		sky2->tx_addr64 = high32(mapping + len);
+		sky2->tx_addr64 = upper_32_bits(mapping + len);
 	}
 
 	/* Check for TCP Segmentation Offload */
@@ -1511,7 +1506,7 @@ static int sky2_xmit_frame(struct sk_buf
 
 		mapping = pci_map_page(hw->pdev, frag->page, frag->page_offset,
 				       frag->size, PCI_DMA_TODEVICE);
-		addr64 = high32(mapping);
+		addr64 = upper_32_bits(mapping);
 		if (addr64 != sky2->tx_addr64) {
 			le = get_tx_le(sky2);
 			le->addr = cpu_to_le32(addr64);

-- 
Stephen Hemminger <shemminger@linux-foundation.org>

