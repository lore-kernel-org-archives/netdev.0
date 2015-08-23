From: Achiad Shochat <achiad@mellanox.com>
Subject: [PATCH net-next] net/mlx5e: Avoid accessing NULL pointer at ndo_select_queue
Date: Sun, 23 Aug 2015 16:12:14 +0300
Message-ID: <1440335534-31279-1-git-send-email-achiad@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Rana Shahout <ranas@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:37378 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752366AbbHWNOw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2015 09:14:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rana Shahout <ranas@mellanox.com>

To avoid multiply/division operations on the data path,
we hold a {channel, tc}==>txq mapping table.
We held this mapping table inside the channel object that is
being destroyed upon some configuration operations (e.g MTU change).
So in case ndo_select_queue occurs during such a configuration operation,
it may access a NULL channel pointer, resulting in kernel panic.
To fix this issue we moved the {channel, tc}==>txq mapping table
outside the channel object so that it will be available also
during such configuration operations.


Signed-off-by: Rana Shahout <ranas@mellanox.com>

---
Hi Dave,

This patch fixes a bug in the mlx5 Ethernet driver that causes
a kernel panic due to a NULL pointer access upon the select_queue
callback, in cause it happens in congestion with certain configuration
operations.

The path was applied and tested over commit dc25b25 ("Merge
git://git.kernel.org/pub/scm/linux/kernel/git/davem/net").

Thanks,
Achiad

 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 8 ++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   | 2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 27ca459..0983a20 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -405,7 +405,6 @@ struct mlx5e_channel {
 	__be32                     mkey_be;
 	u8                         num_tc;
 	unsigned long              flags;
-	int                        tc_to_txq_map[MLX5E_MAX_NUM_TC];
 
 	/* control */
 	struct mlx5e_priv         *priv;
@@ -475,6 +474,7 @@ struct mlx5e_priv {
 	/* priv data path fields - start */
 	int                        default_vlan_prio;
 	struct mlx5e_sq            **txq_to_sq_map;
+	int channeltc_to_txq_map[MLX5E_MAX_NUM_CHANNELS][MLX5E_MAX_NUM_TC];
 	/* priv data path fields - end */
 
 	unsigned long              state;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 55166dd..59874d6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -949,13 +949,13 @@ static void mlx5e_close_sqs(struct mlx5e_channel *c)
 		mlx5e_close_sq(&c->sq[tc]);
 }
 
-static void mlx5e_build_tc_to_txq_map(struct mlx5e_channel *c,
-				      int num_channels)
+static void mlx5e_build_channeltc_to_txq_map(struct mlx5e_priv *priv, int ix)
 {
 	int i;
 
 	for (i = 0; i < MLX5E_MAX_NUM_TC; i++)
-		c->tc_to_txq_map[i] = c->ix + i * num_channels;
+		priv->channeltc_to_txq_map[ix][i] =
+			ix + i * priv->params.num_channels;
 }
 
 static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
@@ -979,7 +979,7 @@ static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 	c->mkey_be  = cpu_to_be32(priv->mr.key);
 	c->num_tc   = priv->params.num_tc;
 
-	mlx5e_build_tc_to_txq_map(c, priv->params.num_channels);
+	mlx5e_build_channeltc_to_txq_map(priv, ix);
 
 	netif_napi_add(netdev, &c->napi, mlx5e_napi_poll, 64);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
index 64380bc..b73672f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_tx.c
@@ -106,7 +106,7 @@ u16 mlx5e_select_queue(struct net_device *dev, struct sk_buff *skb,
 		 priv->default_vlan_prio;
 	int tc = netdev_get_prio_tc_map(dev, up);
 
-	return priv->channel[channel_ix]->tc_to_txq_map[tc];
+	return priv->channeltc_to_txq_map[channel_ix][tc];
 }
 
 static inline u16 mlx5e_get_inline_hdr_size(struct mlx5e_sq *sq,
-- 
1.8.3.1
