From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/29] netfilter: conntrack: simplify the code by using nf_conntrack_get_ht
Date: Mon,  5 Sep 2016 12:58:24 +0200
Message-ID: <1473073124-5015-10-git-send-email-pablo@netfilter.org>
References: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35150 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933474AbcIEK7D (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 06:59:03 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 582112EFEAD
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 39CCE1150D1
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:59:01 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id A6EAA1150D4
        for <netdev@vger.kernel.org>; Mon,  5 Sep 2016 12:58:58 +0200 (CEST)
In-Reply-To: <1473073124-5015-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Liping Zhang <liping.zhang@spreadtrum.com>

Since commit 64b87639c9cb ("netfilter: conntrack: fix race between
nf_conntrack proc read and hash resize") introduce the
nf_conntrack_get_ht, so there's no need to check nf_conntrack_generation
again and again to get the hash table and hash size. And convert
nf_conntrack_get_ht to inline function here.

Suggested-by: Pablo Neira Ayuso <pablo@netfilter.org>
Signed-off-by: Liping Zhang <liping.zhang@spreadtrum.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h      | 20 ++++++++++++++
 include/net/netfilter/nf_conntrack_core.h |  3 --
 net/netfilter/nf_conntrack_core.c         | 46 +++++++------------------------
 3 files changed, 30 insertions(+), 39 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 445b019..2a12748 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -303,9 +303,29 @@ struct kernel_param;
 
 int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp);
 int nf_conntrack_hash_resize(unsigned int hashsize);
+
+extern struct hlist_nulls_head *nf_conntrack_hash;
 extern unsigned int nf_conntrack_htable_size;
+extern seqcount_t nf_conntrack_generation;
 extern unsigned int nf_conntrack_max;
 
+/* must be called with rcu read lock held */
+static inline void
+nf_conntrack_get_ht(struct hlist_nulls_head **hash, unsigned int *hsize)
+{
+	struct hlist_nulls_head *hptr;
+	unsigned int sequence, hsz;
+
+	do {
+		sequence = read_seqcount_begin(&nf_conntrack_generation);
+		hsz = nf_conntrack_htable_size;
+		hptr = nf_conntrack_hash;
+	} while (read_seqcount_retry(&nf_conntrack_generation, sequence));
+
+	*hash = hptr;
+	*hsize = hsz;
+}
+
 struct nf_conn *nf_ct_tmpl_alloc(struct net *net,
 				 const struct nf_conntrack_zone *zone,
 				 gfp_t flags);
diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index 79d7ac5..62e17d1 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -51,8 +51,6 @@ bool nf_ct_invert_tuple(struct nf_conntrack_tuple *inverse,
 			const struct nf_conntrack_l3proto *l3proto,
 			const struct nf_conntrack_l4proto *l4proto);
 
-void nf_conntrack_get_ht(struct hlist_nulls_head **hash, unsigned int *hsize);
-
 /* Find a connection corresponding to a tuple. */
 struct nf_conntrack_tuple_hash *
 nf_conntrack_find_get(struct net *net,
@@ -83,7 +81,6 @@ print_tuple(struct seq_file *s, const struct nf_conntrack_tuple *tuple,
 
 #define CONNTRACK_LOCKS 1024
 
-extern struct hlist_nulls_head *nf_conntrack_hash;
 extern spinlock_t nf_conntrack_locks[CONNTRACK_LOCKS];
 void nf_conntrack_lock(spinlock_t *lock);
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 22558b7..aeba28c 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -74,7 +74,6 @@ EXPORT_SYMBOL_GPL(nf_conntrack_hash);
 
 static __read_mostly struct kmem_cache *nf_conntrack_cachep;
 static __read_mostly spinlock_t nf_conntrack_locks_all_lock;
-static __read_mostly seqcount_t nf_conntrack_generation;
 static __read_mostly DEFINE_SPINLOCK(nf_conntrack_locks_all_lock);
 static __read_mostly bool nf_conntrack_locks_all;
 
@@ -162,6 +161,7 @@ static void nf_conntrack_all_unlock(void)
 
 unsigned int nf_conntrack_htable_size __read_mostly;
 unsigned int nf_conntrack_max __read_mostly;
+seqcount_t nf_conntrack_generation __read_mostly;
 
 DEFINE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
 EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
@@ -478,23 +478,6 @@ nf_ct_key_equal(struct nf_conntrack_tuple_hash *h,
 	       net_eq(net, nf_ct_net(ct));
 }
 
-/* must be called with rcu read lock held */
-void nf_conntrack_get_ht(struct hlist_nulls_head **hash, unsigned int *hsize)
-{
-	struct hlist_nulls_head *hptr;
-	unsigned int sequence, hsz;
-
-	do {
-		sequence = read_seqcount_begin(&nf_conntrack_generation);
-		hsz = nf_conntrack_htable_size;
-		hptr = nf_conntrack_hash;
-	} while (read_seqcount_retry(&nf_conntrack_generation, sequence));
-
-	*hash = hptr;
-	*hsize = hsz;
-}
-EXPORT_SYMBOL_GPL(nf_conntrack_get_ht);
-
 /*
  * Warning :
  * - Caller must take a reference on returned object
@@ -507,14 +490,11 @@ ____nf_conntrack_find(struct net *net, const struct nf_conntrack_zone *zone,
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_head *ct_hash;
 	struct hlist_nulls_node *n;
-	unsigned int bucket, sequence;
+	unsigned int bucket, hsize;
 
 begin:
-	do {
-		sequence = read_seqcount_begin(&nf_conntrack_generation);
-		bucket = scale_hash(hash);
-		ct_hash = nf_conntrack_hash;
-	} while (read_seqcount_retry(&nf_conntrack_generation, sequence));
+	nf_conntrack_get_ht(&ct_hash, &hsize);
+	bucket = reciprocal_scale(hash, hsize);
 
 	hlist_nulls_for_each_entry_rcu(h, n, &ct_hash[bucket], hnnode) {
 		if (nf_ct_key_equal(h, tuple, zone, net)) {
@@ -820,18 +800,15 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 	const struct nf_conntrack_zone *zone;
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_head *ct_hash;
-	unsigned int hash, sequence;
+	unsigned int hash, hsize;
 	struct hlist_nulls_node *n;
 	struct nf_conn *ct;
 
 	zone = nf_ct_zone(ignored_conntrack);
 
 	rcu_read_lock();
-	do {
-		sequence = read_seqcount_begin(&nf_conntrack_generation);
-		hash = hash_conntrack(net, tuple);
-		ct_hash = nf_conntrack_hash;
-	} while (read_seqcount_retry(&nf_conntrack_generation, sequence));
+	nf_conntrack_get_ht(&ct_hash, &hsize);
+	hash = __hash_conntrack(net, tuple, hsize);
 
 	hlist_nulls_for_each_entry_rcu(h, n, &ct_hash[hash], hnnode) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
@@ -897,14 +874,11 @@ static noinline int early_drop(struct net *net, unsigned int _hash)
 
 	for (i = 0; i < NF_CT_EVICTION_RANGE; i++) {
 		struct hlist_nulls_head *ct_hash;
-		unsigned hash, sequence, drops;
+		unsigned int hash, hsize, drops;
 
 		rcu_read_lock();
-		do {
-			sequence = read_seqcount_begin(&nf_conntrack_generation);
-			hash = scale_hash(_hash++);
-			ct_hash = nf_conntrack_hash;
-		} while (read_seqcount_retry(&nf_conntrack_generation, sequence));
+		nf_conntrack_get_ht(&ct_hash, &hsize);
+		hash = reciprocal_scale(_hash++, hsize);
 
 		drops = early_drop_list(net, &ct_hash[hash]);
 		rcu_read_unlock();
-- 
2.1.4
