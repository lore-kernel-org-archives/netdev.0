From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net 6/8] net/mlx5e: Modify TIRs hash only when it's needed
Date: Fri, 27 Jan 2017 22:38:41 +0200
Message-ID: <20170127203843.3206-7-saeedm@mellanox.com>
References: <20170127203843.3206-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Gal Pressman <galp@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:33324 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751354AbdA0VLL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 16:11:11 -0500
In-Reply-To: <20170127203843.3206-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gal Pressman <galp@mellanox.com>

We don't need to modify our TIRs unless the user requested a change in
the hash function/key, for example when changing indirection only.

Fixes: bdfc028de1b3 ("net/mlx5e: Fix ethtool RX hash func configuration change")
Signed-off-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c | 18 +++++++++++++-----
 1 file changed, 13 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index ffbdf9ee5a9b..6f4eb34259f0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -996,6 +996,7 @@ static int mlx5e_set_rxfh(struct net_device *dev, const u32 *indir,
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 	int inlen = MLX5_ST_SZ_BYTES(modify_tir_in);
+	bool hash_changed = false;
 	void *in;
 
 	if ((hfunc != ETH_RSS_HASH_NO_CHANGE) &&
@@ -1017,14 +1018,21 @@ static int mlx5e_set_rxfh(struct net_device *dev, const u32 *indir,
 		mlx5e_redirect_rqt(priv, rqtn, MLX5E_INDIR_RQT_SIZE, 0);
 	}
 
-	if (key)
+	if (hfunc != ETH_RSS_HASH_NO_CHANGE &&
+	    hfunc != priv->params.rss_hfunc) {
+		priv->params.rss_hfunc = hfunc;
+		hash_changed = true;
+	}
+
+	if (key) {
 		memcpy(priv->params.toeplitz_hash_key, key,
 		       sizeof(priv->params.toeplitz_hash_key));
+		hash_changed = hash_changed ||
+			       priv->params.rss_hfunc == ETH_RSS_HASH_TOP;
+	}
 
-	if (hfunc != ETH_RSS_HASH_NO_CHANGE)
-		priv->params.rss_hfunc = hfunc;
-
-	mlx5e_modify_tirs_hash(priv, in, inlen);
+	if (hash_changed)
+		mlx5e_modify_tirs_hash(priv, in, inlen);
 
 	mutex_unlock(&priv->state_lock);
 
-- 
2.11.0
