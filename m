From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net-next V2 1/7] net/mlx5e: Implement Fragmented Work Queue (WQ)
Date: Wed, 30 Nov 2016 17:59:37 +0200
Message-ID: <1480521583-12755-2-git-send-email-saeedm@mellanox.com>
References: <1480521583-12755-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Tariq Toukan <tariqt@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Roi Dayan <roid@mellanox.com>,
        Sebastian Ott <sebott@linux.vnet.ibm.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:59013 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753283AbcK3Q2E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 11:28:04 -0500
In-Reply-To: <1480521583-12755-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tariq Toukan <tariqt@mellanox.com>

Add new type of struct mlx5_frag_buf which is used to allocate fragmented
buffers rather than contiguous, and make the Completion Queues (CQs) use
it as they are big (default of 2MB per CQ in Striding RQ).

This fixes the failures of type:
"mlx5e_open_locked: mlx5e_open_channels failed, -12"
due to dma_zalloc_coherent insufficient contiguous coherent memory to
satisfy the driver's request when the user tries to setup more or larger
rings.

Signed-off-by: Tariq Toukan <tariqt@mellanox.com>
Reported-by: Sebastian Ott <sebott@linux.vnet.ibm.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c   | 66 +++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlx5/core/en.h      |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 10 ++--
 drivers/net/ethernet/mellanox/mlx5/core/wq.c      | 26 ++++++---
 drivers/net/ethernet/mellanox/mlx5/core/wq.h      | 18 +++++--
 include/linux/mlx5/driver.h                       | 11 ++++
 6 files changed, 116 insertions(+), 17 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
index 2c6e3c7..44791de 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
@@ -106,6 +106,63 @@ void mlx5_buf_free(struct mlx5_core_dev *dev, struct mlx5_buf *buf)
 }
 EXPORT_SYMBOL_GPL(mlx5_buf_free);
 
+int mlx5_frag_buf_alloc_node(struct mlx5_core_dev *dev, int size,
+			     struct mlx5_frag_buf *buf, int node)
+{
+	int i;
+
+	buf->size = size;
+	buf->npages = 1 << get_order(size);
+	buf->page_shift = PAGE_SHIFT;
+	buf->frags = kcalloc(buf->npages, sizeof(struct mlx5_buf_list),
+			     GFP_KERNEL);
+	if (!buf->frags)
+		goto err_out;
+
+	for (i = 0; i < buf->npages; i++) {
+		struct mlx5_buf_list *frag = &buf->frags[i];
+		int frag_sz = min_t(int, size, PAGE_SIZE);
+
+		frag->buf = mlx5_dma_zalloc_coherent_node(dev, frag_sz,
+							  &frag->map, node);
+		if (!frag->buf)
+			goto err_free_buf;
+		if (frag->map & ((1 << buf->page_shift) - 1)) {
+			dma_free_coherent(&dev->pdev->dev, frag_sz,
+					  buf->frags[i].buf, buf->frags[i].map);
+			mlx5_core_warn(dev, "unexpected map alignment: 0x%p, page_shift=%d\n",
+				       (void *)frag->map, buf->page_shift);
+			goto err_free_buf;
+		}
+		size -= frag_sz;
+	}
+
+	return 0;
+
+err_free_buf:
+	while (i--)
+		dma_free_coherent(&dev->pdev->dev, PAGE_SIZE, buf->frags[i].buf,
+				  buf->frags[i].map);
+	kfree(buf->frags);
+err_out:
+	return -ENOMEM;
+}
+
+void mlx5_frag_buf_free(struct mlx5_core_dev *dev, struct mlx5_frag_buf *buf)
+{
+	int size = buf->size;
+	int i;
+
+	for (i = 0; i < buf->npages; i++) {
+		int frag_sz = min_t(int, size, PAGE_SIZE);
+
+		dma_free_coherent(&dev->pdev->dev, frag_sz, buf->frags[i].buf,
+				  buf->frags[i].map);
+		size -= frag_sz;
+	}
+	kfree(buf->frags);
+}
+
 static struct mlx5_db_pgdir *mlx5_alloc_db_pgdir(struct mlx5_core_dev *dev,
 						 int node)
 {
@@ -230,3 +287,12 @@ void mlx5_fill_page_array(struct mlx5_buf *buf, __be64 *pas)
 	}
 }
 EXPORT_SYMBOL_GPL(mlx5_fill_page_array);
