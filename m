From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH 11/13] net_sched: remove hashmask from Qdisc_class_hash
Date: Tue,  4 Nov 2014 09:56:34 -0800
Message-ID: <1415123796-8093-12-git-send-email-xiyou.wangcong@gmail.com>
References: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:45976 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbaKDR47 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 12:56:59 -0500
Received: by mail-pd0-f178.google.com with SMTP id fp1so14211435pdb.9
        for <netdev@vger.kernel.org>; Tue, 04 Nov 2014 09:56:58 -0800 (PST)
In-Reply-To: <1415123796-8093-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/net/sch_generic.h | 8 +++++---
 net/sched/sch_api.c       | 9 +++------
 2 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/include/net/sch_generic.h b/include/net/sch_generic.h
index 89c3f37..1f30524 100644
--- a/include/net/sch_generic.h
+++ b/include/net/sch_generic.h
@@ -359,12 +359,14 @@ struct Qdisc_class_common {
 struct Qdisc_class_hash {
 	struct hlist_head	*hash;
 	unsigned int		hashsize;
-	unsigned int		hashmask;
 	unsigned int		hashelems;
 };
 
-static inline unsigned int qdisc_class_hash(u32 id, u32 mask)
+static inline
+unsigned int qdisc_class_hash(unsigned int id, unsigned int hashsize)
 {
+	unsigned int mask = hashsize- 1;
+
 	id ^= id >> 8;
 	id ^= id >> 4;
 	return id & mask;
@@ -376,7 +378,7 @@ qdisc_class_find(const struct Qdisc_class_hash *hash, u32 id)
 	struct Qdisc_class_common *cl;
 	unsigned int h;
 
-	h = qdisc_class_hash(id, hash->hashmask);
+	h = qdisc_class_hash(id, hash->hashsize);
 	hlist_for_each_entry(cl, &hash->hash[h], hnode) {
 		if (cl->classid == id)
 			return cl;
diff --git a/net/sched/sch_api.c b/net/sched/sch_api.c
index f57d3c6..efc60d6 100644
--- a/net/sched/sch_api.c
+++ b/net/sched/sch_api.c
@@ -647,14 +647,13 @@ void qdisc_class_hash_grow(struct Qdisc *sch, struct Qdisc_class_hash *clhash)
 	struct Qdisc_class_common *cl;
 	struct hlist_node *next;
 	struct hlist_head *nhash, *ohash;
-	unsigned int nsize, nmask, osize;
+	unsigned int nsize, osize;
 	unsigned int i, h;
 
 	/* Rehash when load factor exceeds 0.75 */
 	if (clhash->hashelems * 4 <= clhash->hashsize * 3)
 		return;
 	nsize = clhash->hashsize * 2;
-	nmask = nsize - 1;
 	nhash = qdisc_class_hash_alloc(nsize);
 	if (nhash == NULL)
 		return;
@@ -665,13 +664,12 @@ void qdisc_class_hash_grow(struct Qdisc *sch, struct Qdisc_class_hash *clhash)
 	sch_tree_lock(sch);
 	for (i = 0; i < osize; i++) {
 		hlist_for_each_entry_safe(cl, next, &ohash[i], hnode) {
-			h = qdisc_class_hash(cl->classid, nmask);
+			h = qdisc_class_hash(cl->classid, nsize);
 			hlist_add_head(&cl->hnode, &nhash[h]);
 		}
 	}
 	clhash->hash     = nhash;
 	clhash->hashsize = nsize;
-	clhash->hashmask = nmask;
 	sch_tree_unlock(sch);
 
 	qdisc_class_hash_free(ohash, osize);
@@ -686,7 +684,6 @@ int qdisc_class_hash_init(struct Qdisc_class_hash *clhash)
 	if (clhash->hash == NULL)
 		return -ENOMEM;
 	clhash->hashsize  = size;
-	clhash->hashmask  = size - 1;
 	clhash->hashelems = 0;
 	return 0;
 }
@@ -704,7 +701,7 @@ void qdisc_class_hash_insert(struct Qdisc_class_hash *clhash,
 	unsigned int h;
 
 	INIT_HLIST_NODE(&cl->hnode);
-	h = qdisc_class_hash(cl->classid, clhash->hashmask);
+	h = qdisc_class_hash(cl->classid, clhash->hashsize);
 	hlist_add_head(&cl->hnode, &clhash->hash[h]);
 	clhash->hashelems++;
 }
-- 
1.8.3.1
