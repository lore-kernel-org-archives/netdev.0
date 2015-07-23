From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 2/6] net/mlx5e: Allocate DMA coherent memory on reader NUMA node
Date: Thu, 23 Jul 2015 23:35:57 +0300
Message-ID: <1437683761-28052-3-git-send-email-amirv@mellanox.com>
References: <1437683761-28052-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Amir Vadai <amirv@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [193.47.165.129] ([193.47.165.129]:39662 "EHLO mellanox.co.il"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753814AbbGWUgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Jul 2015 16:36:50 -0400
In-Reply-To: <1437683761-28052-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@mellanox.com>

By affinity hints and XPS, each mlx5e channel is assigned a CPU
core.

Channel DMA coherent memory that is written by the NIC and read
by SW (e.g CQ buffer) is allocated on the NUMA node of the CPU
core assigned for the channel.

Channel DMA coherent memory that is written by SW and read by the
NIC (e.g SQ/RQ buffer) is allocated on the NUMA node of the NIC.

Doorbell record (written by SW and read by the NIC) is an
exception since it is accessed by SW more frequently.

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c   | 48 +++++++++++++++++++----
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c | 11 ++++--
 drivers/net/ethernet/mellanox/mlx5/core/main.c    |  6 ++-
 drivers/net/ethernet/mellanox/mlx5/core/wq.c      | 12 +++---
 drivers/net/ethernet/mellanox/mlx5/core/wq.h      |  3 +-
 include/linux/mlx5/driver.h                       |  8 ++++
 6 files changed, 70 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
index 0715b49..6cb3830 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
@@ -45,15 +45,34 @@
  * register it in a memory region at HCA virtual address 0.
  */
 
-int mlx5_buf_alloc(struct mlx5_core_dev *dev, int size, struct mlx5_buf *buf)
+static void *mlx5_dma_zalloc_coherent_node(struct mlx5_core_dev *dev,
+					   size_t size, dma_addr_t *dma_handle,
+					   int node)
+{
+	struct mlx5_priv *priv = &dev->priv;
+	int original_node;
+	void *cpu_handle;
+
+	mutex_lock(&priv->alloc_mutex);
+	original_node = dev_to_node(&dev->pdev->dev);
+	set_dev_node(&dev->pdev->dev, node);
+	cpu_handle = dma_zalloc_coherent(&dev->pdev->dev, size,
+					 dma_handle, GFP_KERNEL);
+	set_dev_node(&dev->pdev->dev, original_node);
+	mutex_unlock(&priv->alloc_mutex);
+	return cpu_handle;
+}
+
+int mlx5_buf_alloc_node(struct mlx5_core_dev *dev, int size,
+			struct mlx5_buf *buf, int node)
 {
 	dma_addr_t t;
 
 	buf->size = size;
 	buf->npages       = 1;
 	buf->page_shift   = (u8)get_order(size) + PAGE_SHIFT;
-	buf->direct.buf   = dma_zalloc_coherent(&dev->pdev->dev,
-						size, &t, GFP_KERNEL);
+	buf->direct.buf   = mlx5_dma_zalloc_coherent_node(dev, size,
+							  &t, node);
 	if (!buf->direct.buf)
 		return -ENOMEM;
 
@@ -66,6 +85,11 @@ int mlx5_buf_alloc(struct mlx5_core_dev *dev, int size, struct mlx5_buf *buf)
 
 	return 0;
 }
+
+int mlx5_buf_alloc(struct mlx5_core_dev *dev, int size, struct mlx5_buf *buf)
+{
+	return mlx5_buf_alloc_node(dev, size, buf, dev->priv.numa_node);
+}
 EXPORT_SYMBOL_GPL(mlx5_buf_alloc);
 
 void mlx5_buf_free(struct mlx5_core_dev *dev, struct mlx5_buf *buf)
@@ -75,7 +99,8 @@ void mlx5_buf_free(struct mlx5_core_dev *dev, struct mlx5_buf *buf)
 }
 EXPORT_SYMBOL_GPL(mlx5_buf_free);
 
