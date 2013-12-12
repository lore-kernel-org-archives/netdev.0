From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 12/16] sfc: Fold efx_flush_all() into
 efx_stop_port() and update comments
Date: Thu, 12 Dec 2013 23:02:34 +0000
Message-ID: <1386889354.1516.349.camel@bwh-desktop.uk.level5networks.com>
References: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29534 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751579Ab3LLXCh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Dec 2013 18:02:37 -0500
In-Reply-To: <1386888977.1516.337.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_flush_all() is a really misleading name - it has nothing to do
with e.g. flushing DMA queues.  Since it's called immediately after
efx_stop_port() and is highly dependent on what that does, combine
the two functions.

Update comments to explain what this is doing a little better.
Also update an related and erroneous comment in efx_start_port().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c | 30 ++++++++++++------------------
 1 file changed, 12 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index c734fba8c99c..893cd78c3a6c 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -1060,18 +1060,23 @@ static void efx_start_port(struct efx_nic *efx)
 	mutex_lock(&efx->mac_lock);
 	efx->port_enabled = true;
 
-	/* efx_mac_work() might have been scheduled after efx_stop_port(),
-	 * and then cancelled by efx_flush_all() */
+	/* Ensure MAC ingress/egress is enabled */
 	efx->type->reconfigure_mac(efx);
 
 	mutex_unlock(&efx->mac_lock);
 }
 
-/* Prevent efx_mac_work() and efx_monitor() from working */
+/* Cancel work for MAC reconfiguration, periodic hardware monitoring
+ * and the async self-test, wait for them to finish and prevent them
+ * being scheduled again.  This doesn't cover online resets, which
+ * should only be cancelled when removing the device.
+ */
 static void efx_stop_port(struct efx_nic *efx)
 {
 	netif_dbg(efx, ifdown, efx->net_dev, "stop port\n");
 
+	EFX_ASSERT_RESET_SERIALISED(efx);
+
 	mutex_lock(&efx->mac_lock);
 	efx->port_enabled = false;
 	mutex_unlock(&efx->mac_lock);
@@ -1079,6 +1084,10 @@ static void efx_stop_port(struct efx_nic *efx)
 	/* Serialise against efx_set_multicast_list() */
 	netif_addr_lock_bh(efx->net_dev);
 	netif_addr_unlock_bh(efx->net_dev);
+
+	cancel_delayed_work_sync(&efx->monitor_work);
+	efx_selftest_async_cancel(efx);
+	cancel_work_sync(&efx->mac_work);
 }
 
 static void efx_fini_port(struct efx_nic *efx)
@@ -1690,18 +1699,6 @@ static void efx_start_all(struct efx_nic *efx)
 	spin_unlock_bh(&efx->stats_lock);
 }
 
-/* Flush all delayed work. Should only be called when no more delayed work
- * will be scheduled. This doesn't flush pending online resets (efx_reset),
- * since we're holding the rtnl_lock at this point. */
-static void efx_flush_all(struct efx_nic *efx)
-{
-	/* Make sure the hardware monitor and event self-test are stopped */
-	cancel_delayed_work_sync(&efx->monitor_work);
-	efx_selftest_async_cancel(efx);
-	/* Stop scheduled port reconfigurations */
-	cancel_work_sync(&efx->mac_work);
-}
-
 /* Quiesce the hardware and software data path, and regular activity
  * for the port without bringing the link down.  Safe to call multiple
  * times with the NIC in almost any state, but interrupts should be
@@ -1725,9 +1722,6 @@ static void efx_stop_all(struct efx_nic *efx)
 	efx->type->stop_stats(efx);
 	efx_stop_port(efx);
 
-	/* Flush efx_mac_work(), refill_workqueue, monitor_work */
-	efx_flush_all(efx);
-
 	/* Stop the kernel transmit interface.  This is only valid if
 	 * the device is stopped or detached; otherwise the watchdog
 	 * may fire immediately.


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
