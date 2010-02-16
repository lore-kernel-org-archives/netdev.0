From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 25/62: ctnetlink: only assign helpers for matching protocols
Date: Tue, 16 Feb 2010 15:55:53 +0100 (MET)
Message-ID: <20100216145551.2796.97663.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52014 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932458Ab0BPOzz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:55:55 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 794e68716bab578ae8f8912dc934496d7c7abc90
Author: Patrick McHardy <kaber@trash.net>
Date:   Wed Feb 3 13:41:29 2010 +0100

    netfilter: ctnetlink: only assign helpers for matching protocols
    
    Make sure not to assign a helper for a different network or transport
    layer protocol to a connection.
    
    Additionally change expectation deletion by helper to compare the name
    directly - there might be multiple helper registrations using the same
    name, currently one of them is chosen in an unpredictable manner and
    only those expectations are removed.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index d015de9..86be7c4 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -40,7 +40,7 @@ struct nf_conntrack_helper {
 };
 
 extern struct nf_conntrack_helper *
-__nf_conntrack_helper_find_byname(const char *name);
+__nf_conntrack_helper_find(const char *name, u16 l3num, u8 protonum);
 
 extern int nf_conntrack_helper_register(struct nf_conntrack_helper *);
 extern void nf_conntrack_helper_unregister(struct nf_conntrack_helper *);
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 65c2a7b..c0e461f 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -65,7 +65,7 @@ __nf_ct_helper_find(const struct nf_conntrack_tuple *tuple)
 }
 
 struct nf_conntrack_helper *
-__nf_conntrack_helper_find_byname(const char *name)
+__nf_conntrack_helper_find(const char *name, u16 l3num, u8 protonum)
 {
 	struct nf_conntrack_helper *h;
 	struct hlist_node *n;
@@ -73,13 +73,15 @@ __nf_conntrack_helper_find_byname(const char *name)
 
 	for (i = 0; i < nf_ct_helper_hsize; i++) {
 		hlist_for_each_entry_rcu(h, n, &nf_ct_helper_hash[i], hnode) {
-			if (!strcmp(h->name, name))
+			if (!strcmp(h->name, name) &&
+			    h->tuple.src.l3num == l3num &&
+			    h->tuple.dst.protonum == protonum)
 				return h;
 		}
 	}
 	return NULL;
 }
-EXPORT_SYMBOL_GPL(__nf_conntrack_helper_find_byname);
+EXPORT_SYMBOL_GPL(__nf_conntrack_helper_find);
 
 struct nf_conn_help *nf_ct_helper_ext_add(struct nf_conn *ct, gfp_t gfp)
 {
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 79478df..16f86d6 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -1001,7 +1001,8 @@ ctnetlink_change_helper(struct nf_conn *ct, const struct nlattr * const cda[])
 		return 0;
 	}
 
-	helper = __nf_conntrack_helper_find_byname(helpname);
+	helper = __nf_conntrack_helper_find(helpname, nf_ct_l3num(ct),
+					    nf_ct_protonum(ct));
 	if (helper == NULL) {
 #ifdef CONFIG_MODULES
 		spin_unlock_bh(&nf_conntrack_lock);
@@ -1012,7 +1013,8 @@ ctnetlink_change_helper(struct nf_conn *ct, const struct nlattr * const cda[])
 		}
 
 		spin_lock_bh(&nf_conntrack_lock);
-		helper = __nf_conntrack_helper_find_byname(helpname);
+		helper = __nf_conntrack_helper_find(helpname, nf_ct_l3num(ct),
+						    nf_ct_protonum(ct));
 		if (helper)
 			return -EAGAIN;
 #endif
@@ -1211,7 +1213,8 @@ ctnetlink_create_conntrack(struct net *net,
  		if (err < 0)
 			goto err2;
 
-		helper = __nf_conntrack_helper_find_byname(helpname);
+		helper = __nf_conntrack_helper_find(helpname, nf_ct_l3num(ct),
+						    nf_ct_protonum(ct));
 		if (helper == NULL) {
 			rcu_read_unlock();
 #ifdef CONFIG_MODULES
@@ -1221,7 +1224,9 @@ ctnetlink_create_conntrack(struct net *net,
 			}
 
 			rcu_read_lock();
-			helper = __nf_conntrack_helper_find_byname(helpname);
+			helper = __nf_conntrack_helper_find(helpname,
+							    nf_ct_l3num(ct),
+							    nf_ct_protonum(ct));
 			if (helper) {
 				err = -EAGAIN;
 				goto err2;
@@ -1714,7 +1719,6 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 	struct net *net = sock_net(ctnl);
 	struct nf_conntrack_expect *exp;
 	struct nf_conntrack_tuple tuple;
-	struct nf_conntrack_helper *h;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	struct hlist_node *n, *next;
 	u_int8_t u3 = nfmsg->nfgen_family;
@@ -1751,18 +1755,13 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 
 		/* delete all expectations for this helper */
 		spin_lock_bh(&nf_conntrack_lock);
-		h = __nf_conntrack_helper_find_byname(name);
-		if (!h) {
-			spin_unlock_bh(&nf_conntrack_lock);
-			return -EOPNOTSUPP;
-		}
 		for (i = 0; i < nf_ct_expect_hsize; i++) {
 			hlist_for_each_entry_safe(exp, n, next,
 						  &net->ct.expect_hash[i],
 						  hnode) {
 				m_help = nfct_help(exp->master);
-				if (m_help->helper == h
-				    && del_timer(&exp->timeout)) {
+				if (!strcmp(m_help->helper->name, name) &&
+				    del_timer(&exp->timeout)) {
 					nf_ct_unlink_expect(exp);
 					nf_ct_expect_put(exp);
 				}
