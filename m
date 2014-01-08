From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: IPv6: Bug in net-next
Date: Wed, 8 Jan 2014 15:13:13 +0100
Message-ID: <20140108141313.GI9007@order.stressinduktion.org>
References: <1389187126.20074.YahooMailBasic@web125504.mail.ne1.yahoo.com> <1389188139.44648.YahooMailBasic@web125506.mail.ne1.yahoo.com> <20140108140400.GH9007@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: =?utf-8?Q?Fran=C3=A7ois-Xavier?= Le Bail <fx.lebail@yahoo.com>,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48341 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756223AbaAHONP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jan 2014 09:13:15 -0500
Content-Disposition: inline
In-Reply-To: <20140108140400.GH9007@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 08, 2014 at 03:04:00PM +0100, Hannes Frederic Sowa wrote:
> On Wed, Jan 08, 2014 at 05:35:39AM -0800, Fran=C3=A7ois-Xavier Le Bai=
l wrote:
> > On Wed, 1/8/14, Fran=C3=A7ois-Xavier Le Bail <fx.lebail@yahoo.com> =
wrote:
> >=20
> > > > I think there is a bug in actual net-next.
> >  =20
> > > > When I execute this code and press Crtl-C, all the IPv6
> > > > Link-Layer addresses are deleted.
> >  =20
> > > > This happened between
> > > > c1ddf295f5183a5189196a8035546842caa2055a and HEAD.
> >  =20
> > > > [...]
> > =20
> > > Sorry, it is not linked to this code.
> > > I'm looking for the reason ...
> > =20
> > It seems that the valid lifetime and preferred lft are set to 0 sec=
 for autoconfigured LLA.
>=20
> Grrr, I guess we should switch in addrconf_add_linklocal to call ipv6=
_add_addr
> with INFINITY_LIFE_TIME preferred and valid lft. IFA_PERMANENT may no=
w expire,
> too since commit fad8da3e0 ("ipv6 addrconf: fix preferred lifetime
> state-changing behavior while valid_lft is infinity").

I am testing this patch:

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 31f75ea..f7e86e3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -2528,7 +2528,8 @@ static void add_addr(struct inet6_dev *idev, cons=
t struct in6_addr *addr,
 	struct inet6_ifaddr *ifp;
=20
 	ifp =3D ipv6_add_addr(idev, addr, NULL, plen,
-			    scope, IFA_F_PERMANENT, 0, 0);
+			scope, IFA_F_PERMANENT,
+			INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
 	if (!IS_ERR(ifp)) {
 		spin_lock_bh(&ifp->lock);
 		ifp->flags &=3D ~IFA_F_TENTATIVE;
@@ -2656,7 +2657,8 @@ static void addrconf_add_linklocal(struct inet6_d=
ev *idev, const struct in6_addr
 #endif
=20
=20
-	ifp =3D ipv6_add_addr(idev, addr, NULL, 64, IFA_LINK, addr_flags, 0, =
0);
+	ifp =3D ipv6_add_addr(idev, addr, NULL, 64, IFA_LINK, addr_flags,
+			    INFINITY_LIFE_TIME, INFINITY_LIFE_TIME);
 	if (!IS_ERR(ifp)) {
 		addrconf_prefix_route(&ifp->addr, ifp->prefix_len, idev->dev, 0, 0);
 		addrconf_dad_start(ifp);
