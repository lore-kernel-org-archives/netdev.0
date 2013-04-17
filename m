From: Wilco Baan Hofman <wilco@baanhofman.nl>
Subject: Re: ECMP ipv6 vs ipv4
Date: Wed, 17 Apr 2013 17:22:35 +0200
Message-ID: <1366212155.31353.111.camel@localhost>
References: <1366012728.4975.13.camel@localhost>
	   <516C2212.4030502@6wind.com> <1366044816.4975.27.camel@localhost>
	  <516E6559.4070903@6wind.com> <1366204578.31353.88.camel@localhost>
	 <516EAE3A.8000201@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 37-251-2-65.FTTH.ispfabriek.nl ([37.251.2.65]:37217 "EHLO
	mail.baanhofman.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752415Ab3DQPWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Apr 2013 11:22:49 -0400
In-Reply-To: <516EAE3A.8000201@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-04-17 at 16:14 +0200, Nicolas Dichtel wrote:
> Le 17/04/2013 15:16, Wilco Baan Hofman a =C3=A9crit :
> > On Wed, 2013-04-17 at 11:03 +0200, Nicolas Dichtel wrote:
> >
> >>>>>
> >>>>> I propose that we have a nexthop structure to an exclusive rout=
e,
> >>>>> similar what we have for IPv4, where we store the gateway, devi=
ce and
> >>>>> weight for all nexthops and the algorithm in the route. This wo=
uld make
> >>>>> the netlink API symmetrical again and fixes the n*n inefficienc=
ies when
> >>>>> adding routes (all siblings need to know about all siblings).
> >>>>>
> >>>>> What are your thoughts on this?
> >> The pro of the current implementation is that you can add or delet=
e a nexthop
> >> withtout removing the whole route. You don't need to list again al=
l nexthops
> >> each time you want to modify one.
> >
> > That would also be possible using ip -6 route change, it'll be more
> > efficient for insertions and more consistent with the IPv4
> > implementation. Remember that most code is in fact shared between I=
Pv4
> > and IPv6 implementations for routing protocol suites.
> >
> > For bird it would be much more convenient to have the same API work=
 for
> > both as the code is shared (with minor differences).
> >
> > The memory structure like below would make sense and you can expand=
 it
> > as well:
> >
> > struct ip6_nexthop {
> > 	int               flags; /* algorithm per packet or hash, etc */
> > 	struct list_head  *hops; /* nh_via */
> > };
> > struct ip6_nh {
> > 	int              ifindex;
> > 	struct in6_addr  rt6i_gateway;
> > 	char             weight;
> > 	int              flags; /* pervasive, onlink */
> > };
> >
> > I'm not sure how to make this map correctly to the append API.. I t=
hink
> > we need to make sure that all APIs either are consistent and symmet=
rical
> > or don't work from day 1.
> Maybe the error was to propose two API to insert ECMPv6 routes, but a=
s soon as=20
> there is two API, one will not be symetric with what is returned by t=
he kernel ;-)

Yeah, I'm not a fan, especially when it doesn't map 1:1 with what's
going on.


> >
> > I am willing to implement this, including algorithm support using t=
he
> > netlink nexthop API, like the IPv4 implementation.. or change the I=
Pv4
> > implementation, but either way I feel they need to be consistent.
> I'm not sure that this is a major argument. There is already differen=
ces between=20
> IPv4 and IPv6 (for example, IPv4 addresses are kept when an interface=
 is down,=20
> not IPv6 addresses, netlink messages are sent when routes are removed=
 after=20
> putting down an interface in IPv6 but not in IPv4). But I let other s=
peak about=20
> this.

I would prefer to have fewer differences between IPv4 and IPv6 handling
instead of more, unless the RFCs demand different behaviour.

> What is important is to avoid breaking existing API.
>=20

I sort of agree, but quagga support is on hold until this is resolved,
and bird does not support it properly until we resolve this. The latter
I intend to fix myself and I am in contact with Quagga developers.
Static via iproute is a slightly different story though.


If no-one else comments, I'll start on writing a patch to support the
netlink nexthop API with weights and per-packet and weighted hash
algorithms on an exclusive route. I'll also see if I can support ip
route append if nexthop is specified to add a nexthop to the list, but
this shall be a different patch and it may not map well.

I would like to hear some more thoughts on this though.


Wilco Baan Hofman
