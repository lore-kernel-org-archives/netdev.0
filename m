From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 08/15] net/mlx5e: Use function to map aRFS into traffic type
Date: Fri, 16 Jun 2017 00:42:45 +0300
Message-ID: <20170615214252.30140-9-saeedm@mellanox.com>
References: <20170615214252.30140-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:32930 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752158AbdFOVnK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Jun 2017 17:43:10 -0400
In-Reply-To: <20170615214252.30140-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

For a better code reuse and readability, use the existing
function arfs_get_tt() to map arfs_type into mlx5e_traffic_types,
instead of duplicating the switch-case logic.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c | 21 +++++++--------------
 1 file changed, 7 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
index f4017c06ddd2..12d3ced61114 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_arfs.c
@@ -178,6 +178,7 @@ static int arfs_add_default_rule(struct mlx5e_priv *priv,
 	struct mlx5_flow_destination dest;
 	MLX5_DECLARE_FLOW_ACT(flow_act);
 	struct mlx5_flow_spec *spec;
+	enum mlx5e_traffic_types tt;
 	int err = 0;
 
 	spec = kvzalloc(sizeof(*spec), GFP_KERNEL);
@@ -187,24 +188,16 @@ static int arfs_add_default_rule(struct mlx5e_priv *priv,
 	}
 
 	dest.type = MLX5_FLOW_DESTINATION_TYPE_TIR;
-	switch (type) {
-	case ARFS_IPV4_TCP:
-		dest.tir_num = tir[MLX5E_TT_IPV4_TCP].tirn;
-		break;
-	case ARFS_IPV4_UDP:
-		dest.tir_num = tir[MLX5E_TT_IPV4_UDP].tirn;
-		break;
-	case ARFS_IPV6_TCP:
-		dest.tir_num = tir[MLX5E_TT_IPV6_TCP].tirn;
-		break;
-	case ARFS_IPV6_UDP:
-		dest.tir_num = tir[MLX5E_TT_IPV6_UDP].tirn;
-		break;
-	default:
+	tt = arfs_get_tt(type);
+	if (tt == -EINVAL) {
+		netdev_err(priv->netdev, "%s: bad arfs_type: %d\n",
+			   __func__, type);
 		err = -EINVAL;
 		goto out;
 	}
 
+	dest.tir_num = tir[tt].tirn;
+
 	arfs_t->default_rule = mlx5_add_flow_rules(arfs_t->ft.t, spec,
 						   &flow_act,
 						   &dest, 1);
-- 
2.11.0
