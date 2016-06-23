From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 03/10] net/mlx5e: Introduce net device priv flags infrastructure
Date: Thu, 23 Jun 2016 17:02:39 +0300
Message-ID: <1466690566-14700-4-git-send-email-saeedm@mellanox.com>
References: <1466690566-14700-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Gal Pressman <galp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:35354 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751808AbcFWPrC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jun 2016 11:47:02 -0400
In-Reply-To: <1466690566-14700-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

Introduce an infrastructure for getting/setting private net device
flags.

Currently a 'nop' priv flag is added, following patches will override
the flag will actual feature specific flags.

Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       | 17 +++++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 59 ++++++++++++++++++++++
 2 files changed, 76 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 017e047..02fa4da 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -144,6 +144,22 @@ struct mlx5e_umr_wqe {
 	struct mlx5_wqe_data_seg       data;
 };
 
+static const char mlx5e_priv_flags[][ETH_GSTRING_LEN] = {
+	"nop",
+};
+
+enum mlx5e_priv_flag {
+	MLX5E_PFLAG_NOP = (1 << 0),
+};
+
+#define MLX5E_SET_PRIV_FLAG(priv, pflag, enable)    \
+	do {                                        \
+		if (enable)                         \
+			priv->pflags |= pflag;      \
+		else                                \
+			priv->pflags &= ~pflag;     \
+	} while (0)
+
 #ifdef CONFIG_MLX5_CORE_EN_DCB
 #define MLX5E_MAX_BW_ALLOC 100 /* Max percentage of BW allocation */
 #define MLX5E_MIN_BW_ALLOC 1   /* Min percentage of BW allocation */
@@ -543,6 +559,7 @@ struct mlx5e_priv {
 	struct work_struct         set_rx_mode_work;
 	struct delayed_work        update_stats_work;
 
+	u32                        pflags;
 	struct mlx5_core_dev      *mdev;
 	struct net_device         *netdev;
 	struct mlx5e_stats         stats;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index fc7dcc0..f8bbc2b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -198,6 +198,8 @@ static int mlx5e_get_sset_count(struct net_device *dev, int sset)
 		       MLX5E_NUM_RQ_STATS(priv) +
 		       MLX5E_NUM_SQ_STATS(priv) +
 		       MLX5E_NUM_PFC_COUNTERS(priv);
+	case ETH_SS_PRIV_FLAGS:
+		return ARRAY_SIZE(mlx5e_priv_flags);
 	/* fallthrough */
 	default:
 		return -EOPNOTSUPP;
@@ -272,9 +274,12 @@ static void mlx5e_get_strings(struct net_device *dev,
 			      uint32_t stringset, uint8_t *data)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
+	int i;
 
 	switch (stringset) {
 	case ETH_SS_PRIV_FLAGS:
+		for (i = 0; i < ARRAY_SIZE(mlx5e_priv_flags); i++)
+			strcpy(data + i * ETH_GSTRING_LEN, mlx5e_priv_flags[i]);
 		break;
 
 	case ETH_SS_TEST:
@@ -1272,6 +1277,58 @@ static int mlx5e_get_module_eeprom(struct net_device *netdev,
 	return 0;
 }
 
+typedef int (*mlx5e_pflag_handler)(struct net_device *netdev, bool enable);
+
+static int set_pflag_nop(struct net_device *netdev, bool enable)
+{
+	return 0;
+}
+
+static int mlx5e_handle_pflag(struct net_device *netdev,
+			      u32 wanted_flags,
+			      enum mlx5e_priv_flag flag,
+			      mlx5e_pflag_handler pflag_handler)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	bool enable = !!(wanted_flags & flag);
+	u32 changes = wanted_flags ^ priv->pflags;
+	int err;
+
+	if (!(changes & flag))
+		return 0;
+
+	err = pflag_handler(netdev, enable);
+	if (err) {
+		netdev_err(netdev, "%s private flag 0x%x failed err %d\n",
+			   enable ? "Enable" : "Disable", flag, err);
+		return err;
+	}
+
+	MLX5E_SET_PRIV_FLAG(priv, flag, enable);
+	return 0;
+}
+
+static int mlx5e_set_priv_flags(struct net_device *netdev, u32 pflags)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+	int err;
+
+	mutex_lock(&priv->state_lock);
+
+	err = mlx5e_handle_pflag(netdev, pflags, MLX5E_PFLAG_NOP,
+				 set_pflag_nop);
+
+	mutex_unlock(&priv->state_lock);
+	return err ? -EINVAL : 0;
+}
+
+static u32 mlx5e_get_priv_flags(struct net_device *netdev)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+
+	return priv->pflags;
+}
+
 const struct ethtool_ops mlx5e_ethtool_ops = {
 	.get_drvinfo       = mlx5e_get_drvinfo,
 	.get_link          = ethtool_op_get_link,
@@ -1301,4 +1358,6 @@ const struct ethtool_ops mlx5e_ethtool_ops = {
 	.set_wol	   = mlx5e_set_wol,
 	.get_module_info   = mlx5e_get_module_info,
 	.get_module_eeprom = mlx5e_get_module_eeprom,
+	.get_priv_flags    = mlx5e_get_priv_flags,
+	.set_priv_flags    = mlx5e_set_priv_flags
 };
-- 
2.8.0
