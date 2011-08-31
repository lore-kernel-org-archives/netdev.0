From: Huang Ying <ying.huang@intel.com>
Subject: [PATCH -mm RESEND] net, rds, Replace xlist in net/rds/xlist.h with llist
Date: Wed, 31 Aug 2011 09:21:30 +0800
Message-ID: <1314753690-31250-1-git-send-email-ying.huang@intel.com>
Cc: linux-kernel@vger.kernel.org, ying.huang@intel.com,
	rds-devel@oss.oracle.com, netdev@vger.kernel.org,
	Chris Mason <chris.mason@oracle.com>,
	Andy Grover <andy.grover@oracle.com>,
	"David S. Miller" <davem@davemloft.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The functionality of xlist and llist is almost same.  This patch
replace xlist with llist to avoid code duplication.

Known issues: don't know how to test this, need special hardware?

Signed-off-by: Huang Ying <ying.huang@intel.com>
Cc: Chris Mason <chris.mason@oracle.com>
Cc: Andy Grover <andy.grover@oracle.com>
Cc: "David S. Miller" <davem@davemloft.net>
---
 net/rds/Kconfig   |    1 
 net/rds/ib_rdma.c |  112 ++++++++++++++++++++++++------------------------------
 net/rds/xlist.h   |   80 --------------------------------------
 3 files changed, 52 insertions(+), 141 deletions(-)
 delete mode 100644 net/rds/xlist.h

--- a/net/rds/Kconfig
+++ b/net/rds/Kconfig
@@ -9,6 +9,7 @@ config RDS
 
 config RDS_RDMA
 	tristate "RDS over Infiniband and iWARP"
+	select LLIST
 	depends on RDS && INFINIBAND && INFINIBAND_ADDR_TRANS
 	---help---
 	  Allow RDS to use Infiniband and iWARP as a transport.
--- a/net/rds/ib_rdma.c
+++ b/net/rds/ib_rdma.c
@@ -33,10 +33,10 @@
 #include <linux/kernel.h>
 #include <linux/slab.h>
 #include <linux/rculist.h>
+#include <linux/llist.h>
 
 #include "rds.h"
 #include "ib.h"
-#include "xlist.h"
 
 static DEFINE_PER_CPU(unsigned long, clean_list_grace);
 #define CLEAN_LIST_BUSY_BIT 0
