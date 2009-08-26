From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: UDP multicast packet loss not reported if TX ring overrun?
Date: Wed, 26 Aug 2009 16:22:45 +0200
Message-ID: <4A954535.2000304@gmail.com>
References: <OFB18AD855.24C5AC71-ON8825761D.00687D5E-8825761D.0068BB9C@us.ibm.com>  <alpine.DEB.1.10.0908251514190.17963@gentwo.org> <1251239734.3169.65.camel@w-sridhar.beaverton.ibm.com> <alpine.DEB.1.10.0908261006520.9924@gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	David Stevens <dlstevens@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	niv@linux.vnet.ibm.com, sri@linux.vnet.ibm.com
To: Christoph Lameter <cl@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38211 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755141AbZHZOX1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2009 10:23:27 -0400
In-Reply-To: <alpine.DEB.1.10.0908261006520.9924@gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> I also see no UDP stats for packet drops. If Erics fix gets in then
> ip_push_pending_frames() will give us an error code on drop.
> Incrementing SNDBUFERRORS would require this simple patch.
>=20

I think it's already done in udp_sendmsg()

Code starting at line 765 in net/ipv4/udp.c

        /*
         * ENOBUFS =3D no kernel mem, SOCK_NOSPACE =3D no sndbuf space.=
  Reporting
         * ENOBUFS might not be good (it's not tunable per se), but oth=
erwise
         * we don't have a good statistic (IpOutDiscards but it can be =
too many
         * things).  We could add another new stat but at least for now=
 that
         * seems like overkill.
         */
        if (err =3D=3D -ENOBUFS || test_bit(SOCK_NOSPACE, &sk->sk_socke=
t->flags)) {
                UDP_INC_STATS_USER(sock_net(sk),
                                UDP_MIB_SNDBUFERRORS, is_udplite);
        }


>=20
> UDP: Account for TX drops
>=20
> UDP layer is currently not incrementing error counters when packets a=
re
> dropped. Use the SNDBUFERRORS to indicate packet drops on send.
>=20
> Signed-off-by: Christoph Lameter <cl@linux-foundation.org>
>=20
> ---
>  net/ipv4/udp.c |    7 +++++++
>  1 file changed, 7 insertions(+)
>=20
> Index: linux-2.6/net/ipv4/udp.c
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> --- linux-2.6.orig/net/ipv4/udp.c	2009-08-26 13:21:30.000000000 +0000
> +++ linux-2.6/net/ipv4/udp.c	2009-08-26 13:46:35.000000000 +0000
> @@ -559,6 +559,13 @@ static int udp_push_pending_frames(struc
>=20
>  send:
>  	err =3D ip_push_pending_frames(sk);
> +
> +	if (err)
> +		/*
> +		 * Packet was dropped.
> +		 */
> +		UDP_INC_STATS_USER(sock_net(sk),
> +			UDP_MIB_SNDBUFERRORS, is_udplite);
>  out:
>  	up->len =3D 0;
>  	up->pending =3D 0;

