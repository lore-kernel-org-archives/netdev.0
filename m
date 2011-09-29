From: Jonathan Lallinger <jonathan@ogc.us>
Subject: [PATCH] RDSRDMA: Fix cleanup of rds_iw_mr_pool
Date: Thu, 29 Sep 2011 12:58:41 -0500
Message-ID: <20110929175841.17682.27846.stgit@build.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net, venkat.x.venkatsubra@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:57512 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752717Ab1I2R6m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2011 13:58:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the rds_iw_mr_pool struct the free_pinned field keeps track of
memory pinned by free MRs. While this field is incremented properly
upon allocation, it is never decremented upon unmapping. This would
cause the rds_rdma module to crash the kernel upon unloading, by
triggering the BUG_ON in the rds_iw_destroy_mr_pool function.

This change keeps track of the MRs that become unpinned, so that
free_pinned can be decremented appropriately.

Signed-off-by: Jonathan Lallinger <jonathan@ogc.us>
Signed-off-by: Steve Wise <swise@ogc.us>
---

 net/rds/iw_rdma.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/rds/iw_rdma.c b/net/rds/iw_rdma.c
index 7c1c873..81d3167 100644
--- a/net/rds/iw_rdma.c
+++ b/net/rds/iw_rdma.c
@@ -84,7 +84,8 @@ static int rds_iw_map_fastreg(struct rds_iw_mr_pool *pool,
 static void rds_iw_free_fastreg(struct rds_iw_mr_pool *pool, struct rds_iw_mr *ibmr);
 static unsigned int rds_iw_unmap_fastreg_list(struct rds_iw_mr_pool *pool,
 			struct list_head *unmap_list,
-			struct list_head *kill_list);
+			struct list_head *kill_list,
+			int *unpinned);
 static void rds_iw_destroy_fastreg(struct rds_iw_mr_pool *pool, struct rds_iw_mr *ibmr);
 
 static int rds_iw_get_device(struct rds_sock *rs, struct rds_iw_device **rds_iwdev, struct rdma_cm_id **cm_id)
@@ -499,7 +500,7 @@ static int rds_iw_flush_mr_pool(struct rds_iw_mr_pool *pool, int free_all)
 	LIST_HEAD(unmap_list);
 	LIST_HEAD(kill_list);
 	unsigned long flags;
-	unsigned int nfreed = 0, ncleaned = 0, free_goal;
+	unsigned int nfreed = 0, ncleaned = 0, unpinned = 0, free_goal;
 	int ret = 0;
 
 	rds_iw_stats_inc(s_iw_rdma_mr_pool_flush);
@@ -524,7 +525,8 @@ static int rds_iw_flush_mr_pool(struct rds_iw_mr_pool *pool, int free_all)
 	 * will be destroyed by the unmap function.
 	 */
 	if (!list_empty(&unmap_list)) {
-		ncleaned = rds_iw_unmap_fastreg_list(pool, &unmap_list, &kill_list);
+		ncleaned = rds_iw_unmap_fastreg_list(pool, &unmap_list,
+						     &kill_list, &unpinned);
 		/* If we've been asked to destroy all MRs, move those
 		 * that were simply cleaned to the kill list */
 		if (free_all)
@@ -548,6 +550,7 @@ static int rds_iw_flush_mr_pool(struct rds_iw_mr_pool *pool, int free_all)
 		spin_unlock_irqrestore(&pool->list_lock, flags);
 	}
 
+	atomic_sub(unpinned, &pool->free_pinned);
 	atomic_sub(ncleaned, &pool->dirty_count);
 	atomic_sub(nfreed, &pool->item_count);
 
@@ -828,7 +831,8 @@ static void rds_iw_free_fastreg(struct rds_iw_mr_pool *pool,
 
 static unsigned int rds_iw_unmap_fastreg_list(struct rds_iw_mr_pool *pool,
 				struct list_head *unmap_list,
-				struct list_head *kill_list)
+				struct list_head *kill_list,
+				int *unpinned)
 {
 	struct rds_iw_mapping *mapping, *next;
 	unsigned int ncleaned = 0;
@@ -855,6 +859,7 @@ static unsigned int rds_iw_unmap_fastreg_list(struct rds_iw_mr_pool *pool,
 
 		spin_lock_irqsave(&pool->list_lock, flags);
 		list_for_each_entry_safe(mapping, next, unmap_list, m_list) {
+			*unpinned += mapping->m_sg.len;
 			list_move(&mapping->m_list, &laundered);
 			ncleaned++;
 		}
