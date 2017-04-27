From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH rdma-next] IB/mlx5: Enable IPoIB acceleration
Date: Thu, 27 Apr 2017 17:01:34 +0300
Message-ID: <20170427140134.11886-1-leon@kernel.org>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Enable mlx5 IPoIB acceleration by declaring
mlx5_ib_{alloc,free}_rdma_netdev and assigning the mlx5
IPoIB rdma_netdev callbacks.

In addition, this patch brings in sync mlx5's IPoIB parts for net and IB
trees. As a precaution, we disabled IPoIB acceleration by default (in
the mlx5_core Kconfig file).

Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
Hi Doug,

This is connection patch between IPoIB mlx5_core and mlx5_ib parts.

The patch itself is based on merge between your's k.o/for-4.12-rdma-netdevice
commit cc47dd684ee04f9f49f081002a74ef1ba9d14cc8 and David's master
commit b1513c35317c106a1588f3ab32f6888f0e2afd71 , because there was patch
from Stephen exactly in that area:
http://marc.info/?l=linux-netdev&m=149288674816288&w=2

Are you OK with this base?
Or do you prefer patch which will be based on your's branch, which will fail
in merge tests (linux-next) between yours and Dave's tree?

Thanks

Cc: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Cc: David S. Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
---
 drivers/infiniband/hw/mlx5/main.c               | 22 +++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c | 44 +++++++++++++++----------
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.h |  2 ++
 include/linux/mlx5/driver.h                     | 19 +++++++++++
 5 files changed, 70 insertions(+), 19 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 9f3ba320ce70..d45772da0963 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -3530,6 +3530,26 @@ static int mlx5_ib_get_hw_stats(struct ib_device *ibdev,
 	return num_counters;
 }

+static struct net_device*
+mlx5_ib_alloc_rdma_netdev(struct ib_device *hca,
+			  u8 port_num,
+			  enum rdma_netdev_t type,
+			  const char *name,
+			  unsigned char name_assign_type,
+			  void (*setup)(struct net_device *))
+{
+	if (type != RDMA_NETDEV_IPOIB)
+		return ERR_PTR(-EOPNOTSUPP);
+
+	return mlx5_rdma_netdev_alloc(to_mdev(hca)->mdev, hca,
+				      name, setup);
+}
+
+static void mlx5_ib_free_rdma_netdev(struct net_device *netdev)
+{
+	return mlx5_rdma_netdev_free(netdev);
+}
+
 static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 {
 	struct mlx5_ib_dev *dev;
@@ -3660,6 +3680,8 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 	dev->ib_dev.check_mr_status	= mlx5_ib_check_mr_status;
 	dev->ib_dev.get_port_immutable  = mlx5_port_immutable;
 	dev->ib_dev.get_dev_fw_str      = get_dev_fw_str;
+	dev->ib_dev.alloc_rdma_netdev	= mlx5_ib_alloc_rdma_netdev;
+	dev->ib_dev.free_rdma_netdev	= mlx5_ib_free_rdma_netdev;
 	if (mlx5_core_is_pf(mdev)) {
 		dev->ib_dev.get_vf_config	= mlx5_ib_get_vf_config;
 		dev->ib_dev.set_vf_link_state	= mlx5_ib_set_vf_link_state;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index a84b652f9b54..fc52d742b7f7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -35,6 +35,6 @@ config MLX5_CORE_EN_DCB
 config MLX5_CORE_IPOIB
 	bool "Mellanox Technologies ConnectX-4 IPoIB offloads support"
 	depends on MLX5_CORE_EN
-	default y
+	default n
 	---help---
 	  MLX5 IPoIB offloads & acceleration support.
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
index 3c84e36af018..019c230da498 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
@@ -30,6 +30,7 @@
  * SOFTWARE.
  */

+#include <rdma/ib_verbs.h>
 #include <linux/mlx5/fs.h>
 #include "en.h"
 #include "ipoib.h"
@@ -359,10 +360,10 @@ static int mlx5i_close(struct net_device *netdev)
 	return 0;
 }

-#ifdef notusedyet
 /* IPoIB RDMA netdev callbacks */
 static int mlx5i_attach_mcast(struct net_device *netdev, struct ib_device *hca,
-			      union ib_gid *gid, u16 lid, int set_qkey)
+			      union ib_gid *gid, u16 lid, int set_qkey,
+			      u32 qkey)
 {
 	struct mlx5e_priv    *epriv = mlx5i_epriv(netdev);
 	struct mlx5_core_dev *mdev  = epriv->mdev;
@@ -375,6 +376,12 @@ static int mlx5i_attach_mcast(struct net_device *netdev, struct ib_device *hca,
 		mlx5_core_warn(mdev, "failed attaching QPN 0x%x, MGID %pI6\n",
 			       ipriv->qp.qpn, gid->raw);

+	if (set_qkey) {
+		mlx5_core_dbg(mdev, "%s setting qkey 0x%x\n",
+			      netdev->name, qkey);
+		ipriv->qkey = qkey;
+	}
+
 	return err;
 }

@@ -397,15 +404,15 @@ static int mlx5i_detach_mcast(struct net_device *netdev, struct ib_device *hca,
 }

 static int mlx5i_xmit(struct net_device *dev, struct sk_buff *skb,
-	       struct ib_ah *address, u32 dqpn, u32 dqkey)
+		      struct ib_ah *address, u32 dqpn)
 {
 	struct mlx5e_priv *epriv = mlx5i_epriv(dev);
 	struct mlx5e_txqsq *sq   = epriv->txq2sq[skb_get_queue_mapping(skb)];
 	struct mlx5_ib_ah *mah   = to_mah(address);
+	struct mlx5i_priv *ipriv = epriv->ppriv;

-	return mlx5i_sq_xmit(sq, skb, &mah->av, dqpn, dqkey);
+	return mlx5i_sq_xmit(sq, skb, &mah->av, dqpn, ipriv->qkey);
 }
