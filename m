From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet switch
 configuration API
Date: Sun, 27 Oct 2013 20:51:22 +0100
Message-ID: <526D6EBA.3020903@openwrt.org>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com> <1382466229-15123-2-git-send-email-f.fainelli@gmail.com> <5266D7D6.9000309@intel.com> <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com> <20131022202537.GA16336@hmsreliant.think-freely.org> <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com> <5267B764.305@mojatatu.com> <5267BB53.8030703@openwrt.org> <5267C6B9.4000704@mojatatu.com> <5267CFAB.9090100@openwrt.org> <5267D8AE.7080009@mojatatu.com> <5267DDE6.70600@openwrt.org> <526A5949.6040404@mojatatu.com> <526A6BB3.7050507@openwrt.org> <526D4B06.8040505@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	John Crispin <blogic@openwrt.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Gary Thomas <gary@mlbassoc.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>
To: Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:56366 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752397Ab3J0Tvo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Oct 2013 15:51:44 -0400
In-Reply-To: <526D4B06.8040505@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-10-27 6:19 PM, Jamal Hadi Salim wrote:
> On 10/25/13 09:01, Felix Fietkau wrote:
>> 'won't pass up the tag'? The switch is treated in pretty much the same
>> way as a normal managed standalone switch (you know, one you can buy in
>> a shop and plug your Ethernet cable into).
>> You simply tell it, which VLANs to put on which ports, and make the
>> ports tagged or untagged.
>> The link between the switch and the CPU is not really special, for the
>> switch it's just another port. This way of configuring works with pretty
>> much all switches that we're using.
> 
> So does it get its own MAC address? Other than flooding broadcasts,
> how does one end up sending packets to the cpu?
That question does not make any sense to me. Aside from low level
control frames like pause frames for flow control, the switch has no
need to send packets to the CPU port on its own.
Remember what I told you about the switch being a *separate* entity from
the NIC that connects it to the CPU.

>> I remain absolutely unconvinced that this will make the end result
>> better. Right now, these switches act like separate devices, because
>> aside from the fact that they're put on the same board with other
>> components, they pretty much *are* separate devices.
>>
>> You seem to insist on treating it as a kind of port multiplexer + bridge
>> accelerator instead of a mostly standalone switch.
> 
> Yes, the above is the point i was making.
> I apologize for sounding like a broken record, but to just re-iterate:
> there are, if i recall correctly, several drivers  in the kernel
> which are challenged as such (with single entry point into the CPU)
> which expose multiple netdevs with the driver acting as mux point.
DSA does this, and last time I looked, it pushes *all* bridge traffic
through the CPU, making it completely unusable for slower embedded CPUs.

If I remember correctly, adding support 'bridge acceleration' was left
as an exercise for the reader and never actually implemented.

Sure, this could be fixed somehow, but even then the model and
assumptions that DSA is built on simply don't work for some of the
dumber switches that we support.

>> This may work for some devices, but on others this simply a model that
>> the hardware wasn't designed for.
> 
> I agree. But what i just described above is not new. A lot of embedded
> multiport NICs tend to be handicapped in exactly the same way.
> 
>> Sure, we could try to cram in all
>> those special cases, extra options, and hack through the layers where
>> they're in the way. If *all* you care about is being able to reuse the
>> existing interfaces, that might even seem like a good idea.
> 
> I do care a lot about using existing interfaces ;-> Great usability
> for someone to run a tool that has been around for 20 years and it
> works. If i can just reuse my scripts without having to invent
> new ones etc etc.
I see that. But please stop treating this as the *only* factor that
matters! I'd like to see a more balanced cost/benefit analysis.

>> On the other hand, I've pointed out quite a few examples where the model
>> of trying to cram it into the bridge API is just a bad fit in general.
> 
> Sorry Felix, nothing you described is insurmountable.
I'm not saying it's insurmountable, I'm saying it's impractical!
It makes one aspect (code reuse) better in some cases, while making lots
of other aspects worse.

> The challenge here is non-technical:
> You already have code that has been proven and is deployed for what 
> appears to be sometime now.
> I totally empathize.
Please stop making it look like this is the primary issue. Sure, it's
more convenient for us to reuse the existing code, but it's far from
being the only important factor here!
As an embedded Linux developer, I care a lot about fighting complexity
and bloat, and those do tend to be much harder to deal with than a bit
of API consistency.

I get the sense that trying to communicate on an abstract level gets us
nowhere in this discussion, so let me make it a bit more specific with
some examples:

One of the currently very common switches in many embedded devices is
the RTL8366/RTL8367. It has some flexibility when it comes to
configuring VLANs, and it's one of the few ones where you can configure
a forwarding table for a VLAN (which spans multiple ports), which allows
software bridging between multiple VLANs.
However, what this switch does *not* support is adding a header/trailer
to packets to indicate the originating port.
This means that all per-port netdevs will be dummy ports which don't
include the data path.

So let's say you have a configuration where you're using VLAN ID 4 on
port 1, and you want to bridge it to VLAN ID 400 on port 2.

Sounds easy enough, you can easily create a bridge that spans port1.4
and port2.400. Except, this particular switch (like pretty much any
other switch supported by swconfig) isn't actually able to handle such a
configuration on its own.
It needs two VLAN configurations, with different forwarding table IDs,
and then the software bridge on the CPU port needs to forward between
the two different VLANs.
To be able to handle such a configuration, the code would have to detect
this kind of special case scenario, somehow hook itself via rx handler
into the NIC connected to the CPU port and emulate that VLAN ID
replacement behavior.

With swconfig, you create two VLANs: VLAN 4, containing CPU and port1;
VLAN 400, containing CPU and port2. You then create a software bridge
between eth0.4 and eth0.400 (assuming eth0 is the NIC connected to the
switch).

In a different scenario, the code would also have to detect
configurations that the switch isn't able to handle, e.g.: bridging
port1.4 to eth1 and port2.4 to eth2.
Such a configuration wouldn't work at all with such a switch, because
the CPU isn't able to tell apart traffic from port1 and port2, and
there's no way to tell the switch that port1.4 and port2.4 should not be
connected to each other, but both should go to the CPU.

Those are just two simple scenarios from the top of my head - I'm pretty
sure I could come up with a long list of further corner cases and
quirks, which are simply either difficult to deal with, or completely
unnatural in the model that you're describing.

Trying to make all of these cases work in the code will make the whole
thing a lot more difficult to deal with and maintain. It will also make
it much harder for the user to figure out, what configurations work, and
what configurations don't.

Especially the case with reusing VLANs on different ports (but not
connecting them to each other) is something that can easily work with
software devices, but cannot be emulated on most embedded device
switches. The software bridge configuration model raises a lot of
expectations that these switches simply cannot meet.

If you look at the swconfig model, you will see that the abstraction
clearly communicates the limitations of these typical switches.

The configuration model simply doesn't even let you express these kinds
of unsuppported configurations that seem normal in the tools used to set
up software bridges/vlans.
At the same time, it's fairly consistent across the range of different
chips that we have drivers for. That certainly leaves a much smaller
amount of traps and surprises for users, compared to trying to emulate
the software bridge model by hacking through the layers.

Hopefully this will clear a few things up for you.

- Felix
