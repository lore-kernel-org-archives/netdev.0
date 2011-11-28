From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: Open vSwitch Design
Date: Mon, 28 Nov 2011 17:42:51 -0500
Message-ID: <1322520171.6118.29.camel@mojatatu>
References: <CAEP_g=_2L1xFWtDXh_6YyXz1Mt9TR3zvjLzix+SpO6yzeOLsSQ@mail.gmail.com>
	 <1322173833.1944.5.camel@mojatatu>
	 <20111124212021.2ae2fb7f@s6510.linuxnetplumber.net>
	 <2DB44B16-598F-4414-8B35-8E322D705A9A@nicira.com>
	 <1322269906.7338.23.camel@mojatatu>
	 <06FA64A0-9CCF-4621-9DE6-61A6B37B925F@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Jesse Gross <jesse@nicira.com>,
	netdev <netdev@vger.kernel.org>, dev@openvswitch.org,
	David Miller <davem@davemloft.net>,
	Chris Wright <chrisw@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>
To: Justin Pettit <jpettit@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:64703 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753945Ab1K1Wmz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2011 17:42:55 -0500
Received: by qyk4 with SMTP id 4so1286847qyk.19
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2011 14:42:54 -0800 (PST)
In-Reply-To: <06FA64A0-9CCF-4621-9DE6-61A6B37B925F@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-11-28 at 10:34 -0800, Justin Pettit wrote:
> On Nov 25, 2011, at 5:11 PM, Jamal Hadi Salim wrote:

> 
> Are you talking about ASICs on NICs?  

I am indifferent - looking at it entirely from a control
perspective. i.e if i do "ip link blah down" on a port
i want that to work with zero changes to iproute2; the only
way you can achieve that is if you expose those ports as
netdevs.
This is what I said was a good thing the Intel folks were trying to
achieve (and what Lennert has done for the small Marvel switch chips).

> I was referring to integrating Open vSwitch into top-of-rack switches.  
> These typically have a 48x1G or 48x10G switching ASIC and a relatively 
> slow (~800MHz PPC-class) management CPU running an operating system like 
> Linux.  There's no way that these systems can have a standard CPU on the fastpath.

No, not the datapath; just control of the hardware.  If i run
"ip route add .." i want that to work on the ASIC.
Same with tc action/classification. I want to run those tools and
configure an ACL in the ASIC with no new learning curve.

> 
> I understood the original question to be: Can we make the interface to the 
> kernel look like a hardware switch?  My answer had two main parts.  First, 
> I don't think we could define a "standard" hardware interface, since they're
> all very different.  Second, even if we could, I think a software fastpath's
> strengths and weaknesses are such that the hardware model wouldn't be ideal.

Not talking about datapath - but control interface to those devices.
We cant define how the low levels look like. But if you expose things
using standard linux interfaces, then user space tools and APIs stay
unchanged.

Then i shouldnt care where the feature runs (hardware NIC, ASIC, pure
kernel level software etc).

> 
> The problem is that DRAM isn't going to cut it on the ACL tables--which are 
> typically used for flow-based matching--on a 48x10G (or even 48x1G) switch.

There are vendors who use DRAMS with speacilized interfaces that
interleave requests behind the scenes. Maybe i can point you to one
offline. 

> I've seen a couple of switching ASICs that support many 10s of thousands of
> ACL entries, but they require expensive external TCAMs for lookup and SRAM 
> for counters.  Most of the white box vendors that I've seen that use those 
> ASICs don't bother adding the external TCAM and SRAM to their designs.  
> Even when they are added, their matching capabilities are typically limited 
> in order to keep up with traffic.

I thought SRAM markets have dried up these days. Anyways what you are
refereing to above is generally true.

> > Justin - theres nothing new you need in the kernel to have that feature.
> > Let me rephrase that, that has not been a new feature for at least a
> > decade in Linux.
> > Add exact match filters with higher priority. Have the lowest priority
> > filter to redirect to user space. Let user space lookup some service
> > rule; have it download to the kernel one or more exact matches.
> > Let the packet proceed on its way down the kernel to its destination if
> > thats what is defined.
> 
> My point was that a software fastpath should look different than a hardware-based one.

And i was pointing  to what your datapath patches which in conjunction
with your user space code.

> > 
> > That bit sounds interesting - I will look at your spec.
> 
> Great!

