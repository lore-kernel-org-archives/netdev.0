From: Timo Teras <timo.teras@iki.fi>
Subject: [PATCH 4/7] flow: delayed deletion of flow cache entries
Date: Mon, 29 Mar 2010 17:12:41 +0300
Message-ID: <1269871964-5412-5-git-send-email-timo.teras@iki.fi>
References: <1269871964-5412-1-git-send-email-timo.teras@iki.fi>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Timo Teras <timo.teras@iki.fi>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:13175 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752770Ab0C2ONC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Mar 2010 10:13:02 -0400
Received: by ey-out-2122.google.com with SMTP id d26so1125925eyd.19
        for <netdev@vger.kernel.org>; Mon, 29 Mar 2010 07:13:01 -0700 (PDT)
In-Reply-To: <1269871964-5412-1-git-send-email-timo.teras@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Speed up lookups by freeing flow cache entries later. This is also in
preparation to have virtual entry destructor that might do more
work.

As gc_list is more effective with double linked list, the flow cache
is converted to use common hlist and list macroes where appropriate.

Signed-off-by: Timo Teras <timo.teras@iki.fi>
---
 net/core/flow.c |  112 ++++++++++++++++++++++++++++++++++++++----------------
 1 files changed, 79 insertions(+), 33 deletions(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index 104078d..760f93d 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -26,7 +26,10 @@
 #include <linux/security.h>
 
 struct flow_cache_entry {
-	struct flow_cache_entry	*next;
+	union {
+		struct hlist_node	hlist;
+		struct list_head	gc_list;
+	} u;
 	u16			family;
 	u8			dir;
 	u32			genid;
@@ -36,7 +39,7 @@ struct flow_cache_entry {
 };
 
 struct flow_cache_percpu {
-	struct flow_cache_entry **	hash_table;
+	struct hlist_head *		hash_table;
 	int				hash_count;
 	u32				hash_rnd;
 	int				hash_rnd_recalc;
@@ -63,6 +66,9 @@ atomic_t flow_cache_genid = ATOMIC_INIT(0);
 static struct flow_cache flow_cache_global;
 static struct kmem_cache *flow_cachep;
 
+static DEFINE_SPINLOCK(flow_cache_gc_lock);
+static LIST_HEAD(flow_cache_gc_list);
+
 #define flow_cache_hash_size(cache)	(1 << (cache)->hash_shift)
 #define FLOW_HASH_RND_PERIOD		(10 * 60 * HZ)
 
@@ -78,36 +84,62 @@ static void flow_cache_new_hashrnd(unsigned long arg)
 	add_timer(&fc->rnd_timer);
 }
 
-static void flow_entry_kill(struct flow_cache *fc,
-			    struct flow_cache_percpu *fcp,
-			    struct flow_cache_entry *fle)
+static void flow_entry_kill(struct flow_cache_entry *fle)
 {
 	if (fle->object)
 		atomic_dec(fle->object_ref);
 	kmem_cache_free(flow_cachep, fle);
-	fcp->hash_count--;
 }
 
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
 static void __flow_cache_shrink(struct flow_cache *fc,
 				struct flow_cache_percpu *fcp,
 				int shrink_to)
 {
-	struct flow_cache_entry *fle, **flp;
-	int i;
+	struct flow_cache_entry *fce;
+	struct hlist_node *entry, *tmp;
+	struct list_head gc_list;
+	int i, deleted = 0;
 
+	INIT_LIST_HEAD(&gc_list);
 	for (i = 0; i < flow_cache_hash_size(fc); i++) {
-		int k = 0;
-
-		flp = &fcp->hash_table[i];
-		while ((fle = *flp) != NULL && k < shrink_to) {
-			k++;
-			flp = &fle->next;
-		}
-		while ((fle = *flp) != NULL) {
-			*flp = fle->next;
-			flow_entry_kill(fc, fcp, fle);
+		int saved = 0;
+
+		hlist_for_each_entry_safe(fce, entry, tmp,
+					  &fcp->hash_table[i], u.hlist) {
+			if (saved < shrink_to) {
+				saved++;
+			} else {
+				deleted++;
+				hlist_del(&fce->u.hlist);
+				list_add_tail(&fce->u.gc_list, &gc_list);
+			}
 		}
 	}
+
+	if (deleted) {
+		fcp->hash_count -= deleted;
+
+		spin_lock_bh(&flow_cache_gc_lock);
+		list_splice_tail(&gc_list, &flow_cache_gc_list);
+		spin_unlock_bh(&flow_cache_gc_lock);
+
+		schedule_work(&flow_cache_gc_work);
+	}
 }
 
 static void flow_cache_shrink(struct flow_cache *fc,
@@ -171,7 +203,8 @@ void *flow_cache_lookup(struct net *net, struct flowi *key, u16 family, u8 dir,
 {
 	struct flow_cache *fc = &flow_cache_global;
 	struct flow_cache_percpu *fcp;
-	struct flow_cache_entry *fle, **head;
+	struct flow_cache_entry *fle;
+	struct hlist_node *entry;
 	unsigned int hash;
 
 	local_bh_disable();
@@ -187,8 +220,7 @@ void *flow_cache_lookup(struct net *net, struct flowi *key, u16 family, u8 dir,
 		flow_new_hash_rnd(fc, fcp);
 	hash = flow_hash_code(fc, fcp, key);
 
-	head = &fcp->hash_table[hash];
-	for (fle = *head; fle; fle = fle->next) {
+	hlist_for_each_entry(fle, entry, &fcp->hash_table[hash], u.hlist) {
 		if (fle->family == family &&
 		    fle->dir == dir &&
 		    flow_key_compare(key, &fle->key) == 0) {
@@ -211,12 +243,12 @@ void *flow_cache_lookup(struct net *net, struct flowi *key, u16 family, u8 dir,
 
 		fle = kmem_cache_alloc(flow_cachep, GFP_ATOMIC);
 		if (fle) {
-			fle->next = *head;
-			*head = fle;
 			fle->family = family;
 			fle->dir = dir;
 			memcpy(&fle->key, key, sizeof(*key));
 			fle->object = NULL;
+
+			hlist_add_head(&fle->u.hlist, &fcp->hash_table[hash]);
 			fcp->hash_count++;
 		}
 	}
@@ -253,24 +285,38 @@ static void flow_cache_flush_tasklet(unsigned long data)
 	struct flow_flush_info *info = (void *)data;
 	struct flow_cache *fc = info->cache;
 	struct flow_cache_percpu *fcp;
-	int i;
+	struct flow_cache_entry *fle;
+	struct hlist_node *entry, *tmp;
+	struct list_head gc_list;
+	int i, deleted = 0;
+	unsigned genid;
 
+	INIT_LIST_HEAD(&gc_list);
 	fcp = per_cpu_ptr(fc->percpu, smp_processor_id());
 	for (i = 0; i < flow_cache_hash_size(fc); i++) {
-		struct flow_cache_entry *fle;
-
-		fle = fcp->hash_table[i];
-		for (; fle; fle = fle->next) {
-			unsigned genid = atomic_read(&flow_cache_genid);
+		hlist_for_each_entry_safe(fle, entry, tmp,
+					  &fcp->hash_table[i], u.hlist) {
+			genid = atomic_read(&flow_cache_genid);
 
 			if (!fle->object || fle->genid == genid)
 				continue;
 
-			fle->object = NULL;
-			atomic_dec(fle->object_ref);
+			deleted++;
+			hlist_del(&fle->u.hlist);
+			list_add_tail(&fle->u.gc_list, &gc_list);
 		}
 	}
 
+	if (deleted) {
+		fcp->hash_count -= deleted;
+
+		spin_lock_bh(&flow_cache_gc_lock);
+		list_splice_tail(&gc_list, &flow_cache_gc_list);
+		spin_unlock_bh(&flow_cache_gc_lock);
+
+		schedule_work(&flow_cache_gc_work);
+	}
+
 	if (atomic_dec_and_test(&info->cpuleft))
 		complete(&info->completion);
 }
@@ -312,7 +358,7 @@ void flow_cache_flush(void)
 static void __cpuinit flow_cache_cpu_prepare(struct flow_cache *fc,
 					     struct flow_cache_percpu *fcp)
 {
-	fcp->hash_table = (struct flow_cache_entry **)
+	fcp->hash_table = (struct hlist_head *)
 		__get_free_pages(GFP_KERNEL|__GFP_ZERO, fc->order);
 	fcp->hash_rnd_recalc = 1;
 	fcp->hash_count = 0;
@@ -359,7 +405,7 @@ static int flow_cache_init(struct flow_cache *fc)
 
 	for (order = 0;
 	     (PAGE_SIZE << order) <
-		     (sizeof(struct flow_cache_entry *)*flow_cache_hash_size(fc));
+		     (sizeof(struct hlist_head)*flow_cache_hash_size(fc));
 	     order++)
 		/* NOTHING */;
 	fc->order = order;
-- 
1.6.3.3

