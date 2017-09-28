From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v3 net-next 4/8] flow_dissector: Add protocol specific flow dissection offload
Date: Thu, 28 Sep 2017 14:48:19 -0700
Message-ID: <20170928214823.2426-4-tom@quantonium.net>
References: <20170928214823.2426-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:47535 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751042AbdI1Vsr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 17:48:47 -0400
Received: by mail-pg0-f46.google.com with SMTP id d8so1642580pgt.4
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 14:48:47 -0700 (PDT)
In-Reply-To: <20170928214823.2426-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add offload capability for performing protocol specific flow dissection
(either by EtherType or IP protocol).

Specifically:

- Add flow_dissect to offload callbacks
- Move flow_dissect_ret enum to flow_dissector.h, cleanup names and add a
  couple of values
- Unify handling of functions that return flow_dissect_ret enum
- In __skb_flow_dissect, add default case for switch(proto) as well as
  switch(ip_proto) that looks up and calls protocol specific flow
  dissection

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 include/linux/netdevice.h    | 27 ++++++++++++++++++
 include/net/flow_dissector.h |  1 +
 net/core/dev.c               | 65 ++++++++++++++++++++++++++++++++++++++++++++
 net/core/flow_dissector.c    | 16 +++++++++--
 net/ipv4/route.c             |  4 ++-
 5 files changed, 110 insertions(+), 3 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f535779d9dc1..565d7cdfe967 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2207,12 +2207,25 @@ struct offload_callbacks {
 	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
 						 struct sk_buff *skb);
 	int			(*gro_complete)(struct sk_buff *skb, int nhoff);
+	enum flow_dissect_ret (*flow_dissect)(struct sk_buff *skb,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags);
 };
 
 struct packet_offload {
 	__be16			 type;	/* This is really htons(ether_type). */
 	u16			 priority;
 	struct offload_callbacks callbacks;
+	enum flow_dissect_ret (*proto_flow_dissect)(struct sk_buff *skb,
+			u8 proto,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags);
 	struct list_head	 list;
 };
 
@@ -3252,6 +3265,20 @@ struct sk_buff *napi_get_frags(struct napi_struct *napi);
 gro_result_t napi_gro_frags(struct napi_struct *napi);
 struct packet_offload *gro_find_receive_by_type(__be16 type);
 struct packet_offload *gro_find_complete_by_type(__be16 type);
