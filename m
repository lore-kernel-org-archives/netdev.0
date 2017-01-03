From: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: [for-next 03/10] mlx5: Fix naming convention with respect to UARs
Date: Tue,  3 Jan 2017 23:55:21 +0200
Message-ID: <1483480528-22622-4-git-send-email-saeedm@mellanox.com>
References: <1483480528-22622-1-git-send-email-saeedm@mellanox.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1483480528-22622-1-git-send-email-saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

This establishes a solid naming conventions for UARs. A UAR (User Access
Region) can have size identical to a system page or can be fixed 4KB
depending on a value queried by firmware. Each UAR always has 4 blue
flame register which are used to post doorbell to send queue. In
addition, a UAR has section used for posting doorbells to CQs or EQs. In
this patch we change names to reflect this conventions.

Signed-off-by: Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Reviewed-by: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Signed-off-by: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Signed-off-by: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
---
 drivers/infiniband/hw/mlx5/cq.c                |   6 +-
 drivers/infiniband/hw/mlx5/main.c              |  80 +++++------
 drivers/infiniband/hw/mlx5/mlx5_ib.h           |   6 +-
 drivers/infiniband/hw/mlx5/qp.c                | 176 ++++++++++++-------------
 drivers/net/ethernet/mellanox/mlx5/core/eq.c   |   8 +-
 drivers/net/ethernet/mellanox/mlx5/core/main.c |   8 +-
 drivers/net/ethernet/mellanox/mlx5/core/uar.c  |  90 ++++++-------
 include/linux/mlx5/device.h                    |   9 +-
 include/linux/mlx5/driver.h                    |  14 +-
 include/uapi/rdma/mlx5-abi.h                   |  12 +-
 10 files changed, 206 insertions(+), 203 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/cq.c b/drivers/infiniband/hw/mlx5/cq.c
