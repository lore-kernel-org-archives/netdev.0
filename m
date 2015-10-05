From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH v3 14/14] RDS: IB: split mr pool to improve 8K messages performance
Date: Mon,  5 Oct 2015 10:56:37 -0700
Message-ID: <1444067797-14101-15-git-send-email-santosh.shilimkar@oracle.com>
References: <1444067797-14101-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: davem@davemloft.net, linux-kernel@vger.kernel.org,
	ssantosh@kernel.org,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444067797-14101-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

8K message sizes are pretty important usecase for RDS current
workloads so we make provison to have 8K mrs available from the pool.
Based on number of SG's in the RDS message, we pick a pool to use.

Also to make sure that we don't under utlise mrs when say 8k messages
are dominating which could lead to 8k pull being exhausted, we fall-back
to 1m pool till 8k pool recovers for use.

This helps to at least push ~55 kB/s bidirectional data which
is a nice improvement.

Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib.c       |  47 +++++++++++++++++--------
 net/rds/ib.h       |  43 ++++++++++++++++-------
 net/rds/ib_rdma.c  | 101 +++++++++++++++++++++++++++++++++++++----------------
 net/rds/ib_stats.c |  18 ++++++----
 4 files changed, 147 insertions(+), 62 deletions(-)

diff --git a/net/rds/ib.c b/net/rds/ib.c
index 883813a..a833ab7 100644
--- a/net/rds/ib.c
+++ b/net/rds/ib.c
@@ -43,14 +43,14 @@
 #include "rds.h"
 #include "ib.h"
 
-static unsigned int fmr_pool_size = RDS_FMR_POOL_SIZE;
-unsigned int fmr_message_size = RDS_FMR_SIZE + 1; /* +1 allows for unaligned MRs */
+unsigned int rds_ib_fmr_1m_pool_size = RDS_FMR_1M_POOL_SIZE;
+unsigned int rds_ib_fmr_8k_pool_size = RDS_FMR_8K_POOL_SIZE;
 unsigned int rds_ib_retry_count = RDS_IB_DEFAULT_RETRY_COUNT;
 
-module_param(fmr_pool_size, int, 0444);
-MODULE_PARM_DESC(fmr_pool_size, " Max number of fmr per HCA");
-module_param(fmr_message_size, int, 0444);
-MODULE_PARM_DESC(fmr_message_size, " Max size of a RDMA transfer");
+module_param(rds_ib_fmr_1m_pool_size, int, 0444);
+MODULE_PARM_DESC(rds_ib_fmr_1m_pool_size, " Max number of 1M fmr per HCA");
+module_param(rds_ib_fmr_8k_pool_size, int, 0444);
+MODULE_PARM_DESC(rds_ib_fmr_8k_pool_size, " Max number of 8K fmr per HCA");
 module_param(rds_ib_retry_count, int, 0444);
 MODULE_PARM_DESC(rds_ib_retry_count, " Number of hw retries before reporting an error");
 
@@ -97,8 +97,10 @@ static void rds_ib_dev_free(struct work_struct *work)
 	struct rds_ib_device *rds_ibdev = container_of(work,
 					struct rds_ib_device, free_work);
 
-	if (rds_ibdev->mr_pool)
-		rds_ib_destroy_mr_pool(rds_ibdev->mr_pool);
+	if (rds_ibdev->mr_8k_pool)
+		rds_ib_destroy_mr_pool(rds_ibdev->mr_8k_pool);
+	if (rds_ibdev->mr_1m_pool)
+		rds_ib_destroy_mr_pool(rds_ibdev->mr_1m_pool);
 	if (rds_ibdev->pd)
 		ib_dealloc_pd(rds_ibdev->pd);
 
@@ -148,9 +150,13 @@ static void rds_ib_add_one(struct ib_device *device)
 	rds_ibdev->max_sge = min(dev_attr->max_sge, RDS_IB_MAX_SGE);
 
 	rds_ibdev->fmr_max_remaps = dev_attr->max_map_per_fmr?: 32;
