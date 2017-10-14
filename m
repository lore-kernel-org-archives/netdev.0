From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 6/6] bnxt_en: Fix possible corruption in DCB parameters from firmware.
Date: Fri, 13 Oct 2017 21:09:34 -0400
Message-ID: <1507943374-13308-7-git-send-email-michael.chan@broadcom.com>
References: <1507943374-13308-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org,
        Sankar Patchineelam <sankar.patchineelam@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f175.google.com ([209.85.220.175]:50155 "EHLO
        mail-qk0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753512AbdJNBJw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Oct 2017 21:09:52 -0400
Received: by mail-qk0-f175.google.com with SMTP id q83so3935492qke.6
        for <netdev@vger.kernel.org>; Fri, 13 Oct 2017 18:09:51 -0700 (PDT)
In-Reply-To: <1507943374-13308-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sankar Patchineelam <sankar.patchineelam@broadcom.com>

hwrm_send_message() is replaced with _hwrm_send_message(), and
hwrm_cmd_lock mutex lock is grabbed for the whole period of
firmware call until the firmware DCB parameters have been copied.
This will prevent possible corruption of the firmware data.

Fixes: 7df4ae9fe855 ("bnxt_en: Implement DCBNL to support host-based DCBX.")
Signed-off-by: Sankar Patchineelam <sankar.patchineelam@broadcom.com>
Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c | 23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
index aa1f3a2..fed37cd 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_dcb.c
@@ -50,7 +50,9 @@ static int bnxt_hwrm_queue_pri2cos_qcfg(struct bnxt *bp, struct ieee_ets *ets)
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_QUEUE_PRI2COS_QCFG, -1, -1);
 	req.flags = cpu_to_le32(QUEUE_PRI2COS_QCFG_REQ_FLAGS_IVLAN);
-	rc = hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+
+	mutex_lock(&bp->hwrm_cmd_lock);
+	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
 	if (!rc) {
 		u8 *pri2cos = &resp->pri0_cos_queue_id;
 		int i, j;
@@ -66,6 +68,7 @@ static int bnxt_hwrm_queue_pri2cos_qcfg(struct bnxt *bp, struct ieee_ets *ets)
 			}
 		}
 	}
+	mutex_unlock(&bp->hwrm_cmd_lock);
 	return rc;
 }
 
@@ -119,9 +122,13 @@ static int bnxt_hwrm_queue_cos2bw_qcfg(struct bnxt *bp, struct ieee_ets *ets)
 	int rc, i;
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_QUEUE_COS2BW_QCFG, -1, -1);
-	rc = hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
-	if (rc)
+
+	mutex_lock(&bp->hwrm_cmd_lock);
+	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	if (rc) {
+		mutex_unlock(&bp->hwrm_cmd_lock);
 		return rc;
+	}
 
 	data = &resp->queue_id0 + offsetof(struct bnxt_cos2bw_cfg, queue_id);
 	for (i = 0; i < bp->max_tc; i++, data += sizeof(cos2bw) - 4) {
@@ -143,6 +150,7 @@ static int bnxt_hwrm_queue_cos2bw_qcfg(struct bnxt *bp, struct ieee_ets *ets)
 			}
 		}
 	}
+	mutex_unlock(&bp->hwrm_cmd_lock);
 	return 0;
 }
 
@@ -240,12 +248,17 @@ static int bnxt_hwrm_queue_pfc_qcfg(struct bnxt *bp, struct ieee_pfc *pfc)
 	int rc;
 
 	bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_QUEUE_PFCENABLE_QCFG, -1, -1);
-	rc = hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
-	if (rc)
+
+	mutex_lock(&bp->hwrm_cmd_lock);
+	rc = _hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	if (rc) {
+		mutex_unlock(&bp->hwrm_cmd_lock);
 		return rc;
+	}
 
 	pri_mask = le32_to_cpu(resp->flags);
 	pfc->pfc_en = pri_mask;
+	mutex_unlock(&bp->hwrm_cmd_lock);
 	return 0;
 }
 
-- 
1.8.3.1
