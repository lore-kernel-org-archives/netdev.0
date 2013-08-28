From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [RFC PATCH net-next 1/4] iptunnels: remove net arg from iptunnel_xmit()
Date: Wed, 28 Aug 2013 17:20:07 +0200
Message-ID: <1377703210-7021-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1377703210-7021-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, jesse@nicira.com, dev@openvswitch.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:38401 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754688Ab3H1PUT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 11:20:19 -0400
In-Reply-To: <1377703210-7021-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This argument is not used, let's remove it.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 drivers/net/vxlan.c         | 3 +--
 include/net/ip_tunnels.h    | 3 +--
 net/ipv4/ip_tunnel.c        | 3 +--
 net/ipv4/ip_tunnel_core.c   | 3 +--
 net/ipv6/sit.c              | 4 ++--
 net/openvswitch/vport-gre.c | 2 +-
 6 files changed, 7 insertions(+), 11 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 3b21aca0c0c2..3bc27c2ca569 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -1171,8 +1171,7 @@ int vxlan_xmit_skb(struct net *net, struct vxlan_sock *vs,
 	if (err)
 		return err;
 
-	return iptunnel_xmit(net, rt, skb, src, dst,
-			IPPROTO_UDP, tos, ttl, df);
+	return iptunnel_xmit(rt, skb, src, dst, IPPROTO_UDP, tos, ttl, df);
 }
 EXPORT_SYMBOL_GPL(vxlan_xmit_skb);
 
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 0ce316bb3c65..94fe8fd07bc9 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -146,8 +146,7 @@ static inline u8 ip_tunnel_ecn_encap(u8 tos, const struct iphdr *iph,
 }
 
 int iptunnel_pull_header(struct sk_buff *skb, int hdr_len, __be16 inner_proto);
-int iptunnel_xmit(struct net *net, struct rtable *rt,
-		  struct sk_buff *skb,
+int iptunnel_xmit(struct rtable *rt, struct sk_buff *skb,
 		  __be32 src, __be32 dst, __u8 proto,
 		  __u8 tos, __u8 ttl, __be16 df);
 
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index 830de3f4e293..0a6cf0e69478 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -654,8 +654,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
 		}
 	}
 
-	err = iptunnel_xmit(tunnel->net, rt, skb,
-			    fl4.saddr, fl4.daddr, protocol,
+	err = iptunnel_xmit(rt, skb, fl4.saddr, fl4.daddr, protocol,
 			    ip_tunnel_ecn_encap(tos, inner_iph, skb), ttl, df);
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 850525b34899..e82045842351 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -46,8 +46,7 @@
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
 
-int iptunnel_xmit(struct net *net, struct rtable *rt,
-		  struct sk_buff *skb,
+int iptunnel_xmit(struct rtable *rt, struct sk_buff *skb,
 		  __be32 src, __be32 dst, __u8 proto,
 		  __u8 tos, __u8 ttl, __be16 df)
 {
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index f18f842ac893..1d1458a3b7c4 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -888,8 +888,8 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		ttl = iph6->hop_limit;
 	tos = INET_ECN_encapsulate(tos, ipv6_get_dsfield(iph6));
 
-	err = iptunnel_xmit(dev_net(dev), rt, skb, fl4.saddr, fl4.daddr,
-			    IPPROTO_IPV6, tos, ttl, df);
+	err = iptunnel_xmit(rt, skb, fl4.saddr, fl4.daddr, IPPROTO_IPV6, tos,
+			    ttl, df);
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 	return NETDEV_TX_OK;
 
diff --git a/net/openvswitch/vport-gre.c b/net/openvswitch/vport-gre.c
index 21d5073e148e..9b3713ef831e 100644
--- a/net/openvswitch/vport-gre.c
+++ b/net/openvswitch/vport-gre.c
@@ -176,7 +176,7 @@ static int gre_tnl_send(struct vport *vport, struct sk_buff *skb)
 
 	skb->local_df = 1;
 
-	return iptunnel_xmit(net, rt, skb, fl.saddr,
+	return iptunnel_xmit(rt, skb, fl.saddr,
 			     OVS_CB(skb)->tun_key->ipv4_dst, IPPROTO_GRE,
 			     OVS_CB(skb)->tun_key->ipv4_tos,
 			     OVS_CB(skb)->tun_key->ipv4_ttl, df);
-- 
1.8.2.1
