From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 01/32] sfc: Simplify PHY polling
Date: Sat, 28 Nov 2009 03:43:42 +0000
Message-ID: <1259379822.2811.7.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:42342 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753381AbZK1Dno (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2009 22:43:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Hodgson <shodgson@solarflare.com>

Falcon can generate events for LASI interrupts from the PHY, but in
practice we have never implemented this in reference designs.  Instead
we have polled, inserted the appropriate events, and then handled the
events later.  This is a waste of time and code.

Instead, make PHY poll functions update the link state synchronously
and report whether it changed.  We can still make use of the LASI
registers as a shortcut on the SFT9001.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c        |   35 +++++----------------
 drivers/net/sfc/efx.h        |    3 ++
 drivers/net/sfc/falcon.c     |   69 +++++++++++++++++++++++++----------------
 drivers/net/sfc/falcon.h     |    1 -
 drivers/net/sfc/net_driver.h |   24 ++++++++------
 drivers/net/sfc/qt202x_phy.c |   26 +++++----------
 drivers/net/sfc/tenxpress.c  |   69 ++++++++++++++++-------------------------
 7 files changed, 103 insertions(+), 124 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 1009d1e..b5a7e91 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -583,7 +583,7 @@ void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue, int delay)
  * netif_carrier_on/off) of the link status, and also maintains the
  * link status's stop on the port's TX queue.
  */
-static void efx_link_status_changed(struct efx_nic *efx)
+void efx_link_status_changed(struct efx_nic *efx)
 {
 	struct efx_link_state *link_state = &efx->link_state;
 
@@ -675,19 +675,6 @@ void efx_reconfigure_port(struct efx_nic *efx)
 	mutex_unlock(&efx->mac_lock);
 }
 
-/* Asynchronous efx_reconfigure_port work item. To speed up efx_flush_all()
- * we don't efx_reconfigure_port() if the port is disabled. Care is taken
- * in efx_stop_all() and efx_start_port() to prevent PHY events being lost */
-static void efx_phy_work(struct work_struct *data)
-{
-	struct efx_nic *efx = container_of(data, struct efx_nic, phy_work);
-
-	mutex_lock(&efx->mac_lock);
-	if (efx->port_enabled)
-		__efx_reconfigure_port(efx);
-	mutex_unlock(&efx->mac_lock);
-}
-
 /* Asynchronous work item for changing MAC promiscuity and multicast
  * hash.  Avoid a drain/rx_ingress enable by reconfiguring the current
  * MAC directly. */
@@ -768,9 +755,6 @@ fail1:
 	return rc;
 }
 
-/* Allow efx_reconfigure_port() to be scheduled, and close the window
- * between efx_stop_port and efx_flush_all whereby a previously scheduled
- * efx_phy_work()/efx_mac_work() may have been cancelled */
 static void efx_start_port(struct efx_nic *efx)
 {
 	EFX_LOG(efx, "start port\n");
@@ -787,10 +771,7 @@ static void efx_start_port(struct efx_nic *efx)
 	mutex_unlock(&efx->mac_lock);
 }
 
-/* Prevent efx_phy_work, efx_mac_work, and efx_monitor() from executing,
- * and efx_set_multicast_list() from scheduling efx_phy_work. efx_phy_work
- * and efx_mac_work may still be scheduled via NAPI processing until
- * efx_flush_all() is called */
+/* Prevent efx_mac_work() and efx_monitor() from working */
 static void efx_stop_port(struct efx_nic *efx)
 {
 	EFX_LOG(efx, "stop port\n");
@@ -1188,8 +1169,6 @@ static void efx_flush_all(struct efx_nic *efx)
 
 	/* Stop scheduled port reconfigurations */
 	cancel_work_sync(&efx->mac_work);
-	cancel_work_sync(&efx->phy_work);
-
 }
 
 /* Quiesce hardware and software without bringing the link down.
@@ -1227,7 +1206,7 @@ static void efx_stop_all(struct efx_nic *efx)
 	 * window to loose phy events */
 	efx_stop_port(efx);
 
