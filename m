From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 04/10] bnxt_en: Use event bit map in RX path.
Date: Mon, 30 Jan 2017 20:49:29 -0500
Message-ID: <1485827375-20421-5-git-send-email-michael.chan@broadcom.com>
References: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36688 "EHLO
        mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751982AbdAaBur (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Jan 2017 20:50:47 -0500
Received: by mail-pf0-f175.google.com with SMTP id 189so96675154pfu.3
        for <netdev@vger.kernel.org>; Mon, 30 Jan 2017 17:49:59 -0800 (PST)
In-Reply-To: <1485827375-20421-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the current code, we have separate rx_event and agg_event parameters
to keep track of rx and aggregation events.  Combine these events into
an u8 event mask with different bits defined for different events.  This
way, it is easier to expand the logic to include XDP tx events.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 28 +++++++++++++---------------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  3 +++
 2 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c63570d..0f6ca67 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1264,7 +1264,7 @@ static inline struct sk_buff *bnxt_tpa_end(struct bnxt *bp,
 					   u32 *raw_cons,
 					   struct rx_tpa_end_cmp *tpa_end,
 					   struct rx_tpa_end_cmp_ext *tpa_end1,
-					   bool *agg_event)
+					   u8 *event)
 {
 	struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
 	struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
@@ -1299,7 +1299,7 @@ static inline struct sk_buff *bnxt_tpa_end(struct bnxt *bp,
 		if (!bnxt_agg_bufs_valid(bp, cpr, agg_bufs, raw_cons))
 			return ERR_PTR(-EBUSY);
 
-		*agg_event = true;
+		*event |= BNXT_AGG_EVENT;
 		cp_cons = NEXT_CMP(cp_cons);
 	}
 
@@ -1385,7 +1385,7 @@ static inline struct sk_buff *bnxt_tpa_end(struct bnxt *bp,
  * -EIO    - packet aborted due to hw error indicated in BD
  */
 static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
-		       bool *agg_event)
+		       u8 *event)
 {
 	struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
 	struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
@@ -1426,8 +1426,7 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 	} else if (cmp_type == CMP_TYPE_RX_L2_TPA_END_CMP) {
 		skb = bnxt_tpa_end(bp, bnapi, &tmp_raw_cons,
 				   (struct rx_tpa_end_cmp *)rxcmp,
-				   (struct rx_tpa_end_cmp_ext *)rxcmp1,
-				   agg_event);
+				   (struct rx_tpa_end_cmp_ext *)rxcmp1, event);
 
 		if (unlikely(IS_ERR(skb)))
 			return -EBUSY;
@@ -1461,7 +1460,7 @@ static int bnxt_rx_pkt(struct bnxt *bp, struct bnxt_napi *bnapi, u32 *raw_cons,
 			return -EBUSY;
 
 		cp_cons = NEXT_CMP(cp_cons);
-		*agg_event = true;
+		*event |= BNXT_AGG_EVENT;
 	}
 
 	rx_buf->data = NULL;
@@ -1714,8 +1713,7 @@ static int bnxt_poll_work(struct bnxt *bp, struct bnxt_napi *bnapi, int budget)
 	u32 cons;
 	int tx_pkts = 0;
 	int rx_pkts = 0;
-	bool rx_event = false;
-	bool agg_event = false;
+	u8 event = 0;
 	struct tx_cmp *txcmp;
 
 	while (1) {
@@ -1737,12 +1735,12 @@ static int bnxt_poll_work(struct bnxt *bp, struct bnxt_napi *bnapi, int budget)
 			if (unlikely(tx_pkts > bp->tx_wake_thresh))
 				rx_pkts = budget;
 		} else if ((TX_CMP_TYPE(txcmp) & 0x30) == 0x10) {
-			rc = bnxt_rx_pkt(bp, bnapi, &raw_cons, &agg_event);
+			rc = bnxt_rx_pkt(bp, bnapi, &raw_cons, &event);
 			if (likely(rc >= 0))
 				rx_pkts += rc;
 			else if (rc == -EBUSY)	/* partial completion */
 				break;
-			rx_event = true;
+			event |= BNXT_RX_EVENT;
 		} else if (unlikely((TX_CMP_TYPE(txcmp) ==
 				     CMPL_BASE_TYPE_HWRM_DONE) ||
 				    (TX_CMP_TYPE(txcmp) ==
@@ -1767,12 +1765,12 @@ static int bnxt_poll_work(struct bnxt *bp, struct bnxt_napi *bnapi, int budget)
 	if (tx_pkts)
 		bnxt_tx_int(bp, bnapi, tx_pkts);
 
-	if (rx_event) {
+	if (event & BNXT_RX_EVENT) {
 		struct bnxt_rx_ring_info *rxr = bnapi->rx_ring;
 
 		writel(DB_KEY_RX | rxr->rx_prod, rxr->rx_doorbell);
 		writel(DB_KEY_RX | rxr->rx_prod, rxr->rx_doorbell);
-		if (agg_event) {
+		if (event & BNXT_AGG_EVENT) {
 			writel(DB_KEY_RX | rxr->rx_agg_prod,
 			       rxr->rx_agg_doorbell);
 			writel(DB_KEY_RX | rxr->rx_agg_prod,
@@ -1793,7 +1791,7 @@ static int bnxt_poll_nitroa0(struct napi_struct *napi, int budget)
 	u32 cp_cons, tmp_raw_cons;
 	u32 raw_cons = cpr->cp_raw_cons;
 	u32 rx_pkts = 0;
-	bool agg_event = false;
+	u8 event = 0;
 
 	while (1) {
 		int rc;
@@ -1817,7 +1815,7 @@ static int bnxt_poll_nitroa0(struct napi_struct *napi, int budget)
 			rxcmp1->rx_cmp_cfa_code_errors_v2 |=
 				cpu_to_le32(RX_CMPL_ERRORS_CRC_ERROR);
 
-			rc = bnxt_rx_pkt(bp, bnapi, &raw_cons, &agg_event);
+			rc = bnxt_rx_pkt(bp, bnapi, &raw_cons, &event);
 			if (likely(rc == -EIO))
 				rx_pkts++;
 			else if (rc == -EBUSY)	/* partial completion */
@@ -1840,7 +1838,7 @@ static int bnxt_poll_nitroa0(struct napi_struct *napi, int budget)
 	writel(DB_KEY_RX | rxr->rx_prod, rxr->rx_doorbell);
 	writel(DB_KEY_RX | rxr->rx_prod, rxr->rx_doorbell);
 
-	if (agg_event) {
+	if (event & BNXT_AGG_EVENT) {
 		writel(DB_KEY_RX | rxr->rx_agg_prod, rxr->rx_agg_doorbell);
 		writel(DB_KEY_RX | rxr->rx_agg_prod, rxr->rx_agg_doorbell);
 	}
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index b55a9c1..2202113 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -511,6 +511,9 @@ struct rx_tpa_end_cmp_ext {
 #define BNXT_HWRM_REQS_PER_PAGE		(BNXT_PAGE_SIZE /	\
 					 BNXT_HWRM_REQ_MAX_SIZE)
 
+#define BNXT_RX_EVENT	1
+#define BNXT_AGG_EVENT	2
+
 struct bnxt_sw_tx_bd {
 	struct sk_buff		*skb;
 	DEFINE_DMA_UNMAP_ADDR(mapping);
-- 
1.8.3.1
