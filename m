From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net-next v2 2/9] bnx2x: ETS changes
Date: Mon, 28 Nov 2011 12:49:46 +0200
Message-ID: <1322477393-22904-3-git-send-email-yanivr@broadcom.com>
References: <1322477393-22904-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3516 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752826Ab1K1Iun (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 03:50:43 -0500
In-Reply-To: <1322477393-22904-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a problem when new traffic class is created with 0% BW, the ETS is not conforming.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   19 ++++++++++++++++---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h |    2 +-
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 8e6909a..de03730 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -874,23 +874,36 @@ static int bnx2x_ets_e3b0_set_cos_bw(struct bnx2x *bp,
 ******************************************************************************/
 static int bnx2x_ets_e3b0_get_total_bw(
 	const struct link_params *params,
-	const struct bnx2x_ets_params *ets_params,
+	struct bnx2x_ets_params *ets_params,
 	u16 *total_bw)
 {
 	struct bnx2x *bp = params->bp;
 	u8 cos_idx = 0;
+	u8 is_bw_cos_exist = 0;
 
 	*total_bw = 0 ;
+
 	/* Calculate total BW requested */
 	for (cos_idx = 0; cos_idx < ets_params->num_of_cos; cos_idx++) {
 		if (bnx2x_cos_state_bw == ets_params->cos[cos_idx].state) {
+			is_bw_cos_exist = 1;
+			if (!ets_params->cos[cos_idx].params.bw_params.bw) {
+				DP(NETIF_MSG_LINK, "bnx2x_ets_E3B0_config BW"
+						   "was set to 0\n");
+				/*
+				 * This is to prevent a state when ramrods
+				 * can't be sent
+				*/
+				ets_params->cos[cos_idx].params.bw_params.bw
+					 = 1;
+			}
 			*total_bw +=
 				ets_params->cos[cos_idx].params.bw_params.bw;
 		}
 	}
 
 	/* Check total BW is valid */
-	if ((100 != *total_bw) || (0 == *total_bw)) {
+	if ((1 == is_bw_cos_exist) && (100 != *total_bw)) {
 		if (0 == *total_bw) {
 			DP(NETIF_MSG_LINK,
 			   "bnx2x_ets_E3B0_config toatl BW shouldn't be 0\n");
@@ -1100,7 +1113,7 @@ static int bnx2x_ets_e3b0_sp_set_pri_cli_reg(const struct link_params *params,
 ******************************************************************************/
 int bnx2x_ets_e3b0_config(const struct link_params *params,
 			 const struct link_vars *vars,
-			 const struct bnx2x_ets_params *ets_params)
+			 struct bnx2x_ets_params *ets_params)
 {
 	struct bnx2x *bp = params->bp;
 	int bnx2x_status = 0;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
index 2a46e63..e02a68a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.h
@@ -479,7 +479,7 @@ int bnx2x_ets_strict(const struct link_params *params, const u8 strict_cos);
 /*  Configure the COS to ETS according to BW and SP settings.*/
 int bnx2x_ets_e3b0_config(const struct link_params *params,
 			 const struct link_vars *vars,
-			 const struct bnx2x_ets_params *ets_params);
+			 struct bnx2x_ets_params *ets_params);
 /* Read pfc statistic*/
 void bnx2x_pfc_statistic(struct link_params *params, struct link_vars *vars,
 						 u32 pfc_frames_sent[2],
-- 
1.7.7.1
