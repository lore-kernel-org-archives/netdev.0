From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v1 18/18] net: mlx4: use new ETHTOOL_G/SSETTINGS API
Date: Mon, 26 Jan 2015 17:36:14 -0800
Message-ID: <1422322574-6188-19-git-send-email-ddecotig@gmail.com>
References: <1422322574-6188-1-git-send-email-ddecotig@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
	Eugenia Emantayev <eugenia@mellanox.co.il>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Joe Perches <joe@perches.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Govindarajulu Varadarajan <_govind@gmx.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Eyal Perry <eyalpe@mellanox.com>,
	Pravin B Shelar <pshelar@nicira.com>,
	Ed Swierk <eswierk@skyportsystems.com>,
	David Decotigny <decot@googlers.com>
To: "David S. Miller" <davem@davemloft.net>,
	Ben Hutchings <ben@decadent.org.uk>,
	Amir Vadai <amirv@mellanox.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-api@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1422322574-6188-1-git-send-email-ddecotig@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>

Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 326 ++++++++++++------------
 drivers/net/ethernet/mellanox/mlx4/en_main.c    |   1 +
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |   1 +
 3 files changed, 161 insertions(+), 167 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 569eda9..4ad34064 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -388,34 +388,30 @@ static u32 mlx4_en_autoneg_get(struct net_device *dev)
 	return autoneg;
 }
 
