From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH net-next 15/22] route: Extend flow representation with tunnel key
Date: Tue, 21 Jul 2015 10:43:59 +0200
Message-ID: <4ddc4d8086ea817a91caa87e33e2441c8de7f500.1437468140.git.tgraf@suug.ch>
References: <cover.1437468140.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	simon.horman@netronome.com, joestringer@nicira.com, ja@ssi.bg,
	ast@plumgrid.com, weichunc@plumgrid.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:40107 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754227AbbGUIo3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 04:44:29 -0400
In-Reply-To: <cover.1437468140.git.tgraf@suug.ch>
In-Reply-To: <cover.1437468140.git.tgraf@suug.ch>
References: <cover.1437468140.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new flowi_tunnel structure which is a subset of ip_tunnel_key to
allow routes to match on tunnel metadata. For now, the tunnel id is
added to flowi_tunnel which allows for routes to be bound to specific
virtual tunnels.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 include/net/flow.h      | 8 ++++++++
 net/ipv4/fib_frontend.c | 2 ++
 net/ipv4/route.c        | 8 ++++++++
 3 files changed, 18 insertions(+)

diff --git a/include/net/flow.h b/include/net/flow.h
index 8109a15..3098ae3 100644
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
@@ -95,6 +101,7 @@ static inline void flowi4_init_output(struct flowi4 *fl4, int oif,
 	fl4->flowi4_proto = proto;
 	fl4->flowi4_flags = flags;
 	fl4->flowi4_secid = 0;
+	fl4->flowi4_tun_key.tun_id = 0;
 	fl4->daddr = daddr;
 	fl4->saddr = saddr;
 	fl4->fl4_dport = dport;
@@ -165,6 +172,7 @@ struct flowi {
 #define flowi_proto	u.__fl_common.flowic_proto
 #define flowi_flags	u.__fl_common.flowic_flags
 #define flowi_secid	u.__fl_common.flowic_secid
+#define flowi_tun_key	u.__fl_common.flowic_tun_key
 } __attribute__((__aligned__(BITS_PER_LONG/8)));
 
 static inline struct flowi *flowi4_to_flowi(struct flowi4 *fl4)
diff --git a/net/ipv4/fib_frontend.c b/net/ipv4/fib_frontend.c
index 9b2019c..6b98de0 100644
--- a/net/ipv4/fib_frontend.c
+++ b/net/ipv4/fib_frontend.c
@@ -280,6 +280,7 @@ __be32 fib_compute_spec_dst(struct sk_buff *skb)
 		fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
 		fl4.flowi4_scope = scope;
 		fl4.flowi4_mark = IN_DEV_SRC_VMARK(in_dev) ? skb->mark : 0;
+		fl4.flowi4_tun_key.tun_id = 0;
 		if (!fib_lookup(net, &fl4, &res, 0))
 			return FIB_RES_PREFSRC(net, res);
 	} else {
@@ -313,6 +314,7 @@ static int __fib_validate_source(struct sk_buff *skb, __be32 src, __be32 dst,
 	fl4.saddr = dst;
 	fl4.flowi4_tos = tos;
 	fl4.flowi4_scope = RT_SCOPE_UNIVERSE;
+	fl4.flowi4_tun_key.tun_id = 0;
 
 	no_addr = idev->ifa_list == NULL;
 
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index 4c8e84e..91da18b 100644
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
@@ -1673,6 +1675,7 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 {
 	struct fib_result res;
 	struct in_device *in_dev = __in_dev_get_rcu(dev);
+	struct ip_tunnel_info *tun_info;
 	struct flowi4	fl4;
 	unsigned int	flags = 0;
 	u32		itag = 0;
@@ -1690,6 +1693,11 @@ static int ip_route_input_slow(struct sk_buff *skb, __be32 daddr, __be32 saddr,
 	   by fib_lookup.
 	 */
 
+	tun_info = skb_tunnel_info(skb);
+	if (tun_info && tun_info->mode == IP_TUNNEL_INFO_RX)
+		fl4.flowi4_tun_key.tun_id = tun_info->key.tun_id;
+	else
+		fl4.flowi4_tun_key.tun_id = 0;
 	skb_dst_drop(skb);
 
 	if (ipv4_is_multicast(saddr) || ipv4_is_lbcast(saddr))
-- 
2.4.3
