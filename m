From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 30/33] netns nat: per-netns bysource hash
Date: Mon,  8 Sep 2008 07:03:07 +0400
Message-ID: <1220842990-30500-30-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index b286b84..ece1c92 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -39,6 +39,8 @@ struct netns_ipv4 {
 	struct xt_table		*arptable_filter;
 	struct xt_table		*iptable_security;
 	struct xt_table		*nat_table;
+	struct hlist_head	*nat_bysource;
+	int			nat_vmalloced;
 #endif
 
 	int sysctl_icmp_echo_ignore_all;
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 5d4a5b7..2ac9eaf 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -37,9 +37,6 @@ static struct nf_conntrack_l3proto *l3proto __read_mostly;
 
 /* Calculated at init based on memory size */
 static unsigned int nf_nat_htable_size __read_mostly;
-static int nf_nat_vmalloced;
-
-static struct hlist_head *bysource __read_mostly;
 
 #define MAX_IP_NAT_PROTO 256
 static const struct nf_nat_protocol *nf_nat_protos[MAX_IP_NAT_PROTO]
@@ -145,7 +142,8 @@ same_src(const struct nf_conn *ct,
 
 /* Only called for SRC manip */
 static int
-find_appropriate_src(const struct nf_conntrack_tuple *tuple,
+find_appropriate_src(struct net *net,
+		     const struct nf_conntrack_tuple *tuple,
 		     struct nf_conntrack_tuple *result,
 		     const struct nf_nat_range *range)
 {
@@ -155,7 +153,7 @@ find_appropriate_src(const struct nf_conntrack_tuple *tuple,
 	const struct hlist_node *n;
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(nat, n, &bysource[h], bysource) {
+	hlist_for_each_entry_rcu(nat, n, &net->ipv4.nat_bysource[h], bysource) {
 		ct = nat->ct;
 		if (same_src(ct, tuple)) {
 			/* Copy source part from reply tuple. */
@@ -231,6 +229,7 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
 		 struct nf_conn *ct,
 		 enum nf_nat_manip_type maniptype)
 {
+	struct net *net = nf_ct_net(ct);
 	const struct nf_nat_protocol *proto;
 
 	/* 1) If this srcip/proto/src-proto-part is currently mapped,
@@ -242,7 +241,7 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
 	   manips not an issue.  */
 	if (maniptype == IP_NAT_MANIP_SRC &&
 	    !(range->flags & IP_NAT_RANGE_PROTO_RANDOM)) {
-		if (find_appropriate_src(orig_tuple, tuple, range)) {
+		if (find_appropriate_src(net, orig_tuple, tuple, range)) {
 			pr_debug("get_unique_tuple: Found current src map\n");
 			if (!nf_nat_used_tuple(tuple, ct))
 				return;
@@ -283,6 +282,7 @@ nf_nat_setup_info(struct nf_conn *ct,
 		  const struct nf_nat_range *range,
 		  enum nf_nat_manip_type maniptype)
 {
+	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_tuple curr_tuple, new_tuple;
 	struct nf_conn_nat *nat;
 	int have_to_hash = !(ct->status & IPS_NAT_DONE_MASK);
@@ -334,7 +334,8 @@ nf_nat_setup_info(struct nf_conn *ct,
 		/* nf_conntrack_alter_reply might re-allocate exntension aera */
 		nat = nfct_nat(ct);
 		nat->ct = ct;
-		hlist_add_head_rcu(&nat->bysource, &bysource[srchash]);
+		hlist_add_head_rcu(&nat->bysource,
+				   &net->ipv4.nat_bysource[srchash]);
 		spin_unlock_bh(&nf_nat_lock);
 	}
 
@@ -583,6 +584,40 @@ static struct nf_ct_ext_type nat_extend __read_mostly = {
 	.flags		= NF_CT_EXT_F_PREALLOC,
 };
 
+static int __net_init nf_nat_net_init(struct net *net)
+{
+	net->ipv4.nat_bysource = nf_ct_alloc_hashtable(&nf_nat_htable_size,
+						      &net->ipv4.nat_vmalloced);
+	if (!net->ipv4.nat_bysource)
+		return -ENOMEM;
+	return 0;
+}
+
+/* Clear NAT section of all conntracks, in case we're loaded again. */
+static int clean_nat(struct nf_conn *i, void *data)
+{
+	struct nf_conn_nat *nat = nfct_nat(i);
+
+	if (!nat)
+		return 0;
+	memset(nat, 0, sizeof(*nat));
+	i->status &= ~(IPS_NAT_MASK | IPS_NAT_DONE_MASK | IPS_SEQ_ADJUST);
+	return 0;
+}
+
+static void __net_exit nf_nat_net_exit(struct net *net)
+{
+	nf_ct_iterate_cleanup(net, &clean_nat, NULL);
+	synchronize_rcu();
+	nf_ct_free_hashtable(net->ipv4.nat_bysource, net->ipv4.nat_vmalloced,
+			     nf_nat_htable_size);
+}
+
+static struct pernet_operations nf_nat_net_ops = {
+	.init = nf_nat_net_init,
+	.exit = nf_nat_net_exit,
+};
+
 static int __init nf_nat_init(void)
 {
 	size_t i;
@@ -599,12 +634,9 @@ static int __init nf_nat_init(void)
 	/* Leave them the same for the moment. */
 	nf_nat_htable_size = nf_conntrack_htable_size;
 
-	bysource = nf_ct_alloc_hashtable(&nf_nat_htable_size,
-					 &nf_nat_vmalloced);
-	if (!bysource) {
-		ret = -ENOMEM;
+	ret = register_pernet_subsys(&nf_nat_net_ops);
+	if (ret < 0)
 		goto cleanup_extend;
-	}
 
 	/* Sew in builtin protocols. */
 	spin_lock_bh(&nf_nat_lock);
@@ -629,23 +661,9 @@ static int __init nf_nat_init(void)
 	return ret;
 }
 
-/* Clear NAT section of all conntracks, in case we're loaded again. */
-static int clean_nat(struct nf_conn *i, void *data)
-{
-	struct nf_conn_nat *nat = nfct_nat(i);
-
-	if (!nat)
-		return 0;
-	memset(nat, 0, sizeof(*nat));
-	i->status &= ~(IPS_NAT_MASK | IPS_NAT_DONE_MASK | IPS_SEQ_ADJUST);
-	return 0;
-}
-
 static void __exit nf_nat_cleanup(void)
 {
-	nf_ct_iterate_cleanup(&init_net, &clean_nat, NULL);
-	synchronize_rcu();
-	nf_ct_free_hashtable(bysource, nf_nat_vmalloced, nf_nat_htable_size);
+	unregister_pernet_subsys(&nf_nat_net_ops);
 	nf_ct_l3proto_put(l3proto);
 	nf_ct_extend_unregister(&nat_extend);
 	rcu_assign_pointer(nf_nat_seq_adjust_hook, NULL);
