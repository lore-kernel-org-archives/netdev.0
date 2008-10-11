From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 4/6] [NET-NEXT]qlge: Cleanup chip reset path.
Date: Sat, 11 Oct 2008 10:17:11 -0700
Message-ID: <1223745433-26440-4-git-send-email-ron.mercer@qlogic.com>
References: <20081011171614.GA26384@susedev.qlogic.org>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:13301 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760572AbYJKRRR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2008 13:17:17 -0400
In-Reply-To: <20081011171614.GA26384@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   41 +++++++++++++++++------------------------
 1 files changed, 17 insertions(+), 24 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index c257546..1788e5c 100755
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3141,28 +3141,6 @@ err_init:
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
@@ -3471,14 +3449,29 @@ static int qlge_set_mac_address(struct net_device *ndev, void *p)
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
+
+	status = ql_adapter_up(qdev);
+	if (status)
+		goto error;
+	return;
+error:
+	QPRINTK(qdev, IFUP, ALERT,
+		"Driver up/down cycle failed, closing device\n");
+	rtnl_lock();
+	dev_close(qdev->ndev);
+	rtnl_unlock();
 }
 
 static void ql_get_board_info(struct ql_adapter *qdev)
-- 
1.6.0

