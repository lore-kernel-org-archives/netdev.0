From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH] sctp: Don't lookup dst if transport dst is still
 valid
Date: Tue, 9 Jul 2013 07:38:15 -0400
Message-ID: <20130709113815.GA955@hmsreliant.think-freely.org>
References: <1372747174-23580-1-git-send-email-fan.du@windriver.com>
 <51D2E3C8.5050100@gmail.com>
 <51D389F9.4030804@windriver.com>
 <51D425B7.20204@gmail.com>
 <51D4DEFF.8030305@windriver.com>
 <20130705130353.GA15691@hmsreliant.think-freely.org>
 <51DBB7BB.6020606@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Yasevich <vyasevich@gmail.com>, nicolas.dichtel@6wind.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:37407 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752923Ab3GILie (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jul 2013 07:38:34 -0400
Content-Disposition: inline
In-Reply-To: <51DBB7BB.6020606@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 09, 2013 at 03:11:55PM +0800, Fan Du wrote:
> Hello Neil
>=20
> On 2013=E5=B9=B407=E6=9C=8805=E6=97=A5 21:03, Neil Horman wrote:
> >On Thu, Jul 04, 2013 at 10:33:35AM +0800, Fan Du wrote:
> >>
> >>
> >>On 2013=E5=B9=B407=E6=9C=8803=E6=97=A5 21:23, Vlad Yasevich wrote:
> >>>On 07/02/2013 10:18 PM, Fan Du wrote:
> >>>>
> >>>>
> >>>>On 2013=E5=B9=B407=E6=9C=8802=E6=97=A5 22:29, Vlad Yasevich wrote=
:
> >>>>>On 07/02/2013 02:39 AM, Fan Du wrote:
> >>>>>>When sctp sits on IPv6, sctp_transport_dst_check pass cookie as=
 ZERO,
> >>>>>>as a result ip6_dst_check always fail out. This behaviour makes
> >>>>>>transport->dst useless, because every sctp_packet_transmit must=
 look
> >>>>>>for valid dst(Is this what supposed to be?)
> >>>>>>
> >>>>>>One aggressive way is to call rt_genid_bump which invalid all d=
st to
> >>>>>>make new dst for transport, apparently it also hurts others.
> >>>>>>I'm sure this may not be the best for all, so any commnets?
> >>>>>>
> >>>>>>Signed-off-by: Fan Du<fan.du@windriver.com>
> >>>>>>---
> >>>>>>include/net/sctp/sctp.h | 18 ++++++++++++------
> >>>>>>net/sctp/ipv6.c | 2 ++
> >>>>>>2 files changed, 14 insertions(+), 6 deletions(-)
> >>>>>>
> >>>>>>diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> >>>>>>index cd89510..f05af01 100644
> >>>>>>--- a/include/net/sctp/sctp.h
> >>>>>>+++ b/include/net/sctp/sctp.h
> >>>>>>@@ -719,14 +719,20 @@ static inline void sctp_v4_map_v6(union
> >>>>>>sctp_addr *addr)
> >>>>>>addr->v6.sin6_addr.s6_addr32[2] =3D htonl(0x0000ffff);
> >>>>>>}
> >>>>>>
> >>>>>>-/* The cookie is always 0 since this is how it's used in the
> >>>>>>- * pmtu code.
> >>>>>>- */
> >>>>>>+/* Set cookie with the right one for IPv6 and zero for others =
*/
> >>>>>>static inline struct dst_entry *sctp_transport_dst_check(struct
> >>>>>>sctp_transport *t)
> >>>>>>{
> >>>>>>- if (t->dst&&  !dst_check(t->dst, 0)) {
> >>>>>>- dst_release(t->dst);
> >>>>>>- t->dst =3D NULL;
> >>>>>>+
> >>>>>>+ if (t->dst) {
> >>>>>>+ struct rt6_info *rt =3D (struct rt6_info *)t->dst;
> >>>>>>+ u32 cookie =3D 0;
> >>>>>>+
> >>>>>>+ if ((t->af_specific->sa_family =3D=3D AF_INET6)&&  rt->rt6i_n=
ode)
> >>>>>>+ cookie =3D rt->rt6i_node->fn_sernum;
> >>>>>>+ if (!dst_check(t->dst, cookie)) {
> >>>>>>+ dst_release(t->dst);
> >>>>>>+ t->dst =3D NULL;
> >>>>>>+ }
> >>>>>>}
> >>>>>
> >>>>>I think it would be better if we stored the dst_cookie in the
> >>>>>transport structure and initialized it at lookup time. If you do=
 that,
> >>>>>then if the route table changes, we'd correctly detect it withou=
t
> >>>>>artificially bumping rt_genid (and hurting ipv4).
> >>>>
> >>>>Hi Vlad/Neil
> >>>>
> >>>>Is this what you mean?
> >>>
> >>>Yes, exactly.
> >>>
> >>
> >>Hi Vlad
> >>
> >>I thinks twice about below patch, this is actually a chicken-egg is=
sue.
> >>Look below scenario:
> >>  (1) The first time we push packet through a transport, dst_cookie=
 is 0,
> >>      so sctp_transport_dst_check also pass cookie as 0, then retur=
n dst as NULL.
> >>      Then we lookup dst by sctp_transport_route, and in there we i=
nitiate dst_cookie
> >>      with rt->rt6i_node->fn_sernum
> >>
> >>  (2) Then the next time we push packet through this transport agai=
n,
> >>      we pass dst_cookie(rt->rt6i_node->fn_sernum) to ip6_dst_check=
, and
> >>      return valid dst without bothering to lookup dst again.
> >>
> >>BUT, suppose when deleting the source address of this dst after tra=
nsport->dst_cookie
> >>has been well initialized. transport->dst_cookie still holds rt->rt=
6i_node->fn_sernum,
> >>meaning ip6_dst_check will return valid dst, which it shouldn't in =
this case, the
> >>result will be association ABORT.
> >>
> >Have you tried this?  It seems to me in the situation you describe, =
deleting a
> >source address will result in fib_inetaddr_event getting called, whi=
ch will call
>                                  ^^^^^^^^^^
>                                  This is IPv4 specific.
>=20
Sorry, meant to be looking at fib6_run_gc here, as called from
ndisc_event_netdev.  That should age all the ipv6 router entries approp=
riately.


> >rt_cache_flush, bumping the rt_genid to get bumped for that network =
namespace.
> >That will cause any subsequent calls to dst_check->ip6_dst_check to =
return NULL
>                                            ^^^^^^^^^^^^^^^^^
>                                            This is IPv6 specific
> >rather than the cached dst_entry for that transport.
>=20
> The phenomenon(transport->dst got lookup every time for IPv6) I descr=
ibed before
> could be easily observed by turning on SCTP debug.
>=20
I'm not talking about the origional behavior, I'm talking about the con=
cern you
have above with your patch.  Nothing messes with sernum or genid in the=
 ipv6
garbage collector, but cached routes, when expunged by fib6_del_route, =
will set
rt6i_node to NULL, which should cause both if clauses in ip6_dst_chk to=
 be
skipped, returning NULL, forcing a new lookup.

Neil

> >Neil
> >
> >
>=20
> --=20
> =E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=
=9D=E7=AC=91
>=20
> --fan
>=20
