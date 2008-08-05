From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: [PATCH 1/2] (revised) Interfamily IPSec BEET
Date: Tue, 5 Aug 2008 12:35:41 +0300
Message-ID: <200808051235.42038.joakim.koskela@hiit.fi>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, yoshfuji@wide.ad.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:58553 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752860AbYHEJdD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 05:33:03 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Here's a revised version, based on Herbert's comments, of a fix for
the ipv6-inner, ipv4-outer interfamily ipsec beet mode. It fixes the
network header adjustment in interfamily, and doesn't reserve space
for the pseudo header anymore when we have ipv6 as the inner family.

Signed-off-by: Joakim Koskela <jookos@gmail.com>

---
 net/ipv4/esp4.c            |    2 +-
 net/ipv4/xfrm4_mode_beet.c |    6 ++++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 4e73e57..21515d4 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -575,7 +575,7 @@ static int esp_init_state(struct xfrm_state *x)
 			      crypto_aead_ivsize(aead);
 	if (x->props.mode == XFRM_MODE_TUNNEL)
 		x->props.header_len += sizeof(struct iphdr);
-	else if (x->props.mode == XFRM_MODE_BEET)
+	else if (x->props.mode == XFRM_MODE_BEET && x->sel.family != AF_INET6)
 		x->props.header_len += IPV4_BEET_PHMAXLEN;
 	if (x->encap) {
 		struct xfrm_encap_tmpl *encap = x->encap;
diff --git a/net/ipv4/xfrm4_mode_beet.c b/net/ipv4/xfrm4_mode_beet.c
index 9c798ab..6341818 100644
--- a/net/ipv4/xfrm4_mode_beet.c
+++ b/net/ipv4/xfrm4_mode_beet.c
@@ -47,8 +47,10 @@ static int xfrm4_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 	if (unlikely(optlen))
 		hdrlen += IPV4_BEET_PHMAXLEN - (optlen & 4);
 
-	skb_set_network_header(skb, IPV4_BEET_PHMAXLEN - x->props.header_len -
-				    hdrlen);
+	skb_set_network_header(skb, -x->props.header_len -
+			            hdrlen + (XFRM_MODE_SKB_CB(skb)->ihl - sizeof(*top_iph)));
+	if (x->sel.family != AF_INET6)
+		skb->network_header += IPV4_BEET_PHMAXLEN;
 	skb->mac_header = skb->network_header +
 			  offsetof(struct iphdr, protocol);
 	skb->transport_header = skb->network_header + sizeof(*top_iph);