@@ -49,7 +49,7 @@ struct rds_ib_mr {
 	struct rds_ib_mr_pool	*pool;
 	struct ib_fmr		*fmr;
 
-	struct xlist_head	xlist;
+	struct llist_node	llnode;
 
 	/* unmap_list is for freeing */
 	struct list_head	unmap_list;
@@ -71,9 +71,9 @@ struct rds_ib_mr_pool {
 	atomic_t		item_count;		/* total # of MRs */
 	atomic_t		dirty_count;		/* # dirty of MRs */
 
-	struct xlist_head	drop_list;		/* MRs that have reached their max_maps limit */
-	struct xlist_head	free_list;		/* unused MRs */
-	struct xlist_head	clean_list;		/* global unused & unamapped MRs */
+	struct llist_head	drop_list;		/* MRs that have reached their max_maps limit */
+	struct llist_head	free_list;		/* unused MRs */
+	struct llist_head	clean_list;		/* global unused & unamapped MRs */
 	wait_queue_head_t	flush_wait;
 
 	atomic_t		free_pinned;		/* memory pinned by free MRs */
@@ -220,9 +220,9 @@ struct rds_ib_mr_pool *rds_ib_create_mr_
 	if (!pool)
 		return ERR_PTR(-ENOMEM);
 
-	INIT_XLIST_HEAD(&pool->free_list);
-	INIT_XLIST_HEAD(&pool->drop_list);
-	INIT_XLIST_HEAD(&pool->clean_list);
+	init_llist_head(&pool->free_list);
+	init_llist_head(&pool->drop_list);
+	init_llist_head(&pool->clean_list);
 	mutex_init(&pool->flush_lock);
 	init_waitqueue_head(&pool->flush_wait);
 	INIT_DELAYED_WORK(&pool->flush_worker, rds_ib_mr_pool_flush_worker);
@@ -260,26 +260,18 @@ void rds_ib_destroy_mr_pool(struct rds_i
 	kfree(pool);
 }
 
-static void refill_local(struct rds_ib_mr_pool *pool, struct xlist_head *xl,
-			 struct rds_ib_mr **ibmr_ret)
-{
-	struct xlist_head *ibmr_xl;
-	ibmr_xl = xlist_del_head_fast(xl);
-	*ibmr_ret = list_entry(ibmr_xl, struct rds_ib_mr, xlist);
-}
-
 static inline struct rds_ib_mr *rds_ib_reuse_fmr(struct rds_ib_mr_pool *pool)
 {
 	struct rds_ib_mr *ibmr = NULL;
-	struct xlist_head *ret;
+	struct llist_node *ret;
 	unsigned long *flag;
 
 	preempt_disable();
 	flag = &__get_cpu_var(clean_list_grace);
 	set_bit(CLEAN_LIST_BUSY_BIT, flag);
-	ret = xlist_del_head(&pool->clean_list);
+	ret = llist_del_first(&pool->clean_list);
 	if (ret)
-		ibmr = list_entry(ret, struct rds_ib_mr, xlist);
+		ibmr = llist_entry(ret, struct rds_ib_mr, llnode);
 
 	clear_bit(CLEAN_LIST_BUSY_BIT, flag);
 	preempt_enable();
@@ -529,46 +521,44 @@ static inline unsigned int rds_ib_flush_
 }
 
 /*
- * given an xlist of mrs, put them all into the list_head for more processing
+ * given an llist of mrs, put them all into the list_head for more processing
  */
-static void xlist_append_to_list(struct xlist_head *xlist, struct list_head *list)
+static void llist_append_to_list(struct llist_head *llist, struct list_head *list)
 {
 	struct rds_ib_mr *ibmr;
-	struct xlist_head splice;
-	struct xlist_head *cur;
-	struct xlist_head *next;
-
-	splice.next = NULL;
-	xlist_splice(xlist, &splice);
-	cur = splice.next;
-	while (cur) {
-		next = cur->next;
-		ibmr = list_entry(cur, struct rds_ib_mr, xlist);
+	struct llist_node *node;
+	struct llist_node *next;
+
+	node = llist_del_all(llist);
+	while (node) {
+		next = node->next;
+		ibmr = llist_entry(node, struct rds_ib_mr, llnode);
 		list_add_tail(&ibmr->unmap_list, list);
-		cur = next;
+		node = next;
 	}
 }
 
 /*
- * this takes a list head of mrs and turns it into an xlist of clusters.
- * each cluster has an xlist of MR_CLUSTER_SIZE mrs that are ready for
- * reuse.
+ * this takes a list head of mrs and turns it into linked llist nodes
+ * of clusters.  Each cluster has linked llist nodes of
+ * MR_CLUSTER_SIZE mrs that are ready for reuse.
  */
-static void list_append_to_xlist(struct rds_ib_mr_pool *pool,
-				struct list_head *list, struct xlist_head *xlist,
-				struct xlist_head **tail_ret)
+static void list_to_llist_nodes(struct rds_ib_mr_pool *pool,
+				struct list_head *list,
+				struct llist_node **nodes_head,
+				struct llist_node **nodes_tail)
 {
 	struct rds_ib_mr *ibmr;
-	struct xlist_head *cur_mr = xlist;
-	struct xlist_head *tail_mr = NULL;
+	struct llist_node *cur = NULL;
+	struct llist_node **next = nodes_head;
 
 	list_for_each_entry(ibmr, list, unmap_list) {
-		tail_mr = &ibmr->xlist;
-		tail_mr->next = NULL;
-		cur_mr->next = tail_mr;
-		cur_mr = tail_mr;
+		cur = &ibmr->llnode;
+		*next = cur;
+		next = &cur->next;
 	}
-	*tail_ret = tail_mr;
+	*next = NULL;
+	*nodes_tail = cur;
 }
 
 /*
@@ -581,8 +571,8 @@ static int rds_ib_flush_mr_pool(struct r
 			        int free_all, struct rds_ib_mr **ibmr_ret)
 {
 	struct rds_ib_mr *ibmr, *next;
-	struct xlist_head clean_xlist;
-	struct xlist_head *clean_tail;
+	struct llist_node *clean_nodes;
+	struct llist_node *clean_tail;
 	LIST_HEAD(unmap_list);
 	LIST_HEAD(fmr_list);
 	unsigned long unpinned = 0;
@@ -603,7 +593,7 @@ static int rds_ib_flush_mr_pool(struct r
 
 			prepare_to_wait(&pool->flush_wait, &wait,
 					TASK_UNINTERRUPTIBLE);
-			if (xlist_empty(&pool->clean_list))
+			if (llist_empty(&pool->clean_list))
 				schedule();
 
 			ibmr = rds_ib_reuse_fmr(pool);
@@ -628,10 +618,10 @@ static int rds_ib_flush_mr_pool(struct r
 	/* Get the list of all MRs to be dropped. Ordering matters -
 	 * we want to put drop_list ahead of free_list.
 	 */
-	xlist_append_to_list(&pool->drop_list, &unmap_list);
-	xlist_append_to_list(&pool->free_list, &unmap_list);
+	llist_append_to_list(&pool->drop_list, &unmap_list);
+	llist_append_to_list(&pool->free_list, &unmap_list);
 	if (free_all)
-		xlist_append_to_list(&pool->clean_list, &unmap_list);
+		llist_append_to_list(&pool->clean_list, &unmap_list);
 
 	free_goal = rds_ib_flush_goal(pool, free_all);
 
@@ -663,22 +653,22 @@ static int rds_ib_flush_mr_pool(struct r
 	if (!list_empty(&unmap_list)) {
 		/* we have to make sure that none of the things we're about
 		 * to put on the clean list would race with other cpus trying
-		 * to pull items off.  The xlist would explode if we managed to
+		 * to pull items off.  The llist would explode if we managed to
 		 * remove something from the clean list and then add it back again
-		 * while another CPU was spinning on that same item in xlist_del_head.
+		 * while another CPU was spinning on that same item in llist_del_first.
 		 *
-		 * This is pretty unlikely, but just in case  wait for an xlist grace period
+		 * This is pretty unlikely, but just in case  wait for an llist grace period
 		 * here before adding anything back into the clean list.
 		 */
 		wait_clean_list_grace();
 
-		list_append_to_xlist(pool, &unmap_list, &clean_xlist, &clean_tail);
+		list_to_llist_nodes(pool, &unmap_list, &clean_nodes, &clean_tail);
 		if (ibmr_ret)
-			refill_local(pool, &clean_xlist, ibmr_ret);
+			*ibmr_ret = llist_entry(clean_nodes, struct rds_ib_mr, llnode);
 
-		/* refill_local may have emptied our list */
-		if (!xlist_empty(&clean_xlist))
-			xlist_add(clean_xlist.next, clean_tail, &pool->clean_list);
+		/* more than one entry in llist nodes */
+		if (clean_nodes->next)
+			llist_add_batch(clean_nodes->next, clean_tail, &pool->clean_list);
 
 	}
 
@@ -711,9 +701,9 @@ void rds_ib_free_mr(void *trans_private,
 
 	/* Return it to the pool's free list */
 	if (ibmr->remap_count >= pool->fmr_attr.max_maps)
-		xlist_add(&ibmr->xlist, &ibmr->xlist, &pool->drop_list);
+		llist_add(&ibmr->llnode, &pool->drop_list);
 	else
-		xlist_add(&ibmr->xlist, &ibmr->xlist, &pool->free_list);
+		llist_add(&ibmr->llnode, &pool->free_list);
 
 	atomic_add(ibmr->sg_len, &pool->free_pinned);
 	atomic_inc(&pool->dirty_count);
--- a/net/rds/xlist.h
+++ /dev/null
@@ -1,80 +0,0 @@
-#ifndef _LINUX_XLIST_H
-#define _LINUX_XLIST_H
-
-#include <linux/stddef.h>
-#include <linux/poison.h>
-#include <linux/prefetch.h>
-#include <asm/system.h>
-
-struct xlist_head {
-	struct xlist_head *next;
-};
-
-static inline void INIT_XLIST_HEAD(struct xlist_head *list)
-{
-	list->next = NULL;
-}
-
-static inline int xlist_empty(struct xlist_head *head)
-{
-	return head->next == NULL;
-}
-
-static inline void xlist_add(struct xlist_head *new, struct xlist_head *tail,
-			     struct xlist_head *head)
-{
-	struct xlist_head *cur;
-	struct xlist_head *check;
-
-	while (1) {
-		cur = head->next;
-		tail->next = cur;
-		check = cmpxchg(&head->next, cur, new);
-		if (check == cur)
-			break;
-	}
-}
-
-static inline struct xlist_head *xlist_del_head(struct xlist_head *head)
-{
-	struct xlist_head *cur;
-	struct xlist_head *check;
-	struct xlist_head *next;
-
-	while (1) {
-		cur = head->next;
-		if (!cur)
-			goto out;
-
-		next = cur->next;
-		check = cmpxchg(&head->next, cur, next);
-		if (check == cur)
-			goto out;
-	}
-out:
-	return cur;
-}
-
-static inline struct xlist_head *xlist_del_head_fast(struct xlist_head *head)
-{
-	struct xlist_head *cur;
-
-	cur = head->next;
-	if (!cur)
-		return NULL;
-
-	head->next = cur->next;
-	return cur;
-}
-
-static inline void xlist_splice(struct xlist_head *list,
-				struct xlist_head *head)
-{
-	struct xlist_head *cur;
-
-	WARN_ON(head->next);
-	cur = xchg(&list->next, NULL);
-	head->next = cur;
-}
-
-#endif
