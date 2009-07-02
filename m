From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 2/8] qlge: Clear frame to queue routing before reset.
Date: Thu,  2 Jul 2009 09:06:07 -0700
Message-ID: <1246550773-18417-2-git-send-email-ron.mercer@qlogic.com>
References: <1246550773-18417-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:26904 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752089AbZGBQLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jul 2009 12:11:32 -0400
In-Reply-To: <1246550773-18417-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Not clearing the routing bits can cause frames to erroneously get routed to
management processor.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   41 ++++++++++++++++++++++++++++++++---------
 1 files changed, 32 insertions(+), 9 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 7f37267..1da831e 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3040,25 +3040,40 @@ static int ql_start_rss(struct ql_adapter *qdev)
 	return status;
 }
 
-/* Initialize the frame-to-queue routing. */
-static int ql_route_initialize(struct ql_adapter *qdev)
+static int ql_clear_routing_entries(struct ql_adapter *qdev)
 {
-	int status = 0;
-	int i;
+	int i, status = 0;
 
 	status = ql_sem_spinlock(qdev, SEM_RT_IDX_MASK);
 	if (status)
 		return status;
-
 	/* Clear all the entries in the routing table. */
 	for (i = 0; i < 16; i++) {
 		status = ql_set_routing_reg(qdev, i, 0, 0);
 		if (status) {
 			QPRINTK(qdev, IFUP, ERR,
-				"Failed to init routing register for CAM packets.\n");
-			goto exit;
+				"Failed to init routing register for CAM "
+				"packets.\n");
+			break;
 		}
 	}
+	ql_sem_unlock(qdev, SEM_RT_IDX_MASK);
+	return status;
+}
+
+/* Initialize the frame-to-queue routing. */
+static int ql_route_initialize(struct ql_adapter *qdev)
+{
+	int status = 0;
+
+	status = ql_sem_spinlock(qdev, SEM_RT_IDX_MASK);
+	if (status)
+		return status;
+
+	/* Clear all the entries in the routing table. */
+	status = ql_clear_routing_entries(qdev);
+	if (status)
+		goto exit;
 
 	status = ql_set_routing_reg(qdev, RT_IDX_ALL_ERR_SLOT, RT_IDX_ERR, 1);
 	if (status) {
@@ -3211,9 +3226,17 @@ static int ql_adapter_reset(struct ql_adapter *qdev)
 {
 	u32 value;
 	int status = 0;
-	unsigned long end_jiffies = jiffies +
-		max((unsigned long)1, usecs_to_jiffies(30));
+	unsigned long end_jiffies;
 
+	/* Clear all the entries in the routing table. */
+	status = ql_clear_routing_entries(qdev);
+	if (status) {
+		QPRINTK(qdev, IFUP, ERR, "Failed to clear routing bits.\n");
+		return status;
+	}
+
+	end_jiffies = jiffies +
+		max((unsigned long)1, usecs_to_jiffies(30));
 	ql_write32(qdev, RST_FO, (RST_FO_FR << 16) | RST_FO_FR);
 
 	do {
-- 
1.6.0.2

