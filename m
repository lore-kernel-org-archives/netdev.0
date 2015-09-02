From: David Miller <davem@davemloft.net>
Subject: [PATCH] flow_dissector: Use 'const' where possible.
Date: Tue, 01 Sep 2015 21:19:44 -0700 (PDT)
Message-ID: <20150901.211944.1246891781745159331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:34372 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987AbbIBETq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Sep 2015 00:19:46 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(Authenticated sender: davem-davemloft)
	by shards.monkeyblade.net (Postfix) with ESMTPSA id 7AD34586717
	for <netdev@vger.kernel.org>; Tue,  1 Sep 2015 21:19:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/skbuff.h    |  8 ++---
 include/net/flow.h        |  8 ++---
 net/core/flow_dissector.c | 79 ++++++++++++++++++++++++-----------------------
 3 files changed, 49 insertions(+), 46 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index eabfb81..2738d35 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1029,9 +1029,9 @@ static inline __u32 skb_get_hash(struct sk_buff *skb)
 	return skb->hash;
 }
 
-__u32 __skb_get_hash_flowi6(struct sk_buff *skb, struct flowi6 *fl6);
+__u32 __skb_get_hash_flowi6(struct sk_buff *skb, const struct flowi6 *fl6);
 
-static inline __u32 skb_get_hash_flowi6(struct sk_buff *skb, struct flowi6 *fl6)
+static inline __u32 skb_get_hash_flowi6(struct sk_buff *skb, const struct flowi6 *fl6)
 {
 	if (!skb->l4_hash && !skb->sw_hash) {
 		struct flow_keys keys;
@@ -1043,9 +1043,9 @@ static inline __u32 skb_get_hash_flowi6(struct sk_buff *skb, struct flowi6 *fl6)
 	return skb->hash;
 }
 
-__u32 __skb_get_hash_flowi4(struct sk_buff *skb, struct flowi4 *fl);
+__u32 __skb_get_hash_flowi4(struct sk_buff *skb, const struct flowi4 *fl);
 
-static inline __u32 skb_get_hash_flowi4(struct sk_buff *skb, struct flowi4 *fl4)
+static inline __u32 skb_get_hash_flowi4(struct sk_buff *skb, const struct flowi4 *fl4)
 {
 	if (!skb->l4_hash && !skb->sw_hash) {
 		struct flow_keys keys;
diff --git a/include/net/flow.h b/include/net/flow.h
index dafe97c..acd6a09 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -244,18 +244,18 @@ void flow_cache_flush(struct net *net);
 void flow_cache_flush_deferred(struct net *net);
 extern atomic_t flow_cache_genid;
 
-__u32 __get_hash_from_flowi6(struct flowi6 *fl6, struct flow_keys *keys);
+__u32 __get_hash_from_flowi6(const struct flowi6 *fl6, struct flow_keys *keys);
 
-static inline __u32 get_hash_from_flowi6(struct flowi6 *fl6)
+static inline __u32 get_hash_from_flowi6(const struct flowi6 *fl6)
 {
 	struct flow_keys keys;
 
 	return __get_hash_from_flowi6(fl6, &keys);
 }
 
-__u32 __get_hash_from_flowi4(struct flowi4 *fl4, struct flow_keys *keys);
+__u32 __get_hash_from_flowi4(const struct flowi4 *fl4, struct flow_keys *keys);
 
-static inline __u32 get_hash_from_flowi4(struct flowi4 *fl4)
+static inline __u32 get_hash_from_flowi4(const struct flowi4 *fl4)
 {
 	struct flow_keys keys;
 
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 345a040..d79699c 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -19,14 +19,14 @@
 #include <net/flow_dissector.h>
 #include <scsi/fc/fc_fcoe.h>
 
-static bool skb_flow_dissector_uses_key(struct flow_dissector *flow_dissector,
-					enum flow_dissector_key_id key_id)
+static bool dissector_uses_key(const struct flow_dissector *flow_dissector,
+			       enum flow_dissector_key_id key_id)
 {
 	return flow_dissector->used_keys & (1 << key_id);
 }
 
-static void skb_flow_dissector_set_key(struct flow_dissector *flow_dissector,
-				       enum flow_dissector_key_id key_id)
+static void dissector_set_key(struct flow_dissector *flow_dissector,
+			      enum flow_dissector_key_id key_id)
 {
 	flow_dissector->used_keys |= (1 << key_id);
 }
@@ -51,20 +51,20 @@ void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
 		 * boundaries of unsigned short.
 		 */
 		BUG_ON(key->offset > USHRT_MAX);
-		BUG_ON(skb_flow_dissector_uses_key(flow_dissector,
-						   key->key_id));
+		BUG_ON(dissector_uses_key(flow_dissector,
+					  key->key_id));
 
-		skb_flow_dissector_set_key(flow_dissector, key->key_id);
+		dissector_set_key(flow_dissector, key->key_id);
 		flow_dissector->offset[key->key_id] = key->offset;
 	}
 
 	/* Ensure that the dissector always includes control and basic key.
 	 * That way we are able to avoid handling lack of these in fast path.
 	 */
-	BUG_ON(!skb_flow_dissector_uses_key(flow_dissector,
-					    FLOW_DISSECTOR_KEY_CONTROL));
-	BUG_ON(!skb_flow_dissector_uses_key(flow_dissector,
-					    FLOW_DISSECTOR_KEY_BASIC));
+	BUG_ON(!dissector_uses_key(flow_dissector,
+				   FLOW_DISSECTOR_KEY_CONTROL));
+	BUG_ON(!dissector_uses_key(flow_dissector,
+				   FLOW_DISSECTOR_KEY_BASIC));
 }
 EXPORT_SYMBOL(skb_flow_dissector_init);
 
@@ -154,8 +154,8 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 					      FLOW_DISSECTOR_KEY_BASIC,
 					      target_container);
 
-	if (skb_flow_dissector_uses_key(flow_dissector,
-					FLOW_DISSECTOR_KEY_ETH_ADDRS)) {
+	if (dissector_uses_key(flow_dissector,
+			       FLOW_DISSECTOR_KEY_ETH_ADDRS)) {
 		struct ethhdr *eth = eth_hdr(skb);
 		struct flow_dissector_key_eth_addrs *key_eth_addrs;
 
@@ -178,8 +178,8 @@ ip:
 
 		ip_proto = iph->protocol;
 
-		if (!skb_flow_dissector_uses_key(flow_dissector,
-						 FLOW_DISSECTOR_KEY_IPV4_ADDRS))
+		if (!dissector_uses_key(flow_dissector,
+					FLOW_DISSECTOR_KEY_IPV4_ADDRS))
 			break;
 
 		key_addrs = skb_flow_dissector_target(flow_dissector,
@@ -218,8 +218,8 @@ ipv6:
 		ip_proto = iph->nexthdr;
 		nhoff += sizeof(struct ipv6hdr);
 
-		if (skb_flow_dissector_uses_key(flow_dissector,
-						FLOW_DISSECTOR_KEY_IPV6_ADDRS)) {
+		if (dissector_uses_key(flow_dissector,
+				       FLOW_DISSECTOR_KEY_IPV6_ADDRS)) {
 			struct flow_dissector_key_ipv6_addrs *key_ipv6_addrs;
 
 			key_ipv6_addrs = skb_flow_dissector_target(flow_dissector,
@@ -232,8 +232,8 @@ ipv6:
 
 		flow_label = ip6_flowlabel(iph);
 		if (flow_label) {
-			if (skb_flow_dissector_uses_key(flow_dissector,
-				FLOW_DISSECTOR_KEY_FLOW_LABEL)) {
+			if (dissector_uses_key(flow_dissector,
+					       FLOW_DISSECTOR_KEY_FLOW_LABEL)) {
 				key_tags = skb_flow_dissector_target(flow_dissector,
 								     FLOW_DISSECTOR_KEY_FLOW_LABEL,
 								     target_container);
@@ -257,8 +257,8 @@ ipv6:
 		if (!vlan)
 			goto out_bad;
 
-		if (skb_flow_dissector_uses_key(flow_dissector,
-						FLOW_DISSECTOR_KEY_VLANID)) {
+		if (dissector_uses_key(flow_dissector,
+				       FLOW_DISSECTOR_KEY_VLANID)) {
 			key_tags = skb_flow_dissector_target(flow_dissector,
 							     FLOW_DISSECTOR_KEY_VLANID,
 							     target_container);
@@ -298,8 +298,8 @@ ipv6:
 		if (!hdr)
 			goto out_bad;
 
-		if (skb_flow_dissector_uses_key(flow_dissector,
-						FLOW_DISSECTOR_KEY_TIPC_ADDRS)) {
+		if (dissector_uses_key(flow_dissector,
+				       FLOW_DISSECTOR_KEY_TIPC_ADDRS)) {
 			key_addrs = skb_flow_dissector_target(flow_dissector,
 							      FLOW_DISSECTOR_KEY_TIPC_ADDRS,
 							      target_container);
@@ -320,8 +320,8 @@ mpls:
 
 		if ((ntohl(hdr[0].entry) & MPLS_LS_LABEL_MASK) >>
 		     MPLS_LS_LABEL_SHIFT == MPLS_LABEL_ENTROPY) {
-			if (skb_flow_dissector_uses_key(flow_dissector,
-							FLOW_DISSECTOR_KEY_MPLS_ENTROPY)) {
+			if (dissector_uses_key(flow_dissector,
+					       FLOW_DISSECTOR_KEY_MPLS_ENTROPY)) {
 				key_keyid = skb_flow_dissector_target(flow_dissector,
 								      FLOW_DISSECTOR_KEY_MPLS_ENTROPY,
 								      target_container);
@@ -374,8 +374,8 @@ ip_proto_again:
 			if (!keyid)
 				goto out_bad;
 
-			if (skb_flow_dissector_uses_key(flow_dissector,
-							FLOW_DISSECTOR_KEY_GRE_KEYID)) {
+			if (dissector_uses_key(flow_dissector,
+					       FLOW_DISSECTOR_KEY_GRE_KEYID)) {
 				key_keyid = skb_flow_dissector_target(flow_dissector,
 								      FLOW_DISSECTOR_KEY_GRE_KEYID,
 								      target_container);
@@ -470,8 +470,8 @@ ip_proto_again:
 		break;
 	}
 
-	if (skb_flow_dissector_uses_key(flow_dissector,
-					FLOW_DISSECTOR_KEY_PORTS)) {
+	if (dissector_uses_key(flow_dissector,
+			       FLOW_DISSECTOR_KEY_PORTS)) {
 		key_ports = skb_flow_dissector_target(flow_dissector,
 						      FLOW_DISSECTOR_KEY_PORTS,
 						      target_container);
@@ -497,18 +497,21 @@ static __always_inline void __flow_hash_secret_init(void)
 	net_get_random_once(&hashrnd, sizeof(hashrnd));
 }
 
-static __always_inline u32 __flow_hash_words(u32 *words, u32 length, u32 keyval)
+static __always_inline u32 __flow_hash_words(const u32 *words, u32 length,
+					     u32 keyval)
 {
 	return jhash2(words, length, keyval);
 }
 
-static inline void *flow_keys_hash_start(struct flow_keys *flow)
+static inline const u32 *flow_keys_hash_start(const struct flow_keys *flow)
 {
+	const void *p = flow;
+
 	BUILD_BUG_ON(FLOW_KEYS_HASH_OFFSET % sizeof(u32));
-	return (void *)flow + FLOW_KEYS_HASH_OFFSET;
+	return (const u32 *)(p + FLOW_KEYS_HASH_OFFSET);
 }
 
-static inline size_t flow_keys_hash_length(struct flow_keys *flow)
+static inline size_t flow_keys_hash_length(const struct flow_keys *flow)
 {
 	size_t diff = FLOW_KEYS_HASH_OFFSET + sizeof(flow->addrs);
 	BUILD_BUG_ON((sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32));
@@ -598,7 +601,7 @@ static inline u32 __flow_hash_from_keys(struct flow_keys *keys, u32 keyval)
 
 	__flow_hash_consistentify(keys);
 
-	hash = __flow_hash_words((u32 *)flow_keys_hash_start(keys),
+	hash = __flow_hash_words(flow_keys_hash_start(keys),
 				 flow_keys_hash_length(keys), keyval);
 	if (!hash)
 		hash = 1;
@@ -677,7 +680,7 @@ __u32 skb_get_hash_perturb(const struct sk_buff *skb, u32 perturb)
 }
 EXPORT_SYMBOL(skb_get_hash_perturb);
 
-__u32 __skb_get_hash_flowi6(struct sk_buff *skb, struct flowi6 *fl6)
+__u32 __skb_get_hash_flowi6(struct sk_buff *skb, const struct flowi6 *fl6)
 {
 	struct flow_keys keys;
 
@@ -701,7 +704,7 @@ __u32 __skb_get_hash_flowi6(struct sk_buff *skb, struct flowi6 *fl6)
 }
 EXPORT_SYMBOL(__skb_get_hash_flowi6);
 
-__u32 __skb_get_hash_flowi4(struct sk_buff *skb, struct flowi4 *fl4)
+__u32 __skb_get_hash_flowi4(struct sk_buff *skb, const struct flowi4 *fl4)
 {
 	struct flow_keys keys;
 
@@ -787,7 +790,7 @@ u32 skb_get_poff(const struct sk_buff *skb)
 	return __skb_get_poff(skb, skb->data, &keys, skb_headlen(skb));
 }
 
-__u32 __get_hash_from_flowi6(struct flowi6 *fl6, struct flow_keys *keys)
+__u32 __get_hash_from_flowi6(const struct flowi6 *fl6, struct flow_keys *keys)
 {
 	memset(keys, 0, sizeof(*keys));
 
@@ -806,7 +809,7 @@ __u32 __get_hash_from_flowi6(struct flowi6 *fl6, struct flow_keys *keys)
 }
 EXPORT_SYMBOL(__get_hash_from_flowi6);
 
-__u32 __get_hash_from_flowi4(struct flowi4 *fl4, struct flow_keys *keys)
+__u32 __get_hash_from_flowi4(const struct flowi4 *fl4, struct flow_keys *keys)
 {
 	memset(keys, 0, sizeof(*keys));
 
-- 
2.1.0
