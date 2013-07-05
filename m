From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH] sctp: Don't lookup dst if transport dst is still
 valid
Date: Fri, 5 Jul 2013 09:03:53 -0400
Message-ID: <20130705130353.GA15691@hmsreliant.think-freely.org>
References: <1372747174-23580-1-git-send-email-fan.du@windriver.com>
 <51D2E3C8.5050100@gmail.com>
 <51D389F9.4030804@windriver.com>
 <51D425B7.20204@gmail.com>
 <51D4DEFF.8030305@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Yasevich <vyasevich@gmail.com>, nicolas.dichtel@6wind.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:35293 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757352Ab3GENEJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jul 2013 09:04:09 -0400
Content-Disposition: inline
In-Reply-To: <51D4DEFF.8030305@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 04, 2013 at 10:33:35AM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B407=E6=9C=8803=E6=97=A5 21:23, Vlad Yasevich wrote:
> >On 07/02/2013 10:18 PM, Fan Du wrote:
> >>
> >>
> >>On 2013=E5=B9=B407=E6=9C=8802=E6=97=A5 22:29, Vlad Yasevich wrote:
> >>>On 07/02/2013 02:39 AM, Fan Du wrote:
> >>>>When sctp sits on IPv6, sctp_transport_dst_check pass cookie as Z=
ERO,
> >>>>as a result ip6_dst_check always fail out. This behaviour makes
> >>>>transport->dst useless, because every sctp_packet_transmit must l=
ook
> >>>>for valid dst(Is this what supposed to be?)
> >>>>
> >>>>One aggressive way is to call rt_genid_bump which invalid all dst=
 to
> >>>>make new dst for transport, apparently it also hurts others.
> >>>>I'm sure this may not be the best for all, so any commnets?
> >>>>
> >>>>Signed-off-by: Fan Du <fan.du@windriver.com>
> >>>>---
> >>>>include/net/sctp/sctp.h | 18 ++++++++++++------
> >>>>net/sctp/ipv6.c | 2 ++
> >>>>2 files changed, 14 insertions(+), 6 deletions(-)
> >>>>
> >>>>diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> >>>>index cd89510..f05af01 100644
> >>>>--- a/include/net/sctp/sctp.h
> >>>>+++ b/include/net/sctp/sctp.h
> >>>>@@ -719,14 +719,20 @@ static inline void sctp_v4_map_v6(union
> >>>>sctp_addr *addr)
> >>>>addr->v6.sin6_addr.s6_addr32[2] =3D htonl(0x0000ffff);
> >>>>}
> >>>>
> >>>>-/* The cookie is always 0 since this is how it's used in the
> >>>>- * pmtu code.
> >>>>- */
> >>>>+/* Set cookie with the right one for IPv6 and zero for others */
> >>>>static inline struct dst_entry *sctp_transport_dst_check(struct
> >>>>sctp_transport *t)
> >>>>{
> >>>>- if (t->dst && !dst_check(t->dst, 0)) {
> >>>>- dst_release(t->dst);
> >>>>- t->dst =3D NULL;
> >>>>+
> >>>>+ if (t->dst) {
> >>>>+ struct rt6_info *rt =3D (struct rt6_info *)t->dst;
> >>>>+ u32 cookie =3D 0;
> >>>>+
> >>>>+ if ((t->af_specific->sa_family =3D=3D AF_INET6) && rt->rt6i_nod=
e)
> >>>>+ cookie =3D rt->rt6i_node->fn_sernum;
> >>>>+ if (!dst_check(t->dst, cookie)) {
> >>>>+ dst_release(t->dst);
> >>>>+ t->dst =3D NULL;
> >>>>+ }
> >>>>}
> >>>
> >>>I think it would be better if we stored the dst_cookie in the
> >>>transport structure and initialized it at lookup time. If you do t=
hat,
> >>>then if the route table changes, we'd correctly detect it without
> >>>artificially bumping rt_genid (and hurting ipv4).
> >>
> >>Hi Vlad/Neil
> >>
> >>Is this what you mean?
> >
> >Yes, exactly.
> >
>=20
> Hi Vlad
>=20
> I thinks twice about below patch, this is actually a chicken-egg issu=
e.
> Look below scenario:
>  (1) The first time we push packet through a transport, dst_cookie is=
 0,
>      so sctp_transport_dst_check also pass cookie as 0, then return d=
st as NULL.
>      Then we lookup dst by sctp_transport_route, and in there we init=
iate dst_cookie
>      with rt->rt6i_node->fn_sernum
>=20
>  (2) Then the next time we push packet through this transport again,
>      we pass dst_cookie(rt->rt6i_node->fn_sernum) to ip6_dst_check, a=
nd
>      return valid dst without bothering to lookup dst again.
>=20
> BUT, suppose when deleting the source address of this dst after trans=
port->dst_cookie
> has been well initialized. transport->dst_cookie still holds rt->rt6i=
_node->fn_sernum,
> meaning ip6_dst_check will return valid dst, which it shouldn't in th=
is case, the
> result will be association ABORT.
>=20
Have you tried this?  It seems to me in the situation you describe, del=
eting a
source address will result in fib_inetaddr_event getting called, which =
will call
rt_cache_flush, bumping the rt_genid to get bumped for that network nam=
espace.
That will cause any subsequent calls to dst_check->ip6_dst_check to ret=
urn NULL
rather than the cached dst_entry for that transport.

Neil
