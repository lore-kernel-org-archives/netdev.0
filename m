From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next 0/2] extend sch_mqprio to distribute traffic
 not only by ETS TC
Date: Tue, 08 May 2012 23:22:36 -0700
Message-ID: <4FAA0D2C.6040306@intel.com>
References: <1336287910-12010-1-git-send-email-amirv@mellanox.com> <4FA86EB8.2050006@intel.com> <4FA92606.6070401@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Oren Duer <oren@mellanox.com>,
	Liran Liss <liranl@mellanox.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:63068 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756106Ab2EIGWj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2012 02:22:39 -0400
In-Reply-To: <4FA92606.6070401@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/8/2012 6:56 AM, Amir Vadai wrote:
> On 05/08/2012 03:54 AM, John Fastabend wrote:
>> On 5/6/2012 12:05 AM, Amir Vadai wrote:
>>> This series comes to revive the discussion initiated on the thread "net:
>>> support tx_ring per UP in HW based QoS mechanism" (see
>>> http://marc.info/?t=133165957200004&r=1&w=2) with the major issue to be address
>>> is - how should sk_prio<=>   TC be done, for both, tagged and untagged traffic.
>>> Following is a staged description addressing the background, problem
>>> description, current situation, suggestion for the change and implementation of
>>> it.
>>
>> OK but the mqprio qdisc is only concerned with mapping skb->priority to
>> queue sets I perhaps unfortunately called the queue sets tc's. Try not
>> to get hung up on my perhaps limiting naming of variables and functions.
> I understand that.

I figured you did. Just wanted to state it again.

> 
>>
>> mqprio is used outside of 802.1Q as well in these cases a traffic class
>> is not usually even defined.
>>
>>>

[...]

>>> Implementation
>>> --------------
>>> Extended mqprio hw attribute:
>>> * Bit 1: is queue offset/count owned by HW
>>> * Bits 2-7: HW queueing type.
>>>    * 0 - by ETS TC
>>>    * 1 - by UP
>>>
>>> __skb_tx_hash() is now aware to the HW queuing type (pg_type): for pg_type
>>> being ETS TC, traffic is distributed as it was before - tagged and untagged
>>> packets are distributed by netdev_get_prio_tc_map. For pg_type being UP, tagged
>>> and untagged packets are distributed by UP (taken from egress map for tagged
>>> traffic, or netdev_get_prio_tc_map for untagged).
>>
>> I guess I don't see why we need this. If you keep the mqprio priority to
>> queue set mapping set to 1:1. Then modify the egress map accordingly then
>> this should work right?
>>
>> For example:
>>
>> If we want to map 8 802.1Q priority code points onto 4 traffic classes this
>> should work,
>>
>> egress map: 0:0 1:0 2:1 3:1 4:2 5:2 6:3 7:3<-- vlan layer inserts correct tag
>> mqprio up2tc: 0:0 1:1 2:2 3:3 4:4 5:5 6:6 7:7<-- mqprio with unfortunate 'tc' name maps priority to queues
> But mqprio is mapping sk_priority to queue set, which is different from UP to queue set.
> The term UP which we use, is the 8021q PCP in tagged traffic, and a priority mapped by the host admin for untagged traffic.
> What you wrote, is actually, that the application will set the priority without enabling the host admin to control it.
>> dcbnl up2tc: 0:0 1:0 2:1 3:1 4:2 5:2 6:3 7:3<-- dcbx pushes up2tc mapping correctly
> 
> For example, lets take an application that calls setsockopt(SO_PRIORITY, 2):
> according to egress map: 8021q PCP field in vlan tag should be set to 1 (=UP)
> according to mqprio: a tx ring belonging to UP 2 will be selected.
> according to dcbnl: traffic will have ETS attributes of TC 1
> 
> Except some conceptual problems, it won't work:
> 8021q PCP field is set by HW according to the tx ring (UP=2). which
> is different from the one that the user configured in the egress_map
> (UP=1).

sorry I set it up wrong above but it _can_ be made to work as best I
can tell (for a single egress_map at least)

egress map: 0:0 1:1 2:2 3:3 4:4 5:5 6:6 7:7     <-- ignored
mqprio    : 0:0 1:1 2:2 3:3 4:4 5:5 6:6 7:7     <-- map priority to up queue sets
up2tc     : 0:0 1:0 2:1 3:1 4:2 5:2 6:3 7:3     <-- dcbx negotiated up2tc map

