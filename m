From: Justin Pettit <jpettit-l0M0P4e3n4LQT0dZR+AlfA@public.gmane.org>
Subject: Re: Open vSwitch Design
Date: Mon, 28 Nov 2011 10:34:49 -0800
Message-ID: <06FA64A0-9CCF-4621-9DE6-61A6B37B925F@nicira.com>
References: <CAEP_g=_2L1xFWtDXh_6YyXz1Mt9TR3zvjLzix+SpO6yzeOLsSQ@mail.gmail.com>
	<1322173833.1944.5.camel@mojatatu>
	<20111124212021.2ae2fb7f@s6510.linuxnetplumber.net>
	<2DB44B16-598F-4414-8B35-8E322D705A9A@nicira.com>
	<1322269906.7338.23.camel@mojatatu>
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, Chris Wright <chrisw-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>,
	Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	John Fastabend <john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Stephen Hemminger <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Jamal Hadi Salim <jhs-jkUAjuhPggJWk0Htik3J/w@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
In-Reply-To: <1322269906.7338.23.camel@mojatatu>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
	<mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Sender: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
List-Id: netdev.vger.kernel.org

On Nov 25, 2011, at 5:11 PM, Jamal Hadi Salim wrote:

>> A big difficulty is finding an appropriate hardware abstraction.  I've worked on porting 
>> Open vSwitch to a few different vendors' switching ASICs, and they've all looked quite 
>> different from each other.  Even within a vendor, there can be fairly substantial differences.  
>> Packet processing is broken up into stages (e.g., VLAN preprocessing, ingress ACL processing, 
>> L2 lookup, L3 lookup, packet modification, packet queuing, packet replication, egress ACL 
>> processing, etc.)
>> and these can be done in different orders and have quite different behaviors.
> 
> Theres some discussion going on on how to get ASIC support on the
> variety of chips with different offloads (qos, L2 etc); you may wanna
> share your experiences.

Are you talking about ASICs on NICs?  I was referring to integrating Open vSwitch into top-of-rack switches.  These typically have a 48x1G or 48x10G switching ASIC and a relatively slow (~800MHz PPC-class) management CPU running an operating system like Linux.  There's no way that these systems can have a standard CPU on the fastpath.

> Having said that - in the kernel we have all the mechanisms you describe
> above with quiet a good fit. Speaking from experience of working on some
> vendors ASICs (of which i am sure at least one you are working on).
> As an example, the ACL can be applied before or after L2 or L3. We can
> support wildcard matching to user space and exact-matches in the kernel.

I understood the original question to be: Can we make the interface to the kernel look like a hardware switch?  My answer had two main parts.  First, I don't think we could define a "standard" hardware interface, since they're all very different.  Second, even if we could, I think a software fastpath's strengths and weaknesses are such that the hardware model wouldn't be ideal.

>> Also, the size of the various tables varies widely between ASICs--even within the same 
>> family.
>> 
>> Hardware typically makes use of TCAMs, which support fast lookups of wildcarded flows.
>> They're expensive, though, so they're typically limited to entries in the very low thousands.
> 
> Those are problems with most merchant silicon - small tables; but there
> are some which are easily expandable via DRAM to support a full BGP
> table for example.

The problem is that DRAM isn't going to cut it on the ACL tables--which are typically used for flow-based matching--on a 48x10G (or even 48x1G) switch.  I've seen a couple of switching ASICs that support many 10s of thousands of ACL entries, but they require expensive external TCAMs for lookup and SRAM for counters.  Most of the white box vendors that I've seen that use those ASICs don't bother adding the external TCAM and SRAM to their designs.  Even when they are added, their matching capabilities are typically limited in order to keep up with traffic.

>> In software, we can trivially store 100,000s of entries, but supporting wildcarded lookups 
>> is very slow.  If we only use exact-match flows in the kernel (and leave the wildcarding 
>> in userspace for kernel misses), we can do extremely fast lookups with hashing on what 
>> becomes the fastpath.
> 
> Justin - theres nothing new you need in the kernel to have that feature.
> Let me rephrase that, that has not been a new feature for at least a
> decade in Linux.
> Add exact match filters with higher priority. Have the lowest priority
> filter to redirect to user space. Let user space lookup some service
> rule; have it download to the kernel one or more exact matches.
> Let the packet proceed on its way down the kernel to its destination if
> thats what is defined.

My point was that a software fastpath should look different than a hardware-based one.

