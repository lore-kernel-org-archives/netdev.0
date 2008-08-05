From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: [PATCH 2/2] (revised) Interfamily IPSec BEET
Date: Tue, 5 Aug 2008 12:35:47 +0300
Message-ID: <200808051235.47624.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, yoshfuji@wide.ad.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:58561 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753859AbYHEJdG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 05:33:06 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here's a revised version, based on Herbert's comments, of a fix for
the ipv4-inner, ipv6-outer interfamily ipsec beet mode. It fixes the
network header adjustment during interfamily, as well as makes sure
that we reserve enough room for the new ipv6 header if we might have
something else as the inner family. Also, the ipv4 pseudo header
construction was added.

Signed-off-by: Joakim Koskela <jookos@gmail.com>

---
 net/ipv6/esp6.c            |    4 ++++
 net/ipv6/xfrm6_mode_beet.c |   27 +++++++++++++++++++++++++--
 2 files changed, 29 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index c6bb4c6..b181b08 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -521,6 +521,10 @@ static int esp6_init_state(struct xfrm_state *x)
 			      crypto_aead_ivsize(aead);
 	switch (x->props.mode) {
 	case XFRM_MODE_BEET:
+		if (x->sel.family != AF_INET6)
+			x->props.header_len += IPV4_BEET_PHMAXLEN +
+				               (sizeof(struct ipv6hdr) - sizeof(struct iphdr));
+		break;
 	case XFRM_MODE_TRANSPORT:
 		break;
 	case XFRM_MODE_TUNNEL:
diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index d6ce400..bbd48b1 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -40,16 +40,39 @@ static void xfrm6_beet_make_header(struct sk_buff *skb)
 static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ipv6hdr *top_iph;
-
-	skb_set_network_header(skb, -x->props.header_len);
+	struct ip_beet_phdr *ph;
+	struct iphdr *iphv4;
+	int optlen, hdr_len;
+
+	iphv4 = ip_hdr(skb);
+	hdr_len = 0;
+	optlen = XFRM_MODE_SKB_CB(skb)->optlen;
+	if (unlikely(optlen))
+		hdr_len += IPV4_BEET_PHMAXLEN - (optlen & 4);
+
+	skb_set_network_header(skb, -x->props.header_len - hdr_len);
+	if (x->sel.family != AF_INET6)
+		skb->network_header += IPV4_BEET_PHMAXLEN;
 	skb->mac_header = skb->network_header +
 			  offsetof(struct ipv6hdr, nexthdr);
 	skb->transport_header = skb->network_header + sizeof(*top_iph);
-	__skb_pull(skb, XFRM_MODE_SKB_CB(skb)->ihl);
+	ph = (struct ip_beet_phdr *)__skb_pull(skb, XFRM_MODE_SKB_CB(skb)->ihl-hdr_len);
 
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
