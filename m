From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next v2 4/7] ipv6: Use l3_dev for L3 ingress processing
Date: Wed,  9 Mar 2016 13:50:06 -0800
Message-ID: <1457560206-13153-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, Tim Hockin <thockin@google.com>,
	Alex Pollitt <alex.pollitt@metaswitch.com>,
	Matthew Dupre <matthew.dupre@metaswitch.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35558 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458AbcCIVuJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 16:50:09 -0500
Received: by mail-pf0-f195.google.com with SMTP id u190so1207217pfb.2
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 13:50:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

Use the in-dev passed by the packet dispatcher for the L3 phase. If
there are places where code uses skb->dev, use the netif_get_l3_dev()
helper to get l3_dev.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
CC: Eric Dumazet <edumazet@google.com>
CC: Tim Hockin <thockin@google.com>
CC: Alex Pollitt <alex.pollitt@metaswitch.com>
CC: Matthew Dupre <matthew.dupre@metaswitch.com>
---
 net/ipv6/ip6_input.c | 14 ++++++++------
 net/ipv6/route.c     |  7 ++++---
 2 files changed, 12 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
index c05c425c2389..f02da6d7e097 100644
--- a/net/ipv6/ip6_input.c
+++ b/net/ipv6/ip6_input.c
@@ -67,7 +67,8 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 	const struct ipv6hdr *hdr;
 	u32 pkt_len;
 	struct inet6_dev *idev;
-	struct net *net = dev_net(skb->dev);
+	struct net_device *l3dev = netif_get_l3_dev(skb->dev);
+	struct net *net = dev_net(l3dev);
 
 	if (skb->pkt_type == PACKET_OTHERHOST) {
 		kfree_skb(skb);
@@ -76,7 +77,7 @@ int ipv6_rcv(struct sk_buff *skb, struct net_device *dev, struct packet_type *pt
 
 	rcu_read_lock();
 
-	idev = __in6_dev_get(skb->dev);
+	idev = __in6_dev_get(l3dev);
 
 	IP6_UPD_PO_STATS_BH(net, idev, IPSTATS_MIB_IN, skb->len);
 
@@ -246,8 +247,8 @@ resubmit:
 					   skb_network_header_len(skb));
 			hdr = ipv6_hdr(skb);
 			if (ipv6_addr_is_multicast(&hdr->daddr) &&
-			    !ipv6_chk_mcast_addr(skb->dev, &hdr->daddr,
-			    &hdr->saddr) &&
+			    !ipv6_chk_mcast_addr(netif_get_l3_dev(skb->dev),
+						 &hdr->daddr, &hdr->saddr) &&
 			    !ipv6_is_mld(skb, nexthdr, skb_network_header_len(skb)))
 				goto discard;
 		}
@@ -287,9 +288,10 @@ discard:
 
 int ip6_input(struct sk_buff *skb)
 {
+	struct net_device *dev = netif_get_l3_dev(skb->dev);
+
 	return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_IN,
-		       dev_net(skb->dev), NULL, skb, skb->dev, NULL,
-		       ip6_input_finish);
+		       dev_net(dev), NULL, skb, dev, NULL, ip6_input_finish);
 }
 
 int ip6_mc_input(struct sk_buff *skb)
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index ed446639219c..3a1b3c62d80b 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1158,11 +1158,12 @@ static struct dst_entry *ip6_route_input_lookup(struct net *net,
 void ip6_route_input(struct sk_buff *skb)
 {
 	const struct ipv6hdr *iph = ipv6_hdr(skb);
-	struct net *net = dev_net(skb->dev);
+	struct net_device *dev = netif_get_l3_dev(skb->dev);
+	struct net *net = dev_net(dev);
 	int flags = RT6_LOOKUP_F_HAS_SADDR;
 	struct ip_tunnel_info *tun_info;
 	struct flowi6 fl6 = {
-		.flowi6_iif = l3mdev_fib_oif(skb->dev),
+		.flowi6_iif = l3mdev_fib_oif(dev),
 		.daddr = iph->daddr,
 		.saddr = iph->saddr,
 		.flowlabel = ip6_flowinfo(iph),
@@ -1174,7 +1175,7 @@ void ip6_route_input(struct sk_buff *skb)
 	if (tun_info && !(tun_info->mode & IP_TUNNEL_INFO_TX))
 		fl6.flowi6_tun_key.tun_id = tun_info->key.tun_id;
 	skb_dst_drop(skb);
-	skb_dst_set(skb, ip6_route_input_lookup(net, skb->dev, &fl6, flags));
+	skb_dst_set(skb, ip6_route_input_lookup(net, dev, &fl6, flags));
 }
 
 static struct rt6_info *ip6_pol_route_output(struct net *net, struct fib6_table *table,
-- 
2.7.0.rc3.207.g0ac5344