>> Using exact-match entries has another big advantage: we can innovate the userspace portion 
>> without requiring changes to the kernel.  For example, we recently went from supporting a 
>> single OpenFlow table to 255 without any kernel changes.  This has an added benefit that 
>> a flow requiring multiple table lookups becomes a single hash lookup in the kernel, which
>> is a huge performance gain in the fastpath.  Another example is our introduction of a number
>> of metadata "registers" between tables that are never seen in the kernel, but open up a lot 
>> of interesting applications for OpenFlow controller writers.
> 
> That bit sounds interesting - I will look at your spec.

Great!

>> If you're interested, we include a porting guide in the distribution that describes how one 
>> would go about bringing Open vSwitch to a new hardware or software platform:
>> 
>> 	http://openvswitch.org/cgi-bin/gitweb.cgi?p=openvswitch;a=blob;f=PORTING
>> 
>> Obviously, it's not that relevant here, since there's already a port to Linux.  :-)  
> 
> Does this mean i can have a 24x10G switch sitting in hardware with Linux
> hardware support if i use your kernel switch? 

Yes, Open vSwitch has been ported to 24x10G ASICs running Linux on their management CPUs.  However, in these cases the datapath is handled by hardware and not the software forwarding plane, obviously.

> Do the vendors agree to some common interface?

Yes, if you view ofproto (as described in the porting guide) as that interface.  Every merchant silicon vendor I've seen views the interfaces to their ASICs as proprietary.  Someone (with the appropriate SDK and licenses) needs to write providers for those different hardware ports.  We've helped multiple vendors do this and know a few others that have done it on their own.

This really seems besides the point for this discussion, though.  We've written an ofproto provider for software switches called "dpif" (this is also described in the porting guide). What we're proposing be included in Linux is the kernel module that speaks to that dpif provider over a well-defined, stable, netlink-based protocol.

Here's just a quick (somewhat simplified) summary of the different layers.  At the top, there are controllers and switches that communicate using OpenFlow.  OpenFlow gives controller writers the ability to inspect and modify the switches' flow tables and interfaces.  If a flow entry doesn't match an existing entry, the packet is forwarded to the controller for further processing.  OpenFlow 1.0 was pretty basic and exposed a single flow table.  OpenFlow 1.1 introduced a number of new features including multiple table support.  The forthcoming OpenFlow 1.2 will include support for extensible matches, which means that new fields may be added without requiring a full revision of the specification.  OpenFlow is defined by the Open Networking Foundation and is not directly related to Open vSwitc
 h.

The userspace in Open vSwitch has an OpenFlow library that interacts with the controllers.  Userspace has its own classifier that supports wildcard entries and multiple tables.  Many of the changes to the OpenFlow protocol only require modifying that library and perhaps some of the glue code with the classifier.  (In theory, other software-defined networking protocols could be plugged in as well.)  The classifier interacts with the ofproto layer below it, which implements a fastpath.  On a hardware switch, since it supports wildcarding, it essentially becomes a passthrough that just calls the appropriate APIs for the ASIC.  On software, as we've discussed, exact-match flows work better.

For that reason, we've defined the dpif layer, which is an ofproto provider.  It's primary purpose is to take high-level concepts like "treat this group of interfaces as a LACP bond" or "support this set of wildcard flow entries" and explode them into exact-match entries on-demand.  We've then implemented a Linux dpif provider that takes the exact match entries created by the dpif layer and converts them into netlink messages that the kernel module understands.  These messages are well-defined and not specific to Open vSwitch or OpenFlow.

This layering has allowed us to introduce new OpenFlow-like features such as multiple tables and non-OpenFlow features such as port mirroring, STP, CCM, and new bonding modes without changes to the kernel module.  In fact, the only changes that should necessitate a kernel interface change are new matches or actions, such as would be required for handling MPLS.

>> But we've 
>> iterated over a few different designs and worked on other ports, and we've found this 
>> hardware/software abstraction layer to work pretty well.  In fact, multiple ports of 
>> Open vSwitch have been done by name-brand third party vendors (this is the avenue most
>> vendors use to get their OpenFlow support) and are now shipping.
>> 
>> We're always open to discussing ways that we can improve this interfaces, too, of course!
> 
> Make these vendor switches work with plain Linux. The Intel folks are
> producing interfaces with L2, ACLs, VIs and are putting some effort to
> integrate them into plain Linux. I should be able to set the qos rules
> with tc on an intel chip.
> You guys can still take advantage of all that and still have your nice
> control plane.

Once again, I think we are talking about different things.  I believe you are discussing interfacing with NICs, which is quite different from a high fanout switching ASIC.  As I previously mentioned, the point of my original post was that I think it would be best not to model a high fanout switch in the interface to the kernel.

--Justin
