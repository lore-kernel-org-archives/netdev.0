From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/7] sky2: transmit ring 64 bit conservation
Date: Tue, 18 Aug 2009 18:17:06 -0700
Message-ID: <20090819011738.684469289@vyatta.com>
References: <20090819011704.685802801@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:50668 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750900AbZHSBWp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 21:22:45 -0400
Content-Disposition: inline; filename=sky2-64.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch saves elements on transmit ring by only updating the upper
64 bit address when it changes. With many workloads skb's are located
in same region, so it saves space.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/sky2.c	2009-08-18 09:32:29.143195273 -0700
+++ b/drivers/net/sky2.c	2009-08-18 09:33:15.490426779 -0700
@@ -1016,6 +1016,7 @@ static void tx_init(struct sky2_port *sk
 	le = get_tx_le(sky2, &sky2->tx_prod);
 	le->addr = 0;
 	le->opcode = OP_ADDR64 | HW_OWNER;
+	sky2->tx_last_upper = 0;
 }
 
 static inline struct tx_ring_info *tx_le_re(struct sky2_port *sky2,
@@ -1573,8 +1574,9 @@ static int sky2_xmit_frame(struct sk_buf
 	struct sky2_tx_le *le = NULL;
 	struct tx_ring_info *re;
 	unsigned i, len;
-	u16 slot;
 	dma_addr_t mapping;
+	u32 upper;
+	u16 slot;
 	u16 mss;
 	u8 ctrl;
 
@@ -1593,9 +1595,11 @@ static int sky2_xmit_frame(struct sk_buf
 		       dev->name, slot, skb->len);
 
 	/* Send high bits if needed */
-	if (sizeof(dma_addr_t) > sizeof(u32)) {
+	upper = upper_32_bits(mapping);
+	if (upper != sky2->tx_last_upper) {
 		le = get_tx_le(sky2, &slot);
-		le->addr = cpu_to_le32(upper_32_bits(mapping));
+		le->addr = cpu_to_le32(upper);
+		sky2->tx_last_upper = upper;
 		le->opcode = OP_ADDR64 | HW_OWNER;
 	}
 
@@ -1681,10 +1685,11 @@ static int sky2_xmit_frame(struct sk_buf
 		if (pci_dma_mapping_error(hw->pdev, mapping))
 			goto mapping_unwind;
 
-		if (sizeof(dma_addr_t) > sizeof(u32)) {
+		upper = upper_32_bits(mapping);
+		if (upper != sky2->tx_last_upper) {
 			le = get_tx_le(sky2, &slot);
-			le->addr = cpu_to_le32(upper_32_bits(mapping));
-			le->ctrl = 0;
+			le->addr = cpu_to_le32(upper);
+			sky2->tx_last_upper = upper;
 			le->opcode = OP_ADDR64 | HW_OWNER;
 		}
 
--- a/drivers/net/sky2.h	2009-08-18 09:29:59.224176503 -0700
+++ b/drivers/net/sky2.h	2009-08-18 09:33:15.491426771 -0700
@@ -2017,6 +2017,7 @@ struct sky2_port {
 
 	u16		     tx_pending;
 	u16		     tx_last_mss;
+	u32		     tx_last_upper;
 	u32		     tx_tcpsum;
 
 	struct rx_ring_info  *rx_ring ____cacheline_aligned_in_smp;

-- 

