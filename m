From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet
 switch configuration API
Date: Wed, 30 Oct 2013 18:27:56 +0100
Message-ID: <20131030172756.GM8570@wantstofly.org>
References: <5267BB53.8030703@openwrt.org>
 <5267C6B9.4000704@mojatatu.com>
 <5267CFAB.9090100@openwrt.org>
 <5267D8AE.7080009@mojatatu.com>
 <5267DDE6.70600@openwrt.org>
 <526A5949.6040404@mojatatu.com>
 <526A6BB3.7050507@openwrt.org>
 <526D4B06.8040505@mojatatu.com>
 <526D6EBA.3020903@openwrt.org>
 <526EEAE9.6090508@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
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
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Felix Fietkau <nbd@openwrt.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fw.wantstofly.org ([80.101.37.227]:61716 "EHLO
	mail.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707Ab3J3RgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 13:36:08 -0400
Content-Disposition: inline
In-Reply-To: <526EEAE9.6090508@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I didn't follow the rest of this thread, but..


On Mon, Oct 28, 2013 at 06:53:29PM -0400, Jamal Hadi Salim wrote:

> >That question does not make any sense to me. Aside from low level
> >control frames like pause frames for flow control, the switch has no
> >need to send packets to the CPU port on its own.

..a lot of people want to be able to do Spanning Tree, LLDP, 802.1x,
you name it, on their routers and access points, and that requires
that your CPU can send/receive packets to/from individual ports on
your switch chip.  In a lot of markets, your product is a non-starter
if it can't provide any or all of the above.  Excluding this entire
class of use cases _by software design_ is somewhat myopic and stupid.

(It's a different thing if your switch chip is dumb and can't actually
address individual ports, but then there's still no reason to impose
the same restrictions on your software design.)


> >DSA does this, and last time I looked, it pushes *all* bridge traffic
> >through the CPU, making it completely unusable for slower embedded CPUs.
>
> [...]
>
> >If I remember correctly, adding support 'bridge acceleration' was left
> >as an exercise for the reader and never actually implemented.

This patch does exactly that:

	http://patchwork.ozlabs.org/patch/16578/

This patch is in production use in a couple of million DSL gateways,
as well as in a bunch of airplane in-flight entertainment systems, so
by all means I would say that it works rather well.

If there is renewed interest in having such functionality upstream,
I would be happy to update the patch and submit it for inclusion.


> >Sure, this could be fixed somehow, but even then the model and
> >assumptions that DSA is built on simply don't work for some of the
> >dumber switches that we support.

What model and assumptions would those be?


> >One of the currently very common switches in many embedded devices is
> >the RTL8366/RTL8367. It has some flexibility when it comes to
> >configuring VLANs, and it's one of the few ones where you can configure
> >a forwarding table for a VLAN (which spans multiple ports), which allows
> >software bridging between multiple VLANs.
> >However, what this switch does *not* support is adding a header/trailer
> >to packets to indicate the originating port.

The ingress/egress port doesn't _have_ to be conveyed in the data
packets themselves.

>From a quick look at the RTL8366 datasheet, you can control the
egress port by creating a temporary MAC address table entry (this
seems to work both for unicast and multicast packets).

Admittedly, I didn't have a very thorough look at the datasheet,
but it also mentions the Spanning Tree protocol, and contains this
remark related to receiving BPDUs: "The CPU port should carry the
ingress port number of the receiving BPDU.".  If this switch chip
can't do per-port addressing, how can it actually ever speak STP
at all?  Is the datasheet just lying about this?


> >This means that all per-port netdevs will be dummy ports which don't
> >include the data path.

And I think that's fine.

Look, even if you're not going to address data traffic to individual
ports on your switch chip, there's still a plethora of per-port
operations that you want to be able to do: administratively setting
the link state on ports up and down, controlling autonegotiation and
other PHY settings on individual ports, etc.

You can either let the administrator do this with the standard ifconfig
/ ip link / ethtool tools, or you can make up a parallel API and
corresponding set of userland tools to duplicate most of the existing
functionality -- I know which option I prefer.

Presenting each switch port as an individual Linux netdevice to the OS
is an orthogonal decision to actually using those netdevices for data
traffic, and conflating the two by arguing that you need special tools
to do per-port operations for the sole reason that your switch chip
cannot address individual ports is a rather confused argument.


> My view is that netdevs are still valuable even if only they get
> used for control path. Like you said earlier - you can still pull
> stats, flow control messages still make it through etc. They provide
> you
> the consistent api to configure the switch above, ex:
> If i was to use the FDB api for this switch as long as i can
> abstract it in software as a bridge, I could send it a switch config
> via its ops which says:
> "I am giving you this entry with vland 400 for port 2, but i want you to
> send it to the hardware not to your local entry"

Fully agreed on this.


> >So let's say you have a configuration where you're using VLAN ID 4 on
> >port 1, and you want to bridge it to VLAN ID 400 on port 2.
> >
> >Sounds easy enough, you can easily create a bridge that spans port1.4
> >and port2.400. Except, this particular switch (like pretty much any
> >other switch supported by swconfig) isn't actually able to handle such a
> >configuration on its own.

Neither can DSA switch chips.

You can always find things that Linux can do that your switch chip
cannot (e.g. stateful firewalling between ports), and that isn't much
of an argument for or against anything.


> >With swconfig, you create two VLANs: VLAN 4, containing CPU and port1;
> >VLAN 400, containing CPU and port2. You then create a software bridge
> >between eth0.4 and eth0.400 (assuming eth0 is the NIC connected to the
> >switch).

With DSA, you would bridge between port1.4 and port2.400.  I'm still
not sure what your argument is arguing for or against.


> >In a different scenario, the code would also have to detect
> >configurations that the switch isn't able to handle, e.g.: bridging
> >port1.4 to eth1 and port2.4 to eth2.
> >Such a configuration wouldn't work at all with such a switch, because
> >the CPU isn't able to tell apart traffic from port1 and port2, and
> >there's no way to tell the switch that port1.4 and port2.4 should not be
> >connected to each other, but both should go to the CPU.

And it's quite easy to detect what your switch chip can do and offload
that part to the hardware, and keep doing the rest in software.


> >Trying to make all of these cases work in the code will make the whole
> >thing a lot more difficult to deal with and maintain. It will also make
> >it much harder for the user to figure out, what configurations work, and
> >what configurations don't.

It's actually quite easy, and certainly a lot less total effort than
forcing all of your users to learn a new set of userland tools (unless
you're not aiming to ever have a lot of users, that is..).


thanks,
Lennert
