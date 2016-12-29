From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 12/14] bnxt_en: Set default completion ring for async events.
Date: Thu, 29 Dec 2016 12:13:42 -0500
Message-ID: <1483031624-20076-13-git-send-email-michael.chan@broadcom.com>
References: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f53.google.com ([74.125.83.53]:32795 "EHLO
        mail-pg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753343AbcL2ROL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Dec 2016 12:14:11 -0500
Received: by mail-pg0-f53.google.com with SMTP id g1so129328975pgn.0
        for <netdev@vger.kernel.org>; Thu, 29 Dec 2016 09:14:11 -0800 (PST)
In-Reply-To: <1483031624-20076-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the added support for the bnxt_re RDMA driver, both drivers can be
allocating completion rings in any order.  The firmware does not know
which completion ring should be receiving async events.  Add an
extra step to tell firmware the completion ring number for receiving
async events after bnxt_en allocates the completion rings.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 30 ++++++++++++++++++++++++++++++
 1 file changed, 30 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 338dbd0..1f54a7a 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3858,6 +3858,30 @@ static int hwrm_ring_alloc_send_msg(struct bnxt *bp,
 	return rc;
 }
 
+static int bnxt_hwrm_set_async_event_cr(struct bnxt *bp, int idx)
+{
+	int rc;
+
+	if (BNXT_PF(bp)) {
+		struct hwrm_func_cfg_input req = {0};
+
+		bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_CFG, -1, -1);
+		req.fid = cpu_to_le16(0xffff);
+		req.enables = cpu_to_le32(FUNC_CFG_REQ_ENABLES_ASYNC_EVENT_CR);
+		req.async_event_cr = cpu_to_le16(idx);
+		rc = hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	} else {
+		struct hwrm_func_vf_cfg_input req = {0};
+
+		bnxt_hwrm_cmd_hdr_init(bp, &req, HWRM_FUNC_VF_CFG, -1, -1);
+		req.enables =
+			cpu_to_le32(FUNC_VF_CFG_REQ_ENABLES_ASYNC_EVENT_CR);
+		req.async_event_cr = cpu_to_le16(idx);
+		rc = hwrm_send_message(bp, &req, sizeof(req), HWRM_CMD_TIMEOUT);
+	}
+	return rc;
+}
+
 static int bnxt_hwrm_ring_alloc(struct bnxt *bp)
 {
 	int i, rc = 0;
@@ -3874,6 +3898,12 @@ static int bnxt_hwrm_ring_alloc(struct bnxt *bp)
 			goto err_out;
 		BNXT_CP_DB(cpr->cp_doorbell, cpr->cp_raw_cons);
 		bp->grp_info[i].cp_fw_ring_id = ring->fw_ring_id;
+
+		if (!i) {
+			rc = bnxt_hwrm_set_async_event_cr(bp, ring->fw_ring_id);
+			if (rc)
+				netdev_warn(bp->dev, "Failed to set async event completion ring.\n");
+		}
 	}
 
 	for (i = 0; i < bp->tx_nr_rings; i++) {
-- 
1.8.3.1
