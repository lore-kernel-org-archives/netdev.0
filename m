From: Doug Kehn <rdkehn@yahoo.com>
Subject: Re: Multicast Fails Over Multipoint GRE Tunnel
Date: Tue, 15 Mar 2011 14:33:37 -0700 (PDT)
Message-ID: <666427.5500.qm@web39303.mail.mud.yahoo.com>
References: <4D7F9592.5050408@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>,
	=?iso-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web39303.mail.mud.yahoo.com ([66.94.238.170]:36994 "HELO
	web39303.mail.mud.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752841Ab1COVdi convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Mar 2011 17:33:38 -0400
In-Reply-To: <4D7F9592.5050408@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Timo,


--- On Tue, 3/15/11, Timo Ter=E4s <timo.teras@iki.fi> wrote:

> From: Timo Ter=E4s <timo.teras@iki.fi>
> Subject: Re: Multicast Fails Over Multipoint GRE Tunnel
> To: "Eric Dumazet" <eric.dumazet@gmail.com>
> Cc: "Doug Kehn" <rdkehn@yahoo.com>, netdev@vger.kernel.org
> Date: Tuesday, March 15, 2011, 12:36 PM
> On 03/15/2011 05:34 PM, Eric Dumazet
> wrote:
> > Le lundi 14 mars 2011 =E0 16:34 -0700, Doug Kehn a
> =E9crit :
> >> I'm running kernel version 2.6.36 on ARM XSCALE
> (big-endian) and multicast over a multipoint GRE tunnel
> isn't working.=A0 For my architecture, this worked on
> 2.6.26.8.=A0 For x86, multicast over a multipoint GRE
> tunnel worked with kernel version 2.6.31 but failed with
> version 2.6.35.=A0 Multicast over a multipoint GRE tunnel
> fails because ipgre_header() fails the 'if (iph->daddr)'
> check and reutrns -t->hlen.=A0 ipgre_header() is being
> called, from neigh_connected_output(), with a non-null
> daddr; the contents of daddr is zero.
> >>
> >> Reverting the ip_gre.c patch posted in http://marc.info/?l=3Dlinux=
-netdev&m=3D126762491525281&w=3D2
> resolves the problem.=A0 (Reviewing the HEAD of
> net-next-2.6 it appears that ipgre_header() remains
> unchanged from 2.6.36.)
> >>
> >> The configuration used to discover/diagnose the
> problem:
> >>
> >> ip tunnel add tun1 mode gre key 11223344 ttl 64
> csum remote any
> >> ip link set dev tun1 up
> >> ip link set dev tun1 multicast on
> >> ip addr flush dev tun1
> >> ip addr add 10.40.92.114/24 broadcast 10.40.92.255
> dev tun1
> >>
> >> 12: tun1: <MULTICAST,NOARP,UP,10000> mtu
> 1468 qdisc noqueue
> >>=A0 =A0=A0=A0link/gre 0.0.0.0 brd
> 0.0.0.0
> >>=A0 =A0=A0=A0inet 10.40.92.114/24 brd
> 10.40.92.255 scope global tun1
> >>
> >> Then attempt:
> >> ping -I tun1 224.0.0.9
> >>
> >> Are additional configuration steps now required
> for multicast over multipoint GRE tunnel or is
> ipgre_header() in error?
> >=20
> > Hi Doug
> >=20
> > CC Timo Teras <timo.teras@iki.fi>
> >=20
> > I would do a partial revert of Timo patch, but this
> means initial
> > concern should be addressed ?
> >=20
> > (Timo mentioned :=20
> > =A0=A0=A0 If the NOARP packets are not
> dropped, ipgre_tunnel_xmit() will
> > =A0=A0=A0 take rt->rt_gateway (=3D NBMA IP)
> and use that for route
> > =A0=A0=A0 look up (and may lead to bogus xfrm
> acquires).)
> >=20
> >=20
> > Is the following works for you ?
>=20
> I have memory that _header() is called with daddr being
> valid pointer,
> but pointing to zero memory. So basically my situation
> would break with
> this.
>=20
> The above configuration would be fixable by setting
> broadcast to tun1
> interface explicitly. But I'm not sure if the above
> configuration is
> somehow different that it'd need to work.
>=20
> Basically how things work on send path is:
>  1. arp_constructor maps multicast address to NUD_NOARP
>  2. arp_mc_map in turn copies dev->broadcast to haddr
> =A0 =A0 (so you get the ip packet pointing to zero
> ip)
> =A0 =A0 - i assumed normally gre tunnels would have
> the
> =A0 =A0 =A0 broadcast address set
>  3. ipgre_tunnel_xmit checks for daddr=3D=3D0 and uses the
> =A0 =A0 rt_gateway then, which would map to the
> multicast
> =A0 =A0 address
>=20
> So I assume that the above ping command not working would
> end up sending
> gre encapsulated packet where both the inner and outer IP
> address is the
> same multicast address?
>=20
> Looks like my patch also broke the default behaviour that
> if one has
> such GRE tunnel, and you send unicast packets, it would
> default the link
> destination to be same as the inner destination. Not sure
> if this would
> be useful.
>=20
> So basically my situation is undistinguishable from the
> above one. The
> only difference is that the above problems only with
> multicast, and I'm
> having with unicast.
>=20
> I think the fundamental problem is that arp_mc_map maps the
> multicast
> address to zeroes (due to device broadcast being zero).
>=20
> Could we instead maybe do something like:
>=20
> diff --git a/net/ipv4/arp.c b/net/ipv4/arp.c
> index 7927589..372448a 100644
> --- a/net/ipv4/arp.c
> +++ b/net/ipv4/arp.c
> @@ -215,6 +215,12 @@ int arp_mc_map(__be32 addr, u8 *haddr,
> struct
> net_device *dev, int dir)
> =A0 =A0 =A0 =A0 case ARPHRD_INFINIBAND:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0
> ip_ib_mc_map(addr, dev->broadcast, haddr);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0
> return 0;
> +=A0 =A0 =A0=A0=A0case ARPHRD_IPGRE:
> +=A0 =A0 =A0 =A0 =A0 =A0
> =A0=A0=A0if (dev->broadcast)
> +=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0
> =A0 =A0 =A0=A0=A0memcpy(haddr,
> dev->broadcast, dev->addr_len);
> +=A0 =A0 =A0 =A0 =A0 =A0
> =A0=A0=A0else
> +=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0
> =A0 =A0 =A0=A0=A0memcpy(haddr, &addr,
> sizeof(addr));
> +=A0 =A0 =A0 =A0 =A0 =A0
> =A0=A0=A0return 0;
> =A0 =A0 =A0 =A0 default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if
> (dir) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0
> =A0 =A0 =A0 =A0 memcpy(haddr, dev->broadcast,
> dev->addr_len);
>=20


I wasn't sure if the above patch was in addition too or in lieu of the =
partial revert of ipgre_header() suggested by Eric; both cases were att=
empted.

The multicast scenario described does not work if only the arp_mc_map()=
 patch is applied.

The multicast scenario described does work if the partial revert of ipg=
re_header(), suggested by Eric, and the arp_mc_map patch are applied.

Regards,
=2E..doug



     =20
