From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v6 net-next 04/11] net: Get skb hash over flow_keys structure
Date: Thu, 4 Jun 2015 09:16:39 -0700
Message-ID: <1433434606-527444-5-git-send-email-tom@herbertland.com>
References: <1433434606-527444-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:30318 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753521AbbFDQRI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 12:17:08 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t54GDuTS021887
	for <netdev@vger.kernel.org>; Thu, 4 Jun 2015 09:17:08 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1utr5mgc8c-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 04 Jun 2015 09:17:08 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.63) with ESMTP	id
 24742f080ad511e5a1cf0002c992ebde-4e7fd280 for <netdev@vger.kernel.org>;	Thu,
 04 Jun 2015 09:17:06 -0700
In-Reply-To: <1433434606-527444-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes flow hashing to use jhash2 over the flow_keys
structure instead just doing jhash_3words over src, dst, and ports.
This method will allow us take more input into the hashing function
so that we can include full IPv6 addresses, VLAN, flow labels etc.
without needing to resort to xor'ing which makes for a poor hash.

Acked-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/skbuff.h       |  2 +-
 include/net/flow_dissector.h | 21 ++++++++++++++---
 include/net/ip.h             |  2 ++
 include/net/ipv6.h           |  2 ++
 net/core/flow_dissector.c    | 54 +++++++++++++++++++++++++++++++++-----------
 net/sched/cls_flower.c       |  2 ++
 6 files changed, 66 insertions(+), 17 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 6b41c15..cc612fc 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1943,7 +1943,7 @@ static inline void skb_probe_transport_header(struct sk_buff *skb,
 	if (skb_transport_header_was_set(skb))
 		return;
 	else if (skb_flow_dissect_flow_keys(skb, &keys))
-		skb_set_transport_header(skb, keys.basic.thoff);
+		skb_set_transport_header(skb, keys.control.thoff);
 	else
 		skb_set_transport_header(skb, offset_hint);
 }
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index bac9c14..cba6a10 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -7,15 +7,24 @@
 #include <uapi/linux/if_ether.h>
 
 /**
+ * struct flow_dissector_key_control:
+ * @thoff: Transport header offset
+ */
+struct flow_dissector_key_control {
+	u16	thoff;
+	u16	padding;
+};
+
+/**
  * struct flow_dissector_key_basic:
  * @thoff: Transport header offset
  * @n_proto: Network header protocol (eg. IPv4/IPv6)
  * @ip_proto: Transport header protocol (eg. TCP/UDP)
  */
 struct flow_dissector_key_basic {
-	u16	thoff;
 	__be16	n_proto;
 	u8	ip_proto;
+	u8	padding;
 };
 
 /**
@@ -70,6 +79,7 @@ struct flow_dissector_key_eth_addrs {
 };
 
 enum flow_dissector_key_id {
+	FLOW_DISSECTOR_KEY_CONTROL, /* struct flow_dissector_key_control */
 	FLOW_DISSECTOR_KEY_BASIC, /* struct flow_dissector_key_basic */
 	FLOW_DISSECTOR_KEY_IPV4_ADDRS, /* struct flow_dissector_key_addrs */
 	FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS, /* struct flow_dissector_key_addrs */
@@ -109,11 +119,16 @@ static inline bool skb_flow_dissect(const struct sk_buff *skb,
 }
 
 struct flow_keys {
-	struct flow_dissector_key_addrs addrs;
-	struct flow_dissector_key_ports ports;
+	struct flow_dissector_key_control control;
+#define FLOW_KEYS_HASH_START_FIELD basic
 	struct flow_dissector_key_basic basic;
+	struct flow_dissector_key_ports ports;
+	struct flow_dissector_key_addrs addrs;
 };
 
+#define FLOW_KEYS_HASH_OFFSET		\
+	offsetof(struct flow_keys, FLOW_KEYS_HASH_START_FIELD)
+
 extern struct flow_dissector flow_keys_dissector;
 extern struct flow_dissector flow_keys_buf_dissector;
 
