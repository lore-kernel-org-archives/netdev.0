From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: Flows! Offload them.
Date: Fri, 27 Feb 2015 10:00:14 +0100
Message-ID: <20150227090014.GD2057@nanopsycho.orion>
References: <20150226074214.GF2074@nanopsycho.orion>
 <20150226083758.GA15139@vergenet.net>
 <20150226091628.GA4059@nanopsycho.orion>
 <CA+mtBx-sVMNFng_=DcM5mJTbzrRNsFhTvC8YxvjxcqEXwDcWWw@mail.gmail.com>
 <20150226161705.GH1973@nanopsycho.lan>
 <CA+mtBx8r6OGGYXivBc86662peU81Z3UxxZbVS68a_Nadg5p3ZA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Simon Horman <simon.horman@netronome.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <dborkman@redhat.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jesse Gross <jesse@nicira.com>, jpettit@nicira.com,
	Joe Stringer <joestringer@nicira.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Scott Feldman <sfeldma@gmail.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	John Linville <linville@tuxdriver.com>, shrijeet@gmail.com,
	Andy Gospodarek <gospo@cumulusnetworks.com>, bcrl@kvack.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:35971 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754005AbbB0JAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 04:00:21 -0500
Received: by wevk48 with SMTP id k48so18516916wev.3
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 01:00:19 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CA+mtBx8r6OGGYXivBc86662peU81Z3UxxZbVS68a_Nadg5p3ZA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Feb 26, 2015 at 07:15:24PM CET, therbert@google.com wrote:
>On Thu, Feb 26, 2015 at 8:17 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>> Thu, Feb 26, 2015 at 05:04:31PM CET, therbert@google.com wrote:
>>>On Thu, Feb 26, 2015 at 1:16 AM, Jiri Pirko <jiri@resnulli.us> wrote:
>>>> Thu, Feb 26, 2015 at 09:38:01AM CET, simon.horman@netronome.com wrote:
>>>>>Hi Jiri,
>>>>>
>>>>>On Thu, Feb 26, 2015 at 08:42:14AM +0100, Jiri Pirko wrote:
>>>>>> Hello everyone.
>>>>>>
>>>>>> I would like to discuss big next step for switch offloading. Probably
>>>>>> the most complicated one we have so far. That is to be able to offload flows.
>>>>>> Leaving nftables aside for a moment, I see 2 big usecases:
>>>>>> - TC filters and actions offload.
>>>>>> - OVS key match and actions offload.
>>>>>>
>>>>>> I think it might sense to ignore OVS for now. The reason is ongoing efford
>>>>>> to replace OVS kernel datapath with TC subsystem. After that, OVS offload
>>>>>> will not longer be needed and we'll get it for free with TC offload
>>>>>> implementation. So we can focus on TC now.
>>>>>>
>>>>>> Here is my list of actions to achieve some results in near future:
>>>>>> 1) finish cls_openflow classifier and iproute part of it
>>>>>> 2) extend switchdev API for TC cls and acts offloading (using John's flow api?)
>>>>>> 3) use rocker to provide offload for cls_openflow and couple of selected actions
>>>>>> 4) improve cls_openflow performance (hashtables etc)
>>>>>> 5) improve TC subsystem performance in both slow and fast path
>>>>>>     -RTNL mutex and qdisc lock removal/reduction, lockless stats update.
>>>>>> 6) implement "named sockets" (working name) and implement TC support for that
>>>>>>     -ingress qdisc attach, act_mirred target
>>>>>> 7) allow tunnels (VXLAN, Geneve, GRE) to be created as named sockets
>>>>>> 8) implement TC act_mpls
>>>>>> 9) suggest to switch OVS userspace from OVS genl to TC API
>>>>>>
>>>>>> This is my personal action list, but you are *very welcome* to step in to help.
>>>>>> Point 2) haunts me at night....
>>>>>> I believe that John is already working on 2) and part of 3).
>>>>>>
>>>>>> What do you think?
>>>>>
>>>> >From my point of view the question of replacing the kernel datapath with TC
>>>>>is orthogonal to the question of flow offloads. This is because I believe
>>>>>there is some consensus around the idea that, at least in the case of Open
>>>>>vSwitch, the decision to offload flows should made in user-space where
>>>>>flows are already managed. And in that case datapath will not be
>>>>>transparently offloading of flows.  And thus flow offload may be performed
>>>>>independently of the kernel datapath, weather that be via flow manipulation
>>>>>portions of John's Flow API, TC, or some other means.
>>>>
>>>> Well, on netdev01, I believe that a consensus was reached that for every
>>>> switch offloaded functionality there has to be an implementation in
>>>> kernel. What John's Flow API originally did was to provide a way to
>>>> configure hardware independently of kernel. So the right way is to
>>>> configure kernel and, if hw allows it, to offload the configuration to hw.
>>>>
>>>> In this case, seems to me logical to offload from one place, that being
>>>> TC. The reason is, as I stated above, the possible conversion from OVS
>>>> datapath to TC.
>>>>
>>>Sorry if I'm asking dumb questions, but this is about where I usually
>>>start to get lost in these discussions ;-). Is the aim of switch
>>>offload to offload OVS or kernel functions of routing, iptables, tc,
>>>etc.? These are very different I believe. As far as I can tell OVS
>>>model of "flows" (like Openflow) is currently incompatible with the
>>>rest of the kernel. So if the plan is convert OVS datapath to TC does
>>>that mean introducing that model into core kernel?
>>
>> The thing is that you can achieve very similar model as OVS with TC.
>> OVS uses rx_handler.
>> TC uses handle_ing hook.
>> Those are in the same place in the receive path.
>> After that, ovs processes skb through key matches, and does some actions.
>> The same is done in TC cls_* and act_*.
>> Finally skb is forwarded to some netdev by dev_queue_xmit (in both OVS
>> and TC).
>>
>> I certainly simplified things. But I do not see the different model you
>> are talking about.
>>
>But, routing (aka switching) in the stack is not configured through
>TC. We have a whole forwarding and routing infrastructure (eg.
>iproute) with optimizations that  allow routes to be cached in
>sockets, etc. To me, it seems like offloading that basic functionality
>is a prerequisite before attempting to offload more advanced policy
>mechanisms of TC, netfilter, etc.

I believe we are talking about 2 separate cases. Case one is to
offload L2, L3 traditional infrastructure we have in kernel now.

Case two is to offload independent OVS DP infrastructure. I'm just saying
that OVS DP can be replaced by TC (subpart of that including ingress
qdisq, cls and acts). Then we can offload this TC subpart.

These 2 cases can be handled separatelly.

Also I believe that offload needs to be done per-partes one way or
another. So I imagine that cls_openflow can be the first classifier to
get offloaded.
