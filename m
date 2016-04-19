From: Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Subject: Re: [PATCH V2] net: ethernet: mellanox: correct page conversion
Date: Tue, 19 Apr 2016 11:22:12 -0700
Message-ID: <20160419182212.GA8441@infradead.org>
References: <1460845412-13120-1-git-send-email-okaya@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Sinan Kaya <okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1460845412-13120-1-git-send-email-okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

What I think we need is something like the patch below.  In the long
ru nwe should also kill the mlx4_buf structure which now is pretty
pointless.

---
>From a493881d2a6c90152d3daabb7b6b3afd1d254d78 Mon Sep 17 00:00:00 2001
From: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Date: Tue, 19 Apr 2016 14:12:14 -0400
Subject: mlx4_en: don't try to split and vmap dma coherent allocations

The memory returned by dma_alloc_coherent is not suitable for calling
virt_to_page on it, as it might for example come from vmap allocator.

Remove the code that calls virt_to_page and vmap on dma coherent
allocations from the mlx4 drivers, and replace them with a single
high-order dma_alloc_coherent call.

Signed-off-by: Christoph Hellwig <hch-jcswGhMUV9g@public.gmane.org>
Reported-by: Sinan Kaya <okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
---
 drivers/net/ethernet/mellanox/mlx4/alloc.c        | 89 ++++-------------------
 drivers/net/ethernet/mellanox/mlx4/en_cq.c        |  7 --
 drivers/net/ethernet/mellanox/mlx4/en_resources.c | 31 --------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c        |  8 --
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        |  9 ---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |  2 -
 drivers/net/ethernet/mellanox/mlx4/mr.c           |  5 +-
 include/linux/mlx4/device.h                       |  8 +-
 8 files changed, 16 insertions(+), 143 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/alloc.c b/drivers/net/ethernet/mellanox/mlx4/alloc.c
