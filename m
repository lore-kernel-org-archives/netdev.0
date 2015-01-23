From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [net-next PATCH v3 00/12] Flow API
Date: Fri, 23 Jan 2015 07:43:48 -0800
Message-ID: <54C26C34.2000309@gmail.com>
References: <54C11703.7030702@mojatatu.com> <20150122153727.GC25797@casper.infradead.org> <54C11ACC.5010005@mojatatu.com> <20150123101019.GF25797@casper.infradead.org> <20150123102421.GB2065@nanopsycho.orion> <20150123110821.GH25797@casper.infradead.org> <20150123113934.GD2065@nanopsycho.orion> <20150123122838.GI25797@casper.infradead.org> <20150123134315.GF2065@nanopsycho.orion> <20150123140724.GJ25797@casper.infradead.org> <20150123152556.GG2065@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Jamal Hadi Salim <jhs@mojatatu.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	simon.horman@netronome.com, sfeldma@gmail.com,
	netdev@vger.kernel.org, davem@davemloft.net, gerlitz.or@gmail.com,
	andy@greyhouse.net, ast@plumgrid.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:43448 "EHLO
	mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752593AbbAWPoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jan 2015 10:44:07 -0500
Received: by mail-oi0-f42.google.com with SMTP id i138so5112747oig.1
        for <netdev@vger.kernel.org>; Fri, 23 Jan 2015 07:44:06 -0800 (PST)
In-Reply-To: <20150123152556.GG2065@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/23/2015 07:25 AM, Jiri Pirko wrote:
> Fri, Jan 23, 2015 at 03:07:24PM CET, tgraf@suug.ch wrote:
>> On 01/23/15 at 02:43pm, Jiri Pirko wrote:
>>> Fri, Jan 23, 2015 at 01:28:38PM CET, tgraf@suug.ch wrote:
>>>> If I understand this correctly then you propose to do the decision on
>>>> whether to implement a flow in software or offload it to hardware in the
>>>> xflows classifier and action. I had exactly the same architecture in mind
>>>> initially when I first approached this and wanted to offload OVS
>>>> datapath flows transparently to hardware.
>>>
>>> Think about xflows as an iface to multiple backends, some sw and some hw.
>>> User will be able to specify which backed he wants to use for particular
>>> "commands".
>>>
>>> So for example, ovs kernel datapath module will implement an xflows
>>> backend and register it as "ovsdp". Rocker will implement another xflows
>>> backend and register it as "rockerdp". Then, ovs userspace will use xflows
>>> api to setup both backends independently, but using the same xflows api.
>>>
>>> It is still up to userspace to decide what should be put where (what
>>> backend to use).
>>
>> OK, sounds good so far. Although we can't completely ditch the existing
>> genl based OVS flow API for obvious backwards compatibility reasons ;-)
>
> Sure.

Replied to the other thread before seeing this, but some comments.

>
>>
>> How does John's API fit into this? How would you expose capabilities
>> through xflows? How would it differ from what John proposes?
>
> This certainly need more thinking. The capabilities could be exposed
> either by separate a genl api (like in this version) or directly via TC
> netlink iface (RTM_GETTFILTERCAP, RTM_GETACTIONCAP). The insides of the
> message can stay the same. I like the second way better.
>

For what its worth I started this route when I did the flow API before
ditching it and going to its own netlink family.

> flow manipulation would happen as standard TC filters/actions manipulation.
> Here, the Netlink messages could be also very similar to what John has now.
>

In fact I think they are almost the same ;) I don't mind doing the
embedding as long as there is some sort of plan for how to attach
filters to hardware. This is where I got stuck. I think you need
a new attach point in the hardware. See my other reply.

>
>>
>> Since this would be a regular tc classifier I assume it could be
>> attached to any tc class and interface and then combined with other
>> classifiers which OVS would not be aware of. How do you intend to
>> resolve such conflicts?
>>
>> Example:
>> eth0:
>>    ingress qdisc:
>>      cls prio 20 u32 match [...]
>>      cls prio 10 xflows [...]
>>
>> If xflows offloads to hardware, the u32 classifier with higher
>> priority is hidden unintentionally.
>
>
> Right. We have to either introduce some limitations for xflows to
> disallow this or let the user to take care of this. But it's similar
> problem as if you use tc with John's API or ovs with John's API.
>

But with the current API its clear that the rules managed by the
Flow API are in front of 'tc' and 'ovs' on ingress. Just the same
as it is clear 'tc' ingress rules are walked before 'ovs' ingress
rules. On egress it is similarly clear that 'ovs' does a forward
rule to a netdev, then 'tc' fiters+qdisc is run, and finally the
hardware flow api is hit.

I also think it is clear that when a packet never enters the software
dataplane _only_ the hardware dataplane rules are used namely the
entries in the Flow API.

The cases I've been experimenting with using Flow API it is clear
on the priority and what rules are being used by looking at counters
and "knowing" the above pipeline mode.

Although as I type this I think a picture would help and some
documentation.

.John


-- 
John Fastabend         Intel Corporation
