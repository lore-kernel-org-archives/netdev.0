From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC PATCH] sctp: Don't lookup dst if transport dst is still
 valid
Date: Fri, 12 Jul 2013 07:19:09 -0400
Message-ID: <20130712111909.GA5854@hmsreliant.think-freely.org>
References: <1372747174-23580-1-git-send-email-fan.du@windriver.com>
 <51D2E3C8.5050100@gmail.com>
 <51D389F9.4030804@windriver.com>
 <51D425B7.20204@gmail.com>
 <51D4DEFF.8030305@windriver.com>
 <51D6D3A0.7050106@gmail.com>
 <51DC282C.9090007@gmail.com>
 <51DCF09B.106@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vlad Yasevich <vyasevich@gmail.com>, nicolas.dichtel@6wind.com,
	davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50357 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932637Ab3GLLT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jul 2013 07:19:27 -0400
Content-Disposition: inline
In-Reply-To: <51DCF09B.106@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 10, 2013 at 01:26:51PM +0800, Fan Du wrote:
>=20
>=20
> On 2013=E5=B9=B407=E6=9C=8809=E6=97=A5 23:11, Vlad Yasevich wrote:
> >On 07/05/2013 10:09 AM, Vlad Yasevich wrote:
> >>On 07/03/2013 10:33 PM, Fan Du wrote:
> >>>
> >>>
> >>>On 2013=E5=B9=B407=E6=9C=8803=E6=97=A5 21:23, Vlad Yasevich wrote:
> >>>>On 07/02/2013 10:18 PM, Fan Du wrote:
> >>>>>
> >>>>>
> >>>>>On 2013=E5=B9=B407=E6=9C=8802=E6=97=A5 22:29, Vlad Yasevich wrot=
e:
> >>>>>>On 07/02/2013 02:39 AM, Fan Du wrote:
> >>>>>>>When sctp sits on IPv6, sctp_transport_dst_check pass cookie a=
s ZERO,
> >>>>>>>as a result ip6_dst_check always fail out. This behaviour make=
s
> >>>>>>>transport->dst useless, because every sctp_packet_transmit mus=
t look
> >>>>>>>for valid dst(Is this what supposed to be?)
> >>>>>>>
> >>>>>>>One aggressive way is to call rt_genid_bump which invalid all =
dst to
> >>>>>>>make new dst for transport, apparently it also hurts others.
> >>>>>>>I'm sure this may not be the best for all, so any commnets?
> >>>>>>>
> >>>>>>>Signed-off-by: Fan Du <fan.du@windriver.com>
> >>>>>>>---
> >>>>>>>include/net/sctp/sctp.h | 18 ++++++++++++------
> >>>>>>>net/sctp/ipv6.c | 2 ++
> >>>>>>>2 files changed, 14 insertions(+), 6 deletions(-)
> >>>>>>>
> >>>>>>>diff --git a/include/net/sctp/sctp.h b/include/net/sctp/sctp.h
> >>>>>>>index cd89510..f05af01 100644
> >>>>>>>--- a/include/net/sctp/sctp.h
> >>>>>>>+++ b/include/net/sctp/sctp.h
> >>>>>>>@@ -719,14 +719,20 @@ static inline void sctp_v4_map_v6(union
> >>>>>>>sctp_addr *addr)
> >>>>>>>addr->v6.sin6_addr.s6_addr32[2] =3D htonl(0x0000ffff);
> >>>>>>>}
> >>>>>>>
> >>>>>>>-/* The cookie is always 0 since this is how it's used in the
> >>>>>>>- * pmtu code.
> >>>>>>>- */
> >>>>>>>+/* Set cookie with the right one for IPv6 and zero for others=
 */
