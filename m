From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 00/11] A flow API
Date: Fri, 09 Jan 2015 10:27:46 -0800
Message-ID: <54B01DA2.9090104@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <54ABD3D1.6020608@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, sfeldma@gmail.com, jiri@resnulli.us,
	simon.horman@netronome.com, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Jamal Hadi Salim <jhs@mojatatu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:57680 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751139AbbAIS2G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 13:28:06 -0500
Received: by mail-ob0-f178.google.com with SMTP id gq1so14380249obb.9
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 10:28:04 -0800 (PST)
In-Reply-To: <54ABD3D1.6020608@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/06/2015 04:23 AM, Jamal Hadi Salim wrote:
> John,
>
> There are a lot of things to digest in your posting - I am interested
> in commenting on many things but feel need to pay attention to details
> in general given the importance of this interface (and conference is
> chewing my netdev time at the moment). I need to actually sit down
> and stare at code and documentation.

any additional feedback would be great. sorry I tried to be concise
but this email got fairly long regardless. Also a delayed the response
a few days as I mulled over some of it.

>
> I do think we need to have this discussion as part of the BOF
> Shrijeet is running at netdev01.

Maybe I was a bit ambitious thinking we could get this merged
by then? Maybe I can resolve concerns via email ;) What I wanted
to discuss at netdev01 was specifically the mapping between
software models and hardware model as exposed by this series.
I see value in doing this in user space for some consumers OVS
which is why the UAPI is there to support this.

Also I think in-kernel users are interesting as well and 'tc'
is a reasonable candidate to try and offload from in the kernel IMO.

>
> General comments:
> 1) one of the things that i have learnt over time is that not
> everything that sits or is abstracted from hardware is a table.
> You could have structs or simple scalars for config or runtime
> control. How does what you are proposing here allow to express that?
> I dont think you'd need it for simple things but if you dont allow
> for it you run into the square-hole-round-peg syndrome of "yeah
> i can express that u32 variable as a single table with a single row
> and a single column" ;-> or "you need another infrastructure for
> that single scalr u32"

The interface (both UAPI and kernel API) deals exclusively with the
flow table pipeline at the moment. I've allowed for table attributes
which allows you to give tables characteristics. Right now it only
supports basic attribs like ingress_root and egress_root but I have
some work not in this series to allow tables to be dynamic
(allocated/freed) at runtime. More attributes could be added as needed
here. But this still only covers tables.

I agree there other things besides tables, of course. First thing
that comes to mind for me is queues and QOS. How do we model these?
My take is you add another object type call it QUEUE and use a
'struct net_flow_queue' to model queues. Queues then have attributes
as well like length, QOS policies, etc. I would call this extending the
infrastructure not creating another one :). Maybe my naming it
'net_flow' is not ideal. With a queue structure I can connect queues
and tables together with an enqueue action. That would be one example I
can generate more, encrypt operations, etc.

FWIW queues and QOS to me fit nicely into the existing infrastructure
and it may be easier to utilize the existing 'tc' UAPI for this.

In this series I just want to get the flow table piece down though.

>
> 2) So i understood the sense of replacing ethtool for classifier
> access with a direct interface mostly because thats what it was
> already doing - but i am not sure why you need
> it for a generic interface. Am i mistaken you are providing direct
> access to hardware from user space? Would this make essentially
> the Linux infrastructure a bypass (which vendors and their SDKs
> love)? IMHO, a good example is to pick something like netfilter
> or tc-filters and show how that is offloaded. This keeps it in
> the same spirit as what we are shooting for in L2/3 at the moment.
>

I'll try to knock these off one by one:

Yes we are providing an interface for userspace to interrogate the
hardware and program it. My take on this is even if you embed this
into another netlink family OVS, NFT, TCA you end up with the same
operations w.r.t. table support (a) query hardware for
resources/constraints/etc and (b) an API to add/del rules in those
tables. It seems the intersection of these features with existing
netlink families is fairly small so I opted to create a new family.
The underlying hardware offload mechanisms in flow_table.c here could
be used by in-kernel consumers as well as user space. For some
consumers 'tc' perhaps this makes good sense for others 'OVS'
it does not IMO.

