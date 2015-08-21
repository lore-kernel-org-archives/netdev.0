From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/15] netfilter: nf_conntrack: push zone object into functions
Date: Fri, 21 Aug 2015 06:32:41 +0200
Message-ID: <1440131564-8807-13-git-send-email-pablo@netfilter.org>
References: <1440131564-8807-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1440131564-8807-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <daniel@iogearbox.net>

This patch replaces the zone id which is pushed down into functions
with the actual zone object. It's a bigger one-time change, but
needed for later on extending zones with a direction parameter, and
thus decoupling this additional information from all call-sites.

No functional changes in this patch.

The default zone becomes a global const object, namely nf_ct_zone_dflt
and will be returned directly in various cases, one being, when there's
f.e. no zoning support.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h           |   10 ++-
 include/net/netfilter/nf_conntrack_core.h      |    3 +-
 include/net/netfilter/nf_conntrack_expect.h    |   11 +++-
 include/net/netfilter/nf_conntrack_zones.h     |   33 +++++++---
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    2 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    3 +-
 net/ipv4/netfilter/nf_defrag_ipv4.c            |   11 ++--
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    3 +-
 net/ipv6/netfilter/nf_defrag_ipv6_hooks.c      |   12 ++--
 net/netfilter/ipvs/ip_vs_nfct.c                |    2 +-
 net/netfilter/nf_conntrack_core.c              |   75 +++++++++++++--------
 net/netfilter/nf_conntrack_expect.c            |   21 +++---
 net/netfilter/nf_conntrack_netlink.c           |   84 +++++++++++++-----------
 net/netfilter/nf_conntrack_pptp.c              |    3 +-
 net/netfilter/nf_conntrack_standalone.c        |   17 +++--
 net/netfilter/nf_nat_core.c                    |   19 ++++--
 net/netfilter/nf_synproxy_core.c               |    4 +-
 net/netfilter/xt_CT.c                          |    6 +-
 net/netfilter/xt_connlimit.c                   |    9 +--
 net/sched/act_connmark.c                       |    5 +-
 21 files changed, 203 insertions(+), 132 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index 37cd391..f5e23c6 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -250,8 +250,12 @@ void nf_ct_untracked_status_or(unsigned long bits);
 void nf_ct_iterate_cleanup(struct net *net,
 			   int (*iter)(struct nf_conn *i, void *data),
 			   void *data, u32 portid, int report);
+
+struct nf_conntrack_zone;
+
 void nf_conntrack_free(struct nf_conn *ct);
