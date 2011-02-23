From: David Miller <davem@davemloft.net>
Subject: [PATCH 20/20] net: Make flow cache paths use a const struct flowi.
Date: Tue, 22 Feb 2011 19:55:08 -0800 (PST)
Message-ID: <20110222.195508.35022694.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32872
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753765Ab1BWDyb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Feb 2011 22:54:31 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 7C3F424C088
	for <netdev@vger.kernel.org>; Tue, 22 Feb 2011 19:55:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/net/dst.h      |   10 ++++++----
 include/net/flow.h     |    4 ++--
 net/core/flow.c        |   14 +++++++-------
 net/xfrm/xfrm_policy.c |   13 ++++++++-----
 4 files changed, 23 insertions(+), 18 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 23b564d..4fedffd 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -428,20 +428,22 @@ enum {
 struct flowi;
 #ifndef CONFIG_XFRM
 static inline int xfrm_lookup(struct net *net, struct dst_entry **dst_p,
-			      struct flowi *fl, struct sock *sk, int flags)
+			      const struct flowi *fl, struct sock *sk,
+			      int flags)
 {
 	return 0;
 } 
 static inline int __xfrm_lookup(struct net *net, struct dst_entry **dst_p,
-				struct flowi *fl, struct sock *sk, int flags)
+				const struct flowi *fl, struct sock *sk,
+				int flags)
 {
 	return 0;
 }
 #else
 extern int xfrm_lookup(struct net *net, struct dst_entry **dst_p,
-		       struct flowi *fl, struct sock *sk, int flags);
+		       const struct flowi *fl, struct sock *sk, int flags);
 extern int __xfrm_lookup(struct net *net, struct dst_entry **dst_p,
-			 struct flowi *fl, struct sock *sk, int flags);
+			 const struct flowi *fl, struct sock *sk, int flags);
 #endif
 #endif
 
diff --git a/include/net/flow.h b/include/net/flow.h
index f4270d4..f2080e6 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -102,11 +102,11 @@ struct flow_cache_ops {
 };
 
 typedef struct flow_cache_object *(*flow_resolve_t)(
-		struct net *net, struct flowi *key, u16 family,
+		struct net *net, const struct flowi *key, u16 family,
 		u8 dir, struct flow_cache_object *oldobj, void *ctx);
 
 extern struct flow_cache_object *flow_cache_lookup(
-		struct net *net, struct flowi *key, u16 family,
+		struct net *net, const struct flowi *key, u16 family,
 		u8 dir, flow_resolve_t resolver, void *ctx);
 
 extern void flow_cache_flush(void);
diff --git a/net/core/flow.c b/net/core/flow.c
index 127c8a7..990703b 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -172,9 +172,9 @@ static void flow_new_hash_rnd(struct flow_cache *fc,
 
 static u32 flow_hash_code(struct flow_cache *fc,
 			  struct flow_cache_percpu *fcp,
-			  struct flowi *key)
+			  const struct flowi *key)
 {
-	u32 *k = (u32 *) key;
+	const u32 *k = (const u32 *) key;
 
 	return jhash2(k, (sizeof(*key) / sizeof(u32)), fcp->hash_rnd)
 		& (flow_cache_hash_size(fc) - 1);
@@ -186,17 +186,17 @@ typedef unsigned long flow_compare_t;
  * important assumptions that we can here, such as alignment and
  * constant size.
  */
-static int flow_key_compare(struct flowi *key1, struct flowi *key2)
+static int flow_key_compare(const struct flowi *key1, const struct flowi *key2)
 {
-	flow_compare_t *k1, *k1_lim, *k2;
+	const flow_compare_t *k1, *k1_lim, *k2;
 	const int n_elem = sizeof(struct flowi) / sizeof(flow_compare_t);
 
 	BUILD_BUG_ON(sizeof(struct flowi) % sizeof(flow_compare_t));
 
-	k1 = (flow_compare_t *) key1;
+	k1 = (const flow_compare_t *) key1;
 	k1_lim = k1 + n_elem;
 
-	k2 = (flow_compare_t *) key2;
+	k2 = (const flow_compare_t *) key2;
 
 	do {
 		if (*k1++ != *k2++)
@@ -207,7 +207,7 @@ static int flow_key_compare(struct flowi *key1, struct flowi *key2)
 }
 
 struct flow_cache_object *
-flow_cache_lookup(struct net *net, struct flowi *key, u16 family, u8 dir,
+flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 		  flow_resolve_t resolver, void *ctx)
 {
 	struct flow_cache *fc = &flow_cache_global;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index ef899a8..28c865a 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -954,7 +954,7 @@ __xfrm_policy_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir
 }
 
 static struct flow_cache_object *
-xfrm_policy_lookup(struct net *net, struct flowi *fl, u16 family,
+xfrm_policy_lookup(struct net *net, const struct flowi *fl, u16 family,
 		   u8 dir, struct flow_cache_object *old_obj, void *ctx)
 {
 	struct xfrm_policy *pol;
@@ -990,7 +990,8 @@ static inline int policy_to_flow_dir(int dir)
 	}
 }
 
-static struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir, struct flowi *fl)
+static struct xfrm_policy *xfrm_sk_policy_lookup(struct sock *sk, int dir,
+						 const struct flowi *fl)
 {
 	struct xfrm_policy *pol;
 
@@ -1629,7 +1630,7 @@ xfrm_resolve_and_create_bundle(struct xfrm_policy **pols, int num_pols,
 }
 
 static struct flow_cache_object *
-xfrm_bundle_lookup(struct net *net, struct flowi *fl, u16 family, u8 dir,
+xfrm_bundle_lookup(struct net *net, const struct flowi *fl, u16 family, u8 dir,
 		   struct flow_cache_object *oldflo, void *ctx)
 {
 	struct dst_entry *dst_orig = (struct dst_entry *)ctx;
@@ -1733,7 +1734,8 @@ error:
  * At the moment we eat a raw IP route. Mostly to speed up lookups
  * on interfaces with disabled IPsec.
  */
-int __xfrm_lookup(struct net *net, struct dst_entry **dst_p, struct flowi *fl,
+int __xfrm_lookup(struct net *net, struct dst_entry **dst_p,
+		  const struct flowi *fl,
 		  struct sock *sk, int flags)
 {
 	struct xfrm_policy *pols[XFRM_POLICY_TYPE_MAX];
@@ -1889,7 +1891,8 @@ dropdst:
 }
 EXPORT_SYMBOL(__xfrm_lookup);
 
-int xfrm_lookup(struct net *net, struct dst_entry **dst_p, struct flowi *fl,
+int xfrm_lookup(struct net *net, struct dst_entry **dst_p,
+		const struct flowi *fl,
 		struct sock *sk, int flags)
 {
 	int err = __xfrm_lookup(net, dst_p, fl, sk, flags);
-- 
1.7.4.1

