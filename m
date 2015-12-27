From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 09/12] bnxt_en: Improve VF resource accounting.
Date: Sun, 27 Dec 2015 18:19:26 -0500
Message-ID: <1451258369-21543-10-git-send-email-mchan@broadcom.com>
References: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:32628 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754635AbbL0XTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Dec 2015 18:19:31 -0500
In-Reply-To: <1451258369-21543-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to keep track of all resources, such as rx rings, tx rings,
cmpl rings, rss contexts, stats contexts, vnics, after we have
divided them for the VFs.  Otherwise, subsequent ring changes on
the PF may not work correctly.

We adjust all max resources in struct bnxt_pf_info after they have been
assigned to the VFs.  There is no need to keep the separate
max_pf_tx_rings and max_pf_rx_rings.

When SR-IOV is disabled, we call bnxt_hwrm_func_qcaps() to restore the
max resources for the PF.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c       |  8 +++-----
 drivers/net/ethernet/broadcom/bnxt/bnxt.h       |  3 +--
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c | 15 ++++++++-------
 3 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 8827b7b..22c2644 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3592,7 +3592,7 @@ static int bnxt_hwrm_stat_ctx_alloc(struct bnxt *bp)
 	return 0;
 }
 
-static int bnxt_hwrm_func_qcaps(struct bnxt *bp)
+int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 {
 	int rc = 0;
 	struct hwrm_func_qcaps_input req = {0};
@@ -3616,9 +3616,7 @@ static int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 		pf->max_rsscos_ctxs = le16_to_cpu(resp->max_rsscos_ctx);
 		pf->max_cp_rings = le16_to_cpu(resp->max_cmpl_rings);
 		pf->max_tx_rings = le16_to_cpu(resp->max_tx_rings);
-		pf->max_pf_tx_rings = pf->max_tx_rings;
 		pf->max_rx_rings = le16_to_cpu(resp->max_rx_rings);
-		pf->max_pf_rx_rings = pf->max_rx_rings;
 		pf->max_l2_ctxs = le16_to_cpu(resp->max_l2_ctxs);
 		pf->max_vnics = le16_to_cpu(resp->max_vnics);
 		pf->max_stat_ctxs = le16_to_cpu(resp->max_stat_ctx);
@@ -5623,8 +5621,8 @@ void bnxt_get_max_rings(struct bnxt *bp, int *max_rx, int *max_tx)
 	int max_rings = 0;
 
 	if (BNXT_PF(bp)) {
-		*max_tx = bp->pf.max_pf_tx_rings;
-		*max_rx = bp->pf.max_pf_rx_rings;
+		*max_tx = bp->pf.max_tx_rings;
+		*max_rx = bp->pf.max_rx_rings;
 		max_rings = min_t(int, bp->pf.max_irqs, bp->pf.max_cp_rings);
 		max_rings = min_t(int, max_rings, bp->pf.max_stat_ctxs);
 	} else {
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index f199f4c..8abaece 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -722,9 +722,7 @@ struct bnxt_pf_info {
 	u16	max_rsscos_ctxs;
 	u16	max_cp_rings;
 	u16	max_tx_rings; /* HW assigned max tx rings for this PF */
-	u16	max_pf_tx_rings; /* runtime max tx rings owned by PF */
 	u16	max_rx_rings; /* HW assigned max rx rings for this PF */
-	u16	max_pf_rx_rings; /* runtime max rx rings owned by PF */
 	u16	max_irqs;
 	u16	max_l2_ctxs;
 	u16	max_vnics;
@@ -1084,6 +1082,7 @@ void bnxt_hwrm_cmd_hdr_init(struct bnxt *, void *, u16, u16, u16);
 int _hwrm_send_message(struct bnxt *, void *, u32, int);
 int hwrm_send_message(struct bnxt *, void *, u32, int);
 int bnxt_hwrm_set_coal(struct bnxt *);
+int bnxt_hwrm_func_qcaps(struct bnxt *);
 int bnxt_hwrm_set_pause(struct bnxt *);
 int bnxt_hwrm_set_link_setting(struct bnxt *, bool);
 int bnxt_open_nic(struct bnxt *, bool, bool);
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index 95b9316..44673e6 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -427,11 +427,12 @@ static int bnxt_hwrm_func_cfg(struct bnxt *bp, int num_vfs)
 	}
 	mutex_unlock(&bp->hwrm_cmd_lock);
 	if (!rc) {
-		pf->max_pf_tx_rings = bp->tx_nr_rings;
-		if (bp->flags & BNXT_FLAG_AGG_RINGS)
-			pf->max_pf_rx_rings = bp->rx_nr_rings * 2;
-		else
-			pf->max_pf_rx_rings = bp->rx_nr_rings;
+		pf->max_tx_rings -= vf_tx_rings * num_vfs;
+		pf->max_rx_rings -= vf_rx_rings * num_vfs;
+		pf->max_cp_rings -= vf_cp_rings * num_vfs;
+		pf->max_rsscos_ctxs -= num_vfs;
+		pf->max_stat_ctxs -= vf_stat_ctx * num_vfs;
+		pf->max_vnics -= vf_vnics * num_vfs;
 	}
 	return rc;
 }
@@ -535,8 +536,8 @@ void bnxt_sriov_disable(struct bnxt *bp)
 	bnxt_free_vf_resources(bp);
 
 	bp->pf.active_vfs = 0;
-	bp->pf.max_pf_rx_rings = bp->pf.max_rx_rings;
-	bp->pf.max_pf_tx_rings = bp->pf.max_tx_rings;
+	/* Reclaim all resources for the PF. */
+	bnxt_hwrm_func_qcaps(bp);
 }
 
 int bnxt_sriov_configure(struct pci_dev *pdev, int num_vfs)
-- 
1.8.3.1
