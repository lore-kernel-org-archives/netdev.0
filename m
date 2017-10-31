From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 13/14] net/mlx5e: Switch ipsec counters to use stats group API
Date: Tue, 31 Oct 2017 15:06:46 -0700
Message-ID: <20171031220647.23614-14-saeedm@mellanox.com>
References: <20171031220647.23614-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org,
        Stephen Hemminger <stephen@networkplumber.org>,
        Kamal Heib <kamalh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:56778 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932816AbdJaWIe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 18:08:34 -0400
In-Reply-To: <20171031220647.23614-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kamal Heib <kamalh@mellanox.com>

Switch the ipsec counters to use the new stats group API.

Signed-off-by: Kamal Heib <kamalh@mellanox.com>
Reviewed-by: Gal Pressman <galp@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 10 +--------
 drivers/net/ethernet/mellanox/mlx5/core/en_stats.c | 24 ++++++++++++++++++++++
 2 files changed, 25 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 6de948819034..ff21348b7623 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -31,7 +31,6 @@
  */
 
 #include "en.h"
-#include "en_accel/ipsec.h"
 
 void mlx5e_ethtool_get_drvinfo(struct mlx5e_priv *priv,
 			       struct ethtool_drvinfo *drvinfo)
@@ -150,8 +149,7 @@ int mlx5e_ethtool_get_sset_count(struct mlx5e_priv *priv, int sset)
 			num_stats += mlx5e_stats_grps[i].get_num_stats(priv);
 		return num_stats +
 		       MLX5E_NUM_RQ_STATS(priv) +
-		       MLX5E_NUM_SQ_STATS(priv) +
-		       mlx5e_ipsec_get_count(priv);
+		       MLX5E_NUM_SQ_STATS(priv);
 
 	case ETH_SS_PRIV_FLAGS:
 		return ARRAY_SIZE(mlx5e_priv_flags);
@@ -177,9 +175,6 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, u8 *data)
 	for (i = 0; i < mlx5e_num_stats_grps; i++)
 		idx = mlx5e_stats_grps[i].fill_strings(priv, data, idx);
 
-	/* IPSec counters */
-	idx += mlx5e_ipsec_get_strings(priv, data + idx * ETH_GSTRING_LEN);
-
 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
 		return;
 
@@ -244,9 +239,6 @@ void mlx5e_ethtool_get_ethtool_stats(struct mlx5e_priv *priv,
 	for (i = 0; i < mlx5e_num_stats_grps; i++)
 		idx = mlx5e_stats_grps[i].fill_stats(priv, data, idx);
 
-	/* IPSec counters */
-	idx += mlx5e_ipsec_get_stats(priv, data + idx);
-
 	if (!test_bit(MLX5E_STATE_OPENED, &priv->state))
 		return;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
index b120957ea940..930a8224e013 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_stats.c
@@ -31,6 +31,7 @@
  */
 
 #include "en.h"
+#include "en_accel/ipsec.h"
 
 static const struct counter_desc sw_stats_desc[] = {
 	{ MLX5E_DECLARE_STAT(struct mlx5e_sw_stats, rx_packets) },
@@ -702,6 +703,24 @@ static int mlx5e_grp_pme_fill_stats(struct mlx5e_priv *priv, u64 *data,
 	return idx;
 }
 
+static int mlx5e_grp_ipsec_get_num_stats(struct mlx5e_priv *priv)
+{
+	return mlx5e_ipsec_get_count(priv);
+}
+
+static int mlx5e_grp_ipsec_fill_strings(struct mlx5e_priv *priv, u8 *data,
+					int idx)
+{
+	return idx + mlx5e_ipsec_get_strings(priv,
+					     data + idx * ETH_GSTRING_LEN);
+}
+
+static int mlx5e_grp_ipsec_fill_stats(struct mlx5e_priv *priv, u64 *data,
+				      int idx)
+{
+	return idx + mlx5e_ipsec_get_stats(priv, data + idx);
+}
+
 const struct mlx5e_stats_grp mlx5e_stats_grps[] = {
 	{
 		.get_num_stats = mlx5e_grp_sw_get_num_stats,
@@ -763,6 +782,11 @@ const struct mlx5e_stats_grp mlx5e_stats_grps[] = {
 		.fill_strings = mlx5e_grp_pme_fill_strings,
 		.fill_stats = mlx5e_grp_pme_fill_stats,
 	},
+	{
+		.get_num_stats = mlx5e_grp_ipsec_get_num_stats,
+		.fill_strings = mlx5e_grp_ipsec_fill_strings,
+		.fill_stats = mlx5e_grp_ipsec_fill_stats,
+	},
 };
 
 const int mlx5e_num_stats_grps = ARRAY_SIZE(mlx5e_stats_grps);
-- 
2.14.2
