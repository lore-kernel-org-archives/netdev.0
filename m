From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 2/7] [IPSEC] beet: Fix extension header support on output
Date: Wed, 10 Oct 2007 22:40:11 +0800
Message-ID: <E1IfcjL-000246-00@gondolin.me.apana.org.au>
References: <20071010143915.GA7650@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3578 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754163AbXJJOkN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 10:40:13 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC] beet: Fix extension header support on output

The beet output function completely kills any extension headers by replacing
them with the IPv6 header.  This is because it essentially ignores the
result of ip6_find_1stfragopt by simply acting as if there aren't any
extension headers.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv6/xfrm6_mode_beet.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/xfrm6_mode_beet.c b/net/ipv6/xfrm6_mode_beet.c
index 65e6b2a..d9366df 100644
--- a/net/ipv6/xfrm6_mode_beet.c
+++ b/net/ipv6/xfrm6_mode_beet.c
@@ -44,9 +44,9 @@ static int xfrm6_beet_output(struct xfrm_state *x, struct sk_buff *skb)
 	hdr_len = ip6_find_1stfragopt(skb, &prevhdr);
 	memmove(skb->data, iph, hdr_len);
 
-	skb_set_mac_header(skb, offsetof(struct ipv6hdr, nexthdr));
+	skb_set_mac_header(skb, (prevhdr - x->props.header_len) - skb->data);
 	skb_reset_network_header(skb);
-	skb_set_transport_header(skb, sizeof(struct ipv6hdr));
+	skb_set_transport_header(skb, hdr_len);
 	top_iph = ipv6_hdr(skb);
 
 	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
