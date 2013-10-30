From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet switch
 configuration API
Date: Wed, 30 Oct 2013 20:47:30 +0100
Message-ID: <52716252.9060502@openwrt.org>
References: <5267BB53.8030703@openwrt.org> <5267C6B9.4000704@mojatatu.com> <5267CFAB.9090100@openwrt.org> <5267D8AE.7080009@mojatatu.com> <5267DDE6.70600@openwrt.org> <526A5949.6040404@mojatatu.com> <526A6BB3.7050507@openwrt.org> <526D4B06.8040505@mojatatu.com> <526D6EBA.3020903@openwrt.org> <526EEAE9.6090508@mojatatu.com> <20131030172756.GM8570@wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	John Crispin <blogic@openwrt.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Gary Thomas <gary@mlbassoc.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Chris Healy <cphealy@gmail.com>
To: Lennert Buytenhek <buytenh@wantstofly.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:36320 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754732Ab3J3Trz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 15:47:55 -0400
In-Reply-To: <20131030172756.GM8570@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-10-30 18:27, Lennert Buytenhek wrote:
> I didn't follow the rest of this thread, but..
> 
> 
> On Mon, Oct 28, 2013 at 06:53:29PM -0400, Jamal Hadi Salim wrote:
> 
>> >That question does not make any sense to me. Aside from low level
>> >control frames like pause frames for flow control, the switch has no
>> >need to send packets to the CPU port on its own.
> 
> ..a lot of people want to be able to do Spanning Tree, LLDP, 802.1x,
> you name it, on their routers and access points, and that requires
> that your CPU can send/receive packets to/from individual ports on
> your switch chip.  In a lot of markets, your product is a non-starter
> if it can't provide any or all of the above.  Excluding this entire
> class of use cases _by software design_ is somewhat myopic and stupid.
> 
> (It's a different thing if your switch chip is dumb and can't actually
> address individual ports, but then there's still no reason to impose
> the same restrictions on your software design.)
Many of the switches we support can't address individual ports via tags.
You usually just set up VLANs and let the switch do the rest.

>> >DSA does this, and last time I looked, it pushes *all* bridge traffic
>> >through the CPU, making it completely unusable for slower embedded CPUs.
>>
>> [...]
>>
>> >If I remember correctly, adding support 'bridge acceleration' was left
>> >as an exercise for the reader and never actually implemented.
> 
> This patch does exactly that:
> 
> 	http://patchwork.ozlabs.org/patch/16578/
> 
> This patch is in production use in a couple of million DSL gateways,
> as well as in a bunch of airplane in-flight entertainment systems, so
> by all means I would say that it works rather well.
> 
> If there is renewed interest in having such functionality upstream,
> I would be happy to update the patch and submit it for inclusion.
Yes, I would really like to see this merged. If we can somehow get the
bridge offload stuff to handle VLAN trunking as well, I'd be interested
in looking into DSA support for some Atheros switches that I've been
working with.

>> >Sure, this could be fixed somehow, but even then the model and
>> >assumptions that DSA is built on simply don't work for some of the
>> >dumber switches that we support.
> 
> What model and assumptions would those be?
The assumption of being able to address individual ports via tags.

>> >One of the currently very common switches in many embedded devices is
>> >the RTL8366/RTL8367. It has some flexibility when it comes to
>> >configuring VLANs, and it's one of the few ones where you can configure
>> >a forwarding table for a VLAN (which spans multiple ports), which allows
>> >software bridging between multiple VLANs.
>> >However, what this switch does *not* support is adding a header/trailer
>> >to packets to indicate the originating port.
> 
> The ingress/egress port doesn't _have_ to be conveyed in the data
> packets themselves.
> 
> From a quick look at the RTL8366 datasheet, you can control the
> egress port by creating a temporary MAC address table entry (this
> seems to work both for unicast and multicast packets).
Sounds nasty. I certainly wouldn't want this called from the data path,
since on some systems register access will be bit-banged over GPIO.

> Admittedly, I didn't have a very thorough look at the datasheet,
> but it also mentions the Spanning Tree protocol, and contains this
> remark related to receiving BPDUs: "The CPU port should carry the
> ingress port number of the receiving BPDU.".  If this switch chip
> can't do per-port addressing, how can it actually ever speak STP
> at all?  Is the datasheet just lying about this?
>From what the datasheet, it looks like it expects the CPU to guess the
port based on the VLAN ID. This is RealTek, so it might just be
theoretically possible to do what the datasheet says, but quirky enough
to be unusable in practice.

>> >This means that all per-port netdevs will be dummy ports which don't
>> >include the data path.
> 
> And I think that's fine.
> 
> Look, even if you're not going to address data traffic to individual
> ports on your switch chip, there's still a plethora of per-port
> operations that you want to be able to do: administratively setting
> the link state on ports up and down, controlling autonegotiation and
> other PHY settings on individual ports, etc.
> 
> You can either let the administrator do this with the standard ifconfig
> / ip link / ethtool tools, or you can make up a parallel API and
> corresponding set of userland tools to duplicate most of the existing
> functionality -- I know which option I prefer.
> 
> Presenting each switch port as an individual Linux netdevice to the OS
> is an orthogonal decision to actually using those netdevices for data
> traffic, and conflating the two by arguing that you need special tools
> to do per-port operations for the sole reason that your switch chip
> cannot address individual ports is a rather confused argument.
The thing that most swconfig users in OpenWrt care about is being able
to group ports into VLANs, sometimes just to be able to split them into
LAN/WAN, sometimes to be able to use one port as a trunking port to
connect multiple networks (some of which may be on ports of the same
switch, some behind the CPU port).
I care about that part a lot more than messing around with the
individual ports.
If we can figure out a clean and simple way to support this well, even
on switches that are seriously limited wrt. individual port addressing
via the data path, I'd be more willing to consider it.
I still don't like the dummy netdev thing very much, because I know
enough users that will easily get confused by this, and with a separate
interface they at least know that there's a separate set of rules to it.
I don't think that's a confused argument.

>> >With swconfig, you create two VLANs: VLAN 4, containing CPU and port1;
>> >VLAN 400, containing CPU and port2. You then create a software bridge
>> >between eth0.4 and eth0.400 (assuming eth0 is the NIC connected to the
>> >switch).
> 
> With DSA, you would bridge between port1.4 and port2.400.  I'm still
> not sure what your argument is arguing for or against.
I'm saying most switches that we support cannot do DSA-style packet port
tagging for ingress/egress. That kind of setup can be done with some
software bridging when setting up VLAN tables appropriately, but I'm not
sure it's possible to emulate this if you're treating the switch as a
'bridge' and trying to do handle this via the FDB API, which is what we
were discussing earlier.

- Felix
