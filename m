From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net-next 06/10] net/mlx5e: Use hard_mtu as part of the mlx5e_priv struct
Date: Tue, 20 Jun 2017 17:13:10 +0300
Message-ID: <20170620141314.25620-7-saeedm@mellanox.com>
References: <20170620141314.25620-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Erez Shitrit <erezsh@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42052 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751789AbdFTONd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2017 10:13:33 -0400
In-Reply-To: <20170620141314.25620-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Erez Shitrit <erezsh@mellanox.com>

The mtu extra space that kept for the HW is specific for each link type,
and it is different in mlx5e and mlx5i modules.
Now it is kept in the priv structures, set by the mlx5e/mlx5i driver
accordingly.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/en.h          |  7 +++++--
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c     | 10 ++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_rep.c      |  3 +++
 drivers/net/ethernet/mellanox/mlx5/core/en_rx.c       |  6 +-----
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c |  6 ++++--
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h |  5 +++++
 6 files changed, 24 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index a223a8e15ece..318ef7f0292f 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -52,8 +52,10 @@
 
 #define MLX5_SET_CFG(p, f, v) MLX5_SET(create_flow_group_in, p, f, v)
 
-#define MLX5E_HW2SW_MTU(hwmtu) ((hwmtu) - (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
-#define MLX5E_SW2HW_MTU(swmtu) ((swmtu) + (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN))
+#define MLX5E_ETH_HARD_MTU (ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN)
+
+#define MLX5E_HW2SW_MTU(priv, hwmtu) ((hwmtu) - ((priv)->hard_mtu))
+#define MLX5E_SW2HW_MTU(priv, swmtu) ((swmtu) + ((priv)->hard_mtu))
 
 #define MLX5E_MAX_NUM_TC	8
 
