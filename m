From: Malahal Naineni <malahal@us.ibm.com>
Subject: [PATCH] qlge: call ql_core_dump() only if dump memory was allocated.
Date: Fri, 20 Sep 2013 10:30:31 -0500
Message-ID: <1379691031-28666-1-git-send-email-malahal@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:52137 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751737Ab3ITPaf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Sep 2013 11:30:35 -0400
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <malahal@us.ibm.com>;
	Fri, 20 Sep 2013 09:30:34 -0600
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id AA8AE3E40042
	for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 09:30:32 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r8KFUWLc295462
	for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 09:30:32 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r8KFUWYe018466
	for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 09:30:32 -0600
Received: from malahal (malahal.austin.ibm.com [9.41.105.170])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id r8KFUV5g018418
	for <netdev@vger.kernel.org>; Fri, 20 Sep 2013 09:30:32 -0600
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also changed a log message to indicate that memory was not allocated
instead of memory not available!
---
 drivers/net/ethernet/qlogic/qlge/qlge_dbg.c |  4 ++--
 drivers/net/ethernet/qlogic/qlge/qlge_mpi.c | 12 +++++++-----
 2 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c b/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
index 10093f0..6bc5db7 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_dbg.c
@@ -740,8 +740,8 @@ int ql_core_dump(struct ql_adapter *qdev, struct ql_mpi_coredump *mpi_coredump)
 	int i;
 
 	if (!mpi_coredump) {
-		netif_err(qdev, drv, qdev->ndev, "No memory available\n");
-		return -ENOMEM;
+		netif_err(qdev, drv, qdev->ndev, "No memory allocated\n");
+		return -EINVAL;
 	}
 
 	/* Try to get the spinlock, but dont worry if
diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c b/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c
index ff2bf8a..99a3e07 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_mpi.c
@@ -1274,11 +1274,13 @@ void ql_mpi_reset_work(struct work_struct *work)
 		return;
 	}
 
-	if (!ql_core_dump(qdev, qdev->mpi_coredump)) {
-		netif_err(qdev, drv, qdev->ndev, "Core is dumped!\n");
-		qdev->core_is_dumped = 1;
-		queue_delayed_work(qdev->workqueue,
-			&qdev->mpi_core_to_log, 5 * HZ);
+	if (qdev->mpi_coredump) {
+		if (!ql_core_dump(qdev, qdev->mpi_coredump)) {
+			netif_err(qdev, drv, qdev->ndev, "Core is dumped!\n");
+			qdev->core_is_dumped = 1;
+			queue_delayed_work(qdev->workqueue,
+				&qdev->mpi_core_to_log, 5 * HZ);
+		}
 	}
 	ql_soft_reset_mpi_risc(qdev);
 }
-- 
1.7.11.7
