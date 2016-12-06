From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 4/7] bnxt_en: Improve completion ring allocation for VFs.
Date: Tue,  6 Dec 2016 12:09:35 -0500
Message-ID: <1481044178-25193-5-git-send-email-michael.chan@broadcom.com>
References: <1481044178-25193-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org, selvin.xavier@broadcom.com,
        somnath.kotur@broadcom.com, dledford@redhat.com,
        linux-rdma@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:33906 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753052AbcLFRKJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 12:10:09 -0500
Received: by mail-pg0-f53.google.com with SMTP id x23so151275537pgx.1
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 09:10:08 -0800 (PST)
In-Reply-To: <1481044178-25193-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All available remaining completion rings not used by the PF should be
made available for the VFs so that there are enough rings in the VF to
support RDMA.  The earlier workaround code of capping the rings by the
statistics context is removed.

When SRIOV is disabled, call a new function bnxt_restore_pf_fw_resources()
to restore FW resources.  Later on we need to add some logic to account
for RDMA resources.

Signed-off-by: Somnath Kotur <somnath.kotur@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c       |  8 +++++++-
 drivers/net/ethernet/broadcom/bnxt/bnxt.h       |  2 +-
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c | 14 ++++----------
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 8b00ef4..1f6be83 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4152,7 +4152,7 @@ static int bnxt_hwrm_func_qcfg(struct bnxt *bp)
 	return rc;
 }
 
-int bnxt_hwrm_func_qcaps(struct bnxt *bp)
+static int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 {
 	int rc = 0;
 	struct hwrm_func_qcaps_input req = {0};
@@ -6856,6 +6856,12 @@ static int bnxt_set_dflt_rings(struct bnxt *bp)
 	return rc;
 }
 
+void bnxt_restore_pf_fw_resources(struct bnxt *bp)
+{
+	ASSERT_RTNL();
+	bnxt_hwrm_func_qcaps(bp);
+}
+
 static void bnxt_parse_log_pcie_link(struct bnxt *bp)
 {
 	enum pcie_link_width width = PCIE_LNK_WIDTH_UNKNOWN;
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 0ee2cc4..43a4b17 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -1234,7 +1234,6 @@ static inline void bnxt_disable_poll(struct bnxt_napi *bnapi)
 int hwrm_send_message(struct bnxt *, void *, u32, int);
 int hwrm_send_message_silent(struct bnxt *, void *, u32, int);
 int bnxt_hwrm_set_coal(struct bnxt *);
-int bnxt_hwrm_func_qcaps(struct bnxt *);
 void bnxt_set_max_func_irqs(struct bnxt *bp, unsigned int max);
 void bnxt_tx_disable(struct bnxt *bp);
 void bnxt_tx_enable(struct bnxt *bp);
@@ -1245,4 +1244,5 @@ static inline void bnxt_disable_poll(struct bnxt_napi *bnapi)
 int bnxt_close_nic(struct bnxt *, bool, bool);
 int bnxt_setup_mq_tc(struct net_device *dev, u8 tc);
 int bnxt_get_max_rings(struct bnxt *, int *, int *, bool);
+void bnxt_restore_pf_fw_resources(struct bnxt *bp);
 #endif
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index bff626a..c696025 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -420,15 +420,7 @@ static int bnxt_hwrm_func_cfg(struct bnxt *bp, int num_vfs)
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_CFG, -1, -1);
 
 	/* Remaining rings are distributed equally amongs VF's for now */
-	/* TODO: the following workaroud is needed to restrict total number
-	 * of vf_cp_rings not exceed number of HW ring groups. This WA should
-	 * be removed once new HWRM provides HW ring groups capability in
-	 * hwrm_func_qcap.
-	 */
-	vf_cp_rings = min_t(u16, pf->max_cp_rings, pf->max_stat_ctxs);
-	vf_cp_rings = (vf_cp_rings - bp->cp_nr_rings) / num_vfs;
-	/* TODO: restore this logic below once the WA above is removed */
-	/* vf_cp_rings = (pf->max_cp_rings - bp->cp_nr_rings) / num_vfs; */
+	vf_cp_rings = (pf->max_cp_rings - bp->cp_nr_rings) / num_vfs;
 	vf_stat_ctx = (pf->max_stat_ctxs - bp->num_stat_ctxs) / num_vfs;
 	if (bp->flags & BNXT_FLAG_AGG_RINGS)
 		vf_rx_rings = (pf->max_rx_rings - bp->rx_nr_rings * 2) /
@@ -590,7 +582,9 @@ void bnxt_sriov_disable(struct bnxt *bp)
 
 	bp->pf.active_vfs = 0;
 	/* Reclaim all resources for the PF. */
-	bnxt_hwrm_func_qcaps(bp);
+	rtnl_lock();
+	bnxt_restore_pf_fw_resources(bp);
+	rtnl_unlock();
 }
 
 int bnxt_sriov_configure(struct pci_dev *pdev, int num_vfs)
-- 
1.8.3.1
