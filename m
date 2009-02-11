From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 2/7] qlge: bugfix: Fix fatal error recovery hang.
Date: Wed, 11 Feb 2009 05:58:32 -0800
Message-ID: <1234360717-32194-2-git-send-email-ron.mercer@qlogic.com>
References: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:50248 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751774AbZBKOBQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Feb 2009 09:01:16 -0500
In-Reply-To: <1234360717-32194-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index 27c5e4d..69f7d05 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -1511,6 +1511,11 @@ void ql_queue_asic_error(struct ql_adapter *qdev)
 	netif_stop_queue(qdev->ndev);
 	netif_carrier_off(qdev->ndev);
 	ql_disable_interrupts(qdev);
+	/* Clear adapter up bit to signal the recovery
+	 * process that it shouldn't kill the reset worker
+	 * thread
+	 */
+	clear_bit(QL_ADAPTER_UP, &qdev->flags);
 	queue_delayed_work(qdev->workqueue, &qdev->asic_reset_work, 0);
 }
 
@@ -3100,7 +3105,11 @@ static int ql_adapter_down(struct ql_adapter *qdev)
 	netif_stop_queue(ndev);
 	netif_carrier_off(ndev);
 
-	cancel_delayed_work_sync(&qdev->asic_reset_work);
+	/* Don't kill the reset worker thread if we
+	 * are in the process of recovery.
+	 */
+	if (test_bit(QL_ADAPTER_UP, &qdev->flags))
+		cancel_delayed_work_sync(&qdev->asic_reset_work);
 	cancel_delayed_work_sync(&qdev->mpi_reset_work);
 	cancel_delayed_work_sync(&qdev->mpi_work);
 
@@ -3501,7 +3510,7 @@ static int qlge_set_mac_address(struct net_device *ndev, void *p)
 static void qlge_tx_timeout(struct net_device *ndev)
 {
 	struct ql_adapter *qdev = (struct ql_adapter *)netdev_priv(ndev);
-	queue_delayed_work(qdev->workqueue, &qdev->asic_reset_work, 0);
+	ql_queue_asic_error(qdev);
 }
 
 static void ql_asic_reset_work(struct work_struct *work)
-- 
1.6.0.2

