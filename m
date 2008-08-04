From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: [PATCH 2/2] Interfamily IPSec BEET
Date: Mon, 4 Aug 2008 16:19:42 +0300
Message-ID: <200808041619.42562.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, yoshfuji@wide.ad.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:41605 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753255AbYHDNRA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Aug 2008 09:17:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the ipv4-inner, ipv6-outer mode.  This one is a bit more
complex as not only do we need to take into account the difference
between ipv4/ipv6 headers when adjusting the sk_buff network header,
we also need to reserve extra room for the new ipv6 header.  This
extra room, here got by adding it to the props.header_len, is needed
to accomodate the new & larger ipv6 header (the kernel is currently
panicing because of this).

The BEET ipv4 pseudo-header construction was also missing from the
ipv6 output.

Signed-off-by: Joakim Koskela <jookos@gmail.com>

---
 net/ipv6/esp6.c            |    4 ++++
 net/ipv6/xfrm6_mode_beet.c |   28 ++++++++++++++++++++++++++--
 2 files changed, 30 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index c6bb4c6..f09fcb9 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -521,6 +521,10 @@ static int esp6_init_state(struct xfrm_state *x)
 			      crypto_aead_ivsize(aead);
 	switch (x->props.mode) {
 	case XFRM_MODE_BEET:
+		x->props.header_len += IPV4_BEET_PHMAXLEN;
+		if (x->sel.family == AF_INET)
+			x->props.header_len += (sizeof(struct ipv6hdr) - sizeof(struct iphdr));
+		break;
 	case XFRM_MODE_TRANSPORT:
 		break;
 	case XFRM_MODE_TUNNEL:
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index d6ce400..dc53623 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -41,15 +41,39 @@ static int xfrm6_beet_output(struct xfrm_state *x, struct 
sk_buff *skb)
 {
 	struct ipv6hdr *top_iph;
 
-	skb_set_network_header(skb, -x->props.header_len);
+	int optlen, hdr_len;
+	struct ip_beet_phdr *ph;
+	u8 protocol;
+	struct iphdr *iphv4;
+
+	iphv4 = ip_hdr(skb);
+	hdr_len = 0;
+	optlen = XFRM_MODE_SKB_CB(skb)->optlen;
+	if (unlikely(optlen))
+		hdr_len += IPV4_BEET_PHMAXLEN - (optlen & 4);
+
+	skb_set_network_header(skb, IPV4_BEET_PHMAXLEN - x->props.header_len -
+			            hdr_len);
 	skb->mac_header = skb->network_header +
 			  offsetof(struct ipv6hdr, nexthdr);
 	skb->transport_header = skb->network_header + sizeof(*top_iph);
-	__skb_pull(skb, XFRM_MODE_SKB_CB(skb)->ihl);
+	ph = (struct ip_beet_phdr *)__skb_pull(skb, 
XFRM_MODE_SKB_CB(skb)->ihl-hdr_len);
 
 	xfrm6_beet_make_header(skb);
 
 	top_iph = ipv6_hdr(skb);
+	if (unlikely(optlen)) {
+
+		BUG_ON(optlen < 0);
+
+		ph->padlen = 4 - (optlen & 4);
+		ph->hdrlen = optlen / 8;
+		ph->nexthdr = top_iph->nexthdr;
+		if (ph->padlen)
+			memset(ph + 1, IPOPT_NOP, ph->padlen);
+
+		top_iph->nexthdr = IPPROTO_BEETPH;
+	}
 
 	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
 	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
