From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v3 net-next 5/8] ip: Add callbacks to flow dissection by IP protocol
Date: Thu, 28 Sep 2017 14:48:20 -0700
Message-ID: <20170928214823.2426-5-tom@quantonium.net>
References: <20170928214823.2426-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:55069 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751710AbdI1Vst (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 17:48:49 -0400
Received: by mail-pf0-f174.google.com with SMTP id d187so1498296pfg.11
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 14:48:49 -0700 (PDT)
In-Reply-To: <20170928214823.2426-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Populate the proto_flow_dissect function for IPv4 and IPv6 packet
offloads. This allows the caller to flow dissect a packet starting
at the given IP protocol (as parsed to that point by flow dissector
for instance).

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 net/ipv4/af_inet.c     | 27 +++++++++++++++++++++++++++
 net/ipv6/ip6_offload.c | 27 +++++++++++++++++++++++++++
 2 files changed, 54 insertions(+)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index e31108e5ef79..18c1d884999a 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1440,6 +1440,32 @@ static struct sk_buff **ipip_gro_receive(struct sk_buff **head,
 	return inet_gro_receive(head, skb);
 }
 
+static enum flow_dissect_ret inet_proto_flow_dissect(struct sk_buff *skb,
+			u8 proto,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags)
+{
+	enum flow_dissect_ret ret = FLOW_DISSECT_RET_CONTINUE;
+	const struct net_offload *ops;
+
+	rcu_read_lock();
+
+	ops = rcu_dereference(inet_offloads[proto]);
+	if (ops && ops->callbacks.flow_dissect)
+		ret =  ops->callbacks.flow_dissect(skb, key_control,
+						   flow_dissector,
+						   target_container,
+						   data, p_proto, p_ip_proto,
+						   p_nhoff, p_hlen, flags);
+
+	rcu_read_unlock();
+
+	return ret;
+}
+
 #define SECONDS_PER_DAY	86400
 
 /* inet_current_timestamp - Return IP network timestamp
@@ -1763,6 +1789,7 @@ static int ipv4_proc_init(void);
 
 static struct packet_offload ip_packet_offload __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IP),
+	.proto_flow_dissect = inet_proto_flow_dissect,
 	.callbacks = {
 		.gso_segment = inet_gso_segment,
 		.gro_receive = inet_gro_receive,
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index cdb3728faca7..a33a2b40b3d6 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -339,8 +339,35 @@ static int ip4ip6_gro_complete(struct sk_buff *skb, int nhoff)
 	return inet_gro_complete(skb, nhoff);
 }
 
+static enum flow_dissect_ret inet6_proto_flow_dissect(struct sk_buff *skb,
+			u8 proto,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags)
+{
+	enum flow_dissect_ret ret = FLOW_DISSECT_RET_CONTINUE;
+	const struct net_offload *ops;
+
+	rcu_read_lock();
+
+	ops = rcu_dereference(inet6_offloads[proto]);
+	if (ops && ops->callbacks.flow_dissect)
+		ret =  ops->callbacks.flow_dissect(skb, key_control,
+						   flow_dissector,
+						   target_container, data,
+						   p_proto, p_ip_proto, p_nhoff,
+						   p_hlen, flags);
+
+	rcu_read_unlock();
+
+	return ret;
+}
+
 static struct packet_offload ipv6_packet_offload __read_mostly = {
 	.type = cpu_to_be16(ETH_P_IPV6),
+	.proto_flow_dissect = inet6_proto_flow_dissect,
 	.callbacks = {
 		.gso_segment = ipv6_gso_segment,
 		.gro_receive = ipv6_gro_receive,
-- 
2.11.0
