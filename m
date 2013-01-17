From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH] ipv6: add anti-spoofing checks for 6to4 and 6rd
Date: Thu, 17 Jan 2013 04:32:58 +0100
Message-ID: <20130117033258.GA23782@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:32942 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757317Ab3AQDdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Jan 2013 22:33:00 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds anti-spoofing checks in sit.c as specified in RFC3964
section 5.2 for 6to4 and RFC5969 section 12 for 6rd. I left out the
checks which could easily be implemented with netfilter.

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/sit.c | 27 +++++++++++++++++++++++++--
 1 file changed, 25 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index cfba99b..2b4c15a 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -590,6 +590,22 @@ out:
 	return err;
 }
 
+static int sit_chksrc(struct ip_tunnel *tunnel, const __be32 *addr,
+		const struct in6_addr *addr6)
+{
+#ifdef CONFIG_IPV6_SIT_6RD
+	if (ipv6_prefix_equal(addr6, &tunnel->ip6rd.prefix,
+				tunnel->ip6rd.prefixlen) &&
+		memcmp(addr, &addr6->s6_addr16[1], 4))
+		return 0;
+#else
+	if (addr6->s6_addr16[0] == htons(0x2002) &&
+		memcmp(addr, &addr6->s6_addr16[1], 4))
+		return 0;
+#endif
+	return 1;
+}
+
 static int ipip6_rcv(struct sk_buff *skb)
 {
 	const struct iphdr *iph;
@@ -613,8 +629,15 @@ static int ipip6_rcv(struct sk_buff *skb)
 		skb->protocol = htons(ETH_P_IPV6);
 		skb->pkt_type = PACKET_HOST;
 
-		if ((tunnel->dev->priv_flags & IFF_ISATAP) &&
-		    !isatap_chksrc(skb, iph, tunnel)) {
+		if (tunnel->dev->priv_flags & IFF_ISATAP) {
+			if (!isatap_chksrc(skb, iph, tunnel)) {
+				tunnel->dev->stats.rx_errors++;
+				goto out;
+			}
+		} else if (!sit_chksrc(tunnel, &iph->saddr,
+					&ipv6_hdr(skb)->saddr) ||
+			!sit_chksrc(tunnel, &iph->daddr,
+				&ipv6_hdr(skb)->daddr)) {
 			tunnel->dev->stats.rx_errors++;
 			goto out;
 		}
-- 
1.7.11.7
