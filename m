From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 6/6] net/mlx4_en: Fix mac_hash database inconsistency
Date: Tue,  8 Jul 2014 11:25:24 +0300
Message-ID: <1404807924-29038-7-git-send-email-amirv@mellanox.com>
References: <1404807924-29038-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Noa Osherovich <noaos@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:44711 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753748AbaGHI0l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2014 04:26:41 -0400
In-Reply-To: <1404807924-29038-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Noa Osherovich <noaos@mellanox.com>

Using a local copy of dev_addr in mlx4_en_set_mac() to prevent dev_addr
from being modified during error flow or when dev_addr is modified in
another context (which is another problem that is being discussed over
the mailing list [1]).
Also fixing bad naming of priv->prev_mac into priv->current_mac.

[1] - http://patchwork.ozlabs.org/patch/351489/


Reviewed-by: Eyal Perry <eyalpe@mellanox.com>
Signed-off-by: Noa Osherovich <noaos@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c | 23 ++++++++++++++---------
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h   |  2 +-
 2 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index 255950a..f384b354 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -760,21 +760,22 @@ static int mlx4_en_replace_mac(struct mlx4_en_priv *priv, int qpn,
 	return __mlx4_replace_mac(dev, priv->port, qpn, new_mac_u64);
 }
 
-static int mlx4_en_do_set_mac(struct mlx4_en_priv *priv)
+static int mlx4_en_do_set_mac(struct mlx4_en_priv *priv,
+			      unsigned char new_mac[ETH_ALEN + 2])
 {
 	int err = 0;
 
 	if (priv->port_up) {
 		/* Remove old MAC and insert the new one */
 		err = mlx4_en_replace_mac(priv, priv->base_qpn,
-					  priv->dev->dev_addr, priv->prev_mac);
+					  new_mac, priv->current_mac);
 		if (err)
 			en_err(priv, "Failed changing HW MAC address\n");
 	} else
 		en_dbg(HW, priv, "Port is down while registering mac, exiting...\n");
 
-	memcpy(priv->prev_mac, priv->dev->dev_addr,
-	       sizeof(priv->prev_mac));
+	if (!err)
+		memcpy(priv->current_mac, new_mac, sizeof(priv->current_mac));
 
 	return err;
 }
@@ -784,14 +785,17 @@ static int mlx4_en_set_mac(struct net_device *dev, void *addr)
 	struct mlx4_en_priv *priv = netdev_priv(dev);
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct sockaddr *saddr = addr;
+	unsigned char new_mac[ETH_ALEN + 2];
 	int err;
 
 	if (!is_valid_ether_addr(saddr->sa_data))
 		return -EADDRNOTAVAIL;
 
 	mutex_lock(&mdev->state_lock);
-	memcpy(dev->dev_addr, saddr->sa_data, ETH_ALEN);
-	err = mlx4_en_do_set_mac(priv);
+	memcpy(new_mac, saddr->sa_data, ETH_ALEN);
+	err = mlx4_en_do_set_mac(priv, new_mac);
+	if (!err)
+		memcpy(dev->dev_addr, saddr->sa_data, ETH_ALEN);
 	mutex_unlock(&mdev->state_lock);
 
 	return err;
@@ -1156,7 +1160,8 @@ static void mlx4_en_do_uc_filter(struct mlx4_en_priv *priv,
 			}
 
 			/* MAC address of the port is not in uc list */
-			if (ether_addr_equal_64bits(entry->mac, dev->dev_addr))
+			if (ether_addr_equal_64bits(entry->mac,
+						    priv->current_mac))
 				found = true;
 
 			if (!found) {
@@ -1466,7 +1471,7 @@ static void mlx4_en_do_get_stats(struct work_struct *work)
 		queue_delayed_work(mdev->workqueue, &priv->stats_task, STATS_DELAY);
 	}
 	if (mdev->mac_removed[MLX4_MAX_PORTS + 1 - priv->port]) {
-		mlx4_en_do_set_mac(priv);
+		mlx4_en_do_set_mac(priv, priv->current_mac);
 		mdev->mac_removed[MLX4_MAX_PORTS + 1 - priv->port] = 0;
 	}
 	mutex_unlock(&mdev->state_lock);
@@ -2524,7 +2529,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 		}
 	}
 
-	memcpy(priv->prev_mac, dev->dev_addr, sizeof(priv->prev_mac));
+	memcpy(priv->current_mac, dev->dev_addr, sizeof(priv->current_mac));
 
 	priv->stride = roundup_pow_of_two(sizeof(struct mlx4_en_rx_desc) +
 					  DS_SIZE * MLX4_EN_MAX_RX_FRAGS);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index 01011d4..7c1b5ec 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -530,7 +530,7 @@ struct mlx4_en_priv {
 	int registered;
 	int allocated;
 	int stride;
-	unsigned char prev_mac[ETH_ALEN + 2];
+	unsigned char current_mac[ETH_ALEN + 2];
 	int mac_index;
 	unsigned max_mtu;
 	int base_qpn;
-- 
1.8.3.4
