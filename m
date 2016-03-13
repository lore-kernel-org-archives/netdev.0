From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] bnx2x: don't wait for Tx completion on recovery
Date: Sun, 13 Mar 2016 21:21:48 +0200
Message-ID: <1457896908-13476-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:33118 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752163AbcCMTV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2016 15:21:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When driver has hit a parity event, HW can no longer write to host memory.
As a result, Tx completions cannot be written to the host SB memory, and
waiting for Tx completions eventually timeout.
As driver is willing to delay as much as 1-2 seconds per Tx queue for its
draining and this delay is sequential, the time to recover might greatly 
lengthen needlessly in case the recovery is done under multi-connection
traffic.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
Hi Dave,

Wasn't sure whether to prepare this for net/net-next; But as it wasn't
a bug-fix by definition, I took the safer approach.

Please consider applying this to `net-next'.

Thanks,
Yuval
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index a949783..0a9108c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3042,8 +3042,12 @@ int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode, bool keep_link)
 		bnx2x_save_statistics(bp);
 	}
 
-	/* wait till consumers catch up with producers in all queues */
-	bnx2x_drain_tx_queues(bp);
+	/* wait till consumers catch up with producers in all queues.
+	 * If we're recovering, FW can't write to host so no reason
+	 * to wait for the queues to complete all Tx.
+	 */
+	if (unload_mode != UNLOAD_RECOVERY)
+		bnx2x_drain_tx_queues(bp);
 
 	/* if VF indicate to PF this function is going down (PF will delete sp
 	 * elements and clear initializations
-- 
1.9.3
