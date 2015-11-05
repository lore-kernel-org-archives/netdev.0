From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net 5/5] bnxt_en: More robust SRIOV cleanup sequence.
Date: Thu, 5 Nov 2015 16:25:51 -0500
Message-ID: <1446758751-27999-6-git-send-email-mchan@broadcom.com>
References: <1446758751-27999-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jeffrey Huang <huangjw@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:64059 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756839AbbKEVZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2015 16:25:53 -0500
In-Reply-To: <1446758751-27999-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeffrey Huang <huangjw@broadcom.com>

Instead of always calling pci_sriov_disable() in remove_one(),
the driver should detect whether VFs are currently assigned
to the VMs. If the VFs are active in VMs, then it should not
disable SRIOV as it is catastrophic to the VMs. Instead,
it just leaves the VFs alone and continues to unload the PF.
The user can then cleanup the VMs even after the PF driver
has been unloaded.

Signed-off-by: Jeffrey Huang <huangjw@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c | 40 +++++++++++++++++--------
 1 file changed, 27 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index 60989e7..f4cf688 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -258,7 +258,7 @@ static int bnxt_set_vf_attr(struct bnxt *bp, int num_vfs)
 	return 0;
 }
 
-static int bnxt_hwrm_func_vf_resource_free(struct bnxt *bp)
+static int bnxt_hwrm_func_vf_resource_free(struct bnxt *bp, int num_vfs)
 {
 	int i, rc = 0;
 	struct bnxt_pf_info *pf = &bp->pf;
@@ -267,7 +267,7 @@ static int bnxt_hwrm_func_vf_resource_free(struct bnxt *bp)
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_VF_RESC_FREE, -1, -1);
 
 	mutex_lock(&bp->hwrm_cmd_lock);
-	for (i = pf->first_vf_id; i < pf->first_vf_id + pf->active_vfs; i++) {
+	for (i = pf->first_vf_id; i < pf->first_vf_id + num_vfs; i++) {
 		req.vf_id = cpu_to_le16(i);
 		rc = _hwrm_send_message(bp, &req, sizeof(req),
 					HWRM_CMD_TIMEOUT);
@@ -509,7 +509,7 @@ static int bnxt_sriov_enable(struct bnxt *bp, int *num_vfs)
 
 err_out2:
 	/* Free the resources reserved for various VF's */
-	bnxt_hwrm_func_vf_resource_free(bp);
+	bnxt_hwrm_func_vf_resource_free(bp, *num_vfs);
 
 err_out1:
 	bnxt_free_vf_resources(bp);
@@ -519,13 +519,19 @@ err_out1:
 
 void bnxt_sriov_disable(struct bnxt *bp)
 {
-	if (!bp->pf.active_vfs)
-		return;
+	u16 num_vfs = pci_num_vf(bp->pdev);
 
-	pci_disable_sriov(bp->pdev);
+	if (!num_vfs)
+		return;
 
-	/* Free the resources reserved for various VF's */
-	bnxt_hwrm_func_vf_resource_free(bp);
+	if (pci_vfs_assigned(bp->pdev)) {
+		netdev_warn(bp->dev, "Unable to free %d VFs because some are assigned to VMs.\n",
+			    num_vfs);
+	} else {
+		pci_disable_sriov(bp->pdev);
+		/* Free the HW resources reserved for various VF's */
+		bnxt_hwrm_func_vf_resource_free(bp, num_vfs);
+	}
 
 	bnxt_free_vf_resources(bp);
 
@@ -552,17 +558,25 @@ int bnxt_sriov_configure(struct pci_dev *pdev, int num_vfs)
 	}
 	bp->sriov_cfg = true;
 	rtnl_unlock();
-	if (!num_vfs) {
-		bnxt_sriov_disable(bp);
-		return 0;
+
+	if (pci_vfs_assigned(bp->pdev)) {
+		netdev_warn(dev, "Unable to configure SRIOV since some VFs are assigned to VMs.\n");
+		num_vfs = 0;
+		goto sriov_cfg_exit;
 	}
 
 	/* Check if enabled VFs is same as requested */
-	if (num_vfs == bp->pf.active_vfs)
-		return 0;
+	if (num_vfs && num_vfs == bp->pf.active_vfs)
+		goto sriov_cfg_exit;
+
+	/* if there are previous existing VFs, clean them up */
+	bnxt_sriov_disable(bp);
+	if (!num_vfs)
+		goto sriov_cfg_exit;
 
 	bnxt_sriov_enable(bp, &num_vfs);
 
+sriov_cfg_exit:
 	bp->sriov_cfg = false;
 	wake_up(&bp->sriov_cfg_wait);
 
-- 
1.8.3.1
