From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net 3/3] sfc: Detach net device when stopping queues for
 reconfiguration
Date: Tue, 26 Feb 2013 19:12:48 +0000
Message-ID: <1361905968.2996.12.camel@bwh-desktop.uk.solarflarecom.com>
References: <1361905763.2996.9.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<scrum-linux@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:36034 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753724Ab3BZTMv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Feb 2013 14:12:51 -0500
In-Reply-To: <1361905763.2996.9.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We must only ever stop TX queues when they are full or the net device
is not 'ready' so far as the net core, and specifically the watchdog,
is concerned.  Otherwise, the watchdog may fire *immediately* if no
packets have been added to the queue in the last 5 seconds.

The device is ready if all the following are true:

(a) It has a qdisc
(b) It is marked present
(c) It is running
(d) The link is reported up

(a) and (c) are normally true, and must not be changed by a driver.
(d) is under our control, but fake link changes may disturb userland.
This leaves (b).  We already mark the device absent during reset
and self-test, but we need to do the same during MTU changes and ring
reallocation.  We don't need to do this when the device is brought
down because then (c) is already false.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |   16 ++++++++++++----
 1 files changed, 12 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index bf57b3c..0bc0099 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -779,6 +779,7 @@ efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries)
 						tx_queue->txd.entries);
 	}
 
+	efx_device_detach_sync(efx);
 	efx_stop_all(efx);
 	efx_stop_interrupts(efx, true);
 
@@ -832,6 +833,7 @@ out:
 
 	efx_start_interrupts(efx, true);
 	efx_start_all(efx);
+	netif_device_attach(efx->net_dev);
 	return rc;
 
 rollback:
@@ -1641,8 +1643,12 @@ static void efx_stop_all(struct efx_nic *efx)
 	/* Flush efx_mac_work(), refill_workqueue, monitor_work */
 	efx_flush_all(efx);
 
-	/* Stop the kernel transmit interface late, so the watchdog
-	 * timer isn't ticking over the flush */
+	/* Stop the kernel transmit interface.  This is only valid if
+	 * the device is stopped or detached; otherwise the watchdog
+	 * may fire immediately.
+	 */
+	WARN_ON(netif_running(efx->net_dev) &&
+		netif_device_present(efx->net_dev));
 	netif_tx_disable(efx->net_dev);
 
 	efx_stop_datapath(efx);
@@ -1963,16 +1969,18 @@ static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 	if (new_mtu > EFX_MAX_MTU)
 		return -EINVAL;
 
-	efx_stop_all(efx);
-
 	netif_dbg(efx, drv, efx->net_dev, "changing MTU to %d\n", new_mtu);
 
+	efx_device_detach_sync(efx);
+	efx_stop_all(efx);
+
 	mutex_lock(&efx->mac_lock);
 	net_dev->mtu = new_mtu;
 	efx->type->reconfigure_mac(efx);
 	mutex_unlock(&efx->mac_lock);
 
 	efx_start_all(efx);
+	netif_device_attach(efx->net_dev);
 	return 0;
 }
 
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
