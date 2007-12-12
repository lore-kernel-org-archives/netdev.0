From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 5/8][BNX2]: Add init. code to handle RX pages.
Date: Wed, 12 Dec 2007 10:59:39 -0800
Message-ID: <1197485979.16386.30.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:2402 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752708AbXLLSPG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Dec 2007 13:15:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[BNX2]: Add init. code to handle RX pages.

Add new fields to keep track of the pages and the page rings.
Add functions to allocate and free pages.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index db3b750..38e8e31 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -483,6 +483,16 @@ bnx2_free_mem(struct bnx2 *bp)
 	}
 	vfree(bp->rx_buf_ring);
 	bp->rx_buf_ring = NULL;
+	for (i = 0; i < bp->rx_max_pg_ring; i++) {
+		if (bp->rx_pg_desc_ring[i])
+			pci_free_consistent(bp->pdev, RXBD_RING_SIZE,
+					    bp->rx_pg_desc_ring[i],
+					    bp->rx_pg_desc_mapping[i]);
+		bp->rx_pg_desc_ring[i] = NULL;
+	}
+	if (bp->rx_pg_ring)
+		vfree(bp->rx_pg_ring);
+	bp->rx_pg_ring = NULL;
 }
 
 static int
@@ -514,6 +524,25 @@ bnx2_alloc_mem(struct bnx2 *bp)
 
 	}
 
+	if (bp->rx_pg_ring_size) {
+		bp->rx_pg_ring = vmalloc(SW_RXPG_RING_SIZE *
+					 bp->rx_max_pg_ring);
+		if (bp->rx_pg_ring == NULL)
+			goto alloc_mem_err;
+
+		memset(bp->rx_pg_ring, 0, SW_RXPG_RING_SIZE *
+		       bp->rx_max_pg_ring);
+	}
+
+	for (i = 0; i < bp->rx_max_pg_ring; i++) {
+		bp->rx_pg_desc_ring[i] =
+			pci_alloc_consistent(bp->pdev, RXBD_RING_SIZE,
+					     &bp->rx_pg_desc_mapping[i]);
+		if (bp->rx_pg_desc_ring[i] == NULL)
+			goto alloc_mem_err;
+
+	}
+
 	/* Combine status and statistics blocks into one allocation. */
 	status_blk_size = L1_CACHE_ALIGN(sizeof(struct status_block));
 	bp->status_stats_size = status_blk_size +
@@ -2195,6 +2224,42 @@ bnx2_set_mac_addr(struct bnx2 *bp)
 }
 
 static inline int
+bnx2_alloc_rx_page(struct bnx2 *bp, u16 index)
+{
+	dma_addr_t mapping;
+	struct sw_pg *rx_pg = &bp->rx_pg_ring[index];
+	struct rx_bd *rxbd =
+		&bp->rx_pg_desc_ring[RX_RING(index)][RX_IDX(index)];
+	struct page *page = alloc_page(GFP_ATOMIC);
+
+	if (!page)
+		return -ENOMEM;
+	mapping = pci_map_page(bp->pdev, page, 0, PAGE_SIZE,
+			       PCI_DMA_FROMDEVICE);
+	rx_pg->page = page;
+	pci_unmap_addr_set(rx_pg, mapping, mapping);
+	rxbd->rx_bd_haddr_hi = (u64) mapping >> 32;
+	rxbd->rx_bd_haddr_lo = (u64) mapping & 0xffffffff;
+	return 0;
+}
+
+static void
+bnx2_free_rx_page(struct bnx2 *bp, u16 index)
+{
+	struct sw_pg *rx_pg = &bp->rx_pg_ring[index];
+	struct page *page = rx_pg->page;
+
+	if (!page)
+		return;
+
+	pci_unmap_page(bp->pdev, pci_unmap_addr(rx_pg, mapping), PAGE_SIZE,
+		       PCI_DMA_FROMDEVICE);
+
+	__free_page(page);
+	rx_pg->page = NULL;
+}
+
+static inline int
 bnx2_alloc_rx_skb(struct bnx2 *bp, u16 index)
 {
 	struct sk_buff *skb;
@@ -4213,11 +4278,31 @@ bnx2_init_rx_ring(struct bnx2 *bp)
 	bp->rx_prod = 0;
 	bp->rx_cons = 0;
 	bp->rx_prod_bseq = 0;
+	bp->rx_pg_prod = 0;
+	bp->rx_pg_cons = 0;
 
 	bnx2_init_rxbd_rings(bp->rx_desc_ring, bp->rx_desc_mapping,
 			     bp->rx_buf_use_size, bp->rx_max_ring);
 
 	CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_PG_BUF_SIZE, 0);
