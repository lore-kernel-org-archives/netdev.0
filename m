From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 06/10] bnxt_en: Re-arrange bnxt_hwrm_func_qcaps().
Date: Mon, 19 Sep 2016 03:58:05 -0400
Message-ID: <1474271889-8229-7-git-send-email-michael.chan@broadcom.com>
References: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35468 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760256AbcISH6a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 03:58:30 -0400
Received: by mail-pf0-f181.google.com with SMTP id z123so48337550pfz.2
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 00:58:30 -0700 (PDT)
In-Reply-To: <1474271889-8229-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Re-arrange the code so that the generation of the random MAC address for
the VF is at the end of the function.  The next patch will add one more step
to call bnxt_approve_mac() to get the firmware to approve the random MAC
address.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index f0a9d23..b1dcece 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4161,6 +4161,11 @@ int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 	if (rc)
 		goto hwrm_func_qcaps_exit;
 
+	bp->tx_push_thresh = 0;
+	if (resp->flags &
+	    cpu_to_le32(FUNC_QCAPS_RESP_FLAGS_PUSH_MODE_SUPPORTED))
+		bp->tx_push_thresh = BNXT_TX_PUSH_THRESH;
+
 	if (BNXT_PF(bp)) {
 		struct bnxt_pf_info *pf = &bp->pf;
 
@@ -4192,12 +4197,6 @@ int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 		struct bnxt_vf_info *vf = &bp->vf;
 
 		vf->fw_fid = le16_to_cpu(resp->fid);
-		memcpy(vf->mac_addr, resp->mac_address, ETH_ALEN);
-		if (is_valid_ether_addr(vf->mac_addr))
-			/* overwrite netdev dev_adr with admin VF MAC */
-			memcpy(bp->dev->dev_addr, vf->mac_addr, ETH_ALEN);
-		else
-			random_ether_addr(bp->dev->dev_addr);
 
 		vf->max_rsscos_ctxs = le16_to_cpu(resp->max_rsscos_ctx);
 		vf->max_cp_rings = le16_to_cpu(resp->max_cmpl_rings);
@@ -4209,14 +4208,16 @@ int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 		vf->max_l2_ctxs = le16_to_cpu(resp->max_l2_ctxs);
 		vf->max_vnics = le16_to_cpu(resp->max_vnics);
 		vf->max_stat_ctxs = le16_to_cpu(resp->max_stat_ctx);
+
+		memcpy(vf->mac_addr, resp->mac_address, ETH_ALEN);
+		if (is_valid_ether_addr(vf->mac_addr))
+			/* overwrite netdev dev_adr with admin VF MAC */
+			memcpy(bp->dev->dev_addr, vf->mac_addr, ETH_ALEN);
+		else
+			random_ether_addr(bp->dev->dev_addr);
 #endif
 	}
 
-	bp->tx_push_thresh = 0;
-	if (resp->flags &
-	    cpu_to_le32(FUNC_QCAPS_RESP_FLAGS_PUSH_MODE_SUPPORTED))
-		bp->tx_push_thresh = BNXT_TX_PUSH_THRESH;
-
 hwrm_func_qcaps_exit:
 	mutex_unlock(&bp->hwrm_cmd_lock);
 	return rc;
-- 
1.8.3.1
