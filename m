From: kaber@trash.net
Subject: [PATCH 09/72] netfilter: save the hash of the tuple in the original direction for latter use
Date: Thu, 21 Oct 2010 17:18:56 +0200
Message-ID: <1287674399-31455-10-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59997 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752199Ab0JUPUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:04 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

Since we don't change the tuple in the original direction, we can save it
in ct->tuplehash[IP_CT_DIR_REPLY].hnode.pprev for __nf_conntrack_confirm()
use.

__hash_conntrack() is split into two steps: hash_conntrack_raw() is used
to get the raw hash, and __hash_bucket() is used to get the bucket id.

In SYN-flood case, early_drop() doesn't need to recompute the hash again.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/nf_conntrack_core.c |  112 +++++++++++++++++++++++++-----------
 1 files changed, 78 insertions(+), 34 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 4c0ad9b..1eacf8d 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -67,29 +67,40 @@ EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
 
 static unsigned int nf_conntrack_hash_rnd __read_mostly;
 
-static u_int32_t __hash_conntrack(const struct nf_conntrack_tuple *tuple,
-				  u16 zone, unsigned int size, unsigned int rnd)
+static u32 hash_conntrack_raw(const struct nf_conntrack_tuple *tuple, u16 zone)
 {
 	unsigned int n;
-	u_int32_t h;
 
 	/* The direction must be ignored, so we hash everything up to the
 	 * destination ports (which is a multiple of 4) and treat the last
 	 * three bytes manually.
 	 */
 	n = (sizeof(tuple->src) + sizeof(tuple->dst.u3)) / sizeof(u32);
-	h = jhash2((u32 *)tuple, n,
-		   zone ^ rnd ^ (((__force __u16)tuple->dst.u.all << 16) |
-				 tuple->dst.protonum));
+	return jhash2((u32 *)tuple, n, zone ^ nf_conntrack_hash_rnd ^
+		      (((__force __u16)tuple->dst.u.all << 16) |
+		      tuple->dst.protonum));
+}
+
+static u32 __hash_bucket(u32 hash, unsigned int size)
+{
+	return ((u64)hash * size) >> 32;
+}
+
+static u32 hash_bucket(u32 hash, const struct net *net)
+{
+	return __hash_bucket(hash, net->ct.htable_size);
+}
 
-	return ((u64)h * size) >> 32;
+static u_int32_t __hash_conntrack(const struct nf_conntrack_tuple *tuple,
+				  u16 zone, unsigned int size)
+{
+	return __hash_bucket(hash_conntrack_raw(tuple, zone), size);
 }
 
 static inline u_int32_t hash_conntrack(const struct net *net, u16 zone,
 				       const struct nf_conntrack_tuple *tuple)
 {
-	return __hash_conntrack(tuple, zone, net->ct.htable_size,
-				nf_conntrack_hash_rnd);
+	return __hash_conntrack(tuple, zone, net->ct.htable_size);
 }
 
 bool
@@ -291,20 +302,20 @@ static void death_by_timeout(unsigned long ul_conntrack)
  * OR
  * - Caller must lock nf_conntrack_lock before calling this function
  */
-struct nf_conntrack_tuple_hash *
-__nf_conntrack_find(struct net *net, u16 zone,
-		    const struct nf_conntrack_tuple *tuple)
+static struct nf_conntrack_tuple_hash *
+____nf_conntrack_find(struct net *net, u16 zone,
+		      const struct nf_conntrack_tuple *tuple, u32 hash)
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_node *n;
-	unsigned int hash = hash_conntrack(net, zone, tuple);
+	unsigned int bucket = hash_bucket(hash, net);
 
 	/* Disable BHs the entire time since we normally need to disable them
 	 * at least once for the stats anyway.
 	 */
 	local_bh_disable();
 begin:
