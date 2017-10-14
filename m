From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next 07/12] net/mlx5e: IPoIB, Support for setting PKEY index to underlay QP
Date: Sat, 14 Oct 2017 11:48:22 -0700
Message-ID: <20171014184827.18491-8-saeedm@mellanox.com>
References: <20171014184827.18491-1-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Alex Vesker <valex@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:43340 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1751680AbdJNSsv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 14 Oct 2017 14:48:51 -0400
In-Reply-To: <20171014184827.18491-1-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Vesker <valex@mellanox.com>

Added a function to set PKEY index to IPoIB device driver using the
already present set_id function. PKEY index is attached to the QP
during state modification.

Signed-off-by: Alex Vesker <valex@mellanox.com>
Reviewed-by: Erez Shitrit <erezsh@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c | 9 +++++++++
 drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h | 1 +
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
index 00f0e6a038bb..679c1f9af642 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.c
@@ -123,6 +123,7 @@ static int mlx5i_init_underlay_qp(struct mlx5e_priv *priv)
 
 	context->flags = cpu_to_be32(MLX5_QP_PM_MIGRATED << 11);
 	context->pri_path.port = 1;
+	context->pri_path.pkey_index = cpu_to_be16(ipriv->pkey_index);
 	context->qkey = cpu_to_be32(IB_DEFAULT_Q_KEY);
 
 	ret = mlx5_core_qp_modify(mdev, MLX5_CMD_OP_RST2INIT_QP, 0, context, qp);
@@ -529,6 +530,13 @@ static int mlx5i_xmit(struct net_device *dev, struct sk_buff *skb,
 	return mlx5i_sq_xmit(sq, skb, &mah->av, dqpn, ipriv->qkey);
 }
 
+static void mlx5i_set_pkey_index(struct net_device *netdev, int id)
+{
+	struct mlx5i_priv *ipriv = netdev_priv(netdev);
+
+	ipriv->pkey_index = (u16)id;
+}
+
 static int mlx5i_check_required_hca_cap(struct mlx5_core_dev *mdev)
 {
 	if (MLX5_CAP_GEN(mdev, port_type) != MLX5_CAP_PORT_TYPE_IB)
@@ -593,6 +601,7 @@ struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
 	rn->send = mlx5i_xmit;
 	rn->attach_mcast = mlx5i_attach_mcast;
 	rn->detach_mcast = mlx5i_detach_mcast;
+	rn->set_id = mlx5i_set_pkey_index;
 
 	return netdev;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
index a0f405f520f7..9a729883c3b3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib/ipoib.h
@@ -50,6 +50,7 @@ struct mlx5i_priv {
 	struct rdma_netdev rn; /* keep this first */
 	struct mlx5_core_qp qp;
 	u32    qkey;
+	u16    pkey_index;
 	char  *mlx5e_priv[0];
 };
 
-- 
2.14.2
