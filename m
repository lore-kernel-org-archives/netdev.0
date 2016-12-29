From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 08/14] bnxt_en: Add new hardware RFS mode.
Date: Thu, 29 Dec 2016 12:13:38 -0500
Message-ID: <1483031624-20076-9-git-send-email-michael.chan@broadcom.com>
References: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:36562 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752839AbcL2ROH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 12:14:07 -0500
Received: by mail-pg0-f52.google.com with SMTP id f188so168383610pgc.3
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 09:14:07 -0800 (PST)
In-Reply-To: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The existing hardware RFS mode uses one hardware RSS context block
per ring just to calculate the RSS hash.  This is very wasteful and
prevents VF functions from using it.  The new hardware mode shares
the same hardware RSS context for RSS placement and RFS steering.
This allows VFs to enable RFS.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 27 ++++++++++++++++++++++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h |  1 +
 2 files changed, 27 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index f7ea99f..0ca530e 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -2630,6 +2630,10 @@ static int bnxt_alloc_vnic_attributes(struct bnxt *bp)
 			goto out;
 		}
 
+		if ((bp->flags & BNXT_FLAG_NEW_RSS_CAP) &&
+		    !(vnic->flags & BNXT_VNIC_RSS_FLAG))
+			continue;
+
 		/* Allocate rss table and hash key */
 		vnic->rss_table = dma_alloc_coherent(&pdev->dev, PAGE_SIZE,
 						     &vnic->rss_table_dma_addr,
@@ -3562,6 +3566,12 @@ int bnxt_hwrm_vnic_cfg(struct bnxt *bp, u16 vnic_id)
 		req.rss_rule = cpu_to_le16(vnic->fw_rss_cos_lb_ctx[0]);
 		req.enables |= cpu_to_le32(VNIC_CFG_REQ_ENABLES_RSS_RULE |
 					   VNIC_CFG_REQ_ENABLES_MRU);
+	} else if (vnic->flags & BNXT_VNIC_RFS_NEW_RSS_FLAG) {
+		req.rss_rule =
+			cpu_to_le16(bp->vnic_info[0].fw_rss_cos_lb_ctx[0]);
+		req.enables |= cpu_to_le32(VNIC_CFG_REQ_ENABLES_RSS_RULE |
+					   VNIC_CFG_REQ_ENABLES_MRU);
+		req.flags |= cpu_to_le32(VNIC_CFG_REQ_FLAGS_RSS_DFLT_CR_MODE);
 	} else {
 		req.rss_rule = cpu_to_le16(0xffff);
 	}
@@ -4490,8 +4500,12 @@ static void bnxt_hwrm_resource_free(struct bnxt *bp, bool close_path,
 
 static int bnxt_setup_vnic(struct bnxt *bp, u16 vnic_id)
 {
+	struct bnxt_vnic_info *vnic = &bp->vnic_info[vnic_id];
 	int rc;
 
+	if (vnic->flags & BNXT_VNIC_RFS_NEW_RSS_FLAG)
+		goto skip_rss_ctx;
+
 	/* allocate context for vnic */
 	rc = bnxt_hwrm_vnic_ctx_alloc(bp, vnic_id, 0);
 	if (rc) {
@@ -4511,6 +4525,7 @@ static int bnxt_setup_vnic(struct bnxt *bp, u16 vnic_id)
 		bp->rsscos_nr_ctxs++;
 	}
 
+skip_rss_ctx:
 	/* configure default vnic, ring grp */
 	rc = bnxt_hwrm_vnic_cfg(bp, vnic_id);
 	if (rc) {
@@ -4545,13 +4560,17 @@ static int bnxt_alloc_rfs_vnics(struct bnxt *bp)
 	int i, rc = 0;
 
 	for (i = 0; i < bp->rx_nr_rings; i++) {
+		struct bnxt_vnic_info *vnic;
 		u16 vnic_id = i + 1;
 		u16 ring_id = i;
 
 		if (vnic_id >= bp->nr_vnics)
 			break;
 
-		bp->vnic_info[vnic_id].flags |= BNXT_VNIC_RFS_FLAG;
+		vnic = &bp->vnic_info[vnic_id];
+		vnic->flags |= BNXT_VNIC_RFS_FLAG;
+		if (bp->flags & BNXT_FLAG_NEW_RSS_CAP)
+			vnic->flags |= BNXT_VNIC_RFS_NEW_RSS_FLAG;
 		rc = bnxt_hwrm_vnic_alloc(bp, vnic_id, ring_id, 1);
 		if (rc) {
 			netdev_err(bp->dev, "hwrm vnic %d alloc failure rc: %x\n",
@@ -5985,6 +6004,8 @@ static bool bnxt_rfs_supported(struct bnxt *bp)
 {
 	if (BNXT_PF(bp) && !BNXT_CHIP_TYPE_NITRO_A0(bp))
 		return true;
+	if (bp->flags & BNXT_FLAG_NEW_RSS_CAP)
+		return true;
 	return false;
 }
 
@@ -6000,6 +6021,10 @@ static bool bnxt_rfs_capable(struct bnxt *bp)
 	vnics = 1 + bp->rx_nr_rings;
 	max_vnics = bnxt_get_max_func_vnics(bp);
 	max_rss_ctxs = bnxt_get_max_func_rss_ctxs(bp);
+
+	/* RSS contexts not a limiting factor */
+	if (bp->flags & BNXT_FLAG_NEW_RSS_CAP)
+		max_rss_ctxs = max_vnics;
 	if (vnics > max_vnics || vnics > max_rss_ctxs) {
 		netdev_warn(bp->dev,
 			    "Not enough resources to support NTUPLE filters, enough resources for up to %d rx rings\n",
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 80bf1ab..75803e5 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -708,6 +708,7 @@ struct bnxt_vnic_info {
 #define BNXT_VNIC_RFS_FLAG	2
 #define BNXT_VNIC_MCAST_FLAG	4
 #define BNXT_VNIC_UCAST_FLAG	8
+#define BNXT_VNIC_RFS_NEW_RSS_FLAG	0x10
 };
 
 #if defined(CONFIG_BNXT_SRIOV)
-- 
1.8.3.1
