From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net-next 0/2] extend sch_mqprio to distribute traffic
 not only by ETS TC
Date: Tue, 8 May 2012 16:56:22 +0300
Message-ID: <4FA92606.6070401@mellanox.com>
References: <1336287910-12010-1-git-send-email-amirv@mellanox.com> <4FA86EB8.2050006@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Oren Duer <oren@mellanox.com>, Liran Liss <liranl@mellanox.com>
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog117.obsmtp.com ([207.126.144.143]:35532 "HELO
	eu1sys200aog117.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754503Ab2EHN42 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 May 2012 09:56:28 -0400
In-Reply-To: <4FA86EB8.2050006@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/08/2012 03:54 AM, John Fastabend wrote:
> On 5/6/2012 12:05 AM, Amir Vadai wrote:
>> This series comes to revive the discussion initiated on the thread "net:
>> support tx_ring per UP in HW based QoS mechanism" (see
>> http://marc.info/?t=133165957200004&r=1&w=2) with the major issue to be address
>> is - how should sk_prio<=>   TC be done, for both, tagged and untagged traffic.
>> Following is a staged description addressing the background, problem
>> description, current situation, suggestion for the change and implementation of
>> it.
>
> OK but the mqprio qdisc is only concerned with mapping skb->priority to
> queue sets I perhaps unfortunately called the queue sets tc's. Try not
> to get hung up on my perhaps limiting naming of variables and functions.
I understand that.

>
> mqprio is used outside of 802.1Q as well in these cases a traffic class
> is not usually even defined.
>
>>
>> Background
>> ----------
>> Egress traffic has 3 layers of management to configure QoS attributes:
>> * Application - sets sk_prio
>>    * setsockopt() - application may set sk_prio using SO_PRIORITY or IP_TOS
>> * Host admin - sets sk_prio<=>  UP
>>    * net_prio cgroup
>
> net_prio cgroup is about setting skb->priority not really UP.
Right.
>
>>    * Egress map for tagged traffic
>> * Net admin - sets UP<=>  TC + TC QoS attributes
>>    * lldpad
>> Commit 4f57c087de9 "net: implement mechanism for HW based QOS" introduced a
>> mechanism for lower layer devices to steer traffic using skb->priority to tx
>> queues.
>
> yep that was my first comment.
>
>>
>> Problem
>> -------
>> How should sk_prio<=>  TC be done, for both, tagged and untagged traffic?
>>
>> Current situation
>> -----------------
>> * The network priority cgroup infrastructure commit 5bc1421e, introduced implicit
>>    assumption that sk_prio == UP.
>
> I don't think this is true at least this is not my perspective.
>
> The cgroup infrastructure in that commit sets the skb->priority. What you
> do with the priority and if you map it to a UP or qdisc classes or some
> other thing is up to the lower layers. In the DCBX context it eventually
> gets mapped to some queue sets but that is only one usage case.
>
>> * tc tool is used to map UP<=>  TC for both tagged and untagged traffic.
>
> Yes. But this is just a display issue. If I was being more general I
> would have named this 'priority to queue set'. A bit short sighted
> on my part.
>
>> * egress map and lldptool and ignored when tc tool is being used.
>
> Agreed. And this creates a bit of a nuisance but I believe it can
> be resolved in user space. AFAIK all the interfaces needed are available.
>
>> * HW queue is per TC.
>>
>> Suggestion
>> ----------
>> * sk_prio is an attribute controlled by the Application or cgroup.
>>    As used to be in tagged traffic
>
> This is the current usage correct?
Yes
>
>> * tc tool is used by the Host admin and sets sk_prio<=>  UP for untagged
>>    traffic. The rest of the chain is UP<=>  TC mapped by the Net admin (using
>>    DCBx netlink).
>
> This seems fine. But, what exactly is broken today? If you use the current
> mqprio qdisc and rename tc to queue_set then this works right?
For untagged traffic it is perfectly ok. This will cause problems with
tagged traffic (below).
>
>
>>    To keep backward compatibility, will have an option to set tc tool to
>>    compatabilty mode, in which, the old sk_prio<=>  TC will be kept.
>> * Depending on HW, queue selection is by UP or by TC.
>>
>> Implementation
>> --------------
>> Extended mqprio hw attribute:
>> * Bit 1: is queue offset/count owned by HW
>> * Bits 2-7: HW queueing type.
>>    * 0 - by ETS TC
>>    * 1 - by UP
>>
>> __skb_tx_hash() is now aware to the HW queuing type (pg_type): for pg_type
>> being ETS TC, traffic is distributed as it was before - tagged and untagged
>> packets are distributed by netdev_get_prio_tc_map. For pg_type being UP, tagged
>> and untagged packets are distributed by UP (taken from egress map for tagged
>> traffic, or netdev_get_prio_tc_map for untagged).
>
> I guess I don't see why we need this. If you keep the mqprio priority to
> queue set mapping set to 1:1. Then modify the egress map accordingly then
> this should work right?
>
> For example:
>
> If we want to map 8 802.1Q priority code points onto 4 traffic classes this
> should work,
>
> egress map: 0:0 1:0 2:1 3:1 4:2 5:2 6:3 7:3<-- vlan layer inserts correct tag
> mqprio up2tc: 0:0 1:1 2:2 3:3 4:4 5:5 6:6 7:7<-- mqprio with unfortunate 'tc' name maps priority to queues
But mqprio is mapping sk_priority to queue set, which is different from 
UP to queue set.
The term UP which we use, is the 8021q PCP in tagged traffic, and a 
priority mapped by the host admin for untagged traffic.
What you wrote, is actually, that the application will set the priority 
without enabling the host admin to control it.
> dcbnl up2tc: 0:0 1:0 2:1 3:1 4:2 5:2 6:3 7:3<-- dcbx pushes up2tc mapping correctly

For example, lets take an application that calls setsockopt(SO_PRIORITY, 2):
according to egress map: 8021q PCP field in vlan tag should be set to 1 
(=UP)
according to mqprio: a tx ring belonging to UP 2 will be selected.
according to dcbnl: traffic will have ETS attributes of TC 1

Except some conceptual problems, it won't work:
8021q PCP field is set by HW according to the tx ring (UP=2). which
is different from the one that the user configured in the egress_map
(UP=1).

>
> We may need to fixup userspace tools some but I think the kernel mechanisms
> are in place.
>
> BTW I did think about this while implementing the existing code and decided
> that rather than create more if/else branches the case you are describing
> could be handled by independently controlling the priority to queue set mappings
> in mqprio and the egress map.
>
> Feel free to let me know where I went wrong or why this doesn't work on
> your hardware. I agree though we may need to fixup lldpad and maybe even
> 'tc' some to get this to look correct in user space and get automagically
> setup correctly.
>
> Thanks,
> .John

I think I understand your stand, that mqprio mapping should be generic
and should not be TC nor UP oriented.

The problem is that our HW needs the queues to be selected by UP. ETS
TC mapping is configured before traffic starts, and therefore ETS
attributes are enforced by HW according to the UP, which the tx ring
belongs to. Same thing for vlan tag in tagged traffic. 8021q PCP is
placed by HW according to the tx ring.

For backward compatibility, tagged traffic should be steered to a tx
ring by UP taken from egress map - skb_tx_hash() as it is today, can't
do it. Even if we implement ndo_select_queue(), we will need to
duplicate most of the code from skb_tx_hash(), because there are more
than one tx ring per UP, and we need skb_tx_hash() to be able to select
a ring from a range of rings belonging to a UP.

Also, there are some configurations that can't be done by mqprio and
egress map. For example when having two vlans with different egress
maps.

And in the conceptual level, I think that kernel should not accept bad
configurations and rely on user space to protect it.

- Amir
