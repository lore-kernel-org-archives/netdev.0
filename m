From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next 5/7] net/mlx4_en: Add steering rules after RSS creation
Date: Thu,  8 Oct 2015 17:14:01 +0300
Message-ID: <1444313643-15284-6-git-send-email-ogerlitz@mellanox.com>
References: <1444313643-15284-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Eli Cohen <eli@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:45274 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S932289AbbJHOOd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Oct 2015 10:14:33 -0400
In-Reply-To: <1444313643-15284-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Shamay <idos@mellanox.com>

Changed the receive control flow in a way that steering
rules are added only when the RSS object is already in RTR/RTS mode.
Some optimization features, which are enabled by the device firmware,
require this condition in order to be effective.

Signed-off-by: Ido Shamay <idos@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 144 ++++++++++++++-----------
 1 file changed, 80 insertions(+), 64 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 4726122..597d892 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -573,10 +573,8 @@ static int mlx4_en_get_qp(struct mlx4_en_priv *priv)
 {
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_dev *dev = mdev->dev;
-	struct mlx4_mac_entry *entry;
 	int index = 0;
 	int err = 0;
-	u64 reg_id = 0;
 	int *qpn = &priv->base_qpn;
 	u64 mac = mlx4_mac_to_u64(priv->dev->dev_addr);
 
@@ -600,44 +598,11 @@ static int mlx4_en_get_qp(struct mlx4_en_priv *priv)
 	en_dbg(DRV, priv, "Reserved qp %d\n", *qpn);
 	if (err) {
 		en_err(priv, "Failed to reserve qp for mac registration\n");
-		goto qp_err;
-	}
-
-	err = mlx4_en_uc_steer_add(priv, priv->dev->dev_addr, qpn, &reg_id);
-	if (err)
-		goto steer_err;
-
-	err = mlx4_en_tunnel_steer_add(priv, priv->dev->dev_addr, *qpn,
-				       &priv->tunnel_reg_id);
-	if (err)
-		goto tunnel_err;
-
-	entry = kmalloc(sizeof(*entry), GFP_KERNEL);
-	if (!entry) {
-		err = -ENOMEM;
-		goto alloc_err;
+		mlx4_unregister_mac(dev, priv->port, mac);
+		return err;
 	}
-	memcpy(entry->mac, priv->dev->dev_addr, sizeof(entry->mac));
-	memcpy(priv->current_mac, entry->mac, sizeof(priv->current_mac));
-	entry->reg_id = reg_id;
-
-	hlist_add_head_rcu(&entry->hlist,
-			   &priv->mac_hash[entry->mac[MLX4_EN_MAC_HASH_IDX]]);
 
 	return 0;
-
-alloc_err:
-	if (priv->tunnel_reg_id)
-		mlx4_flow_detach(priv->mdev->dev, priv->tunnel_reg_id);
-tunnel_err:
-	mlx4_en_uc_steer_release(priv, priv->dev->dev_addr, *qpn, reg_id);
-
-steer_err:
-	mlx4_qp_release_range(dev, *qpn, 1);
-
-qp_err:
-	mlx4_unregister_mac(dev, priv->port, mac);
-	return err;
 }
 
 static void mlx4_en_put_qp(struct mlx4_en_priv *priv)
@@ -645,39 +610,13 @@ static void mlx4_en_put_qp(struct mlx4_en_priv *priv)
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_dev *dev = mdev->dev;
 	int qpn = priv->base_qpn;
-	u64 mac;
 
 	if (dev->caps.steering_mode == MLX4_STEERING_MODE_A0) {
-		mac = mlx4_mac_to_u64(priv->dev->dev_addr);
+		u64 mac = mlx4_mac_to_u64(priv->dev->dev_addr);
 		en_dbg(DRV, priv, "Registering MAC: %pM for deleting\n",
 		       priv->dev->dev_addr);
 		mlx4_unregister_mac(dev, priv->port, mac);
 	} else {
-		struct mlx4_mac_entry *entry;
-		struct hlist_node *tmp;
-		struct hlist_head *bucket;
-		unsigned int i;
-
-		for (i = 0; i < MLX4_EN_MAC_HASH_SIZE; ++i) {
-			bucket = &priv->mac_hash[i];
-			hlist_for_each_entry_safe(entry, tmp, bucket, hlist) {
-				mac = mlx4_mac_to_u64(entry->mac);
-				en_dbg(DRV, priv, "Registering MAC: %pM for deleting\n",
-				       entry->mac);
-				mlx4_en_uc_steer_release(priv, entry->mac,
-							 qpn, entry->reg_id);
-
-				mlx4_unregister_mac(dev, priv->port, mac);
-				hlist_del_rcu(&entry->hlist);
-				kfree_rcu(entry, rcu);
-			}
-		}
-
-		if (priv->tunnel_reg_id) {
-			mlx4_flow_detach(priv->mdev->dev, priv->tunnel_reg_id);
-			priv->tunnel_reg_id = 0;
-		}
-
 		en_dbg(DRV, priv, "Releasing qp: port %d, qpn %d\n",
 		       priv->port, qpn);
 		mlx4_qp_release_range(dev, qpn, 1);
@@ -1283,6 +1222,75 @@ static void mlx4_en_netpoll(struct net_device *dev)
 }
 #endif
 
