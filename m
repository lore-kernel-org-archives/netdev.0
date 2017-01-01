From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH v2 2/2] net: sfc: falcon: use new api ethtool_{get|set}_link_ksettings
Date: Sun,  1 Jan 2017 19:02:46 +0100
Message-ID: <1483293766-4581-2-git-send-email-tremyfr@gmail.com>
References: <1483293766-4581-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: linux-net-drivers@solarflare.com, ecree@solarflare.com,
        bkenward@solarflare.com, davem@davemloft.net, andrew@lunn.ch,
        f.fainelli@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1483293766-4581-1-git-send-email-tremyfr@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
Changelog:
v2:
- simplify the code of ef4_ethtool_get_link_ksettings
  (feedback from Bert Kenward)

 drivers/net/ethernet/sfc/falcon/efx.c          |    2 +-
 drivers/net/ethernet/sfc/falcon/ethtool.c      |   29 +++++++++-------
 drivers/net/ethernet/sfc/falcon/mdio_10g.c     |   44 +++++++++++++++---------
 drivers/net/ethernet/sfc/falcon/mdio_10g.h     |    3 +-
 drivers/net/ethernet/sfc/falcon/net_driver.h   |   12 +++---
 drivers/net/ethernet/sfc/falcon/qt202x_phy.c   |    9 +++--
 drivers/net/ethernet/sfc/falcon/tenxpress.c    |   22 ++++++------
 drivers/net/ethernet/sfc/falcon/txc43128_phy.c |    9 +++--
 8 files changed, 74 insertions(+), 56 deletions(-)

diff --git a/drivers/net/ethernet/sfc/falcon/efx.c b/drivers/net/ethernet/sfc/falcon/efx.c
index 5c5cb3c..438ef9e 100644
--- a/drivers/net/ethernet/sfc/falcon/efx.c
+++ b/drivers/net/ethernet/sfc/falcon/efx.c
@@ -986,7 +986,7 @@ void ef4_mac_reconfigure(struct ef4_nic *efx)
 
 /* Push loopback/power/transmit disable settings to the PHY, and reconfigure
  * the MAC appropriately. All other PHY configuration changes are pushed
- * through phy_op->set_settings(), and pushed asynchronously to the MAC
+ * through phy_op->set_link_ksettings(), and pushed asynchronously to the MAC
  * through ef4_monitor().
  *
  * Callers must hold the mac_lock
diff --git a/drivers/net/ethernet/sfc/falcon/ethtool.c b/drivers/net/ethernet/sfc/falcon/ethtool.c
index 8e1929b..5604915 100644
--- a/drivers/net/ethernet/sfc/falcon/ethtool.c
+++ b/drivers/net/ethernet/sfc/falcon/ethtool.c
@@ -115,44 +115,47 @@ static int ef4_ethtool_phys_id(struct net_device *net_dev,
 }
 
 /* This must be called with rtnl_lock held. */
-static int ef4_ethtool_get_settings(struct net_device *net_dev,
-				    struct ethtool_cmd *ecmd)
+static int
+ef4_ethtool_get_link_ksettings(struct net_device *net_dev,
+			       struct ethtool_link_ksettings *cmd)
 {
 	struct ef4_nic *efx = netdev_priv(net_dev);
 	struct ef4_link_state *link_state = &efx->link_state;
 
 	mutex_lock(&efx->mac_lock);
-	efx->phy_op->get_settings(efx, ecmd);
+	efx->phy_op->get_link_ksettings(efx, cmd);
 	mutex_unlock(&efx->mac_lock);
 
 	/* Both MACs support pause frames (bidirectional and respond-only) */
-	ecmd->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
+	ethtool_link_ksettings_add_link_mode(cmd, supported, Pause);
+	ethtool_link_ksettings_add_link_mode(cmd, supported, Asym_Pause);
 
 	if (LOOPBACK_INTERNAL(efx)) {
-		ethtool_cmd_speed_set(ecmd, link_state->speed);
-		ecmd->duplex = link_state->fd ? DUPLEX_FULL : DUPLEX_HALF;
+		cmd->base.speed = link_state->speed;
+		cmd->base.duplex = link_state->fd ? DUPLEX_FULL : DUPLEX_HALF;
 	}
 
 	return 0;
 }
 
 /* This must be called with rtnl_lock held. */