-	rds_ibdev->max_fmrs = dev_attr->max_mr ?
-			min_t(unsigned int, dev_attr->max_mr, fmr_pool_size) :
-			fmr_pool_size;
+	rds_ibdev->max_1m_fmrs = dev_attr->max_mr ?
+		min_t(unsigned int, (dev_attr->max_mr / 2),
+		      rds_ib_fmr_1m_pool_size) : rds_ib_fmr_1m_pool_size;
+
+	rds_ibdev->max_8k_fmrs = dev_attr->max_mr ?
+		min_t(unsigned int, ((dev_attr->max_mr / 2) * RDS_MR_8K_SCALE),
+		      rds_ib_fmr_8k_pool_size) : rds_ib_fmr_8k_pool_size;
 
 	rds_ibdev->max_initiator_depth = dev_attr->max_qp_init_rd_atom;
 	rds_ibdev->max_responder_resources = dev_attr->max_qp_rd_atom;
@@ -162,12 +168,25 @@ static void rds_ib_add_one(struct ib_device *device)
 		goto put_dev;
 	}
 
-	rds_ibdev->mr_pool = rds_ib_create_mr_pool(rds_ibdev);
-	if (IS_ERR(rds_ibdev->mr_pool)) {
-		rds_ibdev->mr_pool = NULL;
+	rds_ibdev->mr_1m_pool =
+		rds_ib_create_mr_pool(rds_ibdev, RDS_IB_MR_1M_POOL);
+	if (IS_ERR(rds_ibdev->mr_1m_pool)) {
+		rds_ibdev->mr_1m_pool = NULL;
 		goto put_dev;
 	}
 
+	rds_ibdev->mr_8k_pool =
+		rds_ib_create_mr_pool(rds_ibdev, RDS_IB_MR_8K_POOL);
+	if (IS_ERR(rds_ibdev->mr_8k_pool)) {
+		rds_ibdev->mr_8k_pool = NULL;
+		goto put_dev;
+	}
+
+	rdsdebug("RDS/IB: max_mr = %d, max_wrs = %d, max_sge = %d, fmr_max_remaps = %d, max_1m_fmrs = %d, max_8k_fmrs = %d\n",
+		 dev_attr->max_fmr, rds_ibdev->max_wrs, rds_ibdev->max_sge,
+		 rds_ibdev->fmr_max_remaps, rds_ibdev->max_1m_fmrs,
+		 rds_ibdev->max_8k_fmrs);
+
 	INIT_LIST_HEAD(&rds_ibdev->ipaddr_list);
 	INIT_LIST_HEAD(&rds_ibdev->conn_list);
 
diff --git a/net/rds/ib.h b/net/rds/ib.h
index 3a8cd31..f17d095 100644
--- a/net/rds/ib.h
+++ b/net/rds/ib.h
@@ -9,8 +9,11 @@
 #include "rds.h"
 #include "rdma_transport.h"
 
-#define RDS_FMR_SIZE			256
-#define RDS_FMR_POOL_SIZE		8192
+#define RDS_FMR_1M_POOL_SIZE		(8192 / 2)
+#define RDS_FMR_1M_MSG_SIZE		256
+#define RDS_FMR_8K_MSG_SIZE		2
+#define RDS_MR_8K_SCALE			(256 / (RDS_FMR_8K_MSG_SIZE + 1))
+#define RDS_FMR_8K_POOL_SIZE		(RDS_MR_8K_SCALE * (8192 / 2))
 
 #define RDS_IB_MAX_SGE			8
 #define RDS_IB_RECV_SGE 		2
@@ -189,15 +192,23 @@ struct rds_ib_ipaddr {
 	struct rcu_head		rcu;
 };
 
+enum {
+	RDS_IB_MR_8K_POOL,
+	RDS_IB_MR_1M_POOL,
+};
+
 struct rds_ib_device {
 	struct list_head	list;
 	struct list_head	ipaddr_list;
 	struct list_head	conn_list;
 	struct ib_device	*dev;
 	struct ib_pd		*pd;
-	struct rds_ib_mr_pool	*mr_pool;
-	unsigned int		fmr_max_remaps;
 	unsigned int		max_fmrs;
+	struct rds_ib_mr_pool	*mr_1m_pool;
+	struct rds_ib_mr_pool   *mr_8k_pool;
+	unsigned int		fmr_max_remaps;
+	unsigned int		max_8k_fmrs;
+	unsigned int		max_1m_fmrs;
 	int			max_sge;
 	unsigned int		max_wrs;
 	unsigned int		max_initiator_depth;
@@ -239,12 +250,18 @@ struct rds_ib_statistics {
 	uint64_t	s_ib_ack_send_delayed;
 	uint64_t	s_ib_ack_send_piggybacked;
 	uint64_t	s_ib_ack_received;
-	uint64_t	s_ib_rdma_mr_alloc;
-	uint64_t	s_ib_rdma_mr_free;
-	uint64_t	s_ib_rdma_mr_used;
-	uint64_t	s_ib_rdma_mr_pool_flush;
-	uint64_t	s_ib_rdma_mr_pool_wait;
-	uint64_t	s_ib_rdma_mr_pool_depleted;
+	uint64_t	s_ib_rdma_mr_8k_alloc;
+	uint64_t	s_ib_rdma_mr_8k_free;
+	uint64_t	s_ib_rdma_mr_8k_used;
+	uint64_t	s_ib_rdma_mr_8k_pool_flush;
+	uint64_t	s_ib_rdma_mr_8k_pool_wait;
+	uint64_t	s_ib_rdma_mr_8k_pool_depleted;
+	uint64_t	s_ib_rdma_mr_1m_alloc;
+	uint64_t	s_ib_rdma_mr_1m_free;
+	uint64_t	s_ib_rdma_mr_1m_used;
+	uint64_t	s_ib_rdma_mr_1m_pool_flush;
+	uint64_t	s_ib_rdma_mr_1m_pool_wait;
+	uint64_t	s_ib_rdma_mr_1m_pool_depleted;
 	uint64_t	s_ib_atomic_cswp;
 	uint64_t	s_ib_atomic_fadd;
 };
@@ -296,7 +313,8 @@ struct rds_ib_device *rds_ib_get_client_data(struct ib_device *device);
 void rds_ib_dev_put(struct rds_ib_device *rds_ibdev);
 extern struct ib_client rds_ib_client;
 
-extern unsigned int fmr_message_size;
+extern unsigned int rds_ib_fmr_1m_pool_size;
+extern unsigned int rds_ib_fmr_8k_pool_size;
 extern unsigned int rds_ib_retry_count;
 
 extern spinlock_t ib_nodev_conns_lock;
@@ -326,7 +344,8 @@ int rds_ib_update_ipaddr(struct rds_ib_device *rds_ibdev, __be32 ipaddr);
 void rds_ib_add_conn(struct rds_ib_device *rds_ibdev, struct rds_connection *conn);
 void rds_ib_remove_conn(struct rds_ib_device *rds_ibdev, struct rds_connection *conn);
 void rds_ib_destroy_nodev_conns(void);
-struct rds_ib_mr_pool *rds_ib_create_mr_pool(struct rds_ib_device *);
+struct rds_ib_mr_pool *rds_ib_create_mr_pool(struct rds_ib_device *rds_dev,
+					     int npages);
 void rds_ib_get_mr_info(struct rds_ib_device *rds_ibdev, struct rds_info_rdma_connection *iinfo);
 void rds_ib_destroy_mr_pool(struct rds_ib_mr_pool *);
 void *rds_ib_get_mr(struct scatterlist *sg, unsigned long nents,
diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index bb62024..a234074 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -65,6 +65,7 @@ struct rds_ib_mr {
  * Our own little FMR pool
  */
 struct rds_ib_mr_pool {
+	unsigned int            pool_type;
 	struct mutex		flush_lock;		/* serialize fmr invalidate */
 	struct delayed_work	flush_worker;		/* flush worker */
 
@@ -234,7 +235,8 @@ void rds_ib_destroy_nodev_conns(void)
 		rds_conn_destroy(ic->conn);
 }
 
-struct rds_ib_mr_pool *rds_ib_create_mr_pool(struct rds_ib_device *rds_ibdev)
+struct rds_ib_mr_pool *rds_ib_create_mr_pool(struct rds_ib_device *rds_ibdev,
+					     int pool_type)
 {
 	struct rds_ib_mr_pool *pool;
 
@@ -242,6 +244,7 @@ struct rds_ib_mr_pool *rds_ib_create_mr_pool(struct rds_ib_device *rds_ibdev)
 	if (!pool)
 		return ERR_PTR(-ENOMEM);
 
+	pool->pool_type = pool_type;
 	init_llist_head(&pool->free_list);
 	init_llist_head(&pool->drop_list);
 	init_llist_head(&pool->clean_list);
@@ -249,28 +252,30 @@ struct rds_ib_mr_pool *rds_ib_create_mr_pool(struct rds_ib_device *rds_ibdev)
 	init_waitqueue_head(&pool->flush_wait);
 	INIT_DELAYED_WORK(&pool->flush_worker, rds_ib_mr_pool_flush_worker);
 
-	pool->fmr_attr.max_pages = fmr_message_size;
+	if (pool_type == RDS_IB_MR_1M_POOL) {
+		/* +1 allows for unaligned MRs */
+		pool->fmr_attr.max_pages = RDS_FMR_1M_MSG_SIZE + 1;
+		pool->max_items = RDS_FMR_1M_POOL_SIZE;
+	} else {
+		/* pool_type == RDS_IB_MR_8K_POOL */
+		pool->fmr_attr.max_pages = RDS_FMR_8K_MSG_SIZE + 1;
+		pool->max_items = RDS_FMR_8K_POOL_SIZE;
+	}
+
+	pool->max_free_pinned = pool->max_items * pool->fmr_attr.max_pages / 4;
 	pool->fmr_attr.max_maps = rds_ibdev->fmr_max_remaps;
 	pool->fmr_attr.page_shift = PAGE_SHIFT;
-	pool->max_free_pinned = rds_ibdev->max_fmrs * fmr_message_size / 4;
-
-	/* We never allow more than max_items MRs to be allocated.
-	 * When we exceed more than max_items_soft, we start freeing
-	 * items more aggressively.
-	 * Make sure that max_items > max_items_soft > max_items / 2
-	 */
 	pool->max_items_soft = rds_ibdev->max_fmrs * 3 / 4;
-	pool->max_items = rds_ibdev->max_fmrs;
 
 	return pool;
 }
 
 void rds_ib_get_mr_info(struct rds_ib_device *rds_ibdev, struct rds_info_rdma_connection *iinfo)
 {
-	struct rds_ib_mr_pool *pool = rds_ibdev->mr_pool;
+	struct rds_ib_mr_pool *pool_1m = rds_ibdev->mr_1m_pool;
 
-	iinfo->rdma_mr_max = pool->max_items;
-	iinfo->rdma_mr_size = pool->fmr_attr.max_pages;
+	iinfo->rdma_mr_max = pool_1m->max_items;
+	iinfo->rdma_mr_size = pool_1m->fmr_attr.max_pages;
 }
 
 void rds_ib_destroy_mr_pool(struct rds_ib_mr_pool *pool)
@@ -312,15 +317,29 @@ static inline void wait_clean_list_grace(void)
 	}
 }
 
-static struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *rds_ibdev)
+static struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *rds_ibdev,
+					  int npages)
 {
-	struct rds_ib_mr_pool *pool = rds_ibdev->mr_pool;
+	struct rds_ib_mr_pool *pool;
 	struct rds_ib_mr *ibmr = NULL;
 	int err = 0, iter = 0;
 
+	if (npages <= RDS_FMR_8K_MSG_SIZE)
+		pool = rds_ibdev->mr_8k_pool;
+	else
+		pool = rds_ibdev->mr_1m_pool;
+
 	if (atomic_read(&pool->dirty_count) >= pool->max_items / 10)
 		queue_delayed_work(rds_ib_fmr_wq, &pool->flush_worker, 10);
 
+	/* Switch pools if one of the pool is reaching upper limit */
+	if (atomic_read(&pool->dirty_count) >=  pool->max_items * 9 / 10) {
+		if (pool->pool_type == RDS_IB_MR_8K_POOL)
+			pool = rds_ibdev->mr_1m_pool;
+		else
+			pool = rds_ibdev->mr_8k_pool;
+	}
+
 	while (1) {
 		ibmr = rds_ib_reuse_fmr(pool);
 		if (ibmr)
@@ -341,12 +360,18 @@ static struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *rds_ibdev)
 		atomic_dec(&pool->item_count);
 
 		if (++iter > 2) {
-			rds_ib_stats_inc(s_ib_rdma_mr_pool_depleted);
+			if (pool->pool_type == RDS_IB_MR_8K_POOL)
+				rds_ib_stats_inc(s_ib_rdma_mr_8k_pool_depleted);
+			else
+				rds_ib_stats_inc(s_ib_rdma_mr_1m_pool_depleted);
 			return ERR_PTR(-EAGAIN);
 		}
 
 		/* We do have some empty MRs. Flush them out. */
-		rds_ib_stats_inc(s_ib_rdma_mr_pool_wait);
+		if (pool->pool_type == RDS_IB_MR_8K_POOL)
+			rds_ib_stats_inc(s_ib_rdma_mr_8k_pool_wait);
+		else
+			rds_ib_stats_inc(s_ib_rdma_mr_1m_pool_wait);
 		rds_ib_flush_mr_pool(pool, 0, &ibmr);
 		if (ibmr)
 			return ibmr;
@@ -371,7 +396,12 @@ static struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *rds_ibdev)
 		goto out_no_cigar;
 	}
 
