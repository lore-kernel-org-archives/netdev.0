From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: OVS Offload Decision Proposal
Date: Thu, 5 Mar 2015 19:44:25 -0500
Message-ID: <20150306004425.GB6785@neilslaptop.think-freely.org>
References: <20150304011817.GA29502@vergenet.net>
 <CA+mtBx9U-HUXcfk+oOuNRwpKq74WXmbkWvQDrYURCavfWZjQaQ@mail.gmail.com>
 <54F75802.90705@gmail.com>
 <CA+mtBx-WYTo7tzvNKPYhBHkrPo8_W795+6tAMqVySLsMBqeRdQ@mail.gmail.com>
 <54F7B830.3060603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Herbert <therbert@google.com>,
	Simon Horman <simon.horman@netronome.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	tgraf <tgraf@suug.ch>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46300 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753694AbbCFAoy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 19:44:54 -0500
Content-Disposition: inline
In-Reply-To: <54F7B830.3060603@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 04, 2015 at 05:58:08PM -0800, John Fastabend wrote:
> [...]
> 
> >>>Doesn't this imply two entities to be independently managing the same
> >>>physical resource? If so, this raises questions of how the resource
> >>>would be partitioned between them? How are conflicting requests
> >>>between the two rectified?
> >>
> >>
> >>What two entities? The driver + flow API code I have in this case manage
> >>the physical resource.
> >>
> >OVS and non-OVS kernel. Management in this context refers to policies
> >for optimizing use of the HW resource (like which subset of flows to
> >offload for best utilization).
> >
> >>I'm guessing the conflict you are thinking about is if we want to use
> >>both L3 (or some other kernel subsystem) and OVS in the above case at
> >>the same time? Not sure if people actually do this but what I expect is
> >>the L3 sub-system should request a table from the hardware for L3
> >>routes. Then the driver/kernel can allocate a part of the hardware
> >>resources for L3 and a set for OVS.
> >>
> >I'm thinking of this as a more general problem. We've established that
> >the existing kernel mechanisms (routing, tc, qdiscs, etc) should and
> >maybe are required to work with these HW offloads. I don't think that
> >a model where we can't use offloads with OVS and kernel simultaneously
> >would fly, nor are we going to want the kernel to be dependent on OVS
> >for resource management. So at some point, these two are going to need
> >to work together somehow to share common HW resources. By this
> >reasoning,  OVS offload can't be defined in a vacuum. Strict
> >partitioning only goes so far an inevitably leads to poor resource
> >utilization. For instance, if we gave OVS and kernel each 1000 flow
> >states each to offload, but OVS has 2000 flows that are inundated and
> >kernel ones are getting any traffic then we have achieved poor
> >utilization. This problem becomes even more evident when someone adds
> >rate limiting to flows. What would it mean if both OVS and kernel
> >tried to instantiate a flow with guaranteed line rate bandwidth? It
> >seems like we need either a centralized resource manager,  or at least
> >some sort of fairly dynamic delegation mechanism for managing the
> >resource (presumably kernel is master of the resource).
> >
> >Maybe a solution to all of this has already been fleshed out, but I
> >didn't readily see this in Simon's write-up.
> 
In addition to Johns notes below, I think its important to keep in mind here
that no one is explicitly setting out make OVS offload and kernel dataplane
offload mutually exclusive, nor do I think that any of the available proposals
are actually doing so.  We just have two use cases that require different
semantics to make efficient use of those offloads within their own environments.

OVS, in Johns world requires fine grained control of the hardware dataplane, so
that the OVS bridge can optimally pass off the most cycle constrained operations
to the hardware, be that L2/L3, or some combination of both, in an effort to
maximize whatever aggregate software/hardware datapath it wishes to construct
based on user supplied rules.

Alternatively, kernel functional offloads already have very well defined
semantics, and more than anything else really just want to enforce those
semantics in hardware to opportunistically accelerate data movement when
possible, but not if it means sacrificing how the users interacts with those
functions (routing should still act like routing, bridging like bridging, etc).
That may require somewhat less efficient resource utilization than we could
otherwise achieve in the hardware, but if the goal is semantic consistency, that
may be a necessecary trade off. 

