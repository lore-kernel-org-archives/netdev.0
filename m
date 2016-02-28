From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [net-next][PATCH v2 07/13] RDS: IB: move FMR code to its own file
Date: Sat, 27 Feb 2016 18:19:44 -0800
Message-ID: <1456625990-4739-8-git-send-email-santosh.shilimkar@oracle.com>
References: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:39095 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2992798AbcB1CUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2016 21:20:25 -0500
In-Reply-To: <1456625990-4739-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No functional change.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_fmr.c  | 126 +++++++++++++++++++++++++++++++++---------------------
 net/rds/ib_mr.h   |   6 +++
 net/rds/ib_rdma.c | 108 ++++++++++++++++++++++------------------------
 3 files changed, 134 insertions(+), 106 deletions(-)

diff --git a/net/rds/ib_fmr.c b/net/rds/ib_fmr.c
index 74f2c21..4fe8f4f 100644
--- a/net/rds/ib_fmr.c
+++ b/net/rds/ib_fmr.c
@@ -37,61 +37,16 @@ struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *rds_ibdev, int npages)
 	struct rds_ib_mr_pool *pool;
 	struct rds_ib_mr *ibmr = NULL;
 	struct rds_ib_fmr *fmr;
-	int err = 0, iter = 0;
+	int err = 0;
 
 	if (npages <= RDS_MR_8K_MSG_SIZE)
 		pool = rds_ibdev->mr_8k_pool;
 	else
 		pool = rds_ibdev->mr_1m_pool;
 
-	if (atomic_read(&pool->dirty_count) >= pool->max_items / 10)
-		queue_delayed_work(rds_ib_mr_wq, &pool->flush_worker, 10);
-
-	/* Switch pools if one of the pool is reaching upper limit */
-	if (atomic_read(&pool->dirty_count) >=  pool->max_items * 9 / 10) {
-		if (pool->pool_type == RDS_IB_MR_8K_POOL)
-			pool = rds_ibdev->mr_1m_pool;
-		else
-			pool = rds_ibdev->mr_8k_pool;
-	}
-
-	while (1) {
-		ibmr = rds_ib_reuse_mr(pool);
-		if (ibmr)
-			return ibmr;
-
-		/* No clean MRs - now we have the choice of either
-		 * allocating a fresh MR up to the limit imposed by the
-		 * driver, or flush any dirty unused MRs.
-		 * We try to avoid stalling in the send path if possible,
-		 * so we allocate as long as we're allowed to.
-		 *
-		 * We're fussy with enforcing the FMR limit, though. If the
-		 * driver tells us we can't use more than N fmrs, we shouldn't
-		 * start arguing with it
-		 */
-		if (atomic_inc_return(&pool->item_count) <= pool->max_items)
-			break;
-
-		atomic_dec(&pool->item_count);
-
-		if (++iter > 2) {
-			if (pool->pool_type == RDS_IB_MR_8K_POOL)
-				rds_ib_stats_inc(s_ib_rdma_mr_8k_pool_depleted);
-			else
-				rds_ib_stats_inc(s_ib_rdma_mr_1m_pool_depleted);
-			return ERR_PTR(-EAGAIN);
-		}
-
-		/* We do have some empty MRs. Flush them out. */
-		if (pool->pool_type == RDS_IB_MR_8K_POOL)
-			rds_ib_stats_inc(s_ib_rdma_mr_8k_pool_wait);
-		else
-			rds_ib_stats_inc(s_ib_rdma_mr_1m_pool_wait);
-		rds_ib_flush_mr_pool(pool, 0, &ibmr);
-		if (ibmr)
-			return ibmr;
-	}
+	ibmr = rds_ib_try_reuse_ibmr(pool);
+	if (ibmr)
+		return ibmr;
 
 	ibmr = kzalloc_node(sizeof(*ibmr), GFP_KERNEL,
 			    rdsibdev_to_node(rds_ibdev));
@@ -218,3 +173,76 @@ out:
 
 	return ret;
 }
