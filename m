From: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Subject: [PATCH 3/6] RDS: fix fmr pool dirty_count
Date: Tue, 25 Aug 2015 12:02:00 -0700
Message-ID: <1440529323-4171-4-git-send-email-santosh.shilimkar@oracle.com>
References: <1440529323-4171-1-git-send-email-santosh.shilimkar@oracle.com>
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	ssantosh@kernel.org, Wengang Wang <wen.gang.wang@oracle.com>,
	Santosh Shilimkar <santosh.shilimkar@oracle.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440529323-4171-1-git-send-email-santosh.shilimkar@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Wengang Wang <wen.gang.wang@oracle.com>

In rds_ib_flush_mr_pool(), dirty_count accounts the clean ones
which is wrong. This can lead to a negative dirty count value.

Lets fix it.

Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
Signed-off-by: Santosh Shilimkar <ssantosh@kernel.org>
Signed-off-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
---
 net/rds/ib_rdma.c | 15 +++++++++------
 1 file changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/rds/ib_rdma.c b/net/rds/ib_rdma.c
index 7b7aac8..a275b7d 100644
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -528,11 +528,13 @@ static inline unsigned int rds_ib_flush_goal(struct rds_ib_mr_pool *pool, int fr
 /*
  * given an llist of mrs, put them all into the list_head for more processing
  */
-static void llist_append_to_list(struct llist_head *llist, struct list_head *list)
+static unsigned int llist_append_to_list(struct llist_head *llist,
+					 struct list_head *list)
 {
 	struct rds_ib_mr *ibmr;
 	struct llist_node *node;
 	struct llist_node *next;
+	unsigned int count = 0;
 
 	node = llist_del_all(llist);
 	while (node) {
@@ -540,7 +542,9 @@ static void llist_append_to_list(struct llist_head *llist, struct list_head *lis
 		ibmr = llist_entry(node, struct rds_ib_mr, llnode);
 		list_add_tail(&ibmr->unmap_list, list);
 		node = next;
+		count++;
 	}
+	return count;
 }
 
 /*
@@ -581,7 +585,7 @@ static int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
 	LIST_HEAD(unmap_list);
 	LIST_HEAD(fmr_list);
 	unsigned long unpinned = 0;
-	unsigned int nfreed = 0, ncleaned = 0, free_goal;
+	unsigned int nfreed = 0, dirty_to_clean = 0, free_goal;
 	int ret = 0;
 
 	rds_ib_stats_inc(s_ib_rdma_mr_pool_flush);
@@ -623,8 +627,8 @@ static int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
 	/* Get the list of all MRs to be dropped. Ordering matters -
 	 * we want to put drop_list ahead of free_list.
 	 */
-	llist_append_to_list(&pool->drop_list, &unmap_list);
-	llist_append_to_list(&pool->free_list, &unmap_list);
+	dirty_to_clean = llist_append_to_list(&pool->drop_list, &unmap_list);
+	dirty_to_clean += llist_append_to_list(&pool->free_list, &unmap_list);
 	if (free_all)
 		llist_append_to_list(&pool->clean_list, &unmap_list);
 
@@ -652,7 +656,6 @@ static int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
 			kfree(ibmr);
 			nfreed++;
 		}
-		ncleaned++;
 	}
 
 	if (!list_empty(&unmap_list)) {
@@ -678,7 +681,7 @@ static int rds_ib_flush_mr_pool(struct rds_ib_mr_pool *pool,
 	}
 
 	atomic_sub(unpinned, &pool->free_pinned);
-	atomic_sub(ncleaned, &pool->dirty_count);
+	atomic_sub(dirty_to_clean, &pool->dirty_count);
 	atomic_sub(nfreed, &pool->item_count);
 
 out:
-- 
1.9.1
