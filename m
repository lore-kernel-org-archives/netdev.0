From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v4 net-next 0/8] flow_dissector: Protocol specific flow dissector offload
Date: Fri, 29 Sep 2017 09:58:28 +0200
Message-ID: <87y3oyylzv.fsf@stressinduktion.org>
References: <20170928235230.22158-1-tom@quantonium.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org, rohit@quantonium.net
To: Tom Herbert <tom@quantonium.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:33131 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750907AbdI2H6b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 03:58:31 -0400
In-Reply-To: <20170928235230.22158-1-tom@quantonium.net> (Tom Herbert's
        message of "Thu, 28 Sep 2017 16:52:22 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@quantonium.net> writes:

> This patch set adds a new offload type to perform flow dissection for
> specific protocols (either by EtherType or by IP protocol). This is
> primary useful to crack open UDP encapsulations (like VXLAN, GUE) for
> the purposes of parsing the encapsulated packet.
>
> Items in this patch set:
> - Create new protocol case in __skb_dissect for ETH_P_TEB. This is based
>   on the code in the GRE dissect function and the special handling in
>   GRE can now be removed (it sets protocol to ETH_P_TEB and returns so
>   goto proto_again is done)
> - Add infrastructure for protocol specific flow dissection offload
> - Add infrastructure to perform UDP flow dissection. Uses same model of
>   GRO where a flow_dissect callback can be associated with a UDP
>   socket
> - Use the infrastructure to support flow dissection of VXLAN and GUE
>
> Tested:
>
> Forced RPS to call flow dissection for VXLAN, FOU, and GUE. Observed
> that inner packet was being properly dissected.

I have the feeling that this patch series changes the behavior of flower
and thus causes uAPI problems.

flower seems to use the flow dissector results for parsing the inner
packets. In case of vxlan in vxlan encapsulation, which seems to become
more common (sigh!) you let part of the flow specification match on the
most inner header, while the flower ingress filter might want to match
inside the first encapsulation only.
