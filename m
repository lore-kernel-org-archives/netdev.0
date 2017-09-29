From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v4 net-next 0/8] flow_dissector: Protocol specific flow
 dissector offload
Date: Fri, 29 Sep 2017 08:48:55 -0700
Message-ID: <CALx6S37J-Uv11TJuNFj4et==NFZj9W0v9s_c-Qowqcs--Kx_VQ@mail.gmail.com>
References: <20170928235230.22158-1-tom@quantonium.net> <87y3oyylzv.fsf@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tom Herbert <tom@quantonium.net>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Rohit Seth <rohit@quantonium.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:49136 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751828AbdI2Ps5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 11:48:57 -0400
Received: by mail-qk0-f170.google.com with SMTP id a128so42572qkc.5
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 08:48:57 -0700 (PDT)
In-Reply-To: <87y3oyylzv.fsf@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 29, 2017 at 12:58 AM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> Tom Herbert <tom@quantonium.net> writes:
>
>> This patch set adds a new offload type to perform flow dissection for
>> specific protocols (either by EtherType or by IP protocol). This is
>> primary useful to crack open UDP encapsulations (like VXLAN, GUE) for
>> the purposes of parsing the encapsulated packet.
>>
>> Items in this patch set:
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
>
> I have the feeling that this patch series changes the behavior of flower
> and thus causes uAPI problems.
>
The flow_dissector interface is not a uAPI. And in this case we are
not changing behavior, we are extending the functionality which is a
routine occurrence in this facility. Semantically UDP encapsulations
are no different than other encapsulations, it's just that the details
are different. This patch set brings us closer consistency across
various encapsulation protocols. For instance, if some were to upgrade
use of GRE to GRE/UDP the user would likely expect that the UDP is
mostly transparent and that accelerations and parsing (like
flow_disseector) of GRE are the same.

> flower seems to use the flow dissector results for parsing the inner
> packets. In case of vxlan in vxlan encapsulation, which seems to become
> more common (sigh!) you let part of the flow specification match on the
> most inner header, while the flower ingress filter might want to match
> inside the first encapsulation only.

I don't see why this would be any different than if flower wanted to
match on the outer headers of a GRE packet versus the inner headers.
In any case, there are already FLOW_DISSECTOR_F_STOP_AT_L3,
FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL, and
FLOW_DISSECTOR_F_STOP_AT_ENCAP-- those should be sufficient to control
the depth of parsing for flower or other use cases.

Tom
