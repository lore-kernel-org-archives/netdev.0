From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH net-next 03/11] net/mlx5_core: Virtually extend work/completion queue buffers by one page
Date: Wed,  8 Apr 2015 17:51:17 +0300
Message-ID: <1428504685-8945-4-git-send-email-amirv@mellanox.com>
References: <1428504685-8945-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Vadai <amirv@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1327.ztomy.com ([193.47.165.129]:36574 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754076AbbDHOv5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 10:51:57 -0400
In-Reply-To: <1428504685-8945-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Achiad Shochat <achiad@mellanox.com>

- Direct buf allocation will be allocated via mlx5_buf_alloc_direct.
- Add and export mlx5_buf_alloc_pages to be used by mlx5_buf_alloc as before.
- Add virtual_extension parameter to be used to request to virtually extended
  buffer pages for cyclic usage, to avoid handling wqe wrap around the buffer.

Signed-off-by: Achiad Shochat <achiad@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx5/core/alloc.c | 126 ++++++++++++++----------
 include/linux/mlx5/driver.h                     |   2 +
 2 files changed, 76 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
index ac0f7bf..ffda222 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/alloc.c
@@ -47,70 +47,92 @@
  * multiple pages, so we don't require too much contiguous memory.
  */
 
-int mlx5_buf_alloc(struct mlx5_core_dev *dev, int size, int max_direct,
-		   struct mlx5_buf *buf)
+static int mlx5_buf_alloc_direct(struct mlx5_core_dev *dev, int size,
+				 struct mlx5_buf *buf)
 {
 	dma_addr_t t;
 
-	buf->size = size;
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
+	buf->size         = size;
+	buf->nbufs        = 1;
+	buf->npages       = 1;
+	buf->page_shift   = (u8)get_order(size) + PAGE_SHIFT;
+	buf->direct.buf   = dma_zalloc_coherent(&dev->pdev->dev,
+						size, &t, GFP_KERNEL);
+	if (!buf->direct.buf)
+		return -ENOMEM;
+
+	buf->direct.map = t;
+
+	while (t & ((1 << buf->page_shift) - 1)) {
+		--buf->page_shift;
+		buf->npages *= 2;
 	}
 
 	return 0;
+}
+
+int mlx5_buf_alloc_pages(struct mlx5_core_dev *dev, int size,
+			 int virtual_extension, struct mlx5_buf *buf)
+{
+	dma_addr_t t;
+	int i;
+
+	buf->size        = size;
+	buf->direct.buf  = NULL;
+	buf->nbufs       = (size + PAGE_SIZE - 1) / PAGE_SIZE;
+	buf->npages      = buf->nbufs;
+	buf->page_shift  = PAGE_SHIFT;
+	buf->page_list   = kcalloc(buf->nbufs, sizeof(*buf->page_list),
+				   GFP_KERNEL);
+	if (!buf->page_list)
+		return -ENOMEM;
+
+	for (i = 0; i < buf->nbufs; i++) {
+		buf->page_list[i].buf =
+			dma_zalloc_coherent(&dev->pdev->dev, PAGE_SIZE,
+					    &t, GFP_KERNEL);
+		if (!buf->page_list[i].buf)
+			goto err_free;
+
+		buf->page_list[i].map = t;
+	}
+
+	if (BITS_PER_LONG == 64) {
+		struct page **pages;
+		int npages = buf->nbufs + (virtual_extension ? 1 : 0);
+
+		pages = kcalloc(npages, sizeof(*pages), GFP_KERNEL);
+		if (!pages)
+			goto err_free;
+
+		for (i = 0; i < buf->nbufs; i++)
+			pages[i] = virt_to_page(buf->page_list[i].buf);
+
+		if (virtual_extension)
+			pages[buf->nbufs] = pages[0];
+
+		buf->direct.buf = vmap(pages, npages, VM_MAP, PAGE_KERNEL);
+		kfree(pages);
+		if (!buf->direct.buf)
+			goto err_free;
+	}
+	return 0;
 
 err_free:
 	mlx5_buf_free(dev, buf);
 
 	return -ENOMEM;
 }
+EXPORT_SYMBOL_GPL(mlx5_buf_alloc_pages);
+
+int mlx5_buf_alloc(struct mlx5_core_dev *dev, int size, int max_direct,
+		   struct mlx5_buf *buf)
+{
+	if (size <= max_direct)
+		return mlx5_buf_alloc_direct(dev, size, buf);
+
+	return mlx5_buf_alloc_pages(dev, size, 0, buf);
+}
 EXPORT_SYMBOL_GPL(mlx5_buf_alloc);
 
 void mlx5_buf_free(struct mlx5_core_dev *dev, struct mlx5_buf *buf)
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index fc45233..0c93745 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -676,6 +676,8 @@ void mlx5_start_health_poll(struct mlx5_core_dev *dev);
 void mlx5_stop_health_poll(struct mlx5_core_dev *dev);
 int mlx5_buf_alloc(struct mlx5_core_dev *dev, int size, int max_direct,
 		   struct mlx5_buf *buf);
+int mlx5_buf_alloc_pages(struct mlx5_core_dev *dev, int size,
+			 int virtual_extension, struct mlx5_buf *buf);
 void mlx5_buf_free(struct mlx5_core_dev *dev, struct mlx5_buf *buf);
 struct mlx5_cmd_mailbox *mlx5_alloc_cmd_mailbox_chain(struct mlx5_core_dev *dev,
 						      gfp_t flags, int npages);
-- 
1.9.3
