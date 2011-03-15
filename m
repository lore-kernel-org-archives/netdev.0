From: Doug Kehn <rdkehn@yahoo.com>
Subject: Re: Multicast Fails Over Multipoint GRE Tunnel
Date: Tue, 15 Mar 2011 14:24:42 -0700 (PDT)
Message-ID: <736238.4685.qm@web39308.mail.mud.yahoo.com>
References: <1300203277.2927.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Timo Teras <timo.teras@iki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web39308.mail.mud.yahoo.com ([66.94.238.175]:30387 "HELO
	web39308.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751239Ab1COVYn convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 17:24:43 -0400
In-Reply-To: <1300203277.2927.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

--- On Tue, 3/15/11, Eric Dumazet <eric.dumazet@gmail.com> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> Subject: Re: Multicast Fails Over Multipoint GRE Tunnel
> To: "Doug Kehn" <rdkehn@yahoo.com>
> Cc: netdev@vger.kernel.org, "Timo Teras" <timo.teras@iki.fi>
> Date: Tuesday, March 15, 2011, 11:34 AM
> Le lundi 14 mars 2011 =E0 16:34 -0700,
> Doug Kehn a =E9crit :
> > Hi All,
> >=20
> > I'm running kernel version 2.6.36 on ARM XSCALE
> (big-endian) and multicast over a multipoint GRE tunnel
> isn't working.=A0 For my architecture, this worked on
> 2.6.26.8.=A0 For x86, multicast over a multipoint GRE
> tunnel worked with kernel version 2.6.31 but failed with
> version 2.6.35.=A0 Multicast over a multipoint GRE tunnel
> fails because ipgre_header() fails the 'if (iph->daddr)'
> check and reutrns -t->hlen.=A0 ipgre_header() is being
> called, from neigh_connected_output(), with a non-null
> daddr; the contents of daddr is zero.
> >=20
> > Reverting the ip_gre.c patch posted in http://marc.info/?l=3Dlinux-=
netdev&m=3D126762491525281&w=3D2
> resolves the problem.=A0 (Reviewing the HEAD of
> net-next-2.6 it appears that ipgre_header() remains
> unchanged from 2.6.36.)
> >=20
> > The configuration used to discover/diagnose the
> problem:
> >=20
> > ip tunnel add tun1 mode gre key 11223344 ttl 64 csum
> remote any
> > ip link set dev tun1 up
> > ip link set dev tun1 multicast on
> > ip addr flush dev tun1
> > ip addr add 10.40.92.114/24 broadcast 10.40.92.255 dev
> tun1
> >=20
> > 12: tun1: <MULTICAST,NOARP,UP,10000> mtu 1468
> qdisc noqueue
> >=A0 =A0=A0=A0link/gre 0.0.0.0 brd 0.0.0.0
> >=A0 =A0=A0=A0inet 10.40.92.114/24 brd
> 10.40.92.255 scope global tun1
> >=20
> > Then attempt:
> > ping -I tun1 224.0.0.9
> >=20
> > Are additional configuration steps now required for
> multicast over multipoint GRE tunnel or is ipgre_header() in
> error?
>=20
> Hi Doug
>=20
> CC Timo Teras <timo.teras@iki.fi>
>=20
> I would do a partial revert of Timo patch, but this means
> initial
> concern should be addressed ?
>=20
> (Timo mentioned :=20
> =A0=A0=A0 If the NOARP packets are not dropped,
> ipgre_tunnel_xmit() will
> =A0=A0=A0 take rt->rt_gateway (=3D NBMA IP) and
> use that for route
> =A0=A0=A0 look up (and may lead to bogus xfrm
> acquires).)
>=20
>=20
> Is the following works for you ?
>=20
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index da5941f..47844fa2 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -1170,8 +1170,10 @@ static int ipgre_header(struct
> sk_buff *skb, struct net_device *dev,
> =20
>  =A0=A0=A0 if (saddr)
>  =A0=A0=A0 =A0=A0=A0
> memcpy(&iph->saddr, saddr, 4);
> -=A0=A0=A0 if (daddr)
> +=A0=A0=A0 if (daddr) {
>  =A0=A0=A0 =A0=A0=A0
> memcpy(&iph->daddr, daddr, 4);
> +=A0=A0=A0 =A0=A0=A0 return t->hlen;
> +=A0=A0=A0 }
>  =A0=A0=A0 if (iph->daddr)
>  =A0=A0=A0 =A0=A0=A0 return t->hlen;
> =20

Yes, the partial revert does work.

Regards,
=2E..doug



     =20
