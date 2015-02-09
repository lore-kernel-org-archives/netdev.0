From: David Ahern <dsahern@gmail.com>
Subject: Re: [RFC PATCH 00/29] net: VRF support
Date: Sun, 08 Feb 2015 17:36:05 -0700
Message-ID: <54D800F5.60603@gmail.com>
References: <1423100070-31848-1-git-send-email-dsahern@gmail.com> <87k2zubw7l.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	roopa <roopa@cumulusnetworks.com>, hannes@stressinduktion.org,
	Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Vipin Kumar <vipin@cumulusnetworks.com>,
	Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:45681 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755313AbbBIAgJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Feb 2015 19:36:09 -0500
Received: by mail-pa0-f53.google.com with SMTP id lf10so22350311pab.12
        for <netdev@vger.kernel.org>; Sun, 08 Feb 2015 16:36:08 -0800 (PST)
In-Reply-To: <87k2zubw7l.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2/6/15 1:50 PM, Eric W. Biederman wrote:
>
> David looking at your patches and reading through your code I think I
> understand what you are proposing, let me see if I can sum it up.
>
> Semantics:
>     - The same as a network namespace.
>     - Addition of a VRF-ANY context
>     - No per VRF settings
>     - No creation or removal operation.

Yes. Plus what I see is an important feature: the ability to layer VRFs 
and network namespaces.

Network namespaces can be used to create smaller, logical switches 
within a single physical switch. (i.e., A network namespace is on par 
with what Cisco calls a VDC, virtual device context, for its Nexus 7000 
switches -- logical separation at the device layer front panel port).

Layering VRFs (L3 separation) within a network namespace (L1 separation) 
provides some nice end-user features.

>
> Implementation:
>     - Add a VRF-id to every affected data structure.
>
> This implies that you see the current implementation of network
> namespaces to be space inefficient, and that you think you can remove
> this inefficiency by simply removing the settings and the associated
> proc files.

Not exactly. I see the current namespace implementation as an excellent 
L1 separation construct, but not an L3 construct.

>
> Given that you have chosen to keep the same semantics as network
> namespaces for everything except for settings this raises the questions:
> - Are the settings and their associated proc files what actually cause
>    the size cost you see in network namespaces?
> - Can we instead of reimplementing network namespaces instead optimize
>    the current implementation?

The namespace memory consumption is side problem to the bigger problem 
of how the isolation of namespaces affect processes (the need to have a 
presence in each namespace).

What I was targeting is a trade-off. To make an L3 separation efficient 
from a large scale* perspective one needs to give up something -- here 
it is per-VRF procfs settings. Replicating procfs tree for each 
namespace does have a high cost.

* scale here meaning VRFs from 1 to N, N for current products goes up to 
4000, though I know of that has mentioned 16k VRFs.

>
> We need measurements to answer either of those questions and I think
> before proceeding we need to answer those questions.

agreed.


> Beyond that I want to point out that in general a data structure that
> has a tag on every member is going to have a larger memory foot print
> per entry, contain more entries, and by virtue of both of those be less
> memory efficient and less time efficient to use.   So it is not clear
> that a implementation that tags everything with a vrf-id will actually
> be lighter weight.

The memory hit for a network namespace is >100k (yes, CONFIG option 
dependent and that 100k is based on a 3.10 kernel which is higher than 
what was measured for a 3.4 kernel).

This proposal puts a 4-byte tag to netdevices, sockets and tasks (skb's 
are out per a prior email). So yes there will be a point that the number 
of netdevices (logical + physical), plus tasks, and sockets will make 
the memory hit of a VRF tag on par with namespace overhead. But the VRF 
tagging alleviates the need to replicate processes/multiple 
sockets/threads so in the big picture I can;t see how the overall hit to 
memory is higher with a VRF id tag.

>
> Also there is a concern that placing tags in every data structure may be
> significantly more error prone to implement (as it is more more thing to
> keep trace of), and that can impact the maintainability and the
> correctness of the code for everyone.

I don't agree with this. You have already done the groundwork here by 
plumbing through the namespace checks. Adding a vrf id has not proven to 
be a huge problem. The patch changes are highly repetitive because again 
it can leverage the namespace changes you have done.

> The standard that was applied to the network namespace was that
> it did not have any measurable performance impact when enabled.  The
> measurments taken at the time did not show a slow down when a 1Gig
> interface was place in a network namespace.  Compared to running an
> unpatched kernel.

Sure. I will build kernels at the commit id my patches are based on and 
one with my changes and do a comparison. Virtual machines on KVM 
emphasize the performance effects so I will compare a few netperf runs 
with and without my changes. On a newer 3.x kernel I typically see 
network throughput rates in 15 to 16 Gbps range (though H/W dependent), 
so this far exceeds the 1G rate. Does that sound reasonable?

>
> I suspect your extra layer of indirection to get to struct net in
> addition to touching struct skb will give you a noticable performance
> impact.

I don't understand the 'extra layer of indirection' comment. I don't see 
the indirection, I see an extra comparison. ie., from net_eq to net_eq + 
(vrf_eq || vrf_eq_any).

 From a struct comparison it has gone from:

struct net_device {
     ...
     struct net              *nd_net;
     ...
};

