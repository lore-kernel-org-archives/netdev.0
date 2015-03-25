From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 1/2] ipv4: hash net ptr into fragmentation bucket selection
Date: Wed, 25 Mar 2015 15:00:18 +0100
Message-ID: <8d98fd0e002553538fb43e5fcafff38f3d65153f.1427291651.git.hannes@stressinduktion.org>
Cc: Eric Dumazet <edumazet@google.com>, Flavio Leitner <fbl@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:50716 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752204AbbCYOAZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2015 10:00:25 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 4E0FC206E5
	for <netdev@vger.kernel.org>; Wed, 25 Mar 2015 10:00:22 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As namespaces are sometimes used with overlapping ip address ranges,
we should also use the namespace as input to the hash to select the ip
fragmentation counter bucket.

Cc: Eric Dumazet <edumazet@google.com>
Cc: Flavio Leitner <fbl@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 drivers/net/ppp/pptp.c          | 2 +-
 net/netfilter/ipvs/ip_vs_xmit.c | 5 +++--
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 1dc628f..e3bfbd4d 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -281,7 +281,7 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	nf_reset(skb);
 
 	skb->ip_summed = CHECKSUM_NONE;
-	ip_select_ident(skb, NULL);
+	ip_select_ident(sock_net(sk), skb, NULL);
 	ip_send_check(iph);
 
 	ip_local_out(skb);
diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index f35c15b..bf02932 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -924,7 +924,8 @@ int
 ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 		  struct ip_vs_protocol *pp, struct ip_vs_iphdr *ipvsh)
 {
-	struct netns_ipvs *ipvs = net_ipvs(skb_net(skb));
+	struct net *net = skb_net(skb);
+	struct netns_ipvs *ipvs = net_ipvs(net);
 	struct rtable *rt;			/* Route to the other host */
 	__be32 saddr;				/* Source for tunnel */
 	struct net_device *tdev;		/* Device to other host */
@@ -991,7 +992,7 @@ ip_vs_tunnel_xmit(struct sk_buff *skb, struct ip_vs_conn *cp,
 	iph->daddr		=	cp->daddr.ip;
 	iph->saddr		=	saddr;
 	iph->ttl		=	ttl;
-	ip_select_ident(skb, NULL);
+	ip_select_ident(net, skb, NULL);
 
 	/* Another hack: avoid icmp_send in ip_fragment */
 	skb->ignore_df = 1;
-- 
2.1.0
