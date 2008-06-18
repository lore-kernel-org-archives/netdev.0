From: Karsten Keil <kkeil@suse.de>
Subject: Re: [PATCH] [IPv6] Do not use loopback as source address on other interfaces
Date: Wed, 18 Jun 2008 19:49:07 +0200
Message-ID: <20080618174907.GA31937@pingi.kke.suse.de>
References: <20080618132312.GA25004@pingi.kke.suse.de> <20080618.223600.81071656.yoshfuji@linux-ipv6.org> <20080618140558.GB25004@pingi.kke.suse.de> <20080618.233607.20745708.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38209 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751810AbYFRRtJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 13:49:09 -0400
Received: from Relay2.suse.de (relay-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 7B68F4599D
	for <netdev@vger.kernel.org>; Wed, 18 Jun 2008 19:49:08 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20080618.233607.20745708.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Yoshfuji,

On Wed, Jun 18, 2008 at 11:36:07PM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:

Verified that this patch fix the TAHI issue and that ping6 ::1 still wo=
rks.
So this should go in.

=2E..

> ipv6: Drop packets for loopback address from outside of the box.
>=20
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>=20
> --=20
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index e0a612b..f422f72 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -367,6 +367,12 @@ static inline int ipv6_addr_any(const struct in6=
_addr *a)
>  		 a->s6_addr32[2] | a->s6_addr32[3] ) =3D=3D 0);=20
>  }
> =20
> +static inline int ipv6_addr_loopback(const struct in6_addr *a)
> +{
> +	return ((a->s6_addr32[0] | a->s6_addr32[1] |
> +		 a->s6_addr32[2] | (a->s6_addr32[3] ^ htonl(1))) =3D=3D 0);
> +}
> +
>  static inline int ipv6_addr_v4mapped(const struct in6_addr *a)
>  {
>  	return ((a->s6_addr32[0] | a->s6_addr32[1] |
> diff --git a/net/ipv6/ip6_input.c b/net/ipv6/ip6_input.c
> index 4e5c861..17eb48b 100644
> --- a/net/ipv6/ip6_input.c
> +++ b/net/ipv6/ip6_input.c
> @@ -102,6 +102,15 @@ int ipv6_rcv(struct sk_buff *skb, struct net_dev=
ice *dev, struct packet_type *pt
>  	if (hdr->version !=3D 6)
>  		goto err;
> =20
> +	/*
> +	 * RFC4291 2.5.3
> +	 * A packet received on an interface with a destination address
> +	 * of loopback must be dropped.
> +	 */
> +	if (!(dev->flags & IFF_LOOPBACK) &&
> +	    ipv6_addr_loopback(&hdr->daddr))
> +		goto err;
> +
>  	skb->transport_header =3D skb->network_header + sizeof(*hdr);
>  	IP6CB(skb)->nhoff =3D offsetof(struct ipv6hdr, nexthdr);
> =20
>=20
>=20
> --yoshfuji
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=20
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex,=
 HRB 16746 (AG Nuernberg)
