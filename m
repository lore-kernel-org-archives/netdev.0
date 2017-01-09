From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next V3 08/10] IB/mlx5: Allow future extension of libmlx5 input data
Date: Mon,  9 Jan 2017 21:00:51 +0200
Message-ID: <1483988453-28551-9-git-send-email-saeedm@mellanox.com>
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

Current check requests that new fields in struct
mlx5_ib_alloc_ucontext_req_v2 that are not known to the driver be zero.
This was introduced so new libraries passing additional information to
the kernel through struct mlx5_ib_alloc_ucontext_req_v2 will be notified
by old kernels that do not support their request by failing the
operation. This schecme is problematic since it requires libmlx5 to issue
the requests with descending input size for struct
mlx5_ib_alloc_ucontext_req_v2.

To avoid this, we require that new features that will obey the following
rules:
If the feature requires one or more fields in the response and the at
least one of the fields can be encoded such that a zero value means the
kernel ignored the request then this field will provide the indication
to the library. If no response is required or if zero is a valid
response, a new field should be added that indicates to the library
whether its request was processed.

Fixes: b368d7cb8ceb ('IB/mlx5: Add hca_core_clock_offset to udata in init_ucontext')
Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/mlx5/cq.c      |   2 +-
 drivers/infiniband/hw/mlx5/main.c    | 201 ++++++++++++++++++++++-------------
 drivers/infiniband/hw/mlx5/mlx5_ib.h |  15 ++-
 drivers/infiniband/hw/mlx5/qp.c      | 133 ++++++++++-------------
 include/linux/mlx5/device.h          |  12 ++-
 include/linux/mlx5/driver.h          |  12 +--
 6 files changed, 209 insertions(+), 166 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/cq.c b/drivers/infiniband/hw/mlx5/cq.c
