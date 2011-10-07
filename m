From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] IPv6: DAD from bonding iface is treated as dup address
 from others
Date: Fri, 7 Oct 2011 07:10:28 -0400
Message-ID: <20111007111028.GA11408@hmsreliant.think-freely.org>
References: <1317873550-1677-1-git-send-email-Yinglin.Sun@emc.com>
 <20111006110047.GA22462@hmsreliant.think-freely.org>
 <27199.1317927933@death>
 <CAN17JHUo00BGbsQ0wDjhcY-wWRuGr-in-i_JBzE5__jgO5be=g@mail.gmail.com>
 <CAN17JHWgYyrz0WFmXiyR8Ep1W-zGjeQEKCADmX6zMT=ZfQ8n7Q@mail.gmail.com>
 <7122.1317949193@death>
 <CAN17JHUkeCarKf3U-0EMEyL+RJvZGV3GSQWG7+TZFy7ZvD8jYA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Yinglin Sun <yinglin.s@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49395 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759824Ab1JGLK7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2011 07:10:59 -0400
Content-Disposition: inline
In-Reply-To: <CAN17JHUkeCarKf3U-0EMEyL+RJvZGV3GSQWG7+TZFy7ZvD8jYA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 06, 2011 at 06:24:36PM -0700, Yinglin Sun wrote:
> On Thu, Oct 6, 2011 at 5:59 PM, Jay Vosburgh <fubar@us.ibm.com> wrote=
:
> > Yinglin Sun <Yinglin.Sun@emc.com> wrote:
> >
> >>On Thu, Oct 6, 2011 at 3:17 PM, Yinglin Sun <Yinglin.Sun@emc.com> w=
rote:
> >>>
> >>> On Thu, Oct 6, 2011 at 12:05 PM, Jay Vosburgh <fubar@us.ibm.com> =
wrote:
> >>> >
> >>> > Neil Horman <nhorman@tuxdriver.com> wrote:
> >>> >
> >>> > >On Wed, Oct 05, 2011 at 08:59:10PM -0700, Yinglin Sun wrote:
> >>> > >> Steps to reproduce this issue:
> >>> > >> 1. create bond0 over eth0 and eth1, set the mode to balance-=
xor
> >>> > >> 2. add an IPv6 address to bond0
> >>> > >> 3. DAD packet is sent out from one slave and then is looped =
back from
> >>> > >> the other slave. Therefore, it is treated as a duplicate add=
ress and
> >>> > >> stays tentative afterwards:
> >>> > >> =A0 =A0kern.info:
> >>> > >> =A0 =A0 =A0 =A0Oct =A05 11:50:18 testvm1 kernel: [ =A0129.22=
4353] bond0: IPv6 duplicate address 1234::1 detected!
> >
> > [...]
> >
> >>> > >Nack, This seems like it will just completely break DAD. =A0Wh=
at if theres another
> >>> > >system out there with the same mac address. =A0A response from=
 that system would
> >>> > >get dropped by this filter, instead of causing The local syste=
m to stop using
> >>> > >the address. =A0What you really want to do is modify
> >>> > >bond_should_deliver_exact_match to detect this frame on the in=
active slave or
> >>> > >some such, and drop the frame there.
> >>> >
> >>> > =A0 =A0 =A0 =A0Also NACK; and adding a bit of information. =A0T=
he balance-xor
> >>> > mode is nominally expecting to interact with a switch whose por=
ts are
> >>> > set for etherchannel ("static link aggregation"), in which case=
 the
> >>> > switch will not loop the packet back around.
> >>> >
> >>> > =A0 =A0 =A0 =A0If your switch can do etherchannel, then enable =
it and the
> >>> > problem should go away. =A0If your switch cannot do this, then =
you may
> >>> > have other issues, because all of the multicast or broadcast pa=
ckets
> >>> > going out any bonding slave will loop around to another slave. =
=A0You
> >>> > could also use 802.3ad / LACP if you switch supports that.
> >>> >
> >>> > =A0 =A0 =A0 =A0For balance-xor (or balance-rr, for that matter)=
 mode to a
