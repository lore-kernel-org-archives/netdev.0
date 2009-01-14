From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 08/34]bnx2x: Protecting the link change indication
Date: Wed, 14 Jan 2009 18:43:05 +0200
Message-ID: <1231951385.11301.129.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2391 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763006AbZANQns (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:43:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Without this lock, in some race conditions the driver missed link change
indication

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 56eae2d..4735f57 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2250,9 +2250,7 @@ static void bnx2x_link_attn(struct bnx2x *bp)
 	/* Make sure that we are synced with the current statistics */
 	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
 
-	bnx2x_acquire_phy_lock(bp);
 	bnx2x_link_update(&bp->link_params, &bp->link_vars);
-	bnx2x_release_phy_lock(bp);
 
 	if (bp->link_vars.link_up) {
 
@@ -2501,6 +2499,8 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 	if (asserted & ATTN_HARD_WIRED_MASK) {
 		if (asserted & ATTN_NIG_FOR_FUNC) {
 
+			bnx2x_acquire_phy_lock(bp);
+
 			/* save nig interrupt mask */
 			bp->nig_mask = REG_RD(bp, nig_int_mask_addr);
 			REG_WR(bp, nig_int_mask_addr, 0);
@@ -2556,8 +2556,10 @@ static void bnx2x_attn_int_asserted(struct bnx2x *bp, u32 asserted)
 	REG_WR(bp, hc_addr, asserted);
 
 	/* now set back the mask */
-	if (asserted & ATTN_NIG_FOR_FUNC)
+	if (asserted & ATTN_NIG_FOR_FUNC) {
 		REG_WR(bp, nig_int_mask_addr, bp->nig_mask);
+		bnx2x_release_phy_lock(bp);
+	}
 }
 
 static inline void bnx2x_attn_int_deasserted0(struct bnx2x *bp, u32 attn)
-- 
1.5.4.3




