From: "Vlad Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net] bnx2x: Prevent restarting Tx during
 bnx2x_nic_unload
Date: Tue, 2 Aug 2011 10:52:37 +0300
Message-ID: <201108021052.37368.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:3518 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751946Ab1HBHxf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Aug 2011 03:53:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tx queues were stopped before  bp->state was changed to a value different 
from BNX2X_STATE_OPEN, which allowed the bnx2x_tx_int() called from the 
NAPI context to re-enable it. This then allowed the netdev->ndo_start_xmit() 
to be called in the middle of the function reset and rings freeing. 

This patch changes bp->state to a value different 
from BNX2X_STATE_OPEN BEFORE disabling the Tx queues in order to restore the
broken protection against the above race in the bnx2x_tx_int().

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index 5b0dba6..d724a18 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1989,14 +1989,20 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
 		return -EINVAL;
 	}
 
+	/*
+	 * It's important to set the bp->state to the value different from
+	 * BNX2X_STATE_OPEN and only then stop the Tx. Otherwise bnx2x_tx_int()
+	 * may restart the Tx from the NAPI context (see bnx2x_tx_int()).
+	 */
+	bp->state = BNX2X_STATE_CLOSING_WAIT4_HALT;
+	smp_mb();
+
 	/* Stop Tx */
 	bnx2x_tx_disable(bp);
 
 #ifdef BCM_CNIC
 	bnx2x_cnic_notify(bp, CNIC_CTL_STOP_CMD);
 #endif
-	bp->state = BNX2X_STATE_CLOSING_WAIT4_HALT;
-	smp_mb();
 
 	bp->rx_mode = BNX2X_RX_MODE_NONE;
 
-- 
1.7.4.1


