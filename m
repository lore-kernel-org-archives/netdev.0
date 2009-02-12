From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 36/41]bnx2x: Driver dump
Date: Thu, 12 Feb 2009 20:38:22 +0200
Message-ID: <1234463902.1863.168.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1658 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758877AbZBLSpL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 13:45:11 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subject: [PATCH 36/41]bnx2x: Driver dump
Re-arrange the driver debug print to support the Tx multi-queue and add support
for debug prints at the end of the ring (when start<end)

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   97 ++++++++++++++++++++++++++++------------------
 1 files changed, 59 insertions(+), 38 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 26451f6..78f628a 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -507,50 +507,54 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 
 	BNX2X_ERR("begin crash dump -----------------\n");
 
-	for_each_queue(bp, i) {
+	/* Indices */
+	/* Common */
+	BNX2X_ERR("def_c_idx(%u)  def_u_idx(%u)  def_x_idx(%u)"
+		  "  def_t_idx(%u)  def_att_idx(%u)  attn_state(%u)"
+		  "  spq_prod_idx(%u)\n",
+		  bp->def_c_idx, bp->def_u_idx, bp->def_x_idx, bp->def_t_idx,
+		  bp->def_att_idx, bp->attn_state, bp->spq_prod_idx);
+
+	/* Rx */
+	for_each_rx_queue(bp, i) {
 		struct bnx2x_fastpath *fp = &bp->fp[i];
-		struct eth_tx_db_data *hw_prods = fp->hw_tx_prods;
 
-		BNX2X_ERR("queue[%d]: tx_pkt_prod(%x)  tx_pkt_cons(%x)"
-			  "  tx_bd_prod(%x)  tx_bd_cons(%x)  *tx_cons_sb(%x)\n",
-			  i, fp->tx_pkt_prod, fp->tx_pkt_cons, fp->tx_bd_prod,
-			  fp->tx_bd_cons, le16_to_cpu(*fp->tx_cons_sb));
-		BNX2X_ERR("          rx_bd_prod(%x)  rx_bd_cons(%x)"
+		BNX2X_ERR("queue[%d]: rx_bd_prod(%x)  rx_bd_cons(%x)"
 			  "  *rx_bd_cons_sb(%x)  rx_comp_prod(%x)"
 			  "  rx_comp_cons(%x)  *rx_cons_sb(%x)\n",
-			  fp->rx_bd_prod, fp->rx_bd_cons,
+			  i, fp->rx_bd_prod, fp->rx_bd_cons,
 			  le16_to_cpu(*fp->rx_bd_cons_sb), fp->rx_comp_prod,
 			  fp->rx_comp_cons, le16_to_cpu(*fp->rx_cons_sb));
 		BNX2X_ERR("          rx_sge_prod(%x)  last_max_sge(%x)"
-			  "  fp_c_idx(%x)  *sb_c_idx(%x)  fp_u_idx(%x)"
-			  "  *sb_u_idx(%x)  bd data(%x,%x)\n",
-			  fp->rx_sge_prod, fp->last_max_sge, fp->fp_c_idx,
-			  fp->status_blk->c_status_block.status_block_index,
-			  fp->fp_u_idx,
-			  fp->status_blk->u_status_block.status_block_index,
-			  hw_prods->packets_prod, hw_prods->bds_prod);
-
-		start = TX_BD(le16_to_cpu(*fp->tx_cons_sb) - 10);
-		end = TX_BD(le16_to_cpu(*fp->tx_cons_sb) + 245);
-		for (j = start; j < end; j++) {
-			struct sw_tx_bd *sw_bd = &fp->tx_buf_ring[j];
+			  "  fp_u_idx(%x) *sb_u_idx(%x)\n",
+			  fp->rx_sge_prod, fp->last_max_sge,
+			  le16_to_cpu(fp->fp_u_idx),
+			  fp->status_blk->u_status_block.status_block_index);
+	}
 
-			BNX2X_ERR("packet[%x]=[%p,%x]\n", j,
-				  sw_bd->skb, sw_bd->first_bd);
-		}
+	/* Tx */
+	for_each_tx_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
+		struct eth_tx_db_data *hw_prods = fp->hw_tx_prods;
 
-		start = TX_BD(fp->tx_bd_cons - 10);
-		end = TX_BD(fp->tx_bd_cons + 254);
-		for (j = start; j < end; j++) {
-			u32 *tx_bd = (u32 *)&fp->tx_desc_ring[j];
+		BNX2X_ERR("queue[%d]: tx_pkt_prod(%x)  tx_pkt_cons(%x)"
+			  "  tx_bd_prod(%x)  tx_bd_cons(%x)  *tx_cons_sb(%x)\n",
+			  i, fp->tx_pkt_prod, fp->tx_pkt_cons, fp->tx_bd_prod,
+			  fp->tx_bd_cons, le16_to_cpu(*fp->tx_cons_sb));
+		BNX2X_ERR("          fp_c_idx(%x)  *sb_c_idx(%x)"
+			  "  bd data(%x,%x)\n", le16_to_cpu(fp->fp_c_idx),
+			  fp->status_blk->c_status_block.status_block_index,
+			  hw_prods->packets_prod, hw_prods->bds_prod);
+	}
 
-			BNX2X_ERR("tx_bd[%x]=[%x:%x:%x:%x]\n",
-				  j, tx_bd[0], tx_bd[1], tx_bd[2], tx_bd[3]);
-		}
+	/* Rings */
+	/* Rx */
+	for_each_rx_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
 
 		start = RX_BD(le16_to_cpu(*fp->rx_cons_sb) - 10);
 		end = RX_BD(le16_to_cpu(*fp->rx_cons_sb) + 503);
