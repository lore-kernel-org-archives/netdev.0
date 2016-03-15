From: Alexey Kardashevskiy <aik-sLpHqDYs0B2HXe+LvDLADg@public.gmane.org>
Subject: [RFC PATCH kernel] Revert "net/mlx4_core: Set UAR page size to 4KB regardless of system page size"
Date: Tue, 15 Mar 2016 21:19:08 +1100
Message-ID: <1458037148-4475-1-git-send-email-aik@ozlabs.ru>
Cc: Alexey Kardashevskiy <aik-sLpHqDYs0B2HXe+LvDLADg@public.gmane.org>,
	Eugenia Emantayev <eugenia-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Paul Mackerras <paulus-eUNUBHrolfbYtjvyW6yDsg@public.gmane.org>,
	Carol L Soto <clsoto-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
To: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This reverts commit 85743f1eb34548ba4b056d2f184a3d107a3b8917.

Without this revert, POWER "pseries" KVM guests with a VF passed to a guest
using VFIO fail to bring the driver up:

mlx4_core: Mellanox ConnectX core driver v2.2-1 (Feb, 2014)
mlx4_core: Initializing 0000:00:00.0
mlx4_core 0000:00:00.0: enabling device (0000 -> 0002)
mlx4_core 0000:00:00.0: Detected virtual function - running in slave mode
mlx4_core 0000:00:00.0: Sending reset
mlx4_core 0000:00:00.0: Sending vhcr0
mlx4_core 0000:00:00.0: HCA minimum page size:512
mlx4_core 0000:00:00.0: UAR size:4096 != kernel PAGE_SIZE of 65536
mlx4_core 0000:00:00.0: Failed to obtain slave caps


Both host and guest use 64K system pages.

How to fix this properly? Thanks.



---
 drivers/infiniband/hw/mlx4/qp.c                   |  7 +--
 drivers/net/ethernet/mellanox/mlx4/cq.c           |  4 +-
 drivers/net/ethernet/mellanox/mlx4/en_resources.c |  3 +-
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |  4 +-
 drivers/net/ethernet/mellanox/mlx4/eq.c           |  7 ++-
 drivers/net/ethernet/mellanox/mlx4/main.c         | 56 +++++------------------
 drivers/net/ethernet/mellanox/mlx4/pd.c           | 12 ++---
 include/linux/mlx4/device.h                       | 13 ------
 8 files changed, 22 insertions(+), 84 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index fd97534..bc5536f 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -1681,12 +1681,9 @@ static int __mlx4_ib_modify_qp(struct ib_qp *ibqp,
 	}
 
 	if (qp->ibqp.uobject)
-		context->usr_page = cpu_to_be32(
-			mlx4_to_hw_uar_index(dev->dev,
-					     to_mucontext(ibqp->uobject->context)->uar.index));
+		context->usr_page = cpu_to_be32(to_mucontext(ibqp->uobject->context)->uar.index);
 	else
-		context->usr_page = cpu_to_be32(
-			mlx4_to_hw_uar_index(dev->dev, dev->priv_uar.index));
+		context->usr_page = cpu_to_be32(dev->priv_uar.index);
 
 	if (attr_mask & IB_QP_DEST_QPN)
 		context->remote_qpn = cpu_to_be32(attr->dest_qp_num);
diff --git a/drivers/net/ethernet/mellanox/mlx4/cq.c b/drivers/net/ethernet/mellanox/mlx4/cq.c
index a849da9..3348e64 100644
--- a/drivers/net/ethernet/mellanox/mlx4/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/cq.c
@@ -318,9 +318,7 @@ int mlx4_cq_alloc(struct mlx4_dev *dev, int nent,
 	if (timestamp_en)
 		cq_context->flags  |= cpu_to_be32(1 << 19);
 
-	cq_context->logsize_usrpage =
-		cpu_to_be32((ilog2(nent) << 24) |
-			    mlx4_to_hw_uar_index(dev, uar->index));
+	cq_context->logsize_usrpage = cpu_to_be32((ilog2(nent) << 24) | uar->index);
 	cq_context->comp_eqn	    = priv->eq_table.eq[MLX4_CQ_TO_EQ_VECTOR(vector)].eqn;
 	cq_context->log_page_size   = mtt->page_shift - MLX4_ICM_PAGE_SHIFT;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_resources.c b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
index 02e925d..12aab5a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_resources.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
@@ -58,8 +58,7 @@ void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 	} else {
 		context->sq_size_stride = ilog2(TXBB_SIZE) - 4;
 	}