index a28ec33..31803b3 100644
--- a/drivers/infiniband/hw/mlx5/cq.c
+++ b/drivers/infiniband/hw/mlx5/cq.c
@@ -788,7 +788,7 @@ static int create_cq_user(struct mlx5_ib_dev *dev, struct ib_udata *udata,
 	MLX5_SET(cqc, cqc, log_page_size,
 		 page_shift - MLX5_ADAPTER_PAGE_SHIFT);
 
-	*index = to_mucontext(context)->bfregi.uars[0].index;
+	*index = to_mucontext(context)->bfregi.sys_pages[0];
 
 	if (ucmd.cqe_comp_en == 1) {
 		if (unlikely((*cqe_size != 64) ||
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index e9f0830..6640672 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -992,6 +992,80 @@ static int mlx5_ib_modify_port(struct ib_device *ibdev, u8 port, int mask,
 	return err;
 }
 
+static int calc_total_bfregs(struct mlx5_ib_dev *dev, bool lib_uar_4k,
+			     struct mlx5_ib_alloc_ucontext_req_v2 *req,
+			     u32 *num_sys_pages)
+{
+	int uars_per_sys_page;
+	int bfregs_per_sys_page;
+	int ref_bfregs = req->total_num_bfregs;
+
+	if (req->total_num_bfregs == 0)
+		return -EINVAL;
+
+	BUILD_BUG_ON(MLX5_MAX_BFREGS % MLX5_NON_FP_BFREGS_IN_PAGE);
+	BUILD_BUG_ON(MLX5_MAX_BFREGS < MLX5_NON_FP_BFREGS_IN_PAGE);
+
+	if (req->total_num_bfregs > MLX5_MAX_BFREGS)
+		return -ENOMEM;
+
+	uars_per_sys_page = get_uars_per_sys_page(dev, lib_uar_4k);
+	bfregs_per_sys_page = uars_per_sys_page * MLX5_NON_FP_BFREGS_PER_UAR;
+	req->total_num_bfregs = ALIGN(req->total_num_bfregs, bfregs_per_sys_page);
+	*num_sys_pages = req->total_num_bfregs / bfregs_per_sys_page;
+
+	if (req->num_low_latency_bfregs > req->total_num_bfregs - 1)
+		return -EINVAL;
+
+	mlx5_ib_dbg(dev, "uar_4k: fw support %s, lib support %s, user requested %d bfregs, alloated %d, using %d sys pages\n",
+		    MLX5_CAP_GEN(dev->mdev, uar_4k) ? "yes" : "no",
+		    lib_uar_4k ? "yes" : "no", ref_bfregs,
+		    req->total_num_bfregs, *num_sys_pages);
+
+	return 0;
+}
+
+static int allocate_uars(struct mlx5_ib_dev *dev, struct mlx5_ib_ucontext *context)
+{
+	struct mlx5_bfreg_info *bfregi;
+	int err;
+	int i;
+
+	bfregi = &context->bfregi;
+	for (i = 0; i < bfregi->num_sys_pages; i++) {
+		err = mlx5_cmd_alloc_uar(dev->mdev, &bfregi->sys_pages[i]);
+		if (err)
+			goto error;
+
+		mlx5_ib_dbg(dev, "allocated uar %d\n", bfregi->sys_pages[i]);
+	}
+	return 0;
+
+error:
+	for (--i; i >= 0; i--)
+		if (mlx5_cmd_free_uar(dev->mdev, bfregi->sys_pages[i]))
+			mlx5_ib_warn(dev, "failed to free uar %d\n", i);
+
+	return err;
+}
+
+static int deallocate_uars(struct mlx5_ib_dev *dev, struct mlx5_ib_ucontext *context)
+{
+	struct mlx5_bfreg_info *bfregi;
+	int err;
+	int i;
+
+	bfregi = &context->bfregi;
+	for (i = 0; i < bfregi->num_sys_pages; i++) {
+		err = mlx5_cmd_free_uar(dev->mdev, bfregi->sys_pages[i]);
+		if (err) {
+			mlx5_ib_warn(dev, "failed to free uar %d\n", i);
+			return err;
+		}
+	}
+	return 0;
+}
+
 static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 						  struct ib_udata *udata)
 {
@@ -1000,16 +1074,12 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	struct mlx5_ib_alloc_ucontext_resp resp = {};
 	struct mlx5_ib_ucontext *context;
 	struct mlx5_bfreg_info *bfregi;
-	struct mlx5_uar *uars;
-	int gross_bfregs;
-	int num_uars;
 	int ver;
-	int bfregn;
 	int err;
-	int i;
 	size_t reqlen;
 	size_t min_req_v2 = offsetof(struct mlx5_ib_alloc_ucontext_req_v2,
 				     max_cqe_version);
+	bool lib_uar_4k;
 
 	if (!dev->ib_active)
 		return ERR_PTR(-EAGAIN);
@@ -1032,27 +1102,14 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	if (req.flags)
 		return ERR_PTR(-EINVAL);
 
-	if (req.total_num_bfregs > MLX5_MAX_BFREGS)
-		return ERR_PTR(-ENOMEM);
-
-	if (req.total_num_bfregs == 0)
-		return ERR_PTR(-EINVAL);
-
 	if (req.comp_mask || req.reserved0 || req.reserved1 || req.reserved2)
 		return ERR_PTR(-EOPNOTSUPP);
 
-	if (reqlen > sizeof(req) &&
-	    !ib_is_udata_cleared(udata, sizeof(req),
-				 reqlen - sizeof(req)))
-		return ERR_PTR(-EOPNOTSUPP);
-
 	req.total_num_bfregs = ALIGN(req.total_num_bfregs,
 				    MLX5_NON_FP_BFREGS_PER_UAR);
 	if (req.num_low_latency_bfregs > req.total_num_bfregs - 1)
 		return ERR_PTR(-EINVAL);
 
-	num_uars = req.total_num_bfregs / MLX5_NON_FP_BFREGS_PER_UAR;
-	gross_bfregs = num_uars * MLX5_BFREGS_PER_UAR;
 	resp.qp_tab_size = 1 << MLX5_CAP_GEN(dev->mdev, log_max_qp);
 	if (mlx5_core_is_pf(dev->mdev) && MLX5_CAP_GEN(dev->mdev, bf))
 		resp.bf_reg_size = 1 << MLX5_CAP_GEN(dev->mdev, log_bf_reg_size);
@@ -1072,42 +1129,34 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	if (!context)
 		return ERR_PTR(-ENOMEM);
 
+	lib_uar_4k = false;
 	bfregi = &context->bfregi;
-	mutex_init(&bfregi->lock);
-	uars = kcalloc(num_uars, sizeof(*uars), GFP_KERNEL);
-	if (!uars) {
-		err = -ENOMEM;
+
+	/* updates req->total_num_bfregs */
+	err = calc_total_bfregs(dev, lib_uar_4k, &req, &bfregi->num_sys_pages);
+	if (err)
 		goto out_ctx;
-	}
 
-	bfregi->bitmap = kcalloc(BITS_TO_LONGS(gross_bfregs),
-				sizeof(*bfregi->bitmap),
+	mutex_init(&bfregi->lock);
+	bfregi->lib_uar_4k = lib_uar_4k;
+	bfregi->count = kcalloc(req.total_num_bfregs, sizeof(*bfregi->count),
 				GFP_KERNEL);
-	if (!bfregi->bitmap) {
+	if (!bfregi->count) {
 		err = -ENOMEM;
-		goto out_uar_ctx;
-	}
-	/*
-	 * clear all fast path bfregs
-	 */
-	for (i = 0; i < gross_bfregs; i++) {
-		bfregn = i & 3;
-		if (bfregn == 2 || bfregn == 3)
-			set_bit(i, bfregi->bitmap);
+		goto out_ctx;
 	}
 
-	bfregi->count = kcalloc(gross_bfregs,
-				sizeof(*bfregi->count), GFP_KERNEL);
-	if (!bfregi->count) {
+	bfregi->sys_pages = kcalloc(bfregi->num_sys_pages,
+				    sizeof(*bfregi->sys_pages),
+				    GFP_KERNEL);
+	if (!bfregi->sys_pages) {
 		err = -ENOMEM;
-		goto out_bitmap;
+		goto out_count;
 	}
 
-	for (i = 0; i < num_uars; i++) {
-		err = mlx5_cmd_alloc_uar(dev->mdev, &uars[i].index);
-		if (err)
-			goto out_count;
-	}
+	err = allocate_uars(dev, context);
+	if (err)
+		goto out_sys_pages;
 
 #ifdef CONFIG_INFINIBAND_ON_DEMAND_PAGING
 	context->ibucontext.invalidate_range = &mlx5_ib_invalidate_range;
@@ -1166,9 +1215,8 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 
 	bfregi->ver = ver;
 	bfregi->num_low_latency_bfregs = req.num_low_latency_bfregs;
-	bfregi->uars = uars;
-	bfregi->num_uars = num_uars;
 	context->cqe_version = resp.cqe_version;
+	context->lib_caps = false;
 
 	return &context->ibucontext;
 
@@ -1180,19 +1228,17 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	free_page(context->upd_xlt_page);
 
 out_uars:
-	for (i--; i >= 0; i--)
-		mlx5_cmd_free_uar(dev->mdev, uars[i].index);
-out_count:
-	kfree(bfregi->count);
+	deallocate_uars(dev, context);
 
-out_bitmap:
-	kfree(bfregi->bitmap);
+out_sys_pages:
+	kfree(bfregi->sys_pages);
 
-out_uar_ctx:
-	kfree(uars);
+out_count:
+	kfree(bfregi->count);
 
 out_ctx:
 	kfree(context);
+
 	return ERR_PTR(err);
 }
 
@@ -1200,31 +1246,31 @@ static int mlx5_ib_dealloc_ucontext(struct ib_ucontext *ibcontext)
 {
 	struct mlx5_ib_ucontext *context = to_mucontext(ibcontext);
 	struct mlx5_ib_dev *dev = to_mdev(ibcontext->device);
-	struct mlx5_bfreg_info *bfregi = &context->bfregi;
-	int i;
+	struct mlx5_bfreg_info *bfregi;
 
+	bfregi = &context->bfregi;
 	if (MLX5_CAP_GEN(dev->mdev, log_max_transport_domain))
 		mlx5_core_dealloc_transport_domain(dev->mdev, context->tdn);
 
 	free_page(context->upd_xlt_page);
-
-	for (i = 0; i < bfregi->num_uars; i++) {
-		if (mlx5_cmd_free_uar(dev->mdev, bfregi->uars[i].index))
-			mlx5_ib_warn(dev, "Failed to free UAR 0x%x\n",
-				     bfregi->uars[i].index);
-	}
-
+	deallocate_uars(dev, context);
+	kfree(bfregi->sys_pages);
 	kfree(bfregi->count);
-	kfree(bfregi->bitmap);
-	kfree(bfregi->uars);
 	kfree(context);
 
 	return 0;
 }
 
-static phys_addr_t uar_index2pfn(struct mlx5_ib_dev *dev, int index)
+static phys_addr_t uar_index2pfn(struct mlx5_ib_dev *dev,
+				 struct mlx5_bfreg_info *bfregi,
+				 int idx)
 {
-	return (pci_resource_start(dev->mdev->pdev, 0) >> PAGE_SHIFT) + index;
+	int fw_uars_per_page;
+
+	fw_uars_per_page = MLX5_CAP_GEN(dev->mdev, uar_4k) ? MLX5_UARS_IN_PAGE : 1;
+
+	return (pci_resource_start(dev->mdev->pdev, 0) >> PAGE_SHIFT) +
+			bfregi->sys_pages[idx] / fw_uars_per_page;
 }
 
 static int get_command(unsigned long offset)
@@ -1384,6 +1430,18 @@ static int uar_mmap(struct mlx5_ib_dev *dev, enum mlx5_ib_mmap_cmd cmd,
 	unsigned long idx;
 	phys_addr_t pfn, pa;
 	pgprot_t prot;
+	int uars_per_page;
+
+	if (vma->vm_end - vma->vm_start != PAGE_SIZE)
+		return -EINVAL;
+
+	uars_per_page = get_uars_per_sys_page(dev, bfregi->lib_uar_4k);
+	idx = get_index(vma->vm_pgoff);
+	if (idx % uars_per_page ||
+	    idx * uars_per_page >= bfregi->num_sys_pages) {
+		mlx5_ib_warn(dev, "invalid uar index %lu\n", idx);
+		return -EINVAL;
+	}
 
 	switch (cmd) {
 	case MLX5_IB_MMAP_WC_PAGE:
@@ -1406,14 +1464,7 @@ static int uar_mmap(struct mlx5_ib_dev *dev, enum mlx5_ib_mmap_cmd cmd,
 		return -EINVAL;
 	}
 
-	if (vma->vm_end - vma->vm_start != PAGE_SIZE)
-		return -EINVAL;
-
-	idx = get_index(vma->vm_pgoff);
-	if (idx >= bfregi->num_uars)
-		return -EINVAL;
-
-	pfn = uar_index2pfn(dev, bfregi->uars[idx].index);
+	pfn = uar_index2pfn(dev, bfregi, idx);
 	mlx5_ib_dbg(dev, "uar idx 0x%lx, pfn %pa\n", idx, &pfn);
 
 	vma->vm_page_prot = prot;
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index ae3bc4a..e1a4b93d 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -90,7 +90,6 @@ enum mlx5_ib_latency_class {
 	MLX5_IB_LATENCY_CLASS_LOW,
 	MLX5_IB_LATENCY_CLASS_MEDIUM,
 	MLX5_IB_LATENCY_CLASS_HIGH,
-	MLX5_IB_LATENCY_CLASS_FAST_PATH
 };
 
 enum mlx5_ib_mad_ifc_flags {
@@ -129,6 +128,7 @@ struct mlx5_ib_ucontext {
 	unsigned long		upd_xlt_page;
 	/* protect ODP/KSM */
 	struct mutex		upd_xlt_page_mutex;
+	u64			lib_caps;
 };
 
 static inline struct mlx5_ib_ucontext *to_mucontext(struct ib_ucontext *ibucontext)
@@ -975,4 +975,17 @@ static inline int get_srq_user_index(struct mlx5_ib_ucontext *ucontext,
 
 	return verify_assign_uidx(cqe_version, ucmd->uidx, user_index);
 }
+
+static inline int get_uars_per_sys_page(struct mlx5_ib_dev *dev, bool lib_support)
+{
+	return lib_support && MLX5_CAP_GEN(dev->mdev, uar_4k) ?
+				MLX5_UARS_IN_PAGE : 1;
+}
+
+static inline int get_num_uars(struct mlx5_ib_dev *dev,
+			       struct mlx5_bfreg_info *bfregi)
+{
+	return get_uars_per_sys_page(dev, bfregi->lib_uar_4k) * bfregi->num_sys_pages;
+}
+
 #endif /* MLX5_IB_H */
diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index fce1c6d..6a83fb3 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -480,16 +480,6 @@ static int first_med_bfreg(void)
 	return 1;
 }
 
-static int next_bfreg(int n)
-{
-	n++;
-
-	while (((n % 4) & 2))
-		n++;
-
-	return n;
-}
-
 enum {
 	/* this is the first blue flame register in the array of bfregs assigned
 	 * to a processes. Since we do not use it for blue flame but rather
@@ -499,36 +489,38 @@ enum {
 	NUM_NON_BLUE_FLAME_BFREGS = 1,
 };
 
-static int num_med_bfreg(struct mlx5_bfreg_info *bfregi)
+static int max_bfregs(struct mlx5_ib_dev *dev, struct mlx5_bfreg_info *bfregi)
+{
+	return get_num_uars(dev, bfregi) * MLX5_NON_FP_BFREGS_PER_UAR;
+}
+
+static int num_med_bfreg(struct mlx5_ib_dev *dev,
+			 struct mlx5_bfreg_info *bfregi)
 {
 	int n;
 
-	n = bfregi->num_uars * MLX5_NON_FP_BFREGS_PER_UAR -
-		bfregi->num_low_latency_bfregs - NUM_NON_BLUE_FLAME_BFREGS;
+	n = max_bfregs(dev, bfregi) - bfregi->num_low_latency_bfregs -
+	    NUM_NON_BLUE_FLAME_BFREGS;
 
 	return n >= 0 ? n : 0;
 }
 
-static int max_bfregi(struct mlx5_bfreg_info *bfregi)
-{
-	return bfregi->num_uars * 4;
-}
-
-static int first_hi_bfreg(struct mlx5_bfreg_info *bfregi)
+static int first_hi_bfreg(struct mlx5_ib_dev *dev,
+			  struct mlx5_bfreg_info *bfregi)
 {
 	int med;
 
-	med = num_med_bfreg(bfregi);
-	return next_bfreg(med);
+	med = num_med_bfreg(dev, bfregi);
+	return ++med;
 }
 
-static int alloc_high_class_bfreg(struct mlx5_bfreg_info *bfregi)
+static int alloc_high_class_bfreg(struct mlx5_ib_dev *dev,
+				  struct mlx5_bfreg_info *bfregi)
 {
 	int i;
 
-	for (i = first_hi_bfreg(bfregi); i < max_bfregi(bfregi); i = next_bfreg(i)) {
-		if (!test_bit(i, bfregi->bitmap)) {
-			set_bit(i, bfregi->bitmap);
+	for (i = first_hi_bfreg(dev, bfregi); i < max_bfregs(dev, bfregi); i++) {
+		if (!bfregi->count[i]) {
 			bfregi->count[i]++;
 			return i;
 		}
@@ -537,12 +529,13 @@ static int alloc_high_class_bfreg(struct mlx5_bfreg_info *bfregi)
 	return -ENOMEM;
 }
 
-static int alloc_med_class_bfreg(struct mlx5_bfreg_info *bfregi)
+static int alloc_med_class_bfreg(struct mlx5_ib_dev *dev,
+				 struct mlx5_bfreg_info *bfregi)
 {
 	int minidx = first_med_bfreg();
 	int i;
 
-	for (i = first_med_bfreg(); i < first_hi_bfreg(bfregi); i = next_bfreg(i)) {
+	for (i = first_med_bfreg(); i < first_hi_bfreg(dev, bfregi); i++) {
 		if (bfregi->count[i] < bfregi->count[minidx])
 			minidx = i;
 		if (!bfregi->count[minidx])
@@ -553,7 +546,8 @@ static int alloc_med_class_bfreg(struct mlx5_bfreg_info *bfregi)
 	return minidx;
 }
 
-static int alloc_bfreg(struct mlx5_bfreg_info *bfregi,
+static int alloc_bfreg(struct mlx5_ib_dev *dev,
+		       struct mlx5_bfreg_info *bfregi,
 		       enum mlx5_ib_latency_class lat)
 {
 	int bfregn = -EINVAL;
@@ -570,18 +564,14 @@ static int alloc_bfreg(struct mlx5_bfreg_info *bfregi,
 		if (bfregi->ver < 2)
 			bfregn = -ENOMEM;
 		else
-			bfregn = alloc_med_class_bfreg(bfregi);
+			bfregn = alloc_med_class_bfreg(dev, bfregi);
 		break;
 
 	case MLX5_IB_LATENCY_CLASS_HIGH:
 		if (bfregi->ver < 2)
 			bfregn = -ENOMEM;
 		else
-			bfregn = alloc_high_class_bfreg(bfregi);
-		break;
-
-	case MLX5_IB_LATENCY_CLASS_FAST_PATH:
-		bfregn = 2;
+			bfregn = alloc_high_class_bfreg(dev, bfregi);
 		break;
 	}
 	mutex_unlock(&bfregi->lock);
@@ -589,37 +579,10 @@ static int alloc_bfreg(struct mlx5_bfreg_info *bfregi,
 	return bfregn;
 }
 
-static void free_med_class_bfreg(struct mlx5_bfreg_info *bfregi, int bfregn)
+static void free_bfreg(struct mlx5_ib_dev *dev, struct mlx5_bfreg_info *bfregi, int bfregn)
 {
-	clear_bit(bfregn, bfregi->bitmap);
-	--bfregi->count[bfregn];
-}
-
-static void free_high_class_bfreg(struct mlx5_bfreg_info *bfregi, int bfregn)
-{
-	clear_bit(bfregn, bfregi->bitmap);
-	--bfregi->count[bfregn];
-}
-
-static void free_bfreg(struct mlx5_bfreg_info *bfregi, int bfregn)
-{
-	int nbfregs = bfregi->num_uars * MLX5_BFREGS_PER_UAR;
-	int high_bfreg = nbfregs - bfregi->num_low_latency_bfregs;
-
 	mutex_lock(&bfregi->lock);
-	if (bfregn == 0) {
-		--bfregi->count[bfregn];
-		goto out;
-	}
-
-	if (bfregn < high_bfreg) {
-		free_med_class_bfreg(bfregi, bfregn);
-		goto out;
-	}
-
-	free_high_class_bfreg(bfregi, bfregn);
-
-out:
+	bfregi->count[bfregn]--;
 	mutex_unlock(&bfregi->lock);
 }
 
@@ -661,9 +624,20 @@ static void mlx5_ib_lock_cqs(struct mlx5_ib_cq *send_cq,
 static void mlx5_ib_unlock_cqs(struct mlx5_ib_cq *send_cq,
 			       struct mlx5_ib_cq *recv_cq);
 
-static int bfregn_to_uar_index(struct mlx5_bfreg_info *bfregi, int bfregn)
+static int bfregn_to_uar_index(struct mlx5_ib_dev *dev,
+			       struct mlx5_bfreg_info *bfregi, int bfregn)
 {
-	return bfregi->uars[bfregn / MLX5_BFREGS_PER_UAR].index;
+	int bfregs_per_sys_page;
+	int index_of_sys_page;
+	int offset;
+
+	bfregs_per_sys_page = get_uars_per_sys_page(dev, bfregi->lib_uar_4k) *
+				MLX5_NON_FP_BFREGS_PER_UAR;
+	index_of_sys_page = bfregn / bfregs_per_sys_page;
+
+	offset = bfregn % bfregs_per_sys_page / MLX5_NON_FP_BFREGS_PER_UAR;
+
+	return bfregi->sys_pages[index_of_sys_page] + offset;
 }
 
 static int mlx5_ib_umem_get(struct mlx5_ib_dev *dev,
@@ -766,6 +740,13 @@ static int create_user_rq(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 	return err;
 }
 
+static int adjust_bfregn(struct mlx5_ib_dev *dev,
+			 struct mlx5_bfreg_info *bfregi, int bfregn)
+{
+	return bfregn / MLX5_NON_FP_BFREGS_PER_UAR * MLX5_BFREGS_PER_UAR +
+				bfregn % MLX5_NON_FP_BFREGS_PER_UAR;
+}
+
 static int create_user_qp(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 			  struct mlx5_ib_qp *qp, struct ib_udata *udata,
 			  struct ib_qp_init_attr *attr,
@@ -800,15 +781,15 @@ static int create_user_qp(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 		/* In CROSS_CHANNEL CQ and QP must use the same UAR */
 		bfregn = MLX5_CROSS_CHANNEL_BFREG;
 	else {
-		bfregn = alloc_bfreg(&context->bfregi, MLX5_IB_LATENCY_CLASS_HIGH);
+		bfregn = alloc_bfreg(dev, &context->bfregi, MLX5_IB_LATENCY_CLASS_HIGH);
 		if (bfregn < 0) {
 			mlx5_ib_dbg(dev, "failed to allocate low latency BFREG\n");
 			mlx5_ib_dbg(dev, "reverting to medium latency\n");
-			bfregn = alloc_bfreg(&context->bfregi, MLX5_IB_LATENCY_CLASS_MEDIUM);
+			bfregn = alloc_bfreg(dev, &context->bfregi, MLX5_IB_LATENCY_CLASS_MEDIUM);
 			if (bfregn < 0) {
 				mlx5_ib_dbg(dev, "failed to allocate medium latency BFREG\n");
 				mlx5_ib_dbg(dev, "reverting to high latency\n");
-				bfregn = alloc_bfreg(&context->bfregi, MLX5_IB_LATENCY_CLASS_LOW);
+				bfregn = alloc_bfreg(dev, &context->bfregi, MLX5_IB_LATENCY_CLASS_LOW);
 				if (bfregn < 0) {
 					mlx5_ib_warn(dev, "bfreg allocation failed\n");
 					return bfregn;
@@ -817,7 +798,7 @@ static int create_user_qp(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 		}
 	}
 
-	uar_index = bfregn_to_uar_index(&context->bfregi, bfregn);
+	uar_index = bfregn_to_uar_index(dev, &context->bfregi, bfregn);
 	mlx5_ib_dbg(dev, "bfregn 0x%x, uar_index 0x%x\n", bfregn, uar_index);
 
 	qp->rq.offset = 0;
@@ -858,7 +839,7 @@ static int create_user_qp(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 	MLX5_SET(qpc, qpc, page_offset, offset);
 
 	MLX5_SET(qpc, qpc, uar_page, uar_index);
-	resp->bfreg_index = bfregn;
+	resp->bfreg_index = adjust_bfregn(dev, &context->bfregi, bfregn);
 	qp->bfregn = bfregn;
 
 	err = mlx5_ib_db_map_user(context, ucmd.db_addr, &qp->db);
@@ -887,12 +868,12 @@ static int create_user_qp(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 		ib_umem_release(ubuffer->umem);
 
 err_bfreg:
-	free_bfreg(&context->bfregi, bfregn);
+	free_bfreg(dev, &context->bfregi, bfregn);
 	return err;
 }
 
-static void destroy_qp_user(struct ib_pd *pd, struct mlx5_ib_qp *qp,
-			    struct mlx5_ib_qp_base *base)
+static void destroy_qp_user(struct mlx5_ib_dev *dev, struct ib_pd *pd,
+			    struct mlx5_ib_qp *qp, struct mlx5_ib_qp_base *base)
 {
 	struct mlx5_ib_ucontext *context;
 
@@ -900,7 +881,7 @@ static void destroy_qp_user(struct ib_pd *pd, struct mlx5_ib_qp *qp,
 	mlx5_ib_db_unmap_user(context, &qp->db);
 	if (base->ubuffer.umem)
 		ib_umem_release(base->ubuffer.umem);
-	free_bfreg(&context->bfregi, qp->bfregn);
+	free_bfreg(dev, &context->bfregi, qp->bfregn);
 }
 
 static int create_kernel_qp(struct mlx5_ib_dev *dev,
@@ -1784,7 +1765,7 @@ static int create_qp_common(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 
 err_create:
 	if (qp->create_type == MLX5_QP_USER)
-		destroy_qp_user(pd, qp, base);
+		destroy_qp_user(dev, pd, qp, base);
 	else if (qp->create_type == MLX5_QP_KERNEL)
 		destroy_qp_kernel(dev, qp);
 
@@ -1962,7 +1943,7 @@ static void destroy_qp_common(struct mlx5_ib_dev *dev, struct mlx5_ib_qp *qp)
 	if (qp->create_type == MLX5_QP_KERNEL)
 		destroy_qp_kernel(dev, qp);
 	else if (qp->create_type == MLX5_QP_USER)
-		destroy_qp_user(&get_pd(qp)->ibpd, qp, base);
+		destroy_qp_user(dev, &get_pd(qp)->ibpd, qp, base);
 }
 
 static const char *ib_qp_type_str(enum ib_qp_type type)
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index db1b928..dd345e8 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -212,6 +212,11 @@ enum {
 };
 
 enum {
+	MLX5_ADAPTER_PAGE_SHIFT		= 12,
+	MLX5_ADAPTER_PAGE_SIZE		= 1 << MLX5_ADAPTER_PAGE_SHIFT,
+};
+
+enum {
 	MLX5_BFREGS_PER_UAR		= 4,
 	MLX5_MAX_UARS			= 1 << 8,
 	MLX5_NON_FP_BFREGS_PER_UAR	= 2,
@@ -219,6 +224,8 @@ enum {
 					  MLX5_NON_FP_BFREGS_PER_UAR,
 	MLX5_MAX_BFREGS			= MLX5_MAX_UARS *
 					  MLX5_NON_FP_BFREGS_PER_UAR,
+	MLX5_UARS_IN_PAGE		= PAGE_SIZE / MLX5_ADAPTER_PAGE_SIZE,
+	MLX5_NON_FP_BFREGS_IN_PAGE	= MLX5_NON_FP_BFREGS_PER_UAR * MLX5_UARS_IN_PAGE,
 };
 
 enum {
@@ -392,11 +399,6 @@ enum {
 };
 
 enum {
-	MLX5_ADAPTER_PAGE_SHIFT		= 12,
-	MLX5_ADAPTER_PAGE_SIZE		= 1 << MLX5_ADAPTER_PAGE_SHIFT,
-};
-
-enum {
 	MLX5_CAP_OFF_CMDIF_CSUM		= 46,
 };
 
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index bb362f5..7e7394f 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -189,18 +189,17 @@ enum mlx5_eq_type {
 };
 
 struct mlx5_bfreg_info {
-	struct mlx5_uar	       *uars;
-	int			num_uars;
+	u32		       *sys_pages;
 	int			num_low_latency_bfregs;
-	unsigned long	       *bitmap;
 	unsigned int	       *count;
-	struct mlx5_bf	       *bfs;
 
 	/*
 	 * protect bfreg allocation data structs
 	 */
 	struct mutex		lock;
 	u32			ver;
+	bool			lib_uar_4k;
+	u32			num_sys_pages;
 };
 
 struct mlx5_cmd_first {
@@ -470,13 +469,10 @@ struct mlx5_sq_bfreg {
 
 struct mlx5_uar {
 	u32			index;
-	struct list_head	bf_list;
-	unsigned		free_bf_bmap;
-	void __iomem	       *bf_map;
 	void __iomem	       *map;
+	void __iomem	       *bf_map;
 };
 
-
 struct mlx5_core_health {
 	struct health_buffer __iomem   *health;
 	__be32 __iomem		       *health_counter;
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
