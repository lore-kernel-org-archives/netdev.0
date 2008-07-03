From: Patrick McHardy <kaber@trash.net>
Subject: net-sched 01/06: add dynamically sized qdisc class hash helpers
Date: Thu,  3 Jul 2008 17:16:02 +0200 (MEST)
Message-ID: <20080703151602.26225.4418.sendpatchset@localhost.localdomain>
References: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Cc: devik@cdi.cz, Patrick McHardy <kaber@trash.net>, jarkao2@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40212 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbYGCPQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jul 2008 11:16:04 -0400
In-Reply-To: <20080703151600.26225.3394.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

net-sched: add dynamically sized qdisc class hash helpers

Currently all qdiscs which allow to create classes uses a fixed sized hash
table with size 16 to hash the classes. This causes a large bottleneck
when using thousands of classes and unbound filters.

Add helpers for dynamically sized class hashes to fix this. The following
patches will convert the qdiscs to use them.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit ba0c034039d0c4a76c38cd1d252a4e6a5a65333d
tree 6bf49094e76c1fea2594a404c718ffa2aa652d9a
parent dbe4e4f34c356cd31cf9bc8972c0eb4eadebe920
author Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 16:58:45 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 03 Jul 2008 16:58:45 +0200

 include/net/sch_generic.h |   42 ++++++++++++++++++
 net/sched/sch_api.c       |  104 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 146 insertions(+), 0 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index a87fc03..073f258 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -167,6 +167,48 @@ extern void qdisc_unlock_tree(struct net_device *dev);
 extern struct Qdisc noop_qdisc;
 extern struct Qdisc_ops noop_qdisc_ops;
 
+struct Qdisc_class_common
+{
+	u32			classid;
+	struct hlist_node	hnode;
+};
+
+struct Qdisc_class_hash
+{
+	struct hlist_head	*hash;
+	unsigned int		hashsize;
+	unsigned int		hashmask;
+	unsigned int		hashelems;
+};
+
+static inline unsigned int qdisc_class_hash(u32 id, u32 mask)
+{
+	id ^= id >> 8;
+	id ^= id >> 4;
+	return id & mask;
+}
+
+static inline struct Qdisc_class_common *
+qdisc_class_find(struct Qdisc_class_hash *hash, u32 id)
+{
+	struct Qdisc_class_common *cl;
+	struct hlist_node *n;
+	unsigned int h;
+
+	h = qdisc_class_hash(id, hash->hashmask);
+	hlist_for_each_entry(cl, n, &hash->hash[h], hnode) {
+		if (cl->classid == id)
+			return cl;
+	}
+	return NULL;
+}
+
+extern int qdisc_class_hash_init(struct Qdisc_class_hash *);
+extern void qdisc_class_hash_insert(struct Qdisc_class_hash *, struct Qdisc_class_common *);
+extern void qdisc_class_hash_remove(struct Qdisc_class_hash *, struct Qdisc_class_common *);
+extern void qdisc_class_hash_grow(struct Qdisc *, struct Qdisc_class_hash *);
+extern void qdisc_class_hash_destroy(struct Qdisc_class_hash *);
+
 extern void dev_init_scheduler(struct net_device *dev);
 extern void dev_shutdown(struct net_device *dev);
 extern void dev_activate(struct net_device *dev);
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index 10f01ad..e9ebc7a 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -316,6 +316,110 @@ void qdisc_watchdog_cancel(struct qdisc_watchdog *wd)
 }
 EXPORT_SYMBOL(qdisc_watchdog_cancel);
 
+struct hlist_head *qdisc_class_hash_alloc(unsigned int n)
+{
+	unsigned int size = n * sizeof(struct hlist_head), i;
+	struct hlist_head *h;
+
+	if (size <= PAGE_SIZE)
+		h = kmalloc(size, GFP_KERNEL);
+	else
+		h = (struct hlist_head *)
+			__get_free_pages(GFP_KERNEL, get_order(size));
+
+	if (h != NULL) {
+		for (i = 0; i < n; i++)
+			INIT_HLIST_HEAD(&h[i]);
+	}
+	return h;
+}
+
+static void qdisc_class_hash_free(struct hlist_head *h, unsigned int n)
+{
+	unsigned int size = n * sizeof(struct hlist_head);
+
+	if (size <= PAGE_SIZE)
+		kfree(h);
+	else
+		free_pages((unsigned long)h, get_order(size));
+}
+
+void qdisc_class_hash_grow(struct Qdisc *sch, struct Qdisc_class_hash *clhash)
+{
+	struct Qdisc_class_common *cl;
+	struct hlist_node *n, *next;
+	struct hlist_head *nhash, *ohash;
+	unsigned int nsize, nmask, osize;
+	unsigned int i, h;
+
+	/* Rehash when load factor exceeds 0.75 */
+	if (clhash->hashelems * 4 <= clhash->hashsize * 3)
+		return;
+	nsize = clhash->hashsize * 2;
+	nmask = nsize - 1;
+	nhash = qdisc_class_hash_alloc(nsize);
+	if (nhash == NULL)
+		return;
+
+	ohash = clhash->hash;
+	osize = clhash->hashsize;
+
+	sch_tree_lock(sch);
+	for (i = 0; i < osize; i++) {
+		hlist_for_each_entry_safe(cl, n, next, &ohash[i], hnode) {
+			h = qdisc_class_hash(cl->classid, nmask);
+			hlist_add_head(&cl->hnode, &nhash[h]);
+		}
+	}
+	clhash->hash     = nhash;
+	clhash->hashsize = nsize;
+	clhash->hashmask = nmask;
+	sch_tree_unlock(sch);
+
+	qdisc_class_hash_free(ohash, osize);
+}
+EXPORT_SYMBOL(qdisc_class_hash_grow);
+
+int qdisc_class_hash_init(struct Qdisc_class_hash *clhash)
+{
+	unsigned int size = 4;
+
+	clhash->hash = qdisc_class_hash_alloc(size);
+	if (clhash->hash == NULL)
+		return -ENOMEM;
+	clhash->hashsize  = size;
+	clhash->hashmask  = size - 1;
+	clhash->hashelems = 0;
+	return 0;
+}
+EXPORT_SYMBOL(qdisc_class_hash_init);
+
+void qdisc_class_hash_destroy(struct Qdisc_class_hash *clhash)
+{
+	qdisc_class_hash_free(clhash->hash, clhash->hashsize);
+}
+EXPORT_SYMBOL(qdisc_class_hash_destroy);
+
+void qdisc_class_hash_insert(struct Qdisc_class_hash *clhash,
+			     struct Qdisc_class_common *cl)
+{
+	unsigned int h;
+
+	INIT_HLIST_NODE(&cl->hnode);
+	h = qdisc_class_hash(cl->classid, clhash->hashmask);
+	hlist_add_head(&cl->hnode, &clhash->hash[h]);
+	clhash->hashelems++;
+}
+EXPORT_SYMBOL(qdisc_class_hash_insert);
+
+void qdisc_class_hash_remove(struct Qdisc_class_hash *clhash,
+			     struct Qdisc_class_common *cl)
+{
+	hlist_del(&cl->hnode);
+	clhash->hashelems--;
+}
+EXPORT_SYMBOL(qdisc_class_hash_remove);
+
 /* Allocate an unique handle from space managed by kernel */
 
 static u32 qdisc_alloc_handle(struct net_device *dev)
