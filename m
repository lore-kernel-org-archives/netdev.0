From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 4/12] [IPSEC]: Move ip_summed zapping out of xfrm6_rcv_spi
Date: Tue, 16 Oct 2007 22:33:12 +0800
Message-ID: <E1IhnTs-0003GZ-00@gondolin.me.apana.org.au>
References: <20071016141843.GA11956@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3010 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932987AbXJPOxx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 10:53:53 -0400
Received: from gondolin.me.apana.org.au ([192.168.0.6] ident=mail)
	by arnor.apana.org.au with esmtp (Exim 4.50 #1 (Debian))
	id 1Ihnnp-0001GY-1J
	for <netdev@vger.kernel.org>; Wed, 17 Oct 2007 00:53:49 +1000
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Move ip_summed zapping out of xfrm6_rcv_spi

Not every transform needs to zap ip_summed.  For example, a pure tunnel
mode encapsulation does not affect the hardware checksum at all.  In fact,
every algorithm (that needs this) other than AH6 already does its own
ip_summed zapping.

This patch moves the zapping into AH6 which is in line with what IPv4 does.

Possible future optimisation: Checksum the data as we copy them in IPComp.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv6/ah6.c         |    2 ++
 net/ipv6/xfrm6_input.c |    1 -
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index f9f6891..a8221d1 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -344,6 +344,8 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 	    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
 		goto out;
 
+	skb->ip_summed = CHECKSUM_NONE;
+
 	hdr_len = skb->data - skb_network_header(skb);
 	ah = (struct ip_auth_hdr *)skb->data;
 	ahp = x->data;
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index 596a730..b1201c3 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -97,7 +97,6 @@ int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 	memcpy(skb->sp->xvec + skb->sp->len, xfrm_vec,
 	       xfrm_nr * sizeof(xfrm_vec[0]));
 	skb->sp->len += xfrm_nr;
-	skb->ip_summed = CHECKSUM_NONE;
 
 	nf_reset(skb);
 