+
+void mlx5_fill_page_frag_array(struct mlx5_frag_buf *buf, __be64 *pas)
+{
+	int i;
+
+	for (i = 0; i < buf->npages; i++)
+		pas[i] = cpu_to_be64(buf->frags[i].map);
+}
+EXPORT_SYMBOL_GPL(mlx5_fill_page_frag_array);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en.h b/drivers/net/ethernet/mellanox/mlx5/core/en.h
index 442dbc3..f16f7fb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en.h
@@ -286,7 +286,7 @@ struct mlx5e_cq {
 	u16                        decmprs_wqe_counter;
 
 	/* control */
-	struct mlx5_wq_ctrl        wq_ctrl;
+	struct mlx5_frag_wq_ctrl   wq_ctrl;
 } ____cacheline_aligned_in_smp;
 
 struct mlx5e_rq;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 6b492ca..ba25cd3 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -1201,7 +1201,7 @@ static int mlx5e_create_cq(struct mlx5e_channel *c,
 
 static void mlx5e_destroy_cq(struct mlx5e_cq *cq)
 {
-	mlx5_wq_destroy(&cq->wq_ctrl);
+	mlx5_cqwq_destroy(&cq->wq_ctrl);
 }
 
 static int mlx5e_enable_cq(struct mlx5e_cq *cq, struct mlx5e_cq_param *param)
@@ -1218,7 +1218,7 @@ static int mlx5e_enable_cq(struct mlx5e_cq *cq, struct mlx5e_cq_param *param)
 	int err;
 
 	inlen = MLX5_ST_SZ_BYTES(create_cq_in) +
-		sizeof(u64) * cq->wq_ctrl.buf.npages;
+		sizeof(u64) * cq->wq_ctrl.frag_buf.npages;
 	in = mlx5_vzalloc(inlen);
 	if (!in)
 		return -ENOMEM;
@@ -1227,15 +1227,15 @@ static int mlx5e_enable_cq(struct mlx5e_cq *cq, struct mlx5e_cq_param *param)
 
 	memcpy(cqc, param->cqc, sizeof(param->cqc));
 
-	mlx5_fill_page_array(&cq->wq_ctrl.buf,
-			     (__be64 *)MLX5_ADDR_OF(create_cq_in, in, pas));
+	mlx5_fill_page_frag_array(&cq->wq_ctrl.frag_buf,
+				  (__be64 *)MLX5_ADDR_OF(create_cq_in, in, pas));
 
 	mlx5_vector2eqn(mdev, param->eq_ix, &eqn, &irqn_not_used);
 
 	MLX5_SET(cqc,   cqc, cq_period_mode, param->cq_period_mode);
 	MLX5_SET(cqc,   cqc, c_eqn,         eqn);
 	MLX5_SET(cqc,   cqc, uar_page,      mcq->uar->index);
-	MLX5_SET(cqc,   cqc, log_page_size, cq->wq_ctrl.buf.page_shift -
+	MLX5_SET(cqc,   cqc, log_page_size, cq->wq_ctrl.frag_buf.page_shift -
 					    MLX5_ADAPTER_PAGE_SHIFT);
 	MLX5_SET64(cqc, cqc, dbr_addr,      cq->wq_ctrl.db.dma);
 
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/wq.c b/drivers/net/ethernet/mellanox/mlx5/core/wq.c
index 821a087..921673c 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/wq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/wq.c
@@ -101,13 +101,15 @@ int mlx5_wq_cyc_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
 
 int mlx5_cqwq_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
 		     void *cqc, struct mlx5_cqwq *wq,
-		     struct mlx5_wq_ctrl *wq_ctrl)
+		     struct mlx5_frag_wq_ctrl *wq_ctrl)
 {
 	int err;
 
-	wq->log_stride = 6 + MLX5_GET(cqc, cqc, cqe_sz);
-	wq->log_sz = MLX5_GET(cqc, cqc, log_cq_size);
-	wq->sz_m1 = (1 << wq->log_sz) - 1;
+	wq->log_stride	= 6 + MLX5_GET(cqc, cqc, cqe_sz);
+	wq->log_sz	= MLX5_GET(cqc, cqc, log_cq_size);
+	wq->sz_m1	= (1 << wq->log_sz) - 1;
+	wq->log_frag_strides = PAGE_SHIFT - wq->log_stride;
+	wq->frag_sz_m1	= (1 << wq->log_frag_strides) - 1;
 
 	err = mlx5_db_alloc_node(mdev, &wq_ctrl->db, param->db_numa_node);
 	if (err) {
@@ -115,14 +117,16 @@ int mlx5_cqwq_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
 		return err;
 	}
 
-	err = mlx5_buf_alloc_node(mdev, mlx5_cqwq_get_byte_size(wq),
-				  &wq_ctrl->buf, param->buf_numa_node);
+	err = mlx5_frag_buf_alloc_node(mdev, mlx5_cqwq_get_byte_size(wq),
+				       &wq_ctrl->frag_buf,
+				       param->buf_numa_node);
 	if (err) {
-		mlx5_core_warn(mdev, "mlx5_buf_alloc_node() failed, %d\n", err);
+		mlx5_core_warn(mdev, "mlx5_frag_buf_alloc_node() failed, %d\n",
+			       err);
 		goto err_db_free;
 	}
 
-	wq->buf = wq_ctrl->buf.direct.buf;
+	wq->frag_buf = wq_ctrl->frag_buf;
 	wq->db  = wq_ctrl->db.db;
 
 	wq_ctrl->mdev = mdev;
@@ -184,3 +188,9 @@ void mlx5_wq_destroy(struct mlx5_wq_ctrl *wq_ctrl)
 	mlx5_buf_free(wq_ctrl->mdev, &wq_ctrl->buf);
 	mlx5_db_free(wq_ctrl->mdev, &wq_ctrl->db);
 }
