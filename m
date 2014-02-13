From: Tom Herbert <therbert@google.com>
Subject: Re: [PATCH 2/3] net: UDP gro_receive accept csum=0
Date: Thu, 13 Feb 2014 14:27:54 -0800
Message-ID: <CA+mtBx_+fc5YdQE+M49QD5ymuD7bfDdedfi2AuCDhU2=CawN6Q@mail.gmail.com>
References: <alpine.DEB.2.02.1402110928070.7090@tomh.mtv.corp.google.com>
	<52FC7D0C.1020601@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Joseph Gasparakis <joseph.gasparakis@intel.com>,
	Jerry Chu <hkchu@google.com>,
	Eric Dumazet <edumazet@google.com>
To: Or Gerlitz <ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:38829 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752294AbaBMW1z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Feb 2014 17:27:55 -0500
Received: by mail-ie0-f171.google.com with SMTP id as1so6922789iec.16
        for <netdev@vger.kernel.org>; Thu, 13 Feb 2014 14:27:54 -0800 (PST)
In-Reply-To: <52FC7D0C.1020601@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Hi Tom,
>
> Considering the patch just "as is" vs. the current code, its OK.
>
> However, as skbs have only one indicator for the status of the checksum
> checks done by the receiving hardware, the basic assertion I thought we
> needed here is to reject skb if either it has the udp mark set or the
> encapsulation field is false, this is according to the conventions set by
> these two commits
>
> 0afb166 vxlan: Add capability of Rx checksum offload for inner packet
> 6a674e9 net: Add support for hardware-offloaded encapsulation
>
> B/c after finalizing the GRO work and decapsulating, skb injected up into
> the TCP stack with ip_summed equals to CHECKSUM_NONE are rejected. If this
> assumption is wrong, maybe we can remove testing the ip_summed field here
> altogether?
>
If I'm interpreting the semantics correctly, when skb->encapsulation
is set the ip_summed is valid for both the inner and outer header
(e.g. CHECKSUM_COMPLETE is always assumed okay for both layers). If
skb->encapsulation is not set then ip_summed is only valid for outer
header. So then the patch is broken in the case that encap is not set,
ip_summed is CHECKSUM_UNNECESSARY, csum == 0, and we need to validate
the inner checksum.

But even worse, is there a fundamental issue where udp4_csum_init is
able to change ip_summed to be CHECKSUM_UNNECESSARY (either check == 0
or ip_summed == CHECKSUM_UNNECESSARY) regardless of
skb->encapsulation, sending the packet into encap_rcv which could
ultimately incorrectly apply ip_summed on the inner TCP/UDP packet?

Tom

> Or.
>
