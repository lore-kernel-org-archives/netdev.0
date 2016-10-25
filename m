From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net 01/12] {net, ib}/mlx5: Make cache line size determination at runtime.
Date: Tue, 25 Oct 2016 18:36:24 +0300
Message-ID: <1477409795-28807-2-git-send-email-saeedm@mellanox.com>
References: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Leon Romanovsky <leonro@mellanox.com>,
        Daniel Jurgens <danielj@mellanox.com>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:40899 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754608AbcJYPiU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Oct 2016 11:38:20 -0400
In-Reply-To: <1477409795-28807-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Jurgens <danielj@mellanox.com>

ARM 64B cache line systems have L1_CACHE_BYTES set to 128.
cache_line_size() will return the correct size.

Fixes: cf50b5efa2fe('net/mlx5_core/ib: New device capabilities
handling.')
Signed-off-by: Daniel Jurgens <danielj@mellanox.com>

Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/main.c               |  2 +-
 drivers/infiniband/hw/mlx5/qp.c                 |  1 -
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c | 31 +++++++++++++++++++++----
 include/linux/mlx5/driver.h                     | 11 ---------
 4 files changed, 27 insertions(+), 18 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 2217477..63036c7 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1019,7 +1019,7 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	resp.qp_tab_size = 1 << MLX5_CAP_GEN(dev->mdev, log_max_qp);
 	if (mlx5_core_is_pf(dev->mdev) && MLX5_CAP_GEN(dev->mdev, bf))
 		resp.bf_reg_size = 1 << MLX5_CAP_GEN(dev->mdev, log_bf_reg_size);
-	resp.cache_line_size = L1_CACHE_BYTES;
+	resp.cache_line_size = cache_line_size();
 	resp.max_sq_desc_sz = MLX5_CAP_GEN(dev->mdev, max_wqe_sz_sq);
 	resp.max_rq_desc_sz = MLX5_CAP_GEN(dev->mdev, max_wqe_sz_rq);
 	resp.max_send_wqebb = 1 << MLX5_CAP_GEN(dev->mdev, log_max_qp_sz);
diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index 41f4c2a..7ce97da 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -52,7 +52,6 @@ enum {
 
 enum {
 	MLX5_IB_SQ_STRIDE	= 6,
-	MLX5_IB_CACHE_LINE_SIZE	= 64,
 };
 
 static const u32 mlx5_ib_opcode[] = {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
index 6cb3830..2c6e3c7 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
@@ -41,6 +41,13 @@
 
 #include "mlx5_core.h"
 
+struct mlx5_db_pgdir {
+	struct list_head	list;
+	unsigned long	       *bitmap;
+	__be32		       *db_page;
+	dma_addr_t		db_dma;
+};
+
 /* Handling for queue buffers -- we allocate a bunch of memory and
  * register it in a memory region at HCA virtual address 0.
  */
@@ -102,17 +109,28 @@ EXPORT_SYMBOL_GPL(mlx5_buf_free);
 static struct mlx5_db_pgdir *mlx5_alloc_db_pgdir(struct mlx5_core_dev *dev,
 						 int node)
 {
+	u32 db_per_page = PAGE_SIZE / cache_line_size();
 	struct mlx5_db_pgdir *pgdir;
 
 	pgdir = kzalloc(sizeof(*pgdir), GFP_KERNEL);
 	if (!pgdir)
 		return NULL;
 
-	bitmap_fill(pgdir->bitmap, MLX5_DB_PER_PAGE);
+	pgdir->bitmap = kcalloc(BITS_TO_LONGS(db_per_page),
+				sizeof(unsigned long),
+				GFP_KERNEL);
+
+	if (!pgdir->bitmap) {
+		kfree(pgdir);
+		return NULL;
+	}
+
+	bitmap_fill(pgdir->bitmap, db_per_page);
 
 	pgdir->db_page = mlx5_dma_zalloc_coherent_node(dev, PAGE_SIZE,
 						       &pgdir->db_dma, node);
 	if (!pgdir->db_page) {
+		kfree(pgdir->bitmap);
 		kfree(pgdir);
 		return NULL;
 	}
@@ -123,18 +141,19 @@ static struct mlx5_db_pgdir *mlx5_alloc_db_pgdir(struct mlx5_core_dev *dev,
 static int mlx5_alloc_db_from_pgdir(struct mlx5_db_pgdir *pgdir,
 				    struct mlx5_db *db)
 {
+	u32 db_per_page = PAGE_SIZE / cache_line_size();
 	int offset;
 	int i;
 
-	i = find_first_bit(pgdir->bitmap, MLX5_DB_PER_PAGE);
-	if (i >= MLX5_DB_PER_PAGE)
+	i = find_first_bit(pgdir->bitmap, db_per_page);
+	if (i >= db_per_page)
 		return -ENOMEM;
 
 	__clear_bit(i, pgdir->bitmap);
 
 	db->u.pgdir = pgdir;
 	db->index   = i;
-	offset = db->index * L1_CACHE_BYTES;
+	offset = db->index * cache_line_size();
 	db->db      = pgdir->db_page + offset / sizeof(*pgdir->db_page);
 	db->dma     = pgdir->db_dma  + offset;
 
@@ -181,14 +200,16 @@ EXPORT_SYMBOL_GPL(mlx5_db_alloc);
 
 void mlx5_db_free(struct mlx5_core_dev *dev, struct mlx5_db *db)
 {
+	u32 db_per_page = PAGE_SIZE / cache_line_size();
 	mutex_lock(&dev->priv.pgdir_mutex);
 
 	__set_bit(db->index, db->u.pgdir->bitmap);
 
-	if (bitmap_full(db->u.pgdir->bitmap, MLX5_DB_PER_PAGE)) {
+	if (bitmap_full(db->u.pgdir->bitmap, db_per_page)) {
 		dma_free_coherent(&(dev->pdev->dev), PAGE_SIZE,
 				  db->u.pgdir->db_page, db->u.pgdir->db_dma);
 		list_del(&db->u.pgdir->list);
+		kfree(db->u.pgdir->bitmap);
 		kfree(db->u.pgdir);
 	}
 
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 85c4786..5dbda60 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -626,10 +626,6 @@ struct mlx5_db {
 };
 
 enum {
-	MLX5_DB_PER_PAGE = PAGE_SIZE / L1_CACHE_BYTES,
-};
-
-enum {
 	MLX5_COMP_EQ_SIZE = 1024,
 };
 
@@ -638,13 +634,6 @@ enum {
 	MLX5_PTYS_EN = 1 << 2,
 };
 
-struct mlx5_db_pgdir {
-	struct list_head	list;
-	DECLARE_BITMAP(bitmap, MLX5_DB_PER_PAGE);
-	__be32		       *db_page;
-	dma_addr_t		db_dma;
-};
-
 typedef void (*mlx5_cmd_cbk_t)(int status, void *context);
 
 struct mlx5_cmd_work_ent {
-- 
2.7.4
