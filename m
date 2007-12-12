From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/8][BNX2]: Restructure RX ring init. code.
Date: Wed, 12 Dec 2007 10:59:05 -0800
Message-ID: <1197485945.16386.28.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4312 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751653AbXLLSOd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 13:14:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Restructure RX ring init. code.

Factor out the common functions that will be used to initialize the
normal RX rings and the page rings.

Change the copybreak constant RX_COPY_THRESH to 128.  This same
constant will be used for the max. size of the linear SKB when pages
are used.  Copybreak will be turned off when pages are used.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 14119fb..81971b1 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -2117,15 +2117,12 @@ bnx2_init_context(struct bnx2 *bp)
 			vcid_addr += (i << PHY_CTX_SHIFT);
 			pcid_addr += (i << PHY_CTX_SHIFT);
 
-			REG_WR(bp, BNX2_CTX_VIRT_ADDR, 0x00);
+			REG_WR(bp, BNX2_CTX_VIRT_ADDR, vcid_addr);
 			REG_WR(bp, BNX2_CTX_PAGE_TBL, pcid_addr);
 
 			/* Zero out the context. */
 			for (offset = 0; offset < PHY_CTX_SIZE; offset += 4)
-				CTX_WR(bp, 0x00, offset, 0);
-
-			REG_WR(bp, BNX2_CTX_VIRT_ADDR, vcid_addr);
-			REG_WR(bp, BNX2_CTX_PAGE_TBL, pcid_addr);
+				CTX_WR(bp, vcid_addr, offset, 0);
 		}
 	}
 }
@@ -2459,10 +2456,7 @@ bnx2_rx_int(struct bnx2 *bp, int budget)
 			goto next_rx;
 		}
 
-		/* Since we don't have a jumbo ring, copy small packets
-		 * if mtu > 1500
-		 */
-		if ((bp->dev->mtu > 1500) && (len <= RX_COPY_THRESH)) {
+		if (len <= bp->rx_copy_thresh) {
 			struct sk_buff *new_skb;
 
 			new_skb = netdev_alloc_skb(bp->dev, len + 2);
@@ -4172,50 +4166,57 @@ bnx2_init_tx_ring(struct bnx2 *bp)
 }
 
 static void
-bnx2_init_rx_ring(struct bnx2 *bp)
+bnx2_init_rxbd_rings(struct rx_bd *rx_ring[], dma_addr_t dma[], u32 buf_size,
+		     int num_rings)
 {
-	struct rx_bd *rxbd;
 	int i;
-	u16 prod, ring_prod;
-	u32 val;
-
-	/* 8 for CRC and VLAN */
-	bp->rx_buf_use_size = bp->dev->mtu + ETH_HLEN + bp->rx_offset + 8;
-	/* hw alignment */
-	bp->rx_buf_size = bp->rx_buf_use_size + BNX2_RX_ALIGN;
-
-	ring_prod = prod = bp->rx_prod = 0;
-	bp->rx_cons = 0;
-	bp->rx_prod_bseq = 0;
+	struct rx_bd *rxbd;
 
-	for (i = 0; i < bp->rx_max_ring; i++) {
+	for (i = 0; i < num_rings; i++) {
 		int j;
 
-		rxbd = &bp->rx_desc_ring[i][0];
+		rxbd = &rx_ring[i][0];
 		for (j = 0; j < MAX_RX_DESC_CNT; j++, rxbd++) {
-			rxbd->rx_bd_len = bp->rx_buf_use_size;
+			rxbd->rx_bd_len = buf_size;
 			rxbd->rx_bd_flags = RX_BD_FLAGS_START | RX_BD_FLAGS_END;
 		}
-		if (i == (bp->rx_max_ring - 1))
+		if (i == (num_rings - 1))
 			j = 0;
 		else
 			j = i + 1;
-		rxbd->rx_bd_haddr_hi = (u64) bp->rx_desc_mapping[j] >> 32;
-		rxbd->rx_bd_haddr_lo = (u64) bp->rx_desc_mapping[j] &
-				       0xffffffff;
+		rxbd->rx_bd_haddr_hi = (u64) dma[j] >> 32;
+		rxbd->rx_bd_haddr_lo = (u64) dma[j] & 0xffffffff;
 	}
+}
+
+static void
+bnx2_init_rx_ring(struct bnx2 *bp)
+{
+	int i;
+	u16 prod, ring_prod;
+	u32 val, rx_cid_addr = GET_CID_ADDR(RX_CID);
+
+	bp->rx_prod = 0;
+	bp->rx_cons = 0;
+	bp->rx_prod_bseq = 0;
+
+	bnx2_init_rxbd_rings(bp->rx_desc_ring, bp->rx_desc_mapping,
+			     bp->rx_buf_use_size, bp->rx_max_ring);
+
+	CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_PG_BUF_SIZE, 0);
 
 	val = BNX2_L2CTX_CTX_TYPE_CTX_BD_CHN_TYPE_VALUE;
 	val |= BNX2_L2CTX_CTX_TYPE_SIZE_L2;
 	val |= 0x02 << 8;
-	CTX_WR(bp, GET_CID_ADDR(RX_CID), BNX2_L2CTX_CTX_TYPE, val);
+	CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_CTX_TYPE, val);
 
 	val = (u64) bp->rx_desc_mapping[0] >> 32;
-	CTX_WR(bp, GET_CID_ADDR(RX_CID), BNX2_L2CTX_NX_BDHADDR_HI, val);
+	CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_NX_BDHADDR_HI, val);
 
 	val = (u64) bp->rx_desc_mapping[0] & 0xffffffff;
