From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Questions on XDP
Date: Tue, 21 Feb 2017 09:44:51 -0800
Message-ID: <CAKgT0UdFo1kKdPV=bL8m_y+o37t+m9NNesA8XAUE8pCtcexUaw@mail.gmail.com>
References: <CAADnVQKmfu8FR3LvKfLbhKaQhXX9g4N=O-MC+K+frM3MF8XaFQ@mail.gmail.com>
 <58A8DD34.5040205@gmail.com> <CAKgT0UcpW_MMCgURnB=r5Tezdm9jJSNfOYcNJg8TR1sMKREzPg@mail.gmail.com>
 <20170221031829.GA3960@ast-mbp.thefacebook.com> <58ABB66D.60902@gmail.com>
 <CAKgT0UciU7sJrSqYKaCNK1iLD72WLcw=pRW5BMukCc99K5a0PQ@mail.gmail.com> <20170221075523.GA29348@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: John Fastabend <john.fastabend@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f45.google.com ([209.85.214.45]:37396 "EHLO
        mail-it0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754225AbdBURoy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 12:44:54 -0500
Received: by mail-it0-f45.google.com with SMTP id 203so51713731ith.0
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 09:44:54 -0800 (PST)
In-Reply-To: <20170221075523.GA29348@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 20, 2017 at 11:55 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Mon, Feb 20, 2017 at 08:00:57PM -0800, Alexander Duyck wrote:
>>
>> I assumed "toy Tx" since I wasn't aware that they were actually
>> allowing writing to the page.  I think that might work for the XDP_TX
>> case,
>
> Take a look at samples/bpf/xdp_tx_iptunnel_kern.c
> It's close enough approximation of load balancer.
> The packet header is rewritten by the bpf program.
> That's where dma_bidirectional requirement came from.

Thanks.  I will take a look at it.

>> but the case where encap/decap is done and then passed up to the
>> stack runs the risk of causing data corruption on some architectures
>> if they unmap the page before the stack is done with the skb.  I
>> already pointed out the issue to the Mellanox guys and that will
>> hopefully be addressed shortly.
>
> sure. the path were xdp program does decap and passes to the stack
> is not finished. To make it work properly we need to expose
> csum complete field to the program at least.

I would think the checksum is something that could be validated after
the frame has been modified.  In the case of encapsulating or
decapsulating a TCP frame you could probably assume the inner TCP
checksum is valid and then you only have to deal with the checksum if
it is present in the outer tunnel header.  Basically deal with it like
we do the local checksum offload, only you would have to compute the
pseudo header checksum for the inner and outer headers since you can't
use the partial checksum of the inner header.

>> As far as the Tx I need to work with John since his current solution
>> doesn't have any batching support that I saw and that is a major
>> requirement if we want to get above 7 Mpps for a single core.
>
> I think we need to focus on both Mpps and 'perf report' together.

Agreed, I usually look over both as one tells you how fast you are
going and the other tells you where the bottlenecks are.

> Single core doing 7Mpps and scaling linearly to 40Gbps line rate
> is much better than single core doing 20Mpps and not scaling at all.
> There could be sw inefficiencies and hw limits, hence 'perf report'
> is must have when discussing numbers.

Agreed.

> I think long term we will be able to agree on a set of real life
> use cases and corresponding set of 'blessed' bpf programs and
> create a table of nic, driver, use case 1, 2, 3, single core, multi.
> Making level playing field for all nic vendors is one of the goals.
>
> Right now we have xdp1, xdp2 and xdp_tx_iptunnel benchmarks.
> They are approximations of ddos, router, load balancer
> use cases. They obviously need work to get to 'blessed' shape,
> but imo quite good to do vendor vs vendor comparison for
> the use cases that we care about.
> Eventually nic->vm and vm->vm use cases via xdp_redirect should
> be added to such set of 'blessed' benchmarks too.
> I think so far we avoided falling into trap of microbenchmarking wars.

I'll keep this in mind for upcoming patches.

>> >>> 3.  Should we support scatter-gather to support 9K jumbo frames
>> >>> instead of allocating order 2 pages?
>> >>
>> >> we can, if main use case of mtu < 4k doesn't suffer.
>> >
>> > Agreed I don't think it should degrade <4k performance. That said
>> > for VM traffic this is absolutely needed. Without TSO enabled VM
>> > traffic is 50% slower on my tests :/.
>> >
>> > With tap/vhost support for XDP this becomes necessary. vhost/tap
>> > support for XDP is on my list directly behind ixgbe and redirect
>> > support.
>>
>> I'm thinking we just need to turn XDP into something like a
>> scatterlist for such cases.  It wouldn't take much to just convert the
>> single xdp_buf into an array of xdp_buf.
>
> datapath has to be fast. If xdp program needs to look at all
> bytes of the packet the performance is gone. Therefore I don't see
> a need to expose an array of xdp_buffs to the program.

The program itself may not care, but if we are going to deal with
things like Tx and Drop we need to make sure we drop all the parts of
the frame.  An alternate idea I have been playing around with is just
having the driver repeat the last action until it hits the end of a
frame.  So XDP would analyze the first 1.5K or 3K of the frame, and
then tell us to either drop it, pass it, or xmit it.  After that we
would just repeat that action until we hit the end of the frame.  The
only limitation is that it means XDP is limited to only accessing the
first 1514 bytes.

> The alternative would be to add a hidden field to xdp_buff that keeps
> SG in some form and data_end will point to the end of linear chunk.
> But you cannot put only headers into linear part. If program
> needs to see something that is after data_end, it will drop the packet.
> So it's not at all split-header model. 'data-data_end' chunk
> should cover as much as possible. We cannot get into sg games
> while parsing the packet inside the program. Everything
> that program needs to see has to be in the linear part.

Agreed, I wouldn't want to do header split.  My thought is to break
things up so that you have 1.5K at least.  The rest should hopefully
just be data that we wouldn't need to look at.

> I think such model will work well for jumbo packet case.
> but I don't think it will work for VM's tso.
> For xdp program to pass csum_partial packet from vm into nic
> in a meaninful way it needs to gain knowledge of ip, l4, csum
> and bunch of other meta-data fields that nic needs to do TSO.
> I'm not sure it's worth exposing all that to xdp. Instead
> can we make VM to do segmentation, so that xdp program don't
> need to deal with gso packets ?

GSO/TSO is getting into advanced stuff I would rather not have to get
into right now.  I figure we need to take this portion one step at a
time.  To support GSO we need more information like the mss.

I think for now if we can get xmit bulking working that should get us
behavior close enough to see some of the benefits of GRO as we can
avoid having vhost transition between user space and kernel space
quite so much.

> I think the main cost is packet csum and for this something
> like xdp_tx_with_pseudo_header() helper can work.
> xdp program will see individual packets with pseudo header
> and hw nic will do final csum over packet.
> The program will see csum field as part of xdp_buff
> and if it's csum_partial it will use xdp_tx_with_pseudo_header()
> to transmit the packet instead of xdp_redirect or xdp_tx.
> The call may look like:
> xdp_tx_with_pseudo_header(xdp_buff, ip_off, tcp_off);
> and these two offsets the program will compute based on
> the packet itself and not metadata that came from VM.
> In other words I'd like xdp program to deal with raw packets
> as much as possible. pseudo header is part of the packet.
> So the only metadata program needs is whether packet has
> pseudo header or not.
> Saying it differently: whether the packet came from physical
> nic and in xdp_buff we have csum field (from hw rx descriptor)
> that has csum complete meaning or the packet came from VM,
> pseudo header is populated and xdp_buff->csum is empty.
> From physical nic the packet will travel through xdp program
> into VM and csum complete is nicely covers all encap/decap
> cases whether they're done by xdp program or by stack inside VM.
> From VM the packet similarly travels through xdp programs
> and when it's about to hit physical nic the last program
> calls xdp_tx_with_pseudo_header(). Any packet manipulations
> that are done in between are done cleanly without worrying
> about gso and adjustments to metadata.
>
>> The ixgbe driver has been doing page recycling for years.  I believe
>> Dave just pulled the bits from Jeff to enable ixgbe to use build_skb,
>> update the DMA API, and bulk the page count additions.  There is still
>> a few tweaks I plan to make to increase the headroom since it is
>> currently only NET_SKB_PAD + NET_IP_ALIGN and I think we have enough
>> room for 192 bytes of headroom as I recall.
>
> Nice. Why keep old ixgbe_construct_skb code around?
> With split page and build_skb perf should be great for small and large
> packets ?

I kept it around mostly just as a fall back in case something goes
wrong.  The last time I pushed the build_skb code I had to revert it
shortly afterwards as we found the DMA API did't support he use of
build_skb on DMA mapped pages.  This way if we find there is an
architecture that doesn't play well with this we have a fall back we
can enable until we can get it fixed.

> Unless I wasn't clear earlier:
> Please release your ixgbe and i40e xdp patches in whatever shape
> they are right now. I'm ready to test with xdp1+xdp2+xdp_tx_iptunnel :)

The i40e patches are going to be redone since they need to be rebased
on top of the build_skb changes for our out-of-tree driver and then
resubmitted once those changes are upstream.  So it will probably be a
few weeks before we have them ready.

I'll let John talk to when the ixgbe changes can be submitted.

- Alex
