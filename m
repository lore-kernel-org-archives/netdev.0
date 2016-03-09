From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH next v2 3/7] ipv4: Use l3_dev for L3 ingress processing
Date: Wed,  9 Mar 2016 13:50:02 -0800
Message-ID: <1457560202-13083-1-git-send-email-mahesh@bandewar.net>
Cc: Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	netdev <netdev@vger.kernel.org>, Tim Hockin <thockin@google.com>,
	Alex Pollitt <alex.pollitt@metaswitch.com>,
	Matthew Dupre <matthew.dupre@metaswitch.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35540 "EHLO
	mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754068AbcCIVuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 16:50:06 -0500
Received: by mail-pf0-f195.google.com with SMTP id u190so1207141pfb.2
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 13:50:06 -0800 (PST)
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
 net/ipv4/ip_input.c   | 12 +++++++-----
 net/ipv4/ip_options.c |  3 ++-
 2 files changed, 9 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
index e3d782746d9d..cae3503c872b 100644
--- a/net/ipv4/ip_input.c
+++ b/net/ipv4/ip_input.c
@@ -247,7 +247,8 @@ int ip_local_deliver(struct sk_buff *skb)
 	/*
 	 *	Reassemble IP fragments.
 	 */
-	struct net *net = dev_net(skb->dev);
+	struct net_device *dev = netif_get_l3_dev(skb->dev);
+	struct net *net = dev_net(dev);
 
 	if (ip_is_fragment(ip_hdr(skb))) {
 		if (ip_defrag(net, skb, IP_DEFRAG_LOCAL_DELIVER))
@@ -255,7 +256,7 @@ int ip_local_deliver(struct sk_buff *skb)
 	}
 
 	return NF_HOOK(NFPROTO_IPV4, NF_INET_LOCAL_IN,
-		       net, NULL, skb, skb->dev, NULL,
+		       net, NULL, skb, dev, NULL,
 		       ip_local_deliver_finish);
 }
 
@@ -263,7 +264,7 @@ static inline bool ip_rcv_options(struct sk_buff *skb)
 {
 	struct ip_options *opt;
 	const struct iphdr *iph;
-	struct net_device *dev = skb->dev;
+	struct net_device *dev = netif_get_l3_dev(skb->dev);
 
 	/* It looks as overkill, because not all
 	   IP options require packet mangling.
@@ -312,6 +313,7 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 {
 	const struct iphdr *iph = ip_hdr(skb);
 	struct rtable *rt;
+	struct net_device *dev = netif_get_l3_dev(skb->dev);
 
 	if (net->ipv4.sysctl_ip_early_demux &&
 	    !skb_dst(skb) &&
@@ -334,7 +336,7 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 	 */
 	if (!skb_valid_dst(skb)) {
 		int err = ip_route_input_noref(skb, iph->daddr, iph->saddr,
-					       iph->tos, skb->dev);
+					       iph->tos, dev);
 		if (unlikely(err)) {
 			if (err == -EXDEV)
 				NET_INC_STATS_BH(net, LINUX_MIB_IPRPFILTER);
@@ -363,7 +365,7 @@ static int ip_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb)
 		IP_UPD_PO_STATS_BH(net, IPSTATS_MIB_INBCAST, skb->len);
 	} else if (skb->pkt_type == PACKET_BROADCAST ||
 		   skb->pkt_type == PACKET_MULTICAST) {
-		struct in_device *in_dev = __in_dev_get_rcu(skb->dev);
+		struct in_device *in_dev = __in_dev_get_rcu(dev);
 
 		/* RFC 1122 3.3.6:
 		 *
diff --git a/net/ipv4/ip_options.c b/net/ipv4/ip_options.c
index bd246792360b..fc434b12a3d3 100644
--- a/net/ipv4/ip_options.c
+++ b/net/ipv4/ip_options.c
@@ -639,7 +639,8 @@ int ip_options_rcv_srr(struct sk_buff *skb)
 
 		orefdst = skb->_skb_refdst;
 		skb_dst_set(skb, NULL);
-		err = ip_route_input(skb, nexthop, iph->saddr, iph->tos, skb->dev);
+		err = ip_route_input(skb, nexthop, iph->saddr, iph->tos,
+				     netif_get_l3_dev(skb->dev));
 		rt2 = skb_rtable(skb);
 		if (err || (rt2->rt_type != RTN_UNICAST && rt2->rt_type != RTN_LOCAL)) {
 			skb_dst_drop(skb);
-- 
2.7.0.rc3.207.g0ac5344
