From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [PATCH for-next 07/11] IB/mlx5: Add MR cache for large UMR regions
Date: Sun,  1 Jan 2017 23:10:23 +0200
Message-ID: <1483305027-2573-8-git-send-email-saeedm@mellanox.com>
References: <1483305027-2573-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ilya Lesokhin <ilyal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Artemy Kovalyov <artemyko-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1483305027-2573-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Artemy Kovalyov <artemyko-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

In this change we turn mlx5_ib_update_mtt() into generic
mlx5_ib_update_xlt() to perfrom HCA translation table modifiactions
supporting both atomic and process contexts and not limited by number
of modified entries.
Using this function we increase preallocated MRs up to 16GB.

Signed-off-by: Artemy Kovalyov <artemyko-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/mlx5/main.c              |  14 +-
 drivers/infiniband/hw/mlx5/mem.c               |  32 +-
 drivers/infiniband/hw/mlx5/mlx5_ib.h           |  15 +-
 drivers/infiniband/hw/mlx5/mr.c                | 386 ++++++++++---------------
 drivers/infiniband/hw/mlx5/odp.c               |  19 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c |  20 ++
 include/linux/mlx5/driver.h                    |   2 +-
 7 files changed, 240 insertions(+), 248 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 2ab4e32..b871272 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -1112,11 +1112,18 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	context->ibucontext.invalidate_range = &mlx5_ib_invalidate_range;
 #endif
 
+	context->upd_xlt_page = __get_free_page(GFP_KERNEL);
+	if (!context->upd_xlt_page) {
+		err = -ENOMEM;
+		goto out_uars;
+	}
+	mutex_init(&context->upd_xlt_page_mutex);
+
 	if (MLX5_CAP_GEN(dev->mdev, log_max_transport_domain)) {
 		err = mlx5_core_alloc_transport_domain(dev->mdev,
 						       &context->tdn);
 		if (err)
-			goto out_uars;
+			goto out_page;
 	}
 
 	INIT_LIST_HEAD(&context->vma_private_list);
@@ -1168,6 +1175,9 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	if (MLX5_CAP_GEN(dev->mdev, log_max_transport_domain))
 		mlx5_core_dealloc_transport_domain(dev->mdev, context->tdn);
 
+out_page:
+	free_page(context->upd_xlt_page);
+
 out_uars:
 	for (i--; i >= 0; i--)
 		mlx5_cmd_free_uar(dev->mdev, uars[i].index);
@@ -1195,6 +1205,8 @@ static int mlx5_ib_dealloc_ucontext(struct ib_ucontext *ibcontext)
 	if (MLX5_CAP_GEN(dev->mdev, log_max_transport_domain))
 		mlx5_core_dealloc_transport_domain(dev->mdev, context->tdn);
 
