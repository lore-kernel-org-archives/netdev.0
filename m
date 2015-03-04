From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: OVS Offload Decision Proposal
Date: Wed, 04 Mar 2015 11:07:46 -0800
Message-ID: <54F75802.90705@gmail.com>
References: <20150304011817.GA29502@vergenet.net> <CA+mtBx9U-HUXcfk+oOuNRwpKq74WXmbkWvQDrYURCavfWZjQaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <simon.horman@netronome.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>, tgraf <tgraf@suug.ch>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:44442 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759416AbbCDTID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 14:08:03 -0500
Received: by obcuy5 with SMTP id uy5so1804907obc.11
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 11:08:02 -0800 (PST)
In-Reply-To: <CA+mtBx9U-HUXcfk+oOuNRwpKq74WXmbkWvQDrYURCavfWZjQaQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/04/2015 08:45 AM, Tom Herbert wrote:
> Hi Simon, a few comments inline.
>
> On Tue, Mar 3, 2015 at 5:18 PM, Simon Horman <simon.horman@netronome.com> wrote:
>> [ CCed netdev as although this is primarily about Open vSwitch userspace
>>    I believe there are some interested parties not on the Open vSwitch
>>    dev mailing list ]
>>
>> Hi,
>>
>> The purpose of this email is to describe a rough design for driving Open
>> vSwitch flow offload from user-space. But before getting to that I would
>> like to provide some background information.
>>
>> The proposed design is for "OVS Offload Decision": a proposed component of
>> ovs-vswitchd. In short the top-most red box in the first figure in the
>> "OVS HW Offload Architecture" document edited by Thomas Graf[1].
>>
>> [1] https://docs.google.com/document/d/195waUliu7G5YYVuXHmLmHgJ38DFSte321WPq0oaFhyU/edit#heading=h.116je16s8xzw
>>
>> Assumptions
>> -----------
>>
>> There is currently a lively debate on various aspects of flow offloads
>> within the Linux networking community. As of writing the latest discussion
>> centers around the "Flows! Offload them." thread[2] on the netdev mailing
>> list.
>>
>> [2] http://thread.gmane.org/gmane.linux.network/351860
>>
>> My aim is not to preempt the outcome of those discussions. But rather to
>> investigate what offloads might look like in ovs-vswitchd. In order to make
>> that investigation concrete I have made some assumptions about facilities
>> that may be provided by the kernel in future. Clearly if the discussions
>> within the Linux networking community end in a solution that differs from
>> my assumptions then this work will need to be revisited. Indeed, I entirely
>> expect this work to be revised and refined and possibly even radically
>> rethought as time goes on.
>>
>> That said, my working assumptions are:
>>
>> * That Open vSwitch may manage flow offloads from user-space. This is as
>>    opposed to them being transparently handled in the datapath. This does
>>    not preclude the existence of transparent offloading in the datapath.
>>    But rather limits this discussion to a mode where offloads are managed
>>    from user-space.
>>
>> * That Open vSwitch may add flows to hardware via an API provided by the
>>    kernel. In particular my working assumption is that the Flow API proposed
>>    by John Fastabend[3] may be used to add flows to hardware. While the
>>    existing netlink API may be used to add flows to the kernel datapath.
>>
> Doesn't this imply two entities to be independently managing the same
> physical resource? If so, this raises questions of how the resource
> would be partitioned between them? How are conflicting requests
> between the two rectified?

What two entities? The driver + flow API code I have in this case manage
the physical resource.

I'm guessing the conflict you are thinking about is if we want to use
both L3 (or some other kernel subsystem) and OVS in the above case at
the same time? Not sure if people actually do this but what I expect is
the L3 sub-system should request a table from the hardware for L3
routes. Then the driver/kernel can allocate a part of the hardware
resources for L3 and a set for OVS.

This seems to work fairly well in practice in the user space drivers
but implies some provisioning up front which is what Neil was proposing.
Even without this OVS discussion I don't see how you avoid the
provisioning step.

>
>> * That there will be an API provided by the kernel to allow the discovery
>>    of hardware offload capabilities by user-space. Again my working
>>    assumption is that the Flow API proposed by John Fastabend[3] may be used
>>    for this purpose.
>>
>> [3] http://thread.gmane.org/gmane.linux.network/347188
>>
>> Rough Design
>> ------------
>>
>> * Modify flow translation so that the switch parent id[4] of the flow is
>>    recorded as part of its translation context. The switch parent id was
>>    recently added to the Linux kernel and provides a common identifier for
>>    all netdevices that are backed by the same underlying switch hardware for
>>    some very loose definition of switch. In this scheme if the input and all
>>    output ports of a flow belong to the same switch hardware then the switch
>>    id of the translation context would be set accordingly, indicating
>>    offload of the flow may occur to that switch.
>>
>>    [4] https://github.com/torvalds/linux/blob/master/Documentation/networking/switchdev.txt
>>
>>    At this time this excludes both flows that either span multiple switch
>>    devices or use vports that are not backed directly by netdevices, for
>>    example tunnel vports. While important I believe these are topics for
>>    further work.
>>
>> * At the point where a flow is to be added to the datapath ovs-vswitchd
>>    should determine if it should be offloaded and if so translate it to a
>>    flow for the hardware offload API and queue this translated flow up to be
>>    added to hardware as well as the datapath.
>>
>>    The translation to hardware flows could be performed along with the
>>    translation that already occurs from OpenFlow to ODP flows. However, that
>>    translation is already quite complex and called for a variety of reasons
>>    other than to prepare flows to be added to the datapath. So I think it
>>    makes some sense to keep the new translation separate from the existing
>>    one.
>>
>>    The determination mentioned above could first check if the switch id is
>>    set and then may make further checks: for example that there is space in
>>    the hardware for a new flow, that all the matches and actions of the flow
>>    may be offloaded.
>>
>>    There seems to be ample scope for complex logic to determine which flows
>>    should be offloaded. And I believe that one motivation for handling
>>    offloads in user-space for such complex logic to live in user-space.
>
> I think there needs to be more thought around the long term
> ramifications of this model. Aside from the potential conflicts with
> kernel that I mentioned above as well as the inevitable replication of
> functionality between kernel and userspace, I don't see that we have
> any good precedents for dynamically managing a HW offload from user
> space like this. AFAIK, all current networking offloads are managed by
> kernel or device, and I believe iSCSI, RDMA qp's, and even TOE
> offloads were all managed in the kernel. The basic problem of choosing
> best M of N total flows to offload really isn't fundamentally
> different than some other kernel mechanisms such as how we need to
> manage the memory allocated to the page cache.

