From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [net PATCH v2 2/7] bnx2x: fix stats copying logic
Date: Tue, 11 Sep 2012 17:34:09 +0300
Message-ID: <1347374054-16730-3-git-send-email-yuvalmin@broadcom.com>
References: <1347374054-16730-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1386 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759501Ab2IKO6n (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Sep 2012 10:58:43 -0400
In-Reply-To: <1347374054-16730-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

FW needs the driver statistics for management. Current logic is broken
in that the function that gathers the port statistics does not copy
its own statistics to a place where the FW can use it.
This patch causes every function that can pass statistics to the FW to
do so.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
index d848dc9..a1d0446 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.c
@@ -101,6 +101,11 @@ static void bnx2x_hw_stats_post(struct bnx2x *bp)
 	if (CHIP_REV_IS_SLOW(bp))
 		return;
 
+	/* Update MCP's statistics if possible */
+	if (bp->func_stx)
+		memcpy(bnx2x_sp(bp, func_stats), &bp->func_stats,
+		       sizeof(bp->func_stats));
+
 	/* loader */
 	if (bp->executer_idx) {
 		int loader_idx = PMF_DMAE_C(bp);
@@ -128,8 +133,6 @@ static void bnx2x_hw_stats_post(struct bnx2x *bp)
 
 	} else if (bp->func_stx) {
 		*stats_comp = 0;
-		memcpy(bnx2x_sp(bp, func_stats), &bp->func_stats,
-		       sizeof(bp->func_stats));
 		bnx2x_post_dmae(bp, dmae, INIT_DMAE_C(bp));
 	}
 }
-- 
1.7.9.rc2
