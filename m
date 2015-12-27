From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 08/12] bnxt_en: Cleanup bnxt_hwrm_func_cfg().
Date: Sun, 27 Dec 2015 18:19:25 -0500
Message-ID: <1451258369-21543-9-git-send-email-mchan@broadcom.com>
References: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:4052 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754143AbbL0XTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 18:19:31 -0500
In-Reply-To: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1. Use local variable pf for repeated access to this pointer.

2.  The 2nd argument num_vfs was unnecessarily declared as pointer to int.
This function doesn't change num_vfs so change the argument to int.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c | 33 ++++++++++++-------------
 1 file changed, 16 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index ea044bb..95b9316 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -363,7 +363,7 @@ static int bnxt_hwrm_func_buf_rgtr(struct bnxt *bp)
 }
 
 /* only call by PF to reserve resources for VF */
-static int bnxt_hwrm_func_cfg(struct bnxt *bp, int *num_vfs)
+static int bnxt_hwrm_func_cfg(struct bnxt *bp, int num_vfs)
 {
 	u32 rc = 0, mtu, i;
 	u16 vf_tx_rings, vf_rx_rings, vf_cp_rings, vf_stat_ctx, vf_vnics;
@@ -378,18 +378,17 @@ static int bnxt_hwrm_func_cfg(struct bnxt *bp, int *num_vfs)
 	 * be removed once new HWRM provides HW ring groups capability in
 	 * hwrm_func_qcap.
 	 */
-	vf_cp_rings = min_t(u16, bp->pf.max_cp_rings, bp->pf.max_stat_ctxs);
-	vf_cp_rings = (vf_cp_rings - bp->cp_nr_rings) / *num_vfs;
+	vf_cp_rings = min_t(u16, pf->max_cp_rings, pf->max_stat_ctxs);
+	vf_cp_rings = (vf_cp_rings - bp->cp_nr_rings) / num_vfs;
 	/* TODO: restore this logic below once the WA above is removed */
-	/* vf_cp_rings = (bp->pf.max_cp_rings - bp->cp_nr_rings) / *num_vfs; */
-	vf_stat_ctx = (bp->pf.max_stat_ctxs - bp->num_stat_ctxs) / *num_vfs;
+	/* vf_cp_rings = (pf->max_cp_rings - bp->cp_nr_rings) / num_vfs; */
+	vf_stat_ctx = (pf->max_stat_ctxs - bp->num_stat_ctxs) / num_vfs;
 	if (bp->flags & BNXT_FLAG_AGG_RINGS)
-		vf_rx_rings = (bp->pf.max_rx_rings - bp->rx_nr_rings * 2) /
-			      *num_vfs;
+		vf_rx_rings = (pf->max_rx_rings - bp->rx_nr_rings * 2) /
+			      num_vfs;
 	else
-		vf_rx_rings = (bp->pf.max_rx_rings - bp->rx_nr_rings) /
-			      *num_vfs;
-	vf_tx_rings = (bp->pf.max_tx_rings - bp->tx_nr_rings) / *num_vfs;
+		vf_rx_rings = (pf->max_rx_rings - bp->rx_nr_rings) / num_vfs;
+	vf_tx_rings = (pf->max_tx_rings - bp->tx_nr_rings) / num_vfs;
 
 	req.enables = cpu_to_le32(FUNC_CFG_REQ_ENABLES_MTU |
 				  FUNC_CFG_REQ_ENABLES_MRU |
@@ -417,22 +416,22 @@ static int bnxt_hwrm_func_cfg(struct bnxt *bp, int *num_vfs)
 	req.num_stat_ctxs = cpu_to_le16(vf_stat_ctx);
 
 	mutex_lock(&bp->hwrm_cmd_lock);
-	for (i = 0; i < *num_vfs; i++) {
+	for (i = 0; i < num_vfs; i++) {
 		req.vf_id = cpu_to_le16(pf->first_vf_id + i);
 		rc = _hwrm_send_message(bp, &req, sizeof(req),
 					HWRM_CMD_TIMEOUT);
 		if (rc)
 			break;
-		bp->pf.active_vfs = i + 1;
-		bp->pf.vf[i].fw_fid = le16_to_cpu(req.vf_id);
+		pf->active_vfs = i + 1;
+		pf->vf[i].fw_fid = le16_to_cpu(req.vf_id);
 	}
 	mutex_unlock(&bp->hwrm_cmd_lock);
 	if (!rc) {
-		bp->pf.max_pf_tx_rings = bp->tx_nr_rings;
+		pf->max_pf_tx_rings = bp->tx_nr_rings;
 		if (bp->flags & BNXT_FLAG_AGG_RINGS)
-			bp->pf.max_pf_rx_rings = bp->rx_nr_rings * 2;
+			pf->max_pf_rx_rings = bp->rx_nr_rings * 2;
 		else
-			bp->pf.max_pf_rx_rings = bp->rx_nr_rings;
+			pf->max_pf_rx_rings = bp->rx_nr_rings;
 	}
 	return rc;
 }
@@ -492,7 +491,7 @@ static int bnxt_sriov_enable(struct bnxt *bp, int *num_vfs)
 		goto err_out1;
 
 	/* Reserve resources for VFs */
-	rc = bnxt_hwrm_func_cfg(bp, num_vfs);
+	rc = bnxt_hwrm_func_cfg(bp, *num_vfs);
 	if (rc)
 		goto err_out2;
 
-- 
1.8.3.1
