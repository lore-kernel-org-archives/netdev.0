From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 2/2] bnx2x: add RSS capability for GRE traffic
Date: Mon, 18 Mar 2013 18:51:04 +0200
Message-ID: <1363625464-21633-2-git-send-email-dmitry@broadcom.com>
References: <1363625464-21633-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2997 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754411Ab3CRQvR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Mar 2013 12:51:17 -0400
In-Reply-To: <1363625464-21633-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch drives FW to perform RSS for GRE traffic,
based on inner headers.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h |    3 +++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c  |   23 ++++++++++++-----------
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h  |    9 +++++++++
 3 files changed, 24 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
index 8f96372..f9098d8 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.h
@@ -973,6 +973,9 @@ static inline int bnx2x_func_start(struct bnx2x *bp)
 	else /* CHIP_IS_E1X */
 		start_params->network_cos_mode = FW_WRR;
 
+	start_params->gre_tunnel_mode = IPGRE_TUNNEL;
+	start_params->gre_tunnel_rss = GRE_INNER_HEADERS_RSS;
+
 	return bnx2x_func_state_change(bp, &func_params);
 }
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 66ab259..5bdc1d6 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -5679,17 +5679,18 @@ static inline int bnx2x_func_send_start(struct bnx2x *bp,
 	memset(rdata, 0, sizeof(*rdata));
 
 	/* Fill the ramrod data with provided parameters */
-	rdata->function_mode    = (u8)start_params->mf_mode;
-	rdata->sd_vlan_tag      = cpu_to_le16(start_params->sd_vlan_tag);
-	rdata->path_id          = BP_PATH(bp);
-	rdata->network_cos_mode = start_params->network_cos_mode;
-
-	/*
-	 *  No need for an explicit memory barrier here as long we would
-	 *  need to ensure the ordering of writing to the SPQ element
-	 *  and updating of the SPQ producer which involves a memory
-	 *  read and we will have to put a full memory barrier there
-	 *  (inside bnx2x_sp_post()).
+	rdata->function_mode	= (u8)start_params->mf_mode;
+	rdata->sd_vlan_tag	= cpu_to_le16(start_params->sd_vlan_tag);
+	rdata->path_id		= BP_PATH(bp);
+	rdata->network_cos_mode	= start_params->network_cos_mode;
+	rdata->gre_tunnel_mode	= start_params->gre_tunnel_mode;
+	rdata->gre_tunnel_rss	= start_params->gre_tunnel_rss;
+
+	/* No need for an explicit memory barrier here as long we would
+	 * need to ensure the ordering of writing to the SPQ element
+	 * and updating of the SPQ producer which involves a memory
+	 * read and we will have to put a full memory barrier there
+	 * (inside bnx2x_sp_post()).
 	 */
 
 	return bnx2x_sp_post(bp, RAMROD_CMD_ID_COMMON_FUNCTION_START, 0,
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
index 064dba2..35479da 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.h
@@ -1123,6 +1123,15 @@ struct bnx2x_func_start_params {
 
 	/* Function cos mode */
 	u8 network_cos_mode;
+
+	/* NVGRE classification enablement */
+	u8 nvgre_clss_en;
+
+	/* NO_GRE_TUNNEL/NVGRE_TUNNEL/L2GRE_TUNNEL/IPGRE_TUNNEL */
+	u8 gre_tunnel_mode;
+
+	/* GRE_OUTER_HEADERS_RSS/GRE_INNER_HEADERS_RSS/NVGRE_KEY_ENTROPY_RSS */
+	u8 gre_tunnel_rss;
 };
 
 struct bnx2x_func_switch_update_params {
-- 
1.7.7.2
