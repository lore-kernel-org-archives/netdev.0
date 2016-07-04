From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 6/8] net/mlx5e: Add support to get ethtool flow rules
Date: Mon,  4 Jul 2016 17:23:10 +0300
Message-ID: <1467642192-28259-7-git-send-email-saeedm@mellanox.com>
References: <1467642192-28259-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Maor Gottlieb <maorg@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:54699 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752120AbcGDOXz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Jul 2016 10:23:55 -0400
In-Reply-To: <1467642192-28259-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Maor Gottlieb <maorg@mellanox.com>

Enhance the existing get_rxnfc callback:
1. Get flow rule of specific ID.
2. Get all flow rules.
3. Get number of rules.

Signed-off-by: Maor Gottlieb <maorg@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  4 +++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  9 ++++++
 .../ethernet/mellanox/mlx5/core/en_fs_ethtool.c    | 34 ++++++++++++++++++++++
 3 files changed, 47 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 9842594..1365cdc 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -717,6 +717,10 @@ int mlx5e_create_flow_steering(struct mlx5e_priv *priv);
 void mlx5e_destroy_flow_steering(struct mlx5e_priv *priv);
 void mlx5e_init_l2_addr(struct mlx5e_priv *priv);
 void mlx5e_destroy_flow_table(struct mlx5e_flow_table *ft);
+int mlx5e_ethtool_get_flow(struct mlx5e_priv *priv, struct ethtool_rxnfc *info,
+			   int location);
+int mlx5e_ethtool_get_all_flows(struct mlx5e_priv *priv,
+				struct ethtool_rxnfc *info, u32 *rule_locs);
 int mlx5e_ethtool_flow_replace(struct mlx5e_priv *priv,
 			       struct ethtool_rx_flow_spec *fs);
 int mlx5e_ethtool_flow_remove(struct mlx5e_priv *priv,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index edbb665..d652aa9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -931,6 +931,15 @@ static int mlx5e_get_rxnfc(struct net_device *netdev,
 	case ETHTOOL_GRXRINGS:
 		info->data = priv->params.num_channels;
 		break;
+	case ETHTOOL_GRXCLSRLCNT:
+		info->rule_cnt = priv->fs.ethtool.tot_num_rules;
+		break;
+	case ETHTOOL_GRXCLSRULE:
+		err = mlx5e_ethtool_get_flow(priv, info, info->fs.location);
+		break;
+	case ETHTOOL_GRXCLSRLALL:
+		err = mlx5e_ethtool_get_all_flows(priv, info, rule_locs);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
index 830106e..d17c242 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs_ethtool.c
@@ -537,6 +537,40 @@ out:
 	return err;
 }
 
+int mlx5e_ethtool_get_flow(struct mlx5e_priv *priv, struct ethtool_rxnfc *info,
+			   int location)
+{
+	struct mlx5e_ethtool_rule *eth_rule;
+
+	if (location < 0 || location >= MAX_NUM_OF_ETHTOOL_RULES)
+		return -EINVAL;
+
+	list_for_each_entry(eth_rule, &priv->fs.ethtool.rules, list) {
+		if (eth_rule->flow_spec.location == location) {
+			info->fs = eth_rule->flow_spec;
+			return 0;
+		}
+	}
+
+	return -ENOENT;
+}
+
+int mlx5e_ethtool_get_all_flows(struct mlx5e_priv *priv, struct ethtool_rxnfc *info,
+				u32 *rule_locs)
+{
+	int location = 0;
+	int idx = 0;
+	int err = 0;
+
+	while ((!err || err == -ENOENT) && idx < info->rule_cnt) {
+		err = mlx5e_ethtool_get_flow(priv, info, location);
+		if (!err)
+			rule_locs[idx++] = location;
+		location++;
+	}
+	return err;
+}
+
 void mlx5e_ethtool_cleanup_steering(struct mlx5e_priv *priv)
 {
 	struct mlx5e_ethtool_rule *iter;
-- 
2.8.0
