From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH v2 net-next 1/2] flow dissector: ICMP support
Date: Fri,  2 Dec 2016 21:31:41 +0100
Message-ID: <1480710702-16850-2-git-send-email-simon.horman@netronome.com>
References: <1480710702-16850-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
        Veaceslav Falico <vfalico@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36760 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759550AbcLBUcM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 15:32:12 -0500
Received: by mail-wm0-f45.google.com with SMTP id g23so27647543wme.1
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 12:31:55 -0800 (PST)
In-Reply-To: <1480710702-16850-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow dissection of ICMP(V6) type and code. This re-uses transport layer
port dissection code as although ICMP is not a transport protocol and their
type and code are not ports this allows sharing of both code and storage.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/bonding/bond_main.c |  6 +++--
 include/linux/skbuff.h          |  5 +++++
 include/net/flow_dissector.h    | 50 ++++++++++++++++++++++++++++++++++++++---
 net/core/flow_dissector.c       | 34 +++++++++++++++++++++++++---
 net/sched/cls_flow.c            |  4 ++--
 5 files changed, 89 insertions(+), 10 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 8029dd4912b6..a6f75cfb2bf7 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -3181,7 +3181,8 @@ static bool bond_flow_dissect(struct bonding *bond, struct sk_buff *skb,
 	} else {
 		return false;
 	}
-	if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER34 && proto >= 0)
+	if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER34 &&
+	    proto >= 0 && !skb_flow_is_icmp_any(skb, proto))
 		fk->ports.ports = skb_flow_get_ports(skb, noff, proto);
 
 	return true;
@@ -3209,7 +3210,8 @@ u32 bond_xmit_hash(struct bonding *bond, struct sk_buff *skb)
 		return bond_eth_hash(skb);
 
 	if (bond->params.xmit_policy == BOND_XMIT_POLICY_LAYER23 ||
-	    bond->params.xmit_policy == BOND_XMIT_POLICY_ENCAP23)
+	    bond->params.xmit_policy == BOND_XMIT_POLICY_ENCAP23 ||
+	    flow_keys_are_icmp_any(&flow))
 		hash = bond_eth_hash(skb);
 	else
 		hash = (__force u32)flow.ports.ports;
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9c535fbccf2c..44a8f69a9198 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1094,6 +1094,11 @@ u32 __skb_get_poff(const struct sk_buff *skb, void *data,
 __be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
 			    void *data, int hlen_proto);
 
