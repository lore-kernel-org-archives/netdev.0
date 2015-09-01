From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 03/11] flowi: Abstract out functions to get flow hash based on flowi
Date: Tue, 1 Sep 2015 09:24:25 -0700
Message-ID: <1441124673-3438470-4-git-send-email-tom@herbertland.com>
References: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:30702 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753410AbbIAQZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:25:12 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t81GNShB006937
	for <netdev@vger.kernel.org>; Tue, 1 Sep 2015 09:25:11 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wnf6p03d6-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 09:25:11 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 03d360ac50c611e5b4920002c99331b0-5fbfc240 for <netdev@vger.kernel.org>;	Tue,
 01 Sep 2015 09:25:10 -0700
In-Reply-To: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create __get_hash_from_flowi6 and __get_hash_from_flowi4 to get the
flow keys and hash based on flowi structures. These are called by
__skb_get_hash_flowi6 and __skb_get_hash_flowi4. Also, created
get_hash_from_flowi6 and get_hash_from_flowi4 which can be called
when just the hash value for a flowi is needed.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/skbuff.h       | 16 ++++++++++++----
 include/net/flow.h           | 19 +++++++++++++++++++
 include/net/flow_dissector.h |  2 ++
 net/core/flow.c              | 36 ++++++++++++++++++++++++++++++++++++
 4 files changed, 69 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5d2c812..bbe41bc 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1030,8 +1030,12 @@ __u32 __skb_get_hash_flowi6(struct sk_buff *skb, struct flowi6 *fl6);
 
 static inline __u32 skb_get_hash_flowi6(struct sk_buff *skb, struct flowi6 *fl6)
 {
-	if (!skb->l4_hash && !skb->sw_hash)
-		__skb_get_hash_flowi6(skb, fl6);
+	if (!skb->l4_hash && !skb->sw_hash) {
+		struct flow_keys keys;
+
+		__skb_set_sw_hash(skb, __get_hash_from_flowi6(fl6, &keys),
+				  flow_keys_have_l4(&keys));
+	}
 
 	return skb->hash;
 }
@@ -1040,8 +1044,12 @@ __u32 __skb_get_hash_flowi4(struct sk_buff *skb, struct flowi4 *fl);
 
 static inline __u32 skb_get_hash_flowi4(struct sk_buff *skb, struct flowi4 *fl4)
 {
-	if (!skb->l4_hash && !skb->sw_hash)
-		__skb_get_hash_flowi4(skb, fl4);
+	if (!skb->l4_hash && !skb->sw_hash) {
+		struct flow_keys keys;
+
+		__skb_set_sw_hash(skb, __get_hash_from_flowi4(fl4, &keys),
+				  flow_keys_have_l4(&keys));
+	}
 
 	return skb->hash;
 }
diff --git a/include/net/flow.h b/include/net/flow.h
index 9e0297c..dafe97c 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -10,6 +10,7 @@
 #include <linux/socket.h>
 #include <linux/in6.h>
 #include <linux/atomic.h>
+#include <net/flow_dissector.h>
 
 /*
  * ifindex generation is per-net namespace, and loopback is
@@ -243,4 +244,22 @@ void flow_cache_flush(struct net *net);
 void flow_cache_flush_deferred(struct net *net);
 extern atomic_t flow_cache_genid;
 
+__u32 __get_hash_from_flowi6(struct flowi6 *fl6, struct flow_keys *keys);
+
+static inline __u32 get_hash_from_flowi6(struct flowi6 *fl6)
+{
+	struct flow_keys keys;
+
+	return __get_hash_from_flowi6(fl6, &keys);
+}
+
+__u32 __get_hash_from_flowi4(struct flowi4 *fl4, struct flow_keys *keys);
+
+static inline __u32 get_hash_from_flowi4(struct flowi4 *fl4)
+{
+	struct flow_keys keys;
+
+	return __get_hash_from_flowi4(fl4, &keys);
+}
+
 #endif
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index af76c49..74fe160 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -172,4 +172,6 @@ static inline bool flow_keys_have_l4(struct flow_keys *keys)
 	return (keys->ports.ports || keys->tags.flow_label);
 }
 
+u32 flow_hash_from_keys(struct flow_keys *keys);
+
 #endif
diff --git a/net/core/flow.c b/net/core/flow.c
index 1033725..61930bb 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -22,6 +22,7 @@
 #include <linux/cpumask.h>
 #include <linux/mutex.h>
 #include <net/flow.h>
+#include <net/flow_dissector.h>
 #include <linux/atomic.h>
 #include <linux/security.h>
 #include <net/net_namespace.h>
@@ -509,3 +510,38 @@ void flow_cache_fini(struct net *net)
 	fc->percpu = NULL;
 }
 EXPORT_SYMBOL(flow_cache_fini);
+
+__u32 __get_hash_from_flowi6(struct flowi6 *fl6, struct flow_keys *keys)
+{
+	memset(keys, 0, sizeof(*keys));
+
+	memcpy(&keys->addrs.v6addrs.src, &fl6->saddr,
+	    sizeof(keys->addrs.v6addrs.src));
+	memcpy(&keys->addrs.v6addrs.dst, &fl6->daddr,
+	    sizeof(keys->addrs.v6addrs.dst));
+	keys->control.addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
+	keys->ports.src = fl6->fl6_sport;
+	keys->ports.dst = fl6->fl6_dport;
+	keys->keyid.keyid = fl6->fl6_gre_key;
+	keys->tags.flow_label = (__force u32)fl6->flowlabel;
+	keys->basic.ip_proto = fl6->flowi6_proto;
+
+	return flow_hash_from_keys(keys);
+}
+EXPORT_SYMBOL(__get_hash_from_flowi6);
+
+__u32 __get_hash_from_flowi4(struct flowi4 *fl4, struct flow_keys *keys)
+{
+	memset(keys, 0, sizeof(*keys));
+
+	keys->addrs.v4addrs.src = fl4->saddr;
+	keys->addrs.v4addrs.dst = fl4->daddr;
+	keys->control.addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
+	keys->ports.src = fl4->fl4_sport;
+	keys->ports.dst = fl4->fl4_dport;
+	keys->keyid.keyid = fl4->fl4_gre_key;
+	keys->basic.ip_proto = fl4->flowi4_proto;
+
+	return flow_hash_from_keys(keys);
+}
+EXPORT_SYMBOL(__get_hash_from_flowi4);
-- 
1.8.1
