From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 02/12] bnxt_en: Optimize ring alloc and ring free functions.
Date: Sun, 27 Dec 2015 18:19:19 -0500
Message-ID: <1451258369-21543-3-git-send-email-mchan@broadcom.com>
References: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:39628 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754457AbbL0XTa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 18:19:30 -0500
In-Reply-To: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the unnecessary "if" statement before the "for" statement:

if (x) {
        for (i = 0; i < x; i++)
...
}

Also, change the ring free function to return void as it only returns 0.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 201 +++++++++++++-----------------
 1 file changed, 87 insertions(+), 114 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 8d401e8..e340fb3 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1969,11 +1969,12 @@ static int bnxt_init_one_rx_ring(struct bnxt *bp, int ring_nr)
 	rxr->rx_prod = prod;
 	ring->fw_ring_id = INVALID_HW_RING_ID;
 
+	ring = &rxr->rx_agg_ring_struct;
+	ring->fw_ring_id = INVALID_HW_RING_ID;
+
 	if (!(bp->flags & BNXT_FLAG_AGG_RINGS))
 		return 0;
 
-	ring = &rxr->rx_agg_ring_struct;
-
 	type = ((u32)PAGE_SIZE << RX_BD_LEN_SHIFT) |
 		RX_BD_TYPE_RX_AGG_BD | RX_BD_FLAGS_SOP;
 
@@ -1989,7 +1990,6 @@ static int bnxt_init_one_rx_ring(struct bnxt *bp, int ring_nr)
 		prod = NEXT_RX_AGG(prod);
 	}
 	rxr->rx_agg_prod = prod;
