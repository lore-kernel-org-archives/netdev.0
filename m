From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/25] netfilter: nat: convert nat bysrc hash to rhashtable
Date: Sat, 23 Jul 2016 13:08:21 +0200
Message-ID: <1469272119-29942-8-git-send-email-pablo@netfilter.org>
References: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35899 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751367AbcGWLJT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 23 Jul 2016 07:09:19 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id BB1D4E7DAA
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:17 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id AC161FC618
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:17 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 8C1B4FAB56
	for <netdev@vger.kernel.org>; Sat, 23 Jul 2016 13:09:15 +0200 (CEST)
In-Reply-To: <1469272119-29942-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

It did use a fixed-size bucket list plus single lock to protect add/del.

Unlike the main conntrack table we only need to add and remove keys.
Convert it to rhashtable to get table autosizing and per-bucket locking.

The maximum number of entries is -- as before -- tied to the number of
conntracks so we do not need another upperlimit.

The change does not handle rhashtable_remove_fast error, only possible
"error" is -ENOENT, and that is something that can happen legitimetely,
e.g. because nat module was inserted at a later time and no src manip
took place yet.

Tested with http-client-benchmark + httpterm with DNAT and SNAT rules
in place.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h |   3 +-
 include/net/netfilter/nf_nat.h       |   1 +
 net/netfilter/nf_nat_core.c          | 126 +++++++++++++++++++----------------
 3 files changed, 71 insertions(+), 59 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index e5135d8..a08825b 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -17,6 +17,7 @@
 #include <linux/bitops.h>
 #include <linux/compiler.h>
 #include <linux/atomic.h>
+#include <linux/rhashtable.h>
 
 #include <linux/netfilter/nf_conntrack_tcp.h>
 #include <linux/netfilter/nf_conntrack_dccp.h>
@@ -118,7 +119,7 @@ struct nf_conn {
 	struct nf_ct_ext *ext;
 
 #if IS_ENABLED(CONFIG_NF_NAT)
-	struct hlist_node	nat_bysource;
+	struct rhash_head	nat_bysource;
 #endif
 	/* Storage reserved for other modules, must be the last member */
 	union nf_conntrack_proto proto;
diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index 02515f7..c327a43 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -1,5 +1,6 @@
 #ifndef _NF_NAT_H
 #define _NF_NAT_H
+#include <linux/rhashtable.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter/nf_nat.h>
 #include <net/netfilter/nf_conntrack_tuple.h>
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 6925347..de31818 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -30,17 +30,19 @@
 #include <net/netfilter/nf_conntrack_zones.h>
 #include <linux/netfilter/nf_nat.h>
 
-static DEFINE_SPINLOCK(nf_nat_lock);
-
 static DEFINE_MUTEX(nf_nat_proto_mutex);
 static const struct nf_nat_l3proto __rcu *nf_nat_l3protos[NFPROTO_NUMPROTO]
 						__read_mostly;
 static const struct nf_nat_l4proto __rcu **nf_nat_l4protos[NFPROTO_NUMPROTO]
 						__read_mostly;
 
-static struct hlist_head *nf_nat_bysource __read_mostly;
-static unsigned int nf_nat_htable_size __read_mostly;
-static unsigned int nf_nat_hash_rnd __read_mostly;
+struct nf_nat_conn_key {
+	const struct net *net;
+	const struct nf_conntrack_tuple *tuple;
+	const struct nf_conntrack_zone *zone;
+};
+
+static struct rhashtable nf_nat_bysource_table;
 
 inline const struct nf_nat_l3proto *
 __nf_nat_l3proto_find(u8 family)
@@ -119,19 +121,17 @@ int nf_xfrm_me_harder(struct net *net, struct sk_buff *skb, unsigned int family)
 EXPORT_SYMBOL(nf_xfrm_me_harder);
 #endif /* CONFIG_XFRM */
 
-/* We keep an extra hash for each conntrack, for fast searching. */
-static inline unsigned int
-hash_by_src(const struct net *n, const struct nf_conntrack_tuple *tuple)
+static u32 nf_nat_bysource_hash(const void *data, u32 len, u32 seed)
 {
-	unsigned int hash;
-
-	get_random_once(&nf_nat_hash_rnd, sizeof(nf_nat_hash_rnd));
+	const struct nf_conntrack_tuple *t;
+	const struct nf_conn *ct = data;
 
+	t = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
 	/* Original src, to ensure we map it consistently if poss. */
-	hash = jhash2((u32 *)&tuple->src, sizeof(tuple->src) / sizeof(u32),
-		      tuple->dst.protonum ^ nf_nat_hash_rnd ^ net_hash_mix(n));
 
-	return reciprocal_scale(hash, nf_nat_htable_size);
+	seed ^= net_hash_mix(nf_ct_net(ct));
+	return jhash2((const u32 *)&t->src, sizeof(t->src) / sizeof(u32),
+		      t->dst.protonum ^ seed);
 }
 
 /* Is this tuple already taken? (not by us) */
@@ -187,6 +187,26 @@ same_src(const struct nf_conn *ct,
 		t->src.u.all == tuple->src.u.all);
 }
 
