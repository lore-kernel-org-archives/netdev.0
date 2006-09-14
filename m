From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipip and ip_gre encapsulation bugs
Date: Thu, 14 Sep 2006 10:23:42 +1000
Message-ID: <E1GNf14-0004dW-00@gondolin.me.apana.org.au>
References: <E1GNBTO-0001v7-Pb@ZenIV.linux.org.uk>
Cc: davem@davemloft.net, torvalds@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:34573 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1751259AbWINAY2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Sep 2006 20:24:28 -0400
To: viro@ftp.linux.org.uk (Al Viro)
In-Reply-To: <E1GNBTO-0001v7-Pb@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Viro <viro@ftp.linux.org.uk> wrote:
> Handling of ipip and ip_gre ICMP error relaying is b0rken; it accesses
> 32bit net-endian field as host-endian, does comparison, subtraction and
> stuffs the result to 32bit net-endian.  Without any conversions.

Thanks for spotting this.

> @@ -422,14 +423,16 @@ #else
>        default:
>                return;
>        case ICMP_PARAMETERPROB:
> -               if (skb->h.icmph->un.gateway < (iph->ihl<<2))
> +               n = ntohl(skb->h.icmph->un.gateway);
> +               if (n < (iph->ihl<<2))
>                        return;

I don't think this is right.  The original code works correctly on
little-endian.  The patch introduces a swab on little-endian so it
isn't right anymore.

I suggest that you add a member to the icmph union which is just a
u8 since that is what RFC792 specifies for PARAMETERPROB.  That way
we can just use that u8 value without any swapping at all.

> @@ -440,13 +443,14 @@ #else
>                        return;
>                case ICMP_FRAG_NEEDED:
>                        /* And it is the only really necessary thing :-) */
> -                       rel_info = ntohs(skb->h.icmph->un.frag.mtu);
> -                       if (rel_info < grehlen+68)
> +                       n = ntohs(skb->h.icmph->un.frag.mtu);
> +                       if (n < grehlen+68)
>                                return;

That's a good clean-up.

> diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
> index 76ab50b..c27b071 100644
> --- a/net/ipv4/ipip.c
> +++ b/net/ipv4/ipip.c
> @@ -354,14 +355,15 @@ #else
>        default:
>                return 0;
>        case ICMP_PARAMETERPROB:
> -               if (skb->h.icmph->un.gateway < hlen)
> +               n = htonl(skb->h.icmph->un.gateway);
> +               if (n < hlen)
>                        return 0;

Same problem as above.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
