From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-next PATCH 01/12] qlge: Move reset logic into asic_reset_worker func.
Date: Mon,  9 Mar 2009 13:59:17 -0700
Message-ID: <1236632368-22079-2-git-send-email-ron.mercer@qlogic.com>
References: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:18643 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753500AbZCIVDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Mar 2009 17:03:06 -0400
In-Reply-To: <1236632368-22079-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Get rid of extraneous ql_cycle_adapter.  It's only called from the one
place.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |   41 ++++++++++++++++++-----------------------
 1 files changed, 18 insertions(+), 23 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index d800ff4..ed7138d 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3263,28 +3263,6 @@ err_init:
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
@@ -3617,7 +3595,24 @@ static void ql_asic_reset_work(struct work_struct *work)
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
+
+	return;
+error:
+	QPRINTK(qdev, IFUP, ALERT,
+		"Driver up/down cycle failed, closing device\n");
+	rtnl_lock();
+	set_bit(QL_ADAPTER_UP, &qdev->flags);
+	dev_close(qdev->ndev);
+	rtnl_unlock();
 }
 
 static struct nic_operations qla8012_nic_ops = {
-- 
1.6.0.2

