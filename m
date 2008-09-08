From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 13/33] netns ct: unregister helper in every netns
Date: Mon,  8 Sep 2008 07:02:50 +0400
Message-ID: <1220842990-30500-13-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/net/netfilter/nf_conntrack_helper.c b/net/netfilter/nf_conntrack_helper.c
index 920e778..9c06b9f 100644
--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -123,29 +123,18 @@ int nf_conntrack_helper_register(struct nf_conntrack_helper *me)
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_helper_register);
 
-void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
+static void __nf_conntrack_helper_unregister(struct nf_conntrack_helper *me,
+					     struct net *net)
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conntrack_expect *exp;
 	const struct hlist_node *n, *next;
 	unsigned int i;
 
-	mutex_lock(&nf_ct_helper_mutex);
-	hlist_del_rcu(&me->hnode);
-	nf_ct_helper_count--;
-	mutex_unlock(&nf_ct_helper_mutex);
-
-	/* Make sure every nothing is still using the helper unless its a
-	 * connection in the hash.
-	 */
-	synchronize_rcu();
-
-	spin_lock_bh(&nf_conntrack_lock);
-
 	/* Get rid of expectations */
 	for (i = 0; i < nf_ct_expect_hsize; i++) {
 		hlist_for_each_entry_safe(exp, n, next,
-					  &init_net.ct.expect_hash[i], hnode) {
+					  &net->ct.expect_hash[i], hnode) {
 			struct nf_conn_help *help = nfct_help(exp->master);
 			if ((help->helper == me || exp->helper == me) &&
 			    del_timer(&exp->timeout)) {
@@ -156,12 +145,31 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
 	}
 
 	/* Get rid of expecteds, set helpers to NULL. */
-	hlist_for_each_entry(h, n, &init_net.ct.unconfirmed, hnode)
+	hlist_for_each_entry(h, n, &net->ct.unconfirmed, hnode)
 		unhelp(h, me);
 	for (i = 0; i < nf_conntrack_htable_size; i++) {
-		hlist_for_each_entry(h, n, &init_net.ct.hash[i], hnode)
+		hlist_for_each_entry(h, n, &net->ct.hash[i], hnode)
 			unhelp(h, me);
 	}
+}
+
+void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
+{
+	struct net *net;
+
+	mutex_lock(&nf_ct_helper_mutex);
+	hlist_del_rcu(&me->hnode);
+	nf_ct_helper_count--;
+	mutex_unlock(&nf_ct_helper_mutex);
+
+	/* Make sure every nothing is still using the helper unless its a
+	 * connection in the hash.
+	 */
+	synchronize_rcu();
+
+	spin_lock_bh(&nf_conntrack_lock);
+	for_each_net(net)
+		__nf_conntrack_helper_unregister(me, net);
 	spin_unlock_bh(&nf_conntrack_lock);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_helper_unregister);
