From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH 2/2] net: Handle different key sizes between address families in flow cache
Date: Mon, 5 Sep 2011 22:47:24 -0400
Message-ID: <1315277244-19335-3-git-send-email-david.ward@ll.mit.edu>
References: <CAHXqBF+eF_zYAFPZv0hWUvDHv5YMHuFAR3-iB8MEZz2G7vCUyA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Julian Anastasov <ja@ssi.bg>,
	=?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirqus@gmail.com>,
	David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:60750 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751644Ab1IFDNY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Sep 2011 23:13:24 -0400
In-Reply-To: <CAHXqBF+eF_zYAFPZv0hWUvDHv5YMHuFAR3-iB8MEZz2G7vCUyA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With the conversion of struct flowi to a union of AF-specific structs, some
operations on the flow cache need to account for the exact size of the key.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 include/net/flow.h |   19 +++++++++++++++++++
 net/core/flow.c    |   31 +++++++++++++++++--------------
 2 files changed, 36 insertions(+), 14 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index 2ec377d..a094477 100644
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
+static inline size_t flow_key_size(u16 family)
+{
+	switch (family) {
+	case AF_INET:
+		BUILD_BUG_ON(sizeof(struct flowi4) % sizeof(flow_compare_t));
+		return sizeof(struct flowi4) / sizeof(flow_compare_t);
+	case AF_INET6:
+		BUILD_BUG_ON(sizeof(struct flowi6) % sizeof(flow_compare_t));
+		return sizeof(struct flowi6) / sizeof(flow_compare_t);
+	case AF_DECnet:
+		BUILD_BUG_ON(sizeof(struct flowidn) % sizeof(flow_compare_t));
+		return sizeof(struct flowidn) / sizeof(flow_compare_t);
+	}
+	return 0;
+}
+
 #define FLOW_DIR_IN	0
 #define FLOW_DIR_OUT	1
 #define FLOW_DIR_FWD	2
diff --git a/net/core/flow.c b/net/core/flow.c
index bf32c33..2d93a37 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -172,29 +172,26 @@ static void flow_new_hash_rnd(struct flow_cache *fc,
 
 static u32 flow_hash_code(struct flow_cache *fc,
 			  struct flow_cache_percpu *fcp,
-			  const struct flowi *key)
+			  const struct flowi *key,
+			  size_t keysize)
 {
 	const u32 *k = (const u32 *) key;
+	const u32 length = keysize * sizeof(flow_compare_t) / sizeof(u32); 
 
-	return jhash2(k, (sizeof(*key) / sizeof(u32)), fcp->hash_rnd)
+	return jhash2(k, length, fcp->hash_rnd)
 		& (flow_cache_hash_size(fc) - 1);
 }
 
-typedef unsigned long flow_compare_t;
-
 /* I hear what you're saying, use memcmp.  But memcmp cannot make
- * important assumptions that we can here, such as alignment and
- * constant size.
+ * important assumptions that we can here, such as alignment.
  */
-static int flow_key_compare(const struct flowi *key1, const struct flowi *key2)
+static int flow_key_compare(const struct flowi *key1, const struct flowi *key2,
+			    size_t keysize)
 {
 	const flow_compare_t *k1, *k1_lim, *k2;
-	const int n_elem = sizeof(struct flowi) / sizeof(flow_compare_t);
-
-	BUILD_BUG_ON(sizeof(struct flowi) % sizeof(flow_compare_t));
 
 	k1 = (const flow_compare_t *) key1;
-	k1_lim = k1 + n_elem;
+	k1_lim = k1 + keysize;
 
 	k2 = (const flow_compare_t *) key2;
 
@@ -215,6 +212,7 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 	struct flow_cache_entry *fle, *tfle;
 	struct hlist_node *entry;
 	struct flow_cache_object *flo;
+	size_t keysize;
 	unsigned int hash;
 
 	local_bh_disable();
@@ -222,6 +220,11 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 
 	fle = NULL;
 	flo = NULL;
+
+	keysize = flow_key_size(family);
+	if (!keysize)
+		goto nocache;
+
 	/* Packet really early in init?  Making flow_cache_init a
 	 * pre-smp initcall would solve this.  --RR */
 	if (!fcp->hash_table)
@@ -230,11 +233,11 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
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
@@ -248,7 +251,7 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 		if (fle) {
 			fle->family = family;
 			fle->dir = dir;
-			memcpy(&fle->key, key, sizeof(*key));
+			memcpy(&fle->key, key, keysize * sizeof(flow_compare_t));
 			fle->object = NULL;
 			hlist_add_head(&fle->u.hlist, &fcp->hash_table[hash]);
 			fcp->hash_count++;
-- 
1.7.1
