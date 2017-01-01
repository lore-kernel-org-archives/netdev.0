From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH for-next 05/11] IB/mlx5: Refactor UMR post send format
Date: Sun,  1 Jan 2017 23:10:21 +0200
Message-ID: <1483305027-2573-6-git-send-email-saeedm@mellanox.com>
References: <1483305027-2573-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, linux-rdma@vger.kernel.org,
        Leon Romanovsky <leonro@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        Artemy Kovalyov <artemyko@mellanox.com>,
        Leon Romanovsky <leon@kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Doug Ledford <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:42848 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S932477AbdAAVKu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 16:10:50 -0500
In-Reply-To: <1483305027-2573-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Artemy Kovalyov <artemyko@mellanox.com>

* Update struct mlx5_wqe_umr_ctrl_seg.
* Currenlty UMR send_flags aim only certain use cases: enabled/disable
  cached MR, modifying XLT for ODP. By making flags independent make UMR
  more flexible allowing arbitrary manipulations.
* Since different UMR formats have different entry sizes UMR request
  should receive exact size of translation table update instead of
  number of entries. Rename field npages to xlt_size in struct mlx5_umr_wr
  and update relevant code accordingly.
* Add support of length64 bit.

Signed-off-by: Artemy Kovalyov <artemyko@mellanox.com>
Signed-off-by: Leon Romanovsky <leon@kernel.org>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---
 drivers/infiniband/hw/mlx5/mlx5_ib.h              |  24 ++--
 drivers/infiniband/hw/mlx5/mr.c                   |  50 +++++----
 drivers/infiniband/hw/mlx5/odp.c                  |   3 +-
 drivers/infiniband/hw/mlx5/qp.c                   | 128 +++++++++-------------
 drivers/net/ethernet/mellanox/mlx5/core/en_main.c |   2 +-
 include/linux/mlx5/qp.h                           |  14 ++-
 6 files changed, 103 insertions(+), 118 deletions(-)

