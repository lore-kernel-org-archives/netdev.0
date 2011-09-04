From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH 2/2] net: Handle different key sizes between address families in flow cache
Date: Sun, 4 Sep 2011 09:07:21 -0400
Message-ID: <1315141641-3120-3-git-send-email-david.ward@ll.mit.edu>
References: <alpine.LFD.2.00.1109031004500.1492@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Julian Anastasov <ja@ssi.bg>, David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:37087 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753039Ab1IDNh7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 4 Sep 2011 09:37:59 -0400
In-Reply-To: <alpine.LFD.2.00.1109031004500.1492@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the conversion of struct flowi to a union of AF-specific structs, some
operations on the flow cache need to account for the exact size of the key.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 include/net/flow.h |   19 +++++++++++++++++++
 net/core/flow.c    |   28 ++++++++++++++++------------
 2 files changed, 35 insertions(+), 12 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 2ec377d..99119f6 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -7,6 +7,7 @@
 #ifndef _NET_FLOW_H
 #define _NET_FLOW_H
 
+#include <linux/socket.h>
 #include <linux/in6.h>
 #include <linux/atomic.h>
 
@@ -161,6 +162,24 @@ static inline struct flowi *flowidn_to_flowi(struct flowidn *fldn)
 	return container_of(fldn, struct flowi, u.dn);
 }
 
+typedef unsigned long flow_compare_t;
+
+static inline size_t flowi_size(u16 family)
+{
+	switch (family) {
+	case AF_INET:
+		BUILD_BUG_ON(sizeof(struct flowi4) % sizeof(flow_compare_t));
+		return sizeof(struct flowi4);
+	case AF_INET6:
+		BUILD_BUG_ON(sizeof(struct flowi6) % sizeof(flow_compare_t));
+		return sizeof(struct flowi6);
+	case AF_DECnet:
+		BUILD_BUG_ON(sizeof(struct flowidn) % sizeof(flow_compare_t));
+		return sizeof(struct flowidn);
+	}
+	return 0;
+}
+
 #define FLOW_DIR_IN	0
 #define FLOW_DIR_OUT	1
 #define FLOW_DIR_FWD	2
diff --git a/net/core/flow.c b/net/core/flow.c
index bf32c33..1545445 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -172,26 +172,24 @@ static void flow_new_hash_rnd(struct flow_cache *fc,
 
 static u32 flow_hash_code(struct flow_cache *fc,
 			  struct flow_cache_percpu *fcp,
-			  const struct flowi *key)
+			  const struct flowi *key,
+			  size_t keysize)
 {
 	const u32 *k = (const u32 *) key;
 
-	return jhash2(k, (sizeof(*key) / sizeof(u32)), fcp->hash_rnd)
+	return jhash2(k, (keysize / sizeof(u32)), fcp->hash_rnd)
 		& (flow_cache_hash_size(fc) - 1);
 }
 
-typedef unsigned long flow_compare_t;
-
 /* I hear what you're saying, use memcmp.  But memcmp cannot make
  * important assumptions that we can here, such as alignment and
- * constant size.
+ * size.
  */
-static int flow_key_compare(const struct flowi *key1, const struct flowi *key2)
+static int flow_key_compare(const struct flowi *key1, const struct flowi *key2,
+			    size_t keysize)
 {
 	const flow_compare_t *k1, *k1_lim, *k2;
-	const int n_elem = sizeof(struct flowi) / sizeof(flow_compare_t);
-
-	BUILD_BUG_ON(sizeof(struct flowi) % sizeof(flow_compare_t));
+	const int n_elem = keysize / sizeof(flow_compare_t);
 
 	k1 = (const flow_compare_t *) key1;
 	k1_lim = k1 + n_elem;
@@ -215,6 +213,7 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 	struct flow_cache_entry *fle, *tfle;
 	struct hlist_node *entry;
 	struct flow_cache_object *flo;
+	size_t keysize;
 	unsigned int hash;
 
 	local_bh_disable();
@@ -222,6 +221,11 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 
 	fle = NULL;
 	flo = NULL;
+
+	keysize = flowi_size(family);
+	if (!keysize)
+		goto nocache;
+
 	/* Packet really early in init?  Making flow_cache_init a
 	 * pre-smp initcall would solve this.  --RR */
 	if (!fcp->hash_table)
@@ -230,11 +234,11 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 	if (fcp->hash_rnd_recalc)
 		flow_new_hash_rnd(fc, fcp);
 
-	hash = flow_hash_code(fc, fcp, key);
+	hash = flow_hash_code(fc, fcp, key, keysize);
 	hlist_for_each_entry(tfle, entry, &fcp->hash_table[hash], u.hlist) {
 		if (tfle->family == family &&
 		    tfle->dir == dir &&
-		    flow_key_compare(key, &tfle->key) == 0) {
+		    flow_key_compare(key, &tfle->key, keysize) == 0) {
 			fle = tfle;
 			break;
 		}
@@ -248,7 +252,7 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 		if (fle) {
 			fle->family = family;
 			fle->dir = dir;
-			memcpy(&fle->key, key, sizeof(*key));
+			memcpy(&fle->key, key, keysize);
 			fle->object = NULL;
 			hlist_add_head(&fle->u.hlist, &fcp->hash_table[hash]);
 			fcp->hash_count++;
-- 
1.7.1
