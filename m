From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 5/6] bnxt_en: Workaround Nitro A0 RX hardware bug (part 4).
Date: Mon, 18 Jul 2016 07:15:24 -0400
Message-ID: <1468840525-340-6-git-send-email-michael.chan@broadcom.com>
References: <1468840525-340-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:35999 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747AbcGRLPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jul 2016 07:15:39 -0400
Received: by mail-oi0-f46.google.com with SMTP id w18so247276765oiw.3
        for <netdev@vger.kernel.org>; Mon, 18 Jul 2016 04:15:39 -0700 (PDT)
In-Reply-To: <1468840525-340-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prashant Sreedharan <prashant.sreedharan@broadcom.com>

Allocate special vnic for dropping packets not matching the RX filters.
First vnic is for normal RX packets and the driver will drop all
packets on the 2nd vnic.

Signed-off-by: Prashant Sreedharan <prashant.sreedharan@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 64 +++++++++++++++++++++++++------
 1 file changed, 53 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index f0aa582..fd6a174 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2410,6 +2410,9 @@ static int bnxt_alloc_vnics(struct bnxt *bp)
 		num_vnics += bp->rx_nr_rings;
 #endif
 
+	if (BNXT_CHIP_TYPE_NITRO_A0(bp))
+		num_vnics++;
+
 	bp->vnic_info = kcalloc(num_vnics, sizeof(struct bnxt_vnic_info),
 				GFP_KERNEL);
 	if (!bp->vnic_info)
@@ -3271,8 +3274,10 @@ static int bnxt_hwrm_set_vnic_filter(struct bnxt *bp, u16 vnic_id, u16 idx,
 	struct hwrm_cfa_l2_filter_alloc_output *resp = bp->hwrm_cmd_resp_addr;
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_CFA_L2_FILTER_ALLOC, -1, -1);
-	req.flags = cpu_to_le32(CFA_L2_FILTER_ALLOC_REQ_FLAGS_PATH_RX |
-				CFA_L2_FILTER_ALLOC_REQ_FLAGS_OUTERMOST);
+	req.flags = cpu_to_le32(CFA_L2_FILTER_ALLOC_REQ_FLAGS_PATH_RX);
+	if (!BNXT_CHIP_TYPE_NITRO_A0(bp))
+		req.flags |=
+			cpu_to_le32(CFA_L2_FILTER_ALLOC_REQ_FLAGS_OUTERMOST);
 	req.dst_id = cpu_to_le16(bp->vnic_info[vnic_id].fw_vnic_id);
 	req.enables =
 		cpu_to_le32(CFA_L2_FILTER_ALLOC_REQ_ENABLES_L2_ADDR |
@@ -3391,10 +3396,14 @@ static int bnxt_hwrm_vnic_set_rss(struct bnxt *bp, u16 vnic_id, bool set_rss)
 
 		req.hash_type = cpu_to_le32(vnic->hash_type);
 
-		if (vnic->flags & BNXT_VNIC_RSS_FLAG)
-			max_rings = bp->rx_nr_rings;
-		else
+		if (vnic->flags & BNXT_VNIC_RSS_FLAG) {
+			if (BNXT_CHIP_TYPE_NITRO_A0(bp))
+				max_rings = bp->rx_nr_rings - 1;
+			else
+				max_rings = bp->rx_nr_rings;
+		} else {
 			max_rings = 1;
+		}
 
 		/* Fill the RSS indirection table with ring group ids */
 		for (i = 0, j = 0; i < HW_HASH_INDEX_SIZE; i++, j++) {
@@ -3486,13 +3495,19 @@ static int bnxt_hwrm_vnic_cfg(struct bnxt *bp, u16 vnic_id)
 	u16 def_vlan = 0;
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_VNIC_CFG, -1, -1);
+
+	req.enables = cpu_to_le32(VNIC_CFG_REQ_ENABLES_DFLT_RING_GRP);
 	/* Only RSS support for now TBD: COS & LB */
-	req.enables = cpu_to_le32(VNIC_CFG_REQ_ENABLES_DFLT_RING_GRP |
-				  VNIC_CFG_REQ_ENABLES_RSS_RULE |
-				  VNIC_CFG_REQ_ENABLES_MRU);
-	req.rss_rule = cpu_to_le16(vnic->fw_rss_cos_lb_ctx[0]);
+	if (vnic->fw_rss_cos_lb_ctx[0] != INVALID_HW_RING_ID) {
+		req.rss_rule = cpu_to_le16(vnic->fw_rss_cos_lb_ctx[0]);
+		req.enables |= cpu_to_le32(VNIC_CFG_REQ_ENABLES_RSS_RULE |
+					   VNIC_CFG_REQ_ENABLES_MRU);
+	} else {
+		req.rss_rule = cpu_to_le16(0xffff);
+	}
 
-	if (BNXT_CHIP_TYPE_NITRO_A0(bp)) {
+	if (BNXT_CHIP_TYPE_NITRO_A0(bp) &&
+	    (vnic->fw_rss_cos_lb_ctx[0] != INVALID_HW_RING_ID)) {
 		req.cos_rule = cpu_to_le16(vnic->fw_rss_cos_lb_ctx[1]);
 		req.enables |= cpu_to_le32(VNIC_CFG_REQ_ENABLES_COS_RULE);
 	} else {
@@ -4430,6 +4445,26 @@ static bool bnxt_promisc_ok(struct bnxt *bp)
 	return true;
 }
 
+static int bnxt_setup_nitroa0_vnic(struct bnxt *bp)
+{
+	unsigned int rc = 0;
+
+	rc = bnxt_hwrm_vnic_alloc(bp, 1, bp->rx_nr_rings - 1, 1);
+	if (rc) {
+		netdev_err(bp->dev, "Cannot allocate special vnic for NS2 A0: %x\n",
+			   rc);
+		return rc;
+	}
+
+	rc = bnxt_hwrm_vnic_cfg(bp, 1);
+	if (rc) {
+		netdev_err(bp->dev, "Cannot allocate special vnic for NS2 A0: %x\n",
+			   rc);
+		return rc;
+	}
+	return rc;
+}
+
 static int bnxt_cfg_rx_mode(struct bnxt *);
 static bool bnxt_mc_list_updated(struct bnxt *, u32 *);
 
@@ -4519,7 +4554,14 @@ static int bnxt_init_chip(struct bnxt *bp, bool irq_re_init)
 	rc = bnxt_hwrm_set_coal(bp);
 	if (rc)
 		netdev_warn(bp->dev, "HWRM set coalescing failure rc: %x\n",
-			    rc);
+				rc);
+
+	if (BNXT_CHIP_TYPE_NITRO_A0(bp)) {
+		rc = bnxt_setup_nitroa0_vnic(bp);
+		if (rc)
+			netdev_err(bp->dev, "Special vnic setup failure for NS2 A0 rc: %x\n",
+				   rc);
+	}
 
 	if (BNXT_VF(bp)) {
 		bnxt_hwrm_func_qcfg(bp);
-- 
1.8.3.1