diff --git a/include/net/ip.h b/include/net/ip.h
index 9b976cf..16cfc87 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -360,6 +360,8 @@ static inline void inet_set_txhash(struct sock *sk)
 	struct inet_sock *inet = inet_sk(sk);
 	struct flow_keys keys;
 
+	memset(&keys, 0, sizeof(keys));
+
 	keys.addrs.src = inet->inet_saddr;
 	keys.addrs.dst = inet->inet_daddr;
 	keys.ports.src = inet->inet_sport;
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 35d485c..474ca46 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -699,6 +699,8 @@ static inline void ip6_set_txhash(struct sock *sk)
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct flow_keys keys;
 
+	memset(&keys, 0, sizeof(keys));
+
 	keys.addrs.src = (__force __be32)ipv6_addr_hash(&np->saddr);
 	keys.addrs.dst = (__force __be32)ipv6_addr_hash(&sk->sk_v6_daddr);
 	keys.ports.src = inet->inet_sport;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 0763795..55b5f29 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -57,10 +57,12 @@ void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
 		flow_dissector->offset[key->key_id] = key->offset;
 	}
 
-	/* Ensure that the dissector always includes basic key. That way
-	 * we are able to avoid handling lack of it in fast path.
+	/* Ensure that the dissector always includes control and basic key.
+	 * That way we are able to avoid handling lack of these in fast path.
 	 */
 	BUG_ON(!skb_flow_dissector_uses_key(flow_dissector,
+					    FLOW_DISSECTOR_KEY_CONTROL));
+	BUG_ON(!skb_flow_dissector_uses_key(flow_dissector,
 					    FLOW_DISSECTOR_KEY_BASIC));
 }
 EXPORT_SYMBOL(skb_flow_dissector_init);
@@ -120,6 +122,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 			void *target_container,
 			void *data, __be16 proto, int nhoff, int hlen)
 {
+	struct flow_dissector_key_control *key_control;
 	struct flow_dissector_key_basic *key_basic;
 	struct flow_dissector_key_addrs *key_addrs;
 	struct flow_dissector_key_ports *key_ports;
@@ -132,6 +135,13 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		hlen = skb_headlen(skb);
 	}
 
+	/* It is ensured by skb_flow_dissector_init() that control key will
+	 * be always present.
+	 */
+	key_control = skb_flow_dissector_target(flow_dissector,
+						FLOW_DISSECTOR_KEY_CONTROL,
+						target_container);
+
 	/* It is ensured by skb_flow_dissector_init() that basic key will
 	 * be always present.
 	 */
@@ -219,7 +229,7 @@ flow_label:
 
 			key_basic->n_proto = proto;
 			key_basic->ip_proto = ip_proto;
-			key_basic->thoff = (u16)nhoff;
+			key_control->thoff = (u16)nhoff;
 
 			if (skb_flow_dissector_uses_key(flow_dissector,
 							FLOW_DISSECTOR_KEY_PORTS)) {
@@ -275,7 +285,7 @@ flow_label:
 		if (!hdr)
 			return false;
 		key_basic->n_proto = proto;
-		key_basic->thoff = (u16)nhoff;
+		key_control->thoff = (u16)nhoff;
 
 		if (skb_flow_dissector_uses_key(flow_dissector,
 						FLOW_DISSECTOR_KEY_IPV6_HASH_ADDRS)) {
@@ -288,7 +298,7 @@ flow_label:
 		return true;
 	}
 	case htons(ETH_P_FCOE):
-		key_basic->thoff = (u16)(nhoff + FCOE_HEADER_LEN);
+		key_control->thoff = (u16)(nhoff + FCOE_HEADER_LEN);
 		/* fall through */
 	default:
 		return false;
@@ -345,7 +355,7 @@ flow_label:
 
 	key_basic->n_proto = proto;
 	key_basic->ip_proto = ip_proto;
-	key_basic->thoff = (u16) nhoff;
+	key_control->thoff = (u16)nhoff;
 
 	if (skb_flow_dissector_uses_key(flow_dissector,
 					FLOW_DISSECTOR_KEY_PORTS)) {
@@ -366,9 +376,21 @@ static __always_inline void __flow_hash_secret_init(void)
 	net_get_random_once(&hashrnd, sizeof(hashrnd));
 }
 
-static __always_inline u32 __flow_hash_3words(u32 a, u32 b, u32 c, u32 keyval)
+static __always_inline u32 __flow_hash_words(u32 *words, u32 length, u32 keyval)
+{
+	return jhash2(words, length, keyval);
+}
+
+static inline void *flow_keys_hash_start(struct flow_keys *flow)
 {
-	return jhash_3words(a, b, c, keyval);
+	BUILD_BUG_ON(FLOW_KEYS_HASH_OFFSET % sizeof(u32));
+	return (void *)flow + FLOW_KEYS_HASH_OFFSET;
+}
+
+static inline size_t flow_keys_hash_length(struct flow_keys *flow)
+{
+	BUILD_BUG_ON((sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) % sizeof(u32));
+	return (sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) / sizeof(u32);
 }
 
 static inline u32 __flow_hash_from_keys(struct flow_keys *keys, u32 keyval)
@@ -383,10 +405,8 @@ static inline u32 __flow_hash_from_keys(struct flow_keys *keys, u32 keyval)
 		swap(keys->ports.src, keys->ports.dst);
 	}
 