As to co-existence, theres no reason that both the models can't operate in
parallel, as long as the API's for resource management collaborate under the
covers.  The only question is, does the hardware have enough resources to do
both?  I expect the answer is, not likely (though in some situations it may).
But for that very reason we need to make that resource allocation an
administrative decision.  For kernel functionality, the only aspect of the
offload that we should expose to the user is an on/off switch, and possibly some
parameters with which to define offload resource sizing and policy. I.e.
commands like:
ip neigh offload enable dev sw0 cachesize 1000 policy lru
to reserve 1000 entries to store l2 lookups with a least recently used
replacement policy

or 
ip route offload enable dev sw0 cachesize 1000 policy maxuse
to reserve 1000 entries to store l3 lookups with a replacement policy that only
replaces routes who's hit count is larger than the least used in the cache

By enabling kernel functionality like that, remaining resources can be used by
the lower level API for things like OVS to use.  If there aren't enough left to
enable OVS offload, so be it.  the administrator has all the tools at their
disposal with which to reduce resource usage in one area in order to free them
for use in another.

Best
Neil

> I agree with all this and no I don't think it is all flushed out yet.
> 
> I currently have something like the following although currently
> proto-typed on a user space driver I plan to move the prototype into
> the kernel rocker switch over the next couple weeks. The biggest amount
> of work left is getting a "world" into rocker that doesn't have a
> pre-defined table model and implementing constraints on the resources
> to reflect how the tables are created.
> 
> Via user space tool I can call into an API to allocate tables,
> 
> #./flowtl create table type flow name flow-table \
> 	  matches $my_matches actions $my_actions \
> 	  size 1024 source 1
> 
> this allocates a flow table resource in the hardware with the identifier
> 'flow-table' that can match on fields in $my_matches and provide actions
> in $my_actions. This lets the driver create an optimized table in the
> hardware that matches on just the matches and just the actions. One
> reason we need this is because if the hardware (at least the hardware I
> generally work on) tries to use wide matches it is severely limited in
> the number of entries it can support. But if you build tables that just
> match on the relevant fields we can support many more entries in the
> table.
> 
> Then I have a few other 'well-defined' types to handle L3, L2.
> 
> #./flowtl create table type l3-route route-table size 2048 source dflt
> 
> these don't need matches/actions specifiers because it is known what
> a l3-route type table is. Similarly we can have a l2 table,
> 
> #./flowtl create table type l2-fwd l2-table size 8k source dflt
> 
> the 'source' field instructs the hardware where to place the table in
> the forwarding pipeline. I use 'dflt' to indicate the driver should
> place it in the "normal" spot for that type.
> 
> Then the flow-api module in the kernel acts as the resource manager. If
> a "route" rule is received it maps to the l3-route table if a l2 ndo op
> is received we point it at the "l2-table" and so on. User space flowtl
> set rule commands can only be directed at tables of type 'flow'. If the
> user tries to push a flow rule into l2-table or l3-table it will be
> rejected because these are reserved for the kernel subsystems.
> 
> I would expect OVS user space data plane for example to reserve a table
> or maybe multiple tables like this,
> 
> #./flowtl create table type flow name ovs-table-1 \
> 	matches $ovs_matches1 actions $ovs_actions1 \
> 	size 1k source 1
> 
> #./flowtl create table type flow name ovs-table-2 \
> 	matches $ovs_matches2 actions $ovs_actoins2 \
> 	size 1k source 2
> 
> By manipulating the source fields you could have a table that forward
> packets to the l2/l3 tables or a "flow" table depending on some criteria
> or you could work the other way have a set of routes and if they miss
> forward to a "flow" table. Other combinations are possible as well.
> 
> I hope that is helpful I'll try to do a better write-up when I post the
> code. Also it seems like a reasonable approach to me any thoughts?
> 
> .John
> 
> -- 
> John Fastabend         Intel Corporation
> 
