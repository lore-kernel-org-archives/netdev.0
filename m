From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 5/8] bnx2x: Adding FW mailbox mutex
Date: Thu, 15 Oct 2009 08:48:40 +0200
Message-ID: <1255589320.25030.75.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3324 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934591AbZJOGtb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Oct 2009 02:49:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DCC commands are not protected with the RTNL lock, so a mutex should be added

Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |    3 +++
 drivers/net/bnx2x_main.c |    7 +++++--
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index 185a6ba..c3b32f7 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -1023,6 +1023,9 @@ struct bnx2x {
 	/* used to synchronize dmae accesses */
 	struct mutex		dmae_mutex;
 
+	/* used to protect the FW mail box */
+	struct mutex		fw_mb_mutex;
+
 	/* used to synchronize stats collecting */
 	int			stats_state;
 	/* used by dmae command loader */
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index e7b3b27..7c5c300 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -2528,6 +2528,7 @@ u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
 	u32 cnt = 1;
 	u8 delay = CHIP_REV_IS_SLOW(bp) ? 100 : 10;
 
+	mutex_lock(&bp->fw_mb_mutex);
 	SHMEM_WR(bp, func_mb[func].drv_mb_header, (command | seq));
 	DP(BNX2X_MSG_MCP, "wrote command (%x) to FW MB\n", (command | seq));
 
@@ -2537,8 +2538,8 @@ u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
 
 		rc = SHMEM_RD(bp, func_mb[func].fw_mb_header);
 
-		/* Give the FW up to 2 second (200*10ms) */
-	} while ((seq != (rc & FW_MSG_SEQ_NUMBER_MASK)) && (cnt++ < 200));
+		/* Give the FW up to 5 second (500*10ms) */
+	} while ((seq != (rc & FW_MSG_SEQ_NUMBER_MASK)) && (cnt++ < 500));
 
 	DP(BNX2X_MSG_MCP, "[after %d ms] read (%x) seq is (%x) from FW MB\n",
 	   cnt*delay, rc, seq);
@@ -2552,6 +2553,7 @@ u32 bnx2x_fw_command(struct bnx2x *bp, u32 command)
 		bnx2x_fw_dump(bp);
 		rc = 0;
 	}
+	mutex_unlock(&bp->fw_mb_mutex);
 
 	return rc;
 }
@@ -8956,6 +8958,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *bp)
 	smp_wmb(); /* Ensure that bp->intr_sem update is SMP-safe */
 
 	mutex_init(&bp->port.phy_mutex);
+	mutex_init(&bp->fw_mb_mutex);
 #ifdef BCM_CNIC
 	mutex_init(&bp->cnic_mutex);
 #endif
-- 
1.5.4.3