-	/* Flush efx_phy_work, efx_mac_work, refill_workqueue, monitor_work */
+	/* Flush efx_mac_work(), refill_workqueue, monitor_work */
 	efx_flush_all(efx);
 
 	/* Isolate the MAC from the TX and RX engines, so that queue
@@ -1907,6 +1886,10 @@ void efx_port_dummy_op_void(struct efx_nic *efx) {}
 void efx_port_dummy_op_set_id_led(struct efx_nic *efx, enum efx_led_mode mode)
 {
 }
+bool efx_port_dummy_op_poll(struct efx_nic *efx)
+{
+	return false;
+}
 
 static struct efx_mac_operations efx_dummy_mac_operations = {
 	.reconfigure	= efx_port_dummy_op_void,
@@ -1915,9 +1898,8 @@ static struct efx_mac_operations efx_dummy_mac_operations = {
 static struct efx_phy_operations efx_dummy_phy_operations = {
 	.init		 = efx_port_dummy_op_int,
 	.reconfigure	 = efx_port_dummy_op_void,
-	.poll		 = efx_port_dummy_op_void,
+	.poll		 = efx_port_dummy_op_poll,
 	.fini		 = efx_port_dummy_op_void,
-	.clear_interrupt = efx_port_dummy_op_void,
 };
 
 /**************************************************************************
@@ -1957,7 +1939,6 @@ static int efx_init_struct(struct efx_nic *efx, struct efx_nic_type *type,
 	efx->mac_op = &efx_dummy_mac_operations;
 	efx->phy_op = &efx_dummy_phy_operations;
 	efx->mdio.dev = net_dev;
-	INIT_WORK(&efx->phy_work, efx_phy_work);
 	INIT_WORK(&efx->mac_work, efx_mac_work);
 	atomic_set(&efx->netif_stop_count, 1);
 
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 01b93f9..15edda2 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -90,6 +90,7 @@ extern int efx_port_dummy_op_int(struct efx_nic *efx);
 extern void efx_port_dummy_op_void(struct efx_nic *efx);
 extern void
 efx_port_dummy_op_set_id_led(struct efx_nic *efx, enum efx_led_mode mode);
+extern bool efx_port_dummy_op_poll(struct efx_nic *efx);
 
 /* MTD */
 #ifdef CONFIG_SFC_MTD
@@ -113,4 +114,6 @@ static inline void efx_schedule_channel(struct efx_channel *channel)
 	napi_schedule(&channel->napi_str);
 }
 
+extern void efx_link_status_changed(struct efx_nic *efx);
+
 #endif /* EFX_EFX_H */
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index e26043e..e16faad 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -893,8 +893,7 @@ static void falcon_handle_global_event(struct efx_channel *channel,
 	if (EFX_QWORD_FIELD(*event, FSF_AB_GLB_EV_G_PHY0_INTR) ||
 	    EFX_QWORD_FIELD(*event, FSF_AB_GLB_EV_XG_PHY0_INTR) ||
 	    EFX_QWORD_FIELD(*event, FSF_AB_GLB_EV_XFP_PHY0_INTR)) {
-		efx->phy_op->clear_interrupt(efx);
-		queue_work(efx->workqueue, &efx->phy_work);
+		/* Ignored */
 		handled = true;
 	}
 
@@ -1140,20 +1139,6 @@ void falcon_generate_test_event(struct efx_channel *channel, unsigned int magic)
 	falcon_generate_event(channel, &test_event);
 }
 
-void falcon_sim_phy_event(struct efx_nic *efx)
-{
-	efx_qword_t phy_event;
-
-	EFX_POPULATE_QWORD_1(phy_event, FSF_AZ_EV_CODE,
-			     FSE_AZ_EV_CODE_GLOBAL_EV);
-	if (EFX_IS10G(efx))
-		EFX_SET_QWORD_FIELD(phy_event, FSF_AB_GLB_EV_XG_PHY0_INTR, 1);
-	else
-		EFX_SET_QWORD_FIELD(phy_event, FSF_AB_GLB_EV_G_PHY0_INTR, 1);
-
-	falcon_generate_event(&efx->channel[0], &phy_event);
-}
-
 /**************************************************************************
  *
  * Flush handling
@@ -2063,6 +2048,25 @@ static void falcon_stats_timer_func(unsigned long context)
 	spin_unlock(&efx->stats_lock);
 }
 
+static bool falcon_loopback_link_poll(struct efx_nic *efx)
+{
+	struct efx_link_state old_state = efx->link_state;
+
+	WARN_ON(!mutex_is_locked(&efx->mac_lock));
+	WARN_ON(!LOOPBACK_INTERNAL(efx));
+
+	efx->link_state.fd = true;
+	efx->link_state.fc = efx->wanted_fc;
+	efx->link_state.up = true;
+
+	if (efx->loopback_mode == LOOPBACK_GMAC)
+		efx->link_state.speed = 1000;
+	else
+		efx->link_state.speed = 10000;
+
+	return !efx_link_state_equal(&efx->link_state, &old_state);
+}
+
 /**************************************************************************
  *
  * PHY access via GMII
@@ -2225,15 +2229,6 @@ int falcon_switch_mac(struct efx_nic *efx)
 	/* Don't try to fetch MAC stats while we're switching MACs */
 	falcon_stop_nic_stats(efx);
 
