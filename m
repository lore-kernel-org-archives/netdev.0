From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [net V2 05/14] net/mlx5e: IPoIB, Modify add/remove underlay QPN flows
Date: Thu, 27 Jul 2017 16:56:08 +0300
Message-ID: <20170727135617.18559-6-saeedm@mellanox.com>
References: <20170727135617.18559-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Alex Vesker <valex@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40103 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751517AbdG0N5P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Jul 2017 09:57:15 -0400
In-Reply-To: <20170727135617.18559-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Vesker <valex@mellanox.com>

On interface remove, the clean-up was done incorrectly causing
an error in the log:
"SET_FLOW_TABLE_ROOT(0x92f) op_mod(0x0) failed...syndrome (0x7e9f14)"

This was caused by the following flow:
-ndo_uninit:
 Move QP state to RST (this disconnects the QP from FT),
 the QP cannot be attached to any FT unless it is in RTS.

-mlx5_rdma_netdev_free:
 cleanup_rx: Destroy FT
 cleanup_tx: Destroy QP and remove QPN from FT

This caused a problem when destroying current FT we tried to
re-attach the QP to the next FT which is not needed.

The correct flow is:
-mlx5_rdma_netdev_free:
	cleanup_rx: remove QPN from FT & Destroy FT
	cleanup_tx: Destroy QP

Fixes: 508541146af1 ("net/mlx5: Use underlay QPN from the root name space")
Signed-off-by: Alex Vesker <valex@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
index 1ee5bce85901..85298051a3e4 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
@@ -178,8 +178,6 @@ static int mlx5i_create_underlay_qp(struct mlx5_core_dev *mdev, struct mlx5_core
 
 static void mlx5i_destroy_underlay_qp(struct mlx5_core_dev *mdev, struct mlx5_core_qp *qp)
 {
-	mlx5_fs_remove_rx_underlay_qpn(mdev, qp->qpn);
-
 	mlx5_core_destroy_qp(mdev, qp);
 }
 
@@ -194,8 +192,6 @@ static int mlx5i_init_tx(struct mlx5e_priv *priv)
 		return err;
 	}
 
-	mlx5_fs_add_rx_underlay_qpn(priv->mdev, ipriv->qp.qpn);
-
 	err = mlx5e_create_tis(priv->mdev, 0 /* tc */, ipriv->qp.qpn, &priv->tisn[0]);
 	if (err) {
 		mlx5_core_warn(priv->mdev, "create tis failed, %d\n", err);
@@ -253,6 +249,7 @@ static void mlx5i_destroy_flow_steering(struct mlx5e_priv *priv)
 
 static int mlx5i_init_rx(struct mlx5e_priv *priv)
 {
+	struct mlx5i_priv *ipriv  = priv->ppriv;
 	int err;
 
 	err = mlx5e_create_indirect_rqt(priv);
@@ -271,12 +268,18 @@ static int mlx5i_init_rx(struct mlx5e_priv *priv)
 	if (err)
 		goto err_destroy_indirect_tirs;
 
-	err = mlx5i_create_flow_steering(priv);
+	err = mlx5_fs_add_rx_underlay_qpn(priv->mdev, ipriv->qp.qpn);
 	if (err)
 		goto err_destroy_direct_tirs;
 
+	err = mlx5i_create_flow_steering(priv);
+	if (err)
+		goto err_remove_rx_underlay_qpn;
+
 	return 0;
 
+err_remove_rx_underlay_qpn:
+	mlx5_fs_remove_rx_underlay_qpn(priv->mdev, ipriv->qp.qpn);
 err_destroy_direct_tirs:
 	mlx5e_destroy_direct_tirs(priv);
 err_destroy_indirect_tirs:
@@ -290,6 +293,9 @@ static int mlx5i_init_rx(struct mlx5e_priv *priv)
 
 static void mlx5i_cleanup_rx(struct mlx5e_priv *priv)
 {
+	struct mlx5i_priv *ipriv  = priv->ppriv;
+
+	mlx5_fs_remove_rx_underlay_qpn(priv->mdev, ipriv->qp.qpn);
 	mlx5i_destroy_flow_steering(priv);
 	mlx5e_destroy_direct_tirs(priv);
 	mlx5e_destroy_indirect_tirs(priv);
-- 
2.13.0
