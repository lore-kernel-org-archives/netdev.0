From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [PATCH 3/9] bnx2x: Minimize lock time
Date: Mon, 25 Aug 2008 17:24:35 +0300
Message-ID: <1219674275.19456.29.camel@lb-tlvb-eliezer>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3159 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753629AbYHYOZw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Aug 2008 10:25:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Minimize lock time
After iSCSI boot, the HW lock should only protect the flag so only the
first function will reset the chip and not then entire chip reset
process

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x_main.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 2e207b8..9972d0c 100755
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -6824,6 +6824,10 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 		 */
 		bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_UNDI);
 		val = REG_RD(bp, DORQ_REG_NORM_CID_OFST);
+		if (val == 0x7)
+			REG_WR(bp, DORQ_REG_NORM_CID_OFST, 0);
+		bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_UNDI);
+
 		if (val == 0x7) {
 			u32 reset_code = DRV_MSG_CODE_UNLOAD_REQ_WOL_DIS;
 			/* save our func */
@@ -6901,7 +6905,6 @@ static void __devinit bnx2x_undi_unload(struct bnx2x *bp)
 			       (SHMEM_RD(bp, func_mb[bp->func].drv_mb_header) &
 				DRV_MSG_SEQ_NUMBER_MASK);
 		}
-		bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_UNDI);
 	}
 }
 
-- 
1.5.3.2