-	/* Internal loopbacks override the phy speed setting */
-	if (efx->loopback_mode == LOOPBACK_GMAC) {
-		efx->link_state.speed = 1000;
-		efx->link_state.fd = true;
-	} else if (LOOPBACK_INTERNAL(efx)) {
-		efx->link_state.speed = 10000;
-		efx->link_state.fd = true;
-	}
-
 	WARN_ON(!mutex_is_locked(&efx->mac_lock));
 	efx->mac_op = (EFX_IS10G(efx) ?
 		       &falcon_xmac_operations : &falcon_gmac_operations);
@@ -2610,16 +2605,36 @@ fail5:
 
 void falcon_monitor(struct efx_nic *efx)
 {
+	bool link_changed;
 	int rc;
 
+	BUG_ON(!mutex_is_locked(&efx->mac_lock));
+
 	rc = falcon_board(efx)->type->monitor(efx);
 	if (rc) {
 		EFX_ERR(efx, "Board sensor %s; shutting down PHY\n",
 			(rc == -ERANGE) ? "reported fault" : "failed");
 		efx->phy_mode |= PHY_MODE_LOW_POWER;
-		falcon_sim_phy_event(efx);
+		__efx_reconfigure_port(efx);
 	}
-	efx->phy_op->poll(efx);
+
+	if (LOOPBACK_INTERNAL(efx))
+		link_changed = falcon_loopback_link_poll(efx);
+	else
+		link_changed = efx->phy_op->poll(efx);
+
+	if (link_changed) {
+		falcon_stop_nic_stats(efx);
+		falcon_deconfigure_mac_wrapper(efx);
+
+		falcon_switch_mac(efx);
+		efx->mac_op->reconfigure(efx);
+
+		falcon_start_nic_stats(efx);
+
+		efx_link_status_changed(efx);
+	}
+
 	if (EFX_IS10G(efx))
 		falcon_poll_xmac(efx);
 }
diff --git a/drivers/net/sfc/falcon.h b/drivers/net/sfc/falcon.h
index c70bb08..a561f67 100644
--- a/drivers/net/sfc/falcon.h
+++ b/drivers/net/sfc/falcon.h
@@ -145,7 +145,6 @@ extern int falcon_init_interrupt(struct efx_nic *efx);
 extern void falcon_enable_interrupts(struct efx_nic *efx);
 extern void falcon_generate_test_event(struct efx_channel *channel,
 				       unsigned int magic);
-extern void falcon_sim_phy_event(struct efx_nic *efx);
 extern void falcon_generate_interrupt(struct efx_nic *efx);
 extern void falcon_set_int_moderation(struct efx_channel *channel);
 extern void falcon_disable_interrupts(struct efx_nic *efx);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index ead1c98..fb9327c 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -503,6 +503,13 @@ struct efx_link_state {
 	unsigned int speed;
 };
 
