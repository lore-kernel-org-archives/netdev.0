From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 2/3] bnxt_en: Fix NULL pointer dereference in a failure path during open.
Date: Mon, 20 Feb 2017 19:25:17 -0500
Message-ID: <1487636718-21293-3-git-send-email-michael.chan@broadcom.com>
References: <1487636718-21293-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:35560 "EHLO
        mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751072AbdBUAZh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 19:25:37 -0500
Received: by mail-qk0-f180.google.com with SMTP id u188so33634035qkc.2
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 16:25:36 -0800 (PST)
In-Reply-To: <1487636718-21293-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If bnxt_hwrm_ring_free() is called during a failure path in bnxt_open(),
it is possible that the completion rings have not been allocated yet.
In that case, the completion doorbell has not been initialized, and
calling bnxt_disable_int() will crash.  Fix it by checking that the
completion ring has been initialized before writing to the completion
ring doorbell.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index f4dec1b..37b9f65 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -3134,8 +3134,10 @@ static void bnxt_disable_int(struct bnxt *bp)
 	for (i = 0; i < bp->cp_nr_rings; i++) {
 		struct bnxt_napi *bnapi = bp->bnapi[i];
 		struct bnxt_cp_ring_info *cpr = &bnapi->cp_ring;
+		struct bnxt_ring_struct *ring = &cpr->cp_ring_struct;
 
-		BNXT_CP_DB(cpr->cp_doorbell, cpr->cp_raw_cons);
+		if (ring->fw_ring_id != INVALID_HW_RING_ID)
+			BNXT_CP_DB(cpr->cp_doorbell, cpr->cp_raw_cons);
 	}
 }
 
-- 
1.8.3.1