index b3ef47c..bb7e91c 100644
--- a/drivers/infiniband/hw/mlx5/cq.c
+++ b/drivers/infiniband/hw/mlx5/cq.c
@@ -689,7 +689,7 @@ int mlx5_ib_arm_cq(struct ib_cq *ibcq, enum ib_cq_notify_flags flags)
 {
 	struct mlx5_core_dev *mdev = to_mdev(ibcq->device)->mdev;
 	struct mlx5_ib_cq *cq = to_mcq(ibcq);
-	void __iomem *uar_page = mdev->priv.uuari.uars[0].map;
+	void __iomem *uar_page = mdev->priv.bfregi.uars[0].map;
 	unsigned long irq_flags;
 	int ret = 0;
 
@@ -790,7 +790,7 @@ static int create_cq_user(struct mlx5_ib_dev *dev, struct ib_udata *udata,
 	MLX5_SET(cqc, cqc, log_page_size,
 		 page_shift - MLX5_ADAPTER_PAGE_SHIFT);
 
-	*index = to_mucontext(context)->uuari.uars[0].index;
+	*index = to_mucontext(context)->bfregi.uars[0].index;
 
 	if (ucmd.cqe_comp_en == 1) {
 		if (unlikely((*cqe_size != 64) ||
@@ -886,7 +886,7 @@ static int create_cq_kernel(struct mlx5_ib_dev *dev, struct mlx5_ib_cq *cq,
 	MLX5_SET(cqc, cqc, log_page_size,
 		 cq->buf.buf.page_shift - MLX5_ADAPTER_PAGE_SHIFT);
 
-	*index = dev->mdev->priv.uuari.uars[0].index;
+	*index = dev->mdev->priv.bfregi.uars[0].index;
 
 	return 0;
 
diff --git a/drivers/infiniband/hw/mlx5/main.c b/drivers/infiniband/hw/mlx5/main.c
index 852b5b7..d5cf82b 100644
--- a/drivers/infiniband/hw/mlx5/main.c
+++ b/drivers/infiniband/hw/mlx5/main.c
@@ -999,12 +999,12 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	struct mlx5_ib_alloc_ucontext_req_v2 req = {};
 	struct mlx5_ib_alloc_ucontext_resp resp = {};
 	struct mlx5_ib_ucontext *context;
-	struct mlx5_uuar_info *uuari;
+	struct mlx5_bfreg_info *bfregi;
 	struct mlx5_uar *uars;
-	int gross_uuars;
+	int gross_bfregs;
 	int num_uars;
 	int ver;
-	int uuarn;
+	int bfregn;
 	int err;
 	int i;
 	size_t reqlen;
@@ -1032,10 +1032,10 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	if (req.flags)
 		return ERR_PTR(-EINVAL);
 
-	if (req.total_num_uuars > MLX5_MAX_UUARS)
+	if (req.total_num_bfregs > MLX5_MAX_BFREGS)
 		return ERR_PTR(-ENOMEM);
 
-	if (req.total_num_uuars == 0)
+	if (req.total_num_bfregs == 0)
 		return ERR_PTR(-EINVAL);
 
 	if (req.comp_mask || req.reserved0 || req.reserved1 || req.reserved2)
@@ -1046,13 +1046,13 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 				 reqlen - sizeof(req)))
 		return ERR_PTR(-EOPNOTSUPP);
 
-	req.total_num_uuars = ALIGN(req.total_num_uuars,
-				    MLX5_NON_FP_BF_REGS_PER_PAGE);
-	if (req.num_low_latency_uuars > req.total_num_uuars - 1)
+	req.total_num_bfregs = ALIGN(req.total_num_bfregs,
+				    MLX5_NON_FP_BFREGS_PER_UAR);
+	if (req.num_low_latency_bfregs > req.total_num_bfregs - 1)
 		return ERR_PTR(-EINVAL);
 
-	num_uars = req.total_num_uuars / MLX5_NON_FP_BF_REGS_PER_PAGE;
-	gross_uuars = num_uars * MLX5_BF_REGS_PER_PAGE;
+	num_uars = req.total_num_bfregs / MLX5_NON_FP_BFREGS_PER_UAR;
+	gross_bfregs = num_uars * MLX5_BFREGS_PER_UAR;
 	resp.qp_tab_size = 1 << MLX5_CAP_GEN(dev->mdev, log_max_qp);
 	if (mlx5_core_is_pf(dev->mdev) && MLX5_CAP_GEN(dev->mdev, bf))
 		resp.bf_reg_size = 1 << MLX5_CAP_GEN(dev->mdev, log_bf_reg_size);
@@ -1072,32 +1072,33 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	if (!context)
 		return ERR_PTR(-ENOMEM);
 
-	uuari = &context->uuari;
-	mutex_init(&uuari->lock);
+	bfregi = &context->bfregi;
+	mutex_init(&bfregi->lock);
 	uars = kcalloc(num_uars, sizeof(*uars), GFP_KERNEL);
 	if (!uars) {
 		err = -ENOMEM;
 		goto out_ctx;
 	}
 
-	uuari->bitmap = kcalloc(BITS_TO_LONGS(gross_uuars),
-				sizeof(*uuari->bitmap),
+	bfregi->bitmap = kcalloc(BITS_TO_LONGS(gross_bfregs),
+				sizeof(*bfregi->bitmap),
 				GFP_KERNEL);
-	if (!uuari->bitmap) {
+	if (!bfregi->bitmap) {
 		err = -ENOMEM;
 		goto out_uar_ctx;
 	}
 	/*
-	 * clear all fast path uuars
+	 * clear all fast path bfregs
 	 */
-	for (i = 0; i < gross_uuars; i++) {
-		uuarn = i & 3;
-		if (uuarn == 2 || uuarn == 3)
-			set_bit(i, uuari->bitmap);
+	for (i = 0; i < gross_bfregs; i++) {
+		bfregn = i & 3;
+		if (bfregn == 2 || bfregn == 3)
+			set_bit(i, bfregi->bitmap);
 	}
 
-	uuari->count = kcalloc(gross_uuars, sizeof(*uuari->count), GFP_KERNEL);
-	if (!uuari->count) {
+	bfregi->count = kcalloc(gross_bfregs,
+				sizeof(*bfregi->count), GFP_KERNEL);
+	if (!bfregi->count) {
 		err = -ENOMEM;
 		goto out_bitmap;
 	}
@@ -1130,7 +1131,7 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	INIT_LIST_HEAD(&context->db_page_list);
 	mutex_init(&context->db_page_mutex);
 
-	resp.tot_uuars = req.total_num_uuars;
+	resp.tot_bfregs = req.total_num_bfregs;
 	resp.num_ports = MLX5_CAP_GEN(dev->mdev, num_ports);
 
 	if (field_avail(typeof(resp), cqe_version, udata->outlen))
@@ -1163,10 +1164,10 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	if (err)
 		goto out_td;
 
-	uuari->ver = ver;
-	uuari->num_low_latency_uuars = req.num_low_latency_uuars;
-	uuari->uars = uars;
-	uuari->num_uars = num_uars;
+	bfregi->ver = ver;
+	bfregi->num_low_latency_bfregs = req.num_low_latency_bfregs;
+	bfregi->uars = uars;
+	bfregi->num_uars = num_uars;
 	context->cqe_version = resp.cqe_version;
 
 	return &context->ibucontext;
@@ -1182,10 +1183,10 @@ static struct ib_ucontext *mlx5_ib_alloc_ucontext(struct ib_device *ibdev,
 	for (i--; i >= 0; i--)
 		mlx5_cmd_free_uar(dev->mdev, uars[i].index);
 out_count:
-	kfree(uuari->count);
+	kfree(bfregi->count);
 
 out_bitmap:
-	kfree(uuari->bitmap);
+	kfree(bfregi->bitmap);
 
 out_uar_ctx:
 	kfree(uars);
@@ -1199,7 +1200,7 @@ static int mlx5_ib_dealloc_ucontext(struct ib_ucontext *ibcontext)
 {
 	struct mlx5_ib_ucontext *context = to_mucontext(ibcontext);
 	struct mlx5_ib_dev *dev = to_mdev(ibcontext->device);
-	struct mlx5_uuar_info *uuari = &context->uuari;
+	struct mlx5_bfreg_info *bfregi = &context->bfregi;
 	int i;
 
 	if (MLX5_CAP_GEN(dev->mdev, log_max_transport_domain))
@@ -1207,14 +1208,15 @@ static int mlx5_ib_dealloc_ucontext(struct ib_ucontext *ibcontext)
 
 	free_page(context->upd_xlt_page);
 
-	for (i = 0; i < uuari->num_uars; i++) {
-		if (mlx5_cmd_free_uar(dev->mdev, uuari->uars[i].index))
-			mlx5_ib_warn(dev, "failed to free UAR 0x%x\n", uuari->uars[i].index);
+	for (i = 0; i < bfregi->num_uars; i++) {
+		if (mlx5_cmd_free_uar(dev->mdev, bfregi->uars[i].index))
+			mlx5_ib_warn(dev, "Failed to free UAR 0x%x\n",
+				     bfregi->uars[i].index);
 	}
 
-	kfree(uuari->count);
-	kfree(uuari->bitmap);
-	kfree(uuari->uars);
+	kfree(bfregi->count);
+	kfree(bfregi->bitmap);
+	kfree(bfregi->uars);
 	kfree(context);
 
 	return 0;
@@ -1377,7 +1379,7 @@ static int uar_mmap(struct mlx5_ib_dev *dev, enum mlx5_ib_mmap_cmd cmd,
 		    struct vm_area_struct *vma,
 		    struct mlx5_ib_ucontext *context)
 {
-	struct mlx5_uuar_info *uuari = &context->uuari;
+	struct mlx5_bfreg_info *bfregi = &context->bfregi;
 	int err;
 	unsigned long idx;
 	phys_addr_t pfn, pa;
@@ -1408,10 +1410,10 @@ static int uar_mmap(struct mlx5_ib_dev *dev, enum mlx5_ib_mmap_cmd cmd,
 		return -EINVAL;
 
 	idx = get_index(vma->vm_pgoff);
-	if (idx >= uuari->num_uars)
+	if (idx >= bfregi->num_uars)
 		return -EINVAL;
 
-	pfn = uar_index2pfn(dev, uuari->uars[idx].index);
+	pfn = uar_index2pfn(dev, bfregi->uars[idx].index);
 	mlx5_ib_dbg(dev, "uar idx 0x%lx, pfn %pa\n", idx, &pfn);
 
 	vma->vm_page_prot = prot;
diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index a51c805..d4d1329 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -100,7 +100,7 @@ enum mlx5_ib_mad_ifc_flags {
 };
 
 enum {
-	MLX5_CROSS_CHANNEL_UUAR         = 0,
+	MLX5_CROSS_CHANNEL_BFREG         = 0,
 };
 
 enum {
@@ -120,7 +120,7 @@ struct mlx5_ib_ucontext {
 	/* protect doorbell record alloc/free
 	 */
 	struct mutex		db_page_mutex;
-	struct mlx5_uuar_info	uuari;
+	struct mlx5_bfreg_info	bfregi;
 	u8			cqe_version;
 	/* Transport Domain number */
 	u32			tdn;
@@ -355,7 +355,7 @@ struct mlx5_ib_qp {
 	/* only for user space QPs. For kernel
 	 * we have it from the bf object
 	 */
-	int			uuarn;
+	int			bfregn;
 
 	int			create_type;
 
diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index 42d021cd..fbea9bd 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -475,12 +475,12 @@ static int qp_has_rq(struct ib_qp_init_attr *attr)
 	return 1;
 }
 
-static int first_med_uuar(void)
+static int first_med_bfreg(void)
 {
 	return 1;
 }
 
-static int next_uuar(int n)
+static int next_bfreg(int n)
 {
 	n++;
 
@@ -490,45 +490,45 @@ static int next_uuar(int n)
 	return n;
 }
 
-static int num_med_uuar(struct mlx5_uuar_info *uuari)
+static int num_med_bfreg(struct mlx5_bfreg_info *bfregi)
 {
 	int n;
 
-	n = uuari->num_uars * MLX5_NON_FP_BF_REGS_PER_PAGE -
-		uuari->num_low_latency_uuars - 1;
+	n = bfregi->num_uars * MLX5_NON_FP_BFREGS_PER_UAR -
+		bfregi->num_low_latency_bfregs - 1;
 
 	return n >= 0 ? n : 0;
 }
 
-static int max_uuari(struct mlx5_uuar_info *uuari)
+static int max_bfregi(struct mlx5_bfreg_info *bfregi)
 {
-	return uuari->num_uars * 4;
+	return bfregi->num_uars * 4;
 }
 
-static int first_hi_uuar(struct mlx5_uuar_info *uuari)
+static int first_hi_bfreg(struct mlx5_bfreg_info *bfregi)
 {
 	int med;
 	int i;
 	int t;
 
-	med = num_med_uuar(uuari);
-	for (t = 0, i = first_med_uuar();; i = next_uuar(i)) {
+	med = num_med_bfreg(bfregi);
+	for (t = 0, i = first_med_bfreg();; i = next_bfreg(i)) {
 		t++;
 		if (t == med)
-			return next_uuar(i);
+			return next_bfreg(i);
 	}
 
 	return 0;
 }
 
-static int alloc_high_class_uuar(struct mlx5_uuar_info *uuari)
+static int alloc_high_class_bfreg(struct mlx5_bfreg_info *bfregi)
 {
 	int i;
 
-	for (i = first_hi_uuar(uuari); i < max_uuari(uuari); i = next_uuar(i)) {
-		if (!test_bit(i, uuari->bitmap)) {
-			set_bit(i, uuari->bitmap);
-			uuari->count[i]++;
+	for (i = first_hi_bfreg(bfregi); i < max_bfregi(bfregi); i = next_bfreg(i)) {
+		if (!test_bit(i, bfregi->bitmap)) {
+			set_bit(i, bfregi->bitmap);
+			bfregi->count[i]++;
 			return i;
 		}
 	}
@@ -536,87 +536,87 @@ static int alloc_high_class_uuar(struct mlx5_uuar_info *uuari)
 	return -ENOMEM;
 }
 
-static int alloc_med_class_uuar(struct mlx5_uuar_info *uuari)
+static int alloc_med_class_bfreg(struct mlx5_bfreg_info *bfregi)
 {
-	int minidx = first_med_uuar();
+	int minidx = first_med_bfreg();
 	int i;
 
-	for (i = first_med_uuar(); i < first_hi_uuar(uuari); i = next_uuar(i)) {
-		if (uuari->count[i] < uuari->count[minidx])
+	for (i = first_med_bfreg(); i < first_hi_bfreg(bfregi); i = next_bfreg(i)) {
+		if (bfregi->count[i] < bfregi->count[minidx])
 			minidx = i;
 	}
 
-	uuari->count[minidx]++;
+	bfregi->count[minidx]++;
 	return minidx;
 }
 
-static int alloc_uuar(struct mlx5_uuar_info *uuari,
-		      enum mlx5_ib_latency_class lat)
+static int alloc_bfreg(struct mlx5_bfreg_info *bfregi,
+		       enum mlx5_ib_latency_class lat)
 {
-	int uuarn = -EINVAL;
+	int bfregn = -EINVAL;
 
-	mutex_lock(&uuari->lock);
+	mutex_lock(&bfregi->lock);
 	switch (lat) {
 	case MLX5_IB_LATENCY_CLASS_LOW:
-		uuarn = 0;
-		uuari->count[uuarn]++;
+		bfregn = 0;
+		bfregi->count[bfregn]++;
 		break;
 
 	case MLX5_IB_LATENCY_CLASS_MEDIUM:
-		if (uuari->ver < 2)
-			uuarn = -ENOMEM;
+		if (bfregi->ver < 2)
+			bfregn = -ENOMEM;
 		else
-			uuarn = alloc_med_class_uuar(uuari);
+			bfregn = alloc_med_class_bfreg(bfregi);
 		break;
 
 	case MLX5_IB_LATENCY_CLASS_HIGH:
-		if (uuari->ver < 2)
-			uuarn = -ENOMEM;
+		if (bfregi->ver < 2)
+			bfregn = -ENOMEM;
 		else
-			uuarn = alloc_high_class_uuar(uuari);
+			bfregn = alloc_high_class_bfreg(bfregi);
 		break;
 
 	case MLX5_IB_LATENCY_CLASS_FAST_PATH:
-		uuarn = 2;
+		bfregn = 2;
 		break;
 	}
-	mutex_unlock(&uuari->lock);
+	mutex_unlock(&bfregi->lock);
 
-	return uuarn;
+	return bfregn;
 }
 
-static void free_med_class_uuar(struct mlx5_uuar_info *uuari, int uuarn)
+static void free_med_class_bfreg(struct mlx5_bfreg_info *bfregi, int bfregn)
 {
-	clear_bit(uuarn, uuari->bitmap);
-	--uuari->count[uuarn];
+	clear_bit(bfregn, bfregi->bitmap);
+	--bfregi->count[bfregn];
 }
 
-static void free_high_class_uuar(struct mlx5_uuar_info *uuari, int uuarn)
+static void free_high_class_bfreg(struct mlx5_bfreg_info *bfregi, int bfregn)
 {
-	clear_bit(uuarn, uuari->bitmap);
-	--uuari->count[uuarn];
+	clear_bit(bfregn, bfregi->bitmap);
+	--bfregi->count[bfregn];
 }
 
-static void free_uuar(struct mlx5_uuar_info *uuari, int uuarn)
+static void free_bfreg(struct mlx5_bfreg_info *bfregi, int bfregn)
 {
-	int nuuars = uuari->num_uars * MLX5_BF_REGS_PER_PAGE;
-	int high_uuar = nuuars - uuari->num_low_latency_uuars;
+	int nbfregs = bfregi->num_uars * MLX5_BFREGS_PER_UAR;
+	int high_bfreg = nbfregs - bfregi->num_low_latency_bfregs;
 
-	mutex_lock(&uuari->lock);
-	if (uuarn == 0) {
-		--uuari->count[uuarn];
+	mutex_lock(&bfregi->lock);
+	if (bfregn == 0) {
+		--bfregi->count[bfregn];
 		goto out;
 	}
 
-	if (uuarn < high_uuar) {
-		free_med_class_uuar(uuari, uuarn);
+	if (bfregn < high_bfreg) {
+		free_med_class_bfreg(bfregi, bfregn);
 		goto out;
 	}
 
-	free_high_class_uuar(uuari, uuarn);
+	free_high_class_bfreg(bfregi, bfregn);
 
 out:
-	mutex_unlock(&uuari->lock);
+	mutex_unlock(&bfregi->lock);
 }
 
 static enum mlx5_qp_state to_mlx5_state(enum ib_qp_state state)
@@ -657,9 +657,9 @@ static void mlx5_ib_lock_cqs(struct mlx5_ib_cq *send_cq,
 static void mlx5_ib_unlock_cqs(struct mlx5_ib_cq *send_cq,
 			       struct mlx5_ib_cq *recv_cq);
 
-static int uuarn_to_uar_index(struct mlx5_uuar_info *uuari, int uuarn)
+static int bfregn_to_uar_index(struct mlx5_bfreg_info *bfregi, int bfregn)
 {
-	return uuari->uars[uuarn / MLX5_BF_REGS_PER_PAGE].index;
+	return bfregi->uars[bfregn / MLX5_BFREGS_PER_UAR].index;
 }
 
 static int mlx5_ib_umem_get(struct mlx5_ib_dev *dev,
@@ -776,7 +776,7 @@ static int create_user_qp(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 	int uar_index;
 	int npages;
 	u32 offset = 0;
-	int uuarn;
+	int bfregn;
 	int ncont = 0;
 	__be64 *pas;
 	void *qpc;
@@ -794,27 +794,27 @@ static int create_user_qp(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 	 */
 	if (qp->flags & MLX5_IB_QP_CROSS_CHANNEL)
 		/* In CROSS_CHANNEL CQ and QP must use the same UAR */
-		uuarn = MLX5_CROSS_CHANNEL_UUAR;
+		bfregn = MLX5_CROSS_CHANNEL_BFREG;
 	else {
-		uuarn = alloc_uuar(&context->uuari, MLX5_IB_LATENCY_CLASS_HIGH);
-		if (uuarn < 0) {
-			mlx5_ib_dbg(dev, "failed to allocate low latency UUAR\n");
+		bfregn = alloc_bfreg(&context->bfregi, MLX5_IB_LATENCY_CLASS_HIGH);
+		if (bfregn < 0) {
+			mlx5_ib_dbg(dev, "failed to allocate low latency BFREG\n");
 			mlx5_ib_dbg(dev, "reverting to medium latency\n");
-			uuarn = alloc_uuar(&context->uuari, MLX5_IB_LATENCY_CLASS_MEDIUM);
-			if (uuarn < 0) {
-				mlx5_ib_dbg(dev, "failed to allocate medium latency UUAR\n");
+			bfregn = alloc_bfreg(&context->bfregi, MLX5_IB_LATENCY_CLASS_MEDIUM);
+			if (bfregn < 0) {
+				mlx5_ib_dbg(dev, "failed to allocate medium latency BFREG\n");
 				mlx5_ib_dbg(dev, "reverting to high latency\n");
-				uuarn = alloc_uuar(&context->uuari, MLX5_IB_LATENCY_CLASS_LOW);
-				if (uuarn < 0) {
-					mlx5_ib_warn(dev, "uuar allocation failed\n");
-					return uuarn;
+				bfregn = alloc_bfreg(&context->bfregi, MLX5_IB_LATENCY_CLASS_LOW);
+				if (bfregn < 0) {
+					mlx5_ib_warn(dev, "bfreg allocation failed\n");
+					return bfregn;
 				}
 			}
 		}
 	}
 
-	uar_index = uuarn_to_uar_index(&context->uuari, uuarn);
-	mlx5_ib_dbg(dev, "uuarn 0x%x, uar_index 0x%x\n", uuarn, uar_index);
+	uar_index = bfregn_to_uar_index(&context->bfregi, bfregn);
+	mlx5_ib_dbg(dev, "bfregn 0x%x, uar_index 0x%x\n", bfregn, uar_index);
 
 	qp->rq.offset = 0;
 	qp->sq.wqe_shift = ilog2(MLX5_SEND_WQE_BB);
@@ -822,7 +822,7 @@ static int create_user_qp(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 
 	err = set_user_buf_size(dev, qp, &ucmd, base, attr);
 	if (err)
-		goto err_uuar;
+		goto err_bfreg;
 
 	if (ucmd.buf_addr && ubuffer->buf_size) {
 		ubuffer->buf_addr = ucmd.buf_addr;
@@ -831,7 +831,7 @@ static int create_user_qp(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 				       &ubuffer->umem, &npages, &page_shift,
 				       &ncont, &offset);
 		if (err)
-			goto err_uuar;
+			goto err_bfreg;
 	} else {
 		ubuffer->umem = NULL;
 	}
@@ -854,8 +854,8 @@ static int create_user_qp(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 	MLX5_SET(qpc, qpc, page_offset, offset);
 
 	MLX5_SET(qpc, qpc, uar_page, uar_index);
-	resp->uuar_index = uuarn;
-	qp->uuarn = uuarn;
+	resp->bfreg_index = bfregn;
+	qp->bfregn = bfregn;
 
 	err = mlx5_ib_db_map_user(context, ucmd.db_addr, &qp->db);
 	if (err) {
@@ -882,8 +882,8 @@ static int create_user_qp(struct mlx5_ib_dev *dev, struct ib_pd *pd,
 	if (ubuffer->umem)
 		ib_umem_release(ubuffer->umem);
 
-err_uuar:
-	free_uuar(&context->uuari, uuarn);
+err_bfreg:
+	free_bfreg(&context->bfregi, bfregn);
 	return err;
 }
 
@@ -896,7 +896,7 @@ static void destroy_qp_user(struct ib_pd *pd, struct mlx5_ib_qp *qp,
 	mlx5_ib_db_unmap_user(context, &qp->db);
 	if (base->ubuffer.umem)
 		ib_umem_release(base->ubuffer.umem);
-	free_uuar(&context->uuari, qp->uuarn);
+	free_bfreg(&context->bfregi, qp->bfregn);
 }
 
 static int create_kernel_qp(struct mlx5_ib_dev *dev,
@@ -906,13 +906,13 @@ static int create_kernel_qp(struct mlx5_ib_dev *dev,
 			    struct mlx5_ib_qp_base *base)
 {
 	enum mlx5_ib_latency_class lc = MLX5_IB_LATENCY_CLASS_LOW;
-	struct mlx5_uuar_info *uuari;
+	struct mlx5_bfreg_info *bfregi;
 	int uar_index;
 	void *qpc;
-	int uuarn;
+	int bfregn;
 	int err;
 
-	uuari = &dev->mdev->priv.uuari;
+	bfregi = &dev->mdev->priv.bfregi;
 	if (init_attr->create_flags & ~(IB_QP_CREATE_SIGNATURE_EN |
 					IB_QP_CREATE_BLOCK_MULTICAST_LOOPBACK |
 					IB_QP_CREATE_IPOIB_UD_LSO |
@@ -922,19 +922,19 @@ static int create_kernel_qp(struct mlx5_ib_dev *dev,
 	if (init_attr->qp_type == MLX5_IB_QPT_REG_UMR)
 		lc = MLX5_IB_LATENCY_CLASS_FAST_PATH;
 
-	uuarn = alloc_uuar(uuari, lc);
-	if (uuarn < 0) {
+	bfregn = alloc_bfreg(bfregi, lc);
+	if (bfregn < 0) {
 		mlx5_ib_dbg(dev, "\n");
 		return -ENOMEM;
 	}
 
-	qp->bf = &uuari->bfs[uuarn];
+	qp->bf = &bfregi->bfs[bfregn];
 	uar_index = qp->bf->uar->index;
 
 	err = calc_sq_size(dev, init_attr, qp);
 	if (err < 0) {
 		mlx5_ib_dbg(dev, "err %d\n", err);
-		goto err_uuar;
+		goto err_bfreg;
 	}
 
 	qp->rq.offset = 0;
@@ -944,7 +944,7 @@ static int create_kernel_qp(struct mlx5_ib_dev *dev,
 	err = mlx5_buf_alloc(dev->mdev, base->ubuffer.buf_size, &qp->buf);
 	if (err) {
 		mlx5_ib_dbg(dev, "err %d\n", err);
-		goto err_uuar;
+		goto err_bfreg;
 	}
 
 	qp->sq.qend = mlx5_get_send_wqe(qp, qp->sq.wqe_cnt);
@@ -1007,8 +1007,8 @@ static int create_kernel_qp(struct mlx5_ib_dev *dev,
 err_buf:
 	mlx5_buf_free(dev->mdev, &qp->buf);
 
-err_uuar:
-	free_uuar(&dev->mdev->priv.uuari, uuarn);
+err_bfreg:
+	free_bfreg(&dev->mdev->priv.bfregi, bfregn);
 	return err;
 }
 
@@ -1021,7 +1021,7 @@ static void destroy_qp_kernel(struct mlx5_ib_dev *dev, struct mlx5_ib_qp *qp)
 	kfree(qp->rq.wrid);
 	mlx5_db_free(dev->mdev, &qp->db);
 	mlx5_buf_free(dev->mdev, &qp->buf);
-	free_uuar(&dev->mdev->priv.uuari, qp->bf->uuarn);
+	free_bfreg(&dev->mdev->priv.bfregi, qp->bf->bfregn);
 }
 
 static u32 get_rx_type(struct mlx5_ib_qp *qp, struct ib_qp_init_attr *attr)
@@ -1353,7 +1353,7 @@ static int create_rss_raw_qp_tir(struct mlx5_ib_dev *dev, struct mlx5_ib_qp *qp,
 	if (init_attr->create_flags || init_attr->send_cq)
 		return -EINVAL;
 
-	min_resp_len = offsetof(typeof(resp), uuar_index) + sizeof(resp.uuar_index);
+	min_resp_len = offsetof(typeof(resp), bfreg_index) + sizeof(resp.bfreg_index);
 	if (udata->outlen < min_resp_len)
 		return -EINVAL;
 
@@ -4132,7 +4132,7 @@ int mlx5_ib_post_send(struct ib_qp *ibqp, struct ib_send_wr *wr,
 			__acquire(&bf->lock);
 
 		/* TBD enable WC */
-		if (0 && nreq == 1 && bf->uuarn && inl && size > 1 && size <= bf->buf_size / 16) {
+		if (0 && nreq == 1 && bf->bfregn && inl && size > 1 && size <= bf->buf_size / 16) {
 			mlx5_bf_copy(bf->reg + bf->offset, (u64 *)ctrl, ALIGN(size * 16, 64), qp);
 			/* wc_wmb(); */
 		} else {
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/eq.c b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
index 4aff8ac..11a8d63 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/eq.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/eq.c
@@ -686,7 +686,7 @@ int mlx5_start_eqs(struct mlx5_core_dev *dev)
 
 	err = mlx5_create_map_eq(dev, &table->cmd_eq, MLX5_EQ_VEC_CMD,
 				 MLX5_NUM_CMD_EQE, 1ull << MLX5_EVENT_TYPE_CMD,
-				 "mlx5_cmd_eq", &dev->priv.uuari.uars[0],
+				 "mlx5_cmd_eq", &dev->priv.bfregi.uars[0],
 				 MLX5_EQ_TYPE_ASYNC);
 	if (err) {
 		mlx5_core_warn(dev, "failed to create cmd EQ %d\n", err);
@@ -697,7 +697,7 @@ int mlx5_start_eqs(struct mlx5_core_dev *dev)
 
 	err = mlx5_create_map_eq(dev, &table->async_eq, MLX5_EQ_VEC_ASYNC,
 				 MLX5_NUM_ASYNC_EQE, async_event_mask,
-				 "mlx5_async_eq", &dev->priv.uuari.uars[0],
+				 "mlx5_async_eq", &dev->priv.bfregi.uars[0],
 				 MLX5_EQ_TYPE_ASYNC);
 	if (err) {
 		mlx5_core_warn(dev, "failed to create async EQ %d\n", err);
@@ -708,7 +708,7 @@ int mlx5_start_eqs(struct mlx5_core_dev *dev)
 				 MLX5_EQ_VEC_PAGES,
 				 /* TODO: sriov max_vf + */ 1,
 				 1 << MLX5_EVENT_TYPE_PAGE_REQUEST, "mlx5_pages_eq",
-				 &dev->priv.uuari.uars[0],
+				 &dev->priv.bfregi.uars[0],
 				 MLX5_EQ_TYPE_ASYNC);
 	if (err) {
 		mlx5_core_warn(dev, "failed to create pages EQ %d\n", err);
@@ -722,7 +722,7 @@ int mlx5_start_eqs(struct mlx5_core_dev *dev)
 					 MLX5_NUM_ASYNC_EQE,
 					 1 << MLX5_EVENT_TYPE_PAGE_FAULT,
 					 "mlx5_page_fault_eq",
-					 &dev->priv.uuari.uars[0],
+					 &dev->priv.bfregi.uars[0],
 					 MLX5_EQ_TYPE_PF);
 		if (err) {
 			mlx5_core_warn(dev, "failed to create page fault EQ %d\n",
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/main.c b/drivers/net/ethernet/mellanox/mlx5/core/main.c
index f411513..634e96a 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/main.c
@@ -753,7 +753,7 @@ static int alloc_comp_eqs(struct mlx5_core_dev *dev)
 		snprintf(name, MLX5_MAX_IRQ_NAME, "mlx5_comp%d", i);
 		err = mlx5_create_map_eq(dev, eq,
 					 i + MLX5_EQ_VEC_COMP_BASE, nent, 0,
-					 name, &dev->priv.uuari.uars[0],
+					 name, &dev->priv.bfregi.uars[0],
 					 MLX5_EQ_TYPE_COMP);
 		if (err) {
 			kfree(eq);
@@ -1094,7 +1094,7 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 		goto err_cleanup_once;
 	}
 
-	err = mlx5_alloc_uuars(dev, &priv->uuari);
+	err = mlx5_alloc_bfregs(dev, &priv->bfregi);
 	if (err) {
 		dev_err(&pdev->dev, "Failed allocating uar, aborting\n");
 		goto err_disable_msix;
@@ -1170,7 +1170,7 @@ static int mlx5_load_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 	mlx5_stop_eqs(dev);
 
 err_free_uar:
-	mlx5_free_uuars(dev, &priv->uuari);
+	mlx5_free_bfregs(dev, &priv->bfregi);
 
 err_disable_msix:
 	mlx5_disable_msix(dev);
@@ -1230,7 +1230,7 @@ static int mlx5_unload_one(struct mlx5_core_dev *dev, struct mlx5_priv *priv,
 	mlx5_irq_clear_affinity_hints(dev);
 	free_comp_eqs(dev);
 	mlx5_stop_eqs(dev);
-	mlx5_free_uuars(dev, &priv->uuari);
+	mlx5_free_bfregs(dev, &priv->bfregi);
 	mlx5_disable_msix(dev);
 	if (cleanup)
 		mlx5_cleanup_once(dev);
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/uar.c b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
index ab0b896..ce7fceb 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/uar.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/uar.c
@@ -39,7 +39,7 @@
 
 enum {
 	NUM_DRIVER_UARS		= 4,
-	NUM_LOW_LAT_UUARS	= 4,
+	NUM_LOW_LAT_BFREGS	= 4,
 };
 
 int mlx5_cmd_alloc_uar(struct mlx5_core_dev *dev, u32 *uarn)
@@ -67,116 +67,116 @@ int mlx5_cmd_free_uar(struct mlx5_core_dev *dev, u32 uarn)
 }
 EXPORT_SYMBOL(mlx5_cmd_free_uar);
 
-static int need_uuar_lock(int uuarn)
+static int need_bfreg_lock(int bfregn)
 {
-	int tot_uuars = NUM_DRIVER_UARS * MLX5_BF_REGS_PER_PAGE;
+	int tot_bfregs = NUM_DRIVER_UARS * MLX5_BFREGS_PER_UAR;
 
-	if (uuarn == 0 || tot_uuars - NUM_LOW_LAT_UUARS)
+	if (bfregn == 0 || tot_bfregs - NUM_LOW_LAT_BFREGS)
 		return 0;
 
 	return 1;
 }
 
-int mlx5_alloc_uuars(struct mlx5_core_dev *dev, struct mlx5_uuar_info *uuari)
+int mlx5_alloc_bfregs(struct mlx5_core_dev *dev, struct mlx5_bfreg_info *bfregi)
 {
-	int tot_uuars = NUM_DRIVER_UARS * MLX5_BF_REGS_PER_PAGE;
+	int tot_bfregs = NUM_DRIVER_UARS * MLX5_BFREGS_PER_UAR;
 	struct mlx5_bf *bf;
 	phys_addr_t addr;
 	int err;
 	int i;
 
-	uuari->num_uars = NUM_DRIVER_UARS;
-	uuari->num_low_latency_uuars = NUM_LOW_LAT_UUARS;
+	bfregi->num_uars = NUM_DRIVER_UARS;
+	bfregi->num_low_latency_bfregs = NUM_LOW_LAT_BFREGS;
 
-	mutex_init(&uuari->lock);
-	uuari->uars = kcalloc(uuari->num_uars, sizeof(*uuari->uars), GFP_KERNEL);
-	if (!uuari->uars)
+	mutex_init(&bfregi->lock);
+	bfregi->uars = kcalloc(bfregi->num_uars, sizeof(*bfregi->uars), GFP_KERNEL);
+	if (!bfregi->uars)
 		return -ENOMEM;
 
-	uuari->bfs = kcalloc(tot_uuars, sizeof(*uuari->bfs), GFP_KERNEL);
-	if (!uuari->bfs) {
+	bfregi->bfs = kcalloc(tot_bfregs, sizeof(*bfregi->bfs), GFP_KERNEL);
+	if (!bfregi->bfs) {
 		err = -ENOMEM;
 		goto out_uars;
 	}
 
-	uuari->bitmap = kcalloc(BITS_TO_LONGS(tot_uuars), sizeof(*uuari->bitmap),
+	bfregi->bitmap = kcalloc(BITS_TO_LONGS(tot_bfregs), sizeof(*bfregi->bitmap),
 				GFP_KERNEL);
-	if (!uuari->bitmap) {
+	if (!bfregi->bitmap) {
 		err = -ENOMEM;
 		goto out_bfs;
 	}
 
-	uuari->count = kcalloc(tot_uuars, sizeof(*uuari->count), GFP_KERNEL);
-	if (!uuari->count) {
+	bfregi->count = kcalloc(tot_bfregs, sizeof(*bfregi->count), GFP_KERNEL);
+	if (!bfregi->count) {
 		err = -ENOMEM;
 		goto out_bitmap;
 	}
 
-	for (i = 0; i < uuari->num_uars; i++) {
-		err = mlx5_cmd_alloc_uar(dev, &uuari->uars[i].index);
+	for (i = 0; i < bfregi->num_uars; i++) {
+		err = mlx5_cmd_alloc_uar(dev, &bfregi->uars[i].index);
 		if (err)
 			goto out_count;
 
-		addr = dev->iseg_base + ((phys_addr_t)(uuari->uars[i].index) << PAGE_SHIFT);
-		uuari->uars[i].map = ioremap(addr, PAGE_SIZE);
-		if (!uuari->uars[i].map) {
-			mlx5_cmd_free_uar(dev, uuari->uars[i].index);
+		addr = dev->iseg_base + ((phys_addr_t)(bfregi->uars[i].index) << PAGE_SHIFT);
+		bfregi->uars[i].map = ioremap(addr, PAGE_SIZE);
+		if (!bfregi->uars[i].map) {
+			mlx5_cmd_free_uar(dev, bfregi->uars[i].index);
 			err = -ENOMEM;
 			goto out_count;
 		}
 		mlx5_core_dbg(dev, "allocated uar index 0x%x, mmaped at %p\n",
-			      uuari->uars[i].index, uuari->uars[i].map);
+			      bfregi->uars[i].index, bfregi->uars[i].map);
 	}
 
-	for (i = 0; i < tot_uuars; i++) {
-		bf = &uuari->bfs[i];
+	for (i = 0; i < tot_bfregs; i++) {
+		bf = &bfregi->bfs[i];
 
 		bf->buf_size = (1 << MLX5_CAP_GEN(dev, log_bf_reg_size)) / 2;
-		bf->uar = &uuari->uars[i / MLX5_BF_REGS_PER_PAGE];
-		bf->regreg = uuari->uars[i / MLX5_BF_REGS_PER_PAGE].map;
+		bf->uar = &bfregi->uars[i / MLX5_BFREGS_PER_UAR];
+		bf->regreg = bfregi->uars[i / MLX5_BFREGS_PER_UAR].map;
 		bf->reg = NULL; /* Add WC support */
-		bf->offset = (i % MLX5_BF_REGS_PER_PAGE) *
+		bf->offset = (i % MLX5_BFREGS_PER_UAR) *
 			     (1 << MLX5_CAP_GEN(dev, log_bf_reg_size)) +
 			     MLX5_BF_OFFSET;
-		bf->need_lock = need_uuar_lock(i);
+		bf->need_lock = need_bfreg_lock(i);
 		spin_lock_init(&bf->lock);
 		spin_lock_init(&bf->lock32);
-		bf->uuarn = i;
+		bf->bfregn = i;
 	}
 
 	return 0;
 
 out_count:
 	for (i--; i >= 0; i--) {
-		iounmap(uuari->uars[i].map);
-		mlx5_cmd_free_uar(dev, uuari->uars[i].index);
+		iounmap(bfregi->uars[i].map);
+		mlx5_cmd_free_uar(dev, bfregi->uars[i].index);
 	}
-	kfree(uuari->count);
+	kfree(bfregi->count);
 
 out_bitmap:
-	kfree(uuari->bitmap);
+	kfree(bfregi->bitmap);
 
 out_bfs:
-	kfree(uuari->bfs);
+	kfree(bfregi->bfs);
 
 out_uars:
-	kfree(uuari->uars);
+	kfree(bfregi->uars);
 	return err;
 }
 
-int mlx5_free_uuars(struct mlx5_core_dev *dev, struct mlx5_uuar_info *uuari)
+int mlx5_free_bfregs(struct mlx5_core_dev *dev, struct mlx5_bfreg_info *bfregi)
 {
-	int i = uuari->num_uars;
+	int i = bfregi->num_uars;
 
 	for (i--; i >= 0; i--) {
-		iounmap(uuari->uars[i].map);
-		mlx5_cmd_free_uar(dev, uuari->uars[i].index);
+		iounmap(bfregi->uars[i].map);
+		mlx5_cmd_free_uar(dev, bfregi->uars[i].index);
 	}
 
-	kfree(uuari->count);
-	kfree(uuari->bitmap);
-	kfree(uuari->bfs);
-	kfree(uuari->uars);
+	kfree(bfregi->count);
+	kfree(bfregi->bitmap);
+	kfree(bfregi->bfs);
+	kfree(bfregi->uars);
 
 	return 0;
 }
diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
index 3ccaeff..aa851c5 100644
--- a/include/linux/mlx5/device.h
+++ b/include/linux/mlx5/device.h
@@ -212,10 +212,11 @@ enum {
 };
 
 enum {
-	MLX5_BF_REGS_PER_PAGE		= 4,
-	MLX5_MAX_UAR_PAGES		= 1 << 8,
-	MLX5_NON_FP_BF_REGS_PER_PAGE	= 2,
-	MLX5_MAX_UUARS	= MLX5_MAX_UAR_PAGES * MLX5_NON_FP_BF_REGS_PER_PAGE,
+	MLX5_BFREGS_PER_UAR		= 4,
+	MLX5_MAX_UARS			= 1 << 8,
+	MLX5_NON_FP_BFREGS_PER_UAR	= 2,
+	MLX5_MAX_BFREGS			= MLX5_MAX_UARS *
+					  MLX5_NON_FP_BFREGS_PER_UAR,
 };
 
 enum {
diff --git a/include/linux/mlx5/driver.h b/include/linux/mlx5/driver.h
index cfa49bc..3d07e25 100644
--- a/include/linux/mlx5/driver.h
+++ b/include/linux/mlx5/driver.h
@@ -188,16 +188,16 @@ enum mlx5_eq_type {
 #endif
 };
 
-struct mlx5_uuar_info {
+struct mlx5_bfreg_info {
 	struct mlx5_uar	       *uars;
 	int			num_uars;
-	int			num_low_latency_uuars;
+	int			num_low_latency_bfregs;
 	unsigned long	       *bitmap;
 	unsigned int	       *count;
 	struct mlx5_bf	       *bfs;
 
 	/*
-	 * protect uuar allocation data structs
+	 * protect bfreg allocation data structs
 	 */
 	struct mutex		lock;
 	u32			ver;
@@ -217,7 +217,7 @@ struct mlx5_bf {
 	/* serialize 64 bit writes when done as two 32 bit accesses
 	 */
 	spinlock_t		lock32;
-	int			uuarn;
+	int			bfregn;
 };
 
 struct mlx5_cmd_first {
@@ -579,7 +579,7 @@ struct mlx5_priv {
 	struct mlx5_eq_table	eq_table;
 	struct msix_entry	*msix_arr;
 	struct mlx5_irq_info	*irq_info;
-	struct mlx5_uuar_info	uuari;
+	struct mlx5_bfreg_info	bfregi;
 	MLX5_DECLARE_DOORBELL_LOCK(cq_uar_lock);
 
 	/* pages stuff */
@@ -903,8 +903,8 @@ void mlx5_cmd_mbox_status(void *out, u8 *status, u32 *syndrome);
 int mlx5_core_get_caps(struct mlx5_core_dev *dev, enum mlx5_cap_type cap_type);
 int mlx5_cmd_alloc_uar(struct mlx5_core_dev *dev, u32 *uarn);
 int mlx5_cmd_free_uar(struct mlx5_core_dev *dev, u32 uarn);
-int mlx5_alloc_uuars(struct mlx5_core_dev *dev, struct mlx5_uuar_info *uuari);
-int mlx5_free_uuars(struct mlx5_core_dev *dev, struct mlx5_uuar_info *uuari);
+int mlx5_alloc_bfregs(struct mlx5_core_dev *dev, struct mlx5_bfreg_info *bfregi);
+int mlx5_free_bfregs(struct mlx5_core_dev *dev, struct mlx5_bfreg_info *bfregi);
 int mlx5_alloc_map_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar,
 		       bool map_wc);
 void mlx5_unmap_free_uar(struct mlx5_core_dev *mdev, struct mlx5_uar *uar);
diff --git a/include/uapi/rdma/mlx5-abi.h b/include/uapi/rdma/mlx5-abi.h
index fae6cda..86a8f30 100644
--- a/include/uapi/rdma/mlx5-abi.h
+++ b/include/uapi/rdma/mlx5-abi.h
@@ -61,13 +61,13 @@ enum {
  */
 
 struct mlx5_ib_alloc_ucontext_req {
-	__u32	total_num_uuars;
-	__u32	num_low_latency_uuars;
+	__u32	total_num_bfregs;
+	__u32	num_low_latency_bfregs;
 };
 
 struct mlx5_ib_alloc_ucontext_req_v2 {
-	__u32	total_num_uuars;
-	__u32	num_low_latency_uuars;
+	__u32	total_num_bfregs;
+	__u32	num_low_latency_bfregs;
 	__u32	flags;
 	__u32	comp_mask;
 	__u8	max_cqe_version;
@@ -88,7 +88,7 @@ enum mlx5_user_cmds_supp_uhw {
 struct mlx5_ib_alloc_ucontext_resp {
 	__u32	qp_tab_size;
 	__u32	bf_reg_size;
-	__u32	tot_uuars;
+	__u32	tot_bfregs;
 	__u32	cache_line_size;
 	__u16	max_sq_desc_sz;
 	__u16	max_rq_desc_sz;
@@ -241,7 +241,7 @@ struct mlx5_ib_create_qp_rss {
 };
 
 struct mlx5_ib_create_qp_resp {
-	__u32	uuar_index;
+	__u32	bfreg_index;
 };
 
 struct mlx5_ib_alloc_mw {
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
