From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Flows! Offload them.
Date: Thu, 26 Feb 2015 13:45:37 -0800
Message-ID: <54EF9401.6080405@gmail.com>
References: <20150226074214.GF2074@nanopsycho.orion> <54EF74E0.7060502@gmail.com> <54EF8911.9080203@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, jpettit@nicira.com, joestringer@nicira.com,
	jhs@mojatatu.com, sfeldma@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, simon.horman@netronome.com,
	shrijeet@gmail.com, gospo@cumulusnetworks.com, bcrl@kvack.org
To: John Fastabend <john.r.fastabend@intel.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:39605 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753976AbbBZVqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 16:46:08 -0500
Received: by pdjy10 with SMTP id y10so15970778pdj.6
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 13:46:07 -0800 (PST)
In-Reply-To: <54EF8911.9080203@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26/02/15 12:58, John Fastabend wrote:
> On 02/26/2015 11:32 AM, Florian Fainelli wrote:
>> Hi Jiri,
>>
>> On 25/02/15 23:42, Jiri Pirko wrote:
>>> Hello everyone.
>>>
>>> I would like to discuss big next step for switch offloading. Probably
>>> the most complicated one we have so far. That is to be able to offload flows.
>>> Leaving nftables aside for a moment, I see 2 big usecases:
>>> - TC filters and actions offload.
>>> - OVS key match and actions offload.
>>>
>>> I think it might sense to ignore OVS for now. The reason is ongoing efford
>>> to replace OVS kernel datapath with TC subsystem. After that, OVS offload
>>> will not longer be needed and we'll get it for free with TC offload
>>> implementation. So we can focus on TC now.
>>
>> What is not necessarily clear to me, is if we leave nftables aside for
>> now from flow offloading, does that mean the entire flow offloading will
>> now be controlled and going with the TC subsystem necessarily?
>>
>> I am not questioning the choice for TC, I am just wondering if
>> ultimately there is the need for a lower layer, which is below, such
>> that both tc and e.g: nftables can benefit from it?
> 
> My thinking on this is to use the FlowAPI ndo_ops as the bottom layer.
> What I would much prefer (having to actually write drivers) is that
> we have one API to the driver and tc, nft, whatever map onto that API.

Ok, I think this is indeed the right approach.

> 
> Then my driver implements a ndo_set_flow op and a ndo_del_flow op. What
> I'm working on now is the map from tc onto the flow API I'm hoping this
> sounds like a good idea to folks.

Sounds good to me.

> 
> Neil, suggested we might need a reservation concept where tc can reserve
> some space in a TCAM, similarly nft can reserve some space. Also I have
> applications in user space that want to reserve some space to offload
> their specific data structures. This idea seems like a good one to me.

Humm, I guess the question is how and when do we do this reservation, is
it upon first potential access from e.g: tc or nft to an offloading
capable hardware, and if so, upon first attempt to offload an operation?

If we are to interface with a TCAM, some operations might require more
slices than others, which will limit the number of actions available,
but it is hard to know ahead of time.

> 
>>
>> I guess my larger question is, if I need to learn about new flows
>> entering the stack, how is that going to wind-up looking like?
>>
>>>
>>> Here is my list of actions to achieve some results in near future:
>>> 1) finish cls_openflow classifier and iproute part of it
>>> 2) extend switchdev API for TC cls and acts offloading (using John's flow api?)
>>> 3) use rocker to provide offload for cls_openflow and couple of selected actions
>>> 4) improve cls_openflow performance (hashtables etc)
>>> 5) improve TC subsystem performance in both slow and fast path
>>>     -RTNL mutex and qdisc lock removal/reduction, lockless stats update.
>>> 6) implement "named sockets" (working name) and implement TC support for that
>>>     -ingress qdisc attach, act_mirred target
>>> 7) allow tunnels (VXLAN, Geneve, GRE) to be created as named sockets
>>> 8) implement TC act_mpls
>>> 9) suggest to switch OVS userspace from OVS genl to TC API
>>>
>>> This is my personal action list, but you are *very welcome* to step in to help.
>>> Point 2) haunts me at night....
>>> I believe that John is already working on 2) and part of 3).
>>>
>>> What do you think?
> 


-- 
Florian
