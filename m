From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 3/3] sfc: Use netif_device_{detach,attach}()
 around reset and self-test
Date: Tue, 17 May 2011 17:06:11 +0100
Message-ID: <1305648371.2848.18.camel@bwh-desktop>
References: <1305647988.2848.14.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26618 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755408Ab1EQQGO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 12:06:14 -0400
In-Reply-To: <1305647988.2848.14.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to keep the TX queues stopped throughout a reset, without
triggering the TX watchdog and regardless of the link state.  The
proper way to do this is to use netif_device_{detach,attach}() just as
we do around suspend/resume, rather than the current bodge of faking
link-down.

Since we also need to do this during an offline self-test and we
perform a reset during that, add these function calls outside of
efx_reset_down() and efx_reset_up().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |    9 +++------
 drivers/net/sfc/net_driver.h |    4 +---
 drivers/net/sfc/selftest.c   |   11 +++++------
 drivers/net/sfc/tx.c         |    9 +++++----
 4 files changed, 14 insertions(+), 19 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 796c47e..05502b3 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -798,11 +798,6 @@ void efx_link_status_changed(struct efx_nic *efx)
 	if (!netif_running(efx->net_dev))
 		return;
 
-	if (efx->port_inhibited) {
-		netif_carrier_off(efx->net_dev);
-		return;
-	}
-
 	if (link_state->up != netif_carrier_ok(efx->net_dev)) {
 		efx->n_link_state_changes++;
 
@@ -1450,7 +1445,7 @@ static void efx_start_all(struct efx_nic *efx)
 	 * restart the transmit interface early so the watchdog timer stops */
 	efx_start_port(efx);
 
-	if (efx_dev_registered(efx) && !efx->port_inhibited)
+	if (efx_dev_registered(efx) && netif_device_present(efx->net_dev))
 		netif_tx_wake_all_queues(efx->net_dev);
 
 	efx_for_each_channel(channel, efx)
@@ -2114,6 +2109,7 @@ int efx_reset(struct efx_nic *efx, enum reset_type method)
 	netif_info(efx, drv, efx->net_dev, "resetting (%s)\n",
 		   RESET_TYPE(method));
 
+	netif_device_detach(efx->net_dev);
 	efx_reset_down(efx, method);
 
 	rc = efx->type->reset(efx, method);
@@ -2147,6 +2143,7 @@ out:
 		efx->state = STATE_DISABLED;
 	} else {
 		netif_dbg(efx, drv, efx->net_dev, "reset complete\n");
+		netif_device_attach(efx->net_dev);
 	}
 	return rc;
 }
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 5718260..ce9697b 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -670,13 +670,12 @@ struct efx_filter_state;
  * @mtd_list: List of MTDs attached to the NIC
  * @nic_data: Hardware dependent state
  * @mac_lock: MAC access lock. Protects @port_enabled, @phy_mode,
- *	@port_inhibited, efx_monitor() and efx_reconfigure_port()
+ *	efx_monitor() and efx_reconfigure_port()
  * @port_enabled: Port enabled indicator.
  *	Serialises efx_stop_all(), efx_start_all(), efx_monitor() and
  *	efx_mac_work() with kernel interfaces. Safe to read under any
  *	one of the rtnl_lock, mac_lock, or netif_tx_lock, but all three must
  *	be held to modify it.
- * @port_inhibited: If set, the netif_carrier is always off. Hold the mac_lock
  * @port_initialized: Port initialized?
  * @net_dev: Operating system network device. Consider holding the rtnl lock
  * @stats_buffer: DMA buffer for statistics
@@ -764,7 +763,6 @@ struct efx_nic {
 	struct mutex mac_lock;
 	struct work_struct mac_work;
 	bool port_enabled;
-	bool port_inhibited;
 
 	bool port_initialized;
 	struct net_device *net_dev;
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 50ad3bc..822f6c2 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -695,12 +695,12 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	/* Offline (i.e. disruptive) testing
 	 * This checks MAC and PHY loopback on the specified port. */
 
-	/* force the carrier state off so the kernel doesn't transmit during
-	 * the loopback test, and the watchdog timeout doesn't fire. Also put
-	 * falcon into loopback for the register test.
+	/* Detach the device so the kernel doesn't transmit during the
+	 * loopback test and the watchdog timeout doesn't fire.
 	 */
+	netif_device_detach(efx->net_dev);
+
 	mutex_lock(&efx->mac_lock);
-	efx->port_inhibited = true;
 	if (efx->loopback_modes) {
 		/* We need the 312 clock from the PHY to test the XMAC
 		 * registers, so move into XGMII loopback if available */
@@ -750,12 +750,11 @@ int efx_selftest(struct efx_nic *efx, struct efx_self_tests *tests,
 	/* restore the PHY to the previous state */
 	mutex_lock(&efx->mac_lock);
 	efx->phy_mode = phy_mode;
-	efx->port_inhibited = false;
 	efx->loopback_mode = loopback_mode;
 	__efx_reconfigure_port(efx);
 	mutex_unlock(&efx->mac_lock);
 
-	netif_tx_wake_all_queues(efx->net_dev);
+	netif_device_attach(efx->net_dev);
 
 	return rc_test;
 }
diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
index d2c85df..84eb99e 100644
--- a/drivers/net/sfc/tx.c
+++ b/drivers/net/sfc/tx.c
@@ -205,7 +205,9 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
 					goto unwind;
 				}
 				smp_mb();
-				netif_tx_start_queue(tx_queue->core_txq);
+				if (likely(!efx->loopback_selftest))
+					netif_tx_start_queue(
+						tx_queue->core_txq);
 			}
 
 			insert_ptr = tx_queue->insert_count & tx_queue->ptr_mask;
@@ -338,8 +340,7 @@ netdev_tx_t efx_hard_start_xmit(struct sk_buff *skb,
 	struct efx_tx_queue *tx_queue;
 	unsigned index, type;
 
-	if (unlikely(efx->port_inhibited))
-		return NETDEV_TX_BUSY;
+	EFX_WARN_ON_PARANOID(!netif_device_present(net_dev));
 
 	index = skb_get_queue_mapping(skb);
 	type = skb->ip_summed == CHECKSUM_PARTIAL ? EFX_TXQ_TYPE_OFFLOAD : 0;
@@ -436,7 +437,7 @@ void efx_xmit_done(struct efx_tx_queue *tx_queue, unsigned int index)
 	smp_mb();
 	if (unlikely(netif_tx_queue_stopped(tx_queue->core_txq)) &&
 	    likely(efx->port_enabled) &&
-	    likely(!efx->port_inhibited)) {
+	    likely(netif_device_present(efx->net_dev))) {
 		fill_level = tx_queue->insert_count - tx_queue->read_count;
 		if (fill_level < EFX_TXQ_THRESHOLD(efx)) {
 			EFX_BUG_ON_PARANOID(!efx_dev_registered(efx));
-- 
1.7.4


-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

