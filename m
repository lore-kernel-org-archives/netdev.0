From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 2/6] bnxt_en: Workaround Nitro A0 hardware RX bug (part 1).
Date: Mon, 18 Jul 2016 07:15:21 -0400
Message-ID: <1468840525-340-3-git-send-email-michael.chan@broadcom.com>
References: <1468840525-340-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f54.google.com ([209.85.218.54]:32821 "EHLO
	mail-oi0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751441AbcGRLPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 07:15:37 -0400
Received: by mail-oi0-f54.google.com with SMTP id j185so240651434oih.0
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 04:15:37 -0700 (PDT)
In-Reply-To: <1468840525-340-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashant Sreedharan <prashant.sreedharan@broadcom.com>

Nitro A0 has a hardware bug in the rx path.  The workaround is to create
a special COS context as a path for non-RSS (non-IP) packets.  Without this
workaround, the chip may stall when receiving RSS and non-RSS packets.

Add infrastructure to allow 2 contexts (RSS and CoS) per VNIC.  Allocate
and configure the CoS context for Nitro A0.

Signed-off-by: Prashant Sreedharan <prashant.sreedharan@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 52 ++++++++++++++++++++++---------
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  3 +-
 2 files changed, 39 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 4970e72..de74012 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2357,7 +2357,8 @@ static void bnxt_init_vnics(struct bnxt *bp)
 		struct bnxt_vnic_info *vnic = &bp->vnic_info[i];
 
 		vnic->fw_vnic_id = INVALID_HW_RING_ID;
-		vnic->fw_rss_cos_lb_ctx = INVALID_HW_RING_ID;
+		vnic->fw_rss_cos_lb_ctx[0] = INVALID_HW_RING_ID;
+		vnic->fw_rss_cos_lb_ctx[1] = INVALID_HW_RING_ID;
 		vnic->fw_l2_ctx_id = INVALID_HW_RING_ID;
 
 		if (bp->vnic_info[i].rss_hash_key) {
@@ -3308,7 +3309,7 @@ static int bnxt_hwrm_vnic_set_rss(struct bnxt *bp, u16 vnic_id, bool set_rss)
 	struct bnxt_vnic_info *vnic = &bp->vnic_info[vnic_id];
 	struct hwrm_vnic_rss_cfg_input req = {0};
 
-	if (vnic->fw_rss_cos_lb_ctx == INVALID_HW_RING_ID)
+	if (vnic->fw_rss_cos_lb_ctx[0] == INVALID_HW_RING_ID)
 		return 0;
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_VNIC_RSS_CFG, -1, -1);
@@ -3336,7 +3337,7 @@ static int bnxt_hwrm_vnic_set_rss(struct bnxt *bp, u16 vnic_id, bool set_rss)
 		req.hash_key_tbl_addr =
 			cpu_to_le64(vnic->rss_hash_key_dma_addr);
 	}
-	req.rss_ctx_idx = cpu_to_le16(vnic->fw_rss_cos_lb_ctx);
+	req.rss_ctx_idx = cpu_to_le16(vnic->fw_rss_cos_lb_ctx[0]);
 	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
 }
 
@@ -3359,32 +3360,35 @@ static int bnxt_hwrm_vnic_set_hds(struct bnxt *bp, u16 vnic_id)
 	return hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
 }
 
-static void bnxt_hwrm_vnic_ctx_free_one(struct bnxt *bp, u16 vnic_id)
+static void bnxt_hwrm_vnic_ctx_free_one(struct bnxt *bp, u16 vnic_id,
+					u16 ctx_idx)
 {
 	struct hwrm_vnic_rss_cos_lb_ctx_free_input req = {0};
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_VNIC_RSS_COS_LB_CTX_FREE, -1, -1);
 	req.rss_cos_lb_ctx_id =
-		cpu_to_le16(bp->vnic_info[vnic_id].fw_rss_cos_lb_ctx);
+		cpu_to_le16(bp->vnic_info[vnic_id].fw_rss_cos_lb_ctx[ctx_idx]);
 
 	hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
-	bp->vnic_info[vnic_id].fw_rss_cos_lb_ctx = INVALID_HW_RING_ID;
+	bp->vnic_info[vnic_id].fw_rss_cos_lb_ctx[ctx_idx] = INVALID_HW_RING_ID;
 }
 
 static void bnxt_hwrm_vnic_ctx_free(struct bnxt *bp)
 {
-	int i;
+	int i, j;
 
 	for (i = 0; i < bp->nr_vnics; i++) {
 		struct bnxt_vnic_info *vnic = &bp->vnic_info[i];
 
-		if (vnic->fw_rss_cos_lb_ctx != INVALID_HW_RING_ID)
-			bnxt_hwrm_vnic_ctx_free_one(bp, i);
+		for (j = 0; j < BNXT_MAX_CTX_PER_VNIC; j++) {
+			if (vnic->fw_rss_cos_lb_ctx[j] != INVALID_HW_RING_ID)
+				bnxt_hwrm_vnic_ctx_free_one(bp, i, j);
+		}
 	}
 	bp->rsscos_nr_ctxs = 0;
 }
 