diff --git a/drivers/infiniband/hw/mlx5/mlx5_ib.h b/drivers/infiniband/hw/mlx5/mlx5_ib.h
index 6c6057e..d79580d 100644
--- a/drivers/infiniband/hw/mlx5/mlx5_ib.h
+++ b/drivers/infiniband/hw/mlx5/mlx5_ib.h
@@ -174,13 +174,12 @@ struct mlx5_ib_flow_db {
  * enum ib_send_flags and enum ib_qp_type for low-level driver
  */
 
-#define MLX5_IB_SEND_UMR_UNREG	IB_SEND_RESERVED_START
-#define MLX5_IB_SEND_UMR_FAIL_IF_FREE (IB_SEND_RESERVED_START << 1)
-#define MLX5_IB_SEND_UMR_UPDATE_MTT (IB_SEND_RESERVED_START << 2)
-
-#define MLX5_IB_SEND_UMR_UPDATE_TRANSLATION	(IB_SEND_RESERVED_START << 3)
-#define MLX5_IB_SEND_UMR_UPDATE_PD		(IB_SEND_RESERVED_START << 4)
-#define MLX5_IB_SEND_UMR_UPDATE_ACCESS		IB_SEND_RESERVED_END
+#define MLX5_IB_SEND_UMR_ENABLE_MR	       (IB_SEND_RESERVED_START << 0)
+#define MLX5_IB_SEND_UMR_DISABLE_MR	       (IB_SEND_RESERVED_START << 1)
+#define MLX5_IB_SEND_UMR_FAIL_IF_FREE	       (IB_SEND_RESERVED_START << 2)
+#define MLX5_IB_SEND_UMR_UPDATE_XLT	       (IB_SEND_RESERVED_START << 3)
+#define MLX5_IB_SEND_UMR_UPDATE_TRANSLATION    (IB_SEND_RESERVED_START << 4)
+#define MLX5_IB_SEND_UMR_UPDATE_PD_ACCESS       IB_SEND_RESERVED_END
 
 #define MLX5_IB_QPT_REG_UMR	IB_QPT_RESERVED1
 /*
@@ -190,6 +189,9 @@ struct mlx5_ib_flow_db {
 #define MLX5_IB_QPT_HW_GSI	IB_QPT_RESERVED2
 #define MLX5_IB_WR_UMR		IB_WR_RESERVED1
 
+#define MLX5_IB_UMR_OCTOWORD	       16
+#define MLX5_IB_UMR_XLT_ALIGNMENT      64
+
 /* Private QP creation flags to be passed in ib_qp_init_attr.create_flags.
  *
  * These flags are intended for internal use by the mlx5_ib driver, and they
@@ -414,13 +416,11 @@ enum mlx5_ib_qp_flags {
 
 struct mlx5_umr_wr {
 	struct ib_send_wr		wr;
-	union {
-		u64			virt_addr;
-		u64			offset;
-	} target;
+	u64				virt_addr;
+	u64				offset;
 	struct ib_pd		       *pd;
 	unsigned int			page_shift;
-	unsigned int			npages;
+	unsigned int			xlt_size;
 	u64				length;
 	int				access_flags;
 	u32				mkey;
diff --git a/drivers/infiniband/hw/mlx5/mr.c b/drivers/infiniband/hw/mlx5/mr.c
index afb6dc1..738ba13 100644
--- a/drivers/infiniband/hw/mlx5/mr.c
+++ b/drivers/infiniband/hw/mlx5/mr.c
@@ -774,7 +774,7 @@ static int dma_map_mr_pas(struct mlx5_ib_dev *dev, struct ib_umem *umem,
 	 * To avoid copying garbage after the pas array, we allocate
 	 * a little more.
 	 */
-	*size = ALIGN(sizeof(u64) * npages, MLX5_UMR_MTT_ALIGNMENT);
+	*size = ALIGN(sizeof(struct mlx5_mtt) * npages, MLX5_UMR_MTT_ALIGNMENT);
 	*mr_pas = kmalloc(*size + MLX5_UMR_ALIGN - 1, GFP_KERNEL);
 	if (!(*mr_pas))
 		return -ENOMEM;
@@ -782,7 +782,7 @@ static int dma_map_mr_pas(struct mlx5_ib_dev *dev, struct ib_umem *umem,
 	pas = PTR_ALIGN(*mr_pas, MLX5_UMR_ALIGN);
 	mlx5_ib_populate_pas(dev, umem, page_shift, pas, MLX5_IB_MTT_PRESENT);
 	/* Clear padding after the actual pages. */
-	memset(pas + npages, 0, *size - npages * sizeof(u64));
+	memset(pas + npages, 0, *size - npages * sizeof(struct mlx5_mtt));
 
 	*dma = dma_map_single(ddev, pas, *size, DMA_TO_DEVICE);
 	if (dma_mapping_error(ddev, *dma)) {
@@ -801,7 +801,8 @@ static void prep_umr_wqe_common(struct ib_pd *pd, struct ib_send_wr *wr,
 	struct mlx5_umr_wr *umrwr = umr_wr(wr);
 
 	sg->addr = dma;
-	sg->length = ALIGN(sizeof(u64) * n, 64);
+	sg->length = ALIGN(sizeof(struct mlx5_mtt) * n,
+			   MLX5_IB_UMR_XLT_ALIGNMENT);
 	sg->lkey = dev->umrc.pd->local_dma_lkey;
 
 	wr->next = NULL;
@@ -813,7 +814,7 @@ static void prep_umr_wqe_common(struct ib_pd *pd, struct ib_send_wr *wr,
 
 	wr->opcode = MLX5_IB_WR_UMR;
 
-	umrwr->npages = n;
+	umrwr->xlt_size = sg->length;
 	umrwr->page_shift = page_shift;
 	umrwr->mkey = key;
 }
@@ -827,9 +828,11 @@ static void prep_umr_reg_wqe(struct ib_pd *pd, struct ib_send_wr *wr,
 
 	prep_umr_wqe_common(pd, wr, sg, dma, n, key, page_shift);
 
-	wr->send_flags = 0;
+	wr->send_flags = MLX5_IB_SEND_UMR_ENABLE_MR |
+			 MLX5_IB_SEND_UMR_UPDATE_TRANSLATION |
+			 MLX5_IB_SEND_UMR_UPDATE_PD_ACCESS;
 
-	umrwr->target.virt_addr = virt_addr;
+	umrwr->virt_addr = virt_addr;
 	umrwr->length = len;
 	umrwr->access_flags = access_flags;
 	umrwr->pd = pd;
@@ -840,7 +843,8 @@ static void prep_umr_unreg_wqe(struct mlx5_ib_dev *dev,
 {
 	struct mlx5_umr_wr *umrwr = umr_wr(wr);
 
-	wr->send_flags = MLX5_IB_SEND_UMR_UNREG | MLX5_IB_SEND_UMR_FAIL_IF_FREE;
+	wr->send_flags = MLX5_IB_SEND_UMR_DISABLE_MR |
+			 MLX5_IB_SEND_UMR_FAIL_IF_FREE;
 	wr->opcode = MLX5_IB_WR_UMR;
 	umrwr->mkey = key;
 }
@@ -993,7 +997,8 @@ int mlx5_ib_update_mtt(struct mlx5_ib_mr *mr, u64 start_page_index, int npages,
 	struct mlx5_umr_wr wr;
 	struct ib_sge sg;
 	int err = 0;
-	const int page_index_alignment = MLX5_UMR_MTT_ALIGNMENT / sizeof(u64);
+	const int page_index_alignment = MLX5_UMR_MTT_ALIGNMENT /
+					 sizeof(struct mlx5_mtt);
 	const int page_index_mask = page_index_alignment - 1;
 	size_t pages_mapped = 0;
 	size_t pages_to_map = 0;
@@ -1012,7 +1017,7 @@ int mlx5_ib_update_mtt(struct mlx5_ib_mr *mr, u64 start_page_index, int npages,
 	if (start_page_index + pages_to_map > MLX5_MAX_UMR_PAGES)
 		return -EINVAL;
 
-	size = sizeof(u64) * pages_to_map;
+	size = sizeof(struct mlx5_mtt) * pages_to_map;
 	size = min_t(int, PAGE_SIZE, size);
 	/* We allocate with GFP_ATOMIC to avoid recursion into page-reclaim
 	 * code, when we are called from an invalidation. The pas buffer must
@@ -1026,7 +1031,7 @@ int mlx5_ib_update_mtt(struct mlx5_ib_mr *mr, u64 start_page_index, int npages,
 		mutex_lock(&mlx5_ib_update_mtt_emergency_buffer_mutex);
 		memset(pas, 0, size);
 	}
-	pages_iter = size / sizeof(u64);
+	pages_iter = size / sizeof(struct mlx5_mtt);
 	dma = dma_map_single(ddev, pas, size, DMA_TO_DEVICE);
 	if (dma_mapping_error(ddev, dma)) {
 		mlx5_ib_err(dev, "unable to map DMA during MTT update.\n");
@@ -1049,7 +1054,8 @@ int mlx5_ib_update_mtt(struct mlx5_ib_mr *mr, u64 start_page_index, int npages,
 					       MLX5_IB_MTT_PRESENT);
 			/* Clear padding after the pages brought from the
 			 * umem. */
-			memset(pas + npages, 0, size - npages * sizeof(u64));
+			memset(pas + npages, 0, size - npages *
+			       sizeof(struct mlx5_mtt));
 		}
 
 		dma_sync_single_for_device(ddev, dma, size, DMA_TO_DEVICE);
@@ -1057,19 +1063,19 @@ int mlx5_ib_update_mtt(struct mlx5_ib_mr *mr, u64 start_page_index, int npages,
 		memset(&wr, 0, sizeof(wr));
 
 		sg.addr = dma;
-		sg.length = ALIGN(npages * sizeof(u64),
+		sg.length = ALIGN(npages * sizeof(struct mlx5_mtt),
 				MLX5_UMR_MTT_ALIGNMENT);
 		sg.lkey = dev->umrc.pd->local_dma_lkey;
 
 		wr.wr.send_flags = MLX5_IB_SEND_UMR_FAIL_IF_FREE |
-				MLX5_IB_SEND_UMR_UPDATE_MTT;
+				   MLX5_IB_SEND_UMR_UPDATE_XLT;
 		wr.wr.sg_list = &sg;
 		wr.wr.num_sge = 1;
 		wr.wr.opcode = MLX5_IB_WR_UMR;
-		wr.npages = sg.length / sizeof(u64);
+		wr.xlt_size = sg.length;
 		wr.page_shift = PAGE_SHIFT;
 		wr.mkey = mr->mmkey.key;
-		wr.target.offset = start_page_index;
+		wr.offset = start_page_index * sizeof(struct mlx5_mtt);
 
 		err = mlx5_ib_post_send_wait(dev, &wr);
 	}
@@ -1272,7 +1278,7 @@ static int rereg_umr(struct ib_pd *pd, struct mlx5_ib_mr *mr, u64 virt_addr,
 		if (err)
 			return err;
 
-		umrwr.target.virt_addr = virt_addr;
+		umrwr.virt_addr = virt_addr;
 		umrwr.length = length;
 		umrwr.wr.send_flags |= MLX5_IB_SEND_UMR_UPDATE_TRANSLATION;
 	}
@@ -1280,14 +1286,10 @@ static int rereg_umr(struct ib_pd *pd, struct mlx5_ib_mr *mr, u64 virt_addr,
 	prep_umr_wqe_common(pd, &umrwr.wr, &sg, dma, npages, mr->mmkey.key,
 			    page_shift);
 
-	if (flags & IB_MR_REREG_PD) {
+	if (flags & IB_MR_REREG_PD || flags & IB_MR_REREG_ACCESS) {
 		umrwr.pd = pd;
-		umrwr.wr.send_flags |= MLX5_IB_SEND_UMR_UPDATE_PD;
-	}
-
-	if (flags & IB_MR_REREG_ACCESS) {
 		umrwr.access_flags = access_flags;
-		umrwr.wr.send_flags |= MLX5_IB_SEND_UMR_UPDATE_ACCESS;
+		umrwr.wr.send_flags |= MLX5_IB_SEND_UMR_UPDATE_PD_ACCESS;
 	}
 
 	/* post send request to UMR QP */
@@ -1552,11 +1554,11 @@ struct ib_mr *mlx5_ib_alloc_mr(struct ib_pd *pd,
 		mr->access_mode = MLX5_MKC_ACCESS_MODE_MTT;
 		MLX5_SET(mkc, mkc, log_page_size, PAGE_SHIFT);
 		err = mlx5_alloc_priv_descs(pd->device, mr,
-					    ndescs, sizeof(u64));
+					    ndescs, sizeof(struct mlx5_mtt));
 		if (err)
 			goto err_free_in;
 
-		mr->desc_size = sizeof(u64);
+		mr->desc_size = sizeof(struct mlx5_mtt);
 		mr->max_descs = ndescs;
 	} else if (mr_type == IB_MR_TYPE_SG_GAPS) {
 		mr->access_mode = MLX5_MKC_ACCESS_MODE_KLMS;
diff --git a/drivers/infiniband/hw/mlx5/odp.c b/drivers/infiniband/hw/mlx5/odp.c
index cacb631..67651ec 100644
--- a/drivers/infiniband/hw/mlx5/odp.c
+++ b/drivers/infiniband/hw/mlx5/odp.c
@@ -47,7 +47,8 @@ void mlx5_ib_invalidate_range(struct ib_umem *umem, unsigned long start,
 			      unsigned long end)
 {
 	struct mlx5_ib_mr *mr;
-	const u64 umr_block_mask = (MLX5_UMR_MTT_ALIGNMENT / sizeof(u64)) - 1;
+	const u64 umr_block_mask = (MLX5_UMR_MTT_ALIGNMENT /
+				    sizeof(struct mlx5_mtt)) - 1;
 	u64 idx = 0, blk_start_idx = 0;
 	int in_block = 0;
 	u64 addr;
diff --git a/drivers/infiniband/hw/mlx5/qp.c b/drivers/infiniband/hw/mlx5/qp.c
index a1b3125..6d5f5d4 100644
--- a/drivers/infiniband/hw/mlx5/qp.c
+++ b/drivers/infiniband/hw/mlx5/qp.c
@@ -3080,9 +3080,10 @@ static void set_data_ptr_seg(struct mlx5_wqe_data_seg *dseg, struct ib_sge *sg)
 	dseg->addr       = cpu_to_be64(sg->addr);
 }
 
-static __be16 get_klm_octo(int npages)
+static inline u64 get_xlt_octo(u64 bytes)
 {
-	return cpu_to_be16(ALIGN(npages, 8) / 2);
+	return ALIGN(bytes, MLX5_IB_UMR_XLT_ALIGNMENT) /
+	       MLX5_IB_UMR_OCTOWORD;
 }
 
 static __be64 frwr_mkey_mask(void)
@@ -3127,18 +3128,14 @@ static __be64 sig_mkey_mask(void)
 }
 
 static void set_reg_umr_seg(struct mlx5_wqe_umr_ctrl_seg *umr,
-				struct mlx5_ib_mr *mr)
+			    struct mlx5_ib_mr *mr)
 {
-	int ndescs = mr->ndescs;
+	int size = mr->ndescs * mr->desc_size;
 
 	memset(umr, 0, sizeof(*umr));
 
-	if (mr->access_mode == MLX5_MKC_ACCESS_MODE_KLMS)
-		/* KLMs take twice the size of MTTs */
-		ndescs *= 2;
-
 	umr->flags = MLX5_UMR_CHECK_NOT_FREE;
-	umr->klm_octowords = get_klm_octo(ndescs);
+	umr->xlt_octowords = cpu_to_be16(get_xlt_octo(size));
 	umr->mkey_mask = frwr_mkey_mask();
 }
 
@@ -3149,37 +3146,17 @@ static void set_linv_umr_seg(struct mlx5_wqe_umr_ctrl_seg *umr)
 	umr->flags = MLX5_UMR_INLINE;
 }
 
-static __be64 get_umr_reg_mr_mask(int atomic)
+static __be64 get_umr_enable_mr_mask(void)
 {
 	u64 result;
 
-	result = MLX5_MKEY_MASK_LEN		|
-		 MLX5_MKEY_MASK_PAGE_SIZE	|
-		 MLX5_MKEY_MASK_START_ADDR	|
-		 MLX5_MKEY_MASK_PD		|
-		 MLX5_MKEY_MASK_LR		|
-		 MLX5_MKEY_MASK_LW		|
-		 MLX5_MKEY_MASK_KEY		|
-		 MLX5_MKEY_MASK_RR		|
-		 MLX5_MKEY_MASK_RW		|
+	result = MLX5_MKEY_MASK_KEY |
 		 MLX5_MKEY_MASK_FREE;
 
-	if (atomic)
-		result |= MLX5_MKEY_MASK_A;
-
-	return cpu_to_be64(result);
-}
-
-static __be64 get_umr_unreg_mr_mask(void)
-{
-	u64 result;
-
-	result = MLX5_MKEY_MASK_FREE;
-
 	return cpu_to_be64(result);
 }
 
-static __be64 get_umr_update_mtt_mask(void)
+static __be64 get_umr_disable_mr_mask(void)
 {
 	u64 result;
 
@@ -3194,23 +3171,22 @@ static __be64 get_umr_update_translation_mask(void)
 
 	result = MLX5_MKEY_MASK_LEN |
 		 MLX5_MKEY_MASK_PAGE_SIZE |
-		 MLX5_MKEY_MASK_START_ADDR |
-		 MLX5_MKEY_MASK_KEY |
-		 MLX5_MKEY_MASK_FREE;
+		 MLX5_MKEY_MASK_START_ADDR;
 
 	return cpu_to_be64(result);
 }
 
-static __be64 get_umr_update_access_mask(void)
+static __be64 get_umr_update_access_mask(int atomic)
 {
 	u64 result;
 
-	result = MLX5_MKEY_MASK_LW |
+	result = MLX5_MKEY_MASK_LR |
+		 MLX5_MKEY_MASK_LW |
 		 MLX5_MKEY_MASK_RR |
-		 MLX5_MKEY_MASK_RW |
-		 MLX5_MKEY_MASK_A |
-		 MLX5_MKEY_MASK_KEY |
-		 MLX5_MKEY_MASK_FREE;
+		 MLX5_MKEY_MASK_RW;
+
+	if (atomic)
+		result |= MLX5_MKEY_MASK_A;
 
 	return cpu_to_be64(result);
 }
@@ -3219,9 +3195,7 @@ static __be64 get_umr_update_pd_mask(void)
 {
 	u64 result;
 
-	result = MLX5_MKEY_MASK_PD |
-		 MLX5_MKEY_MASK_KEY |
-		 MLX5_MKEY_MASK_FREE;
+	result = MLX5_MKEY_MASK_PD;
 
 	return cpu_to_be64(result);
 }
@@ -3238,24 +3212,24 @@ static void set_reg_umr_segment(struct mlx5_wqe_umr_ctrl_seg *umr,
 	else
 		umr->flags = MLX5_UMR_CHECK_NOT_FREE; /* fail if not free */
 
-	if (!(wr->send_flags & MLX5_IB_SEND_UMR_UNREG)) {
-		umr->klm_octowords = get_klm_octo(umrwr->npages);
-		if (wr->send_flags & MLX5_IB_SEND_UMR_UPDATE_MTT) {
-			umr->mkey_mask = get_umr_update_mtt_mask();
-			umr->bsf_octowords = get_klm_octo(umrwr->target.offset);
-			umr->flags |= MLX5_UMR_TRANSLATION_OFFSET_EN;
-		}
-		if (wr->send_flags & MLX5_IB_SEND_UMR_UPDATE_TRANSLATION)
-			umr->mkey_mask |= get_umr_update_translation_mask();
-		if (wr->send_flags & MLX5_IB_SEND_UMR_UPDATE_ACCESS)
-			umr->mkey_mask |= get_umr_update_access_mask();
-		if (wr->send_flags & MLX5_IB_SEND_UMR_UPDATE_PD)
-			umr->mkey_mask |= get_umr_update_pd_mask();
-		if (!umr->mkey_mask)
-			umr->mkey_mask = get_umr_reg_mr_mask(atomic);
-	} else {
-		umr->mkey_mask = get_umr_unreg_mr_mask();
+	umr->xlt_octowords = cpu_to_be16(get_xlt_octo(umrwr->xlt_size));
+	if (wr->send_flags & MLX5_IB_SEND_UMR_UPDATE_XLT) {
+		u64 offset = get_xlt_octo(umrwr->offset);
+
+		umr->xlt_offset = cpu_to_be16(offset & 0xffff);
+		umr->xlt_offset_47_16 = cpu_to_be32(offset >> 16);
+		umr->flags |= MLX5_UMR_TRANSLATION_OFFSET_EN;
 	}
+	if (wr->send_flags & MLX5_IB_SEND_UMR_UPDATE_TRANSLATION)
+		umr->mkey_mask |= get_umr_update_translation_mask();
+	if (wr->send_flags & MLX5_IB_SEND_UMR_UPDATE_PD_ACCESS) {
+		umr->mkey_mask |= get_umr_update_access_mask(atomic);
+		umr->mkey_mask |= get_umr_update_pd_mask();
+	}
+	if (wr->send_flags & MLX5_IB_SEND_UMR_ENABLE_MR)
+		umr->mkey_mask |= get_umr_enable_mr_mask();
+	if (wr->send_flags & MLX5_IB_SEND_UMR_DISABLE_MR)
+		umr->mkey_mask |= get_umr_disable_mr_mask();
 
 	if (!wr->num_sge)
 		umr->flags |= MLX5_UMR_INLINE;
@@ -3303,17 +3277,17 @@ static void set_reg_mkey_segment(struct mlx5_mkey_seg *seg, struct ib_send_wr *w
 	struct mlx5_umr_wr *umrwr = umr_wr(wr);
 
 	memset(seg, 0, sizeof(*seg));
-	if (wr->send_flags & MLX5_IB_SEND_UMR_UNREG) {
+	if (wr->send_flags & MLX5_IB_SEND_UMR_DISABLE_MR)
 		seg->status = MLX5_MKEY_STATUS_FREE;
-		return;
-	}
 
 	seg->flags = convert_access(umrwr->access_flags);
-	if (!(wr->send_flags & MLX5_IB_SEND_UMR_UPDATE_MTT)) {
-		if (umrwr->pd)
-			seg->flags_pd = cpu_to_be32(to_mpd(umrwr->pd)->pdn);
-		seg->start_addr = cpu_to_be64(umrwr->target.virt_addr);
-	}
+	if (umrwr->pd)
+		seg->flags_pd = cpu_to_be32(to_mpd(umrwr->pd)->pdn);
+	if (wr->send_flags & MLX5_IB_SEND_UMR_UPDATE_TRANSLATION &&
+	    !umrwr->length)
+		seg->flags_pd |= cpu_to_be32(MLX5_MKEY_LEN64);
+
+	seg->start_addr = cpu_to_be64(umrwr->virt_addr);
 	seg->len = cpu_to_be64(umrwr->length);
 	seg->log2_page_size = umrwr->page_shift;
 	seg->qpn_mkey7_0 = cpu_to_be32(0xffffff00 |
@@ -3611,7 +3585,7 @@ static int set_sig_data_segment(struct ib_sig_handover_wr *wr,
 }
 
 static void set_sig_mkey_segment(struct mlx5_mkey_seg *seg,
-				 struct ib_sig_handover_wr *wr, u32 nelements,
+				 struct ib_sig_handover_wr *wr, u32 size,
 				 u32 length, u32 pdn)
 {
 	struct ib_mr *sig_mr = wr->sig_mr;
@@ -3626,17 +3600,17 @@ static void set_sig_mkey_segment(struct mlx5_mkey_seg *seg,
 	seg->flags_pd = cpu_to_be32(MLX5_MKEY_REMOTE_INVAL | sigerr << 26 |
 				    MLX5_MKEY_BSF_EN | pdn);
 	seg->len = cpu_to_be64(length);
-	seg->xlt_oct_size = cpu_to_be32(be16_to_cpu(get_klm_octo(nelements)));
+	seg->xlt_oct_size = cpu_to_be32(get_xlt_octo(size));
 	seg->bsfs_octo_size = cpu_to_be32(MLX5_MKEY_BSF_OCTO_SIZE);
 }
 
 static void set_sig_umr_segment(struct mlx5_wqe_umr_ctrl_seg *umr,
-				u32 nelements)
+				u32 size)
 {
 	memset(umr, 0, sizeof(*umr));
 
 	umr->flags = MLX5_FLAGS_INLINE | MLX5_FLAGS_CHECK_FREE;
-	umr->klm_octowords = get_klm_octo(nelements);
+	umr->xlt_octowords = cpu_to_be16(get_xlt_octo(size));
 	umr->bsf_octowords = cpu_to_be16(MLX5_MKEY_BSF_OCTO_SIZE);
 	umr->mkey_mask = sig_mkey_mask();
 }
@@ -3648,7 +3622,7 @@ static int set_sig_umr_wr(struct ib_send_wr *send_wr, struct mlx5_ib_qp *qp,
 	struct ib_sig_handover_wr *wr = sig_handover_wr(send_wr);
 	struct mlx5_ib_mr *sig_mr = to_mmr(wr->sig_mr);
 	u32 pdn = get_pd(qp)->pdn;
-	u32 klm_oct_size;
+	u32 xlt_size;
 	int region_len, ret;
 
 	if (unlikely(wr->wr.num_sge != 1) ||
@@ -3670,15 +3644,15 @@ static int set_sig_umr_wr(struct ib_send_wr *send_wr, struct mlx5_ib_qp *qp,
 	 * then we use strided block format (3 octowords),
 	 * else we use single KLM (1 octoword)
 	 **/
-	klm_oct_size = wr->prot ? 3 : 1;
+	xlt_size = wr->prot ? 0x30 : sizeof(struct mlx5_klm);
 
-	set_sig_umr_segment(*seg, klm_oct_size);
+	set_sig_umr_segment(*seg, xlt_size);
 	*seg += sizeof(struct mlx5_wqe_umr_ctrl_seg);
 	*size += sizeof(struct mlx5_wqe_umr_ctrl_seg) / 16;
 	if (unlikely((*seg == qp->sq.qend)))
 		*seg = mlx5_get_send_wqe(qp, 0);
 
-	set_sig_mkey_segment(*seg, wr, klm_oct_size, region_len, pdn);
+	set_sig_mkey_segment(*seg, wr, xlt_size, region_len, pdn);
 	*seg += sizeof(struct mlx5_mkey_seg);
 	*size += sizeof(struct mlx5_mkey_seg) / 16;
 	if (unlikely((*seg == qp->sq.qend)))
diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
index cbfa38f..5ff86f0 100644
--- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
+++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
@@ -396,7 +396,7 @@ static inline void mlx5e_build_umr_wqe(struct mlx5e_rq *rq, struct mlx5e_sq *sq,
 	cseg->imm       = rq->mkey_be;
 
 	ucseg->flags = MLX5_UMR_TRANSLATION_OFFSET_EN;
-	ucseg->klm_octowords =
+	ucseg->xlt_octowords =
 		cpu_to_be16(MLX5_MTT_OCTW(MLX5_MPWRQ_PAGES_PER_WQE));
 	ucseg->bsf_octowords =
 		cpu_to_be16(MLX5_MTT_OCTW(umr_wqe_mtt_offset));
diff --git a/include/linux/mlx5/qp.h b/include/linux/mlx5/qp.h
index 0aacb2a..693811e 100644
--- a/include/linux/mlx5/qp.h
+++ b/include/linux/mlx5/qp.h
@@ -292,10 +292,14 @@ struct mlx5_wqe_data_seg {
 struct mlx5_wqe_umr_ctrl_seg {
 	u8		flags;
 	u8		rsvd0[3];
-	__be16		klm_octowords;
-	__be16		bsf_octowords;
+	__be16		xlt_octowords;
+	union {
+		__be16	xlt_offset;
+		__be16	bsf_octowords;
+	};
 	__be64		mkey_mask;
-	u8		rsvd1[32];
+	__be32		xlt_offset_47_16;
+	u8		rsvd1[28];
 };
 
 struct mlx5_seg_set_psv {
@@ -389,6 +393,10 @@ struct mlx5_bsf {
 	struct mlx5_bsf_inl	m_inl;
 };
 
+struct mlx5_mtt {
+	__be64		ptag;
+};
+
 struct mlx5_klm {
 	__be32		bcount;
 	__be32		key;
-- 
2.7.4