-static u32 ptys_get_supported_port(struct mlx4_ptys_reg *ptys_reg)
+static void ptys2ethtool_update_supported_port(ethtool_link_mode_mask_t *mask,
+					       struct mlx4_ptys_reg *ptys_reg)
 {
 	u32 eth_proto = be32_to_cpu(ptys_reg->eth_proto_cap);
 
 	if (eth_proto & (MLX4_PROT_MASK(MLX4_10GBASE_T)
 			 | MLX4_PROT_MASK(MLX4_1000BASE_T)
 			 | MLX4_PROT_MASK(MLX4_100BASE_TX))) {
-			return SUPPORTED_TP;
-	}
-
-	if (eth_proto & (MLX4_PROT_MASK(MLX4_10GBASE_CR)
+		ethtool_add_link_modes(mask, ETHTOOL_LINK_MODE_TP_BIT);
+	} else if (eth_proto & (MLX4_PROT_MASK(MLX4_10GBASE_CR)
 			 | MLX4_PROT_MASK(MLX4_10GBASE_SR)
 			 | MLX4_PROT_MASK(MLX4_56GBASE_SR4)
 			 | MLX4_PROT_MASK(MLX4_40GBASE_CR4)
 			 | MLX4_PROT_MASK(MLX4_40GBASE_SR4)
 			 | MLX4_PROT_MASK(MLX4_1000BASE_CX_SGMII))) {
-			return SUPPORTED_FIBRE;
-	}
-
-	if (eth_proto & (MLX4_PROT_MASK(MLX4_56GBASE_KR4)
+		ethtool_add_link_modes(mask, ETHTOOL_LINK_MODE_FIBRE_BIT);
+	} else if (eth_proto & (MLX4_PROT_MASK(MLX4_56GBASE_KR4)
 			 | MLX4_PROT_MASK(MLX4_40GBASE_KR4)
 			 | MLX4_PROT_MASK(MLX4_20GBASE_KR2)
 			 | MLX4_PROT_MASK(MLX4_10GBASE_KR)
 			 | MLX4_PROT_MASK(MLX4_10GBASE_KX4)
 			 | MLX4_PROT_MASK(MLX4_1000BASE_KX))) {
-			return SUPPORTED_Backplane;
+		ethtool_add_link_modes(mask, ETHTOOL_LINK_MODE_Backplane_BIT);
 	}
-	return 0;
 }
 
 static u32 ptys_get_active_port(struct mlx4_ptys_reg *ptys_reg)
@@ -461,122 +457,91 @@ static u32 ptys_get_active_port(struct mlx4_ptys_reg *ptys_reg)
 enum ethtool_report {
 	SUPPORTED = 0,
 	ADVERTISED = 1,
-	SPEED = 2
 };
 
+struct ptys2ethtool_config {
+	ethtool_link_mode_mask_t link_modes[2];  /* SUPPORTED/ADVERTISED */
+	u32 speed;
+};
+
+#define MLX4_BUILD_PTYS2ETHTOOL_CONFIG(reg_, speed_, ...)		\
+	({								\
+		struct ptys2ethtool_config *cfg;			\
+		cfg = &ptys2ethtool_map[reg_];				\
+		cfg->speed = speed_;					\
+		ethtool_build_link_mode(&cfg->link_modes[SUPPORTED],	\
+					__VA_ARGS__);			\
+		ethtool_build_link_mode(&cfg->link_modes[ADVERTISED],	\
+					__VA_ARGS__);			\
+	})
+
 /* Translates mlx4 link mode to equivalent ethtool Link modes/speed */
-static u32 ptys2ethtool_map[MLX4_LINK_MODES_SZ][3] = {
-	[MLX4_100BASE_TX] = {
-		SUPPORTED_100baseT_Full,
-		ADVERTISED_100baseT_Full,
-		SPEED_100
-		},
-
-	[MLX4_1000BASE_T] = {
-		SUPPORTED_1000baseT_Full,
-		ADVERTISED_1000baseT_Full,
-		SPEED_1000
-		},
-	[MLX4_1000BASE_CX_SGMII] = {
-		SUPPORTED_1000baseKX_Full,
-		ADVERTISED_1000baseKX_Full,
-		SPEED_1000
-		},
-	[MLX4_1000BASE_KX] = {
-		SUPPORTED_1000baseKX_Full,
-		ADVERTISED_1000baseKX_Full,
-		SPEED_1000
-		},
-
-	[MLX4_10GBASE_T] = {
-		SUPPORTED_10000baseT_Full,
-		ADVERTISED_10000baseT_Full,
-		SPEED_10000
-		},
-	[MLX4_10GBASE_CX4] = {
-		SUPPORTED_10000baseKX4_Full,
-		ADVERTISED_10000baseKX4_Full,
-		SPEED_10000
-		},
-	[MLX4_10GBASE_KX4] = {
-		SUPPORTED_10000baseKX4_Full,
-		ADVERTISED_10000baseKX4_Full,
-		SPEED_10000
-		},
-	[MLX4_10GBASE_KR] = {
-		SUPPORTED_10000baseKR_Full,
-		ADVERTISED_10000baseKR_Full,
-		SPEED_10000
-		},
-	[MLX4_10GBASE_CR] = {
-		SUPPORTED_10000baseKR_Full,
-		ADVERTISED_10000baseKR_Full,
-		SPEED_10000
-		},
-	[MLX4_10GBASE_SR] = {
-		SUPPORTED_10000baseKR_Full,
-		ADVERTISED_10000baseKR_Full,
-		SPEED_10000
-		},
-
-	[MLX4_20GBASE_KR2] = {
-		SUPPORTED_20000baseMLD2_Full | SUPPORTED_20000baseKR2_Full,
-		ADVERTISED_20000baseMLD2_Full | ADVERTISED_20000baseKR2_Full,
-		SPEED_20000
-		},
-
-	[MLX4_40GBASE_CR4] = {
-		SUPPORTED_40000baseCR4_Full,
-		ADVERTISED_40000baseCR4_Full,
-		SPEED_40000
-		},
-	[MLX4_40GBASE_KR4] = {
-		SUPPORTED_40000baseKR4_Full,
-		ADVERTISED_40000baseKR4_Full,
-		SPEED_40000
-		},
-	[MLX4_40GBASE_SR4] = {
-		SUPPORTED_40000baseSR4_Full,
-		ADVERTISED_40000baseSR4_Full,
-		SPEED_40000
-		},
-
-	[MLX4_56GBASE_KR4] = {
-		SUPPORTED_56000baseKR4_Full,
-		ADVERTISED_56000baseKR4_Full,
-		SPEED_56000
-		},
-	[MLX4_56GBASE_CR4] = {
-		SUPPORTED_56000baseCR4_Full,
-		ADVERTISED_56000baseCR4_Full,
-		SPEED_56000
-		},
-	[MLX4_56GBASE_SR4] = {
-		SUPPORTED_56000baseSR4_Full,
-		ADVERTISED_56000baseSR4_Full,
-		SPEED_56000
-		},
+static struct ptys2ethtool_config ptys2ethtool_map[MLX4_LINK_MODES_SZ];
+
+void __init mlx4_en_init_ptys2ethtool_map(void)
+{
+	MLX4_BUILD_PTYS2ETHTOOL_CONFIG(MLX4_100BASE_TX, SPEED_100,
+				       ETHTOOL_LINK_MODE_100baseT_Full_BIT);
+	MLX4_BUILD_PTYS2ETHTOOL_CONFIG(MLX4_1000BASE_T, SPEED_1000,
+				       ETHTOOL_LINK_MODE_1000baseT_Full_BIT);
+	MLX4_BUILD_PTYS2ETHTOOL_CONFIG(MLX4_1000BASE_CX_SGMII, SPEED_1000,
+				       ETHTOOL_LINK_MODE_1000baseKX_Full_BIT);
+	MLX4_BUILD_PTYS2ETHTOOL_CONFIG(MLX4_1000BASE_KX, SPEED_1000,
+				       ETHTOOL_LINK_MODE_1000baseKX_Full_BIT);
+	MLX4_BUILD_PTYS2ETHTOOL_CONFIG(MLX4_10GBASE_T, SPEED_10000,
+				       ETHTOOL_LINK_MODE_10000baseT_Full_BIT);
+	MLX4_BUILD_PTYS2ETHTOOL_CONFIG(MLX4_10GBASE_CX4, SPEED_10000,
+				       ETHTOOL_LINK_MODE_10000baseKX4_Full_BIT);
+	MLX4_BUILD_PTYS2ETHTOOL_CONFIG(MLX4_10GBASE_KX4, SPEED_10000,
+				       ETHTOOL_LINK_MODE_10000baseKX4_Full_BIT);
+	MLX4_BUILD_PTYS2ETHTOOL_CONFIG(MLX4_10GBASE_KR, SPEED_10000,
+				       ETHTOOL_LINK_MODE_10000baseKR_Full_BIT);
+	MLX4_BUILD_PTYS2ETHTOOL_CONFIG(MLX4_10GBASE_CR, SPEED_10000,
+				       ETHTOOL_LINK_MODE_10000baseKR_Full_BIT);
+	MLX4_BUILD_PTYS2ETHTOOL_CONFIG(MLX4_10GBASE_SR, SPEED_10000,
+				       ETHTOOL_LINK_MODE_10000baseKR_Full_BIT);
+	MLX4_BUILD_PTYS2ETHTOOL_CONFIG(MLX4_20GBASE_KR2, SPEED_20000,
+				       ETHTOOL_LINK_MODE_20000baseMLD2_Full_BIT,
+				       ETHTOOL_LINK_MODE_20000baseKR2_Full_BIT);
+	MLX4_BUILD_PTYS2ETHTOOL_CONFIG(MLX4_40GBASE_CR4, SPEED_40000,
+				       ETHTOOL_LINK_MODE_40000baseCR4_Full_BIT);
+	MLX4_BUILD_PTYS2ETHTOOL_CONFIG(MLX4_40GBASE_KR4, SPEED_40000,
+				       ETHTOOL_LINK_MODE_40000baseKR4_Full_BIT);
+	MLX4_BUILD_PTYS2ETHTOOL_CONFIG(MLX4_40GBASE_SR4, SPEED_40000,
+				       ETHTOOL_LINK_MODE_40000baseSR4_Full_BIT);
+	MLX4_BUILD_PTYS2ETHTOOL_CONFIG(MLX4_56GBASE_KR4, SPEED_56000,
+				       ETHTOOL_LINK_MODE_56000baseKR4_Full_BIT);
+	MLX4_BUILD_PTYS2ETHTOOL_CONFIG(MLX4_56GBASE_CR4, SPEED_56000,
+				       ETHTOOL_LINK_MODE_56000baseCR4_Full_BIT);
+	MLX4_BUILD_PTYS2ETHTOOL_CONFIG(MLX4_56GBASE_SR4, SPEED_56000,
+				       ETHTOOL_LINK_MODE_56000baseSR4_Full_BIT);
 };
 
-static u32 ptys2ethtool_link_modes(u32 eth_proto, enum ethtool_report report)
+static void ptys2ethtool_update_link_modes(ethtool_link_mode_mask_t *link_modes,
+					   u32 eth_proto,
+					   enum ethtool_report report)
 {
 	int i;
-	u32 link_modes = 0;
-
 	for (i = 0; i < MLX4_LINK_MODES_SZ; i++) {
 		if (eth_proto & MLX4_PROT_MASK(i))
-			link_modes |= ptys2ethtool_map[i][report];
+			bitmap_or(link_modes->mask,
+				  link_modes->mask,
+				  ptys2ethtool_map[i].link_modes[report].mask,
+				  __ETHTOOL_LINK_MODE_MASK_NBITS);
 	}
-	return link_modes;
 }
 
-static u32 ethtool2ptys_link_modes(u32 link_modes, enum ethtool_report report)
+static u32 ethtool2ptys_link_modes(const ethtool_link_mode_mask_t *link_modes,
+				   enum ethtool_report report)
 {
 	int i;
 	u32 ptys_modes = 0;
 
 	for (i = 0; i < MLX4_LINK_MODES_SZ; i++) {
-		if (ptys2ethtool_map[i][report] & link_modes)
+		if (bitmap_intersects(
+			    ptys2ethtool_map[i].link_modes[report].mask,
+			    link_modes->mask,
+			    __ETHTOOL_LINK_MODE_MASK_NBITS))
 			ptys_modes |= 1 << i;
 	}
 	return ptys_modes;
@@ -589,14 +554,14 @@ static u32 speed2ptys_link_modes(u32 speed)
 	u32 ptys_modes = 0;
 
 	for (i = 0; i < MLX4_LINK_MODES_SZ; i++) {
-		if (ptys2ethtool_map[i][SPEED] == speed)
+		if (ptys2ethtool_map[i].speed == speed)
 			ptys_modes |= 1 << i;
 	}
 	return ptys_modes;
 }
 
-static int ethtool_get_ptys_settings(struct net_device *dev,
-				     struct ethtool_cmd *cmd)
+static int ethtool_get_ptys_ksettings(struct net_device *dev,
+				      struct ethtool_ksettings *ksettings)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_ptys_reg ptys_reg;
@@ -624,79 +589,94 @@ static int ethtool_get_ptys_settings(struct net_device *dev,
 	en_dbg(DRV, priv, "ptys_reg.eth_proto_lp_adv %x\n",
 	       be32_to_cpu(ptys_reg.eth_proto_lp_adv));
 
-	cmd->supported = 0;
-	cmd->advertising = 0;
+	/* reset supported/advertising masks */
+	ethtool_build_link_mode(&ksettings->link_modes.supported);
+	ethtool_build_link_mode(&ksettings->link_modes.advertising);
 
-	cmd->supported |= ptys_get_supported_port(&ptys_reg);
+	ptys2ethtool_update_supported_port(&ksettings->link_modes.supported,
+					   &ptys_reg);
 
 	eth_proto = be32_to_cpu(ptys_reg.eth_proto_cap);
-	cmd->supported |= ptys2ethtool_link_modes(eth_proto, SUPPORTED);
+	ptys2ethtool_update_link_modes(&ksettings->link_modes.supported,
+				       eth_proto, SUPPORTED);
 
 	eth_proto = be32_to_cpu(ptys_reg.eth_proto_admin);
-	cmd->advertising |= ptys2ethtool_link_modes(eth_proto, ADVERTISED);
+	ptys2ethtool_update_link_modes(&ksettings->link_modes.advertising,
+				       eth_proto, ADVERTISED);
 
-	cmd->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
-	cmd->advertising |= (priv->prof->tx_pause) ? ADVERTISED_Pause : 0;
+	ethtool_add_link_modes(&ksettings->link_modes.supported,
+			       ETHTOOL_LINK_MODE_Pause_BIT,
+			       ETHTOOL_LINK_MODE_Pause_BIT);
 
-	cmd->advertising |= (priv->prof->tx_pause ^ priv->prof->rx_pause) ?
-		ADVERTISED_Asym_Pause : 0;
+	if (priv->prof->tx_pause)
+		ethtool_add_link_modes(&ksettings->link_modes.advertising,
+				       ETHTOOL_LINK_MODE_Pause_BIT);
+	if (priv->prof->tx_pause ^ priv->prof->rx_pause)
+		ethtool_add_link_modes(&ksettings->link_modes.advertising,
+				       ETHTOOL_LINK_MODE_Asym_Pause_BIT);
 
-	cmd->port = ptys_get_active_port(&ptys_reg);
-	cmd->transceiver = (SUPPORTED_TP & cmd->supported) ?
-		XCVR_EXTERNAL : XCVR_INTERNAL;
+	ksettings->parent.port = ptys_get_active_port(&ptys_reg);
 
 	if (mlx4_en_autoneg_get(dev)) {
-		cmd->supported |= SUPPORTED_Autoneg;
-		cmd->advertising |= ADVERTISED_Autoneg;
+		ethtool_add_link_modes(&ksettings->link_modes.supported,
+				       ETHTOOL_LINK_MODE_Autoneg_BIT);
+		ethtool_add_link_modes(&ksettings->link_modes.advertising,
+				       ETHTOOL_LINK_MODE_Autoneg_BIT);
 	}
 
-	cmd->autoneg = (priv->port_state.flags & MLX4_EN_PORT_ANC) ?
+	ksettings->parent.autoneg
+		= (priv->port_state.flags & MLX4_EN_PORT_ANC) ?
 		AUTONEG_ENABLE : AUTONEG_DISABLE;
 
 	eth_proto = be32_to_cpu(ptys_reg.eth_proto_lp_adv);
-	cmd->lp_advertising = ptys2ethtool_link_modes(eth_proto, ADVERTISED);
 
-	cmd->lp_advertising |= (priv->port_state.flags & MLX4_EN_PORT_ANC) ?
-			ADVERTISED_Autoneg : 0;
+	ethtool_build_link_mode(&ksettings->link_modes.lp_advertising);
+	ptys2ethtool_update_link_modes(&ksettings->link_modes.lp_advertising,
+				       eth_proto, ADVERTISED);
+	if (priv->port_state.flags & MLX4_EN_PORT_ANC)
+		ethtool_add_link_modes(&ksettings->link_modes.lp_advertising,
+				       ETHTOOL_LINK_MODE_Autoneg_BIT);
 
-	cmd->phy_address = 0;
-	cmd->mdio_support = 0;
-	cmd->maxtxpkt = 0;
-	cmd->maxrxpkt = 0;
-	cmd->eth_tp_mdix = ETH_TP_MDI_INVALID;
-	cmd->eth_tp_mdix_ctrl = ETH_TP_MDI_AUTO;
+	ksettings->parent.phy_address = 0;
+	ksettings->parent.mdio_support = 0;
+	ksettings->parent.eth_tp_mdix = ETH_TP_MDI_INVALID;
+	ksettings->parent.eth_tp_mdix_ctrl = ETH_TP_MDI_AUTO;
 
 	return ret;
 }
 
-static void ethtool_get_default_settings(struct net_device *dev,
-					 struct ethtool_cmd *cmd)
+static void ethtool_get_default_ksettings(struct net_device *dev,
+					  struct ethtool_ksettings *ksettings)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	int trans_type;
 
-	cmd->autoneg = AUTONEG_DISABLE;
-	cmd->supported = SUPPORTED_10000baseT_Full;
-	cmd->advertising = ADVERTISED_10000baseT_Full;
+	ksettings->parent.autoneg = AUTONEG_DISABLE;
+	ethtool_build_link_mode(&ksettings->link_modes.supported,
+				ETHTOOL_LINK_MODE_10000baseT_Full_BIT);
+	ethtool_build_link_mode(&ksettings->link_modes.advertising,
+				ETHTOOL_LINK_MODE_10000baseT_Full_BIT);
 	trans_type = priv->port_state.transceiver;
 
 	if (trans_type > 0 && trans_type <= 0xC) {
-		cmd->port = PORT_FIBRE;
-		cmd->transceiver = XCVR_EXTERNAL;
-		cmd->supported |= SUPPORTED_FIBRE;
-		cmd->advertising |= ADVERTISED_FIBRE;
+		ksettings->parent.port = PORT_FIBRE;
+		ethtool_add_link_modes(&ksettings->link_modes.supported,
+				       ETHTOOL_LINK_MODE_FIBRE_BIT);
+		ethtool_add_link_modes(&ksettings->link_modes.advertising,
+				       ETHTOOL_LINK_MODE_FIBRE_BIT);
 	} else if (trans_type == 0x80 || trans_type == 0) {
-		cmd->port = PORT_TP;
-		cmd->transceiver = XCVR_INTERNAL;
-		cmd->supported |= SUPPORTED_TP;
-		cmd->advertising |= ADVERTISED_TP;
+		ksettings->parent.port = PORT_TP;
+		ethtool_add_link_modes(&ksettings->link_modes.supported,
+				       ETHTOOL_LINK_MODE_TP_BIT);
+		ethtool_add_link_modes(&ksettings->link_modes.advertising,
+				       ETHTOOL_LINK_MODE_TP_BIT);
 	} else  {
-		cmd->port = -1;
-		cmd->transceiver = -1;
+		ksettings->parent.port = -1;
 	}
 }
 
-static int mlx4_en_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int mlx4_en_get_ksettings(struct net_device *dev,
+				 struct ethtool_ksettings *ksettings)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	int ret = -EINVAL;
@@ -709,16 +689,16 @@ static int mlx4_en_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	       priv->port_state.flags & MLX4_EN_PORT_ANE);
 
 	if (priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_ETH_PROT_CTRL)
-		ret = ethtool_get_ptys_settings(dev, cmd);
+		ret = ethtool_get_ptys_ksettings(dev, ksettings);
 	if (ret) /* ETH PROT CRTL is not supported or PTYS CMD failed */
-		ethtool_get_default_settings(dev, cmd);
+		ethtool_get_default_ksettings(dev, ksettings);
 
 	if (netif_carrier_ok(dev)) {
-		ethtool_cmd_speed_set(cmd, priv->port_state.link_speed);
-		cmd->duplex = DUPLEX_FULL;
+		ksettings->parent.speed = priv->port_state.link_speed;
+		ksettings->parent.duplex = DUPLEX_FULL;
 	} else {
-		ethtool_cmd_speed_set(cmd, SPEED_UNKNOWN);
-		cmd->duplex = DUPLEX_UNKNOWN;
+		ksettings->parent.speed = SPEED_UNKNOWN;
+		ksettings->parent.duplex = DUPLEX_UNKNOWN;
 	}
 	return 0;
 }