-	ring->fw_ring_id = INVALID_HW_RING_ID;
 
 	if (bp->flags & BNXT_FLAG_TPA) {
 		if (rxr->rx_tpa) {
@@ -3301,54 +3301,45 @@ static int bnxt_hwrm_ring_alloc(struct bnxt *bp)
 {
 	int i, rc = 0;
 
-	if (bp->cp_nr_rings) {
-		for (i = 0; i < bp->cp_nr_rings; i++) {
-			struct bnxt_napi *bnapi = bp->bnapi[i];
-			struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
-			struct bnxt_ring_struct *ring = &cpr->cp_ring_struct;
+	for (i = 0; i < bp->cp_nr_rings; i++) {
+		struct bnxt_napi *bnapi = bp->bnapi[i];
+		struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
+		struct bnxt_ring_struct *ring = &cpr->cp_ring_struct;
 
-			rc = hwrm_ring_alloc_send_msg(bp, ring,
-						      HWRM_RING_ALLOC_CMPL, i,
-						      INVALID_STATS_CTX_ID);
-			if (rc)
-				goto err_out;
-			cpr->cp_doorbell = bp->bar1 + i * 0x80;
-			BNXT_CP_DB(cpr->cp_doorbell, cpr->cp_raw_cons);
-			bp->grp_info[i].cp_fw_ring_id = ring->fw_ring_id;
-		}
+		rc = hwrm_ring_alloc_send_msg(bp, ring, HWRM_RING_ALLOC_CMPL, i,
+					      INVALID_STATS_CTX_ID);
+		if (rc)
+			goto err_out;
+		cpr->cp_doorbell = bp->bar1 + i * 0x80;
+		BNXT_CP_DB(cpr->cp_doorbell, cpr->cp_raw_cons);
+		bp->grp_info[i].cp_fw_ring_id = ring->fw_ring_id;
 	}
 
-	if (bp->tx_nr_rings) {
-		for (i = 0; i < bp->tx_nr_rings; i++) {
-			struct bnxt_napi *bnapi = bp->bnapi[i];
-			struct bnxt_tx_ring_info *txr = &bnapi->tx_ring;
-			struct bnxt_ring_struct *ring = &txr->tx_ring_struct;
-			u16 fw_stats_ctx = bp->grp_info[i].fw_stats_ctx;
+	for (i = 0; i < bp->tx_nr_rings; i++) {
+		struct bnxt_napi *bnapi = bp->bnapi[i];
+		struct bnxt_tx_ring_info *txr = &bnapi->tx_ring;
+		struct bnxt_ring_struct *ring = &txr->tx_ring_struct;
+		u16 fw_stats_ctx = bp->grp_info[i].fw_stats_ctx;
 
-			rc = hwrm_ring_alloc_send_msg(bp, ring,
-						      HWRM_RING_ALLOC_TX, i,
-						      fw_stats_ctx);
-			if (rc)
-				goto err_out;
-			txr->tx_doorbell = bp->bar1 + i * 0x80;
-		}
+		rc = hwrm_ring_alloc_send_msg(bp, ring, HWRM_RING_ALLOC_TX, i,
+					      fw_stats_ctx);
+		if (rc)
+			goto err_out;
+		txr->tx_doorbell = bp->bar1 + i * 0x80;
 	}
 
-	if (bp->rx_nr_rings) {
-		for (i = 0; i < bp->rx_nr_rings; i++) {
-			struct bnxt_napi *bnapi = bp->bnapi[i];
-			struct bnxt_rx_ring_info *rxr = &bnapi->rx_ring;
-			struct bnxt_ring_struct *ring = &rxr->rx_ring_struct;
+	for (i = 0; i < bp->rx_nr_rings; i++) {
+		struct bnxt_napi *bnapi = bp->bnapi[i];
+		struct bnxt_rx_ring_info *rxr = &bnapi->rx_ring;
+		struct bnxt_ring_struct *ring = &rxr->rx_ring_struct;
 
-			rc = hwrm_ring_alloc_send_msg(bp, ring,
-						      HWRM_RING_ALLOC_RX, i,
-						      INVALID_STATS_CTX_ID);
-			if (rc)
-				goto err_out;
-			rxr->rx_doorbell = bp->bar1 + i * 0x80;
-			writel(DB_KEY_RX | rxr->rx_prod, rxr->rx_doorbell);
-			bp->grp_info[i].rx_fw_ring_id = ring->fw_ring_id;
-		}
+		rc = hwrm_ring_alloc_send_msg(bp, ring, HWRM_RING_ALLOC_RX, i,
+					      INVALID_STATS_CTX_ID);
+		if (rc)
+			goto err_out;
+		rxr->rx_doorbell = bp->bar1 + i * 0x80;
+		writel(DB_KEY_RX | rxr->rx_prod, rxr->rx_doorbell);
+		bp->grp_info[i].rx_fw_ring_id = ring->fw_ring_id;
 	}
 
 	if (bp->flags & BNXT_FLAG_AGG_RINGS) {
@@ -3416,91 +3407,73 @@ static int hwrm_ring_free_send_msg(struct bnxt *bp,
 	return 0;
 }
 
-static int bnxt_hwrm_ring_free(struct bnxt *bp, bool close_path)
+static void bnxt_hwrm_ring_free(struct bnxt *bp, bool close_path)
 {
-	int i, rc = 0;
+	int i;
 
 	if (!bp->bnapi)
-		return 0;
+		return;
 
-	if (bp->tx_nr_rings) {
-		for (i = 0; i < bp->tx_nr_rings; i++) {
-			struct bnxt_napi *bnapi = bp->bnapi[i];
-			struct bnxt_tx_ring_info *txr = &bnapi->tx_ring;
-			struct bnxt_ring_struct *ring = &txr->tx_ring_struct;
-			u32 cmpl_ring_id = bp->grp_info[i].cp_fw_ring_id;
-
-			if (ring->fw_ring_id != INVALID_HW_RING_ID) {
-				hwrm_ring_free_send_msg(
-					bp, ring,
-					RING_FREE_REQ_RING_TYPE_TX,
-					close_path ? cmpl_ring_id :
-					INVALID_HW_RING_ID);
-				ring->fw_ring_id = INVALID_HW_RING_ID;
-			}
+	for (i = 0; i < bp->tx_nr_rings; i++) {
+		struct bnxt_napi *bnapi = bp->bnapi[i];
+		struct bnxt_tx_ring_info *txr = &bnapi->tx_ring;
+		struct bnxt_ring_struct *ring = &txr->tx_ring_struct;
+		u32 cmpl_ring_id = bp->grp_info[i].cp_fw_ring_id;
+
+		if (ring->fw_ring_id != INVALID_HW_RING_ID) {
+			hwrm_ring_free_send_msg(bp, ring,
+						RING_FREE_REQ_RING_TYPE_TX,
+						close_path ? cmpl_ring_id :
+						INVALID_HW_RING_ID);
+			ring->fw_ring_id = INVALID_HW_RING_ID;
 		}
 	}
 
-	if (bp->rx_nr_rings) {
-		for (i = 0; i < bp->rx_nr_rings; i++) {
-			struct bnxt_napi *bnapi = bp->bnapi[i];
-			struct bnxt_rx_ring_info *rxr = &bnapi->rx_ring;
-			struct bnxt_ring_struct *ring = &rxr->rx_ring_struct;
-			u32 cmpl_ring_id = bp->grp_info[i].cp_fw_ring_id;
-
-			if (ring->fw_ring_id != INVALID_HW_RING_ID) {
-				hwrm_ring_free_send_msg(
-					bp, ring,
-					RING_FREE_REQ_RING_TYPE_RX,
-					close_path ? cmpl_ring_id :
-					INVALID_HW_RING_ID);
-				ring->fw_ring_id = INVALID_HW_RING_ID;
-				bp->grp_info[i].rx_fw_ring_id =
-					INVALID_HW_RING_ID;
-			}
+	for (i = 0; i < bp->rx_nr_rings; i++) {
+		struct bnxt_napi *bnapi = bp->bnapi[i];
+		struct bnxt_rx_ring_info *rxr = &bnapi->rx_ring;
+		struct bnxt_ring_struct *ring = &rxr->rx_ring_struct;
+		u32 cmpl_ring_id = bp->grp_info[i].cp_fw_ring_id;
+
+		if (ring->fw_ring_id != INVALID_HW_RING_ID) {
+			hwrm_ring_free_send_msg(bp, ring,
+						RING_FREE_REQ_RING_TYPE_RX,
+						close_path ? cmpl_ring_id :
+						INVALID_HW_RING_ID);
+			ring->fw_ring_id = INVALID_HW_RING_ID;
+			bp->grp_info[i].rx_fw_ring_id = INVALID_HW_RING_ID;
 		}
 	}
 
-	if (bp->rx_agg_nr_pages) {
-		for (i = 0; i < bp->rx_nr_rings; i++) {
-			struct bnxt_napi *bnapi = bp->bnapi[i];
-			struct bnxt_rx_ring_info *rxr = &bnapi->rx_ring;
-			struct bnxt_ring_struct *ring =
-						&rxr->rx_agg_ring_struct;
-			u32 cmpl_ring_id = bp->grp_info[i].cp_fw_ring_id;
-
-			if (ring->fw_ring_id != INVALID_HW_RING_ID) {
-				hwrm_ring_free_send_msg(
-					bp, ring,
-					RING_FREE_REQ_RING_TYPE_RX,
-					close_path ? cmpl_ring_id :
-					INVALID_HW_RING_ID);
-				ring->fw_ring_id = INVALID_HW_RING_ID;
-				bp->grp_info[i].agg_fw_ring_id =
-					INVALID_HW_RING_ID;
-			}
+	for (i = 0; i < bp->rx_nr_rings; i++) {
+		struct bnxt_napi *bnapi = bp->bnapi[i];
+		struct bnxt_rx_ring_info *rxr = &bnapi->rx_ring;
+		struct bnxt_ring_struct *ring = &rxr->rx_agg_ring_struct;
+		u32 cmpl_ring_id = bp->grp_info[i].cp_fw_ring_id;
+
+		if (ring->fw_ring_id != INVALID_HW_RING_ID) {
+			hwrm_ring_free_send_msg(bp, ring,
+						RING_FREE_REQ_RING_TYPE_RX,
+						close_path ? cmpl_ring_id :
+						INVALID_HW_RING_ID);
+			ring->fw_ring_id = INVALID_HW_RING_ID;
+			bp->grp_info[i].agg_fw_ring_id = INVALID_HW_RING_ID;
 		}
 	}
 
-	if (bp->cp_nr_rings) {
-		for (i = 0; i < bp->cp_nr_rings; i++) {
-			struct bnxt_napi *bnapi = bp->bnapi[i];
-			struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
-			struct bnxt_ring_struct *ring = &cpr->cp_ring_struct;
-
-			if (ring->fw_ring_id != INVALID_HW_RING_ID) {
-				hwrm_ring_free_send_msg(
-					bp, ring,
-					RING_FREE_REQ_RING_TYPE_CMPL,
-					INVALID_HW_RING_ID);
-				ring->fw_ring_id = INVALID_HW_RING_ID;
-				bp->grp_info[i].cp_fw_ring_id =
-							INVALID_HW_RING_ID;
-			}
+	for (i = 0; i < bp->cp_nr_rings; i++) {
+		struct bnxt_napi *bnapi = bp->bnapi[i];
+		struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
+		struct bnxt_ring_struct *ring = &cpr->cp_ring_struct;
+
+		if (ring->fw_ring_id != INVALID_HW_RING_ID) {
+			hwrm_ring_free_send_msg(bp, ring,
+						RING_FREE_REQ_RING_TYPE_CMPL,
+						INVALID_HW_RING_ID);
+			ring->fw_ring_id = INVALID_HW_RING_ID;
+			bp->grp_info[i].cp_fw_ring_id = INVALID_HW_RING_ID;
 		}
 	}
-
-	return rc;
 }
 
 int bnxt_hwrm_set_coal(struct bnxt *bp)
-- 
1.8.3.1
