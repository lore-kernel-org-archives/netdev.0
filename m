From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC]: Optimise be16/be32 conversions
Date: Thu, 18 May 2006 22:36:32 +1000
Message-ID: <20060518123632.GA14874@gondor.apana.org.au>
References: <20060518093733.GA15918@mipter.zuzino.mipt.ru>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="IJpNTDwzlM2Ie8A6"
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:18450 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750939AbWERMhF
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 May 2006 08:37:05 -0400
To: Alexey Dobriyan <adobriyan@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20060518093733.GA15918@mipter.zuzino.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 18, 2006 at 09:37:33AM +0000, Alexey Dobriyan wrote:
> 
> --- a/net/ipv4/ipcomp.c
> +++ 1/net/ipv4/ipcomp.c
> @@ -210,7 +210,7 @@ static void ipcomp4_err(struct sk_buff *
>  	    skb->h.icmph->code != ICMP_FRAG_NEEDED)
>  		return;
>  
> -	spi = ntohl(ntohs(ipch->cpi));
> +	spi = htonl(ntohs(ipch->cpi));

Unfortunately the gcc on i386 generates horrible code for that construct.
So lets bite the bullet and optimise it ourselves.

[IPSEC]: Optimise be16/be32 conversions

Up until now we've used constructs such as ntohl(ntohs(x)) to convert
between be16 and be32 quantities, in particular, the CPI for IPComp.
The compiler dutifully generates code on i386 to perform both operations
rather than optimising them away.

So it's worthwhile to add new primitives to handle these operations
specifically.  The following patch addes be16_to_be32 and be32_to_be16
and uses them for IPComp.

This patch was prompted by a sparse clean-up patch from Alexey Dobriyan.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--IJpNTDwzlM2Ie8A6
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="ipcomp-spi-cleanup.patch"

diff --git a/include/linux/byteorder/big_endian.h b/include/linux/byteorder/big_endian.h
index bef8789..7ea1042 100644
--- a/include/linux/byteorder/big_endian.h
+++ b/include/linux/byteorder/big_endian.h
@@ -101,6 +101,9 @@
 #define __cpu_to_be16s(x) do {} while (0)
 #define __be16_to_cpus(x) do {} while (0)
 
+#define __be32_to_be16(x) ((__force __be16)(__be32)x)
+#define __be16_to_be32(x) ((__force __be32)(__be16)x)
+
 #include <linux/byteorder/generic.h>
 
 #endif /* _LINUX_BYTEORDER_BIG_ENDIAN_H */
diff --git a/include/linux/byteorder/generic.h b/include/linux/byteorder/generic.h
index e86e4a9..0bafb90 100644
--- a/include/linux/byteorder/generic.h
+++ b/include/linux/byteorder/generic.h
@@ -124,6 +124,8 @@
 #define be32_to_cpus __be32_to_cpus
 #define cpu_to_be16s __cpu_to_be16s
 #define be16_to_cpus __be16_to_cpus
+#define be32_to_be16 __be32_to_be16
+#define be16_to_be32 __be16_to_be32
 #endif
 
 
diff --git a/include/linux/byteorder/little_endian.h b/include/linux/byteorder/little_endian.h
index 86e62b7..ab6abcd 100644
--- a/include/linux/byteorder/little_endian.h
+++ b/include/linux/byteorder/little_endian.h
@@ -101,6 +101,9 @@
 #define __cpu_to_be16s(x) __swab16s((x))
 #define __be16_to_cpus(x) __swab16s((x))
 
+#define __be32_to_be16(x) ((__force __be16)((__force __u32)(__be32)x >> 16))
+#define __be16_to_be32(x) ((__force __be32)((__force __u32)(__be16)x << 16))
+
 #include <linux/byteorder/generic.h>
 
 #endif /* _LINUX_BYTEORDER_LITTLE_ENDIAN_H */
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index cd810f4..db04339 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -188,7 +188,7 @@
 	ipch = (struct ip_comp_hdr *)((char *)iph + iph->ihl * 4);
 	ipch->nexthdr = iph->protocol;
 	ipch->flags = 0;
-	ipch->cpi = htons((u16 )ntohl(x->id.spi));
+	ipch->cpi = be32_to_be16(x->id.spi);
 	iph->protocol = IPPROTO_COMP;
 	ip_send_check(iph);
 	return 0;
@@ -210,7 +210,7 @@
 	    skb->h.icmph->code != ICMP_FRAG_NEEDED)
 		return;
 
-	spi = ntohl(ntohs(ipch->cpi));
+	spi = be16_to_be32(ipch->cpi);
 	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr,
 	                      spi, IPPROTO_COMP, AF_INET);
 	if (!x)
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index f285bbf..30b671c 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -219,9 +219,9 @@
 
 		case IPPROTO_COMP:
 			if (pskb_may_pull(skb, xprth + 4 - skb->data)) {
-				u16 *ipcomp_hdr = (u16 *)xprth;
+				__be16 *ipcomp_hdr = (__be16 *)xprth;
 
-				fl->fl_ipsec_spi = ntohl(ntohs(ipcomp_hdr[1]));
+				fl->fl_ipsec_spi = be16_to_be32(ipcomp_hdr[1]);
 			}
 			break;
 		default:
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index 05eb67d..6ed793e 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -190,7 +190,7 @@
 	ipch = (struct ipv6_comp_hdr *)start;
 	ipch->nexthdr = *skb->nh.raw;
 	ipch->flags = 0;
-	ipch->cpi = htons((u16 )ntohl(x->id.spi));
+	ipch->cpi = be32_to_be16(x->id.spi);
 	*skb->nh.raw = IPPROTO_COMP;
 
 out_ok:
@@ -208,7 +208,7 @@
 	if (type != ICMPV6_DEST_UNREACH && type != ICMPV6_PKT_TOOBIG)
 		return;
 
-	spi = ntohl(ntohs(ipcomph->cpi));
+	spi = be16_to_be32(ipcomph->cpi);
 	x = xfrm_state_lookup((xfrm_address_t *)&iph->daddr, spi, IPPROTO_COMP, AF_INET6);
 	if (!x)
 		return;
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index b549710..65f208d 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -62,7 +62,7 @@
 	case IPPROTO_COMP:
 		if (!pskb_may_pull(skb, sizeof(struct ip_comp_hdr)))
 			return -EINVAL;
-		*spi = ntohl(ntohs(*(u16*)(skb->h.raw + 2)));
+		*spi = be16_to_be32(*(__be16 *)(skb->h.raw + 2));
 		*seq = 0;
 		return 0;
 	default:

--IJpNTDwzlM2Ie8A6--
