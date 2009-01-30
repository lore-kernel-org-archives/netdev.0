From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 11/11] sfc: Replace stats_enabled flag with a disable count
Date: Fri, 30 Jan 2009 04:00:07 +0000
Message-ID: <20090130040007.GM15266@solarflare.com>
References: <20090129.170811.135213740.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost03.mail.zen.net.uk ([212.23.3.142]:48320 "EHLO
	smarthost03.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752436AbZA3EAK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2009 23:00:10 -0500
Content-Disposition: inline
In-Reply-To: <20090129.170811.135213740.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we use a spin-lock to serialise statistics fetches and also
to inhibit them for short periods of time, plus a flag to
enable/disable statistics fetches for longer periods of time, during
online reset.  This was apparently insufficient to deal with the several
reasons for stats being disabled.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   33 ++++++++++++++++++++++-----------
 drivers/net/sfc/efx.h        |    2 ++
 drivers/net/sfc/falcon.c     |   15 +++++++++++----
 drivers/net/sfc/net_driver.h |    5 ++---
 drivers/net/sfc/sfe4001.c    |   15 ++++++++++++++-
 drivers/net/sfc/tenxpress.c  |   12 ++++++------
 6 files changed, 57 insertions(+), 25 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index b0e5308..ab0e09b 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -685,7 +685,7 @@ static int efx_init_port(struct efx_nic *efx)
 	efx->mac_op->reconfigure(efx);
 
 	efx->port_initialized = true;
-	efx->stats_enabled = true;
+	efx_stats_enable(efx);
 	return 0;
 
 fail:
@@ -734,6 +734,7 @@ static void efx_fini_port(struct efx_nic *efx)
 	if (!efx->port_initialized)
 		return;
 
+	efx_stats_disable(efx);
 	efx->phy_op->fini(efx);
 	efx->port_initialized = false;
 
@@ -1360,6 +1361,20 @@ static int efx_net_stop(struct net_device *net_dev)
 	return 0;
 }
 
