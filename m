From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH 16/17] sky2: make sure high DMA bits set
Date: Tue, 08 May 2007 20:50:05 -0700
Message-ID: <20070509035031.155434136@linux-foundation.org>
References: <20070509034949.624934448@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([65.172.181.25]:47089 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755633AbXEIEJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 May 2007 00:09:49 -0400
Cc: Greg KH <greg@kroah.com>
Content-Disposition: inline; filename=sky2-force64.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Be more frugal on memory on 32bit platforms (less rx elements are needed),
and make sure high DMA bits are set on 64bit platforms.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 drivers/net/sky2.c |   62 ++++++++++++++++++++++++++++++++++++-----------------
 drivers/net/sky2.h |    2 -
 2 files changed, 43 insertions(+), 21 deletions(-)

--- sky2-2.6.21.orig/drivers/net/sky2.c	2007-05-08 16:09:03.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.c	2007-05-08 16:10:41.000000000 -0700
@@ -61,9 +61,11 @@
  * similar to Tigon3.
  */
 
-#define RX_LE_SIZE		1024
-#define RX_LE_BYTES		(RX_LE_SIZE*sizeof(struct sky2_rx_le))
-#define RX_MAX_PENDING		(RX_LE_SIZE/6 - 2)
+#define NDMA_LE			(sizeof(dma_addr_t)/sizeof(u32))
+
+#define RX_LE_SIZE	    	(512 * NDMA_LE)
+#define RX_LE_BYTES		(RX_LE_SIZE * sizeof(struct sky2_rx_le))
+#define RX_MAX_PENDING		500
 #define RX_DEF_PENDING		RX_MAX_PENDING
 #define RX_SKB_ALIGN		8
 #define RX_BUF_WRITE		16
@@ -71,7 +73,7 @@
 #define TX_RING_SIZE		512
 #define TX_DEF_PENDING		(TX_RING_SIZE - 1)
 #define TX_MIN_PENDING		64
-#define MAX_SKB_TX_LE		(4 + (sizeof(dma_addr_t)/sizeof(u32))*MAX_SKB_FRAGS)
+#define MAX_SKB_TX_LE		(2 + (NDMA_LE * (MAX_SKB_FRAGS + 1)))
 
 #define STATUS_RING_SIZE	2048	/* 2 ports * (TX + 2*RX) */
 #define STATUS_LE_BYTES		(STATUS_RING_SIZE*sizeof(struct sky2_status_le))
@@ -826,7 +828,6 @@ static inline struct sky2_tx_le *get_tx_
 	struct sky2_tx_le *le = sky2->tx_le + sky2->tx_prod;
 
 	sky2->tx_prod = RING_NEXT(sky2->tx_prod, TX_RING_SIZE);
-	le->ctrl = 0;
 	return le;
 }
 
