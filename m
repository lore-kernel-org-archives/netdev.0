From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Questions on XDP
Date: Sat, 18 Feb 2017 18:16:47 -0800
Message-ID: <CAKgT0UcpW_MMCgURnB=r5Tezdm9jJSNfOYcNJg8TR1sMKREzPg@mail.gmail.com>
References: <CAADnVQKmfu8FR3LvKfLbhKaQhXX9g4N=O-MC+K+frM3MF8XaFQ@mail.gmail.com>
 <58A8DD34.5040205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:33049 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750905AbdBSCQt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 21:16:49 -0500
Received: by mail-it0-f46.google.com with SMTP id d9so19793544itc.0
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 18:16:48 -0800 (PST)
In-Reply-To: <58A8DD34.5040205@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 18, 2017 at 3:48 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 17-02-18 03:31 PM, Alexei Starovoitov wrote:
>> On Sat, Feb 18, 2017 at 10:18 AM, Alexander Duyck
>> <alexander.duyck@gmail.com> wrote:
>>>
>>>> XDP_DROP does not require having one page per frame.
>>>
>>> Agreed.
>>
>> why do you think so?
>> xdp_drop is targeting ddos where in good case
>> all traffic is passed up and in bad case
>> most of the traffic is dropped, but good traffic still needs
>> to be serviced by the layers after. Like other xdp
>> programs and the stack.
>> Say ixgbe+xdp goes with 2k per packet,
>> very soon we will have a bunch of half pages
>> sitting in the stack and other halfs requiring
>> complex refcnting and making the actual
>> ddos mitigation ineffective and forcing nic to drop packets
>
> I'm not seeing the distinction here. If its a 4k page and
> in the stack the driver will get overrun as well.
>
>> because it runs out of buffers. Why complicate things?
>
> It doesn't seem complex to me and the driver already handles this
> case so it actually makes the drivers simpler because there is only
> a single buffer management path.
>
>> packet per page approach is simple and effective.
>> virtio is different. there we don't have hw that needs
>> to have buffers ready for dma.
>>
>>> Looking at the Mellanox way of doing it I am not entirely sure it is
>>> useful.  It looks good for benchmarks but that is about it.  Also I
>>
>> it's the opposite. It already runs very nicely in production.
>> In real life it's always a combination of xdp_drop, xdp_tx and
>> xdp_pass actions.
>> Sounds like ixgbe wants to do things differently because
>> of not-invented-here. That new approach may turn
>> out to be good or bad, but why risk it?
>> mlx4 approach works.
>> mlx5 has few issues though, because page recycling
>> was done too simplistic. Generic page pool/recycling
>> that all drivers will use should solve that. I hope.
>> Is the proposal to have generic split-page recycler ?
>> How that is going to work?
>>
>
> No, just give the driver a page when it asks for it. How the
> driver uses the page is not the pools concern.
>
>>> don't see it extending out to the point that we would be able to
>>> exchange packets between interfaces which really seems like it should
>>> be the ultimate goal for XDP_TX.
>>
>> we don't have a use case for multi-port xdp_tx,
>> but I'm not objecting to doing it in general.
>> Just right now I don't see a need to complicate
>> drivers to do so.
>
> We are running our vswitch in userspace now for many workloads
> it would be nice to have these in kernel if possible.
>
>>
>>> It seems like eventually we want to be able to peel off the buffer and
>>> send it to something other than ourselves.  For example it seems like
>>> it might be useful at some point to use XDP to do traffic
>>> classification and have it route packets between multiple interfaces
>>> on a host and it wouldn't make sense to have all of them map every
>>> page as bidirectional because it starts becoming ridiculous if you
>>> have dozens of interfaces in a system.
>>
>> dozen interfaces? Like a single nic with dozen ports?
>> or many nics with many ports on the same system?
>> are you trying to build a switch out of x86?
>> I don't think it's realistic to have multi-terrabit x86 box.
>> Is it all because of dpdk/6wind demos?
>> I saw how dpdk was bragging that they can saturate
>> pcie bus. So? Why is this useful?

Actually I was thinking more of an OVS, bridge, or routing
replacement.  Basically with a couple of physical interfaces and then
either veth and/or vhost interfaces.

>> Why anyone would care to put a bunch of nics
>> into x86 and demonstrate that bandwidth of pcie is now
>> a limiting factor ?
>
> Maybe Alex had something else in mind but we have many virtual interfaces
> plus physical interfaces in vswitch use case. Possibly thousands.

I was thinking about the fact that the Mellanox driver is currently
mapping pages as bidirectional, so I was sticking to the device to
device case in regards to that discussion.  For virtual interfaces we
don't even need the DMA mapping, it is just a copy to user space we
have to deal with in the case of vhost.  In that regard I was thinking
we need to start looking at taking XDP_TX one step further and
possibly look at supporting the transmit of an xdp_buf on an unrelated
netdev.  Although it looks like that means adding a netdev pointer to
xdp_buf in order to support returning that.

Anyway I am just running on conjecture at this point.  But it seems
like if we want to make XDP capable of doing transmit we should
support something other than bounce on the same port since that seems
like a "just saturate the bus" use case more than anything.  I suppose
you can do a one armed router, or have it do encap/decap for a tunnel,
but that is about the limits of it.  If we allow it to do transmit on
other netdevs then suddenly this has the potential to replace
significant existing infrastructure.

Sorry if I am stirring the hornets nest here.  I just finished the DMA
API changes to allow DMA page reuse with writable pages on ixgbe, and
igb/i40e/i40evf should be getting the same treatment shortly.  So now
I am looking forward at XDP and just noticing a few things that didn't
seem to make sense given the work I was doing to enable the API.