-static int ef4_ethtool_set_settings(struct net_device *net_dev,
-				    struct ethtool_cmd *ecmd)
+static int
+ef4_ethtool_set_link_ksettings(struct net_device *net_dev,
+			       const struct ethtool_link_ksettings *cmd)
 {
 	struct ef4_nic *efx = netdev_priv(net_dev);
 	int rc;
 
 	/* GMAC does not support 1000Mbps HD */
-	if ((ethtool_cmd_speed(ecmd) == SPEED_1000) &&
-	    (ecmd->duplex != DUPLEX_FULL)) {
+	if ((cmd->base.speed == SPEED_1000) &&
+	    (cmd->base.duplex != DUPLEX_FULL)) {
 		netif_dbg(efx, drv, efx->net_dev,
 			  "rejecting unsupported 1000Mbps HD setting\n");
 		return -EINVAL;
 	}
 
 	mutex_lock(&efx->mac_lock);
-	rc = efx->phy_op->set_settings(efx, ecmd);
+	rc = efx->phy_op->set_link_ksettings(efx, cmd);
 	mutex_unlock(&efx->mac_lock);
 	return rc;
 }
@@ -1310,8 +1313,6 @@ static int ef4_ethtool_get_module_info(struct net_device *net_dev,
 }
 
 const struct ethtool_ops ef4_ethtool_ops = {
-	.get_settings		= ef4_ethtool_get_settings,
-	.set_settings		= ef4_ethtool_set_settings,
 	.get_drvinfo		= ef4_ethtool_get_drvinfo,
 	.get_regs_len		= ef4_ethtool_get_regs_len,
 	.get_regs		= ef4_ethtool_get_regs,
@@ -1340,4 +1341,6 @@ static int ef4_ethtool_get_module_info(struct net_device *net_dev,
 	.set_rxfh		= ef4_ethtool_set_rxfh,
 	.get_module_info	= ef4_ethtool_get_module_info,
 	.get_module_eeprom	= ef4_ethtool_get_module_eeprom,
+	.get_link_ksettings	= ef4_ethtool_get_link_ksettings,
+	.set_link_ksettings	= ef4_ethtool_set_link_ksettings,
 };
diff --git a/drivers/net/ethernet/sfc/falcon/mdio_10g.c b/drivers/net/ethernet/sfc/falcon/mdio_10g.c
index e7d7c09..ee0713f 100644
--- a/drivers/net/ethernet/sfc/falcon/mdio_10g.c
+++ b/drivers/net/ethernet/sfc/falcon/mdio_10g.c
@@ -226,33 +226,45 @@ void ef4_mdio_set_mmds_lpower(struct ef4_nic *efx,
 }
 
 /**
- * ef4_mdio_set_settings - Set (some of) the PHY settings over MDIO.
+ * ef4_mdio_set_link_ksettings - Set (some of) the PHY settings over MDIO.
  * @efx:		Efx NIC
- * @ecmd:		New settings
+ * @cmd:		New settings
  */
-int ef4_mdio_set_settings(struct ef4_nic *efx, struct ethtool_cmd *ecmd)
+int ef4_mdio_set_link_ksettings(struct ef4_nic *efx,
+				const struct ethtool_link_ksettings *cmd)
 {
-	struct ethtool_cmd prev = { .cmd = ETHTOOL_GSET };
-
-	efx->phy_op->get_settings(efx, &prev);
-
-	if (ecmd->advertising == prev.advertising &&
-	    ethtool_cmd_speed(ecmd) == ethtool_cmd_speed(&prev) &&
-	    ecmd->duplex == prev.duplex &&
-	    ecmd->port == prev.port &&
-	    ecmd->autoneg == prev.autoneg)
+	struct ethtool_link_ksettings prev = {
+		.base.cmd = ETHTOOL_GLINKSETTINGS
+	};
+	u32 prev_advertising, advertising;
+	u32 prev_supported;
+
+	efx->phy_op->get_link_ksettings(efx, &prev);
+
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
+	ethtool_convert_link_mode_to_legacy_u32(&prev_advertising,
+						prev.link_modes.advertising);
+	ethtool_convert_link_mode_to_legacy_u32(&prev_supported,
+						prev.link_modes.supported);
+
+	if (advertising == prev_advertising &&
+	    cmd->base.speed == prev.base.speed &&
+	    cmd->base.duplex == prev.base.duplex &&
+	    cmd->base.port == prev.base.port &&
+	    cmd->base.autoneg == prev.base.autoneg)
 		return 0;
 
 	/* We can only change these settings for -T PHYs */
-	if (prev.port != PORT_TP || ecmd->port != PORT_TP)
+	if (prev.base.port != PORT_TP || cmd->base.port != PORT_TP)
 		return -EINVAL;
 
 	/* Check that PHY supports these settings */
-	if (!ecmd->autoneg ||
-	    (ecmd->advertising | SUPPORTED_Autoneg) & ~prev.supported)
+	if (!cmd->base.autoneg ||
+	    (advertising | SUPPORTED_Autoneg) & ~prev_supported)
 		return -EINVAL;
 
-	ef4_link_set_advertising(efx, ecmd->advertising | ADVERTISED_Autoneg);
+	ef4_link_set_advertising(efx, advertising | ADVERTISED_Autoneg);
 	ef4_mdio_an_reconfigure(efx);
 	return 0;
 }
diff --git a/drivers/net/ethernet/sfc/falcon/mdio_10g.h b/drivers/net/ethernet/sfc/falcon/mdio_10g.h
index 885cf7a..53cb5cc 100644
--- a/drivers/net/ethernet/sfc/falcon/mdio_10g.h
+++ b/drivers/net/ethernet/sfc/falcon/mdio_10g.h
@@ -83,7 +83,8 @@ void ef4_mdio_set_mmds_lpower(struct ef4_nic *efx, int low_power,
 			      unsigned int mmd_mask);
 
 /* Set (some of) the PHY settings over MDIO */
-int ef4_mdio_set_settings(struct ef4_nic *efx, struct ethtool_cmd *ecmd);
+int ef4_mdio_set_link_ksettings(struct ef4_nic *efx,
+				const struct ethtool_link_ksettings *cmd);
 
 /* Push advertising flags and restart autonegotiation */
 void ef4_mdio_an_reconfigure(struct ef4_nic *efx);
diff --git a/drivers/net/ethernet/sfc/falcon/net_driver.h b/drivers/net/ethernet/sfc/falcon/net_driver.h
index 210b28f..fe59dd6 100644
--- a/drivers/net/ethernet/sfc/falcon/net_driver.h
+++ b/drivers/net/ethernet/sfc/falcon/net_driver.h
@@ -684,8 +684,8 @@ static inline bool ef4_link_state_equal(const struct ef4_link_state *left,
  * @reconfigure: Reconfigure PHY (e.g. for new link parameters)
  * @poll: Update @link_state and report whether it changed.
  *	Serialised by the mac_lock.
- * @get_settings: Get ethtool settings. Serialised by the mac_lock.
- * @set_settings: Set ethtool settings. Serialised by the mac_lock.
+ * @get_link_ksettings: Get ethtool settings. Serialised by the mac_lock.
+ * @set_link_ksettings: Set ethtool settings. Serialised by the mac_lock.
  * @set_npage_adv: Set abilities advertised in (Extended) Next Page
  *	(only needed where AN bit is set in mmds)
  * @test_alive: Test that PHY is 'alive' (online)
@@ -700,10 +700,10 @@ struct ef4_phy_operations {
 	void (*remove) (struct ef4_nic *efx);
 	int (*reconfigure) (struct ef4_nic *efx);
 	bool (*poll) (struct ef4_nic *efx);
-	void (*get_settings) (struct ef4_nic *efx,
-			      struct ethtool_cmd *ecmd);
-	int (*set_settings) (struct ef4_nic *efx,
-			     struct ethtool_cmd *ecmd);
+	void (*get_link_ksettings)(struct ef4_nic *efx,
+				   struct ethtool_link_ksettings *cmd);
+	int (*set_link_ksettings)(struct ef4_nic *efx,
+				  const struct ethtool_link_ksettings *cmd);
 	void (*set_npage_adv) (struct ef4_nic *efx, u32);
 	int (*test_alive) (struct ef4_nic *efx);
 	const char *(*test_name) (struct ef4_nic *efx, unsigned int index);
diff --git a/drivers/net/ethernet/sfc/falcon/qt202x_phy.c b/drivers/net/ethernet/sfc/falcon/qt202x_phy.c
index d293316..f5e0f18 100644
--- a/drivers/net/ethernet/sfc/falcon/qt202x_phy.c
+++ b/drivers/net/ethernet/sfc/falcon/qt202x_phy.c
@@ -437,9 +437,10 @@ static int qt202x_phy_reconfigure(struct ef4_nic *efx)
 	return 0;
 }
 
-static void qt202x_phy_get_settings(struct ef4_nic *efx, struct ethtool_cmd *ecmd)
+static void qt202x_phy_get_link_ksettings(struct ef4_nic *efx,
+					  struct ethtool_link_ksettings *cmd)
 {
-	mdio45_ethtool_gset(&efx->mdio, ecmd);
+	mdio45_ethtool_ksettings_get(&efx->mdio, cmd);
 }
 
 static void qt202x_phy_remove(struct ef4_nic *efx)
@@ -487,8 +488,8 @@ static int qt202x_phy_get_module_eeprom(struct ef4_nic *efx,
 	.poll		 = qt202x_phy_poll,
 	.fini		 = ef4_port_dummy_op_void,
 	.remove		 = qt202x_phy_remove,
-	.get_settings	 = qt202x_phy_get_settings,
-	.set_settings	 = ef4_mdio_set_settings,
+	.get_link_ksettings = qt202x_phy_get_link_ksettings,
+	.set_link_ksettings = ef4_mdio_set_link_ksettings,
 	.test_alive	 = ef4_mdio_test_alive,
 	.get_module_eeprom = qt202x_phy_get_module_eeprom,
 	.get_module_info = qt202x_phy_get_module_info,
diff --git a/drivers/net/ethernet/sfc/falcon/tenxpress.c b/drivers/net/ethernet/sfc/falcon/tenxpress.c
index acc548a..ff9b4e2 100644
--- a/drivers/net/ethernet/sfc/falcon/tenxpress.c
+++ b/drivers/net/ethernet/sfc/falcon/tenxpress.c
@@ -351,9 +351,6 @@ static int tenxpress_phy_reconfigure(struct ef4_nic *efx)
 	return 0;
 }
 
-static void
-tenxpress_get_settings(struct ef4_nic *efx, struct ethtool_cmd *ecmd);
-
 /* Poll for link state changes */
 static bool tenxpress_phy_poll(struct ef4_nic *efx)
 {
@@ -443,7 +440,8 @@ void tenxpress_set_id_led(struct ef4_nic *efx, enum ef4_led_mode mode)
 }
 
 static void
-tenxpress_get_settings(struct ef4_nic *efx, struct ethtool_cmd *ecmd)
+tenxpress_get_link_ksettings(struct ef4_nic *efx,
+			     struct ethtool_link_ksettings *cmd)
 {
 	u32 adv = 0, lpa = 0;
 	int reg;
@@ -455,20 +453,22 @@ void tenxpress_set_id_led(struct ef4_nic *efx, enum ef4_led_mode mode)
 	if (reg & MDIO_AN_10GBT_STAT_LP10G)
 		lpa |= ADVERTISED_10000baseT_Full;
 
-	mdio45_ethtool_gset_npage(&efx->mdio, ecmd, adv, lpa);
+	mdio45_ethtool_ksettings_get_npage(&efx->mdio, cmd, adv, lpa);
 
 	/* In loopback, the PHY automatically brings up the correct interface,
 	 * but doesn't advertise the correct speed. So override it */
 	if (LOOPBACK_EXTERNAL(efx))
-		ethtool_cmd_speed_set(ecmd, SPEED_10000);
+		cmd->base.speed = SPEED_10000;
 }
 
-static int tenxpress_set_settings(struct ef4_nic *efx, struct ethtool_cmd *ecmd)
+static int
+tenxpress_set_link_ksettings(struct ef4_nic *efx,
+			     const struct ethtool_link_ksettings *cmd)
 {
-	if (!ecmd->autoneg)
+	if (!cmd->base.autoneg)
 		return -EINVAL;
 
-	return ef4_mdio_set_settings(efx, ecmd);
+	return ef4_mdio_set_link_ksettings(efx, cmd);
 }
 
 static void sfx7101_set_npage_adv(struct ef4_nic *efx, u32 advertising)
@@ -485,8 +485,8 @@ static void sfx7101_set_npage_adv(struct ef4_nic *efx, u32 advertising)
 	.poll             = tenxpress_phy_poll,
 	.fini             = sfx7101_phy_fini,
 	.remove		  = tenxpress_phy_remove,
-	.get_settings	  = tenxpress_get_settings,
-	.set_settings	  = tenxpress_set_settings,
+	.get_link_ksettings = tenxpress_get_link_ksettings,
+	.set_link_ksettings = tenxpress_set_link_ksettings,
 	.set_npage_adv    = sfx7101_set_npage_adv,
 	.test_alive	  = ef4_mdio_test_alive,
 	.test_name	  = sfx7101_test_name,
diff --git a/drivers/net/ethernet/sfc/falcon/txc43128_phy.c b/drivers/net/ethernet/sfc/falcon/txc43128_phy.c
index 18421f5..3c55fd2 100644
--- a/drivers/net/ethernet/sfc/falcon/txc43128_phy.c
+++ b/drivers/net/ethernet/sfc/falcon/txc43128_phy.c
@@ -540,9 +540,10 @@ static int txc43128_run_tests(struct ef4_nic *efx, int *results, unsigned flags)
 	return rc;
 }
 
-static void txc43128_get_settings(struct ef4_nic *efx, struct ethtool_cmd *ecmd)
+static void txc43128_get_link_ksettings(struct ef4_nic *efx,
+					struct ethtool_link_ksettings *cmd)
 {
-	mdio45_ethtool_gset(&efx->mdio, ecmd);
+	mdio45_ethtool_ksettings_get(&efx->mdio, cmd);
 }
 
 const struct ef4_phy_operations falcon_txc_phy_ops = {
@@ -552,8 +553,8 @@ static void txc43128_get_settings(struct ef4_nic *efx, struct ethtool_cmd *ecmd)
 	.poll		= txc43128_phy_poll,
 	.fini		= txc43128_phy_fini,
 	.remove		= txc43128_phy_remove,
-	.get_settings	= txc43128_get_settings,
-	.set_settings	= ef4_mdio_set_settings,
+	.get_link_ksettings = txc43128_get_link_ksettings,
+	.set_link_ksettings = ef4_mdio_set_link_ksettings,
 	.test_alive	= ef4_mdio_test_alive,
 	.run_tests	= txc43128_run_tests,
 	.test_name	= txc43128_test_name,
-- 
1.7.4.4
