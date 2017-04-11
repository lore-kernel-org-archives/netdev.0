From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next RFC] Generic XDP
Date: Tue, 11 Apr 2017 09:05:33 -0700
Message-ID: <1491926733.10587.56.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170409.133528.660876505013192371.davem@davemloft.net>
         <20170410183935.GB4730@C02RW35GFVH8.dhcp.broadcom.net>
         <58EBE73A.7090202@iogearbox.net>
         <20170410214131.GE4730@C02RW35GFVH8.dhcp.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        xdp-newbies@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35987 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751992AbdDKQFh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 11 Apr 2017 12:05:37 -0400
In-Reply-To: <20170410214131.GE4730@C02RW35GFVH8.dhcp.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-04-10 at 17:41 -0400, Andy Gospodarek wrote:

> Results with bpf_git_enable=1 and gro off, still only 7.5Mpps.

7.5 Mpps is already a nice number.

We all understand that using native XDP in the driver might give some
extra pps, but for the ones that do not want to patch old drivers, it is
probably good enough.

> 
>     26.34%  ksoftirqd/5      [kernel.vmlinux]              [k] memcpy_erms

Can you investigate to see what are the call graphs ?

Is this from copying headers to skb->head from bnxt driver ?

Some kind of copybreak maybe ?

perf record -a -g sleep 5
perf report --stdio

Copybreak is generally not really useful, and can have downsides.

Much better to let upper stacks deciding this.

For example, there is no point doing copy break for TCP ACK packets that
are going to be consumed immediately.

There is also no point doing copy break in case the packet will be
dropped (say by ... XDP ;) )


>     14.79%  ksoftirqd/5      [bnxt_en]                     [k] bnxt_rx_pkt
>     10.11%  ksoftirqd/5      [kernel.vmlinux]              [k] __build_skb
>      5.01%  ksoftirqd/5      [kernel.vmlinux]              [k] page_frag_free
>      4.66%  ksoftirqd/5      [kernel.vmlinux]              [k] kmem_cache_alloc
>      4.19%  ksoftirqd/5      [kernel.vmlinux]              [k] kmem_cache_free
>      3.67%  ksoftirqd/5      [bnxt_en]                     [k] bnxt_poll
>      2.97%  ksoftirqd/5      [kernel.vmlinux]              [k] netif_receive_skb_internal
>      2.24%  ksoftirqd/5      [kernel.vmlinux]              [k] __napi_alloc_skb
>      1.92%  ksoftirqd/5      [kernel.vmlinux]              [k] eth_type_trans
>      1.78%  ksoftirqd/5      [bnxt_en]                     [k] bnxt_rx_xdp
>      1.62%  ksoftirqd/5      [kernel.vmlinux]              [k] net_rx_action
