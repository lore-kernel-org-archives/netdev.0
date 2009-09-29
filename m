From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 2/5] qlge: Fix out of sync hardware semaphore.
Date: Tue, 29 Sep 2009 11:39:22 -0700
Message-ID: <1254249565-16381-3-git-send-email-ron.mercer@qlogic.com>
References: <1254249565-16381-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:8737 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753448AbZI2SpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 14:45:15 -0400
In-Reply-To: <1254249565-16381-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ql_clear_routing_entries() takes/gives it's own hardware semaphore since
it is called from more than one place.  ql_route_initialize() should
make this call and THEN take it's own semaphore before doing it's work.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 2205292..e4b756d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3142,14 +3142,14 @@ static int ql_route_initialize(struct ql_adapter *qdev)
 {
 	int status = 0;
 
-	status = ql_sem_spinlock(qdev, SEM_RT_IDX_MASK);
+	/* Clear all the entries in the routing table. */
+	status = ql_clear_routing_entries(qdev);
 	if (status)
 		return status;
 
-	/* Clear all the entries in the routing table. */
-	status = ql_clear_routing_entries(qdev);
+	status = ql_sem_spinlock(qdev, SEM_RT_IDX_MASK);
 	if (status)
-		goto exit;
+		return status;
 
 	status = ql_set_routing_reg(qdev, RT_IDX_ALL_ERR_SLOT, RT_IDX_ERR, 1);
 	if (status) {
-- 
1.6.0.2

