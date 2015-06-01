From: Thomas Graf <tgraf@suug.ch>
Subject: [net-next RFC 04/14] route: Extend flow representation with tunnel key
Date: Mon,  1 Jun 2015 16:27:28 +0200
Message-ID: <f881e0452e2dd3090ca90ae7f04d528872acdfd5.1433167295.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Cc: pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, dev@openvswitch.org, tom@herbertland.com,
	edumazet@google.com, jiri@resnulli.us, hannes@stressinduktion.org,
	marcelo.leitner@gmail.com, stephen@networkplumber.org,
	jpettit@nicira.com, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:50927 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751234AbbFAO1r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jun 2015 10:27:47 -0400
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
In-Reply-To: <cover.1433167295.git.tgraf@suug.ch>
References: <cover.1433167295.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new flowi_tunnel structure which is a subset of ip_tunnel_key
to allow routes to match on tunnel metadata. For now, the tunnel id
is added to flowi_tunnel which allows for routes to be bound to
specific virtual tunnels.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/flow.h       |  7 +++++++
 include/net/ip_tunnels.h | 10 ++++++++++
 net/ipv4/route.c         |  2 ++
 3 files changed, 19 insertions(+)

diff --git a/include/net/flow.h b/include/net/flow.h
index 8109a15..c15fb5e 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -19,6 +19,10 @@
 
 #define LOOPBACK_IFINDEX	1
 
+struct flowi_tunnel {
+	__be64			tun_id;
+};
+
 struct flowi_common {
 	int	flowic_oif;
 	int	flowic_iif;
@@ -30,6 +34,7 @@ struct flowi_common {
 #define FLOWI_FLAG_ANYSRC		0x01
 #define FLOWI_FLAG_KNOWN_NH		0x02
 	__u32	flowic_secid;
+	struct flowi_tunnel flowic_tun_key;
 };
 
 union flowi_uli {
@@ -66,6 +71,7 @@ struct flowi4 {
 #define flowi4_proto		__fl_common.flowic_proto
 #define flowi4_flags		__fl_common.flowic_flags
 #define flowi4_secid		__fl_common.flowic_secid
+#define flowi4_tun_key		__fl_common.flowic_tun_key
 
 	/* (saddr,daddr) must be grouped, same order as in IP header */
 	__be32			saddr;
@@ -165,6 +171,7 @@ struct flowi {
 #define flowi_proto	u.__fl_common.flowic_proto
 #define flowi_flags	u.__fl_common.flowic_flags
 #define flowi_secid	u.__fl_common.flowic_secid
+#define flowi_tun_key	u.__fl_common.flowic_tun_key
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 static inline struct flowi *flowi4_to_flowi(struct flowi4 *fl4)
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 8b76ba1..df8cfd3 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -12,6 +12,7 @@
 #include <net/ip.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
+#include <net/flow.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
 #include <net/ipv6.h>
@@ -337,6 +338,15 @@ static inline void *ip_tunnel_info_opts(struct ip_tunnel_info *info,
 	return info + 1;
 }
 
+static inline void ip_tunnel_derive_key(struct sk_buff *skb,
+					struct flowi_tunnel *key)
+{
+	struct ip_tunnel_info *tun_info = skb_shinfo(skb)->tun_info;
+
+	if (tun_info && tun_info->mode == IP_TUNNEL_INFO_RX)
+		key->tun_id = tun_info->key.tun_id;
+}
+
 #endif /* CONFIG_INET */
 
 #endif /* __NET_IP_TUNNELS_H */
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f605598..6e8e1be 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -109,6 +109,7 @@
 #include <linux/kmemleak.h>
 #endif
 #include <net/secure_seq.h>
+#include <net/ip_tunnels.h>
 
 #define RT_FL_TOS(oldflp4) \
 	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
@@ -1716,6 +1717,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
 	fl4.daddr = daddr;
 	fl4.saddr = saddr;
+	ip_tunnel_derive_key(skb, &fl4.flowi4_tun_key);
 	err = fib_lookup(net, &fl4, &res);
 	if (err != 0) {
 		if (!IN_DEV_FORWARD(in_dev))
-- 
2.3.5
