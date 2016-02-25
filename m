From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 02/10] bnxt_en: Send PF driver unload notification to all VFs.
Date: Thu, 25 Feb 2016 03:19:26 -0500
Message-ID: <1456388374-1440-3-git-send-email-michael.chan@broadcom.com>
References: <1456388374-1440-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:60498
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759238AbcBYITf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 03:19:35 -0500
In-Reply-To: <1456388374-1440-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeffrey Huang <huangjw@broadcom.com>

During remove_one() when SRIOV is enabled, the PF driver
should broadcast PF driver unload notification to all
VFs that are attached to VMs. Upon receiving the PF
driver unload notification, the VF driver should print
a warning message to message log.  Certain operations on the
VF may not succeed after the PF has unloaded.

Signed-off-by: Jeffrey Huang <huangjw@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c       | 10 ++++--
 drivers/net/ethernet/broadcom/bnxt/bnxt.h       |  1 +
 drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c | 43 +++++++++++++++++++++++++
 3 files changed, 52 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index ff1507f..80c4412 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -1239,13 +1239,17 @@ static int bnxt_async_event_process(struct bnxt *bp,
 	switch (event_id) {
 	case HWRM_ASYNC_EVENT_CMPL_EVENT_ID_LINK_STATUS_CHANGE:
 		set_bit(BNXT_LINK_CHNG_SP_EVENT, &bp->sp_event);
-		schedule_work(&bp->sp_task);
+		break;
+	case HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_DRVR_UNLOAD:
+		set_bit(BNXT_HWRM_PF_UNLOAD_SP_EVENT, &bp->sp_event);
 		break;
 	default:
 		netdev_err(bp->dev, "unhandled ASYNC event (id 0x%x)\n",
 			   event_id);
-		break;
+		goto async_event_process_exit;
 	}
+	schedule_work(&bp->sp_task);
+async_event_process_exit:
 	return 0;
 }
 
@@ -5559,6 +5563,8 @@ static void bnxt_cfg_ntp_filters(struct bnxt *bp)
 			}
 		}
 	}
+	if (test_and_clear_bit(BNXT_HWRM_PF_UNLOAD_SP_EVENT, &bp->sp_event))
+		netdev_info(bp->dev, "Receive PF driver unload event!");
 }
 
 #else
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.h b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
index 2be51b3..cc798d5 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.h
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.h
@@ -986,6 +986,7 @@ struct bnxt {
 #define BNXT_VXLAN_DEL_PORT_SP_EVENT	5
 #define BNXT_RESET_TASK_SP_EVENT	6
 #define BNXT_RST_RING_SP_EVENT		7
+#define BNXT_HWRM_PF_UNLOAD_SP_EVENT	8
 
 	struct bnxt_pf_info	pf;
 #ifdef CONFIG_BNXT_SRIOV
diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
index bb2b376..a6af5e9 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_sriov.c
@@ -522,6 +522,46 @@ err_out1:
 	return rc;
 }
 
+static int bnxt_hwrm_fwd_async_event_cmpl(struct bnxt *bp,
+					  struct bnxt_vf_info *vf,
+					  u16 event_id)
+{
+	int rc = 0;
+	struct hwrm_fwd_async_event_cmpl_input req = {0};
+	struct hwrm_fwd_async_event_cmpl_output *resp = bp->hwrm_cmd_resp_addr;
+	struct hwrm_async_event_cmpl *async_cmpl;
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
 void bnxt_sriov_disable(struct bnxt *bp)
 {
 	u16 num_vfs = pci_num_vf(bp->pdev);
@@ -530,6 +570,9 @@ void bnxt_sriov_disable(struct bnxt *bp)
 		return;
 
 	if (pci_vfs_assigned(bp->pdev)) {
+		bnxt_hwrm_fwd_async_event_cmpl(
+			bp, NULL,
+			HWRM_ASYNC_EVENT_CMPL_EVENT_ID_PF_DRVR_UNLOAD);
 		netdev_warn(bp->dev, "Unable to free %d VFs because some are assigned to VMs.\n",
 			    num_vfs);
 	} else {
-- 
1.8.3.1
