From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 5/6] sfc: Do not reset when hardware monitor detects a fault
Date: Tue, 4 Nov 2008 20:35:36 +0000
Message-ID: <20081104203535.GB7331@solarflare.com>
References: <20081104203117.GW7331@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:34078 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753541AbYKDUfj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 15:35:39 -0500
Content-Disposition: inline
In-Reply-To: <20081104203117.GW7331@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The TX watchdog should trigger a reset, but a temperature/power alarm
should not as this is unlikely to solve the problem.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c  |   25 ++++---------------------
 drivers/net/sfc/enum.h |    4 ++--
 2 files changed, 6 insertions(+), 23 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 5b05789..5eb8abd 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -77,11 +77,6 @@ static int napi_weight = 64;
  */
 unsigned int efx_monitor_interval = 1 * HZ;
 
-/* This controls whether or not the hardware monitor will trigger a
- * reset when it detects an error condition.
- */
-static unsigned int monitor_reset = true;
-
 /* This controls whether or not the driver will initialise devices
  * with invalid MAC addresses stored in the EEPROM or flash.  If true,
  * such devices will be initialised with a random locally-generated
@@ -1176,17 +1171,6 @@ static void efx_monitor(struct work_struct *data)
 		rc = falcon_check_xmac(efx);
 	mutex_unlock(&efx->mac_lock);
 
-	if (rc) {
-		if (monitor_reset) {
-			EFX_ERR(efx, "hardware monitor detected a fault: "
-				"triggering reset\n");
-			efx_schedule_reset(efx, RESET_TYPE_MONITOR);
-		} else {
-			EFX_ERR(efx, "hardware monitor detected a fault, "
-				"skipping reset\n");
-		}
-	}
-
 	queue_delayed_work(efx->workqueue, &efx->monitor_work,
 			   efx_monitor_interval);
 }
@@ -1358,12 +1342,11 @@ static void efx_watchdog(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
-	EFX_ERR(efx, "TX stuck with stop_count=%d port_enabled=%d: %s\n",
-		atomic_read(&efx->netif_stop_count), efx->port_enabled,
-		monitor_reset ? "resetting channels" : "skipping reset");
+	EFX_ERR(efx, "TX stuck with stop_count=%d port_enabled=%d:"
+		" resetting channels\n",
+		atomic_read(&efx->netif_stop_count), efx->port_enabled);
 
-	if (monitor_reset)
-		efx_schedule_reset(efx, RESET_TYPE_MONITOR);
+	efx_schedule_reset(efx, RESET_TYPE_TX_WATCHDOG);
 }
 
 
diff --git a/drivers/net/sfc/enum.h b/drivers/net/sfc/enum.h
index cec15db..41e758e 100644
--- a/drivers/net/sfc/enum.h
+++ b/drivers/net/sfc/enum.h
@@ -72,7 +72,7 @@ extern const char *efx_loopback_mode_names[];
  * @RESET_TYPE_ALL: reset everything but PCI core blocks
  * @RESET_TYPE_WORLD: reset everything, save & restore PCI config
  * @RESET_TYPE_DISABLE: disable NIC
- * @RESET_TYPE_MONITOR: reset due to hardware monitor
+ * @RESET_TYPE_TX_WATCHDOG: reset due to TX watchdog
  * @RESET_TYPE_INT_ERROR: reset due to internal error
  * @RESET_TYPE_RX_RECOVERY: reset to recover from RX datapath errors
  * @RESET_TYPE_RX_DESC_FETCH: pcie error during rx descriptor fetch
@@ -86,7 +86,7 @@ enum reset_type {
 	RESET_TYPE_WORLD = 2,
 	RESET_TYPE_DISABLE = 3,
 	RESET_TYPE_MAX_METHOD,
-	RESET_TYPE_MONITOR,
+	RESET_TYPE_TX_WATCHDOG,
 	RESET_TYPE_INT_ERROR,
 	RESET_TYPE_RX_RECOVERY,
 	RESET_TYPE_RX_DESC_FETCH,
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
