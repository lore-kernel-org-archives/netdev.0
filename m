From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v2 net-next 1/5] net: Add functions to get skb->hash based on flow structures
Date: Fri, 31 Jul 2015 16:52:10 -0700
Message-ID: <1438386734-1942188-2-git-send-email-tom@herbertland.com>
References: <1438386734-1942188-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:26595 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752373AbbGaXzs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 19:55:48 -0400
Received: from pps.filterd (m0044010 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t6VNtVbK025597
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 16:55:47 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1w0gj70c2p-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 16:55:47 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 a94a3a6037df11e5bb6f0002c9dfb610-93ffa2b0 for <netdev@vger.kernel.org>;	Fri,
 31 Jul 2015 16:55:46 -0700
In-Reply-To: <1438386734-1942188-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add skb_get_hash_flowi6 and skb_get_hash_flowi4 which derive an sk_buff
hash from flowi6 and flowi4 structures respectively. These functions
can be called when creating a packet in the output path where the new
sk_buff does not yet contain a fully formed packet that is parsable by
flow dissector.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/linux/skbuff.h    | 21 +++++++++++++++++
 net/core/flow_dissector.c | 58 +++++++++++++++++++++++++++++++++++++++++++----
 2 files changed, 75 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 648a2c2..b7c1286 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -37,6 +37,7 @@
 #include <net/flow_dissector.h>
 #include <linux/splice.h>
 #include <linux/in6.h>
+#include <net/flow.h>
 
 /* A. Checksumming of received packets by device.
  *
@@ -945,6 +946,26 @@ static inline __u32 skb_get_hash(struct sk_buff *skb)
 	return skb->hash;
 }
 
+__u32 __skb_get_hash_flowi6(struct sk_buff *skb, struct flowi6 *fl6);
+
+static inline __u32 skb_get_hash_flowi6(struct sk_buff *skb, struct flowi6 *fl6)
+{
+	if (!skb->l4_hash && !skb->sw_hash)
+		__skb_get_hash_flowi6(skb, fl6);
+
+	return skb->hash;
+}
+
+__u32 __skb_get_hash_flowi4(struct sk_buff *skb, struct flowi4 *fl);
+
+static inline __u32 skb_get_hash_flowi4(struct sk_buff *skb, struct flowi4 *fl4)
+{
+	if (!skb->l4_hash && !skb->sw_hash)
+		__skb_get_hash_flowi4(skb, fl4);
+
+	return skb->hash;
+}
+
 __u32 skb_get_hash_perturb(const struct sk_buff *skb, u32 perturb);
 
 static inline __u32 skb_get_hash_raw(const struct sk_buff *skb)
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 2a834c6..11e6540 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -590,6 +590,15 @@ void make_flow_keys_digest(struct flow_keys_digest *digest,
 }
 EXPORT_SYMBOL(make_flow_keys_digest);
 
+static inline void __skb_set_sw_hash(struct sk_buff *skb, u32 hash,
+				     struct flow_keys *keys)
+{
+	if (keys->ports.ports)
+		skb->l4_hash = 1;
+	skb->sw_hash = 1;
+	skb->hash = hash;
+}
+
 /**
  * __skb_get_hash: calculate a flow hash
  * @skb: sk_buff to calculate flow hash from
@@ -609,10 +618,8 @@ void __skb_get_hash(struct sk_buff *skb)
 	hash = ___skb_get_hash(skb, &keys, hashrnd);
 	if (!hash)
 		return;
-	if (keys.ports.ports)
-		skb->l4_hash = 1;
-	skb->sw_hash = 1;
-	skb->hash = hash;
+
+	__skb_set_sw_hash(skb, hash, &keys);
 }
 EXPORT_SYMBOL(__skb_get_hash);
 
@@ -624,6 +631,49 @@ __u32 skb_get_hash_perturb(const struct sk_buff *skb, u32 perturb)
 }
 EXPORT_SYMBOL(skb_get_hash_perturb);
 
+__u32 __skb_get_hash_flowi6(struct sk_buff *skb, struct flowi6 *fl6)
+{
+	struct flow_keys keys;
+
+	memset(&keys, 0, sizeof(keys));
+
+	memcpy(&keys.addrs.v6addrs.src, &fl6->saddr,
+	       sizeof(keys.addrs.v6addrs.src));
+	memcpy(&keys.addrs.v6addrs.dst, &fl6->daddr,
+	       sizeof(keys.addrs.v6addrs.dst));
+	keys.control.addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
+	keys.ports.src = fl6->fl6_sport;
+	keys.ports.dst = fl6->fl6_dport;
+	keys.keyid.keyid = fl6->fl6_gre_key;
+	keys.tags.flow_label = (__force u32)fl6->flowlabel;
+	keys.basic.ip_proto = fl6->flowi6_proto;
+
+	__skb_set_sw_hash(skb, flow_hash_from_keys(&keys), &keys);
+
+	return skb->hash;
+}
+EXPORT_SYMBOL(__skb_get_hash_flowi6);
+
+__u32 __skb_get_hash_flowi4(struct sk_buff *skb, struct flowi4 *fl4)
+{
+	struct flow_keys keys;
+
+	memset(&keys, 0, sizeof(keys));
+
+	keys.addrs.v4addrs.src = fl4->saddr;
+	keys.addrs.v4addrs.dst = fl4->daddr;
+	keys.control.addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
+	keys.ports.src = fl4->fl4_sport;
+	keys.ports.dst = fl4->fl4_dport;
+	keys.keyid.keyid = fl4->fl4_gre_key;
+	keys.basic.ip_proto = fl4->flowi4_proto;
+
+	__skb_set_sw_hash(skb, flow_hash_from_keys(&keys), &keys);
+
+	return skb->hash;
+}
+EXPORT_SYMBOL(__skb_get_hash_flowi4);
+
 u32 __skb_get_poff(const struct sk_buff *skb, void *data,
 		   const struct flow_keys *keys, int hlen)
 {
-- 
1.8.5.6
