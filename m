From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 12/21] [next] qlge: Clean up chip reset path.
Date: Fri, 23 Jan 2009 07:16:30 -0800
Message-ID: <1232723799-8620-12-git-send-email-ron.mercer@qlogic.com>
References: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:48587 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754382AbZAWPR4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2009 10:17:56 -0500
In-Reply-To: <20090123151513.GA8526@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of ql_cycle_adapter() as it's small and only called
from one place.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   45 ++++++++++++++++++-----------------------
 1 files changed, 20 insertions(+), 25 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 176d7e2..023dfe9 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1544,6 +1544,7 @@ void ql_queue_asic_error(struct ql_adapter *qdev)
 {
 	ql_link_off(qdev);
 	ql_disable_interrupts(qdev);
+	clear_bit(QL_ADAPTER_UP, &qdev->flags);
 	queue_delayed_work(qdev->workqueue, &qdev->asic_reset_work, 0);
 }
 
@@ -3094,7 +3095,8 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 
 	ql_link_off(qdev);
 
-	cancel_delayed_work_sync(&qdev->asic_reset_work);
+	if (test_bit(QL_ADAPTER_UP, &qdev->flags))
+		cancel_delayed_work_sync(&qdev->asic_reset_work);
 	cancel_delayed_work_sync(&qdev->mpi_reset_work);
 	cancel_delayed_work_sync(&qdev->mpi_work);
 
@@ -3154,28 +3156,6 @@ err_init:
 	return err;
 }
 
-static int ql_cycle_adapter(struct ql_adapter *qdev)
-{
-	int status;
-
-	status = ql_adapter_down(qdev);
-	if (status)
-		goto error;
-
-	status = ql_adapter_up(qdev);
-	if (status)
-		goto error;
-
-	return status;
-error:
-	QPRINTK(qdev, IFUP, ALERT,
-		"Driver up/down cycle failed, closing device\n");
-	rtnl_lock();
-	dev_close(qdev->ndev);
-	rtnl_unlock();
-	return status;
-}
-
 static void ql_release_adapter_resources(struct ql_adapter *qdev)
 {
 	ql_free_mem_resources(qdev);
@@ -3500,14 +3480,29 @@ static int qlge_set_mac_address(struct net_device *ndev, void *p)
 static void qlge_tx_timeout(struct net_device *ndev)
 {
 	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
-	queue_delayed_work(qdev->workqueue, &qdev->asic_reset_work, 0);
+	ql_queue_asic_error(qdev);
 }
 
 static void ql_asic_reset_work(struct work_struct *work)
 {
 	struct ql_adapter *qdev =
 	    container_of(work, struct ql_adapter, asic_reset_work.work);
-	ql_cycle_adapter(qdev);
+	int status;
+
+	status = ql_adapter_down(qdev);
+	if (status)
+		goto error;
+	status = ql_adapter_up(qdev);
+	if (status)
+		goto error;
+	return;
+error:
+	QPRINTK(qdev, IFUP, ALERT,
+		"Driver up/down cycle failed, closing device\n");
+	rtnl_lock();
+	set_bit(QL_ADAPTER_UP, &qdev->flags);
+	dev_close(qdev->ndev);
+	rtnl_unlock();
 }
 
 static void ql_get_board_info(struct ql_adapter *qdev)
-- 
1.6.0.2