+	if (bp->rx_pg_ring_size) {
+		bnx2_init_rxbd_rings(bp->rx_pg_desc_ring,
+				     bp->rx_pg_desc_mapping,
+				     PAGE_SIZE, bp->rx_max_pg_ring);
+		val = (bp->rx_buf_use_size << 16) | PAGE_SIZE;
+		CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_PG_BUF_SIZE, val);
+		CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_RBDC_KEY,
+		       BNX2_L2CTX_RBDC_JUMBO_KEY);
+
+		val = (u64) bp->rx_pg_desc_mapping[0] >> 32;
+		CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_NX_PG_BDHADDR_HI, val);
+
+		val = (u64) bp->rx_pg_desc_mapping[0] & 0xffffffff;
+		CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_NX_PG_BDHADDR_LO, val);
+
+		if (CHIP_NUM(bp) == CHIP_NUM_5709)
+			REG_WR(bp, BNX2_MQ_MAP_L2_3, BNX2_MQ_MAP_L2_3_DEFAULT);
+	}
 
 	val = BNX2_L2CTX_CTX_TYPE_CTX_BD_CHN_TYPE_VALUE;
 	val |= BNX2_L2CTX_CTX_TYPE_SIZE_L2;
@@ -4230,6 +4315,15 @@ bnx2_init_rx_ring(struct bnx2 *bp)
 	val = (u64) bp->rx_desc_mapping[0] & 0xffffffff;
 	CTX_WR(bp, rx_cid_addr, BNX2_L2CTX_NX_BDHADDR_LO, val);
 
+	ring_prod = prod = bp->rx_pg_prod;
+	for (i = 0; i < bp->rx_pg_ring_size; i++) {
+		if (bnx2_alloc_rx_page(bp, ring_prod) < 0)
+			break;
+		prod = NEXT_RX_BD(prod);
+		ring_prod = RX_PG_RING_IDX(prod);
+	}
+	bp->rx_pg_prod = prod;
+
 	ring_prod = prod = bp->rx_prod;
 	for (i = 0; i < bp->rx_ring_size; i++) {
 		if (bnx2_alloc_rx_skb(bp, ring_prod) < 0) {
@@ -4240,6 +4334,7 @@ bnx2_init_rx_ring(struct bnx2 *bp)
 	}
 	bp->rx_prod = prod;
 
+	REG_WR16(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_PG_BDIDX, bp->rx_pg_prod);
 	REG_WR16(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_BDIDX, prod);
 
 	REG_WR(bp, MB_RX_CID_ADDR + BNX2_L2CTX_HOST_BSEQ, bp->rx_prod_bseq);
@@ -4273,6 +4368,9 @@ bnx2_set_rx_ring_size(struct bnx2 *bp, u32 size)
 	rx_size = bp->dev->mtu + ETH_HLEN + bp->rx_offset + 8;
 
 	bp->rx_copy_thresh = RX_COPY_THRESH;
+	bp->rx_pg_ring_size = 0;
+	bp->rx_max_pg_ring = 0;
+	bp->rx_max_pg_ring_idx = 0;
 
 	bp->rx_buf_use_size = rx_size;
 	/* hw alignment */
@@ -4341,6 +4439,8 @@ bnx2_free_rx_skbs(struct bnx2 *bp)
 
 		dev_kfree_skb(skb);
 	}
+	for (i = 0; i < bp->rx_max_pg_ring_idx; i++)
+		bnx2_free_rx_page(bp, i);
 }
 
 static void
@@ -5813,11 +5913,11 @@ bnx2_get_ringparam(struct net_device *dev, struct ethtool_ringparam *ering)
 
 	ering->rx_max_pending = MAX_TOTAL_RX_DESC_CNT;
 	ering->rx_mini_max_pending = 0;
-	ering->rx_jumbo_max_pending = 0;
+	ering->rx_jumbo_max_pending = MAX_TOTAL_RX_PG_DESC_CNT;
 
 	ering->rx_pending = bp->rx_ring_size;
 	ering->rx_mini_pending = 0;
