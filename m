From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [net-2.6 PATCH 4/5] qlge: Protect reset recovery with rtnl_lock().
Date: Tue, 29 Sep 2009 11:39:24 -0700
Message-ID: <1254249565-16381-5-git-send-email-ron.mercer@qlogic.com>
References: <1254249565-16381-1-git-send-email-ron.mercer@qlogic.com>
Cc: netdev@vger.kernel.org, ron.mercer@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:8737 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753762AbZI2SpP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2009 14:45:15 -0400
In-Reply-To: <1254249565-16381-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the call to rtnl_lock() to before the internal call to
ql_adapter_down()/ql_adapter_up().  This prevents collisions that can
happen when recovering from an asic error.

Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.c
index b05300d..fbef305 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3703,7 +3703,7 @@ static void ql_asic_reset_work(struct work_struct *work)
 	struct ql_adapter *qdev =
 	    container_of(work, struct ql_adapter, asic_reset_work.work);
 	int status;
-
+	rtnl_lock();
 	status = ql_adapter_down(qdev);
 	if (status)
 		goto error;
@@ -3711,12 +3711,12 @@ static void ql_asic_reset_work(struct work_struct *work)
 	status = ql_adapter_up(qdev);
 	if (status)
 		goto error;
-
+	rtnl_unlock();
 	return;
 error:
 	QPRINTK(qdev, IFUP, ALERT,
 		"Driver up/down cycle failed, closing device\n");
-	rtnl_lock();
+
 	set_bit(QL_ADAPTER_UP, &qdev->flags);
 	dev_close(qdev->ndev);
 	rtnl_unlock();
-- 
1.6.0.2