-		for (j = start; j < end; j++) {
+		for (j = start; j != end; j = RX_BD(j + 1)) {
 			u32 *rx_bd = (u32 *)&fp->rx_desc_ring[j];
 			struct sw_rx_bd *sw_bd = &fp->rx_buf_ring[j];
 
@@ -560,7 +564,7 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 
 		start = RX_SGE(fp->rx_sge_prod);
 		end = RX_SGE(fp->last_max_sge);
-		for (j = start; j < end; j++) {
+		for (j = start; j != end; j = RX_SGE(j + 1)) {
 			u32 *rx_sge = (u32 *)&fp->rx_sge_ring[j];
 			struct sw_rx_page *sw_page = &fp->rx_page_ring[j];
 
@@ -570,7 +574,7 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 
 		start = RCQ_BD(fp->rx_comp_cons - 10);
 		end = RCQ_BD(fp->rx_comp_cons + 503);
-		for (j = start; j < end; j++) {
+		for (j = start; j != end; j = RCQ_BD(j + 1)) {
 			u32 *cqe = (u32 *)&fp->rx_comp_ring[j];
 
 			BNX2X_ERR("cqe[%x]=[%x:%x:%x:%x]\n",
@@ -578,11 +582,28 @@ static void bnx2x_panic_dump(struct bnx2x *bp)
 		}
 	}
 
-	BNX2X_ERR("def_c_idx(%u)  def_u_idx(%u)  def_x_idx(%u)"
-		  "  def_t_idx(%u)  def_att_idx(%u)  attn_state(%u)"
-		  "  spq_prod_idx(%u)\n",
-		  bp->def_c_idx, bp->def_u_idx, bp->def_x_idx, bp->def_t_idx,
-		  bp->def_att_idx, bp->attn_state, bp->spq_prod_idx);
+	/* Tx */
+	for_each_tx_queue(bp, i) {
+		struct bnx2x_fastpath *fp = &bp->fp[i];
+
+		start = TX_BD(le16_to_cpu(*fp->tx_cons_sb) - 10);
+		end = TX_BD(le16_to_cpu(*fp->tx_cons_sb) + 245);
+		for (j = start; j != end; j = TX_BD(j + 1)) {
+			struct sw_tx_bd *sw_bd = &fp->tx_buf_ring[j];
+
+			BNX2X_ERR("packet[%x]=[%p,%x]\n", j,
+				  sw_bd->skb, sw_bd->first_bd);
+		}
+
+		start = TX_BD(fp->tx_bd_cons - 10);
+		end = TX_BD(fp->tx_bd_cons + 254);
+		for (j = start; j != end; j = TX_BD(j + 1)) {
+			u32 *tx_bd = (u32 *)&fp->tx_desc_ring[j];
+
+			BNX2X_ERR("tx_bd[%x]=[%x:%x:%x:%x]\n",
+				  j, tx_bd[0], tx_bd[1], tx_bd[2], tx_bd[3]);
+		}
+	}
 
 	bnx2x_fw_dump(bp);
 	bnx2x_mc_assert(bp);
-- 
1.5.4.3




