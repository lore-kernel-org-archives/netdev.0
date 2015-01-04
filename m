From: David Decotigny <ddecotig@gmail.com>
Subject: [PATCH net-next v1 7/7] net: mlx4_en: extend link mode support to 48 bits
Date: Sun,  4 Jan 2015 12:56:57 -0800
Message-ID: <1420405017-23278-8-git-send-email-ddecotig@gmail.com>
References: <1420405017-23278-1-git-send-email-ddecotig@gmail.com>
Cc: David Decotigny <decot@googlers.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Ben Hutchings <ben@decadent.org.uk>,
	Masatake YAMATO <yamato@redhat.com>, Xi Wang <xii@google.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	WANG Cong <xiyou.wangcong@gmail.com>,
	Flavio Leitner <fbl@redhat.com>, Tom Gundersen <teg@jklm.no>,
	Jiri Pirko <jiri@resnulli.us>,
	Vlad Yasevich <vyasevic@redhat.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Venkata Duvvuru <VenkatKumar.Duvvuru@Emulex.Com>,
	Govindarajulu Varadarajan <_govind@gmx.com>
To: Amir Vadai <amirv@mellanox.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-api@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420405017-23278-1-git-send-email-ddecotig@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Decotigny <decot@googlers.com>

Signed-off-by: David Decotigny <decot@googlers.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 67 +++++++++++++++----------
 1 file changed, 40 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 90e0f04..395ab72 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -388,7 +388,8 @@ static u32 mlx4_en_autoneg_get(struct net_device *dev)
 	return autoneg;
 }
 