There is at least some precedence today where we configure VFs and the
hardware VEB/VEPA to forward traffic via 'ip' and 'fdb' dynamically. If
we get an indication from the controller a new VM has landed on the VF
and the controller indicates it should only send MAC/VLAN x we add it
to the hardware.

I would argue the controller is where the context to "know" which flows
should be sent to which VMs/queue_pairs/etc. The controller also has a
policy it wants to enforce on the VMs and hypervisor the kernel doesn't
have any of this context.

So without any of this context how can we build policy that requires
flows to be sent directly to a VM/queue-set or pre-processed by
hardware. Its not clear to me how the kernel can decide which flows are
the "best" in this case. Three cases come to mind (1) I always want
this done in hardware or I'll move my application/VM/whatever to another
system, (2) try and program this flow in hardware but if you can't its
a don't care, and (3) never offload this flow. We may dynamically
change the criteria above depending on external configuration/policy
events. If its a specific application the same three cases apply. It
might be required that pre-processing happens in hardware to meet
performance guarantees, it might be a nice to have, or it might be an
application that we never want to do pre-processing in hardware.

Another case is where you have two related rules possibly in different
subsystems. If you offload a route that depends on setting some meta
data for example but don't offload the rule to set the metadata the
route offload is useless and consuming hardware resources. So you need
to account for this as well and its not clear to me how to do this in
the kernel cleanly.

The conflicts issue I think can be resolved as noted above.

>
>>    However, in order to keep things simple in the beginning I propose some
>>    very simple logic: offload all flows that the hardware supports up until
>>    the hardware runs out of space.
>>
>>    This seems like a reasonable start keeping in mind that all flows will
>>    also be added to the datapath and that ovs-vswitchd constructs flows such
>>    that they do not overlap.
>>
> Again, who will enforce this?

This is the OVS user space and only one policy. We can build better ones
following this. But from the kernel perspective it only gets requests to
add flows or delete flows it doesn't have the above policy embedded in
the kernel.

You could implement the same policy on top of the L3 offloads if you
wanted. Load L3 rules into hardware until its full then stop in this
case its the application driving the L3 interface that implements the
policy we are saying the same thing here for OVS.

>
>>    A more conservative version of this simple rule would be to remove all
>>    flows from hardware if a flow is encountered that is not to be added to
>>    hardware. That is, ensure either all flows that are in hardware are also
>>    in software or no flows are in hardware at all. This is the approach
>>    being initially taken for L3 offloads in the Linux kernel[5].
>>
> That approach is non-starter for real deployment anyway. Graceful
> degradation is a fundamental requirement.

Agreed, but we can improve it by making the applications smarter.

>
>>    [5] http://thread.gmane.org/gmane.linux.network/352481/focus=352658
>>
>> * It seems to me that somewhat tricky problem is how to manage flows in
>>    hardware. As things stand ovs-vswitchd generally manages flows in the
>>    datapath by dumping flows, inspecting the dumped flows to see how
>>    recently they have been used and removing idle flows from the datapath.
>>    Unfortunately this approach may not be well suited to flows offloaded to
>>    hardware as dumping flows may be prohibitively expensive. As such I would
>>    like some consideration given to three approaches. Perhaps in the end all
>>    will need to be supported. And perhaps there are others:
>>
>>    1. Dump Flows
>>       This is the approach currently taken to managing datapath flows. As
>>       stated above my feeling is that this will not be well suited much
>>       hardware. However, for simplicity it may be a good place to start.
>>
>>    2. Notifications
>>       In this approach flows are added to hardware with a soft timeout and
>>       hardware removes flows when they timeout sending a notification when
>>       that occurs. Notifications would be relayed up to user space from the
>>       driver in the kernel. Some effort may be required to mitigate
>>       notification storms if many flows are removed in a short space of
>>       time. It is also of note that there is likely to be hardware that
>>       can't generate notifications on flow removal.
>>
>>    3. Aging in hardware
>>       In this approach flows are added to hardware with a soft timeout and
>>       hardware removes the flows when they timeout. However no notification
>>       is generated. And thus ovs-vswitchd has no way of knowing if a flow is
>>       still present in hardware or not. From a hardware point of view this
>>       seems to be the simplest to support. But I suspect that it would
>>       present some significant challenges to ovs-vswitchd in the context of
>>       its current implementation of flow management. Especially if flows are
>>       also to be present in the datapath as proposed above.
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>


-- 
John Fastabend         Intel Corporation
