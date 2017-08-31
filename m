From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v2 net-next 0/6] flow_dissector: Protocol specific flow dissector offload
Date: Thu, 31 Aug 2017 12:11:33 +0200
Message-ID: <87h8wonj1m.fsf@stressinduktion.org>
References: <20170829232711.1465-1-tom@quantonium.net>
        <874lsp8n2x.fsf@stressinduktion.org>
        <CAPDqMepnrDRecc5FcrKK39+_EMvpvpNjhJW7LyReZBGjcZ9TJw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:45685 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750972AbdHaKLg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2017 06:11:36 -0400
In-Reply-To: <CAPDqMepnrDRecc5FcrKK39+_EMvpvpNjhJW7LyReZBGjcZ9TJw@mail.gmail.com>
        (Tom Herbert's message of "Wed, 30 Aug 2017 07:50:09 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Tom Herbert <tom@quantonium.net> writes:

> On Wed, Aug 30, 2017 at 1:41 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> Hello Tom,
>>
>> Tom Herbert <tom@quantonium.net> writes:
>>
>>> This patch set adds a new offload type to perform flow dissection for
>>> specific protocols (either by EtherType or by IP protocol). This is
>>> primary useful to crack open UDP encapsulations (like VXLAN, GUE) for
>>> the purposes of parsing the encapsulated packet.
>>>
>>> Items in this patch set:
>>> - Constify skb argument to UDP lookup functions
>>> - Create new protocol case in __skb_dissect for ETH_P_TEB. This is based
>>>   on the code in the GRE dissect function and the special handling in
>>>   GRE can now be removed (it sets protocol to ETH_P_TEB and returns so
>>>   goto proto_again is done)
>>> - Add infrastructure for protocol specific flow dissection offload
>>> - Add infrastructure to perform UDP flow dissection. Uses same model of
>>>   GRO where a flow_dissect callback can be associated with a UDP
>>>   socket
>>> - Use the infrastructure to support flow dissection of VXLAN and GUE
>>>
>>> Tested:
>>>
>>> Forced RPS to call flow dissection for VXLAN, FOU, and GUE. Observed
>>> that inner packet was being properly dissected.
>>>
>>> v2: Add signed off
>>
>> [...]
>>
>> Can you provide more context on why you did this series? Is the entropy
>> insufficient you receive via UDP source ports? I assume this is the case
>> for HW RSS hashing but actually not for the software dissector.
>>
> Hi Hannes,
>
> I think entropy is sufficient looking at UDP source ports, but there
> is not universal agreement on that. In any case there are now many
> other uses of flow dissector, for those that want DPI like getting TCP
> flags, UDP encapsulation is currently a blind spot.

Regarding entropy, Toeplitz seems to do worse while mixing it in
compared to jenkins hash used in flow dissection in software.

I have a number of things I don't understand yet and haven't wound my
head around, yet:

* it seems you implemented boundless looping in the flow dissection. If
  you do know the outer vxlan tunnel parameter (dst-ip and port) I
  basically can let your implementation loop a while until the packet
  data is exceeded. This is not good. This seriously needs to be limited
  to one layer above the tunnels. Never trust user input! It seems a
  user can even overwrite the VID in the flow keys while reparsing? (I
  got this only from looking at the code)

* MPLS/VPLS do encapsulate IP or Ethernet depnding on the label but
  don't have representative sockets but would need other ways to query
  inner content - is this relevant to you.

>> Btw. we forbid hardware to use L4 information if IP_PROTO is UDP but we
>> allow it in RPS (not in IPv6 if flowlabel is present). Your series could
>> solve this problem by being more protocol specific and disallow
>> fragmentation on a particular quadtuple, very much the same like hw
>> encap offload, where we tell the specific port number to the hardware
>> and then disallow using L4 information for all other UDP protocols.
>>
> IMO the fact that HW is protocol specific and operates solely on ports
> is a problem (remember Less Is More...). It's better to be protocol
> generic and do the socket lookup in SW which no longer has atomic
> operations. Matching by bound socket tuple is more accurate than just
> a port. However, technically this solution still isn't 100% correct
> since it's possible that macvlan or ipvlan may intercede and steer
> packet to a namespace where the socket isn't valid.

Your implementation needs to do hierachical socket lookups with checking
the bound interface and traverse the stack figure out the next stacked
interface and use that for the next socket lookup.

I don't think this approach works, to be honest.

Bye,
Hannes
