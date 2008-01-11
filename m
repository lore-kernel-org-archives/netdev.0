From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 1/4] sky2: large memory workaround.
Date: Thu, 10 Jan 2008 16:14:12 -0800
Message-ID: <20080111001550.762938769@linux-foundation.org>
References: <20080111001411.158113585@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:45739 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756313AbYAKDQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 22:16:29 -0500
Content-Disposition: inline; filename=sky2-dma64.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch might fix problems with 4G or more of memory.
It stops the driver from doing a small optimization for Tx and Rx,
and instead always sets the high-page on tx/rx descriptors.

Fixes-bug: http://bugzilla.kernel.org/show_bug.cgi?id=9725

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
Please apply to 2.6.24.

--- a/drivers/net/sky2.c	2008-01-10 15:42:09.000000000 -0800
+++ b/drivers/net/sky2.c	2008-01-10 15:49:12.000000000 -0800
@@ -943,7 +943,6 @@ static void tx_init(struct sky2_port *sk
 	le = get_tx_le(sky2);
 	le->addr = 0;
 	le->opcode = OP_ADDR64 | HW_OWNER;
-	sky2->tx_addr64 = 0;
 }
 
 static inline struct tx_ring_info *tx_le_re(struct sky2_port *sky2,
@@ -977,13 +976,11 @@ static void sky2_rx_add(struct sky2_port
 			dma_addr_t map, unsigned len)
 {
 	struct sky2_rx_le *le;
-	u32 hi = upper_32_bits(map);
 
-	if (sky2->rx_addr64 != hi) {
+	if (sizeof(dma_addr_t) > sizeof(u32)) {
 		le = sky2_next_rx(sky2);
-		le->addr = cpu_to_le32(hi);
+		le->addr = cpu_to_le32(upper_32_bits(map));
 		le->opcode = OP_ADDR64 | HW_OWNER;
-		sky2->rx_addr64 = upper_32_bits(map + len);
 	}
 
 	le = sky2_next_rx(sky2);
@@ -1477,7 +1474,6 @@ static int sky2_xmit_frame(struct sk_buf
 	struct tx_ring_info *re;
 	unsigned i, len;
 	dma_addr_t mapping;
-	u32 addr64;
 	u16 mss;
 	u8 ctrl;
 
@@ -1490,15 +1486,12 @@ static int sky2_xmit_frame(struct sk_buf
 
 	len = skb_headlen(skb);
 	mapping = pci_map_single(hw->pdev, skb->data, len, PCI_DMA_TODEVICE);
-	addr64 = upper_32_bits(mapping);
 
-	/* Send high bits if changed or crosses boundary */
-	if (addr64 != sky2->tx_addr64 ||
-	    upper_32_bits(mapping + len) != sky2->tx_addr64) {
+	/* Send high bits if needed */
+	if (sizeof(dma_addr_t) > sizeof(u32)) {
 		le = get_tx_le(sky2);
-		le->addr = cpu_to_le32(addr64);
+		le->addr = cpu_to_le32(upper_32_bits(mapping));
 		le->opcode = OP_ADDR64 | HW_OWNER;
-		sky2->tx_addr64 = upper_32_bits(mapping + len);
 	}
 
 	/* Check for TCP Segmentation Offload */
@@ -1579,13 +1572,12 @@ static int sky2_xmit_frame(struct sk_buf
 
 		mapping = pci_map_page(hw->pdev, frag->page, frag->page_offset,
 				       frag->size, PCI_DMA_TODEVICE);
-		addr64 = upper_32_bits(mapping);
-		if (addr64 != sky2->tx_addr64) {
+
+		if (sizeof(dma_addr_t) > sizeof(u32)) {
 			le = get_tx_le(sky2);
-			le->addr = cpu_to_le32(addr64);
+			le->addr = cpu_to_le32(upper_32_bits(mapping));
 			le->ctrl = 0;
 			le->opcode = OP_ADDR64 | HW_OWNER;
-			sky2->tx_addr64 = addr64;
 		}
 
 		le = get_tx_le(sky2);
--- a/drivers/net/sky2.h	2008-01-10 15:41:55.000000000 -0800
+++ b/drivers/net/sky2.h	2008-01-10 15:49:12.000000000 -0800
@@ -1991,14 +1991,14 @@ struct sky2_port {
 	u16		     tx_cons;		/* next le to check */
 	u16		     tx_prod;		/* next le to use */
 	u16		     tx_next;		/* debug only */
-	u32		     tx_addr64;
+
 	u16		     tx_pending;
 	u16		     tx_last_mss;
 	u32		     tx_tcpsum;
 
 	struct rx_ring_info  *rx_ring ____cacheline_aligned_in_smp;
 	struct sky2_rx_le    *rx_le;
-	u32		     rx_addr64;
+
 	u16		     rx_next;		/* next re to check */
 	u16		     rx_put;		/* next le index to use */
 	u16		     rx_pending;

-- 
Stephen Hemminger <stephen.hemminger@vyatta.com>

