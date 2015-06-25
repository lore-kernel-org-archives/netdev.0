From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 3/9] bnx2x: Prevent false warning when accessing MACs
Date: Thu, 25 Jun 2015 15:19:23 +0300
Message-ID: <1435234769-5625-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:39850 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751662AbbFYMUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2015 08:20:03 -0400
In-Reply-To: <1435234769-5625-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Each time a flow finishes reads from the classification shadow
configuration in the driver, that flow would check for pending commands
and pass them to FW if possible.
In case there's already a completion pending command, I.e., a ramrod
that has been sent to the FW and is yet to be completed while said flow
tries to configure the pending command we would get a false error message
in logs [and panic if SOE was used for driver compilation] since the
command could not have been completed.

This prevents said print [and panic]; The pending command will be sent by
the time the completion of the current sent command would arrive.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 07cdf9b..4ad415a 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -424,7 +424,7 @@ static void __bnx2x_vlan_mac_h_exec_pending(struct bnx2x *bp,
 	o->head_exe_request = false;
 	o->saved_ramrod_flags = 0;
 	rc = bnx2x_exe_queue_step(bp, &o->exe_queue, &ramrod_flags);
-	if (rc != 0) {
+	if ((rc != 0) && (rc != 1)) {
 		BNX2X_ERR("execution of pending commands failed with rc %d\n",
 			  rc);
 #ifdef BNX2X_STOP_ON_ERROR
-- 
1.9.3
