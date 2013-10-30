From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet switch
 configuration API
Date: Wed, 30 Oct 2013 13:53:59 +0100
Message-ID: <52710167.20604@openwrt.org>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com> <1382466229-15123-2-git-send-email-f.fainelli@gmail.com> <5266D7D6.9000309@intel.com> <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com> <20131022202537.GA16336@hmsreliant.think-freely.org> <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com> <5267B764.305@mojatatu.com> <5267BB53.8030703@openwrt.org> <5267C6B9.4000704@mojatatu.com> <5267CFAB.9090100@openwrt.org> <5267D8AE.7080009@mojatatu.com> <5267DDE6.70600@openwrt.org> <526A5949.6040404@mojatatu.com> <526A6BB3.7050507@openwrt.org> <526D4B06.8040505@mojatatu.com> <526D6EBA.3020903@openwrt.org> <526EEAE9.6090508@mojatatu.com> <526F8118.50909@openwrt.org> <5270F161.80603@mojatatu.com>
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
Received: from nbd.name ([46.4.11.11]:44792 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751666Ab3J3MyN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Oct 2013 08:54:13 -0400
In-Reply-To: <5270F161.80603@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-10-30 12:45, Jamal Hadi Salim wrote:
> On 10/29/13 05:34, Felix Fietkau wrote:
>> On 2013-10-28 23:53, Jamal Hadi Salim wrote:
> 
>>
>> These are simple switches, why would they respond to ARP?
>> I suspect that you're attributing too much functionality to the switch
>> itself. Think of it as a device similar to the cheap unmanaged ones you
>> can buy in a shop and hook up to your machine via Ethernet.
>> Add to that some very limited VLAN grouping functionality, and you're
>> pretty close to the limits of what these switches can do.
>> They don't do ARP, IP or other things. They learn about MAC addresses
>> from incoming packets to build their forwarding path.
>> The CPU port in this case is whatever port on the switch that you plug
>> the cable of your machine into :)
> 
> Ok, got it - the only use for cpu for these things is to retrieve things
> like stats, link state, etc; can you even read the fdb?
Where supported, all you can typically read is a list of which MAC
address was discovered behind which port - if you're lucky. You usually
won't find VLAN information attached to that.
Often it simply isn't supported at all.

>> The FDB related abstraction that you're describing will not work with
>> the hardware that I'm talking about. Let's leave that one out of this
>> discussion.
> 
> sigh - ok. But you gotta help me understand why.
The hardware implementation of MAC address handling isn't even
consistent across chips from different vendors. Often you don't even get
things like the VLAN ID. Sometimes there's a global forwarding table,
sometimes you can have multiple tables and assign them to VLANs.

>>> Can we call that "L3" instead of software bridge?
>> L3? Why?
> 
> We have two L2 domains. You want to connect them - you need a higher
> layer; Layer 3 seems to be the simple one (i.e typically people would
> use ip to link two layer 2 broadcast domains).
If you connect two L2 domains through a bridge, I still consider that L2
- it's still on the same layer, just goes through more hops.

>> I think that's way more confusing to users than presenting a consistent
>> model that properly reflects what you can do with the hardware.
> I think discovery from a control view is always a win.
Yes, and swconfig handles the discovery part fairly well.

>> I'm not going to try to enumerate all the case; I have other projects
>> that I need to work on. :)
> 
> I understand. I am busy as well, just saying if we need to reach an
> agreement to either agree or disagree we need to capture the esoterics
> of the different cases; as you can see i tried to enumerate some in
> my previous email. In my case this would be useful to see, using current
> mechanisms, that it can or cant be done or can be done with mods etc.
At this point, I'm not sure if we will be able to reach an agreement. I
think I've shown over and over again that what you're proposing comes
with huge costs in terms of complexity and bloat, as demonstrated by the
fact that it adds so many corner cases that would have to be dealt with,
including many for which we haven't even the slightest idea of a good
solution.
Now, to make this a viable option, the benefits would have to be big and
significant enough to offset these costs.
The only real benefit you've pointed out so far is to be able to reuse
existing tools/APIs (but only with modifications, not as-is). I think
that's fairly small, when put in perspective with the hard problems that
this approach creates, both for users (hidden traps and surprises) and
for developers (implementation difficulties and incompatible abstractions).

>> Only a *tiny* part of the software bridge configuration model can be
>> emulated, the rest does not fit and has to be handled through extensions
>> or different APIs anyway. That's why I am convinced that it's a really
>> bad model to try to make these switches fit into it.
>>
>> You gain a tiny advantage with writing scripts, but at the same time,
>> the code gets more complex, the configuration interface gets more
>> confusing, there are more nasty corner cases to take care of.
>> Why do you insist on making so many things worse just for one tiny
>> advantage? Where's the pragmatic cost/benefit tradeoff?
>>
> 
> There is nothing wrong with making extensions if they make sense.
Yes, but if the basic abstraction doesn't make sense for the use case,
and it leads to too many corner cases, there's everything wrong with
trying to work around that through extensions.

> My problem so far in this discussion is i havent figured which will be bad
> extensions you bring up. My approach is to list things and
> then point out which one will require some witchcraft on top of
> current interfaces. I am afraid I am still missing that part. Maybe
> I have to go back and study your patch some more.
Sure, go ahead.

>> On pretty much all devices that we work with, one of the ports
>> connects to a NIC in the CPU. It's just that the switch cannot be
>> assumed to have special treatment for that CPU port. As far as it is
>> concerned, it is just another port like the others.
> 
> Aha. I think i see a small terminology cross-talk. You refer to things
> as NICs when i use the term netdev. So now i understand better what you
> mean by rx handler (I intepreted earlier to mean something at the tap
> level). 
I only started using the term NIC to emphasize that it's not just a
netdev of the switch - it's a real Ethernet MAC (usually in the SoC),
with a separate driver that knows nothing about the switch.

> Ok, so Felix, for the case where we have switches with cpu ports
> that can tag incoming packets with ingress port ids - can we say the
> NIC rx handler is reasonable to be used as a demux point for the
> software version of the ports? I am not talking about the corner
> cases.
Yes, but when looking at the big picture, the switch being able to tag
incoming packets with the ingress port is a corner case!
Most switches that we work with aren't actually able to do that!
I want to have a decent baseline implementation that does not assume
this port tagging capability.

>>> - ive never seen table id, but i think this is another one; in which
>>> case the number of table ids becomes something one needs to discover..
>> Yes, and this is something that doesn't even map directly to something
>> in the software bridge world.
> It does - There is a single table per bridge on the software bridge
> world. You need multiple bridges, one per id.
Depends on which software bridge.
If I have two normal netdevs, eth0 and eth1, I can create eth0.4 and
bridge it to eth1.5. That's just one bridge.
I can't easily emulate that with fake per-port netdevs and a typical
switch supported by swconfig.
With just swconfig (no fake netdevs) switches that support these table
ids, I would need to have two VLANs in the switch (both connected to the
CPU port, each one getting a separate table id), and then one software
bridge between eth0.4 and eth0.5 (assuming eth0 connects to the switch).

- Felix
