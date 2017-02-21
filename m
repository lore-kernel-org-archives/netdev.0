From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Questions on XDP
Date: Mon, 20 Feb 2017 19:39:25 -0800
Message-ID: <58ABB66D.60902@gmail.com>
References: <CAADnVQKmfu8FR3LvKfLbhKaQhXX9g4N=O-MC+K+frM3MF8XaFQ@mail.gmail.com>
 <58A8DD34.5040205@gmail.com>
 <CAKgT0UcpW_MMCgURnB=r5Tezdm9jJSNfOYcNJg8TR1sMKREzPg@mail.gmail.com>
 <20170221031829.GA3960@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36099 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750844AbdBUDjn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 22:39:43 -0500
Received: by mail-pg0-f67.google.com with SMTP id a123so13044817pgc.3
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 19:39:43 -0800 (PST)
In-Reply-To: <20170221031829.GA3960@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-20 07:18 PM, Alexei Starovoitov wrote:
> On Sat, Feb 18, 2017 at 06:16:47PM -0800, Alexander Duyck wrote:
>>
>> I was thinking about the fact that the Mellanox driver is currently
>> mapping pages as bidirectional, so I was sticking to the device to
>> device case in regards to that discussion.  For virtual interfaces we
>> don't even need the DMA mapping, it is just a copy to user space we
>> have to deal with in the case of vhost.  In that regard I was thinking
>> we need to start looking at taking XDP_TX one step further and
>> possibly look at supporting the transmit of an xdp_buf on an unrelated
>> netdev.  Although it looks like that means adding a netdev pointer to
>> xdp_buf in order to support returning that.
> 
> xdp_tx variant (via bpf_xdp_redirect as John proposed) should work.
> I don't see why such tx into another netdev cannot be done today.
> The only requirement that it shouldn't be driver specific.
> Whichever way it's implemented in igxbe/i40e should be applicable
> to mlx*, bnx*, nfp at least.

I'm working on it this week so I'll let everyone know how it goes. But
it should work. On virtio it runs OK but will test out ixgbe soon.

> 
>> Anyway I am just running on conjecture at this point.  But it seems
>> like if we want to make XDP capable of doing transmit we should
>> support something other than bounce on the same port since that seems
>> like a "just saturate the bus" use case more than anything.  I suppose
>> you can do a one armed router, or have it do encap/decap for a tunnel,
>> but that is about the limits of it. 
> 
> one armed router is exactly our ILA router use case.
> encap/decap is our load balancer use case.
> 
> From your other email:
>> 1.  The Tx code is mostly just a toy.  We need support for more
>> functional use cases.
> 
> this tx toy is serving real traffic.
> Adding more use cases to xdp is nice, but we cannot sacrifice
> performance of these bread and butter use cases like ddos and lb.
> 

Sure, but above redirect is needed for my use case ;) which is why
I'm pushing for it.

>> 2.  1 page per packet is costly, and blocks use on the intel drivers,
>> mlx4 (after Eric's patches), and 64K page architectures.
> 
> 1 page per packet is costly on archs with 64k pagesize. that's it.
> I see no reason to waste x86 cycles to improve perf on such archs.
> If the argument is truesize socket limits due to 4k vs 2k, then
> please show the patch where split page can work just as fast
> as page per packet and everyone will be giving two thumbs up.
> If we can have 2k truesize with the same xdp_drop/tx performance
> then by all means please do it.
> 
> But I suspect what is really happening is a premature defense
> of likely mediocre ixgbe xdp performance on xdp_drop due to split page...
> If so, that's only ixgbe's fault and trying to make other
> nics slower to have apple to apples with ixgbe is just wrong.
> 

Nope I don't think this is the case drop rates seem good on my side
at least after initial tests. And XDP_TX is a bit slow at the moment
but I suspect batching the send with xmit_more should get it up to
line rate.

>> 3.  Should we support scatter-gather to support 9K jumbo frames
>> instead of allocating order 2 pages?
> 
> we can, if main use case of mtu < 4k doesn't suffer.

Agreed I don't think it should degrade <4k performance. That said
for VM traffic this is absolutely needed. Without TSO enabled VM
traffic is 50% slower on my tests :/.

With tap/vhost support for XDP this becomes necessary. vhost/tap
support for XDP is on my list directly behind ixgbe and redirect
support.

> 
>> If we allow it to do transmit on
>> other netdevs then suddenly this has the potential to replace
>> significant existing infrastructure.
> 
> what existing infrastructure are we talking about?
> The clear containers need is clear :)
> The xdp_redirect into vhost/virtio would be great to have,
> but xdp_tx from one port into another of physical nic
> is much less clear. That's 'saturate pci' demo.

middlebox use cases exist but I doubt those stacks will move to
XDP anytime soon.

> 
>> Sorry if I am stirring the hornets nest here.  I just finished the DMA
>> API changes to allow DMA page reuse with writable pages on ixgbe, and
>> igb/i40e/i40evf should be getting the same treatment shortly.  So now
>> I am looking forward at XDP and just noticing a few things that didn't
>> seem to make sense given the work I was doing to enable the API.
> 
> did I miss the patches that already landed ?
> I don't see any recycling done by i40e_clean_tx_irq or by
> ixgbe_clean_tx_irq ...
> 

ixgbe (and I believe i40e) already do recycling so there is nothing to add
to support this. For example running XDP_DROP tests and XDP_TX tests I never
see any allocations occurring after initial buffers are setup. With the
caveat that XDP_TX is a bit slow still.

.John