@@ -742,21 +722,33 @@ static __be32 speed_set_ptys_admin(struct mlx4_en_priv *priv, u32 speed,
 	return proto_admin;
 }
 
-static int mlx4_en_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+static int mlx4_en_set_ksettings(struct net_device *dev,
+				 const struct ethtool_ksettings *ksettings)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_ptys_reg ptys_reg;
 	__be32 proto_admin;
 	int ret;
 
-	u32 ptys_adv = ethtool2ptys_link_modes(cmd->advertising, ADVERTISED);
-	int speed = ethtool_cmd_speed(cmd);
+	u32 ptys_adv = ethtool2ptys_link_modes(
+		&ksettings->link_modes.advertising, ADVERTISED);
+	const int speed = ksettings->parent.speed;
+
+	if (en_dbg_enabled(DRV, priv)) {
+		char dbg_link_mode_buff[64];
 
-	en_dbg(DRV, priv, "Set Speed=%d adv=0x%x autoneg=%d duplex=%d\n",
-	       speed, cmd->advertising, cmd->autoneg, cmd->duplex);
+		bitmap_scnprintf(dbg_link_mode_buff,
+				 sizeof(dbg_link_mode_buff),
+				 ksettings->link_modes.supported.mask,
+				 __ETHTOOL_LINK_MODE_MASK_NBITS);
+		en_dbg(DRV, priv,
+		       "Set Speed=%d adv={%s} autoneg=%d duplex=%d\n",
+		       speed, dbg_link_mode_buff,
+		       ksettings->parent.autoneg, ksettings->parent.duplex);
+	}
 
 	if (!(priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_ETH_PROT_CTRL) ||
-	    (cmd->duplex == DUPLEX_HALF))
+	    (ksettings->parent.duplex == DUPLEX_HALF))
 		return -EINVAL;
 
 	memset(&ptys_reg, 0, sizeof(ptys_reg));
