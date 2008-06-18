From: Karsten Keil <kkeil@suse.de>
Subject: Re: [PATCH] [IPv6] Do not use loopback as source address on other interfaces
Date: Wed, 18 Jun 2008 18:11:42 +0200
Message-ID: <20080618161142.GD25004@pingi.kke.suse.de>
References: <20080618132312.GA25004@pingi.kke.suse.de> <20080618.223600.81071656.yoshfuji@linux-ipv6.org> <20080618140558.GB25004@pingi.kke.suse.de> <20080618.233607.20745708.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Mironov_Sergey@emc.com, akpm@linux-foundation.org,
	torvalds@linux-foundation.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:58477 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753446AbYFRQLs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Jun 2008 12:11:48 -0400
Content-Disposition: inline
In-Reply-To: <20080618.233607.20745708.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 18, 2008 at 11:36:07PM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20080618140558.GB25004@pingi.kke.suse.de> (at Wed, 18 Jun=
 2008 16:05:58 +0200), Karsten Keil <kkeil@suse.de> says:
>=20
> > On Wed, Jun 18, 2008 at 10:36:00PM +0900, YOSHIFUJI Hideaki / =E5=90=
=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> > > In article <20080618132312.GA25004@pingi.kke.suse.de> (at Wed, 18=
 Jun 2008 15:23:12 +0200), Karsten Keil <kkeil@suse.de> says:
> > >=20
> > > > RFC 4291 forbit the use of the loopback address as source outsi=
de a node
> > > > (paragraph 2.5.3).
> > > >=20
> > > > The latest TAHI test release 4.0.1 does have a check for this (=
ICMPv6 test
> > > > v6LC.5.1.2 Part F), so it fails currently on Linux.
> > > >=20
> > > > Signed-off-by: Sergey Mironov <Mironov_Sergey@emc.com>
> > > > Signed-off-by: Karsten Keil <kkeil@suse.de>
> > >=20
> > > I disagree this approach - too ad-hoc fix just to pass the tests.
> > >=20
> >=20
> > So you would prefer a more general test in some common place (like
> > __ip6_local_out() ) to avoid any packets with ::1 on other devices =
as
> > loopback ?
>=20
> No, we should not even accept packets for ::1 from outside of the box=
=2E
> Something like this.
>=20

Yes I was thinking about nearly the same patch now :-)

> ---
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

--=20
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex,=
 HRB 16746 (AG Nuernberg)
