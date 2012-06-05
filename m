From: Vincent Bernat <bernat@luffy.cx>
Subject: [PATCH] snmp: fix OutOctets counter to include forwarded datagrams
Date: Tue,  5 Jun 2012 15:41:42 +0200
Message-ID: <1338903702-18975-1-git-send-email-bernat@luffy.cx>
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org,
	Vincent Bernat <bernat@luffy.cx>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ftmxout01ba.infra.b2.fti.net ([193.252.121.124]:56125 "EHLO
	ftmxout01ba.infra.b2.fti.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757752Ab2FENrw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 09:47:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC 4293 defines ipIfStatsOutOctets (similar definition for
ipSystemStatsOutOctets):

   The total number of octets in IP datagrams delivered to the lower
   layers for transmission.  Octets from datagrams counted in
   ipIfStatsOutTransmits MUST be counted here.

And ipIfStatsOutTransmits:

   The total number of IP datagrams that this entity supplied to the
   lower layers for transmission.  This includes datagrams generated
   locally and those forwarded by this entity.

Therefore, IPSTATS_MIB_OUTOCTETS must be incremented when incrementing
IPSTATS_MIB_OUTFORWDATAGRAMS.

IP_UPD_PO_STATS is not used since ipIfStatsOutRequests must not
include forwarded datagrams:

   The total number of IP datagrams that local IP user-protocols
   (including ICMP) supplied to IP in requests for transmission.  Note
   that this counter does not include any datagrams counted in
   ipIfStatsOutForwDatagrams.

Signed-off-by: Vincent Bernat <bernat@luffy.cx>
---
 net/ipv4/ip_forward.c |    1 +
 net/ipv4/ipmr.c       |    1 +
 net/ipv6/ip6_output.c |    1 +
 net/ipv6/ip6mr.c      |    2 ++
 4 files changed, 5 insertions(+)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index e5c44fc..ab09b12 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -44,6 +44,7 @@ static int ip_forward_finish(struct sk_buff *skb)
 	struct ip_options *opt	= &(IPCB(skb)->opt);
 
 	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTFORWDATAGRAMS);
+	IP_ADD_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTOCTETS, skb->len);
 
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a9e519a..c94bbc6 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1574,6 +1574,7 @@ static inline int ipmr_forward_finish(struct sk_buff *skb)
 	struct ip_options *opt = &(IPCB(skb)->opt);
 
 	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTFORWDATAGRAMS);
+	IP_ADD_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_OUTOCTETS, skb->len);
 
 	if (unlikely(opt->optlen))
 		ip_forward_options(skb);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 17b8c67..decc21d1 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -526,6 +526,7 @@ int ip6_forward(struct sk_buff *skb)
 	hdr->hop_limit--;
 
 	IP6_INC_STATS_BH(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTFORWDATAGRAMS);
+	IP6_ADD_STATS_BH(net, ip6_dst_idev(dst), IPSTATS_MIB_OUTOCTETS, skb->len);
 	return NF_HOOK(NFPROTO_IPV6, NF_INET_FORWARD, skb, skb->dev, dst->dev,
 		       ip6_forward_finish);
 
diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index b15dc08..461e47c 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -1886,6 +1886,8 @@ static inline int ip6mr_forward2_finish(struct sk_buff *skb)
 {
 	IP6_INC_STATS_BH(dev_net(skb_dst(skb)->dev), ip6_dst_idev(skb_dst(skb)),
 			 IPSTATS_MIB_OUTFORWDATAGRAMS);
+	IP6_ADD_STATS_BH(dev_net(skb_dst(skb)->dev), ip6_dst_idev(skb_dst(skb)),
+			 IPSTATS_MIB_OUTOCTETS, skb->len);
 	return dst_output(skb);
 }
 
-- 
1.7.10
