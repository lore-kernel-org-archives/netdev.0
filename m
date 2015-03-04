From: Tom Herbert <therbert@google.com>
Subject: Re: OVS Offload Decision Proposal
Date: Wed, 4 Mar 2015 13:36:34 -0800
Message-ID: <CA+mtBx-WYTo7tzvNKPYhBHkrPo8_W795+6tAMqVySLsMBqeRdQ@mail.gmail.com>
References: <20150304011817.GA29502@vergenet.net>
	<CA+mtBx9U-HUXcfk+oOuNRwpKq74WXmbkWvQDrYURCavfWZjQaQ@mail.gmail.com>
	<54F75802.90705@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Simon Horman <simon.horman@netronome.com>,
	"dev@openvswitch.org" <dev@openvswitch.org>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Neil Horman <nhorman@tuxdriver.com>, tgraf <tgraf@suug.ch>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f169.google.com ([209.85.223.169]:39775 "EHLO
	mail-ie0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751051AbbCDVgf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 16:36:35 -0500
Received: by iecat20 with SMTP id at20so17498465iec.6
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 13:36:34 -0800 (PST)
In-Reply-To: <54F75802.90705@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 4, 2015 at 11:07 AM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 03/04/2015 08:45 AM, Tom Herbert wrote:
>>
>> Hi Simon, a few comments inline.
>>
>> On Tue, Mar 3, 2015 at 5:18 PM, Simon Horman <simon.horman@netronome.com>
>> wrote:
>>>
>>> [ CCed netdev as although this is primarily about Open vSwitch userspace
>>>    I believe there are some interested parties not on the Open vSwitch
>>>    dev mailing list ]
>>>
>>> Hi,
>>>
>>> The purpose of this email is to describe a rough design for driving Open
>>> vSwitch flow offload from user-space. But before getting to that I would
>>> like to provide some background information.
>>>
>>> The proposed design is for "OVS Offload Decision": a proposed component
>>> of
>>> ovs-vswitchd. In short the top-most red box in the first figure in the
>>> "OVS HW Offload Architecture" document edited by Thomas Graf[1].
>>>
>>> [1]
>>> https://docs.google.com/document/d/195waUliu7G5YYVuXHmLmHgJ38DFSte321WPq0oaFhyU/edit#heading=h.116je16s8xzw
>>>
>>> Assumptions
>>> -----------
>>>
>>> There is currently a lively debate on various aspects of flow offloads
>>> within the Linux networking community. As of writing the latest
>>> discussion
>>> centers around the "Flows! Offload them." thread[2] on the netdev mailing
>>> list.
>>>
>>> [2] http://thread.gmane.org/gmane.linux.network/351860
>>>
>>> My aim is not to preempt the outcome of those discussions. But rather to
>>> investigate what offloads might look like in ovs-vswitchd. In order to
>>> make
>>> that investigation concrete I have made some assumptions about facilities
>>> that may be provided by the kernel in future. Clearly if the discussions
>>> within the Linux networking community end in a solution that differs from
>>> my assumptions then this work will need to be revisited. Indeed, I
>>> entirely
>>> expect this work to be revised and refined and possibly even radically
>>> rethought as time goes on.
>>>
>>> That said, my working assumptions are:
>>>
>>> * That Open vSwitch may manage flow offloads from user-space. This is as
>>>    opposed to them being transparently handled in the datapath. This does
>>>    not preclude the existence of transparent offloading in the datapath.
>>>    But rather limits this discussion to a mode where offloads are managed
>>>    from user-space.
>>>
>>> * That Open vSwitch may add flows to hardware via an API provided by the
>>>    kernel. In particular my working assumption is that the Flow API
>>> proposed
>>>    by John Fastabend[3] may be used to add flows to hardware. While the
>>>    existing netlink API may be used to add flows to the kernel datapath.
>>>
>> Doesn't this imply two entities to be independently managing the same
>> physical resource? If so, this raises questions of how the resource
>> would be partitioned between them? How are conflicting requests
>> between the two rectified?
>
>
> What two entities? The driver + flow API code I have in this case manage
> the physical resource.
>
OVS and non-OVS kernel. Management in this context refers to policies
for optimizing use of the HW resource (like which subset of flows to
offload for best utilization).

> I'm guessing the conflict you are thinking about is if we want to use
> both L3 (or some other kernel subsystem) and OVS in the above case at
> the same time? Not sure if people actually do this but what I expect is
> the L3 sub-system should request a table from the hardware for L3
> routes. Then the driver/kernel can allocate a part of the hardware
> resources for L3 and a set for OVS.
>
I'm thinking of this as a more general problem. We've established that
the existing kernel mechanisms (routing, tc, qdiscs, etc) should and
maybe are required to work with these HW offloads. I don't think that
a model where we can't use offloads with OVS and kernel simultaneously
would fly, nor are we going to want the kernel to be dependent on OVS
for resource management. So at some point, these two are going to need
to work together somehow to share common HW resources. By this
reasoning,  OVS offload can't be defined in a vacuum. Strict
partitioning only goes so far an inevitably leads to poor resource
utilization. For instance, if we gave OVS and kernel each 1000 flow
states each to offload, but OVS has 2000 flows that are inundated and
kernel ones are getting any traffic then we have achieved poor
utilization. This problem becomes even more evident when someone adds
rate limiting to flows. What would it mean if both OVS and kernel
tried to instantiate a flow with guaranteed line rate bandwidth? It
seems like we need either a centralized resource manager,  or at least
some sort of fairly dynamic delegation mechanism for managing the
resource (presumably kernel is master of the resource).

Maybe a solution to all of this has already been fleshed out, but I
didn't readily see this in Simon's write-up.

Thanks,
Tom