-	CTX_WR(bp, GET_CID_ADDR(RX_CID), BNX2_L2CTX_NX_BDHADDR_LO, val);
+	CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_NX_BDHADDR_LO, val);
 
+	ring_prod = prod = bp->rx_prod;
 	for (i = 0; i < bp->rx_ring_size; i++) {
 		if (bnx2_alloc_rx_skb(bp, ring_prod) < 0) {
 			break;
@@ -4230,26 +4231,40 @@ bnx2_init_rx_ring(struct bnx2 *bp)
 	REG_WR(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_BSEQ, bp->rx_prod_bseq);
 }
 
-static void
-bnx2_set_rx_ring_size(struct bnx2 *bp, u32 size)
+static u32 bnx2_find_max_ring(u32 ring_size, u32 max_size)
 {
-	u32 num_rings, max;
+	u32 max, num_rings = 1;
 
-	bp->rx_ring_size = size;
-	num_rings = 1;
-	while (size > MAX_RX_DESC_CNT) {
-		size -= MAX_RX_DESC_CNT;
+	while (ring_size > MAX_RX_DESC_CNT) {
+		ring_size -= MAX_RX_DESC_CNT;
 		num_rings++;
 	}
 	/* round to next power of 2 */
-	max = MAX_RX_RINGS;
+	max = max_size;
 	while ((max & num_rings) == 0)
 		max >>= 1;
 
 	if (num_rings != max)
 		max <<= 1;
 
-	bp->rx_max_ring = max;
+	return max;
+}
+
+static void
+bnx2_set_rx_ring_size(struct bnx2 *bp, u32 size)
+{
+	u32 rx_size;
+
+	/* 8 for CRC and VLAN */
+	rx_size = bp->dev->mtu + ETH_HLEN + bp->rx_offset + 8;
+
+	bp->rx_copy_thresh = RX_COPY_THRESH;
+
+	bp->rx_buf_use_size = rx_size;
+	/* hw alignment */
+	bp->rx_buf_size = bp->rx_buf_use_size + BNX2_RX_ALIGN;
+	bp->rx_ring_size = size;
+	bp->rx_max_ring = bnx2_find_max_ring(size, MAX_RX_RINGS);
 	bp->rx_max_ring_idx = (bp->rx_max_ring * RX_DESC_CNT) - 1;
 }
 
@@ -5795,16 +5810,8 @@ bnx2_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
 }
 
 static int
-bnx2_set_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
+bnx2_change_ring_size(struct bnx2 *bp, u32 rx, u32 tx)
 {
-	struct bnx2 *bp = netdev_priv(dev);
-
-	if ((ering->rx_pending > MAX_TOTAL_RX_DESC_CNT) ||
-		(ering->tx_pending > MAX_TX_DESC_CNT) ||
-		(ering->tx_pending <= MAX_SKB_FRAGS)) {
-
-		return -EINVAL;
-	}
 	if (netif_running(bp->dev)) {
 		bnx2_netif_stop(bp);
 		bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_RESET);
@@ -5812,8 +5819,8 @@ bnx2_set_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
 		bnx2_free_mem(bp);
 	}
 
-	bnx2_set_rx_ring_size(bp, ering->rx_pending);
-	bp->tx_ring_size = ering->tx_pending;
+	bnx2_set_rx_ring_size(bp, rx);
+	bp->tx_ring_size = tx;
 
 	if (netif_running(bp->dev)) {
 		int rc;
@@ -5824,10 +5831,25 @@ bnx2_set_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
 		bnx2_init_nic(bp);
 		bnx2_netif_start(bp);
 	}
-
 	return 0;
 }
 
