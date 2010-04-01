From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH 4/4] flow: delayed deletion of flow cache entries
Date: Thu,  1 Apr 2010 15:52:20 +0300
Message-ID: <1270126340-30181-5-git-send-email-timo.teras@iki.fi>
References: <1270126340-30181-1-git-send-email-timo.teras@iki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:46390 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756112Ab0DAMwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Apr 2010 08:52:31 -0400
Received: by ewy20 with SMTP id 20so329264ewy.1
        for <netdev@vger.kernel.org>; Thu, 01 Apr 2010 05:52:30 -0700 (PDT)
In-Reply-To: <1270126340-30181-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Speed up lookups by freeing flow cache entries later. After
virtualizing flow cache entry operations, the flow cache may now
end up calling policy or bundle destructor which can be slowish.

As gc_list is more effective with double linked list, the flow cache
is converted to use common hlist and list macroes where appropriate.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
 net/core/flow.c |  101 ++++++++++++++++++++++++++++++++++++++-----------------
 1 files changed, 70 insertions(+), 31 deletions(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index f938137..d3a8f80 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -26,7 +26,10 @@
 #include <linux/security.h>
 
 struct flow_cache_entry {
-	struct flow_cache_entry *	next;
+	union {
+		struct hlist_node	hlist;
+		struct list_head	gc_list;
+	} u;
 	u16				family;
 	u8				dir;
 	u32				genid;
@@ -35,7 +38,7 @@ struct flow_cache_entry {
 };
 
 struct flow_cache_percpu {
-	struct flow_cache_entry **	hash_table;
+	struct hlist_head *		hash_table;
 	int				hash_count;
 	u32				hash_rnd;
 	int				hash_rnd_recalc;
@@ -62,6 +65,9 @@ atomic_t flow_cache_genid = ATOMIC_INIT(0);
 static struct flow_cache flow_cache_global;
 static struct kmem_cache *flow_cachep;
 
+static DEFINE_SPINLOCK(flow_cache_gc_lock);
+static LIST_HEAD(flow_cache_gc_list);
+
 #define flow_cache_hash_size(cache)	(1 << (cache)->hash_shift)
 #define FLOW_HASH_RND_PERIOD		(10 * 60 * HZ)
 
@@ -86,38 +92,66 @@ static int flow_entry_valid(struct flow_cache_entry *fle)
 	return 1;
 }
 
-static void flow_entry_kill(struct flow_cache *fc,
-			    struct flow_cache_percpu *fcp,
-			    struct flow_cache_entry *fle)
+static void flow_entry_kill(struct flow_cache_entry *fle)
 {
 	if (fle->ops)
 		(*fle->ops)->delete(fle->ops);
 	kmem_cache_free(flow_cachep, fle);
-	fcp->hash_count--;
+}
+
+static void flow_cache_gc_task(struct work_struct *work)
+{
+	struct list_head gc_list;
+	struct flow_cache_entry *fce, *n;
+
+	INIT_LIST_HEAD(&gc_list);
+	spin_lock_bh(&flow_cache_gc_lock);
+	list_splice_tail_init(&flow_cache_gc_list, &gc_list);
+	spin_unlock_bh(&flow_cache_gc_lock);
+
+	list_for_each_entry_safe(fce, n, &gc_list, u.gc_list)
+		flow_entry_kill(fce);
+}
+static DECLARE_WORK(flow_cache_gc_work, flow_cache_gc_task);
+
+static void flow_cache_queue_garbage(struct flow_cache_percpu *fcp,
+				     int deleted, struct list_head *gc_list)
+{
+	if (deleted) {
+		fcp->hash_count -= deleted;
+		spin_lock_bh(&flow_cache_gc_lock);
+		list_splice_tail(gc_list, &flow_cache_gc_list);
+		spin_unlock_bh(&flow_cache_gc_lock);
+		schedule_work(&flow_cache_gc_work);
+	}
 }
 
 static void __flow_cache_shrink(struct flow_cache *fc,
 				struct flow_cache_percpu *fcp,
 				int shrink_to)
 {
-	struct flow_cache_entry *fle, **flp;
-	int i;
+	struct flow_cache_entry *fle;
+	struct hlist_node *entry, *tmp;
+	LIST_HEAD(gc_list);
+	int i, deleted = 0;
 
 	for (i = 0; i < flow_cache_hash_size(fc); i++) {
 		int saved = 0;
 
-		flp = &fcp->hash_table[i];
-		while ((fle = *flp) != NULL) {
+		hlist_for_each_entry_safe(fle, entry, tmp,
+					  &fcp->hash_table[i], u.hlist) {
 			if (saved < shrink_to &&
 			    flow_entry_valid(fle)) {
 				saved++;
-				flp = &fle->next;
 			} else {
-				*flp = fle->next;
-				flow_entry_kill(fc, fcp, fle);
+				deleted++;
+				hlist_del(&fle->u.hlist);
+				list_add_tail(&fle->u.gc_list, &gc_list);
 			}
 		}
 	}
+
+	flow_cache_queue_garbage(fcp, deleted, &gc_list);
 }
 
 static void flow_cache_shrink(struct flow_cache *fc,
@@ -182,8 +216,9 @@ struct flow_cache_entry_ops **flow_cache_lookup(
 {
 	struct flow_cache *fc = &flow_cache_global;
 	struct flow_cache_percpu *fcp;
-	struct flow_cache_entry *fle, **head;
 	struct flow_cache_entry_ops **ops;
+	struct flow_cache_entry *fle, *tfle;
+	struct hlist_node *entry;
 	unsigned int hash;
 
 	local_bh_disable();
@@ -200,12 +235,13 @@ struct flow_cache_entry_ops **flow_cache_lookup(
 		flow_new_hash_rnd(fc, fcp);
 
 	hash = flow_hash_code(fc, fcp, key);
-	head = &fcp->hash_table[hash];
-	for (fle = *head; fle; fle = fle->next) {
-		if (fle->family == family &&
-		    fle->dir == dir &&
-		    flow_key_compare(key, &fle->key) == 0)
+	hlist_for_each_entry(tfle, entry, &fcp->hash_table[hash], u.hlist) {
+		if (tfle->family == family &&
+		    tfle->dir == dir &&
+		    flow_key_compare(key, &tfle->key) == 0) {
+			fle = tfle;
 			break;
+		}
 	}
 
 	if (!fle) {
@@ -214,13 +250,13 @@ struct flow_cache_entry_ops **flow_cache_lookup(
 
 		fle = kmem_cache_alloc(flow_cachep, GFP_ATOMIC);
 		if (fle) {
-			fle->next = *head;
-			*head = fle;
 			fle->family = family;
 			fle->dir = dir;
 			fle->ops = NULL;
 			memcpy(&fle->key, key, sizeof(*key));
 			fle->ops = NULL;
+
+			hlist_add_head(&fle->u.hlist, &fcp->hash_table[hash]);
 			fcp->hash_count++;
 		}
 	} else if (fle->genid == atomic_read(&flow_cache_genid)) {
@@ -256,23 +292,26 @@ static void flow_cache_flush_tasklet(unsigned long data)
 	struct flow_flush_info *info = (void *)data;
 	struct flow_cache *fc = info->cache;
 	struct flow_cache_percpu *fcp;
-	int i;
+	struct flow_cache_entry *fle;
+	struct hlist_node *entry, *tmp;
+	LIST_HEAD(gc_list);
+	int i, deleted = 0;
 
 	fcp = per_cpu_ptr(fc->percpu, smp_processor_id());
 	for (i = 0; i < flow_cache_hash_size(fc); i++) {
-		struct flow_cache_entry *fle;
-
-		fle = fcp->hash_table[i];
-		for (; fle; fle = fle->next) {
+		hlist_for_each_entry_safe(fle, entry, tmp,
+					  &fcp->hash_table[i], u.hlist) {
 			if (flow_entry_valid(fle))
 				continue;
 
-			if (fle->ops)
-				(*fle->ops)->delete(fle->ops);
-			fle->ops = NULL;
+			deleted++;
+			hlist_del(&fle->u.hlist);
+			list_add_tail(&fle->u.gc_list, &gc_list);
 		}
 	}
 
+	flow_cache_queue_garbage(fcp, deleted, &gc_list);
+
 	if (atomic_dec_and_test(&info->cpuleft))
 		complete(&info->completion);
 }
@@ -314,7 +353,7 @@ void flow_cache_flush(void)
 static void __init flow_cache_cpu_prepare(struct flow_cache *fc,
 					  struct flow_cache_percpu *fcp)
 {
-	fcp->hash_table = (struct flow_cache_entry **)
+	fcp->hash_table = (struct hlist_head *)
 		__get_free_pages(GFP_KERNEL|__GFP_ZERO, fc->order);
 	if (!fcp->hash_table)
 		panic("NET: failed to allocate flow cache order %lu\n", fc->order);
@@ -348,7 +387,7 @@ static int flow_cache_init(struct flow_cache *fc)
 
 	for (order = 0;
 	     (PAGE_SIZE << order) <
-		     (sizeof(struct flow_cache_entry *)*flow_cache_hash_size(fc));
+		     (sizeof(struct hlist_head)*flow_cache_hash_size(fc));
 	     order++)
 		/* NOTHING */;
 	fc->order = order;
-- 
1.6.3.3

