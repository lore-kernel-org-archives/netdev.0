From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH v2 net-next 12/13] ipv6: route: extend flow representation with tunnel key
Date: Wed, 19 Aug 2015 12:10:02 +0200
Message-ID: <eb93ff91f642c62fb269555006bcd0d7ebf7b69c.1439978875.git.jbenc@redhat.com>
References: <cover.1439978875.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46953 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753755AbbHSKLp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2015 06:11:45 -0400
In-Reply-To: <cover.1439978875.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use flowi_tunnel in flowi6 similarly to what is done with IPv4.
This complements commit 1b7179d3adff ("route: Extend flow representation
with tunnel key").

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 include/net/flow.h | 1 +
 net/ipv6/route.c   | 6 ++++++
 2 files changed, 7 insertions(+)

diff --git a/include/net/flow.h b/include/net/flow.h
index f305588fc162..9e0297c4c11d 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -130,6 +130,7 @@ struct flowi6 {
 #define flowi6_proto		__fl_common.flowic_proto
 #define flowi6_flags		__fl_common.flowic_flags
 #define flowi6_secid		__fl_common.flowic_secid
+#define flowi6_tun_key		__fl_common.flowic_tun_key
 	struct in6_addr		daddr;
 	struct in6_addr		saddr;
 	__be32			flowlabel;
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c4f3b9fcca9d..6c0fe4c7ce8d 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -54,11 +54,13 @@
 #include <net/tcp.h>
 #include <linux/rtnetlink.h>
 #include <net/dst.h>
+#include <net/dst_metadata.h>
 #include <net/xfrm.h>
 #include <net/netevent.h>
 #include <net/netlink.h>
 #include <net/nexthop.h>
 #include <net/lwtunnel.h>
+#include <net/ip_tunnels.h>
 
 #include <asm/uaccess.h>
 
@@ -1131,6 +1133,7 @@ void ip6_route_input(struct sk_buff *skb)
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct net *net = dev_net(skb->dev);
 	int flags = RT6_LOOKUP_F_HAS_SADDR;
+	struct ip_tunnel_info *tun_info;
 	struct flowi6 fl6 = {
 		.flowi6_iif = skb->dev->ifindex,
 		.daddr = iph->daddr,
@@ -1140,6 +1143,9 @@ void ip6_route_input(struct sk_buff *skb)
 		.flowi6_proto = iph->nexthdr,
 	};
 
+	tun_info = skb_tunnel_info(skb);
+	if (tun_info && tun_info->mode == IP_TUNNEL_INFO_RX)
+		fl6.flowi6_tun_key.tun_id = tun_info->key.tun_id;
 	skb_dst_drop(skb);
 	skb_dst_set(skb, ip6_route_input_lookup(net, skb->dev, &fl6, flags));
 }
-- 
1.8.3.1
