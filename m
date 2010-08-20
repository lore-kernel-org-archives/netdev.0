From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH v3] netfilter: save the hash of the tuple in the original direction for latter use
Date: Fri, 20 Aug 2010 22:53:23 +0800
Message-ID: <1282316003-2966-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	akpm@linux-foundation.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since we don't change the tuple in the original direction, we can save it
in ct->tuplehash[IP_CT_DIR_REPLY].hnode.pprev for __nf_conntrack_confirm()
use.

__hash_conntrack() is split into two steps: ____hash_conntrack() is used
to get the raw hash, and __hash_bucket() is used to get the bucket id.

In SYN-flood case, early_drop() doesn't need to recompute the hash again.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
v3: define static variable rnd out of the function ____hash_conntrack(),
    and call get_random_bytes() until we get a non-zero random int.
v2: use cmpxchg() to save 2 variables.
 net/netfilter/nf_conntrack_core.c |  122 ++++++++++++++++++++++++++------------
 1 file changed, 85 insertions(+), 37 deletions(-)
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index df3eedb..a6bb577 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -65,32 +65,57 @@ EXPORT_SYMBOL_GPL(nf_conntrack_max);
 DEFINE_PER_CPU(struct nf_conn, nf_conntrack_untracked);
 EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
 
-static int nf_conntrack_hash_rnd_initted;
-static unsigned int nf_conntrack_hash_rnd;
+static unsigned int nf_conntrack_rnd;
 
-static u_int32_t __hash_conntrack(const struct nf_conntrack_tuple *tuple,
-				  u16 zone, unsigned int size, unsigned int rnd)
+static u32 ____hash_conntrack(const struct nf_conntrack_tuple *tuple, u16 zone)
 {
 	unsigned int n;
 	u_int32_t h;
 
+	if (unlikely(!nf_conntrack_rnd)) {
+		unsigned int rand;
+
+		/* Why not initialize nf_conntrack_rnd in a "init()" function ?
+		 * Because there isn't enough entropy when system initializing,
+		 * and we initialize it as late as possible. */
+		do {
+			get_random_bytes(&rand, sizeof(rand));
+		} while (!rand);
+		cmpxchg(&nf_conntrack_rnd, 0, rand);
+	}
+
 	/* The direction must be ignored, so we hash everything up to the
 	 * destination ports (which is a multiple of 4) and treat the last
 	 * three bytes manually.
 	 */
 	n = (sizeof(tuple->src) + sizeof(tuple->dst.u3)) / sizeof(u32);
-	h = jhash2((u32 *)tuple, n,
-		   zone ^ rnd ^ (((__force __u16)tuple->dst.u.all << 16) |
-				 tuple->dst.protonum));
+	h = jhash2((u32 *)tuple, n, zone ^ nf_conntrack_rnd ^
+		   (((__force __u16)tuple->dst.u.all << 16) |
+		    tuple->dst.protonum));
+
+	return h;
+}
+
+static u32 __hash_bucket(u32 __hash, unsigned int size)
+{
+	return ((u64)__hash * size) >> 32;
+}
+
+static u32 hash_bucket(u32 __hash, const struct net *net)
+{
+	return __hash_bucket(__hash, net->ct.htable_size);
+}
 
-	return ((u64)h * size) >> 32;
+static u_int32_t __hash_conntrack(const struct nf_conntrack_tuple *tuple,
+				  u16 zone, unsigned int size)
+{
+	return __hash_bucket(____hash_conntrack(tuple, zone), size);
 }
 
 static inline u_int32_t hash_conntrack(const struct net *net, u16 zone,
 				       const struct nf_conntrack_tuple *tuple)
 {
-	return __hash_conntrack(tuple, zone, net->ct.htable_size,
-				nf_conntrack_hash_rnd);
+	return __hash_conntrack(tuple, zone, net->ct.htable_size);
 }
 
 bool
@@ -292,13 +317,13 @@ static void death_by_timeout(unsigned long ul_conntrack)
  * OR
  * - Caller must lock nf_conntrack_lock before calling this function
  */
-struct nf_conntrack_tuple_hash *
-__nf_conntrack_find(struct net *net, u16 zone,
-		    const struct nf_conntrack_tuple *tuple)
+static struct nf_conntrack_tuple_hash *
+____nf_conntrack_find(struct net *net, u16 zone,
+		      const struct nf_conntrack_tuple *tuple, u32 __hash)
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_node *n;
-	unsigned int hash = hash_conntrack(net, zone, tuple);
+	unsigned int hash = hash_bucket(__hash, net);
 
 	/* Disable BHs the entire time since we normally need to disable them
 	 * at least once for the stats anyway.
@@ -327,19 +352,27 @@ begin:
 
 	return NULL;
 }
+
+struct nf_conntrack_tuple_hash *
+__nf_conntrack_find(struct net *net, u16 zone,
+		    const struct nf_conntrack_tuple *tuple)
+{
+	return ____nf_conntrack_find(net, zone, tuple,
+				     ____hash_conntrack(tuple, zone));
+}
 EXPORT_SYMBOL_GPL(__nf_conntrack_find);
 
 /* Find a connection corresponding to a tuple. */
