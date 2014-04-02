From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 2 Apr 2014 15:29:15 -0400
Message-ID: <20140402192915.GB3301@tuxdriver.com>
References: <5332677F.2090404@cumulusnetworks.com>
 <5332B1FE.7080102@mojatatu.com>
 <53330639.8050403@cumulusnetworks.com>
 <20140326165934.GH2869@minipsycho.orion>
 <533312A3.5070600@cumulusnetworks.com>
 <20140326180356.GK2869@minipsycho.orion>
 <2D65D0C2-6BBC-4968-8400-4EB60BDF887A@cumulusnetworks.com>
 <533C1F91.6000704@greyhouse.net>
 <20140402152546.GB3596@tuxdriver.com>
 <CD1A9D96-F1E1-4AF6-B089-41AEBF7F1699@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38761 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030203AbaDBTbD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 15:31:03 -0400
Content-Disposition: inline
In-Reply-To: <CD1A9D96-F1E1-4AF6-B089-41AEBF7F1699@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 02, 2014 at 09:15:55AM -0700, Scott Feldman wrote:
>=20
> On Apr 2, 2014, at 8:25 AM, John W. Linville <linville@tuxdriver.com>=
 wrote:
>=20
> > On Wed, Apr 02, 2014 at 10:32:49AM -0400, Andy Gospodarek wrote:

> >> Using netlink messages to notify drivers for these ASICs really
> >> seems like a great way to handle things.  It would obviously requi=
re
> >> some expansion of netlink, but that seems fine.
> >>=20
> >> I would prefer that ASIC vendors write initial drivers for their
> >> ASICs such that each physical port is detected and exported as a
> >> netdev.  This would mean each *minimal* kernel driver for an ASIC
> >> would need to have support for the following (off the top of my
> >> head):
> >>=20
> >> - detect link status on an interface
> >> - set an interface's MAC address
> >> - configure the chip to send all frames to the CPU
> >> - register a napi handler for the interfaces (depending on
> >> packet-buffering capabilities in the hardware)
> >>=20
> >> As support for new hardware capabilities are moved from switch
> >> vendor SDKs to their kernel driver the driver can begin to listen
> >> for netlink messages that:
> >>=20
> >> - setup bonds/teams
> >> - add ports to bridge groups
> >> - configure port-based or mac-based VLANs
> >> - add unicast and multicast entries
> >> - add and remove entries from a flow table
> >> - ...
> >>=20
> >> Maybe this all seems to matter-of-fact and the discussion has
> >> evolved well beyond something this high-level, but there still see=
ms
> >> to be significant discussion about whether or not the ASIC should =
be
> >> exported as a netdev and I'm just not seeing a compelling reason.
> >> This was my attempt to explain why.  :)
> >=20
> > Andy and I discussed this off-line, so I am admittedly partial to
> > the conclusions we shared as reflected above... :-)
> >=20
> > While I might be convinced that there should be _something_ to
> > represent the switch chip for some purpose (e.g. topology mapping),
> > I'm not at all convinced that thing should be a netdev.  I don't se=
e
> > where the switch chip by itself looks much like any other netdev at
> > all, especially once you model the actual front-panel ports with
> > their own netdevs.  I do know that having an extra "magic netdev"
> > in the wireless space added a lot of confusion for no clear gain,
> > leading to it later being abolished.
> >=20
> > Modeling at the switch level might make more sense from a flow
> > management perspective?  But if those flows are managed using a net=
link
> > protocol, does it matter what sort of entity is listening and actin=
g
> > on those messages?  If a switch-specific interface is needed for th=
at,
> > we should build it rather than pretending it looks like a netdev.
> > I also think that throwing the DSA switches in with flow-based and
> > "Enterprise" switches may just be confusing things.
> >=20
> > I think that the opening bid should be a minimal hardware driver th=
at
> > models each front-panel port with a netdev and passes all traffic
> > to/from the CPU.  Intelligence beyond that should be added on a
> > 'can-do' basis, with individual drivers (or corresponding userland
> > components) listening to existing netlink traffic and implementing
> > support for existing protocols to the best of their abilities.
> > Missing functionality in the netlink protocols or other functions
> > (e.g. bonding, bridging, etc) can be evolved over time as we discov=
er
> > missing bits required for switch acceleration.
>=20
> I agree completely with your/Andy=E2=80=99s view.  It=E2=80=99s the s=
witch port,
> not the switch, that needs to be modeled as a netdev.  The switch por=
t
> is the abstraction that allows other existing virtual devices (bridge=
s,
> bond, vxlans, etc) to cuddle against.  Is a switch port a special
> netdev in some way?  At a high level, not really.  I mean in sense
> it=E2=80=99s just eth48 on a super NIC.  OK, there may be some advant=
age
> to setting a IFF_SWITCH_PORT on the switch port netdev, so cuddling
> netdevs could get a hint that their data plane might be offloaded.

Some sort of "I'm a switch port!" flag or an ndo_whatever might make
sense in the long run.  But, I'm not sure it is the kind of thing
that needs to be modeled right now...?  It seems more important to
get something modeled that we can build upon without having to solve
every problem up front.

> I=E2=80=99ve been back-and-forth on the switch netdev.  Today I=E2=80=
=99m
> not for it.  But I=E2=80=99m still searching for a reason.  At one po=
int
> I thought a switch netdev would be nice in a L3 router case where
> we needed a router IP address to do things like OSPF unnumbered
> interfaces, but even in that case, we can just put the router IP
> on lo.  Another reason would be to use the switch netdev as a place
> for switch-wide settings and status.  For example,
> ethtool -S stats on switch netdev would show switch-wide stats like
> ACL drops or something like that.  Maybe a switch device is modeled a=
s
> a new device class?  I guess it comes down to how much is duplicated
> between different vendors' switch driver implementations.

I've seen the 'ethtool -S' example before and I guess it is valid.
Still, is it worth the confusion of having a mostly useless/unique
netdev just to reuse an ethtool ioctl?  Maybe, I guess...?

The example of having a netdev that represents an L3 entity riding on
top of the L2 network provided by the switch seems somewhat reasonable.
It reminds me of what we did when I worked on FASTPATH, ages ago.
In some cases it probably makes some sense.  Still, I'm not sure it
provides any utility over just implementing a bridge on top of all
the switch port netdevs?

> Agree on the missing netlink functionality point, add it as we go.
> Outside the bonding stuff we recently added, we (Cumulus) find netlin=
k
> pretty complete as-is to program modern, enterprise-class switch chip=
s.

Cool!  I'm glad we agree.  Now we just need some switch hardware
drivers that fit the general model outlined above...

I would be happy to maintain a kernel.org git tree as a nursery for
such drivers as they develop and mature, and I'm sure my daytime
employer would be happy to support me on that.  I wonder if we can
get any switch people from Intel, Mellanox, Broadcom, or elsewhere
to play along?

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
