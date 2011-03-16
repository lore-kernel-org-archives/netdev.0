From: Doug Kehn <rdkehn@yahoo.com>
Subject: Re: Multicast Fails Over Multipoint GRE Tunnel
Date: Wed, 16 Mar 2011 13:02:54 -0700 (PDT)
Message-ID: <500208.18069.qm@web39303.mail.mud.yahoo.com>
References: <4D805239.6040905@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: =?iso-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web39303.mail.mud.yahoo.com ([66.94.238.170]:23862 "HELO
	web39303.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753611Ab1CPUCz convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2011 16:02:55 -0400
In-Reply-To: <4D805239.6040905@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Timo,


--- On Wed, 3/16/11, Timo Ter=E4s <timo.teras@iki.fi> wrote:

> From: Timo Ter=E4s <timo.teras@iki.fi>
> Subject: Re: Multicast Fails Over Multipoint GRE Tunnel
> To: "Doug Kehn" <rdkehn@yahoo.com>
> Cc: "Eric Dumazet" <eric.dumazet@gmail.com>, netdev@vger.kernel.org
> Date: Wednesday, March 16, 2011, 2:01 AM
> On 03/15/2011 11:35 PM, Doug Kehn
> wrote:
> >> From: Timo Ter=E4s <timo.teras@iki.fi>
> >> Subject: Re: Multicast Fails Over Multipoint GRE
> Tunnel
> >> To: "Eric Dumazet" <eric.dumazet@gmail.com>
> >> Cc: "Doug Kehn" <rdkehn@yahoo.com>,
> netdev@vger.kernel.org
> >> Date: Tuesday, March 15, 2011, 12:36 PM
> >> On 03/15/2011 05:34 PM, Eric Dumazet
> >> wrote:
> >>> Le lundi 14 mars 2011 =E0 16:34 -0700, Doug
> Kehn a
> >> =E9crit :
> >>>> I'm running kernel version 2.6.36 on ARM
> XSCALE
> >> (big-endian) and multicast over a multipoint GRE
> tunnel
> >> isn't working.=A0 For my architecture, this
> worked on
> >> 2.6.26.8.=A0 For x86, multicast over a
> multipoint GRE
> >> tunnel worked with kernel version 2.6.31 but
> failed with
> >> version 2.6.35.=A0 Multicast over a multipoint
> GRE tunnel
> >> fails because ipgre_header() fails the 'if
> (iph->daddr)'
> >> check and reutrns -t->hlen.=A0
> ipgre_header() is being
> >> called, from neigh_connected_output(), with a
> non-null
> >> daddr; the contents of daddr is zero.
> >
> > I wasn't sure if the above patch was in addition too
> or in lieu of the partial revert of ipgre_header() suggested
> by Eric; both cases were attempted.
>=20
> It was intended without the ipgre_header revert. The
> partial revert does
> not differ from full revert related to my problem.
>=20
> > The multicast scenario described does not work if only
> the arp_mc_map() patch is applied.
>=20
> Uh. Right, the if test had wrong condition. The intention
> was to show
> the idea that we create the multicast-to-multicast GRE
> NOARP mappings in
> arp code where it should've been done in the first place
> (IMHO).
>=20
> Could you try the below patch? That should work better. And
> the
> ipgre_header should not be touched.
>=20
> - Timo
>=20
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 7927589..8c24845 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -215,6 +215,13 @@ int arp_mc_map(__be32 addr, u8 *haddr,
> struct
> net_device *dev, int dir)
>  =A0=A0=A0 case ARPHRD_INFINIBAND:
>  =A0=A0=A0 =A0=A0=A0 ip_ib_mc_map(addr,
> dev->broadcast, haddr);
>  =A0=A0=A0 =A0=A0=A0 return 0;
> +=A0=A0=A0 case ARPHRD_IPGRE:
> +=A0=A0=A0 =A0=A0=A0 if (dev->addr_len
> =3D=3D 4 &&
> +=A0=A0=A0 =A0=A0=A0 =A0 =A0
> get_unaligned_be32(dev->broadcast) !=3D INADDR_ANY)
> +=A0=A0=A0 =A0=A0=A0 =A0=A0=A0
> memcpy(haddr, dev->broadcast, dev->addr_len);
> +=A0=A0=A0 =A0=A0=A0 else
> +=A0=A0=A0 =A0=A0=A0 =A0=A0=A0
> memcpy(haddr, &addr, sizeof(addr));
> +=A0=A0=A0 =A0=A0=A0 return 0;
>  =A0=A0=A0 default:
>  =A0=A0=A0 =A0=A0=A0 if (dir) {
>  =A0=A0=A0 =A0=A0=A0 =A0=A0=A0
> memcpy(haddr, dev->broadcast, dev->addr_len);
> --

It does!  With this patch my configuration works.

Thanks,
=2E..doug



     =20
