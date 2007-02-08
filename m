From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Thu, 8 Feb 2007 08:07:15 -0500
Message-ID: <20070208130715.GA27267@hmsreliant.homelinux.net>
References: <20070206200915.GC10707@hmsreliant.homelinux.net> <45C8EF75.6070506@hp.com> <20070207205503.GB20804@hmsreliant.homelinux.net> <20070208.065206.107341055.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2344 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423000AbXBHNJB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 08:09:01 -0500
Content-Disposition: inline
In-Reply-To: <20070208.065206.107341055.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 08, 2007 at 06:52:06AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20070207205503.GB20804@hmsreliant.homelinux.net> (at Wed,=
 7 Feb 2007 15:55:03 -0500), Neil Horman <nhorman@tuxdriver.com> says:
>=20
> > diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> > index 7b7bd44..8a1ea96 100644
> > --- a/net/ipv6/ip6_output.c
> > +++ b/net/ipv6/ip6_output.c
> > @@ -859,6 +859,34 @@ static int ip6_dst_lookup_tail(struct sock *sk=
,
> >  		err =3D ipv6_get_saddr(*dst, &fl->fl6_dst, &fl->fl6_src);
> >  		if (err)
> >  			goto out_err_release;
> > +#ifdef CONFIG_IPV6_OPTIMISTIC_DAD
> > +		/*
> > +		 * Here if the dst entry we've looked up=20
> > +		 * has a neighbour entry that is in the INCOMPLETE
> > +		 * state and the src address from the flow is=20
> > +		 * marked as OPTIMISTIC, we release the found=20
> > +		 * dst entry and replace it instead with the=20
> > +		 * dst entry of the nexthop router
> > +		 */
> > +		if (!((*dst)->neighbour->nud_state & NUD_VALID)) {
> > +			struct inet6_ifaddr *ifp;
> > +			struct flowi fl_gw;
> > +			ifp =3D ipv6_get_ifaddr(&fl->fl6_src, (*dst)->dev, 1);
> > +
> > +			if (ifp && ifp->flags & IFA_F_OPTIMISTIC) {
> > +				/*
> > +				 * We need to get the dst entry for the=20
> > +				 * default router instead
> > +				 */
> > +				dst_release(*dst);
> > +				memcpy(&fl_gw, fl, sizeof(struct flowi));
> > +				memset(&fl_gw.fl6_dst, 0, sizeof(struct in6_addr));
> > +				*dst =3D ip6_route_output(sk, &fl_gw);
> > +				if ((err =3D (*dst)->error))
> > +					goto out_err_release;			=09
> > +			}
> > +		}
> > +#endif
> >  	}
> > =20
> >  	return 0;
>=20
> Sorry, this is still not correct if the source address is already
> specified.  I think they should be placed just betwee laste "}" and
> "return 0;", no?
>=20
I think moving it would be no more correct or incorrect, but it would b=
e less
efficient.  ipv6_addr_any will only return true if the source address i=
s the
anycast address (::).  That address will never be optimistic.  So we co=
uld
certainly move  the optimistic code to where you indicate, but then we'=
d be
checking the code for optimistic address without any need?  Or is there
something I'm missing?

>=20
> I still have a question.  Now, who will install the kernel route for
> the incoming packet?  Can we get packet for our unicast address durin=
g
> optimistic DAD period?
>=20
Not sure what you're getting at here.  RFC 4429 makes no distinction be=
tween
optimistic and non-optimistic packets for recevied frames, so routes fo=
r
received packets will be added by the same code that does it currently =
(which I
admittedly haven't looked into to closely).  Packets received for our u=
nicast
address (even if it is optimistic) are handled just as any other packet=
 is (same
as it is for TENTATIVE addresses, as I understand it).=20

Regards
Neil

> --yoshfuji
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
