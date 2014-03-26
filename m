From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 26 Mar 2014 12:11:55 -0700
Message-ID: <CAGVrzcYNW0Z96mL-MecY=mte=+TcFn8k3eSY4pqi9h0N2jF7hw@mail.gmail.com>
References: <CAGVrzcbqQGGYb2Wkkekei7ivGd2XOnE+5GthLUv6_nD_oicrSQ@mail.gmail.com>
 <532C2AC4.7080303@mojatatu.com> <20140322094852.GB2844@minipsycho.orion>
 <5330BAB7.3040501@mojatatu.com> <20140325173927.GE8102@hmsreliant.think-freely.org>
 <20140325180009.GB15723@casper.infradead.org> <20140325193533.GF8102@hmsreliant.think-freely.org>
 <5331ED86.7020704@mojatatu.com> <20140326111031.GB31370@hmsreliant.think-freely.org>
 <20140326112903.GG15723@casper.infradead.org> <20140326182122.GC31370@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Thomas Graf <tgraf@suug.ch>, Jamal Hadi Salim <jhs@mojatatu.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Scott Feldman <sfeldma@cumulusnetworks.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Felix Fietkau <nbd@openwrt.org>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:34795 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754548AbaCZTMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 15:12:35 -0400
Received: by mail-pa0-f54.google.com with SMTP id lf10so2354259pab.13
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 12:12:35 -0700 (PDT)
In-Reply-To: <20140326182122.GC31370@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014-03-26 11:21 GMT-07:00 Neil Horman <nhorman@tuxdriver.com>:
> On Wed, Mar 26, 2014 at 11:29:03AM +0000, Thomas Graf wrote:
>> On 03/26/14 at 07:10am, Neil Horman wrote:
>> > But by creating net_devices that are registered in the current fashion we
>> > implicitly agree to levels of functionality that are assumed to be available and
>> > as such are not within the purview of a net_device to reject.  E.g. it is
>> > assumed that a netdevice can filter frames using iptables/ebtables, limit
>> > traffic using tc, etc.
>>
>> I think this is the point where we disagree. We already have several
>> devices that hook into the rx handler and never have their packets
>> pass through either iptables or ebtables. Better examples of this are
>> macvtap or OVS.
>>
> Yes, this is the point of contention, you're right.  And you're also correct in
> that we do have several devices that bypass the network stack on the.  My
> concern is that, in all of those cases its being bypassed because we know that
> other software is handling that functionality (in the case of macvtap we know
> that we're passing it off to a guest to be processed via the full network stack
> available in the guest, and in the case of OVS, we know that we are passing
> traffic to a software defined switch for handling).  In the case of having a
> switch fabric available, we're explicitly hiding the fact that traffic we are
> passing between ports never touches the cpu, and that just rubs me the wrong
> way.  I suppose I'm looking at switch fabrics in the same way that I look at
> TOE.  In offloading forwaring functionality we remove from the cpu activity
> which an administrator may reasonably expect to see handled in the cpu, but they
> wont.  In the case of macvlan, the admin knows thats a macvlan device, and
> packet handling for frames bound to it occurs in the guest.  for OVS, packets
> recieved on the cpu with the proper encapsulation are clearly handled in the
> OVS bridge.  But in the case of a hardware switch, all they see are 4 net device
> interfaces that seem like any other net device.

Right, this is why Felix did not expose the switch ports as netdevices
when he designed swconfig, because this would break the contract and
assumptions that net_devices do actually transport data, and are not
just used for control. It also made it easier to have a separate
control path to expose the gazillion different configuration knobs
that various switches offer...

>
> Perhaps I need to let go of this notion, but it seems to me, if we're going to
> allow cpu stack bypass, then we need to make that very obvious to an
> administrator.  Maybe a flag like IFF_L2ONLY (or perhaps better still
> IFF_LOCALDATAONLY, to indicate that only data directly addressed to the
> interface, or to a multi/broadcast address will be received by it, despite the
> promisc or other settings is sufficient). I really don't know.  Thats where my
> hang up is though.

This is where putting those devices in a separate namespace really
helped making that obvious. That said, there are already in-tree
infrastructure which is "breaking" the contract that per-port
net_device do transport data, with DSA in particular. Those per-port
network devices are just used as control endpoints to reach the switch
per-port configuration registers. They might deliver some per-port
traffic at some point in time, until you reconfigure the switch to do
otherwise, by e.g: bridging LAN ports together.

If we use Jiri's latest patchset, IFF_LOCALDATAONLY would become
pretty much implied by IFF_SWITCH_PORT.

>
>> What should happen is that these devices are given a chance to implement
>> the ACL in their own flow table. If no such facility exists, the rule
>> insertion should fall back to software mode if that is possible (an
>> OF capable switching chip could insert a 'upcall' flow), or as
>> a last resort return an error to indicate EOPNOTSUPP.
>>
>> > And if a switch fabric is short cutting traffic so that
>> > the cpu doesn't see them, those bits of functionality won't work.  I agree we
>> > can likely work around that with richer feature capabilities, but such an
>> > infrastructure would both require extensive kernel changes to fully cover the
>> > set of existing features at a sufficient granularity, and require user space
>> > changes to grok the feature set of a given device.  Not saying its impossibible
>> > or even undesireable mind you, just thats its not any less invasive than what
>> > I'm proposing.
>>
>> What I don't understand at this point is how hiding the ports behind
>> a master device would buy us anything. We would still need to abstract
>> the filtering capabilities of the ports at some level and hiding that
>> behind existing tools seems to most convenient way.
>>
>
> If we agree that inconsistent frame reception / stack bypass is acceptable, then
> hiding the ports buys us nothing.

I think this was pretty much agreed on a while ago with DSA, macvlan
and TOE as you cited.

> My only goal with that suggestion was to
> differentiate ports on a switch device so that the ports were differentiated in
> such a way as to make it clear that they didn't behave like typical NIC ports
> that were meant to receive host terminated traffic only.  If the consensus is
> to allows sparse reception of forwarded traffic at the cpu, then no, its not
> worthwhile and can be ignored.

Part of the problem is that you might start seeing actual relevant
traffic on these per-port net_devices e.g: during software learning
times, where traffic to specific ports will also be mirrored to the
CPU port for lossless (or close to) traffic delivery, and then some
software agent on the CPU will decide to bridge/bond/add vlans to some
ports, and then we won't be seeing traffic again on these per-port
net_devices for a while (in the context of switches supporting tags).
As such, I'd rather treat those per-port net_devices as almost regular
net_devices to allow that traffic to flow, even though this is not a
permanent state.
-- 
Florian
