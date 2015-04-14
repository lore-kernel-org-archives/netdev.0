From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next V2 01/12] net/mlx5_core,mlx5_ib: Do not use vmap() on coherent memory
Date: Tue, 14 Apr 2015 11:20:24 +0300
Message-ID: <1428999635-15025-2-git-send-email-amirv@mellanox.com>
References: <1428999635-15025-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Tal Alon <talal@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	David Daney <david.daney@cavium.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:41922 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751664AbbDNIVT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Apr 2015 04:21:19 -0400
In-Reply-To: <1428999635-15025-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As David Daney pointed in mlx4_core driver [1], mlx5_core is also
misusing the DMA-API.

This patch is removing the code that vmap() memory allocated by
dma_alloc_coherent().

After this patch, users of this drivers might fail allocating resources
on memory fragmeneted systems.  This will be fixed later on.

[1] - https://patchwork.ozlabs.org/patch/458531/

CC: David Daney <david.daney@cavium.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/infiniband/hw/mlx5/cq.c                 |  3 +-
 drivers/infiniband/hw/mlx5/qp.c                 |  2 +-
 drivers/infiniband/hw/mlx5/srq.c                |  2 +-
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c | 96 +++++--------------------
 drivers/net/ethernet/mellanox/mlx5/core/eq.c    |  3 +-
 include/linux/mlx5/driver.h                     |  9 +--
 6 files changed, 22 insertions(+), 93 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/cq.c b/drivers/infiniband/hw/mlx5/cq.c