+static int mlx4_en_set_rss_steer_rules(struct mlx4_en_priv *priv)
+{
+	u64 reg_id;
+	int err = 0;
+	int *qpn = &priv->base_qpn;
+	struct mlx4_mac_entry *entry;
+
+	err = mlx4_en_uc_steer_add(priv, priv->dev->dev_addr, qpn, &reg_id);
+	if (err)
+		return err;
+
+	err = mlx4_en_tunnel_steer_add(priv, priv->dev->dev_addr, *qpn,
+				       &priv->tunnel_reg_id);
+	if (err)
+		goto tunnel_err;
+
+	entry = kmalloc(sizeof(*entry), GFP_KERNEL);
+	if (!entry) {
+		err = -ENOMEM;
+		goto alloc_err;
+	}
+
+	memcpy(entry->mac, priv->dev->dev_addr, sizeof(entry->mac));
+	memcpy(priv->current_mac, entry->mac, sizeof(priv->current_mac));
+	entry->reg_id = reg_id;
+	hlist_add_head_rcu(&entry->hlist,
+			   &priv->mac_hash[entry->mac[MLX4_EN_MAC_HASH_IDX]]);
+
+	return 0;
+
+alloc_err:
+	if (priv->tunnel_reg_id)
+		mlx4_flow_detach(priv->mdev->dev, priv->tunnel_reg_id);
+
+tunnel_err:
+	mlx4_en_uc_steer_release(priv, priv->dev->dev_addr, *qpn, reg_id);
+	return err;
+}
+
+static void mlx4_en_delete_rss_steer_rules(struct mlx4_en_priv *priv)
+{
+	u64 mac;
+	unsigned int i;
+	int qpn = priv->base_qpn;
+	struct hlist_head *bucket;
+	struct hlist_node *tmp;
+	struct mlx4_mac_entry *entry;
+
+	for (i = 0; i < MLX4_EN_MAC_HASH_SIZE; ++i) {
+		bucket = &priv->mac_hash[i];
+		hlist_for_each_entry_safe(entry, tmp, bucket, hlist) {
+			mac = mlx4_mac_to_u64(entry->mac);
+			en_dbg(DRV, priv, "Registering MAC:%pM for deleting\n",
+			       entry->mac);
+			mlx4_en_uc_steer_release(priv, entry->mac,
+						 qpn, entry->reg_id);
+
+			mlx4_unregister_mac(priv->mdev->dev, priv->port, mac);
+			hlist_del_rcu(&entry->hlist);
+			kfree_rcu(entry, rcu);
+		}
+	}
+
+	if (priv->tunnel_reg_id) {
+		mlx4_flow_detach(priv->mdev->dev, priv->tunnel_reg_id);
+		priv->tunnel_reg_id = 0;
+	}
+}
+
 static void mlx4_en_tx_timeout(struct net_device *dev)
 {
 	struct mlx4_en_priv *priv = netdev_priv(dev);
@@ -1684,6 +1692,11 @@ int mlx4_en_start_port(struct net_device *dev)
 		goto tx_err;
 	}
 
+	/* Set Unicast and VXLAN steering rules */
+	if (mdev->dev->caps.steering_mode != MLX4_STEERING_MODE_A0 &&
+	    mlx4_en_set_rss_steer_rules(priv))
+		mlx4_warn(mdev, "Failed setting steering rules\n");
+
 	/* Attach rx QP to bradcast address */
 	eth_broadcast_addr(&mc_list[10]);
 	mc_list[5] = priv->port; /* needed for B0 steering support */
@@ -1831,6 +1844,9 @@ void mlx4_en_stop_port(struct net_device *dev, int detach)
 	for (i = 0; i < priv->tx_ring_num; i++)
 		mlx4_en_free_tx_buf(dev, priv->tx_ring[i]);
 
+	if (mdev->dev->caps.steering_mode != MLX4_STEERING_MODE_A0)
+		mlx4_en_delete_rss_steer_rules(priv);
+
 	/* Free RSS qps */
 	mlx4_en_release_rss_steer(priv);
 
-- 
2.3.7