> >>>>>>>static inline struct dst_entry *sctp_transport_dst_check(struc=
t
> >>>>>>>sctp_transport *t)
> >>>>>>>{
> >>>>>>>- if (t->dst && !dst_check(t->dst, 0)) {
> >>>>>>>- dst_release(t->dst);
> >>>>>>>- t->dst =3D NULL;
> >>>>>>>+
> >>>>>>>+ if (t->dst) {
> >>>>>>>+ struct rt6_info *rt =3D (struct rt6_info *)t->dst;
> >>>>>>>+ u32 cookie =3D 0;
> >>>>>>>+
> >>>>>>>+ if ((t->af_specific->sa_family =3D=3D AF_INET6) && rt->rt6i_=
node)
> >>>>>>>+ cookie =3D rt->rt6i_node->fn_sernum;
> >>>>>>>+ if (!dst_check(t->dst, cookie)) {
> >>>>>>>+ dst_release(t->dst);
> >>>>>>>+ t->dst =3D NULL;
> >>>>>>>+ }
> >>>>>>>}
> >>>>>>
> >>>>>>I think it would be better if we stored the dst_cookie in the
> >>>>>>transport structure and initialized it at lookup time. If you d=
o that,
> >>>>>>then if the route table changes, we'd correctly detect it witho=
ut
> >>>>>>artificially bumping rt_genid (and hurting ipv4).
> >>>>>
> >>>>>Hi Vlad/Neil
> >>>>>
> >>>>>Is this what you mean?
> >>>>
> >>>>Yes, exactly.
> >>>>
> >>>
> >>>Hi Vlad
> >>>
> >>>I thinks twice about below patch, this is actually a chicken-egg i=
ssue.
> >>>Look below scenario:
> >>>(1) The first time we push packet through a transport, dst_cookie =
is 0,
> >>>so sctp_transport_dst_check also pass cookie as 0, then return dst
> >>>as NULL.
> >>>Then we lookup dst by sctp_transport_route, and in there we
> >>>initiate dst_cookie
> >>>with rt->rt6i_node->fn_sernum
> >>>
> >>>(2) Then the next time we push packet through this transport again=
,
> >>>we pass dst_cookie(rt->rt6i_node->fn_sernum) to ip6_dst_check, and
> >>>return valid dst without bothering to lookup dst again.
> >>
> >>No, if the route was removed rt6i_node will be NULL, and NULL will =
be
> >>returned from ip6_dst_check(). If the route still exists then we'll
> >>compare the serial number with a cookie.
> >>
> >>>
> >>>BUT, suppose when deleting the source address of this dst after
> >>>transport->dst_cookie
> >>>has been well initialized. transport->dst_cookie still holds
> >>>rt->rt6i_node->fn_sernum,
> >>>meaning ip6_dst_check will return valid dst, which it shouldn't in=
 this
> >>>case, the
> >>>result will be association ABORT.
> >>
> >>No, removing the address cause the route for that prefix to be remo=
ved
> >>as well. This will set rt6i_node to NULL.
> >>
> >>>
> >>>Other way is invalid all transport->dst which using the deleting a=
ddress
> >>>as source address
> >>>without bumping gen_id, problem is the traverse times depends heav=
ily on
> >>>transport number,
> >>>and also need to take account locking issue it will introduce.
> >>>
> >>>>
> >>>> No, you are not missing anything. IPv4 doesn't use the cookie an=
d
> >>>always seems to pass it as 0.
> >>>>
> >>>> Yes, ipv4 will bump the gen_id thus invalidating all routes (the=
re
> >>>has been disagreement about it).
> >>>> IPv6 doesn't do that. In ipv6, when the addresses are added or
> >>>removed, routes are also added or removed and
> >>>> any time the route is added it will have a new serial number. So=
, you
> >>>don't have to disturb ipv4 cache when ipv6 routing info changes.
> >>>
> >>>Thank you very much for your explanation!
> >>>
> >>>IPv6 don't bump gen_id, when adding/deleting address, and tag an s=
erial
> >>>number with each route.
> >>>Doing this way loose the semantic of dst_check, because SCTP depen=
ds no
> >>>dst_check fulfill its
> >>>duty to actually check whether the holding dst is still valid, wel=
l most
> >>>other Layer 4 protocol
> >>>simply rely on ip6_route_output/ip6_dst_lookup_flow to grab dst ev=
ery
> >>>time sending data out.
> >>
> >>Look at how other protocols (tcp, dccp) do this. It is sufficient t=
o
> >>cache the route serial number into the dst_cookie at the time the r=
oute
> >>was lookup-up and cached. Then the cookie is passed to dst_check to
> >>validate the route.
> >
> >
> >Hi Fan
> >
> >Have you tried the updated patch you sent? Based on what the tcp/udp=
 code is doing, the updated patch should work correctly. If it does, ca=
n you re-post with attribution/sign-off
> >
>=20
> Hello Vlad and Neil
>=20
> I don't know whether my test procedure has drawbacks or something els=
e.
> It seems the updated patch does not works well, but my first patch is=
 ok under below configuration.
>=20
> Host A:
> 	ifconfig eth1 inet6 add 2001::803/64
> 	ifconfig eth1 inet6 add 2001::804/64
> 	sctp_darn -H 2001::803 -B 2001::804 -P 5001 -l
>=20
> Host B:
> 	ifconfig eth1 inet6 add 2001::805/64
> 	ifconfig eth1 inet6 add 2001::806/64
>         sctp_darn -H 2001::805 -B 2001::806 -P 5002 -h 2001::803 -p 5=
001 -s
>=20
> hbinterval set to 2 seconds, after setup the association, primary add=
ress: 2001::804 <--> 2001::806
>=20
>=20
> Step 1:
>=20
> After adding in IPv6 address to an interface, we populate
> struct inet6_ifaddr *ifp->rt->rt6i_node, this rt6i_node is stored in =
a radix tree.
>=20
> addrconf_add_ifaddr
>  ->inet6_addr_add
>     ->ipv6_add_addr  <-- Do DAD checking afterward.
>     ->addrconf_prefix_route
>       ->ip6_route_add
>         ->__ip6_ins_rt
>           ->fib6_add
>             ->fib6_add_1  <-- Create struct fib6_node *fn
>               ->fib6_add_rt2node
>                 ->rt->rt6i_node =3D fn; (*1*)
>=20
> Step 2:
>=20
> In host A ,for the packet destinate for 2001::806 using source addres=
s 2001::804,
> In sctp_v6_get_dst, let's print the rt, rt->rt6i_node, and rt->rt6i_n=
ode->fn_sernum
> after ip6_dst_lookup_flow got valid dst. The problem is the transport=
->dst->rt6i_node
> we have looked for is *not* the rt6i_node in (*1*), I'm not drunk her=
e.....
> So in Step 3, let's be naughty: ifconfig eth1 inet6 del 2001::804/64
>=20
Wait, don't just skip past here.  As far as I know the dst_entry that g=
ets
cached in transport->dst really needs to point at the same rt6_info and
rt6i_node as the one created in step 1.  If it doesn't then that second=
 check in
ip6_dst_check is pointless and will never work.  This really needs to b=
e the
question here.  What is the result of your call to sctp_transport_route
returning if not the route matching the one added for the source interf=
ace?
