From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net-next 05/16] net/mlx5e: IPoIB, Add netdevice profile skeleton
Date: Thu, 13 Apr 2017 06:36:55 +0300
Message-ID: <20170413033706.19016-6-saeedm@mellanox.com>
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

Create mlx5e IPoIB netdevice profile skeleton in the new ipoib.c
file with empty implementation.

Downstream patches will provide the full mlx5 rdma netdevice acceleration
support for IPoIB into this new file, by using the mlx5e netdevice
profile and new mlx5_channels APIs and infrastructures.
Same as already done in mlx5e NIC netdevice and switchdev mode VF
representors.

Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Erez Shitrit <erezsh-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx5/core/Kconfig    |   7 +
 drivers/net/ethernet/mellanox/mlx5/core/Makefile   |   2 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |   9 +
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  |   9 -
 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c    | 181 +++++++++++++++++++++
 .../ethernet/mellanox/mlx5/core/ipoib.h}           |  22 ++-
 6 files changed, 215 insertions(+), 15 deletions(-)
 create mode 100644 drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
 copy drivers/{infiniband/hw/mlx5/cmd.h => net/ethernet/mellanox/mlx5/core/ipoib.h} (77%)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
index 117170014e88..a84b652f9b54 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Kconfig
@@ -31,3 +31,10 @@ config MLX5_CORE_EN_DCB
 	  This flag is depended on the kernel's DCB support.
 
 	  If unsure, set to Y
+
+config MLX5_CORE_IPOIB
+	bool "Mellanox Technologies ConnectX-4 IPoIB offloads support"
+	depends on MLX5_CORE_EN
+	default y
+	---help---
+	  MLX5 IPoIB offloads & acceleration support.
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/Makefile b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
index 9f43beb86250..9e644615f07a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/Makefile
+++ b/drivers/net/ethernet/mellanox/mlx5/core/Makefile
@@ -11,3 +11,5 @@ mlx5_core-$(CONFIG_MLX5_CORE_EN) += wq.o eswitch.o eswitch_offloads.o \
 		en_tc.o en_arfs.o en_rep.o en_fs_ethtool.o en_selftest.o
 
 mlx5_core-$(CONFIG_MLX5_CORE_EN_DCB) +=  en_dcbnl.o
+
+mlx5_core-$(CONFIG_MLX5_CORE_IPOIB) += ipoib.o
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index ced31906b8fd..02aa3cc59dc3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -37,6 +37,7 @@
 #include <linux/timecounter.h>
 #include <linux/net_tstamp.h>
 #include <linux/ptp_clock_kernel.h>
+#include <linux/crash_dump.h>
 #include <linux/mlx5/driver.h>
 #include <linux/mlx5/qp.h>
 #include <linux/mlx5/cq.h>
@@ -153,6 +154,14 @@ static inline int mlx5_max_log_rq_size(int wq_type)
 	}
 }
 
+static inline int mlx5e_get_max_num_channels(struct mlx5_core_dev *mdev)
+{
+	return is_kdump_kernel() ?
+		MLX5E_MIN_NUM_CHANNELS :
+		min_t(int, mdev->priv.eq_table.num_comp_vectors,
+		      MLX5E_MAX_NUM_CHANNELS);
+}
+
 struct mlx5e_tx_wqe {
 	struct mlx5_wqe_ctrl_seg ctrl;
 	struct mlx5_wqe_eth_seg  eth;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index cdc34ba354c8..14c7452a6348 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -31,7 +31,6 @@
  */
 
 #include <net/tc_act/tc_gact.h>
-#include <linux/crash_dump.h>
 #include <net/pkt_cls.h>
 #include <linux/mlx5/fs.h>
 #include <net/vxlan.h>
@@ -1710,14 +1709,6 @@ static int mlx5e_set_tx_maxrate(struct net_device *dev, int index, u32 rate)
 	return err;
 }
 
