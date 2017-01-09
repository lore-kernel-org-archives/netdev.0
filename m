From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next V3 07/10] IB/mlx5: Use blue flame register allocator in mlx5_ib
Date: Mon,  9 Jan 2017 21:00:50 +0200
Message-ID: <1483988453-28551-8-git-send-email-saeedm@mellanox.com>
References: <1483988453-28551-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1483988453-28551-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

Make use of the blue flame registers allocator at mlx5_ib. Since blue
flame was not really supported we remove all the code that is related to
blue flame and we let all consumers to use the same blue flame register.
Once blue flame is supported we will add the code. As part of this patch
we also move the definition of struct mlx5_bf to mlx5_ib.h as it is only
used by mlx5_ib.

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/mlx5/cq.c                |   8 +-
 drivers/infiniband/hw/mlx5/main.c              |  28 +++++-
 drivers/infiniband/hw/mlx5/mlx5_ib.h           |  11 ++-
 drivers/infiniband/hw/mlx5/qp.c                |  73 +++-------------
 drivers/net/ethernet/mellanox/mlx5/core/en.h   |   2 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c |  16 +---
 drivers/net/ethernet/mellanox/mlx5/core/uar.c  | 114 -------------------------
 include/linux/mlx5/cq.h                        |   3 +-
 include/linux/mlx5/doorbell.h                  |   6 +-
 include/linux/mlx5/driver.h                    |  19 -----
 10 files changed, 59 insertions(+), 221 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/cq.c b/drivers/infiniband/hw/mlx5/cq.c
index bb7e91c..a28ec33 100644
--- a/drivers/infiniband/hw/mlx5/cq.c
+++ b/drivers/infiniband/hw/mlx5/cq.c
@@ -689,7 +689,7 @@ int mlx5_ib_arm_cq(struct ib_cq *ibcq, enum ib_cq_notify_flags flags)
 {
 	struct mlx5_core_dev *mdev = to_mdev(ibcq->device)->mdev;
 	struct mlx5_ib_cq *cq = to_mcq(ibcq);
-	void __iomem *uar_page = mdev->priv.bfregi.uars[0].map;
+	void __iomem *uar_page = mdev->priv.uar->map;
 	unsigned long irq_flags;
 	int ret = 0;
 
@@ -704,9 +704,7 @@ int mlx5_ib_arm_cq(struct ib_cq *ibcq, enum ib_cq_notify_flags flags)
 	mlx5_cq_arm(&cq->mcq,
 		    (flags & IB_CQ_SOLICITED_MASK) == IB_CQ_SOLICITED ?
 		    MLX5_CQ_DB_REQ_NOT_SOL : MLX5_CQ_DB_REQ_NOT,
-		    uar_page,
-		    MLX5_GET_DOORBELL_LOCK(&mdev->priv.cq_uar_lock),
-		    to_mcq(ibcq)->mcq.cons_index);
+		    uar_page, to_mcq(ibcq)->mcq.cons_index);
 
 	return ret;
 }