-	context->usr_page = cpu_to_be32(mlx4_to_hw_uar_index(mdev->dev,
-					mdev->priv_uar.index));
+	context->usr_page = cpu_to_be32(mdev->priv_uar.index);
 	context->local_qpn = cpu_to_be32(qpn);
 	context->pri_path.ackto = 1 & 0x07;
 	context->pri_path.sched_queue = 0x83 | (priv->port - 1) << 6;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index e0946ab..4421bf5 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -213,9 +213,7 @@ int mlx4_en_activate_tx_ring(struct mlx4_en_priv *priv,
 	mlx4_en_fill_qp_context(priv, ring->size, ring->stride, 1, 0, ring->qpn,
 				ring->cqn, user_prio, &ring->context);
 	if (ring->bf_alloced)
-		ring->context.usr_page =
-			cpu_to_be32(mlx4_to_hw_uar_index(mdev->dev,
-							 ring->bf.uar->index));
+		ring->context.usr_page = cpu_to_be32(ring->bf.uar->index);
 
 	err = mlx4_qp_to_ready(mdev->dev, &ring->wqres.mtt, &ring->context,
 			       &ring->qp, &ring->qp_state);
diff --git a/drivers/net/ethernet/mellanox/mlx4/eq.c b/drivers/net/ethernet/mellanox/mlx4/eq.c
index f613977..4696053 100644
--- a/drivers/net/ethernet/mellanox/mlx4/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/eq.c
@@ -940,10 +940,9 @@ static void __iomem *mlx4_get_eq_uar(struct mlx4_dev *dev, struct mlx4_eq *eq)
 
 	if (!priv->eq_table.uar_map[index]) {
 		priv->eq_table.uar_map[index] =
-			ioremap(
-				pci_resource_start(dev->persist->pdev, 2) +
-				((eq->eqn / 4) << (dev->uar_page_shift)),
-				(1 << (dev->uar_page_shift)));
+			ioremap(pci_resource_start(dev->persist->pdev, 2) +
+				((eq->eqn / 4) << PAGE_SHIFT),
+				PAGE_SIZE);
 		if (!priv->eq_table.uar_map[index]) {
 			mlx4_err(dev, "Couldn't map EQ doorbell for EQN 0x%06x\n",
 				 eq->eqn);
diff --git a/drivers/net/ethernet/mellanox/mlx4/main.c b/drivers/net/ethernet/mellanox/mlx4/main.c
index 2cc3c62..f1b6d21 100644
--- a/drivers/net/ethernet/mellanox/mlx4/main.c
+++ b/drivers/net/ethernet/mellanox/mlx4/main.c
@@ -168,20 +168,6 @@ struct mlx4_port_config {
 
 static atomic_t pf_loading = ATOMIC_INIT(0);
 
-static inline void mlx4_set_num_reserved_uars(struct mlx4_dev *dev,
-					      struct mlx4_dev_cap *dev_cap)
-{
-	/* The reserved_uars is calculated by system page size unit.
-	 * Therefore, adjustment is added when the uar page size is less
-	 * than the system page size
-	 */
-	dev->caps.reserved_uars	=
-		max_t(int,
-		      mlx4_get_num_reserved_uar(dev),
-		      dev_cap->reserved_uars /
-			(1 << (PAGE_SHIFT - dev->uar_page_shift)));
-}
-
 int mlx4_check_port_params(struct mlx4_dev *dev,
 			   enum mlx4_port_type *port_type)
 {
@@ -400,6 +386,8 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev->caps.reserved_mtts      = dev_cap->reserved_mtts;
 	dev->caps.reserved_mrws	     = dev_cap->reserved_mrws;
 
+	/* The first 128 UARs are used for EQ doorbells */
+	dev->caps.reserved_uars	     = max_t(int, 128, dev_cap->reserved_uars);
 	dev->caps.reserved_pds	     = dev_cap->reserved_pds;
 	dev->caps.reserved_xrcds     = (dev->caps.flags & MLX4_DEV_CAP_FLAG_XRC) ?
 					dev_cap->reserved_xrcds : 0;
@@ -417,15 +405,6 @@ static int mlx4_dev_cap(struct mlx4_dev *dev, struct mlx4_dev_cap *dev_cap)
 	dev->caps.max_gso_sz	     = dev_cap->max_gso_sz;
 	dev->caps.max_rss_tbl_sz     = dev_cap->max_rss_tbl_sz;
 
-	/* Save uar page shift */
-	if (!mlx4_is_slave(dev)) {
-		/* Virtual PCI function needs to determine UAR page size from
-		 * firmware. Only master PCI function can set the uar page size
-		 */
-		dev->uar_page_shift = DEFAULT_UAR_PAGE_SHIFT;
-		mlx4_set_num_reserved_uars(dev, dev_cap);
-	}
-
 	if (dev->caps.flags2 & MLX4_DEV_CAP_FLAG2_PHV_EN) {
 		struct mlx4_init_hca_param hca_param;
 
@@ -836,25 +815,16 @@ static int mlx4_slave_cap(struct mlx4_dev *dev)
 		return -ENODEV;
 	}
 
-	/* Set uar_page_shift for VF */
-	dev->uar_page_shift = hca_param.uar_page_sz + 12;
+	/* slave gets uar page size from QUERY_HCA fw command */
+	dev->caps.uar_page_size = 1 << (hca_param.uar_page_sz + 12);
 
-	/* Make sure the master uar page size is valid */
-	if (dev->uar_page_shift > PAGE_SHIFT) {
-		mlx4_err(dev,
-			 "Invalid configuration: uar page size is larger than system page size\n");
-		return  -ENODEV;
+	/* TODO: relax this assumption */
+	if (dev->caps.uar_page_size != PAGE_SIZE) {
+		mlx4_err(dev, "UAR size:%d != kernel PAGE_SIZE of %ld\n",
+			 dev->caps.uar_page_size, PAGE_SIZE);
+		return -ENODEV;
 	}
 
-	/* Set reserved_uars based on the uar_page_shift */
-	mlx4_set_num_reserved_uars(dev, &dev_cap);
-
-	/* Although uar page size in FW differs from system page size,
-	 * upper software layers (mlx4_ib, mlx4_en and part of mlx4_core)
-	 * still works with assumption that uar page size == system page size
-	 */
-	dev->caps.uar_page_size = PAGE_SIZE;
-
 	memset(&func_cap, 0, sizeof(func_cap));
 	err = mlx4_QUERY_FUNC_CAP(dev, 0, &func_cap);
 	if (err) {
@@ -2209,12 +2179,8 @@ static int mlx4_init_hca(struct mlx4_dev *dev)
 
 		dev->caps.max_fmr_maps = (1 << (32 - ilog2(dev->caps.num_mpts))) - 1;
 
-		/* Always set UAR page size 4KB, set log_uar_sz accordingly */
-		init_hca.log_uar_sz = ilog2(dev->caps.num_uars) +
-				      PAGE_SHIFT -
-				      DEFAULT_UAR_PAGE_SHIFT;
-		init_hca.uar_page_sz = DEFAULT_UAR_PAGE_SHIFT - 12;
-
+		init_hca.log_uar_sz = ilog2(dev->caps.num_uars);
+		init_hca.uar_page_sz = PAGE_SHIFT - 12;
 		init_hca.mw_enabled = 0;
 		if (dev->caps.flags & MLX4_DEV_CAP_FLAG_MEM_WINDOW ||
 		    dev->caps.bmme_flags & MLX4_BMME_FLAG_TYPE_2_WIN)
diff --git a/drivers/net/ethernet/mellanox/mlx4/pd.c b/drivers/net/ethernet/mellanox/mlx4/pd.c
index b3cc3ab..609c59d 100644
--- a/drivers/net/ethernet/mellanox/mlx4/pd.c
+++ b/drivers/net/ethernet/mellanox/mlx4/pd.c
@@ -269,15 +269,9 @@ EXPORT_SYMBOL_GPL(mlx4_bf_free);
 
 int mlx4_init_uar_table(struct mlx4_dev *dev)
 {
-	int num_reserved_uar = mlx4_get_num_reserved_uar(dev);
-
-	mlx4_dbg(dev, "uar_page_shift = %d", dev->uar_page_shift);
-	mlx4_dbg(dev, "Effective reserved_uars=%d", dev->caps.reserved_uars);
-
-	if (dev->caps.num_uars <= num_reserved_uar) {
-		mlx4_err(
-			dev, "Only %d UAR pages (need more than %d)\n",
-			dev->caps.num_uars, num_reserved_uar);
+	if (dev->caps.num_uars <= 128) {
+		mlx4_err(dev, "Only %d UAR pages (need more than 128)\n",
+			 dev->caps.num_uars);
 		mlx4_err(dev, "Increase firmware log2_uar_bar_megabytes?\n");
 		return -ENODEV;
 	}
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index a0e8cc8..430a929 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -44,8 +44,6 @@
 
 #include <linux/timecounter.h>
 
-#define DEFAULT_UAR_PAGE_SHIFT  12
-
 #define MAX_MSIX_P_PORT		17
 #define MAX_MSIX		64
 #define MIN_MSIX_P_PORT		5
@@ -858,7 +856,6 @@ struct mlx4_dev {
 	u64			regid_promisc_array[MLX4_MAX_PORTS + 1];
 	u64			regid_allmulti_array[MLX4_MAX_PORTS + 1];
 	struct mlx4_vf_dev     *dev_vfs;
-	u8  uar_page_shift;
 };
 
 struct mlx4_clock_params {
@@ -1531,14 +1528,4 @@ int mlx4_ACCESS_PTYS_REG(struct mlx4_dev *dev,
 int mlx4_get_internal_clock_params(struct mlx4_dev *dev,
 				   struct mlx4_clock_params *params);
 
-static inline int mlx4_to_hw_uar_index(struct mlx4_dev *dev, int index)
-{
-	return (index << (PAGE_SHIFT - dev->uar_page_shift));
-}
-
-static inline int mlx4_get_num_reserved_uar(struct mlx4_dev *dev)
-{
-	/* The first 128 UARs are used for EQ doorbells */
-	return (128 >> (PAGE_SHIFT - dev->uar_page_shift));
-}
 #endif /* MLX4_DEVICE_H */
-- 
2.5.0.rc3

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
