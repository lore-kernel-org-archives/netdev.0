From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 5/8] fou: enable LCO in FOU and GUE
Date: Fri, 5 Feb 2016 20:42:30 +0000
Message-ID: <56B50936.1070703@solarflare.com>
References: <56B50886.1050201@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>,
	<tom@herbertland.com>, <alexander.duyck@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:44687 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756921AbcBEUmh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 15:42:37 -0500
In-Reply-To: <56B50886.1050201@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 net/ipv4/fou.c | 14 ++++++--------
 1 file changed, 6 insertions(+), 8 deletions(-)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 976f0dc..dac1874 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -774,7 +774,6 @@ static void fou_build_udp(struct sk_buff *skb, struct ip_tunnel_encap *e,
 	uh->dest = e->dport;
 	uh->source = sport;
 	uh->len = htons(skb->len);
-	uh->check = 0;
 	udp_set_csum(!(e->flags & TUNNEL_ENCAP_FLAG_CSUM), skb,
 		     fl4->saddr, fl4->daddr, skb->len);
 
@@ -784,11 +783,11 @@ static void fou_build_udp(struct sk_buff *skb, struct ip_tunnel_encap *e,
 int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 		     u8 *protocol, struct flowi4 *fl4)
 {
-	bool csum = !!(e->flags & TUNNEL_ENCAP_FLAG_CSUM);
-	int type = csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+	int type = e->flags & TUNNEL_ENCAP_FLAG_CSUM ? SKB_GSO_UDP_TUNNEL_CSUM :
+						       SKB_GSO_UDP_TUNNEL;
 	__be16 sport;
 
-	skb = iptunnel_handle_offloads(skb, csum, type);
+	skb = iptunnel_handle_offloads(skb, false, type);
 
 	if (IS_ERR(skb))
 		return PTR_ERR(skb);
@@ -804,8 +803,8 @@ EXPORT_SYMBOL(fou_build_header);
 int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 		     u8 *protocol, struct flowi4 *fl4)
 {
-	bool csum = !!(e->flags & TUNNEL_ENCAP_FLAG_CSUM);
-	int type = csum ? SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
+	int type = e->flags & TUNNEL_ENCAP_FLAG_CSUM ? SKB_GSO_UDP_TUNNEL_CSUM :
+						       SKB_GSO_UDP_TUNNEL;
 	struct guehdr *guehdr;
 	size_t hdrlen, optlen = 0;
 	__be16 sport;
@@ -814,7 +813,6 @@ int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 
 	if ((e->flags & TUNNEL_ENCAP_FLAG_REMCSUM) &&
 	    skb->ip_summed == CHECKSUM_PARTIAL) {
-		csum = false;
 		optlen += GUE_PLEN_REMCSUM;
 		type |= SKB_GSO_TUNNEL_REMCSUM;
 		need_priv = true;
@@ -822,7 +820,7 @@ int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 
 	optlen += need_priv ? GUE_LEN_PRIV : 0;
 
-	skb = iptunnel_handle_offloads(skb, csum, type);
+	skb = iptunnel_handle_offloads(skb, false, type);
 
 	if (IS_ERR(skb))
 		return PTR_ERR(skb);
