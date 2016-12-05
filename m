From: Selvin Xavier <selvin.xavier@broadcom.com>
Subject: [PATCH 04/28] bnxt_en: Improve completion ring allocation for VFs.
Date: Sun,  4 Dec 2016 22:38:08 -0800
Message-ID: <1480919912-1079-5-git-send-email-selvin.xavier@broadcom.com>
References: <1480919912-1079-1-git-send-email-selvin.xavier@broadcom.com>
Cc: linux-rdma@vger.kernel.org,
        Michael Chan <michael.chan@broadcom.com>,
        David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Selvin Xavier <selvin.xavier@broadcom.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from lpdvsmtp01.broadcom.com ([192.19.211.62]:33831 "EHLO
        relay.smtp.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751340AbcLEGpq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2016 01:45:46 -0500
In-Reply-To: <1480919912-1079-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Chan <michael.chan@broadcom.com>

All available remaining completion rings not used by the PF should be
made available for the VFs so that there are enough rings in the VF to
support RDMA.  The earlier workaround code of capping the rings by the
statistics context is removed.

When SRIOV is disabled, call a new function bnxt_restore_pf_fw_resources()
to restore FW resources.  Later on we need to add some logic to account
for RDMA resources.

Cc: David Miller <davem@davemloft.net>
Cc: <netdev@vger.kernel.org>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
Signed-off-by: Selvin Xavier <selvin.xavier@broadcom.com>
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
@@ -1234,7 +1234,6 @@ int _hwrm_send_message(struct bnxt *, void *, u32, int);
 int hwrm_send_message(struct bnxt *, void *, u32, int);
 int hwrm_send_message_silent(struct bnxt *, void *, u32, int);
 int bnxt_hwrm_set_coal(struct bnxt *);
-int bnxt_hwrm_func_qcaps(struct bnxt *);
 void bnxt_set_max_func_irqs(struct bnxt *bp, unsigned int max);
 void bnxt_tx_disable(struct bnxt *bp);
 void bnxt_tx_enable(struct bnxt *bp);
@@ -1245,4 +1244,5 @@ int bnxt_open_nic(struct bnxt *, bool, bool);
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
2.5.5
