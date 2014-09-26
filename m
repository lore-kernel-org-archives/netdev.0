From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 0/5] udp: Generalize GSO for UDP tunnels
Date: Fri, 26 Sep 2014 23:16:20 +0300
Message-ID: <CAJ3xEMjVx6-XK9Eb2akLHei_43pw10rnHM-zXrOD7pzoXuXaRg@mail.gmail.com>
References: <1411748554-7346-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f178.google.com ([209.85.214.178]:33177 "EHLO
	mail-ob0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754829AbaIZUQV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2014 16:16:21 -0400
Received: by mail-ob0-f178.google.com with SMTP id va2so10678354obc.9
        for <netdev@vger.kernel.org>; Fri, 26 Sep 2014 13:16:20 -0700 (PDT)
In-Reply-To: <1411748554-7346-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 26, 2014 at 7:22 PM, Tom Herbert <therbert@google.com> wrote:
[...]
> Notes:
>   - GSO for GRE/UDP where GRE checksum is enabled does not work.
>     Handling this will require some special case code.
>   - Software GSO now supports many varieties of encapsulation with
>     SKB_GSO_UDP_TUNNEL{_CSUM}. We still need a mechanism to query
>     for device support of particular combinations (I intend to
>     add ndo_gso_check for that).

Tom,

As I wrote you earlier on another thread/s, fact is that there are
upstream drivers who advertize SKB_GSO_UDP_TUNNEL and aren't capable @
this point to issue proper HW segmentation of something which isn't
VXLAN.

Just to make sure, this series isn't expected to introduce a
regression, right? we don't expect the stack to attempt and xmit a
large 64KB UDP packet which isn't vxlan through these devices.



>   - MPLS seems to be the only previous user of inner_protocol. I don't
>     believe these patches can affect that. For supporting GSO with
>     MPLS over UDP, the inner_protocol should be set using the
>     helper functions in this patch.
>   - GSO for L2TP/UDP should also be straightforward now.

> Tested GRE, IPIP, and SIT over fou as well as VLXAN. This was
> done using 200 TCP_STREAMs in netperf.
[...]
>    VXLAN
>       TCP_STREAM TSO enabled on tun interface
>         16.42% TX CPU utilization
>         23.66% RX CPU utilization
>         9081 Mbps
>       TCP_STREAM TSO disabled on tun interface
>         30.32% TX CPU utilization
>         30.55% RX CPU utilization
>         9185 Mbps

so TSO disabled has better BW vs TSO enabled?

>    Baseline (no encp, TSO and LRO enabled)
>       TCP_STREAM
>         11.85% TX CPU utilization
>         15.13% RX CPU utilization
>         9452 Mbps

I would strongly recommend to have a far better baseline when
developing and testing these changes in the stack in the form of 40Gbs
NICs.

Or.


>
> Tom Herbert (5):
>   udp: Generalize skb_udp_segment
>   sit: Set inner IP protocol in sit
>   ipip: Set inner IP protocol in ipip
>   gre: Set inner protocol in v4 and v6 GRE transmit
>   vxlan: Set inner protocol before transmit
>
>  drivers/net/vxlan.c    |  4 ++++
>  include/linux/skbuff.h | 26 +++++++++++++++++++++++--
>  include/net/udp.h      |  3 ++-
>  net/core/skbuff.c      |  1 +
>  net/ipv4/ip_gre.c      |  2 ++
>  net/ipv4/ipip.c        |  2 ++
>  net/ipv4/udp_offload.c | 51 +++++++++++++++++++++++++++++++++++++++++++++-----
>  net/ipv6/ip6_gre.c     |  8 ++++++--
>  net/ipv6/sit.c         |  4 ++++
>  net/ipv6/udp_offload.c |  2 +-
>  10 files changed, 92 insertions(+), 11 deletions(-)
>
> --
> 2.1.0.rc2.206.gedb03e5
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
