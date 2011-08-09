From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net 3/5] bnx2x: prevent race between undi_unload and
 load flows
Date: Tue, 9 Aug 2011 16:09:52 +0300
Message-ID: <1312895392.21856.2.camel@lb-tlvb-dmitry>
Reply-To: dmitry@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Vladislav Zolotarov" <vladz@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2861 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751998Ab1HINOU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Aug 2011 09:14:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_main.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 1507091..1f5467f 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -5798,6 +5798,12 @@ static int bnx2x_init_hw_common(struct bnx2x *bp)
 
 	DP(BNX2X_MSG_MCP, "starting common init  func %d\n", BP_ABS_FUNC(bp));
 
+	/*
+	 * take the UNDI lock to protect undi_unload flow from accessing
+	 * registers while we're resetting the chip
+	 */
+	bnx2x_acquire_hw_lock(bp, HW_LOCK_RESOURCE_UNDI);
+
 	bnx2x_reset_common(bp);
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET, 0xffffffff);
 
@@ -5808,6 +5814,8 @@ static int bnx2x_init_hw_common(struct bnx2x *bp)
 	}
 	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET, val);
 
+	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_UNDI);
+
 	bnx2x_init_block(bp, BLOCK_MISC, PHASE_COMMON);
 
 	if (!CHIP_IS_E1x(bp)) {
-- 
1.7.2.2




