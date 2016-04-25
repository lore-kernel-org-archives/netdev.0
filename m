From: Haggai Abramovsky <hagaya-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH net] net/mlx4: Avoid wrong virtual mappings
Date: Mon, 25 Apr 2016 16:34:47 +0300
Message-ID: <1461591287-11595-1-git-send-email-hagaya@mellanox.com>
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Sinan Kaya <okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Eran Ben Elisha <eranbe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Tal Alon <talal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Haggai Abramovsky <hagaya-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The dma_alloc_coherent() function returns a virtual address which can
be used for coherent access to the underlying memory.  On some
architectures, like arm64, undefined behavior results if this memory is
also accessed via virtual mappings that are not coherent.  Because of
their undefined nature, operations like virt_to_page() return garbage
when passed virtual addresses obtained from dma_alloc_coherent().  Any
subsequent mappings via vmap() of the garbage page values are unusable
and result in bad things like bus errors (synchronous aborts in ARM64
speak).

The mlx4 driver contains code that does the equivalent of:
vmap(virt_to_page(dma_alloc_coherent)), this results in an OOPs when the
device is opened.

Prevent Ethernet driver to run this problematic code by forcing it to
allocate contiguous memory. As for the Infiniband driver, at first we
are trying to allocate contiguous memory, but in case of failure roll
back to work with fragmented memory.

Signed-off-by: Haggai Abramovsky <hagaya-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Yishai Hadas <yishaih-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reported-by: David Daney <david.daney-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Tested-by: Sinan Kaya <okaya-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
---
 drivers/infiniband/hw/mlx4/qp.c                   | 26 ++++++--
 drivers/net/ethernet/mellanox/mlx4/alloc.c        | 75 ++++++++++-------------
 drivers/net/ethernet/mellanox/mlx4/en_cq.c        |  9 +--
 drivers/net/ethernet/mellanox/mlx4/en_netdev.c    |  2 +-
 drivers/net/ethernet/mellanox/mlx4/en_resources.c | 31 ----------
 drivers/net/ethernet/mellanox/mlx4/en_rx.c        | 11 +---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c        | 14 +----
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h      |  2 -
 include/linux/mlx4/device.h                       |  4 +-
 9 files changed, 58 insertions(+), 116 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/qp.c b/drivers/infiniband/hw/mlx4/qp.c
