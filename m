From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 5/9] iseries_veth: don't use flush_scheduled_work()
Date: Sun, 12 Dec 2010 16:53:01 +0100
Message-ID: <1292169185-10579-6-git-send-email-tj@kernel.org>
References: <1292169185-10579-1-git-send-email-tj@kernel.org>
Cc: Tejun Heo <tj@kernel.org>,
	Santiago Leon <santil@linux.vnet.ibm.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:56565 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753346Ab0LLPx2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 10:53:28 -0500
In-Reply-To: <1292169185-10579-1-git-send-email-tj@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

flush_scheduled_work() is on its way out.  Remove its usage from
iseries_veth.

* Cancelling a delayed work, queueing it for immediate execution if
  cancelled and then waiting for completion can be done by simply
  calling flush_delayed_work_sync().

* Explicitly cancel cnx->statemachine_wq on module unload.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Santiago Leon <santil@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org
---
 drivers/net/iseries_veth.c |   18 ++++--------------
 1 files changed, 4 insertions(+), 14 deletions(-)

diff --git a/drivers/net/iseries_veth.c b/drivers/net/iseries_veth.c
index 63ac531..9ece1fd 100644
--- a/drivers/net/iseries_veth.c
+++ b/drivers/net/iseries_veth.c
@@ -885,17 +885,8 @@ static void veth_stop_connection(struct veth_lpar_connection *cnx)
 	veth_kick_statemachine(cnx);
 	spin_unlock_irq(&cnx->lock);
 
-	/* There's a slim chance the reset code has just queued the
-	 * statemachine to run in five seconds. If so we need to cancel
-	 * that and requeue the work to run now. */
-	if (cancel_delayed_work(&cnx->statemachine_wq)) {
-		spin_lock_irq(&cnx->lock);
-		veth_kick_statemachine(cnx);
-		spin_unlock_irq(&cnx->lock);
-	}
-
-	/* Wait for the state machine to run. */
-	flush_scheduled_work();
+	/* ensure the statemachine runs now and waits for its completion */
+	flush_delayed_work_sync(&cnx->statemachine_wq);
 }
 
 static void veth_destroy_connection(struct veth_lpar_connection *cnx)
@@ -1653,15 +1644,14 @@ static void __exit veth_module_cleanup(void)
 	/* Disconnect our "irq" to stop events coming from the Hypervisor. */
 	HvLpEvent_unregisterHandler(HvLpEvent_Type_VirtualLan);
 
-	/* Make sure any work queued from Hypervisor callbacks is finished. */
-	flush_scheduled_work();
-
 	for (i = 0; i < HVMAXARCHITECTEDLPS; ++i) {
 		cnx = veth_cnx[i];
 
 		if (!cnx)
 			continue;
 
+		/* Cancel work queued from Hypervisor callbacks */
+		cancel_delayed_work_sync(&cnx->statemachine_wq);
 		/* Remove the connection from sysfs */
 		kobject_del(&cnx->kobject);
 		/* Drop the driver's reference to the connection */
-- 
1.7.1

