From: adobriyan@gmail.com
Subject: [PATCH 35/38] netns nat: per-netns bysource hash
Date: Fri, 22 Aug 2008 02:10:12 +0400
Message-ID: <20080821221012.GI31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: kaber@trash.net, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.191]:3723 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758083AbYHUWIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 18:08:47 -0400
Received: by gv-out-0910.google.com with SMTP id e6so78595gvc.37
        for <netdev@vger.kernel.org>; Thu, 21 Aug 2008 15:08:47 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/net/netns/ipv4.h         |    2 +
 net/ipv4/netfilter/nf_nat_core.c |   71 +++++++++++++++++++++++----------------
 2 files changed, 45 insertions(+), 28 deletions(-)

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
@@ -242,7 +240,7 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
 	   manips not an issue.  */
 	if (maniptype == IP_NAT_MANIP_SRC &&
 	    !(range->flags & IP_NAT_RANGE_PROTO_RANDOM)) {
-		if (find_appropriate_src(orig_tuple, tuple, range)) {
+		if (find_appropriate_src(nf_ct_net(ct), orig_tuple, tuple, range)) {
 			pr_debug("get_unique_tuple: Found current src map\n");
 			if (!nf_nat_used_tuple(tuple, ct))
 				return;
@@ -334,7 +332,8 @@ nf_nat_setup_info(struct nf_conn *ct,
 		/* nf_conntrack_alter_reply might re-allocate exntension aera */
 		nat = nfct_nat(ct);
 		nat->ct = ct;
-		hlist_add_head_rcu(&nat->bysource, &bysource[srchash]);
+		hlist_add_head_rcu(&nat->bysource,
+				   &nf_ct_net(ct)->ipv4.nat_bysource[srchash]);
 		spin_unlock_bh(&nf_nat_lock);
 	}
 
@@ -583,6 +582,40 @@ static struct nf_ct_ext_type nat_extend __read_mostly = {
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
@@ -599,12 +632,9 @@ static int __init nf_nat_init(void)
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
@@ -629,23 +659,9 @@ static int __init nf_nat_init(void)
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
-- 
1.5.6.3


