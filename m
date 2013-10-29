From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet switch
 configuration API
Date: Tue, 29 Oct 2013 10:34:16 +0100
Message-ID: <526F8118.50909@openwrt.org>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com> <1382466229-15123-2-git-send-email-f.fainelli@gmail.com> <5266D7D6.9000309@intel.com> <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com> <20131022202537.GA16336@hmsreliant.think-freely.org> <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com> <5267B764.305@mojatatu.com> <5267BB53.8030703@openwrt.org> <5267C6B9.4000704@mojatatu.com> <5267CFAB.9090100@openwrt.org> <5267D8AE.7080009@mojatatu.com> <5267DDE6.70600@openwrt.org> <526A5949.6040404@mojatatu.com> <526A6BB3.7050507@openwrt.org> <526D4B06.8040505@mojatatu.com> <526D6EBA.3020903@openwrt.org> <526EEAE9.6090508@mojatatu.com>
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
Received: from nbd.name ([46.4.11.11]:37941 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751732Ab3J2Jeb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Oct 2013 05:34:31 -0400
In-Reply-To: <526EEAE9.6090508@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-10-28 23:53, Jamal Hadi Salim wrote:
> On 10/27/13 15:51, Felix Fietkau wrote:
>> On 2013-10-27 6:19 PM, Jamal Hadi Salim wrote:
> 
>> That question does not make any sense to me. Aside from low level
>> control frames like pause frames for flow control, the switch has no
>> need to send packets to the CPU port on its own.
>> Remember what I told you about the switch being a *separate* entity from
>> the NIC that connects it to the CPU.
>>
> 
> I am assuming there is a MAC address which is identified to be that of a
> switch. Something responds to ARP for example for that MAC. I think
> you are  saying that for a certain class of switch chips, there is no
> concept of "cpu port" - therefore there cannot be unicast from the
> chip to the cpu.
These are simple switches, why would they respond to ARP?
I suspect that you're attributing too much functionality to the switch
itself. Think of it as a device similar to the cheap unmanaged ones you
can buy in a shop and hook up to your machine via Ethernet.
Add to that some very limited VLAN grouping functionality, and you're
pretty close to the limits of what these switches can do.
They don't do ARP, IP or other things. They learn about MAC addresses
from incoming packets to build their forwarding path.
The CPU port in this case is whatever port on the switch that you plug
the cable of your machine into :)

>> One of the currently very common switches in many embedded devices is
>> the RTL8366/RTL8367. It has some flexibility when it comes to
>> configuring VLANs, and it's one of the few ones where you can configure
>> a forwarding table for a VLAN (which spans multiple ports), which allows
>> software bridging between multiple VLANs.
>> However, what this switch does *not* support is adding a header/trailer
>> to packets to indicate the originating port.
>> This means that all per-port netdevs will be dummy ports which don't
>> include the data path.
> 
> My view is that netdevs are still valuable even if only they get used 
> for control path. Like you said earlier - you can still pull stats, flow 
> control messages still make it through etc. They provide you
> the consistent api to configure the switch above, ex:
> If i was to use the FDB api for this switch as long as i can
> abstract it in software as a bridge, I could send it a switch config
> via its ops which says:
> "I am giving you this entry with vland 400 for port 2, but i want you to
> send it to the hardware not to your local entry"
The FDB related abstraction that you're describing will not work with
the hardware that I'm talking about. Let's leave that one out of this
discussion.
As for per-port netdevs: Yes, you could pull stats.
No, flow control messages would not make it through.
No idea how it would provide a *consistent* API.
Either way, if adding netdevs just for stats and link state, that could
be easily added on top of swconfig (or whatever name we pick for it)
later. I just don't think it's worth it at this point.

>> So let's say you have a configuration where you're using VLAN ID 4 on
>> port 1, and you want to bridge it to VLAN ID 400 on port 2.
>>
>> Sounds easy enough, you can easily create a bridge that spans port1.4
>> and port2.400. Except, this particular switch (like pretty much any
>> other switch supported by swconfig) isn't actually able to handle such a
>> configuration on its own.
> 
> Makes sense.
> Let me point that even the Linux bridge cant handle this on its own
> either.
> You would need two bridges instantiated. The "cpu port" (we should call
> it the "L3 port" really) is implicit in the case of the bridge i.e it
> is the Linux network stack.
> You would need to set the vlan filters on the bridge to strip the vlan
> on egress of the first bridge etc ..
> 
>> It needs two VLAN configurations, with different forwarding table IDs,
>> and then the software bridge on the CPU port needs to forward between
>> the two different VLANs.
>> To be able to handle such a configuration, the code would have to detect
>> this kind of special case scenario, somehow hook itself via rx handler
>> into the NIC connected to the CPU port and emulate that VLAN ID
>> replacement behavior.
> 
> IMO: You dont need to muck with rx handler if you used bridge
> abstraction. It becomes a config issue.
If we don't need to muck with an rx handler, how are packets intercepted
from the NIC that connects to the switch?
That NIC is run by a driver that knows nothing about switch stuff.

