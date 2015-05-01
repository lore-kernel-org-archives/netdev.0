From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 1/7] net: Add skb_get_hash_perturb
Date: Fri, 1 May 2015 11:30:12 -0700
Message-ID: <1430505018-496801-2-git-send-email-tom@herbertland.com>
References: <1430505018-496801-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:7658 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751388AbbEASab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 May 2015 14:30:31 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t41IRgwJ016506
	for <netdev@vger.kernel.org>; Fri, 1 May 2015 11:30:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1u4e72860c-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 01 May 2015 11:30:31 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 248f8038f03011e490790002c95209d8-79ad2240 for <netdev@vger.kernel.org>;	Fri,
 01 May 2015 11:30:29 -0700
In-Reply-To: <1430505018-496801-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This calls flow_disect and __skb_get_hash to procure a hash for a
packet. Input includes a key to initialize jhash. This function
does not set skb->hash.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/skbuff.h    |  2 ++
 net/core/flow_dissector.c | 38 ++++++++++++++++++++++++++++++--------
 2 files changed, 32 insertions(+), 8 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 66e374d..acb83e2 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -927,6 +927,8 @@ static inline __u32 skb_get_hash(struct sk_buff *skb)
 	return skb->hash;
 }
 
+__u32 skb_get_hash_perturb(const struct sk_buff *skb, u32 perturb);
+
 static inline __u32 skb_get_hash_raw(const struct sk_buff *skb)
 {
 	return skb->hash;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 2c35c02..b1df995 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -267,13 +267,12 @@ static __always_inline void __flow_hash_secret_init(void)
 	net_get_random_once(&hashrnd, sizeof(hashrnd));
 }
 
-static __always_inline u32 __flow_hash_3words(u32 a, u32 b, u32 c)
+static __always_inline u32 __flow_hash_3words(u32 a, u32 b, u32 c, u32 keyval)
 {
-	__flow_hash_secret_init();
-	return jhash_3words(a, b, c, hashrnd);
+	return jhash_3words(a, b, c, keyval);
 }
 
-static inline u32 __flow_hash_from_keys(struct flow_keys *keys)
+static inline u32 __flow_hash_from_keys(struct flow_keys *keys, u32 keyval)
 {
 	u32 hash;
 
@@ -287,7 +286,8 @@ static inline u32 __flow_hash_from_keys(struct flow_keys *keys)
 
 	hash = __flow_hash_3words((__force u32)keys->dst,
 				  (__force u32)keys->src,
-				  (__force u32)keys->ports);
+				  (__force u32)keys->ports,
+				  keyval);
 	if (!hash)
 		hash = 1;
 
@@ -296,10 +296,20 @@ static inline u32 __flow_hash_from_keys(struct flow_keys *keys)
 
 u32 flow_hash_from_keys(struct flow_keys *keys)
 {
-	return __flow_hash_from_keys(keys);
+	__flow_hash_secret_init();
+	return __flow_hash_from_keys(keys, hashrnd);
 }
 EXPORT_SYMBOL(flow_hash_from_keys);
 
+static inline u32 ___skb_get_hash(const struct sk_buff *skb,
+				  struct flow_keys *keys, u32 keyval)
+{
+	if (!skb_flow_dissect(skb, keys))
+		return 0;
+
+	return __flow_hash_from_keys(keys, keyval);
+}
+
 /*
  * __skb_get_hash: calculate a flow hash based on src/dst addresses
  * and src/dst port numbers.  Sets hash in skb to non-zero hash value
@@ -309,8 +319,12 @@ EXPORT_SYMBOL(flow_hash_from_keys);
 void __skb_get_hash(struct sk_buff *skb)
 {
 	struct flow_keys keys;
+	u32 hash;
 
-	if (!skb_flow_dissect(skb, &keys))
+	__flow_hash_secret_init();
+
+	hash = ___skb_get_hash(skb, &keys, hashrnd);
+	if (!hash)
 		return;
 
 	if (keys.ports)
@@ -318,10 +332,18 @@ void __skb_get_hash(struct sk_buff *skb)
 
 	skb->sw_hash = 1;
 
-	skb->hash = __flow_hash_from_keys(&keys);
+	skb->hash = hash;
 }
 EXPORT_SYMBOL(__skb_get_hash);
 
+__u32 skb_get_hash_perturb(const struct sk_buff *skb, u32 perturb)
+{
+	struct flow_keys keys;
+
+	return ___skb_get_hash(skb, &keys, perturb);
+}
+EXPORT_SYMBOL(skb_get_hash_perturb);
+
 /*
  * Returns a Tx hash based on the given packet descriptor a Tx queues' number
  * to be used as a distribution range.
-- 
1.8.1