Direct access to the hardware? hmm not so sure about that its an
abstraction layer so I can talk to _any_ hardware device using the
same semantics. But yes at the bottom of the interface there is
hardware. Although this provide a "raw" interface for userspace to
inspect and program the hardware it equally provides an API for
in-kernel consumers from using the hardware offload APIs. For
example if you want 'tc' to offload a queueing discipline with some
filters. For what its worth I did some experimental work here and for
some basic cases its possible to do this offload. I'll explore
this more as Jiri/you suggest.

Would this make essentially the Linux infrastructure a bypass? hmm
I'm not sure here exactly what you mean? If switching is done in
the ASIC then the dataplane is being bypassed. And I don't want
to couple management of software dataplane with management with
hardware dataplane. It would be valid to have these dataplanes
running two completely different pipelines/network functions. So I
assume you mean does this API bypass the existing Linux control plane
infrastructure for software dataplanes. I'll say tentatively
yes it does. But in many cases my goal is to unify them in userspace
where it is easier to make policy decisions. For OVS, NFT it
seems to me that user space libraries can handle the unification
of hardware/software dataplanes. Further I think it is the correct
place to unify the dataplanes. I don't want to encode complex
policies into the kernel. Even if you embed the netlink UAPI into
another netlink family the semantics look the same.

To address how to offload existing infrastructures, I'll try to
explain my ideas for each subsystem.

I looked into using netfilter but really didn't make much traction
in the existing infrastructure. The trouble being nft wants to use
expressions like payload that have registers, base, offset, len in
the kernel but the hardware (again at least all the hardware I'm
working with) doesn't work with these semantics it needs a field-id,
possibly the logical operation to use and the value to match. Yes I can
map base/offset/len to a field_id but what do I do with register? And
this sort of complication continues with most the other expressions.
I could write a new expression that was primarily used by hardware
but could have a software user as well but I'm not convinced we would
ever use it in software when we already have the functionally more
generic expressions. To me this looks like a somewhat arbitrary
embedding into netfilter uapi where the gain of doing this is not
entirely clear to me.

OVS would seem to have similar trouble all the policy is in user
space. And the netlink UAPI is tuned for OVS we don't want to start
adding/removing bits to support a hardware API where very little of it
would be used in the software only case and vice versa very little of
the OVS uapi messages as they exist today would be sufficient for the
hardware API. My point of view is the intersection is small enough here
that its easier to write a clean API that stands on its own then try
to sync these hardware offload operations into the OVS UAPI. Further
OVS is very specific about what fields/tables it supports in its current
version and I don't want to force hardware into this model.

And finally 'tc'. Filters today can only be attached to qdisc's which
are bound to net_devices. So the model is netdev's have queues, queues
have a qdisc association and qdiscs have filters. Here we are are
modelling a pipeline associated with a set of ports and in hardware.
The model is slightly different we have queues that dequeue into
an ingress table and an egress table that enqueues packets into queues.
Queues may or may not be bound to the same port. Yes I know 'tc' can
forward to ports but it has no notion of a global table space.

We could build a new 'tc' filter that loaded the hardware tables and
then added rules or deleted rules via hardware api but we would need
some new mechanics to get out the capabilities/resources. Basically
the same set of operations supported in the UAPI of this series. This
would end up IMO to be basically this series only embedded in the TCA_
family with a new filter kind. But then what do we attach it to? Not
a specific qdisc because it is associated with a set of qdiscs. And
additionally why would we use this qdisc*/hw-filter in software when
we already have u32 and bpf? IMO 'tc' is about per port(queues) QOS
and filters/actions to support this. That said I actually see offloading
'tc' qdisc/filters on the ports into the hardware as being useful
and using the operations added in this series to flow_table.c. See
my response to Jiri noting I'll go ahead and try to get this working.
OTOH I still think you need the UAPI proposed in this series for other
consumers.

Maybe I need to be enlightened but I thought for a bit about some grand
unification of ovs, bridge, tc, netlink, et. al. but that seems like
an entirely different scope of project. (side note: filters/actions
are no longer locked by qdisc and could stand on their own) My thoughts
on this are not yet organized.

> Anyways I apologize i havent spent as much time (holiday period
> wasnt good for me and netdev01 is picking up and consuming my time
> but i will try my best to respond and comment with some latency)
>

great thanks. Maybe this will give you more to mull over. If its
clear as mud let me know and I'll draw up some pictures. Likely
need to do that regardless. Bottom line I think the proposed API
here solves a real need.

Thanks!
John

