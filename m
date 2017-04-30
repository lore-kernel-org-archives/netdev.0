From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 07/15] net/mlx5e: Add neighbour hash table to the representors
Date: Sun, 30 Apr 2017 16:20:08 +0300
Message-ID: <20170430132016.27012-8-saeedm@mellanox.com>
References: <20170430132016.27012-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Hen-Zion <hadarh@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46757 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1756812AbdD3NU1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2017 09:20:27 -0400
In-Reply-To: <20170430132016.27012-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hadar Hen Zion <hadarh@mellanox.com>

Add hash table to the representors which is to be used by the next patch
to save neighbours information in the driver.

In order to offload IP tunnel encapsulation rules, the driver must find
the tunnel dst neighbour according to the output device and the
destination address given by the user. The next patch will cache the
neighbors information in the driver to allow support in neigh update
flow for tunnel encap rules.

The neighbour entries are also saved in a list so we easily iterate over
them when querying statistics in order to provide 'used' feedback to the
kernel neighbour NUD core.

Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c | 107 +++++++++++++++++++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.h |  30 +++++++
 2 files changed, 129 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index 8e82b11afd99..52ea7f1c0973 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -224,6 +224,68 @@ void mlx5e_remove_sqs_fwd_rules(struct mlx5e_priv *priv)
 	mlx5_eswitch_sqs2vport_stop(esw, rep);
 }
 
+static const struct rhashtable_params mlx5e_neigh_ht_params = {
+	.head_offset = offsetof(struct mlx5e_neigh_hash_entry, rhash_node),
+	.key_offset = offsetof(struct mlx5e_neigh_hash_entry, m_neigh),
+	.key_len = sizeof(struct mlx5e_neigh),
+	.automatic_shrinking = true,
+};
+
+static int mlx5e_rep_neigh_init(struct mlx5e_rep_priv *rpriv)
+{
+	struct mlx5e_neigh_update_table *neigh_update = &rpriv->neigh_update;
+
+	INIT_LIST_HEAD(&neigh_update->neigh_list);
+	return rhashtable_init(&neigh_update->neigh_ht, &mlx5e_neigh_ht_params);
+}
+
+static void mlx5e_rep_neigh_cleanup(struct mlx5e_rep_priv *rpriv)
+{
+	struct mlx5e_neigh_update_table *neigh_update = &rpriv->neigh_update;
+
+	rhashtable_destroy(&neigh_update->neigh_ht);
+}
+
+static int mlx5e_rep_neigh_entry_insert(struct mlx5e_priv *priv,
+					struct mlx5e_neigh_hash_entry *nhe)
+{
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
+	int err;
+
+	err = rhashtable_insert_fast(&rpriv->neigh_update.neigh_ht,
+				     &nhe->rhash_node,
+				     mlx5e_neigh_ht_params);
+	if (err)
+		return err;
+
+	list_add(&nhe->neigh_list, &rpriv->neigh_update.neigh_list);
+
+	return err;
+}
+
+static void mlx5e_rep_neigh_entry_remove(struct mlx5e_priv *priv,
+					 struct mlx5e_neigh_hash_entry *nhe)
+{
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
+
+	list_del(&nhe->neigh_list);
+
+	rhashtable_remove_fast(&rpriv->neigh_update.neigh_ht,
+			       &nhe->rhash_node,
+			       mlx5e_neigh_ht_params);
+}
+
+static struct mlx5e_neigh_hash_entry *
+mlx5e_rep_neigh_entry_lookup(struct mlx5e_priv *priv,
+			     struct mlx5e_neigh *m_neigh)
+{
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
+	struct mlx5e_neigh_update_table *neigh_update = &rpriv->neigh_update;
+
+	return rhashtable_lookup_fast(&neigh_update->neigh_ht, m_neigh,
+				      mlx5e_neigh_ht_params);
+}
+
 static int mlx5e_rep_open(struct net_device *dev)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
