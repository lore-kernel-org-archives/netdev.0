From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 1/3] qlge:Fix crash caused by mailbox execution on wedged chip.
Date: Thu, 23 Jun 2011 10:52:22 -0700
Message-ID: <1308851544-25719-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <ron.mercer@qlogic.com>,
	<jitendra.kalsaria@qlogic.com>, <ameen.rahman@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe006.messaging.microsoft.com ([216.32.180.16]:49039
	"EHLO VA3EHSOBE007.bigfish.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933366Ab1FWSLe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jun 2011 14:11:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

When we are in a recover process from a chip fatal error,
	driver should skip over execution of mailbox commands during
	resetting chip.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge.h      |    1 +
 drivers/net/qlge/qlge_main.c |   20 +++++++++++++++-----
 2 files changed, 16 insertions(+), 5 deletions(-)

diff --git a/drivers/net/qlge/qlge.h b/drivers/net/qlge/qlge.h
index d328507..b2c8612 100644
--- a/drivers/net/qlge/qlge.h
+++ b/drivers/net/qlge/qlge.h
@@ -1996,6 +1996,7 @@ enum {
 	QL_LB_LINK_UP = 10,
 	QL_FRC_COREDUMP = 11,
 	QL_EEH_FATAL = 12,
+	QL_ASIC_RECOVERY = 14, /* We are in ascic recovery. */
 };
 
 /* link_status bit definitions */
diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 930ae45..4fbefcf 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -2152,6 +2152,10 @@ void ql_queue_asic_error(struct ql_adapter *qdev)
 	 * thread
 	 */
 	clear_bit(QL_ADAPTER_UP, &qdev->flags);
+	/* Set asic recovery bit to indicate reset process that we are
+	 * in fatal error recovery process rather than normal close
+	 */
+	set_bit(QL_ASIC_RECOVERY, &qdev->flags);
 	queue_delayed_work(qdev->workqueue, &qdev->asic_reset_work, 0);
 }
 
@@ -3818,11 +3822,17 @@ static int ql_adapter_reset(struct ql_adapter *qdev)
 	end_jiffies = jiffies +
 		max((unsigned long)1, usecs_to_jiffies(30));
 
-	/* Stop management traffic. */
-	ql_mb_set_mgmnt_traffic_ctl(qdev, MB_SET_MPI_TFK_STOP);
+	/* Check if bit is set then skip the mailbox command and
+	 * clear the bit, else we are in normal reset process.
+	 */
+	if (!test_bit(QL_ASIC_RECOVERY, &qdev->flags)) {
+		/* Stop management traffic. */
+		ql_mb_set_mgmnt_traffic_ctl(qdev, MB_SET_MPI_TFK_STOP);
 
-	/* Wait for the NIC and MGMNT FIFOs to empty. */
-	ql_wait_fifo_empty(qdev);
+		/* Wait for the NIC and MGMNT FIFOs to empty. */
+		ql_wait_fifo_empty(qdev);
+	} else
+		clear_bit(QL_ASIC_RECOVERY, &qdev->flags);
 
 	ql_write32(qdev, RST_FO, (RST_FO_FR << 16) | RST_FO_FR);
 
-- 
1.6.0.2


