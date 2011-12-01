From: David Miller <davem@davemloft.net>
Subject: [PATCH 2/7] neigh: Get rid of neigh_table->kmem_cachep
Date: Wed, 30 Nov 2011 22:41:35 -0500 (EST)
Message-ID: <20111130.224135.756277331421611413.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58059 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753997Ab1LADlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 22:41:37 -0500
Received: from localhost (cpe-66-65-61-233.nyc.res.rr.com [66.65.61.233])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id pB13fZAe027309
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 19:41:36 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


We are going to alloc for device specific private areas for
neighbour entries, and in order to do that we have to move
away from the fixed allocation size enforced by using
neigh_table->kmem_cachep

As a nice side effect we can now use kfree_rcu().

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/neighbour.h |    1 -
 net/core/neighbour.c    |   18 ++----------------
 2 files changed, 2 insertions(+), 17 deletions(-)

diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 87c0e5c..e31f0a8 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -173,7 +173,6 @@ struct neigh_table {
 	atomic_t		entries;
 	rwlock_t		lock;
 	unsigned long		last_rand;
-	struct kmem_cache	*kmem_cachep;
 	struct neigh_statistics	__percpu *stats;
 	struct neigh_hash_table __rcu *nht;
 	struct pneigh_entry	**phash_buckets;
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 27d3fef..661ad12 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -288,7 +288,7 @@ static struct neighbour *neigh_alloc(struct neigh_table *tbl)
 			goto out_entries;
 	}
 
-	n = kmem_cache_zalloc(tbl->kmem_cachep, GFP_ATOMIC);
+	n = kzalloc(tbl->entry_size, GFP_ATOMIC);
 	if (!n)
 		goto out_entries;
 
@@ -678,12 +678,6 @@ static inline void neigh_parms_put(struct neigh_parms *parms)
 		neigh_parms_destroy(parms);
 }
 
-static void neigh_destroy_rcu(struct rcu_head *head)
-{
-	struct neighbour *neigh = container_of(head, struct neighbour, rcu);
-
-	kmem_cache_free(neigh->tbl->kmem_cachep, neigh);
-}
 /*
  *	neighbour must already be out of the table;
  *
@@ -711,7 +705,7 @@ void neigh_destroy(struct neighbour *neigh)
 	NEIGH_PRINTK2("neigh %p is destroyed.\n", neigh);
 
 	atomic_dec(&neigh->tbl->entries);
-	call_rcu(&neigh->rcu, neigh_destroy_rcu);
+	kfree_rcu(neigh, rcu);
 }
 EXPORT_SYMBOL(neigh_destroy);
 
@@ -1486,11 +1480,6 @@ void neigh_table_init_no_netlink(struct neigh_table *tbl)
 	tbl->parms.reachable_time =
 			  neigh_rand_reach_time(tbl->parms.base_reachable_time);
 
-	if (!tbl->kmem_cachep)
-		tbl->kmem_cachep =
-			kmem_cache_create(tbl->id, tbl->entry_size, 0,
-					  SLAB_HWCACHE_ALIGN|SLAB_PANIC,
-					  NULL);
 	tbl->stats = alloc_percpu(struct neigh_statistics);
 	if (!tbl->stats)
 		panic("cannot create neighbour cache statistics");
@@ -1575,9 +1564,6 @@ int neigh_table_clear(struct neigh_table *tbl)
 	free_percpu(tbl->stats);
 	tbl->stats = NULL;
 
-	kmem_cache_destroy(tbl->kmem_cachep);
-	tbl->kmem_cachep = NULL;
-
 	return 0;
 }
 EXPORT_SYMBOL(neigh_table_clear);
-- 
1.7.6.4
