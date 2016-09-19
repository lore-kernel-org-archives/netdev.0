From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 10/10] bnxt_en: Fixed the VF link status after a link state change
Date: Mon, 19 Sep 2016 03:58:09 -0400
Message-ID: <1474271889-8229-11-git-send-email-michael.chan@broadcom.com>
References: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f182.google.com ([209.85.192.182]:33809 "EHLO
        mail-pf0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932580AbcISH6e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 03:58:34 -0400
Received: by mail-pf0-f182.google.com with SMTP id p64so48353395pfb.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 00:58:33 -0700 (PDT)
In-Reply-To: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eddie Wai <eddie.wai@broadcom.com>

The VF link state can be changed via the 'ip link set' cmd.
Currently, the new link state does not take effect immediately.

The fix is for the PF to send a link change async event to the
designated VF after a VF link state change.  This async event will
trigger the VF to update the link status.

Signed-off-by: Eddie Wai <eddie.wai@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c | 84 ++++++++++++-------------
 1 file changed, 42 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index 50d2007..8be7185 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -19,6 +19,45 @@
 #include "bnxt_ethtool.h"
 
 #ifdef CONFIG_BNXT_SRIOV
+static int bnxt_hwrm_fwd_async_event_cmpl(struct bnxt *bp,
+					  struct bnxt_vf_info *vf, u16 event_id)
+{
+	struct hwrm_fwd_async_event_cmpl_output *resp = bp->hwrm_cmd_resp_addr;
+	struct hwrm_fwd_async_event_cmpl_input req = {0};
+	struct hwrm_async_event_cmpl *async_cmpl;
+	int rc = 0;
+
+	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FWD_ASYNC_EVENT_CMPL, -1, -1);
+	if (vf)
+		req.encap_async_event_target_id = cpu_to_le16(vf->fw_fid);
+	else
+		/* broadcast this async event to all VFs */
+		req.encap_async_event_target_id = cpu_to_le16(0xffff);
+	async_cmpl = (struct hwrm_async_event_cmpl *)req.encap_async_event_cmpl;
+	async_cmpl->type =
+		cpu_to_le16(HWRM_ASYNC_EVENT_CMPL_TYPE_HWRM_ASYNC_EVENT);
+	async_cmpl->event_id = cpu_to_le16(event_id);
+
+	mutex_lock(&bp->hwrm_cmd_lock);
+	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+
+	if (rc) {
+		netdev_err(bp->dev, "hwrm_fwd_async_event_cmpl failed. rc:%d\n",
+			   rc);
+		goto fwd_async_event_cmpl_exit;
+	}
+
+	if (resp->error_code) {
+		netdev_err(bp->dev, "hwrm_fwd_async_event_cmpl error %d\n",
+			   resp->error_code);
+		rc = -1;
+	}
+
+fwd_async_event_cmpl_exit:
+	mutex_unlock(&bp->hwrm_cmd_lock);
+	return rc;
+}
+
 static int bnxt_vf_ndo_prep(struct bnxt *bp, int vf_id)
 {
 	if (!test_bit(BNXT_STATE_OPEN, &bp->state)) {
@@ -243,8 +282,9 @@ int bnxt_set_vf_link_state(struct net_device *dev, int vf_id, int link)
 		rc = -EINVAL;
 		break;
 	}
-	/* CHIMP TODO: send msg to VF to update new link state */
-
+	if (vf->flags & (BNXT_VF_LINK_UP | BNXT_VF_LINK_FORCED))
+		rc = bnxt_hwrm_fwd_async_event_cmpl(bp, vf,
+			HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_STATUS_CHANGE);
 	return rc;
 }
 
@@ -525,46 +565,6 @@ err_out1:
 	return rc;
 }
 
-static int bnxt_hwrm_fwd_async_event_cmpl(struct bnxt *bp,
-					  struct bnxt_vf_info *vf,
-					  u16 event_id)
-{
-	int rc = 0;
-	struct hwrm_fwd_async_event_cmpl_input req = {0};
-	struct hwrm_fwd_async_event_cmpl_output *resp = bp->hwrm_cmd_resp_addr;
-	struct hwrm_async_event_cmpl *async_cmpl;
-
-	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FWD_ASYNC_EVENT_CMPL, -1, -1);
-	if (vf)
-		req.encap_async_event_target_id = cpu_to_le16(vf->fw_fid);
-	else
-		/* broadcast this async event to all VFs */
-		req.encap_async_event_target_id = cpu_to_le16(0xffff);
-	async_cmpl = (struct hwrm_async_event_cmpl *)req.encap_async_event_cmpl;
-	async_cmpl->type =
-		cpu_to_le16(HWRM_ASYNC_EVENT_CMPL_TYPE_HWRM_ASYNC_EVENT);
-	async_cmpl->event_id = cpu_to_le16(event_id);
-
-	mutex_lock(&bp->hwrm_cmd_lock);
-	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
-
-	if (rc) {
-		netdev_err(bp->dev, "hwrm_fwd_async_event_cmpl failed. rc:%d\n",
-			   rc);
-		goto fwd_async_event_cmpl_exit;
-	}
-
-	if (resp->error_code) {
-		netdev_err(bp->dev, "hwrm_fwd_async_event_cmpl error %d\n",
-			   resp->error_code);
-		rc = -1;
-	}
-
-fwd_async_event_cmpl_exit:
-	mutex_unlock(&bp->hwrm_cmd_lock);
-	return rc;
-}
-
 void bnxt_sriov_disable(struct bnxt *bp)
 {
 	u16 num_vfs = pci_num_vf(bp->pdev);
-- 
1.8.3.1