+static inline bool efx_link_state_equal(const struct efx_link_state *left,
+					const struct efx_link_state *right)
+{
+	return left->up == right->up && left->fd == right->fd &&
+		left->fc == right->fc && left->speed == right->speed;
+}
+
 /**
  * struct efx_mac_operations - Efx MAC operations table
  * @reconfigure: Reconfigure MAC. Serialised by the mac_lock
@@ -520,8 +527,8 @@ struct efx_mac_operations {
  * @init: Initialise PHY
  * @fini: Shut down PHY
  * @reconfigure: Reconfigure PHY (e.g. for new link parameters)
- * @clear_interrupt: Clear down interrupt
- * @poll: Poll for hardware state. Serialised by the mac_lock.
+ * @poll: Update @link_state and report whether it changed.
+ *	Serialised by the mac_lock.
  * @get_settings: Get ethtool settings. Serialised by the mac_lock.
  * @set_settings: Set ethtool settings. Serialised by the mac_lock.
  * @set_npage_adv: Set abilities advertised in (Extended) Next Page
@@ -538,8 +545,7 @@ struct efx_phy_operations {
 	int (*init) (struct efx_nic *efx);
 	void (*fini) (struct efx_nic *efx);
 	void (*reconfigure) (struct efx_nic *efx);
-	void (*clear_interrupt) (struct efx_nic *efx);
-	void (*poll) (struct efx_nic *efx);
+	bool (*poll) (struct efx_nic *efx);
 	void (*get_settings) (struct efx_nic *efx,
 			      struct ethtool_cmd *ecmd);
 	int (*set_settings) (struct efx_nic *efx,
@@ -700,10 +706,10 @@ union efx_multicast_hash {
  * @mac_lock: MAC access lock. Protects @port_enabled, @phy_mode,
  *	@port_inhibited, efx_monitor() and efx_reconfigure_port()
  * @port_enabled: Port enabled indicator.
- *	Serialises efx_stop_all(), efx_start_all(), efx_monitor(),
- *	efx_phy_work(), and efx_mac_work() with kernel interfaces. Safe to read
- *	under any one of the rtnl_lock, mac_lock, or netif_tx_lock, but all
- *	three must be held to modify it.
+ *	Serialises efx_stop_all(), efx_start_all(), efx_monitor() and
+ *	efx_mac_work() with kernel interfaces. Safe to read under any
+ *	one of the rtnl_lock, mac_lock, or netif_tx_lock, but all three must
+ *	be held to modify it.
  * @port_inhibited: If set, the netif_carrier is always off. Hold the mac_lock
  * @port_initialized: Port initialized?
  * @net_dev: Operating system network device. Consider holding the rtnl lock
@@ -729,7 +735,6 @@ union efx_multicast_hash {
  * @promiscuous: Promiscuous flag. Protected by netif_tx_lock.
  * @multicast_hash: Multicast hash table
  * @wanted_fc: Wanted flow control flags
- * @phy_work: work item for dealing with PHY events
  * @mac_work: Work item for changing MAC promiscuity and multicast hash
  * @loopback_mode: Loopback status
  * @loopback_modes: Supported loopback mode bitmask
@@ -802,7 +807,6 @@ struct efx_nic {
 
 	enum phy_type phy_type;
 	spinlock_t phy_lock;
-	struct work_struct phy_work;
 	struct efx_phy_operations *phy_op;
 	void *phy_data;
 	struct mdio_if_info mdio;
diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index f9c354e..1b174c3 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -167,29 +167,26 @@ static int qt202x_phy_init(struct efx_nic *efx)
 	return rc;
 }
 
-static void qt202x_phy_clear_interrupt(struct efx_nic *efx)
-{
-	/* Read to clear link status alarm */
-	efx_mdio_read(efx, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_STAT);
-}
-
 static int qt202x_link_ok(struct efx_nic *efx)
 {
 	return efx_mdio_links_ok(efx, QT202X_REQUIRED_DEVS);
 }
 