-	hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnnode) {
+	hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[bucket], hnnode) {
 		if (nf_ct_tuple_equal(tuple, &h->tuple) &&
 		    nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)) == zone) {
 			NF_CT_STAT_INC(net, found);
@@ -318,7 +329,7 @@ begin:
 	 * not the expected one, we must restart lookup.
 	 * We probably met an item that was moved to another chain.
 	 */
-	if (get_nulls_value(n) != hash) {
+	if (get_nulls_value(n) != bucket) {
 		NF_CT_STAT_INC(net, search_restart);
 		goto begin;
 	}
@@ -326,19 +337,27 @@ begin:
 
 	return NULL;
 }
+
+struct nf_conntrack_tuple_hash *
+__nf_conntrack_find(struct net *net, u16 zone,
+		    const struct nf_conntrack_tuple *tuple)
+{
+	return ____nf_conntrack_find(net, zone, tuple,
+				     hash_conntrack_raw(tuple, zone));
+}
 EXPORT_SYMBOL_GPL(__nf_conntrack_find);
 
 /* Find a connection corresponding to a tuple. */
-struct nf_conntrack_tuple_hash *
-nf_conntrack_find_get(struct net *net, u16 zone,
-		      const struct nf_conntrack_tuple *tuple)
+static struct nf_conntrack_tuple_hash *
+__nf_conntrack_find_get(struct net *net, u16 zone,
+			const struct nf_conntrack_tuple *tuple, u32 hash)
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
 
 	rcu_read_lock();
 begin:
-	h = __nf_conntrack_find(net, zone, tuple);
+	h = ____nf_conntrack_find(net, zone, tuple, hash);
 	if (h) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
 		if (unlikely(nf_ct_is_dying(ct) ||
@@ -356,6 +375,14 @@ begin:
 
 	return h;
 }
+
+struct nf_conntrack_tuple_hash *
+nf_conntrack_find_get(struct net *net, u16 zone,
+		      const struct nf_conntrack_tuple *tuple)
+{
+	return __nf_conntrack_find_get(net, zone, tuple,
+				       hash_conntrack_raw(tuple, zone));
+}
 EXPORT_SYMBOL_GPL(nf_conntrack_find_get);
 
 static void __nf_conntrack_hash_insert(struct nf_conn *ct,
@@ -408,8 +435,11 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 		return NF_ACCEPT;
 
 	zone = nf_ct_zone(ct);
-	hash = hash_conntrack(net, zone, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
-	repl_hash = hash_conntrack(net, zone, &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+	/* reuse the hash saved before */
+	hash = *(unsigned long *)&ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev;
+	hash = hash_bucket(hash, net);
+	repl_hash = hash_conntrack(net, zone,
+				   &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
 
 	/* We're not in hash table, and we refuse to set up related
 	   connections for unconfirmed conns.  But packet copies and
@@ -566,10 +596,11 @@ static noinline int early_drop(struct net *net, unsigned int hash)
 	return dropped;
 }
 
-struct nf_conn *nf_conntrack_alloc(struct net *net, u16 zone,
-				   const struct nf_conntrack_tuple *orig,
-				   const struct nf_conntrack_tuple *repl,
-				   gfp_t gfp)
+static struct nf_conn *
+__nf_conntrack_alloc(struct net *net, u16 zone,
+		     const struct nf_conntrack_tuple *orig,
+		     const struct nf_conntrack_tuple *repl,
+		     gfp_t gfp, u32 hash)
 {
 	struct nf_conn *ct;
 
@@ -585,6 +616,9 @@ struct nf_conn *nf_conntrack_alloc(struct net *net, u16 zone,
 			get_random_bytes(&rand, sizeof(rand));
 		} while (!rand);
 		cmpxchg(&nf_conntrack_hash_rnd, 0, rand);
+
+		/* recompute the hash as nf_conntrack_hash_rnd is initialized */
+		hash = hash_conntrack_raw(orig, zone);
 	}
 
 	/* We don't want any race condition at early drop stage */
@@ -592,8 +626,7 @@ struct nf_conn *nf_conntrack_alloc(struct net *net, u16 zone,
 
 	if (nf_conntrack_max &&
 	    unlikely(atomic_read(&net->ct.count) > nf_conntrack_max)) {
-		unsigned int hash = hash_conntrack(net, zone, orig);
-		if (!early_drop(net, hash)) {
+		if (!early_drop(net, hash_bucket(hash, net))) {
 			atomic_dec(&net->ct.count);
 			if (net_ratelimit())
 				printk(KERN_WARNING
@@ -623,7 +656,8 @@ struct nf_conn *nf_conntrack_alloc(struct net *net, u16 zone,
 	ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple = *orig;
 	ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.pprev = NULL;
 	ct->tuplehash[IP_CT_DIR_REPLY].tuple = *repl;
-	ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev = NULL;
+	/* save hash for reusing when confirming */
+	*(unsigned long *)(&ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev) = hash;
 	/* Don't set timer yet: wait for confirmation */
 	setup_timer(&ct->timeout, death_by_timeout, (unsigned long)ct);
 	write_pnet(&ct->ct_net, net);
@@ -650,6 +684,14 @@ out_free:
 	return ERR_PTR(-ENOMEM);
 #endif
 }
+
+struct nf_conn *nf_conntrack_alloc(struct net *net, u16 zone,
+				   const struct nf_conntrack_tuple *orig,
+				   const struct nf_conntrack_tuple *repl,
+				   gfp_t gfp)
+{
+	return __nf_conntrack_alloc(net, zone, orig, repl, gfp, 0);
+}
 EXPORT_SYMBOL_GPL(nf_conntrack_alloc);
 
 void nf_conntrack_free(struct nf_conn *ct)
@@ -671,7 +713,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 	       struct nf_conntrack_l3proto *l3proto,
 	       struct nf_conntrack_l4proto *l4proto,
 	       struct sk_buff *skb,
-	       unsigned int dataoff)
+	       unsigned int dataoff, u32 hash)
 {
 	struct nf_conn *ct;
 	struct nf_conn_help *help;
@@ -685,7 +727,8 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 		return NULL;
 	}
 
-	ct = nf_conntrack_alloc(net, zone, tuple, &repl_tuple, GFP_ATOMIC);
+	ct = __nf_conntrack_alloc(net, zone, tuple, &repl_tuple, GFP_ATOMIC,
+				  hash);
 	if (IS_ERR(ct)) {
 		pr_debug("Can't allocate conntrack.\n");
 		return (struct nf_conntrack_tuple_hash *)ct;
@@ -762,6 +805,7 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
 	u16 zone = tmpl ? nf_ct_zone(tmpl) : NF_CT_DEFAULT_ZONE;
+	u32 hash;
 
 	if (!nf_ct_get_tuple(skb, skb_network_offset(skb),
 			     dataoff, l3num, protonum, &tuple, l3proto,
@@ -771,10 +815,11 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 	}
 
 	/* look for tuple match */
-	h = nf_conntrack_find_get(net, zone, &tuple);
+	hash = hash_conntrack_raw(&tuple, zone);
+	h = __nf_conntrack_find_get(net, zone, &tuple, hash);
 	if (!h) {
 		h = init_conntrack(net, tmpl, &tuple, l3proto, l4proto,
-				   skb, dataoff);
+				   skb, dataoff, hash);
 		if (!h)
 			return NULL;
 		if (IS_ERR(h))
@@ -1314,8 +1359,7 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 			ct = nf_ct_tuplehash_to_ctrack(h);
 			hlist_nulls_del_rcu(&h->hnnode);
 			bucket = __hash_conntrack(&h->tuple, nf_ct_zone(ct),
-						  hashsize,
-						  nf_conntrack_hash_rnd);
+						  hashsize);
 			hlist_nulls_add_head_rcu(&h->hnnode, &hash[bucket]);
 		}
 	}
-- 
1.7.1