@@ -886,7 +884,7 @@ static int create_cq_kernel(struct mlx5_ib_dev *dev, struct mlx5_ib_cq *cq,
 	MLX5_SET(cqc, cqc, log_page_size,
 		 cq->buf.buf.page_shift - MLX5_ADAPTER_PAGE_SHIFT);
 
-	*index = dev->mdev->priv.bfregi.uars[0].index;
+	*index = dev->mdev->priv.uar->index;
 
 	return 0;
 
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index d5cf82b..e9f0830 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -3074,8 +3074,6 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 	if (mlx5_use_mad_ifc(dev))
 		get_ext_port_caps(dev);
 
-	MLX5_INIT_DOORBELL_LOCK(&dev->uar_lock);
-
 	if (!mlx5_lag_is_active(mdev))
 		name = "mlx5_%d";
 	else
@@ -3251,9 +3249,21 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 	if (err)
 		goto err_odp;
 
+	dev->mdev->priv.uar = mlx5_get_uars_page(dev->mdev);
+	if (!dev->mdev->priv.uar)
+		goto err_q_cnt;
+
+	err = mlx5_alloc_bfreg(dev->mdev, &dev->bfreg, false, false);
+	if (err)
+		goto err_uar_page;
+
+	err = mlx5_alloc_bfreg(dev->mdev, &dev->fp_bfreg, false, true);
+	if (err)
+		goto err_bfreg;
+
 	err = ib_register_device(&dev->ib_dev, NULL);
 	if (err)
-		goto err_q_cnt;
+		goto err_fp_bfreg;
 
 	err = create_umr_res(dev);
 	if (err)
@@ -3276,6 +3286,15 @@ static void *mlx5_ib_add(struct mlx5_core_dev *mdev)
 err_dev:
 	ib_unregister_device(&dev->ib_dev);
 
+err_fp_bfreg:
+	mlx5_free_bfreg(dev->mdev, &dev->fp_bfreg);
+
+err_bfreg:
+	mlx5_free_bfreg(dev->mdev, &dev->bfreg);
+
+err_uar_page:
+	mlx5_put_uars_page(dev->mdev, dev->mdev->priv.uar);
+
 err_q_cnt:
 	mlx5_ib_dealloc_q_counters(dev);
 
@@ -3307,6 +3326,9 @@ static void mlx5_ib_remove(struct mlx5_core_dev *mdev, void *context)
 
 	mlx5_remove_netdev_notifier(dev);
 	ib_unregister_device(&dev->ib_dev);
+	mlx5_free_bfreg(dev->mdev, &dev->fp_bfreg);
+	mlx5_free_bfreg(dev->mdev, &dev->bfreg);
+	mlx5_put_uars_page(dev->mdev, mdev->priv.uar);
 	mlx5_ib_dealloc_q_counters(dev);
 	destroy_umrc_res(dev);
 	mlx5_ib_odp_remove_one(dev);
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index d4d1329..ae3bc4a 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -324,6 +324,12 @@ struct mlx5_ib_raw_packet_qp {
 	struct mlx5_ib_rq rq;
 };
 
+struct mlx5_bf {
+	int			buf_size;
+	unsigned long		offset;
+	struct mlx5_sq_bfreg   *bfreg;
+};
+
 struct mlx5_ib_qp {
 	struct ib_qp		ibqp;
 	union {
@@ -349,7 +355,7 @@ struct mlx5_ib_qp {
 	int			wq_sig;
 	int			scat_cqe;
 	int			max_inline_data;
-	struct mlx5_bf	       *bf;
+	struct mlx5_bf	        bf;
 	int			has_rq;
 
 	/* only for user space QPs. For kernel
@@ -591,7 +597,6 @@ struct mlx5_ib_dev {
 	struct ib_device		ib_dev;
 	struct mlx5_core_dev		*mdev;
 	struct mlx5_roce		roce;
-	MLX5_DECLARE_DOORBELL_LOCK(uar_lock);
 	int				num_ports;
 	/* serialize update of capability mask
 	 */
@@ -621,6 +626,8 @@ struct mlx5_ib_dev {
 	struct list_head	qp_list;
 	/* Array with num_ports elements */
 	struct mlx5_ib_port	*port;
+	struct mlx5_sq_bfreg     bfreg;
+	struct mlx5_sq_bfreg     fp_bfreg;
 };
 
 static inline struct mlx5_ib_cq *to_mibcq(struct mlx5_core_cq *mcq)
diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index 240fbb0..fce1c6d 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -909,14 +909,10 @@ static int create_kernel_qp(struct mlx5_ib_dev *dev,
 			    u32 **in, int *inlen,
 			    struct mlx5_ib_qp_base *base)
 {
-	enum mlx5_ib_latency_class lc = MLX5_IB_LATENCY_CLASS_LOW;
-	struct mlx5_bfreg_info *bfregi;
 	int uar_index;
 	void *qpc;
-	int bfregn;
 	int err;
 
-	bfregi = &dev->mdev->priv.bfregi;
 	if (init_attr->create_flags & ~(IB_QP_CREATE_SIGNATURE_EN |
 					IB_QP_CREATE_BLOCK_MULTICAST_LOOPBACK |
 					IB_QP_CREATE_IPOIB_UD_LSO |
@@ -924,21 +920,17 @@ static int create_kernel_qp(struct mlx5_ib_dev *dev,
 		return -EINVAL;
 
 	if (init_attr->qp_type == MLX5_IB_QPT_REG_UMR)
-		lc = MLX5_IB_LATENCY_CLASS_FAST_PATH;
-
-	bfregn = alloc_bfreg(bfregi, lc);
-	if (bfregn < 0) {
-		mlx5_ib_dbg(dev, "\n");
-		return -ENOMEM;
-	}
+		qp->bf.bfreg = &dev->fp_bfreg;
+	else
+		qp->bf.bfreg = &dev->bfreg;
 
-	qp->bf = &bfregi->bfs[bfregn];
-	uar_index = qp->bf->uar->index;
+	qp->bf.buf_size = 1 << MLX5_CAP_GEN(dev->mdev, log_bf_reg_size);
+	uar_index = qp->bf.bfreg->index;
 
 	err = calc_sq_size(dev, init_attr, qp);
 	if (err < 0) {
 		mlx5_ib_dbg(dev, "err %d\n", err);
-		goto err_bfreg;
+		return err;
 	}
 
 	qp->rq.offset = 0;
@@ -948,7 +940,7 @@ static int create_kernel_qp(struct mlx5_ib_dev *dev,
 	err = mlx5_buf_alloc(dev->mdev, base->ubuffer.buf_size, &qp->buf);
 	if (err) {
 		mlx5_ib_dbg(dev, "err %d\n", err);
-		goto err_bfreg;
+		return err;
 	}
 
 	qp->sq.qend = mlx5_get_send_wqe(qp, qp->sq.wqe_cnt);
@@ -1010,9 +1002,6 @@ static int create_kernel_qp(struct mlx5_ib_dev *dev,
 
 err_buf:
 	mlx5_buf_free(dev->mdev, &qp->buf);
-
-err_bfreg:
-	free_bfreg(&dev->mdev->priv.bfregi, bfregn);
 	return err;
 }
 
@@ -1025,7 +1014,6 @@ static void destroy_qp_kernel(struct mlx5_ib_dev *dev, struct mlx5_ib_qp *qp)
 	kfree(qp->rq.wrid);
 	mlx5_db_free(dev->mdev, &qp->db);
 	mlx5_buf_free(dev->mdev, &qp->buf);
-	free_bfreg(&dev->mdev->priv.bfregi, qp->bf->bfregn);
 }
 
 static u32 get_rx_type(struct mlx5_ib_qp *qp, struct ib_qp_init_attr *attr)
@@ -3744,24 +3732,6 @@ static void dump_wqe(struct mlx5_ib_qp *qp, int idx, int size_16)
 	}
 }
 
-static void mlx5_bf_copy(u64 __iomem *dst, u64 *src,
-			 unsigned bytecnt, struct mlx5_ib_qp *qp)
-{
-	while (bytecnt > 0) {
-		__iowrite64_copy(dst++, src++, 8);
-		__iowrite64_copy(dst++, src++, 8);
-		__iowrite64_copy(dst++, src++, 8);
-		__iowrite64_copy(dst++, src++, 8);
-		__iowrite64_copy(dst++, src++, 8);
-		__iowrite64_copy(dst++, src++, 8);
-		__iowrite64_copy(dst++, src++, 8);
-		__iowrite64_copy(dst++, src++, 8);
-		bytecnt -= 64;
-		if (unlikely(src == qp->sq.qend))
-			src = mlx5_get_send_wqe(qp, 0);
-	}
-}
-
 static u8 get_fence(u8 fence, struct ib_send_wr *wr)
 {
 	if (unlikely(wr->opcode == IB_WR_LOCAL_INV &&
@@ -3857,7 +3827,7 @@ int mlx5_ib_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 		return mlx5_ib_gsi_post_send(ibqp, wr, bad_wr);
 
 	qp = to_mqp(ibqp);
-	bf = qp->bf;
+	bf = &qp->bf;
 	qend = qp->sq.qend;
 
 	spin_lock_irqsave(&qp->sq.lock, flags);
@@ -4130,28 +4100,13 @@ int mlx5_ib_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 		 * we hit doorbell */
 		wmb();
 
-		if (bf->need_lock)
-			spin_lock(&bf->lock);
-		else
-			__acquire(&bf->lock);
-
-		/* TBD enable WC */
-		if (0 && nreq == 1 && bf->bfregn && inl && size > 1 && size <= bf->buf_size / 16) {
-			mlx5_bf_copy(bf->reg + bf->offset, (u64 *)ctrl, ALIGN(size * 16, 64), qp);
-			/* wc_wmb(); */
-		} else {
-			mlx5_write64((__be32 *)ctrl, bf->regreg + bf->offset,
-				     MLX5_GET_DOORBELL_LOCK(&bf->lock32));
-			/* Make sure doorbells don't leak out of SQ spinlock
-			 * and reach the HCA out of order.
-			 */
-			mmiowb();
-		}
+		/* currently we support only regular doorbells */
+		mlx5_write64((__be32 *)ctrl, bf->bfreg->map + bf->offset, NULL);
+		/* Make sure doorbells don't leak out of SQ spinlock
+		 * and reach the HCA out of order.
+		 */
+		mmiowb();
 		bf->offset ^= bf->buf_size;
-		if (bf->need_lock)
-			spin_unlock(&bf->lock);
-		else
-			__release(&bf->lock);
 	}
 
 	spin_unlock_irqrestore(&qp->sq.lock, flags);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 951dbd5..3037631 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -832,7 +832,7 @@ static inline void mlx5e_cq_arm(struct mlx5e_cq *cq)
 	struct mlx5_core_cq *mcq;
 
 	mcq = &cq->mcq;
-	mlx5_cq_arm(mcq, MLX5_CQ_DB_REQ_NOT, mcq->uar->map, NULL, cq->wq.cc);
+	mlx5_cq_arm(mcq, MLX5_CQ_DB_REQ_NOT, mcq->uar->map, cq->wq.cc);
 }
 
 static inline u32 mlx5e_get_wqe_mtt_offset(struct mlx5e_rq *rq, u16 wqe_ix)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 2882d04..ff1f144 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -913,8 +913,6 @@ static int mlx5_init_once(struct mlx5_core_dev *dev, struct mlx5_priv *priv)
 		goto out;
 	}
 
-	MLX5_INIT_DOORBELL_LOCK(&priv->cq_uar_lock);
-
 	err = mlx5_init_cq_table(dev);
 	if (err) {
 		dev_err(&pdev->dev, "failed to initialize cq table\n");
@@ -1099,16 +1097,10 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 		goto err_disable_msix;
 	}
 
-	err = mlx5_alloc_bfregs(dev, &priv->bfregi);
-	if (err) {
-		dev_err(&pdev->dev, "Failed allocating uuars, aborting\n");
-		goto err_uar_cleanup;
-	}
-
 	err = mlx5_start_eqs(dev);
 	if (err) {
 		dev_err(&pdev->dev, "Failed to start pages and async EQs\n");
-		goto err_free_uar;
+		goto err_put_uars;
 	}
 
 	err = alloc_comp_eqs(dev);
@@ -1174,10 +1166,7 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 err_stop_eqs:
 	mlx5_stop_eqs(dev);
 
-err_free_uar:
-	mlx5_free_bfregs(dev, &priv->bfregi);
-
-err_uar_cleanup:
+err_put_uars:
 	mlx5_put_uars_page(dev, priv->uar);
 
 err_disable_msix:
@@ -1238,7 +1227,6 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 	mlx5_irq_clear_affinity_hints(dev);
 	free_comp_eqs(dev);
 	mlx5_stop_eqs(dev);
-	mlx5_free_bfregs(dev, &priv->bfregi);
 	mlx5_put_uars_page(dev, priv->uar);
 	mlx5_disable_msix(dev);
 	if (cleanup)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/uar.c b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
index fcc0270..07b273c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/uar.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
@@ -67,120 +67,6 @@ int mlx5_cmd_free_uar(struct mlx5_core_dev *dev, u32 uarn)
 }
 EXPORT_SYMBOL(mlx5_cmd_free_uar);
 
-static int need_bfreg_lock(int bfregn)
-{
-	int tot_bfregs = NUM_DRIVER_UARS * MLX5_BFREGS_PER_UAR;
-
-	if (bfregn == 0 || tot_bfregs - NUM_LOW_LAT_BFREGS)
-		return 0;
-
-	return 1;
-}
-
-int mlx5_alloc_bfregs(struct mlx5_core_dev *dev, struct mlx5_bfreg_info *bfregi)
-{
-	int tot_bfregs = NUM_DRIVER_UARS * MLX5_BFREGS_PER_UAR;
-	struct mlx5_bf *bf;
-	phys_addr_t addr;
-	int err;
-	int i;
-
-	bfregi->num_uars = NUM_DRIVER_UARS;
-	bfregi->num_low_latency_bfregs = NUM_LOW_LAT_BFREGS;
-
-	mutex_init(&bfregi->lock);
-	bfregi->uars = kcalloc(bfregi->num_uars, sizeof(*bfregi->uars), GFP_KERNEL);
-	if (!bfregi->uars)
-		return -ENOMEM;
-
-	bfregi->bfs = kcalloc(tot_bfregs, sizeof(*bfregi->bfs), GFP_KERNEL);
-	if (!bfregi->bfs) {
-		err = -ENOMEM;
-		goto out_uars;
-	}
-
-	bfregi->bitmap = kcalloc(BITS_TO_LONGS(tot_bfregs), sizeof(*bfregi->bitmap),
-				GFP_KERNEL);
-	if (!bfregi->bitmap) {
-		err = -ENOMEM;
-		goto out_bfs;
-	}
-
-	bfregi->count = kcalloc(tot_bfregs, sizeof(*bfregi->count), GFP_KERNEL);
-	if (!bfregi->count) {
-		err = -ENOMEM;
-		goto out_bitmap;
-	}
-
-	for (i = 0; i < bfregi->num_uars; i++) {
-		err = mlx5_cmd_alloc_uar(dev, &bfregi->uars[i].index);
-		if (err)
-			goto out_count;
-
-		addr = dev->iseg_base + ((phys_addr_t)(bfregi->uars[i].index) << PAGE_SHIFT);
-		bfregi->uars[i].map = ioremap(addr, PAGE_SIZE);
-		if (!bfregi->uars[i].map) {
-			mlx5_cmd_free_uar(dev, bfregi->uars[i].index);
-			err = -ENOMEM;
-			goto out_count;
-		}
-		mlx5_core_dbg(dev, "allocated uar index 0x%x, mmaped at %p\n",
-			      bfregi->uars[i].index, bfregi->uars[i].map);
-	}
-
-	for (i = 0; i < tot_bfregs; i++) {
-		bf = &bfregi->bfs[i];
-
-		bf->buf_size = (1 << MLX5_CAP_GEN(dev, log_bf_reg_size)) / 2;
-		bf->uar = &bfregi->uars[i / MLX5_BFREGS_PER_UAR];
-		bf->regreg = bfregi->uars[i / MLX5_BFREGS_PER_UAR].map;
-		bf->reg = NULL; /* Add WC support */
-		bf->offset = (i % MLX5_BFREGS_PER_UAR) *
-			     (1 << MLX5_CAP_GEN(dev, log_bf_reg_size)) +
-			     MLX5_BF_OFFSET;
-		bf->need_lock = need_bfreg_lock(i);
-		spin_lock_init(&bf->lock);
-		spin_lock_init(&bf->lock32);
-		bf->bfregn = i;
-	}
-
-	return 0;
-
-out_count:
-	for (i--; i >= 0; i--) {
-		iounmap(bfregi->uars[i].map);
-		mlx5_cmd_free_uar(dev, bfregi->uars[i].index);
-	}
-	kfree(bfregi->count);
-
-out_bitmap:
-	kfree(bfregi->bitmap);
-
-out_bfs:
-	kfree(bfregi->bfs);
-
-out_uars:
-	kfree(bfregi->uars);
-	return err;
-}
-
-int mlx5_free_bfregs(struct mlx5_core_dev *dev, struct mlx5_bfreg_info *bfregi)
-{
-	int i = bfregi->num_uars;
-
-	for (i--; i >= 0; i--) {
-		iounmap(bfregi->uars[i].map);
-		mlx5_cmd_free_uar(dev, bfregi->uars[i].index);
-	}
-
-	kfree(bfregi->count);
-	kfree(bfregi->bitmap);
-	kfree(bfregi->bfs);
-	kfree(bfregi->uars);
-
-	return 0;
-}
-
 int mlx5_alloc_map_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar,
 		       bool map_wc)
 {
diff --git a/include/linux/mlx5/cq.h b/include/linux/mlx5/cq.h
index 7c3c0d3..9968633 100644
--- a/include/linux/mlx5/cq.h
+++ b/include/linux/mlx5/cq.h
@@ -144,7 +144,6 @@ enum {
 
 static inline void mlx5_cq_arm(struct mlx5_core_cq *cq, u32 cmd,
 			       void __iomem *uar_page,
-			       spinlock_t *doorbell_lock,
 			       u32 cons_index)
 {
 	__be32 doorbell[2];
@@ -164,7 +163,7 @@ static inline void mlx5_cq_arm(struct mlx5_core_cq *cq, u32 cmd,
 	doorbell[0] = cpu_to_be32(sn << 28 | cmd | ci);
 	doorbell[1] = cpu_to_be32(cq->cqn);
 
-	mlx5_write64(doorbell, uar_page + MLX5_CQ_DOORBELL, doorbell_lock);
+	mlx5_write64(doorbell, uar_page + MLX5_CQ_DOORBELL, NULL);
 }
 
 int mlx5_init_cq_table(struct mlx5_core_dev *dev);
diff --git a/include/linux/mlx5/doorbell.h b/include/linux/mlx5/doorbell.h
index afc78a3..0787de2 100644
--- a/include/linux/mlx5/doorbell.h
+++ b/include/linux/mlx5/doorbell.h
@@ -68,10 +68,12 @@ static inline void mlx5_write64(__be32 val[2], void __iomem *dest,
 {
 	unsigned long flags;
 
-	spin_lock_irqsave(doorbell_lock, flags);
+	if (doorbell_lock)
+		spin_lock_irqsave(doorbell_lock, flags);
 	__raw_writel((__force u32) val[0], dest);
 	__raw_writel((__force u32) val[1], dest + 4);
-	spin_unlock_irqrestore(doorbell_lock, flags);
+	if (doorbell_lock)
+		spin_unlock_irqrestore(doorbell_lock, flags);
 }
 
 #endif
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 9a3a095..bb362f5 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -203,23 +203,6 @@ struct mlx5_bfreg_info {
 	u32			ver;
 };
 
-struct mlx5_bf {
-	void __iomem	       *reg;
-	void __iomem	       *regreg;
-	int			buf_size;
-	struct mlx5_uar	       *uar;
-	unsigned long		offset;
-	int			need_lock;
-	/* protect blue flame buffer selection when needed
-	 */
-	spinlock_t		lock;
-
-	/* serialize 64 bit writes when done as two 32 bit accesses
-	 */
-	spinlock_t		lock32;
-	int			bfregn;
-};
-
 struct mlx5_cmd_first {
 	__be32		data[4];
 };
@@ -612,8 +595,6 @@ struct mlx5_priv {
 	struct mlx5_eq_table	eq_table;
 	struct msix_entry	*msix_arr;
 	struct mlx5_irq_info	*irq_info;
-	struct mlx5_bfreg_info	bfregi;
-	MLX5_DECLARE_DOORBELL_LOCK(cq_uar_lock);
 
 	/* pages stuff */
 	struct workqueue_struct *pg_wq;
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
