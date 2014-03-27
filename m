From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Thu, 27 Mar 2014 11:26:55 -0400
Message-ID: <20140327152655.GA1358@hmsreliant.think-freely.org>
References: <5330BAB7.3040501@mojatatu.com>
 <20140325173927.GE8102@hmsreliant.think-freely.org>
 <20140325180009.GB15723@casper.infradead.org>
 <20140325193533.GF8102@hmsreliant.think-freely.org>
 <5331ED86.7020704@mojatatu.com>
 <20140326111031.GB31370@hmsreliant.think-freely.org>
 <20140326112903.GG15723@casper.infradead.org>
 <20140326182122.GC31370@hmsreliant.think-freely.org>
 <CAGVrzcYNW0Z96mL-MecY=mte=+TcFn8k3eSY4pqi9h0N2jF7hw@mail.gmail.com>
 <53335838.3060409@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	netdev <netdev@vger.kernel.org>,
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
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:54180 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469AbaC0P12 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2014 11:27:28 -0400
Content-Disposition: inline
In-Reply-To: <53335838.3060409@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 26, 2014 at 06:44:08PM -0400, Jamal Hadi Salim wrote:
> On 03/26/14 15:11, Florian Fainelli wrote:
> >2014-03-26 11:21 GMT-07:00 Neil Horman <nhorman@tuxdriver.com>:
> 
> >>Yes, this is the point of contention, you're right.  And you're also correct in
> >>that we do have several devices that bypass the network stack on the.  My
> >>concern is that, in all of those cases its being bypassed because we know that
> >>other software is handling that functionality (in the case of macvtap we know
> >>that we're passing it off to a guest to be processed via the full network stack
> >>available in the guest, and in the case of OVS, we know that we are passing
> >>traffic to a software defined switch for handling).  In the case of having a
> >>switch fabric available, we're explicitly hiding the fact that traffic we are
> >>passing between ports never touches the cpu, and that just rubs me the wrong
> >>way.  I suppose I'm looking at switch fabrics in the same way that I look at
> >>TOE.  In offloading forwaring functionality we remove from the cpu activity
> >>which an administrator may reasonably expect to see handled in the cpu, but they
> >>wont.  In the case of macvlan, the admin knows thats a macvlan device, and
> >>packet handling for frames bound to it occurs in the guest.  for OVS, packets
> >>recieved on the cpu with the proper encapsulation are clearly handled in the
> >>OVS bridge.  But in the case of a hardware switch, all they see are 4 net device
> >>interfaces that seem like any other net device.
> >
> >Right, this is why Felix did not expose the switch ports as netdevices
> >when he designed swconfig, because this would break the contract and
> >assumptions that net_devices do actually transport data, and are not
> >just used for control. It also made it easier to have a separate
> >control path to expose the gazillion different configuration knobs
> >that various switches offer...
> >
> 
> Neil, I may be misreading your "TOE" semantis, but i think you view
> the switch ports from a host prism. I am a middle box guy - I love
> it when packets transiting through my box are offloaded. I can move
> more
> bits/sec.
> It is only TOE if the middle box is trying to do an end host function;->
> 
You're absolutely correct - I am viewing this from a host based perspective.
And I completely understand that offload is good in a middle box environment (I
worked for embedded switch companies in a former life).  I'm looking at it from
a host perspective because, as we've been discussing the wide range of devices
covered here (from the small SOC switches used by owrt to the big enterprise
switches), theres this middle ground thats seeing some consolodation here which
I think we need to cover as well.  I'm referring to NICS that have an embedded
switch in them that can (or soon will) preform lots of these flow based
forwarding operations and actions.

> OTOH, the owrt view is probably because (If i understood correctly
> last time), there are cases where there is no way to even pass packets
> and attribute them to the originating switch ports. Infact, in some
> cases  there may be no way at all to even pass packets to the kernel.
> Did i  understand that part correctly?
I think you did.  At least you and I had the same understanding here.

> I suppose this is eventually all part of that capability discovery.
> 
Agreed.

> [..]
> 
> >
> >Part of the problem is that you might start seeing actual relevant
> >traffic on these per-port net_devices e.g: during software learning
> >times, where traffic to specific ports will also be mirrored to the
> >CPU port for lossless (or close to) traffic delivery, and then some
> >software agent on the CPU will decide to bridge/bond/add vlans to some
> >ports, and then we won't be seeing traffic again on these per-port
> >net_devices for a while (in the context of switches supporting tags).
> >As such, I'd rather treat those per-port net_devices as almost regular
> >net_devices to allow that traffic to flow, even though this is not a
> >permanent state.
> >
> 
> A nod from here.
> I think it would be useful to enumerate these types of devices
> and what their control/data capability is.
> 
> cheers,
> jamal
> 