index fd97534..842a6da 100644
--- a/drivers/infiniband/hw/mlx4/qp.c
+++ b/drivers/infiniband/hw/mlx4/qp.c
@@ -419,7 +419,8 @@ static int set_rq_size(struct mlx4_ib_dev *dev, struct ib_qp_cap *cap,
 }
 
 static int set_kernel_sq_size(struct mlx4_ib_dev *dev, struct ib_qp_cap *cap,
-			      enum mlx4_ib_qp_type type, struct mlx4_ib_qp *qp)
+			      enum mlx4_ib_qp_type type, struct mlx4_ib_qp *qp,
+			      int shrink_wqe)
 {
 	int s;
 
@@ -477,7 +478,7 @@ static int set_kernel_sq_size(struct mlx4_ib_dev *dev, struct ib_qp_cap *cap,
 	 * We set WQE size to at least 64 bytes, this way stamping
 	 * invalidates each WQE.
 	 */
-	if (dev->dev->caps.fw_ver >= MLX4_FW_VER_WQE_CTRL_NEC &&
+	if (shrink_wqe && dev->dev->caps.fw_ver >= MLX4_FW_VER_WQE_CTRL_NEC &&
 	    qp->sq_signal_bits && BITS_PER_LONG == 64 &&
 	    type != MLX4_IB_QPT_SMI && type != MLX4_IB_QPT_GSI &&
 	    !(type & (MLX4_IB_QPT_PROXY_SMI_OWNER | MLX4_IB_QPT_PROXY_SMI |
@@ -642,6 +643,7 @@ static int create_qp_common(struct mlx4_ib_dev *dev, struct ib_pd *pd,
 {
 	int qpn;
 	int err;
+	struct ib_qp_cap backup_cap;
 	struct mlx4_ib_sqp *sqp;
 	struct mlx4_ib_qp *qp;
 	enum mlx4_ib_qp_type qp_type = (enum mlx4_ib_qp_type) init_attr->qp_type;
@@ -775,7 +777,8 @@ static int create_qp_common(struct mlx4_ib_dev *dev, struct ib_pd *pd,
 				goto err;
 		}
 
-		err = set_kernel_sq_size(dev, &init_attr->cap, qp_type, qp);
+		memcpy(&backup_cap, &init_attr->cap, sizeof(backup_cap));
+		err = set_kernel_sq_size(dev, &init_attr->cap, qp_type, qp, 1);
 		if (err)
 			goto err;
 
@@ -787,9 +790,20 @@ static int create_qp_common(struct mlx4_ib_dev *dev, struct ib_pd *pd,
 			*qp->db.db = 0;
 		}
 
-		if (mlx4_buf_alloc(dev->dev, qp->buf_size, PAGE_SIZE * 2, &qp->buf, gfp)) {
-			err = -ENOMEM;
-			goto err_db;
+		if (mlx4_buf_alloc(dev->dev, qp->buf_size, qp->buf_size,
+				   &qp->buf, gfp)) {
+			memcpy(&init_attr->cap, &backup_cap,
+			       sizeof(backup_cap));
+			err = set_kernel_sq_size(dev, &init_attr->cap, qp_type,
+						 qp, 0);
+			if (err)
+				goto err_db;
+
+			if (mlx4_buf_alloc(dev->dev, qp->buf_size,
+					   PAGE_SIZE * 2, &qp->buf, gfp)) {
+				err = -ENOMEM;
+				goto err_db;
+			}
 		}
 
 		err = mlx4_mtt_init(dev->dev, qp->buf.npages, qp->buf.page_shift,
diff --git a/drivers/net/ethernet/mellanox/mlx4/alloc.c b/drivers/net/ethernet/mellanox/mlx4/alloc.c
index 0c51c69..c0bac5e 100644
--- a/drivers/net/ethernet/mellanox/mlx4/alloc.c
+++ b/drivers/net/ethernet/mellanox/mlx4/alloc.c
@@ -576,24 +576,18 @@ out:
 
 	return res;
 }
-/*
- * Handling for queue buffers -- we allocate a bunch of memory and
- * register it in a memory region at HCA virtual address 0.  If the
- * requested size is > max_direct, we split the allocation into
- * multiple pages, so we don't require too much contiguous memory.
- */
 
-int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
-		   struct mlx4_buf *buf, gfp_t gfp)
+static int mlx4_buf_direct_alloc(struct mlx4_dev *dev, int size,
+				 struct mlx4_buf *buf, gfp_t gfp)
 {
-	dma_addr_t t;
+		dma_addr_t t;
 
-	if (size <= max_direct) {
 		buf->nbufs        = 1;
 		buf->npages       = 1;
 		buf->page_shift   = get_order(size) + PAGE_SHIFT;
-		buf->direct.buf   = dma_alloc_coherent(&dev->persist->pdev->dev,
-						       size, &t, gfp);
+		buf->direct.buf   =
+			dma_zalloc_coherent(&dev->persist->pdev->dev,
+					    size, &t, gfp);
 		if (!buf->direct.buf)
 			return -ENOMEM;
 
@@ -604,13 +598,26 @@ int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
 			buf->npages *= 2;
 		}
 
-		memset(buf->direct.buf, 0, size);
+		return 0;
+}
+
+/* Handling for queue buffers -- we allocate a bunch of memory and
+ * register it in a memory region at HCA virtual address 0. If the
+ *  requested size is > max_direct, we split the allocation into
+ *  multiple pages, so we don't require too much contiguous memory.
+ */
+int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
+		   struct mlx4_buf *buf, gfp_t gfp)
+{
+	if (size <= max_direct) {
+		return mlx4_buf_direct_alloc(dev, size, buf, gfp);
 	} else {
+		dma_addr_t t;
 		int i;
 
-		buf->direct.buf  = NULL;
-		buf->nbufs       = (size + PAGE_SIZE - 1) / PAGE_SIZE;
-		buf->npages      = buf->nbufs;
+		buf->direct.buf = NULL;
+		buf->nbufs	= (size + PAGE_SIZE - 1) / PAGE_SIZE;
+		buf->npages	= buf->nbufs;
 		buf->page_shift  = PAGE_SHIFT;
 		buf->page_list   = kcalloc(buf->nbufs, sizeof(*buf->page_list),
 					   gfp);
@@ -619,28 +626,12 @@ int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
 
 		for (i = 0; i < buf->nbufs; ++i) {
 			buf->page_list[i].buf =
-				dma_alloc_coherent(&dev->persist->pdev->dev,
-						   PAGE_SIZE,
-						   &t, gfp);
+				dma_zalloc_coherent(&dev->persist->pdev->dev,
+						    PAGE_SIZE, &t, gfp);
 			if (!buf->page_list[i].buf)
 				goto err_free;
 
 			buf->page_list[i].map = t;
-
-			memset(buf->page_list[i].buf, 0, PAGE_SIZE);
-		}
-
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
 		}
 	}
 
@@ -655,15 +646,11 @@ EXPORT_SYMBOL_GPL(mlx4_buf_alloc);
 
 void mlx4_buf_free(struct mlx4_dev *dev, int size, struct mlx4_buf *buf)
 {
-	int i;
-
-	if (buf->nbufs == 1)
+	if (buf->nbufs == 1) {
 		dma_free_coherent(&dev->persist->pdev->dev, size,
-				  buf->direct.buf,
-				  buf->direct.map);
-	else {
-		if (BITS_PER_LONG == 64)
-			vunmap(buf->direct.buf);
+				  buf->direct.buf, buf->direct.map);
+	} else {
+		int i;
 
 		for (i = 0; i < buf->nbufs; ++i)
 			if (buf->page_list[i].buf)
@@ -789,7 +776,7 @@ void mlx4_db_free(struct mlx4_dev *dev, struct mlx4_db *db)
 EXPORT_SYMBOL_GPL(mlx4_db_free);
 
 int mlx4_alloc_hwq_res(struct mlx4_dev *dev, struct mlx4_hwq_resources *wqres,
-		       int size, int max_direct)
+		       int size)
 {
 	int err;
 
@@ -799,7 +786,7 @@ int mlx4_alloc_hwq_res(struct mlx4_dev *dev, struct mlx4_hwq_resources *wqres,
 
 	*wqres->db.db = 0;
 
-	err = mlx4_buf_alloc(dev, size, max_direct, &wqres->buf, GFP_KERNEL);
+	err = mlx4_buf_direct_alloc(dev, size, &wqres->buf, GFP_KERNEL);
 	if (err)
 		goto err_db;
 
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_cq.c b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
index af975a2..132cea6 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_cq.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_cq.c
@@ -73,22 +73,16 @@ int mlx4_en_create_cq(struct mlx4_en_priv *priv,
 	 */
 	set_dev_node(&mdev->dev->persist->pdev->dev, node);
 	err = mlx4_alloc_hwq_res(mdev->dev, &cq->wqres,
-				cq->buf_size, 2 * PAGE_SIZE);
+				cq->buf_size);
 	set_dev_node(&mdev->dev->persist->pdev->dev, mdev->dev->numa_node);
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
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
index b4b258c..5b19178 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
@@ -2907,7 +2907,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev, int port,
 
 	/* Allocate page for receive rings */
 	err = mlx4_alloc_hwq_res(mdev->dev, &priv->res,
-				MLX4_EN_PAGE_SIZE, MLX4_EN_PAGE_SIZE);
+				MLX4_EN_PAGE_SIZE);
 	if (err) {
 		en_err(priv, "Failed to allocate page for rx qps\n");
 		goto out;
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
index 7d25bc9..89775bb 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
@@ -394,17 +394,11 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 
 	/* Allocate HW buffers on provided NUMA node */
 	set_dev_node(&mdev->dev->persist->pdev->dev, node);
-	err = mlx4_alloc_hwq_res(mdev->dev, &ring->wqres,
-				 ring->buf_size, 2 * PAGE_SIZE);
+	err = mlx4_alloc_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
 	set_dev_node(&mdev->dev->persist->pdev->dev, mdev->dev->numa_node);
 	if (err)
 		goto err_info;
 
-	err = mlx4_en_map_buffer(&ring->wqres.buf);
-	if (err) {
-		en_err(priv, "Failed to map RX buffer\n");
-		goto err_hwq;
-	}
 	ring->buf = ring->wqres.buf.direct.buf;
 
 	ring->hwtstamp_rx_filter = priv->hwtstamp_config.rx_filter;
@@ -412,8 +406,6 @@ int mlx4_en_create_rx_ring(struct mlx4_en_priv *priv,
 	*pring = ring;
 	return 0;
 
-err_hwq:
-	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
 err_info:
 	vfree(ring->rx_info);
 	ring->rx_info = NULL;
@@ -517,7 +509,6 @@ void mlx4_en_destroy_rx_ring(struct mlx4_en_priv *priv,
 	struct mlx4_en_dev *mdev = priv->mdev;
 	struct mlx4_en_rx_ring *ring = *pring;
 
-	mlx4_en_unmap_buffer(&ring->wqres.buf);
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, size * stride + TXBB_SIZE);
 	vfree(ring->rx_info);
 	ring->rx_info = NULL;
diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index c0d7b72..b9ab646 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -93,20 +93,13 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 
 	/* Allocate HW buffers on provided NUMA node */
 	set_dev_node(&mdev->dev->persist->pdev->dev, node);
-	err = mlx4_alloc_hwq_res(mdev->dev, &ring->wqres, ring->buf_size,
-				 2 * PAGE_SIZE);
+	err = mlx4_alloc_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
 	set_dev_node(&mdev->dev->persist->pdev->dev, mdev->dev->numa_node);
 	if (err) {
 		en_err(priv, "Failed allocating hwq resources\n");
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
@@ -117,7 +110,7 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 				    MLX4_RESERVE_ETH_BF_QP);
 	if (err) {
 		en_err(priv, "failed reserving qp for TX ring\n");
-		goto err_map;
+		goto err_hwq_res;
 	}
 
 	err = mlx4_qp_alloc(mdev->dev, ring->qpn, &ring->qp, GFP_KERNEL);
@@ -154,8 +147,6 @@ int mlx4_en_create_tx_ring(struct mlx4_en_priv *priv,
 
 err_reserve:
 	mlx4_qp_release_range(mdev->dev, ring->qpn, 1);
-err_map:
-	mlx4_en_unmap_buffer(&ring->wqres.buf);
 err_hwq_res:
 	mlx4_free_hwq_res(mdev->dev, &ring->wqres, ring->buf_size);
 err_bounce:
@@ -182,7 +173,6 @@ void mlx4_en_destroy_tx_ring(struct mlx4_en_priv *priv,
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
diff --git a/include/linux/mlx4/device.h b/include/linux/mlx4/device.h
index 8541a91..72da65f 100644
--- a/include/linux/mlx4/device.h
+++ b/include/linux/mlx4/device.h
@@ -1051,7 +1051,7 @@ int mlx4_buf_alloc(struct mlx4_dev *dev, int size, int max_direct,
 void mlx4_buf_free(struct mlx4_dev *dev, int size, struct mlx4_buf *buf);
 static inline void *mlx4_buf_offset(struct mlx4_buf *buf, int offset)
 {
-	if (BITS_PER_LONG == 64 || buf->nbufs == 1)
+	if (buf->nbufs == 1)
 		return buf->direct.buf + offset;
 	else
 		return buf->page_list[offset >> PAGE_SHIFT].buf +
@@ -1091,7 +1091,7 @@ int mlx4_db_alloc(struct mlx4_dev *dev, struct mlx4_db *db, int order,
 void mlx4_db_free(struct mlx4_dev *dev, struct mlx4_db *db);
 
 int mlx4_alloc_hwq_res(struct mlx4_dev *dev, struct mlx4_hwq_resources *wqres,
-		       int size, int max_direct);
+		       int size);
 void mlx4_free_hwq_res(struct mlx4_dev *mdev, struct mlx4_hwq_resources *wqres,
 		       int size);
 
-- 
1.8.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
