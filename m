From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH] net: sfc: use new api ethtool_{get|set}_link_ksettings
Date: Thu, 15 Dec 2016 00:12:53 +0100
Message-ID: <1481757173-16000-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Philippe Reynes <tremyfr@gmail.com>
To: linux-net-drivers@solarflare.com, ecree@solarflare.com,
        bkenward@solarflare.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The ethtool api {get|set}_settings is deprecated.
We move this driver to new api {get|set}_link_ksettings.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/sfc/ethtool.c    |   35 ++++++++++++-------
 drivers/net/ethernet/sfc/mcdi_port.c  |   60 ++++++++++++++++++++------------
 drivers/net/ethernet/sfc/net_driver.h |   12 +++---
 3 files changed, 65 insertions(+), 42 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index f644216..87bdc56 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -120,44 +120,53 @@ static int efx_ethtool_phys_id(struct net_device *net_dev,
 }
 
 /* This must be called with rtnl_lock held. */
-static int efx_ethtool_get_settings(struct net_device *net_dev,
-				    struct ethtool_cmd *ecmd)
+static int
+efx_ethtool_get_link_ksettings(struct net_device *net_dev,
+			       struct ethtool_link_ksettings *cmd)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
 	struct efx_link_state *link_state = &efx->link_state;
+	u32 supported;
 
 	mutex_lock(&efx->mac_lock);
-	efx->phy_op->get_settings(efx, ecmd);
+	efx->phy_op->get_link_ksettings(efx, cmd);
 	mutex_unlock(&efx->mac_lock);
 
 	/* Both MACs support pause frames (bidirectional and respond-only) */
-	ecmd->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
+	ethtool_convert_link_mode_to_legacy_u32(&supported,
+						cmd->link_modes.supported);
+
+	supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
 
 	if (LOOPBACK_INTERNAL(efx)) {
-		ethtool_cmd_speed_set(ecmd, link_state->speed);
-		ecmd->duplex = link_state->fd ? DUPLEX_FULL : DUPLEX_HALF;
+		cmd->base.speed = link_state->speed;
+		cmd->base.duplex = link_state->fd ? DUPLEX_FULL : DUPLEX_HALF;
 	}
 
 	return 0;
 }
 
 /* This must be called with rtnl_lock held. */
-static int efx_ethtool_set_settings(struct net_device *net_dev,
-				    struct ethtool_cmd *ecmd)
+static int
+efx_ethtool_set_link_ksettings(struct net_device *net_dev,
+			       const struct ethtool_link_ksettings *cmd)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
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
@@ -1342,8 +1351,6 @@ static int efx_ethtool_get_module_info(struct net_device *net_dev,
 }
 
 const struct ethtool_ops efx_ethtool_ops = {
-	.get_settings		= efx_ethtool_get_settings,
-	.set_settings		= efx_ethtool_set_settings,
 	.get_drvinfo		= efx_ethtool_get_drvinfo,
 	.get_regs_len		= efx_ethtool_get_regs_len,
 	.get_regs		= efx_ethtool_get_regs,
@@ -1373,4 +1380,6 @@ static int efx_ethtool_get_module_info(struct net_device *net_dev,
 	.get_ts_info		= efx_ethtool_get_ts_info,
 	.get_module_info	= efx_ethtool_get_module_info,
 	.get_module_eeprom	= efx_ethtool_get_module_eeprom,
+	.get_link_ksettings	= efx_ethtool_get_link_ksettings,
+	.set_link_ksettings	= efx_ethtool_set_link_ksettings,
 };
diff --git a/drivers/net/ethernet/sfc/mcdi_port.c b/drivers/net/ethernet/sfc/mcdi_port.c
index 9dcd396..c905971 100644
--- a/drivers/net/ethernet/sfc/mcdi_port.c
+++ b/drivers/net/ethernet/sfc/mcdi_port.c
@@ -503,45 +503,59 @@ static void efx_mcdi_phy_remove(struct efx_nic *efx)
 	kfree(phy_data);
 }
 
-static void efx_mcdi_phy_get_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+static void efx_mcdi_phy_get_link_ksettings(struct efx_nic *efx,
+					    struct ethtool_link_ksettings *cmd)
 {
 	struct efx_mcdi_phy_data *phy_cfg = efx->phy_data;
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_LINK_OUT_LEN);
 	int rc;
-
-	ecmd->supported =
-		mcdi_to_ethtool_cap(phy_cfg->media, phy_cfg->supported_cap);
-	ecmd->advertising = efx->link_advertising;
-	ethtool_cmd_speed_set(ecmd, efx->link_state.speed);
-	ecmd->duplex = efx->link_state.fd;
-	ecmd->port = mcdi_to_ethtool_media(phy_cfg->media);
-	ecmd->phy_address = phy_cfg->port;
-	ecmd->transceiver = XCVR_INTERNAL;
-	ecmd->autoneg = !!(efx->link_advertising & ADVERTISED_Autoneg);
-	ecmd->mdio_support = (efx->mdio.mode_support &
+	u32 supported, advertising, lp_advertising;
+
+	supported = mcdi_to_ethtool_cap(phy_cfg->media, phy_cfg->supported_cap);
+	advertising = efx->link_advertising;
+	cmd->base.speed = efx->link_state.speed;
+	cmd->base.duplex = efx->link_state.fd;
+	cmd->base.port = mcdi_to_ethtool_media(phy_cfg->media);
+	cmd->base.phy_address = phy_cfg->port;
+	cmd->base.autoneg = !!(efx->link_advertising & ADVERTISED_Autoneg);
+	cmd->base.mdio_support = (efx->mdio.mode_support &
 			      (MDIO_SUPPORTS_C45 | MDIO_SUPPORTS_C22));
 
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.supported,
+						supported);
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.advertising,
+						advertising);
+
 	BUILD_BUG_ON(MC_CMD_GET_LINK_IN_LEN != 0);
 	rc = efx_mcdi_rpc(efx, MC_CMD_GET_LINK, NULL, 0,
 			  outbuf, sizeof(outbuf), NULL);
 	if (rc)
 		return;
