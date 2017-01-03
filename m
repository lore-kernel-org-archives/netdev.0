From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [for-next 09/10] IB/mlx5: Support 4k UAR for libmlx5
Date: Tue,  3 Jan 2017 23:55:27 +0200
Message-ID: <1483480528-22622-10-git-send-email-saeedm@mellanox.com>
References: <1483480528-22622-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Eli Cohen <eli@mellanox.com>,
        Matan Barak <matanb@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:34220 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S936191AbdACVzm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2017 16:55:42 -0500
In-Reply-To: <1483480528-22622-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eli Cohen <eli@mellanox.com>

Add fields to structs to convey to kernel an indication whether the
library supports multi UARs per page and return to the library the size
of a UAR based on the queried value.

Signed-off-by: Eli Cohen <eli@mellanox.com>
Reviewed-by: Matan Barak <matanb@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c                  | 21 +++++++-
 drivers/net/ethernet/mellanox/mlx5/core/cq.c       |  2 +
 drivers/net/ethernet/mellanox/mlx5/core/en.h       |  9 ++--
 .../net/ethernet/mellanox/mlx5/core/en_common.c    | 12 +----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 21 ++++----
 drivers/net/ethernet/mellanox/mlx5/core/uar.c      | 56 ----------------------
 include/linux/mlx5/cq.h                            |  2 +-
 include/linux/mlx5/driver.h                        | 12 -----
 include/uapi/rdma/mlx5-abi.h                       |  7 +++
 9 files changed, 42 insertions(+), 100 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 6640672..a191b93 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -992,6 +992,12 @@ static int mlx5_ib_modify_port(struct ib_device *ibdev, u8 port, int mask,
 	return err;
 }
 
+static void print_lib_caps(struct mlx5_ib_dev *dev, u64 caps)
+{
+	mlx5_ib_dbg(dev, "MLX5_LIB_CAP_4K_UAR = %s\n",
+		    caps & MLX5_LIB_CAP_4K_UAR ? "y" : "n");
+}
+
 static int calc_total_bfregs(struct mlx5_ib_dev *dev, bool lib_uar_4k,
 			     struct mlx5_ib_alloc_ucontext_req_v2 *req,
 			     u32 *num_sys_pages)
@@ -1122,6 +1128,10 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	resp.cqe_version = min_t(__u8,
 				 (__u8)MLX5_CAP_GEN(dev->mdev, cqe_version),
 				 req.max_cqe_version);
+	resp.log_uar_size = MLX5_CAP_GEN(dev->mdev, uar_4k) ?
+				MLX5_ADAPTER_PAGE_SHIFT : PAGE_SHIFT;
+	resp.num_uars_per_page = MLX5_CAP_GEN(dev->mdev, uar_4k) ?
+					MLX5_CAP_GEN(dev->mdev, num_of_uars_per_page) : 1;
 	resp.response_length = min(offsetof(typeof(resp), response_length) +
 				   sizeof(resp.response_length), udata->outlen);
 
@@ -1129,7 +1139,7 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	if (!context)
 		return ERR_PTR(-ENOMEM);
 
-	lib_uar_4k = false;
+	lib_uar_4k = req.lib_caps & MLX5_LIB_CAP_4K_UAR;
 	bfregi = &context->bfregi;
 
 	/* updates req->total_num_bfregs */
@@ -1209,6 +1219,12 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 					sizeof(resp.reserved2);
 	}
 
+	if (field_avail(typeof(resp), log_uar_size, udata->outlen))
+		resp.response_length += sizeof(resp.log_uar_size);
+
+	if (field_avail(typeof(resp), num_uars_per_page, udata->outlen))
+		resp.response_length += sizeof(resp.num_uars_per_page);
+
 	err = ib_copy_to_udata(udata, &resp, resp.response_length);
 	if (err)
 		goto out_td;
@@ -1216,7 +1232,8 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	bfregi->ver = ver;
 	bfregi->num_low_latency_bfregs = req.num_low_latency_bfregs;
 	context->cqe_version = resp.cqe_version;
