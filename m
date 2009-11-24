From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 13/17] sfc: Gather link state fields in struct efx_nic into
	new struct efx_link_state
Date: Tue, 24 Nov 2009 02:06:30 +0000
Message-ID: <1259028390.14645.29.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:34845 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752241AbZKXCG0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 21:06:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/efx.c           |   12 +++++++-----
 drivers/net/sfc/ethtool.c       |    4 ++--
 drivers/net/sfc/falcon.c        |   21 +++++++++++----------
 drivers/net/sfc/falcon_boards.c |    2 +-
 drivers/net/sfc/falcon_gmac.c   |   13 +++++++------
 drivers/net/sfc/falcon_xmac.c   |    8 ++++----
 drivers/net/sfc/net_driver.h    |   26 +++++++++++++++++---------
 drivers/net/sfc/qt202x_phy.c    |   11 ++++++-----
 drivers/net/sfc/selftest.c      |    2 +-
 drivers/net/sfc/tenxpress.c     |   22 ++++++++++++----------
 10 files changed, 68 insertions(+), 53 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index b913211..ea31141 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -543,6 +543,8 @@ void efx_schedule_slow_fill(struct efx_rx_queue *rx_queue, int delay)
  */
 static void efx_link_status_changed(struct efx_nic *efx)
 {
+	struct efx_link_state *link_state = &efx->link_state;
+
 	/* SFC Bug 5356: A net_dev notifier is registered, so we must ensure
 	 * that no events are triggered between unregister_netdev() and the
 	 * driver unloading. A more general condition is that NETDEV_CHANGE
@@ -555,19 +557,19 @@ static void efx_link_status_changed(struct efx_nic *efx)
 		return;
 	}
 
-	if (efx->link_up != netif_carrier_ok(efx->net_dev)) {
+	if (link_state->up != netif_carrier_ok(efx->net_dev)) {
 		efx->n_link_state_changes++;
 
-		if (efx->link_up)
+		if (link_state->up)
 			netif_carrier_on(efx->net_dev);
 		else
 			netif_carrier_off(efx->net_dev);
 	}
 
 	/* Status message for kernel log */
-	if (efx->link_up) {
+	if (link_state->up) {
 		EFX_INFO(efx, "link up at %uMbps %s-duplex (MTU %d)%s\n",
-			 efx->link_speed, efx->link_fd ? "full" : "half",
+			 link_state->speed, link_state->fd ? "full" : "half",
 			 efx->net_dev->mtu,
 			 (efx->promiscuous ? " [PROMISC]" : ""));
 	} else {
@@ -758,7 +760,7 @@ static void efx_fini_port(struct efx_nic *efx)
 	efx->phy_op->fini(efx);
 	efx->port_initialized = false;
 
-	efx->link_up = false;
+	efx->link_state.up = false;
 	efx_link_status_changed(efx);
 }
 
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index bb41532..eb12f20 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -539,7 +539,7 @@ static u32 efx_ethtool_get_link(struct net_device *net_dev)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 
-	return efx->link_up;
+	return efx->link_state.up;
 }
 
 static int efx_ethtool_get_eeprom_len(struct net_device *net_dev)
@@ -699,7 +699,7 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 	if (EFX_WORKAROUND_11482(efx) && reset) {
 		if (falcon_rev(efx) >= FALCON_REV_B0) {
 			/* Recover by resetting the EM block */
-			if (efx->link_up)
+			if (efx->link_state.up)
 				falcon_drain_tx_fifo(efx);
 		} else {
 			/* Schedule a reset to recover */
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index ff15b9d..6eee4b7 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1905,7 +1905,7 @@ static int falcon_reset_macs(struct efx_nic *efx)
 
 	/* If we've reset the EM block and the link is up, then
 	 * we'll have to kick the XAUI link so the PHY can recover */
-	if (efx->link_up && EFX_IS10G(efx) && EFX_WORKAROUND_5147(efx))
+	if (efx->link_state.up && EFX_IS10G(efx) && EFX_WORKAROUND_5147(efx))
 		falcon_reset_xaui(efx);
 
 	return 0;
@@ -1939,17 +1939,18 @@ void falcon_deconfigure_mac_wrapper(struct efx_nic *efx)
 	EFX_SET_OWORD_FIELD(reg, FRF_BZ_RX_INGR_EN, 0);
 	efx_writeo(efx, &reg, FR_AZ_RX_CFG);
 
-	if (!efx->link_up)
+	if (!efx->link_state.up)
 		falcon_drain_tx_fifo(efx);
 }
 
 void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 {
+	struct efx_link_state *link_state = &efx->link_state;
 	efx_oword_t reg;
 	int link_speed;
 	bool tx_fc;
 
-	switch (efx->link_speed) {
+	switch (link_state->speed) {
 	case 10000: link_speed = 3; break;
 	case 1000:  link_speed = 2; break;
 	case 100:   link_speed = 1; break;
@@ -1969,7 +1970,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	 * discarded. */
 	if (falcon_rev(efx) >= FALCON_REV_B0) {
 		EFX_SET_OWORD_FIELD(reg, FRF_BB_TXFIFO_DRAIN_EN,
-				    !efx->link_up);
+				    !link_state->up);
 	}
 
 	efx_writeo(efx, &reg, FR_AB_MAC_CTRL);
@@ -1980,7 +1981,7 @@ void falcon_reconfigure_mac_wrapper(struct efx_nic *efx)
 	/* Transmission of pause frames when RX crosses the threshold is
 	 * covered by RX_XOFF_MAC_EN and XM_TX_CFG_REG:XM_FCNTL.
 	 * Action on receipt of pause frames is controller by XM_DIS_FCNTL */
-	tx_fc = !!(efx->link_fc & EFX_FC_TX);
+	tx_fc = !!(efx->link_state.fc & EFX_FC_TX);
 	efx_reado(efx, &reg, FR_AZ_RX_CFG);
 	EFX_SET_OWORD_FIELD(reg, FRF_AZ_RX_XOFF_MAC_EN, tx_fc);
 
@@ -2175,11 +2176,11 @@ int falcon_switch_mac(struct efx_nic *efx)
 
 	/* Internal loopbacks override the phy speed setting */
 	if (efx->loopback_mode == LOOPBACK_GMAC) {
-		efx->link_speed = 1000;
-		efx->link_fd = true;
+		efx->link_state.speed = 1000;
+		efx->link_state.fd = true;
 	} else if (LOOPBACK_INTERNAL(efx)) {
-		efx->link_speed = 10000;
-		efx->link_fd = true;
+		efx->link_state.speed = 10000;
+		efx->link_state.fd = true;
 	}
 
 	WARN_ON(!mutex_is_locked(&efx->mac_lock));
@@ -2752,7 +2753,7 @@ static int falcon_probe_nic_variant(struct efx_nic *efx)
 	}
 
 	/* Initial assumed speed */
-	efx->link_speed = EFX_OWORD_FIELD(nic_stat, FRF_AB_STRAP_10G) ? 10000 : 1000;
+	efx->link_state.speed = EFX_OWORD_FIELD(nic_stat, FRF_AB_STRAP_10G) ? 10000 : 1000;
 
 	return 0;
 }
diff --git a/drivers/net/sfc/falcon_boards.c b/drivers/net/sfc/falcon_boards.c
index cdf7a0d..333ccc1 100644
--- a/drivers/net/sfc/falcon_boards.c
+++ b/drivers/net/sfc/falcon_boards.c
@@ -85,7 +85,7 @@ static int efx_check_lm87(struct efx_nic *efx, unsigned mask)
 	s32 alarms1, alarms2;
 
 	/* If link is up then do not monitor temperature */
-	if (EFX_WORKAROUND_7884(efx) && efx->link_up)
+	if (EFX_WORKAROUND_7884(efx) && efx->link_state.up)
 		return 0;
 
 	alarms1 = i2c_smbus_read_byte_data(client, LM87_REG_ALARMS1);
diff --git a/drivers/net/sfc/falcon_gmac.c b/drivers/net/sfc/falcon_gmac.c
index 8a1b80d..967f3fb 100644
--- a/drivers/net/sfc/falcon_gmac.c
+++ b/drivers/net/sfc/falcon_gmac.c
@@ -24,16 +24,17 @@
 
 static void falcon_reconfigure_gmac(struct efx_nic *efx)
 {
+	struct efx_link_state *link_state = &efx->link_state;
 	bool loopback, tx_fc, rx_fc, bytemode;
 	int if_mode;
 	unsigned int max_frame_len;
 	efx_oword_t reg;
 
 	/* Configuration register 1 */
-	tx_fc = (efx->link_fc & EFX_FC_TX) || !efx->link_fd;
-	rx_fc = !!(efx->link_fc & EFX_FC_RX);
+	tx_fc = (link_state->fc & EFX_FC_TX) || !link_state->fd;
+	rx_fc = !!(link_state->fc & EFX_FC_RX);
 	loopback = (efx->loopback_mode == LOOPBACK_GMAC);
-	bytemode = (efx->link_speed == 1000);
+	bytemode = (link_state->speed == 1000);
 
 	EFX_POPULATE_OWORD_5(reg,
 			     FRF_AB_GM_LOOP, loopback,
@@ -50,7 +51,7 @@ static void falcon_reconfigure_gmac(struct efx_nic *efx)
 			     FRF_AB_GM_IF_MODE, if_mode,
 			     FRF_AB_GM_PAD_CRC_EN, 1,
 			     FRF_AB_GM_LEN_CHK, 1,
-			     FRF_AB_GM_FD, efx->link_fd,
+			     FRF_AB_GM_FD, link_state->fd,
 			     FRF_AB_GM_PAMBL_LEN, 0x7/*datasheet recommended */);
 
 	efx_writeo(efx, &reg, FR_AB_GM_CFG2);
@@ -101,8 +102,8 @@ static void falcon_reconfigure_gmac(struct efx_nic *efx)
 	/* FIFO configuration register 5 */
 	efx_reado(efx, &reg, FR_AB_GMF_CFG5);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_CFGBYTMODE, bytemode);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_CFGHDPLX, !efx->link_fd);
-	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_HSTDRPLT64, !efx->link_fd);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_CFGHDPLX, !link_state->fd);
+	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_HSTDRPLT64, !link_state->fd);
 	EFX_SET_OWORD_FIELD(reg, FRF_AB_GMF_HSTFLTRFRMDC_PAUSE, 0);
 	efx_writeo(efx, &reg, FR_AB_GMF_CFG5);
 	udelay(10);
