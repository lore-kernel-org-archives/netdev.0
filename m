From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net-next 6/9] bnx2x: added TLV_NOT_FOUND flags to the dcb
Date: Sun, 18 Mar 2012 16:33:42 -0400
Message-ID: <1332102825-7838-7-git-send-email-yuvalmin@broadcom.com>
References: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Yuval Mintz" <yuvalmin@broadcom.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4955 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755088Ab2CRNsd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Mar 2012 09:48:33 -0400
In-Reply-To: <1332102825-7838-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Kravkov <dmitry@broadcom.com>

The new error flags are supported by the bnx2x FW.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c |   21 ++++++++++++++-------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h |    3 +++
 2 files changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index fafbc00..9bba7b7 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -206,8 +206,11 @@ static void bnx2x_dcbx_get_ap_feature(struct bnx2x *bp,
 	if (GET_FLAGS(error, DCBX_LOCAL_APP_MISMATCH))
 		DP(BNX2X_MSG_DCB, "DCBX_LOCAL_APP_MISMATCH\n");
 
+	if (GET_FLAGS(error, DCBX_REMOTE_APP_TLV_NOT_FOUND))
+		DP(BNX2X_MSG_DCB, "DCBX_REMOTE_APP_TLV_NOT_FOUND\n");
 	if (app->enabled &&
-	    !GET_FLAGS(error, DCBX_LOCAL_APP_ERROR | DCBX_LOCAL_APP_MISMATCH)) {
+	    !GET_FLAGS(error, DCBX_LOCAL_APP_ERROR | DCBX_LOCAL_APP_MISMATCH |
+			      DCBX_REMOTE_APP_TLV_NOT_FOUND)) {
 
 		bp->dcbx_port_params.app.enabled = true;
 
@@ -258,6 +261,8 @@ static void bnx2x_dcbx_get_ets_feature(struct bnx2x *bp,
 	if (GET_FLAGS(error, DCBX_LOCAL_ETS_ERROR))
 		DP(BNX2X_MSG_DCB, "DCBX_LOCAL_ETS_ERROR\n");
 
+	if (GET_FLAGS(error, DCBX_REMOTE_ETS_TLV_NOT_FOUND))
+		DP(BNX2X_MSG_DCB, "DCBX_REMOTE_ETS_TLV_NOT_FOUND\n");
 
 	/* Clean up old settings of ets on COS */
 	for (i = 0; i < ARRAY_SIZE(bp->dcbx_port_params.ets.cos_params) ; i++) {
@@ -267,9 +272,9 @@ static void bnx2x_dcbx_get_ets_feature(struct bnx2x *bp,
 		cos_params[i].pri_bitmask = 0;
 	}
 
-	if (bp->dcbx_port_params.app.enabled &&
-	   !GET_FLAGS(error, DCBX_LOCAL_ETS_ERROR) &&
-	   ets->enabled) {
+	if (bp->dcbx_port_params.app.enabled && ets->enabled &&
+	   !GET_FLAGS(error,
+		      DCBX_LOCAL_ETS_ERROR | DCBX_REMOTE_ETS_TLV_NOT_FOUND)) {
 		DP(BNX2X_MSG_DCB, "DCBX_LOCAL_ETS_ENABLE\n");
 		bp->dcbx_port_params.ets.enabled = true;
 
@@ -301,9 +306,11 @@ static void  bnx2x_dcbx_get_pfc_feature(struct bnx2x *bp,
 	if (GET_FLAGS(error, DCBX_LOCAL_PFC_ERROR))
 		DP(BNX2X_MSG_DCB, "DCBX_LOCAL_PFC_ERROR\n");
 
-	if (bp->dcbx_port_params.app.enabled &&
-	   !GET_FLAGS(error, DCBX_LOCAL_PFC_ERROR | DCBX_LOCAL_PFC_MISMATCH) &&
-	   pfc->enabled) {
+	if (GET_FLAGS(error, DCBX_REMOTE_PFC_TLV_NOT_FOUND))
+		DP(BNX2X_MSG_DCB, "DCBX_REMOTE_PFC_TLV_NOT_FOUND\n");
+	if (bp->dcbx_port_params.app.enabled && pfc->enabled &&
+	   !GET_FLAGS(error, DCBX_LOCAL_PFC_ERROR | DCBX_LOCAL_PFC_MISMATCH |
+			     DCBX_REMOTE_PFC_TLV_NOT_FOUND)) {
 		bp->dcbx_port_params.pfc.enabled = true;
 		bp->dcbx_port_params.pfc.priority_non_pauseable_mask =
 			~(pfc->pri_en_bitmap);
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
index a1413ad..0c5f121 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_hsi.h
@@ -1833,6 +1833,9 @@ struct lldp_local_mib {
 	#define DCBX_LOCAL_PFC_MISMATCH          0x00000010
 	#define DCBX_LOCAL_APP_MISMATCH          0x00000020
 	#define DCBX_REMOTE_MIB_ERROR		 0x00000040
+	#define DCBX_REMOTE_ETS_TLV_NOT_FOUND    0x00000080
+	#define DCBX_REMOTE_PFC_TLV_NOT_FOUND    0x00000100
+	#define DCBX_REMOTE_APP_TLV_NOT_FOUND    0x00000200
 	struct dcbx_features   features;
 	u32 suffix_seq_num;
 };
-- 
1.7.9.rc2
