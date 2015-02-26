From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: Flows! Offload them.
Date: Thu, 26 Feb 2015 12:58:57 -0800
Message-ID: <54EF8911.9080203@intel.com>
References: <20150226074214.GF2074@nanopsycho.orion> <54EF74E0.7060502@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com, andy@greyhouse.net,
	tgraf@suug.ch, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, jpettit@nicira.com, joestringer@nicira.com,
	jhs@mojatatu.com, sfeldma@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, simon.horman@netronome.com,
	shrijeet@gmail.com, gospo@cumulusnetworks.com, bcrl@kvack.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24880 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932191AbbBZU7A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Feb 2015 15:59:00 -0500
In-Reply-To: <54EF74E0.7060502@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/26/2015 11:32 AM, Florian Fainelli wrote:
> Hi Jiri,
> 
> On 25/02/15 23:42, Jiri Pirko wrote:
>> Hello everyone.
>>
>> I would like to discuss big next step for switch offloading. Probably
>> the most complicated one we have so far. That is to be able to offload flows.
>> Leaving nftables aside for a moment, I see 2 big usecases:
>> - TC filters and actions offload.
>> - OVS key match and actions offload.
>>
>> I think it might sense to ignore OVS for now. The reason is ongoing efford
>> to replace OVS kernel datapath with TC subsystem. After that, OVS offload
>> will not longer be needed and we'll get it for free with TC offload
>> implementation. So we can focus on TC now.
> 
> What is not necessarily clear to me, is if we leave nftables aside for
> now from flow offloading, does that mean the entire flow offloading will
> now be controlled and going with the TC subsystem necessarily?
> 
> I am not questioning the choice for TC, I am just wondering if
> ultimately there is the need for a lower layer, which is below, such
> that both tc and e.g: nftables can benefit from it?

My thinking on this is to use the FlowAPI ndo_ops as the bottom layer.
What I would much prefer (having to actually write drivers) is that
we have one API to the driver and tc, nft, whatever map onto that API.

Then my driver implements a ndo_set_flow op and a ndo_del_flow op. What
I'm working on now is the map from tc onto the flow API I'm hoping this
sounds like a good idea to folks.

Neil, suggested we might need a reservation concept where tc can reserve
some space in a TCAM, similarly nft can reserve some space. Also I have
applications in user space that want to reserve some space to offload
their specific data structures. This idea seems like a good one to me.

> 
> I guess my larger question is, if I need to learn about new flows
> entering the stack, how is that going to wind-up looking like?
> 
>>
>> Here is my list of actions to achieve some results in near future:
>> 1) finish cls_openflow classifier and iproute part of it
>> 2) extend switchdev API for TC cls and acts offloading (using John's flow api?)
>> 3) use rocker to provide offload for cls_openflow and couple of selected actions
>> 4) improve cls_openflow performance (hashtables etc)
>> 5) improve TC subsystem performance in both slow and fast path
>>     -RTNL mutex and qdisc lock removal/reduction, lockless stats update.
>> 6) implement "named sockets" (working name) and implement TC support for that
>>     -ingress qdisc attach, act_mirred target
>> 7) allow tunnels (VXLAN, Geneve, GRE) to be created as named sockets
>> 8) implement TC act_mpls
>> 9) suggest to switch OVS userspace from OVS genl to TC API
>>
>> This is my personal action list, but you are *very welcome* to step in to help.
>> Point 2) haunts me at night....
>> I believe that John is already working on 2) and part of 3).
>>
>> What do you think?
