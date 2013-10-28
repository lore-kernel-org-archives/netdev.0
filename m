From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet switch
 configuration API
Date: Mon, 28 Oct 2013 18:53:29 -0400
Message-ID: <526EEAE9.6090508@mojatatu.com>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com> <1382466229-15123-2-git-send-email-f.fainelli@gmail.com> <5266D7D6.9000309@intel.com> <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com> <20131022202537.GA16336@hmsreliant.think-freely.org> <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com> <5267B764.305@mojatatu.com> <5267BB53.8030703@openwrt.org> <5267C6B9.4000704@mojatatu.com> <5267CFAB.9090100@openwrt.org> <5267D8AE.7080009@mojatatu.com> <5267DDE6.70600@openwrt.org> <526A5949.6040404@mojatatu.com> <526A6BB3.7050507@openwrt.org> <526D4B06.8040505@mojatatu.com> <526D6EBA.3020903@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	John Crispin <blogic@openwrt.org>,
	Jonas Gorski <jogo@openwrt.org>,
	Gary Thomas <gary@mlbassoc.com>,
	Vlad Yasevich <vyasevic@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Lennert Buytenhek <buytenh@wantstofly.org>
To: Felix Fietkau <nbd@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qe0-f46.google.com ([209.85.128.46]:41462 "EHLO
	mail-qe0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755412Ab3J1Wxb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Oct 2013 18:53:31 -0400
Received: by mail-qe0-f46.google.com with SMTP id s14so4504322qeb.33
        for <netdev@vger.kernel.org>; Mon, 28 Oct 2013 15:53:31 -0700 (PDT)
In-Reply-To: <526D6EBA.3020903@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/13 15:51, Felix Fietkau wrote:
> On 2013-10-27 6:19 PM, Jamal Hadi Salim wrote:

> That question does not make any sense to me. Aside from low level
> control frames like pause frames for flow control, the switch has no
> need to send packets to the CPU port on its own.
> Remember what I told you about the switch being a *separate* entity from
> the NIC that connects it to the CPU.
>

I am assuming there is a MAC address which is identified to be that of a
switch. Something responds to ARP for example for that MAC. I think
you are  saying that for a certain class of switch chips, there is no
concept of "cpu port" - therefore there cannot be unicast from the
chip to the cpu.

> DSA does this, and last time I looked, it pushes *all* bridge traffic
> through the CPU, making it completely unusable for slower embedded CPUs.
>

I wasnt thinking DSA (rather some MIPS based embedded boards)- but now
that you bring it up, lets Cc Lennert.

> If I remember correctly, adding support 'bridge acceleration' was left
> as an exercise for the reader and never actually implemented.
>

 From talking to you, I realize there are things that are dumb and
cant be "accelerated". The scenarios so far have been for accelaration
(or to be correct: offloading).
And my contention is - this is a matter of capability discovery as
advertised by the driver and as used by the user tools.

> Sure, this could be fixed somehow, but even then the model and
> assumptions that DSA is built on simply don't work for some of the
> dumber switches that we support.
>

Agreed.

[.. content removed for brevity, dont think we have disagreements ..]


> One of the currently very common switches in many embedded devices is
> the RTL8366/RTL8367. It has some flexibility when it comes to
> configuring VLANs, and it's one of the few ones where you can configure
> a forwarding table for a VLAN (which spans multiple ports), which allows
> software bridging between multiple VLANs.
> However, what this switch does *not* support is adding a header/trailer
> to packets to indicate the originating port.
> This means that all per-port netdevs will be dummy ports which don't
> include the data path.
>

My view is that netdevs are still valuable even if only they get used 
for control path. Like you said earlier - you can still pull stats, flow 
control messages still make it through etc. They provide you
the consistent api to configure the switch above, ex:
If i was to use the FDB api for this switch as long as i can
abstract it in software as a bridge, I could send it a switch config
via its ops which says:
"I am giving you this entry with vland 400 for port 2, but i want you to
send it to the hardware not to your local entry"

> So let's say you have a configuration where you're using VLAN ID 4 on
> port 1, and you want to bridge it to VLAN ID 400 on port 2.
>
> Sounds easy enough, you can easily create a bridge that spans port1.4
> and port2.400. Except, this particular switch (like pretty much any
> other switch supported by swconfig) isn't actually able to handle such a
> configuration on its own.

Makes sense.
Let me point that even the Linux bridge cant handle this on its own
either.
You would need two bridges instantiated. The "cpu port" (we should call
it the "L3 port" really) is implicit in the case of the bridge i.e it
is the Linux network stack.
You would need to set the vlan filters on the bridge to strip the vlan
on egress of the first bridge etc ..

> It needs two VLAN configurations, with different forwarding table IDs,
> and then the software bridge on the CPU port needs to forward between
> the two different VLANs.
> To be able to handle such a configuration, the code would have to detect
> this kind of special case scenario, somehow hook itself via rx handler
> into the NIC connected to the CPU port and emulate that VLAN ID
> replacement behavior.
>


IMO: You dont need to muck with rx handler if you used bridge
abstraction. It becomes a config issue.

> With swconfig, you create two VLANs: VLAN 4, containing CPU and port1;
> VLAN 400, containing CPU and port2. You then create a software bridge
> between eth0.4 and eth0.400 (assuming eth0 is the NIC connected to the
> switch).
>

Can we call that "L3" instead of software bridge?
It can be done if you create a Linux bridge in software per L2 table id
in your chip. Then you attach the bridge ports.
A linux bridge of the sort, assuming there's a subnet per bridge is
configured thus:
bridge-tab1: link ports {eth0:vlan4, eth1:vlan4}, subnet 1
bridge-tab2: link ports {eth0:vlan400, eth1:vlan400}, subnet 2


> In a different scenario, the code would also have to detect
> configurations that the switch isn't able to handle, e.g.: bridging
> port1.4 to eth1 and port2.4 to eth2.
> Such a configuration wouldn't work at all with such a switch, because
> the CPU isn't able to tell apart traffic from port1 and port2, and
> there's no way to tell the switch that port1.4 and port2.4 should not be
> connected to each other, but both should go to the CPU.
>

Understood.
I think that discovery is a must - so you can apply different behavior
to different switches.
But you seem to have solved this already. Linux as is does not.
You can either have the driver tell you what it can/cant do or you
can attempt to fire and miss and get a return code that will tell
you that it cant achieve what you are asking it to do. I prefer the
former.

 >
> Those are just two simple scenarios from the top of my head - I'm pretty
> sure I could come up with a long list of further corner cases and
> quirks, which are simply either difficult to deal with, or completely
> unnatural in the model that you're describing.
>

I think these are the kind of things that need to be enumerated to come
to some conclusion.

> Trying to make all of these cases work in the code will make the whole
> thing a lot more difficult to deal with and maintain. It will also make
> it much harder for the user to figure out, what configurations work, and
> what configurations don't.
>
>
> Especially the case with reusing VLANs on different ports (but not
> connecting them to each other) is something that can easily work with
> software devices, but cannot be emulated on most embedded device
> switches. The software bridge configuration model raises a lot of
> expectations that these switches simply cannot meet.
>

I wouldnt expect every thing a software bridge does would be met by
a random switch.S/w bridge would be the super-set. But this is
not a new concept, example: Netdev itself is an abstraction - we have
USB, ethernet, wireless, variety of virtual interfaces etc.
Sometimes we dont even have the concept of a "link" in some of these
devices; infiniband would have a huge MAC address but i can still
use ifconfig on it etc.

> If you look at the swconfig model, you will see that the abstraction
> clearly communicates the limitations of these typical switches.
>

I will have to go back and look - but like i said earlier seems to me
you have solved this problem. Of the switch hardware i am familiar with
(high end pricey stuff), the capabilities tend to fall into the
following components:
-flooding control (i.e what should happen on destination failure)
-learning control (i.e what should happen on the source lookup failure)
(Ive seen knobs for "drop", "send to portX" where "X" could be cpu etc)
-fdb capacity
-whether it can do vlans, filtering pvids etc
-multicast snooping capability

To add to the above a few more based on talking to you:
- cpu port (in what ive come across this is always present, but
as you point out this cannot be assumed)
- ingress port tag (you point out that some cases this may never be
present even when the cpu port is present)
- ive never seen table id, but i think this is another one; in which
case the number of table ids becomes something one needs to discover..

cheers,
jamal

> The configuration model simply doesn't even let you express these kinds
> of unsuppported configurations that seem normal in the tools used to set
> up software bridges/vlans.
> At the same time, it's fairly consistent across the range of different
> chips that we have drivers for. That certainly leaves a much smaller
> amount of traps and surprises for users, compared to trying to emulate
> the software bridge model by hacking through the layers.
>
> Hopefully this will clear a few things up for you.
>
> - Felix
>
