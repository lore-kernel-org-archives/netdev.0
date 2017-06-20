From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 03/10] net/mlx5e: IPoIB, Add ethtool support
Date: Tue, 20 Jun 2017 17:13:07 +0300
Message-ID: <20170620141314.25620-4-saeedm@mellanox.com>
References: <20170620141314.25620-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Erez Shitrit <erezsh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42046 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751038AbdFTONd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 10:13:33 -0400
In-Reply-To: <20170620141314.25620-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.com>

Add support for the following:
	"ethtool -S" (statistics).
	"ethtool -i" (driver info).
	"ethtool -g/G" (rings parameters).
	"ethtool -l/L" (channels parameters).
	"ethtool -c/C" (coalesce options).

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  21 ++++
 .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   | 138 +++++++++++++++------
 .../ethernet/mellanox/mlx5/core/ipoib/ethtool.c    | 127 +++++++++++++++++++
 .../net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c  |   2 +-
 .../net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h  |   2 +
 6 files changed, 255 insertions(+), 37 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 59b87b30e438..5ad093a21a6e 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -15,4 +15,4 @@ mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o eswitch_offloads.o \
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
 
-mlx5_core-$(CONFIG_MLX5_CORE_IPOIB) += ipoib/ipoib.o
+mlx5_core-$(CONFIG_MLX5_CORE_IPOIB) += ipoib/ipoib.o ipoib/ethtool.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 8094e78292de..49c5fe9fdff0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -1021,6 +1021,27 @@ int mlx5e_open(struct net_device *netdev);
 void mlx5e_update_stats_work(struct work_struct *work);
 u32 mlx5e_choose_lro_timeout(struct mlx5_core_dev *mdev, u32 wanted_timeout);
 
+/* ethtool helpers */
+void mlx5e_ethtool_get_drvinfo(struct mlx5e_priv *priv,
+			       struct ethtool_drvinfo *drvinfo);
+void mlx5e_ethtool_get_strings(struct mlx5e_priv *priv,
+			       uint32_t stringset, uint8_t *data);
+int mlx5e_ethtool_get_sset_count(struct mlx5e_priv *priv, int sset);
+void mlx5e_ethtool_get_ethtool_stats(struct mlx5e_priv *priv,
+				     struct ethtool_stats *stats, u64 *data);
+void mlx5e_ethtool_get_ringparam(struct mlx5e_priv *priv,
+				 struct ethtool_ringparam *param);
+int mlx5e_ethtool_set_ringparam(struct mlx5e_priv *priv,
+				struct ethtool_ringparam *param);
+void mlx5e_ethtool_get_channels(struct mlx5e_priv *priv,
+				struct ethtool_channels *ch);
+int mlx5e_ethtool_set_channels(struct mlx5e_priv *priv,
+			       struct ethtool_channels *ch);
+int mlx5e_ethtool_get_coalesce(struct mlx5e_priv *priv,
+			       struct ethtool_coalesce *coal);
+int mlx5e_ethtool_set_coalesce(struct mlx5e_priv *priv,
+			       struct ethtool_coalesce *coal);
+
 /* mlx5e generic netdev management API */
 struct net_device*
 mlx5e_create_netdev(struct mlx5_core_dev *mdev, const struct mlx5e_profile *profile,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index 7408c298ce2f..fa472c4d3d00 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -32,10 +32,9 @@
 
 #include "en.h"
 
-static void mlx5e_get_drvinfo(struct net_device *dev,
-			      struct ethtool_drvinfo *drvinfo)
+void mlx5e_ethtool_get_drvinfo(struct mlx5e_priv *priv,
+			       struct ethtool_drvinfo *drvinfo)
 {
-	struct mlx5e_priv *priv = netdev_priv(dev);
 	struct mlx5_core_dev *mdev = priv->mdev;
 
 	strlcpy(drvinfo->driver, DRIVER_NAME, sizeof(drvinfo->driver));
@@ -49,6 +48,14 @@ static void mlx5e_get_drvinfo(struct net_device *dev,
 		sizeof(drvinfo->bus_info));
 }
 
+static void mlx5e_get_drvinfo(struct net_device *dev,
+			      struct ethtool_drvinfo *drvinfo)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	mlx5e_ethtool_get_drvinfo(priv, drvinfo);
+}
+
 struct ptys2ethtool_config {
 	__ETHTOOL_DECLARE_LINK_MODE_MASK(supported);
 	__ETHTOOL_DECLARE_LINK_MODE_MASK(advertised);
@@ -166,9 +173,8 @@ static bool mlx5e_query_global_pause_combined(struct mlx5e_priv *priv)
 	((mlx5e_query_global_pause_combined(priv) + hweight8(mlx5e_query_pfc_combined(priv))) * \
 	  NUM_PPORT_PER_PRIO_PFC_COUNTERS)
 
-static int mlx5e_get_sset_count(struct net_device *dev, int sset)
+int mlx5e_ethtool_get_sset_count(struct mlx5e_priv *priv, int sset)
 {
-	struct mlx5e_priv *priv = netdev_priv(dev);
 
 	switch (sset) {
 	case ETH_SS_STATS:
@@ -192,6 +198,13 @@ static int mlx5e_get_sset_count(struct net_device *dev, int sset)
 	}
 }
 
+static int mlx5e_get_sset_count(struct net_device *dev, int sset)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	return mlx5e_ethtool_get_sset_count(priv, sset);
+}
+
 static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, uint8_t *data)
 {
 	int i, j, tc, prio, idx = 0;
@@ -279,10 +292,9 @@ static void mlx5e_fill_stats_strings(struct mlx5e_priv *priv, uint8_t *data)
 					priv->channel_tc2txq[i][tc]);
 }
 
