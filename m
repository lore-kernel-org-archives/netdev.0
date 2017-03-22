From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 03/15] nfp: remove cpp mutex cache
Date: Tue, 21 Mar 2017 17:59:09 -0700
Message-ID: <20170322005921.10965-4-jakub.kicinski@netronome.com>
References: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:34530 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933083AbdCVBGp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:06:45 -0400
Received: by mail-pg0-f42.google.com with SMTP id 21so68067991pgg.1
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 18:06:44 -0700 (PDT)
In-Reply-To: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CPP mutex cache was introduced to work around the fact that the
same host could successfully acquire a lock multiple times.  It
used to collapse multiple users to the same struct nfp_cpp_mutex
and track use count.  Unfortunately it's racy.  Since we now force
all nfp_mutex_lock() callers within the host to actually succeed
at acquiring the lock we no longer need the cache, let's remove it.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../ethernet/netronome/nfp/nfpcore/nfp_cppcore.c   | 43 +---------------------
 1 file changed, 2 insertions(+), 41 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
index e2267b421af0..6337342c5b62 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_cppcore.c
@@ -66,10 +66,8 @@ struct nfp_cpp_resource {
 };
 
 struct nfp_cpp_mutex {
-	struct list_head list;
 	struct nfp_cpp *cpp;
 	int target;
-	u16 usage;
 	u16 depth;
 	unsigned long long address;
 	u32 key;
@@ -86,7 +84,6 @@ struct nfp_cpp {
 
 	const struct nfp_cpp_operations *op;
 	struct list_head resource_list;	/* NFP CPP resource list */
-	struct list_head mutex_cache;	/* Mutex cache */
 	rwlock_t resource_lock;
 	wait_queue_head_t waitq;
 
@@ -187,24 +184,6 @@ void nfp_cpp_free(struct nfp_cpp *cpp)
 {
 	struct nfp_cpp_area_cache *cache, *ctmp;
 	struct nfp_cpp_resource *res, *rtmp;
-	struct nfp_cpp_mutex *mutex, *mtmp;
-
-	/* There should be no mutexes in the cache at this point. */
-	WARN_ON(!list_empty(&cpp->mutex_cache));
-	/* .. but if there are, unlock them and complain. */
-	list_for_each_entry_safe(mutex, mtmp, &cpp->mutex_cache, list) {
-		dev_err(cpp->dev.parent, "Dangling mutex: @%d::0x%llx, %d locks held by %d owners\n",
-			mutex->target, (unsigned long long)mutex->address,
-			mutex->depth, mutex->usage);
-
-		/* Forcing an unlock */
-		mutex->depth = 1;
-		nfp_cpp_mutex_unlock(mutex);
-
-		/* Forcing a free */
-		mutex->usage = 1;
-		nfp_cpp_mutex_free(mutex);
-	}
 
 	/* Remove all caches */
 	list_for_each_entry_safe(cache, ctmp, &cpp->area_cache_list, entry) {
@@ -1127,7 +1106,6 @@ nfp_cpp_from_operations(const struct nfp_cpp_operations *ops,
 	rwlock_init(&cpp->resource_lock);
 	init_waitqueue_head(&cpp->waitq);
 	lockdep_set_class(&cpp->resource_lock, &nfp_cpp_resource_lock_key);
-	INIT_LIST_HEAD(&cpp->mutex_cache);
 	INIT_LIST_HEAD(&cpp->resource_list);
 	INIT_LIST_HEAD(&cpp->area_cache_list);
 	mutex_init(&cpp->area_cache_mutex);
@@ -1536,14 +1514,6 @@ struct nfp_cpp_mutex *nfp_cpp_mutex_alloc(struct nfp_cpp *cpp, int target,
 	if (err)
 		return NULL;
 
-	/* Look for mutex on cache list */
-	list_for_each_entry(mutex, &cpp->mutex_cache, list) {
-		if (mutex->target == target && mutex->address == address) {
-			mutex->usage++;
-			return mutex;
-		}
-	}
-
 	err = nfp_cpp_readl(cpp, mur, address + 4, &tmp);
 	if (err < 0)
 		return NULL;
@@ -1560,10 +1530,6 @@ struct nfp_cpp_mutex *nfp_cpp_mutex_alloc(struct nfp_cpp *cpp, int target,
 	mutex->address = address;
 	mutex->key = key;
 	mutex->depth = 0;
-	mutex->usage = 1;
-
-	/* Add mutex to cache list */
-	list_add(&mutex->list, &cpp->mutex_cache);
 
 	return mutex;
 }
@@ -1574,11 +1540,6 @@ struct nfp_cpp_mutex *nfp_cpp_mutex_alloc(struct nfp_cpp *cpp, int target,
  */
 void nfp_cpp_mutex_free(struct nfp_cpp_mutex *mutex)
 {
-	if (--mutex->usage)
-		return;
-
-	/* Remove mutex from cache */
-	list_del(&mutex->list);
 	kfree(mutex);
 }
 
@@ -1611,8 +1572,8 @@ int nfp_cpp_mutex_lock(struct nfp_cpp_mutex *mutex)
 		if (time_is_before_eq_jiffies(warn_at)) {
 			warn_at = jiffies + 60 * HZ;
 			dev_warn(mutex->cpp->dev.parent,
-				 "Warning: waiting for NFP mutex [usage:%hd depth:%hd target:%d addr:%llx key:%08x]\n",
-				 mutex->usage, mutex->depth,
+				 "Warning: waiting for NFP mutex [depth:%hd target:%d addr:%llx key:%08x]\n",
+				 mutex->depth,
 				 mutex->target, mutex->address, mutex->key);
 		}
 	}
-- 
2.11.0
