From: Timo Teras <timo.teras@iki.fi>
Subject: Re: [PATCH] Revert "ip_gre: make ipgre_tunnel_xmit() not parse
 network header as IP unconditionally"
Date: Wed, 13 Mar 2013 17:56:43 +0200
Message-ID: <20130313175643.16218a15@vostro>
References: <1363178269-27553-1-git-send-email-timo.teras@iki.fi>
	<20130313150510.GF19577@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: Isaku Yamahata <yamahata@valinux.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f49.google.com ([74.125.83.49]:65419 "EHLO
	mail-ee0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932656Ab3CMP4M convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 11:56:12 -0400
Received: by mail-ee0-f49.google.com with SMTP id d41so541661eek.36
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 08:56:11 -0700 (PDT)
In-Reply-To: <20130313150510.GF19577@valinux.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Mar 2013 00:05:10 +0900
Isaku Yamahata <yamahata@valinux.co.jp> wrote:

> Hi.
>=20
> On Wed, Mar 13, 2013 at 02:37:49PM +0200, Timo Ter=C3=A4s wrote:
> > This reverts commit 412ed94744d16806fbec3bd250fd94e71cde5a1f.
> >=20
> > The commit is wrong as tiph points to the outer IPv4 header which i=
s
> > installed at ipgre_header() and not the inner one which is protocol
> > dependant.
> >=20
> > This commit broke succesfully opennhrp which use PF_PACKET socket
> > with ETH_P_NHRP protocol. Additionally ssl_addr is set to the
> > link-layer IPv4 address. This address is written by ipgre_header()
> > to the skb earlier, and this is the IPv4 header tiph should point
> > to - regardless of the inner protocol payload.
>=20
> Is this the case only for ETH_P_HNRP?
> I wrote the patch having MPLS over GRE in mind.
> Should it be something like this?
>   if (protocol =3D=3D htons(ETH_P_IP) || protocol =3D=3D htons(ETH_P_=
NHRP))
>     ....

No, the original code was correct for all protocols.

tiph refers to the IPv4 headers pushed by ip_gre driver in
ipgre_header() function. This is _always_ present regardless of the
inner protocol. Thus no checking for protocol should be done.

And for reference: NHRP does not have iphdr, it is completely different
payload.

What happens is on xmit path is:

 1. ipgre_header() is always called first with NBMA destination
    address and outer IPv4 + GRE headers are pushed here with
    per-packet destination set

 2. ipgre_tunnel_xmit() is called, tiph points to the tunnel's
    IPv4 header, gre_hlen is set to zero so that the header is not
    pushed twice, but the existing header is modified later

Thus, it does not matter if the payload is MPLS, we will not refer to
the mpls data - the skb has already tunnel's outer IPv4 and GRE header
pushed, and tiph will refer to the tunnel's IPv4 header.

- Timo
