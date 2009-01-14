From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 24/34]bnx2x: Potential race after iSCSI boot
Date: Wed, 14 Jan 2009 18:43:56 +0200
Message-ID: <1231951436.11301.145.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1340 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1763886AbZANQox (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Jan 2009 11:44:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The lock was release too soon. Make sure the HW is marked as locked until the
boot driver was unloaded from FW perspective

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index e875dd2..5f0d2de 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6909,10 +6909,6 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 		 */
 		bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_UNDI);
 		val = REG_RD(bp, DORQ_REG_NORM_CID_OFST);
-		if (val == 0x7)
-			REG_WR(bp, DORQ_REG_NORM_CID_OFST, 0);
-		bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_UNDI);
-
 		if (val == 0x7) {
 			u32 reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
 			/* save our func */
@@ -6920,6 +6916,9 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 			u32 swap_en;
 			u32 swap_val;
 
+			/* clear the UNDI indication */
+			REG_WR(bp, DORQ_REG_NORM_CID_OFST, 0);
+
 			BNX2X_DEV_INFO("UNDI is active! reset device\n");
 
 			/* try unload UNDI on port 0 */
@@ -6945,6 +6944,9 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 				bnx2x_fw_command(bp, reset_code);
 			}
 
+			/* now it's safe to release the lock */
+			bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_UNDI);
+
 			REG_WR(bp, (BP_PORT(bp) ? HC_REG_CONFIG_1 :
 				    HC_REG_CONFIG_0), 0x1000);
 
@@ -6989,7 +6991,9 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 			bp->fw_seq =
 			       (SHMEM_RD(bp, func_mb[bp->func].drv_mb_header) &
 				DRV_MSG_SEQ_NUMBER_MASK);
-		}
+
+		} else
+			bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_UNDI);
 	}
 }
 
-- 
1.5.4.3




