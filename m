From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net 1/6] bnx2x: Fix ETS bandwidth
Date: Tue, 6 Sep 2011 09:46:31 +0300
Message-ID: <1315291591.28564.14.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1478 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752546Ab1IFGqs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Sep 2011 02:46:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ETS bandwidth of 0% is not allowed by driver, so provide alternative HW configuration for this case. 

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_link.c |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_link.c b/drivers/net/bnx2x/bnx2x_link.c
index d45b155..9d381db 100644
--- a/drivers/net/bnx2x/bnx2x_link.c
+++ b/drivers/net/bnx2x/bnx2x_link.c
@@ -778,9 +778,9 @@ static int bnx2x_ets_e3b0_set_cos_bw(struct bnx2x *bp,
 {
 	u32 nig_reg_adress_crd_weight = 0;
 	u32 pbf_reg_adress_crd_weight = 0;
-	/* Calculate and set BW for this COS*/
-	const u32 cos_bw_nig = (bw * min_w_val_nig) / total_bw;
-	const u32 cos_bw_pbf = (bw * min_w_val_pbf) / total_bw;
+	/* Calculate and set BW for this COS - use 1 instead of 0 for BW */
+	const u32 cos_bw_nig = ((bw ? bw : 1) * min_w_val_nig) / total_bw;
+	const u32 cos_bw_pbf = ((bw ? bw : 1) * min_w_val_pbf) / total_bw;
 
 	switch (cos_entry) {
 	case 0:
@@ -852,18 +852,12 @@ static int bnx2x_ets_e3b0_get_total_bw(
 	/* Calculate total BW requested */
 	for (cos_idx = 0; cos_idx < ets_params->num_of_cos; cos_idx++) {
 		if (bnx2x_cos_state_bw == ets_params->cos[cos_idx].state) {
-
-			if (0 == ets_params->cos[cos_idx].params.bw_params.bw) {
-				DP(NETIF_MSG_LINK, "bnx2x_ets_E3B0_config BW"
-						   "was set to 0\n");
-			return -EINVAL;
+			*total_bw +=
+				ets_params->cos[cos_idx].params.bw_params.bw;
 		}
-		*total_bw +=
-		    ets_params->cos[cos_idx].params.bw_params.bw;
-	    }
 	}
 
-	/*Check taotl BW is valid */
+	/* Check total BW is valid */
 	if ((100 != *total_bw) || (0 == *total_bw)) {
 		if (0 == *total_bw) {
 			DP(NETIF_MSG_LINK, "bnx2x_ets_E3B0_config toatl BW"
-- 
1.7.1
