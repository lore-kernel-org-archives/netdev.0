From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net 2/4] bnxt_en: Call bnxt_ulp_stop() during tx timeout.
Date: Wed,  8 Mar 2017 18:44:33 -0500
Message-ID: <1489016675-16097-3-git-send-email-michael.chan@broadcom.com>
References: <1489016675-16097-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:34026 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753908AbdCHXqD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 18:46:03 -0500
Received: by mail-wm0-f46.google.com with SMTP id 196so32926465wmm.1
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 15:44:51 -0800 (PST)
In-Reply-To: <1489016675-16097-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we call bnxt_reset_task() due to tx timeout, we should call
bnxt_ulp_stop() to inform the RDMA driver about the error and the
impending reset.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index 33293ac..bbe9371 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -6495,8 +6495,14 @@ static void bnxt_reset_task(struct bnxt *bp, bool silent)
 	if (!silent)
 		bnxt_dbg_dump_states(bp);
 	if (netif_running(bp->dev)) {
+		int rc;
+
+		if (!silent)
+			bnxt_ulp_stop(bp);
 		bnxt_close_nic(bp, false, false);
-		bnxt_open_nic(bp, false, false);
+		rc = bnxt_open_nic(bp, false, false);
+		if (!silent && !rc)
+			bnxt_ulp_start(bp);
 	}
 }
 
-- 
1.8.3.1
