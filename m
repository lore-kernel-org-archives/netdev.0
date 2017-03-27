From: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 5/5] rds: ib: add the static type to the functions
Date: Mon, 27 Mar 2017 03:06:30 -0400
Message-ID: <1490598390-13812-6-git-send-email-yanjun.zhu@oracle.com>
References: <1490598390-13812-1-git-send-email-yanjun.zhu@oracle.com>
To: yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, santosh.shilimkar-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org, junxiao.bi-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, joe.jin-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1490598390-13812-1-git-send-email-yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The functions rds_ib_flush_mr_pool and rds_ib_reuse_mr
are called in the local file. As such, the static type
is added to limit them in the local file.

And the function rds_ib_flush_mr_pool always returns zero.
As such, change the return type to void.

Signed-off-by: Zhu Yanjun <yanjun.zhu-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
 net/rds/ib_mr.h   |  2 --
 net/rds/ib_rdma.c | 12 +++++-------
 2 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/rds/ib_mr.h b/net/rds/ib_mr.h
index 0ea4ab0..a3a9676 100644
--- a/net/rds/ib_mr.h
+++ b/net/rds/ib_mr.h
@@ -125,8 +125,6 @@ void rds_ib_mr_exit(void);
 void __rds_ib_teardown_mr(struct rds_ib_mr *);
 void rds_ib_teardown_mr(struct rds_ib_mr *);
 struct rds_ib_mr *rds_ib_alloc_fmr(struct rds_ib_device *, int);
-struct rds_ib_mr *rds_ib_reuse_mr(struct rds_ib_mr_pool *);
-int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *, int, struct rds_ib_mr **);
 struct rds_ib_mr *rds_ib_reg_fmr(struct rds_ib_device *, struct scatterlist *,
 				 unsigned long, u32 *);
 struct rds_ib_mr *rds_ib_try_reuse_ibmr(struct rds_ib_mr_pool *);
diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 977f698..1bd3aba 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -179,7 +179,7 @@ void rds_ib_get_mr_info(struct rds_ib_device *rds_ibdev, struct rds_info_rdma_co
 	iinfo->rdma_mr_size = pool_1m->fmr_attr.max_pages;
 }
 
-struct rds_ib_mr *rds_ib_reuse_mr(struct rds_ib_mr_pool *pool)
+static struct rds_ib_mr *rds_ib_reuse_mr(struct rds_ib_mr_pool *pool)
 {
 	struct rds_ib_mr *ibmr = NULL;
 	struct llist_node *ret;
@@ -336,8 +336,8 @@ static void list_to_llist_nodes(struct rds_ib_mr_pool *pool,
  * If the number of MRs allocated exceeds the limit, we also try
  * to free as many MRs as needed to get back to this limit.
  */
-int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
-			 int free_all, struct rds_ib_mr **ibmr_ret)
+static void rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
+				 int free_all, struct rds_ib_mr **ibmr_ret)
 {
 	struct rds_ib_mr *ibmr;
 	struct llist_node *clean_nodes;
@@ -358,7 +358,7 @@ int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
 			if (ibmr) {
 				*ibmr_ret = ibmr;
 				finish_wait(&pool->flush_wait, &wait);
-				goto out_nolock;
+				return;
 			}
 
 			prepare_to_wait(&pool->flush_wait, &wait,
@@ -370,7 +370,7 @@ int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
 			if (ibmr) {
 				*ibmr_ret = ibmr;
 				finish_wait(&pool->flush_wait, &wait);
-				goto out_nolock;
+				return;
 			}
 		}
 		finish_wait(&pool->flush_wait, &wait);
@@ -433,8 +433,6 @@ int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
 	mutex_unlock(&pool->flush_lock);
 	if (waitqueue_active(&pool->flush_wait))
 		wake_up(&pool->flush_wait);
-out_nolock:
-	return 0;
 }
 
 struct rds_ib_mr *rds_ib_try_reuse_ibmr(struct rds_ib_mr_pool *pool)
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
