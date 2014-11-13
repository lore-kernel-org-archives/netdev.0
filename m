From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/4] rhashtable: Add parent argument to mutex_is_held
Date: Thu, 13 Nov 2014 18:11:22 +0800
Message-ID: <E1XorN4-0000zn-0H@gondolin.me.apana.org.au>
References: <20141113101025.GA3728@gondor.apana.org.au>
To: netdev@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:54080 "EHLO
	helcar.apana.org.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932358AbaKMKL0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Nov 2014 05:11:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently mutex_is_held can only test locks in the that are global
since it takes no arguments.  This prevents rhashtable from being
used in places where locks are lock, e.g., per-namespace locks.

This patch adds a parent field to mutex_is_held and rhashtable_params
so that local locks can be used (and tested).

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/rhashtable.h |    3 ++-
 lib/rhashtable.c           |    4 ++--
 net/netfilter/nft_hash.c   |    2 +-
 net/netlink/af_netlink.c   |    2 +-
 4 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 96ce8ce..473e26b 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -66,7 +66,8 @@ struct rhashtable_params {
 	bool			(*shrink_decision)(const struct rhashtable *ht,
 						   size_t new_size);
 #ifdef CONFIG_PROVE_LOCKING
-	int			(*mutex_is_held)(void);
+	int			(*mutex_is_held)(void *parent);
+	void			*parent;
 #endif
 };
 
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 548bb29..6acc4ce 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -32,7 +32,7 @@
 #ifdef CONFIG_PROVE_LOCKING
 int lockdep_rht_mutex_is_held(const struct rhashtable *ht)
 {
-	return ht->p.mutex_is_held();
+	return ht->p.mutex_is_held(ht->p.parent);
 }
 EXPORT_SYMBOL_GPL(lockdep_rht_mutex_is_held);
 #endif
@@ -618,7 +618,7 @@ EXPORT_SYMBOL_GPL(rhashtable_destroy);
 #define TEST_NEXPANDS	4
 
 #ifdef CONFIG_PROVE_LOCKING
-static int test_mutex_is_held(void)
+static int test_mutex_is_held(void *parent)
 {
 	return 1;
 }
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index b86305c..3f75aaa 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -154,7 +154,7 @@ static unsigned int nft_hash_privsize(const struct nlattr * const nla[])
 }
 
 #ifdef CONFIG_PROVE_LOCKING
-static int lockdep_nfnl_lock_is_held(void)
+static int lockdep_nfnl_lock_is_held(void *parent)
 {
 	return lockdep_nfnl_is_held(NFNL_SUBSYS_NFTABLES);
 }
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 53b8ea7..9e0628c 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -115,7 +115,7 @@ DEFINE_MUTEX(nl_sk_hash_lock);
 EXPORT_SYMBOL_GPL(nl_sk_hash_lock);
 
 #ifdef CONFIG_PROVE_LOCKING
-static int lockdep_nl_sk_hash_is_held(void)
+static int lockdep_nl_sk_hash_is_held(void *parent)
 {
 	if (debug_locks)
 		return lockdep_is_held(&nl_sk_hash_lock) || lockdep_is_held(&nl_table_lock);
