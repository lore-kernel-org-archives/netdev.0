From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 4/7] bnxt_en: Re-structure ring indexing and mapping.
Date: Sat, 2 Jan 2016 23:45:01 -0500
Message-ID: <1451796304-23220-5-git-send-email-mchan@broadcom.com>
References: <1451796304-23220-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw3-out.broadcom.com ([216.31.210.64]:52177 "EHLO
	mail-gw3-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbcACEpJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2016 23:45:09 -0500
In-Reply-To: <1451796304-23220-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to support dedicated or shared completion rings, the ring
indexing and mapping are re-structured as below:

1. bp->grp_info[] array index is 1:1 with bp->bnapi[] array index and
completion ring index.

2. rx rings 0 to n will be mapped to completion rings 0 to n.

3. If tx and rx rings share completion rings, then tx rings 0 to m will
be mapped to completion rings 0 to m.

4. If tx and rx rings use dedicated completion rings, then tx rings 0 to
m will be mapped to completion rings n + 1 to n + m.

5. Each tx or rx ring will use the corresponding completion ring index
for doorbell mapping and MSIX mapping.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 91 ++++++++++++++++++-------------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  2 +
 2 files changed, 55 insertions(+), 38 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 11478c9..8a54dab 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -422,7 +422,7 @@ tx_dma_error:
 static void bnxt_tx_int(struct bnxt *bp, struct bnxt_napi *bnapi, int nr_pkts)
 {
 	struct bnxt_tx_ring_info *txr = bnapi->tx_ring;
-	int index = bnapi->index;
+	int index = txr - &bp->tx_ring[0];
 	struct netdev_queue *txq = netdev_get_tx_queue(bp->dev, index);
 	u16 cons = txr->tx_cons;
 	struct pci_dev *pdev = bp->pdev;
@@ -3082,7 +3082,7 @@ static int bnxt_hwrm_vnic_ctx_alloc(struct bnxt *bp, u16 vnic_id)
 
 static int bnxt_hwrm_vnic_cfg(struct bnxt *bp, u16 vnic_id)
 {
-	int grp_idx = 0;
+	unsigned int ring = 0, grp_idx;
 	struct bnxt_vnic_info *vnic = &bp->vnic_info[vnic_id];
 	struct hwrm_vnic_cfg_input req = {0};
 
@@ -3093,10 +3093,11 @@ static int bnxt_hwrm_vnic_cfg(struct bnxt *bp, u16 vnic_id)
 	req.rss_rule = cpu_to_le16(vnic->fw_rss_cos_lb_ctx);
 	req.cos_rule = cpu_to_le16(0xffff);
 	if (vnic->flags & BNXT_VNIC_RSS_FLAG)
-		grp_idx = 0;
+		ring = 0;
 	else if (vnic->flags & BNXT_VNIC_RFS_FLAG)
-		grp_idx = vnic_id - 1;
+		ring = vnic_id - 1;
 
+	grp_idx = bp->rx_ring[ring].bnapi->index;
 	req.vnic_id = cpu_to_le16(vnic->fw_vnic_id);
 	req.dflt_ring_grp = cpu_to_le16(bp->grp_info[grp_idx].fw_grp_id);
 
@@ -3137,22 +3138,25 @@ static void bnxt_hwrm_vnic_free(struct bnxt *bp)
 		bnxt_hwrm_vnic_free_one(bp, i);
 }
 
-static int bnxt_hwrm_vnic_alloc(struct bnxt *bp, u16 vnic_id, u16 start_grp_id,
-				u16 end_grp_id)
+static int bnxt_hwrm_vnic_alloc(struct bnxt *bp, u16 vnic_id,
+				unsigned int start_rx_ring_idx,
+				unsigned int nr_rings)
 {
-	u32 rc = 0, i, j;
+	int rc = 0;
+	unsigned int i, j, grp_idx, end_idx = start_rx_ring_idx + nr_rings;
 	struct hwrm_vnic_alloc_input req = {0};
 	struct hwrm_vnic_alloc_output *resp = bp->hwrm_cmd_resp_addr;
 
 	/* map ring groups to this vnic */
-	for (i = start_grp_id, j = 0; i < end_grp_id; i++, j++) {
-		if (bp->grp_info[i].fw_grp_id == INVALID_HW_RING_ID) {
+	for (i = start_rx_ring_idx, j = 0; i < end_idx; i++, j++) {
+		grp_idx = bp->rx_ring[i].bnapi->index;
+		if (bp->grp_info[grp_idx].fw_grp_id == INVALID_HW_RING_ID) {
 			netdev_err(bp->dev, "Not enough ring groups avail:%x req:%x\n",
-				   j, (end_grp_id - start_grp_id));
+				   j, nr_rings);
 			break;
 		}
 		bp->vnic_info[vnic_id].fw_grp_ids[j] =
-					bp->grp_info[i].fw_grp_id;
+					bp->grp_info[grp_idx].fw_grp_id;
 	}
 
 	bp->vnic_info[vnic_id].fw_rss_cos_lb_ctx = INVALID_HW_RING_ID;
@@ -3179,20 +3183,22 @@ static int bnxt_hwrm_ring_grp_alloc(struct bnxt *bp)
 		struct hwrm_ring_grp_alloc_input req = {0};
 		struct hwrm_ring_grp_alloc_output *resp =
 					bp->hwrm_cmd_resp_addr;
+		unsigned int grp_idx = bp->rx_ring[i].bnapi->index;
 
 		bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_RING_GRP_ALLOC, -1, -1);
 
-		req.cr = cpu_to_le16(bp->grp_info[i].cp_fw_ring_id);
-		req.rr = cpu_to_le16(bp->grp_info[i].rx_fw_ring_id);
-		req.ar = cpu_to_le16(bp->grp_info[i].agg_fw_ring_id);
-		req.sc = cpu_to_le16(bp->grp_info[i].fw_stats_ctx);
+		req.cr = cpu_to_le16(bp->grp_info[grp_idx].cp_fw_ring_id);
+		req.rr = cpu_to_le16(bp->grp_info[grp_idx].rx_fw_ring_id);
+		req.ar = cpu_to_le16(bp->grp_info[grp_idx].agg_fw_ring_id);
+		req.sc = cpu_to_le16(bp->grp_info[grp_idx].fw_stats_ctx);
 
 		rc = _hwrm_send_message(bp, &req, sizeof(req),
 					HWRM_CMD_TIMEOUT);
 		if (rc)
 			break;
 
-		bp->grp_info[i].fw_grp_id = le32_to_cpu(resp->ring_group_id);
+		bp->grp_info[grp_idx].fw_grp_id =
+			le32_to_cpu(resp->ring_group_id);
 	}
 	mutex_unlock(&bp->hwrm_cmd_lock);
 	return rc;
@@ -3334,26 +3340,28 @@ static int bnxt_hwrm_ring_alloc(struct bnxt *bp)
 	for (i = 0; i < bp->tx_nr_rings; i++) {
 		struct bnxt_tx_ring_info *txr = &bp->tx_ring[i];
 		struct bnxt_ring_struct *ring = &txr->tx_ring_struct;
-		u16 fw_stats_ctx = bp->grp_info[i].fw_stats_ctx;
+		u32 map_idx = txr->bnapi->index;
+		u16 fw_stats_ctx = bp->grp_info[map_idx].fw_stats_ctx;
 
-		rc = hwrm_ring_alloc_send_msg(bp, ring, HWRM_RING_ALLOC_TX, i,
-					      fw_stats_ctx);
+		rc = hwrm_ring_alloc_send_msg(bp, ring, HWRM_RING_ALLOC_TX,
+					      map_idx, fw_stats_ctx);
 		if (rc)
 			goto err_out;
-		txr->tx_doorbell = bp->bar1 + i * 0x80;
+		txr->tx_doorbell = bp->bar1 + map_idx * 0x80;
 	}
 
 	for (i = 0; i < bp->rx_nr_rings; i++) {
 		struct bnxt_rx_ring_info *rxr = &bp->rx_ring[i];
 		struct bnxt_ring_struct *ring = &rxr->rx_ring_struct;
+		u32 map_idx = rxr->bnapi->index;
 
-		rc = hwrm_ring_alloc_send_msg(bp, ring, HWRM_RING_ALLOC_RX, i,
-					      INVALID_STATS_CTX_ID);
+		rc = hwrm_ring_alloc_send_msg(bp, ring, HWRM_RING_ALLOC_RX,
+					      map_idx, INVALID_STATS_CTX_ID);
 		if (rc)
 			goto err_out;
-		rxr->rx_doorbell = bp->bar1 + i * 0x80;
+		rxr->rx_doorbell = bp->bar1 + map_idx * 0x80;
 		writel(DB_KEY_RX | rxr->rx_prod, rxr->rx_doorbell);
-		bp->grp_info[i].rx_fw_ring_id = ring->fw_ring_id;
+		bp->grp_info[map_idx].rx_fw_ring_id = ring->fw_ring_id;
 	}
 
 	if (bp->flags & BNXT_FLAG_AGG_RINGS) {
@@ -3361,19 +3369,20 @@ static int bnxt_hwrm_ring_alloc(struct bnxt *bp)
 			struct bnxt_rx_ring_info *rxr = &bp->rx_ring[i];
 			struct bnxt_ring_struct *ring =
 						&rxr->rx_agg_ring_struct;
+			u32 grp_idx = rxr->bnapi->index;
+			u32 map_idx = grp_idx + bp->rx_nr_rings;
 
 			rc = hwrm_ring_alloc_send_msg(bp, ring,
 						      HWRM_RING_ALLOC_AGG,
-						      bp->rx_nr_rings + i,
+						      map_idx,
 						      INVALID_STATS_CTX_ID);
 			if (rc)
 				goto err_out;
 
-			rxr->rx_agg_doorbell =
-				bp->bar1 + (bp->rx_nr_rings + i) * 0x80;
+			rxr->rx_agg_doorbell = bp->bar1 + map_idx * 0x80;
 			writel(DB_KEY_RX | rxr->rx_agg_prod,
 			       rxr->rx_agg_doorbell);
-			bp->grp_info[i].agg_fw_ring_id = ring->fw_ring_id;
+			bp->grp_info[grp_idx].agg_fw_ring_id = ring->fw_ring_id;
 		}
 	}
 err_out:
@@ -3430,7 +3439,8 @@ static void bnxt_hwrm_ring_free(struct bnxt *bp, bool close_path)
 	for (i = 0; i < bp->tx_nr_rings; i++) {
 		struct bnxt_tx_ring_info *txr = &bp->tx_ring[i];
 		struct bnxt_ring_struct *ring = &txr->tx_ring_struct;
-		u32 cmpl_ring_id = bp->grp_info[i].cp_fw_ring_id;
+		u32 grp_idx = txr->bnapi->index;
+		u32 cmpl_ring_id = bp->grp_info[grp_idx].cp_fw_ring_id;
 
 		if (ring->fw_ring_id != INVALID_HW_RING_ID) {
 			hwrm_ring_free_send_msg(bp, ring,
@@ -3444,7 +3454,8 @@ static void bnxt_hwrm_ring_free(struct bnxt *bp, bool close_path)
 	for (i = 0; i < bp->rx_nr_rings; i++) {
 		struct bnxt_rx_ring_info *rxr = &bp->rx_ring[i];
 		struct bnxt_ring_struct *ring = &rxr->rx_ring_struct;
-		u32 cmpl_ring_id = bp->grp_info[i].cp_fw_ring_id;
+		u32 grp_idx = rxr->bnapi->index;
+		u32 cmpl_ring_id = bp->grp_info[grp_idx].cp_fw_ring_id;
 
 		if (ring->fw_ring_id != INVALID_HW_RING_ID) {
 			hwrm_ring_free_send_msg(bp, ring,
@@ -3452,14 +3463,16 @@ static void bnxt_hwrm_ring_free(struct bnxt *bp, bool close_path)
 						close_path ? cmpl_ring_id :
 						INVALID_HW_RING_ID);
 			ring->fw_ring_id = INVALID_HW_RING_ID;
-			bp->grp_info[i].rx_fw_ring_id = INVALID_HW_RING_ID;
+			bp->grp_info[grp_idx].rx_fw_ring_id =
+				INVALID_HW_RING_ID;
 		}
 	}
 
 	for (i = 0; i < bp->rx_nr_rings; i++) {
 		struct bnxt_rx_ring_info *rxr = &bp->rx_ring[i];
 		struct bnxt_ring_struct *ring = &rxr->rx_agg_ring_struct;
-		u32 cmpl_ring_id = bp->grp_info[i].cp_fw_ring_id;
+		u32 grp_idx = rxr->bnapi->index;
+		u32 cmpl_ring_id = bp->grp_info[grp_idx].cp_fw_ring_id;
 
 		if (ring->fw_ring_id != INVALID_HW_RING_ID) {
 			hwrm_ring_free_send_msg(bp, ring,
@@ -3467,7 +3480,8 @@ static void bnxt_hwrm_ring_free(struct bnxt *bp, bool close_path)
 						close_path ? cmpl_ring_id :
 						INVALID_HW_RING_ID);
 			ring->fw_ring_id = INVALID_HW_RING_ID;
-			bp->grp_info[i].agg_fw_ring_id = INVALID_HW_RING_ID;
+			bp->grp_info[grp_idx].agg_fw_ring_id =
+				INVALID_HW_RING_ID;
 		}
 	}
 
@@ -3859,7 +3873,7 @@ static int bnxt_alloc_rfs_vnics(struct bnxt *bp)
 			break;
 
 		bp->vnic_info[vnic_id].flags |= BNXT_VNIC_RFS_FLAG;
-		rc = bnxt_hwrm_vnic_alloc(bp, vnic_id, ring_id, ring_id + 1);
+		rc = bnxt_hwrm_vnic_alloc(bp, vnic_id, ring_id, 1);
 		if (rc) {
 			netdev_err(bp->dev, "hwrm vnic %d alloc failure rc: %x\n",
 				   vnic_id, rc);
@@ -4165,7 +4179,7 @@ static void bnxt_free_irq(struct bnxt *bp)
 
 static int bnxt_request_irq(struct bnxt *bp)
 {
-	int i, rc = 0;
+	int i, j, rc = 0;
 	unsigned long flags = 0;
 #ifdef CONFIG_RFS_ACCEL
 	struct cpu_rmap *rmap = bp->dev->rx_cpu_rmap;
@@ -4174,14 +4188,15 @@ static int bnxt_request_irq(struct bnxt *bp)
 	if (!(bp->flags & BNXT_FLAG_USING_MSIX))
 		flags = IRQF_SHARED;
 
-	for (i = 0; i < bp->cp_nr_rings; i++) {
+	for (i = 0, j = 0; i < bp->cp_nr_rings; i++) {
 		struct bnxt_irq *irq = &bp->irq_tbl[i];
 #ifdef CONFIG_RFS_ACCEL
-		if (rmap && (i < bp->rx_nr_rings)) {
+		if (rmap && bp->bnapi[i]->rx_ring) {
 			rc = irq_cpu_rmap_add(rmap, irq->vector);
 			if (rc)
 				netdev_warn(bp->dev, "failed adding irq rmap for ring %d\n",
-					    i);
+					    j);
+			j++;
 		}
 #endif
 		rc = request_irq(irq->vector, irq->handler, flags, irq->name,
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index ea2fd92..ec3edcc 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -918,6 +918,8 @@ struct bnxt {
 	int			cp_nr_rings;
 
 	int			num_stat_ctxs;
+
+	/* grp_info indexed by completion ring index */
 	struct bnxt_ring_grp_info	*grp_info;
 	struct bnxt_vnic_info	*vnic_info;
 	int			nr_vnics;
-- 
1.8.3.1