index 2ee6b10..4e88b18 100644
--- a/drivers/infiniband/hw/mlx5/cq.c
+++ b/drivers/infiniband/hw/mlx5/cq.c
@@ -590,8 +590,7 @@ static int alloc_cq_buf(struct mlx5_ib_dev *dev, struct mlx5_ib_cq_buf *buf,
 {
 	int err;
 
-	err = mlx5_buf_alloc(dev->mdev, nent * cqe_size,
-			     PAGE_SIZE * 2, &buf->buf);
+	err = mlx5_buf_alloc(dev->mdev, nent * cqe_size, &buf->buf);
 	if (err)
 		return err;
 
diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index 4d7024b..4709d7d 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -768,7 +768,7 @@ static int create_kernel_qp(struct mlx5_ib_dev *dev,
 	qp->sq.offset = qp->rq.wqe_cnt << qp->rq.wqe_shift;
 	qp->buf_size = err + (qp->rq.wqe_cnt << qp->rq.wqe_shift);
 
-	err = mlx5_buf_alloc(dev->mdev, qp->buf_size, PAGE_SIZE * 2, &qp->buf);
+	err = mlx5_buf_alloc(dev->mdev, qp->buf_size, &qp->buf);
 	if (err) {
 		mlx5_ib_dbg(dev, "err %d\n", err);
 		goto err_uuar;
diff --git a/drivers/infiniband/hw/mlx5/srq.c b/drivers/infiniband/hw/mlx5/srq.c
index 02d77a2..4242e1d 100644
--- a/drivers/infiniband/hw/mlx5/srq.c
+++ b/drivers/infiniband/hw/mlx5/srq.c
@@ -165,7 +165,7 @@ static int create_srq_kernel(struct mlx5_ib_dev *dev, struct mlx5_ib_srq *srq,
 		return err;
 	}
 
-	if (mlx5_buf_alloc(dev->mdev, buf_size, PAGE_SIZE * 2, &srq->buf)) {
+	if (mlx5_buf_alloc(dev->mdev, buf_size, &srq->buf)) {
 		mlx5_ib_dbg(dev, "buf alloc failed\n");
 		err = -ENOMEM;
 		goto err_db;
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
index ac0f7bf..0715b49 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
@@ -42,95 +42,36 @@
 #include "mlx5_core.h"
 
 /* Handling for queue buffers -- we allocate a bunch of memory and
- * register it in a memory region at HCA virtual address 0.  If the
- * requested size is > max_direct, we split the allocation into
- * multiple pages, so we don't require too much contiguous memory.
+ * register it in a memory region at HCA virtual address 0.
  */
 
-int mlx5_buf_alloc(struct mlx5_core_dev *dev, int size, int max_direct,
-		   struct mlx5_buf *buf)
+int mlx5_buf_alloc(struct mlx5_core_dev *dev, int size, struct mlx5_buf *buf)
 {
 	dma_addr_t t;
 
 	buf->size = size;
-	if (size <= max_direct) {
-		buf->nbufs        = 1;
-		buf->npages       = 1;
-		buf->page_shift   = (u8)get_order(size) + PAGE_SHIFT;
-		buf->direct.buf   = dma_zalloc_coherent(&dev->pdev->dev,
-							size, &t, GFP_KERNEL);
-		if (!buf->direct.buf)
-			return -ENOMEM;
-
-		buf->direct.map = t;
-
-		while (t & ((1 << buf->page_shift) - 1)) {
-			--buf->page_shift;
-			buf->npages *= 2;
-		}
-	} else {
-		int i;
-
-		buf->direct.buf  = NULL;
-		buf->nbufs       = (size + PAGE_SIZE - 1) / PAGE_SIZE;
-		buf->npages      = buf->nbufs;
-		buf->page_shift  = PAGE_SHIFT;
-		buf->page_list   = kcalloc(buf->nbufs, sizeof(*buf->page_list),
-					   GFP_KERNEL);
-		if (!buf->page_list)
-			return -ENOMEM;
-
-		for (i = 0; i < buf->nbufs; i++) {
-			buf->page_list[i].buf =
-				dma_zalloc_coherent(&dev->pdev->dev, PAGE_SIZE,
-						    &t, GFP_KERNEL);
-			if (!buf->page_list[i].buf)
-				goto err_free;
-
-			buf->page_list[i].map = t;
-		}
-
-		if (BITS_PER_LONG == 64) {
-			struct page **pages;
-			pages = kmalloc(sizeof(*pages) * buf->nbufs, GFP_KERNEL);
-			if (!pages)
-				goto err_free;
-			for (i = 0; i < buf->nbufs; i++)
-				pages[i] = virt_to_page(buf->page_list[i].buf);
-			buf->direct.buf = vmap(pages, buf->nbufs, VM_MAP, PAGE_KERNEL);
-			kfree(pages);
-			if (!buf->direct.buf)
-				goto err_free;
-		}
-	}
+	buf->npages       = 1;
+	buf->page_shift   = (u8)get_order(size) + PAGE_SHIFT;
+	buf->direct.buf   = dma_zalloc_coherent(&dev->pdev->dev,
+						size, &t, GFP_KERNEL);
+	if (!buf->direct.buf)
+		return -ENOMEM;
 
-	return 0;
+	buf->direct.map = t;
 
-err_free:
-	mlx5_buf_free(dev, buf);
+	while (t & ((1 << buf->page_shift) - 1)) {
+		--buf->page_shift;
+		buf->npages *= 2;
+	}
 
-	return -ENOMEM;
+	return 0;
 }
 EXPORT_SYMBOL_GPL(mlx5_buf_alloc);
 
 void mlx5_buf_free(struct mlx5_core_dev *dev, struct mlx5_buf *buf)
 {
-	int i;
-
-	if (buf->nbufs == 1)
-		dma_free_coherent(&dev->pdev->dev, buf->size, buf->direct.buf,
-				  buf->direct.map);
-	else {
-		if (BITS_PER_LONG == 64)
-			vunmap(buf->direct.buf);
-
-		for (i = 0; i < buf->nbufs; i++)
-			if (buf->page_list[i].buf)
-				dma_free_coherent(&dev->pdev->dev, PAGE_SIZE,
-						  buf->page_list[i].buf,
-						  buf->page_list[i].map);
-		kfree(buf->page_list);
-	}
+	dma_free_coherent(&dev->pdev->dev, buf->size, buf->direct.buf,
+			  buf->direct.map);
 }
 EXPORT_SYMBOL_GPL(mlx5_buf_free);
 
@@ -230,10 +171,7 @@ void mlx5_fill_page_array(struct mlx5_buf *buf, __be64 *pas)
 	int i;
 
 	for (i = 0; i < buf->npages; i++) {
-		if (buf->nbufs == 1)
-			addr = buf->direct.map + (i << buf->page_shift);
-		else
-			addr = buf->page_list[i].map;
+		addr = buf->direct.map + (i << buf->page_shift);
 
 		pas[i] = cpu_to_be64(addr);
 	}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index 58800e4..3f511bd 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -346,8 +346,7 @@ int mlx5_create_map_eq(struct mlx5_core_dev *dev, struct mlx5_eq *eq, u8 vecidx,
 	int inlen;
 
 	eq->nent = roundup_pow_of_two(nent + MLX5_NUM_SPARE_EQE);
-	err = mlx5_buf_alloc(dev, eq->nent * MLX5_EQE_SIZE, 2 * PAGE_SIZE,
-			     &eq->buf);
+	err = mlx5_buf_alloc(dev, eq->nent * MLX5_EQE_SIZE, &eq->buf);
 	if (err)
 		return err;
 
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 9a90e75..c4cf25f 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -334,8 +334,6 @@ struct mlx5_buf_list {
 
 struct mlx5_buf {
 	struct mlx5_buf_list	direct;
-	struct mlx5_buf_list   *page_list;
-	int			nbufs;
 	int			npages;
 	int			size;
 	u8			page_shift;
@@ -586,11 +584,7 @@ struct mlx5_pas {
 
 static inline void *mlx5_buf_offset(struct mlx5_buf *buf, int offset)
 {
-	if (likely(BITS_PER_LONG == 64 || buf->nbufs == 1))
 		return buf->direct.buf + offset;
-	else
-		return buf->page_list[offset >> PAGE_SHIFT].buf +
-			(offset & (PAGE_SIZE - 1));
 }
 
 extern struct workqueue_struct *mlx5_core_wq;
@@ -669,8 +663,7 @@ void mlx5_health_cleanup(void);
 void  __init mlx5_health_init(void);
 void mlx5_start_health_poll(struct mlx5_core_dev *dev);
 void mlx5_stop_health_poll(struct mlx5_core_dev *dev);
-int mlx5_buf_alloc(struct mlx5_core_dev *dev, int size, int max_direct,
-		   struct mlx5_buf *buf);
+int mlx5_buf_alloc(struct mlx5_core_dev *dev, int size, struct mlx5_buf *buf);
 void mlx5_buf_free(struct mlx5_core_dev *dev, struct mlx5_buf *buf);
 struct mlx5_cmd_mailbox *mlx5_alloc_cmd_mailbox_chain(struct mlx5_core_dev *dev,
 						      gfp_t flags, int npages);
-- 
1.9.3