>> With swconfig, you create two VLANs: VLAN 4, containing CPU and port1;
>> VLAN 400, containing CPU and port2. You then create a software bridge
>> between eth0.4 and eth0.400 (assuming eth0 is the NIC connected to the
>> switch).
> 
> Can we call that "L3" instead of software bridge?
L3? Why?

> Understood.
> I think that discovery is a must - so you can apply different behavior
> to different switches.
> But you seem to have solved this already. Linux as is does not.
> You can either have the driver tell you what it can/cant do or you
> can attempt to fire and miss and get a return code that will tell
> you that it cant achieve what you are asking it to do. I prefer the
> former.
I think that's way more confusing to users than presenting a consistent
model that properly reflects what you can do with the hardware.

But I sense a pattern here. I've long had my beef with quite a few Linux
network related APIs for being inconsistent, having no decent error
reporting when you're trying to configure things (errno doesn't count,
it's just too ambiguous), and just making it hard to figure out the
capabilities. Of course, none of this can be easily fixed due to ABI
stability constraints.
I do NOT wish to follow that pattern!

>> Those are just two simple scenarios from the top of my head - I'm pretty
>> sure I could come up with a long list of further corner cases and
>> quirks, which are simply either difficult to deal with, or completely
>> unnatural in the model that you're describing.
> I think these are the kind of things that need to be enumerated to come
> to some conclusion.
I'm not going to try to enumerate all the case; I have other projects
that I need to work on. :)

>> Trying to make all of these cases work in the code will make the whole
>> thing a lot more difficult to deal with and maintain. It will also make
>> it much harder for the user to figure out, what configurations work, and
>> what configurations don't.
>>
>>
>> Especially the case with reusing VLANs on different ports (but not
>> connecting them to each other) is something that can easily work with
>> software devices, but cannot be emulated on most embedded device
>> switches. The software bridge configuration model raises a lot of
>> expectations that these switches simply cannot meet.
> I wouldnt expect every thing a software bridge does would be met by
> a random switch.S/w bridge would be the super-set. But this is
> not a new concept, example: Netdev itself is an abstraction - we have
> USB, ethernet, wireless, variety of virtual interfaces etc.
> Sometimes we dont even have the concept of a "link" in some of these
> devices; infiniband would have a huge MAC address but i can still
> use ifconfig on it etc.
Only a *tiny* part of the software bridge configuration model can be
emulated, the rest does not fit and has to be handled through extensions
or different APIs anyway. That's why I am convinced that it's a really
bad model to try to make these switches fit into it.

You gain a tiny advantage with writing scripts, but at the same time,
the code gets more complex, the configuration interface gets more
confusing, there are more nasty corner cases to take care of.
Why do you insist on making so many things worse just for one tiny
advantage? Where's the pragmatic cost/benefit tradeoff?

>> If you look at the swconfig model, you will see that the abstraction
>> clearly communicates the limitations of these typical switches.
>>
> 
> I will have to go back and look - but like i said earlier seems to me
> you have solved this problem. Of the switch hardware i am familiar with
> (high end pricey stuff), the capabilities tend to fall into the
> following components:
> -flooding control (i.e what should happen on destination failure)
> -learning control (i.e what should happen on the source lookup failure)
> (Ive seen knobs for "drop", "send to portX" where "X" could be cpu etc)
> -fdb capacity
> -whether it can do vlans, filtering pvids etc
> -multicast snooping capability
Right, with most of the switches that we support, almost none of these
things work in a way that can be integrated with the network stack.

> To add to the above a few more based on talking to you:
> - cpu port (in what ive come across this is always present, but
> as you point out this cannot be assumed)
I'm not even sure what you mean when you say 'cpu port cannot be
assumed'. On pretty much all devices that we work with, one of the ports
connects to a NIC in the CPU. It's just that the switch cannot be
assumed to have special treatment for that CPU port. As far as it is
concerned, it is just another port like the others.

> - ingress port tag (you point out that some cases this may never be
> present even when the cpu port is present)
> - ive never seen table id, but i think this is another one; in which
> case the number of table ids becomes something one needs to discover..
Yes, and this is something that doesn't even map directly to something
in the software bridge world.

- Felix