-static void qt202x_phy_poll(struct efx_nic *efx)
+static bool qt202x_phy_poll(struct efx_nic *efx)
 {
-	int link_up = qt202x_link_ok(efx);
-	/* Simulate a PHY event if link state has changed */
-	if (link_up != efx->link_state.up)
-		falcon_sim_phy_event(efx);
+	bool was_up = efx->link_state.up;
+
+	efx->link_state.up = qt202x_link_ok(efx);
+	efx->link_state.speed = 10000;
+	efx->link_state.fd = true;
+	efx->link_state.fc = efx->wanted_fc;
+
+	return efx->link_state.up != was_up;
 }
 
 static void qt202x_phy_reconfigure(struct efx_nic *efx)
 {
 	struct qt202x_phy_data *phy_data = efx->phy_data;
-	struct efx_link_state *link_state = &efx->link_state;
 
 	if (efx->phy_type == PHY_TYPE_QT2025C) {
 		/* There are several different register bits which can
@@ -216,10 +213,6 @@ static void qt202x_phy_reconfigure(struct efx_nic *efx)
 	efx_mdio_phy_reconfigure(efx);
 
 	phy_data->phy_mode = efx->phy_mode;
-	link_state->up = qt202x_link_ok(efx);
-	link_state->speed = 10000;
-	link_state->fd = true;
-	link_state->fc = efx->wanted_fc;
 }
 
 static void qt202x_phy_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
@@ -240,7 +233,6 @@ struct efx_phy_operations falcon_qt202x_phy_ops = {
 	.reconfigure	 = qt202x_phy_reconfigure,
 	.poll	     	 = qt202x_phy_poll,
 	.fini	  	 = qt202x_phy_fini,
-	.clear_interrupt = qt202x_phy_clear_interrupt,
 	.get_settings	 = qt202x_phy_get_settings,
 	.set_settings	 = efx_mdio_set_settings,
 	.mmds            = QT202X_REQUIRED_DEVS,
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index e6232fe..1bd7965 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -503,7 +503,6 @@ static void tenxpress_low_power(struct efx_nic *efx)
 static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data = efx->phy_data;
-	struct efx_link_state *link_state = &efx->link_state;
 	struct ethtool_cmd ecmd;
 	bool phy_mode_change, loop_reset;
 
@@ -544,53 +543,41 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 
 	phy_data->loopback_mode = efx->loopback_mode;
 	phy_data->phy_mode = efx->phy_mode;
-
-	if (efx->phy_type == PHY_TYPE_SFX7101) {
-		link_state->speed = 10000;
-		link_state->fd = true;
-		link_state->up = sfx7101_link_ok(efx);
-	} else {
-		efx->phy_op->get_settings(efx, &ecmd);
-		link_state->speed = ecmd.speed;
-		link_state->fd = ecmd.duplex == DUPLEX_FULL;
-		link_state->up = sft9001_link_ok(efx, &ecmd);
-	}
-	link_state->fc = efx_mdio_get_pause(efx);
 }
 
-/* Poll PHY for interrupt */
-static void tenxpress_phy_poll(struct efx_nic *efx)
+static void
+tenxpress_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd);
+
+/* Poll for link state changes */
+static bool tenxpress_phy_poll(struct efx_nic *efx)
 {
-	struct tenxpress_phy_data *phy_data = efx->phy_data;
-	struct efx_link_state *link_state = &efx->link_state;
-	bool change = false;
+	struct efx_link_state old_state = efx->link_state;
 
 	if (efx->phy_type == PHY_TYPE_SFX7101) {
-		bool link_ok = sfx7101_link_ok(efx);
-		if (link_ok != link_state->up) {
-			change = true;
-		} else {
-			unsigned int link_fc = efx_mdio_get_pause(efx);
-			if (link_fc != link_state->fc)
-				change = true;
-		}
-		sfx7101_check_bad_lp(efx, link_ok);
-	} else if (efx->loopback_mode) {
-		bool link_ok = sft9001_link_ok(efx, NULL);
-		if (link_ok != link_state->up)
-			change = true;
+		efx->link_state.up = sfx7101_link_ok(efx);
+		efx->link_state.speed = 10000;
+		efx->link_state.fd = true;
+		efx->link_state.fc = efx_mdio_get_pause(efx);
+
+		sfx7101_check_bad_lp(efx, efx->link_state.up);
 	} else {
-		int status = efx_mdio_read(efx, MDIO_MMD_PMAPMD,
-					   MDIO_PMA_LASI_STAT);
-		if (status & MDIO_PMA_LASI_LSALARM)
-			change = true;
-	}
+		struct ethtool_cmd ecmd;
 
-	if (change)
-		falcon_sim_phy_event(efx);
+		/* Check the LASI alarm first */
+		if (efx->loopback_mode == LOOPBACK_NONE &&
+		    !(efx_mdio_read(efx, MDIO_MMD_PMAPMD, MDIO_PMA_LASI_STAT) &
+		      MDIO_PMA_LASI_LSALARM))
+			return false;
 
-	if (phy_data->phy_mode != PHY_MODE_NORMAL)
-		return;
+		tenxpress_get_settings(efx, &ecmd);
+
+		efx->link_state.up = sft9001_link_ok(efx, &ecmd);
+		efx->link_state.speed = ecmd.speed;
+		efx->link_state.fd = (ecmd.duplex == DUPLEX_FULL);
+		efx->link_state.fc = efx_mdio_get_pause(efx);
+	}
+
+	return !efx_link_state_equal(&efx->link_state, &old_state);
 }
 
 static void tenxpress_phy_fini(struct efx_nic *efx)
@@ -818,7 +805,6 @@ struct efx_phy_operations falcon_sfx7101_phy_ops = {
 	.reconfigure      = tenxpress_phy_reconfigure,
 	.poll             = tenxpress_phy_poll,
 	.fini             = tenxpress_phy_fini,
-	.clear_interrupt  = efx_port_dummy_op_void,
 	.get_settings	  = tenxpress_get_settings,
 	.set_settings	  = tenxpress_set_settings,
 	.set_npage_adv    = sfx7101_set_npage_adv,
@@ -835,7 +821,6 @@ struct efx_phy_operations falcon_sft9001_phy_ops = {
 	.reconfigure      = tenxpress_phy_reconfigure,
 	.poll             = tenxpress_phy_poll,
 	.fini             = tenxpress_phy_fini,
-	.clear_interrupt  = efx_port_dummy_op_void,
 	.get_settings	  = tenxpress_get_settings,
 	.set_settings	  = tenxpress_set_settings,
 	.set_npage_adv    = sft9001_set_npage_adv,

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