@@ -747,6 +749,7 @@ struct mlx5e_priv {
 	struct mlx5e_tir           indir_tir[MLX5E_NUM_INDIR_TIRS];
 	struct mlx5e_tir           direct_tir[MLX5E_MAX_NUM_CHANNELS];
 	u32                        tx_rates[MLX5E_MAX_NUM_SQS];
+	int                        hard_mtu;
 
 	struct mlx5e_flow_steering fs;
 	struct mlx5e_vxlan_db      vxlan;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 343be65621db..de1e936fc2be 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -635,7 +635,7 @@ static int mlx5e_alloc_rq(struct mlx5e_channel *c,
 
 		rq->buff.wqe_sz = params->lro_en  ?
 				params->lro_wqe_sz :
-				MLX5E_SW2HW_MTU(c->netdev->mtu);
+				MLX5E_SW2HW_MTU(c->priv, c->netdev->mtu);
 		byte_count = rq->buff.wqe_sz;
 
 		/* calc the required page order */
@@ -2468,7 +2468,7 @@ static int mlx5e_modify_tirs_lro(struct mlx5e_priv *priv)
 static int mlx5e_set_mtu(struct mlx5e_priv *priv, u16 mtu)
 {
 	struct mlx5_core_dev *mdev = priv->mdev;
-	u16 hw_mtu = MLX5E_SW2HW_MTU(mtu);
+	u16 hw_mtu = MLX5E_SW2HW_MTU(priv, mtu);
 	int err;
 
 	err = mlx5_set_port_mtu(mdev, hw_mtu, 1);
@@ -2490,7 +2490,7 @@ static void mlx5e_query_mtu(struct mlx5e_priv *priv, u16 *mtu)
 	if (err || !hw_mtu) /* fallback to port oper mtu */
 		mlx5_query_port_oper_mtu(mdev, &hw_mtu, 1);
 
-	*mtu = MLX5E_HW2SW_MTU(hw_mtu);
+	*mtu = MLX5E_HW2SW_MTU(priv, hw_mtu);
 }
 
 static int mlx5e_set_dev_port_mtu(struct mlx5e_priv *priv)
@@ -3876,6 +3876,7 @@ void mlx5e_build_nic_params(struct mlx5_core_dev *mdev,
 	mlx5e_set_rq_params(mdev, params);
 
 	/* HW LRO */
+
 	/* TODO: && MLX5_CAP_ETH(mdev, lro_cap) */
 	if (params->rq_wq_type == MLX5_WQ_TYPE_LINKED_LIST_STRIDING_RQ)
 		params->lro_en = hw_lro_heuristic(link_speed, pci_bw);
@@ -3916,6 +3917,7 @@ static void mlx5e_build_nic_netdev_priv(struct mlx5_core_dev *mdev,
 	priv->netdev      = netdev;
 	priv->profile     = profile;
 	priv->ppriv       = ppriv;
+	priv->hard_mtu = MLX5E_ETH_HARD_MTU;
 
 	mlx5e_build_nic_params(mdev, &priv->channels.params, profile->max_nch(mdev));
 
@@ -4161,7 +4163,7 @@ static void mlx5e_nic_enable(struct mlx5e_priv *priv)
 	/* MTU range: 68 - hw-specific max */
 	netdev->min_mtu = ETH_MIN_MTU;
 	mlx5_query_port_max_mtu(priv->mdev, &max_mtu, 1);
-	netdev->max_mtu = MLX5E_HW2SW_MTU(max_mtu);
+	netdev->max_mtu = MLX5E_HW2SW_MTU(priv, max_mtu);
 	mlx5e_set_dev_port_mtu(priv);
 
 	mlx5_lag_add(mdev, netdev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
index a39873bd88a6..76cb6ad6e00b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rep.c
@@ -833,6 +833,9 @@ static void mlx5e_init_rep(struct mlx5_core_dev *mdev,
 	INIT_DELAYED_WORK(&priv->update_stats_work, mlx5e_update_stats_work);
 
 	priv->channels.params.num_channels = profile->max_nch(mdev);
+
+	priv->hard_mtu = MLX5E_ETH_HARD_MTU;
+
 	mlx5e_build_rep_params(mdev, &priv->channels.params);
 	mlx5e_build_rep_netdev(netdev);
 }
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
index 806139d62139..da42d55939ed 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_rx.c
@@ -648,7 +648,7 @@ static inline bool mlx5e_xmit_xdp_frame(struct mlx5e_rq *rq,
 	prefetchw(wqe);
 
 	if (unlikely(dma_len < MLX5E_XDP_MIN_INLINE ||
-		     MLX5E_SW2HW_MTU(rq->netdev->mtu) < dma_len)) {
+		     MLX5E_SW2HW_MTU(rq->channel->priv, rq->netdev->mtu) < dma_len)) {
 		rq->stats.xdp_drop++;
 		mlx5e_page_release(rq, di, true);
 		return false;
@@ -1038,11 +1038,7 @@ void mlx5e_free_xdpsq_descs(struct mlx5e_xdpsq *sq)
 #ifdef CONFIG_MLX5_CORE_IPOIB
 
 #define MLX5_IB_GRH_DGID_OFFSET 24
-#define MLX5_IB_GRH_BYTES       40
-#define MLX5_IPOIB_ENCAP_LEN    4
 #define MLX5_GID_SIZE           16
-#define MLX5_IPOIB_PSEUDO_LEN   20
-#define MLX5_IPOIB_HARD_LEN     (MLX5_IPOIB_PSEUDO_LEN + MLX5_IPOIB_ENCAP_LEN)
 
 static inline void mlx5i_complete_rx_cqe(struct mlx5e_rq *rq,
 					 struct mlx5_cqe64 *cqe,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
index 45ca869118c0..9cf5f465caae 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
@@ -73,16 +73,18 @@ static void mlx5i_init(struct mlx5_core_dev *mdev,
 {
 	struct mlx5e_priv *priv  = mlx5i_epriv(netdev);
 
+	/* priv init */
 	priv->mdev        = mdev;
 	priv->netdev      = netdev;
 	priv->profile     = profile;
 	priv->ppriv       = ppriv;
+	priv->hard_mtu = MLX5_IB_GRH_BYTES + MLX5_IPOIB_HARD_LEN;
+	mutex_init(&priv->state_lock);
 
 	mlx5e_build_nic_params(mdev, &priv->channels.params, profile->max_nch(mdev));
 	mlx5i_build_nic_params(mdev, &priv->channels.params);
 
-	mutex_init(&priv->state_lock);
-
+	/* netdev init */
 	netdev->hw_features    |= NETIF_F_SG;
 	netdev->hw_features    |= NETIF_F_IP_CSUM;
 	netdev->hw_features    |= NETIF_F_IPV6_CSUM;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
index 3553a06c8fa6..a0f405f520f7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
@@ -40,6 +40,11 @@
 
 extern const struct ethtool_ops mlx5i_ethtool_ops;
 
+#define MLX5_IB_GRH_BYTES       40
+#define MLX5_IPOIB_ENCAP_LEN    4
+#define MLX5_IPOIB_PSEUDO_LEN   20
+#define MLX5_IPOIB_HARD_LEN     (MLX5_IPOIB_PSEUDO_LEN + MLX5_IPOIB_ENCAP_LEN)
+
 /* ipoib rdma netdev's private data structure */
 struct mlx5i_priv {
 	struct rdma_netdev rn; /* keep this first */
-- 
2.11.0
