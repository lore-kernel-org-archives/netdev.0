From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: Questions on XDP
Date: Sat, 18 Feb 2017 15:31:16 -0800
Message-ID: <CAADnVQKmfu8FR3LvKfLbhKaQhXX9g4N=O-MC+K+frM3MF8XaFQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:33249 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751483AbdBRXbx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 18:31:53 -0500
Received: by mail-wr0-f178.google.com with SMTP id 35so6561246wrw.0
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 15:31:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 18, 2017 at 10:18 AM, Alexander Duyck
<alexander.duyck@gmail.com> wrote:
>
>> XDP_DROP does not require having one page per frame.
>
> Agreed.

why do you think so?
xdp_drop is targeting ddos where in good case
all traffic is passed up and in bad case
most of the traffic is dropped, but good traffic still needs
to be serviced by the layers after. Like other xdp
programs and the stack.
Say ixgbe+xdp goes with 2k per packet,
very soon we will have a bunch of half pages
sitting in the stack and other halfs requiring
complex refcnting and making the actual
ddos mitigation ineffective and forcing nic to drop packets
because it runs out of buffers. Why complicate things?
packet per page approach is simple and effective.
virtio is different. there we don't have hw that needs
to have buffers ready for dma.

> Looking at the Mellanox way of doing it I am not entirely sure it is
> useful.  It looks good for benchmarks but that is about it.  Also I

it's the opposite. It already runs very nicely in production.
In real life it's always a combination of xdp_drop, xdp_tx and
xdp_pass actions.
Sounds like ixgbe wants to do things differently because
of not-invented-here. That new approach may turn
out to be good or bad, but why risk it?
mlx4 approach works.
mlx5 has few issues though, because page recycling
was done too simplistic. Generic page pool/recycling
that all drivers will use should solve that. I hope.
Is the proposal to have generic split-page recycler ?
How that is going to work?

> don't see it extending out to the point that we would be able to
> exchange packets between interfaces which really seems like it should
> be the ultimate goal for XDP_TX.

we don't have a use case for multi-port xdp_tx,
but I'm not objecting to doing it in general.
Just right now I don't see a need to complicate
drivers to do so.

> It seems like eventually we want to be able to peel off the buffer and
> send it to something other than ourselves.  For example it seems like
> it might be useful at some point to use XDP to do traffic
> classification and have it route packets between multiple interfaces
> on a host and it wouldn't make sense to have all of them map every
> page as bidirectional because it starts becoming ridiculous if you
> have dozens of interfaces in a system.

dozen interfaces? Like a single nic with dozen ports?
or many nics with many ports on the same system?
are you trying to build a switch out of x86?
I don't think it's realistic to have multi-terrabit x86 box.
Is it all because of dpdk/6wind demos?
I saw how dpdk was bragging that they can saturate
pcie bus. So? Why is this useful?
Why anyone would care to put a bunch of nics
into x86 and demonstrate that bandwidth of pcie is now
a limiting factor ?

> Also as far as the one page per frame it occurs to me that you will
> have to eventually deal with things like frame replication.

... only in cases where one needs to demo a multi-port
bridge with lots of nics in one x86 box.
I don't see practicality of such setup and I think
that copying full page every time xdp needs to
broadcast is preferred vs doing atomic refcnting
that will slow down the main case. broadcast is slow path.

My strong believe that xdp should not care about
niche architectures. It never meant to be a solution
for everyone and for all use cases.
If xdp sucks on powerpc, so be it.
cpus with 64k pages are doomed. We should
not sacrifice performance on x86 because of ppc.
I think it was a mistake that ixgbe choose to do that
in the past. When mb()s were added because
of powerpc and it took years to introduce dma_mb()
and return performance to good levels.
btw, dma_mb work was awesome.
In xdp I don't want to make such trade-offs.
Really only x86 and arm64 archs matter today.
Everything else is best effort.