-	context->lib_caps = false;
+	context->lib_caps = req.lib_caps;
+	print_lib_caps(dev, context->lib_caps);
 
 	return &context->ibucontext;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/cq.c b/drivers/net/ethernet/mellanox/mlx5/core/cq.c
index 32d4af9..336d473 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/cq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/cq.c
@@ -179,6 +179,8 @@ int mlx5_core_create_cq(struct mlx5_core_dev *dev, struct mlx5_core_cq *cq,
 		mlx5_core_dbg(dev, "failed adding CP 0x%x to debug file system\n",
 			      cq->cqn);
 
+	cq->uar = dev->priv.uar;
+
 	return 0;
 
 err_cmd:
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index e3ef0b5..396c63d 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -465,7 +465,6 @@ struct mlx5e_sq {
 	/* read only */
 	struct mlx5_wq_cyc         wq;
 	u32                        dma_fifo_mask;
-	void __iomem              *uar_map;
 	struct netdev_queue       *txq;
 	u32                        sqn;
 	u16                        bf_buf_size;
@@ -479,7 +478,7 @@ struct mlx5e_sq {
 
 	/* control path */
 	struct mlx5_wq_ctrl        wq_ctrl;
-	struct mlx5_uar            uar;
+	struct mlx5_sq_bfreg	   bfreg;
 	struct mlx5e_channel      *channel;
 	int                        tc;
 	u32                        rate_limit;
@@ -806,7 +805,7 @@ void mlx5e_set_rx_cq_mode_params(struct mlx5e_params *params,
 static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
 				      struct mlx5_wqe_ctrl_seg *ctrl, int bf_sz)
 {
-	u16 ofst = MLX5_BF_OFFSET + sq->bf_offset;
+	u16 ofst = sq->bf_offset;
 
 	/* ensure wqe is visible to device before updating doorbell record */
 	dma_wmb();
@@ -818,9 +817,9 @@ static inline void mlx5e_tx_notify_hw(struct mlx5e_sq *sq,
 	 */
 	wmb();
 	if (bf_sz)
-		__iowrite64_copy(sq->uar_map + ofst, ctrl, bf_sz);
+		__iowrite64_copy(sq->bfreg.map + ofst, ctrl, bf_sz);
 	else
-		mlx5_write64((__be32 *)ctrl, sq->uar_map + ofst);
+		mlx5_write64((__be32 *)ctrl, sq->bfreg.map + ofst);
 	/* flush the write-combining mapped buffer */
 	wmb();
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
index f175518..bd898d8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_common.c
@@ -89,16 +89,10 @@ int mlx5e_create_mdev_resources(struct mlx5_core_dev *mdev)
 	struct mlx5e_resources *res = &mdev->mlx5e_res;
 	int err;
 
-	err = mlx5_alloc_map_uar(mdev, &res->cq_uar, false);
-	if (err) {
-		mlx5_core_err(mdev, "alloc_map uar failed, %d\n", err);
-		return err;
-	}
-
 	err = mlx5_core_alloc_pd(mdev, &res->pdn);
 	if (err) {
 		mlx5_core_err(mdev, "alloc pd failed, %d\n", err);
-		goto err_unmap_free_uar;
+		return err;
 	}
 
 	err = mlx5_core_alloc_transport_domain(mdev, &res->td.tdn);
@@ -121,9 +115,6 @@ int mlx5e_create_mdev_resources(struct mlx5_core_dev *mdev)
 	mlx5_core_dealloc_transport_domain(mdev, res->td.tdn);
 err_dealloc_pd:
 	mlx5_core_dealloc_pd(mdev, res->pdn);
-err_unmap_free_uar:
-	mlx5_unmap_free_uar(mdev, &res->cq_uar);
-
 	return err;
 }
 
@@ -134,7 +125,6 @@ void mlx5e_destroy_mdev_resources(struct mlx5_core_dev *mdev)
 	mlx5_core_destroy_mkey(mdev, &res->mkey);
 	mlx5_core_dealloc_transport_domain(mdev, res->td.tdn);
 	mlx5_core_dealloc_pd(mdev, res->pdn);
-	mlx5_unmap_free_uar(mdev, &res->cq_uar);
 }
 
 int mlx5e_refresh_tirs_self_loopback(struct mlx5_core_dev *mdev,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 5ff86f0..c32754b 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -991,7 +991,7 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	sq->channel   = c;
 	sq->tc        = tc;
 
-	err = mlx5_alloc_map_uar(mdev, &sq->uar, !!MLX5_CAP_GEN(mdev, bf));
+	err = mlx5_alloc_bfreg(mdev, &sq->bfreg, MLX5_CAP_GEN(mdev, bf), false);
 	if (err)
 		return err;
 
@@ -1003,12 +1003,9 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 		goto err_unmap_free_uar;
 
 	sq->wq.db       = &sq->wq.db[MLX5_SND_DBR];
-	if (sq->uar.bf_map) {
+	if (sq->bfreg.wc)
 		set_bit(MLX5E_SQ_STATE_BF_ENABLE, &sq->state);
-		sq->uar_map = sq->uar.bf_map;
-	} else {
-		sq->uar_map = sq->uar.map;
-	}
+
 	sq->bf_buf_size = (1 << MLX5_CAP_GEN(mdev, log_bf_reg_size)) / 2;
 	sq->max_inline  = param->max_inline;
 	sq->min_inline_mode =
@@ -1036,7 +1033,7 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	mlx5_wq_destroy(&sq->wq_ctrl);
 
 err_unmap_free_uar:
-	mlx5_unmap_free_uar(mdev, &sq->uar);
+	mlx5_free_bfreg(mdev, &sq->bfreg);
 
 	return err;
 }
@@ -1048,7 +1045,7 @@ static void mlx5e_destroy_sq(struct mlx5e_sq *sq)
 
 	mlx5e_free_sq_db(sq);
 	mlx5_wq_destroy(&sq->wq_ctrl);
-	mlx5_unmap_free_uar(priv->mdev, &sq->uar);
+	mlx5_free_bfreg(priv->mdev, &sq->bfreg);
 }
 
 static int mlx5e_enable_sq(struct mlx5e_sq *sq, struct mlx5e_sq_param *param)
@@ -1082,7 +1079,7 @@ static int mlx5e_enable_sq(struct mlx5e_sq *sq, struct mlx5e_sq_param *param)
 	MLX5_SET(sqc,  sqc, tis_lst_sz, param->type == MLX5E_SQ_ICO ? 0 : 1);
 
 	MLX5_SET(wq,   wq, wq_type,       MLX5_WQ_TYPE_CYCLIC);
-	MLX5_SET(wq,   wq, uar_page,      sq->uar.index);
+	MLX5_SET(wq,   wq, uar_page,      sq->bfreg.index);
 	MLX5_SET(wq,   wq, log_wq_pg_sz,  sq->wq_ctrl.buf.page_shift -
 					  MLX5_ADAPTER_PAGE_SHIFT);
 	MLX5_SET64(wq, wq, dbr_addr,      sq->wq_ctrl.db.dma);
@@ -1240,7 +1237,6 @@ static int mlx5e_create_cq(struct mlx5e_channel *c,
 	mcq->comp       = mlx5e_completion_event;
 	mcq->event      = mlx5e_cq_error_event;
 	mcq->irqn       = irqn;
-	mcq->uar        = &mdev->mlx5e_res.cq_uar;
 
 	for (i = 0; i < mlx5_cqwq_get_size(&cq->wq); i++) {
 		struct mlx5_cqe64 *cqe = mlx5_cqwq_get_wqe(&cq->wq, i);
@@ -1289,7 +1285,7 @@ static int mlx5e_enable_cq(struct mlx5e_cq *cq, struct mlx5e_cq_param *param)
 
 	MLX5_SET(cqc,   cqc, cq_period_mode, param->cq_period_mode);
 	MLX5_SET(cqc,   cqc, c_eqn,         eqn);
-	MLX5_SET(cqc,   cqc, uar_page,      mcq->uar->index);
+	MLX5_SET(cqc,   cqc, uar_page,      mdev->priv.uar->index);
 	MLX5_SET(cqc,   cqc, log_page_size, cq->wq_ctrl.frag_buf.page_shift -
 					    MLX5_ADAPTER_PAGE_SHIFT);
 	MLX5_SET64(cqc, cqc, dbr_addr,      cq->wq_ctrl.db.dma);
@@ -1701,7 +1697,7 @@ static void mlx5e_build_common_cq_param(struct mlx5e_priv *priv,
 {
 	void *cqc = param->cqc;
 
-	MLX5_SET(cqc, cqc, uar_page, priv->mdev->mlx5e_res.cq_uar.index);
+	MLX5_SET(cqc, cqc, uar_page, priv->mdev->priv.uar->index);
 }
 
 static void mlx5e_build_rx_cq_param(struct mlx5e_priv *priv,
@@ -2320,7 +2316,6 @@ static int mlx5e_create_drop_cq(struct mlx5e_priv *priv,
 	mcq->comp       = mlx5e_completion_event;
 	mcq->event      = mlx5e_cq_error_event;
 	mcq->irqn       = irqn;
-	mcq->uar        = &mdev->mlx5e_res.cq_uar;
 
 	cq->priv = priv;
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/uar.c b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
index 07b273c..2e6b0f2 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/uar.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
@@ -37,11 +37,6 @@
 #include <linux/mlx5/cmd.h>
 #include "mlx5_core.h"
 
-enum {
-	NUM_DRIVER_UARS		= 4,
-	NUM_LOW_LAT_BFREGS	= 4,
-};
-
 int mlx5_cmd_alloc_uar(struct mlx5_core_dev *dev, u32 *uarn)
 {
 	u32 out[MLX5_ST_SZ_DW(alloc_uar_out)] = {0};
@@ -67,57 +62,6 @@ int mlx5_cmd_free_uar(struct mlx5_core_dev *dev, u32 uarn)
 }
 EXPORT_SYMBOL(mlx5_cmd_free_uar);
 
-int mlx5_alloc_map_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar,
-		       bool map_wc)
-{
-	phys_addr_t pfn;
-	phys_addr_t uar_bar_start;
-	int err;
-
-	err = mlx5_cmd_alloc_uar(mdev, &uar->index);
-	if (err) {
-		mlx5_core_warn(mdev, "mlx5_cmd_alloc_uar() failed, %d\n", err);
-		return err;
-	}
-
-	uar_bar_start = pci_resource_start(mdev->pdev, 0);
-	pfn           = (uar_bar_start >> PAGE_SHIFT) + uar->index;
-
-	if (map_wc) {
-		uar->bf_map = ioremap_wc(pfn << PAGE_SHIFT, PAGE_SIZE);
-		if (!uar->bf_map) {
-			mlx5_core_warn(mdev, "ioremap_wc() failed\n");
-			uar->map = ioremap(pfn << PAGE_SHIFT, PAGE_SIZE);
-			if (!uar->map)
-				goto err_free_uar;
-		}
-	} else {
-		uar->map = ioremap(pfn << PAGE_SHIFT, PAGE_SIZE);
-		if (!uar->map)
-			goto err_free_uar;
-	}
-
-	return 0;
-
-err_free_uar:
-	mlx5_core_warn(mdev, "ioremap() failed\n");
-	err = -ENOMEM;
-	mlx5_cmd_free_uar(mdev, uar->index);
-
-	return err;
-}
-EXPORT_SYMBOL(mlx5_alloc_map_uar);
-
-void mlx5_unmap_free_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar)
-{
-	if (uar->map)
-		iounmap(uar->map);
-	else
-		iounmap(uar->bf_map);
-	mlx5_cmd_free_uar(mdev, uar->index);
-}
-EXPORT_SYMBOL(mlx5_unmap_free_uar);
-
 static int uars_per_sys_page(struct mlx5_core_dev *mdev)
 {
 	if (MLX5_CAP_GEN(mdev, uar_4k))
diff --git a/include/linux/mlx5/cq.h b/include/linux/mlx5/cq.h
index 1ed50f7..fbce184 100644
--- a/include/linux/mlx5/cq.h
+++ b/include/linux/mlx5/cq.h
@@ -42,13 +42,13 @@ struct mlx5_core_cq {
 	int			cqe_sz;
 	__be32		       *set_ci_db;
 	__be32		       *arm_db;
+	struct mlx5_uars_page  *uar;
 	atomic_t		refcount;
 	struct completion	free;
 	unsigned		vector;
 	unsigned int		irqn;
 	void (*comp)		(struct mlx5_core_cq *);
 	void (*event)		(struct mlx5_core_cq *, enum mlx5_event);
-	struct mlx5_uar	       *uar;
 	u32			cons_index;
 	unsigned		arm_sn;
 	struct mlx5_rsc_debug	*dbg;
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 7e7394f..10e6325 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -467,12 +467,6 @@ struct mlx5_sq_bfreg {
 	unsigned int		offset;
 };
 
-struct mlx5_uar {
-	u32			index;
-	void __iomem	       *map;
-	void __iomem	       *bf_map;
-};
-
 struct mlx5_core_health {
 	struct health_buffer __iomem   *health;
 	__be32 __iomem		       *health_counter;
@@ -725,7 +719,6 @@ struct mlx5_td {
 };
 
 struct mlx5e_resources {
-	struct mlx5_uar            cq_uar;
 	u32                        pdn;
 	struct mlx5_td             td;
 	struct mlx5_core_mkey      mkey;
@@ -915,11 +908,6 @@ void mlx5_cmd_mbox_status(void *out, u8 *status, u32 *syndrome);
 int mlx5_core_get_caps(struct mlx5_core_dev *dev, enum mlx5_cap_type cap_type);
 int mlx5_cmd_alloc_uar(struct mlx5_core_dev *dev, u32 *uarn);
 int mlx5_cmd_free_uar(struct mlx5_core_dev *dev, u32 uarn);
-int mlx5_alloc_bfregs(struct mlx5_core_dev *dev, struct mlx5_bfreg_info *bfregi);
-int mlx5_free_bfregs(struct mlx5_core_dev *dev, struct mlx5_bfreg_info *bfregi);
-int mlx5_alloc_map_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar,
-		       bool map_wc);
-void mlx5_unmap_free_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar);
 void mlx5_health_cleanup(struct mlx5_core_dev *dev);
 int mlx5_health_init(struct mlx5_core_dev *dev);
 void mlx5_start_health_poll(struct mlx5_core_dev *dev);
diff --git a/include/uapi/rdma/mlx5-abi.h b/include/uapi/rdma/mlx5-abi.h
index 86a8f30..85dc966 100644
--- a/include/uapi/rdma/mlx5-abi.h
+++ b/include/uapi/rdma/mlx5-abi.h
@@ -65,6 +65,10 @@ struct mlx5_ib_alloc_ucontext_req {
 	__u32	num_low_latency_bfregs;
 };
 
+enum mlx5_lib_caps {
+	MLX5_LIB_CAP_4K_UAR	= (u64)1 << 0,
+};
+
 struct mlx5_ib_alloc_ucontext_req_v2 {
 	__u32	total_num_bfregs;
 	__u32	num_low_latency_bfregs;
@@ -74,6 +78,7 @@ struct mlx5_ib_alloc_ucontext_req_v2 {
 	__u8	reserved0;
 	__u16	reserved1;
 	__u32	reserved2;
+	__u64	lib_caps;
 };
 
 enum mlx5_ib_alloc_ucontext_resp_mask {
@@ -103,6 +108,8 @@ struct mlx5_ib_alloc_ucontext_resp {
 	__u8	cmds_supp_uhw;
 	__u16	reserved2;
 	__u64	hca_core_clock_offset;
+	__u32	log_uar_size;
+	__u32	num_uars_per_page;
 };
 
 struct mlx5_ib_alloc_pd_resp {
-- 
2.7.4
