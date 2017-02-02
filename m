From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 12/12] bnxt_en: Add support for XDP_TX action.
Date: Thu,  2 Feb 2017 11:55:40 -0500
Message-ID: <1486054540-366-13-git-send-email-michael.chan@broadcom.com>
References: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:33838 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752119AbdBBQ4H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 11:56:07 -0500
Received: by mail-pf0-f178.google.com with SMTP id e4so6480871pfg.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 08:56:07 -0800 (PST)
In-Reply-To: <1486054540-366-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add dedicated transmit function and transmit completion handler for
XDP which are a lot simpler than the original functions for SKB.

v2: Add trace_xdp_exception().
    Add dma_sync.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
Tested-by: Andy Gospodarek <gospo@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c     | 35 ++++++-----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h     | 14 +++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c | 90 +++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h |  2 +
 4 files changed, 125 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 4613702..6376c1f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -212,16 +212,7 @@ static bool bnxt_vf_pciid(enum board_idx idx)
 #define BNXT_CP_DB_IRQ_DIS(db)						\
 		writel(DB_CP_IRQ_DIS_FLAGS, db)
 
-static inline u32 bnxt_tx_avail(struct bnxt *bp, struct bnxt_tx_ring_info *txr)
-{
-	/* Tell compiler to fetch tx indices from memory. */
-	barrier();
-
-	return bp->tx_ring_size -
-		((txr->tx_prod - txr->tx_cons) & bp->tx_ring_mask);
-}
-
-static const u16 bnxt_lhint_arr[] = {
+const u16 bnxt_lhint_arr[] = {
 	TX_BD_FLAGS_LHINT_512_AND_SMALLER,
 	TX_BD_FLAGS_LHINT_512_TO_1023,
 	TX_BD_FLAGS_LHINT_1024_TO_2047,
@@ -613,9 +604,8 @@ static inline u8 *__bnxt_alloc_rx_data(struct bnxt *bp, dma_addr_t *mapping,
 	return data;
 }
 
-static inline int bnxt_alloc_rx_data(struct bnxt *bp,
-				     struct bnxt_rx_ring_info *rxr,
-				     u16 prod, gfp_t gfp)
+int bnxt_alloc_rx_data(struct bnxt *bp, struct bnxt_rx_ring_info *rxr,
+		       u16 prod, gfp_t gfp)
 {
 	struct rx_bd *rxbd = &rxr->rx_desc_ring[RX_RING(prod)][RX_IDX(prod)];
 	struct bnxt_sw_rx_bd *rx_buf = &rxr->rx_buf_ring[prod];
@@ -1770,6 +1760,17 @@ static int bnxt_poll_work(struct bnxt *bp, struct bnxt_napi *bnapi, int budget)
 	if (tx_pkts)
 		bnapi->tx_int(bp, bnapi, tx_pkts);
 
+	if (event & BNXT_TX_EVENT) {
+		struct bnxt_tx_ring_info *txr = bnapi->tx_ring;
+		void __iomem *db = txr->tx_doorbell;
+		u16 prod = txr->tx_prod;
+
+		/* Sync BD data before updating doorbell */
+		wmb();
+
+		writel(DB_KEY_TX | prod, db);
+		writel(DB_KEY_TX | prod, db);
+	}
 	if (event & BNXT_RX_EVENT) {
 		struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
 
@@ -3060,12 +3061,14 @@ static int bnxt_alloc_mem(struct bnxt *bp, bool irq_re_init)
 			bp->tx_ring[i].bnapi = bp->bnapi[j];
 			bp->bnapi[j]->tx_ring = &bp->tx_ring[i];
 			bp->tx_ring_map[i] = bp->tx_nr_rings_xdp + i;
-			if (i >= bp->tx_nr_rings_xdp)
+			if (i >= bp->tx_nr_rings_xdp) {
 				bp->tx_ring[i].txq_index = i -
 					bp->tx_nr_rings_xdp;
-			else
+				bp->bnapi[j]->tx_int = bnxt_tx_int;
+			} else {
 				bp->bnapi[j]->flags |= BNXT_NAPI_FLAG_XDP;
-			bp->bnapi[j]->tx_int = bnxt_tx_int;
+				bp->bnapi[j]->tx_int = bnxt_tx_int_xdp;
+			}
 		}
 
 		rc = bnxt_alloc_stats(bp);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index db9d5d9..8ce4c59 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -514,6 +514,7 @@ struct rx_tpa_end_cmp_ext {
 
 #define BNXT_RX_EVENT	1
 #define BNXT_AGG_EVENT	2
+#define BNXT_TX_EVENT	4
 
 struct bnxt_sw_tx_bd {
 	union {
@@ -1194,6 +1195,19 @@ struct bnxt {
 #define SFF_MODULE_ID_QSFP28			0x11
 #define BNXT_MAX_PHY_I2C_RESP_SIZE		64
 
+static inline u32 bnxt_tx_avail(struct bnxt *bp, struct bnxt_tx_ring_info *txr)
+{
+	/* Tell compiler to fetch tx indices from memory. */
+	barrier();
+
+	return bp->tx_ring_size -
+		((txr->tx_prod - txr->tx_cons) & bp->tx_ring_mask);
+}
+
+extern const u16 bnxt_lhint_arr[];
+
+int bnxt_alloc_rx_data(struct bnxt *bp, struct bnxt_rx_ring_info *rxr,
+		       u16 prod, gfp_t gfp);
 void bnxt_reuse_rx_data(struct bnxt_rx_ring_info *rxr, u16 cons, void *data);
 void bnxt_set_tpa_flags(struct bnxt *bp);
 void bnxt_set_ring_params(struct bnxt *);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
index 50315d7..0a9a050 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
@@ -20,6 +20,68 @@
 #include "bnxt_xdp.h"
 
 #ifdef CONFIG_BNXT_XDP
+static int bnxt_xmit_xdp(struct bnxt *bp, struct bnxt_tx_ring_info *txr,
+			 struct page *page, dma_addr_t mapping, u32 offset,
+			 u32 len)
+{
+	struct bnxt_sw_tx_bd *tx_buf;
+	struct tx_bd_ext *txbd1;
+	struct tx_bd *txbd;
+	u32 flags;
+	u16 prod;
+
+	if (bnxt_tx_avail(bp, txr) < 2)
+		return -ENOSPC;
+
+	prod = txr->tx_prod;
+	txbd = &txr->tx_desc_ring[TX_RING(prod)][TX_IDX(prod)];
+
+	tx_buf = &txr->tx_buf_ring[prod];
+	tx_buf->page = page;
+	dma_unmap_addr_set(tx_buf, mapping, mapping);
+	flags = (len << TX_BD_LEN_SHIFT) | TX_BD_TYPE_LONG_TX_BD |
+		(2 << TX_BD_FLAGS_BD_CNT_SHIFT) | TX_BD_FLAGS_PACKET_END |
+		bnxt_lhint_arr[len >> 9];
+	txbd->tx_bd_len_flags_type = cpu_to_le32(flags);
+	txbd->tx_bd_opaque = prod;
+	txbd->tx_bd_haddr = cpu_to_le64(mapping + offset);
+
+	prod = NEXT_TX(prod);
+	txbd1 = (struct tx_bd_ext *)
+		&txr->tx_desc_ring[TX_RING(prod)][TX_IDX(prod)];
+
+	txbd1->tx_bd_hsize_lflags = cpu_to_le32(0);
+	txbd1->tx_bd_mss = cpu_to_le32(0);
+	txbd1->tx_bd_cfa_action = cpu_to_le32(0);
+	txbd1->tx_bd_cfa_meta = cpu_to_le32(0);
+
+	prod = NEXT_TX(prod);
+	txr->tx_prod = prod;
+	return 0;
+}
+
+void bnxt_tx_int_xdp(struct bnxt *bp, struct bnxt_napi *bnapi, int nr_pkts)
+{
+	struct bnxt_tx_ring_info *txr = bnapi->tx_ring;
+	struct device *dev = &bp->pdev->dev;
+	u16 cons = txr->tx_cons;
+	int i;
+
+	for (i = 0; i < nr_pkts; i++) {
+		struct bnxt_sw_tx_bd *tx_buf;
+
+		tx_buf = &txr->tx_buf_ring[cons];
+		cons = NEXT_TX(cons);
+		cons = NEXT_TX(cons);
+
+		dma_unmap_page(dev, dma_unmap_addr(tx_buf, mapping), PAGE_SIZE,
+			       bp->rx_dir);
+		__free_page(tx_buf->page);
+		tx_buf->page = NULL;
+	}
+	txr->tx_cons = cons;
+}
+
 /* returns the following:
  * true    - packet consumed by XDP and new buffer is allocated.
  * false   - packet should be passed to the stack.
@@ -61,6 +123,28 @@ bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 	case XDP_PASS:
 		return false;
 
+	case XDP_TX: {
+		struct bnxt_tx_ring_info *txr = rxr->bnapi->tx_ring;
+		int rc;
+
+		rc = bnxt_alloc_rx_data(bp, rxr, rxr->rx_prod, GFP_ATOMIC);
+		if (unlikely(rc)) {
+			trace_xdp_exception(bp->dev, xdp_prog, act);
+			bnxt_reuse_rx_data(rxr, cons, page);
+			return true;
+		}
+		dma_sync_single_for_device(&pdev->dev, mapping + offset, len,
+					   bp->rx_dir);
+		if (bnxt_xmit_xdp(bp, txr, page, mapping, offset, len)) {
+			trace_xdp_exception(bp->dev, xdp_prog, act);
+			dma_unmap_page(&bp->pdev->dev, mapping, PAGE_SIZE,
+				       bp->rx_dir);
+			__free_page(page);
+			return true;
+		}
+		*event |= BNXT_TX_EVENT;
+		return true;
+	}
 	default:
 		bpf_warn_invalid_xdp_action(act);
 		/* Fall thru */
@@ -154,4 +238,10 @@ int bnxt_xdp(struct net_device *dev, struct netdev_xdp *xdp)
 	}
 	return rc;
 }
+
+#else
+
+void bnxt_tx_int_xdp(struct bnxt *bp, struct bnxt_napi *bnapi, int nr_pkts)
+{
+}
 #endif
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h
index 85c01cc..4589603 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h
@@ -10,6 +10,8 @@
 #ifndef BNXT_XDP_H
 #define BNXT_XDP_H
 
+void bnxt_tx_int_xdp(struct bnxt *bp, struct bnxt_napi *bnapi, int nr_pkts);
+
 #ifdef CONFIG_BNXT_XDP
 bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 		 struct page *page, unsigned int len, u8 *event);
-- 
1.8.3.1