I am sorry - been overloaded elsewhere havent looked. But i think above
I pretty much spelt out what my desires are.


> Yes, Open vSwitch has been ported to 24x10G ASICs running Linux on their management CPUs.  
> However, in these cases the datapath is handled by hardware and not the software forwarding 
> plane, obviously.

Of course.

> > Do the vendors agree to some common interface?
> 
> Yes, if you view ofproto (as described in the porting guide) as that interface.  Every merchant silicon vendor 
> I've seen views the interfaces to their ASICs as proprietary.  

Yes, the XAL agony (HALS and PALS that run on 26 other OSes).

> Someone (with the appropriate SDK and licenses) needs to write providers for those different hardware ports.  
> We've helped multiple vendors do this and know a few others that have done it on their own.

You know what would be really nice is if you achieved what i described
above.
Can I ifconfig an ethernet switch port?

> This really seems besides the point for this discussion, though.  
> We've written an ofproto provider for software switches called "dpif" 
> (this is also described in the porting guide). What we're proposing be 
> included in Linux is the kernel module that speaks to that dpif provider 
> over a well-defined, stable, netlink-based protocol.
> 
> Here's just a quick (somewhat simplified) summary of the different layers. 
> At the top, there are controllers and switches that communicate using OpenFlow.
> OpenFlow gives controller writers the ability to inspect and modify the switches' 
> flow tables and interfaces.  If a flow entry doesn't match an existing entry, the 
> packet is forwarded to the controller for further processing.  OpenFlow 1.0 was 
> pretty basic and exposed a single flow table.  OpenFlow 1.1 introduced a number 
> of new features including multiple table support.  The forthcoming OpenFlow 1.2 
> will include support for extensible matches, which means that new fields may be 
> added without requiring a full revision of the specification.  OpenFlow is defined 
> by the Open Networking Foundation and is not directly related to Open vSwitch.
> 
> The userspace in Open vSwitch has an OpenFlow library that interacts with the 
> controllers.  Userspace has its own classifier that supports wildcard entries 
> and multiple tables.  Many of the changes to the OpenFlow protocol only require 
> modifying that library and perhaps some of the glue code with the classifier.  
> (In theory, other software-defined networking protocols could be plugged in as well.)  
> The classifier interacts with the ofproto layer below it, which implements a fastpath.

Yes, when i looked at your code i can see that you have gone past
openflow.

> On a hardware switch, since it supports wildcarding, it essentially becomes a 
> passthrough that just calls the appropriate APIs for the ASIC.  

Are these APIs documented as well? Maybe thats all we need if you dont
have the standard linux tools working.

> On software, 
> as we've discussed, exact-match flows work better.
> 
> For that reason, we've defined the dpif layer, which is an ofproto provider.  
> It's primary purpose is to take high-level concepts like "treat this group of 
> interfaces as a LACP bond" or "support this set of wildcard flow entries" and 
> explode them into exact-match entries on-demand.  We've then implemented a 
> Linux dpif provider that takes the exact match entries created by the dpif 
> layer and converts them into netlink messages that the kernel module understands.  
> These messages are well-defined and not specific to Open vSwitch or OpenFlow.

Useful but that seems more like a service layer - I want just to be able
to ifconfig a port as a basic need.
In any case, I should look at your doc to get some clarity.

> This layering has allowed us to introduce new OpenFlow-like features such as multiple tables 
> and non-OpenFlow features such as port mirroring, STP, CCM, and new bonding modes without 
> changes to the kernel module.  In fact, the only changes that should necessitate a kernel 
> interface change are new matches or actions, such as would be required for handling MPLS.

I just need the basic cobbling blocks.
If you conform to what Linux already does and i can run standard tools,
we can have a lot of creative things that could be done.


> > Make these vendor switches work with plain Linux. The Intel folks are
> > producing interfaces with L2, ACLs, VIs and are putting some effort to
> > integrate them into plain Linux. I should be able to set the qos rules
> > with tc on an intel chip.
> > You guys can still take advantage of all that and still have your nice
> > control plane.
> 
> Once again, I think we are talking about different things.  I believe you are 
> discussing interfacing with NICs, which is quite different from a high fanout 
> switching ASIC.  As I previously mentioned, the point of my original 

> post was that I think it would be best not to model a high fanout switch in the interface to the kernel.
> 

I hope my clarification above makes more sense.

cheers,
jamal
