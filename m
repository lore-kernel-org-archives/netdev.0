From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net v4 3/6] bnx2x: update fairness parameters following
 DCB negotiation
Date: Tue, 6 Aug 2013 00:35:41 +0300
Message-ID: <1375738544-8695-4-git-send-email-dmitry@broadcom.com>
References: <1375738544-8695-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1133 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754621Ab3HEVgH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Aug 2013 17:36:07 -0400
In-Reply-To: <1375738544-8695-1-git-send-email-dmitry@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ETS can be enabled as a result of DCB negotiation, then
fairness must be recalculated after each negotiation.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h      |  2 ++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c  |  4 ++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c | 30 ++++++++++++++----------
 3 files changed, 24 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index c7ffff3..062480a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -2454,4 +2454,6 @@ enum bnx2x_pci_bus_speed {
 	BNX2X_PCI_LINK_SPEED_5000 = 5000,
 	BNX2X_PCI_LINK_SPEED_8000 = 8000
 };
+
+void bnx2x_set_local_cmng(struct bnx2x *bp);
 #endif /* bnx2x.h */
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
index 0c94df4..f9122f2 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_dcb.c
@@ -753,6 +753,10 @@ void bnx2x_dcbx_set_params(struct bnx2x *bp, u32 state)
 		bnx2x_pfc_set_pfc(bp);
 
 		bnx2x_dcbx_update_ets_params(bp);
+
+		/* ets may affect cmng configuration: reinit it in hw */
+		bnx2x_set_local_cmng(bp);
+
 		bnx2x_dcbx_resume_hw_tx(bp);
 
 		return;
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index e06186c..90a84af 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -2476,7 +2476,7 @@ static void bnx2x_cmng_fns_init(struct bnx2x *bp, u8 read_cfg, u8 cmng_type)
 
 	input.port_rate = bp->link_vars.line_speed;
 
-	if (cmng_type == CMNG_FNS_MINMAX) {
+	if (cmng_type == CMNG_FNS_MINMAX && input.port_rate) {
 		int vn;
 
 		/* read mf conf from shmem */
@@ -2533,6 +2533,21 @@ static void storm_memset_cmng(struct bnx2x *bp,
 	}
 }
 
+/* init cmng mode in HW according to local configuration */
+void bnx2x_set_local_cmng(struct bnx2x *bp)
+{
+	int cmng_fns = bnx2x_get_cmng_fns_mode(bp);
+
+	if (cmng_fns != CMNG_FNS_NONE) {
+		bnx2x_cmng_fns_init(bp, false, cmng_fns);
+		storm_memset_cmng(bp, &bp->cmng, BP_PORT(bp));
+	} else {
+		/* rate shaping and fairness are disabled */
+		DP(NETIF_MSG_IFUP,
+		   "single function mode without fairness\n");
+	}
+}
+
 /* This function is called upon link interrupt */
 static void bnx2x_link_attn(struct bnx2x *bp)
 {
@@ -2568,17 +2583,8 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 			bnx2x_stats_handle(bp, STATS_EVENT_LINK_UP);
 	}
 
-	if (bp->link_vars.link_up && bp->link_vars.line_speed) {
-		int cmng_fns = bnx2x_get_cmng_fns_mode(bp);
-
-		if (cmng_fns != CMNG_FNS_NONE) {
-			bnx2x_cmng_fns_init(bp, false, cmng_fns);
-			storm_memset_cmng(bp, &bp->cmng, BP_PORT(bp));
-		} else
-			/* rate shaping and fairness are disabled */
-			DP(NETIF_MSG_IFUP,
-			   "single function mode without fairness\n");
-	}
+	if (bp->link_vars.link_up && bp->link_vars.line_speed)
+		bnx2x_set_local_cmng(bp);
 
 	__bnx2x_link_report(bp);
 
-- 
1.8.1.4