+	free_page(context->upd_xlt_page);
+
 	for (i = 0; i < uuari->num_uars; i++) {
 		if (mlx5_cmd_free_uar(dev->mdev, uuari->uars[i].index))
 			mlx5_ib_warn(dev, "failed to free UAR 0x%x\n", uuari->uars[i].index);
diff --git a/drivers/infiniband/hw/mlx5/mem.c b/drivers/infiniband/hw/mlx5/mem.c
index 6851357..778d8a1 100644
--- a/drivers/infiniband/hw/mlx5/mem.c
+++ b/drivers/infiniband/hw/mlx5/mem.c
@@ -159,7 +159,7 @@ void __mlx5_ib_populate_pas(struct mlx5_ib_dev *dev, struct ib_umem *umem,
 	unsigned long umem_page_shift = ilog2(umem->page_size);
 	int shift = page_shift - umem_page_shift;
 	int mask = (1 << shift) - 1;
-	int i, k;
+	int i, k, idx;
 	u64 cur = 0;
 	u64 base;
 	int len;
@@ -185,18 +185,36 @@ void __mlx5_ib_populate_pas(struct mlx5_ib_dev *dev, struct ib_umem *umem,
 	for_each_sg(umem->sg_head.sgl, sg, umem->nmap, entry) {
 		len = sg_dma_len(sg) >> umem_page_shift;
 		base = sg_dma_address(sg);
-		for (k = 0; k < len; k++) {
+
+		/* Skip elements below offset */
+		if (i + len < offset << shift) {
+			i += len;
+			continue;
+		}
+
+		/* Skip pages below offset */
+		if (i < offset << shift) {
+			k = (offset << shift) - i;
+			i = offset << shift;
+		} else {
+			k = 0;
+		}
+
+		for (; k < len; k++) {
 			if (!(i & mask)) {
 				cur = base + (k << umem_page_shift);
 				cur |= access_flags;
+				idx = (i >> shift) - offset;
 
-				pas[i >> shift] = cpu_to_be64(cur);
+				pas[idx] = cpu_to_be64(cur);
 				mlx5_ib_dbg(dev, "pas[%d] 0x%llx\n",
-					    i >> shift, be64_to_cpu(pas[i >> shift]));
-			}  else
-				mlx5_ib_dbg(dev, "=====> 0x%llx\n",
-					    base + (k << umem_page_shift));
+					    i >> shift, be64_to_cpu(pas[idx]));
+			}
 			i++;
+
+			/* Stop after num_pages reached */
+			if (i >> shift >= offset + num_pages)
+				return;
 		}
 	}
 }
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index 73bff77..02d9255 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -125,6 +125,10 @@ struct mlx5_ib_ucontext {
 	/* Transport Domain number */
 	u32			tdn;
 	struct list_head	vma_private_list;
+
+	unsigned long		upd_xlt_page;
+	/* protect ODP/KSM */
+	struct mutex		upd_xlt_page_mutex;
 };
 
 static inline struct mlx5_ib_ucontext *to_mucontext(struct ib_ucontext *ibucontext)
@@ -192,6 +196,13 @@ struct mlx5_ib_flow_db {
 #define MLX5_IB_UMR_OCTOWORD	       16
 #define MLX5_IB_UMR_XLT_ALIGNMENT      64
 
+#define MLX5_IB_UPD_XLT_ZAP	      BIT(0)
+#define MLX5_IB_UPD_XLT_ENABLE	      BIT(1)
+#define MLX5_IB_UPD_XLT_ATOMIC	      BIT(2)
+#define MLX5_IB_UPD_XLT_ADDR	      BIT(3)
+#define MLX5_IB_UPD_XLT_PD	      BIT(4)
+#define MLX5_IB_UPD_XLT_ACCESS	      BIT(5)
+
 /* Private QP creation flags to be passed in ib_qp_init_attr.create_flags.
  *
  * These flags are intended for internal use by the mlx5_ib driver, and they
@@ -788,8 +799,8 @@ struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
 struct ib_mw *mlx5_ib_alloc_mw(struct ib_pd *pd, enum ib_mw_type type,
 			       struct ib_udata *udata);
 int mlx5_ib_dealloc_mw(struct ib_mw *mw);
-int mlx5_ib_update_mtt(struct mlx5_ib_mr *mr, u64 start_page_index,
-		       int npages, int zap);
+int mlx5_ib_update_xlt(struct mlx5_ib_mr *mr, u64 idx, int npages,
+		       int page_shift, int flags);
 int mlx5_ib_rereg_user_mr(struct ib_mr *ib_mr, int flags, u64 start,
 			  u64 length, u64 virt_addr, int access_flags,
 			  struct ib_pd *pd, struct ib_udata *udata);
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index 271b78e..e4333c8 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -46,14 +46,9 @@ enum {
 };
 
 #define MLX5_UMR_ALIGN 2048
-#ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING
-static __be64 mlx5_ib_update_mtt_emergency_buffer[
-		MLX5_UMR_MTT_MIN_CHUNK_SIZE/sizeof(__be64)]
-	__aligned(MLX5_UMR_ALIGN);
-static DEFINE_MUTEX(mlx5_ib_update_mtt_emergency_buffer_mutex);
-#endif
 
 static int clean_mr(struct mlx5_ib_mr *mr);
+static int use_umr(struct mlx5_ib_dev *dev, int order);
 
 static int destroy_mkey(struct mlx5_ib_dev *dev, struct mlx5_ib_mr *mr)
 {
@@ -629,7 +624,8 @@ int mlx5_mr_cache_init(struct mlx5_ib_dev *dev)
 		ent->dev = dev;
 
 		if ((dev->mdev->profile->mask & MLX5_PROF_MASK_MR_CACHE) &&
-		    (mlx5_core_is_pf(dev->mdev)))
+		    mlx5_core_is_pf(dev->mdev) &&
+		    use_umr(dev, ent->order))
 			limit = dev->mdev->profile->mr_cache[i].limit;
 		else
 			limit = 0;
@@ -757,98 +753,13 @@ static int get_octo_len(u64 addr, u64 len, int page_size)
 	return (npages + 1) / 2;
 }
 
-static int use_umr(int order)
+static int use_umr(struct mlx5_ib_dev *dev, int order)
 {
+	if (MLX5_CAP_GEN(dev->mdev, umr_extended_translation_offset))
+		return order < MAX_MR_CACHE_ENTRIES + 2;
 	return order <= MLX5_MAX_UMR_SHIFT;
 }
 
-static int dma_map_mr_pas(struct mlx5_ib_dev *dev, struct ib_umem *umem,
-			  int npages, int page_shift, int *size,
-			  __be64 **mr_pas, dma_addr_t *dma)
-{
-	__be64 *pas;
-	struct device *ddev = dev->ib_dev.dma_device;
-
-	/*
-	 * UMR copies MTTs in units of MLX5_UMR_MTT_ALIGNMENT bytes.
-	 * To avoid copying garbage after the pas array, we allocate
-	 * a little more.
-	 */
-	*size = ALIGN(sizeof(struct mlx5_mtt) * npages, MLX5_UMR_MTT_ALIGNMENT);
-	*mr_pas = kmalloc(*size + MLX5_UMR_ALIGN - 1, GFP_KERNEL);
-	if (!(*mr_pas))
-		return -ENOMEM;
-
-	pas = PTR_ALIGN(*mr_pas, MLX5_UMR_ALIGN);
-	mlx5_ib_populate_pas(dev, umem, page_shift, pas, MLX5_IB_MTT_PRESENT);
-	/* Clear padding after the actual pages. */
-	memset(pas + npages, 0, *size - npages * sizeof(struct mlx5_mtt));
-
-	*dma = dma_map_single(ddev, pas, *size, DMA_TO_DEVICE);
-	if (dma_mapping_error(ddev, *dma)) {
-		kfree(*mr_pas);
-		return -ENOMEM;
-	}
-
-	return 0;
-}
-
-static void prep_umr_wqe_common(struct ib_pd *pd, struct ib_send_wr *wr,
-				struct ib_sge *sg, u64 dma, int n, u32 key,
-				int page_shift)
-{
-	struct mlx5_ib_dev *dev = to_mdev(pd->device);
-	struct mlx5_umr_wr *umrwr = umr_wr(wr);
-
-	sg->addr = dma;
-	sg->length = ALIGN(sizeof(struct mlx5_mtt) * n,
-			   MLX5_IB_UMR_XLT_ALIGNMENT);
-	sg->lkey = dev->umrc.pd->local_dma_lkey;
-
-	wr->next = NULL;
-	wr->sg_list = sg;
-	if (n)
-		wr->num_sge = 1;
-	else
-		wr->num_sge = 0;
-
-	wr->opcode = MLX5_IB_WR_UMR;
-
-	umrwr->xlt_size = sg->length;
-	umrwr->page_shift = page_shift;
-	umrwr->mkey = key;
-}
-
-static void prep_umr_reg_wqe(struct ib_pd *pd, struct ib_send_wr *wr,
-			     struct ib_sge *sg, u64 dma, int n, u32 key,
-			     int page_shift, u64 virt_addr, u64 len,
-			     int access_flags)
-{
-	struct mlx5_umr_wr *umrwr = umr_wr(wr);
-
-	prep_umr_wqe_common(pd, wr, sg, dma, n, key, page_shift);
-
-	wr->send_flags = MLX5_IB_SEND_UMR_ENABLE_MR |
-			 MLX5_IB_SEND_UMR_UPDATE_TRANSLATION |
-			 MLX5_IB_SEND_UMR_UPDATE_PD_ACCESS;
-
-	umrwr->virt_addr = virt_addr;
-	umrwr->length = len;
-	umrwr->access_flags = access_flags;
-	umrwr->pd = pd;
-}
-
-static void prep_umr_unreg_wqe(struct mlx5_ib_dev *dev,
-			       struct ib_send_wr *wr, u32 key)
-{
-	struct mlx5_umr_wr *umrwr = umr_wr(wr);
-
-	wr->send_flags = MLX5_IB_SEND_UMR_DISABLE_MR |
-			 MLX5_IB_SEND_UMR_FAIL_IF_FREE;
-	wr->opcode = MLX5_IB_WR_UMR;
-	umrwr->mkey = key;
-}
-
 static int mr_umem_get(struct ib_pd *pd, u64 start, u64 length,
 		       int access_flags, struct ib_umem **umem,
 		       int *npages, int *page_shift, int *ncont,
@@ -927,13 +838,7 @@ static struct mlx5_ib_mr *reg_umr(struct ib_pd *pd, struct ib_umem *umem,
 				  int page_shift, int order, int access_flags)
 {
 	struct mlx5_ib_dev *dev = to_mdev(pd->device);
-	struct device *ddev = dev->ib_dev.dma_device;
-	struct mlx5_umr_wr umrwr = {};
 	struct mlx5_ib_mr *mr;
-	struct ib_sge sg;
-	int size;
-	__be64 *mr_pas;
-	dma_addr_t dma;
 	int err = 0;
 	int i;
 
@@ -952,144 +857,174 @@ static struct mlx5_ib_mr *reg_umr(struct ib_pd *pd, struct ib_umem *umem,
 	if (!mr)
 		return ERR_PTR(-EAGAIN);
 
-	err = dma_map_mr_pas(dev, umem, npages, page_shift, &size, &mr_pas,
-			     &dma);
-	if (err)
-		goto free_mr;
-
-	prep_umr_reg_wqe(pd, &umrwr.wr, &sg, dma, npages, mr->mmkey.key,
-			 page_shift, virt_addr, len, access_flags);
-
-	err = mlx5_ib_post_send_wait(dev, &umrwr);
-	if (err && err != -EFAULT)
-		goto unmap_dma;
-
+	mr->ibmr.pd = pd;
+	mr->umem = umem;
+	mr->access_flags = access_flags;
+	mr->desc_size = sizeof(struct mlx5_mtt);
 	mr->mmkey.iova = virt_addr;
 	mr->mmkey.size = len;
 	mr->mmkey.pd = to_mpd(pd)->pdn;
 
-	mr->live = 1;
-
-unmap_dma:
-	dma_unmap_single(ddev, dma, size, DMA_TO_DEVICE);
+	err = mlx5_ib_update_xlt(mr, 0, npages, page_shift,
+				 MLX5_IB_UPD_XLT_ENABLE);
 
-	kfree(mr_pas);
-
-free_mr:
 	if (err) {
 		free_cached_mr(dev, mr);
 		return ERR_PTR(err);
 	}
 
+	mr->live = 1;
+
 	return mr;
 }
 
-#ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING
-int mlx5_ib_update_mtt(struct mlx5_ib_mr *mr, u64 start_page_index, int npages,
-		       int zap)
+static inline int populate_xlt(struct mlx5_ib_mr *mr, int idx, int npages,
+			       void *xlt, int page_shift, size_t size,
+			       int flags)
 {
 	struct mlx5_ib_dev *dev = mr->dev;
-	struct device *ddev = dev->ib_dev.dma_device;
 	struct ib_umem *umem = mr->umem;
+
+	npages = min_t(size_t, npages, ib_umem_num_pages(umem) - idx);
+
+	if (!(flags & MLX5_IB_UPD_XLT_ZAP)) {
+		__mlx5_ib_populate_pas(dev, umem, page_shift,
+				       idx, npages, xlt,
+				       MLX5_IB_MTT_PRESENT);
+		/* Clear padding after the pages
+		 * brought from the umem.
+		 */
+		memset(xlt + (npages * sizeof(struct mlx5_mtt)), 0,
+		       size - npages * sizeof(struct mlx5_mtt));
+	}
+
+	return npages;
+}
+
+#define MLX5_MAX_UMR_CHUNK ((1 << (MLX5_MAX_UMR_SHIFT + 4)) - \
+			    MLX5_UMR_MTT_ALIGNMENT)
+#define MLX5_SPARE_UMR_CHUNK 0x10000
+
+int mlx5_ib_update_xlt(struct mlx5_ib_mr *mr, u64 idx, int npages,
+		       int page_shift, int flags)
+{
+	struct mlx5_ib_dev *dev = mr->dev;
+	struct device *ddev = dev->ib_dev.dma_device;
+	struct mlx5_ib_ucontext *uctx = NULL;
 	int size;
-	__be64 *pas;
+	void *xlt;
 	dma_addr_t dma;
 	struct mlx5_umr_wr wr;
 	struct ib_sge sg;
 	int err = 0;
-	const int page_index_alignment = MLX5_UMR_MTT_ALIGNMENT /
-					 sizeof(struct mlx5_mtt);
-	const int page_index_mask = page_index_alignment - 1;
+	int desc_size = sizeof(struct mlx5_mtt);
+	const int page_align = MLX5_UMR_MTT_ALIGNMENT / desc_size;
+	const int page_mask = page_align - 1;
 	size_t pages_mapped = 0;
 	size_t pages_to_map = 0;
 	size_t pages_iter = 0;
-	int use_emergency_buf = 0;
+	gfp_t gfp;
 
 	/* UMR copies MTTs in units of MLX5_UMR_MTT_ALIGNMENT bytes,
-	 * so we need to align the offset and length accordingly */
-	if (start_page_index & page_index_mask) {
-		npages += start_page_index & page_index_mask;
-		start_page_index &= ~page_index_mask;
+	 * so we need to align the offset and length accordingly
+	 */
+	if (idx & page_mask) {
+		npages += idx & page_mask;
+		idx &= ~page_mask;
 	}
 
-	pages_to_map = ALIGN(npages, page_index_alignment);
+	gfp = flags & MLX5_IB_UPD_XLT_ATOMIC ? GFP_ATOMIC : GFP_KERNEL;
+	gfp |= __GFP_ZERO | __GFP_NOWARN;
 
-	if (start_page_index + pages_to_map > MLX5_MAX_UMR_PAGES)
-		return -EINVAL;
+	pages_to_map = ALIGN(npages, page_align);
+	size = desc_size * pages_to_map;
+	size = min_t(int, size, MLX5_MAX_UMR_CHUNK);
 
-	size = sizeof(struct mlx5_mtt) * pages_to_map;
-	size = min_t(int, PAGE_SIZE, size);
-	/* We allocate with GFP_ATOMIC to avoid recursion into page-reclaim
-	 * code, when we are called from an invalidation. The pas buffer must
-	 * be 2k-aligned for Connect-IB. */
-	pas = (__be64 *)get_zeroed_page(GFP_ATOMIC);
-	if (!pas) {
-		mlx5_ib_warn(dev, "unable to allocate memory during MTT update, falling back to slower chunked mechanism.\n");
-		pas = mlx5_ib_update_mtt_emergency_buffer;
-		size = MLX5_UMR_MTT_MIN_CHUNK_SIZE;
-		use_emergency_buf = 1;
-		mutex_lock(&mlx5_ib_update_mtt_emergency_buffer_mutex);
-		memset(pas, 0, size);
+	xlt = (void *)__get_free_pages(gfp, get_order(size));
+	if (!xlt && size > MLX5_SPARE_UMR_CHUNK) {
+		mlx5_ib_dbg(dev, "Failed to allocate %d bytes of order %d. fallback to spare UMR allocation od %d bytes\n",
+			    size, get_order(size), MLX5_SPARE_UMR_CHUNK);
+
+		size = MLX5_SPARE_UMR_CHUNK;
+		xlt = (void *)__get_free_pages(gfp, get_order(size));
 	}
-	pages_iter = size / sizeof(struct mlx5_mtt);
-	dma = dma_map_single(ddev, pas, size, DMA_TO_DEVICE);
+
+	if (!xlt) {
+		uctx = to_mucontext(mr->ibmr.uobject->context);
+		mlx5_ib_warn(dev, "Using XLT emergency buffer\n");
+		size = PAGE_SIZE;
+		xlt = (void *)uctx->upd_xlt_page;
+		mutex_lock(&uctx->upd_xlt_page_mutex);
+		memset(xlt, 0, size);
+	}
+	pages_iter = size / desc_size;
+	dma = dma_map_single(ddev, xlt, size, DMA_TO_DEVICE);
 	if (dma_mapping_error(ddev, dma)) {
-		mlx5_ib_err(dev, "unable to map DMA during MTT update.\n");
+		mlx5_ib_err(dev, "unable to map DMA during XLT update.\n");
 		err = -ENOMEM;
-		goto free_pas;
+		goto free_xlt;
 	}
 
+	sg.addr = dma;
+	sg.lkey = dev->umrc.pd->local_dma_lkey;
+
+	memset(&wr, 0, sizeof(wr));
+	wr.wr.send_flags = MLX5_IB_SEND_UMR_UPDATE_XLT;
+	if (!(flags & MLX5_IB_UPD_XLT_ENABLE))
+		wr.wr.send_flags |= MLX5_IB_SEND_UMR_FAIL_IF_FREE;
+	wr.wr.sg_list = &sg;
+	wr.wr.num_sge = 1;
+	wr.wr.opcode = MLX5_IB_WR_UMR;
+
+	wr.pd = mr->ibmr.pd;
+	wr.mkey = mr->mmkey.key;
+	wr.length = mr->mmkey.size;
+	wr.virt_addr = mr->mmkey.iova;
+	wr.access_flags = mr->access_flags;
+	wr.page_shift = page_shift;
+
 	for (pages_mapped = 0;
 	     pages_mapped < pages_to_map && !err;
-	     pages_mapped += pages_iter, start_page_index += pages_iter) {
+	     pages_mapped += pages_iter, idx += pages_iter) {
 		dma_sync_single_for_cpu(ddev, dma, size, DMA_TO_DEVICE);
-
-		npages = min_t(size_t,
-			       pages_iter,
-			       ib_umem_num_pages(umem) - start_page_index);
-
-		if (!zap) {
-			__mlx5_ib_populate_pas(dev, umem, PAGE_SHIFT,
-					       start_page_index, npages, pas,
-					       MLX5_IB_MTT_PRESENT);
-			/* Clear padding after the pages brought from the
-			 * umem. */
-			memset(pas + npages, 0, size - npages *
-			       sizeof(struct mlx5_mtt));
-		}
+		npages = populate_xlt(mr, idx, pages_iter, xlt,
+				      page_shift, size, flags);
 
 		dma_sync_single_for_device(ddev, dma, size, DMA_TO_DEVICE);
 
-		memset(&wr, 0, sizeof(wr));
-
-		sg.addr = dma;
-		sg.length = ALIGN(npages * sizeof(struct mlx5_mtt),
-				MLX5_UMR_MTT_ALIGNMENT);
-		sg.lkey = dev->umrc.pd->local_dma_lkey;
+		sg.length = ALIGN(npages * desc_size,
+				  MLX5_UMR_MTT_ALIGNMENT);
+
+		if (pages_mapped + pages_iter >= pages_to_map) {
+			if (flags & MLX5_IB_UPD_XLT_ENABLE)
+				wr.wr.send_flags |=
+					MLX5_IB_SEND_UMR_ENABLE_MR |
+					MLX5_IB_SEND_UMR_UPDATE_PD_ACCESS |
+					MLX5_IB_SEND_UMR_UPDATE_TRANSLATION;
+			if (flags & MLX5_IB_UPD_XLT_PD ||
+			    flags & MLX5_IB_UPD_XLT_ACCESS)
+				wr.wr.send_flags |=
+					MLX5_IB_SEND_UMR_UPDATE_PD_ACCESS;
+			if (flags & MLX5_IB_UPD_XLT_ADDR)
+				wr.wr.send_flags |=
+					MLX5_IB_SEND_UMR_UPDATE_TRANSLATION;
+		}
 
-		wr.wr.send_flags = MLX5_IB_SEND_UMR_FAIL_IF_FREE |
-				   MLX5_IB_SEND_UMR_UPDATE_XLT;
-		wr.wr.sg_list = &sg;
-		wr.wr.num_sge = 1;
-		wr.wr.opcode = MLX5_IB_WR_UMR;
+		wr.offset = idx * desc_size;
 		wr.xlt_size = sg.length;
-		wr.page_shift = PAGE_SHIFT;
-		wr.mkey = mr->mmkey.key;
-		wr.offset = start_page_index * sizeof(struct mlx5_mtt);
 
 		err = mlx5_ib_post_send_wait(dev, &wr);
 	}
 	dma_unmap_single(ddev, dma, size, DMA_TO_DEVICE);
 
-free_pas:
-	if (!use_emergency_buf)
-		free_page((unsigned long)pas);
+free_xlt:
+	if (uctx)
+		mutex_unlock(&uctx->upd_xlt_page_mutex);
 	else
-		mutex_unlock(&mlx5_ib_update_mtt_emergency_buffer_mutex);
+		free_pages((unsigned long)xlt, get_order(size));
 
 	return err;
 }
-#endif
 
 /*
  * If ibmr is NULL it will be allocated by reg_create.
@@ -1204,7 +1139,7 @@ struct ib_mr *mlx5_ib_reg_user_mr(struct ib_pd *pd, u64 start, u64 length,
         if (err < 0)
 		return ERR_PTR(err);
 
-	if (use_umr(order)) {
+	if (use_umr(dev, order)) {
 		mr = reg_umr(pd, umem, virt_addr, length, ncont, page_shift,
 			     order, access_flags);
 		if (PTR_ERR(mr) == -EAGAIN) {
@@ -1254,39 +1189,25 @@ static int unreg_umr(struct mlx5_ib_dev *dev, struct mlx5_ib_mr *mr)
 	if (mdev->state == MLX5_DEVICE_STATE_INTERNAL_ERROR)
 		return 0;
 
-	prep_umr_unreg_wqe(dev, &umrwr.wr, mr->mmkey.key);
+	umrwr.wr.send_flags = MLX5_IB_SEND_UMR_DISABLE_MR |
+			      MLX5_IB_SEND_UMR_FAIL_IF_FREE;
+	umrwr.wr.opcode = MLX5_IB_WR_UMR;
+	umrwr.mkey = mr->mmkey.key;
 
 	return mlx5_ib_post_send_wait(dev, &umrwr);
 }
 
-static int rereg_umr(struct ib_pd *pd, struct mlx5_ib_mr *mr, u64 virt_addr,
-		     u64 length, int npages, int page_shift, int order,
+static int rereg_umr(struct ib_pd *pd, struct mlx5_ib_mr *mr,
 		     int access_flags, int flags)
 {
 	struct mlx5_ib_dev *dev = to_mdev(pd->device);
-	struct device *ddev = dev->ib_dev.dma_device;
 	struct mlx5_umr_wr umrwr = {};
-	struct ib_sge sg;
-	dma_addr_t dma = 0;
-	__be64 *mr_pas = NULL;
-	int size;
 	int err;
 
 	umrwr.wr.send_flags = MLX5_IB_SEND_UMR_FAIL_IF_FREE;
 
-	if (flags & IB_MR_REREG_TRANS) {
-		err = dma_map_mr_pas(dev, mr->umem, npages, page_shift, &size,
-				     &mr_pas, &dma);
-		if (err)
-			return err;
-
-		umrwr.virt_addr = virt_addr;
-		umrwr.length = length;
-		umrwr.wr.send_flags |= MLX5_IB_SEND_UMR_UPDATE_TRANSLATION;
-	}
-
-	prep_umr_wqe_common(pd, &umrwr.wr, &sg, dma, npages, mr->mmkey.key,
-			    page_shift);
+	umrwr.wr.opcode = MLX5_IB_WR_UMR;
+	umrwr.mkey = mr->mmkey.key;
 
 	if (flags & IB_MR_REREG_PD || flags & IB_MR_REREG_ACCESS) {
 		umrwr.pd = pd;
@@ -1294,13 +1215,8 @@ static int rereg_umr(struct ib_pd *pd, struct mlx5_ib_mr *mr, u64 virt_addr,
 		umrwr.wr.send_flags |= MLX5_IB_SEND_UMR_UPDATE_PD_ACCESS;
 	}
 
-	/* post send request to UMR QP */
 	err = mlx5_ib_post_send_wait(dev, &umrwr);
 
-	if (flags & IB_MR_REREG_TRANS) {
-		dma_unmap_single(ddev, dma, size, DMA_TO_DEVICE);
-		kfree(mr_pas);
-	}
 	return err;
 }
 
@@ -1317,6 +1233,7 @@ int mlx5_ib_rereg_user_mr(struct ib_mr *ib_mr, int flags, u64 start,
 	u64 addr = (flags & IB_MR_REREG_TRANS) ? virt_addr : mr->umem->address;
 	u64 len = (flags & IB_MR_REREG_TRANS) ? length : mr->umem->length;
 	int page_shift = 0;
+	int upd_flags = 0;
 	int npages = 0;
 	int ncont = 0;
 	int order = 0;
@@ -1325,6 +1242,8 @@ int mlx5_ib_rereg_user_mr(struct ib_mr *ib_mr, int flags, u64 start,
 	mlx5_ib_dbg(dev, "start 0x%llx, virt_addr 0x%llx, length 0x%llx, access_flags 0x%x\n",
 		    start, virt_addr, length, access_flags);
 
+	atomic_sub(mr->npages, &dev->mdev->priv.reg_pages);
+
 	if (flags != IB_MR_REREG_PD) {
 		/*
 		 * Replace umem. This needs to be done whether or not UMR is
@@ -1335,7 +1254,7 @@ int mlx5_ib_rereg_user_mr(struct ib_mr *ib_mr, int flags, u64 start,
 		err = mr_umem_get(pd, addr, len, access_flags, &mr->umem,
 				  &npages, &page_shift, &ncont, &order);
 		if (err < 0) {
-			mr->umem = NULL;
+			clean_mr(mr);
 			return err;
 		}
 	}
@@ -1367,32 +1286,37 @@ int mlx5_ib_rereg_user_mr(struct ib_mr *ib_mr, int flags, u64 start,
 		/*
 		 * Send a UMR WQE
 		 */
-		err = rereg_umr(pd, mr, addr, len, npages, page_shift,
-				order, access_flags, flags);
+		mr->ibmr.pd = pd;
+		mr->access_flags = access_flags;
+		mr->mmkey.iova = addr;
+		mr->mmkey.size = len;
+		mr->mmkey.pd = to_mpd(pd)->pdn;
+
+		if (flags & IB_MR_REREG_TRANS) {
+			upd_flags = MLX5_IB_UPD_XLT_ADDR;
+			if (flags & IB_MR_REREG_PD)
+				upd_flags |= MLX5_IB_UPD_XLT_PD;
+			if (flags & IB_MR_REREG_ACCESS)
+				upd_flags |= MLX5_IB_UPD_XLT_ACCESS;
+			err = mlx5_ib_update_xlt(mr, 0, npages, page_shift,
+						 upd_flags);
+		} else {
+			err = rereg_umr(pd, mr, access_flags, flags);
+		}
+
 		if (err) {
 			mlx5_ib_warn(dev, "Failed to rereg UMR\n");
+			ib_umem_release(mr->umem);
+			clean_mr(mr);
 			return err;
 		}
 	}
 
-	if (flags & IB_MR_REREG_PD) {
-		ib_mr->pd = pd;
-		mr->mmkey.pd = to_mpd(pd)->pdn;
-	}
+	set_mr_fileds(dev, mr, npages, len, access_flags);
 
-	if (flags & IB_MR_REREG_ACCESS)
-		mr->access_flags = access_flags;
-
-	if (flags & IB_MR_REREG_TRANS) {
-		atomic_sub(mr->npages, &dev->mdev->priv.reg_pages);
-		set_mr_fileds(dev, mr, npages, len, access_flags);
-		mr->mmkey.iova = addr;
-		mr->mmkey.size = len;
-	}
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING
 	update_odp_mr(mr);
 #endif
-
 	return 0;
 }
 
diff --git a/drivers/infiniband/hw/mlx5/odp.c b/drivers/infiniband/hw/mlx5/odp.c
index 1e73c12..cfd7ee5 100644
--- a/drivers/infiniband/hw/mlx5/odp.c
+++ b/drivers/infiniband/hw/mlx5/odp.c
@@ -91,16 +91,21 @@ void mlx5_ib_invalidate_range(struct ib_umem *umem, unsigned long start,
 			u64 umr_offset = idx & umr_block_mask;
 
 			if (in_block && umr_offset == 0) {
-				mlx5_ib_update_mtt(mr, blk_start_idx,
-						   idx - blk_start_idx, 1);
+				mlx5_ib_update_xlt(mr, blk_start_idx,
+						   idx - blk_start_idx,
+						   PAGE_SHIFT,
+						   MLX5_IB_UPD_XLT_ZAP |
+						   MLX5_IB_UPD_XLT_ATOMIC);
 				in_block = 0;
 			}
 		}
 	}
 	if (in_block)
-		mlx5_ib_update_mtt(mr, blk_start_idx, idx - blk_start_idx + 1,
-				   1);
-
+		mlx5_ib_update_xlt(mr, blk_start_idx,
+				   idx - blk_start_idx + 1,
+				   PAGE_SHIFT,
+				   MLX5_IB_UPD_XLT_ZAP |
+				   MLX5_IB_UPD_XLT_ATOMIC);
 	/*
 	 * We are now sure that the device will not access the
 	 * memory. We can safely unmap it, and mark it as dirty if
@@ -257,7 +262,9 @@ static int pagefault_single_data_segment(struct mlx5_ib_qp *qp,
 			 * this MR, since ib_umem_odp_map_dma_pages already
 			 * checks this.
 			 */
-			ret = mlx5_ib_update_mtt(mr, start_idx, npages, 0);
+			ret = mlx5_ib_update_xlt(mr, start_idx, npages,
+						 PAGE_SHIFT,
+						 MLX5_IB_UPD_XLT_ATOMIC);
 		} else {
 			ret = -EAGAIN;
 		}
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index 54e5a78..1713bd8 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -152,6 +152,26 @@ static struct mlx5_profile profile[] = {
 			.size	= 8,
 			.limit	= 4
 		},
+		.mr_cache[16]	= {
+			.size	= 8,
+			.limit	= 4
+		},
+		.mr_cache[17]	= {
+			.size	= 8,
+			.limit	= 4
+		},
+		.mr_cache[18]	= {
+			.size	= 8,
+			.limit	= 4
+		},
+		.mr_cache[19]	= {
+			.size	= 4,
+			.limit	= 2
+		},
+		.mr_cache[20]	= {
+			.size	= 4,
+			.limit	= 2
+		},
 	},
 };
 
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index 0ae5536..ec52f3b 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -959,7 +959,7 @@ enum {
 };
 
 enum {
-	MAX_MR_CACHE_ENTRIES    = 16,
+	MAX_MR_CACHE_ENTRIES    = 21,
 };
 
 enum {
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
