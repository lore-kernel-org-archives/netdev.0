From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 02/12] qlge: Remove debug junk from asic reset logic.
Date: Mon,  9 Mar 2009 13:59:18 -0700
Message-ID: <1236632368-22079-3-git-send-email-ron.mercer@qlogic.com>
References: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:18643 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753560AbZCIVDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 17:03:07 -0400
In-Reply-To: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   25 ++++++-------------------
 1 files changed, 6 insertions(+), 19 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index ed7138d..bc04aeb 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3129,36 +3129,23 @@ static int ql_adapter_initialize(struct ql_adapter *qdev)
 static int ql_adapter_reset(struct ql_adapter *qdev)
 {
 	u32 value;
-	int max_wait_time;
 	int status = 0;
-	int resetCnt = 0;
+	unsigned long end_jiffies = jiffies +
+		max((unsigned long)1, usecs_to_jiffies(30));
 
-#define MAX_RESET_CNT   1
-issueReset:
-	resetCnt++;
-	QPRINTK(qdev, IFDOWN, DEBUG, "Issue soft reset to chip.\n");
 	ql_write32(qdev, RST_FO, (RST_FO_FR << 16) | RST_FO_FR);
-	/* Wait for reset to complete. */
-	max_wait_time = 3;
-	QPRINTK(qdev, IFDOWN, DEBUG, "Wait %d seconds for reset to complete.\n",
-		max_wait_time);
+
 	do {
 		value = ql_read32(qdev, RST_FO);
 		if ((value & RST_FO_FR) == 0)
 			break;
+		cpu_relax();
+	} while (time_before(jiffies, end_jiffies));
 
-		ssleep(1);
-	} while ((--max_wait_time));
 	if (value & RST_FO_FR) {
 		QPRINTK(qdev, IFDOWN, ERR,
-			"Stuck in SoftReset:  FSC_SR:0x%08x\n", value);
-		if (resetCnt < MAX_RESET_CNT)
-			goto issueReset;
-	}
-	if (max_wait_time == 0) {
-		status = -ETIMEDOUT;
-		QPRINTK(qdev, IFDOWN, ERR,
 			"ETIMEOUT!!! errored out of resetting the chip!\n");
+		status = -ETIMEDOUT;
 	}
 
 	return status;
-- 
1.6.0.2