-	rds_ib_stats_inc(s_ib_rdma_mr_alloc);
+	ibmr->pool = pool;
+	if (pool->pool_type == RDS_IB_MR_8K_POOL)
+		rds_ib_stats_inc(s_ib_rdma_mr_8k_alloc);
+	else
+		rds_ib_stats_inc(s_ib_rdma_mr_1m_alloc);
+
 	return ibmr;
 
 out_no_cigar:
@@ -427,7 +457,7 @@ static int rds_ib_map_fmr(struct rds_ib_device *rds_ibdev, struct rds_ib_mr *ibm
 	}
 
 	page_cnt += len >> PAGE_SHIFT;
-	if (page_cnt > fmr_message_size)
+	if (page_cnt > ibmr->pool->fmr_attr.max_pages)
 		return -EINVAL;
 
 	dma_pages = kmalloc_node(sizeof(u64) * page_cnt, GFP_ATOMIC,
@@ -459,7 +489,10 @@ static int rds_ib_map_fmr(struct rds_ib_device *rds_ibdev, struct rds_ib_mr *ibm
 	ibmr->sg_dma_len = sg_dma_len;
 	ibmr->remap_count++;
 
-	rds_ib_stats_inc(s_ib_rdma_mr_used);
+	if (ibmr->pool->pool_type == RDS_IB_MR_8K_POOL)
+		rds_ib_stats_inc(s_ib_rdma_mr_8k_used);
+	else
+		rds_ib_stats_inc(s_ib_rdma_mr_1m_used);
 	ret = 0;
 
 out:
@@ -591,7 +624,7 @@ static void list_to_llist_nodes(struct rds_ib_mr_pool *pool,
  * to free as many MRs as needed to get back to this limit.
  */
 static int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
-			        int free_all, struct rds_ib_mr **ibmr_ret)
+				int free_all, struct rds_ib_mr **ibmr_ret)
 {
 	struct rds_ib_mr *ibmr, *next;
 	struct llist_node *clean_nodes;
@@ -602,11 +635,14 @@ static int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
 	unsigned int nfreed = 0, dirty_to_clean = 0, free_goal;
 	int ret = 0;
 
-	rds_ib_stats_inc(s_ib_rdma_mr_pool_flush);
+	if (pool->pool_type == RDS_IB_MR_8K_POOL)
+		rds_ib_stats_inc(s_ib_rdma_mr_8k_pool_flush);
+	else
+		rds_ib_stats_inc(s_ib_rdma_mr_1m_pool_flush);
 
 	if (ibmr_ret) {
 		DEFINE_WAIT(wait);
-		while(!mutex_trylock(&pool->flush_lock)) {
+		while (!mutex_trylock(&pool->flush_lock)) {
 			ibmr = rds_ib_reuse_fmr(pool);
 			if (ibmr) {
 				*ibmr_ret = ibmr;
@@ -663,8 +699,12 @@ static int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
 	list_for_each_entry_safe(ibmr, next, &unmap_list, unmap_list) {
 		unpinned += ibmr->sg_len;
 		__rds_ib_teardown_mr(ibmr);
-		if (nfreed < free_goal || ibmr->remap_count >= pool->fmr_attr.max_maps) {
-			rds_ib_stats_inc(s_ib_rdma_mr_free);
+		if (nfreed < free_goal ||
+		    ibmr->remap_count >= pool->fmr_attr.max_maps) {
+			if (ibmr->pool->pool_type == RDS_IB_MR_8K_POOL)
+				rds_ib_stats_inc(s_ib_rdma_mr_8k_free);
+			else
+				rds_ib_stats_inc(s_ib_rdma_mr_1m_free);
 			list_del(&ibmr->unmap_list);
 			ib_dealloc_fmr(ibmr->fmr);
 			kfree(ibmr);
@@ -756,10 +796,11 @@ void rds_ib_flush_mrs(void)
 
 	down_read(&rds_ib_devices_lock);
 	list_for_each_entry(rds_ibdev, &rds_ib_devices, list) {
-		struct rds_ib_mr_pool *pool = rds_ibdev->mr_pool;
+		if (rds_ibdev->mr_8k_pool)
+			rds_ib_flush_mr_pool(rds_ibdev->mr_8k_pool, 0, NULL);
 
-		if (pool)
-			rds_ib_flush_mr_pool(pool, 0, NULL);
+		if (rds_ibdev->mr_1m_pool)
+			rds_ib_flush_mr_pool(rds_ibdev->mr_1m_pool, 0, NULL);
 	}
 	up_read(&rds_ib_devices_lock);
 }
@@ -777,12 +818,12 @@ void *rds_ib_get_mr(struct scatterlist *sg, unsigned long nents,
 		goto out;
 	}
 
-	if (!rds_ibdev->mr_pool) {
+	if (!rds_ibdev->mr_8k_pool || !rds_ibdev->mr_1m_pool) {
 		ret = -ENODEV;
 		goto out;
 	}
 
-	ibmr = rds_ib_alloc_fmr(rds_ibdev);
+	ibmr = rds_ib_alloc_fmr(rds_ibdev, nents);
 	if (IS_ERR(ibmr)) {
 		rds_ib_dev_put(rds_ibdev);
 		return ibmr;
diff --git a/net/rds/ib_stats.c b/net/rds/ib_stats.c
index 8c8b84f..d77e044 100644
--- a/net/rds/ib_stats.c
+++ b/net/rds/ib_stats.c
@@ -61,12 +61,18 @@ static const char *const rds_ib_stat_names[] = {
 	"ib_ack_send_delayed",
 	"ib_ack_send_piggybacked",
 	"ib_ack_received",
-	"ib_rdma_mr_alloc",
-	"ib_rdma_mr_free",
-	"ib_rdma_mr_used",
-	"ib_rdma_mr_pool_flush",
-	"ib_rdma_mr_pool_wait",
-	"ib_rdma_mr_pool_depleted",
+	"ib_rdma_mr_8k_alloc",
+	"ib_rdma_mr_8k_free",
+	"ib_rdma_mr_8k_used",
+	"ib_rdma_mr_8k_pool_flush",
+	"ib_rdma_mr_8k_pool_wait",
+	"ib_rdma_mr_8k_pool_depleted",
+	"ib_rdma_mr_1m_alloc",
+	"ib_rdma_mr_1m_free",
+	"ib_rdma_mr_1m_used",
+	"ib_rdma_mr_1m_pool_flush",
+	"ib_rdma_mr_1m_pool_wait",
+	"ib_rdma_mr_1m_pool_depleted",
 	"ib_atomic_cswp",
 	"ib_atomic_fadd",
 };
-- 
1.9.1
