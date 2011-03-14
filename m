From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH 3/4] netfilter: xt_connlimit: use hlist instead
Date: Mon, 14 Mar 2011 14:50:13 +0800
Message-ID: <1300085414-27275-3-git-send-email-xiaosuo@gmail.com>
References: <1300085414-27275-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1300085414-27275-1-git-send-email-xiaosuo@gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The header of hlist is smaller than list.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
---
 net/netfilter/xt_connlimit.c |   28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index ade2a80..da56d6e 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -33,14 +33,14 @@
 
 /* we will save the tuples of all connections we care about */
 struct xt_connlimit_conn {
-	struct list_head		list;
+	struct hlist_node		node;
 	struct nf_conntrack_tuple	tuple;
 	union nf_inet_addr		addr;
 };
 
 struct xt_connlimit_data {
-	struct list_head iphash[256];
-	spinlock_t lock;
+	struct hlist_head	iphash[256];
+	spinlock_t		lock;
 };
 
 static u_int32_t connlimit_rnd __read_mostly;
@@ -102,9 +102,9 @@ static int count_them(struct net *net,
 {
 	const struct nf_conntrack_tuple_hash *found;
 	struct xt_connlimit_conn *conn;
-	struct xt_connlimit_conn *tmp;
+	struct hlist_node *pos, *n;
 	struct nf_conn *found_ct;
-	struct list_head *hash;
+	struct hlist_head *hash;
 	bool addit = true;
 	int matches = 0;
 
@@ -116,7 +116,7 @@ static int count_them(struct net *net,
 	rcu_read_lock();
 
 	/* check the saved connections */
-	list_for_each_entry_safe(conn, tmp, hash, list) {
+	hlist_for_each_entry_safe(conn, pos, n, hash, node) {
 		found    = nf_conntrack_find_get(net, NF_CT_DEFAULT_ZONE,
 						 &conn->tuple);
 		found_ct = NULL;
@@ -136,7 +136,7 @@ static int count_them(struct net *net,
 
 		if (found == NULL) {
 			/* this one is gone */
-			list_del(&conn->list);
+			hlist_del(&conn->node);
 			kfree(conn);
 			continue;
 		}
@@ -147,7 +147,7 @@ static int count_them(struct net *net,
 			 * closed already -> ditch it
 			 */
 			nf_ct_put(found_ct);
-			list_del(&conn->list);
+			hlist_del(&conn->node);
 			kfree(conn);
 			continue;
 		}
@@ -167,7 +167,7 @@ static int count_them(struct net *net,
 			return -ENOMEM;
 		conn->tuple = *tuple;
 		conn->addr = *addr;
-		list_add(&conn->list, hash);
+		hlist_add_head(&conn->node, hash);
 		++matches;
 	}
 
@@ -246,7 +246,7 @@ static int connlimit_mt_check(const struct xt_mtchk_param *par)
 
 	spin_lock_init(&info->data->lock);
 	for (i = 0; i < ARRAY_SIZE(info->data->iphash); ++i)
-		INIT_LIST_HEAD(&info->data->iphash[i]);
+		INIT_HLIST_HEAD(&info->data->iphash[i]);
 
 	return 0;
 }
@@ -255,15 +255,15 @@ static void connlimit_mt_destroy(const struct xt_mtdtor_param *par)
 {
 	const struct xt_connlimit_info *info = par->matchinfo;
 	struct xt_connlimit_conn *conn;
-	struct xt_connlimit_conn *tmp;
-	struct list_head *hash = info->data->iphash;
+	struct hlist_node *pos, *n;
+	struct hlist_head *hash = info->data->iphash;
 	unsigned int i;
 
 	nf_ct_l3proto_module_put(par->family);
 
 	for (i = 0; i < ARRAY_SIZE(info->data->iphash); ++i) {
-		list_for_each_entry_safe(conn, tmp, &hash[i], list) {
-			list_del(&conn->list);
+		hlist_for_each_entry_safe(conn, pos, n, &hash[i], node) {
+			hlist_del(&conn->node);
 			kfree(conn);
 		}
 	}