-	hash = __flow_hash_3words((__force u32)keys->addrs.dst,
-				  (__force u32)keys->addrs.src,
-				  (__force u32)keys->ports.ports,
-				  keyval);
+	hash = __flow_hash_words((u32 *)flow_keys_hash_start(keys),
+				 flow_keys_hash_length(keys), keyval);
 	if (!hash)
 		hash = 1;
 
@@ -473,7 +493,7 @@ EXPORT_SYMBOL(skb_get_hash_perturb);
 u32 __skb_get_poff(const struct sk_buff *skb, void *data,
 		   const struct flow_keys *keys, int hlen)
 {
-	u32 poff = keys->basic.thoff;
+	u32 poff = keys->control.thoff;
 
 	switch (keys->basic.ip_proto) {
 	case IPPROTO_TCP: {
@@ -537,6 +557,10 @@ u32 skb_get_poff(const struct sk_buff *skb)
 
 static const struct flow_dissector_key flow_keys_dissector_keys[] = {
 	{
+		.key_id = FLOW_DISSECTOR_KEY_CONTROL,
+		.offset = offsetof(struct flow_keys, control),
+	},
+	{
 		.key_id = FLOW_DISSECTOR_KEY_BASIC,
 		.offset = offsetof(struct flow_keys, basic),
 	},
@@ -556,6 +580,10 @@ static const struct flow_dissector_key flow_keys_dissector_keys[] = {
 
 static const struct flow_dissector_key flow_keys_buf_dissector_keys[] = {
 	{
+		.key_id = FLOW_DISSECTOR_KEY_CONTROL,
+		.offset = offsetof(struct flow_keys, control),
+	},
+	{
 		.key_id = FLOW_DISSECTOR_KEY_BASIC,
 		.offset = offsetof(struct flow_keys, basic),
 	},
diff --git a/net/sched/cls_flower.c b/net/sched/cls_flower.c
index 8c8f34e..5a7d66c 100644
--- a/net/sched/cls_flower.c
+++ b/net/sched/cls_flower.c
@@ -25,6 +25,7 @@
 
 struct fl_flow_key {
 	int	indev_ifindex;
+	struct flow_dissector_key_control control;
 	struct flow_dissector_key_basic basic;
 	struct flow_dissector_key_eth_addrs eth;
 	union {
@@ -347,6 +348,7 @@ static void fl_init_dissector(struct cls_fl_head *head,
 	struct flow_dissector_key keys[FLOW_DISSECTOR_KEY_MAX];
 	size_t cnt = 0;
 
+	FL_KEY_SET(keys, cnt, FLOW_DISSECTOR_KEY_CONTROL, control);
 	FL_KEY_SET(keys, cnt, FLOW_DISSECTOR_KEY_BASIC, basic);
 	FL_KEY_SET_IF_IN_RANGE(mask, keys, cnt,
 			       FLOW_DISSECTOR_KEY_ETH_ADDRS, eth);
-- 
1.8.1
