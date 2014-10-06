From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V1 14/14] net/mlx4_en: Use the new tx_copybreak to set inline threshold
Date: Mon,  6 Oct 2014 09:16:03 +0300
Message-ID: <1412576163-7224-15-git-send-email-amirv@mellanox.com>
References: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:37938 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751377AbaJFGQd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Oct 2014 02:16:33 -0400
In-Reply-To: <1412576163-7224-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Instead of setting inline threshold using module parameter only on
driver load, use set_tunable() to set it dynamically.
No need to store the threshold per ring, using instead the netdev global
priv->prof->inline_thold
Initial value still is set using the module parameter, therefore
backward compatability is kept.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 44 +++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx4/en_tx.c      |  1 -
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |  1 -
 3 files changed, 44 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
index 42c9f8b..b2d9e1f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_ethtool.c
@@ -1267,6 +1267,48 @@ static u32 mlx4_en_get_priv_flags(struct net_device *dev)
 	return priv->pflags;
 }
 
+static int mlx4_en_get_tunable(struct net_device *dev,
+			       const struct ethtool_tunable *tuna,
+			       void *data)
+{
+	const struct mlx4_en_priv *priv = netdev_priv(dev);
+	int ret = 0;
+
+	switch (tuna->id) {
+	case ETHTOOL_TX_COPYBREAK:
+		*(u32 *)data = priv->prof->inline_thold;
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
+static int mlx4_en_set_tunable(struct net_device *dev,
+			       const struct ethtool_tunable *tuna,
+			       const void *data)
+{
+	struct mlx4_en_priv *priv = netdev_priv(dev);
+	int val, ret = 0;
+
+	switch (tuna->id) {
+	case ETHTOOL_TX_COPYBREAK:
+		val = *(u32 *)data;
+		if (val < MIN_PKT_LEN || val > MAX_INLINE)
+			ret = -EINVAL;
+		else
+			priv->prof->inline_thold = val;
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	}
+
+	return ret;
+}
+
 
 const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_drvinfo = mlx4_en_get_drvinfo,
@@ -1297,6 +1339,8 @@ const struct ethtool_ops mlx4_en_ethtool_ops = {
 	.get_ts_info = mlx4_en_get_ts_info,
 	.set_priv_flags = mlx4_en_set_priv_flags,
 	.get_priv_flags = mlx4_en_get_priv_flags,
+	.get_tunable = mlx4_en_get_tunable,
+	.set_tunable = mlx4_en_set_tunable,
 };
 
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index f0080c5..92a7cf4 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -66,7 +66,6 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 	ring->size = size;
 	ring->size_mask = size - 1;
 	ring->stride = stride;
-	ring->inline_thold = priv->prof->inline_thold;
 
 	tmp = size * sizeof(struct mlx4_en_tx_info);
 	ring->tx_info = kmalloc_node(tmp, GFP_KERNEL | __GFP_NOWARN, node);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index a904030..8fef658 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -295,7 +295,6 @@ struct mlx4_en_tx_ring {
 	bool			bf_alloced;
 	struct netdev_queue	*tx_queue;
 	int			hwtstamp_tx_type;
-	int			inline_thold;
 } ____cacheline_aligned_in_smp;
 
 struct mlx4_en_rx_desc {
-- 
1.8.3.1
