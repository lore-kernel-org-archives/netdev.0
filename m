From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 5/6] net/mlx4_en: Cleanup MAC resources on module unload or port stop
Date: Thu,  7 Mar 2013 15:46:56 +0200
Message-ID: <1362664017-30275-6-git-send-email-ogerlitz@mellanox.com>
References: <1362664017-30275-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	Yan Burman <yanb@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog103.obsmtp.com ([207.126.144.115]:59303 "EHLO
	eu1sys200aog103.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753264Ab3CGNrN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 08:47:13 -0500
In-Reply-To: <1362664017-30275-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yan Burman <yanb@mellanox.com>

Make sure we cleanup all MAC related resources (entries in the port MAC
table and steering rules) when stopping a port or when the driver is unloaded.

The leak was introduced by commit 07cb4b0a "net/mlx4_en: Manage hash of MAC
addresses per port".

Signed-off-by: Yan Burman <yanb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   38 +++++++++++++----------
 1 files changed, 21 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 217e618..7fd0936 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -565,34 +565,38 @@ static void mlx4_en_put_qp(struct mlx4_en_priv *priv)
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_dev *dev = mdev->dev;
 	int qpn = priv->base_qpn;
-	u64 mac = mlx4_en_mac_to_u64(priv->dev->dev_addr);
-
-	en_dbg(DRV, priv, "Registering MAC: %pM for deleting\n",
-	       priv->dev->dev_addr);
-	mlx4_unregister_mac(dev, priv->port, mac);
+	u64 mac;
 
-	if (dev->caps.steering_mode != MLX4_STEERING_MODE_A0) {
+	if (dev->caps.steering_mode == MLX4_STEERING_MODE_A0) {
+		mac = mlx4_en_mac_to_u64(priv->dev->dev_addr);
+		en_dbg(DRV, priv, "Registering MAC: %pM for deleting\n",
+		       priv->dev->dev_addr);
+		mlx4_unregister_mac(dev, priv->port, mac);
+	} else {
 		struct mlx4_mac_entry *entry;
 		struct hlist_node *tmp;
 		struct hlist_head *bucket;
-		unsigned int mac_hash;
+		unsigned int i;
 
-		mac_hash = priv->dev->dev_addr[MLX4_EN_MAC_HASH_IDX];
-		bucket = &priv->mac_hash[mac_hash];
-		hlist_for_each_entry_safe(entry, tmp, bucket, hlist) {
-			if (ether_addr_equal_64bits(entry->mac,
-						    priv->dev->dev_addr)) {
-				en_dbg(DRV, priv, "Releasing qp: port %d, MAC %pM, qpn %d\n",
-				       priv->port, priv->dev->dev_addr, qpn);
+		for (i = 0; i < MLX4_EN_MAC_HASH_SIZE; ++i) {
+			bucket = &priv->mac_hash[i];
+			hlist_for_each_entry_safe(entry, tmp, bucket, hlist) {
+				mac = mlx4_en_mac_to_u64(entry->mac);
+				en_dbg(DRV, priv, "Registering MAC: %pM for deleting\n",
+				       entry->mac);
 				mlx4_en_uc_steer_release(priv, entry->mac,
 							 qpn, entry->reg_id);
-				mlx4_qp_release_range(dev, qpn, 1);
 
+				mlx4_unregister_mac(dev, priv->port, mac);
 				hlist_del_rcu(&entry->hlist);
 				kfree_rcu(entry, rcu);
-				break;
 			}
 		}
+
+		en_dbg(DRV, priv, "Releasing qp: port %d, qpn %d\n",
+		       priv->port, qpn);
+		mlx4_qp_release_range(dev, qpn, 1);
+		priv->flags &= ~MLX4_EN_FLAG_FORCE_PROMISC;
 	}
 }
 
-- 
1.7.1
