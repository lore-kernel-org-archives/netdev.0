From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next 10/11] net/mlx5e: Restore vlan filter after seamless reset
Date: Fri,  9 Sep 2016 17:35:26 +0300
Message-ID: <1473431727-20150-11-git-send-email-saeedm@mellanox.com>
References: <1473431727-20150-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Moahamd Haj Yahia <mohamad@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:35515 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752814AbcIIOhA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2016 10:37:00 -0400
In-Reply-To: <1473431727-20150-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mohamad Haj Yahia <mohamad@mellanox.com>

When detaching the mlx5e interface clear all the vlans rules from the
vlan flow table.
When attaching it back restore all the active vlans rules to the HW.

Signed-off-by: Mohamad Haj Yahia <mohamad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_fs.c | 38 +++++++++++++++++++++----
 1 file changed, 32 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
index 1587a9f..36fbc6b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_fs.c
@@ -294,6 +294,36 @@ int mlx5e_vlan_rx_kill_vid(struct net_device *dev, __always_unused __be16 proto,
 	return 0;
 }
 
+static void mlx5e_add_vlan_rules(struct mlx5e_priv *priv)
+{
+	int i;
+
+	mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_UNTAGGED, 0);
+
+	for_each_set_bit(i, priv->fs.vlan.active_vlans, VLAN_N_VID) {
+		mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_MATCH_VID, i);
+	}
+
+	if (priv->fs.vlan.filter_disabled &&
+	    !(priv->netdev->flags & IFF_PROMISC))
+		mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_VID, 0);
+}
+
+static void mlx5e_del_vlan_rules(struct mlx5e_priv *priv)
+{
+	int i;
+
+	mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_UNTAGGED, 0);
+
+	for_each_set_bit(i, priv->fs.vlan.active_vlans, VLAN_N_VID) {
+		mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_MATCH_VID, i);
+	}
+
+	if (priv->fs.vlan.filter_disabled &&
+	    !(priv->netdev->flags & IFF_PROMISC))
+		mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_ANY_VID, 0);
+}
+
 #define mlx5e_for_each_hash_node(hn, tmp, hash, i) \
 	for (i = 0; i < MLX5E_L2_ADDR_HASH_SIZE; i++) \
 		hlist_for_each_entry_safe(hn, tmp, &hash[i], hlist)
@@ -1024,14 +1054,10 @@ static int mlx5e_create_vlan_table(struct mlx5e_priv *priv)
 	if (err)
 		goto err_free_g;
 
-	err = mlx5e_add_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_UNTAGGED, 0);
-	if (err)
-		goto err_destroy_vlan_flow_groups;
+	mlx5e_add_vlan_rules(priv);
 
 	return 0;
 
-err_destroy_vlan_flow_groups:
-	mlx5e_destroy_groups(ft);
 err_free_g:
 	kfree(ft->g);
 err_destroy_vlan_table:
@@ -1043,6 +1069,7 @@ err_destroy_vlan_table:
 
 static void mlx5e_destroy_vlan_table(struct mlx5e_priv *priv)
 {
+	mlx5e_del_vlan_rules(priv);
 	mlx5e_destroy_flow_table(&priv->fs.vlan.ft);
 }
 
@@ -1100,7 +1127,6 @@ err_destroy_arfs_tables:
 
 void mlx5e_destroy_flow_steering(struct mlx5e_priv *priv)
 {
-	mlx5e_del_vlan_rule(priv, MLX5E_VLAN_RULE_TYPE_UNTAGGED, 0);
 	mlx5e_destroy_vlan_table(priv);
 	mlx5e_destroy_l2_table(priv);
 	mlx5e_destroy_ttc_table(priv);
-- 
2.7.4
