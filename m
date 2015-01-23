From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Fri, 23 Jan 2015 11:59:01 -0800
Message-ID: <54C2A805.7030401@gmail.com>
References: <20150123174609.GA23242@casper.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:41294 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751427AbbAWT7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 14:59:21 -0500
Received: by mail-ob0-f170.google.com with SMTP id wp4so6782553obc.1
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 11:59:20 -0800 (PST)
In-Reply-To: <20150123174609.GA23242@casper.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2015 09:46 AM, Thomas Graf wrote:
> I'm pulling in both branches of the thread here:
>
> On 01/23/15 at 04:56pm, Jiri Pirko wrote:
>> Fri, Jan 23, 2015 at 04:43:48PM CET, john.fastabend@gmail.com wrote:
>>> But with the current API its clear that the rules managed by the
>>> Flow API are in front of 'tc' and 'ovs' on ingress. Just the same
>>> as it is clear 'tc' ingress rules are walked before 'ovs' ingress
>>> rules. On egress it is similarly clear that 'ovs' does a forward
>>> rule to a netdev, then 'tc' fiters+qdisc is run, and finally the
>>> hardware flow api is hit.
>>
>>
>> Seems like this would be resolved by the separe "offload" qdisc.
>
> I'm not sure I understand the offload qdisc yet. My interpretation
> so far is that it would contain childs which *must* be offloaded.

Correct that is my suggestion.

_If_ we want to pursue an embedding inside tc/qdisc for the Flow API
then we need some structure to attach filters and qdisc's that _must_
be offloaded. I have cases where qdisc's on the software dataplane
will be entirely different the qdisc/filter layout on the hardware
dataplane. If you don't do this you end up with a rather strange
array of filters that I don't see anyway to unravel especially
with filters like u32 that have many tables and hardware that has
many tables.

In these cases IMO its going to be easiest to reason about the state
and how to configure it if you have two qdisc/filter attach points. One
for software and one for hardware.

>
> How would one transparently offload tc in this model? e.g. let's
> assume we have a simple prio qdisc with u32 cls:
>
> eth0
>    prio
>        class
>        class
>        ...
>      u32 ...
>      u32 ...
>
> Would you need to attach the prio to an "offload qdisc" to offload
> it or would that happen automatically? How would this looks like to
> user space?

My take is it doesn't happen transparently in general. The user space
has to add the qdisc then subsequently attach flows and actions
explicitly to the hardware qdisc. But I'm confused about what 'tc' has
to say about global pipelines see below,

>
> eth0
>    offload
>      prio
>        u32
>        u32
>    prio
>     u32
>     u32
>
> Like this?
>

So if I try to do a mock 'tc' session first creating some software
QOS and filters,

   # tc qdisc dev eth0 handle 8001: root mq <- add my mq sw qdisc
   # tc qdisc dev eth0 parent 8001:1 fq_codel <- add my fq_codel qdiscs
   # tc qdisc dev eth0 parent 8001:2 prio <- one per queue
	...
   # tc filter add dev p3p2 parent 8001:2 \
        protocol ip prio 20 \
        u32 match ip protocol 1 0xff \
        action skbedit priority        <- arbitrary filter

    [...]

   everything above is part of my software dataplane next up add some
   hw qdisc's and filters.

   # tc qdisc dev eth0 handle hw_dpif: root mq <- add my mq hw qdisc
   # tc qdisc show
	[...] <- normal output
	qdisc mq (hwdpif) 0: dev eth0 ...

So that seems OK to me I have a multiqueue QOS object on top of a
netdev that represents the switch _port_.

But it starts to break when I want to add a filter to the flow table
pipeline _not_ a qdisc on a port. The pipeline is shared between all
ports its a per port queueing discipline which is how the current
'tc' model works?

And here is where I stopped in my initial attempt and decided we needed
a new object the Flow API. But let me try to push it perhaps? So I need
something to represent the actual pipeline not the per port qdisc. A
new 'tc' object called 'tables' perhaps?

   # tc tables dev eth0 show
	[...]
       table: vlan:2
	src 1 apply 2 size -1
	matches:
	 in_lport [in_lport (lpm)]
	 vlan [vid (lpm)]
	actions:
	 set_vlan_id ( u16 vlan_id 0  )
	[...]

So the above is just selected output from 'flow' tool command giving a
table description. Then I can use the same syntax as my 'flow' tool but
embedded in 'tc'

  # tc tables dev eth0 set_rule prio 1 handle 4 table 2  \
     match in_lport.in_lport 1 0xffffffff		\
     action set_vlan_id 10

This could work but its a very simple embedding of what I have now.

Also I can imagine another qdisc options to offload port filters/qos
automagically from inside 'tc'. This could/should be done regardless
of if the Flow API is embedded in 'tc' IMO. So we can have a bit,

# tc qdisc set dev p3p2 handle 8001: offload

Then we can do some tests and offload flows and rules from 'tc'. but
I hope(?) its clear its not the same operation as the above 'tables'
command that I made up to represent the pipeline. The tables cmd above
lets me work on the pipeline.


>>> The cases I've been experimenting with using Flow API it is clear
>>> on the priority and what rules are being used by looking at counters
>>> and "knowing" the above pipeline mode.
>>>
>>> Although as I type this I think a picture would help and some
>>> documentation.
>
> +1
>
> We need one of those awesome graphs as the netfilter guys had it with
> where the hooks are attached to ;-)

Yes, I'll try to draft something next week. I'm a bit worried my above
example is a bit convoluted without it.

>
> On 01/23/15 at 07:34am, John Fastabend wrote:
>> Now 'xflows' needs to implement the same get operations that exist in
>> this flow API otherwise writing meaningful policies as Thomas points out
>> is crude at best. So this tc classifier supports 'get headers',
>> 'get actions', and 'get tables' and then there associated graphs. All
>> good so far. This is just an embedding of the existing API in the 'tc'
>> netlink family. I've never had any issues with this. Finally you build
>> up the 'get_flow' and 'set_flow' operations I still so no issue with
>> this and its just an embedding of the existing API into a 'tc
>> classifier'. My flow tool becomes one of the classifier tools.
>
> .... if we can get rid of the rtnl lock in the flow mod path ;-)

Well isn't it the qdisc lock here? And its not needed anymore for
filters/actions only qdisc's use it because they are not lock-safe
yet. Its been on my backlog to start replacing the skb lists with
lock-free rings but I haven't got anywhere on this yet.

Although a hardware doesn't really need a queuing discipline its
done in hardware so you could drop the qdisc lock in this case.

>
>> Now what should I attach my filter to? Typically we attach it to qdiscs
>> today. But what does that mean for a switch device? I guess I need an
>> _offloaded qdisc_? I don't want to run the same qdisc in my dataplane
>> of the switch as I run on the ports going into/out of the sw dataplane.
>> Similarly I don't want to run the same set of filters. So at this point
>> I have a set of qdiscs per port to represent the switch dataplane and
>> a set of qdiscs attached to the software dataplane. If people think this
>> is worth doing lets do it. It may get you a nice way to manage QOS while
>> your @ it.
>
> If I interpret this correctly then this would imply that each switch
> port is represented with a net_device as this is what the tc API
> understands.
>

I think this would work for QOS but I'm also confused as I tried to
illustrate above how the global pipeline fits into the 'tc' model where
everything is a port with queues.


-- 
John Fastabend         Intel Corporation
