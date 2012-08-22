From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v3 09/17] SUNRPC/cache: use new hashtable
	implementation
Date: Wed, 22 Aug 2012 04:27:04 +0200
Message-ID: <1345602432-27673-10-git-send-email-levinsasha928@gmail.com>
References: <1345602432-27673-1-git-send-email-levinsasha928@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: snitzer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, neilb-l3A5Bk7waGM@public.gmane.org, fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	Trond.Myklebust-HgOvQuBEEgTQT0dZR+AlfA@public.gmane.org, bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org,
	paul.gortmaker-CWA4WttNNZF54TAoqtyWWQ@public.gmane.org, dm-devel-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	agk-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, aarcange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org,
	ccaulfie-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org, dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org,
	ericvh-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, josh-iaAMLnmF4UmaiuxdJuQwMA@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org,
	lw-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org, mathieu.desnoyers-vg+e7yoeK/dWk0Htik3J/w@public.gmane.org,
	Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, axboe-tSWWG44O7X1aa/9Udqfwiw@public.gmane.org,
	linux-nfs-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org,
	linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, ejt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, teigland-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1345602432-27673-1-git-send-email-levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

Switch cache to use the new hashtable implementation. This reduces the amount of
generic unrelated code in the cache implementation.

Signed-off-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/sunrpc/cache.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 2afd2a8..8a8ef6d 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -28,6 +28,7 @@
 #include <linux/workqueue.h>
 #include <linux/mutex.h>
 #include <linux/pagemap.h>
+#include <linux/hashtable.h>
 #include <asm/ioctls.h>
 #include <linux/sunrpc/types.h>
 #include <linux/sunrpc/cache.h>
@@ -524,19 +525,18 @@ EXPORT_SYMBOL_GPL(cache_purge);
  * it to be revisited when cache info is available
  */
 
-#define	DFR_HASHSIZE	(PAGE_SIZE/sizeof(struct list_head))
-#define	DFR_HASH(item)	((((long)item)>>4 ^ (((long)item)>>13)) % DFR_HASHSIZE)
+#define	DFR_HASH_BITS	9
 
 #define	DFR_MAX	300	/* ??? */
 
 static DEFINE_SPINLOCK(cache_defer_lock);
 static LIST_HEAD(cache_defer_list);
-static struct hlist_head cache_defer_hash[DFR_HASHSIZE];
+static DEFINE_HASHTABLE(cache_defer_hash, DFR_HASH_BITS)
 static int cache_defer_cnt;
 
 static void __unhash_deferred_req(struct cache_deferred_req *dreq)
 {
-	hlist_del_init(&dreq->hash);
+	hash_del(&dreq->hash);
 	if (!list_empty(&dreq->recent)) {
 		list_del_init(&dreq->recent);
 		cache_defer_cnt--;
@@ -545,10 +545,7 @@ static void __unhash_deferred_req(struct cache_deferred_req *dreq)
 
 static void __hash_deferred_req(struct cache_deferred_req *dreq, struct cache_head *item)
 {
-	int hash = DFR_HASH(item);
-
-	INIT_LIST_HEAD(&dreq->recent);
-	hlist_add_head(&dreq->hash, &cache_defer_hash[hash]);
+	hash_add(cache_defer_hash, &dreq->hash, (unsigned long)item);
 }
 
 static void setup_deferral(struct cache_deferred_req *dreq,
@@ -600,7 +597,7 @@ static void cache_wait_req(struct cache_req *req, struct cache_head *item)
 		 * to clean up
 		 */
 		spin_lock(&cache_defer_lock);
-		if (!hlist_unhashed(&sleeper.handle.hash)) {
+		if (hash_hashed(&sleeper.handle.hash)) {
 			__unhash_deferred_req(&sleeper.handle);
 			spin_unlock(&cache_defer_lock);
 		} else {
@@ -671,12 +668,11 @@ static void cache_revisit_request(struct cache_head *item)
 	struct cache_deferred_req *dreq;
 	struct list_head pending;
 	struct hlist_node *lp, *tmp;
-	int hash = DFR_HASH(item);
 
 	INIT_LIST_HEAD(&pending);
 	spin_lock(&cache_defer_lock);
 
-	hlist_for_each_entry_safe(dreq, lp, tmp, &cache_defer_hash[hash], hash)
+	hash_for_each_possible_safe(cache_defer_hash, dreq, lp, tmp, hash, (unsigned long)item)
 		if (dreq->item == item) {
 			__unhash_deferred_req(dreq);
 			list_add(&dreq->recent, &pending);
@@ -1636,6 +1632,8 @@ static int create_cache_proc_entries(struct cache_detail *cd, struct net *net)
 void __init cache_initialize(void)
 {
 	INIT_DELAYED_WORK_DEFERRABLE(&cache_cleaner, do_cache_clean);
+
+	hash_init(cache_defer_hash);
 }
 
 int cache_register_net(struct cache_detail *cd, struct net *net)
-- 
1.7.8.6