With your example application does setsockopt(SO_PRIORITY, 2):
	according to egress map : insert PCP 2
	according to mqprio	: tx ring belonging to UP2 is selected
	accroding to dcbnl	: traffic will have ETS attributes of TC1

The point is either you use the skb->priority to PCP map and then a 1:1
mqprio map or you use the mqprio map directly. Agree?

One more example translating the case with these patches onto a case
without these patches as I understand them.

first with these patches mapping:

up2tc     : 0:0 1:0 2:1 3:1 4:2 5:2 6:3 7:3     <-- dcbnl up2tc map 
egress map: 0:0 1:0 2:1 3:1 4:2 5:2 6:3 7:3     <-- sets pcp bits
mqprio    : 0:0 1:1 2:2 3:3 4:4 5:5 6:6 7:7     <-- with PGROUP_UP set

equivalent mapping without PGROUP_UP set

up2tc     : 0:0 1:0 2:1 3:1 4:2 5:2 6:3 7:3     <-- dcbnl negotiated up2tc map 
egress map: 0:0 1:0 2:0 3:0 4:0 5:0 6:0 7:0     <-- default unset egress map
mqprio    : 0:0 1:0 2:1 3:1 4:2 5:2 6:3 7:3     <-- with PGROUP_UP set

Application sets skb->priority to 2, in the first case egress map
sets the PCP to 1 and mqprio maps it to queues for UP1 based on PCP bits.

In case two egress map does nothing but skb->priority is still 2 so the
mqprio maps these to queues associated with UP1 so everything works
still.

I apologize if I'm missing something here but it seems correct to me. Spell
it out for me if I am still wrong.

> 
>>
>> We may need to fixup userspace tools some but I think the kernel mechanisms
>> are in place.
>>
>> BTW I did think about this while implementing the existing code and decided
>> that rather than create more if/else branches the case you are describing
>> could be handled by independently controlling the priority to queue set mappings
>> in mqprio and the egress map.
>>
>> Feel free to let me know where I went wrong or why this doesn't work on
>> your hardware. I agree though we may need to fixup lldpad and maybe even
>> 'tc' some to get this to look correct in user space and get automagically
>> setup correctly.
>>
>> Thanks,
>> .John
> 
> I think I understand your stand, that mqprio mapping should be generic
> and should not be TC nor UP oriented.
> 

Right. Also I want to avoid user space having to somehow "know" which
mode to put the qdisc in. Checking if the hardware is a mellanox card
does not scale.

> The problem is that our HW needs the queues to be selected by UP. ETS
> TC mapping is configured before traffic starts, and therefore ETS
> attributes are enforced by HW according to the UP, which the tx ring
> belongs to. Same thing for vlan tag in tagged traffic. 8021q PCP is
> placed by HW according to the tx ring.

OK. Can you agree though in the case where we restrict the egress_map
to be the same for all vlan's on a real_dev the existing mqprio map
_can_ work?

> 
> For backward compatibility, tagged traffic should be steered to a tx
> ring by UP taken from egress map - skb_tx_hash() as it is today, can't
> do it. Even if we implement ndo_select_queue(), we will need to
> duplicate most of the code from skb_tx_hash(), because there are more
> than one tx ring per UP, and we need skb_tx_hash() to be able to select
> a ring from a range of rings belonging to a UP.

agreed implementing this in select_queue() is no good.

> 
> Also, there are some configurations that can't be done by mqprio and
> egress map. For example when having two vlans with different egress
> maps.

This is a good example thanks. This currently doesn't work for hardware
that maps tx_rings to traffic classes either. So if we need/want to
solve this case then I guess we need something like your patches. Note
I think the patch you submitted should work regardless if you map
the PCP bits to UP queues or PCP bits to TC queues. We could use this
in both cases which helps my user space concerns.

> 
> And in the conceptual level, I think that kernel should not accept bad
> configurations and rely on user space to protect it.

I disagree policy should be managed in user space. Also I see no reason
to create a strong coupling between egress maps and mqprio maps. I can
imagine a case where they could be used independently. DCB is just one
usage model for mqprio. Using a bit like you did seems fine though.

> 
> - Amir

Assuming we want the multiple different egress map case to work I guess
we will have to do something like this. At least right now I can't think
of anything better but I'll think on it tomorrow some more.

The other thought would be to provide a qdisc hook before queue selection
to attach 'tc filters' and provide a new action to hash a skb across
queue sets.

Thanks,
John