@@ -1822,8 +1814,8 @@ static int mlx4_en_get_module_eeprom(struct net_device *dev,
 
 const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_drvinfo = mlx4_en_get_drvinfo,
-	.get_settings = mlx4_en_get_settings,
-	.set_settings = mlx4_en_set_settings,
+	.get_ksettings = mlx4_en_get_ksettings,
+	.set_ksettings = mlx4_en_set_ksettings,
 	.get_link = ethtool_op_get_link,
 	.get_strings = mlx4_en_get_strings,
 	.get_sset_count = mlx4_en_get_sset_count,
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_main.c b/drivers/net/ethernet/mellanox/mlx4/en_main.c
index c643d2b..b435349 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_main.c
@@ -348,6 +348,7 @@ static void mlx4_en_verify_params(void)
 static int __init mlx4_en_init(void)
 {
 	mlx4_en_verify_params();
+	mlx4_en_init_ptys2ethtool_map();
 
 	return mlx4_register_interface(&mlx4_en_interface);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 96bf728..609fc3e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -749,6 +749,7 @@ static inline bool mlx4_en_cq_busy_polling(struct mlx4_en_cq *cq)
 
 #define MLX4_EN_WOL_DO_MODIFY (1ULL << 63)
 
+void mlx4_en_init_ptys2ethtool_map(void);
 void mlx4_en_update_loopback_state(struct net_device *dev,
 				   netdev_features_t features);
 
-- 
2.2.0.rc0.207.ga3a616c
