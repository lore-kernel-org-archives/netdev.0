From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.30 2/4] cxgb3: fix workqueue flush issues
Date: Fri, 17 Apr 2009 15:21:17 -0700
Message-ID: <20090417222117.8504.11164.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7088 "EHLO
	stargate.chelsio.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756085AbZDQXD3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 19:03:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

The fatal error task can be scheduled while processing an offload packet
in NAPI context when the connection handle is bogus. this can race
with the ports being brought down and the cxgb3 workqueue being flushed.
Stop napi processing before flushing the work queue.

The ULP drivers (iSCSI, iWARP) might also schedule a task on keventd_wk 
while releasing a connection handle (cxgb3_offload.c::cxgb3_queue_tid_release()).
The driver however does not flush any work on keventd_wq while being unloaded. 
This patch also fixes this.

Also call cancel_delayed_work_sync in place of the the deprecated
cancel_rearming_delayed_workqueue.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 9fdfe0b..99b5032 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1117,8 +1117,8 @@ static void cxgb_down(struct adapter *adapter)
 	spin_unlock_irq(&adapter->work_lock);
 
 	free_irq_resources(adapter);
-	flush_workqueue(cxgb3_wq);	/* wait for external IRQ handler */
 	quiesce_rx(adapter);
+	flush_workqueue(cxgb3_wq);	/* wait for external IRQ handler */
 }
 
 static void schedule_chk_task(struct adapter *adap)
@@ -1187,6 +1187,9 @@ static int offload_close(struct t3cdev *tdev)
 
 	sysfs_remove_group(&tdev->lldev->dev.kobj, &offload_attr_group);
 
+	/* Flush work scheduled while releasing TIDs */
+	flush_scheduled_work();
+
 	tdev->lldev = NULL;
 	cxgb3_set_dummy_ops(tdev);
 	t3_tp_set_offload_mode(adapter, 0);
@@ -1247,8 +1250,7 @@ static int cxgb_close(struct net_device *dev)
 	spin_unlock_irq(&adapter->work_lock);
 
 	if (!(adapter->open_device_map & PORT_MASK))
-		cancel_rearming_delayed_workqueue(cxgb3_wq,
-						  &adapter->adap_check_task);
+		cancel_delayed_work_sync(&adapter->adap_check_task);
 
 	if (!adapter->open_device_map)
 		cxgb_down(adapter);