+
+void mlx5_cqwq_destroy(struct mlx5_frag_wq_ctrl *wq_ctrl)
+{
+	mlx5_frag_buf_free(wq_ctrl->mdev, &wq_ctrl->frag_buf);
+	mlx5_db_free(wq_ctrl->mdev, &wq_ctrl->db);
+}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/wq.h b/drivers/net/ethernet/mellanox/mlx5/core/wq.h
index 6c2a8f9..d8afed8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/wq.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/wq.h
@@ -47,6 +47,12 @@ struct mlx5_wq_ctrl {
 	struct mlx5_db		db;
 };
 
+struct mlx5_frag_wq_ctrl {
+	struct mlx5_core_dev	*mdev;
+	struct mlx5_frag_buf	frag_buf;
+	struct mlx5_db		db;
+};
+
 struct mlx5_wq_cyc {
 	void			*buf;
 	__be32			*db;
@@ -55,12 +61,14 @@ struct mlx5_wq_cyc {
 };
 
 struct mlx5_cqwq {
-	void			*buf;
+	struct mlx5_frag_buf	frag_buf;
 	__be32			*db;
 	u32			sz_m1;
+	u32			frag_sz_m1;
 	u32			cc; /* consumer counter */
 	u8			log_sz;
 	u8			log_stride;
+	u8			log_frag_strides;
 };
 
 struct mlx5_wq_ll {
@@ -81,7 +89,7 @@ u32 mlx5_wq_cyc_get_size(struct mlx5_wq_cyc *wq);
 
 int mlx5_cqwq_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
 		     void *cqc, struct mlx5_cqwq *wq,
-		     struct mlx5_wq_ctrl *wq_ctrl);
+		     struct mlx5_frag_wq_ctrl *wq_ctrl);
 u32 mlx5_cqwq_get_size(struct mlx5_cqwq *wq);
 
 int mlx5_wq_ll_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
@@ -90,6 +98,7 @@ int mlx5_wq_ll_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
 u32 mlx5_wq_ll_get_size(struct mlx5_wq_ll *wq);
 
 void mlx5_wq_destroy(struct mlx5_wq_ctrl *wq_ctrl);
+void mlx5_cqwq_destroy(struct mlx5_frag_wq_ctrl *wq_ctrl);
 
 static inline u16 mlx5_wq_cyc_ctr2ix(struct mlx5_wq_cyc *wq, u16 ctr)
 {
@@ -116,7 +125,10 @@ static inline u32 mlx5_cqwq_get_ci(struct mlx5_cqwq *wq)
 
 static inline void *mlx5_cqwq_get_wqe(struct mlx5_cqwq *wq, u32 ix)
 {
-	return wq->buf + (ix << wq->log_stride);
+	unsigned int frag = (ix >> wq->log_frag_strides);
+
+	return wq->frag_buf.frags[frag].buf +
+		((wq->frag_sz_m1 & ix) << wq->log_stride);
 }
 
 static inline u32 mlx5_cqwq_get_wrap_cnt(struct mlx5_cqwq *wq)
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 68b85ef..0ae5536 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -318,6 +318,13 @@ struct mlx5_buf {
 	u8			page_shift;
 };
 
+struct mlx5_frag_buf {
+	struct mlx5_buf_list	*frags;
+	int			npages;
+	int			size;
+	u8			page_shift;
+};
+
 struct mlx5_eq_tasklet {
 	struct list_head list;
 	struct list_head process_list;
@@ -822,6 +829,9 @@ int mlx5_buf_alloc_node(struct mlx5_core_dev *dev, int size,
 			struct mlx5_buf *buf, int node);
 int mlx5_buf_alloc(struct mlx5_core_dev *dev, int size, struct mlx5_buf *buf);
 void mlx5_buf_free(struct mlx5_core_dev *dev, struct mlx5_buf *buf);
+int mlx5_frag_buf_alloc_node(struct mlx5_core_dev *dev, int size,
+			     struct mlx5_frag_buf *buf, int node);
+void mlx5_frag_buf_free(struct mlx5_core_dev *dev, struct mlx5_frag_buf *buf);
 struct mlx5_cmd_mailbox *mlx5_alloc_cmd_mailbox_chain(struct mlx5_core_dev *dev,
 						      gfp_t flags, int npages);
 void mlx5_free_cmd_mailbox_chain(struct mlx5_core_dev *dev,
@@ -866,6 +876,7 @@ void mlx5_unregister_debugfs(void);
 int mlx5_eq_init(struct mlx5_core_dev *dev);
 void mlx5_eq_cleanup(struct mlx5_core_dev *dev);
 void mlx5_fill_page_array(struct mlx5_buf *buf, __be64 *pas);
+void mlx5_fill_page_frag_array(struct mlx5_frag_buf *frag_buf, __be64 *pas);
 void mlx5_cq_completion(struct mlx5_core_dev *dev, u32 cqn);
 void mlx5_rsc_event(struct mlx5_core_dev *dev, u32 rsn, int event_type);
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING
-- 
2.7.4
