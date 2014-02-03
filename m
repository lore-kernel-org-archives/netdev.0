From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: default route for link local address is not added while assigning a address
Date: Mon, 3 Feb 2014 17:08:38 +0100
Message-ID: <20140203160838.GA17999@order.stressinduktion.org>
References: <52E8A2AA.3090507@linux.vnet.ibm.com> <52E8DA37.7010208@6wind.com> <20140130232909.GH25336@order.stressinduktion.org> <52EF42FF.60907@linux.vnet.ibm.com> <52EFB454.1040908@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sohny Thomas <sthomas@linux.vnet.ibm.com>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	yoshfuji@linux-ipv6.org, davem@davemloft.net,
	kumuda <kumuda@linux.vnet.ibm.com>
To: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <52EFB454.1040908@6wind.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On Mon, Feb 03, 2014 at 04:23:00PM +0100, Nicolas Dichtel wrote:
> Le 03/02/2014 08:19, Sohny Thomas a =C3=A9crit :
> >
> >>Actually I am not so sure, there is no defined semantic of flush. I=
 would
> >>be ok with all three solutions: leave it as is, always add link-loc=
al
> >>address (it does not matter if we don't have a link-local address o=
n
> It matters. This address is required.
> RFC 4291
> Section 2.1:
>    All interfaces are required to have at least one Link-Local unicas=
t
>    address (see Section 2.8 for additional required addresses).
> Section 2.8:
>       o Its required Link-Local address for each interface.

Yes, sure, it is required. But you also can manually delete the LL addr=
ess and
we don't guard against that.

> >>that interface, as a global scoped one is just fine enough) or make=
 flush=20
> >>not
> >>remove the link-local address (but this seems a bit too special cas=
ed for=20
> >>me).
> >
> >1) In case if we leave it as it is, there is rfc 6724 rule 2 to be=20
> >considered (
> >previously rfc 3484)
> >
> >Rule 2: Prefer appropriate scope.
> >    If Scope(SA) < Scope(SB): If Scope(SA) < Scope(D), then prefer S=
B and
> >    otherwise prefer SA.  Similarly, if Scope(SB) < Scope(SA): If
> >    Scope(SB) < Scope(D), then prefer SA and otherwise prefer SB.
> >
> >Test:
> >
> >    Destination: fe80::2(LS)
> >     Candidate Source Addresses: 3ffe::1(GS) or fec0::1(SS) or LLA(L=
S)
> >     Result: LLA(LS)
> >     Scope(LLA) < Scope(fec0::1): If Scope(LLA) < Scope(fe80::2),  n=
o,=20
> >     prefer LLA
> >     Scope(LLA) < Scope(3ffe::1): If Scope(LLA) < Scope(fe80::2),  n=
o,=20
> >     prefer LLA
> >
> >
> >Now the above test fails since the route itself is not present, and =
the=20
> >test
> >assumes that the route gets added since the LLA is not removed durin=
g the=20
> >test
> In your scenario, the link local route has been removed manually, not=
 by the
> kernel. What is your network manager?

The test scenario is outlined here:
<https://bugzilla.kernel.org/show_bug.cgi?id=3D68511>

Basically, the command in question is this one:

	[root@localhost ~]# ip -6 -statistics -statistics route flush dev eth0

which removes the fe80::/64 route.

> >2) having a LLA always helps in NDP i think
> A link-local Address yes, it's a MUST. But having only the link local=
 route=20
> will
> not help.

Agreed, the LL address should be available, too. I currently don't know
what will break if LL address is not available. I guess MLD won't work
properly and thus even basic connectivity won't work with some switches=
=2E

> >3) making flush not remove link-local address will be chnaging=20
> >functionality of
> >ip flush command
> You can flush by specifying the prototype:
> ip -6 route flush proto static

So we have four possiblities now:

1) leave it as is

	seems still acceptable to me

2) add fe80::/64 route unconditionally if any address gets added

	Sohny's patch already looks good in doing so at first look.

3) add fe80::/64 route in case LL address gets added via inet6_rtm_newa=
ddr

	would be ok, too. I tend towards this solution somehow by now.

4) make flush not remove the fe80::/64 address

	Least favourable to me. I guess this also woud need iproute change
	and seems most difficult to do.

Any opionions?

Greetings,

  Hannes
