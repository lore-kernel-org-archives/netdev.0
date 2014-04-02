From: Scott Feldman <sfeldma@cumulusnetworks.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of switch chip datapath
Date: Wed, 2 Apr 2014 09:15:55 -0700
Message-ID: <CD1A9D96-F1E1-4AF6-B089-41AEBF7F1699@cumulusnetworks.com>
References: <20140325193533.GF8102@hmsreliant.think-freely.org> <CAGVrzcbRggJV+5+EuZnXVoU+qdK9ugPRL+J-mp-UraGuo19jnQ@mail.gmail.com> <5332677F.2090404@cumulusnetworks.com> <5332B1FE.7080102@mojatatu.com> <53330639.8050403@cumulusnetworks.com> <20140326165934.GH2869@minipsycho.orion> <533312A3.5070600@cumulusnetworks.com> <20140326180356.GK2869@minipsycho.orion> <2D65D0C2-6BBC-4968-8400-4EB60BDF887A@cumulusnetworks.com> <533C1F91.6000704@greyhouse.net> <20140402152546.GB3596@tuxdriver.com>
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Content-Type: text/plain; charset=windows-1252
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
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:38997 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758808AbaDBQSI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 12:18:08 -0400
In-Reply-To: <20140402152546.GB3596@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 2, 2014, at 8:25 AM, John W. Linville <linville@tuxdriver.com> w=
rote:

> On Wed, Apr 02, 2014 at 10:32:49AM -0400, Andy Gospodarek wrote:
>> On 04/01/2014 03:13 PM, Scott Feldman wrote:
>>> On Mar 26, 2014, at 11:03 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>=20
>>>> Wed, Mar 26, 2014 at 06:47:15PM CET, roopa@cumulusnetworks.com wro=
te:
>>>>> On 3/26/14, 9:59 AM, Jiri Pirko wrote:
>>>>>> Wed, Mar 26, 2014 at 05:54:17PM CET, roopa@cumulusnetworks.com w=
rote:
>>>>>> So you implement bonding netlink api? Or you hook into bonding d=
river
>>>>>> itselt? Can you show us the code?
>>>>> We use the netlink API and libnl. In our current model, our switc=
h
>>>>> chip driver listens to netlink notifications and programs the swi=
tch
>>>>> chip. The switch chip driver uses libnl caches and libnl netlink =
apis
>>>>> to reflect the kernel state to switch chip.
>>>>=20
>>>> So when you configure for example bonding over 2 ports, you actual=
ly use
>>>> bonding driver to do that. And you userspace app listens to
>>>> notifications and programs the switch chip accordingly. Am I close=
?
>>>>=20
>>>> How about data? Is this new "bonding" interface able to assign ip =
to is
>>>> and send/receive packets.
>>>>=20
>>>> I'm still not sure I understand your concept. Do you have some
>>>> documentation for it available?
>>> Actually Jiri this is the code you and I worked on recently to netl=
ink-ify bonding/slave attributes and active/inactive notification.  You=
 have it right, user uses normal ip link tools and bonding driver to cr=
eate bond, set attributes, and enslave switch ports.  RTM_NEWLINK is us=
ed to program ASIC to offload LAG to HW.  RTM_NEWLINK msgs contains bon=
d attributes (mode, etc) and slave list, as well as slave status.  This=
 is enough information to program ASIC.  Once programmed, ASIC offloads=
 the data plane traffic, and in the case of egress, handles the LAG has=
