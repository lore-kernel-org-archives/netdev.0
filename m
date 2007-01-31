From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: Implement RFC 4429 Optimistic Duplicate Address Detection
Date: Wed, 31 Jan 2007 15:54:43 -0500
Message-ID: <20070131205443.GA12237@hmsreliant.homelinux.net>
References: <20070129213013.GA26841@hmsreliant.homelinux.net> <20070130.072536.129403235.yoshfuji@linux-ipv6.org> <20070130130208.GA3723@hmsreliant.homelinux.net> <20070131.011629.84005028.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: vladislav.yasevich@hp.com, sri@us.ibm.com, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	kaber@coreworks.de, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3464 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030576AbXAaVAy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jan 2007 16:00:54 -0500
Content-Disposition: inline
In-Reply-To: <20070131.011629.84005028.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jan 31, 2007 at 01:16:29AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20070130130208.GA3723@hmsreliant.homelinux.net> (at Tue, =
30 Jan 2007 08:02:08 -0500), Neil Horman <nhorman@tuxdriver.com> says:
>=20
> > > I do not think we should copy neighbor information from (one of)
> > > default routers, but use temporary neigh entry (or neigh in new s=
tate)
> > > for such datagrams in stead.  We should aware that:
> > >=20
> > Not sure how that is different from what I'm proposing.  a neighbor=
 entry that
> > maps a given host on the current subnet to the MAC of the default r=
outer, that
> > then gets flushed when DAD completes is temporary, as far as I can =
see.
> >=20
> > >  1) default router's link-layer address may change.
> > True, but if this changes, all our network connectivity is lost, un=
til the
> > normal neighbor solicitation process completes anyway.
>=20
> No, router may update its link-layer address by NA with Override flag=
 set.
> In that case, we must use new link-layer for subsequent packets from
> our opportunistic address duing DAD.
>=20
> > >  2) we may have more than one default routers.
> > True, but I would think we could select any of them and this would =
work.
> > Granted, we wouldn't use all the default routers in the table as we=
 would with
> > routed frames, but I'm not sure how we avoid that.
>=20
> I mean, if the status of the selected default router has changed or=20
> has been deleted, we should try other router, at least.
>=20
> > >  3) the default router's link-layer may be invalidated.
> > >=20
> > yes, but this would be bad for the same reason as (1)
>=20
> We MUST take this into account.
>=20

Ok, understood.  In summary, we can't simply fill out the neighbor entr=
y for a
given host with the address of a default router because

1) Any changes to the router link layer address wont be reflected in th=
at when
it (the change) happens, redering the local address unable to communica=
te until
the neighbour entries age out.

2) There may be more than one default router as selected by the routing=
 policy,
and we should be able to try those routes if the selected router become=
s
unavailable


It sounds like what we need to do is shim into the route lookup code, a=
nd detect
there if we need to redirect every packet as they are sent.  I think I =
may have
an idea for this.  What if we implement the lookup in ip6_dst_lookup_ta=
il.  In
there we can check if the associated neigh entry for the resolved dst_e=
ntry is
in a INCOMPLETE or FAILED state, and if the ifaddr associated withe the=
 source
address passed in via the flowi struct is in an OPTIMISTIC state.  If b=
oth
conditions are true, we release the dst_entry that we origionally looke=
d up, and
instead conduct a second lookup with a newly constructed flowi struct w=
ith the
dst addr replaced with an all zeros address (which I think should retur=
n a
gateway, selected as per routing policy).  Then we can return that dst =
entry
instead.  Since ip6_push_pending frames seems to bulid the ipv6 header =
using the
addresses in the flowi struct passed into ip6_*_dst_lookup from *_sendm=
sg
routines, and the link layer header is built based on the info gathered=
 from the
resolved dst_entry (If I'm reading the code right), I think this give u=
s what we
want, in that we redirect to a gatweway when we send from an optimistic=
 address,
and we select the gateway based on the logic in the route lookup code
(ip6_route_output() specifically).  I'm trying to implement this right =
now, and
will post a new patch as soon as I have it done.  In the meantime, any =
thoughts
would be most appreciated.

Regards
Neil

> --yoshfuji
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
