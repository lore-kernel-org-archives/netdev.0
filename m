From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2.6.17] support for TSO over IPv6
Date: Fri, 30 Jun 2006 09:32:44 +1000
Message-ID: <E1Fw604-0006yP-00@gondolin.me.apana.org.au>
References: <Pine.GSO.4.10.10606291810490.12773-100000@guinness>
Cc: netdev@vger.kernel.org, jgarzik@pobox.com, shemminger@osdl.org,
	Leonid.Grossman@neterion.com, Ravinandan.Arakali@neterion.com,
	Ananda.Raju@neterion.com, sivakumar.subramani@neterion.com,
	Sriram.Rapuru@neterion.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:37138 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S1751308AbWF2Xds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 19:33:48 -0400
To: Ananda.Raju@neterion.com (Ananda Raju)
In-Reply-To: <Pine.GSO.4.10.10606291810490.12773-100000@guinness>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ananda Raju <Ananda.Raju@neterion.com> wrote:
>        This patch enables TSO over IPv6. Currently Linux network stacks
>        restricts TSO over IPv6 by clearing of the NETIF_F_TSO bit from
>        "dev->features". This patch will remove this restriction.

Thanks, looks good over all.
 
>        SKB_GSO_TCPV4 renamed to SKB_GSO_TCP to make it generic GSO packet.
>        SKB_GSO_UDPV4 renamed to SKB_GSO_UDP as UFO is not a IPv4 feature.
>        UFO is supported over IPv6 also

This bit is wrong though.  TCPv4 and TCPv6 packets can't share the same
GSO feature bit.  The reason is that GSO/TSO is no longer just activated
by dev->features.  Bridges can forward GSO/TSO packets through at any time.
This is why it is crucial that each packet specficies exactly the features
that it requires from the hardware.

For UFO, it's OK to have just SKB_GSO_UDP since IIRC your card is the only
one that supports it and it supports both protocols anyway.

> diff -upNr netdev.org/include/linux/skbuff.h netdev.ipv6_tso/include/linux/skbuff.h
> --- netdev.org/include/linux/skbuff.h   2006-06-27 07:30:36.000000000 -0700
> +++ netdev.ipv6_tso/include/linux/skbuff.h      2006-06-27 07:38:48.000000000 -0700
> @@ -170,8 +170,9 @@ enum {
> };
> 
> enum {
> -       SKB_GSO_TCPV4 = 1 << 0,
> -       SKB_GSO_UDPV4 = 1 << 1,
> +       SKB_GSO_TCP = 1 << 0,
> +       SKB_GSO_UDP = 1 << 1,
> +       SKB_GSO_TCPV6 = 1 << 2,
> };

BTW, you should rediff against Dave's current tree which has a few
extra bits there.

You should also leave TCPV4 as is and just add the TCPV6 bit.
 
> diff -upNr netdev.org/net/ipv4/tcp_output.c netdev.ipv6_tso/net/ipv4/tcp_output.c
> --- netdev.org/net/ipv4/tcp_output.c    2006-06-27 07:30:36.000000000 -0700
> +++ netdev.ipv6_tso/net/ipv4/tcp_output.c       2006-06-27 07:38:48.000000000 -0700
> @@ -525,7 +525,7 @@ static void tcp_set_skb_tso_segs(struct 
>                factor /= mss_now;
>                skb_shinfo(skb)->gso_segs = factor;
>                skb_shinfo(skb)->gso_size = mss_now;
> -               skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
> +               skb_shinfo(skb)->gso_type = SKB_GSO_TCP;

You need to set SKB_GSO_TCPV6 for IPv6 packets here.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
