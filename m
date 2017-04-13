From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 10/16] net/mlx5e: IPoIB, Underlay QP
Date: Thu, 13 Apr 2017 06:37:00 +0300
Message-ID: <20170413033706.19016-11-saeedm@mellanox.com>
References: <20170413033706.19016-1-saeedm@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Vishwanathapura Niranjana <niranjana.vishwanathapura-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170413033706.19016-1-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Create IPoIB underlay QP needed by the IPoIB netdevice profile for RSS
and TX HW context to perform on IPoIB traffic.

Reset the underlay QP on dev_uninit ndo to stop IPoIB traffic going
through this QP when the ULP IPoIB decides to cleanup.

Implement attach/detach mcast RDMA netdev callbacks for later RDMA
netdev use.

Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c | 126 +++++++++++++++++++++++-
 1 file changed, 124 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
index e188d067bc97..bd56f36066b3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
@@ -34,6 +34,8 @@
 #include "en.h"
 #include "ipoib.h"
 
+#define IB_DEFAULT_Q_KEY   0xb1b
+
 static int mlx5i_open(struct net_device *netdev);
 static int mlx5i_close(struct net_device *netdev);
 static int  mlx5i_dev_init(struct net_device *dev);
@@ -83,12 +85,89 @@ static void mlx5i_cleanup(struct mlx5e_priv *priv)
 	/* Do nothing .. */
 }
 