-	ecmd->lp_advertising =
+	lp_advertising =
 		mcdi_to_ethtool_cap(phy_cfg->media,
 				    MCDI_DWORD(outbuf, GET_LINK_OUT_LP_CAP));
+
+	ethtool_convert_legacy_u32_to_link_mode(cmd->link_modes.lp_advertising,
+						lp_advertising);
 }
 
-static int efx_mcdi_phy_set_settings(struct efx_nic *efx, struct ethtool_cmd *ecmd)
+static int
+efx_mcdi_phy_set_link_ksettings(struct efx_nic *efx,
+				const struct ethtool_link_ksettings *cmd)
 {
 	struct efx_mcdi_phy_data *phy_cfg = efx->phy_data;
 	u32 caps;
 	int rc;
+	u32 advertising;
+
+	ethtool_convert_link_mode_to_legacy_u32(&advertising,
+						cmd->link_modes.advertising);
 
-	if (ecmd->autoneg) {
-		caps = (ethtool_to_mcdi_cap(ecmd->advertising) |
+	if (cmd->base.autoneg) {
+		caps = (ethtool_to_mcdi_cap(advertising) |
 			 1 << MC_CMD_PHY_CAP_AN_LBN);
-	} else if (ecmd->duplex) {
-		switch (ethtool_cmd_speed(ecmd)) {
+	} else if (cmd->base.duplex) {
+		switch (cmd->base.speed) {
 		case 10:    caps = 1 << MC_CMD_PHY_CAP_10FDX_LBN;    break;
 		case 100:   caps = 1 << MC_CMD_PHY_CAP_100FDX_LBN;   break;
 		case 1000:  caps = 1 << MC_CMD_PHY_CAP_1000FDX_LBN;  break;
@@ -550,7 +564,7 @@ static int efx_mcdi_phy_set_settings(struct efx_nic *efx, struct ethtool_cmd *ec
 		default:    return -EINVAL;
 		}
 	} else {
-		switch (ethtool_cmd_speed(ecmd)) {
+		switch (cmd->base.speed) {
 		case 10:    caps = 1 << MC_CMD_PHY_CAP_10HDX_LBN;    break;
 		case 100:   caps = 1 << MC_CMD_PHY_CAP_100HDX_LBN;   break;
 		case 1000:  caps = 1 << MC_CMD_PHY_CAP_1000HDX_LBN;  break;
@@ -563,9 +577,9 @@ static int efx_mcdi_phy_set_settings(struct efx_nic *efx, struct ethtool_cmd *ec
 	if (rc)
 		return rc;
 
-	if (ecmd->autoneg) {
+	if (cmd->base.autoneg) {
 		efx_link_set_advertising(
-			efx, ecmd->advertising | ADVERTISED_Autoneg);
+			efx, advertising | ADVERTISED_Autoneg);
 		phy_cfg->forced_cap = 0;
 	} else {
 		efx_link_set_advertising(efx, 0);
@@ -812,8 +826,8 @@ static int efx_mcdi_phy_get_module_info(struct efx_nic *efx,
 	.poll		= efx_mcdi_phy_poll,
 	.fini		= efx_port_dummy_op_void,
 	.remove		= efx_mcdi_phy_remove,
-	.get_settings	= efx_mcdi_phy_get_settings,
-	.set_settings	= efx_mcdi_phy_set_settings,
+	.get_link_ksettings = efx_mcdi_phy_get_link_ksettings,
+	.set_link_ksettings = efx_mcdi_phy_set_link_ksettings,
 	.test_alive	= efx_mcdi_phy_test_alive,
 	.run_tests	= efx_mcdi_phy_run_tests,
 	.test_name	= efx_mcdi_phy_test_name,
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 8692e82..1a635ce 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -720,8 +720,8 @@ static inline bool efx_link_state_equal(const struct efx_link_state *left,
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
@@ -736,10 +736,10 @@ struct efx_phy_operations {
 	void (*remove) (struct efx_nic *efx);
 	int (*reconfigure) (struct efx_nic *efx);
 	bool (*poll) (struct efx_nic *efx);
-	void (*get_settings) (struct efx_nic *efx,
-			      struct ethtool_cmd *ecmd);
-	int (*set_settings) (struct efx_nic *efx,
-			     struct ethtool_cmd *ecmd);
+	void (*get_link_ksettings)(struct efx_nic *efx,
+				   struct ethtool_link_ksettings *cmd);
+	int (*set_link_ksettings)(struct efx_nic *efx,
+				  const struct ethtool_link_ksettings *cmd);
 	void (*set_npage_adv) (struct efx_nic *efx, u32);
 	int (*test_alive) (struct efx_nic *efx);
 	const char *(*test_name) (struct efx_nic *efx, unsigned int index);
-- 
1.7.4.4
