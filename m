From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 07/14] bnxt_en: Refactor code that determines RFS capability.
Date: Thu, 29 Dec 2016 12:13:37 -0500
Message-ID: <1483031624-20076-8-git-send-email-michael.chan@broadcom.com>
References: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:36560 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753327AbcL2ROG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 12:14:06 -0500
Received: by mail-pg0-f45.google.com with SMTP id f188so168383488pgc.3
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 09:14:06 -0800 (PST)
In-Reply-To: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add function bnxt_rfs_supported() that determines if the chip supports
RFS.  Refactor the existing function bnxt_rfs_capable() that determines
if run-time conditions support RFS.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 38 +++++++++++++++++++++++++++----
 1 file changed, 33 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 9168326..f7ea99f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4835,6 +4835,24 @@ static int bnxt_setup_int_mode(struct bnxt *bp)
 	return rc;
 }
 
+static unsigned int bnxt_get_max_func_rss_ctxs(struct bnxt *bp)
+{
+#if defined(CONFIG_BNXT_SRIOV)
+	if (BNXT_VF(bp))
+		return bp->vf.max_rsscos_ctxs;
+#endif
+	return bp->pf.max_rsscos_ctxs;
+}
+
+static unsigned int bnxt_get_max_func_vnics(struct bnxt *bp)
+{
+#if defined(CONFIG_BNXT_SRIOV)
+	if (BNXT_VF(bp))
+		return bp->vf.max_vnics;
+#endif
+	return bp->pf.max_vnics;
+}
+
 unsigned int bnxt_get_max_func_stat_ctxs(struct bnxt *bp)
 {
 #if defined(CONFIG_BNXT_SRIOV)
@@ -5962,20 +5980,30 @@ static int bnxt_cfg_rx_mode(struct bnxt *bp)
 	return rc;
 }
 
+/* If the chip and firmware supports RFS */
+static bool bnxt_rfs_supported(struct bnxt *bp)
+{
+	if (BNXT_PF(bp) && !BNXT_CHIP_TYPE_NITRO_A0(bp))
+		return true;
+	return false;
+}
+
+/* If runtime conditions support RFS */
 static bool bnxt_rfs_capable(struct bnxt *bp)
 {
 #ifdef CONFIG_RFS_ACCEL
-	struct bnxt_pf_info *pf = &bp->pf;
-	int vnics;
+	int vnics, max_vnics, max_rss_ctxs;
 
 	if (BNXT_VF(bp) || !(bp->flags & BNXT_FLAG_MSIX_CAP))
 		return false;
 
 	vnics = 1 + bp->rx_nr_rings;
-	if (vnics > pf->max_rsscos_ctxs || vnics > pf->max_vnics) {
+	max_vnics = bnxt_get_max_func_vnics(bp);
+	max_rss_ctxs = bnxt_get_max_func_rss_ctxs(bp);
+	if (vnics > max_vnics || vnics > max_rss_ctxs) {
 		netdev_warn(bp->dev,
 			    "Not enough resources to support NTUPLE filters, enough resources for up to %d rx rings\n",
-			    min(pf->max_rsscos_ctxs - 1, pf->max_vnics - 1));
+			    min(max_rss_ctxs - 1, max_vnics - 1));
 		return false;
 	}
 
@@ -7092,7 +7120,7 @@ static int bnxt_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	}
 
 	bnxt_hwrm_vnic_qcaps(bp);
-	if (BNXT_PF(bp) && !BNXT_CHIP_TYPE_NITRO_A0(bp)) {
+	if (bnxt_rfs_supported(bp)) {
 		dev->hw_features |= NETIF_F_NTUPLE;
 		if (bnxt_rfs_capable(bp)) {
 			bp->flags |= BNXT_FLAG_RFS;
-- 
1.8.3.1
