From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 34/38] netfilter: connlimit: use kmem_cache for conn objects
Date: Mon, 17 Mar 2014 13:42:54 +0100
Message-ID: <1395060178-11833-35-git-send-email-pablo@netfilter.org>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Florian Westphal <fw@strlen.de>

We might allocate thousands of these (one object per connection).
Use distinct kmem cache to permit simplte tracking on how many
objects are currently used by the connlimit match via the sysfs.

Reviewed-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/xt_connlimit.c |   24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 0220d40..a8eaabb 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -44,6 +44,7 @@ struct xt_connlimit_data {
 };
 
 static u_int32_t connlimit_rnd __read_mostly;
+static struct kmem_cache *connlimit_conn_cachep __read_mostly;
 
 static inline unsigned int connlimit_iphash(__be32 addr)
 {
@@ -113,7 +114,7 @@ static int count_hlist(struct net *net,
 						 &conn->tuple);
 		if (found == NULL) {
 			hlist_del(&conn->node);
-			kfree(conn);
+			kmem_cache_free(connlimit_conn_cachep, conn);
 			continue;
 		}
 
@@ -133,7 +134,7 @@ static int count_hlist(struct net *net,
 			 */
 			nf_ct_put(found_ct);
 			hlist_del(&conn->node);
-			kfree(conn);
+			kmem_cache_free(connlimit_conn_cachep, conn);
 			continue;
 		}
 
@@ -152,7 +153,9 @@ static bool add_hlist(struct hlist_head *head,
 		      const struct nf_conntrack_tuple *tuple,
 		      const union nf_inet_addr *addr)
 {
-	struct xt_connlimit_conn *conn = kmalloc(sizeof(*conn), GFP_ATOMIC);
+	struct xt_connlimit_conn *conn;
+
+	conn = kmem_cache_alloc(connlimit_conn_cachep, GFP_ATOMIC);
 	if (conn == NULL)
 		return false;
 	conn->tuple = *tuple;
@@ -285,7 +288,7 @@ static void connlimit_mt_destroy(const struct xt_mtdtor_param *par)
 	for (i = 0; i < ARRAY_SIZE(info->data->iphash); ++i) {
 		hlist_for_each_entry_safe(conn, n, &hash[i], node) {
 			hlist_del(&conn->node);
-			kfree(conn);
+			kmem_cache_free(connlimit_conn_cachep, conn);
 		}
 	}
 
@@ -305,12 +308,23 @@ static struct xt_match connlimit_mt_reg __read_mostly = {
 
 static int __init connlimit_mt_init(void)
 {
-	return xt_register_match(&connlimit_mt_reg);
+	int ret;
+	connlimit_conn_cachep = kmem_cache_create("xt_connlimit_conn",
+					   sizeof(struct xt_connlimit_conn),
+					   0, 0, NULL);
+	if (!connlimit_conn_cachep)
+		return -ENOMEM;
+
+	ret = xt_register_match(&connlimit_mt_reg);
+	if (ret != 0)
+		kmem_cache_destroy(connlimit_conn_cachep);
+	return ret;
 }
 
 static void __exit connlimit_mt_exit(void)
 {
 	xt_unregister_match(&connlimit_mt_reg);
+	kmem_cache_destroy(connlimit_conn_cachep);
 }
 
 module_init(connlimit_mt_init);
-- 
1.7.10.4

