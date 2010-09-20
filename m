From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 8/8] sfc: Clean up and correct comments on
 efx_monitor()
Date: Mon, 20 Sep 2010 19:44:10 +0100
Message-ID: <1285008250.2282.111.camel@achroite.uk.solarflarecom.com>
References: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:7346 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756495Ab0ITSoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 14:44:13 -0400
In-Reply-To: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c |   23 ++++++++++-------------
 1 files changed, 10 insertions(+), 13 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 48e2bf4..8a51c41 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -124,8 +124,9 @@ MODULE_PARM_DESC(separate_tx_channels,
 static int napi_weight = 64;
 
 /* This is the time (in jiffies) between invocations of the hardware
- * monitor, which checks for known hardware bugs and resets the
- * hardware and driver as necessary.
+ * monitor.  On Falcon-based NICs, this will:
+ * - Check the on-board hardware monitor;
+ * - Poll the link state and reconfigure the hardware as necessary.
  */
 unsigned int efx_monitor_interval = 1 * HZ;
 
@@ -1546,8 +1547,7 @@ void efx_init_irq_moderation(struct efx_nic *efx, int tx_usecs, int rx_usecs,
  *
  **************************************************************************/
 
-/* Run periodically off the general workqueue. Serialised against
- * efx_reconfigure_port via the mac_lock */
+/* Run periodically off the general workqueue */
 static void efx_monitor(struct work_struct *data)
 {
 	struct efx_nic *efx = container_of(data, struct efx_nic,
@@ -1560,16 +1560,13 @@ static void efx_monitor(struct work_struct *data)
 
 	/* If the mac_lock is already held then it is likely a port
 	 * reconfiguration is already in place, which will likely do
-	 * most of the work of check_hw() anyway. */
-	if (!mutex_trylock(&efx->mac_lock))
-		goto out_requeue;
-	if (!efx->port_enabled)
-		goto out_unlock;
-	efx->type->monitor(efx);
+	 * most of the work of monitor() anyway. */
+	if (mutex_trylock(&efx->mac_lock)) {
+		if (efx->port_enabled)
+			efx->type->monitor(efx);
+		mutex_unlock(&efx->mac_lock);
+	}
 
-out_unlock:
-	mutex_unlock(&efx->mac_lock);
-out_requeue:
 	queue_delayed_work(efx->workqueue, &efx->monitor_work,
 			   efx_monitor_interval);
 }
-- 
1.7.2.1


-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