+
+struct rds_ib_mr *rds_ib_reg_fmr(struct rds_ib_device *rds_ibdev,
+				 struct scatterlist *sg,
+				 unsigned long nents,
+				 u32 *key)
+{
+	struct rds_ib_mr *ibmr = NULL;
+	struct rds_ib_fmr *fmr;
+	int ret;
+
+	ibmr = rds_ib_alloc_fmr(rds_ibdev, nents);
+	if (IS_ERR(ibmr))
+		return ibmr;
+
+	ibmr->device = rds_ibdev;
+	fmr = &ibmr->u.fmr;
+	ret = rds_ib_map_fmr(rds_ibdev, ibmr, sg, nents);
+	if (ret == 0)
+		*key = fmr->fmr->rkey;
+	else
+		rds_ib_free_mr(ibmr, 0);
+
+	return ibmr;
+}
+
+void rds_ib_unreg_fmr(struct list_head *list, unsigned int *nfreed,
+		      unsigned long *unpinned, unsigned int goal)
+{
+	struct rds_ib_mr *ibmr, *next;
+	struct rds_ib_fmr *fmr;
+	LIST_HEAD(fmr_list);
+	int ret = 0;
+	unsigned int freed = *nfreed;
+
+	/* String all ib_mr's onto one list and hand them to  ib_unmap_fmr */
+	list_for_each_entry(ibmr, list, unmap_list) {
+		fmr = &ibmr->u.fmr;
+		list_add(&fmr->fmr->list, &fmr_list);
+	}
+
+	ret = ib_unmap_fmr(&fmr_list);
+	if (ret)
+		pr_warn("RDS/IB: FMR invalidation failed (err=%d)\n", ret);
+
+	/* Now we can destroy the DMA mapping and unpin any pages */
+	list_for_each_entry_safe(ibmr, next, list, unmap_list) {
+		fmr = &ibmr->u.fmr;
+		*unpinned += ibmr->sg_len;
+		__rds_ib_teardown_mr(ibmr);
+		if (freed < goal ||
+		    ibmr->remap_count >= ibmr->pool->fmr_attr.max_maps) {
+			if (ibmr->pool->pool_type == RDS_IB_MR_8K_POOL)
+				rds_ib_stats_inc(s_ib_rdma_mr_8k_free);
+			else
+				rds_ib_stats_inc(s_ib_rdma_mr_1m_free);
+			list_del(&ibmr->unmap_list);
+			ib_dealloc_fmr(fmr->fmr);
+			kfree(ibmr);
+			freed++;
+		}
+	}
+	*nfreed = freed;
+}
+
+void rds_ib_free_fmr_list(struct rds_ib_mr *ibmr)
+{
+	struct rds_ib_mr_pool *pool = ibmr->pool;
+
+	if (ibmr->remap_count >= pool->fmr_attr.max_maps)
+		llist_add(&ibmr->llnode, &pool->drop_list);
+	else
+		llist_add(&ibmr->llnode, &pool->free_list);
+}
diff --git a/net/rds/ib_mr.h b/net/rds/ib_mr.h
index 309ad59..f5c1fcb 100644
--- a/net/rds/ib_mr.h
+++ b/net/rds/ib_mr.h
@@ -113,4 +113,10 @@ int rds_ib_map_fmr(struct rds_ib_device *, struct rds_ib_mr *,
 		   struct scatterlist *, unsigned int);
 struct rds_ib_mr *rds_ib_reuse_mr(struct rds_ib_mr_pool *);
 int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *, int, struct rds_ib_mr **);
+struct rds_ib_mr *rds_ib_reg_fmr(struct rds_ib_device *, struct scatterlist *,
+				 unsigned long, u32 *);
+struct rds_ib_mr *rds_ib_try_reuse_ibmr(struct rds_ib_mr_pool *);
+void rds_ib_unreg_fmr(struct list_head *, unsigned int *,
+		      unsigned long *, unsigned int);
+void rds_ib_free_fmr_list(struct rds_ib_mr *);
 #endif
diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 9e608d9..0e84843 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -333,15 +333,12 @@ static void list_to_llist_nodes(struct rds_ib_mr_pool *pool,
 int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
 			 int free_all, struct rds_ib_mr **ibmr_ret)
 {
-	struct rds_ib_mr *ibmr, *next;
-	struct rds_ib_fmr *fmr;
+	struct rds_ib_mr *ibmr;
 	struct llist_node *clean_nodes;
 	struct llist_node *clean_tail;
 	LIST_HEAD(unmap_list);
-	LIST_HEAD(fmr_list);
 	unsigned long unpinned = 0;
 	unsigned int nfreed = 0, dirty_to_clean = 0, free_goal;
-	int ret = 0;
 
 	if (pool->pool_type == RDS_IB_MR_8K_POOL)
 		rds_ib_stats_inc(s_ib_rdma_mr_8k_pool_flush);
@@ -395,33 +392,7 @@ int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
 	if (list_empty(&unmap_list))
 		goto out;
 
-	/* String all ib_mr's onto one list and hand them to ib_unmap_fmr */
-	list_for_each_entry(ibmr, &unmap_list, unmap_list) {
-		fmr = &ibmr->u.fmr;
-		list_add(&fmr->fmr->list, &fmr_list);
-	}
-
-	ret = ib_unmap_fmr(&fmr_list);
-	if (ret)
-		printk(KERN_WARNING "RDS/IB: ib_unmap_fmr failed (err=%d)\n", ret);
-
-	/* Now we can destroy the DMA mapping and unpin any pages */
-	list_for_each_entry_safe(ibmr, next, &unmap_list, unmap_list) {
-		unpinned += ibmr->sg_len;
-		fmr = &ibmr->u.fmr;
-		__rds_ib_teardown_mr(ibmr);
-		if (nfreed < free_goal ||
-		    ibmr->remap_count >= pool->fmr_attr.max_maps) {
-			if (ibmr->pool->pool_type == RDS_IB_MR_8K_POOL)
-				rds_ib_stats_inc(s_ib_rdma_mr_8k_free);
-			else
-				rds_ib_stats_inc(s_ib_rdma_mr_1m_free);
-			list_del(&ibmr->unmap_list);
-			ib_dealloc_fmr(fmr->fmr);
-			kfree(ibmr);
-			nfreed++;
-		}
-	}
+	rds_ib_unreg_fmr(&unmap_list, &nfreed, &unpinned, free_goal);
 
 	if (!list_empty(&unmap_list)) {
 		/* we have to make sure that none of the things we're about
@@ -454,7 +425,47 @@ out:
 	if (waitqueue_active(&pool->flush_wait))
 		wake_up(&pool->flush_wait);
 out_nolock:
-	return ret;
+	return 0;
+}
+
+struct rds_ib_mr *rds_ib_try_reuse_ibmr(struct rds_ib_mr_pool *pool)
+{
+	struct rds_ib_mr *ibmr = NULL;
+	int iter = 0;
+
+	if (atomic_read(&pool->dirty_count) >= pool->max_items_soft / 10)
+		queue_delayed_work(rds_ib_mr_wq, &pool->flush_worker, 10);
+
+	while (1) {
+		ibmr = rds_ib_reuse_mr(pool);
+		if (ibmr)
+			return ibmr;
+
+		if (atomic_inc_return(&pool->item_count) <= pool->max_items)
+			break;
+
+		atomic_dec(&pool->item_count);
+
+		if (++iter > 2) {
+			if (pool->pool_type == RDS_IB_MR_8K_POOL)
+				rds_ib_stats_inc(s_ib_rdma_mr_8k_pool_depleted);
+			else
+				rds_ib_stats_inc(s_ib_rdma_mr_1m_pool_depleted);
+			return ERR_PTR(-EAGAIN);
+		}
+
+		/* We do have some empty MRs. Flush them out. */
+		if (pool->pool_type == RDS_IB_MR_8K_POOL)
+			rds_ib_stats_inc(s_ib_rdma_mr_8k_pool_wait);
+		else
+			rds_ib_stats_inc(s_ib_rdma_mr_1m_pool_wait);
+
+		rds_ib_flush_mr_pool(pool, 0, &ibmr);
+		if (ibmr)
+			return ibmr;
+	}
+
+	return ibmr;
 }
 
 static void rds_ib_mr_pool_flush_worker(struct work_struct *work)
@@ -473,10 +484,7 @@ void rds_ib_free_mr(void *trans_private, int invalidate)
 	rdsdebug("RDS/IB: free_mr nents %u\n", ibmr->sg_len);
 
 	/* Return it to the pool's free list */
-	if (ibmr->remap_count >= pool->fmr_attr.max_maps)
-		llist_add(&ibmr->llnode, &pool->drop_list);
-	else
-		llist_add(&ibmr->llnode, &pool->free_list);
+	rds_ib_free_fmr_list(ibmr);
 
 	atomic_add(ibmr->sg_len, &pool->free_pinned);
 	atomic_inc(&pool->dirty_count);
@@ -521,7 +529,6 @@ void *rds_ib_get_mr(struct scatterlist *sg, unsigned long nents,
 {
 	struct rds_ib_device *rds_ibdev;
 	struct rds_ib_mr *ibmr = NULL;
-	struct rds_ib_fmr *fmr;
 	int ret;
 
 	rds_ibdev = rds_ib_get_device(rs->rs_bound_addr);
@@ -535,30 +542,17 @@ void *rds_ib_get_mr(struct scatterlist *sg, unsigned long nents,
 		goto out;
 	}
 
-	ibmr = rds_ib_alloc_fmr(rds_ibdev, nents);
-	if (IS_ERR(ibmr)) {
-		rds_ib_dev_put(rds_ibdev);
-		return ibmr;
-	}
-
-	fmr = &ibmr->u.fmr;
-	ret = rds_ib_map_fmr(rds_ibdev, ibmr, sg, nents);
-	if (ret == 0)
-		*key_ret = fmr->fmr->rkey;
-	else
-		printk(KERN_WARNING "RDS/IB: map_fmr failed (errno=%d)\n", ret);
-
-	ibmr->device = rds_ibdev;
-	rds_ibdev = NULL;
+	ibmr = rds_ib_reg_fmr(rds_ibdev, sg, nents, key_ret);
+	if (ibmr)
+		rds_ibdev = NULL;
 
  out:
-	if (ret) {
-		if (ibmr)
-			rds_ib_free_mr(ibmr, 0);
-		ibmr = ERR_PTR(ret);
-	}
+	if (!ibmr)
+		pr_warn("RDS/IB: rds_ib_get_mr failed (errno=%d)\n", ret);
+
 	if (rds_ibdev)
 		rds_ib_dev_put(rds_ibdev);
+
 	return ibmr;
 }
 
-- 
1.9.1
