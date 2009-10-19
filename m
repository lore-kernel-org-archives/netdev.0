From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] IPv4: skip loopback checksums in ip_rcv()
Date: Mon, 19 Oct 2009 22:42:02 +0200
Message-ID: <4ADCCF1A.7070301@gmail.com>
References: <200910192134.02125.schmto@hrz.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Torsten Schmidt <torsten.schmidt@s2006.tu-chemnitz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:42746 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757557AbZJSUmB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 16:42:01 -0400
In-Reply-To: <200910192134.02125.schmto@hrz.tu-chemnitz.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Torsten Schmidt a =E9crit :
> Skip loopback checksum in ip_rcv() for speed optimisation.
>=20
> Signed-off-by: Torsten Schmidt <schmto@hrz.tu-chemnitz.de>
> ---
>  net/ipv4/ip_input.c |    7 ++++---
>  1 files changed, 4 insertions(+), 3 deletions(-)
>=20
> diff --git a/net/ipv4/ip_input.c b/net/ipv4/ip_input.c
> index 6c98b43..dc72286 100644
> --- a/net/ipv4/ip_input.c
> +++ b/net/ipv4/ip_input.c
> @@ -406,7 +406,7 @@ int ip_rcv(struct sk_buff *skb, struct net_device=
 *dev, struct packet_type *pt,
>  	 *
>  	 *	1.	Length at least the size of an ip header
>  	 *	2.	Version of 4
> -	 *	3.	Checksums correctly. [Speed optimisation for later, skip loop=
back checksums]
> +	 *	3.	Checksums correctly. [Speed optimisation: skip loopback check=
sums]
>  	 *	4.	Doesn't have a bogus length
>  	 */
> =20
> @@ -418,8 +418,9 @@ int ip_rcv(struct sk_buff *skb, struct net_device=
 *dev, struct packet_type *pt,
> =20
>  	iph =3D ip_hdr(skb);
> =20
> -	if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
> -		goto inhdr_error;
> +	if (!ipv4_is_loopback(iph->daddr))
> +		if (unlikely(ip_fast_csum((u8 *)iph, iph->ihl)))
> +			goto inhdr_error;
> =20
>  	len =3D ntohs(iph->tot_len);
>  	if (skb->len < len) {

This is bogus IMHO.

One bit could be corrupted in iph, and ntohl(iph->daddr) becomes 0x7fxx=
yyzz,
we then accept a bogus frame. This is a RFC violation.

This also slows down non loopback devices, adding an extra test.

ip_fast_csum() is really fast (about 16 instructions).