-static int bnxt_hwrm_vnic_ctx_alloc(struct bnxt *bp, u16 vnic_id)
+static int bnxt_hwrm_vnic_ctx_alloc(struct bnxt *bp, u16 vnic_id, u16 ctx_idx)
 {
 	int rc;
 	struct hwrm_vnic_rss_cos_lb_ctx_alloc_input req = {0};
@@ -3397,7 +3401,7 @@ static int bnxt_hwrm_vnic_ctx_alloc(struct bnxt *bp, u16 vnic_id)
 	mutex_lock(&bp->hwrm_cmd_lock);
 	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
 	if (!rc)
-		bp->vnic_info[vnic_id].fw_rss_cos_lb_ctx =
+		bp->vnic_info[vnic_id].fw_rss_cos_lb_ctx[ctx_idx] =
 			le16_to_cpu(resp->rss_cos_lb_ctx_id);
 	mutex_unlock(&bp->hwrm_cmd_lock);
 
@@ -3416,8 +3420,15 @@ static int bnxt_hwrm_vnic_cfg(struct bnxt *bp, u16 vnic_id)
 	req.enables = cpu_to_le32(VNIC_CFG_REQ_ENABLES_DFLT_RING_GRP |
 				  VNIC_CFG_REQ_ENABLES_RSS_RULE |
 				  VNIC_CFG_REQ_ENABLES_MRU);
-	req.rss_rule = cpu_to_le16(vnic->fw_rss_cos_lb_ctx);
-	req.cos_rule = cpu_to_le16(0xffff);
+	req.rss_rule = cpu_to_le16(vnic->fw_rss_cos_lb_ctx[0]);
+
+	if (BNXT_CHIP_TYPE_NITRO_A0(bp)) {
+		req.cos_rule = cpu_to_le16(vnic->fw_rss_cos_lb_ctx[1]);
+		req.enables |= cpu_to_le32(VNIC_CFG_REQ_ENABLES_COS_RULE);
+	} else {
+		req.cos_rule = cpu_to_le16(0xffff);
+	}
+
 	if (vnic->flags & BNXT_VNIC_RSS_FLAG)
 		ring = 0;
 	else if (vnic->flags & BNXT_VNIC_RFS_FLAG)
@@ -3489,7 +3500,8 @@ static int bnxt_hwrm_vnic_alloc(struct bnxt *bp, u16 vnic_id,
 					bp->grp_info[grp_idx].fw_grp_id;
 	}
 
-	bp->vnic_info[vnic_id].fw_rss_cos_lb_ctx = INVALID_HW_RING_ID;
+	bp->vnic_info[vnic_id].fw_rss_cos_lb_ctx[0] = INVALID_HW_RING_ID;
+	bp->vnic_info[vnic_id].fw_rss_cos_lb_ctx[1] = INVALID_HW_RING_ID;
 	if (vnic_id == 0)
 		req.flags = cpu_to_le32(VNIC_ALLOC_REQ_FLAGS_DEFAULT);
 
@@ -4261,7 +4273,7 @@ static int bnxt_setup_vnic(struct bnxt *bp, u16 vnic_id)
 	int rc;
 
 	/* allocate context for vnic */
-	rc = bnxt_hwrm_vnic_ctx_alloc(bp, vnic_id);
+	rc = bnxt_hwrm_vnic_ctx_alloc(bp, vnic_id, 0);
 	if (rc) {
 		netdev_err(bp->dev, "hwrm vnic %d alloc failure rc: %x\n",
 			   vnic_id, rc);
@@ -4269,6 +4281,16 @@ static int bnxt_setup_vnic(struct bnxt *bp, u16 vnic_id)
 	}
 	bp->rsscos_nr_ctxs++;
 
+	if (BNXT_CHIP_TYPE_NITRO_A0(bp)) {
+		rc = bnxt_hwrm_vnic_ctx_alloc(bp, vnic_id, 1);
+		if (rc) {
+			netdev_err(bp->dev, "hwrm vnic %d cos ctx alloc failure rc: %x\n",
+				   vnic_id, rc);
+			goto vnic_setup_err;
+		}
+		bp->rsscos_nr_ctxs++;
+	}
+
 	/* configure default vnic, ring grp */
 	rc = bnxt_hwrm_vnic_cfg(bp, vnic_id);
 	if (rc) {
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index e667150..5307a2e 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -695,7 +695,8 @@ struct bnxt_ring_grp_info {
 
 struct bnxt_vnic_info {
 	u16		fw_vnic_id; /* returned by Chimp during alloc */
-	u16		fw_rss_cos_lb_ctx;
+#define BNXT_MAX_CTX_PER_VNIC	2
+	u16		fw_rss_cos_lb_ctx[BNXT_MAX_CTX_PER_VNIC];
 	u16		fw_l2_ctx_id;
 #define BNXT_MAX_UC_ADDRS	4
 	__le64		fw_l2_filter_id[BNXT_MAX_UC_ADDRS];
-- 
1.8.3.1
