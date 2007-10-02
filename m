From: Olof Johansson <olof@lixom.net>
Subject: [PATCH] [10/11] pasemi_mac: use buffer index pointer in clean_rx()
Date: Tue, 2 Oct 2007 16:27:57 -0500
Message-ID: <20071002212757.GK2282@lixom.net>
References: <20071002212421.GA2282@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lixom.net ([66.141.50.11]:46749 "EHLO mail.lixom.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751350AbXJBVXy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Oct 2007 17:23:54 -0400
Content-Disposition: inline
In-Reply-To: <20071002212421.GA2282@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

pasemi_mac: use buffer index pointer in clean_rx()

Use the new features in B0 for buffer ring index on the receive side. This
means we no longer have to search in the ring for where the buffer
came from.

Also cleanup the RX cleaning side a little, while I was at it.

Note: Pre-B0 hardware is no longer supported, and needs a pile of other
workarounds that are not being submitted for mainline inclusion. So the
fact that this breaks old hardware is not a problem at this time.

Signed-off-by: Olof Johansson <olof@lixom.net>

Index: k.org/drivers/net/pasemi_mac.c
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.c
+++ k.org/drivers/net/pasemi_mac.c
@@ -243,9 +243,9 @@ static int pasemi_mac_setup_rx_resources
 			   PAS_DMA_RXINT_BASEU_SIZ(RX_RING_SIZE >> 3));
 
 	write_dma_reg(mac, PAS_DMA_RXINT_CFG(mac->dma_if),
-			   PAS_DMA_RXINT_CFG_DHL(3) |
-			   PAS_DMA_RXINT_CFG_L2 |
-			   PAS_DMA_RXINT_CFG_LW);
+		      PAS_DMA_RXINT_CFG_DHL(3) | PAS_DMA_RXINT_CFG_L2 |
+		      PAS_DMA_RXINT_CFG_LW | PAS_DMA_RXINT_CFG_RBP |
+		      PAS_DMA_RXINT_CFG_HEN);
 
 	ring->next_to_fill = 0;
 	ring->next_to_clean = 0;
