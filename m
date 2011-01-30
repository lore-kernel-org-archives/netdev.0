From: "Yaniv Rosner" <yanivr@broadcom.com>
Subject: [PATCH net-2.6 4/5] bnx2x: Fix potential link loss in
 multi-function mode
Date: Sun, 30 Jan 2011 16:15:07 +0200
Message-ID: <1296396907.10095.53.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3912 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754877Ab1A3ORy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 Jan 2011 09:17:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

All functions on a port should be set to take the MDC/MDIO lock to avoid contention on the bus

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

---
 drivers/net/bnx2x/bnx2x_main.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 8cdcf5b..404d93e 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -5296,10 +5296,6 @@ static int bnx2x_init_hw_common(struct bnx2x *bp, u32 load_code)
 		}
 	}
 
-	bp->port.need_hw_lock = bnx2x_hw_lock_required(bp,
-						       bp->common.shmem_base,
-						       bp->common.shmem2_base);
-
 	bnx2x_setup_fan_failure_detection(bp);
 
 	/* clear PXP2 attentions */
@@ -5503,9 +5499,6 @@ static int bnx2x_init_hw_port(struct bnx2x *bp)
 
 	bnx2x_init_block(bp, MCP_BLOCK, init_stage);
 	bnx2x_init_block(bp, DMAE_BLOCK, init_stage);
-	bp->port.need_hw_lock = bnx2x_hw_lock_required(bp,
-						       bp->common.shmem_base,
-						       bp->common.shmem2_base);
 	if (bnx2x_fan_failure_det_req(bp, bp->common.shmem_base,
 				      bp->common.shmem2_base, port)) {
 		u32 reg_addr = (port ? MISC_REG_AEU_ENABLE1_FUNC_1_OUT_0 :
@@ -8379,6 +8372,17 @@ static void __devinit bnx2x_get_port_hwinfo(struct bnx2x *bp)
 		 (ext_phy_type != PORT_HW_CFG_XGXS_EXT_PHY_TYPE_NOT_CONN))
 		bp->mdio.prtad =
 			XGXS_EXT_PHY_ADDR(ext_phy_config);
+
+	/*
+	 * Check if hw lock is required to access MDC/MDIO bus to the PHY(s)
+	 * In MF mode, it is set to cover self test cases
+	 */
+	if (IS_MF(bp))
+		bp->port.need_hw_lock = 1;
+	else
+		bp->port.need_hw_lock = bnx2x_hw_lock_required(bp,
+							bp->common.shmem_base,
+							bp->common.shmem2_base);
 }
 
 static void __devinit bnx2x_get_mac_hwinfo(struct bnx2x *bp)
-- 
1.7.1








