From: Tom Herbert <tom@quantonium.net>
Subject: Re: [PATCH v2 net-next 0/6] flow_dissector: Protocol specific flow
 dissector offload
Date: Wed, 30 Aug 2017 07:50:09 -0700
Message-ID: <CAPDqMepnrDRecc5FcrKK39+_EMvpvpNjhJW7LyReZBGjcZ9TJw@mail.gmail.com>
References: <20170829232711.1465-1-tom@quantonium.net> <874lsp8n2x.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "David S . Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f177.google.com ([209.85.128.177]:33039 "EHLO
        mail-wr0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751377AbdH3OuL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 10:50:11 -0400
Received: by mail-wr0-f177.google.com with SMTP id k94so19238316wrc.0
        for <netdev@vger.kernel.org>; Wed, 30 Aug 2017 07:50:11 -0700 (PDT)
In-Reply-To: <874lsp8n2x.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 30, 2017 at 1:41 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Hello Tom,
>
> Tom Herbert <tom@quantonium.net> writes:
>
>> This patch set adds a new offload type to perform flow dissection for
>> specific protocols (either by EtherType or by IP protocol). This is
>> primary useful to crack open UDP encapsulations (like VXLAN, GUE) for
>> the purposes of parsing the encapsulated packet.
>>
>> Items in this patch set:
>> - Constify skb argument to UDP lookup functions
>> - Create new protocol case in __skb_dissect for ETH_P_TEB. This is based
>>   on the code in the GRE dissect function and the special handling in
>>   GRE can now be removed (it sets protocol to ETH_P_TEB and returns so
>>   goto proto_again is done)
>> - Add infrastructure for protocol specific flow dissection offload
>> - Add infrastructure to perform UDP flow dissection. Uses same model of
>>   GRO where a flow_dissect callback can be associated with a UDP
>>   socket
>> - Use the infrastructure to support flow dissection of VXLAN and GUE
>>
>> Tested:
>>
>> Forced RPS to call flow dissection for VXLAN, FOU, and GUE. Observed
>> that inner packet was being properly dissected.
>>
>> v2: Add signed off
>
> [...]
>
> Can you provide more context on why you did this series? Is the entropy
> insufficient you receive via UDP source ports? I assume this is the case
> for HW RSS hashing but actually not for the software dissector.
>
Hi Hannes,

I think entropy is sufficient looking at UDP source ports, but there
is not universal agreement on that. In any case there are now many
other uses of flow dissector, for those that want DPI like getting TCP
flags, UDP encapsulation is currently a blind spot.

> Btw. we forbid hardware to use L4 information if IP_PROTO is UDP but we
> allow it in RPS (not in IPv6 if flowlabel is present). Your series could
> solve this problem by being more protocol specific and disallow
> fragmentation on a particular quadtuple, very much the same like hw
> encap offload, where we tell the specific port number to the hardware
> and then disallow using L4 information for all other UDP protocols.
>
IMO the fact that HW is protocol specific and operates solely on ports
is a problem (remember Less Is More...). It's better to be protocol
generic and do the socket lookup in SW which no longer has atomic
operations. Matching by bound socket tuple is more accurate than just
a port. However, technically this solution still isn't 100% correct
since it's possible that macvlan or ipvlan may intercede and steer
packet to a namespace where the socket isn't valid.

Tom
