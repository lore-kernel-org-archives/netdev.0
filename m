From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 35/36] netfilter: conntrack: use a single nat bysource table for all namespaces
Date: Mon,  9 May 2016 20:46:53 +0200
Message-ID: <1462819614-5402-36-git-send-email-pablo@netfilter.org>
References: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1462819614-5402-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

We already include netns address in the hash, so we only need to use
net_eq in find_appropriate_src and can then put all entries into
same table.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netns/conntrack.h |  4 ----
 net/netfilter/nf_nat_core.c   | 33 +++++++++++++++++----------------
 2 files changed, 17 insertions(+), 20 deletions(-)

diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 2811ddc..1e751bf 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -103,9 +103,5 @@ struct netns_ct {
 	unsigned int		labels_used;
 	u8			label_words;
 #endif
-#ifdef CONFIG_NF_NAT_NEEDED
-	struct hlist_head	*nat_bysource;
-	unsigned int		nat_htable_size;
-#endif
 };
 #endif
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 069912c..6877a39 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -37,6 +37,9 @@ static const struct nf_nat_l3proto __rcu *nf_nat_l3protos[NFPROTO_NUMPROTO]
 						__read_mostly;
 static const struct nf_nat_l4proto __rcu **nf_nat_l4protos[NFPROTO_NUMPROTO]
 						__read_mostly;
+
+static struct hlist_head *nf_nat_bysource __read_mostly;
+static unsigned int nf_nat_htable_size __read_mostly;
 static unsigned int nf_nat_hash_rnd __read_mostly;
 
 inline const struct nf_nat_l3proto *
@@ -128,7 +131,7 @@ hash_by_src(const struct net *n, const struct nf_conntrack_tuple *tuple)
 	hash = jhash2((u32 *)&tuple->src, sizeof(tuple->src) / sizeof(u32),
 		      tuple->dst.protonum ^ nf_nat_hash_rnd ^ net_hash_mix(n));
 
-	return reciprocal_scale(hash, n->ct.nat_htable_size);
+	return reciprocal_scale(hash, nf_nat_htable_size);
 }
 
 /* Is this tuple already taken? (not by us) */
@@ -198,9 +201,10 @@ find_appropriate_src(struct net *net,
 	const struct nf_conn_nat *nat;
 	const struct nf_conn *ct;
 
-	hlist_for_each_entry_rcu(nat, &net->ct.nat_bysource[h], bysource) {
+	hlist_for_each_entry_rcu(nat, &nf_nat_bysource[h], bysource) {
 		ct = nat->ct;
 		if (same_src(ct, tuple) &&
+		    net_eq(net, nf_ct_net(ct)) &&
 		    nf_ct_zone_equal(ct, zone, IP_CT_DIR_ORIGINAL)) {
 			/* Copy source part from reply tuple. */
 			nf_ct_invert_tuplepr(result,
@@ -433,7 +437,7 @@ nf_nat_setup_info(struct nf_conn *ct,
 		nat = nfct_nat(ct);
 		nat->ct = ct;
 		hlist_add_head_rcu(&nat->bysource,
-				   &net->ct.nat_bysource[srchash]);
+				   &nf_nat_bysource[srchash]);
 		spin_unlock_bh(&nf_nat_lock);
 	}
 
@@ -821,27 +825,14 @@ nfnetlink_parse_nat_setup(struct nf_conn *ct,
 }
 #endif
 
-static int __net_init nf_nat_net_init(struct net *net)
-{
-	/* Leave them the same for the moment. */
-	net->ct.nat_htable_size = nf_conntrack_htable_size;
-	net->ct.nat_bysource = nf_ct_alloc_hashtable(&net->ct.nat_htable_size, 0);
-	if (!net->ct.nat_bysource)
-		return -ENOMEM;
-	return 0;
-}
-
 static void __net_exit nf_nat_net_exit(struct net *net)
 {
 	struct nf_nat_proto_clean clean = {};
 
 	nf_ct_iterate_cleanup(net, nf_nat_proto_clean, &clean, 0, 0);
-	synchronize_rcu();
-	nf_ct_free_hashtable(net->ct.nat_bysource, net->ct.nat_htable_size);
 }
 
 static struct pernet_operations nf_nat_net_ops = {
-	.init = nf_nat_net_init,
 	.exit = nf_nat_net_exit,
 };
 
@@ -854,8 +845,16 @@ static int __init nf_nat_init(void)
 {
 	int ret;
 
+	/* Leave them the same for the moment. */
+	nf_nat_htable_size = nf_conntrack_htable_size;
+
+	nf_nat_bysource = nf_ct_alloc_hashtable(&nf_nat_htable_size, 0);
+	if (!nf_nat_bysource)
+		return -ENOMEM;
+
 	ret = nf_ct_extend_register(&nat_extend);
 	if (ret < 0) {
+		nf_ct_free_hashtable(nf_nat_bysource, nf_nat_htable_size);
 		printk(KERN_ERR "nf_nat_core: Unable to register extension\n");
 		return ret;
 	}
@@ -879,6 +878,7 @@ static int __init nf_nat_init(void)
 	return 0;
 
  cleanup_extend:
+	nf_ct_free_hashtable(nf_nat_bysource, nf_nat_htable_size);
 	nf_ct_extend_unregister(&nat_extend);
 	return ret;
 }
@@ -897,6 +897,7 @@ static void __exit nf_nat_cleanup(void)
 	for (i = 0; i < NFPROTO_NUMPROTO; i++)
 		kfree(nf_nat_l4protos[i]);
 	synchronize_net();
+	nf_ct_free_hashtable(nf_nat_bysource, nf_nat_htable_size);
 }
 
 MODULE_LICENSE("GPL");
-- 
2.1.4

