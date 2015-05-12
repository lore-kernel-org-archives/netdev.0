From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 1/5] net: Get skb hash over flow_keys structure
Date: Mon, 11 May 2015 20:26:40 -0700
Message-ID: <1431401204-731380-2-git-send-email-tom@herbertland.com>
References: <1431401204-731380-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:29675 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752315AbbELD1q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2015 23:27:46 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4C3PP3L005609
	for <netdev@vger.kernel.org>; Mon, 11 May 2015 20:27:46 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1ub7dn0caq-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 11 May 2015 20:27:46 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.232.59) with ESMTP	id
 da523b6cf85611e481240002c991e86a-9dfe51e0 for <netdev@vger.kernel.org>;	Mon,
 11 May 2015 20:27:44 -0700
In-Reply-To: <1431401204-731380-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes flow hashing to use jhash2 over the flow_keys
structure instead just doing jhash_3words over src, dst, and ports.
This method will allow us take more input into the hashing function
so that we can include full IPv6 addresses, VLAN, flow labels etc.
without needing to resort to xor'ing which makes for a poor hash.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/flow_keys.h   | 12 +++++++++---
 net/core/flow_dissector.c | 20 ++++++++++++++------
 2 files changed, 23 insertions(+), 9 deletions(-)

diff --git a/include/net/flow_keys.h b/include/net/flow_keys.h
index 6d6ef62..5907472 100644
--- a/include/net/flow_keys.h
+++ b/include/net/flow_keys.h
@@ -15,6 +15,12 @@
  * All the members, except thoff, are in network byte order.
  */
 struct flow_keys {
+	u16	thoff;
+#define FLOW_KEYS_HASH_START_FIELD	n_proto
+	__be16	n_proto;
+	u8	ip_proto;
+	u8	padding;
+
 	/* (src,dst) must be grouped, in the same way than in IP header */
 	__be32 src;
 	__be32 dst;
@@ -22,11 +28,11 @@ struct flow_keys {
 		__be32 ports;
 		__be16 port16[2];
 	};
-	u16	thoff;
-	__be16	n_proto;
-	u8	ip_proto;
 };
 
+#define FLOW_KEYS_HASH_OFFSET		\
+	offsetof(struct flow_keys, FLOW_KEYS_HASH_START_FIELD)
+
 bool __skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow,
 			void *data, __be16 proto, int nhoff, int hlen);
 static inline bool skb_flow_dissect(const struct sk_buff *skb, struct flow_keys *flow)
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index d3acc4d..02c5104 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -267,9 +267,19 @@ static __always_inline void __flow_hash_secret_init(void)
 	net_get_random_once(&hashrnd, sizeof(hashrnd));
 }
 
-static __always_inline u32 __flow_hash_3words(u32 a, u32 b, u32 c, u32 keyval)
+static __always_inline u32 __flow_hash_words(u32 *words, u32 length, u32 keyval)
 {
-	return jhash_3words(a, b, c, keyval);
+	return jhash2(words, length, keyval);
+}
+
+static inline void *flow_keys_hash_start(struct flow_keys *flow)
+{
+	return (void *)flow + FLOW_KEYS_HASH_OFFSET;
+}
+
+static inline size_t flow_keys_hash_length(struct flow_keys *flow)
+{
+	return (sizeof(*flow) - FLOW_KEYS_HASH_OFFSET) / sizeof(u32);
 }
 
 static inline u32 __flow_hash_from_keys(struct flow_keys *keys, u32 keyval)
@@ -284,10 +294,8 @@ static inline u32 __flow_hash_from_keys(struct flow_keys *keys, u32 keyval)
 		swap(keys->port16[0], keys->port16[1]);
 	}
 
-	hash = __flow_hash_3words((__force u32)keys->dst,
-				  (__force u32)keys->src,
-				  (__force u32)keys->ports,
-				  keyval);
+	hash = __flow_hash_words((u32 *)flow_keys_hash_start(keys),
+				 flow_keys_hash_length(keys), keyval);
 	if (!hash)
 		hash = 1;
 
-- 
1.8.1
