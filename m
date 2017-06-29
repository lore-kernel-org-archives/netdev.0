From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 07/29] netfilter: conntrack: add nf_ct_iterate_destroy
Date: Fri, 30 Jun 2017 00:53:05 +0200
Message-ID: <1498776807-11124-8-git-send-email-pablo@netfilter.org>
References: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1498776807-11124-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

sledgehammer to be used on module unload (to remove affected conntracks
from all namespaces).

It will also flag all unconfirmed conntracks as dying, i.e. they will
not be committed to main table.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack.h |  4 ++
 net/netfilter/nf_conntrack_core.c    | 87 ++++++++++++++++++++++++++++++------
 2 files changed, 78 insertions(+), 13 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index f21180ea4558..48407569585d 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -229,6 +229,10 @@ void nf_ct_iterate_cleanup_net(struct net *net,
 			       int (*iter)(struct nf_conn *i, void *data),
 			       void *data, u32 portid, int report);
 
+/* also set unconfirmed conntracks as dying. Only use in module exit path. */
+void nf_ct_iterate_destroy(int (*iter)(struct nf_conn *i, void *data),
+			   void *data);
+
 struct nf_conntrack_zone;
 
 void nf_conntrack_free(struct nf_conn *ct);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 08733685d732..7ecee79c78b8 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -1586,7 +1586,7 @@ static void nf_conntrack_attach(struct sk_buff *nskb, const struct sk_buff *skb)
 
 /* Bring out ya dead! */
 static struct nf_conn *
-get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
+get_next_corpse(int (*iter)(struct nf_conn *i, void *data),
 		void *data, unsigned int *bucket)
 {
 	struct nf_conntrack_tuple_hash *h;
@@ -1603,8 +1603,7 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 				if (NF_CT_DIRECTION(h) != IP_CT_DIR_ORIGINAL)
 					continue;
 				ct = nf_ct_tuplehash_to_ctrack(h);
-				if (net_eq(nf_ct_net(ct), net) &&
-				    iter(ct, data))
+				if (iter(ct, data))
 					goto found;
 			}
 		}
@@ -1621,6 +1620,39 @@ get_next_corpse(struct net *net, int (*iter)(struct nf_conn *i, void *data),
 	return ct;
 }
 
+static void nf_ct_iterate_cleanup(int (*iter)(struct nf_conn *i, void *data),
+				  void *data, u32 portid, int report)
+{
+	struct nf_conn *ct;
+	unsigned int bucket = 0;
+
+	might_sleep();
+
+	while ((ct = get_next_corpse(iter, data, &bucket)) != NULL) {
+		/* Time to push up daises... */
+
+		nf_ct_delete(ct, portid, report);
+		nf_ct_put(ct);
+		cond_resched();
+	}
+}
+
+struct iter_data {
+	int (*iter)(struct nf_conn *i, void *data);
+	void *data;
+	struct net *net;
+};
+
+static int iter_net_only(struct nf_conn *i, void *data)
+{
+	struct iter_data *d = data;
+
+	if (!net_eq(d->net, nf_ct_net(i)))
+		return 0;
+
+	return d->iter(i, d->data);
+}
+
 static void
 __nf_ct_unconfirmed_destroy(struct net *net)
 {
@@ -1653,8 +1685,7 @@ void nf_ct_iterate_cleanup_net(struct net *net,
 			       int (*iter)(struct nf_conn *i, void *data),
 			       void *data, u32 portid, int report)
 {
-	struct nf_conn *ct;
-	unsigned int bucket = 0;
+	struct iter_data d;
 
 	might_sleep();
 
@@ -1663,21 +1694,51 @@ void nf_ct_iterate_cleanup_net(struct net *net,
 
 	__nf_ct_unconfirmed_destroy(net);
 
+	d.iter = iter;
+	d.data = data;
+	d.net = net;
+
 	synchronize_net();
 
-	while ((ct = get_next_corpse(net, iter, data, &bucket)) != NULL) {
-		/* Time to push up daises... */
+	nf_ct_iterate_cleanup(iter_net_only, &d, portid, report);
+}
+EXPORT_SYMBOL_GPL(nf_ct_iterate_cleanup_net);
 
-		nf_ct_delete(ct, portid, report);
-		nf_ct_put(ct);
-		cond_resched();
+/**
+ * nf_ct_iterate_destroy - destroy unconfirmed conntracks and iterate table
+ * @iter: callback to invoke for each conntrack
+ * @data: data to pass to @iter
+ *
+ * Like nf_ct_iterate_cleanup, but first marks conntracks on the
+ * unconfirmed list as dying (so they will not be inserted into
+ * main table).
+ */
+void
+nf_ct_iterate_destroy(int (*iter)(struct nf_conn *i, void *data), void *data)
+{
+	struct net *net;
+
+	rtnl_lock();
+	for_each_net(net) {
+		if (atomic_read(&net->ct.count) == 0)
+			continue;
+		__nf_ct_unconfirmed_destroy(net);
 	}
+	rtnl_unlock();
+
+	/* a conntrack could have been unlinked from unconfirmed list
+	 * before we grabbed pcpu lock in __nf_ct_unconfirmed_destroy().
+	 * This makes sure its inserted into conntrack table.
+	 */
+	synchronize_net();
+
+	nf_ct_iterate_cleanup(iter, data, 0, 0);
 }
-EXPORT_SYMBOL_GPL(nf_ct_iterate_cleanup_net);
+EXPORT_SYMBOL_GPL(nf_ct_iterate_destroy);
 
 static int kill_all(struct nf_conn *i, void *data)
 {
-	return 1;
+	return net_eq(nf_ct_net(i), data);
 }
 
 void nf_ct_free_hashtable(void *hash, unsigned int size)
@@ -1742,7 +1803,7 @@ void nf_conntrack_cleanup_net_list(struct list_head *net_exit_list)
 i_see_dead_people:
 	busy = 0;
 	list_for_each_entry(net, net_exit_list, exit_list) {
-		nf_ct_iterate_cleanup_net(net, kill_all, NULL, 0, 0);
+		nf_ct_iterate_cleanup(kill_all, net, 0, 0);
 		if (atomic_read(&net->ct.count) != 0)
 			busy = 1;
 	}
-- 
2.1.4