diff --git a/drivers/net/sfc/falcon_xmac.c b/drivers/net/sfc/falcon_xmac.c
index 7e57b4a..69cb55f 100644
--- a/drivers/net/sfc/falcon_xmac.c
+++ b/drivers/net/sfc/falcon_xmac.c
@@ -89,7 +89,7 @@ static void falcon_mask_status_intr(struct efx_nic *efx, bool enable)
 		return;
 
 	/* We expect xgmii faults if the wireside link is up */
-	if (!EFX_WORKAROUND_5147(efx) || !efx->link_up)
+	if (!EFX_WORKAROUND_5147(efx) || !efx->link_state.up)
 		return;
 
 	/* We can only use this interrupt to signal the negative edge of
@@ -132,7 +132,7 @@ bool falcon_xaui_link_ok(struct efx_nic *efx)
 	efx_writeo(efx, &reg, FR_AB_XX_CORE_STAT);
 
 	/* If the link is up, then check the phy side of the xaui link */
-	if (efx->link_up && link_ok)
+	if (efx->link_state.up && link_ok)
 		if (efx->phy_op->mmds & (1 << MDIO_MMD_PHYXS))
 			link_ok = efx_mdio_phyxgxs_lane_sync(efx);
 
@@ -143,7 +143,7 @@ static void falcon_reconfigure_xmac_core(struct efx_nic *efx)
 {
 	unsigned int max_frame_len;
 	efx_oword_t reg;
-	bool rx_fc = !!(efx->link_fc & EFX_FC_RX);
+	bool rx_fc = !!(efx->link_state.fc & EFX_FC_RX);
 
 	/* Configure MAC  - cut-thru mode is hard wired on */
 	EFX_POPULATE_DWORD_3(reg,
@@ -356,7 +356,7 @@ static void falcon_xmac_irq(struct efx_nic *efx)
 
 static void falcon_poll_xmac(struct efx_nic *efx)
 {
-	if (!EFX_WORKAROUND_5147(efx) || !efx->link_up || efx->mac_up)
+	if (!EFX_WORKAROUND_5147(efx) || !efx->link_state.up || efx->mac_up)
 		return;
 
 	falcon_mask_status_intr(efx, false);
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 55d45a7..f2df324 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -419,7 +419,7 @@ enum phy_type {
 	PHY_TYPE_MAX	/* Insert any new items before this */
 };
 
-#define EFX_IS10G(efx) ((efx)->link_speed == 10000)
+#define EFX_IS10G(efx) ((efx)->link_state.speed == 10000)
 
 enum nic_state {
 	STATE_INIT = 0,
@@ -468,6 +468,20 @@ enum efx_mac_type {
 };
 
 /**
+ * struct efx_link_state - Current state of the link
+ * @up: Link is up
+ * @fd: Link is full-duplex
+ * @fc: Actual flow control flags
+ * @speed: Link speed (Mbps)
+ */
+struct efx_link_state {
+	bool up;
+	bool fd;
+	enum efx_fc_type fc;
+	unsigned int speed;
+};
+
+/**
  * struct efx_mac_operations - Efx MAC operations table
  * @reconfigure: Reconfigure MAC. Serialised by the mac_lock
  * @update_stats: Update statistics
@@ -691,10 +705,7 @@ union efx_multicast_hash {
  * @mdio: PHY MDIO interface
  * @phy_mode: PHY operating mode. Serialised by @mac_lock.
  * @mac_up: MAC link state
- * @link_up: Link status
- * @link_fd: Link is full duplex
- * @link_fc: Actualy flow control flags
- * @link_speed: Link speed (Mbps)
+ * @link_state: Current state of the link
  * @n_link_state_changes: Number of times the link has changed state
  * @promiscuous: Promiscuous flag. Protected by netif_tx_lock.
  * @multicast_hash: Multicast hash table
@@ -780,10 +791,7 @@ struct efx_nic {
 	enum efx_phy_mode phy_mode;
 
 	bool mac_up;
-	bool link_up;
-	bool link_fd;
-	enum efx_fc_type link_fc;
-	unsigned int link_speed;
+	struct efx_link_state link_state;
 	unsigned int n_link_state_changes;
 
 	bool promiscuous;
diff --git a/drivers/net/sfc/qt202x_phy.c b/drivers/net/sfc/qt202x_phy.c
index 73bc5ad..8208ac0 100644
--- a/drivers/net/sfc/qt202x_phy.c
+++ b/drivers/net/sfc/qt202x_phy.c
@@ -182,13 +182,14 @@ static void qt202x_phy_poll(struct efx_nic *efx)
 {
 	int link_up = qt202x_link_ok(efx);
 	/* Simulate a PHY event if link state has changed */
-	if (link_up != efx->link_up)
+	if (link_up != efx->link_state.up)
 		falcon_sim_phy_event(efx);
 }
 
 static void qt202x_phy_reconfigure(struct efx_nic *efx)
 {
 	struct qt202x_phy_data *phy_data = efx->phy_data;
+	struct efx_link_state *link_state = &efx->link_state;
 
 	if (efx->phy_type == PHY_TYPE_QT2025C) {
 		/* There are several different register bits which can
@@ -215,10 +216,10 @@ static void qt202x_phy_reconfigure(struct efx_nic *efx)
 	efx_mdio_phy_reconfigure(efx);
 
 	phy_data->phy_mode = efx->phy_mode;
-	efx->link_up = qt202x_link_ok(efx);
-	efx->link_speed = 10000;
-	efx->link_fd = true;
-	efx->link_fc = efx->wanted_fc;
+	link_state->up = qt202x_link_ok(efx);
+	link_state->speed = 10000;
+	link_state->fd = true;
+	link_state->fc = efx->wanted_fc;
 }
 
 static void qt202x_phy_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
diff --git a/drivers/net/sfc/selftest.c b/drivers/net/sfc/selftest.c
index 7a9386f..70eb5f1 100644
--- a/drivers/net/sfc/selftest.c
+++ b/drivers/net/sfc/selftest.c
@@ -614,7 +614,7 @@ static int efx_test_loopbacks(struct efx_nic *efx, struct efx_self_tests *tests,
 			/* We need both the phy and xaui links to be ok.
 			 * rather than relying on the falcon_xmac irq/poll
 			 * regime, just poll xaui directly */
-			link_up = efx->link_up;
+			link_up = efx->link_state.up;
 			if (link_up && EFX_IS10G(efx) &&
 			    !falcon_xaui_link_ok(efx))
 				link_up = false;
diff --git a/drivers/net/sfc/tenxpress.c b/drivers/net/sfc/tenxpress.c
index cb5e057..b001f38 100644
--- a/drivers/net/sfc/tenxpress.c
+++ b/drivers/net/sfc/tenxpress.c
@@ -503,6 +503,7 @@ static void tenxpress_low_power(struct efx_nic *efx)
 static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data = efx->phy_data;
+	struct efx_link_state *link_state = &efx->link_state;
 	struct ethtool_cmd ecmd;
 	bool phy_mode_change, loop_reset;
 
@@ -545,37 +546,38 @@ static void tenxpress_phy_reconfigure(struct efx_nic *efx)
 	phy_data->phy_mode = efx->phy_mode;
 
 	if (efx->phy_type == PHY_TYPE_SFX7101) {
-		efx->link_speed = 10000;
-		efx->link_fd = true;
-		efx->link_up = sfx7101_link_ok(efx);
+		link_state->speed = 10000;
+		link_state->fd = true;
+		link_state->up = sfx7101_link_ok(efx);
 	} else {
 		efx->phy_op->get_settings(efx, &ecmd);
-		efx->link_speed = ecmd.speed;
-		efx->link_fd = ecmd.duplex == DUPLEX_FULL;
-		efx->link_up = sft9001_link_ok(efx, &ecmd);
+		link_state->speed = ecmd.speed;
+		link_state->fd = ecmd.duplex == DUPLEX_FULL;
+		link_state->up = sft9001_link_ok(efx, &ecmd);
 	}
-	efx->link_fc = efx_mdio_get_pause(efx);
+	link_state->fc = efx_mdio_get_pause(efx);
 }
 
 /* Poll PHY for interrupt */
 static void tenxpress_phy_poll(struct efx_nic *efx)
 {
 	struct tenxpress_phy_data *phy_data = efx->phy_data;
+	struct efx_link_state *link_state = &efx->link_state;
 	bool change = false;
 
 	if (efx->phy_type == PHY_TYPE_SFX7101) {
 		bool link_ok = sfx7101_link_ok(efx);
-		if (link_ok != efx->link_up) {
+		if (link_ok != link_state->up) {
 			change = true;
 		} else {
 			unsigned int link_fc = efx_mdio_get_pause(efx);
-			if (link_fc != efx->link_fc)
+			if (link_fc != link_state->fc)
 				change = true;
 		}
 		sfx7101_check_bad_lp(efx, link_ok);
 	} else if (efx->loopback_mode) {
 		bool link_ok = sft9001_link_ok(efx, NULL);
-		if (link_ok != efx->link_up)
+		if (link_ok != link_state->up)
 			change = true;
 	} else {
 		int status = efx_mdio_read(efx, MDIO_MMD_PMAPMD,

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

