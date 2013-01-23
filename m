From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net-next 07/12] bnx2x: Modify unload conditions
Date: Wed, 23 Jan 2013 15:21:49 +0200
Message-ID: <1358947314-3851-8-git-send-email-yuvalmin@broadcom.com>
References: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, ariele@broadcom.com,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1315 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755279Ab3AWOXH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jan 2013 09:23:07 -0500
In-Reply-To: <1358947314-3851-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't unload the bnx2x driver if its in a recovery process, or if
the previous load have failed.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 14 +++++++++++---
 1 file changed, 11 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index bcb2b64..a461138 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2805,7 +2805,7 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode, bool keep_link)
 			  val & ~DRV_FLAGS_CAPABILITIES_LOADED_L2);
 	}
 
-	if (IS_PF(bp) &&
+	if (IS_PF(bp) && bp->recovery_state != BNX2X_RECOVERY_DONE &&
 	    (bp->state == BNX2X_STATE_CLOSED ||
 	     bp->state == BNX2X_STATE_ERROR)) {
 		/* We can get here if the driver has been unloaded
@@ -2825,8 +2825,16 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode, bool keep_link)
 		return -EINVAL;
 	}
 
-	/*
-	 * It's important to set the bp->state to the value different from
+	/* Nothing to do during unload if previous bnx2x_nic_load()
+	 * have not completed succesfully - all resourses are released.
+	 *
+	 * we can get here only after unsuccessful ndo_* callback, during which
+	 * dev->IFF_UP flag is still on.
+	 */
+	if (bp->state == BNX2X_STATE_CLOSED || bp->state == BNX2X_STATE_ERROR)
+		return 0;
+
+	/* It's important to set the bp->state to the value different from
 	 * BNX2X_STATE_OPEN and only then stop the Tx. Otherwise bnx2x_tx_int()
 	 * may restart the Tx from the NAPI context (see bnx2x_tx_int()).
 	 */
-- 
1.8.1.227.g44fe835
