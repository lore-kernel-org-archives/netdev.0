From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 8/9] net/mlx4_en: Add unicast MAC filtering
Date: Tue,  5 Feb 2013 13:28:35 +0200
Message-ID: <1360063716-13415-9-git-send-email-amirv@mellanox.com>
References: <1360063716-13415-1-git-send-email-amirv@mellanox.com>
Cc: Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Yan Burman <yanb@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog104.obsmtp.com ([207.126.144.117]:34844 "HELO
	eu1sys200aog104.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751476Ab3BEL3B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2013 06:29:01 -0500
In-Reply-To: <1360063716-13415-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yan Burman <yanb@mellanox.com>

Implement and advertise unicast MAC filtering, such that setting macvlan
instance over mlx4_en interfaces will not require the networking core
to put mlx4_en devices in promiscuous mode.

Signed-off-by: Yan Burman <yanb@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  103 ++++++++++++++++++++++++
 1 files changed, 103 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index f402b20..e5d1d79 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -1018,6 +1018,103 @@ static void mlx4_en_do_multicast(struct mlx4_en_priv *priv,
 	}
 }
 
+static void mlx4_en_do_uc_filter(struct mlx4_en_priv *priv,
+				 struct net_device *dev,
+				 struct mlx4_en_dev *mdev)
+{
+	struct netdev_hw_addr *ha;
+	struct mlx4_mac_entry *entry;
+	struct hlist_node *n, *tmp;
+	bool found;
+	u64 mac;
+	int err = 0;
+	struct hlist_head *bucket;
+	unsigned int i;
+
+	/* Note that we do not need to protect our mac_hash traversal with rcu,
+	 * since all modification code is protected by mdev->state_lock
+	 */
+
+	/* find what to add */
+	netdev_for_each_uc_addr(ha, dev) {
+		found = false;
+		bucket = &priv->mac_hash[ha->addr[MLX4_EN_MAC_HASH_IDX]];
+		hlist_for_each_entry(entry, n, bucket, hlist) {
+			if (ether_addr_equal_64bits(entry->mac, ha->addr)) {
+				found = true;
+				break;
+			}
+		}
+
+		if (!found) {
+			entry = kmalloc(sizeof(*entry), GFP_KERNEL);
+			if (!entry) {
+				en_err(priv, "Failed adding MAC %pM on port:%d (out of memory)\n",
+				       ha->addr, priv->port);
+				return;
+			}
+			mac = mlx4_en_mac_to_u64(ha->addr);
+			memcpy(entry->mac, ha->addr, ETH_ALEN);
+			err = mlx4_register_mac(mdev->dev, priv->port, mac);
+			if (err < 0) {
+				en_err(priv, "Failed registering MAC %pM on port %d: %d\n",
+				       ha->addr, priv->port, err);
+				kfree(entry);
+				continue;
+			}
+			err = mlx4_en_uc_steer_add(priv, ha->addr,
+						   &priv->base_qpn,
+						   &entry->reg_id);
+			if (err) {
+				en_err(priv, "Failed adding MAC %pM on port:%d\n",
+				       ha->addr, priv->port);
+				mlx4_unregister_mac(mdev->dev, priv->port, mac);
+				kfree(entry);
+			} else {
+				unsigned int mac_hash;
+				en_dbg(DRV, priv, "Added MAC %pM on port:%d\n",
+				       ha->addr, priv->port);
+				mac_hash = ha->addr[MLX4_EN_MAC_HASH_IDX];
+				bucket = &priv->mac_hash[mac_hash];
+				hlist_add_head_rcu(&entry->hlist, bucket);
+			}
+		}
+	}
+
+	/* find what to remove */
+	for (i = 0; i < MLX4_EN_MAC_HASH_SIZE; ++i) {
+		bucket = &priv->mac_hash[i];
+		hlist_for_each_entry_safe(entry, n, tmp, bucket, hlist) {
+			found = false;
+			netdev_for_each_uc_addr(ha, dev) {
+				if (ether_addr_equal_64bits(entry->mac,
+							    ha->addr)) {
+					found = true;
+					break;
+				}
+			}
+
+			/* MAC address of the port is not in uc list */
+			if (ether_addr_equal_64bits(entry->mac, dev->dev_addr))
+				found = true;
+
+			if (!found) {
+				mac = mlx4_en_mac_to_u64(entry->mac);
+				mlx4_en_uc_steer_release(priv, entry->mac,
+							 priv->base_qpn,
+							 entry->reg_id);
+				mlx4_unregister_mac(mdev->dev, priv->port, mac);
+
+				hlist_del_rcu(&entry->hlist);
+				synchronize_rcu();
+				kfree(entry);
+				en_dbg(DRV, priv, "Removed MAC %pM on port:%d\n",
+				       entry->mac, priv->port);
+			}
+		}
+	}
+}
+
 static void mlx4_en_do_set_rx_mode(struct work_struct *work)
 {
 	struct mlx4_en_priv *priv = container_of(work, struct mlx4_en_priv,
@@ -1045,6 +1142,9 @@ static void mlx4_en_do_set_rx_mode(struct work_struct *work)
 		}
 	}
 
+	if (dev->priv_flags & IFF_UNICAST_FLT)
+		mlx4_en_do_uc_filter(priv, dev, mdev);
+
 	/* Promsicuous mode: disable all filters */
 	if (dev->flags & IFF_PROMISC) {
 		mlx4_en_set_promisc_mode(priv, mdev);
@@ -1963,6 +2063,9 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 	    MLX4_STEERING_MODE_DEVICE_MANAGED)
 		dev->hw_features |= NETIF_F_NTUPLE;
 
+	if (mdev->dev->caps.steering_mode != MLX4_STEERING_MODE_A0)
+		dev->priv_flags |= IFF_UNICAST_FLT;
+
 	mdev->pndev[port] = dev;
 
 	netif_carrier_off(dev);
-- 
1.7.6.4
