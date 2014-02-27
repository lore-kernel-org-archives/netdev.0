From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 5/9] net/mlx4: Replace mlx4_en_mac_to_u64() with mlx4_mac_to_u64()
Date: Thu, 27 Feb 2014 14:27:02 +0200
Message-ID: <1393504026-13384-6-git-send-email-amirv@mellanox.com>
References: <1393504026-13384-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:53586 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752217AbaB0M10 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Feb 2014 07:27:26 -0500
In-Reply-To: <1393504026-13384-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugenia Emantayev <eugenia@mellanox.com>

Currently, the EN driver uses a private static function
mlx4_en_mac_to_u64(). Move it to a common include file (driver.h)
for mlx4_en and mlx4_ib for further use.


Signed-off-by: Eugenia Emantayev <eugenia@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 32 ++++++++------------------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  1 -
 include/linux/mlx4/driver.h                    | 15 ++++++++++++
 3 files changed, 25 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 2c0823b..3db5946 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -603,7 +603,7 @@ static int mlx4_en_get_qp(struct mlx4_en_priv *priv)
 	int err = 0;
 	u64 reg_id;
 	int *qpn = &priv->base_qpn;
-	u64 mac = mlx4_en_mac_to_u64(priv->dev->dev_addr);
+	u64 mac = mlx4_mac_to_u64(priv->dev->dev_addr);
 
 	en_dbg(DRV, priv, "Registering MAC: %pM for adding\n",
 	       priv->dev->dev_addr);
