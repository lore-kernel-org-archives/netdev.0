From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 18/32] sfc: Generalise link state monitoring
Date: Sat, 28 Nov 2009 03:49:57 +0000
Message-ID: <1259380197.2811.42.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:42661 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753906AbZK1Dtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:49:53 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the efx_nic_type::monitor operation or event handling as
appropriate.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c      |   16 ++++++++-
 drivers/net/sfc/selftest.c |   79 ++++++++++++++++++++++++++------------------
 2 files changed, 61 insertions(+), 34 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index c77338f..d94ec07 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -1174,10 +1174,18 @@ static void efx_start_all(struct efx_nic *efx)
 
 	falcon_enable_interrupts(efx);
 
-	/* Start the hardware monitor (if there is one) if we're in RUNNING */
-	if (efx->state == STATE_RUNNING && efx->type->monitor != NULL)
+	/* Start the hardware monitor if there is one. Otherwise (we're link
+	 * event driven), we have to poll the PHY because after an event queue
+	 * flush, we could have a missed a link state change */
+	if (efx->type->monitor != NULL) {
 		queue_delayed_work(efx->workqueue, &efx->monitor_work,
 				   efx_monitor_interval);
+	} else {
+		mutex_lock(&efx->mac_lock);
+		if (efx->phy_op->poll(efx))
+			efx_link_status_changed(efx);
+		mutex_unlock(&efx->mac_lock);
+	}
 
 	efx->type->start_stats(efx);
 }
@@ -1421,6 +1429,10 @@ static int efx_net_open(struct net_device *net_dev)
 	if (efx->phy_mode & PHY_MODE_SPECIAL)
 		return -EBUSY;
 
+	/* Notify the kernel of the link state polled during driver load,
+	 * before the monitor starts running */
+	efx_link_status_changed(efx);
+
 	efx_start_all(efx);
 	return 0;
 }
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index dddeb9d..f45bf74 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -563,14 +563,49 @@ efx_test_loopback(struct efx_tx_queue *tx_queue,
 	return 0;
 }
 
+/* Wait for link up. On Falcon, we would prefer to rely on efx_monitor, but
+ * any contention on the mac lock (via e.g. efx_mac_mcast_work) causes it
+ * to delay and retry. Therefore, it's safer to just poll directly. Wait
+ * for link up and any faults to dissipate. */
+static int efx_wait_for_link(struct efx_nic *efx)
+{
+	struct efx_link_state *link_state = &efx->link_state;
+	int count;
+	bool link_up;
+
+	for (count = 0; count < 40; count++) {
+		schedule_timeout_uninterruptible(HZ / 10);
+
+		if (efx->type->monitor != NULL) {
+			mutex_lock(&efx->mac_lock);
+			efx->type->monitor(efx);
+			mutex_unlock(&efx->mac_lock);
+		} else {
+			struct efx_channel *channel = &efx->channel[0];
+			if (channel->work_pending)
+				efx_process_channel_now(channel);
+		}
+
+		mutex_lock(&efx->mac_lock);
+		link_up = link_state->up;
+		if (link_up)
+			link_up = !efx->mac_op->check_fault(efx);
+		mutex_unlock(&efx->mac_lock);
+
+		if (link_up)
+			return 0;
+	}
+
+	return -ETIMEDOUT;
+}
+
 static int efx_test_loopbacks(struct efx_nic *efx, struct efx_self_tests *tests,
 			      unsigned int loopback_modes)
 {
 	enum efx_loopback_mode mode;
 	struct efx_loopback_state *state;
 	struct efx_tx_queue *tx_queue;
-	bool link_up;
-	int count, rc = 0;
+	int rc = 0;
 
 	/* Set the port loopback_selftest member. From this point on
 	 * all received packets will be dropped. Mark the state as
@@ -589,43 +624,23 @@ static int efx_test_loopbacks(struct efx_nic *efx, struct efx_self_tests *tests,
 
 		/* Move the port into the specified loopback mode. */
 		state->flush = true;
+		mutex_lock(&efx->mac_lock);
 		efx->loopback_mode = mode;
-		efx_reconfigure_port(efx);
-
-		/* Wait for the PHY to signal the link is up. Interrupts
-		 * are enabled for PHY's using LASI, otherwise we poll()
-		 * quickly */
-		count = 0;
-		do {
-			struct efx_channel *channel = &efx->channel[0];
-
-			efx->phy_op->poll(efx);
-			schedule_timeout_uninterruptible(HZ / 10);
-			if (channel->work_pending)
-				efx_process_channel_now(channel);
-			/* Wait for PHY events to be processed */
-			flush_workqueue(efx->workqueue);
-			rmb();
-
-			/* We need both the PHY and MAC-PHY links to be OK */
-			link_up = efx->link_state.up;
-			if (link_up)
-				link_up = !efx->mac_op->check_fault(efx);
-
-		} while ((++count < 20) && !link_up);
+		rc = __efx_reconfigure_port(efx);
+		mutex_unlock(&efx->mac_lock);
+		if (rc) {
+			EFX_ERR(efx, "unable to move into %s loopback\n",
+				LOOPBACK_MODE(efx));
+			goto out;
+		}
 
-		/* The link should now be up. If it isn't, there is no point
-		 * in attempting a loopback test */
-		if (!link_up) {
+		rc = efx_wait_for_link(efx);
+		if (rc) {
 			EFX_ERR(efx, "loopback %s never came up\n",
 				LOOPBACK_MODE(efx));
-			rc = -EIO;
 			goto out;
 		}
 
-		EFX_LOG(efx, "link came up in %s loopback in %d iterations\n",
-			LOOPBACK_MODE(efx), count);
-
 		/* Test every TX queue */
 		efx_for_each_tx_queue(tx_queue, efx) {
 			state->offload_csum = (tx_queue->queue ==


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

