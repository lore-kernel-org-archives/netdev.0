From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next v2 07/10] bnxt_en: Call firmware to approve the random VF MAC address.
Date: Tue, 20 Sep 2016 02:50:25 -0400
Message-ID: <1474354228-3221-8-git-send-email-michael.chan@broadcom.com>
References: <1474354228-3221-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34692 "EHLO
        mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752504AbcITGuo (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Sep 2016 02:50:44 -0400
Received: by mail-pa0-f42.google.com with SMTP id wk8so3912347pab.1
        for <netdev@vger.kernel.org>; Mon, 19 Sep 2016 23:50:43 -0700 (PDT)
In-Reply-To: <1474354228-3221-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

After generating the random MAC address for VF, call the firmware to
approve it.  This step serves 2 purposes.  Some hypervisor (e.g. ESX)
wants to approve the MAC address.  2nd, the call will setup the
proper forwarding database in the internal switch.

We need to unlock the hwrm_cmd_lock mutex before calling bnxt_approve_mac().
We can do that because we are at the end of the function and all the
previous firmware response data has been copied.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index dc2559a..a9f9f37 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4210,11 +4210,16 @@ int bnxt_hwrm_func_qcaps(struct bnxt *bp)
 		vf->max_stat_ctxs = le16_to_cpu(resp->max_stat_ctx);
 
 		memcpy(vf->mac_addr, resp->mac_address, ETH_ALEN);
-		if (is_valid_ether_addr(vf->mac_addr))
+		mutex_unlock(&bp->hwrm_cmd_lock);
+
+		if (is_valid_ether_addr(vf->mac_addr)) {
 			/* overwrite netdev dev_adr with admin VF MAC */
 			memcpy(bp->dev->dev_addr, vf->mac_addr, ETH_ALEN);
-		else
+		} else {
 			random_ether_addr(bp->dev->dev_addr);
+			rc = bnxt_approve_mac(bp, bp->dev->dev_addr);
+		}
+		return rc;
 #endif
 	}
 
-- 
1.8.3.1
