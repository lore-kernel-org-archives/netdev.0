From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 09/10] net/mlx5e: IPoIB, Add PTP support to IPoIB device driver
Date: Tue, 20 Jun 2017 17:13:13 +0300
Message-ID: <20170620141314.25620-10-saeedm@mellanox.com>
References: <20170620141314.25620-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Feras Daoud <ferasda@mellanox.com>,
        Eitan Rabin <rabin@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42077 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752014AbdFTONd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 10:13:33 -0400
In-Reply-To: <20170620141314.25620-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Feras Daoud <ferasda@mellanox.com>

Enable PTP for IPoIB rdma_netdev and add the ability
to get the time stamping parameters using ethtool.

Signed-off-by: Feras Daoud <ferasda@mellanox.com>
Signed-off-by: Eitan Rabin <rabin@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h            |  2 ++
 drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c    | 15 +++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c         |  4 ++++
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c |  9 +++++++++
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c   |  2 ++
 5 files changed, 28 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 318ef7f0292f..626683f0f487 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -1045,6 +1045,8 @@ int mlx5e_ethtool_get_coalesce(struct mlx5e_priv *priv,
 			       struct ethtool_coalesce *coal);
 int mlx5e_ethtool_set_coalesce(struct mlx5e_priv *priv,
 			       struct ethtool_coalesce *coal);
+int mlx5e_ethtool_get_ts_info(struct mlx5e_priv *priv,
+			      struct ethtool_ts_info *info);
 
 /* mlx5e generic netdev management API */
 struct net_device*
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
index fa472c4d3d00..ab46061f72ab 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_ethtool.c
@@ -1372,13 +1372,12 @@ static int mlx5e_set_pauseparam(struct net_device *netdev,
 	return err;
 }
 
-static int mlx5e_get_ts_info(struct net_device *dev,
-			     struct ethtool_ts_info *info)
+int mlx5e_ethtool_get_ts_info(struct mlx5e_priv *priv,
+			      struct ethtool_ts_info *info)
 {
-	struct mlx5e_priv *priv = netdev_priv(dev);
 	int ret;
 
-	ret = ethtool_op_get_ts_info(dev, info);
+	ret = ethtool_op_get_ts_info(priv->netdev, info);
 	if (ret)
 		return ret;
 
@@ -1401,6 +1400,14 @@ static int mlx5e_get_ts_info(struct net_device *dev,
 	return 0;
 }
 
+static int mlx5e_get_ts_info(struct net_device *dev,
+			     struct ethtool_ts_info *info)
+{
+	struct mlx5e_priv *priv = netdev_priv(dev);
+
+	return mlx5e_ethtool_get_ts_info(priv, info);
+}
+
 static __u32 mlx5e_get_wol_supported(struct mlx5_core_dev *mdev)
 {
 	__u32 ret = 0;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index da42d55939ed..abf6d2fcfe0f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -1046,6 +1046,7 @@ static inline void mlx5i_complete_rx_cqe(struct mlx5e_rq *rq,
 					 struct sk_buff *skb)
 {
 	struct net_device *netdev = rq->netdev;
+	struct mlx5e_tstamp *tstamp = rq->tstamp;
 	char *pseudo_header;
 	u8 *dgid;
 	u8 g;
@@ -1070,6 +1071,9 @@ static inline void mlx5i_complete_rx_cqe(struct mlx5e_rq *rq,
 	skb->ip_summed = CHECKSUM_COMPLETE;
 	skb->csum = csum_unfold((__force __sum16)cqe->check_sum);
 
+	if (unlikely(mlx5e_rx_hw_stamp(tstamp)))
+		mlx5e_fill_hwstamp(tstamp, get_cqe_ts(cqe), skb_hwtstamps(skb));
+
 	skb_record_rx_queue(skb, rq->ix);
 
 	if (likely(netdev->features & NETIF_F_RXHASH))
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
index 20105eda2e11..bf686f0fde5d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ethtool.c
@@ -113,6 +113,14 @@ static int mlx5i_get_coalesce(struct net_device *netdev,
 	return mlx5e_ethtool_get_coalesce(priv, coal);
 }
 
+static int mlx5i_get_ts_info(struct net_device *netdev,
+			     struct ethtool_ts_info *info)
+{
+	struct mlx5e_priv *priv = mlx5i_epriv(netdev);
+
+	return mlx5e_ethtool_get_ts_info(priv, info);
+}
+
 const struct ethtool_ops mlx5i_ethtool_ops = {
 	.get_drvinfo       = mlx5i_get_drvinfo,
 	.get_strings       = mlx5i_get_strings,
@@ -124,4 +132,5 @@ const struct ethtool_ops mlx5i_ethtool_ops = {
 	.set_channels      = mlx5i_set_channels,
 	.get_coalesce      = mlx5i_get_coalesce,
 	.set_coalesce      = mlx5i_set_coalesce,
+	.get_ts_info       = mlx5i_get_ts_info,
 };
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
index 52a58af571a2..58bf0665f50b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
@@ -382,6 +382,7 @@ static int mlx5i_open(struct net_device *netdev)
 
 	mlx5e_refresh_tirs(priv, false);
 	mlx5e_activate_priv_channels(priv);
+	mlx5e_timestamp_init(priv);
 
 	mutex_unlock(&priv->state_lock);
 	return 0;
@@ -406,6 +407,7 @@ static int mlx5i_close(struct net_device *netdev)
 
 	clear_bit(MLX5E_STATE_OPENED, &priv->state);
 
+	mlx5e_timestamp_cleanup(priv);
 	netif_carrier_off(priv->netdev);
 	mlx5e_deactivate_priv_channels(priv);
 	mlx5e_close_channels(&priv->channels);
-- 
2.11.0
