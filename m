From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v2 net-next 3/6] flow_dissector: Add protocol specific flow dissection offload
Date: Tue, 29 Aug 2017 16:27:08 -0700
Message-ID: <20170829232711.1465-4-tom@quantonium.net>
References: <20170829232711.1465-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33519 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751757AbdH2X1i (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 19:27:38 -0400
Received: by mail-pf0-f180.google.com with SMTP id r62so14372597pfj.0
        for <netdev@vger.kernel.org>; Tue, 29 Aug 2017 16:27:38 -0700 (PDT)
In-Reply-To: <20170829232711.1465-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add offload capability for performing protocol specific flow dissection
(either by EtherType or IP protocol).

Specifically:

- Add flow_dissect to offload callbacks
- Move flow_dissect_ret enum to flow_dissector.h, cleanup names and add a
  couple of values
- Create GOTO_BY_RESULT macro to use in the main flow dissector switch to
  simplify handling of functions that return flow_dissect_ret enum
- In __skb_flow_dissect, add default case for switch(proto) as well as
  switch(ip_proto) that looks up and calls protocol specific flow
  dissection

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 include/linux/netdevice.h    |   7 +++
 include/net/flow_dissector.h |   9 +++
 net/core/dev.c               |  14 +++++
 net/core/flow_dissector.c    | 132 +++++++++++++++++++++++++++++++------------
 net/ipv4/route.c             |   4 +-
 5 files changed, 128 insertions(+), 38 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c5475b37a631..90ccb434e127 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2208,6 +2208,12 @@ struct offload_callbacks {
 	struct sk_buff		**(*gro_receive)(struct sk_buff **head,
 						 struct sk_buff *skb);
 	int			(*gro_complete)(struct sk_buff *skb, int nhoff);
+	enum flow_dissect_ret (*flow_dissect)(const struct sk_buff *skb,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags);
 };
 
 struct packet_offload {
@@ -3253,6 +3259,7 @@ struct sk_buff *napi_get_frags(struct napi_struct *napi);
 gro_result_t napi_gro_frags(struct napi_struct *napi);
 struct packet_offload *gro_find_receive_by_type(__be16 type);
 struct packet_offload *gro_find_complete_by_type(__be16 type);
+struct packet_offload *flow_dissect_find_by_type(__be16 type);
 
 static inline void napi_free_frags(struct napi_struct *napi)
 {
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index e2663e900b0a..ad75bbfd1c9c 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -19,6 +19,14 @@ struct flow_dissector_key_control {
 #define FLOW_DIS_FIRST_FRAG	BIT(1)
 #define FLOW_DIS_ENCAPSULATION	BIT(2)
 
+enum flow_dissect_ret {
+	FLOW_DISSECT_RET_OUT_GOOD,
+	FLOW_DISSECT_RET_OUT_BAD,
+	FLOW_DISSECT_RET_PROTO_AGAIN,
+	FLOW_DISSECT_RET_IPPROTO_AGAIN,
+	FLOW_DISSECT_RET_CONTINUE,
+};
+
 /**
  * struct flow_dissector_key_basic:
  * @thoff: Transport header offset
@@ -205,6 +213,7 @@ enum flow_dissector_key_id {
 #define FLOW_DISSECTOR_F_STOP_AT_L3		BIT(1)
 #define FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL	BIT(2)
 #define FLOW_DISSECTOR_F_STOP_AT_ENCAP		BIT(3)
+#define FLOW_DISSECTOR_F_STOP_AT_L4		BIT(4)
 
 struct flow_dissector_key {
 	enum flow_dissector_key_id key_id;
diff --git a/net/core/dev.c b/net/core/dev.c
index 270b54754821..22ea8daa930c 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4860,6 +4860,20 @@ struct packet_offload *gro_find_receive_by_type(__be16 type)
 }
 EXPORT_SYMBOL(gro_find_receive_by_type);
 
+struct packet_offload *flow_dissect_find_by_type(__be16 type)
+{
+	struct list_head *offload_head = &offload_base;
+	struct packet_offload *ptype;
+
+	list_for_each_entry_rcu(ptype, offload_head, list) {
+		if (ptype->type != type || !ptype->callbacks.flow_dissect)
+			continue;
+		return ptype;
+	}
+	return NULL;
+}
+EXPORT_SYMBOL(flow_dissect_find_by_type);
+
 struct packet_offload *gro_find_complete_by_type(__be16 type)
 {
 	struct list_head *offload_head = &offload_base;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 12302acdb073..6a2cf240069a 100644
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
@@ -115,12 +116,6 @@ __be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
 }
 EXPORT_SYMBOL(__skb_flow_get_ports);
 
-enum flow_dissect_ret {
-	FLOW_DISSECT_RET_OUT_GOOD,
-	FLOW_DISSECT_RET_OUT_BAD,
-	FLOW_DISSECT_RET_OUT_PROTO_AGAIN,
-};
-
 static enum flow_dissect_ret
 __skb_flow_dissect_mpls(const struct sk_buff *skb,
 			struct flow_dissector *flow_dissector,
@@ -322,7 +317,7 @@ __skb_flow_dissect_gre(const struct sk_buff *skb,
 	if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
 		return FLOW_DISSECT_RET_OUT_GOOD;
 
-	return FLOW_DISSECT_RET_OUT_PROTO_AGAIN;
+	return FLOW_DISSECT_RET_PROTO_AGAIN;
 }
 
 static void
@@ -383,6 +378,27 @@ __skb_flow_dissect_ipv6(const struct sk_buff *skb,
 	key_ip->ttl = iph->hop_limit;
 }
 
+#define GOTO_BY_RESULT(ret) do {				\
+	switch (ret) {						\
+	case FLOW_DISSECT_RET_OUT_GOOD:				\
+		goto out_good;					\
+	case FLOW_DISSECT_RET_PROTO_AGAIN:			\
+		goto proto_again;				\
+	case FLOW_DISSECT_RET_IPPROTO_AGAIN:			\
+		goto ip_proto_again;				\
+	case FLOW_DISSECT_RET_OUT_BAD:				\
+	default:						\
+		goto out_bad;					\
+	}							\
+} while (0)
+
+#define GOTO_OR_CONT_BY_RESULT(ret) do {			\
+	enum flow_dissect_ret __ret = (ret);			\
+								\
+	if (__ret != FLOW_DISSECT_RET_CONTINUE)			\
+		GOTO_BY_RESULT(__ret);				\
+} while (0)
+
 /**
  * __skb_flow_dissect - extract the flow_keys struct and return it
  * @skb: sk_buff to extract the flow from, can be NULL if the rest are specified
@@ -659,15 +675,10 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	case htons(ETH_P_MPLS_UC):
 	case htons(ETH_P_MPLS_MC):
 mpls:
-		switch (__skb_flow_dissect_mpls(skb, flow_dissector,
-						target_container, data,
-						nhoff, hlen)) {
-		case FLOW_DISSECT_RET_OUT_GOOD:
-			goto out_good;
-		case FLOW_DISSECT_RET_OUT_BAD:
-		default:
-			goto out_bad;
-		}
+		GOTO_BY_RESULT(__skb_flow_dissect_mpls(skb, flow_dissector,
+						       target_container, data,
+						       nhoff, hlen));
+
 	case htons(ETH_P_FCOE):
 		if ((hlen - nhoff) < FCOE_HEADER_LEN)
 			goto out_bad;
@@ -677,32 +688,44 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 
 	case htons(ETH_P_ARP):
 	case htons(ETH_P_RARP):
-		switch (__skb_flow_dissect_arp(skb, flow_dissector,
-					       target_container, data,
-					       nhoff, hlen)) {
-		case FLOW_DISSECT_RET_OUT_GOOD:
-			goto out_good;
-		case FLOW_DISSECT_RET_OUT_BAD:
-		default:
-			goto out_bad;
+		GOTO_BY_RESULT(__skb_flow_dissect_arp(skb, flow_dissector,
+						      target_container, data,
+						      nhoff, hlen));
+
+	default: {
+		struct packet_offload *ptype;
+		enum flow_dissect_ret ret;
+
+		rcu_read_lock();
+
+		ptype = flow_dissect_find_by_type(proto);
+
+		if (ptype) {
+			ret = ptype->callbacks.flow_dissect(skb, key_control,
+						flow_dissector,
+						target_container,
+						data, &proto, &ip_proto, &nhoff,
+						&hlen, flags);
+			rcu_read_unlock();
+
+			GOTO_BY_RESULT(ret);
+		} else {
+			rcu_read_unlock();
 		}
-	default:
+
 		goto out_bad;
 	}
+	}
 
 ip_proto_again:
 	switch (ip_proto) {
 	case IPPROTO_GRE:
-		switch (__skb_flow_dissect_gre(skb, key_control, flow_dissector,
-					       target_container, data,
-					       &proto, &nhoff, &hlen, flags)) {
-		case FLOW_DISSECT_RET_OUT_GOOD:
-			goto out_good;
-		case FLOW_DISSECT_RET_OUT_BAD:
-			goto out_bad;
-		case FLOW_DISSECT_RET_OUT_PROTO_AGAIN:
-			goto proto_again;
-		}
+		GOTO_BY_RESULT(__skb_flow_dissect_gre(skb, key_control,
+						      flow_dissector,
+						      target_container, data,
+						      &proto, &nhoff, &hlen,
+						      flags));
+
 	case NEXTHDR_HOP:
 	case NEXTHDR_ROUTING:
 	case NEXTHDR_DEST: {
@@ -768,9 +791,43 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		__skb_flow_dissect_tcp(skb, flow_dissector, target_container,
 				       data, nhoff, hlen);
 		break;
-	default:
+	default: {
+		const struct net_offload *ops = NULL;
+
+		if (flags & FLOW_DISSECTOR_F_STOP_AT_L4)
+			break;
+
+		rcu_read_lock();
+
+		switch (proto) {
+		case htons(ETH_P_IP):
+			ops = rcu_dereference(inet_offloads[ip_proto]);
+			break;
+		case htons(ETH_P_IPV6):
+			ops = rcu_dereference(inet6_offloads[ip_proto]);
+			break;
+		default:
+			break;
+		}
+
+		if (ops && ops->callbacks.flow_dissect) {
+			enum flow_dissect_ret ret;
+
+			ret = ops->callbacks.flow_dissect(skb, key_control,
+						flow_dissector,
+						target_container,
+						data, &proto, &ip_proto, &nhoff,
+						&hlen, flags);
+			rcu_read_unlock();
+
+			GOTO_OR_CONT_BY_RESULT(ret);
+		} else {
+			rcu_read_unlock();
+		}
+
 		break;
 	}
+	}
 
 	if (dissector_uses_key(flow_dissector,
 			       FLOW_DISSECTOR_KEY_PORTS)) {
@@ -935,7 +992,8 @@ static inline u32 ___skb_get_hash(const struct sk_buff *skb,
 				  struct flow_keys *keys, u32 keyval)
 {
 	skb_flow_dissect_flow_keys(skb, keys,
-				   FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL);
+				   FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL |
+				   FLOW_DISSECTOR_F_STOP_AT_L4);
 
 	return __flow_hash_from_keys(keys, keyval);
 }
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 94d4cd2d5ea4..85f12b8e0b7f 100644
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
