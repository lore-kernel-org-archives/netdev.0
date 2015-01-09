From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 2/3] netlink: eliminate nl_sk_hash_lock
Date: Fri, 9 Jan 2015 16:23:37 +0800
Message-ID: <1420791818-22150-3-git-send-email-ying.xue@windriver.com>
References: <1420791818-22150-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:32872 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754085AbbAIIYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 03:24:08 -0500
In-Reply-To: <1420791818-22150-1-git-send-email-ying.xue@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As rhashtable_lookup_compare_insert() can guarantee the process
of search and insertion is atomic, it's safe to eliminate the
nl_sk_hash_lock. After this, object insertion or removal will
be protected with per bucket lock on write side while object
lookup is guarded with rcu read lock on read side.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Cc: Thomas Graf <tgraf@suug.ch>
---
 net/netlink/af_netlink.c |   43 ++++++++++++++++++++++---------------------
 net/netlink/af_netlink.h |    1 -
 net/netlink/diag.c       |   10 +++++-----
 3 files changed, 27 insertions(+), 27 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 298e1df..ac1daf3 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -98,7 +98,7 @@ static void netlink_skb_destructor(struct sk_buff *skb);
 
 /* nl_table locking explained:
  * Lookup and traversal are protected with an RCU read-side lock. Insertion
- * and removal are protected with nl_sk_hash_lock while using RCU list
+ * and removal are protected with per bucket lock while using RCU list
  * modification primitives and may run in parallel to RCU protected lookups.
  * Destruction of the Netlink socket may only occur *after* nl_table_lock has
  * been acquired * either during or after the socket has been removed from
@@ -110,10 +110,6 @@ static atomic_t nl_table_users = ATOMIC_INIT(0);
 
 #define nl_deref_protected(X) rcu_dereference_protected(X, lockdep_is_held(&nl_table_lock));
 
-/* Protects netlink socket hash table mutations */
-DEFINE_MUTEX(nl_sk_hash_lock);
-EXPORT_SYMBOL_GPL(nl_sk_hash_lock);
-
 static ATOMIC_NOTIFIER_HEAD(netlink_chain);
 
 static DEFINE_SPINLOCK(netlink_tap_lock);
@@ -998,6 +994,19 @@ static struct sock *__netlink_lookup(struct netlink_table *table, u32 portid,
 					 &netlink_compare, &arg);
 }
 
+static bool __netlink_insert(struct netlink_table *table, struct sock *sk,
+			     struct net *net)
+{
+	struct netlink_compare_arg arg = {
+		.net = net,
+		.portid = nlk_sk(sk)->portid,
+	};
+
+	return rhashtable_lookup_compare_insert(&table->hash,
+						&nlk_sk(sk)->node,
+						&netlink_compare, &arg);
+}
+
 static struct sock *netlink_lookup(struct net *net, int protocol, u32 portid)
 {
 	struct netlink_table *table = &nl_table[protocol];
@@ -1041,41 +1050,33 @@ netlink_update_listeners(struct sock *sk)
 static int netlink_insert(struct sock *sk, struct net *net, u32 portid)
 {
 	struct netlink_table *table = &nl_table[sk->sk_protocol];
-	int err = -EADDRINUSE;
-
-	mutex_lock(&nl_sk_hash_lock);
-	if (__netlink_lookup(table, portid, net))
-		goto err;
 
-	err = -EBUSY;
 	if (nlk_sk(sk)->portid)
-		goto err;
+		return -EBUSY;
 
-	err = -ENOMEM;
 	if (BITS_PER_LONG > 32 &&
 	    unlikely(atomic_read(&table->hash.nelems) >= UINT_MAX))
-		goto err;
+		return -ENOMEM;
 
 	nlk_sk(sk)->portid = portid;
 	sock_hold(sk);
-	rhashtable_insert(&table->hash, &nlk_sk(sk)->node);
-	err = 0;
-err:
-	mutex_unlock(&nl_sk_hash_lock);
-	return err;
+	if (!__netlink_insert(table, sk, net)) {
+		sock_put(sk);
+		return -EADDRINUSE;
+	}
+
+	return 0;
 }
 
 static void netlink_remove(struct sock *sk)
 {
 	struct netlink_table *table;
 
-	mutex_lock(&nl_sk_hash_lock);
 	table = &nl_table[sk->sk_protocol];
 	if (rhashtable_remove(&table->hash, &nlk_sk(sk)->node)) {
 		WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
 		__sock_put(sk);
 	}
-	mutex_unlock(&nl_sk_hash_lock);
 
 	netlink_table_grab();
 	if (nlk_sk(sk)->subscriptions) {
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index fd96fa7..7518375 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -74,6 +74,5 @@ struct netlink_table {
 
 extern struct netlink_table *nl_table;
 extern rwlock_t nl_table_lock;
-extern struct mutex nl_sk_hash_lock;
 
 #endif
diff --git a/net/netlink/diag.c b/net/netlink/diag.c
index fcca36d..bb59a7e 100644
--- a/net/netlink/diag.c
+++ b/net/netlink/diag.c
@@ -103,7 +103,7 @@ static int __netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
 {
 	struct netlink_table *tbl = &nl_table[protocol];
 	struct rhashtable *ht = &tbl->hash;
-	const struct bucket_table *htbl = rht_dereference(ht->tbl, ht);
+	const struct bucket_table *htbl = rht_dereference_rcu(ht->tbl, ht);
 	struct net *net = sock_net(skb->sk);
 	struct netlink_diag_req *req;
 	struct netlink_sock *nlsk;
@@ -115,7 +115,7 @@ static int __netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb,
 	for (i = 0; i < htbl->size; i++) {
 		struct rhash_head *pos;
 
-		rht_for_each_entry(nlsk, pos, htbl, i, node) {
+		rht_for_each_entry_rcu(nlsk, pos, htbl, i, node) {
 			sk = (struct sock *)nlsk;
 
 			if (!net_eq(sock_net(sk), net))
@@ -172,7 +172,7 @@ static int netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 	req = nlmsg_data(cb->nlh);
 
-	mutex_lock(&nl_sk_hash_lock);
+	rcu_read_lock();
 	read_lock(&nl_table_lock);
 
 	if (req->sdiag_protocol == NDIAG_PROTO_ALL) {
@@ -186,7 +186,7 @@ static int netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	} else {
 		if (req->sdiag_protocol >= MAX_LINKS) {
 			read_unlock(&nl_table_lock);
-			mutex_unlock(&nl_sk_hash_lock);
+			rcu_read_unlock();
 			return -ENOENT;
 		}
 
@@ -194,7 +194,7 @@ static int netlink_diag_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	}
 
 	read_unlock(&nl_table_lock);
-	mutex_unlock(&nl_sk_hash_lock);
+	rcu_read_unlock();
 
 	return skb->len;
 }
-- 
1.7.9.5
