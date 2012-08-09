From: "Yuval Mintz" <yuvalmin@broadcom.com>
Subject: [PATCH net 2/2] bnx2x: Fix recovery flow cleanup during probe
Date: Thu, 9 Aug 2012 17:37:26 +0300
Message-ID: <1344523046-31577-3-git-send-email-yuvalmin@broadcom.com>
References: <1344523046-31577-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com, "Yuval Mintz" <yuvalmin@broadcom.com>,
	"Ariel Elior" <ariele@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4273 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030521Ab2HIOgp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Aug 2012 10:36:45 -0400
In-Reply-To: <1344523046-31577-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

During probe, every function probed clears the recovery registers from
all functions on its path - thus signaling that given a future recovery
event, there will be no need to wait for those functions.

This is a flawed behaviour - each function should only be responsible
for its own bit.

Since this registers are handled during the load/unload routines,
this cleanup is removed altogether.

Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c |   17 -----------------
 1 files changed, 0 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
index 5384a6d..02b5a34 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_main.c
@@ -4041,20 +4041,6 @@ static bool bnx2x_get_load_status(struct bnx2x *bp, int engine)
 	return val != 0;
 }
 
-/*
- * Reset the load status for the current engine.
- */
-static void bnx2x_clear_load_status(struct bnx2x *bp)
-{
-	u32 val;
-	u32 mask = (BP_PATH(bp) ? BNX2X_PATH1_LOAD_CNT_MASK :
-		    BNX2X_PATH0_LOAD_CNT_MASK);
-	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
-	val = REG_RD(bp, BNX2X_RECOVERY_GLOB_REG);
-	REG_WR(bp, BNX2X_RECOVERY_GLOB_REG, val & (~mask));
-	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RECOVERY_REG);
-}
-
 static void _print_next_block(int idx, const char *blk)
 {
 	pr_cont("%s%s", idx ? ", " : "", blk);
@@ -11428,9 +11414,6 @@ static int __devinit bnx2x_init_dev(struct pci_dev *pdev,
 	if (!chip_is_e1x)
 		REG_WR(bp, PGLUE_B_REG_INTERNAL_PFID_ENABLE_TARGET_READ, 1);
 
-	/* Reset the load counter */
-	bnx2x_clear_load_status(bp);
-
 	dev->watchdog_timeo = TX_TIMEOUT;
 
 	dev->netdev_ops = &bnx2x_netdev_ops;
-- 
1.7.9.rc2
