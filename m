From: Achiad Shochat <achiad@mellanox.com>
Subject: [PATCH net-next 1/8] net/mlx5e: Have a single RSS Toeplitz hash key
Date: Sun, 16 Aug 2015 16:04:45 +0300
Message-ID: <1439730292-29617-2-git-send-email-achiad@mellanox.com>
References: <1439730292-29617-1-git-send-email-achiad@mellanox.com>
Cc: netdev@vger.kernel.org, Achiad <achiad@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:38372 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751307AbbHPNHB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Aug 2015 09:07:01 -0400
In-Reply-To: <1439730292-29617-1-git-send-email-achiad@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to generate a unique key per TIR.
Generating a single key per netdev and copying it to all
its TIRs.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h      | 1 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 5 ++++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index e9d7d90..7b2b743 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -273,6 +273,7 @@ struct mlx5e_params {
 	u32 lro_wqe_sz;
 	u8  rss_hfunc;
 	u16 tx_max_inline;
+	u8 toeplitz_hash_key[40];
 };
 
 enum {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 111427b..662ca67 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1611,7 +1611,7 @@ static void mlx5e_build_tir_ctx(struct mlx5e_priv *priv, u32 *tirc, int tt)
 						       rx_hash_toeplitz_key);
 
 			MLX5_SET(tirc, tirc, rx_hash_symmetric, 1);
-			netdev_rss_key_fill(rss_key, len);
+			memcpy(rss_key, priv->params.toeplitz_hash_key, len);
 		}
 		break;
 	}
@@ -1939,6 +1939,9 @@ static void mlx5e_build_netdev_priv(struct mlx5_core_dev *mdev,
 	priv->params.default_vlan_prio     = 0;
 	priv->params.rss_hfunc             = ETH_RSS_HASH_XOR;
 
+	netdev_rss_key_fill(priv->params.toeplitz_hash_key,
+			    sizeof(priv->params.toeplitz_hash_key));
+
 	priv->params.lro_en = false && !!MLX5_CAP_ETH(priv->mdev, lro_cap);
 	priv->params.lro_wqe_sz            =
 		MLX5E_PARAMS_DEFAULT_LRO_WQE_SZ;
-- 
1.8.3.1
