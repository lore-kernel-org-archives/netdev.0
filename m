From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/15] rhashtable: provide len to obj_hashfn
Date: Thu, 26 Mar 2015 13:06:53 +0100
Message-ID: <1427371622-4466-7-git-send-email-pablo@netfilter.org>
References: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1427371622-4466-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

nftables sets will be converted to use so called setextensions, moving
the key to a non-fixed position. To hash it, the obj_hashfn must be used,
however it so far doesn't receive the length parameter.

Pass the key length to obj_hashfn() and convert existing users.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/rhashtable.h |    6 ++++--
 lib/rhashtable.c           |    2 +-
 net/netlink/af_netlink.c   |    2 +-
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index 99f2e49..e23d242 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -88,7 +88,7 @@ struct rhashtable_compare_arg {
 };
 
 typedef u32 (*rht_hashfn_t)(const void *data, u32 len, u32 seed);
-typedef u32 (*rht_obj_hashfn_t)(const void *data, u32 seed);
+typedef u32 (*rht_obj_hashfn_t)(const void *data, u32 len, u32 seed);
 typedef int (*rht_obj_cmpfn_t)(struct rhashtable_compare_arg *arg,
 			       const void *obj);
 
@@ -242,7 +242,9 @@ static inline unsigned int rht_head_hashfn(
 	const char *ptr = rht_obj(ht, he);
 
 	return likely(params.obj_hashfn) ?
-	       rht_bucket_index(tbl, params.obj_hashfn(ptr, tbl->hash_rnd)) :
+	       rht_bucket_index(tbl, params.obj_hashfn(ptr, params.key_len ?:
+							    ht->p.key_len,
+						       tbl->hash_rnd)) :
 	       rht_key_hashfn(ht, tbl, ptr + params.key_offset, params);
 }
 
diff --git a/lib/rhashtable.c b/lib/rhashtable.c
index 4b7b7e6..4898442 100644
--- a/lib/rhashtable.c
+++ b/lib/rhashtable.c
@@ -691,7 +691,7 @@ static u32 rhashtable_jhash2(const void *key, u32 length, u32 seed)
  *	struct rhash_head	node;
  * };
  *
- * u32 my_hash_fn(const void *data, u32 seed)
+ * u32 my_hash_fn(const void *data, u32 len, u32 seed)
  * {
  *	struct test_obj *obj = data;
  *
diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 4caa809..19909d0 100644
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
1.7.10.4