-static void mlx5e_get_strings(struct net_device *dev,
-			      uint32_t stringset, uint8_t *data)
+void mlx5e_ethtool_get_strings(struct mlx5e_priv *priv,
+			       uint32_t stringset, uint8_t *data)
 {
-	struct mlx5e_priv *priv = netdev_priv(dev);
 	int i;
 
 	switch (stringset) {
@@ -303,10 +315,17 @@ static void mlx5e_get_strings(struct net_device *dev,
 	}
 }
 
-static void mlx5e_get_ethtool_stats(struct net_device *dev,
-				    struct ethtool_stats *stats, u64 *data)
+static void mlx5e_get_strings(struct net_device *dev,
+			      uint32_t stringset, uint8_t *data)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	mlx5e_ethtool_get_strings(priv, stringset, data);
+}
+
+void mlx5e_ethtool_get_ethtool_stats(struct mlx5e_priv *priv,
+				     struct ethtool_stats *stats, u64 *data)
+{
 	struct mlx5e_channels *channels;
 	struct mlx5_priv *mlx5_priv;
 	int i, j, tc, prio, idx = 0;
@@ -401,6 +420,15 @@ static void mlx5e_get_ethtool_stats(struct net_device *dev,
 								   sq_stats_desc, j);
 }
 
+static void mlx5e_get_ethtool_stats(struct net_device *dev,
+				    struct ethtool_stats *stats,
+				    u64 *data)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	mlx5e_ethtool_get_ethtool_stats(priv, stats, data);
+}
+
 static u32 mlx5e_rx_wqes_to_packets(struct mlx5e_priv *priv, int rq_wq_type,
 				    int num_wqe)
 {
@@ -445,10 +473,9 @@ static u32 mlx5e_packets_to_rx_wqes(struct mlx5e_priv *priv, int rq_wq_type,
 	return 1 << (order_base_2(num_wqes));
 }
 
-static void mlx5e_get_ringparam(struct net_device *dev,
-				struct ethtool_ringparam *param)
+void mlx5e_ethtool_get_ringparam(struct mlx5e_priv *priv,
+				 struct ethtool_ringparam *param)
 {
-	struct mlx5e_priv *priv = netdev_priv(dev);
 	int rq_wq_type = priv->channels.params.rq_wq_type;
 
 	param->rx_max_pending = mlx5e_rx_wqes_to_packets(priv, rq_wq_type,
@@ -459,10 +486,17 @@ static void mlx5e_get_ringparam(struct net_device *dev,
 	param->tx_pending     = 1 << priv->channels.params.log_sq_size;
 }
 
-static int mlx5e_set_ringparam(struct net_device *dev,
-			       struct ethtool_ringparam *param)
+static void mlx5e_get_ringparam(struct net_device *dev,
+				struct ethtool_ringparam *param)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	mlx5e_ethtool_get_ringparam(priv, param);
+}
+
+int mlx5e_ethtool_set_ringparam(struct mlx5e_priv *priv,
+				struct ethtool_ringparam *param)
+{
 	int rq_wq_type = priv->channels.params.rq_wq_type;
 	struct mlx5e_channels new_channels = {};
 	u32 rx_pending_wqes;
@@ -474,12 +508,12 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 	int err = 0;
 
 	if (param->rx_jumbo_pending) {
-		netdev_info(dev, "%s: rx_jumbo_pending not supported\n",
+		netdev_info(priv->netdev, "%s: rx_jumbo_pending not supported\n",
 			    __func__);
 		return -EINVAL;
 	}
 	if (param->rx_mini_pending) {
-		netdev_info(dev, "%s: rx_mini_pending not supported\n",
+		netdev_info(priv->netdev, "%s: rx_mini_pending not supported\n",
 			    __func__);
 		return -EINVAL;
 	}
@@ -492,13 +526,13 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 						   param->rx_pending);
 
 	if (param->rx_pending < min_rq_size) {
-		netdev_info(dev, "%s: rx_pending (%d) < min (%d)\n",
+		netdev_info(priv->netdev, "%s: rx_pending (%d) < min (%d)\n",
 			    __func__, param->rx_pending,
 			    min_rq_size);
 		return -EINVAL;
 	}
 	if (param->rx_pending > max_rq_size) {
-		netdev_info(dev, "%s: rx_pending (%d) > max (%d)\n",
+		netdev_info(priv->netdev, "%s: rx_pending (%d) > max (%d)\n",
 			    __func__, param->rx_pending,
 			    max_rq_size);
 		return -EINVAL;
@@ -507,19 +541,19 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 	num_mtts = MLX5E_REQUIRED_MTTS(rx_pending_wqes);
 	if (priv->channels.params.rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ &&
 	    !MLX5E_VALID_NUM_MTTS(num_mtts)) {
-		netdev_info(dev, "%s: rx_pending (%d) request can't be satisfied, try to reduce.\n",
+		netdev_info(priv->netdev, "%s: rx_pending (%d) request can't be satisfied, try to reduce.\n",
 			    __func__, param->rx_pending);
 		return -EINVAL;
 	}
 
 	if (param->tx_pending < (1 << MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE)) {
-		netdev_info(dev, "%s: tx_pending (%d) < min (%d)\n",
+		netdev_info(priv->netdev, "%s: tx_pending (%d) < min (%d)\n",
 			    __func__, param->tx_pending,
 			    1 << MLX5E_PARAMS_MINIMUM_LOG_SQ_SIZE);
 		return -EINVAL;
 	}
 	if (param->tx_pending > (1 << MLX5E_PARAMS_MAXIMUM_LOG_SQ_SIZE)) {
-		netdev_info(dev, "%s: tx_pending (%d) > max (%d)\n",
+		netdev_info(priv->netdev, "%s: tx_pending (%d) > max (%d)\n",
 			    __func__, param->tx_pending,
 			    1 << MLX5E_PARAMS_MAXIMUM_LOG_SQ_SIZE);
 		return -EINVAL;
@@ -555,26 +589,39 @@ static int mlx5e_set_ringparam(struct net_device *dev,
 	return err;
 }
 
-static void mlx5e_get_channels(struct net_device *dev,
-			       struct ethtool_channels *ch)
+static int mlx5e_set_ringparam(struct net_device *dev,
+			       struct ethtool_ringparam *param)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
 
+	return mlx5e_ethtool_set_ringparam(priv, param);
+}
+
+void mlx5e_ethtool_get_channels(struct mlx5e_priv *priv,
+				struct ethtool_channels *ch)
+{
 	ch->max_combined   = priv->profile->max_nch(priv->mdev);
 	ch->combined_count = priv->channels.params.num_channels;
 }
 
-static int mlx5e_set_channels(struct net_device *dev,
-			      struct ethtool_channels *ch)
+static void mlx5e_get_channels(struct net_device *dev,
+			       struct ethtool_channels *ch)
 {
 	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	mlx5e_ethtool_get_channels(priv, ch);
+}
+
+int mlx5e_ethtool_set_channels(struct mlx5e_priv *priv,
+			       struct ethtool_channels *ch)
+{
 	unsigned int count = ch->combined_count;
 	struct mlx5e_channels new_channels = {};
 	bool arfs_enabled;
 	int err = 0;
 
 	if (!count) {
-		netdev_info(dev, "%s: combined_count=0 not supported\n",
+		netdev_info(priv->netdev, "%s: combined_count=0 not supported\n",
 			    __func__);
 		return -EINVAL;
 	}
@@ -599,7 +646,7 @@ static int mlx5e_set_channels(struct net_device *dev,
 	if (err)
 		goto out;
 
-	arfs_enabled = dev->features & NETIF_F_NTUPLE;
+	arfs_enabled = priv->netdev->features & NETIF_F_NTUPLE;
 	if (arfs_enabled)
 		mlx5e_arfs_disable(priv);
 
@@ -609,7 +656,7 @@ static int mlx5e_set_channels(struct net_device *dev,
 	if (arfs_enabled) {
 		err = mlx5e_arfs_enable(priv);
 		if (err)
-			netdev_err(dev, "%s: mlx5e_arfs_enable failed: %d\n",
+			netdev_err(priv->netdev, "%s: mlx5e_arfs_enable failed: %d\n",
 				   __func__, err);
 	}
 
@@ -619,11 +666,17 @@ static int mlx5e_set_channels(struct net_device *dev,
 	return err;
 }
 
-static int mlx5e_get_coalesce(struct net_device *netdev,
-			      struct ethtool_coalesce *coal)
+static int mlx5e_set_channels(struct net_device *dev,
+			      struct ethtool_channels *ch)
 {
-	struct mlx5e_priv *priv = netdev_priv(netdev);
+	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	return mlx5e_ethtool_set_channels(priv, ch);
+}
 
+int mlx5e_ethtool_get_coalesce(struct mlx5e_priv *priv,
+			       struct ethtool_coalesce *coal)
+{
 	if (!MLX5_CAP_GEN(priv->mdev, cq_moderation))
 		return -EOPNOTSUPP;
 
@@ -636,6 +689,14 @@ static int mlx5e_get_coalesce(struct net_device *netdev,
 	return 0;
 }
 
+static int mlx5e_get_coalesce(struct net_device *netdev,
+			      struct ethtool_coalesce *coal)
+{
+	struct mlx5e_priv *priv = netdev_priv(netdev);
+
+	return mlx5e_ethtool_get_coalesce(priv, coal);
+}
+
 static void
 mlx5e_set_priv_channels_coalesce(struct mlx5e_priv *priv, struct ethtool_coalesce *coal)
 {
@@ -659,10 +720,9 @@ mlx5e_set_priv_channels_coalesce(struct mlx5e_priv *priv, struct ethtool_coalesc
 	}
 }
 
-static int mlx5e_set_coalesce(struct net_device *netdev,
-			      struct ethtool_coalesce *coal)
+int mlx5e_ethtool_set_coalesce(struct mlx5e_priv *priv,
+			       struct ethtool_coalesce *coal)
 {
-	struct mlx5e_priv *priv    = netdev_priv(netdev);
 	struct mlx5_core_dev *mdev = priv->mdev;
 	struct mlx5e_channels new_channels = {};
 	int err = 0;
@@ -705,6 +765,14 @@ static int mlx5e_set_coalesce(struct net_device *netdev,
 	return err;
 }
 
+static int mlx5e_set_coalesce(struct net_device *netdev,
+			      struct ethtool_coalesce *coal)
+{
+	struct mlx5e_priv *priv    = netdev_priv(netdev);
+
+	return mlx5e_ethtool_set_coalesce(priv, coal);
+}
+
 static void ptys2ethtool_supported_link(unsigned long *supported_modes,
 					u32 eth_proto_cap)
 {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
new file mode 100644
index 000000000000..20105eda2e11
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
@@ -0,0 +1,127 @@
+/*
+ * Copyright (c) 2017, Mellanox Technologies. All rights reserved.
+ *
+ * This software is available to you under a choice of one of two
+ * licenses.  You may choose to be licensed under the terms of the GNU
+ * General Public License (GPL) Version 2, available from the file
+ * COPYING in the main directory of this source tree, or the
+ * OpenIB.org BSD license below:
+ *
+ *     Redistribution and use in source and binary forms, with or
+ *     without modification, are permitted provided that the following
+ *     conditions are met:
+ *
+ *      - Redistributions of source code must retain the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer.
+ *
+ *      - Redistributions in binary form must reproduce the above
+ *        copyright notice, this list of conditions and the following
+ *        disclaimer in the documentation and/or other materials
+ *        provided with the distribution.
+ *
+ * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
+ * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
+ * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
+ * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
+ * BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
+ * ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
+ * CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
+ * SOFTWARE.
+ */
+
+#include "en.h"
+#include "ipoib.h"
+
+static void mlx5i_get_drvinfo(struct net_device *dev,
+			      struct ethtool_drvinfo *drvinfo)
+{
+	struct mlx5e_priv *priv = mlx5i_epriv(dev);
+
+	mlx5e_ethtool_get_drvinfo(priv, drvinfo);
+}
+
+static void mlx5i_get_strings(struct net_device *dev,
+			      uint32_t stringset, uint8_t *data)
+{
+	struct mlx5e_priv *priv  = mlx5i_epriv(dev);
+
+	mlx5e_ethtool_get_strings(priv, stringset, data);
+}
+
+static int mlx5i_get_sset_count(struct net_device *dev, int sset)
+{
+	struct mlx5e_priv *priv = mlx5i_epriv(dev);
+
+	return mlx5e_ethtool_get_sset_count(priv, sset);
+}
+
+static void mlx5i_get_ethtool_stats(struct net_device *dev,
+				    struct ethtool_stats *stats,
+				    u64 *data)
+{
+	struct mlx5e_priv *priv = mlx5i_epriv(dev);
+
+	mlx5e_ethtool_get_ethtool_stats(priv, stats, data);
+}
+
+static int mlx5i_set_ringparam(struct net_device *dev,
+			       struct ethtool_ringparam *param)
+{
+	struct mlx5e_priv *priv = mlx5i_epriv(dev);
+
+	return mlx5e_ethtool_set_ringparam(priv, param);
+}
+
+static void mlx5i_get_ringparam(struct net_device *dev,
+				struct ethtool_ringparam *param)
+{
+	struct mlx5e_priv *priv = mlx5i_epriv(dev);
+
+	mlx5e_ethtool_get_ringparam(priv, param);
+}
+
+static int mlx5i_set_channels(struct net_device *dev,
+			      struct ethtool_channels *ch)
+{
+	struct mlx5e_priv *priv = mlx5i_epriv(dev);
+
+	return mlx5e_ethtool_set_channels(priv, ch);
+}
+
+static void mlx5i_get_channels(struct net_device *dev,
+			       struct ethtool_channels *ch)
+{
+	struct mlx5e_priv *priv = mlx5i_epriv(dev);
+
+	mlx5e_ethtool_get_channels(priv, ch);
+}
+
+static int mlx5i_set_coalesce(struct net_device *netdev,
+			      struct ethtool_coalesce *coal)
+{
+	struct mlx5e_priv *priv = mlx5i_epriv(netdev);
+
+	return mlx5e_ethtool_set_coalesce(priv, coal);
+}
+
+static int mlx5i_get_coalesce(struct net_device *netdev,
+			      struct ethtool_coalesce *coal)
+{
+	struct mlx5e_priv *priv = mlx5i_epriv(netdev);
+
+	return mlx5e_ethtool_get_coalesce(priv, coal);
+}
+
+const struct ethtool_ops mlx5i_ethtool_ops = {
+	.get_drvinfo       = mlx5i_get_drvinfo,
+	.get_strings       = mlx5i_get_strings,
+	.get_sset_count    = mlx5i_get_sset_count,
+	.get_ethtool_stats = mlx5i_get_ethtool_stats,
+	.get_ringparam     = mlx5i_get_ringparam,
+	.set_ringparam     = mlx5i_set_ringparam,
+	.get_channels      = mlx5i_get_channels,
+	.set_channels      = mlx5i_set_channels,
+	.get_coalesce      = mlx5i_get_coalesce,
+	.set_coalesce      = mlx5i_set_coalesce,
+};
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
index 22ca59145e6c..fdeb426d4751 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
@@ -82,6 +82,7 @@ static void mlx5i_init(struct mlx5_core_dev *mdev,
 	netdev->hw_features    |= NETIF_F_RXHASH;
 
 	netdev->netdev_ops = &mlx5i_netdev_ops;
+	netdev->ethtool_ops = &mlx5i_ethtool_ops;
 }
 
 /* Called directly before IPoIB netdevice is destroyed to cleanup SW structs */
@@ -510,4 +511,3 @@ void mlx5_rdma_netdev_free(struct net_device *netdev)
 	mlx5e_destroy_mdev_resources(priv->mdev);
 }
 EXPORT_SYMBOL(mlx5_rdma_netdev_free);
-
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
index 213191a78464..3553a06c8fa6 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
@@ -38,6 +38,8 @@
 
 #define MLX5I_MAX_NUM_TC 1
 
+extern const struct ethtool_ops mlx5i_ethtool_ops;
+
 /* ipoib rdma netdev's private data structure */
 struct mlx5i_priv {
 	struct rdma_netdev rn; /* keep this first */
-- 
2.11.0
