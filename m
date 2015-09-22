From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 11/30] ipvs: ensure that ICMP cannot be sent in reply to ICMP
Date: Tue, 22 Sep 2015 11:14:01 +0200
Message-ID: <1442913260-3925-12-git-send-email-pablo@netfilter.org>
References: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34992 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757550AbbIVJHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 05:07:49 -0400
In-Reply-To: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Gartrell <agartrell@fb.com>

Check the header for icmp before sending a PACKET_TOO_BIG

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_xmit.c |    5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_xmit.c b/net/netfilter/ipvs/ip_vs_xmit.c
index af5e9d3..c5be055 100644
--- a/net/netfilter/ipvs/ip_vs_xmit.c
+++ b/net/netfilter/ipvs/ip_vs_xmit.c
@@ -224,7 +224,7 @@ static inline bool ensure_mtu_is_adequate(int skb_af, int rt_mode,
 			if (!skb->dev)
 				skb->dev = net->loopback_dev;
 			/* only send ICMP too big on first fragment */
-			if (!ipvsh->fragoffs)
+			if (!ipvsh->fragoffs && !ip_vs_iph_icmp(ipvsh))
 				icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
 			IP_VS_DBG(1, "frag needed for %pI6c\n",
 				  &ipv6_hdr(skb)->saddr);
@@ -242,7 +242,8 @@ static inline bool ensure_mtu_is_adequate(int skb_af, int rt_mode,
 			return true;
 
 		if (unlikely(ip_hdr(skb)->frag_off & htons(IP_DF) &&
-			     skb->len > mtu && !skb_is_gso(skb))) {
+			     skb->len > mtu && !skb_is_gso(skb) &&
+			     !ip_vs_iph_icmp(ipvsh))) {
 			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED,
 				  htonl(mtu));
 			IP_VS_DBG(1, "frag needed for %pI4\n",
-- 
1.7.10.4
