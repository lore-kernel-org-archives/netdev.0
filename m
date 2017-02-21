From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Questions on XDP
Date: Mon, 20 Feb 2017 20:00:57 -0800
Message-ID: <CAKgT0UciU7sJrSqYKaCNK1iLD72WLcw=pRW5BMukCc99K5a0PQ@mail.gmail.com>
References: <CAADnVQKmfu8FR3LvKfLbhKaQhXX9g4N=O-MC+K+frM3MF8XaFQ@mail.gmail.com>
 <58A8DD34.5040205@gmail.com> <CAKgT0UcpW_MMCgURnB=r5Tezdm9jJSNfOYcNJg8TR1sMKREzPg@mail.gmail.com>
 <20170221031829.GA3960@ast-mbp.thefacebook.com> <58ABB66D.60902@gmail.com>
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
Received: from mail-it0-f50.google.com ([209.85.214.50]:38598 "EHLO
        mail-it0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750931AbdBUEA7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 23:00:59 -0500
Received: by mail-it0-f50.google.com with SMTP id y135so37551633itc.1
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 20:00:58 -0800 (PST)
In-Reply-To: <58ABB66D.60902@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 20, 2017 at 7:39 PM, John Fastabend
<john.fastabend@gmail.com> wrote:
> On 17-02-20 07:18 PM, Alexei Starovoitov wrote:
>> On Sat, Feb 18, 2017 at 06:16:47PM -0800, Alexander Duyck wrote:
>>>
>>> I was thinking about the fact that the Mellanox driver is currently
>>> mapping pages as bidirectional, so I was sticking to the device to
>>> device case in regards to that discussion.  For virtual interfaces we
>>> don't even need the DMA mapping, it is just a copy to user space we
>>> have to deal with in the case of vhost.  In that regard I was thinking
>>> we need to start looking at taking XDP_TX one step further and
>>> possibly look at supporting the transmit of an xdp_buf on an unrelated
>>> netdev.  Although it looks like that means adding a netdev pointer to
>>> xdp_buf in order to support returning that.
>>
>> xdp_tx variant (via bpf_xdp_redirect as John proposed) should work.
>> I don't see why such tx into another netdev cannot be done today.
>> The only requirement that it shouldn't be driver specific.
>> Whichever way it's implemented in igxbe/i40e should be applicable
>> to mlx*, bnx*, nfp at least.
>
> I'm working on it this week so I'll let everyone know how it goes. But
> it should work. On virtio it runs OK but will test out ixgbe soon.
>
>>
>>> Anyway I am just running on conjecture at this point.  But it seems
>>> like if we want to make XDP capable of doing transmit we should
>>> support something other than bounce on the same port since that seems
>>> like a "just saturate the bus" use case more than anything.  I suppose
>>> you can do a one armed router, or have it do encap/decap for a tunnel,
>>> but that is about the limits of it.
>>
>> one armed router is exactly our ILA router use case.
>> encap/decap is our load balancer use case.
>>
>> From your other email:
>>> 1.  The Tx code is mostly just a toy.  We need support for more
>>> functional use cases.
>>
>> this tx toy is serving real traffic.
>> Adding more use cases to xdp is nice, but we cannot sacrifice
>> performance of these bread and butter use cases like ddos and lb.
>>
>
> Sure, but above redirect is needed for my use case ;) which is why
> I'm pushing for it.

I assumed "toy Tx" since I wasn't aware that they were actually
allowing writing to the page.  I think that might work for the XDP_TX
case, but the case where encap/decap is done and then passed up to the
stack runs the risk of causing data corruption on some architectures
if they unmap the page before the stack is done with the skb.  I
already pointed out the issue to the Mellanox guys and that will
hopefully be addressed shortly.

>>> 2.  1 page per packet is costly, and blocks use on the intel drivers,
>>> mlx4 (after Eric's patches), and 64K page architectures.
>>
>> 1 page per packet is costly on archs with 64k pagesize. that's it.
>> I see no reason to waste x86 cycles to improve perf on such archs.
>> If the argument is truesize socket limits due to 4k vs 2k, then
>> please show the patch where split page can work just as fast
>> as page per packet and everyone will be giving two thumbs up.
>> If we can have 2k truesize with the same xdp_drop/tx performance
>> then by all means please do it.
>>
>> But I suspect what is really happening is a premature defense
>> of likely mediocre ixgbe xdp performance on xdp_drop due to split page...
>> If so, that's only ixgbe's fault and trying to make other
>> nics slower to have apple to apples with ixgbe is just wrong.
>>
>
> Nope I don't think this is the case drop rates seem good on my side
> at least after initial tests. And XDP_TX is a bit slow at the moment
> but I suspect batching the send with xmit_more should get it up to
> line rate.

In the case of drop it is just a matter of updating the local
pagecnt_bias.  Just a local increment so no cost there.

As far as the Tx I need to work with John since his current solution
doesn't have any batching support that I saw and that is a major
requirement if we want to get above 7 Mpps for a single core.

>>> 3.  Should we support scatter-gather to support 9K jumbo frames
>>> instead of allocating order 2 pages?
>>
>> we can, if main use case of mtu < 4k doesn't suffer.
>
> Agreed I don't think it should degrade <4k performance. That said
> for VM traffic this is absolutely needed. Without TSO enabled VM
> traffic is 50% slower on my tests :/.
>
> With tap/vhost support for XDP this becomes necessary. vhost/tap
> support for XDP is on my list directly behind ixgbe and redirect
> support.

I'm thinking we just need to turn XDP into something like a
scatterlist for such cases.  It wouldn't take much to just convert the
single xdp_buf into an array of xdp_buf.

>>
>>> If we allow it to do transmit on
>>> other netdevs then suddenly this has the potential to replace
>>> significant existing infrastructure.
>>
>> what existing infrastructure are we talking about?
>> The clear containers need is clear :)
>> The xdp_redirect into vhost/virtio would be great to have,
>> but xdp_tx from one port into another of physical nic
>> is much less clear. That's 'saturate pci' demo.
>
> middlebox use cases exist but I doubt those stacks will move to
> XDP anytime soon.
>
>>
>>> Sorry if I am stirring the hornets nest here.  I just finished the DMA
>>> API changes to allow DMA page reuse with writable pages on ixgbe, and
>>> igb/i40e/i40evf should be getting the same treatment shortly.  So now
>>> I am looking forward at XDP and just noticing a few things that didn't
>>> seem to make sense given the work I was doing to enable the API.
>>
>> did I miss the patches that already landed ?
>> I don't see any recycling done by i40e_clean_tx_irq or by
>> ixgbe_clean_tx_irq ...
>>
>
> ixgbe (and I believe i40e) already do recycling so there is nothing to add
> to support this. For example running XDP_DROP tests and XDP_TX tests I never
> see any allocations occurring after initial buffers are setup. With the
> caveat that XDP_TX is a bit slow still.
>
> .John
>

The ixgbe driver has been doing page recycling for years.  I believe
Dave just pulled the bits from Jeff to enable ixgbe to use build_skb,
update the DMA API, and bulk the page count additions.  There is still
a few tweaks I plan to make to increase the headroom since it is
currently only NET_SKB_PAD + NET_IP_ALIGN and I think we have enough
room for 192 bytes of headroom as I recall.

The code for i40e/i40evf is still pending, though there is an earlier
version of the page recycling code there that is doing the old
get_page/page_ref_inc approach that Eric just pushed for mlx4.  I have
it done in our out-of-tree i40e and i40evf drivers and it will take a
little while to make it all the way to the kernel.

- Alex