-static u32 ptys_get_supported_port(struct mlx4_ptys_reg *ptys_reg)
+static ethtool_link_mode_mask_t
+ptys_get_supported_port(struct mlx4_ptys_reg *ptys_reg)
 {
 	u32 eth_proto = be32_to_cpu(ptys_reg->eth_proto_cap);
 
@@ -465,7 +466,7 @@ enum ethtool_report {
 };
 
 /* Translates mlx4 link mode to equivalent ethtool Link modes/speed */
-static u32 ptys2ethtool_map[MLX4_LINK_MODES_SZ][3] = {
+static u64 ptys2ethtool_map[MLX4_LINK_MODES_SZ][3] = {
 	[MLX4_100BASE_TX] = {
 		SUPPORTED_100baseT_Full,
 		ADVERTISED_100baseT_Full,
@@ -558,10 +559,11 @@ static u32 ptys2ethtool_map[MLX4_LINK_MODES_SZ][3] = {
 		},
 };
 
-static u32 ptys2ethtool_link_modes(u32 eth_proto, enum ethtool_report report)
+static ethtool_link_mode_mask_t
+ptys2ethtool_link_modes(u32 eth_proto, enum ethtool_report report)
 {
 	int i;
-	u32 link_modes = 0;
+	ethtool_link_mode_mask_t link_modes = 0;
 
 	for (i = 0; i < MLX4_LINK_MODES_SZ; i++) {
 		if (eth_proto & MLX4_PROT_MASK(i))
@@ -570,7 +572,8 @@ static u32 ptys2ethtool_link_modes(u32 eth_proto, enum ethtool_report report)
 	return link_modes;
 }
 
-static u32 ethtool2ptys_link_modes(u32 link_modes, enum ethtool_report report)
+static u32 ethtool2ptys_link_modes(ethtool_link_mode_mask_t link_modes,
+				   enum ethtool_report report)
 {
 	int i;
 	u32 ptys_modes = 0;
@@ -601,6 +604,9 @@ static int ethtool_get_ptys_settings(struct net_device *dev,
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_ptys_reg ptys_reg;
 	u32 eth_proto;
+	ethtool_link_mode_mask_t eth_supported;
+	ethtool_link_mode_mask_t eth_advertising;
+	ethtool_link_mode_mask_t eth_lp_advertising;
 	int ret;
 
 	memset(&ptys_reg, 0, sizeof(ptys_reg));
@@ -624,41 +630,44 @@ static int ethtool_get_ptys_settings(struct net_device *dev,
 	en_dbg(DRV, priv, "ptys_reg.eth_proto_lp_adv %x\n",
 	       be32_to_cpu(ptys_reg.eth_proto_lp_adv));
 
-	cmd->supported = 0;
-	cmd->advertising = 0;
+	eth_supported = 0;
+	eth_advertising = 0;
 
-	cmd->supported |= ptys_get_supported_port(&ptys_reg);
+	eth_supported |= ptys_get_supported_port(&ptys_reg);
 
 	eth_proto = be32_to_cpu(ptys_reg.eth_proto_cap);
-	cmd->supported |= ptys2ethtool_link_modes(eth_proto, SUPPORTED);
+	eth_supported |= ptys2ethtool_link_modes(eth_proto, SUPPORTED);
 
 	eth_proto = be32_to_cpu(ptys_reg.eth_proto_admin);
-	cmd->advertising |= ptys2ethtool_link_modes(eth_proto, ADVERTISED);
+	eth_advertising |= ptys2ethtool_link_modes(eth_proto, ADVERTISED);
 
-	cmd->supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
-	cmd->advertising |= (priv->prof->tx_pause) ? ADVERTISED_Pause : 0;
+	eth_supported |= SUPPORTED_Pause | SUPPORTED_Asym_Pause;
+	eth_advertising |= (priv->prof->tx_pause) ? ADVERTISED_Pause : 0;
 
-	cmd->advertising |= (priv->prof->tx_pause ^ priv->prof->rx_pause) ?
+	eth_advertising |= (priv->prof->tx_pause ^ priv->prof->rx_pause) ?
 		ADVERTISED_Asym_Pause : 0;
 
 	cmd->port = ptys_get_active_port(&ptys_reg);
-	cmd->transceiver = (SUPPORTED_TP & cmd->supported) ?
+	cmd->transceiver = (SUPPORTED_TP & eth_supported) ?
 		XCVR_EXTERNAL : XCVR_INTERNAL;
 
 	if (mlx4_en_autoneg_get(dev)) {
-		cmd->supported |= SUPPORTED_Autoneg;
-		cmd->advertising |= ADVERTISED_Autoneg;
+		eth_supported |= SUPPORTED_Autoneg;
+		eth_advertising |= ADVERTISED_Autoneg;
 	}
 
 	cmd->autoneg = (priv->port_state.flags & MLX4_EN_PORT_ANC) ?
 		AUTONEG_ENABLE : AUTONEG_DISABLE;
 
 	eth_proto = be32_to_cpu(ptys_reg.eth_proto_lp_adv);
-	cmd->lp_advertising = ptys2ethtool_link_modes(eth_proto, ADVERTISED);
+	eth_lp_advertising = ptys2ethtool_link_modes(eth_proto, ADVERTISED);
 
-	cmd->lp_advertising |= (priv->port_state.flags & MLX4_EN_PORT_ANC) ?
+	eth_lp_advertising |= (priv->port_state.flags & MLX4_EN_PORT_ANC) ?
 			ADVERTISED_Autoneg : 0;
 
+	ethtool_cmd_supported_set(cmd, eth_supported);
+	ethtool_cmd_advertising_set(cmd, eth_advertising);
+	ethtool_cmd_lp_advertising_set(cmd, eth_lp_advertising);
 	cmd->phy_address = 0;
 	cmd->mdio_support = 0;
 	cmd->maxtxpkt = 0;
@@ -673,27 +682,30 @@ static void ethtool_get_default_settings(struct net_device *dev,
 					 struct ethtool_cmd *cmd)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
+	ethtool_link_mode_mask_t eth_supported, eth_advertising;
 	int trans_type;
 
 	cmd->autoneg = AUTONEG_DISABLE;
-	cmd->supported = SUPPORTED_10000baseT_Full;
-	cmd->advertising = ADVERTISED_10000baseT_Full;
+	eth_supported = SUPPORTED_10000baseT_Full;
+	eth_advertising = ADVERTISED_10000baseT_Full;
 	trans_type = priv->port_state.transceiver;
 
 	if (trans_type > 0 && trans_type <= 0xC) {
 		cmd->port = PORT_FIBRE;
 		cmd->transceiver = XCVR_EXTERNAL;
-		cmd->supported |= SUPPORTED_FIBRE;
-		cmd->advertising |= ADVERTISED_FIBRE;
+		eth_supported |= SUPPORTED_FIBRE;
+		eth_advertising |= ADVERTISED_FIBRE;
 	} else if (trans_type == 0x80 || trans_type == 0) {
 		cmd->port = PORT_TP;
 		cmd->transceiver = XCVR_INTERNAL;
-		cmd->supported |= SUPPORTED_TP;
-		cmd->advertising |= ADVERTISED_TP;
+		eth_supported |= SUPPORTED_TP;
+		eth_advertising |= ADVERTISED_TP;
 	} else  {
 		cmd->port = -1;
 		cmd->transceiver = -1;
 	}
+	ethtool_cmd_supported_set(cmd, eth_supported);
+	ethtool_cmd_advertising_set(cmd, eth_advertising);
 }
 
 static int mlx4_en_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
@@ -747,13 +759,14 @@ static int mlx4_en_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_ptys_reg ptys_reg;
 	__be32 proto_admin;
+	const ethtool_link_mode_mask_t eth_adv = ethtool_cmd_advertising(cmd);
 	int ret;
 
-	u32 ptys_adv = ethtool2ptys_link_modes(cmd->advertising, ADVERTISED);
+	u32 ptys_adv = ethtool2ptys_link_modes(eth_adv, ADVERTISED);
 	int speed = ethtool_cmd_speed(cmd);
 
-	en_dbg(DRV, priv, "Set Speed=%d adv=0x%x autoneg=%d duplex=%d\n",
-	       speed, cmd->advertising, cmd->autoneg, cmd->duplex);
+	en_dbg(DRV, priv, "Set Speed=%d adv=0x%llx autoneg=%d duplex=%d\n",
+	       speed, eth_adv, cmd->autoneg, cmd->duplex);
 
 	if (!(priv->mdev->dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_ETH_PROT_CTRL) ||
 	    (cmd->duplex == DUPLEX_HALF))
-- 
2.2.0.rc0.207.ga3a616c