-struct nf_conntrack_tuple_hash *
-nf_conntrack_find_get(struct net *net, u16 zone,
-		      const struct nf_conntrack_tuple *tuple)
+static struct nf_conntrack_tuple_hash *
+__nf_conntrack_find_get(struct net *net, u16 zone,
+			const struct nf_conntrack_tuple *tuple, u32 __hash)
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
 
 	rcu_read_lock();
 begin:
-	h = __nf_conntrack_find(net, zone, tuple);
+	h = ____nf_conntrack_find(net, zone, tuple, __hash);
 	if (h) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
 		if (unlikely(nf_ct_is_dying(ct) ||
@@ -357,6 +390,14 @@ begin:
 
 	return h;
 }
+
+struct nf_conntrack_tuple_hash *
+nf_conntrack_find_get(struct net *net, u16 zone,
+		      const struct nf_conntrack_tuple *tuple)
+{
+	return __nf_conntrack_find_get(net, zone, tuple,
+				       ____hash_conntrack(tuple, zone));
+}
 EXPORT_SYMBOL_GPL(nf_conntrack_find_get);
 
 static void __nf_conntrack_hash_insert(struct nf_conn *ct,
@@ -409,7 +450,8 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 		return NF_ACCEPT;
 
 	zone = nf_ct_zone(ct);
-	hash = hash_conntrack(net, zone, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
+	/* reuse the __hash saved before */
+	hash = hash_bucket(*(unsigned long *)&ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev, net);
 	repl_hash = hash_conntrack(net, zone, &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
 
 	/* We're not in hash table, and we refuse to set up related
@@ -567,25 +609,20 @@ static noinline int early_drop(struct net *net, unsigned int hash)
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
+		     gfp_t gfp, u32 __hash)
 {
 	struct nf_conn *ct;
 
-	if (unlikely(!nf_conntrack_hash_rnd_initted)) {
-		get_random_bytes(&nf_conntrack_hash_rnd,
-				sizeof(nf_conntrack_hash_rnd));
-		nf_conntrack_hash_rnd_initted = 1;
-	}
-
 	/* We don't want any race condition at early drop stage */
 	atomic_inc(&net->ct.count);
 
 	if (nf_conntrack_max &&
 	    unlikely(atomic_read(&net->ct.count) > nf_conntrack_max)) {
-		unsigned int hash = hash_conntrack(net, zone, orig);
+		unsigned int hash = hash_bucket(__hash, net);
 		if (!early_drop(net, hash)) {
 			atomic_dec(&net->ct.count);
 			if (net_ratelimit())
@@ -616,7 +653,8 @@ struct nf_conn *nf_conntrack_alloc(struct net *net, u16 zone,
 	ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple = *orig;
 	ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.pprev = NULL;
 	ct->tuplehash[IP_CT_DIR_REPLY].tuple = *repl;
-	ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev = NULL;
+	/* save __hash for reusing when confirming */
+	*(unsigned long *)(&ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev) = __hash;
 	/* Don't set timer yet: wait for confirmation */
 	setup_timer(&ct->timeout, death_by_timeout, (unsigned long)ct);
 	write_pnet(&ct->ct_net, net);
@@ -643,6 +681,14 @@ out_free:
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
@@ -664,7 +710,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 	       struct nf_conntrack_l3proto *l3proto,
 	       struct nf_conntrack_l4proto *l4proto,
 	       struct sk_buff *skb,
-	       unsigned int dataoff)
+	       unsigned int dataoff, u32 __hash)
 {
 	struct nf_conn *ct;
 	struct nf_conn_help *help;
@@ -678,7 +724,8 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 		return NULL;
 	}
 
-	ct = nf_conntrack_alloc(net, zone, tuple, &repl_tuple, GFP_ATOMIC);
+	ct = __nf_conntrack_alloc(net, zone, tuple, &repl_tuple, GFP_ATOMIC,
+				  __hash);
 	if (IS_ERR(ct)) {
 		pr_debug("Can't allocate conntrack.\n");
 		return (struct nf_conntrack_tuple_hash *)ct;
@@ -755,6 +802,7 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
 	u16 zone = tmpl ? nf_ct_zone(tmpl) : NF_CT_DEFAULT_ZONE;
+	u32 __hash;
 
 	if (!nf_ct_get_tuple(skb, skb_network_offset(skb),
 			     dataoff, l3num, protonum, &tuple, l3proto,
@@ -764,10 +812,11 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 	}
 
 	/* look for tuple match */
-	h = nf_conntrack_find_get(net, zone, &tuple);
+	__hash = ____hash_conntrack(&tuple, zone);
+	h = __nf_conntrack_find_get(net, zone, &tuple, __hash);
 	if (!h) {
 		h = init_conntrack(net, tmpl, &tuple, l3proto, l4proto,
-				   skb, dataoff);
+				   skb, dataoff, __hash);
 		if (!h)
 			return NULL;
 		if (IS_ERR(h))
@@ -1307,8 +1356,7 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 			ct = nf_ct_tuplehash_to_ctrack(h);
 			hlist_nulls_del_rcu(&h->hnnode);
 			bucket = __hash_conntrack(&h->tuple, nf_ct_zone(ct),
-						  hashsize,
-						  nf_conntrack_hash_rnd);
+						  hashsize);
 			hlist_nulls_add_head_rcu(&h->hnnode, &hash[bucket]);
 		}
 	}