+enum flow_dissect_ret flow_dissect_by_type(struct sk_buff *skb,
+			__be16 type,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags);
+enum flow_dissect_ret flow_dissect_by_type_proto(struct sk_buff *skb,
+			__be16 type, u8 proto,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags);
 
 static inline void napi_free_frags(struct napi_struct *napi)
 {
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index fc3dce730a6b..ad75bbfd1c9c 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -213,6 +213,7 @@ enum flow_dissector_key_id {
 #define FLOW_DISSECTOR_F_STOP_AT_L3		BIT(1)
 #define FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL	BIT(2)
 #define FLOW_DISSECTOR_F_STOP_AT_ENCAP		BIT(3)
+#define FLOW_DISSECTOR_F_STOP_AT_L4		BIT(4)
 
 struct flow_dissector_key {
 	enum flow_dissector_key_id key_id;
diff --git a/net/core/dev.c b/net/core/dev.c
index e350c768d4b5..f3cd884bd04b 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -104,6 +104,7 @@
 #include <linux/stat.h>
 #include <net/dst.h>
 #include <net/dst_metadata.h>
+#include <net/flow_dissector.h>
 #include <net/pkt_sched.h>
 #include <net/pkt_cls.h>
 #include <net/checksum.h>
@@ -4907,6 +4908,70 @@ struct packet_offload *gro_find_complete_by_type(__be16 type)
 }
 EXPORT_SYMBOL(gro_find_complete_by_type);
 
+enum flow_dissect_ret flow_dissect_by_type(struct sk_buff *skb,
+			__be16 type,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags)
+{
+	enum flow_dissect_ret ret = FLOW_DISSECT_RET_CONTINUE;
+	struct list_head *offload_head = &offload_base;
+	struct packet_offload *ptype;
+
+	rcu_read_lock();
+
+	list_for_each_entry_rcu(ptype, offload_head, list) {
+		if (ptype->type != type || !ptype->callbacks.flow_dissect)
+			continue;
+		ret = ptype->callbacks.flow_dissect(skb, key_control,
+						    flow_dissector,
+						    target_container,
+						    data, p_proto,
+						    p_ip_proto, p_nhoff,
+						    p_hlen, flags);
+		break;
+	}
+
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL(flow_dissect_by_type);
+
+enum flow_dissect_ret flow_dissect_by_type_proto(struct sk_buff *skb,
+			__be16 type, u8 proto,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags)
+{
+	enum flow_dissect_ret ret = FLOW_DISSECT_RET_CONTINUE;
+	struct list_head *offload_head = &offload_base;
+	struct packet_offload *ptype;
+
+	rcu_read_lock();
+
+	list_for_each_entry_rcu(ptype, offload_head, list) {
+		if (ptype->type != type || !ptype->proto_flow_dissect)
+			continue;
+		ret = ptype->proto_flow_dissect(skb, proto, key_control,
+						    flow_dissector,
+						    target_container,
+						    data, p_proto,
+						    p_ip_proto, p_nhoff,
+						    p_hlen, flags);
+		break;
+	}
+
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL(flow_dissect_by_type_proto);
+
 static void napi_skb_free_stolen_head(struct sk_buff *skb)
 {
 	skb_dst_drop(skb);
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index c15b41f96cbe..84b8eb1f6664 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -9,6 +9,7 @@
 #include <net/ipv6.h>
 #include <net/gre.h>
 #include <net/pptp.h>
+#include <net/protocol.h>
 #include <linux/igmp.h>
 #include <linux/icmp.h>
 #include <linux/sctp.h>
@@ -721,7 +722,11 @@ bool __skb_flow_dissect(struct sk_buff *skb,
 		break;
 
 	default:
-		fdret = FLOW_DISSECT_RET_OUT_BAD;
+		fdret = flow_dissect_by_type(skb, proto, key_control,
+					     flow_dissector,
+					     target_container,
+					     data, &proto, &ip_proto, &nhoff,
+					     &hlen, flags);
 		break;
 	}
 
@@ -838,6 +843,12 @@ bool __skb_flow_dissect(struct sk_buff *skb,
 		break;
 
 	default:
+		fdret = flow_dissect_by_type_proto(skb, proto,
+						ip_proto, key_control,
+						flow_dissector,
+						target_container,
+						data, &proto, &ip_proto, &nhoff,
+						&hlen, flags);
 		break;
 	}
 
@@ -1022,7 +1033,8 @@ static inline u32 ___skb_get_hash(struct sk_buff *skb,
 				  struct flow_keys *keys, u32 keyval)
 {
 	skb_flow_dissect_flow_keys(skb, keys,
-				   FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL);
+				   FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL |
+				   FLOW_DISSECTOR_F_STOP_AT_L4);
 
 	return __flow_hash_from_keys(keys, keyval);
 }
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 94c5b81d8f2b..69d6ce7dfa18 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -1811,7 +1811,9 @@ int fib_multipath_hash(const struct fib_info *fi, const struct flowi4 *fl4,
 	case 1:
 		/* skb is currently provided only when forwarding */
 		if (skb) {
-			unsigned int flag = FLOW_DISSECTOR_F_STOP_AT_ENCAP;
+			unsigned int flag = FLOW_DISSECTOR_F_STOP_AT_ENCAP |
+					    FLOW_DISSECTOR_F_STOP_AT_L4;
+;
 			struct flow_keys keys;
 
 			/* short-circuit if we already have L4 hash present */
-- 
2.11.0