h distribution.  Only the LACP control plane traffic makes it to the bo=
nding driver; data plane traffic does not make it to the bonding driver=
=2E
>>>=20
>>> So, not trying to sound like a smart-ass, but the documentation is =
the bonding driver, specifically the netlink attributes/notifications.
>>>=20
>>> -scott
>>=20
>> Using netlink messages to notify drivers for these ASICs really
>> seems like a great way to handle things.  It would obviously require
>> some expansion of netlink, but that seems fine.
>>=20
>> I would prefer that ASIC vendors write initial drivers for their
>> ASICs such that each physical port is detected and exported as a
>> netdev.  This would mean each *minimal* kernel driver for an ASIC
>> would need to have support for the following (off the top of my
>> head):
>>=20
>> - detect link status on an interface
>> - set an interface's MAC address
>> - configure the chip to send all frames to the CPU
>> - register a napi handler for the interfaces (depending on
>> packet-buffering capabilities in the hardware)
>>=20
>> As support for new hardware capabilities are moved from switch
>> vendor SDKs to their kernel driver the driver can begin to listen
>> for netlink messages that:
>>=20
>> - setup bonds/teams
>> - add ports to bridge groups
>> - configure port-based or mac-based VLANs
>> - add unicast and multicast entries
>> - add and remove entries from a flow table
>> - ...
>>=20
>> Maybe this all seems to matter-of-fact and the discussion has
>> evolved well beyond something this high-level, but there still seems
>> to be significant discussion about whether or not the ASIC should be
>> exported as a netdev and I'm just not seeing a compelling reason.
>> This was my attempt to explain why.  :)
>=20
> Andy and I discussed this off-line, so I am admittedly partial to
> the conclusions we shared as reflected above... :-)
>=20
> While I might be convinced that there should be _something_ to
> represent the switch chip for some purpose (e.g. topology mapping),
> I'm not at all convinced that thing should be a netdev.  I don't see
> where the switch chip by itself looks much like any other netdev at
> all, especially once you model the actual front-panel ports with
> their own netdevs.  I do know that having an extra "magic netdev"
> in the wireless space added a lot of confusion for no clear gain,
> leading to it later being abolished.
>=20
> Modeling at the switch level might make more sense from a flow
> management perspective?  But if those flows are managed using a netli=
nk
> protocol, does it matter what sort of entity is listening and acting
> on those messages?  If a switch-specific interface is needed for that=
,
> we should build it rather than pretending it looks like a netdev.
> I also think that throwing the DSA switches in with flow-based and
> "Enterprise" switches may just be confusing things.
>=20
> I think that the opening bid should be a minimal hardware driver that
> models each front-panel port with a netdev and passes all traffic
> to/from the CPU.  Intelligence beyond that should be added on a
> 'can-do' basis, with individual drivers (or corresponding userland
> components) listening to existing netlink traffic and implementing
> support for existing protocols to the best of their abilities.
> Missing functionality in the netlink protocols or other functions
> (e.g. bonding, bridging, etc) can be evolved over time as we discover
> missing bits required for switch acceleration.

I agree completely with your/Andy=92s view.  It=92s the switch port, no=
t the switch, that needs to be modeled as a netdev.  The switch port is=
 the abstraction that allows other existing virtual devices (bridges, b=
ond, vxlans, etc) to cuddle against.  Is a switch port a special netdev=
 in some way?  At a high level, not really.  I mean in sense it=92s jus=
t eth48 on a super NIC.  OK, there may be some advantage to setting a I=
=46F_SWITCH_PORT on the switch port netdev, so cuddling netdevs could g=
et a hint that their data plane might be offloaded.

I=92ve been back-and-forth on the switch netdev.  Today I=92m not for i=
t.  But I=92m still searching for a reason.  At one point I thought a s=
witch netdev would be nice in a L3 router case where we needed a router=
 IP address to do things like OSPF unnumbered interfaces, but even in t=
hat case, we can just put the router IP on lo.  Another reason would be=
 to use the switch netdev as a place for switch-wide settings and statu=
s.  For example,=20
ethtool -S stats on switch netdev would show switch-wide stats like ACL=
 drops or something like that.  Maybe a switch device is modeled as a n=
ew device class?  I guess it comes down to how much is duplicated betwe=
en different vendors' switch driver implementations.

Agree on the missing netlink functionality point, add it as we go.  Out=
side the bonding stuff we recently added, we (Cumulus) find netlink pre=
tty complete as-is to program modern, enterprise-class switch chips.

-scott