index 0c51c69..8d15b35 100644
--- a/drivers/net/ethernet/mellanox/mlx4/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx4/alloc.c
@@ -588,91 +588,30 @@ int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
 {
 	dma_addr_t t;
 
-	if (size <= max_direct) {
-		buf->nbufs        = 1;
-		buf->npages       = 1;
-		buf->page_shift   = get_order(size) + PAGE_SHIFT;
-		buf->direct.buf   = dma_alloc_coherent(&dev->persist->pdev->dev,
-						       size, &t, gfp);
-		if (!buf->direct.buf)
-			return -ENOMEM;
-
-		buf->direct.map = t;
-
-		while (t & ((1 << buf->page_shift) - 1)) {
-			--buf->page_shift;
-			buf->npages *= 2;
-		}
+	buf->npages       = 1;
+	buf->page_shift   = get_order(size) + PAGE_SHIFT;
+	buf->direct.buf   = dma_alloc_coherent(&dev->persist->pdev->dev,
+					       size, &t, gfp);
+	if (!buf->direct.buf)
+		return -ENOMEM;
 
-		memset(buf->direct.buf, 0, size);
-	} else {
-		int i;
-
-		buf->direct.buf  = NULL;
-		buf->nbufs       = (size + PAGE_SIZE - 1) / PAGE_SIZE;
-		buf->npages      = buf->nbufs;
-		buf->page_shift  = PAGE_SHIFT;
-		buf->page_list   = kcalloc(buf->nbufs, sizeof(*buf->page_list),
-					   gfp);
-		if (!buf->page_list)
-			return -ENOMEM;
-
-		for (i = 0; i < buf->nbufs; ++i) {
-			buf->page_list[i].buf =
-				dma_alloc_coherent(&dev->persist->pdev->dev,
-						   PAGE_SIZE,
-						   &t, gfp);
-			if (!buf->page_list[i].buf)
-				goto err_free;
-
-			buf->page_list[i].map = t;
-
-			memset(buf->page_list[i].buf, 0, PAGE_SIZE);
-		}
+	buf->direct.map = t;
 
-		if (BITS_PER_LONG == 64) {
-			struct page **pages;
-			pages = kmalloc(sizeof *pages * buf->nbufs, gfp);
-			if (!pages)
-				goto err_free;
-			for (i = 0; i < buf->nbufs; ++i)
-				pages[i] = virt_to_page(buf->page_list[i].buf);
-			buf->direct.buf = vmap(pages, buf->nbufs, VM_MAP, PAGE_KERNEL);
-			kfree(pages);
-			if (!buf->direct.buf)
-				goto err_free;
-		}
+	while (t & ((1 << buf->page_shift) - 1)) {
+		--buf->page_shift;
+		buf->npages *= 2;
 	}
 
+	memset(buf->direct.buf, 0, size);
 	return 0;
-
-err_free:
-	mlx4_buf_free(dev, size, buf);
-
-	return -ENOMEM;
 }
 EXPORT_SYMBOL_GPL(mlx4_buf_alloc);
 
 void mlx4_buf_free(struct mlx4_dev *dev, int size, struct mlx4_buf *buf)
 {
-	int i;
-
-	if (buf->nbufs == 1)
-		dma_free_coherent(&dev->persist->pdev->dev, size,
-				  buf->direct.buf,
-				  buf->direct.map);
-	else {
-		if (BITS_PER_LONG == 64)
-			vunmap(buf->direct.buf);
-
-		for (i = 0; i < buf->nbufs; ++i)
-			if (buf->page_list[i].buf)
-				dma_free_coherent(&dev->persist->pdev->dev,
-						  PAGE_SIZE,
-						  buf->page_list[i].buf,
-						  buf->page_list[i].map);
-		kfree(buf->page_list);
-	}
+	dma_free_coherent(&dev->persist->pdev->dev, size,
+			  buf->direct.buf,
+			  buf->direct.map);
 }
 EXPORT_SYMBOL_GPL(mlx4_buf_free);
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index af975a2..16ef8cf 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -78,17 +78,11 @@ int mlx4_en_create_cq(struct mlx4_en_priv *priv,
 	if (err)
 		goto err_cq;
 
-	err = mlx4_en_map_buffer(&cq->wqres.buf);
-	if (err)
-		goto err_res;
-
 	cq->buf = (struct mlx4_cqe *)cq->wqres.buf.direct.buf;
 	*pcq = cq;
 
 	return 0;
 
-err_res:
-	mlx4_free_hwq_res(mdev->dev, &cq->wqres, cq->buf_size);
 err_cq:
 	kfree(cq);
 	*pcq = NULL;
@@ -177,7 +171,6 @@ void mlx4_en_destroy_cq(struct mlx4_en_priv *priv, struct mlx4_en_cq **pcq)
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_cq *cq = *pcq;
 
-	mlx4_en_unmap_buffer(&cq->wqres.buf);
 	mlx4_free_hwq_res(mdev->dev, &cq->wqres, cq->buf_size);
 	if (mlx4_is_eq_vector_valid(mdev->dev, priv->port, cq->vector) &&
 	    cq->is_tx == RX)
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_resources.c b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
index 02e925d..a6b0db0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_resources.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_resources.c
@@ -107,37 +107,6 @@ int mlx4_en_change_mcast_lb(struct mlx4_en_priv *priv, struct mlx4_qp *qp,
 	return ret;
 }
 
-int mlx4_en_map_buffer(struct mlx4_buf *buf)
-{
-	struct page **pages;
-	int i;
-
-	if (BITS_PER_LONG == 64 || buf->nbufs == 1)
-		return 0;
-
-	pages = kmalloc(sizeof *pages * buf->nbufs, GFP_KERNEL);
-	if (!pages)
-		return -ENOMEM;
-
-	for (i = 0; i < buf->nbufs; ++i)
-		pages[i] = virt_to_page(buf->page_list[i].buf);
-
-	buf->direct.buf = vmap(pages, buf->nbufs, VM_MAP, PAGE_KERNEL);
-	kfree(pages);
-	if (!buf->direct.buf)
-		return -ENOMEM;
-
-	return 0;
-}
-
-void mlx4_en_unmap_buffer(struct mlx4_buf *buf)
-{
-	if (BITS_PER_LONG == 64 || buf->nbufs == 1)
-		return;
-
-	vunmap(buf->direct.buf);
-}
-
 void mlx4_en_sqp_event(struct mlx4_qp *qp, enum mlx4_event event)
 {
     return;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
index 86bcfe5..bc6c14a 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -396,11 +396,6 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 	if (err)
 		goto err_info;
 
-	err = mlx4_en_map_buffer(&ring->wqres.buf);
-	if (err) {
-		en_err(priv, "Failed to map RX buffer\n");
-		goto err_hwq;
-	}
 	ring->buf = ring->wqres.buf.direct.buf;
 
 	ring->hwtstamp_rx_filter = priv->hwtstamp_config.rx_filter;
@@ -408,8 +403,6 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 	*pring = ring;
 	return 0;
 
-err_hwq:
-	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
 err_info:
 	vfree(ring->rx_info);
 	ring->rx_info = NULL;
@@ -513,7 +506,6 @@ void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_rx_ring *ring = *pring;
 
-	mlx4_en_unmap_buffer(&ring->wqres.buf);
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, size * stride + TXBB_SIZE);
 	vfree(ring->rx_info);
 	ring->rx_info = NULL;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index c0d7b72..3c6b59c 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -101,12 +101,6 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 		goto err_bounce;
 	}
 
-	err = mlx4_en_map_buffer(&ring->wqres.buf);
-	if (err) {
-		en_err(priv, "Failed to map TX buffer\n");
-		goto err_hwq_res;
-	}
-
 	ring->buf = ring->wqres.buf.direct.buf;
 
 	en_dbg(DRV, priv, "Allocated TX ring (addr:%p) - buf:%p size:%d buf_size:%d dma:%llx\n",
@@ -155,8 +149,6 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 err_reserve:
 	mlx4_qp_release_range(mdev->dev, ring->qpn, 1);
 err_map:
-	mlx4_en_unmap_buffer(&ring->wqres.buf);
-err_hwq_res:
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
 err_bounce:
 	kfree(ring->bounce_buf);
@@ -182,7 +174,6 @@ void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
 	mlx4_qp_remove(mdev->dev, &ring->qp);
 	mlx4_qp_free(mdev->dev, &ring->qp);
 	mlx4_qp_release_range(priv->mdev->dev, ring->qpn, 1);
-	mlx4_en_unmap_buffer(&ring->wqres.buf);
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
 	kfree(ring->bounce_buf);
 	ring->bounce_buf = NULL;
diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index d12ab6a..a70e2d0 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -671,8 +671,6 @@ void mlx4_en_fill_qp_context(struct mlx4_en_priv *priv, int size, int stride,
 		int is_tx, int rss, int qpn, int cqn, int user_prio,
 		struct mlx4_qp_context *context);
 void mlx4_en_sqp_event(struct mlx4_qp *qp, enum mlx4_event event);
-int mlx4_en_map_buffer(struct mlx4_buf *buf);
-void mlx4_en_unmap_buffer(struct mlx4_buf *buf);
 int mlx4_en_change_mcast_lb(struct mlx4_en_priv *priv, struct mlx4_qp *qp,
 			    int loopback);
 void mlx4_en_calc_rx_buf(struct net_device *dev);
diff --git a/drivers/net/ethernet/mellanox/mlx4/mr.c b/drivers/net/ethernet/mellanox/mlx4/mr.c
index 9319519..b61052f 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mr.c
+++ b/drivers/net/ethernet/mellanox/mlx4/mr.c
@@ -802,10 +802,7 @@ int mlx4_buf_write_mtt(struct mlx4_dev *dev, struct mlx4_mtt *mtt,
 		return -ENOMEM;
 
 	for (i = 0; i < buf->npages; ++i)
-		if (buf->nbufs == 1)
-			page_list[i] = buf->direct.map + (i << buf->page_shift);
-		else
-			page_list[i] = buf->page_list[i].map;
+		page_list[i] = buf->direct.map + (i << buf->page_shift);
 
 	err = mlx4_write_mtt(dev, mtt, 0, buf->npages, page_list);
 
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 8541a91..536b547 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -618,8 +618,6 @@ struct mlx4_buf_list {
 
 struct mlx4_buf {
 	struct mlx4_buf_list	direct;
-	struct mlx4_buf_list   *page_list;
-	int			nbufs;
 	int			npages;
 	int			page_shift;
 };
@@ -1051,11 +1049,7 @@ int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
 void mlx4_buf_free(struct mlx4_dev *dev, int size, struct mlx4_buf *buf);
 static inline void *mlx4_buf_offset(struct mlx4_buf *buf, int offset)
 {
-	if (BITS_PER_LONG == 64 || buf->nbufs == 1)
-		return buf->direct.buf + offset;
-	else
-		return buf->page_list[offset >> PAGE_SHIFT].buf +
-			(offset & (PAGE_SIZE - 1));
+	return buf->direct.buf + offset;
 }
 
 int mlx4_pd_alloc(struct mlx4_dev *dev, u32 *pdn);
-- 
2.1.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