@@ -402,13 +402,12 @@ static void pasemi_mac_free_rx_resources
 static void pasemi_mac_replenish_rx_ring(struct net_device *dev, int limit)
 {
 	struct pasemi_mac *mac = netdev_priv(dev);
-	int start = mac->rx->next_to_fill;
-	unsigned int fill, count;
+	int fill, count;
 
 	if (limit <= 0)
 		return;
 
-	fill = start;
+	fill = mac->rx->next_to_fill;
 	for (count = 0; count < limit; count++) {
 		struct pasemi_mac_buffer *info = &RX_RING_INFO(mac, fill);
 		u64 *buff = &RX_BUFF(mac, fill);
@@ -446,10 +445,10 @@ static void pasemi_mac_replenish_rx_ring
 
 	wmb();
 
-	write_dma_reg(mac, PAS_DMA_RXCHAN_INCR(mac->dma_rxch), count);
 	write_dma_reg(mac, PAS_DMA_RXINT_INCR(mac->dma_if), count);
 
-	mac->rx->next_to_fill += count;
+	mac->rx->next_to_fill = (mac->rx->next_to_fill + count) &
+				(RX_RING_SIZE - 1);
 }
 
 static void pasemi_mac_restart_rx_intr(struct pasemi_mac *mac)
@@ -517,15 +516,19 @@ static int pasemi_mac_clean_rx(struct pa
 	int count;
 	struct pasemi_mac_buffer *info;
 	struct sk_buff *skb;
-	unsigned int i, len;
+	unsigned int len;
 	u64 macrx;
 	dma_addr_t dma;
+	int buf_index;
+	u64 eval;
 
 	spin_lock(&mac->rx->lock);
 
 	n = mac->rx->next_to_clean;
 
-	for (count = limit; count; count--) {
+	prefetch(RX_RING(mac, n));
+
+	for (count = 0; count < limit; count++) {
 		macrx = RX_RING(mac, n);
 
 		if ((macrx & XCT_MACRX_E) ||
@@ -537,21 +540,14 @@ static int pasemi_mac_clean_rx(struct pa
 
 		info = NULL;
 
-		/* We have to scan for our skb since there's no way
-		 * to back-map them from the descriptor, and if we
-		 * have several receive channels then they might not
-		 * show up in the same order as they were put on the
-		 * interface ring.
-		 */
+		BUG_ON(!(macrx & XCT_MACRX_RR_8BRES));
 
-		dma = (RX_RING(mac, n+1) & XCT_PTR_ADDR_M);
-		for (i = mac->rx->next_to_fill;
-		     i < (mac->rx->next_to_fill + RX_RING_SIZE);
-		     i++) {
-			info = &RX_RING_INFO(mac, i);
-			if (info->dma == dma)
-				break;
-		}
+		eval = (RX_RING(mac, n+1) & XCT_RXRES_8B_EVAL_M) >>
+			XCT_RXRES_8B_EVAL_S;
+		buf_index = eval-1;
+
+		dma = (RX_RING(mac, n+2) & XCT_PTR_ADDR_M);
+		info = &RX_RING_INFO(mac, buf_index);
 
 		skb = info->skb;
 
@@ -600,9 +596,9 @@ static int pasemi_mac_clean_rx(struct pa
 		/* Need to zero it out since hardware doesn't, since the
 		 * replenish loop uses it to tell when it's done.
 		 */
-		RX_BUFF(mac, i) = 0;
+		RX_BUFF(mac, buf_index) = 0;
 
-		n += 2;
+		n += 4;
 	}
 
 	if (n > RX_RING_SIZE) {
@@ -610,8 +606,16 @@ static int pasemi_mac_clean_rx(struct pa
 		write_iob_reg(mac, PAS_IOB_COM_PKTHDRCNT, 0);
 		n &= (RX_RING_SIZE-1);
 	}
+
 	mac->rx->next_to_clean = n;
-	pasemi_mac_replenish_rx_ring(mac->netdev, limit-count);
+
+	/* Increase is in number of 16-byte entries, and since each descriptor
+	 * with an 8BRES takes up 3x8 bytes (padded to 4x8), increase with
+	 * count*2.
+	 */
+	write_dma_reg(mac, PAS_DMA_RXCHAN_INCR(mac->dma_rxch), count << 1);
+
+	pasemi_mac_replenish_rx_ring(mac->netdev, count);
 
 	spin_unlock(&mac->rx->lock);
 
@@ -927,6 +931,8 @@ static int pasemi_mac_open(struct net_de
 
 	pasemi_mac_replenish_rx_ring(dev, RX_RING_SIZE);
 
+	write_dma_reg(mac, PAS_DMA_RXCHAN_INCR(mac->dma_rxch), RX_RING_SIZE>>1);
+
 	flags = PAS_MAC_CFG_PCFG_S1 | PAS_MAC_CFG_PCFG_PE |
 		PAS_MAC_CFG_PCFG_PR | PAS_MAC_CFG_PCFG_CE;
 
Index: k.org/drivers/net/pasemi_mac.h
===================================================================
--- k.org.orig/drivers/net/pasemi_mac.h
+++ k.org/drivers/net/pasemi_mac.h
@@ -206,12 +206,15 @@ enum {
 #define    PAS_DMA_RXINT_RCMDSTA_DROPS_M	0xfffe0000
 #define    PAS_DMA_RXINT_RCMDSTA_DROPS_S	17
 #define PAS_DMA_RXINT_CFG(i)		(0x204+(i)*_PAS_DMA_RXINT_STRIDE)
+#define    PAS_DMA_RXINT_CFG_RBP	0x80000000
+#define    PAS_DMA_RXINT_CFG_ITRR	0x40000000
 #define    PAS_DMA_RXINT_CFG_DHL_M	0x07000000
 #define    PAS_DMA_RXINT_CFG_DHL_S	24
 #define    PAS_DMA_RXINT_CFG_DHL(x)	(((x) << PAS_DMA_RXINT_CFG_DHL_S) & \
 					 PAS_DMA_RXINT_CFG_DHL_M)
 #define    PAS_DMA_RXINT_CFG_LW		0x00200000
 #define    PAS_DMA_RXINT_CFG_L2		0x00100000
+#define    PAS_DMA_RXINT_CFG_HEN	0x00080000
 #define    PAS_DMA_RXINT_CFG_WIF	0x00000002
 #define    PAS_DMA_RXINT_CFG_WIL	0x00000001
 
@@ -425,10 +428,9 @@ enum {
 /* Receive descriptor fields */
 #define	XCT_MACRX_T		0x8000000000000000ull
 #define	XCT_MACRX_ST		0x4000000000000000ull
-#define XCT_MACRX_NORES		0x0000000000000000ull
-#define XCT_MACRX_8BRES		0x1000000000000000ull
-#define XCT_MACRX_24BRES	0x2000000000000000ull
-#define XCT_MACRX_40BRES	0x3000000000000000ull
+#define XCT_MACRX_RR_M		0x3000000000000000ull
+#define XCT_MACRX_RR_NORES	0x0000000000000000ull
+#define XCT_MACRX_RR_8BRES	0x1000000000000000ull
 #define XCT_MACRX_O		0x0400000000000000ull
 #define XCT_MACRX_E		0x0200000000000000ull
 #define XCT_MACRX_FF		0x0100000000000000ull
@@ -476,6 +478,17 @@ enum {
 #define XCT_PTR_ADDR(x)		((((long)(x)) << XCT_PTR_ADDR_S) & \
 				 XCT_PTR_ADDR_M)
 
+/* Receive interface 8byte result fields */
+#define XCT_RXRES_8B_L4O_M	0xff00000000000000ull
+#define XCT_RXRES_8B_L4O_S	56
+#define XCT_RXRES_8B_RULE_M	0x00ffff0000000000ull
+#define XCT_RXRES_8B_RULE_S	40
+#define XCT_RXRES_8B_EVAL_M	0x000000ffff000000ull
+#define XCT_RXRES_8B_EVAL_S	24
+#define XCT_RXRES_8B_HTYPE_M	0x0000000000f00000ull
+#define XCT_RXRES_8B_HASH_M	0x00000000000fffffull
+#define XCT_RXRES_8B_HASH_S	0
+
 /* Receive interface buffer fields */
 #define XCT_RXB_LEN_M		0x0ffff00000000000ull
 #define XCT_RXB_LEN_S		44