+void efx_stats_disable(struct efx_nic *efx)
+{
+	spin_lock(&efx->stats_lock);
+	++efx->stats_disable_count;
+	spin_unlock(&efx->stats_lock);
+}
+
+void efx_stats_enable(struct efx_nic *efx)
+{
+	spin_lock(&efx->stats_lock);
+	--efx->stats_disable_count;
+	spin_unlock(&efx->stats_lock);
+}
+
 /* Context: process, dev_base_lock or RTNL held, non-blocking. */
 static struct net_device_stats *efx_net_stats(struct net_device *net_dev)
 {
@@ -1368,12 +1383,12 @@ static struct net_device_stats *efx_net_stats(struct net_device *net_dev)
 	struct net_device_stats *stats = &net_dev->stats;
 
 	/* Update stats if possible, but do not wait if another thread
-	 * is updating them (or resetting the NIC); slightly stale
-	 * stats are acceptable.
+	 * is updating them or if MAC stats fetches are temporarily
+	 * disabled; slightly stale stats are acceptable.
 	 */
 	if (!spin_trylock(&efx->stats_lock))
 		return stats;
-	if (efx->stats_enabled) {
+	if (!efx->stats_disable_count) {
 		efx->mac_op->update_stats(efx);
 		falcon_update_nic_stats(efx);
 	}
@@ -1626,12 +1641,7 @@ void efx_reset_down(struct efx_nic *efx, enum reset_type method,
 {
 	EFX_ASSERT_RESET_SERIALISED(efx);
 
-	/* The net_dev->get_stats handler is quite slow, and will fail
-	 * if a fetch is pending over reset. Serialise against it. */
-	spin_lock(&efx->stats_lock);
-	efx->stats_enabled = false;
-	spin_unlock(&efx->stats_lock);
-
+	efx_stats_disable(efx);
 	efx_stop_all(efx);
 	mutex_lock(&efx->mac_lock);
 	mutex_lock(&efx->spi_lock);
@@ -1682,7 +1692,7 @@ int efx_reset_up(struct efx_nic *efx, enum reset_type method,
 
 	if (ok) {
 		efx_start_all(efx);
-		efx->stats_enabled = true;
+		efx_stats_enable(efx);
 	}
 	return rc;
 }
@@ -1888,6 +1898,7 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	efx->rx_checksum_enabled = true;
 	spin_lock_init(&efx->netif_stop_lock);
 	spin_lock_init(&efx->stats_lock);
+	efx->stats_disable_count = 1;
 	mutex_init(&efx->mac_lock);
 	efx->mac_op = &efx_dummy_mac_operations;
 	efx->phy_op = &efx_dummy_phy_operations;
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index ac20158..55d0f13 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -36,6 +36,8 @@ extern void efx_process_channel_now(struct efx_channel *channel);
 extern void efx_flush_queues(struct efx_nic *efx);
 
 /* Ports */
+extern void efx_stats_disable(struct efx_nic *efx);
+extern void efx_stats_enable(struct efx_nic *efx);
 extern void efx_reconfigure_port(struct efx_nic *efx);
 extern void __efx_reconfigure_port(struct efx_nic *efx);
 
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index d9412f8..d5378e6 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1883,7 +1883,7 @@ static int falcon_reset_macs(struct efx_nic *efx)
 
 	/* MAC stats will fail whilst the TX fifo is draining. Serialise
 	 * the drain sequence with the statistics fetch */
-	spin_lock(&efx->stats_lock);
+	efx_stats_disable(efx);
 
 	falcon_read(efx, &reg, MAC0_CTRL_REG_KER);
 	EFX_SET_OWORD_FIELD(reg, TXFIFO_DRAIN_EN_B0, 1);
@@ -1913,7 +1913,7 @@ static int falcon_reset_macs(struct efx_nic *efx)
 		udelay(10);
 	}
 
-	spin_unlock(&efx->stats_lock);
+	efx_stats_enable(efx);
 
 	/* If we've reset the EM block and the link is up, then
 	 * we'll have to kick the XAUI link so the PHY can recover */
@@ -2273,6 +2273,10 @@ int falcon_switch_mac(struct efx_nic *efx)
 	struct efx_mac_operations *old_mac_op = efx->mac_op;
 	efx_oword_t nic_stat;
 	unsigned strap_val;
+	int rc = 0;
+
+	/* Don't try to fetch MAC stats while we're switching MACs */
+	efx_stats_disable(efx);
 
 	/* Internal loopbacks override the phy speed setting */
 	if (efx->loopback_mode == LOOPBACK_GMAC) {
@@ -2302,13 +2306,16 @@ int falcon_switch_mac(struct efx_nic *efx)
 	}
 
 	if (old_mac_op == efx->mac_op)
-		return 0;
+		goto out;
 
 	EFX_LOG(efx, "selected %cMAC\n", EFX_IS10G(efx) ? 'X' : 'G');
 	/* Not all macs support a mac-level link state */
 	efx->mac_up = true;
 
-	return falcon_reset_macs(efx);
+	rc = falcon_reset_macs(efx);
+out:
+	efx_stats_enable(efx);
+	return rc;
 }
 
 /* This call is responsible for hooking in the MAC and PHY operations */
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 8eb411a..e019ad1 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -754,8 +754,7 @@ union efx_multicast_hash {
  *	&struct net_device_stats.
  * @stats_buffer: DMA buffer for statistics
  * @stats_lock: Statistics update lock. Serialises statistics fetches
- * @stats_enabled: Temporarily disable statistics fetches.
- *	Serialised by @stats_lock
+ * @stats_disable_count: Nest count for disabling statistics fetches
  * @mac_op: MAC interface
  * @mac_address: Permanent MAC address
  * @phy_type: PHY type
@@ -837,7 +836,7 @@ struct efx_nic {
 	struct efx_mac_stats mac_stats;
 	struct efx_buffer stats_buffer;
 	spinlock_t stats_lock;
-	bool stats_enabled;
+	unsigned int stats_disable_count;
 
 	struct efx_mac_operations *mac_op;
 	unsigned char mac_address[ETH_ALEN];
diff --git a/drivers/net/sfc/sfe4001.c b/drivers/net/sfc/sfe4001.c
index 853057e..cb25ae5 100644
--- a/drivers/net/sfc/sfe4001.c
+++ b/drivers/net/sfc/sfe4001.c
@@ -235,12 +235,18 @@ static ssize_t set_phy_flash_cfg(struct device *dev,
 	} else if (efx->state != STATE_RUNNING || netif_running(efx->net_dev)) {
 		err = -EBUSY;
 	} else {
+		/* Reset the PHY, reconfigure the MAC and enable/disable
+		 * MAC stats accordingly. */
 		efx->phy_mode = new_mode;
+		if (new_mode & PHY_MODE_SPECIAL)
+			efx_stats_disable(efx);
 		if (efx->board_info.type == EFX_BOARD_SFE4001)
 			err = sfe4001_poweron(efx);
 		else
 			err = sfn4111t_reset(efx);
 		efx_reconfigure_port(efx);
+		if (!(new_mode & PHY_MODE_SPECIAL))
+			efx_stats_enable(efx);
 	}
 	rtnl_unlock();
 
@@ -329,6 +335,11 @@ int sfe4001_init(struct efx_nic *efx)
 	efx->board_info.monitor = sfe4001_check_hw;
 	efx->board_info.fini = sfe4001_fini;
 
+	if (efx->phy_mode & PHY_MODE_SPECIAL) {
+		/* PHY won't generate a 156.25 MHz clock and MAC stats fetch
+		 * will fail. */
+		efx_stats_disable(efx);
+	}
 	rc = sfe4001_poweron(efx);
 	if (rc)
 		goto fail_ioexp;
@@ -405,8 +416,10 @@ int sfn4111t_init(struct efx_nic *efx)
 	if (rc)
 		goto fail_hwmon;
 
-	if (efx->phy_mode & PHY_MODE_SPECIAL)
+	if (efx->phy_mode & PHY_MODE_SPECIAL) {
+		efx_stats_disable(efx);
 		sfn4111t_reset(efx);
+	}
 
 	return 0;
 
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index 412d209..f0efd24 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -370,8 +370,8 @@ static int tenxpress_special_reset(struct efx_nic *efx)
 
 	/* The XGMAC clock is driven from the SFC7101/SFT9001 312MHz clock, so
 	 * a special software reset can glitch the XGMAC sufficiently for stats
-	 * requests to fail. Since we don't often special_reset, just lock. */
-	spin_lock(&efx->stats_lock);
+	 * requests to fail. */
+	efx_stats_disable(efx);
 
 	/* Initiate reset */
 	reg = mdio_clause45_read(efx, efx->mii.phy_id,
@@ -386,17 +386,17 @@ static int tenxpress_special_reset(struct efx_nic *efx)
 	rc = mdio_clause45_wait_reset_mmds(efx,
 					   TENXPRESS_REQUIRED_DEVS);
 	if (rc < 0)
-		goto unlock;
+		goto out;
 
 	/* Try and reconfigure the device */
 	rc = tenxpress_init(efx);
 	if (rc < 0)
-		goto unlock;
+		goto out;
 
 	/* Wait for the XGXS state machine to churn */
 	mdelay(10);
-unlock:
-	spin_unlock(&efx->stats_lock);
+out:
+	efx_stats_enable(efx);
 	return rc;
 }
 

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