+static inline bool skb_flow_is_icmp_any(const struct sk_buff *skb, u8 ip_proto)
+{
+	return flow_protos_are_icmp_any(skb->protocol, ip_proto);
+}
+
 static inline __be32 skb_flow_get_ports(const struct sk_buff *skb,
 					int thoff, u8 ip_proto)
 {
diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index c4f31666afd2..5540dfa18872 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -2,6 +2,7 @@
 #define _NET_FLOW_DISSECTOR_H
 
 #include <linux/types.h>
+#include <linux/in.h>
 #include <linux/in6.h>
 #include <uapi/linux/if_ether.h>
 
@@ -89,10 +90,15 @@ struct flow_dissector_key_addrs {
 };
 
 /**
- * flow_dissector_key_tp_ports:
- *	@ports: port numbers of Transport header
+ * flow_dissector_key_ports:
+ *	@ports: port numbers of Transport header or
+ *		type and code of ICMP header
+ *		ports: source (high) and destination (low) port numbers
  *		src: source port number
  *		dst: destination port number
+ *		icmp: ICMP type (high) and code (low)
+ *		type: ICMP type
+ *		type: ICMP code
  */
 struct flow_dissector_key_ports {
 	union {
@@ -101,6 +107,11 @@ struct flow_dissector_key_ports {
 			__be16 src;
 			__be16 dst;
 		};
+		__be16 icmp;
+		struct {
+			u8 type;
+			u8 code;
+		};
 	};
 };
 
@@ -188,9 +199,42 @@ struct flow_keys_digest {
 void make_flow_keys_digest(struct flow_keys_digest *digest,
 			   const struct flow_keys *flow);
 
+static inline bool flow_protos_are_icmpv4(__be16 n_proto, u8 ip_proto)
+{
+	return n_proto == htons(ETH_P_IP) && ip_proto == IPPROTO_ICMP;
+}
+
+static inline bool flow_protos_are_icmpv6(__be16 n_proto, u8 ip_proto)
+{
+	return n_proto == htons(ETH_P_IPV6) && ip_proto == IPPROTO_ICMPV6;
+}
+
+static inline bool flow_protos_are_icmp_any(__be16 n_proto, u8 ip_proto)
+{
+	return flow_protos_are_icmpv4(n_proto, ip_proto) ||
+		flow_protos_are_icmpv6(n_proto, ip_proto);
+}
+
+static inline bool flow_basic_key_is_icmpv4(const struct flow_dissector_key_basic *basic)
+{
+	return flow_protos_are_icmpv4(basic->n_proto, basic->ip_proto);
+}
+
+static inline bool flow_basic_key_is_icmpv6(const struct flow_dissector_key_basic *basic)
+{
+	return flow_protos_are_icmpv6(basic->n_proto, basic->ip_proto);
+}
+
+static inline bool flow_keys_are_icmp_any(const struct flow_keys *keys)
+{
+	return flow_protos_are_icmp_any(keys->basic.n_proto,
+					keys->basic.ip_proto);
+}
+
 static inline bool flow_keys_have_l4(const struct flow_keys *keys)
 {
-	return (keys->ports.ports || keys->tags.flow_label);
+	return (!flow_keys_are_icmp_any(keys) && keys->ports.ports) ||
+		keys->tags.flow_label;
 }
 
 u32 flow_hash_from_keys(struct flow_keys *keys);
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 1eb6f949e5b2..0584b4bb4390 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -58,6 +58,28 @@ void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
 EXPORT_SYMBOL(skb_flow_dissector_init);
 
 /**
+ * skb_flow_get_be16 - extract be16 entity
+ * @skb: sk_buff to extract from
+ * @poff: offset to extract at
+ * @data: raw buffer pointer to the packet
+ * @hlen: packet header length
+ *
+ * The function will try to retrieve a be32 entity at
+ * offset poff
+ */
+__be16 skb_flow_get_be16(const struct sk_buff *skb, int poff, void *data,
+			 int hlen)
+{
+	__be16 *u, _u;
+
+	u = __skb_header_pointer(skb, poff, sizeof(_u), data, hlen, &_u);
+	if (u)
+		return *u;
+
+	return 0;
+}
+
+/**
  * __skb_flow_get_ports - extract the upper layer ports and return them
  * @skb: sk_buff to extract the ports from
  * @thoff: transport header offset
@@ -542,8 +564,13 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		key_ports = skb_flow_dissector_target(flow_dissector,
 						      FLOW_DISSECTOR_KEY_PORTS,
 						      target_container);
-		key_ports->ports = __skb_flow_get_ports(skb, nhoff, ip_proto,
-							data, hlen);
+		if (flow_protos_are_icmp_any(proto, ip_proto))
+			key_ports->icmp = skb_flow_get_be16(skb, nhoff, data,
+							    hlen);
+		else
+			key_ports->ports = __skb_flow_get_ports(skb, nhoff,
+								ip_proto, data,
+								hlen);
 	}
 
 out_good:
@@ -718,7 +745,8 @@ void make_flow_keys_digest(struct flow_keys_digest *digest,
 
 	data->n_proto = flow->basic.n_proto;
 	data->ip_proto = flow->basic.ip_proto;
-	data->ports = flow->ports.ports;
+	if (flow_keys_have_l4(flow))
+		data->ports = flow->ports.ports;
 	data->src = flow->addrs.v4addrs.src;
 	data->dst = flow->addrs.v4addrs.dst;
 }
diff --git a/net/sched/cls_flow.c b/net/sched/cls_flow.c
index e39672394c7b..a1a7ae71aa62 100644
--- a/net/sched/cls_flow.c
+++ b/net/sched/cls_flow.c
@@ -96,7 +96,7 @@ static u32 flow_get_proto(const struct sk_buff *skb,
 static u32 flow_get_proto_src(const struct sk_buff *skb,
 			      const struct flow_keys *flow)
 {
-	if (flow->ports.ports)
+	if (!flow_keys_are_icmp_any(flow) && flow->ports.ports)
 		return ntohs(flow->ports.src);
 
 	return addr_fold(skb->sk);
@@ -105,7 +105,7 @@ static u32 flow_get_proto_src(const struct sk_buff *skb,
 static u32 flow_get_proto_dst(const struct sk_buff *skb,
 			      const struct flow_keys *flow)
 {
-	if (flow->ports.ports)
+	if (!flow_keys_are_icmp_any(flow) && flow->ports.ports)
 		return ntohs(flow->ports.dst);
 
 	return addr_fold(skb_dst(skb)) ^ (__force u16) tc_skb_protocol(skb);
-- 
2.7.0.rc3.207.g0ac5344
