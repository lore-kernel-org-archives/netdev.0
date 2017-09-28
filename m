From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH v4 net-next 6/8] udp: flow dissector offload
Date: Thu, 28 Sep 2017 16:52:28 -0700
Message-ID: <20170928235230.22158-7-tom@quantonium.net>
References: <20170928235230.22158-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, rohit@quantonium.net,
        Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:57213 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751933AbdI1XxJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 19:53:09 -0400
Received: by mail-pg0-f42.google.com with SMTP id 7so1769980pgd.13
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 16:53:09 -0700 (PDT)
In-Reply-To: <20170928235230.22158-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support to perform UDP specific flow dissection. This is
primarily intended for dissecting encapsulated packets in UDP
encapsulation.

This patch adds a flow_dissect offload for UDP4 and UDP6. The backend
function performs a socket lookup and calls the flow_dissect function
if a socket is found.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 include/linux/udp.h      |  8 ++++++++
 include/net/udp.h        |  8 ++++++++
 include/net/udp_tunnel.h |  8 ++++++++
 net/ipv4/udp_offload.c   | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv4/udp_tunnel.c    |  1 +
 net/ipv6/udp_offload.c   | 16 ++++++++++++++++
 6 files changed, 89 insertions(+)

diff --git a/include/linux/udp.h b/include/linux/udp.h
index eaea63bc79bb..2e90b189ef6a 100644
--- a/include/linux/udp.h
+++ b/include/linux/udp.h
@@ -79,6 +79,14 @@ struct udp_sock {
 	int			(*gro_complete)(struct sock *sk,
 						struct sk_buff *skb,
 						int nhoff);
+	/* Flow dissector function for a UDP socket */
+	enum flow_dissect_ret (*flow_dissect)(struct sock *sk,
+			const struct sk_buff *skb,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags);
 
 	/* udp_recvmsg try to use this before splicing sk_receive_queue */
 	struct sk_buff_head	reader_queue ____cacheline_aligned_in_smp;
diff --git a/include/net/udp.h b/include/net/udp.h
index c6b1c5d8d3c9..4867f329538c 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -176,6 +176,14 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
 				 struct udphdr *uh, udp_lookup_t lookup);
 int udp_gro_complete(struct sk_buff *skb, int nhoff, udp_lookup_t lookup);
 
