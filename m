From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 16/25] netns ct: undo helper in all netns
Date: Sun, 22 Jun 2008 05:14:28 +0400
Message-ID: <20080622011428.GQ5392@martell.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	den@openvz.org, xemul@openvz.org, ebiederm@xmission.com,
	benjamin.thery@bull.net, dlezcano@fr.ibm.com
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When conntrack helper is unregistered, unhelp in every netns.
This for sure needs proper locking, but haven't looked closely.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 net/netfilter/nf_conntrack_helper.c |   40 +++++++++++++++++++++---------------
 1 file changed, 24 insertions(+), 16 deletions(-)

--- a/net/netfilter/nf_conntrack_helper.c
+++ b/net/netfilter/nf_conntrack_helper.c
@@ -122,29 +122,18 @@ int nf_conntrack_helper_register(struct nf_conntrack_helper *me)
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
@@ -155,12 +144,31 @@ void nf_conntrack_helper_unregister(struct nf_conntrack_helper *me)
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
-- 
1.5.4.5