-#endif

 static int mlx5i_check_required_hca_cap(struct mlx5_core_dev *mdev)
 {
@@ -414,22 +421,23 @@ static int mlx5i_check_required_hca_cap(struct mlx5_core_dev *mdev)

 	if (!MLX5_CAP_GEN(mdev, ipoib_enhanced_offloads)) {
 		mlx5_core_warn(mdev, "IPoIB enhanced offloads are not supported\n");
-		return -ENOTSUPP;
+		return -EOPNOTSUPP;
 	}

 	return 0;
 }

-static struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
-						 struct ib_device *ibdev,
-						 const char *name,
-						 void (*setup)(struct net_device *))
+struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
+					  struct ib_device *ibdev,
+					  const char *name,
+					  void (*setup)(struct net_device *))
 {
 	const struct mlx5e_profile *profile = &mlx5i_nic_profile;
 	int nch = profile->max_nch(mdev);
 	struct net_device *netdev;
 	struct mlx5i_priv *ipriv;
 	struct mlx5e_priv *epriv;
+	struct rdma_netdev *rn;
 	int err;

 	if (mlx5i_check_required_hca_cap(mdev)) {
@@ -464,13 +472,13 @@ static struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
 	mlx5e_attach_netdev(epriv);
 	netif_carrier_off(netdev);

-	/* TODO: set rdma_netdev func pointers
-	 * rn = &ipriv->rn;
-	 * rn->hca  = ibdev;
-	 * rn->send = mlx5i_xmit;
-	 * rn->attach_mcast = mlx5i_attach_mcast;
-	 * rn->detach_mcast = mlx5i_detach_mcast;
-	 */
+	/* set rdma_netdev func pointers */
+	rn = &ipriv->rn;
+	rn->hca  = ibdev;
+	rn->send = mlx5i_xmit;
+	rn->attach_mcast = mlx5i_attach_mcast;
+	rn->detach_mcast = mlx5i_detach_mcast;
+
 	return netdev;

 err_free_netdev:
@@ -482,7 +490,7 @@ static struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
 }
 EXPORT_SYMBOL(mlx5_rdma_netdev_alloc);

-static void mlx5_rdma_netdev_free(struct net_device *netdev)
+void mlx5_rdma_netdev_free(struct net_device *netdev)
 {
 	struct mlx5e_priv          *priv    = mlx5i_epriv(netdev);
 	const struct mlx5e_profile *profile = priv->profile;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.h b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.h
index bae0a5cbc8ad..213191a78464 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.h
@@ -40,7 +40,9 @@

 /* ipoib rdma netdev's private data structure */
 struct mlx5i_priv {
+	struct rdma_netdev rn; /* keep this first */
 	struct mlx5_core_qp qp;
+	u32    qkey;
 	char  *mlx5e_priv[0];
 };

diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index f50864626230..a3bd07608cc6 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -1101,6 +1101,25 @@ struct net_device *mlx5_lag_get_roce_netdev(struct mlx5_core_dev *dev);
 struct mlx5_uars_page *mlx5_get_uars_page(struct mlx5_core_dev *mdev);
 void mlx5_put_uars_page(struct mlx5_core_dev *mdev, struct mlx5_uars_page *up);

+#ifndef CONFIG_MLX5_CORE_IPOIB
+static inline
+struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
+					  struct ib_device *ibdev,
+					  const char *name,
+					  void (*setup)(struct net_device *))
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
+static inline void mlx5_rdma_netdev_free(struct net_device *netdev) {}
+#else
+struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
+					  struct ib_device *ibdev,
+					  const char *name,
+					  void (*setup)(struct net_device *));
+void mlx5_rdma_netdev_free(struct net_device *netdev);
+#endif /* CONFIG_MLX5_CORE_IPOIB */
+
 struct mlx5_profile {
 	u64	mask;
 	u8	log_max_qp;
--
2.12.2

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
