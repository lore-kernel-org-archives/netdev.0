From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v3 12/12] bnxt_en: Add support for XDP_TX action.
Date: Mon,  6 Feb 2017 16:55:43 -0500
Message-ID: <1486418143-8958-13-git-send-email-michael.chan@broadcom.com>
References: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33112 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752141AbdBFV4M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2017 16:56:12 -0500
Received: by mail-pg0-f51.google.com with SMTP id 204so31843484pge.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 13:56:12 -0800 (PST)
In-Reply-To: <1486418143-8958-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add dedicated transmit function and transmit completion handler for
XDP.  The XDP transmit logic and completion logic are different than
regular TX ring.  The TX buffer is recycled back to the RX ring when
it completes.

v3: Improved the buffer recyling scheme for XDP_TX.

v2: Add trace_xdp_exception().
    Add dma_sync.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
Tested-by: Andy Gospodarek <gospo@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c     | 36 ++++++------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h     | 19 +++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c | 83 +++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h |  1 +
 4 files changed, 122 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 665fe4f..cda1c78 100644
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
@@ -1766,6 +1756,18 @@ static int bnxt_poll_work(struct bnxt *bp, struct bnxt_napi *bnapi, int budget)
 			break;
 	}
 
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
+
 	cpr->cp_raw_cons = raw_cons;
 	/* ACK completion ring before freeing tx ring and producing new
 	 * buffers in rx/agg rings to prevent overflowing the completion
@@ -3066,12 +3068,14 @@ static int bnxt_alloc_mem(struct bnxt *bp, bool irq_re_init)
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
index db4a410..9f07b9c 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -514,13 +514,17 @@ struct rx_tpa_end_cmp_ext {
 
 #define BNXT_RX_EVENT	1
 #define BNXT_AGG_EVENT	2
+#define BNXT_TX_EVENT	4
 
 struct bnxt_sw_tx_bd {
 	struct sk_buff		*skb;
 	DEFINE_DMA_UNMAP_ADDR(mapping);
 	u8			is_gso;
 	u8			is_push;
-	unsigned short		nr_frags;
+	union {
+		unsigned short		nr_frags;
+		u16			rx_prod;
+	};
 };
 
 struct bnxt_sw_rx_bd {
@@ -1191,6 +1195,19 @@ struct bnxt {
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
index b822e46..899c30f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
@@ -19,6 +19,65 @@
 #include "bnxt.h"
 #include "bnxt_xdp.h"
 
+static void bnxt_xmit_xdp(struct bnxt *bp, struct bnxt_tx_ring_info *txr,
+			  dma_addr_t mapping, u32 len, u16 rx_prod)
+{
+	struct bnxt_sw_tx_bd *tx_buf;
+	struct tx_bd_ext *txbd1;
+	struct tx_bd *txbd;
+	u32 flags;
+	u16 prod;
+
+	prod = txr->tx_prod;
+	tx_buf = &txr->tx_buf_ring[prod];
+	tx_buf->rx_prod = rx_prod;
+
+	txbd = &txr->tx_desc_ring[TX_RING(prod)][TX_IDX(prod)];
+	flags = (len << TX_BD_LEN_SHIFT) | TX_BD_TYPE_LONG_TX_BD |
+		(2 << TX_BD_FLAGS_BD_CNT_SHIFT) | TX_BD_FLAGS_COAL_NOW |
+		TX_BD_FLAGS_PACKET_END | bnxt_lhint_arr[len >> 9];
+	txbd->tx_bd_len_flags_type = cpu_to_le32(flags);
+	txbd->tx_bd_opaque = prod;
+	txbd->tx_bd_haddr = cpu_to_le64(mapping);
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
+}
+
+void bnxt_tx_int_xdp(struct bnxt *bp, struct bnxt_napi *bnapi, int nr_pkts)
+{
+	struct bnxt_tx_ring_info *txr = bnapi->tx_ring;
+	struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
+	struct bnxt_sw_tx_bd *tx_buf;
+	u16 tx_cons = txr->tx_cons;
+	u16 last_tx_cons = tx_cons;
+	u16 rx_prod;
+	int i;
+
+	for (i = 0; i < nr_pkts; i++) {
+		last_tx_cons = tx_cons;
+		tx_cons = NEXT_TX(tx_cons);
+		tx_cons = NEXT_TX(tx_cons);
+	}
+	txr->tx_cons = tx_cons;
+	if (bnxt_tx_avail(bp, txr) == bp->tx_ring_size) {
+		rx_prod = rxr->rx_prod;
+	} else {
+		tx_buf = &txr->tx_buf_ring[last_tx_cons];
+		rx_prod = tx_buf->rx_prod;
+	}
+	writel(DB_KEY_RX | rx_prod, rxr->rx_doorbell);
+}
+
 /* returns the following:
  * true    - packet consumed by XDP and new buffer is allocated.
  * false   - packet should be passed to the stack.
@@ -27,11 +86,13 @@ bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 		 struct page *page, u8 **data_ptr, unsigned int *len, u8 *event)
 {
 	struct bpf_prog *xdp_prog = READ_ONCE(rxr->xdp_prog);
+	struct bnxt_tx_ring_info *txr;
 	struct bnxt_sw_rx_bd *rx_buf;
 	struct pci_dev *pdev;
 	struct xdp_buff xdp;
 	dma_addr_t mapping;
 	void *orig_data;
+	u32 tx_avail;
 	u32 offset;
 	u32 act;
 
@@ -39,6 +100,7 @@ bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 		return false;
 
 	pdev = bp->pdev;
+	txr = rxr->bnapi->tx_ring;
 	rx_buf = &rxr->rx_buf_ring[cons];
 	offset = bp->rx_offset;
 
@@ -54,6 +116,13 @@ bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 	act = bpf_prog_run_xdp(xdp_prog, &xdp);
 	rcu_read_unlock();
 
+	tx_avail = bnxt_tx_avail(bp, txr);
+	/* If the tx ring is not full, we must not update the rx producer yet
+	 * because we may still be transmitting on some BDs.
+	 */
+	if (tx_avail != bp->tx_ring_size)
+		*event &= ~BNXT_RX_EVENT;
+
 	if (orig_data != xdp.data) {
 		offset = xdp.data - xdp.data_hard_start;
 		*data_ptr = xdp.data_hard_start + offset;
@@ -63,6 +132,20 @@ bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 	case XDP_PASS:
 		return false;
 
+	case XDP_TX:
+		if (tx_avail < 2) {
+			trace_xdp_exception(bp->dev, xdp_prog, act);
+			bnxt_reuse_rx_data(rxr, cons, page);
+			return true;
+		}
+
+		*event = BNXT_TX_EVENT;
+		dma_sync_single_for_device(&pdev->dev, mapping + offset, *len,
+					   bp->rx_dir);
+		bnxt_xmit_xdp(bp, txr, mapping + offset, *len,
+			      NEXT_RX(rxr->rx_prod));
+		bnxt_reuse_rx_data(rxr, cons, page);
+		return true;
 	default:
 		bpf_warn_invalid_xdp_action(act);
 		/* Fall thru */
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h
index 0bb7b7d..b529f2c 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.h
@@ -10,6 +10,7 @@
 #ifndef BNXT_XDP_H
 #define BNXT_XDP_H
 
+void bnxt_tx_int_xdp(struct bnxt *bp, struct bnxt_napi *bnapi, int nr_pkts);
 bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 		 struct page *page, u8 **data_ptr, unsigned int *len,
 		 u8 *event);
-- 
1.8.3.1
