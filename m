From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/5 net-next] rhashtable: Disable automatic shrinking by default
Date: Tue, 24 Mar 2015 14:18:19 +0100
Message-ID: <f6ed6e9fe9434e55475b777281f6fe67eff0e07d.1427202823.git.tgraf@suug.ch>
References: <cover.1427202823.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34717 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752667AbbCXNSb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 09:18:31 -0400
In-Reply-To: <cover.1427202823.git.tgraf@suug.ch>
In-Reply-To: <cover.1427202823.git.tgraf@suug.ch>
References: <cover.1427202823.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using rhashtable_remove_fast() will no longer automatically
shrink the table. Users need to opt-in to shrinking by
explicitly using rhashtable_remove_and_shrink()

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/linux/rhashtable.h | 27 +++++++++++++++++++++------
 lib/test_rhashtable.c      |  2 +-
 net/netfilter/nft_hash.c   |  2 +-
 net/netlink/af_netlink.c   |  4 ++--
 net/tipc/socket.c          |  3 ++-
 5 files changed, 27 insertions(+), 11 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 0e1f975..d0ca452 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -2,7 +2,7 @@
  * Resizable, Scalable, Concurrent Hash Table
  *
  * Copyright (c) 2015 Herbert Xu <herbert@gondor.apana.org.au>
- * Copyright (c) 2014 Thomas Graf <tgraf@suug.ch>
+ * Copyright (c) 2014-2015 Thomas Graf <tgraf@suug.ch>
  * Copyright (c) 2008-2014 Patrick McHardy <kaber@trash.net>
  *
  * Code partially derived from nft_hash
@@ -780,14 +780,29 @@ static inline int rhashtable_remove_fast(
 	       (tbl = rht_dereference_rcu(tbl->future_tbl, ht)))
 		;
 
-	if (err)
-		goto out;
+	if (likely(!err))
+		atomic_dec(&ht->nelems);
+
+	rcu_read_unlock();
 
-	atomic_dec(&ht->nelems);
-	if (rht_shrink_below_30(ht, tbl))
+	return err;
+}
+
+static inline int rhashtable_remove_and_shrink(
+	struct rhashtable *ht, struct rhash_head *obj,
+	const struct rhashtable_params params)
+{
+	struct bucket_table *tbl;
+	int err;
+
+	rcu_read_lock();
+
+	tbl = rht_dereference_rcu(ht->tbl, ht);
+
+	err = rhashtable_remove_fast(ht, obj, params);
+	if (!err && rht_shrink_below_30(ht, tbl))
 		schedule_work(&ht->run_work);
 
-out:
 	rcu_read_unlock();
 
 	return err;
diff --git a/lib/test_rhashtable.c b/lib/test_rhashtable.c
index a42a0d4..fe6d4a9 100644
--- a/lib/test_rhashtable.c
+++ b/lib/test_rhashtable.c
@@ -166,7 +166,7 @@ static int __init test_rhashtable(struct rhashtable *ht)
 		obj = rhashtable_lookup_fast(ht, &key, test_rht_params);
 		BUG_ON(!obj);
 
-		rhashtable_remove_fast(ht, &obj->node, test_rht_params);
+		rhashtable_remove_and_shrink(ht, &obj->node, test_rht_params);
 		kfree(obj);
 	}
 
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index ad39669..2986f1d 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -89,7 +89,7 @@ static void nft_hash_remove(const struct nft_set *set,
 {
 	struct rhashtable *priv = nft_set_priv(set);
 
-	rhashtable_remove_fast(priv, elem->cookie, nft_hash_params);
+	rhashtable_remove_and_shrink(priv, elem->cookie, nft_hash_params);
 	synchronize_rcu();
 	kfree(elem->cookie);
 }
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index e2f7f28..b9d3215 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1094,8 +1094,8 @@ static void netlink_remove(struct sock *sk)
 	struct netlink_table *table;
 
 	table = &nl_table[sk->sk_protocol];
-	if (!rhashtable_remove_fast(&table->hash, &nlk_sk(sk)->node,
-				    netlink_rhashtable_params)) {
+	if (!rhashtable_remove_and_shrink(&table->hash, &nlk_sk(sk)->node,
+					  netlink_rhashtable_params)) {
 		WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
 		__sock_put(sk);
 	}
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 6dd5bd9..33338b4 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2282,7 +2282,8 @@ static void tipc_sk_remove(struct tipc_sock *tsk)
 	struct sock *sk = &tsk->sk;
 	struct tipc_net *tn = net_generic(sock_net(sk), tipc_net_id);
 
-	if (!rhashtable_remove_fast(&tn->sk_rht, &tsk->node, tsk_rht_params)) {
+	if (!rhashtable_remove_and_shrink(&tn->sk_rht, &tsk->node,
+					  tsk_rht_params)) {
 		WARN_ON(atomic_read(&sk->sk_refcnt) == 1);
 		__sock_put(sk);
 	}
-- 
1.9.3