-	ering->rx_jumbo_pending = 0;
+	ering->rx_jumbo_pending = bp->rx_pg_ring_size;
 
 	ering->tx_max_pending = MAX_TX_DESC_CNT;
 	ering->tx_pending = bp->tx_ring_size;
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 8354efc..93c2436 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -335,6 +335,7 @@ struct l2_fhdr {
 #define BNX2_L2CTX_HOST_PG_BDIDX			0x00000044
 #define BNX2_L2CTX_PG_BUF_SIZE				0x00000048
 #define BNX2_L2CTX_RBDC_KEY				0x0000004c
+#define BNX2_L2CTX_RBDC_JUMBO_KEY			 0x3ffe
 #define BNX2_L2CTX_NX_PG_BDHADDR_HI			0x00000050
 #define BNX2_L2CTX_NX_PG_BDHADDR_LO			0x00000054
 
@@ -4450,6 +4451,14 @@ struct l2_fhdr {
 #define BNX2_MQ_MEM_RD_DATA2_VALUE			 (0x3fffffffL<<0)
 #define BNX2_MQ_MEM_RD_DATA2_VALUE_XI			 (0x7fffffffL<<0)
 
+#define BNX2_MQ_MAP_L2_3				0x00003d2c
+#define BNX2_MQ_MAP_L2_3_MQ_OFFSET			 (0xffL<<0)
+#define BNX2_MQ_MAP_L2_3_SZ				 (0x3L<<8)
+#define BNX2_MQ_MAP_L2_3_CTX_OFFSET			 (0x2ffL<<10)
+#define BNX2_MQ_MAP_L2_3_BIN_OFFSET			 (0x7L<<23)
+#define BNX2_MQ_MAP_L2_3_ARM				 (0x3L<<26)
+#define BNX2_MQ_MAP_L2_3_ENA				 (0x1L<<31)
+#define BNX2_MQ_MAP_L2_3_DEFAULT			 0x82004646
 
 /*
  *  tsch_reg definition
@@ -6360,9 +6369,11 @@ struct l2_fhdr {
 #define MAX_TX_DESC_CNT (TX_DESC_CNT - 1)
 
 #define MAX_RX_RINGS	4
+#define MAX_RX_PG_RINGS	16
 #define RX_DESC_CNT  (BCM_PAGE_SIZE / sizeof(struct rx_bd))
 #define MAX_RX_DESC_CNT (RX_DESC_CNT - 1)
 #define MAX_TOTAL_RX_DESC_CNT (MAX_RX_DESC_CNT * MAX_RX_RINGS)
+#define MAX_TOTAL_RX_PG_DESC_CNT (MAX_RX_DESC_CNT * MAX_RX_PG_RINGS)
 
 #define NEXT_TX_BD(x) (((x) & (MAX_TX_DESC_CNT - 1)) ==			\
 		(MAX_TX_DESC_CNT - 1)) ?				\
@@ -6375,6 +6386,7 @@ struct l2_fhdr {
 	(x) + 2 : (x) + 1
 
 #define RX_RING_IDX(x) ((x) & bp->rx_max_ring_idx)
+#define RX_PG_RING_IDX(x) ((x) & bp->rx_max_pg_ring_idx)
 
 #define RX_RING(x) (((x) & ~MAX_RX_DESC_CNT) >> (BCM_PAGE_BITS - 4))
 #define RX_IDX(x) ((x) & MAX_RX_DESC_CNT)
@@ -6413,7 +6425,13 @@ struct sw_bd {
 	DECLARE_PCI_UNMAP_ADDR(mapping)
 };
 
+struct sw_pg {
+	struct page		*page;
+	DECLARE_PCI_UNMAP_ADDR(mapping)
+};
+
 #define SW_RXBD_RING_SIZE (sizeof(struct sw_bd) * RX_DESC_CNT)
+#define SW_RXPG_RING_SIZE (sizeof(struct sw_pg) * RX_DESC_CNT)
 #define RXBD_RING_SIZE (sizeof(struct rx_bd) * RX_DESC_CNT)
 #define SW_TXBD_RING_SIZE (sizeof(struct sw_bd) * TX_DESC_CNT)
 #define TXBD_RING_SIZE (sizeof(struct tx_bd) * TX_DESC_CNT)
@@ -6520,15 +6538,21 @@ struct bnx2 {
 	u32			rx_buf_size;		/* with alignment */
 	u32			rx_copy_thresh;
 	u32			rx_max_ring_idx;
+	u32			rx_max_pg_ring_idx;
 
 	u32			rx_prod_bseq;
 	u16			rx_prod;
 	u16			rx_cons;
 
+	u16			rx_pg_prod;
+	u16			rx_pg_cons;
+
 	u32			rx_csum;
 
 	struct sw_bd		*rx_buf_ring;
 	struct rx_bd		*rx_desc_ring[MAX_RX_RINGS];
+	struct sw_pg		*rx_pg_ring;
+	struct rx_bd		*rx_pg_desc_ring[MAX_RX_PG_RINGS];
 
 	/* TX constants */
 	struct tx_bd	*tx_desc_ring;
@@ -6616,6 +6640,10 @@ struct bnx2 {
 	int			rx_ring_size;
 	dma_addr_t		rx_desc_mapping[MAX_RX_RINGS];
 
+	int			rx_max_pg_ring;
+	int			rx_pg_ring_size;
+	dma_addr_t		rx_pg_desc_mapping[MAX_RX_PG_RINGS];
+
 	u16			tx_quick_cons_trip;
 	u16			tx_quick_cons_trip_int;
 	u16			rx_quick_cons_trip;


