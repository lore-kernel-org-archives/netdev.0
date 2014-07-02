From: Tom Herbert <therbert@google.com>
Subject: [PATCH 1/8] flow_dissector: Abstract out hash computation
Date: Tue, 1 Jul 2014 21:32:05 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407012056570.26590@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f74.google.com ([209.85.219.74]:61369 "EHLO
	mail-oa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbaGBEcH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 00:32:07 -0400
Received: by mail-oa0-f74.google.com with SMTP id i7so2450050oag.5
        for <netdev@vger.kernel.org>; Tue, 01 Jul 2014 21:32:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the hash computation located in __skb_get_hash to be a separate
function which takes flow_keys as input. This will allow flow hash
computation in other contexts where we only have addresses and ports.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/net/flow_keys.h   |  1 +
 net/core/flow_dissector.c | 44 ++++++++++++++++++++++++++++----------------
 2 files changed, 29 insertions(+), 16 deletions(-)

diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index fbefdca..6667a05 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -29,4 +29,5 @@ struct flow_keys {
 
 bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow);
 __be32 skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto);
+u32 flow_hash_from_keys(struct flow_keys *keys);
 #endif
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index c2b53c1..2ff8cd4 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -202,6 +202,33 @@ static __always_inline u32 __flow_hash_1word(u32 a)
 	return jhash_1word(a, hashrnd);
 }
 
+static inline u32 __flow_hash_from_keys(struct flow_keys *keys)
+{
+	u32 hash;
+
+	/* get a consistent hash (same value on both flow directions) */
+	if (((__force u32)keys->dst < (__force u32)keys->src) ||
+	    (((__force u32)keys->dst == (__force u32)keys->src) &&
+	     ((__force u16)keys->port16[1] < (__force u16)keys->port16[0]))) {
+		swap(keys->dst, keys->src);
+		swap(keys->port16[0], keys->port16[1]);
+	}
+
+	hash = __flow_hash_3words((__force u32)keys->dst,
+				  (__force u32)keys->src,
+				  (__force u32)keys->ports);
+	if (!hash)
+		hash = 1;
+
+	return hash;
+}
+
+u32 flow_hash_from_keys(struct flow_keys *keys)
+{
+	return __flow_hash_from_keys(keys);
+}
+EXPORT_SYMBOL(flow_hash_from_keys);
+
 /*
  * __skb_get_hash: calculate a flow hash based on src/dst addresses
  * and src/dst port numbers.  Sets hash in skb to non-zero hash value
@@ -211,7 +238,6 @@ static __always_inline u32 __flow_hash_1word(u32 a)
 void __skb_get_hash(struct sk_buff *skb)
 {
 	struct flow_keys keys;
-	u32 hash;
 
 	if (!skb_flow_dissect(skb, &keys))
 		return;
@@ -219,21 +245,7 @@ void __skb_get_hash(struct sk_buff *skb)
 	if (keys.ports)
 		skb->l4_hash = 1;
 
-	/* get a consistent hash (same value on both flow directions) */
-	if (((__force u32)keys.dst < (__force u32)keys.src) ||
-	    (((__force u32)keys.dst == (__force u32)keys.src) &&
-	     ((__force u16)keys.port16[1] < (__force u16)keys.port16[0]))) {
-		swap(keys.dst, keys.src);
-		swap(keys.port16[0], keys.port16[1]);
-	}
-
-	hash = __flow_hash_3words((__force u32)keys.dst,
-				  (__force u32)keys.src,
-				  (__force u32)keys.ports);
-	if (!hash)
-		hash = 1;
-
-	skb->hash = hash;
+	skb->hash = __flow_hash_from_keys(&keys);
 }
 EXPORT_SYMBOL(__skb_get_hash);
 
-- 
2.0.0.526.g5318336
