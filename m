From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH net-next 3/6] bnx2: Add ack parameter to bnx2_fw_sync().
Date: Thu, 10 Jul 2008 18:29:12 -0700
Message-ID: <1215739755-5495-3-git-send-email-mchan@broadcom.com>
References: <1215739755-5495-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1734 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756826AbYGKB0Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Jul 2008 21:26:24 -0400
In-Reply-To: <1215739755-5495-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ack=1 means wait for firmware acknowledgement, and ack=0
means don't wait.  All current callers will set it to 1.

In the next patch, new calls will set ack=0.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/bnx2.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 989d4b6..4dfd439 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1491,7 +1491,7 @@ bnx2_phy_get_pause_adv(struct bnx2 *bp)
 	return adv;
 }
 
-static int bnx2_fw_sync(struct bnx2 *, u32, int);
+static int bnx2_fw_sync(struct bnx2 *, u32, int, int);
 
 static int
 bnx2_setup_remote_phy(struct bnx2 *bp, u8 port)
@@ -1544,7 +1544,7 @@ bnx2_setup_remote_phy(struct bnx2 *bp, u8 port)
 	bnx2_shmem_wr(bp, BNX2_DRV_MB_ARG0, speed_arg);
 
 	spin_unlock_bh(&bp->phy_lock);
-	bnx2_fw_sync(bp, BNX2_DRV_MSG_CODE_CMD_SET_LINK, 0);
+	bnx2_fw_sync(bp, BNX2_DRV_MSG_CODE_CMD_SET_LINK, 1, 0);
 	spin_lock_bh(&bp->phy_lock);
 
 	return 0;
@@ -2262,7 +2262,7 @@ bnx2_set_phy_loopback(struct bnx2 *bp)
 }
 
 static int
-bnx2_fw_sync(struct bnx2 *bp, u32 msg_data, int silent)
+bnx2_fw_sync(struct bnx2 *bp, u32 msg_data, int ack, int silent)
 {
 	int i;
 	u32 val;
@@ -2272,6 +2272,9 @@ bnx2_fw_sync(struct bnx2 *bp, u32 msg_data, int silent)
 
 	bnx2_shmem_wr(bp, BNX2_DRV_MB, msg_data);
 
+	if (!ack)
+		return 0;
+
 	/* wait for an acknowledgement. */
 	for (i = 0; i < (FW_ACK_TIME_OUT_MS / 10); i++) {
 		msleep(10);
@@ -3610,7 +3613,8 @@ bnx2_set_power_state(struct bnx2 *bp, pci_power_t state)
 		}
 
 		if (!(bp->flags & BNX2_FLAG_NO_WOL))
-			bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT3 | wol_msg, 0);
+			bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT3 | wol_msg,
+				     1, 0);
 
 		pmcsr &= ~PCI_PM_CTRL_STATE_MASK;
 		if ((CHIP_ID(bp) == CHIP_ID_5706_A0) ||
@@ -4309,7 +4313,7 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 	udelay(5);
 
 	/* Wait for the firmware to tell us it is ok to issue a reset. */
-	bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT0 | reset_code, 1);
+	bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT0 | reset_code, 1, 1);
 
 	/* Deposit a driver reset signature so the firmware knows that
 	 * this is a soft reset. */
@@ -4370,7 +4374,7 @@ bnx2_reset_chip(struct bnx2 *bp, u32 reset_code)
 	}
 
 	/* Wait for the firmware to finish its initialization. */
-	rc = bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT1 | reset_code, 0);
+	rc = bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT1 | reset_code, 1, 0);
 	if (rc)
 		return rc;
 
@@ -4596,7 +4600,7 @@ bnx2_init_chip(struct bnx2 *bp)
 		REG_WR(bp, BNX2_MISC_NEW_CORE_CTL, val);
 	}
 	rc = bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT2 | BNX2_DRV_MSG_CODE_RESET,
-			  0);
+			  1, 0);
 
 	REG_WR(bp, BNX2_MISC_ENABLE_SET_BITS, BNX2_MISC_ENABLE_DEFAULT);
 	REG_RD(bp, BNX2_MISC_ENABLE_SET_BITS);
-- 
1.5.5.GIT


