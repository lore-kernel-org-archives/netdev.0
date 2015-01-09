From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v1 00/11] A flow API
Date: Fri, 09 Jan 2015 10:10:04 -0800
Message-ID: <54B0197C.7040608@gmail.com>
References: <20141231194057.31070.5244.stgit@nitbit.x32> <20150108180320.GF1898@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, sfeldma@gmail.com, jhs@mojatatu.com,
	simon.horman@netronome.com, netdev@vger.kernel.org,
	davem@davemloft.net, andy@greyhouse.net
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:62019 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750864AbbAISKW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2015 13:10:22 -0500
Received: by mail-ob0-f169.google.com with SMTP id vb8so14314572obc.0
        for <netdev@vger.kernel.org>; Fri, 09 Jan 2015 10:10:22 -0800 (PST)
In-Reply-To: <20150108180320.GF1898@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/08/2015 10:03 AM, Jiri Pirko wrote:
> Wed, Dec 31, 2014 at 08:45:19PM CET, john.fastabend@gmail.com wrote:
>> So... I could continue to mull over this and tweak bits and pieces
>> here and there but I decided its best to get a wider group of folks
>> looking at it and hopefulyl with any luck using it so here it is.
>>
>> This set creates a new netlink family and set of messages to configure
>> flow tables in hardware. I tried to make the commit messages
>> reasonably verbose at least in the flow_table patches.
>>
>> What we get at the end of this series is a working API to get device
>> capabilities and program flows using the rocker switch.
>>
>> I created a user space tool 'flow' that I use to configure and query
>> the devices it is posted here,
>>
>> 	https://github.com/jrfastab/iprotue2-flow-tool
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
>>   (a) error paths and netlink validation code paths
>>
>>   (b) Break down of structures vs netlink attributes. I
>>       am trying to balance flexibility given by having
>>       netlinnk TLV attributes vs conciseness. So some
>>       things are passed as structures.
>>
>>   (c) are there any devices that have pipelines that we
>>       can't represent with this API? It would be good to
>>       know about these so we can design it in probably
>>       in a future series.
>>
>> For some examples and maybe a bit more illustrative description I
>> posted a quickly typed up set of notes on github io pages. Here we
>> can show the description along with images produced by the flow tool
>> showing the pipeline. Once we settle a bit more on the API we should
>> probably do a clean up of this and other threads happening and commit
>> something to the Documentation directory.
>>
>> http://jrfastab.github.io/jekyll/update/2014/12/21/flow-api.html
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
>>       net: flow_table: create interface for hw match/action tables
>>       net: flow_table: add flow, delete flow
>>       net: flow_table: add apply action argument to tables
>>       rocker: add pipeline model for rocker switch
>>       net: rocker: add set flow rules
>>       net: rocker: add group_id slices and drop explicit goto
>>       net: rocker: add multicast path to bridging
>>       net: rocker: add get flow API operation
>>       net: rocker: add cookie to group acls and use flow_id to set cookie
>>       net: rocker: have flow api calls set cookie value
>>       net: rocker: implement delete flow routine
>
> Truly impressive work John (including the "flow" tool, documentation).
> Hat's off.
>
> Currently, all is very userspace oriented and I understand the reason.
> I also understand why Jamal is a bit nervous from that fact. I am as well..
> Correct me if I'm wrong but this amount of "direct hw access" is
> unprecedented. There have been kernel here to cover the hw differencies,
> I wonder if there is any way to continue in this direction with flows...
>

As it is currently written the API allows for abstracting the hardware
programming and low level interface by using a common model and API that
can represent a large array of devices.

By abstract the hw differencies I'm not sure what this means except for
the above model/API. I intentionally didn't want to force _all_
hardware to expose a specific pipeline for example the OVS pipeline.

> What I would love to see in this initial patchset is "the internal user".
> For example tc. The tc code could query the capabilities and decide what
> "flows" to put into hw tables.

Sure, the biggest gap for me on this is 'tc' is actually about
ports/queues and currently filters/tables are part of qdiscs. The
model in this series is a pipeline that has a set of egress endpoints
that can be reached by actions. The endpoints would be ports or tunnel
engines or could be other network function blocks.

That said I can imagine pushing the configuration into a per port table
in the hardware or most likely just requiring any matches on egress
qdisc's to use an implied egress_port match. On ingress similarly use
an ingress_port match.

I'll look at doing this next week but I think the series is useful even
without any "internal users" ;) I'll send out a v2 with all the feedback
I've received so far shortly then think some more about this. Doing the
mapping from software filters/actions/tables onto the hardware tables
exposed by the API in this series is actually what I wanted to present
@ netdev conference so I think we are heading in the same direction.

.John


>
> Jiri
>


-- 
John Fastabend         Intel Corporation