+static int
+bnx2_set_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
+{
+	struct bnx2 *bp = netdev_priv(dev);
+	int rc;
+
+	if ((ering->rx_pending > MAX_TOTAL_RX_DESC_CNT) ||
+		(ering->tx_pending > MAX_TX_DESC_CNT) ||
+		(ering->tx_pending <= MAX_SKB_FRAGS)) {
+
+		return -EINVAL;
+	}
+	rc = bnx2_change_ring_size(bp, ering->rx_pending, ering->tx_pending);
+	return rc;
+}
+
 static void
 bnx2_get_pauseparam(struct net_device *dev, struct ethtool_pauseparam *epause)
 {
@@ -6316,14 +6338,7 @@ bnx2_change_mtu(struct net_device *dev, int new_mtu)
 		return -EINVAL;
 
 	dev->mtu = new_mtu;
-	if (netif_running(dev)) {
-		bnx2_netif_stop(bp);
-
-		bnx2_init_nic(bp);
-
-		bnx2_netif_start(bp);
-	}
-	return 0;
+	return (bnx2_change_ring_size(bp, bp->rx_ring_size, bp->tx_ring_size));
 }
 
 #if defined(HAVE_POLL_CONTROLLER) || defined(CONFIG_NET_POLL_CONTROLLER)
@@ -6644,13 +6659,13 @@ bnx2_init_board(struct pci_dev *pdev, struct net_device *dev)
 	bp->mac_addr[4] = (u8) (reg >> 8);
 	bp->mac_addr[5] = (u8) reg;
 
+	bp->rx_offset = sizeof(struct l2_fhdr) + 2;
+
 	bp->tx_ring_size = MAX_TX_DESC_CNT;
 	bnx2_set_rx_ring_size(bp, 255);
 
 	bp->rx_csum = 1;
 
-	bp->rx_offset = sizeof(struct l2_fhdr) + 2;
-
 	bp->tx_quick_cons_trip_int = 20;
 	bp->tx_quick_cons_trip = 20;
 	bp->tx_ticks_int = 80;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index e6a2153..8354efc 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -332,6 +332,11 @@ struct l2_fhdr {
 #define BNX2_L2CTX_NX_BDHADDR_LO			0x00000014
 #define BNX2_L2CTX_NX_BDIDX				0x00000018
 
+#define BNX2_L2CTX_HOST_PG_BDIDX			0x00000044
+#define BNX2_L2CTX_PG_BUF_SIZE				0x00000048
+#define BNX2_L2CTX_RBDC_KEY				0x0000004c
+#define BNX2_L2CTX_NX_PG_BDHADDR_HI			0x00000050
+#define BNX2_L2CTX_NX_PG_BDHADDR_LO			0x00000054
 
 /*
  *  pci_config_l definition
@@ -6336,7 +6341,7 @@ struct l2_fhdr {
 #define MAX_ETHERNET_PACKET_SIZE	1514
 #define MAX_ETHERNET_JUMBO_PACKET_SIZE	9014
 
-#define RX_COPY_THRESH			92
+#define RX_COPY_THRESH			128
 
 #define BNX2_MISC_ENABLE_DEFAULT	0x7ffffff
 
@@ -6513,6 +6518,7 @@ struct bnx2 {
 	u32			rx_offset;
 	u32			rx_buf_use_size;	/* useable size */
 	u32			rx_buf_size;		/* with alignment */
+	u32			rx_copy_thresh;
 	u32			rx_max_ring_idx;
 
 	u32			rx_prod_bseq;


