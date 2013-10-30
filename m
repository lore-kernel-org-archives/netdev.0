From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 1/4 net-next] net: phy: add Generic Netlink Ethernet switch
 configuration API
Date: Wed, 30 Oct 2013 07:45:37 -0400
Message-ID: <5270F161.80603@mojatatu.com>
References: <1382466229-15123-1-git-send-email-f.fainelli@gmail.com> <1382466229-15123-2-git-send-email-f.fainelli@gmail.com> <5266D7D6.9000309@intel.com> <CAGVrzcZS4SGiUFoCnhau1Fvv9F4ffS7tA+PT4r-qLCj8HV8BqQ@mail.gmail.com> <20131022202537.GA16336@hmsreliant.think-freely.org> <CAGVrzcaXFboRDn40+VciTes09w-jqTASNZz2GZNpTxbaV6D0Lw@mail.gmail.com> <5267B764.305@mojatatu.com> <5267BB53.8030703@openwrt.org> <5267C6B9.4000704@mojatatu.com> <5267CFAB.9090100@openwrt.org> <5267D8AE.7080009@mojatatu.com> <5267DDE6.70600@openwrt.org> <526A5949.6040404@mojatatu.com> <526A6BB3.7050507@openwrt.org> <526D4B06.8040505@mojatatu.com> <526D6EBA.3020903@openwrt.org> <526EEAE9.6090508@mojatatu.com> <526F8118.50909@openwrt.org>
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
	Stephen Hemminger <stephen@networkplumber.org>
To: Felix Fietkau <nbd@openwrt.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:43500 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753925Ab3J3Lpk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 07:45:40 -0400
Received: by mail-ie0-f176.google.com with SMTP id u16so1974571iet.21
        for <netdev@vger.kernel.org>; Wed, 30 Oct 2013 04:45:39 -0700 (PDT)
In-Reply-To: <526F8118.50909@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/29/13 05:34, Felix Fietkau wrote:
> On 2013-10-28 23:53, Jamal Hadi Salim wrote:

>
> These are simple switches, why would they respond to ARP?
> I suspect that you're attributing too much functionality to the switch
> itself. Think of it as a device similar to the cheap unmanaged ones you
> can buy in a shop and hook up to your machine via Ethernet.
> Add to that some very limited VLAN grouping functionality, and you're
> pretty close to the limits of what these switches can do.
> They don't do ARP, IP or other things. They learn about MAC addresses
> from incoming packets to build their forwarding path.
> The CPU port in this case is whatever port on the switch that you plug
> the cable of your machine into :)

Ok, got it - the only use for cpu for these things is to retrieve things
like stats, link state, etc; can you even read the fdb?


> The FDB related abstraction that you're describing will not work with
> the hardware that I'm talking about. Let's leave that one out of this
> discussion.

sigh - ok. But you gotta help me understand why.

> As for per-port netdevs: Yes, you could pull stats.
> No, flow control messages would not make it through.
> No idea how it would provide a *consistent* API.
> Either way, if adding netdevs just for stats and link state, that could
> be easily added on top of swconfig (or whatever name we pick for it)
> later. I just don't think it's worth it at this point.
>

Ok, progress, lets leave this one out.

>> Can we call that "L3" instead of software bridge?
> L3? Why?

We have two L2 domains. You want to connect them - you need a higher
layer; Layer 3 seems to be the simple one (i.e typically people would
use ip to link two layer 2 broadcast domains).


> I think that's way more confusing to users than presenting a consistent
> model that properly reflects what you can do with the hardware.
>

I think discovery from a control view is always a win.

> But I sense a pattern here. I've long had my beef with quite a few Linux
> network related APIs for being inconsistent, having no decent error
> reporting when you're trying to configure things (errno doesn't count,
> it's just too ambiguous), and just making it hard to figure out the
> capabilities. Of course, none of this can be easily fixed due to ABI
> stability constraints.
> I do NOT wish to follow that pattern!
>

You are preaching to the choir. The whole errno 8 bit thing is a mess;
I used to printk things in the kernel to indicate granularity of
which EINVAL i was returning (but i was shot down); one suggestion is
to also include a string description on the error. But that is a side
issue.
So, nod. Discovery of capabilities is better - you still have to defer
to error codes when all else fails.


> I'm not going to try to enumerate all the case; I have other projects
> that I need to work on. :)
>

I understand. I am busy as well, just saying if we need to reach an
agreement to either agree or disagree we need to capture the esoterics
of the different cases; as you can see i tried to enumerate some in
my previous email. In my case this would be useful to see, using current
mechanisms, that it can or cant be done or can be done with mods etc.

> Only a *tiny* part of the software bridge configuration model can be
> emulated, the rest does not fit and has to be handled through extensions
> or different APIs anyway. That's why I am convinced that it's a really
> bad model to try to make these switches fit into it.
>
> You gain a tiny advantage with writing scripts, but at the same time,
> the code gets more complex, the configuration interface gets more
> confusing, there are more nasty corner cases to take care of.
> Why do you insist on making so many things worse just for one tiny
> advantage? Where's the pragmatic cost/benefit tradeoff?
>

There is nothing wrong with making extensions if they make sense. My
problem so far in this discussion is i havent figured which will be bad
extensions you bring up. My approach is to list things and
then point out which one will require some witchcraft on top of
current interfaces. I am afraid I am still missing that part. Maybe
I have to go back and study your patch some more.

> Right, with most of the switches that we support, almost none of these
> things work in a way that can be integrated with the network stack.
>

Good to know. These are useful components for slightly higher end
switches.


> I'm not even sure what you mean when you say 'cpu port cannot be
> assumed'.

Meant for other devices which are dumb - lets move past this point.

> On pretty much all devices that we work with, one of the ports
> connects to a NIC in the CPU. It's just that the switch cannot be
> assumed to have special treatment for that CPU port. As far as it is
> concerned, it is just another port like the others.
>

Aha. I think i see a small terminology cross-talk. You refer to things
as NICs when i use the term netdev. So now i understand better what you
mean by rx handler (I intepreted earlier to mean something at the tap
level). Ok, so Felix, for the case where we have switches with cpu ports
that can tag incoming packets with ingress port ids - can we say the
NIC rx handler is reasonable to be used as a demux point for the
software version of the ports? I am not talking about the corner
cases.

>> - ive never seen table id, but i think this is another one; in which
>> case the number of table ids becomes something one needs to discover..
> Yes, and this is something that doesn't even map directly to something
> in the software bridge world.
>

It does - There is a single table per bridge on the software bridge
world. You need multiple bridges, one per id.

cheers,
jamal