@@ -866,13 +867,14 @@ static void sky2_rx_add(struct sky2_port
 			dma_addr_t map, unsigned len)
 {
 	struct sky2_rx_le *le;
-	u32 hi = high32(map);
 
-	if (sky2->rx_addr64 != hi) {
+	if (sizeof(map) > sizeof(u32)) {
+		u32 hi = high32(map);
+
 		le = sky2_next_rx(sky2);
 		le->addr = cpu_to_le32(hi);
+		le->ctrl = 0;
 		le->opcode = OP_ADDR64 | HW_OWNER;
-		sky2->rx_addr64 = high32(map + len);
 	}
 
 	le = sky2_next_rx(sky2);
@@ -1168,6 +1170,14 @@ static int sky2_rx_start(struct sky2_por
 	}
 	sky2->rx_data_size = size;
 
+	/* On 32bit platforms high bits always zero */
+	if (sizeof(dma_addr_t) == sizeof(u32)) {
+		struct sky2_rx_le *le = sky2_next_rx(sky2);
+		le->addr = 0;
+		le->ctrl = 0;
+		le->opcode = OP_ADDR64 | HW_OWNER;
+	}
+
 	/* Fill Rx ring */
 	for (i = 0; i < sky2->rx_pending; i++) {
 		re = sky2->rx_ring + i;
@@ -1287,6 +1297,14 @@ static int sky2_up(struct net_device *de
 	    && hw->chip_rev == CHIP_REV_YU_EC_U_A0)
 		sky2_write16(hw, Q_ADDR(txqaddr[port], Q_AL), ECU_TXFF_LEV);
 
+	/* Initial high bits to zero */
+	if (sizeof(dma_addr_t) == sizeof(u32)) {
+		struct sky2_tx_le *le = get_tx_le(sky2);
+		le->addr = 0;
+		le->ctrl = 0;
+		le->opcode = OP_ADDR64 | HW_OWNER;
+	}
+
 	sky2_prefetch_init(hw, txqaddr[port], sky2->tx_le_map,
 			   TX_RING_SIZE - 1);
 
@@ -1336,13 +1354,16 @@ static inline int tx_avail(const struct 
 /* Estimate of number of transmit list elements required */
 static unsigned tx_le_req(const struct sk_buff *skb)
 {
-	unsigned count;
+	unsigned count = NDMA_LE;	/* OP_PACKET */
 
-	count = sizeof(dma_addr_t) / sizeof(u32);
-	count += skb_shinfo(skb)->nr_frags * count;
+	count += skb_shinfo(skb)->nr_frags * NDMA_LE;	/* OP_BUFFER */
 
 	if (skb_is_gso(skb))
 		++count;
+#ifdef SKY2_VLAN_TAG_USED
+	else if (vlan_tx_tag_present(skb))
+		++count;
+#endif
 
 	if (skb->ip_summed == CHECKSUM_PARTIAL)
 		++count;
@@ -1379,12 +1400,11 @@ static int sky2_xmit_frame(struct sk_buf
 	mapping = pci_map_single(hw->pdev, skb->data, len, PCI_DMA_TODEVICE);
 	addr64 = high32(mapping);
 
-	/* Send high bits if changed or crosses boundary */
-	if (addr64 != sky2->tx_addr64 || high32(mapping + len) != sky2->tx_addr64) {
+	if (sizeof(mapping) > sizeof(u32)) {
 		le = get_tx_le(sky2);
 		le->addr = cpu_to_le32(addr64);
+		le->ctrl = 0;
 		le->opcode = OP_ADDR64 | HW_OWNER;
-		sky2->tx_addr64 = high32(mapping + len);
 	}
 
 	/* Check for TCP Segmentation Offload */
@@ -1398,6 +1418,7 @@ static int sky2_xmit_frame(struct sk_buf
 			le = get_tx_le(sky2);
 			le->addr = cpu_to_le32(mss);
 			le->opcode = OP_LRGLEN | HW_OWNER;
+			le->ctrl = 0;
 			sky2->tx_last_mss = mss;
 		}
 	}
@@ -1410,6 +1431,7 @@ static int sky2_xmit_frame(struct sk_buf
 			le = get_tx_le(sky2);
 			le->addr = 0;
 			le->opcode = OP_VLAN | HW_OWNER;
+			le->ctrl = 0;
 		} else
 			le->opcode |= OP_VLAN;
 		le->length = cpu_to_be16(vlan_tx_tag_get(skb));
@@ -1453,16 +1475,18 @@ static int sky2_xmit_frame(struct sk_buf
 
 	for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
 		const skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
+		u32 hi;
 
 		mapping = pci_map_page(hw->pdev, frag->page, frag->page_offset,
 				       frag->size, PCI_DMA_TODEVICE);
-		addr64 = high32(mapping);
-		if (addr64 != sky2->tx_addr64) {
+		hi = high32(mapping);
+
+		if (addr64 != hi) {
 			le = get_tx_le(sky2);
-			le->addr = cpu_to_le32(addr64);
-			le->ctrl = 0;
+			le->addr = cpu_to_le32(hi);
 			le->opcode = OP_ADDR64 | HW_OWNER;
-			sky2->tx_addr64 = addr64;
+			le->ctrl = 0;
+			addr64 = hi;
 		}
 
 		le = get_tx_le(sky2);
--- sky2-2.6.21.orig/drivers/net/sky2.h	2007-05-08 16:10:50.000000000 -0700
+++ sky2-2.6.21/drivers/net/sky2.h	2007-05-08 16:10:58.000000000 -0700
@@ -1717,14 +1717,12 @@ struct sky2_port {
 	struct sky2_tx_le    *tx_le;
 	u16		     tx_cons;		/* next le to check */
 	u16		     tx_prod;		/* next le to use */
-	u32		     tx_addr64;
 	u16		     tx_pending;
 	u16		     tx_last_mss;
 	u32		     tx_tcpsum;
 
 	struct rx_ring_info  *rx_ring ____cacheline_aligned_in_smp;
 	struct sky2_rx_le    *rx_le;
-	u32		     rx_addr64;
 	u16		     rx_next;		/* next re to check */
 	u16		     rx_put;		/* next le index to use */
 	u16		     rx_pending;

--

