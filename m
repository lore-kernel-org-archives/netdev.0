From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][IPv6][IPsec] fix the address family for xfrm_state_lookup in xfrm_input
Date: Tue, 4 Dec 2007 16:49:35 +1100
Message-ID: <20071204054935.GA1747@gondor.apana.org.au>
References: <20071204142836.a864e30e.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	"David S. Miller" <davem@davemloft.net>
To: Kazunori MIYAZAWA <kazunori@miyazawa.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1372 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751464AbXLDFtj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2007 00:49:39 -0500
Content-Disposition: inline
In-Reply-To: <20071204142836.a864e30e.kazunori@miyazawa.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 04, 2007 at 02:28:36PM +0900, Kazunori MIYAZAWA wrote:
> Hi Herbert, 
> 
> This is the patch to fix IPv6 IPsec input.
> 
> Signed-off-by: Kazunori MIYAZAWA <kazunori@miyazawa.org>

Good catch! Thanks.

> diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
> index 96f42c1..da3c963 100644
> --- a/net/xfrm/xfrm_input.c
> +++ b/net/xfrm/xfrm_input.c
> @@ -136,7 +136,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
>  		if (skb->sp->len == XFRM_MAX_DEPTH)
>  			goto drop;
>  
> -		x = xfrm_state_lookup(daddr, spi, nexthdr, AF_INET);
> +		x = xfrm_state_lookup(daddr, spi, nexthdr, skb->dst->ops->family);

I'd prefer to put this in XFRM_SPI_SKB_CB instead because the xfrm
layer shouldn't really rely on dst->ops structures except on entry
and exit, like this:

[IPSEC]: Use the correct family for input state lookup

When merging the input paths of IPsec I accidentally left a hard-coded
AF_INET for the state lookup call.  This broke IPv6 obviously.  This
patch fixes by getting the input callers to specify the family through
skb->cb.

Credit goes to Kazunori Miyazawa for diagnosing this and providing an
initial patch.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 99251b7..3f86cd8 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -534,6 +534,7 @@ struct xfrm_spi_skb_cb {
 	} header;
 
 	unsigned int daddroff;
+	unsigned int family;
 };
 
 #define XFRM_SPI_SKB_CB(__skb) ((struct xfrm_spi_skb_cb *)&((__skb)->cb[0]))
diff --git a/net/ipv4/xfrm4_input.c b/net/ipv4/xfrm4_input.c
index 0c377a6..33f990d 100644
--- a/net/ipv4/xfrm4_input.c
+++ b/net/ipv4/xfrm4_input.c
@@ -39,6 +39,7 @@ drop:
 int xfrm4_rcv_encap(struct sk_buff *skb, int nexthdr, __be32 spi,
 		    int encap_type)
 {
+	XFRM_SPI_SKB_CB(skb)->family = AF_INET;
 	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct iphdr, daddr);
 	return xfrm_input(skb, nexthdr, spi, encap_type);
 }
diff --git a/net/ipv6/xfrm6_input.c b/net/ipv6/xfrm6_input.c
index e2c3efd..74f3aac 100644
--- a/net/ipv6/xfrm6_input.c
+++ b/net/ipv6/xfrm6_input.c
@@ -23,6 +23,7 @@ int xfrm6_extract_input(struct xfrm_state *x, struct sk_buff *skb)
 
 int xfrm6_rcv_spi(struct sk_buff *skb, int nexthdr, __be32 spi)
 {
+	XFRM_SPI_SKB_CB(skb)->family = AF_INET6;
 	XFRM_SPI_SKB_CB(skb)->daddroff = offsetof(struct ipv6hdr, daddr);
 	return xfrm_input(skb, nexthdr, spi, 0);
 }
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 96f42c1..8b2b1b5 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -102,6 +102,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 	__be32 seq;
 	struct xfrm_state *x;
 	xfrm_address_t *daddr;
+	unsigned int family;
 	int decaps = 0;
 	int async = 0;
 
@@ -127,6 +128,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 
 	daddr = (xfrm_address_t *)(skb_network_header(skb) +
 				   XFRM_SPI_SKB_CB(skb)->daddroff);
+	family = XFRM_SPI_SKB_CB(skb)->family;
 
 	seq = 0;
 	if (!spi && (err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0)
@@ -136,7 +138,7 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		if (skb->sp->len == XFRM_MAX_DEPTH)
 			goto drop;
 
-		x = xfrm_state_lookup(daddr, spi, nexthdr, AF_INET);
+		x = xfrm_state_lookup(daddr, spi, nexthdr, family);
 		if (x == NULL)
 			goto drop;
 
@@ -198,6 +200,7 @@ resume:
 		 * transport mode so the outer address is identical.
 		 */
 		daddr = &x->id.daddr;
+		family = x->outer_mode->afinfo->family;
 
 		err = xfrm_parse_spi(skb, nexthdr, &spi, &seq);
 		if (err < 0)