to

struct net_device {
     ...
     struct net_ctx          net_ctx {
         struct net *net;
         __u32 vrf;
    };
...
};


>
>
> I have another concern.  I don't think it is wise to have a data
> structure modified two different ways to deal with network namespaces
> and vrfs.  For maintainability and our own sanity we should pick which
> version that we judge to be the most efficient implementation and go
> with it.

you lost me. What data structure is modified 2 different ways? VRFs are 
sub context to a namespace.

>
>
>
> The architecture I imagine for using network namespaces as vrfs for
> devices that perform layer 2 bridging and layer 3 routing.
>
> port1 port2 port3 port4 port5 port6 port7 port8 port9 port10
>    |     |     |     |     |     |     |     |     |     |
>    +-----+-----+-----+-----+-----+-----+-----+-----+-----+
>   /                   Link Aggregation                    \
> +                                                         +
> |                        Bridging                         |
> +----------------------------+----------------------------+
>                               |
>                            cpu port
>                               |
>         +---------------------+---------------------+
>        /     +---------------/ \---------------+     \
>       /     /     +---------/   \---------+     \     \
>      /     /     /     +---/     \---+     \     \     \
>     /     /     /     /    |     |    \     \     \     \
>    |     |     |     |     |     |     |     |     |     |
> vlan1 vlan2 vlan3 vlan4 vlan5 vlan6 vlan7 vlan8 vlan9 vlan10
>    |     |     |     |     |     |     |     |     |     |
> +-+-----+-----+-----+-----+-+ +-+-----+-----+-----+-----+-+
> |    network namespace 1    | |    network namespace2     |
> +---------------------------+ +---------------------------+
>
> Traffic to and from the rest of the world comes through the
> external ports.
>
> The traffic is then processed at layer two including link
> aggregation, bridging and classifying which vlan the traffic
> belongs in.
>
> If the traffic needs to be routed it then comes up to the cpu port.
> The cpu port looks at the tags on the traffic and places it into
> the appropriate vlan device.
>
>  From the various vlans the traffic is then routed according
> to the routing table of whichever network namespace the vlan
> device is in.
>
> There are stateless offloads to this in modern hardware but this is a
> reasonable model how all of this works semantically.
>
> As such the vlan devices can be moved between network namespaces without
> affecting any layer two monitoring or work that happens on the lower
> level devices.  The practical restriction is that L2 and L3 need to be
> handled on different network devices.
>
> This split of network devices ensures that L2 code that works today
> should not need any changes or in any way be concerned about network
> namespaces or that the parent devices are in.

9+ months ago I had considered something similar. I'll try to amend your 
picture to show my concept:


port1 port2 port3 port4 port5 port6 port7 port8 port9 port10

   |     |     |     |     |     |     |     |     |     |
   +-----+-----+-----+-----+-----+-----+-----+-----+-----+
  /                    Link Aggregation                   \
+                                                         +
|                         Bridging                        |
+-----------------------------+---------------------------+
                               |
+-----------------------------+----------------------------+
|default namespace            |                            |
| (init_net)              NIC driver                       |
|                             |                            |
|  +----+----+-----+-----+-------+----+----+----+----+     |
| eth1 eth2 eth3  eth4 eth5     eth6 eth7 eth8 eth9 eth10  |
|  |    |    |     |     |        |    |    |    |    |    |
+-----------------------------+----------------------------+
    |    |    |     |     |        |    |    |    |    |
+--+----+----+-----+-----+---+ +--+----+----+----+----+----+
|  |    |    |     |     |   | |  |    |    |    |    |    |
| seth1 |   seth3  |   seth5 | | seth6 |   seth8 |   seth10|
|      seth2      seth4      | |      seth7     seth9      |
|                            | |                           |
|    network namespace 1     | |    network namespace 2    |
+----------------------------+ +---------------------------+

Essentially netdevices for front panel ports exist in the default 
namespace (init_net). L2 processes, monitoring processes (collectd, snmp 
agents for devices, etc) and such would run here. From there "shadow 
devices" (the 's' on the eth pairs) are created for namespaces where the 
path between real and shadow is similar to how veth pairs work. In the 
end this approach seemed to be a rather complex solution playing a lot 
of games so I abandoned it in favor of the approach in this patch set -- 
adding a VRF id to a network context.

The patch diff might be large but almost all of it is converting the 
existing struct net passing and net_eq checks to the broader struct 
net_ctx and net_ctx_eq comparisons. Really the change rides on top of 
what you have done for namespaces.

As for your proposal with VLAN based tagging, I do not understand the 
packet path from driver for front panel ports to namespace based 
netdevices. The VLAN sorting, and hence VRF sorting, is done in H/W? So 
there are netdevices in init_net the driver uses and then VLAN devices 
in the namespaces -- so those would correspond to what I called a shadow 
device? If the packets are also VLAN tagged we have nested tagging -- 
one for the port and one for the VRF?

Also, doesn't the VLAN design limit number of VRFs to 4096? My current 
patch set might limit it to 4096 but fix the genid piece (IPv6 seems to 
have removed genid comparisons betweeen 3.17 and 3.19 -- need to look 
into that) and it becomes a 32-bit tag which is a huge range for VRFs.

David