-static inline int mlx5e_get_max_num_channels(struct mlx5_core_dev *mdev)
-{
-	return is_kdump_kernel() ?
-		MLX5E_MIN_NUM_CHANNELS :
-		min_t(int, mdev->priv.eq_table.num_comp_vectors,
-		      MLX5E_MAX_NUM_CHANNELS);
-}
-
 static int mlx5e_open_channel(struct mlx5e_priv *priv, int ix,
 			      struct mlx5e_params *params,
 			      struct mlx5e_channel_param *cparam,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
new file mode 100644
index 000000000000..2f65927a8d03
--- /dev/null
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.c
@@ -0,0 +1,181 @@
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
+#include <linux/mlx5/fs.h>
+#include "en.h"
+#include "ipoib.h"
+
+/* IPoIB mlx5 netdev profile */
+
+/* Called directly after IPoIB netdevice was created to initialize SW structs */
+static void mlx5i_init(struct mlx5_core_dev *mdev,
+		       struct net_device *netdev,
+		       const struct mlx5e_profile *profile,
+		       void *ppriv)
+{
+	struct mlx5e_priv *priv  = mlx5i_epriv(netdev);
+
+	priv->ppriv = ppriv;
+	/*  TODO: init netdev and mlx5e_params here */
+}
+
+/* Called directly before IPoIB netdevice is destroyed to cleanup SW structs */
+static void mlx5i_cleanup(struct mlx5e_priv *priv)
+{
+	/* Do nothing .. */
+}
+
+static int mlx5i_init_tx(struct mlx5e_priv *priv)
+{
+	/* TODO: Create IPoIB underlay QP */
+	/* TODO: create IPoIB TX HW TIS */
+	return 0;
+}
+
+static void mlx5i_cleanup_tx(struct mlx5e_priv *priv)
+{
+}
+
+static int mlx5i_init_rx(struct mlx5e_priv *priv)
+{
+	/* TODO: create IPoIB RX HW steering contexts */
+	return 0;
+}
+
+static void mlx5i_cleanup_rx(struct mlx5e_priv *priv)
+{
+}
+
+static const struct mlx5e_profile mlx5i_nic_profile = {
+	.init		   = mlx5i_init,
+	.cleanup	   = mlx5i_cleanup,
+	.init_tx	   = mlx5i_init_tx,
+	.cleanup_tx	   = mlx5i_cleanup_tx,
+	.init_rx	   = mlx5i_init_rx,
+	.cleanup_rx	   = mlx5i_cleanup_rx,
+	.enable		   = NULL, /* mlx5i_enable */
+	.disable	   = NULL, /* mlx5i_disable */
+	.update_stats	   = NULL, /* mlx5i_update_stats */
+	.max_nch	   = mlx5e_get_max_num_channels,
+	.max_tc		   = MLX5I_MAX_NUM_TC,
+};
+
+/* IPoIB RDMA netdev callbacks */
+
+static int mlx5i_check_required_hca_cap(struct mlx5_core_dev *mdev)
+{
+	if (MLX5_CAP_GEN(mdev, port_type) != MLX5_CAP_PORT_TYPE_IB)
+		return -EOPNOTSUPP;
+
+	if (!MLX5_CAP_GEN(mdev, ipoib_enhanced_offloads)) {
+		mlx5_core_warn(mdev, "IPoIB enhanced offloads are not supported\n");
+		return -ENOTSUPP;
+	}
+
+	return 0;
+}
+
+struct net_device *mlx5_rdma_netdev_alloc(struct mlx5_core_dev *mdev,
+					  struct ib_device *ibdev,
+					  const char *name,
+					  void (*setup)(struct net_device *))
+{
+	const struct mlx5e_profile *profile = &mlx5i_nic_profile;
+	int nch = profile->max_nch(mdev);
+	struct net_device *netdev;
+	struct mlx5i_priv *ipriv;
+	struct mlx5e_priv *epriv;
+	int err;
+
+	if (mlx5i_check_required_hca_cap(mdev)) {
+		mlx5_core_warn(mdev, "Accelerated mode is not supported\n");
+		return ERR_PTR(-EOPNOTSUPP);
+	}
+
+	/* This function should only be called once per mdev */
+	err = mlx5e_create_mdev_resources(mdev);
+	if (err)
+		return NULL;
+
+	netdev = alloc_netdev_mqs(sizeof(struct mlx5i_priv) + sizeof(struct mlx5e_priv),
+				  name, NET_NAME_UNKNOWN,
+				  setup,
+				  nch * MLX5E_MAX_NUM_TC,
+				  nch);
+	if (!netdev) {
+		mlx5_core_warn(mdev, "alloc_netdev_mqs failed\n");
+		goto free_mdev_resources;
+	}
+
+	ipriv = netdev_priv(netdev);
+	epriv = mlx5i_epriv(netdev);
+
+	epriv->wq = create_singlethread_workqueue("mlx5i");
+	if (!epriv->wq)
+		goto err_free_netdev;
+
+	profile->init(mdev, netdev, profile, ipriv);
+
+	mlx5e_attach_netdev(epriv);
+	netif_carrier_off(netdev);
+
+	/* TODO: set rdma_netdev func pointers
+	 * rn = &ipriv->rn;
+	 * rn->hca  = ibdev;
+	 * rn->send = mlx5i_xmit;
+	 * rn->attach_mcast = mlx5i_attach_mcast;
+	 * rn->detach_mcast = mlx5i_detach_mcast;
+	 */
+	return netdev;
+
+free_mdev_resources:
+	mlx5e_destroy_mdev_resources(mdev);
+err_free_netdev:
+	free_netdev(netdev);
+	return NULL;
+}
+EXPORT_SYMBOL(mlx5_rdma_netdev_alloc);
+
+void mlx5_rdma_netdev_free(struct net_device *netdev)
+{
+	struct mlx5e_priv          *priv    = mlx5i_epriv(netdev);
+	const struct mlx5e_profile *profile = priv->profile;
+
+	mlx5e_detach_netdev(priv);
+	profile->cleanup(priv);
+	destroy_workqueue(priv->wq);
+	free_netdev(netdev);
+
+	mlx5e_destroy_mdev_resources(priv->mdev);
+}
+EXPORT_SYMBOL(mlx5_rdma_netdev_free);
+
diff --git a/drivers/infiniband/hw/mlx5/cmd.h b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.h
similarity index 77%
copy from drivers/infiniband/hw/mlx5/cmd.h
copy to drivers/net/ethernet/mellanox/mlx5/core/ipoib.h
index 7ca8a7b6434d..25b8b8a33e24 100644
--- a/drivers/infiniband/hw/mlx5/cmd.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/ipoib.h
@@ -30,11 +30,21 @@
  * SOFTWARE.
  */
 
-#ifndef MLX5_IB_CMD_H
-#define MLX5_IB_CMD_H
+#ifndef __MLX5E_IPOB_H__
+#define __MLX5E_IPOB_H__
 
-#include <linux/kernel.h>
-#include <linux/mlx5/driver.h>
+#include <linux/mlx5/fs.h>
+#include "en.h"
 
-int mlx5_cmd_null_mkey(struct mlx5_core_dev *dev, u32 *null_mkey);
-#endif /* MLX5_IB_CMD_H */
+#define MLX5I_MAX_NUM_TC 1
+
+/* ipoib rdma netdev's private data structure */
+struct mlx5i_priv {
+	struct mlx5_core_qp qp;
+	char  *mlx5e_priv[0];
+};
+
+/* Extract mlx5e_priv from IPoIB netdev */
+#define mlx5i_epriv(netdev) ((void *)(((struct mlx5i_priv *)netdev_priv(netdev))->mlx5e_priv))
+
+#endif /* __MLX5E_IPOB_H__ */
-- 
2.11.0

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
