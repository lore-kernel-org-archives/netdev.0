From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] ip6tables: Read outside array bounds
Date: Mon, 31 Aug 2009 15:31:49 +0200
Message-ID: <4A9BD0C5.4010600@trash.net>
References: <4A966C94.1060703@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020502030800030505010408"
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61886 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbZHaNbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Aug 2009 09:31:52 -0400
In-Reply-To: <4A966C94.1060703@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020502030800030505010408
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

Roel Kluin wrote:
> Check bounds before reading from the s6_addr array. It read 1 past
> the end at s6_addr[16] and eui64[] was also read 1 past the end.
> 
> diff --git a/net/ipv6/netfilter/ip6t_eui64.c b/net/ipv6/netfilter/ip6t_eui64.c
> index db610ba..7b40a20 100644
> --- a/net/ipv6/netfilter/ip6t_eui64.c
> +++ b/net/ipv6/netfilter/ip6t_eui64.c
> @@ -43,8 +43,8 @@ eui64_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
>  			eui64[0] ^= 0x02;
>  
>  			i = 0;
> -			while (ipv6_hdr(skb)->saddr.s6_addr[8 + i] == eui64[i]
> -			       && i < 8)
> +			while (i < 8 && ipv6_hdr(skb)->saddr.s6_addr[8 + i] ==
> +					eui64[i])
>  				i++;
>  
>  			if (i == 8)

Nice catch, thanks. We might as well use memcmp though, so I've
committed this patch:


--------------020502030800030505010408
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

commit 488908696971c5ea1dcc5d13f29c158ba4f6ae7d
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Aug 31 15:30:31 2009 +0200

    netfilter: ip6t_eui: fix read outside array bounds
    
    Use memcmp() instead of open coded comparison that reads one byte past
    the intended end.
    
    Based on patch from Roel Kluin <roel.kluin@gmail.com>
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv6/netfilter/ip6t_eui64.c b/net/ipv6/netfilter/ip6t_eui64.c
index db610ba..ca287f6 100644
--- a/net/ipv6/netfilter/ip6t_eui64.c
+++ b/net/ipv6/netfilter/ip6t_eui64.c
@@ -23,7 +23,6 @@ static bool
 eui64_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 {
 	unsigned char eui64[8];
-	int i = 0;
 
 	if (!(skb_mac_header(skb) >= skb->head &&
 	      skb_mac_header(skb) + ETH_HLEN <= skb->data) &&
@@ -42,12 +41,8 @@ eui64_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 			eui64[4] = 0xfe;
 			eui64[0] ^= 0x02;
 
-			i = 0;
-			while (ipv6_hdr(skb)->saddr.s6_addr[8 + i] == eui64[i]
-			       && i < 8)
-				i++;
-
-			if (i == 8)
+			if (!memcmp(ipv6_hdr(skb)->saddr.s6_addr + 8, eui64,
+				    sizeof(eui64)))
 				return true;
 		}
 	}

--------------020502030800030505010408--
