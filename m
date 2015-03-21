From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 1/2] rhashtable: provide len to obj_hashfn
Date: Sat, 21 Mar 2015 15:38:09 +0000
Message-ID: <1426952290-18962-2-git-send-email-kaber@trash.net>
References: <1426952290-18962-1-git-send-email-kaber@trash.net>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au, tgraf@suug.ch,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1426952290-18962-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

nftables sets will be converted to use so called setextensions, moving
the key to a non-fixed position. To hash it, the obj_hashfn must be used,
however it so far doesn't receive the length parameter.

Pass the key length to obj_hashfn() and convert existing users.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/rhashtable.h | 6 ++++--
 lib/rhashtable.c           | 2 +-
 net/netlink/af_netlink.c   | 2 +-
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 89d1022..d94dd53 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -87,7 +87,7 @@ struct rhashtable_compare_arg {
 };
 
 typedef u32 (*rht_hashfn_t)(const void *data, u32 len, u32 seed);
-typedef u32 (*rht_obj_hashfn_t)(const void *data, u32 seed);
+typedef u32 (*rht_obj_hashfn_t)(const void *data, u32 len, u32 seed);
 typedef int (*rht_obj_cmpfn_t)(struct rhashtable_compare_arg *arg,
 			       const void *obj);
 
@@ -211,7 +211,9 @@ static inline unsigned int rht_head_hashfn(
 	const char *ptr = rht_obj(ht, he);
 
 	return likely(params.obj_hashfn) ?
-	       rht_bucket_index(tbl, params.obj_hashfn(ptr, tbl->hash_rnd)) :
+	       rht_bucket_index(tbl, params.obj_hashfn(ptr, params.key_len ?:
+							    ht->p.key_len,
+						       tbl->hash_rnd)) :
 	       rht_key_hashfn(ht, tbl, ptr + params.key_offset, params);
 }
 
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 83cfedd..c897671 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -559,7 +559,7 @@ static size_t rounded_hashtable_size(const struct rhashtable_params *params)
  *	struct rhash_head	node;
  * };
  *
- * u32 my_hash_fn(const void *data, u32 seed)
+ * u32 my_hash_fn(const void *data, u32 len, u32 seed)
  * {
  *	struct test_obj *obj = data;
  *
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 6517921..f15b651 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -3127,7 +3127,7 @@ static struct pernet_operations __net_initdata netlink_net_ops = {
 	.exit = netlink_net_exit,
 };
 
-static inline u32 netlink_hash(const void *data, u32 seed)
+static inline u32 netlink_hash(const void *data, u32 len, u32 seed)
 {
 	const struct netlink_sock *nlk = data;
 	struct netlink_compare_arg arg;
-- 
2.1.0

