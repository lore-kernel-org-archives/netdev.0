From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 02/11] skbuff: Make __skb_set_sw_hash a general function
Date: Tue, 1 Sep 2015 09:24:24 -0700
Message-ID: <1441124673-3438470-3-git-send-email-tom@herbertland.com>
References: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:61936 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751172AbbIAQZJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:25:09 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t81GKCNd000417
	for <netdev@vger.kernel.org>; Tue, 1 Sep 2015 09:25:09 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1wnake8ma7-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 09:25:09 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 02645db650c611e5b4920002c99331b0-5fbfc240 for <netdev@vger.kernel.org>;	Tue,
 01 Sep 2015 09:25:07 -0700
In-Reply-To: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move __skb_set_sw_hash to skbuff.h and add __skb_set_hash which is
a common method (between __skb_set_sw_hash and skb_set_hash) to set
the hash in an skbuff.

Also, move skb_clear_hash to be closer to __skb_set_hash.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/skbuff.h       | 45 ++++++++++++++++++++++++++++----------------
 include/net/flow_dissector.h |  5 +++++
 net/core/flow_dissector.c    | 18 ++++++------------
 3 files changed, 40 insertions(+), 28 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 8a697c6..5d2c812 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -937,14 +937,40 @@ enum pkt_hash_types {
 	PKT_HASH_TYPE_L4,	/* Input: src_IP, dst_IP, src_port, dst_port */
 };
 
-static inline void
-skb_set_hash(struct sk_buff *skb, __u32 hash, enum pkt_hash_types type)
+static inline void skb_clear_hash(struct sk_buff *skb)
 {
-	skb->l4_hash = (type == PKT_HASH_TYPE_L4);
+	skb->hash = 0;
 	skb->sw_hash = 0;
+	skb->l4_hash = 0;
+}
+
+static inline void skb_clear_hash_if_not_l4(struct sk_buff *skb)
+{
+	if (!skb->l4_hash)
+		skb_clear_hash(skb);
+}
+
+static inline void
+__skb_set_hash(struct sk_buff *skb, __u32 hash, bool is_sw, bool is_l4)
+{
+	skb->l4_hash = is_l4;
+	skb->sw_hash = is_sw;
 	skb->hash = hash;
 }
 
+static inline void
+skb_set_hash(struct sk_buff *skb, __u32 hash, enum pkt_hash_types type)
+{
+	/* Used by drivers to set hash from HW */
+	__skb_set_hash(skb, hash, false, type == PKT_HASH_TYPE_L4);
+}
+
+static inline void
+__skb_set_sw_hash(struct sk_buff *skb, __u32 hash, bool is_l4)
+{
+	__skb_set_hash(skb, hash, true, is_l4);
+}
+
 void __skb_get_hash(struct sk_buff *skb);
 u32 skb_get_poff(const struct sk_buff *skb);
 u32 __skb_get_poff(const struct sk_buff *skb, void *data,
@@ -1027,19 +1053,6 @@ static inline __u32 skb_get_hash_raw(const struct sk_buff *skb)
 	return skb->hash;
 }
 
-static inline void skb_clear_hash(struct sk_buff *skb)
-{
-	skb->hash = 0;
-	skb->sw_hash = 0;
-	skb->l4_hash = 0;
-}
-
-static inline void skb_clear_hash_if_not_l4(struct sk_buff *skb)
-{
-	if (!skb->l4_hash)
-		skb_clear_hash(skb);
-}
-
 static inline void skb_copy_hash(struct sk_buff *to, const struct sk_buff *from)
 {
 	to->hash = from->hash;
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 6777a84..af76c49 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -167,4 +167,9 @@ struct flow_keys_digest {
 void make_flow_keys_digest(struct flow_keys_digest *digest,
 			   const struct flow_keys *flow);
 
+static inline bool flow_keys_have_l4(struct flow_keys *keys)
+{
+	return (keys->ports.ports || keys->tags.flow_label);
+}
+
 #endif
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 11e6540..151b6e4 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -590,15 +590,6 @@ void make_flow_keys_digest(struct flow_keys_digest *digest,
 }
 EXPORT_SYMBOL(make_flow_keys_digest);
 
-static inline void __skb_set_sw_hash(struct sk_buff *skb, u32 hash,
-				     struct flow_keys *keys)
-{
-	if (keys->ports.ports)
-		skb->l4_hash = 1;
-	skb->sw_hash = 1;
-	skb->hash = hash;
-}
-
 /**
  * __skb_get_hash: calculate a flow hash
  * @skb: sk_buff to calculate flow hash from
@@ -619,7 +610,8 @@ void __skb_get_hash(struct sk_buff *skb)
 	if (!hash)
 		return;
 
-	__skb_set_sw_hash(skb, hash, &keys);
+	__skb_set_sw_hash(skb, hash,
+			  flow_keys_have_l4(&keys));
 }
 EXPORT_SYMBOL(__skb_get_hash);
 
@@ -648,7 +640,8 @@ __u32 __skb_get_hash_flowi6(struct sk_buff *skb, struct flowi6 *fl6)
 	keys.tags.flow_label = (__force u32)fl6->flowlabel;
 	keys.basic.ip_proto = fl6->flowi6_proto;
 
-	__skb_set_sw_hash(skb, flow_hash_from_keys(&keys), &keys);
+	__skb_set_sw_hash(skb, flow_hash_from_keys(&keys),
+			  flow_keys_have_l4(&keys));
 
 	return skb->hash;
 }
@@ -668,7 +661,8 @@ __u32 __skb_get_hash_flowi4(struct sk_buff *skb, struct flowi4 *fl4)
 	keys.keyid.keyid = fl4->fl4_gre_key;
 	keys.basic.ip_proto = fl4->flowi4_proto;
 
-	__skb_set_sw_hash(skb, flow_hash_from_keys(&keys), &keys);
+	__skb_set_sw_hash(skb, flow_hash_from_keys(&keys),
+			  flow_keys_have_l4(&keys));
 
 	return skb->hash;
 }
-- 
1.8.1