@@ -540,19 +602,33 @@ static struct mlx5e_profile mlx5e_rep_profile = {
 static int
 mlx5e_nic_rep_load(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
 {
-	struct net_device *netdev = rep->netdev;
-	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5e_priv *priv = netdev_priv(rep->netdev);
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
+
+	int err;
+
+	if (test_bit(MLX5E_STATE_OPENED, &priv->state)) {
+		err = mlx5e_add_sqs_fwd_rules(priv);
+		if (err)
+			return err;
+	}
+
+	err = mlx5e_rep_neigh_init(rpriv);
+	if (err)
+		goto err_remove_sqs;
 
-	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
-		return mlx5e_add_sqs_fwd_rules(priv);
 	return 0;
+
+err_remove_sqs:
+	mlx5e_remove_sqs_fwd_rules(priv);
+	return err;
 }
 
 static void
 mlx5e_nic_rep_unload(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
 {
-	struct net_device *netdev = rep->netdev;
-	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5e_priv *priv = netdev_priv(rep->netdev);
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
 
 	if (test_bit(MLX5E_STATE_OPENED, &priv->state))
 		mlx5e_remove_sqs_fwd_rules(priv);
@@ -560,6 +636,8 @@ mlx5e_nic_rep_unload(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
 	/* clean (and re-init) existing uplink offloaded TC rules */
 	mlx5e_tc_cleanup(priv);
 	mlx5e_tc_init(priv);
+
+	mlx5e_rep_neigh_cleanup(rpriv);
 }
 
 static int
@@ -591,15 +669,25 @@ mlx5e_vport_rep_load(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
 		goto err_destroy_netdev;
 	}
 
+	err = mlx5e_rep_neigh_init(rpriv);
+	if (err) {
+		pr_warn("Failed to initialized neighbours handling for vport %d\n",
+			rep->vport);
+		goto err_detach_netdev;
+	}
+
 	err = register_netdev(netdev);
 	if (err) {
 		pr_warn("Failed to register representor netdev for vport %d\n",
 			rep->vport);
-		goto err_detach_netdev;
+		goto err_neigh_cleanup;
 	}
 
 	return 0;
 
+err_neigh_cleanup:
+	mlx5e_rep_neigh_cleanup(rpriv);
+
 err_detach_netdev:
 	mlx5e_detach_netdev(netdev_priv(netdev));
 
@@ -615,9 +703,12 @@ mlx5e_vport_rep_unload(struct mlx5_eswitch *esw, struct mlx5_eswitch_rep *rep)
 {
 	struct net_device *netdev = rep->netdev;
 	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5e_rep_priv *rpriv = priv->ppriv;
 	void *ppriv = priv->ppriv;
 
-	unregister_netdev(netdev);
+	unregister_netdev(rep->netdev);
+
+	mlx5e_rep_neigh_cleanup(rpriv);
 	mlx5e_detach_netdev(priv);
 	mlx5e_destroy_netdev(priv);
 	kfree(ppriv); /* mlx5e_rep_priv */
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
index 425cb1b0bf02..99f6b5f41070 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.h
@@ -34,11 +34,41 @@
 #define __MLX5E_REP_H__
 
 #include <net/ip_tunnels.h>
+#include <linux/rhashtable.h>
 #include "eswitch.h"
 #include "en.h"
 
+struct mlx5e_neigh_update_table {
+	struct rhashtable       neigh_ht;
+	/* Save the neigh hash entries in a list in addition to the hash table
+	 * (neigh_ht). In order to iterate easily over the neigh entries.
+	 * Used for stats query.
+	 */
+	struct list_head	neigh_list;
+};
+
 struct mlx5e_rep_priv {
 	struct mlx5_eswitch_rep *rep;
+	struct mlx5e_neigh_update_table neigh_update;
+};
+
+struct mlx5e_neigh {
+	struct net_device *dev;
+	union {
+		__be32	v4;
+		struct in6_addr v6;
+	} dst_ip;
+};
+
+struct mlx5e_neigh_hash_entry {
+	struct rhash_head rhash_node;
+	struct mlx5e_neigh m_neigh;
+
+	/* Save the neigh hash entry in a list on the representor in
+	 * addition to the hash table. In order to iterate easily over the
+	 * neighbour entries. Used for stats query.
+	 */
+	struct list_head neigh_list;
 };
 
 struct mlx5e_encap_entry {
-- 
2.11.0
