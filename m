From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 10/18] net/mlx5e: Write vlan list into vport context
Date: Mon, 23 Nov 2015 13:11:43 +0200
Message-ID: <1448277111-16474-11-git-send-email-ogerlitz@mellanox.com>
References: <1448277111-16474-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Don Dutile <ddutile@redhat.com>,
	Doug Ledford <dledford@redhat.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Rony Efraim <ronye@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37277 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752746AbbKWLNi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2015 06:13:38 -0500
In-Reply-To: <1448277111-16474-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

Each Vport/vNIC must notify underlying e-Switch layer
for vlan table changes in-order to update SR-IOV FDB tables.

We do that at vlan_rx_add_vid and vlan_rx_kill_vid ndos.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  1 +
 .../ethernet/mellanox/mlx5/core/en_flow_table.c    | 49 ++++++++++++++++++++++
 2 files changed, 50 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 69f1c1a..89313d4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -465,6 +465,7 @@ enum {
 };
 
 struct mlx5e_vlan_db {
+	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
 	u32           active_vlans_ft_ix[VLAN_N_VID];
 	u32           untagged_rule_ft_ix;
 	u32           any_vlan_rule_ft_ix;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
index 9a021be..3c0cf22 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_flow_table.c
@@ -502,6 +502,46 @@ add_eth_addr_rule_out:
 	return err;
 }
 
+static int mlx5e_vport_context_update_vlans(struct mlx5e_priv *priv)
+{
+	struct net_device *ndev = priv->netdev;
+	int max_list_size;
+	int list_size;
+	u16 *vlans;
+	int vlan;
+	int err;
+	int i;
+
+	list_size = 0;
+	for_each_set_bit(vlan, priv->vlan.active_vlans, VLAN_N_VID)
+		list_size++;
+
+	max_list_size = 1 << MLX5_CAP_GEN(priv->mdev, log_max_vlan_list);
+
+	if (list_size > max_list_size) {
+		netdev_warn(ndev,
+			    "netdev vlans list size (%d) > (%d) max vport list size, some vlans will be dropped\n",
+			    list_size, max_list_size);
+		list_size = max_list_size;
+	}
+
+	vlans = kcalloc(list_size, sizeof(*vlans), GFP_KERNEL);
+	if (!vlans)
+		return -ENOMEM;
+
+	i = 0;
+	for_each_set_bit(vlan, priv->vlan.active_vlans, VLAN_N_VID)
+		vlans[i++] = vlan;
+
+	err = mlx5_modify_nic_vport_vlans(priv->mdev, vlans, list_size);
+	if (err)
+		netdev_err(ndev, "Failed to modify vport vlans list err(%d)\n",
+			   err);
+
+	kfree(vlans);
+	return err;
+}
+
 enum mlx5e_vlan_rule_type {
 	MLX5E_VLAN_RULE_TYPE_UNTAGGED,
 	MLX5E_VLAN_RULE_TYPE_ANY_VID,
@@ -552,6 +592,10 @@ static int mlx5e_add_vlan_rule(struct mlx5e_priv *priv,
 			 1);
 		break;
 	default: /* MLX5E_VLAN_RULE_TYPE_MATCH_VID */
+		err = mlx5e_vport_context_update_vlans(priv);
+		if (err)
+			goto add_vlan_rule_out;
+
 		ft_ix = &priv->vlan.active_vlans_ft_ix[vid];
 		MLX5_SET(fte_match_param, match_value, outer_headers.vlan_tag,
 			 1);
@@ -588,6 +632,7 @@ static void mlx5e_del_vlan_rule(struct mlx5e_priv *priv,
 	case MLX5E_VLAN_RULE_TYPE_MATCH_VID:
 		mlx5_del_flow_table_entry(priv->ft.vlan,
 					  priv->vlan.active_vlans_ft_ix[vid]);
+		mlx5e_vport_context_update_vlans(priv);
 		break;
 	}
 }
@@ -619,6 +664,8 @@ int mlx5e_vlan_rx_add_vid(struct net_device *dev, __always_unused __be16 proto,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
+	set_bit(vid, priv->vlan.active_vlans);
+
 	return mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_MATCH_VID, vid);
 }
 
@@ -627,6 +674,8 @@ int mlx5e_vlan_rx_kill_vid(struct net_device *dev, __always_unused __be16 proto,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
+	clear_bit(vid, priv->vlan.active_vlans);
+
 	mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_MATCH_VID, vid);
 
 	return 0;
-- 
2.3.7
