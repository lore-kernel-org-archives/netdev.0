From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/07: conntrack: move helper destruction to nf_ct_helper_destroy()
Date: Sat, 13 Jun 2009 15:09:39 +0200 (MEST)
Message-ID: <20090613130939.2112.70009.sendpatchset@x2.localnet>
References: <20090613130934.2112.65299.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:37052 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754217AbZFMNJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2009 09:09:37 -0400
In-Reply-To: <20090613130934.2112.65299.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 9858a3ae1d4b390fbaa9c30b83cb66d861b76294
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Sat Jun 13 12:28:22 2009 +0200

    netfilter: conntrack: move helper destruction to nf_ct_helper_destroy()
    
    This patch moves the helper destruction to a function that lives
    in nf_conntrack_helper.c. This new function is used in the patch
    to add ctnetlink reliable event delivery.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack_helper.h b/include/net/netfilter/nf_conntrack_helper.h
index ee2a4b3..1b70680 100644
--- a/include/net/netfilter/nf_conntrack_helper.h
+++ b/include/net/netfilter/nf_conntrack_helper.h
@@ -50,6 +50,8 @@ extern struct nf_conn_help *nf_ct_helper_ext_add(struct nf_conn *ct, gfp_t gfp);
 
 extern int __nf_ct_try_assign_helper(struct nf_conn *ct, gfp_t flags);
 
+extern void nf_ct_helper_destroy(struct nf_conn *ct);
+
 static inline struct nf_conn_help *nfct_help(const struct nf_conn *ct)
 {
 	return nf_ct_ext_find(ct, NF_CT_EXT_HELPER);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index bcacbb5..14235b1 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -224,17 +224,8 @@ static void death_by_timeout(unsigned long ul_conntrack)
 {
 	struct nf_conn *ct = (void *)ul_conntrack;
 	struct net *net = nf_ct_net(ct);
-	struct nf_conn_help *help = nfct_help(ct);
-	struct nf_conntrack_helper *helper;
-
-	if (help) {
-		rcu_read_lock();
-		helper = rcu_dereference(help->helper);
-		if (helper && helper->destroy)
-			helper->destroy(ct);
-		rcu_read_unlock();
-	}
 
+	nf_ct_helper_destroy(ct);
 	spin_lock_bh(&nf_conntrack_lock);
 	/* Inside lock so preempt is disabled on module removal path.
 	 * Otherwise we can get spurious warnings. */
diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 0fa5a42..65c2a7b 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -136,6 +136,20 @@ static inline int unhelp(struct nf_conntrack_tuple_hash *i,
 	return 0;
 }
 
+void nf_ct_helper_destroy(struct nf_conn *ct)
+{
+	struct nf_conn_help *help = nfct_help(ct);
+	struct nf_conntrack_helper *helper;
+
+	if (help) {
+		rcu_read_lock();
+		helper = rcu_dereference(help->helper);
+		if (helper && helper->destroy)
+			helper->destroy(ct);
+		rcu_read_unlock();
+	}
+}
+
 int nf_conntrack_helper_register(struct nf_conntrack_helper *me)
 {
 	unsigned int h = helper_hash(&me->tuple);
