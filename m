From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Re: Re: Link-local source IPv6 address in unicast Neighbor Solicitation towards global destination
Date: Tue, 25 Mar 2014 20:13:00 +0100
Message-ID: <20140325191300.GC22086@order.stressinduktion.org>
References: <20140306070250.GC26307@order.stressinduktion.org> <20140310024425.GG5493@order.stressinduktion.org> <trinity-a0afda04-2344-47fa-bfa9-d1d45d0c15f8-1394540117766@3capp-gmx-bs43>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Simon Schneider <simon-schneider@gmx.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59131 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754661AbaCYTNC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 15:13:02 -0400
Content-Disposition: inline
In-Reply-To: <trinity-a0afda04-2344-47fa-bfa9-d1d45d0c15f8-1394540117766@3capp-gmx-bs43>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Simon,

On Tue, Mar 11, 2014 at 01:15:17PM +0100, Simon Schneider wrote:
> Hi Hannes,
> thanks a lot.
>=20
> We'll integrate and test the patch.

Did the patch improve the situation for you? I wonder because I would l=
ike to
submit it for net-next then.

Thanks,

  Hannes

> > Gesendet: Montag, 10. M=C3=A4rz 2014 um 03:44 Uhr
> > Von: "Hannes Frederic Sowa" <hannes@stressinduktion.org>
> > An: "Simon Schneider" <simon-schneider@gmx.net>
> > Cc: netdev@vger.kernel.org
> > Betreff: Re: Re: Link-local source IPv6 address in unicast Neighbor=
 Solicitation towards global destination
> >
> > Hi Simon!
> >=20
> > On Thu, Mar 06, 2014 at 10:18:23AM +0100, Simon Schneider wrote:
> > > thanks, checking that would be good.
> > >=20
> > > Another point here (probably a bit academic): without link-local =
address on the interface (just the global one), the unicast NS for NUD =
is not sent at all.
> > >=20
> > > The neighbor cache entry is in DELAY state for some time, unicast=
 NS is not sent, then the entry is moved to FAILED rather quickly.
> >=20
> > Yep, that's the case. IMHO undefined behaviour so it is ok but coul=
d
> > be improved.
> >=20
> > This would be the patch, should improve your initial observation an=
d would
> > also "fix" the situation you noted above. Could you give it a test =
drive?
> >=20
> > diff --git a/net/ipv6/ndisc.c b/net/ipv6/ndisc.c
> > index 09a22f4..43c66f6 100644
> > --- a/net/ipv6/ndisc.c
> > +++ b/net/ipv6/ndisc.c
> > @@ -553,7 +553,17 @@ void ndisc_send_ns(struct net_device *dev, str=
uct neighbour *neigh,
> >  	struct nd_msg *msg;
> > =20
> >  	if (saddr =3D=3D NULL) {
> > -		if (ipv6_get_lladdr(dev, &addr_buf,
> > +		if (!ipv6_dev_get_saddr(dev_net(dev), dev, daddr,
> > +				       inet6_sk(dev_net(dev)->ipv6.ndisc_sk)->srcprefs,
> > +				       &addr_buf) &&
> > +		    ipv6_chk_addr(dev_net(dev), &addr_buf, dev, 1)) {
> > +			struct inet6_ifaddr *ifp =3D ipv6_get_ifaddr(dev_net(dev), &add=
r_buf, dev, 1);
> > +			if (ifp && !(ifp->flags & IFA_F_OPTIMISTIC))
> > +				saddr =3D &addr_buf;
> > +			in6_ifa_put(ifp);
> > +		}
> > +
> > +		if (!saddr && ipv6_get_lladdr(dev, &addr_buf,
> >  				   (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)))
> >  			return;
> >  		saddr =3D &addr_buf;
> >=20
> >=20
> > Thanks,
> >=20
> >   Hannes
> >=20
> >
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

--=20
gruss,

  Hannes
