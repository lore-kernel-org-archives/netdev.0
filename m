From: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v3 08/17] block,
	elevator: use new hashtable implementation
Date: Wed, 22 Aug 2012 04:27:03 +0200
Message-ID: <1345602432-27673-9-git-send-email-levinsasha928@gmail.com>
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

Switch elevator to use the new hashtable implementation. This reduces the amount of
generic unrelated code in the elevator.

This also removes the dymanic allocation of the hash table. The size of the table is
constant so there's no point in paying the price of an extra dereference when accessing
it.

Signed-off-by: Sasha Levin <levinsasha928-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 block/blk.h              |    2 +-
 block/elevator.c         |   23 ++++-------------------
 include/linux/elevator.h |    5 ++++-
 3 files changed, 9 insertions(+), 21 deletions(-)

diff --git a/block/blk.h b/block/blk.h
index 2a0ea32..5650d48 100644
--- a/block/blk.h
+++ b/block/blk.h
@@ -61,7 +61,7 @@ static inline void blk_clear_rq_complete(struct request *rq)
 /*
  * Internal elevator interface
  */
-#define ELV_ON_HASH(rq)		(!hlist_unhashed(&(rq)->hash))
+#define ELV_ON_HASH(rq) hash_hashed(&(rq)->hash)
 
 void blk_insert_flush(struct request *rq);
 void blk_abort_flushes(struct request_queue *q);
diff --git a/block/elevator.c b/block/elevator.c
index 6a55d41..f462a83 100644
--- a/block/elevator.c
+++ b/block/elevator.c
@@ -46,11 +46,6 @@ static LIST_HEAD(elv_list);
 /*
  * Merge hash stuff.
  */
-static const int elv_hash_shift = 6;
-#define ELV_HASH_BLOCK(sec)	((sec) >> 3)
-#define ELV_HASH_FN(sec)	\
-		(hash_long(ELV_HASH_BLOCK((sec)), elv_hash_shift))
-#define ELV_HASH_ENTRIES	(1 << elv_hash_shift)
 #define rq_hash_key(rq)		(blk_rq_pos(rq) + blk_rq_sectors(rq))
 
 /*
@@ -142,7 +137,6 @@ static struct elevator_queue *elevator_alloc(struct request_queue *q,
 				  struct elevator_type *e)
 {
 	struct elevator_queue *eq;
-	int i;
 
 	eq = kmalloc_node(sizeof(*eq), GFP_KERNEL | __GFP_ZERO, q->node);
 	if (unlikely(!eq))
@@ -151,14 +145,7 @@ static struct elevator_queue *elevator_alloc(struct request_queue *q,
 	eq->type = e;
 	kobject_init(&eq->kobj, &elv_ktype);
 	mutex_init(&eq->sysfs_lock);
-
-	eq->hash = kmalloc_node(sizeof(struct hlist_head) * ELV_HASH_ENTRIES,
-					GFP_KERNEL, q->node);
-	if (!eq->hash)
-		goto err;
-
-	for (i = 0; i < ELV_HASH_ENTRIES; i++)
-		INIT_HLIST_HEAD(&eq->hash[i]);
+	hash_init(eq->hash);
 
 	return eq;
 err:
@@ -173,7 +160,6 @@ static void elevator_release(struct kobject *kobj)
 
 	e = container_of(kobj, struct elevator_queue, kobj);
 	elevator_put(e->type);
-	kfree(e->hash);
 	kfree(e);
 }
 
@@ -240,7 +226,7 @@ EXPORT_SYMBOL(elevator_exit);
 
 static inline void __elv_rqhash_del(struct request *rq)
 {
-	hlist_del_init(&rq->hash);
+	hash_del(&rq->hash);
 }
 
 static void elv_rqhash_del(struct request_queue *q, struct request *rq)
@@ -254,7 +240,7 @@ static void elv_rqhash_add(struct request_queue *q, struct request *rq)
 	struct elevator_queue *e = q->elevator;
 
 	BUG_ON(ELV_ON_HASH(rq));
-	hlist_add_head(&rq->hash, &e->hash[ELV_HASH_FN(rq_hash_key(rq))]);
+	hash_add(e->hash, &rq->hash, rq_hash_key(rq));
 }
 
 static void elv_rqhash_reposition(struct request_queue *q, struct request *rq)
@@ -266,11 +252,10 @@ static void elv_rqhash_reposition(struct request_queue *q, struct request *rq)
 static struct request *elv_rqhash_find(struct request_queue *q, sector_t offset)
 {
 	struct elevator_queue *e = q->elevator;
-	struct hlist_head *hash_list = &e->hash[ELV_HASH_FN(offset)];
 	struct hlist_node *entry, *next;
 	struct request *rq;
 
-	hlist_for_each_entry_safe(rq, entry, next, hash_list, hash) {
+	hash_for_each_possible_safe(e->hash, rq, entry, next, hash, offset) {
 		BUG_ON(!ELV_ON_HASH(rq));
 
 		if (unlikely(!rq_mergeable(rq))) {
diff --git a/include/linux/elevator.h b/include/linux/elevator.h
index c03af76..20b539c 100644
--- a/include/linux/elevator.h
+++ b/include/linux/elevator.h
@@ -2,6 +2,7 @@
 #define _LINUX_ELEVATOR_H
 
 #include <linux/percpu.h>
+#include <linux/hashtable.h>
 
 #ifdef CONFIG_BLOCK
 
@@ -96,6 +97,8 @@ struct elevator_type
 	struct list_head list;
 };
 
+#define ELV_HASH_BITS 6
+
 /*
  * each queue has an elevator_queue associated with it
  */
@@ -105,7 +108,7 @@ struct elevator_queue
 	void *elevator_data;
 	struct kobject kobj;
 	struct mutex sysfs_lock;
-	struct hlist_head *hash;
+	DEFINE_HASHTABLE(hash, ELV_HASH_BITS);
 	unsigned int registered:1;
 };
 
-- 
1.7.8.6
