From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 01/11] flow_dissector: Move skb related functions to skbuff.h
Date: Tue, 1 Sep 2015 09:24:23 -0700
Message-ID: <1441124673-3438470-2-git-send-email-tom@herbertland.com>
References: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:64794 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751172AbbIAQZH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:25:07 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t81GNTr7006950
	for <netdev@vger.kernel.org>; Tue, 1 Sep 2015 09:25:06 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wnf6p03cq-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 09:25:06 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 00c5c49050c611e5b4920002c99331b0-5fbfc240 for <netdev@vger.kernel.org>;	Tue,
 01 Sep 2015 09:25:05 -0700
In-Reply-To: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the flow dissector functions that are specific to skbuffs into
skbuff.h out of flow_dissector.h. This makes flow_dissector.h have
no dependencies on skbuff.h.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/skbuff.h       | 47 +++++++++++++++++++++++++++++++++++++++++
 include/net/flow_dissector.h | 50 --------------------------------------------
 2 files changed, 47 insertions(+), 50 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 989307f9..8a697c6 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -945,6 +945,53 @@ skb_set_hash(struct sk_buff *skb, __u32 hash, enum pkt_hash_types type)
 	skb->hash = hash;
 }
 
+void __skb_get_hash(struct sk_buff *skb);
+u32 skb_get_poff(const struct sk_buff *skb);
+u32 __skb_get_poff(const struct sk_buff *skb, void *data,
+		   const struct flow_keys *keys, int hlen);
+__be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
+			    void *data, int hlen_proto);
+
+static inline __be32 skb_flow_get_ports(const struct sk_buff *skb,
+					int thoff, u8 ip_proto)
+{
+	return __skb_flow_get_ports(skb, thoff, ip_proto, NULL, 0);
+}
+
+void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
+			     const struct flow_dissector_key *key,
+			     unsigned int key_count);
+
+bool __skb_flow_dissect(const struct sk_buff *skb,
+			struct flow_dissector *flow_dissector,
+			void *target_container,
+			void *data, __be16 proto, int nhoff, int hlen);
+
+static inline bool skb_flow_dissect(const struct sk_buff *skb,
+				    struct flow_dissector *flow_dissector,
+				    void *target_container)
+{
+	return __skb_flow_dissect(skb, flow_dissector, target_container,
+				  NULL, 0, 0, 0);
+}
+
+static inline bool skb_flow_dissect_flow_keys(const struct sk_buff *skb,
+					      struct flow_keys *flow)
+{
+	memset(flow, 0, sizeof(*flow));
+	return __skb_flow_dissect(skb, &flow_keys_dissector, flow,
+				  NULL, 0, 0, 0);
+}
+
+static inline bool skb_flow_dissect_flow_keys_buf(struct flow_keys *flow,
+						  void *data, __be16 proto,
+						  int nhoff, int hlen)
+{
+	memset(flow, 0, sizeof(*flow));
+	return __skb_flow_dissect(NULL, &flow_keys_buf_dissector, flow,
+				  data, proto, nhoff, hlen);
+}
+
 static inline __u32 skb_get_hash(struct sk_buff *skb)
 {
 	if (!skb->l4_hash && !skb->sw_hash)
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 1a8c224..6777a84 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -2,7 +2,6 @@
 #define _NET_FLOW_DISSECTOR_H
 
 #include <linux/types.h>
-#include <linux/skbuff.h>
 #include <linux/in6.h>
 #include <uapi/linux/if_ether.h>
 
@@ -134,23 +133,6 @@ struct flow_dissector {
 	unsigned short int offset[FLOW_DISSECTOR_KEY_MAX];
 };
 
-void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
-			     const struct flow_dissector_key *key,
-			     unsigned int key_count);
-
-bool __skb_flow_dissect(const struct sk_buff *skb,
-			struct flow_dissector *flow_dissector,
-			void *target_container,
-			void *data, __be16 proto, int nhoff, int hlen);
-
-static inline bool skb_flow_dissect(const struct sk_buff *skb,
-				    struct flow_dissector *flow_dissector,
-				    void *target_container)
-{
-	return __skb_flow_dissect(skb, flow_dissector, target_container,
-				  NULL, 0, 0, 0);
-}
-
 struct flow_keys {
 	struct flow_dissector_key_control control;
 #define FLOW_KEYS_HASH_START_FIELD basic
@@ -170,38 +152,6 @@ __be32 flow_get_u32_dst(const struct flow_keys *flow);
 extern struct flow_dissector flow_keys_dissector;
 extern struct flow_dissector flow_keys_buf_dissector;
 
-static inline bool skb_flow_dissect_flow_keys(const struct sk_buff *skb,
-					      struct flow_keys *flow)
-{
-	memset(flow, 0, sizeof(*flow));
-	return __skb_flow_dissect(skb, &flow_keys_dissector, flow,
-				  NULL, 0, 0, 0);
-}
-
-static inline bool skb_flow_dissect_flow_keys_buf(struct flow_keys *flow,
-						  void *data, __be16 proto,
-						  int nhoff, int hlen)
-{
-	memset(flow, 0, sizeof(*flow));
-	return __skb_flow_dissect(NULL, &flow_keys_buf_dissector, flow,
-				  data, proto, nhoff, hlen);
-}
-
-__be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
-			    void *data, int hlen_proto);
-
-static inline __be32 skb_flow_get_ports(const struct sk_buff *skb,
-					int thoff, u8 ip_proto)
-{
-	return __skb_flow_get_ports(skb, thoff, ip_proto, NULL, 0);
-}
-
-u32 flow_hash_from_keys(struct flow_keys *keys);
-void __skb_get_hash(struct sk_buff *skb);
-u32 skb_get_poff(const struct sk_buff *skb);
-u32 __skb_get_poff(const struct sk_buff *skb, void *data,
-		   const struct flow_keys *keys, int hlen);
-
 /* struct flow_keys_digest:
  *
  * This structure is used to hold a digest of the full flow keys. This is a
-- 
1.8.1