-static struct mlx5_db_pgdir *mlx5_alloc_db_pgdir(struct device *dma_device)
+static struct mlx5_db_pgdir *mlx5_alloc_db_pgdir(struct mlx5_core_dev *dev,
+						 int node)
 {
 	struct mlx5_db_pgdir *pgdir;
 
@@ -84,8 +109,9 @@ static struct mlx5_db_pgdir *mlx5_alloc_db_pgdir(struct device *dma_device)
 		return NULL;
 
 	bitmap_fill(pgdir->bitmap, MLX5_DB_PER_PAGE);
-	pgdir->db_page = dma_alloc_coherent(dma_device, PAGE_SIZE,
-					    &pgdir->db_dma, GFP_KERNEL);
+
+	pgdir->db_page = mlx5_dma_zalloc_coherent_node(dev, PAGE_SIZE,
+						       &pgdir->db_dma, node);
 	if (!pgdir->db_page) {
 		kfree(pgdir);
 		return NULL;
@@ -118,7 +144,7 @@ static int mlx5_alloc_db_from_pgdir(struct mlx5_db_pgdir *pgdir,
 	return 0;
 }
 
-int mlx5_db_alloc(struct mlx5_core_dev *dev, struct mlx5_db *db)
+int mlx5_db_alloc_node(struct mlx5_core_dev *dev, struct mlx5_db *db, int node)
 {
 	struct mlx5_db_pgdir *pgdir;
 	int ret = 0;
@@ -129,7 +155,7 @@ int mlx5_db_alloc(struct mlx5_core_dev *dev, struct mlx5_db *db)
 		if (!mlx5_alloc_db_from_pgdir(pgdir, db))
 			goto out;
 
-	pgdir = mlx5_alloc_db_pgdir(&(dev->pdev->dev));
+	pgdir = mlx5_alloc_db_pgdir(dev, node);
 	if (!pgdir) {
 		ret = -ENOMEM;
 		goto out;
@@ -145,6 +171,12 @@ out:
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(mlx5_db_alloc_node);
+
+int mlx5_db_alloc(struct mlx5_core_dev *dev, struct mlx5_db *db)
+{
+	return mlx5_db_alloc_node(dev, db, dev->priv.numa_node);
+}
 EXPORT_SYMBOL_GPL(mlx5_db_alloc);
 
 void mlx5_db_free(struct mlx5_core_dev *dev, struct mlx5_db *db)
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index 07d3627..57cc896 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -272,6 +272,8 @@ static int mlx5e_create_rq(struct mlx5e_channel *c,
 	int err;
 	int i;
 
+	param->wq.db_numa_node = cpu_to_node(c->cpu);
+
 	err = mlx5_wq_ll_create(mdev, &param->wq, rqc_wq, &rq->wq,
 				&rq->wq_ctrl);
 	if (err)
@@ -502,6 +504,8 @@ static int mlx5e_create_sq(struct mlx5e_channel *c,
 	if (err)
 		return err;
 
+	param->wq.db_numa_node = cpu_to_node(c->cpu);
+
 	err = mlx5_wq_cyc_create(mdev, &param->wq, sqc_wq, &sq->wq,
 				 &sq->wq_ctrl);
 	if (err)
@@ -702,7 +706,8 @@ static int mlx5e_create_cq(struct mlx5e_channel *c,
 	int err;
 	u32 i;
 
-	param->wq.numa = cpu_to_node(c->cpu);
+	param->wq.buf_numa_node = cpu_to_node(c->cpu);
+	param->wq.db_numa_node  = cpu_to_node(c->cpu);
 	param->eq_ix   = c->ix;
 
 	err = mlx5_cqwq_create(mdev, &param->wq, param->cqc, &cq->wq,
@@ -1000,7 +1005,7 @@ static void mlx5e_build_rq_param(struct mlx5e_priv *priv,
 	MLX5_SET(wq, wq, log_wq_sz,        priv->params.log_rq_size);
 	MLX5_SET(wq, wq, pd,               priv->pdn);
 
-	param->wq.numa   = dev_to_node(&priv->mdev->pdev->dev);
+	param->wq.buf_numa_node = dev_to_node(&priv->mdev->pdev->dev);
 	param->wq.linear = 1;
 }
 
@@ -1014,7 +1019,7 @@ static void mlx5e_build_sq_param(struct mlx5e_priv *priv,
 	MLX5_SET(wq, wq, log_wq_stride, ilog2(MLX5_SEND_WQE_BB));
 	MLX5_SET(wq, wq, pd,            priv->pdn);
 
-	param->wq.numa = dev_to_node(&priv->mdev->pdev->dev);
+	param->wq.buf_numa_node = dev_to_node(&priv->mdev->pdev->dev);
 }
 
 static void mlx5e_build_common_cq_param(struct mlx5e_priv *priv,
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index afad529..c34eafb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -455,7 +455,7 @@ static int mlx5_irq_set_affinity_hint(struct mlx5_core_dev *mdev, int i)
 	struct mlx5_priv *priv  = &mdev->priv;
 	struct msix_entry *msix = priv->msix_arr;
 	int irq                 = msix[i + MLX5_EQ_VEC_COMP_BASE].vector;
-	int numa_node           = dev_to_node(&mdev->pdev->dev);
+	int numa_node           = priv->numa_node;
 	int err;
 
 	if (!zalloc_cpumask_var(&priv->irq_info[i].mask, GFP_KERNEL)) {
@@ -668,6 +668,10 @@ static int mlx5_dev_init(struct mlx5_core_dev *dev, struct pci_dev *pdev)
 	INIT_LIST_HEAD(&priv->pgdir_list);
 	spin_lock_init(&priv->mkey_lock);
 
+	mutex_init(&priv->alloc_mutex);
+
+	priv->numa_node = dev_to_node(&dev->pdev->dev);
+
 	priv->dbg_root = debugfs_create_dir(dev_name(&pdev->dev), mlx5_debugfs_root);
 	if (!priv->dbg_root)
 		return -ENOMEM;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/wq.c b/drivers/net/ethernet/mellanox/mlx5/core/wq.c
index 8388411..ce21ee5 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/wq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/wq.c
@@ -73,13 +73,14 @@ int mlx5_wq_cyc_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
 	wq->log_stride = MLX5_GET(wq, wqc, log_wq_stride);
 	wq->sz_m1 = (1 << MLX5_GET(wq, wqc, log_wq_sz)) - 1;
 
-	err = mlx5_db_alloc(mdev, &wq_ctrl->db);
+	err = mlx5_db_alloc_node(mdev, &wq_ctrl->db, param->db_numa_node);
 	if (err) {
 		mlx5_core_warn(mdev, "mlx5_db_alloc() failed, %d\n", err);
 		return err;
 	}
 
-	err = mlx5_buf_alloc(mdev, mlx5_wq_cyc_get_byte_size(wq), &wq_ctrl->buf);
+	err = mlx5_buf_alloc_node(mdev, mlx5_wq_cyc_get_byte_size(wq),
+				  &wq_ctrl->buf, param->buf_numa_node);
 	if (err) {
 		mlx5_core_warn(mdev, "mlx5_buf_alloc() failed, %d\n", err);
 		goto err_db_free;
@@ -108,13 +109,14 @@ int mlx5_cqwq_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
 	wq->log_sz = MLX5_GET(cqc, cqc, log_cq_size);
 	wq->sz_m1 = (1 << wq->log_sz) - 1;
 
-	err = mlx5_db_alloc(mdev, &wq_ctrl->db);
+	err = mlx5_db_alloc_node(mdev, &wq_ctrl->db, param->db_numa_node);
 	if (err) {
 		mlx5_core_warn(mdev, "mlx5_db_alloc() failed, %d\n", err);
 		return err;
 	}
 
-	err = mlx5_buf_alloc(mdev, mlx5_cqwq_get_byte_size(wq), &wq_ctrl->buf);
+	err = mlx5_buf_alloc_node(mdev, mlx5_cqwq_get_byte_size(wq),
+				  &wq_ctrl->buf, param->buf_numa_node);
 	if (err) {
 		mlx5_core_warn(mdev, "mlx5_buf_alloc() failed, %d\n", err);
 		goto err_db_free;
@@ -144,7 +146,7 @@ int mlx5_wq_ll_create(struct mlx5_core_dev *mdev, struct mlx5_wq_param *param,
 	wq->log_stride = MLX5_GET(wq, wqc, log_wq_stride);
 	wq->sz_m1 = (1 << MLX5_GET(wq, wqc, log_wq_sz)) - 1;
 
-	err = mlx5_db_alloc(mdev, &wq_ctrl->db);
+	err = mlx5_db_alloc_node(mdev, &wq_ctrl->db, param->db_numa_node);
 	if (err) {
 		mlx5_core_warn(mdev, "mlx5_db_alloc() failed, %d\n", err);
 		return err;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/wq.h b/drivers/net/ethernet/mellanox/mlx5/core/wq.h
index e0ddd69..6c2a8f9 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/wq.h
+++ b/drivers/net/ethernet/mellanox/mlx5/core/wq.h
@@ -37,7 +37,8 @@
 
 struct mlx5_wq_param {
 	int		linear;
-	int		numa;
+	int		buf_numa_node;
+	int		db_numa_node;
 };
 
 struct mlx5_wq_ctrl {
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 5722d88..1c0d5d0 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -463,6 +463,10 @@ struct mlx5_priv {
 	/* end: mr staff */
 
 	/* start: alloc staff */
+	/* protect buffer alocation according to numa node */
+	struct mutex            alloc_mutex;
+	int                     numa_node;
+
 	struct mutex            pgdir_mutex;
 	struct list_head        pgdir_list;
 	/* end: alloc staff */
@@ -672,6 +676,8 @@ void mlx5_health_cleanup(void);
 void  __init mlx5_health_init(void);
 void mlx5_start_health_poll(struct mlx5_core_dev *dev);
 void mlx5_stop_health_poll(struct mlx5_core_dev *dev);
+int mlx5_buf_alloc_node(struct mlx5_core_dev *dev, int size,
+			struct mlx5_buf *buf, int node);
 int mlx5_buf_alloc(struct mlx5_core_dev *dev, int size, struct mlx5_buf *buf);
 void mlx5_buf_free(struct mlx5_core_dev *dev, struct mlx5_buf *buf);
 struct mlx5_cmd_mailbox *mlx5_alloc_cmd_mailbox_chain(struct mlx5_core_dev *dev,
@@ -773,6 +779,8 @@ void mlx5_eq_debugfs_cleanup(struct mlx5_core_dev *dev);
 int mlx5_cq_debugfs_init(struct mlx5_core_dev *dev);
 void mlx5_cq_debugfs_cleanup(struct mlx5_core_dev *dev);
 int mlx5_db_alloc(struct mlx5_core_dev *dev, struct mlx5_db *db);
+int mlx5_db_alloc_node(struct mlx5_core_dev *dev, struct mlx5_db *db,
+		       int node);
 void mlx5_db_free(struct mlx5_core_dev *dev, struct mlx5_db *db);
 
 const char *mlx5_command_str(int command);
-- 
2.4.3.413.ga5fe668
