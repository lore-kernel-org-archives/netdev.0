From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 10/16] sfc: Never try to stop and start a NIC that
 is disabled
Date: Fri, 24 Aug 2012 20:51:55 +0100
Message-ID: <1345837915.2694.32.camel@bwh-desktop.uk.solarflarecom.com>
References: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56781 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932254Ab2HXTv6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Aug 2012 15:51:58 -0400
In-Reply-To: <1345837574.2694.22.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

efx_change_mtu() and efx_realloc_channels() each stop and start much
of the NIC, even if it has been disabled.  Since efx_start_all() is a
no-op when the NIC is disabled, this is probably harmless in the case
of efx_change_mtu(), but efx_realloc_channels() also reenables
interrupts which could be a bad thing to do.

Change efx_start_all() and efx_start_interrupts() to assert that the
NIC is not disabled, but make efx_stop_interrupts() do nothing if the
NIC is disabled (since it is already stopped), consistent with
efx_stop_all().

Update comments for efx_start_all() and efx_stop_all() to describe
their purpose and preconditions more accurately.

Add a common function to check and log if the NIC is disabled, and use
it in efx_net_open(), efx_change_mtu() and efx_realloc_channels().

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/efx.c |   65 +++++++++++++++++++++++++++-------------
 1 files changed, 44 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/sfc/efx.c b/drivers/net/ethernet/sfc/efx.c
index 629029e..977fc3a 100644
--- a/drivers/net/ethernet/sfc/efx.c
+++ b/drivers/net/ethernet/sfc/efx.c
@@ -207,6 +207,16 @@ static void efx_stop_all(struct efx_nic *efx);
 			ASSERT_RTNL();			\
 	} while (0)
 
+static int efx_check_disabled(struct efx_nic *efx)
+{
+	if (efx->state == STATE_DISABLED) {
+		netif_err(efx, drv, efx->net_dev,
+			  "device is disabled due to earlier errors\n");
+		return -EIO;
+	}
+	return 0;
+}
+
 /**************************************************************************
  *
  * Event queue processing
@@ -740,7 +750,11 @@ efx_realloc_channels(struct efx_nic *efx, u32 rxq_entries, u32 txq_entries)
 	struct efx_channel *other_channel[EFX_MAX_CHANNELS], *channel;
 	u32 old_rxq_entries, old_txq_entries;
 	unsigned i, next_buffer_table = 0;
-	int rc = 0;
+	int rc;
+
+	rc = efx_check_disabled(efx);
+	if (rc)
+		return rc;
 
 	/* Not all channels should be reallocated. We must avoid
 	 * reallocating their buffer table entries.
@@ -1375,6 +1389,8 @@ static void efx_start_interrupts(struct efx_nic *efx, bool may_keep_eventq)
 {
 	struct efx_channel *channel;
 
+	BUG_ON(efx->state == STATE_DISABLED);
+
 	if (efx->legacy_irq)
 		efx->legacy_irq_enabled = true;
 	efx_nic_enable_interrupts(efx);
@@ -1392,6 +1408,9 @@ static void efx_stop_interrupts(struct efx_nic *efx, bool may_keep_eventq)
 {
 	struct efx_channel *channel;
 
+	if (efx->state == STATE_DISABLED)
+		return;
+
 	efx_mcdi_mode_poll(efx);
 
 	efx_nic_disable_interrupts(efx);
@@ -1543,22 +1562,21 @@ static int efx_probe_all(struct efx_nic *efx)
 	return rc;
 }
 
-/* Called after previous invocation(s) of efx_stop_all, restarts the port,
- * kernel transmit queues and NAPI processing, and ensures that the port is
- * scheduled to be reconfigured. This function is safe to call multiple
- * times when the NIC is in any state.
+/* If the interface is supposed to be running but is not, start
+ * the hardware and software data path, regular activity for the port
+ * (MAC statistics, link polling, etc.) and schedule the port to be
+ * reconfigured.  Interrupts must already be enabled.  This function
+ * is safe to call multiple times, so long as the NIC is not disabled.
+ * Requires the RTNL lock.
  */
 static void efx_start_all(struct efx_nic *efx)
 {
 	EFX_ASSERT_RESET_SERIALISED(efx);
+	BUG_ON(efx->state == STATE_DISABLED);
 
 	/* Check that it is appropriate to restart the interface. All
 	 * of these flags are safe to read under just the rtnl lock */
-	if (efx->port_enabled)
-		return;
-	if ((efx->state != STATE_READY) && (efx->state != STATE_UNINIT))
-		return;
-	if (!netif_running(efx->net_dev))
+	if (efx->port_enabled || !netif_running(efx->net_dev))
 		return;
 
 	efx_start_port(efx);
@@ -1592,11 +1610,11 @@ static void efx_flush_all(struct efx_nic *efx)
 	cancel_work_sync(&efx->mac_work);
 }
 
-/* Quiesce hardware and software without bringing the link down.
- * Safe to call multiple times, when the nic and interface is in any
- * state. The caller is guaranteed to subsequently be in a position
- * to modify any hardware and software state they see fit without
- * taking locks. */
+/* Quiesce the hardware and software data path, and regular activity
+ * for the port without bringing the link down.  Safe to call multiple
+ * times with the NIC in almost any state, but interrupts should be
+ * enabled.  Requires the RTNL lock.
+ */
 static void efx_stop_all(struct efx_nic *efx)
 {
 	EFX_ASSERT_RESET_SERIALISED(efx);
@@ -1830,13 +1848,16 @@ static void efx_netpoll(struct net_device *net_dev)
 static int efx_net_open(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
+	int rc;
+
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
 	netif_dbg(efx, ifup, efx->net_dev, "opening device on CPU %d\n",
 		  raw_smp_processor_id());
 
-	if (efx->state == STATE_DISABLED)
-		return -EIO;
+	rc = efx_check_disabled(efx);
+	if (rc)
+		return rc;
 	if (efx->phy_mode & PHY_MODE_SPECIAL)
 		return -EBUSY;
 	if (efx_mcdi_poll_reboot(efx) && efx_reset(efx, RESET_TYPE_ALL))
@@ -1862,10 +1883,8 @@ static int efx_net_stop(struct net_device *net_dev)
 	netif_dbg(efx, ifdown, efx->net_dev, "closing on CPU %d\n",
 		  raw_smp_processor_id());
 
-	if (efx->state != STATE_DISABLED) {
-		/* Stop the device and flush all the channels */
-		efx_stop_all(efx);
-	}
+	/* Stop the device and flush all the channels */
+	efx_stop_all(efx);
 
 	return 0;
 }
@@ -1925,9 +1944,13 @@ static void efx_watchdog(struct net_device *net_dev)
 static int efx_change_mtu(struct net_device *net_dev, int new_mtu)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
+	int rc;
 
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
+	rc = efx_check_disabled(efx);
+	if (rc)
+		return rc;
 	if (new_mtu > EFX_MAX_MTU)
 		return -EINVAL;
 
-- 
1.7.7.6



-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