-struct nf_conn *nf_conntrack_alloc(struct net *net, u16 zone,
+struct nf_conn *nf_conntrack_alloc(struct net *net,
+				   const struct nf_conntrack_zone *zone,
 				   const struct nf_conntrack_tuple *orig,
 				   const struct nf_conntrack_tuple *repl,
 				   gfp_t gfp);
@@ -291,7 +295,9 @@ extern unsigned int nf_conntrack_max;
 extern unsigned int nf_conntrack_hash_rnd;
 void init_nf_conntrack_hash_rnd(void);
 
-struct nf_conn *nf_ct_tmpl_alloc(struct net *net, u16 zone, gfp_t flags);
+struct nf_conn *nf_ct_tmpl_alloc(struct net *net,
+				 const struct nf_conntrack_zone *zone,
+				 gfp_t flags);
 
 #define NF_CT_STAT_INC(net, count)	  __this_cpu_inc((net)->ct.stat->count)
 #define NF_CT_STAT_INC_ATOMIC(net, count) this_cpu_inc((net)->ct.stat->count)
diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index f2f0fa3..c03f9c4 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -52,7 +52,8 @@ bool nf_ct_invert_tuple(struct nf_conntrack_tuple *inverse,
 
 /* Find a connection corresponding to a tuple. */
 struct nf_conntrack_tuple_hash *
-nf_conntrack_find_get(struct net *net, u16 zone,
+nf_conntrack_find_get(struct net *net,
+		      const struct nf_conntrack_zone *zone,
 		      const struct nf_conntrack_tuple *tuple);
 
 int __nf_conntrack_confirm(struct sk_buff *skb);
diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netfilter/nf_conntrack_expect.h
index 3f3aecb..dce56f0 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -4,7 +4,9 @@
 
 #ifndef _NF_CONNTRACK_EXPECT_H
 #define _NF_CONNTRACK_EXPECT_H
+
 #include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_zones.h>
 
 extern unsigned int nf_ct_expect_hsize;
 extern unsigned int nf_ct_expect_max;
@@ -76,15 +78,18 @@ int nf_conntrack_expect_init(void);
 void nf_conntrack_expect_fini(void);
 
 struct nf_conntrack_expect *
-__nf_ct_expect_find(struct net *net, u16 zone,
+__nf_ct_expect_find(struct net *net,
+		    const struct nf_conntrack_zone *zone,
 		    const struct nf_conntrack_tuple *tuple);
 
 struct nf_conntrack_expect *
-nf_ct_expect_find_get(struct net *net, u16 zone,
+nf_ct_expect_find_get(struct net *net,
+		      const struct nf_conntrack_zone *zone,
 		      const struct nf_conntrack_tuple *tuple);
 
 struct nf_conntrack_expect *
-nf_ct_find_expectation(struct net *net, u16 zone,
+nf_ct_find_expectation(struct net *net,
+		       const struct nf_conntrack_zone *zone,
 		       const struct nf_conntrack_tuple *tuple);
 
 void nf_ct_unlink_expect_report(struct nf_conntrack_expect *exp,
diff --git a/include/net/netfilter/nf_conntrack_zones.h b/include/net/netfilter/nf_conntrack_zones.h
index 034efe8..0788bb0 100644
--- a/include/net/netfilter/nf_conntrack_zones.h
+++ b/include/net/netfilter/nf_conntrack_zones.h
@@ -1,25 +1,38 @@
 #ifndef _NF_CONNTRACK_ZONES_H
 #define _NF_CONNTRACK_ZONES_H
 
-#define NF_CT_DEFAULT_ZONE	0
-
-#if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
-#include <net/netfilter/nf_conntrack_extend.h>
+#define NF_CT_DEFAULT_ZONE_ID	0
 
 struct nf_conntrack_zone {
 	u16	id;
 };
 
-static inline u16 nf_ct_zone(const struct nf_conn *ct)
+extern const struct nf_conntrack_zone nf_ct_zone_dflt;
+
+#if IS_ENABLED(CONFIG_NF_CONNTRACK)
+#include <net/netfilter/nf_conntrack_extend.h>
+
+static inline const struct nf_conntrack_zone *
+nf_ct_zone(const struct nf_conn *ct)
 {
+	const struct nf_conntrack_zone *nf_ct_zone = NULL;
+
 #ifdef CONFIG_NF_CONNTRACK_ZONES
-	struct nf_conntrack_zone *nf_ct_zone;
 	nf_ct_zone = nf_ct_ext_find(ct, NF_CT_EXT_ZONE);
-	if (nf_ct_zone)
-		return nf_ct_zone->id;
 #endif
-	return NF_CT_DEFAULT_ZONE;
+	return nf_ct_zone ? nf_ct_zone : &nf_ct_zone_dflt;
 }
 
-#endif /* CONFIG_NF_CONNTRACK || CONFIG_NF_CONNTRACK_MODULE */
+static inline const struct nf_conntrack_zone *
+nf_ct_zone_tmpl(const struct nf_conn *tmpl)
+{
+	return tmpl ? nf_ct_zone(tmpl) : &nf_ct_zone_dflt;
+}
+
+static inline bool nf_ct_zone_equal(const struct nf_conn *a,
+				    const struct nf_conntrack_zone *b)
+{
+	return nf_ct_zone(a)->id == b->id;
+}
+#endif /* IS_ENABLED(CONFIG_NF_CONNTRACK) */
 #endif /* _NF_CONNTRACK_ZONES_H */
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 30ad955..8a2caaf 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -280,7 +280,7 @@ getorigdst(struct sock *sk, int optval, void __user *user, int *len)
 		return -EINVAL;
 	}
 
-	h = nf_conntrack_find_get(sock_net(sk), NF_CT_DEFAULT_ZONE, &tuple);
+	h = nf_conntrack_find_get(sock_net(sk), &nf_ct_zone_dflt, &tuple);
 	if (h) {
 		struct sockaddr_in sin;
 		struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 80d5554..8a2f41c 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -134,9 +134,10 @@ icmp_error_message(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 	struct nf_conntrack_tuple innertuple, origtuple;
 	const struct nf_conntrack_l4proto *innerproto;
 	const struct nf_conntrack_tuple_hash *h;
-	u16 zone = tmpl ? nf_ct_zone(tmpl) : NF_CT_DEFAULT_ZONE;
+	const struct nf_conntrack_zone *zone;
 
 	NF_CT_ASSERT(skb->nfct == NULL);
+	zone = nf_ct_zone_tmpl(tmpl);
 
 	/* Are they talking about one of our connections? */
 	if (!nf_ct_get_tuplepr(skb,
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index b69e82b..20fe8e6 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -43,19 +43,18 @@ static int nf_ct_ipv4_gather_frags(struct sk_buff *skb, u_int32_t user)
 static enum ip_defrag_users nf_ct_defrag_user(unsigned int hooknum,
 					      struct sk_buff *skb)
 {
-	u16 zone = NF_CT_DEFAULT_ZONE;
-
+	u16 zone_id = NF_CT_DEFAULT_ZONE_ID;
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	if (skb->nfct)
-		zone = nf_ct_zone((struct nf_conn *)skb->nfct);
+		zone_id = nf_ct_zone((struct nf_conn *)skb->nfct)->id;
 #endif
 	if (nf_bridge_in_prerouting(skb))
-		return IP_DEFRAG_CONNTRACK_BRIDGE_IN + zone;
+		return IP_DEFRAG_CONNTRACK_BRIDGE_IN + zone_id;
 
 	if (hooknum == NF_INET_PRE_ROUTING)
-		return IP_DEFRAG_CONNTRACK_IN + zone;
+		return IP_DEFRAG_CONNTRACK_IN + zone_id;
 	else
-		return IP_DEFRAG_CONNTRACK_OUT + zone;
+		return IP_DEFRAG_CONNTRACK_OUT + zone_id;
 }
 
 static unsigned int ipv4_conntrack_defrag(const struct nf_hook_ops *ops,
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 4ba0c34..7302900 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -251,7 +251,7 @@ ipv6_getorigdst(struct sock *sk, int optval, void __user *user, int *len)
 	if (*len < 0 || (unsigned int) *len < sizeof(sin6))
 		return -EINVAL;
 
-	h = nf_conntrack_find_get(sock_net(sk), NF_CT_DEFAULT_ZONE, &tuple);
+	h = nf_conntrack_find_get(sock_net(sk), &nf_ct_zone_dflt, &tuple);
 	if (!h) {
 		pr_debug("IP6T_SO_ORIGINAL_DST: Can't find %pI6c/%u-%pI6c/%u.\n",
 			 &tuple.src.u3.ip6, ntohs(tuple.src.u.tcp.port),
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 90388d6..2029141 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -150,7 +150,6 @@ icmpv6_error_message(struct net *net, struct nf_conn *tmpl,
 	struct nf_conntrack_tuple intuple, origtuple;
 	const struct nf_conntrack_tuple_hash *h;
 	const struct nf_conntrack_l4proto *inproto;
-	u16 zone = tmpl ? nf_ct_zone(tmpl) : NF_CT_DEFAULT_ZONE;
 
 	NF_CT_ASSERT(skb->nfct == NULL);
 
@@ -177,7 +176,7 @@ icmpv6_error_message(struct net *net, struct nf_conn *tmpl,
 
 	*ctinfo = IP_CT_RELATED;
 
-	h = nf_conntrack_find_get(net, zone, &intuple);
+	h = nf_conntrack_find_get(net, nf_ct_zone_tmpl(tmpl), &intuple);
 	if (!h) {
 		pr_debug("icmpv6_error: no match\n");
 		return -NF_ACCEPT;
diff --git a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
index 267fb8d..9d3de9b 100644
--- a/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
+++ b/net/ipv6/netfilter/nf_defrag_ipv6_hooks.c
@@ -33,20 +33,18 @@
 static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
 						struct sk_buff *skb)
 {
-	u16 zone = NF_CT_DEFAULT_ZONE;
-
+	u16 zone_id = NF_CT_DEFAULT_ZONE_ID;
 #if IS_ENABLED(CONFIG_NF_CONNTRACK)
 	if (skb->nfct)
-		zone = nf_ct_zone((struct nf_conn *)skb->nfct);
+		zone_id = nf_ct_zone((struct nf_conn *)skb->nfct)->id;
 #endif
 	if (nf_bridge_in_prerouting(skb))
-		return IP6_DEFRAG_CONNTRACK_BRIDGE_IN + zone;
+		return IP6_DEFRAG_CONNTRACK_BRIDGE_IN + zone_id;
 
 	if (hooknum == NF_INET_PRE_ROUTING)
-		return IP6_DEFRAG_CONNTRACK_IN + zone;
+		return IP6_DEFRAG_CONNTRACK_IN + zone_id;
 	else
-		return IP6_DEFRAG_CONNTRACK_OUT + zone;
-
+		return IP6_DEFRAG_CONNTRACK_OUT + zone_id;
 }
 
 static unsigned int ipv6_defrag(const struct nf_hook_ops *ops,
diff --git a/net/netfilter/ipvs/ip_vs_nfct.c b/net/netfilter/ipvs/ip_vs_nfct.c
index 5882bbf..1361845 100644
--- a/net/netfilter/ipvs/ip_vs_nfct.c
+++ b/net/netfilter/ipvs/ip_vs_nfct.c
@@ -274,7 +274,7 @@ void ip_vs_conn_drop_conntrack(struct ip_vs_conn *cp)
 		" for conn " FMT_CONN "\n",
 		__func__, ARG_TUPLE(&tuple), ARG_CONN(cp));
 
-	h = nf_conntrack_find_get(ip_vs_conn_net(cp), NF_CT_DEFAULT_ZONE,
+	h = nf_conntrack_find_get(ip_vs_conn_net(cp), &nf_ct_zone_dflt,
 				  &tuple);
 	if (h) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 651039a..0bb26e8 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -126,7 +126,8 @@ EXPORT_PER_CPU_SYMBOL(nf_conntrack_untracked);
 unsigned int nf_conntrack_hash_rnd __read_mostly;
 EXPORT_SYMBOL_GPL(nf_conntrack_hash_rnd);
 
-static u32 hash_conntrack_raw(const struct nf_conntrack_tuple *tuple, u16 zone)
+static u32 hash_conntrack_raw(const struct nf_conntrack_tuple *tuple,
+			      const struct nf_conntrack_zone *zone)
 {
 	unsigned int n;
 
@@ -135,7 +136,7 @@ static u32 hash_conntrack_raw(const struct nf_conntrack_tuple *tuple, u16 zone)
 	 * three bytes manually.
 	 */
 	n = (sizeof(tuple->src) + sizeof(tuple->dst.u3)) / sizeof(u32);
-	return jhash2((u32 *)tuple, n, zone ^ nf_conntrack_hash_rnd ^
+	return jhash2((u32 *)tuple, n, zone->id ^ nf_conntrack_hash_rnd ^
 		      (((__force __u16)tuple->dst.u.all << 16) |
 		      tuple->dst.protonum));
 }
@@ -151,12 +152,14 @@ static u32 hash_bucket(u32 hash, const struct net *net)
 }
 
 static u_int32_t __hash_conntrack(const struct nf_conntrack_tuple *tuple,
-				  u16 zone, unsigned int size)
+				  const struct nf_conntrack_zone *zone,
+				  unsigned int size)
 {
 	return __hash_bucket(hash_conntrack_raw(tuple, zone), size);
 }
 
-static inline u_int32_t hash_conntrack(const struct net *net, u16 zone,
+static inline u_int32_t hash_conntrack(const struct net *net,
+				       const struct nf_conntrack_zone *zone,
 				       const struct nf_conntrack_tuple *tuple)
 {
 	return __hash_conntrack(tuple, zone, net->ct.htable_size);
@@ -288,7 +291,9 @@ static void nf_ct_del_from_dying_or_unconfirmed_list(struct nf_conn *ct)
 }
 
 /* Released via destroy_conntrack() */
-struct nf_conn *nf_ct_tmpl_alloc(struct net *net, u16 zone, gfp_t flags)
+struct nf_conn *nf_ct_tmpl_alloc(struct net *net,
+				 const struct nf_conntrack_zone *zone,
+				 gfp_t flags)
 {
 	struct nf_conn *tmpl;
 
@@ -306,7 +311,7 @@ struct nf_conn *nf_ct_tmpl_alloc(struct net *net, u16 zone, gfp_t flags)
 		nf_ct_zone = nf_ct_ext_add(tmpl, NF_CT_EXT_ZONE, GFP_ATOMIC);
 		if (!nf_ct_zone)
 			goto out_free;
-		nf_ct_zone->id = zone;
+		nf_ct_zone->id = zone->id;
 	}
 #endif
 	atomic_set(&tmpl->ct_general.use, 0);
@@ -371,11 +376,12 @@ destroy_conntrack(struct nf_conntrack *nfct)
 
 static void nf_ct_delete_from_lists(struct nf_conn *ct)
 {
+	const struct nf_conntrack_zone *zone;
 	struct net *net = nf_ct_net(ct);
 	unsigned int hash, reply_hash;
-	u16 zone = nf_ct_zone(ct);
 	unsigned int sequence;
 
+	zone = nf_ct_zone(ct);
 	nf_ct_helper_destroy(ct);
 
 	local_bh_disable();
@@ -431,8 +437,8 @@ static void death_by_timeout(unsigned long ul_conntrack)
 
 static inline bool
 nf_ct_key_equal(struct nf_conntrack_tuple_hash *h,
-			const struct nf_conntrack_tuple *tuple,
-			u16 zone)
+		const struct nf_conntrack_tuple *tuple,
+		const struct nf_conntrack_zone *zone)
 {
 	struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
 
@@ -440,8 +446,8 @@ nf_ct_key_equal(struct nf_conntrack_tuple_hash *h,
 	 * so we need to check that the conntrack is confirmed
 	 */
 	return nf_ct_tuple_equal(tuple, &h->tuple) &&
-		nf_ct_zone(ct) == zone &&
-		nf_ct_is_confirmed(ct);
+	       nf_ct_zone_equal(ct, zone) &&
+	       nf_ct_is_confirmed(ct);
 }
 
 /*
@@ -450,7 +456,7 @@ nf_ct_key_equal(struct nf_conntrack_tuple_hash *h,
  *   and recheck nf_ct_tuple_equal(tuple, &h->tuple)
  */
 static struct nf_conntrack_tuple_hash *
-____nf_conntrack_find(struct net *net, u16 zone,
+____nf_conntrack_find(struct net *net, const struct nf_conntrack_zone *zone,
 		      const struct nf_conntrack_tuple *tuple, u32 hash)
 {
 	struct nf_conntrack_tuple_hash *h;
@@ -486,7 +492,7 @@ begin:
 
 /* Find a connection corresponding to a tuple. */
 static struct nf_conntrack_tuple_hash *
-__nf_conntrack_find_get(struct net *net, u16 zone,
+__nf_conntrack_find_get(struct net *net, const struct nf_conntrack_zone *zone,
 			const struct nf_conntrack_tuple *tuple, u32 hash)
 {
 	struct nf_conntrack_tuple_hash *h;
@@ -513,7 +519,7 @@ begin:
 }
 
 struct nf_conntrack_tuple_hash *
-nf_conntrack_find_get(struct net *net, u16 zone,
+nf_conntrack_find_get(struct net *net, const struct nf_conntrack_zone *zone,
 		      const struct nf_conntrack_tuple *tuple)
 {
 	return __nf_conntrack_find_get(net, zone, tuple,
@@ -536,11 +542,11 @@ static void __nf_conntrack_hash_insert(struct nf_conn *ct,
 int
 nf_conntrack_hash_check_insert(struct nf_conn *ct)
 {
+	const struct nf_conntrack_zone *zone;
 	struct net *net = nf_ct_net(ct);
 	unsigned int hash, reply_hash;
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_node *n;
-	u16 zone;
 	unsigned int sequence;
 
 	zone = nf_ct_zone(ct);
@@ -558,12 +564,12 @@ nf_conntrack_hash_check_insert(struct nf_conn *ct)
 	hlist_nulls_for_each_entry(h, n, &net->ct.hash[hash], hnnode)
 		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
 				      &h->tuple) &&
-		    zone == nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)))
+		    nf_ct_zone_equal(nf_ct_tuplehash_to_ctrack(h), zone))
 			goto out;
 	hlist_nulls_for_each_entry(h, n, &net->ct.hash[reply_hash], hnnode)
 		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_REPLY].tuple,
 				      &h->tuple) &&
-		    zone == nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)))
+		    nf_ct_zone_equal(nf_ct_tuplehash_to_ctrack(h), zone))
 			goto out;
 
 	add_timer(&ct->timeout);
@@ -588,6 +594,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_hash_check_insert);
 int
 __nf_conntrack_confirm(struct sk_buff *skb)
 {
+	const struct nf_conntrack_zone *zone;
 	unsigned int hash, reply_hash;
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
@@ -596,7 +603,6 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	struct hlist_nulls_node *n;
 	enum ip_conntrack_info ctinfo;
 	struct net *net;
-	u16 zone;
 	unsigned int sequence;
 
 	ct = nf_ct_get(skb, &ctinfo);
@@ -649,12 +655,12 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	hlist_nulls_for_each_entry(h, n, &net->ct.hash[hash], hnnode)
 		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
 				      &h->tuple) &&
-		    zone == nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)))
+		    nf_ct_zone_equal(nf_ct_tuplehash_to_ctrack(h), zone))
 			goto out;
 	hlist_nulls_for_each_entry(h, n, &net->ct.hash[reply_hash], hnnode)
 		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_REPLY].tuple,
 				      &h->tuple) &&
-		    zone == nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)))
+		    nf_ct_zone_equal(nf_ct_tuplehash_to_ctrack(h), zone))
 			goto out;
 
 	/* Timer relative to confirmation time, not original
@@ -707,11 +713,14 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 			 const struct nf_conn *ignored_conntrack)
 {
 	struct net *net = nf_ct_net(ignored_conntrack);
+	const struct nf_conntrack_zone *zone;
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_node *n;
 	struct nf_conn *ct;
-	u16 zone = nf_ct_zone(ignored_conntrack);
-	unsigned int hash = hash_conntrack(net, zone, tuple);
+	unsigned int hash;
+
+	zone = nf_ct_zone(ignored_conntrack);
+	hash = hash_conntrack(net, zone, tuple);
 
 	/* Disable BHs the entire time since we need to disable them at
 	 * least once for the stats anyway.
@@ -721,7 +730,7 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 		ct = nf_ct_tuplehash_to_ctrack(h);
 		if (ct != ignored_conntrack &&
 		    nf_ct_tuple_equal(tuple, &h->tuple) &&
-		    nf_ct_zone(ct) == zone) {
+		    nf_ct_zone_equal(ct, zone)) {
 			NF_CT_STAT_INC(net, found);
 			rcu_read_unlock_bh();
 			return 1;
@@ -810,7 +819,8 @@ void init_nf_conntrack_hash_rnd(void)
 }
 
 static struct nf_conn *
-__nf_conntrack_alloc(struct net *net, u16 zone,
+__nf_conntrack_alloc(struct net *net,
+		     const struct nf_conntrack_zone *zone,
 		     const struct nf_conntrack_tuple *orig,
 		     const struct nf_conntrack_tuple *repl,
 		     gfp_t gfp, u32 hash)
@@ -864,7 +874,7 @@ __nf_conntrack_alloc(struct net *net, u16 zone,
 		nf_ct_zone = nf_ct_ext_add(ct, NF_CT_EXT_ZONE, GFP_ATOMIC);
 		if (!nf_ct_zone)
 			goto out_free;
-		nf_ct_zone->id = zone;
+		nf_ct_zone->id = zone->id;
 	}
 #endif
 	/* Because we use RCU lookups, we set ct_general.use to zero before
@@ -881,7 +891,8 @@ out_free:
 #endif
 }
 
-struct nf_conn *nf_conntrack_alloc(struct net *net, u16 zone,
+struct nf_conn *nf_conntrack_alloc(struct net *net,
+				   const struct nf_conntrack_zone *zone,
 				   const struct nf_conntrack_tuple *orig,
 				   const struct nf_conntrack_tuple *repl,
 				   gfp_t gfp)
@@ -923,7 +934,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 	struct nf_conntrack_tuple repl_tuple;
 	struct nf_conntrack_ecache *ecache;
 	struct nf_conntrack_expect *exp = NULL;
-	u16 zone = tmpl ? nf_ct_zone(tmpl) : NF_CT_DEFAULT_ZONE;
+	const struct nf_conntrack_zone *zone;
 	struct nf_conn_timeout *timeout_ext;
 	unsigned int *timeouts;
 
@@ -932,6 +943,7 @@ init_conntrack(struct net *net, struct nf_conn *tmpl,
 		return NULL;
 	}
 
+	zone = nf_ct_zone_tmpl(tmpl);
 	ct = __nf_conntrack_alloc(net, zone, tuple, &repl_tuple, GFP_ATOMIC,
 				  hash);
 	if (IS_ERR(ct))
@@ -1026,10 +1038,10 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 		  int *set_reply,
 		  enum ip_conntrack_info *ctinfo)
 {
+	const struct nf_conntrack_zone *zone;
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
-	u16 zone = tmpl ? nf_ct_zone(tmpl) : NF_CT_DEFAULT_ZONE;
 	u32 hash;
 
 	if (!nf_ct_get_tuple(skb, skb_network_offset(skb),
@@ -1040,6 +1052,7 @@ resolve_normal_ct(struct net *net, struct nf_conn *tmpl,
 	}
 
 	/* look for tuple match */
+	zone = nf_ct_zone_tmpl(tmpl);
 	hash = hash_conntrack_raw(&tuple, zone);
 	h = __nf_conntrack_find_get(net, zone, &tuple, hash);
 	if (!h) {
@@ -1290,6 +1303,12 @@ bool __nf_ct_kill_acct(struct nf_conn *ct,
 }
 EXPORT_SYMBOL_GPL(__nf_ct_kill_acct);
 
+/* Built-in default zone used e.g. by modules. */
+const struct nf_conntrack_zone nf_ct_zone_dflt = {
+	.id	= NF_CT_DEFAULT_ZONE_ID,
+};
+EXPORT_SYMBOL_GPL(nf_ct_zone_dflt);
+
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 static struct nf_ct_ext_type nf_ct_zone_extend __read_mostly = {
 	.len	= sizeof(struct nf_conntrack_zone),
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index b45a422..980db85 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -88,7 +88,8 @@ static unsigned int nf_ct_expect_dst_hash(const struct nf_conntrack_tuple *tuple
 }
 
 struct nf_conntrack_expect *
-__nf_ct_expect_find(struct net *net, u16 zone,
+__nf_ct_expect_find(struct net *net,
+		    const struct nf_conntrack_zone *zone,
 		    const struct nf_conntrack_tuple *tuple)
 {
 	struct nf_conntrack_expect *i;
@@ -100,7 +101,7 @@ __nf_ct_expect_find(struct net *net, u16 zone,
 	h = nf_ct_expect_dst_hash(tuple);
 	hlist_for_each_entry_rcu(i, &net->ct.expect_hash[h], hnode) {
 		if (nf_ct_tuple_mask_cmp(tuple, &i->tuple, &i->mask) &&
-		    nf_ct_zone(i->master) == zone)
+		    nf_ct_zone_equal(i->master, zone))
 			return i;
 	}
 	return NULL;
@@ -109,7 +110,8 @@ EXPORT_SYMBOL_GPL(__nf_ct_expect_find);
 
 /* Just find a expectation corresponding to a tuple. */
 struct nf_conntrack_expect *
-nf_ct_expect_find_get(struct net *net, u16 zone,
+nf_ct_expect_find_get(struct net *net,
+		      const struct nf_conntrack_zone *zone,
 		      const struct nf_conntrack_tuple *tuple)
 {
 	struct nf_conntrack_expect *i;
@@ -127,7 +129,8 @@ EXPORT_SYMBOL_GPL(nf_ct_expect_find_get);
 /* If an expectation for this connection is found, it gets delete from
  * global list then returned. */
 struct nf_conntrack_expect *
-nf_ct_find_expectation(struct net *net, u16 zone,
+nf_ct_find_expectation(struct net *net,
+		       const struct nf_conntrack_zone *zone,
 		       const struct nf_conntrack_tuple *tuple)
 {
 	struct nf_conntrack_expect *i, *exp = NULL;
@@ -140,7 +143,7 @@ nf_ct_find_expectation(struct net *net, u16 zone,
 	hlist_for_each_entry(i, &net->ct.expect_hash[h], hnode) {
 		if (!(i->flags & NF_CT_EXPECT_INACTIVE) &&
 		    nf_ct_tuple_mask_cmp(tuple, &i->tuple, &i->mask) &&
-		    nf_ct_zone(i->master) == zone) {
+		    nf_ct_zone_equal(i->master, zone)) {
 			exp = i;
 			break;
 		}
@@ -220,16 +223,16 @@ static inline int expect_clash(const struct nf_conntrack_expect *a,
 	}
 
 	return nf_ct_tuple_mask_cmp(&a->tuple, &b->tuple, &intersect_mask) &&
-	       nf_ct_zone(a->master) == nf_ct_zone(b->master);
+	       nf_ct_zone_equal(a->master, nf_ct_zone(b->master));
 }
 
 static inline int expect_matches(const struct nf_conntrack_expect *a,
 				 const struct nf_conntrack_expect *b)
 {
 	return a->master == b->master && a->class == b->class &&
-		nf_ct_tuple_equal(&a->tuple, &b->tuple) &&
-		nf_ct_tuple_mask_equal(&a->mask, &b->mask) &&
-		nf_ct_zone(a->master) == nf_ct_zone(b->master);
+	       nf_ct_tuple_equal(&a->tuple, &b->tuple) &&
+	       nf_ct_tuple_mask_equal(&a->mask, &b->mask) &&
+	       nf_ct_zone_equal(a->master, nf_ct_zone(b->master));
 }
 
 /* Generally a bad idea to call this: could have matched already. */
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 6b8b0ab..95f7f01 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -458,6 +458,7 @@ static int
 ctnetlink_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 		    struct nf_conn *ct)
 {
+	const struct nf_conntrack_zone *zone;
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
 	struct nlattr *nest_parms;
@@ -487,8 +488,9 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 portid, u32 seq, u32 type,
 		goto nla_put_failure;
 	nla_nest_end(skb, nest_parms);
 
-	if (nf_ct_zone(ct) &&
-	    nla_put_be16(skb, CTA_ZONE, htons(nf_ct_zone(ct))))
+	zone = nf_ct_zone(ct);
+	if (zone->id != NF_CT_DEFAULT_ZONE_ID &&
+	    nla_put_be16(skb, CTA_ZONE, htons(zone->id)))
 		goto nla_put_failure;
 
 	if (ctnetlink_dump_status(skb, ct) < 0 ||
@@ -609,6 +611,7 @@ ctnetlink_nlmsg_size(const struct nf_conn *ct)
 static int
 ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 {
+	const struct nf_conntrack_zone *zone;
 	struct net *net;
 	struct nlmsghdr *nlh;
 	struct nfgenmsg *nfmsg;
@@ -669,8 +672,9 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 		goto nla_put_failure;
 	nla_nest_end(skb, nest_parms);
 
-	if (nf_ct_zone(ct) &&
-	    nla_put_be16(skb, CTA_ZONE, htons(nf_ct_zone(ct))))
+	zone = nf_ct_zone(ct);
+	if (zone->id != NF_CT_DEFAULT_ZONE_ID &&
+	    nla_put_be16(skb, CTA_ZONE, htons(zone->id)))
 		goto nla_put_failure;
 
 	if (ctnetlink_dump_id(skb, ct) < 0)
@@ -965,17 +969,18 @@ ctnetlink_parse_tuple(const struct nlattr * const cda[],
 }
 
 static int
-ctnetlink_parse_zone(const struct nlattr *attr, u16 *zone)
+ctnetlink_parse_zone(const struct nlattr *attr,
+		     struct nf_conntrack_zone *zone)
 {
-	if (attr)
+	zone->id = NF_CT_DEFAULT_ZONE_ID;
+
 #ifdef CONFIG_NF_CONNTRACK_ZONES
-		*zone = ntohs(nla_get_be16(attr));
+	if (attr)
+		zone->id = ntohs(nla_get_be16(attr));
 #else
+	if (attr)
 		return -EOPNOTSUPP;
 #endif
-	else
-		*zone = 0;
-
 	return 0;
 }
 
@@ -1058,7 +1063,7 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	struct nf_conn *ct;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int8_t u3 = nfmsg->nfgen_family;
-	u16 zone;
+	struct nf_conntrack_zone zone;
 	int err;
 
 	err = ctnetlink_parse_zone(cda[CTA_ZONE], &zone);
@@ -1078,7 +1083,7 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	h = nf_conntrack_find_get(net, zone, &tuple);
+	h = nf_conntrack_find_get(net, &zone, &tuple);
 	if (!h)
 		return -ENOENT;
 
@@ -1112,7 +1117,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	struct sk_buff *skb2 = NULL;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int8_t u3 = nfmsg->nfgen_family;
-	u16 zone;
+	struct nf_conntrack_zone zone;
 	int err;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
@@ -1147,7 +1152,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	h = nf_conntrack_find_get(net, zone, &tuple);
+	h = nf_conntrack_find_get(net, &zone, &tuple);
 	if (!h)
 		return -ENOENT;
 
@@ -1645,7 +1650,8 @@ ctnetlink_change_conntrack(struct nf_conn *ct,
 }
 
 static struct nf_conn *
-ctnetlink_create_conntrack(struct net *net, u16 zone,
+ctnetlink_create_conntrack(struct net *net,
+			   const struct nf_conntrack_zone *zone,
 			   const struct nlattr * const cda[],
 			   struct nf_conntrack_tuple *otuple,
 			   struct nf_conntrack_tuple *rtuple,
@@ -1804,7 +1810,7 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	struct nf_conn *ct;
 	u_int8_t u3 = nfmsg->nfgen_family;
-	u16 zone;
+	struct nf_conntrack_zone zone;
 	int err;
 
 	err = ctnetlink_parse_zone(cda[CTA_ZONE], &zone);
@@ -1824,9 +1830,9 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	}
 
 	if (cda[CTA_TUPLE_ORIG])
-		h = nf_conntrack_find_get(net, zone, &otuple);
+		h = nf_conntrack_find_get(net, &zone, &otuple);
 	else if (cda[CTA_TUPLE_REPLY])
-		h = nf_conntrack_find_get(net, zone, &rtuple);
+		h = nf_conntrack_find_get(net, &zone, &rtuple);
 
 	if (h == NULL) {
 		err = -ENOENT;
@@ -1836,7 +1842,7 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			if (!cda[CTA_TUPLE_ORIG] || !cda[CTA_TUPLE_REPLY])
 				return -EINVAL;
 
-			ct = ctnetlink_create_conntrack(net, zone, cda, &otuple,
+			ct = ctnetlink_create_conntrack(net, &zone, cda, &otuple,
 							&rtuple, u3);
 			if (IS_ERR(ct))
 				return PTR_ERR(ct);
@@ -2091,6 +2097,7 @@ ctnetlink_nfqueue_build_size(const struct nf_conn *ct)
 static int
 ctnetlink_nfqueue_build(struct sk_buff *skb, struct nf_conn *ct)
 {
+	const struct nf_conntrack_zone *zone;
 	struct nlattr *nest_parms;
 
 	rcu_read_lock();
@@ -2108,10 +2115,10 @@ ctnetlink_nfqueue_build(struct sk_buff *skb, struct nf_conn *ct)
 		goto nla_put_failure;
 	nla_nest_end(skb, nest_parms);
 
-	if (nf_ct_zone(ct)) {
-		if (nla_put_be16(skb, CTA_ZONE, htons(nf_ct_zone(ct))))
-			goto nla_put_failure;
-	}
+	zone = nf_ct_zone(ct);
+	if (zone->id != NF_CT_DEFAULT_ZONE_ID &&
+	    nla_put_be16(skb, CTA_ZONE, htons(zone->id)))
+		goto nla_put_failure;
 
 	if (ctnetlink_dump_id(skb, ct) < 0)
 		goto nla_put_failure;
@@ -2612,7 +2619,7 @@ static int ctnetlink_dump_exp_ct(struct sock *ctnl, struct sk_buff *skb,
 	struct nf_conntrack_tuple tuple;
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
-	u16 zone = 0;
+	struct nf_conntrack_zone zone;
 	struct netlink_dump_control c = {
 		.dump = ctnetlink_exp_ct_dump_table,
 		.done = ctnetlink_exp_done,
@@ -2622,13 +2629,11 @@ static int ctnetlink_dump_exp_ct(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	if (cda[CTA_EXPECT_ZONE]) {
-		err = ctnetlink_parse_zone(cda[CTA_EXPECT_ZONE], &zone);
-		if (err < 0)
-			return err;
-	}
+	err = ctnetlink_parse_zone(cda[CTA_EXPECT_ZONE], &zone);
+	if (err < 0)
+		return err;
 
-	h = nf_conntrack_find_get(net, zone, &tuple);
+	h = nf_conntrack_find_get(net, &zone, &tuple);
 	if (!h)
 		return -ENOENT;
 
@@ -2652,7 +2657,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	struct sk_buff *skb2;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int8_t u3 = nfmsg->nfgen_family;
-	u16 zone;
+	struct nf_conntrack_zone zone;
 	int err;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
@@ -2681,7 +2686,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	exp = nf_ct_expect_find_get(net, zone, &tuple);
+	exp = nf_ct_expect_find_get(net, &zone, &tuple);
 	if (!exp)
 		return -ENOENT;
 
@@ -2732,8 +2737,8 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	struct hlist_node *next;
 	u_int8_t u3 = nfmsg->nfgen_family;
+	struct nf_conntrack_zone zone;
 	unsigned int i;
-	u16 zone;
 	int err;
 
 	if (cda[CTA_EXPECT_TUPLE]) {
@@ -2747,7 +2752,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 			return err;
 
 		/* bump usage count to 2 */
-		exp = nf_ct_expect_find_get(net, zone, &tuple);
+		exp = nf_ct_expect_find_get(net, &zone, &tuple);
 		if (!exp)
 			return -ENOENT;
 
@@ -2937,7 +2942,8 @@ err_out:
 }
 
 static int
-ctnetlink_create_expect(struct net *net, u16 zone,
+ctnetlink_create_expect(struct net *net,
+			const struct nf_conntrack_zone *zone,
 			const struct nlattr * const cda[],
 			u_int8_t u3, u32 portid, int report)
 {
@@ -3011,7 +3017,7 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 	struct nf_conntrack_expect *exp;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int8_t u3 = nfmsg->nfgen_family;
-	u16 zone;
+	struct nf_conntrack_zone zone;
 	int err;
 
 	if (!cda[CTA_EXPECT_TUPLE]
@@ -3028,14 +3034,12 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 		return err;
 
 	spin_lock_bh(&nf_conntrack_expect_lock);
-	exp = __nf_ct_expect_find(net, zone, &tuple);
-
+	exp = __nf_ct_expect_find(net, &zone, &tuple);
 	if (!exp) {
 		spin_unlock_bh(&nf_conntrack_expect_lock);
 		err = -ENOENT;
 		if (nlh->nlmsg_flags & NLM_F_CREATE) {
-			err = ctnetlink_create_expect(net, zone, cda,
-						      u3,
+			err = ctnetlink_create_expect(net, &zone, cda, u3,
 						      NETLINK_CB(skb).portid,
 						      nlmsg_report(nlh));
 		}
diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
index 825c3e3..5588c7a 100644
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -143,13 +143,14 @@ static int destroy_sibling_or_exp(struct net *net, struct nf_conn *ct,
 				  const struct nf_conntrack_tuple *t)
 {
 	const struct nf_conntrack_tuple_hash *h;
+	const struct nf_conntrack_zone *zone;
 	struct nf_conntrack_expect *exp;
 	struct nf_conn *sibling;
-	u16 zone = nf_ct_zone(ct);
 
 	pr_debug("trying to timeout ct or exp for tuple ");
 	nf_ct_dump_tuple(t);
 
+	zone = nf_ct_zone(ct);
 	h = nf_conntrack_find_get(net, zone, t);
 	if (h)  {
 		sibling = nf_ct_tuplehash_to_ctrack(h);
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index fc823fa..28c8b2b 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -140,6 +140,17 @@ static inline void ct_show_secctx(struct seq_file *s, const struct nf_conn *ct)
 }
 #endif
 
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+static void ct_show_zone(struct seq_file *s, const struct nf_conn *ct)
+{
+	seq_printf(s, "zone=%u ", nf_ct_zone(ct)->id);
+}
+#else
+static inline void ct_show_zone(struct seq_file *s, const struct nf_conn *ct)
+{
+}
+#endif
+
 #ifdef CONFIG_NF_CONNTRACK_TIMESTAMP
 static void ct_show_delta_time(struct seq_file *s, const struct nf_conn *ct)
 {
@@ -228,11 +239,7 @@ static int ct_seq_show(struct seq_file *s, void *v)
 #endif
 
 	ct_show_secctx(s, ct);
-
-#ifdef CONFIG_NF_CONNTRACK_ZONES
-	seq_printf(s, "zone=%u ", nf_ct_zone(ct));
-#endif
-
+	ct_show_zone(s, ct);
 	ct_show_delta_time(s, ct);
 
 	seq_printf(s, "use=%u\n", atomic_read(&ct->ct_general.use));
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 4e0b478..65ebaf9 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -118,14 +118,15 @@ EXPORT_SYMBOL(nf_xfrm_me_harder);
 
 /* We keep an extra hash for each conntrack, for fast searching. */
 static inline unsigned int
-hash_by_src(const struct net *net, u16 zone,
+hash_by_src(const struct net *net,
+	    const struct nf_conntrack_zone *zone,
 	    const struct nf_conntrack_tuple *tuple)
 {
 	unsigned int hash;
 
 	/* Original src, to ensure we map it consistently if poss. */
 	hash = jhash2((u32 *)&tuple->src, sizeof(tuple->src) / sizeof(u32),
-		      tuple->dst.protonum ^ zone ^ nf_conntrack_hash_rnd);
+		      tuple->dst.protonum ^ zone->id ^ nf_conntrack_hash_rnd);
 
 	return reciprocal_scale(hash, net->ct.nat_htable_size);
 }
@@ -185,7 +186,8 @@ same_src(const struct nf_conn *ct,
 
 /* Only called for SRC manip */
 static int
-find_appropriate_src(struct net *net, u16 zone,
+find_appropriate_src(struct net *net,
+		     const struct nf_conntrack_zone *zone,
 		     const struct nf_nat_l3proto *l3proto,
 		     const struct nf_nat_l4proto *l4proto,
 		     const struct nf_conntrack_tuple *tuple,
@@ -198,7 +200,7 @@ find_appropriate_src(struct net *net, u16 zone,
 
 	hlist_for_each_entry_rcu(nat, &net->ct.nat_bysource[h], bysource) {
 		ct = nat->ct;
-		if (same_src(ct, tuple) && nf_ct_zone(ct) == zone) {
+		if (same_src(ct, tuple) && nf_ct_zone_equal(ct, zone)) {
 			/* Copy source part from reply tuple. */
 			nf_ct_invert_tuplepr(result,
 				       &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
@@ -218,7 +220,8 @@ find_appropriate_src(struct net *net, u16 zone,
  * the ip with the lowest src-ip/dst-ip/proto usage.
  */
 static void
-find_best_ips_proto(u16 zone, struct nf_conntrack_tuple *tuple,
+find_best_ips_proto(const struct nf_conntrack_zone *zone,
+		    struct nf_conntrack_tuple *tuple,
 		    const struct nf_nat_range *range,
 		    const struct nf_conn *ct,
 		    enum nf_nat_manip_type maniptype)
@@ -258,7 +261,7 @@ find_best_ips_proto(u16 zone, struct nf_conntrack_tuple *tuple,
 	 */
 	j = jhash2((u32 *)&tuple->src.u3, sizeof(tuple->src.u3) / sizeof(u32),
 		   range->flags & NF_NAT_RANGE_PERSISTENT ?
-			0 : (__force u32)tuple->dst.u3.all[max] ^ zone);
+			0 : (__force u32)tuple->dst.u3.all[max] ^ zone->id);
 
 	full_range = false;
 	for (i = 0; i <= max; i++) {
@@ -297,10 +300,12 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
 		 struct nf_conn *ct,
 		 enum nf_nat_manip_type maniptype)
 {
+	const struct nf_conntrack_zone *zone;
 	const struct nf_nat_l3proto *l3proto;
 	const struct nf_nat_l4proto *l4proto;
 	struct net *net = nf_ct_net(ct);
-	u16 zone = nf_ct_zone(ct);
+
+	zone = nf_ct_zone(ct);
 
 	rcu_read_lock();
 	l3proto = __nf_nat_l3proto_find(orig_tuple->src.l3num);
diff --git a/net/netfilter/nf_synproxy_core.c b/net/netfilter/nf_synproxy_core.c
index 71f1e9f..58b2e84 100644
--- a/net/netfilter/nf_synproxy_core.c
+++ b/net/netfilter/nf_synproxy_core.c
@@ -17,10 +17,12 @@
 #include <linux/netfilter/x_tables.h>
 #include <linux/netfilter/xt_tcpudp.h>
 #include <linux/netfilter/xt_SYNPROXY.h>
+
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_extend.h>
 #include <net/netfilter/nf_conntrack_seqadj.h>
 #include <net/netfilter/nf_conntrack_synproxy.h>
+#include <net/netfilter/nf_conntrack_zones.h>
 
 int synproxy_net_id;
 EXPORT_SYMBOL_GPL(synproxy_net_id);
@@ -352,7 +354,7 @@ static int __net_init synproxy_net_init(struct net *net)
 	struct nf_conn *ct;
 	int err = -ENOMEM;
 
-	ct = nf_ct_tmpl_alloc(net, 0, GFP_KERNEL);
+	ct = nf_ct_tmpl_alloc(net, &nf_ct_zone_dflt, GFP_KERNEL);
 	if (IS_ERR(ct)) {
 		err = PTR_ERR(ct);
 		goto err1;
diff --git a/net/netfilter/xt_CT.c b/net/netfilter/xt_CT.c
index c663003..29e2856 100644
--- a/net/netfilter/xt_CT.c
+++ b/net/netfilter/xt_CT.c
@@ -184,6 +184,7 @@ out:
 static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 			  struct xt_ct_target_info_v1 *info)
 {
+	struct nf_conntrack_zone zone;
 	struct nf_conn *ct;
 	int ret = -EOPNOTSUPP;
 
@@ -201,7 +202,10 @@ static int xt_ct_tg_check(const struct xt_tgchk_param *par,
 	if (ret < 0)
 		goto err1;
 
-	ct = nf_ct_tmpl_alloc(par->net, info->zone, GFP_KERNEL);
+	memset(&zone, 0, sizeof(zone));
+	zone.id = info->zone;
+
+	ct = nf_ct_tmpl_alloc(par->net, &zone, GFP_KERNEL);
 	ret = PTR_ERR(ct);
 	if (IS_ERR(ct))
 		goto err2;
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 29ba621..075d89d 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -134,7 +134,7 @@ static bool add_hlist(struct hlist_head *head,
 static unsigned int check_hlist(struct net *net,
 				struct hlist_head *head,
 				const struct nf_conntrack_tuple *tuple,
-				u16 zone,
+				const struct nf_conntrack_zone *zone,
 				bool *addit)
 {
 	const struct nf_conntrack_tuple_hash *found;
@@ -201,7 +201,7 @@ static unsigned int
 count_tree(struct net *net, struct rb_root *root,
 	   const struct nf_conntrack_tuple *tuple,
 	   const union nf_inet_addr *addr, const union nf_inet_addr *mask,
-	   u8 family, u16 zone)
+	   u8 family, const struct nf_conntrack_zone *zone)
 {
 	struct xt_connlimit_rb *gc_nodes[CONNLIMIT_GC_MAX_NODES];
 	struct rb_node **rbnode, *parent;
@@ -290,7 +290,8 @@ static int count_them(struct net *net,
 		      const struct nf_conntrack_tuple *tuple,
 		      const union nf_inet_addr *addr,
 		      const union nf_inet_addr *mask,
-		      u_int8_t family, u16 zone)
+		      u_int8_t family,
+		      const struct nf_conntrack_zone *zone)
 {
 	struct rb_root *root;
 	int count;
@@ -321,10 +322,10 @@ connlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	union nf_inet_addr addr;
 	struct nf_conntrack_tuple tuple;
 	const struct nf_conntrack_tuple *tuple_ptr = &tuple;
+	const struct nf_conntrack_zone *zone = &nf_ct_zone_dflt;
 	enum ip_conntrack_info ctinfo;
 	const struct nf_conn *ct;
 	unsigned int connections;
-	u16 zone = NF_CT_DEFAULT_ZONE;
 
 	ct = nf_ct_get(skb, &ctinfo);
 	if (ct != NULL) {
diff --git a/net/sched/act_connmark.c b/net/sched/act_connmark.c
index f2b5402..e67a1bd 100644
--- a/net/sched/act_connmark.c
+++ b/net/sched/act_connmark.c
@@ -37,6 +37,7 @@ static int tcf_connmark(struct sk_buff *skb, const struct tc_action *a,
 	struct nf_conntrack_tuple tuple;
 	enum ip_conntrack_info ctinfo;
 	struct tcf_connmark_info *ca = a->priv;
+	struct nf_conntrack_zone zone;
 	struct nf_conn *c;
 	int proto;
 
@@ -70,7 +71,9 @@ static int tcf_connmark(struct sk_buff *skb, const struct tc_action *a,
 			       proto, &tuple))
 		goto out;
 
-	thash = nf_conntrack_find_get(dev_net(skb->dev), ca->zone, &tuple);
+	zone.id = ca->zone;
+
+	thash = nf_conntrack_find_get(dev_net(skb->dev), &zone, &tuple);
 	if (!thash)
 		goto out;
 
-- 
1.7.10.4

