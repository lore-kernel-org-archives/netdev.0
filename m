From: Kim Phillips <kim.phillips@freescale.com>
Subject: [stable v2] net: Handle different key sizes between address
 families in flow cache
Date: Tue, 8 Nov 2011 13:44:45 -0600
Message-ID: <20111108134445.920d6e8a63e500203dcdb4d8@freescale.com>
References: <20111101185022.b156ea957baf286f1bf00f9c@freescale.com>
	<20111101.203430.110242050755204948.davem@davemloft.net>
	<20111103135851.2229247682ec040d653479e1@freescale.com>
	<20111103.224329.2276058062630695656.davem@davemloft.net>
	<20111104144659.3e0a30afffffd9dd73cf740e@freescale.com>
	<20111104212439.GA27324@kroah.com>
	<20111104212958.5d54152b38050e2a0917d575@freescale.com>
	<20111108165317.GB25206@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, <stable@vger.kernel.org>,
	<eric.dumazet@gmail.com>, <zheng.z.yan@intel.com>,
	<netdev@vger.kernel.org>, David Ward <david.ward@ll.mit.edu>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe004.messaging.microsoft.com ([216.32.181.184]:9299
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753811Ab1KHTpp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 14:45:45 -0500
In-Reply-To: <20111108165317.GB25206@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit aa1c366e4febc7f5c2b84958a2dd7cd70e28f9d0 upstream.

With the conversion of struct flowi to a union of AF-specific structs, some
operations on the flow cache need to account for the exact size of the key.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
Signed-off-by: David S. Miller <davem@davemloft.net>
Cc: <stable@vger.kernel.org> # v3.0.x: 728871b: net: Align AF-specific flowi structs to long
Cc: <stable@vger.kernel.org> # v3.0.x
---
v2: resend, with 64-bit build fix dependency 728871b included in sign-off area

 include/net/flow.h |   19 +++++++++++++++++++
 net/core/flow.c    |   31 +++++++++++++++++--------------
 2 files changed, 36 insertions(+), 14 deletions(-)

diff --git a/include/net/flow.h b/include/net/flow.h
index c6d5fe5..93a8785 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -7,6 +7,7 @@
 #ifndef _NET_FLOW_H
 #define _NET_FLOW_H
 
+#include <linux/socket.h>
 #include <linux/in6.h>
 #include <asm/atomic.h>
 
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
index 990703b..a6bda2a 100644
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
1.7.7.2
