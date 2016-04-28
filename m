From: Florian Westphal <fw@strlen.de>
Subject: [PATCH nf-next 7/9] netfilter: conntrack: make netns address part of hash
Date: Thu, 28 Apr 2016 19:13:46 +0200
Message-ID: <1461863628-23350-8-git-send-email-fw@strlen.de>
References: <1461863628-23350-1-git-send-email-fw@strlen.de>
Cc: netdev@vger.kernel.org, Florian Westphal <fw@strlen.de>
To: <netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1461863628-23350-1-git-send-email-fw@strlen.de>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Once we place all conntracks into a global hash table we want them to be
spread across entire hash table, even if namespaces have overlapping ip
addresses.

We add nf_conntrack_netns_hash helper to later re-use it for nat bysrc
and expectation hash handling.  The helper also allows us to avoid the
(then) pointless hashing of init_net if kernel is built without netns
support.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 include/net/netfilter/nf_conntrack_core.h | 10 +++++++++
 net/netfilter/nf_conntrack_core.c         | 34 +++++++++++++++----------------
 2 files changed, 27 insertions(+), 17 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index 62e17d1..389e6da 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -12,6 +12,7 @@
 #ifndef _NF_CONNTRACK_CORE_H
 #define _NF_CONNTRACK_CORE_H
 
+#include <linux/hash.h>
 #include <linux/netfilter.h>
 #include <net/netfilter/nf_conntrack_l3proto.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
@@ -86,4 +87,13 @@ void nf_conntrack_lock(spinlock_t *lock);
 
 extern spinlock_t nf_conntrack_expect_lock;
 
+static inline u32 nf_conntrack_netns_hash(const struct net *net)
+{
+#ifdef CONFIG_NET_NS
+	return hash_ptr(net, 32);
+#else
+	return 0;
+#endif
+}
+
 #endif /* _NF_CONNTRACK_CORE_H */
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 10ae2ee..c29b929 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -144,9 +144,11 @@ EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
 
 static unsigned int nf_conntrack_hash_rnd __read_mostly;
 
-static u32 hash_conntrack_raw(const struct nf_conntrack_tuple *tuple)
+static u32 hash_conntrack_raw(const struct nf_conntrack_tuple *tuple,
+			      const struct net *net)
 {
 	unsigned int n;
+	u32 seed;
 
 	get_random_once(&nf_conntrack_hash_rnd, sizeof(nf_conntrack_hash_rnd));
 
@@ -154,32 +156,29 @@ static u32 hash_conntrack_raw(const struct nf_conntrack_tuple *tuple)
 	 * destination ports (which is a multiple of 4) and treat the last
 	 * three bytes manually.
 	 */
+	seed = nf_conntrack_hash_rnd ^ nf_conntrack_netns_hash(net);
 	n = (sizeof(tuple->src) + sizeof(tuple->dst.u3)) / sizeof(u32);
-	return jhash2((u32 *)tuple, n, nf_conntrack_hash_rnd ^
+	return jhash2((u32 *)tuple, n, seed ^
 		      (((__force __u16)tuple->dst.u.all << 16) |
 		      tuple->dst.protonum));
 }
 
-static u32 __hash_bucket(u32 hash, unsigned int size)
-{
-	return reciprocal_scale(hash, size);
-}
-
 static u32 hash_bucket(u32 hash, const struct net *net)
 {
-	return __hash_bucket(hash, net->ct.htable_size);
+	return reciprocal_scale(hash, net->ct.htable_size);
 }
 
-static u_int32_t __hash_conntrack(const struct nf_conntrack_tuple *tuple,
-				  unsigned int size)
+static u32 __hash_conntrack(const struct net *net,
+			    const struct nf_conntrack_tuple *tuple,
+			    unsigned int size)
 {
-	return __hash_bucket(hash_conntrack_raw(tuple), size);
+	return reciprocal_scale(hash_conntrack_raw(tuple, net), size);
 }
 
-static inline u_int32_t hash_conntrack(const struct net *net,
-				       const struct nf_conntrack_tuple *tuple)
+static u32 hash_conntrack(const struct net *net,
+			  const struct nf_conntrack_tuple *tuple)
 {
-	return __hash_conntrack(tuple, net->ct.htable_size);
+	return __hash_conntrack(net, tuple, net->ct.htable_size);
 }
 
 bool
@@ -535,7 +534,7 @@ nf_conntrack_find_get(struct net *net, const struct nf_conntrack_zone *zone,
 		      const struct nf_conntrack_tuple *tuple)
 {
 	return __nf_conntrack_find_get(net, zone, tuple,
-				       hash_conntrack_raw(tuple));
+				       hash_conntrack_raw(tuple, net));
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_find_get);
 
@@ -1041,7 +1040,7 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 
 	/* look for tuple match */
 	zone = nf_ct_zone_tmpl(tmpl, skb, &tmp);
-	hash = hash_conntrack_raw(&tuple);
+	hash = hash_conntrack_raw(&tuple, net);
 	h = __nf_conntrack_find_get(net, zone, &tuple, hash);
 	if (!h) {
 		h = init_conntrack(net, tmpl, &tuple, l3proto, l4proto,
@@ -1605,7 +1604,8 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 					struct nf_conntrack_tuple_hash, hnnode);
 			ct = nf_ct_tuplehash_to_ctrack(h);
 			hlist_nulls_del_rcu(&h->hnnode);
-			bucket = __hash_conntrack(&h->tuple, hashsize);
+			bucket = __hash_conntrack(nf_ct_net(ct),
+						  &h->tuple, hashsize);
 			hlist_nulls_add_head_rcu(&h->hnnode, &hash[bucket]);
 		}
 	}
-- 
2.7.3

