From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next 5/6] bnx2x: remove unnecessary FUNC_FLG_RSS
 flag and related
Date: Mon, 18 Oct 2010 11:08:53 +0200
Message-ID: <1287392933.11597.39.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"Vladislav Zolotarov" <vladz@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:1699 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754566Ab0JRJMT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Oct 2010 05:12:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


As suggested by: Joe Perches <joe@perches.com>

Although RSS is meaningless when there is a single HW queue we
still need it enabled in order to have HW Rx hash generated.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x.h      |   13 ++-----
 drivers/net/bnx2x/bnx2x_main.c |   70 +++++++++++++++++-----------------------
 2 files changed, 34 insertions(+), 49 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index c49b643..556cad5 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -1180,15 +1180,10 @@ struct bnx2x {
 	TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV6_TCP_CAPABILITY
 
 /* func init flags */
-#define FUNC_FLG_RSS		0x0001
-#define FUNC_FLG_STATS		0x0002
-/* removed  FUNC_FLG_UNMATCHED	0x0004 */
-#define FUNC_FLG_TPA		0x0008
-#define FUNC_FLG_SPQ		0x0010
-#define FUNC_FLG_LEADING	0x0020	/* PF only */
-
-#define FUNC_CONFIG(flgs)	((flgs) & (FUNC_FLG_RSS | FUNC_FLG_TPA | \
-					FUNC_FLG_LEADING))
+#define FUNC_FLG_STATS		0x0001
+#define FUNC_FLG_TPA		0x0002
+#define FUNC_FLG_SPQ		0x0004
+#define FUNC_FLG_LEADING	0x0008	/* PF only */
 
 struct rxq_pause_params {
 	u16		bd_th_lo;
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index ead524b..012c093 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -2284,35 +2284,31 @@ void bnx2x_rxq_set_mac_filters(struct bnx2x *bp, u16 cl_id, u32 filters)
 
 void bnx2x_func_init(struct bnx2x *bp, struct bnx2x_func_init_params *p)
 {
-	if (FUNC_CONFIG(p->func_flgs)) {
-		struct tstorm_eth_function_common_config tcfg = {0};
-
-		/* tpa */
-		if (p->func_flgs & FUNC_FLG_TPA)
-			tcfg.config_flags |=
-			TSTORM_ETH_FUNCTION_COMMON_CONFIG_ENABLE_TPA;
-
-		/* set rss flags */
-		if (p->func_flgs & FUNC_FLG_RSS) {
-			u16 rss_flgs = (p->rss->mode <<
-			TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_MODE_SHIFT);
-
-			if (p->rss->cap & RSS_IPV4_CAP)
-				rss_flgs |= RSS_IPV4_CAP_MASK;
-			if (p->rss->cap & RSS_IPV4_TCP_CAP)
-				rss_flgs |= RSS_IPV4_TCP_CAP_MASK;
-			if (p->rss->cap & RSS_IPV6_CAP)
-				rss_flgs |= RSS_IPV6_CAP_MASK;
-			if (p->rss->cap & RSS_IPV6_TCP_CAP)
-				rss_flgs |= RSS_IPV6_TCP_CAP_MASK;
-
-			tcfg.config_flags |= rss_flgs;
-			tcfg.rss_result_mask = p->rss->result_mask;
+	struct tstorm_eth_function_common_config tcfg = {0};
+	u16 rss_flgs;
 
-		}
+	/* tpa */
+	if (p->func_flgs & FUNC_FLG_TPA)
+		tcfg.config_flags |=
+		TSTORM_ETH_FUNCTION_COMMON_CONFIG_ENABLE_TPA;
 
-		storm_memset_func_cfg(bp, &tcfg, p->func_id);
-	}
+	/* set rss flags */
+	rss_flgs = (p->rss->mode <<
+		TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_MODE_SHIFT);
+
+	if (p->rss->cap & RSS_IPV4_CAP)
+		rss_flgs |= RSS_IPV4_CAP_MASK;
+	if (p->rss->cap & RSS_IPV4_TCP_CAP)
+		rss_flgs |= RSS_IPV4_TCP_CAP_MASK;
+	if (p->rss->cap & RSS_IPV6_CAP)
+		rss_flgs |= RSS_IPV6_CAP_MASK;
+	if (p->rss->cap & RSS_IPV6_TCP_CAP)
+		rss_flgs |= RSS_IPV6_TCP_CAP_MASK;
+
+	tcfg.config_flags |= rss_flgs;
+	tcfg.rss_result_mask = p->rss->result_mask;
+
+	storm_memset_func_cfg(bp, &tcfg, p->func_id);
 
 	/* Enable the function in the FW */
 	storm_memset_vf_to_pf(bp, p->func_id, p->pf_id);
@@ -2479,23 +2475,17 @@ void bnx2x_pf_init(struct bnx2x *bp)
 	else
 		flags |= FUNC_FLG_TPA;
 
+	/* function setup */
+
 	/**
 	 * Although RSS is meaningless when there is a single HW queue we
 	 * still need it enabled in order to have HW Rx hash generated.
-	 *
-	 * if (is_eth_multi(bp))
-	 *	flags |= FUNC_FLG_RSS;
 	 */
-	flags |= FUNC_FLG_RSS;
-
-	/* function setup */
-	if (flags & FUNC_FLG_RSS) {
-		rss.cap = (RSS_IPV4_CAP | RSS_IPV4_TCP_CAP |
-			   RSS_IPV6_CAP | RSS_IPV6_TCP_CAP);
-		rss.mode = bp->multi_mode;
-		rss.result_mask = MULTI_MASK;
-		func_init.rss = &rss;
-	}
+	rss.cap = (RSS_IPV4_CAP | RSS_IPV4_TCP_CAP |
+		   RSS_IPV6_CAP | RSS_IPV6_TCP_CAP);
+	rss.mode = bp->multi_mode;
+	rss.result_mask = MULTI_MASK;
+	func_init.rss = &rss;
 
 	func_init.func_flgs = flags;
 	func_init.pf_id = BP_FUNC(bp);
-- 
1.7.2.2