@@ -672,7 +672,7 @@ static void mlx4_en_put_qp(struct mlx4_en_priv *priv)
 	u64 mac;
 
 	if (dev->caps.steering_mode == MLX4_STEERING_MODE_A0) {
-		mac = mlx4_en_mac_to_u64(priv->dev->dev_addr);
+		mac = mlx4_mac_to_u64(priv->dev->dev_addr);
 		en_dbg(DRV, priv, "Registering MAC: %pM for deleting\n",
 		       priv->dev->dev_addr);
 		mlx4_unregister_mac(dev, priv->port, mac);
@@ -685,7 +685,7 @@ static void mlx4_en_put_qp(struct mlx4_en_priv *priv)
 		for (i = 0; i < MLX4_EN_MAC_HASH_SIZE; ++i) {
 			bucket = &priv->mac_hash[i];
 			hlist_for_each_entry_safe(entry, tmp, bucket, hlist) {
-				mac = mlx4_en_mac_to_u64(entry->mac);
+				mac = mlx4_mac_to_u64(entry->mac);
 				en_dbg(DRV, priv, "Registering MAC: %pM for deleting\n",
 				       entry->mac);
 				mlx4_en_uc_steer_release(priv, entry->mac,
@@ -715,14 +715,14 @@ static int mlx4_en_replace_mac(struct mlx4_en_priv *priv, int qpn,
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_dev *dev = mdev->dev;
 	int err = 0;
-	u64 new_mac_u64 = mlx4_en_mac_to_u64(new_mac);
+	u64 new_mac_u64 = mlx4_mac_to_u64(new_mac);
 
 	if (dev->caps.steering_mode != MLX4_STEERING_MODE_A0) {
 		struct hlist_head *bucket;
 		unsigned int mac_hash;
 		struct mlx4_mac_entry *entry;
 		struct hlist_node *tmp;
-		u64 prev_mac_u64 = mlx4_en_mac_to_u64(prev_mac);
+		u64 prev_mac_u64 = mlx4_mac_to_u64(prev_mac);
 
 		bucket = &priv->mac_hash[prev_mac[MLX4_EN_MAC_HASH_IDX]];
 		hlist_for_each_entry_safe(entry, tmp, bucket, hlist) {
@@ -751,18 +751,6 @@ static int mlx4_en_replace_mac(struct mlx4_en_priv *priv, int qpn,
 	return __mlx4_replace_mac(dev, priv->port, qpn, new_mac_u64);
 }
 
-u64 mlx4_en_mac_to_u64(u8 *addr)
-{
-	u64 mac = 0;
-	int i;
-
-	for (i = 0; i < ETH_ALEN; i++) {
-		mac <<= 8;
-		mac |= addr[i];
-	}
-	return mac;
-}
-
 static int mlx4_en_do_set_mac(struct mlx4_en_priv *priv)
 {
 	int err = 0;
@@ -1081,7 +1069,7 @@ static void mlx4_en_do_multicast(struct mlx4_en_priv *priv,
 		mlx4_en_cache_mclist(dev);
 		netif_addr_unlock_bh(dev);
 		list_for_each_entry(mclist, &priv->mc_list, list) {
-			mcast_addr = mlx4_en_mac_to_u64(mclist->addr);
+			mcast_addr = mlx4_mac_to_u64(mclist->addr);
 			mlx4_SET_MCAST_FLTR(mdev->dev, priv->port,
 					    mcast_addr, 0, MLX4_MCAST_CONFIG);
 		}
@@ -1173,7 +1161,7 @@ static void mlx4_en_do_uc_filter(struct mlx4_en_priv *priv,
 				found = true;
 
 			if (!found) {
-				mac = mlx4_en_mac_to_u64(entry->mac);
+				mac = mlx4_mac_to_u64(entry->mac);
 				mlx4_en_uc_steer_release(priv, entry->mac,
 							 priv->base_qpn,
 							 entry->reg_id);
@@ -1216,7 +1204,7 @@ static void mlx4_en_do_uc_filter(struct mlx4_en_priv *priv,
 				priv->flags |= MLX4_EN_FLAG_FORCE_PROMISC;
 				break;
 			}
-			mac = mlx4_en_mac_to_u64(ha->addr);
+			mac = mlx4_mac_to_u64(ha->addr);
 			memcpy(entry->mac, ha->addr, ETH_ALEN);
 			err = mlx4_register_mac(mdev->dev, priv->port, mac);
 			if (err < 0) {
@@ -2206,7 +2194,7 @@ static int mlx4_en_set_vf_mac(struct net_device *dev, int queue, u8 *mac)
 {
 	struct mlx4_en_priv *en_priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = en_priv->mdev;
-	u64 mac_u64 = mlx4_en_mac_to_u64(mac);
+	u64 mac_u64 = mlx4_mac_to_u64(mac);
 
 	if (!is_valid_ether_addr(mac))
 		return -EINVAL;
@@ -2407,7 +2395,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		if (mlx4_is_slave(priv->mdev->dev)) {
 			eth_hw_addr_random(dev);
 			en_warn(priv, "Assigned random MAC address %pM\n", dev->dev_addr);
-			mac_u64 = mlx4_en_mac_to_u64(dev->dev_addr);
+			mac_u64 = mlx4_mac_to_u64(dev->dev_addr);
 			mdev->dev->caps.def_mac[priv->port] = mac_u64;
 		} else {
 			en_err(priv, "Port: %d, invalid mac burned: %pM, quiting\n",
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index c59011d..4ff7da8 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -797,7 +797,6 @@ void mlx4_en_cleanup_filters(struct mlx4_en_priv *priv);
 
 #define MLX4_EN_NUM_SELF_TEST	5
 void mlx4_en_ex_selftest(struct net_device *dev, u32 *flags, u64 *buf);
-u64 mlx4_en_mac_to_u64(u8 *addr);
 void mlx4_en_ptp_overflow_check(struct mlx4_en_dev *mdev);
 
 /*
diff --git a/include/linux/mlx4/driver.h b/include/linux/mlx4/driver.h
index c257e1b..c68b9e4 100644
--- a/include/linux/mlx4/driver.h
+++ b/include/linux/mlx4/driver.h
@@ -64,4 +64,19 @@ void mlx4_unregister_interface(struct mlx4_interface *intf);
 
 void *mlx4_get_protocol_dev(struct mlx4_dev *dev, enum mlx4_protocol proto, int port);
 
+#ifndef ETH_ALEN
+#define ETH_ALEN       6
+#endif
+static inline u64 mlx4_mac_to_u64(u8 *addr)
+{
+	u64 mac = 0;
+	int i;
+
+	for (i = 0; i < ETH_ALEN; i++) {
+		mac <<= 8;
+		mac |= addr[i];
+	}
+	return mac;
+}
+
 #endif /* MLX4_DRIVER_H */
-- 
1.8.3.4
