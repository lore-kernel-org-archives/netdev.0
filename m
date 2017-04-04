From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 11/12] bnxt_en: Use short TX BDs for the XDP TX ring.
Date: Tue,  4 Apr 2017 18:14:16 -0400
Message-ID: <1491344057-12663-12-git-send-email-michael.chan@broadcom.com>
References: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:34620 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755236AbdDDWPH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 18:15:07 -0400
Received: by mail-wr0-f178.google.com with SMTP id t20so20403515wra.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 15:15:01 -0700 (PDT)
In-Reply-To: <1491344057-12663-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No offload is performed on the XDP_TX ring so we can use the short TX
BDs.  This has the effect of doubling the size of the XDP TX ring so
that it now matches the size of the rx ring by default.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c | 16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
index 8b27137..9dae327 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_xdp.c
@@ -23,7 +23,6 @@ void bnxt_xmit_xdp(struct bnxt *bp, struct bnxt_tx_ring_info *txr,
 		   dma_addr_t mapping, u32 len, u16 rx_prod)
 {
 	struct bnxt_sw_tx_bd *tx_buf;
-	struct tx_bd_ext *txbd1;
 	struct tx_bd *txbd;
 	u32 flags;
 	u16 prod;
@@ -33,23 +32,13 @@ void bnxt_xmit_xdp(struct bnxt *bp, struct bnxt_tx_ring_info *txr,
 	tx_buf->rx_prod = rx_prod;
 
 	txbd = &txr->tx_desc_ring[TX_RING(prod)][TX_IDX(prod)];
-	flags = (len << TX_BD_LEN_SHIFT) | TX_BD_TYPE_LONG_TX_BD |
-		(2 << TX_BD_FLAGS_BD_CNT_SHIFT) | TX_BD_FLAGS_COAL_NOW |
+	flags = (len << TX_BD_LEN_SHIFT) | (1 << TX_BD_FLAGS_BD_CNT_SHIFT) |
 		TX_BD_FLAGS_PACKET_END | bnxt_lhint_arr[len >> 9];
 	txbd->tx_bd_len_flags_type = cpu_to_le32(flags);
 	txbd->tx_bd_opaque = prod;
 	txbd->tx_bd_haddr = cpu_to_le64(mapping);
 
 	prod = NEXT_TX(prod);
-	txbd1 = (struct tx_bd_ext *)
-		&txr->tx_desc_ring[TX_RING(prod)][TX_IDX(prod)];
-
-	txbd1->tx_bd_hsize_lflags = cpu_to_le32(0);
-	txbd1->tx_bd_mss = cpu_to_le32(0);
-	txbd1->tx_bd_cfa_action = cpu_to_le32(0);
-	txbd1->tx_bd_cfa_meta = cpu_to_le32(0);
-
-	prod = NEXT_TX(prod);
 	txr->tx_prod = prod;
 }
 
@@ -66,7 +55,6 @@ void bnxt_tx_int_xdp(struct bnxt *bp, struct bnxt_napi *bnapi, int nr_pkts)
 	for (i = 0; i < nr_pkts; i++) {
 		last_tx_cons = tx_cons;
 		tx_cons = NEXT_TX(tx_cons);
-		tx_cons = NEXT_TX(tx_cons);
 	}
 	txr->tx_cons = tx_cons;
 	if (bnxt_tx_avail(bp, txr) == bp->tx_ring_size) {
@@ -133,7 +121,7 @@ bool bnxt_rx_xdp(struct bnxt *bp, struct bnxt_rx_ring_info *rxr, u16 cons,
 		return false;
 
 	case XDP_TX:
-		if (tx_avail < 2) {
+		if (tx_avail < 1) {
 			trace_xdp_exception(bp->dev, xdp_prog, act);
 			bnxt_reuse_rx_data(rxr, cons, page);
 			return true;
-- 
1.8.3.1
