From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 4/5 net-next v2] rhashtable: Disable automatic shrinking by
 default
Date: Tue, 24 Mar 2015 20:42:19 +0000
Message-ID: <20150324204219.GA23613@casper.infradead.org>
References: <cover.1427202823.git.tgraf@suug.ch>
 <f6ed6e9fe9434e55475b777281f6fe67eff0e07d.1427202823.git.tgraf@suug.ch>
 <20150324185545.GA15837@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:38083 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752342AbbCXUmU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 16:42:20 -0400
Content-Disposition: inline
In-Reply-To: <20150324185545.GA15837@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce a new bool automatic_shrinking to require the
user to explicitly opt-in to automatic shrinking of tables.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
v2: Use bool in params to also disable shrinking in worker as
    pointed out by Herbert.

@Dave: Patch 5 still applied on top with some fuzz. If not,
       let me know and I will respin.

 include/linux/rhashtable.h | 7 +++++--
 lib/rhashtable.c           | 2 +-
 net/netfilter/nft_hash.c   | 1 +
 net/netlink/af_netlink.c   | 1 +
 net/tipc/socket.c          | 1 +
 5 files changed, 9 insertions(+), 3 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 0e1f975..ae26c49 100644
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
@@ -104,6 +104,7 @@ struct rhashtable;
  * @min_size: Minimum size while shrinking
  * @nulls_base: Base value to generate nulls marker
  * @insecure_elasticity: Set to true to disable chain length checks
+ * @automatic_shrinking: Enable automatic shrinking of tables
  * @locks_mul: Number of bucket locks to allocate per cpu (default: 128)
  * @hashfn: Hash function (default: jhash2 if !(key_len % 4), or jhash)
  * @obj_hashfn: Function to hash object
@@ -118,6 +119,7 @@ struct rhashtable_params {
 	unsigned int		min_size;
 	u32			nulls_base;
 	bool			insecure_elasticity;
+	bool			automatic_shrinking;
 	size_t			locks_mul;
 	rht_hashfn_t		hashfn;
 	rht_obj_hashfn_t	obj_hashfn;
@@ -784,7 +786,8 @@ static inline int rhashtable_remove_fast(
 		goto out;
 
 	atomic_dec(&ht->nelems);
-	if (rht_shrink_below_30(ht, tbl))
+	if (unlikely(ht->p.automatic_shrinking &&
+		     rht_shrink_below_30(ht, tbl)))
 		schedule_work(&ht->run_work);
 
 out:
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 93374d7..a0ad777 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -367,7 +367,7 @@ static void rht_deferred_worker(struct work_struct *work)
 
 	if (rht_grow_above_75(ht, tbl))
 		rhashtable_expand(ht);
-	else if (rht_shrink_below_30(ht, tbl))
+	else if (ht->p.automatic_shrinking && rht_shrink_below_30(ht, tbl))
 		rhashtable_shrink(ht);
 
 	err = rhashtable_rehash_table(ht);
diff --git a/net/netfilter/nft_hash.c b/net/netfilter/nft_hash.c
index ad39669..8577a37 100644
--- a/net/netfilter/nft_hash.c
+++ b/net/netfilter/nft_hash.c
@@ -172,6 +172,7 @@ static const struct rhashtable_params nft_hash_params = {
 	.head_offset = offsetof(struct nft_hash_elem, node),
 	.key_offset = offsetof(struct nft_hash_elem, key),
 	.hashfn = jhash,
+	.automatic_shrinking = true,
 };
 
 static int nft_hash_init(const struct nft_set *set,
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index e2f7f28..4caa809 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -3142,6 +3142,7 @@ static const struct rhashtable_params netlink_rhashtable_params = {
 	.obj_hashfn = netlink_hash,
 	.obj_cmpfn = netlink_compare,
 	.max_size = 65536,
+	.automatic_shrinking = true,
 };
 
 static int __init netlink_proto_init(void)
diff --git a/net/tipc/socket.c b/net/tipc/socket.c
index 6dd5bd9..3cc099d 100644
--- a/net/tipc/socket.c
+++ b/net/tipc/socket.c
@@ -2295,6 +2295,7 @@ static const struct rhashtable_params tsk_rht_params = {
 	.key_len = sizeof(u32), /* portid */
 	.max_size = 1048576,
 	.min_size = 256,
+	.automatic_shrinking = true,
 };
 
 int tipc_sk_rht_init(struct net *net)
-- 
1.9.3
