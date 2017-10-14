From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next 12/12] net/mlx5e: IPoIB, Modify rdma netdev allocate and free to support PKEY
Date: Sat, 14 Oct 2017 11:48:27 -0700
Message-ID: <20171014184827.18491-13-saeedm@mellanox.com>
References: <20171014184827.18491-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Alex Vesker <valex@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43478 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751788AbdJNStH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 14:49:07 -0400
In-Reply-To: <20171014184827.18491-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Vesker <valex@mellanox.com>

Resources such as FT, QPN HT and mdev resources should be allocated
only by parent netdev. Shared resources are allocated and freed by the
parent interface since the parent is always present and created
before the IPoIB PKEY sub-interface.

Signed-off-by: Alex Vesker <valex@mellanox.com>
Reviewed-by: Erez Shitrit <erezsh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 .../net/ethernet/mellanox/mlx5/core/en_common.c    |  1 +
 .../net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c  | 52 ++++++++++++++--------
 .../net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h  |  1 +
 3 files changed, 36 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
index ece3fb147e3e..157d02917237 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
@@ -134,6 +134,7 @@ void mlx5e_destroy_mdev_resources(struct mlx5_core_dev *mdev)
 	mlx5_core_destroy_mkey(mdev, &res->mkey);
 	mlx5_core_dealloc_transport_domain(mdev, res->td.tdn);
 	mlx5_core_dealloc_pd(mdev, res->pdn);
+	memset(res, 0, sizeof(*res));
 }
 
 int mlx5e_refresh_tirs(struct mlx5e_priv *priv, bool enable_uc_lb)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
index 70706eb70d3e..abf270d7f556 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
@@ -560,12 +560,13 @@ struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
 					  const char *name,
 					  void (*setup)(struct net_device *))
 {
-	const struct mlx5e_profile *profile = &mlx5i_nic_profile;
-	int nch = profile->max_nch(mdev);
+	const struct mlx5e_profile *profile;
 	struct net_device *netdev;
 	struct mlx5i_priv *ipriv;
 	struct mlx5e_priv *epriv;
 	struct rdma_netdev *rn;
+	bool sub_interface;
+	int nch;
 	int err;
 
 	if (mlx5i_check_required_hca_cap(mdev)) {
@@ -573,10 +574,15 @@ struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
 		return ERR_PTR(-EOPNOTSUPP);
 	}
 
-	/* This function should only be called once per mdev */
-	err = mlx5e_create_mdev_resources(mdev);
-	if (err)
-		return NULL;
+	/* TODO: Need to find a better way to check if child device*/
+	sub_interface = (mdev->mlx5e_res.pdn != 0);
+
+	if (sub_interface)
+		profile = mlx5i_pkey_get_profile();
+	else
+		profile = &mlx5i_nic_profile;
+
+	nch = profile->max_nch(mdev);
 
 	netdev = alloc_netdev_mqs(sizeof(struct mlx5i_priv) + sizeof(struct mlx5e_priv),
 				  name, NET_NAME_UNKNOWN,
@@ -585,7 +591,7 @@ struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
 				  nch);
 	if (!netdev) {
 		mlx5_core_warn(mdev, "alloc_netdev_mqs failed\n");
-		goto free_mdev_resources;
+		return NULL;
 	}
 
 	ipriv = netdev_priv(netdev);
@@ -595,10 +601,18 @@ struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
 	if (!epriv->wq)
 		goto err_free_netdev;
 
-	err = mlx5i_pkey_qpn_ht_init(netdev);
-	if (err) {
-		mlx5_core_warn(mdev, "allocate qpn_to_netdev ht failed\n");
-		goto destroy_wq;
+	ipriv->sub_interface = sub_interface;
+	if (!ipriv->sub_interface) {
+		err = mlx5i_pkey_qpn_ht_init(netdev);
+		if (err) {
+			mlx5_core_warn(mdev, "allocate qpn_to_netdev ht failed\n");
+			goto destroy_wq;
+		}
+
+		/* This should only be called once per mdev */
+		err = mlx5e_create_mdev_resources(mdev);
+		if (err)
+			goto destroy_ht;
 	}
 
 	profile->init(mdev, netdev, profile, ipriv);
@@ -616,12 +630,12 @@ struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
 
 	return netdev;
 
+destroy_ht:
+	mlx5i_pkey_qpn_ht_cleanup(netdev);
 destroy_wq:
 	destroy_workqueue(epriv->wq);
 err_free_netdev:
 	free_netdev(netdev);
-free_mdev_resources:
-	mlx5e_destroy_mdev_resources(mdev);
 
 	return NULL;
 }
@@ -629,16 +643,18 @@ EXPORT_SYMBOL(mlx5_rdma_netdev_alloc);
 
 void mlx5_rdma_netdev_free(struct net_device *netdev)
 {
-	struct mlx5e_priv          *priv    = mlx5i_epriv(netdev);
+	struct mlx5e_priv *priv = mlx5i_epriv(netdev);
+	struct mlx5i_priv *ipriv = priv->ppriv;
 	const struct mlx5e_profile *profile = priv->profile;
-	struct mlx5_core_dev       *mdev    = priv->mdev;
 
 	mlx5e_detach_netdev(priv);
 	profile->cleanup(priv);
 	destroy_workqueue(priv->wq);
-	mlx5i_pkey_qpn_ht_cleanup(netdev);
-	free_netdev(netdev);
 
-	mlx5e_destroy_mdev_resources(mdev);
+	if (!ipriv->sub_interface) {
+		mlx5i_pkey_qpn_ht_cleanup(netdev);
+		mlx5e_destroy_mdev_resources(priv->mdev);
+	}
+	free_netdev(netdev);
 }
 EXPORT_SYMBOL(mlx5_rdma_netdev_free);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
index a50c1a19550e..49008022c306 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
@@ -50,6 +50,7 @@ extern const struct ethtool_ops mlx5i_pkey_ethtool_ops;
 struct mlx5i_priv {
 	struct rdma_netdev rn; /* keep this first */
 	struct mlx5_core_qp qp;
+	bool   sub_interface;
 	u32    qkey;
 	u16    pkey_index;
 	struct mlx5i_pkey_qpn_ht *qpn_htbl;
-- 
2.14.2
