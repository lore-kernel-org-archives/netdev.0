From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [net 2/5] bnx2x: Fix PFC setting on BCM57840
Date: Tue, 17 Jan 2012 14:33:26 +0200
Message-ID: <1326803609-25526-3-git-send-email-yanivr@broadcom.com>
References: <1326803609-25526-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	"Yaniv Rosner" <yanivr@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3453 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753090Ab2AQKez (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jan 2012 05:34:55 -0500
In-Reply-To: <1326803609-25526-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch handles the second port of a path in a 4-port device of BCM57840.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   22 ++++++++++++----------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |    1 +
 2 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 3b184c2..cc80637 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -2502,7 +2502,7 @@ static void bnx2x_update_pfc_nig(struct link_params *params,
 		struct bnx2x_nig_brb_pfc_port_params *nig_params)
 {
 	u32 xcm_mask = 0, ppp_enable = 0, pause_enable = 0, llfc_out_en = 0;
-	u32 llfc_enable = 0, xcm0_out_en = 0, p0_hwpfc_enable = 0;
+	u32 llfc_enable = 0, xcm_out_en = 0, hwpfc_enable = 0;
 	u32 pkt_priority_to_cos = 0;
 	struct bnx2x *bp = params->bp;
 	u8 port = params->port;
@@ -2516,9 +2516,8 @@ static void bnx2x_update_pfc_nig(struct link_params *params,
 	 * MAC control frames (that are not pause packets)
 	 * will be forwarded to the XCM.
 	 */
-	xcm_mask = REG_RD(bp,
-				port ? NIG_REG_LLH1_XCM_MASK :
-				NIG_REG_LLH0_XCM_MASK);
+	xcm_mask = REG_RD(bp, port ? NIG_REG_LLH1_XCM_MASK :
+			  NIG_REG_LLH0_XCM_MASK);
 	/*
 	 * nig params will override non PFC params, since it's possible to
 	 * do transition from PFC to SAFC
@@ -2533,8 +2532,8 @@ static void bnx2x_update_pfc_nig(struct link_params *params,
 		ppp_enable = 1;
 		xcm_mask &= ~(port ? NIG_LLH1_XCM_MASK_REG_LLH1_XCM_MASK_BCN :
 				     NIG_LLH0_XCM_MASK_REG_LLH0_XCM_MASK_BCN);
-		xcm0_out_en = 0;
-		p0_hwpfc_enable = 1;
+		xcm_out_en = 0;
+		hwpfc_enable = 1;
 	} else  {
 		if (nig_params) {
 			llfc_out_en = nig_params->llfc_out_en;
@@ -2545,7 +2544,7 @@ static void bnx2x_update_pfc_nig(struct link_params *params,
 
 		xcm_mask |= (port ? NIG_LLH1_XCM_MASK_REG_LLH1_XCM_MASK_BCN :
 			NIG_LLH0_XCM_MASK_REG_LLH0_XCM_MASK_BCN);
-		xcm0_out_en = 1;
+		xcm_out_en = 1;
 	}
 
 	if (CHIP_IS_E3(bp))
@@ -2564,13 +2563,16 @@ static void bnx2x_update_pfc_nig(struct link_params *params,
 	REG_WR(bp, port ? NIG_REG_LLH1_XCM_MASK :
 	       NIG_REG_LLH0_XCM_MASK, xcm_mask);
 
-	REG_WR(bp,  NIG_REG_LLFC_EGRESS_SRC_ENABLE_0, 0x7);
+	REG_WR(bp, port ? NIG_REG_LLFC_EGRESS_SRC_ENABLE_1 :
+	       NIG_REG_LLFC_EGRESS_SRC_ENABLE_0, 0x7);
 
 	/* output enable for RX_XCM # IF */
-	REG_WR(bp, NIG_REG_XCM0_OUT_EN, xcm0_out_en);
+	REG_WR(bp, port ? NIG_REG_XCM1_OUT_EN :
+	       NIG_REG_XCM0_OUT_EN, xcm_out_en);
 
 	/* HW PFC TX enable */
-	REG_WR(bp, NIG_REG_P0_HWPFC_ENABLE, p0_hwpfc_enable);
+	REG_WR(bp, port ? NIG_REG_P1_HWPFC_ENABLE :
+	       NIG_REG_P0_HWPFC_ENABLE, hwpfc_enable);
 
 	if (nig_params) {
 		u8 i = 0;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 44609de..dddbcf6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -2176,6 +2176,7 @@
  * set to 0x345678021. This is a new register (with 2_) added in E3 B0 to
  * accommodate the 9 input clients to ETS arbiter. */
 #define NIG_REG_P0_TX_ARB_PRIORITY_CLIENT2_MSB			 0x18684
+#define NIG_REG_P1_HWPFC_ENABLE					 0x181d0
 #define NIG_REG_P1_MAC_IN_EN					 0x185c0
 /* [RW 1] Output enable for TX MAC interface */
 #define NIG_REG_P1_MAC_OUT_EN					 0x185c4
-- 
1.7.7.1