+enum flow_dissect_ret udp_flow_dissect(struct sk_buff *skb,
+			udp_lookup_t lookup,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags);
+
 static inline struct udphdr *udp_gro_udphdr(struct sk_buff *skb)
 {
 	struct udphdr *uh;
diff --git a/include/net/udp_tunnel.h b/include/net/udp_tunnel.h
index 10cce0dd4450..b7102e0f41a9 100644
--- a/include/net/udp_tunnel.h
+++ b/include/net/udp_tunnel.h
@@ -69,6 +69,13 @@ typedef struct sk_buff **(*udp_tunnel_gro_receive_t)(struct sock *sk,
 						     struct sk_buff *skb);
 typedef int (*udp_tunnel_gro_complete_t)(struct sock *sk, struct sk_buff *skb,
 					 int nhoff);
+typedef enum flow_dissect_ret (*udp_tunnel_flow_dissect_t)(struct sock *sk,
+			const struct sk_buff *skb,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags);
 
 struct udp_tunnel_sock_cfg {
 	void *sk_user_data;     /* user data used by encap_rcv call back */
@@ -78,6 +85,7 @@ struct udp_tunnel_sock_cfg {
 	udp_tunnel_encap_destroy_t encap_destroy;
 	udp_tunnel_gro_receive_t gro_receive;
 	udp_tunnel_gro_complete_t gro_complete;
+	udp_tunnel_flow_dissect_t flow_dissect;
 };
 
 /* Setup the given (UDP) sock to receive UDP encapsulated packets */
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index a744bb515455..fddf923ef433 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -335,11 +335,59 @@ static int udp4_gro_complete(struct sk_buff *skb, int nhoff)
 	return udp_gro_complete(skb, nhoff, udp4_lib_lookup_skb);
 }
 
+enum flow_dissect_ret udp_flow_dissect(struct sk_buff *skb,
+			udp_lookup_t lookup,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags)
+{
+	enum flow_dissect_ret ret = FLOW_DISSECT_RET_CONTINUE;
+	struct udphdr *uh, _uh;
+	struct sock *sk;
+
+	uh = __skb_header_pointer(skb, *p_nhoff, sizeof(_uh), data,
+				  *p_hlen, &_uh);
+	if (!uh)
+		return FLOW_DISSECT_RET_OUT_BAD;
+
+	rcu_read_lock();
+
+	sk = (*lookup)(skb, uh->source, uh->dest);
+
+	if (sk && udp_sk(sk)->flow_dissect)
+		ret = udp_sk(sk)->flow_dissect(sk, skb, key_control,
+					       flow_dissector, target_container,
+					       data, p_proto, p_ip_proto,
+					       p_nhoff, p_hlen, flags);
+	rcu_read_unlock();
+
+	return ret;
+}
+EXPORT_SYMBOL(udp_flow_dissect);
+
+static enum flow_dissect_ret udp4_flow_dissect(struct sk_buff *skb,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags)
+{
+	if (!static_key_false(&udp_encap_needed))
+		return FLOW_DISSECT_RET_CONTINUE;
+
+	return udp_flow_dissect(skb, udp4_lib_lookup_skb, key_control,
+				flow_dissector, target_container, data,
+				p_proto, p_ip_proto, p_nhoff, p_hlen, flags);
+}
+
 static const struct net_offload udpv4_offload = {
 	.callbacks = {
 		.gso_segment = udp4_tunnel_segment,
 		.gro_receive  =	udp4_gro_receive,
 		.gro_complete =	udp4_gro_complete,
+		.flow_dissect = udp4_flow_dissect,
 	},
 };
 
diff --git a/net/ipv4/udp_tunnel.c b/net/ipv4/udp_tunnel.c
index 6539ff15e9a3..a4eec2a044d2 100644
--- a/net/ipv4/udp_tunnel.c
+++ b/net/ipv4/udp_tunnel.c
@@ -71,6 +71,7 @@ void setup_udp_tunnel_sock(struct net *net, struct socket *sock,
 	udp_sk(sk)->encap_destroy = cfg->encap_destroy;
 	udp_sk(sk)->gro_receive = cfg->gro_receive;
 	udp_sk(sk)->gro_complete = cfg->gro_complete;
+	udp_sk(sk)->flow_dissect = cfg->flow_dissect;
 
 	udp_tunnel_encap_enable(sock);
 }
diff --git a/net/ipv6/udp_offload.c b/net/ipv6/udp_offload.c
index 111b026e4f03..45b77f92d77d 100644
--- a/net/ipv6/udp_offload.c
+++ b/net/ipv6/udp_offload.c
@@ -80,11 +80,27 @@ static int udp6_gro_complete(struct sk_buff *skb, int nhoff)
 	return udp_gro_complete(skb, nhoff, udp6_lib_lookup_skb);
 }
 
+static enum flow_dissect_ret udp6_flow_dissect(struct sk_buff *skb,
+			struct flow_dissector_key_control *key_control,
+			struct flow_dissector *flow_dissector,
+			void *target_container, void *data,
+			__be16 *p_proto, u8 *p_ip_proto, int *p_nhoff,
+			int *p_hlen, unsigned int flags)
+{
+	if (!static_key_false(&udp_encap_needed))
+		return FLOW_DISSECT_RET_CONTINUE;
+
+	return udp_flow_dissect(skb, udp6_lib_lookup_skb, key_control,
+				flow_dissector, target_container, data,
+				p_proto, p_ip_proto, p_nhoff, p_hlen, flags);
+}
+
 static const struct net_offload udpv6_offload = {
 	.callbacks = {
 		.gso_segment	=	udp6_tunnel_segment,
 		.gro_receive	=	udp6_gro_receive,
 		.gro_complete	=	udp6_gro_complete,
+		.flow_dissect	=	udp6_flow_dissect,
 	},
 };
 
-- 
2.11.0
