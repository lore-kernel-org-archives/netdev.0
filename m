From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH 06/13] RDS: IB: create struct rds_ib_fmr
Date: Fri, 26 Feb 2016 21:43:51 -0800
Message-ID: <1456551838-9080-7-git-send-email-santosh.shilimkar@oracle.com>
References: <1456551838-9080-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1456551838-9080-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Keep fmr related filed in its own struct. Fastreg MR structure
will be added to the union.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_fmr.c  | 17 ++++++++++-------
 net/rds/ib_mr.h   | 11 +++++++++--
 net/rds/ib_rdma.c | 14 ++++++++++----
 3 files changed, 29 insertions(+), 13 deletions(-)

diff --git a/net/rds/ib_fmr.c b/net/rds/ib_fmr.c
index d4f200d..74f2c21 100644
--- a/net/rds/ib_fmr.c
+++ b/net/rds/ib_fmr.c
@@ -36,6 +36,7 @@ struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *rds_ibdev, int npages)
 {
 	struct rds_ib_mr_pool *pool;
 	struct rds_ib_mr *ibmr = NULL;
+	struct rds_ib_fmr *fmr;
 	int err = 0, iter = 0;
 
 	if (npages <= RDS_MR_8K_MSG_SIZE)
@@ -99,15 +100,16 @@ struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *rds_ibdev, int npages)
 		goto out_no_cigar;
 	}
 
-	ibmr->fmr = ib_alloc_fmr(rds_ibdev->pd,
+	fmr = &ibmr->u.fmr;
+	fmr->fmr = ib_alloc_fmr(rds_ibdev->pd,
 			(IB_ACCESS_LOCAL_WRITE |
 			 IB_ACCESS_REMOTE_READ |
 			 IB_ACCESS_REMOTE_WRITE |
 			 IB_ACCESS_REMOTE_ATOMIC),
 			&pool->fmr_attr);
-	if (IS_ERR(ibmr->fmr)) {
-		err = PTR_ERR(ibmr->fmr);
-		ibmr->fmr = NULL;
+	if (IS_ERR(fmr->fmr)) {
+		err = PTR_ERR(fmr->fmr);
+		fmr->fmr = NULL;
 		pr_warn("RDS/IB: %s failed (err=%d)\n", __func__, err);
 		goto out_no_cigar;
 	}
@@ -122,8 +124,8 @@ struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *rds_ibdev, int npages)
 
 out_no_cigar:
 	if (ibmr) {
-		if (ibmr->fmr)
-			ib_dealloc_fmr(ibmr->fmr);
+		if (fmr->fmr)
+			ib_dealloc_fmr(fmr->fmr);
 		kfree(ibmr);
 	}
 	atomic_dec(&pool->item_count);
@@ -134,6 +136,7 @@ int rds_ib_map_fmr(struct rds_ib_device *rds_ibdev, struct rds_ib_mr *ibmr,
 		   struct scatterlist *sg, unsigned int nents)
 {
 	struct ib_device *dev = rds_ibdev->dev;
+	struct rds_ib_fmr *fmr = &ibmr->u.fmr;
 	struct scatterlist *scat = sg;
 	u64 io_addr = 0;
 	u64 *dma_pages;
@@ -190,7 +193,7 @@ int rds_ib_map_fmr(struct rds_ib_device *rds_ibdev, struct rds_ib_mr *ibmr,
 				(dma_addr & PAGE_MASK) + j;
 	}
 
-	ret = ib_map_phys_fmr(ibmr->fmr, dma_pages, page_cnt, io_addr);
+	ret = ib_map_phys_fmr(fmr->fmr, dma_pages, page_cnt, io_addr);
 	if (ret)
 		goto out;
 
diff --git a/net/rds/ib_mr.h b/net/rds/ib_mr.h
index d88724f..309ad59 100644
--- a/net/rds/ib_mr.h
+++ b/net/rds/ib_mr.h
@@ -43,11 +43,15 @@
 #define RDS_MR_8K_SCALE			(256 / (RDS_MR_8K_MSG_SIZE + 1))
 #define RDS_MR_8K_POOL_SIZE		(RDS_MR_8K_SCALE * (8192 / 2))
 
+struct rds_ib_fmr {
+	struct ib_fmr		*fmr;
+	u64			*dma;
+};
+
 /* This is stored as mr->r_trans_private. */
 struct rds_ib_mr {
 	struct rds_ib_device	*device;
 	struct rds_ib_mr_pool	*pool;
-	struct ib_fmr		*fmr;
 
 	struct llist_node	llnode;
 
@@ -57,8 +61,11 @@ struct rds_ib_mr {
 
 	struct scatterlist	*sg;
 	unsigned int		sg_len;
-	u64			*dma;
 	int			sg_dma_len;
+
+	union {
+		struct rds_ib_fmr	fmr;
+	} u;
 };
 
 /* Our own little MR pool */
diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index c594519..9e608d9 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -334,6 +334,7 @@ int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
 			 int free_all, struct rds_ib_mr **ibmr_ret)
 {
 	struct rds_ib_mr *ibmr, *next;
+	struct rds_ib_fmr *fmr;
 	struct llist_node *clean_nodes;
 	struct llist_node *clean_tail;
 	LIST_HEAD(unmap_list);
@@ -395,8 +396,10 @@ int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
 		goto out;
 
 	/* String all ib_mr's onto one list and hand them to ib_unmap_fmr */
-	list_for_each_entry(ibmr, &unmap_list, unmap_list)
-		list_add(&ibmr->fmr->list, &fmr_list);
+	list_for_each_entry(ibmr, &unmap_list, unmap_list) {
+		fmr = &ibmr->u.fmr;
+		list_add(&fmr->fmr->list, &fmr_list);
+	}
 
 	ret = ib_unmap_fmr(&fmr_list);
 	if (ret)
@@ -405,6 +408,7 @@ int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
 	/* Now we can destroy the DMA mapping and unpin any pages */
 	list_for_each_entry_safe(ibmr, next, &unmap_list, unmap_list) {
 		unpinned += ibmr->sg_len;
+		fmr = &ibmr->u.fmr;
 		__rds_ib_teardown_mr(ibmr);
 		if (nfreed < free_goal ||
 		    ibmr->remap_count >= pool->fmr_attr.max_maps) {
@@ -413,7 +417,7 @@ int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
 			else
 				rds_ib_stats_inc(s_ib_rdma_mr_1m_free);
 			list_del(&ibmr->unmap_list);
-			ib_dealloc_fmr(ibmr->fmr);
+			ib_dealloc_fmr(fmr->fmr);
 			kfree(ibmr);
 			nfreed++;
 		}
@@ -517,6 +521,7 @@ void *rds_ib_get_mr(struct scatterlist *sg, unsigned long nents,
 {
 	struct rds_ib_device *rds_ibdev;
 	struct rds_ib_mr *ibmr = NULL;
+	struct rds_ib_fmr *fmr;
 	int ret;
 
 	rds_ibdev = rds_ib_get_device(rs->rs_bound_addr);
@@ -536,9 +541,10 @@ void *rds_ib_get_mr(struct scatterlist *sg, unsigned long nents,
 		return ibmr;
 	}
 
+	fmr = &ibmr->u.fmr;
 	ret = rds_ib_map_fmr(rds_ibdev, ibmr, sg, nents);
 	if (ret == 0)
-		*key_ret = ibmr->fmr->rkey;
+		*key_ret = fmr->fmr->rkey;
 	else
 		printk(KERN_WARNING "RDS/IB: map_fmr failed (errno=%d)\n", ret);
 
-- 
1.9.1