+static int nf_nat_bysource_cmp(struct rhashtable_compare_arg *arg,
+			       const void *obj)
+{
+	const struct nf_nat_conn_key *key = arg->key;
+	const struct nf_conn *ct = obj;
+
+	return same_src(ct, key->tuple) &&
+	       net_eq(nf_ct_net(ct), key->net) &&
+	       nf_ct_zone_equal(ct, key->zone, IP_CT_DIR_ORIGINAL);
+}
+
+static struct rhashtable_params nf_nat_bysource_params = {
+	.head_offset = offsetof(struct nf_conn, nat_bysource),
+	.obj_hashfn = nf_nat_bysource_hash,
+	.obj_cmpfn = nf_nat_bysource_cmp,
+	.nelem_hint = 256,
+	.min_size = 1024,
+	.nulls_base = (1U << RHT_BASE_SHIFT),
+};
+
 /* Only called for SRC manip */
 static int
 find_appropriate_src(struct net *net,
@@ -197,23 +217,23 @@ find_appropriate_src(struct net *net,
 		     struct nf_conntrack_tuple *result,
 		     const struct nf_nat_range *range)
 {
-	unsigned int h = hash_by_src(net, tuple);
 	const struct nf_conn *ct;
+	struct nf_nat_conn_key key = {
+		.net = net,
+		.tuple = tuple,
+		.zone = zone
+	};
 
-	hlist_for_each_entry_rcu(ct, &nf_nat_bysource[h], nat_bysource) {
-		if (same_src(ct, tuple) &&
-		    net_eq(net, nf_ct_net(ct)) &&
-		    nf_ct_zone_equal(ct, zone, IP_CT_DIR_ORIGINAL)) {
-			/* Copy source part from reply tuple. */
-			nf_ct_invert_tuplepr(result,
-				       &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
-			result->dst = tuple->dst;
-
-			if (in_range(l3proto, l4proto, result, range))
-				return 1;
-		}
-	}
-	return 0;
+	ct = rhashtable_lookup_fast(&nf_nat_bysource_table, &key,
+				    nf_nat_bysource_params);
+	if (!ct)
+		return 0;
+
+	nf_ct_invert_tuplepr(result,
+			     &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+	result->dst = tuple->dst;
+
+	return in_range(l3proto, l4proto, result, range);
 }
 
 /* For [FUTURE] fragmentation handling, we want the least-used
@@ -385,7 +405,6 @@ nf_nat_setup_info(struct nf_conn *ct,
 		  const struct nf_nat_range *range,
 		  enum nf_nat_manip_type maniptype)
 {
-	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_tuple curr_tuple, new_tuple;
 	struct nf_conn_nat *nat;
 
@@ -426,16 +445,13 @@ nf_nat_setup_info(struct nf_conn *ct,
 	}
 
 	if (maniptype == NF_NAT_MANIP_SRC) {
-		unsigned int srchash;
-
-		srchash = hash_by_src(net,
-				      &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
-		spin_lock_bh(&nf_nat_lock);
-		/* nf_conntrack_alter_reply might re-allocate extension aera */
-		nat = nfct_nat(ct);
-		hlist_add_head_rcu(&ct->nat_bysource,
-				   &nf_nat_bysource[srchash]);
-		spin_unlock_bh(&nf_nat_lock);
+		int err;
+
+		err = rhashtable_insert_fast(&nf_nat_bysource_table,
+					     &ct->nat_bysource,
+					     nf_nat_bysource_params);
+		if (err)
+			return NF_DROP;
 	}
 
 	/* It's done. */
@@ -552,10 +568,10 @@ static int nf_nat_proto_clean(struct nf_conn *ct, void *data)
 	if (!del_timer(&ct->timeout))
 		return 1;
 
-	spin_lock_bh(&nf_nat_lock);
-	hlist_del_rcu(&ct->nat_bysource);
 	ct->status &= ~IPS_NAT_DONE_MASK;
-	spin_unlock_bh(&nf_nat_lock);
+
+	rhashtable_remove_fast(&nf_nat_bysource_table, &ct->nat_bysource,
+			       nf_nat_bysource_params);
 
 	add_timer(&ct->timeout);
 
@@ -687,11 +703,8 @@ static void nf_nat_cleanup_conntrack(struct nf_conn *ct)
 	if (!nat)
 		return;
 
-	NF_CT_ASSERT(ct->status & IPS_SRC_NAT_DONE);
-
-	spin_lock_bh(&nf_nat_lock);
-	hlist_del_rcu(&ct->nat_bysource);
-	spin_unlock_bh(&nf_nat_lock);
+	rhashtable_remove_fast(&nf_nat_bysource_table, &ct->nat_bysource,
+			       nf_nat_bysource_params);
 }
 
 static struct nf_ct_ext_type nat_extend __read_mostly = {
@@ -826,16 +839,13 @@ static int __init nf_nat_init(void)
 {
 	int ret;
 
-	/* Leave them the same for the moment. */
-	nf_nat_htable_size = nf_conntrack_htable_size;
-
-	nf_nat_bysource = nf_ct_alloc_hashtable(&nf_nat_htable_size, 0);
-	if (!nf_nat_bysource)
-		return -ENOMEM;
+	ret = rhashtable_init(&nf_nat_bysource_table, &nf_nat_bysource_params);
+	if (ret)
+		return ret;
 
 	ret = nf_ct_extend_register(&nat_extend);
 	if (ret < 0) {
-		nf_ct_free_hashtable(nf_nat_bysource, nf_nat_htable_size);
+		rhashtable_destroy(&nf_nat_bysource_table);
 		printk(KERN_ERR "nf_nat_core: Unable to register extension\n");
 		return ret;
 	}
@@ -859,7 +869,7 @@ static int __init nf_nat_init(void)
 	return 0;
 
  cleanup_extend:
-	nf_ct_free_hashtable(nf_nat_bysource, nf_nat_htable_size);
+	rhashtable_destroy(&nf_nat_bysource_table);
 	nf_ct_extend_unregister(&nat_extend);
 	return ret;
 }
@@ -877,8 +887,8 @@ static void __exit nf_nat_cleanup(void)
 #endif
 	for (i = 0; i < NFPROTO_NUMPROTO; i++)
 		kfree(nf_nat_l4protos[i]);
-	synchronize_net();
-	nf_ct_free_hashtable(nf_nat_bysource, nf_nat_htable_size);
+
+	rhashtable_destroy(&nf_nat_bysource_table);
 }
 
 MODULE_LICENSE("GPL");
-- 
2.1.4
