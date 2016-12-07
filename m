From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH net-next v3 1/2] flow dissector: ICMP support
Date: Wed, 7 Dec 2016 11:01:48 +0100
Message-ID: <20161207100148.GA1987@nanopsycho>
References: <1481103697-19835-1-git-send-email-simon.horman@netronome.com>
 <1481103697-19835-2-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@mellanox.com>, Tom Herbert <tom@herbertland.com>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34508 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932222AbcLGKBw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 05:01:52 -0500
Received: by mail-wm0-f66.google.com with SMTP id g23so26781835wme.1
        for <netdev@vger.kernel.org>; Wed, 07 Dec 2016 02:01:51 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1481103697-19835-2-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Dec 07, 2016 at 10:41:36AM CET, simon.horman@netronome.com wrote:
>Allow dissection of ICMP(V6) type and code. This should only occur
>if a packet is ICMP(V6) and the dissector has FLOW_DISSECTOR_KEY_ICMP set.
>
>There are currently no users of FLOW_DISSECTOR_KEY_ICMP.
>A follow-up patch will allow FLOW_DISSECTOR_KEY_ICMP to be used by
>the flower classifier.
>---
>v3
>* Add FLOW_DISSECTOR_KEY_ICMP and use separate structure for ICMP, struct
>  flow_dissector_key_icmp, which is a union with struct
>  flow_dissector_key_ports in struct flow_keys.
>* Drop checks for !ICMP before accessing port field
>
>v2
>* Include all helpers in this patch
>---
> include/net/flow_dissector.h | 55 +++++++++++++++++++++++++++++++++++++++++++-
> net/core/flow_dissector.c    | 49 +++++++++++++++++++++++++++++++++------
> 2 files changed, 96 insertions(+), 8 deletions(-)
>
>diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
>index c4f31666afd2..aefb7a8138a6 100644
>--- a/include/net/flow_dissector.h
>+++ b/include/net/flow_dissector.h
>@@ -2,6 +2,7 @@
> #define _NET_FLOW_DISSECTOR_H
> 
> #include <linux/types.h>
>+#include <linux/in.h>
> #include <linux/in6.h>
> #include <uapi/linux/if_ether.h>
> 
>@@ -104,6 +105,22 @@ struct flow_dissector_key_ports {
> 	};
> };
> 
>+/**
>+ * flow_dissector_key_icmp:
>+ *	@ports: type and code of ICMP header
>+ *		icmp: ICMP type (high) and code (low)
>+ *		type: ICMP type
>+ *		code: ICMP code
>+ */
>+struct flow_dissector_key_icmp {
>+	union {
>+		__be16 icmp;
>+		struct {
>+			u8 type;
>+			u8 code;
>+		};
>+	};
>+};
> 
> /**
>  * struct flow_dissector_key_eth_addrs:
>@@ -122,6 +139,7 @@ enum flow_dissector_key_id {
> 	FLOW_DISSECTOR_KEY_IPV4_ADDRS, /* struct flow_dissector_key_ipv4_addrs */
> 	FLOW_DISSECTOR_KEY_IPV6_ADDRS, /* struct flow_dissector_key_ipv6_addrs */
> 	FLOW_DISSECTOR_KEY_PORTS, /* struct flow_dissector_key_ports */
>+	FLOW_DISSECTOR_KEY_ICMP, /* struct flow_dissector_key_icmp */
> 	FLOW_DISSECTOR_KEY_ETH_ADDRS, /* struct flow_dissector_key_eth_addrs */
> 	FLOW_DISSECTOR_KEY_TIPC_ADDRS, /* struct flow_dissector_key_tipc_addrs */
> 	FLOW_DISSECTOR_KEY_VLAN, /* struct flow_dissector_key_flow_vlan */
>@@ -160,7 +178,10 @@ struct flow_keys {
> 	struct flow_dissector_key_tags tags;
> 	struct flow_dissector_key_vlan vlan;
> 	struct flow_dissector_key_keyid keyid;
>-	struct flow_dissector_key_ports ports;
>+	union {
>+		struct flow_dissector_key_ports ports;
>+		struct flow_dissector_key_icmp icmp;
>+	};

Why? You don't need this here.


> 	struct flow_dissector_key_addrs addrs;
> };
> 
>@@ -188,6 +209,38 @@ struct flow_keys_digest {
> void make_flow_keys_digest(struct flow_keys_digest *digest,
> 			   const struct flow_keys *flow);
> 
>+static inline bool flow_protos_are_icmpv4(__be16 n_proto, u8 ip_proto)
>+{
>+	return n_proto == htons(ETH_P_IP) && ip_proto == IPPROTO_ICMP;
>+}
>+
>+static inline bool flow_protos_are_icmpv6(__be16 n_proto, u8 ip_proto)
>+{
>+	return n_proto == htons(ETH_P_IPV6) && ip_proto == IPPROTO_ICMPV6;
>+}
>+
>+static inline bool flow_protos_are_icmp_any(__be16 n_proto, u8 ip_proto)
>+{
>+	return flow_protos_are_icmpv4(n_proto, ip_proto) ||
>+		flow_protos_are_icmpv6(n_proto, ip_proto);
>+}
>+
>+static inline bool flow_basic_key_is_icmpv4(const struct flow_dissector_key_basic *basic)
>+{
>+	return flow_protos_are_icmpv4(basic->n_proto, basic->ip_proto);
>+}
>+
>+static inline bool flow_basic_key_is_icmpv6(const struct flow_dissector_key_basic *basic)
>+{
>+	return flow_protos_are_icmpv6(basic->n_proto, basic->ip_proto);
>+}
>+
>+static inline bool flow_keys_are_icmp_any(const struct flow_keys *keys)
>+{
>+	return flow_protos_are_icmp_any(keys->basic.n_proto,
>+					keys->basic.ip_proto);
>+}
>+
> static inline bool flow_keys_have_l4(const struct flow_keys *keys)
> {
> 	return (keys->ports.ports || keys->tags.flow_label);
>diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>index 1eb6f949e5b2..e37ff021a19e 100644
>--- a/net/core/flow_dissector.c
>+++ b/net/core/flow_dissector.c
>@@ -58,6 +58,28 @@ void skb_flow_dissector_init(struct flow_dissector *flow_dissector,
> EXPORT_SYMBOL(skb_flow_dissector_init);
> 
> /**
>+ * skb_flow_get_be16 - extract be16 entity
>+ * @skb: sk_buff to extract from
>+ * @poff: offset to extract at
>+ * @data: raw buffer pointer to the packet
>+ * @hlen: packet header length
>+ *
>+ * The function will try to retrieve a be32 entity at
>+ * offset poff
>+ */
>+__be16 skb_flow_get_be16(const struct sk_buff *skb, int poff, void *data,
>+			 int hlen)
>+{
>+	__be16 *u, _u;
>+
>+	u = __skb_header_pointer(skb, poff, sizeof(_u), data, hlen, &_u);
>+	if (u)
>+		return *u;
>+
>+	return 0;
>+}
>+
>+/**
>  * __skb_flow_get_ports - extract the upper layer ports and return them
>  * @skb: sk_buff to extract the ports from
>  * @thoff: transport header offset
>@@ -117,6 +139,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
> 	struct flow_dissector_key_basic *key_basic;
> 	struct flow_dissector_key_addrs *key_addrs;
> 	struct flow_dissector_key_ports *key_ports;
>+	struct flow_dissector_key_icmp *key_icmp;
> 	struct flow_dissector_key_tags *key_tags;
> 	struct flow_dissector_key_vlan *key_vlan;
> 	struct flow_dissector_key_keyid *key_keyid;
>@@ -537,13 +560,25 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
> 		break;
> 	}
> 
>-	if (dissector_uses_key(flow_dissector,
>-			       FLOW_DISSECTOR_KEY_PORTS)) {
>-		key_ports = skb_flow_dissector_target(flow_dissector,
>-						      FLOW_DISSECTOR_KEY_PORTS,
>-						      target_container);
>-		key_ports->ports = __skb_flow_get_ports(skb, nhoff, ip_proto,
>-							data, hlen);
>+	if (flow_protos_are_icmp_any(proto, ip_proto)) {

You don't need this.

Just left FLOW_DISSECTOR_KEY_PORTS untouched, and add:

	if (dissector_uses_key(flow_dissector,
			       FLOW_DISSECTOR_KEY_ICMP)) {
			....


>+		if (dissector_uses_key(flow_dissector,
>+				       FLOW_DISSECTOR_KEY_ICMP)) {
>+			key_icmp = skb_flow_dissector_target(flow_dissector,
>+							     FLOW_DISSECTOR_KEY_ICMP,
>+							     target_container);
>+			key_icmp->icmp = skb_flow_get_be16(skb, nhoff, data,
>+							   hlen);
>+		}
>+	} else {
>+		if (dissector_uses_key(flow_dissector,
>+				       FLOW_DISSECTOR_KEY_PORTS)) {
>+			key_ports = skb_flow_dissector_target(flow_dissector,
>+							      FLOW_DISSECTOR_KEY_PORTS,
>+							      target_container);
>+			key_ports->ports = __skb_flow_get_ports(skb, nhoff,
>+								ip_proto, data,
>+								hlen);
>+		}
> 	}
> 
> out_good:
>-- 
>2.7.0.rc3.207.g0ac5344
>