+#define MLX5_QP_ENHANCED_ULP_STATELESS_MODE 2
+
+static int mlx5i_create_underlay_qp(struct mlx5_core_dev *mdev, struct mlx5_core_qp *qp)
+{
+	struct mlx5_qp_context *context = NULL;
+	u32 *in = NULL;
+	void *addr_path;
+	int ret = 0;
+	int inlen;
+	void *qpc;
+
+	inlen = MLX5_ST_SZ_BYTES(create_qp_in);
+	in = mlx5_vzalloc(inlen);
+	if (!in)
+		return -ENOMEM;
+
+	qpc = MLX5_ADDR_OF(create_qp_in, in, qpc);
+	MLX5_SET(qpc, qpc, st, MLX5_QP_ST_UD);
+	MLX5_SET(qpc, qpc, pm_state, MLX5_QP_PM_MIGRATED);
+	MLX5_SET(qpc, qpc, ulp_stateless_offload_mode,
+		 MLX5_QP_ENHANCED_ULP_STATELESS_MODE);
+
+	addr_path = MLX5_ADDR_OF(qpc, qpc, primary_address_path);
+	MLX5_SET(ads, addr_path, port, 1);
+	MLX5_SET(ads, addr_path, grh, 1);
+
+	ret = mlx5_core_create_qp(mdev, qp, in, inlen);
+	if (ret) {
+		mlx5_core_err(mdev, "Failed creating IPoIB QP err : %d\n", ret);
+		goto out;
+	}
+
+	/* QP states */
+	context = kzalloc(sizeof(*context), GFP_KERNEL);
+	if (!context) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	context->flags = cpu_to_be32(MLX5_QP_PM_MIGRATED << 11);
+	context->pri_path.port = 1;
+	context->qkey = cpu_to_be32(IB_DEFAULT_Q_KEY);
+
+	ret = mlx5_core_qp_modify(mdev, MLX5_CMD_OP_RST2INIT_QP, 0, context, qp);
+	if (ret) {
+		mlx5_core_err(mdev, "Failed to modify qp RST2INIT, err: %d\n", ret);
+		goto out;
+	}
+	memset(context, 0, sizeof(*context));
+
+	ret = mlx5_core_qp_modify(mdev, MLX5_CMD_OP_INIT2RTR_QP, 0, context, qp);
+	if (ret) {
+		mlx5_core_err(mdev, "Failed to modify qp INIT2RTR, err: %d\n", ret);
+		goto out;
+	}
+
+	ret = mlx5_core_qp_modify(mdev, MLX5_CMD_OP_RTR2RTS_QP, 0, context, qp);
+	if (ret) {
+		mlx5_core_err(mdev, "Failed to modify qp RTR2RTS, err: %d\n", ret);
+		goto out;
+	}
+
+out:
+	kfree(context);
+	kvfree(in);
+	return ret;
+}
+
+static void mlx5i_destroy_underlay_qp(struct mlx5_core_dev *mdev, struct mlx5_core_qp *qp)
+{
+	mlx5_core_destroy_qp(mdev, qp);
+}
+
 static int mlx5i_init_tx(struct mlx5e_priv *priv)
 {
 	struct mlx5i_priv *ipriv = priv->ppriv;
 	int err;
 
-	/* TODO: Create IPoIB underlay QP */
+	err = mlx5i_create_underlay_qp(priv->mdev, &ipriv->qp);
+	if (err) {
+		mlx5_core_warn(priv->mdev, "create underlay QP failed, %d\n", err);
+		return err;
+	}
 
 	err = mlx5e_create_tis(priv->mdev, 0 /* tc */, ipriv->qp.qpn, &priv->tisn[0]);
 	if (err) {
@@ -101,7 +180,10 @@ static int mlx5i_init_tx(struct mlx5e_priv *priv)
 
 void mlx5i_cleanup_tx(struct mlx5e_priv *priv)
 {
+	struct mlx5i_priv *ipriv = priv->ppriv;
+
 	mlx5e_destroy_tis(priv->mdev, priv->tisn[0]);
+	mlx5i_destroy_underlay_qp(priv->mdev, &ipriv->qp);
 }
 
 static int mlx5i_create_flow_steering(struct mlx5e_priv *priv)
@@ -220,7 +302,13 @@ static int mlx5i_dev_init(struct net_device *dev)
 
 static void mlx5i_dev_cleanup(struct net_device *dev)
 {
-	/* TODO: detach underlay qp from flow-steering by reset it */
+	struct mlx5e_priv    *priv   = mlx5i_epriv(dev);
+	struct mlx5_core_dev *mdev   = priv->mdev;
+	struct mlx5i_priv    *ipriv  = priv->ppriv;
+	struct mlx5_qp_context context;
+
+	/* detach qp from flow-steering by reset it */
+	mlx5_core_qp_modify(mdev, MLX5_CMD_OP_2RST_QP, 0, &context, &ipriv->qp);
 }
 
 static int mlx5i_open(struct net_device *netdev)
@@ -270,6 +358,40 @@ static int mlx5i_close(struct net_device *netdev)
 }
 
 /* IPoIB RDMA netdev callbacks */
+int mlx5i_attach_mcast(struct net_device *netdev, struct ib_device *hca,
+		       union ib_gid *gid, u16 lid, int set_qkey)
+{
+	struct mlx5e_priv    *epriv = mlx5i_epriv(netdev);
+	struct mlx5_core_dev *mdev  = epriv->mdev;
+	struct mlx5i_priv    *ipriv = epriv->ppriv;
+	int err;
+
+	mlx5_core_dbg(mdev, "attaching QPN 0x%x, MGID %pI6\n", ipriv->qp.qpn, gid->raw);
+	err = mlx5_core_attach_mcg(mdev, gid, ipriv->qp.qpn);
+	if (err)
+		mlx5_core_warn(mdev, "failed attaching QPN 0x%x, MGID %pI6\n",
+			       ipriv->qp.qpn, gid->raw);
+
+	return err;
+}
+
+int mlx5i_detach_mcast(struct net_device *netdev, struct ib_device *hca,
+		       union ib_gid *gid, u16 lid)
+{
+	struct mlx5e_priv    *epriv = mlx5i_epriv(netdev);
+	struct mlx5_core_dev *mdev  = epriv->mdev;
+	struct mlx5i_priv    *ipriv = epriv->ppriv;
+	int err;
+
+	mlx5_core_dbg(mdev, "detaching QPN 0x%x, MGID %pI6\n", ipriv->qp.qpn, gid->raw);
+
+	err = mlx5_core_detach_mcg(mdev, gid, ipriv->qp.qpn);
+	if (err)
+		mlx5_core_dbg(mdev, "failed dettaching QPN 0x%x, MGID %pI6\n",
+			      ipriv->qp.qpn, gid->raw);
+
+	return err;
+}
 
 static int mlx5i_check_required_hca_cap(struct mlx5_core_dev *mdev)
 {
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
