From: Thomas Graf <tgraf@suug.ch>
Subject: [RFC net-next 14/22] route: Extend flow representation with tunnel key
Date: Fri, 10 Jul 2015 16:19:16 +0200
Message-ID: <a5ad4c87f0699ef49f637c13c5c9d0942b9b02bf.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40670 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932692AbbGJOTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 10:19:45 -0400
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
In-Reply-To: <cover.1436537414.git.tgraf@suug.ch>
References: <cover.1436537414.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new flowi_tunnel structure which is a subset of ip_tunnel_key to
allow routes to match on tunnel metadata. For now, the tunnel id is
added to flowi_tunnel which allows for routes to be bound to specific
virtual tunnels.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/flow.h | 7 +++++++
 net/ipv4/route.c   | 6 ++++++
 2 files changed, 13 insertions(+)

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
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index ea48880..bf84164c 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -91,6 +91,7 @@
 #include <linux/slab.h>
 #include <linux/jhash.h>
 #include <net/dst.h>
+#include <net/dst_metadata.h>
 #include <net/net_namespace.h>
 #include <net/protocol.h>
 #include <net/ip.h>
@@ -110,6 +111,7 @@
 #include <linux/kmemleak.h>
 #endif
 #include <net/secure_seq.h>
+#include <net/ip_tunnels.h>
 
 #define RT_FL_TOS(oldflp4) \
 	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
@@ -1674,6 +1676,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 {
 	struct fib_result res;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
+	struct ip_tunnel_info *tun_info;
 	struct flowi4	fl4;
 	unsigned int	flags = 0;
 	u32		itag = 0;
@@ -1691,6 +1694,9 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	   by fib_lookup.
 	 */
 
+	tun_info = skb_tunnel_info(skb);
+	if (tun_info && tun_info->mode == IP_TUNNEL_INFO_RX)
+		fl4.flowi4_tun_key.tun_id = tun_info->key.tun_id;
 	skb_dst_drop(skb);
 
 	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr))
-- 
2.4.3
