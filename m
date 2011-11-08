From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: dst->obsolete has become pointless
Date: Tue, 8 Nov 2011 10:34:24 +0100
Message-ID: <20111108093424.GG22141@secunet.com>
References: <20111104.230910.520924516201406800.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, timo.teras@iki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53277 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753854Ab1KHJe2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Nov 2011 04:34:28 -0500
Content-Disposition: inline
In-Reply-To: <20111104.230910.520924516201406800.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 04, 2011 at 11:09:10PM -0400, David Miller wrote:
>=20
> While researching the things unearthed by Steffen Klassert wrt. PMTU
> handling in the current tree I went to do some research on what the
> real story is wrt. dst->obsolete.
>=20
> And sure enough EVERY SINGLE ipv4 and ipv6 route is created with
> obsolete set to -1, so we unconditionally always invoke ->dst_check()=
=2E
>=20
> This makes it completely pointless as an optimization to avoid callin=
g
> the dst_ops->dst_check() method.  It never triggers.
>=20
> This stems from Timo's change to make route expiry properly visible
> to IPSEC stacked routes:
>=20
> --
> commit d11a4dc18bf41719c9f0d7ed494d295dd2973b92
> Author: Timo Ter=E4s <timo.teras@iki.fi>
> Date:   Thu Mar 18 23:20:20 2010 +0000
>=20
>     ipv4: check rt_genid in dst_check
> ...
> --
>=20
> Only DecNET creates routes with obsolete initially set to zero, and
> therefore only hits ->dst_check() when dst_free is invoked on the rou=
te
> during a flush of the decnet routing tables.
>=20
> And actually this is how ipv4 operated before we started using
> generation counts instead of flushing the entire table.  IPV6 seems t=
o
> always have used the FIB6 tree serial numbers for expiration checking
> and therefore always set obsolete to -1 on new routes.
>=20
> So we can't just get rid of the dst->obsolete check in dst_check() an=
d
> __sk_dst_check() because that will break DecNET because DecNET's
> ->dst_check() handler assumes that if it was called then the route
> is obsolete and it just plainly returns NULL to tell the caller the
> route is in fact invalid.
>=20

I don't know what to do with DecNET, but we probaply need to decide
about the future of dst->obsolete before we can fix the ipv4 PMTU
problems. Possible fixes might depend on whether ->dst_check() is
always invoked or not.
