From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 13/30] ipvs: support scheduling inverse and icmp UDP packets
Date: Tue, 22 Sep 2015 11:14:03 +0200
Message-ID: <1442913260-3925-14-git-send-email-pablo@netfilter.org>
References: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:35019 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757681AbbIVJHv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Sep 2015 05:07:51 -0400
In-Reply-To: <1442913260-3925-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Gartrell <agartrell@fb.com>

In the event of an icmp packet, take only the ports instead of trying to
grab the full header.

In the event of an inverse packet, use the source address and port.

Signed-off-by: Alex Gartrell <agartrell@fb.com>
Acked-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_proto_udp.c |   27 ++++++++++++++++++---------
 1 file changed, 18 insertions(+), 9 deletions(-)

diff --git a/net/netfilter/ipvs/ip_vs_proto_udp.c b/net/netfilter/ipvs/ip_vs_proto_udp.c
index 1403be2..f3aa821 100644
--- a/net/netfilter/ipvs/ip_vs_proto_udp.c
+++ b/net/netfilter/ipvs/ip_vs_proto_udp.c
@@ -36,23 +36,32 @@ udp_conn_schedule(int af, struct sk_buff *skb, struct ip_vs_proto_data *pd,
 	struct net *net;
 	struct ip_vs_service *svc;
 	struct udphdr _udph, *uh;
+	__be16 _ports[2], *ports = NULL;
 
-	if (ip_vs_iph_icmp(iph)) {
-		/* TEMPORARY - do not schedule icmp yet */
-		*verdict = NF_ACCEPT;
-		return 0;
+	if (likely(!ip_vs_iph_icmp(iph))) {
+		/* IPv6 fragments, only first fragment will hit this */
+		uh = skb_header_pointer(skb, iph->len, sizeof(_udph), &_udph);
+		if (uh)
+			ports = &uh->source;
+	} else {
+		ports = skb_header_pointer(
+			skb, iph->len, sizeof(_ports), &_ports);
 	}
 
-	/* IPv6 fragments, only first fragment will hit this */
-	uh = skb_header_pointer(skb, iph->len, sizeof(_udph), &_udph);
-	if (uh == NULL) {
+	if (!ports) {
 		*verdict = NF_DROP;
 		return 0;
 	}
+
 	net = skb_net(skb);
 	rcu_read_lock();
-	svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
-				 &iph->daddr, uh->dest);
+	if (likely(!ip_vs_iph_inverse(iph)))
+		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+					 &iph->daddr, ports[1]);
+	else
+		svc = ip_vs_service_find(net, af, skb->mark, iph->protocol,
+					 &iph->saddr, ports[0]);
+
 	if (svc) {
 		int ignored;
 
-- 
1.7.10.4
