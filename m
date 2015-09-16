From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH next 06/30] ipv4: Compute net once in ip_forward
Date: Tue, 15 Sep 2015 20:03:54 -0500
Message-ID: <1442365458-16349-6-git-send-email-ebiederm@xmission.com>
References: <87mvwn18my.fsf@x220.int.ebiederm.org>
Cc: netfilter-devel@vger.kernel.org, <netdev@vger.kernel.org>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:35067 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752266AbbIPBLn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 21:11:43 -0400
In-Reply-To: <87mvwn18my.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Compute struct net from the input device in ip_forward before it is
used.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 net/ipv4/ip_forward.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/ip_forward.c b/net/ipv4/ip_forward.c
index 28fb90108f56..ba2f66b3b3f6 100644
--- a/net/ipv4/ip_forward.c
+++ b/net/ipv4/ip_forward.c
@@ -81,6 +81,7 @@ int ip_forward(struct sk_buff *skb)
 	struct iphdr *iph;	/* Our header */
 	struct rtable *rt;	/* Route we use */
 	struct ip_options *opt	= &(IPCB(skb)->opt);
+	struct net *net;
 
 	/* that should never happen */
 	if (skb->pkt_type != PACKET_HOST)
@@ -99,6 +100,7 @@ int ip_forward(struct sk_buff *skb)
 		return NET_RX_SUCCESS;
 
 	skb_forward_csum(skb);
+	net = dev_net(skb->dev);
 
 	/*
 	 *	According to the RFC, we must first decrease the TTL field. If
@@ -119,7 +121,7 @@ int ip_forward(struct sk_buff *skb)
 	IPCB(skb)->flags |= IPSKB_FORWARDED;
 	mtu = ip_dst_mtu_maybe_forward(&rt->dst, true);
 	if (ip_exceeds_mtu(skb, mtu)) {
-		IP_INC_STATS(dev_net(rt->dst.dev), IPSTATS_MIB_FRAGFAILS);
+		IP_INC_STATS(net, IPSTATS_MIB_FRAGFAILS);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 			  htonl(mtu));
 		goto drop;
@@ -155,7 +157,7 @@ sr_failed:
 
 too_many_hops:
 	/* Tell the sender its packet died... */
-	IP_INC_STATS_BH(dev_net(skb_dst(skb)->dev), IPSTATS_MIB_INHDRERRORS);
+	IP_INC_STATS_BH(net, IPSTATS_MIB_INHDRERRORS);
 	icmp_send(skb, ICMP_TIME_EXCEEDED, ICMP_EXC_TTL, 0);
 drop:
 	kfree_skb(skb);
-- 
2.2.1