> >>> > non-etherchannel switch, it's going to be difficult, if not imp=
ossible,
> >>> > to modify bond_should_deliver_exact_match, because there are no=
 inactive
> >>> > slaves. =A0In this mode, bonding is expecting the switch to bal=
ance
> >>> > incoming traffic across the ports, and not deliver looped back =
packets
> >>> > or duplicates. =A0There are no restrictions on what type of tra=
ffic
> >>> > (mcast, bcast, ucast) may arrive on any given port.
> >>> >
> >>> > =A0 =A0 =A0 =A0I can't think of a way to make the non-etherchan=
nel case work
> >>> > for balance-xor (or balance-rr) without breaking the DAD functi=
onality
> >>> > in the case of an actual duplicate. =A0I'm not aware of a way t=
o
> >>> > distinguish a looped back DAD probe from an actual duplicate ad=
dress
> >>> > probe elsewhere on the network.
> >>> >
> >>>
> >>> Hi Neil & Jay,
> >>>
> >>> Thanks a lot for the comments.
> >>>
> >>> The use case is to add IPv6 address on the bonding interface firs=
t,
> >>> and then set up port channel on switch. We'll hit this issue and =
the
> >>> new address will stay tentative and unusable after port channel i=
s set
> >>> up on switch. This patch is for this valid use case.
> >>>
> >>> Except failover mode, all slaves are active on receiving packets,=
 so
> >>> we are receiving such looped back DAD and the bonding driver cann=
ot
> >>> ignore them. I cannot think of a way to distinguish if a DAD is l=
ooped
> >>> back or from someone else having the same mac address. They look =
the
> >>> same to the host. If there is another machine having the same mac
> >>> address, this code path gets executed if both are doing DAD at th=
e
> >>> same time for the same IPv6 address. Maybe we should find out wha=
t the
> >>> specification defines for this case?
> >>>
> >>
> >>RFC4862 has a discussion about this issue:
> >>http://tools.ietf.org/html/rfc4862#appendix-A
> >>The better solution could be to record the number of DAD sent out. =
If
> >>we received more DAD packets than we sent out, there is someone els=
e
> >>on the network who has the same mac address and sent DAD for the sa=
me
> >>IPv6 address. However, this solution doesn't work with bonding
> >>interface, since all other active slaves but the one sending out DA=
D
> >>will receive packet looped back. It doesn't seem there is a simple
> >>solution for this issue.
> >
> > =A0 =A0 =A0 =A0Why are you setting up the port channel after config=
uring the
> > bond?
> >
> > =A0 =A0 =A0 =A0As a possible workaround, if you have control over t=
he setup
> > process (perhaps it's some sort of manual process), adding one slav=
e to
> > the bond, leaving the other soon-to-be slaves down, then setting up=
 the
> > switch, and finally adding the remaining slaves should work around =
the
> > issue, since if the bond has only one slave it won't see any looped
> > packets.
> >
> > =A0 =A0 =A0 =A0Or you could bring the bond up as active-backup, the=
n change the
> > mode to balance-xor once the switch is configured.
> >
> > =A0 =A0 =A0 =A0Ultimately, though, the problem stems from the setti=
ngs mismatch
> > between the switch and the bonding system; balance-xor is meant to
> > interoperate with etherchannel, and when the switch is not configur=
ed
> > properly, correct behavior is difficult to guarantee.
> >
>=20
> Jay,
>=20
> Thanks a lot for the suggestion.
>=20
> It's mainly about usability. We would like to provide customers with
> consistent IPv6 configuration procedures as IPv4.  Such workarounds
> could be confusing and generate customer calls.
>=20
Its not a workaround, its the way it has to be done.  You can't just dr=
op dad
packets because you can't tell the difference between those that are lo=
oped back
and those that are legitimaely from other hosts, so you need to do some=
thing
like what Jay is suggesting.

> Yinglin
>=20