> cheers,
> jamal
>
> On 12/31/14 14:45, John Fastabend wrote:
>> So... I could continue to mull over this and tweak bits and pieces
>> here and there but I decided its best to get a wider group of folks
>> looking at it and hopefulyl with any luck using it so here it is.
>>
>> This set creates a new netlink family and set of messages to configure
>> flow tables in hardware. I tried to make the commit messages
>> reasonably verbose at least in the flow_table patches.
>>
>> What we get at the end of this series is a working API to ge

t device
>> capabilities and program flows using the rocker switch.
>>
>> I created a user space tool 'flow' that I use to configure and query
>> the devices it is posted here,
>>
>>     https://github.com/jrfastab/iprotue2-flow-tool
>>
>> For now it is a stand-alone tool but once the kernel bits get sorted
>> out (I'm guessing there will need to be a few versions of this series
>> to get it right) I would like to port it into the iproute2 package.
>> This way we can keep all of our tooling in one package see 'bridge'
>> for example.
>>
>> As far as testing, I've tested various combinations of tables and
>> rules on the rocker switch and it seems to work. I have not tested
>> 100% of the rocker code paths though. It would be great to get some
>> sort of automated framework around the API to do this. I don't
>> think should gate the inclusion of the API though.
>>
>> I could use some help reviewing,
>>
>>    (a) error paths and netlink validation code paths
>>
>>    (b) Break down of structures vs netlink attributes. I
>>        am trying to balance flexibility given by having
>>        netlinnk TLV attributes vs conciseness. So some
>>        things are passed as structures.
>>
>>    (c) are there any devices that have pipelines that we
>>        can't represent with this API? It would be good to
>>        know about these so we can design it in probably
>>        in a future series.
>>
>> For some examples and maybe a bit more illustrative description I
>> posted a quickly typed up set of notes on github io pages. Here we
>> can show the description along with images produced by the flow tool
>> showing the pipeline. Once we settle a bit more on the API we should
>> probably do a clean up of this and other threads happening and commit
>> something to the Documentation directory.
>>
>>   http://jrfastab.github.io/jekyll/update/2014/12/21/flow-api.html
>>
>> Finally I have more patches to add support for creating and destroying
>> tables. This allows users to define the pipeline at runtime rather
>> than statically as rocker does now. After this set gets some traction
>> I'll look at pushing them in a next round. However it likely requires
>> adding another "world" to rocker. Another piece that I want to add is
>> a description of the actions and metadata. This way user space can
>> "learn" what an action is and how metadata interacts with the system.
>> This work is under development.
>>
>> Thanks! Any comments/feedback always welcome.
>>
>> And also thanks to everyone who helped with this flow API so far. All
>> the folks at Dusseldorf LPC, OVS summit Santa Clara, P4 authors for
>> some inspiration, the collection of IETF FoRCES documents I mulled
>> over, Netfilter workshop where I started to realize fixing ethtool
>> was most likely not going to work, etc.
>>
>> ---
>>
>> John Fastabend (11):
>>        net: flow_table: create interface for hw match/action tables
>>        net: flow_table: add flow, delete flow
>>        net: flow_table: add apply action argument to tables
>>        rocker: add pipeline model for rocker switch
>>        net: rocker: add set flow rules
>>        net: rocker: add group_id slices and drop explicit goto
>>        net: rocker: add multicast path to bridging
>>        net: rocker: add get flow API operation
>>        net: rocker: add cookie to group acls and use flow_id to set
>> cookie
>>        net: rocker: have flow api calls set cookie value
>>        net: rocker: implement delete flow routine
>>
>>
>>   drivers/net/ethernet/rocker/rocker.c          | 1641
>> +++++++++++++++++++++++++
>>   drivers/net/ethernet/rocker/rocker_pipeline.h |  793 ++++++++++++
>>   include/linux/if_flow.h                       |  115 ++
>>   include/linux/netdevice.h                     |   20
>>   include/uapi/linux/if_flow.h                  |  413 ++++++
>>   net/Kconfig                                   |    7
>>   net/core/Makefile                             |    1
>>   net/core/flow_table.c                         | 1339
>> ++++++++++++++++++++
>>   8 files changed, 4312 insertions(+), 17 deletions(-)
>>   create mode 100644 drivers/net/ethernet/rocker/rocker_pipeline.h
>>   create mode 100644 include/linux/if_flow.h
>>   create mode 100644 include/uapi/linux/if_flow.h
>>   create mode 100644 net/core/flow_table.c
>>
>


-- 
John Fastabend         Intel Corporation
