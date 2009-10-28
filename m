From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 2/2] qlge: Fix firmware mailbox command timeout.
Date: Wed, 28 Oct 2009 11:39:21 -0700
Message-ID: <1256755161-29606-3-git-send-email-ron.mercer@qlogic.com>
References: <1256755161-29606-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:53983 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751449AbZJ1Spd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 14:45:33 -0400
In-Reply-To: <1256755161-29606-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The mailbox command process would only process a maximum of 5 unrelated
firmware events while waiting for it's command completion status.
It should process an unlimited number of events while waiting for a maximum of 5 seconds.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h     |    1 +
 drivers/net/qlge/qlge_mpi.c |   23 ++++++++++++-----------
 2 files changed, 13 insertions(+), 11 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index e7285f0..c2383ad 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -95,6 +95,7 @@ enum {
 
 	/* Misc. stuff */
 	MAILBOX_COUNT = 16,
+	MAILBOX_TIMEOUT = 5,
 
 	PROC_ADDR_RDY = (1 << 31),
 	PROC_ADDR_R = (1 << 30),
diff --git a/drivers/net/qlge/qlge_mpi.c b/drivers/net/qlge/qlge_mpi.c
index 99e58e3..bcf13c9 100644
--- a/drivers/net/qlge/qlge_mpi.c
+++ b/drivers/net/qlge/qlge_mpi.c
@@ -470,7 +470,8 @@ end:
  */
 static int ql_mailbox_command(struct ql_adapter *qdev, struct mbox_params *mbcp)
 {
-	int status, count;
+	int status;
+	unsigned long count;
 
 
 	/* Begin polled mode for MPI */
@@ -491,9 +492,9 @@ static int ql_mailbox_command(struct ql_adapter *qdev, struct mbox_params *mbcp)
 	/* Wait for the command to complete. We loop
 	 * here because some AEN might arrive while
 	 * we're waiting for the mailbox command to
-	 * complete. If more than 5 arrive then we can
+	 * complete. If more than 5 seconds expire we can
 	 * assume something is wrong. */
-	count = 5;
+	count = jiffies + HZ * MAILBOX_TIMEOUT;
 	do {
 		/* Wait for the interrupt to come in. */
 		status = ql_wait_mbx_cmd_cmplt(qdev);
@@ -517,15 +518,15 @@ static int ql_mailbox_command(struct ql_adapter *qdev, struct mbox_params *mbcp)
 					MB_CMD_STS_GOOD) ||
 			((mbcp->mbox_out[0] & 0x0000f000) ==
 					MB_CMD_STS_INTRMDT))
-			break;
-	} while (--count);
+			goto done;
+	} while (time_before(jiffies, count));
 
-	if (!count) {
-		QPRINTK(qdev, DRV, ERR,
-			"Timed out waiting for mailbox complete.\n");
-		status = -ETIMEDOUT;
-		goto end;
-	}
+	QPRINTK(qdev, DRV, ERR,
+		"Timed out waiting for mailbox complete.\n");
+	status = -ETIMEDOUT;
+	goto end;
+
+done:
 
 	/* Now we can clear the interrupt condition
 	 * and look at our status.
-- 
1.6.0.2

