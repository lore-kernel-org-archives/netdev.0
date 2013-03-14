From: Isaku Yamahata <yamahata@valinux.co.jp>
Subject: Re: [PATCH] Revert "ip_gre: make ipgre_tunnel_xmit() not parse
	network header as IP unconditionally"
Date: Thu, 14 Mar 2013 11:53:47 +0900
Message-ID: <20130314025347.GB18057@valinux.co.jp>
References: <1363178269-27553-1-git-send-email-timo.teras@iki.fi> <20130313150510.GF19577@valinux.co.jp> <20130313175643.16218a15@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Timo Teras <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.valinux.co.jp ([210.128.90.3]:49631 "EHLO
	mail.valinux.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753653Ab3CNCxs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 22:53:48 -0400
Content-Disposition: inline
In-Reply-To: <20130313175643.16218a15@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 13, 2013 at 05:56:43PM +0200, Timo Teras wrote:
> On Thu, 14 Mar 2013 00:05:10 +0900
> Isaku Yamahata <yamahata@valinux.co.jp> wrote:
>=20
> > Hi.
> >=20
> > On Wed, Mar 13, 2013 at 02:37:49PM +0200, Timo Ter=C3=A4s wrote:
> > > This reverts commit 412ed94744d16806fbec3bd250fd94e71cde5a1f.
> > >=20
> > > The commit is wrong as tiph points to the outer IPv4 header which=
 is
> > > installed at ipgre_header() and not the inner one which is protoc=
ol
> > > dependant.
> > >=20
> > > This commit broke succesfully opennhrp which use PF_PACKET socket
> > > with ETH_P_NHRP protocol. Additionally ssl_addr is set to the
> > > link-layer IPv4 address. This address is written by ipgre_header(=
)
> > > to the skb earlier, and this is the IPv4 header tiph should point
> > > to - regardless of the inner protocol payload.
> >=20
> > Is this the case only for ETH_P_HNRP?
> > I wrote the patch having MPLS over GRE in mind.
> > Should it be something like this?
> >   if (protocol =3D=3D htons(ETH_P_IP) || protocol =3D=3D htons(ETH_=
P_NHRP))
> >     ....
>=20
> No, the original code was correct for all protocols.
>=20
> tiph refers to the IPv4 headers pushed by ip_gre driver in
> ipgre_header() function. This is _always_ present regardless of the
> inner protocol. Thus no checking for protocol should be done.
>=20
> And for reference: NHRP does not have iphdr, it is completely differe=
nt
> payload.
>=20
> What happens is on xmit path is:
>=20
>  1. ipgre_header() is always called first with NBMA destination
>     address and outer IPv4 + GRE headers are pushed here with
>     per-packet destination set
>=20
>  2. ipgre_tunnel_xmit() is called, tiph points to the tunnel's
>     IPv4 header, gre_hlen is set to zero so that the header is not
>     pushed twice, but the existing header is modified later
>=20
> Thus, it does not matter if the payload is MPLS, we will not refer to
> the mpls data - the skb has already tunnel's outer IPv4 and GRE heade=
r
> pushed, and tiph will refer to the tunnel's IPv4 header.

You're right. Thanks for explanation.
Originally I tried to copy TTL in MPLS label into outer IP header.
But dropped MPLS bits.
--=20
yamahata
