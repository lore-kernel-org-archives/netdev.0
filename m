From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: Flows! Offload them.
Date: Thu, 26 Feb 2015 07:23:36 -0800
Message-ID: <54EF3A78.9020507@intel.com>
References: <20150226074214.GF2074@nanopsycho.orion> <20150226083758.GA15139@vergenet.net> <20150226091628.GA4059@nanopsycho.orion> <20150226133326.GC23050@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <simon.horman@netronome.com>, netdev@vger.kernel.org,
	davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	jpettit@nicira.com, joestringer@nicira.com, jhs@mojatatu.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, shrijeet@gmail.com,
	gospo@cumulusnetworks.com, bcrl@kvack.org
To: Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:63561 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753864AbbBZPZH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 10:25:07 -0500
In-Reply-To: <20150226133326.GC23050@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2015 05:33 AM, Thomas Graf wrote:
> On 02/26/15 at 10:16am, Jiri Pirko wrote:
>> Well, on netdev01, I believe that a consensus was reached that for every
>> switch offloaded functionality there has to be an implementation in
>> kernel.
> 
> Agreed. This should not prevent the policy being driven from user
> space though.
> 
>> What John's Flow API originally did was to provide a way to
>> configure hardware independently of kernel. So the right way is to
>> configure kernel and, if hw allows it, to offload the configuration to hw.
>>
>> In this case, seems to me logical to offload from one place, that being
>> TC. The reason is, as I stated above, the possible conversion from OVS
>> datapath to TC.
> 
> Offloading of TC definitely makes a lot of sense. I think that even in
> that case you will already encounter independent configuration of
> hardware and kernel. Example: The hardware provides a fixed, generic
> function to push up to n bytes onto a packet. This hardware function
> could be used to implement TC actions "push_vlan", "push_vxlan",
> "push_mpls". You would you would likely agree that TC should make use
> of such a function even if the hardware version is different from the
> software version. So I don't think we'll have a 1:1 mapping for all
> configurations, regardless of whether the how is decided in kernel or
> user space.

Just to expand slightly on this. I don't think you can get to a 1:1
mapping here. One reason is hardware typically has a TCAM and limited
size. So you need a _policy_ to determine when to push rules into the
hardware. The kernel doesn't know when to do this and I don't believe
its the kernel's place to start enforcing policy like this. One thing I likely
need to do is get some more "worlds" in rocker so we aren't stuck only
thinking about the infinite size OF_DPA world. The OF_DPA world is only
one world and not a terribly flexible one at that when compared with the
NPU folk. So minimally you need a flag to indicate rules go into hardware
vs software.

That said I think the bigger mismatch between software and hardware is
you program it differently because the data structures are different. Maybe
a u32 example would help. For parsing with u32 you might build a parse
graph with a root and some leaf nodes. In hardware you want to collapse
this down onto the hardware. I argue this is not a kernel task because
there are lots of ways to do this and there are trade-offs made with
respect to space and performance and which table to use when it could be
handled by a set of tables. Another example is a virtual switch possibly
OVS but we have others. The software does some "unmasking" (there term)
before sending the rules into the software dataplane cache. Basically this
means we can ignore priority in the hash lookup. However this is not how you
would optimally use hardware. Maybe I should do another write up with
some more concrete examples.

There are also lots of use cases to _not_ have hardware and software in
sync. A flag allows this.

My only point is I think we need to allow users to optimally use there
hardware either via 'tc' or my previous 'flow' tool. Actually in my
opinion I still think its best to have both interfaces.

I'll go get some coffee now and hopefully that is somewhat clear.

> 
> My primiary concern of *only* allowing to decide how to program the
> hardware in the kernel is the lack of context; A given L3/L4 software
> pipeline in the Linux kernel consists of various subsystems: tc
> ingress, linux bridge, various iptables chains, routing rules, routing
> tables, tc egress, etc. All of them can be stacked in almost unlimited
> combinations using virtual software devices and segmented using
> net namespaces.
> 
> Given this complexity we'll most likely have to solve some of it with
> a flag to control offloading (as already introduced for bridging) and
> allow the user to shoot himself in the foot (as Jamal and others
> pointed out a couple of times). I currently don't see how the kernel
> could *always* get it right automatically. We need some additional
> input from the user (See also Patrick's comments regarding iptables
> offload)
> 
> However, for certain datacenter server use cases we actually have the
> full user intent in user space as we configure all of the kernel
> subsystems from a single central management agent running locally
> on the server (OpenStack, Kubernetes, Mesos, ...), i.e. we do know
> exactly what the user wants on the system as a whole. This intent is
> then split into small configuration pieces to configure iptables, tc,
> routes on multiple net namespaces (for example to implement VRF).
> 
> E.g. A VRF in software would make use of net namespaces which holds
> tenant specific ACLs, routes and QoS settings. A separate action
> would fwd packets to the namespace. Easy and straight forward in
> software. OTOH, the hardware, capable of implementing the ACLs,
> would also need to know about the tc action which selected the
> namespace when attempting to offload the ACL as it would otherwise
> ACLs to wrong packets.
> 
> I would love to have the possibility to make use of that rich intent
> avaiable in user space to program the hardware in combination with
> configuring the kernel.
> 
> Would love to hear your thoughts on this. I think we all share the same
> goal which is to have in-kernel drivers for chips which can perform
> advanced switching and support it natively with Linux and have it
> become the de-facto standard for both hardware switch management and
> compute servers.
> 
