From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: igb driver can cause cache invalidation of non-owned memory?
Date: Thu, 13 Oct 2016 13:32:33 -0700
Message-ID: <CAKgT0Uc8inNwwcVWmLSPG6pVb9k=DPpMCGSs1G97YYMyZaB-Ew@mail.gmail.com>
References: <0b57cbe2-84f7-6c0a-904a-d166571234b5@cogentembedded.com>
 <20161010.050125.1981283393312167625.davem@davemloft.net> <10474d19-df1a-3b09-917e-70659be3a56c@cogentembedded.com>
 <20161010.075731.2449861168238706.davem@davemloft.net> <f75cf1e1-d7e8-e044-188a-987f05f321a5@cogentembedded.com>
 <CAKgT0Uc2nL1aPoryhNxdbf3+TQO+fOvAZMZDe+=9NaqnHCZPyw@mail.gmail.com>
 <19aebfc3-5f1a-9206-4493-2255af7269f9@cogentembedded.com> <CAKgT0UcSkG1Nws1kcUp-QV0jnwdXcXrOZ2m0vsWRziETA-11sw@mail.gmail.com>
 <a0779e4d-3228-8649-1e68-21dffd4249bd@cogentembedded.com> <CAKgT0UfPC_uAn5=+0iiAOGyY7QA-4NWAmedVmWf6TGnywjJR8A@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB01E6F0F@AcuExch.aculab.com>
 <cbd0f41d-bc01-3f93-9171-2795c61afdc9@cogentembedded.com> <CAKgT0UdqwpjP0b4knt2d4DqS1Z9dR+vg-smkgBTZDeACGGdx=Q@mail.gmail.com>
 <d34b7175-1024-8cc9-d422-d9f75f56c069@cogentembedded.com> <CAKgT0UdMG4D8CZCVhBD7vF+E5aOk7zyPEp1xXaBukg3v0aYfFg@mail.gmail.com>
 <070385e5-7cfb-4f87-bb53-9b8549ea2c89@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Laight <David.Laight@aculab.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Chris Healy <cphealy@gmail.com>
To: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <070385e5-7cfb-4f87-bb53-9b8549ea2c89@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 13, 2016 at 4:00 AM, Nikita Yushchenko
<nikita.yoush@cogentembedded.com> wrote:
>>>> It would make more sense to update the DMA API for
>>>> __dma_page_cpu_to_dev on ARM so that you don't invalidate the cache if
>>>> the direction is DMA_FROM_DEVICE.
>>>
>>> No, in generic case it's unsafe.
>>>
>>> If CPU issued a write to a location, and sometime later that location is
>>> used as DMA buffer, there is danger that write is still in cache only,
>>> and writeback is pending. Later this writeback can overwrite data
>>> written to memory via DMA, causing corruption.
>>
>> Okay so if I understand it correctly then the invalidation in
>> sync_for_device is to force any writes to be flushed out, and the
>> invalidation in sync_for_cpu is to flush out any speculative reads.
>> So without speculative reads then the sync_for_cpu portion is not
>> needed.  You might want to determine if the core you are using
>> supports the speculative reads, if not you might be able to get away
>> without having to do the sync_for_cpu at all.
>
> pl310 L2 cache controller does support prefetching - and I think most
> arm systems use pl310.
>
>
>>>> Changing the driver code for this won't necessarily work on all
>>>> architectures, and on top of it we have some changes planned which
>>>> will end up making the pages writable in the future to support the
>>>> ongoing XDP effort.  That is one of the reasons why I would not be
>>>> okay with changing the driver to make this work.
>>>
>>> Well I was not really serious about removing that sync_for_device() in
>>> mainline :)   Although >20% throughput win that this provides is
>>> impressive...
>>
>> I agree the improvement is pretty impressive.  The think is there are
>> similar gains we can generate on x86 by stripping out bits and pieces
>> that are needed for other architectures.  I'm just wanting to make
>> certain we aren't optimizing for one architecture at the detriment of
>> others.
>
> Well in ideal world needs of other architectures should not limit x86 -
> and if they do then that's a bug and should be fixed - by designing
> proper set of abstractions :)
>
> Perhaps issue is that "do whatever needed for device to perform DMA
> correctly" semantics of dma_map() / sync_for_device() - and symmetric
> for dma_unmap() / sync_for_cpu() - is too abstract and that hurts
> performance. In particular, "setup i/o" and "sync caches" is different
> activity with conflicting performance properties: for better
> performance, one wants to setup i/o for larger blocks, but sync caches
> for smaller blocks.  Probably separation of these activities into
> different calls is the way for better performance.
>
>
>>> But what about doing something safer, e.g. adding a bit of tracking and
>>> only sync_for_device() what was previously sync_for_cpu()ed?  Will you
>>> accept that?
>>
>> The problem is that as we move things over for XDP we will be looking
>> at having the CPU potentially write to any spot in the region that was
>> mapped as we could append headers to the front or pad data onto the
>> end of the frame.  It is probably safest for us to invalidate the
>> entire region just to make sure we don't have a collision with
>> something that is writing to the page.
>
> Can't comment without knowning particular access patterns that XDP will
> cause. Still rule is simple - "invalidate more" does hurt performance,
> thus need to invalidate minimal required area. To avoid this
> invalidation thing hurting performance on x86 that does not need
> invalidation at all, good idea is to use some compile-time magic - just
> to compile out unneeded things completely.

On x86 we don't perform any invalidation.  We just have the function
pointers usually referencing functions that don't do anything unless
we can't handle the DMA address for some reason as we usually default
to swiotlb setup on x86_64.

> Still, XDP is future question, currently igb does not use it. Why not
> improve sync_for_cpu() / sync_for_device() pairing in the current code?
> I can propare such a patch. If XDP will make it irrelevant in future,
> perhaps it could be just undone (and if this will cause performance
> degradation, then it will be something to work on)

So the plan is to update the code path in the near future.  I'm
working on rewriting the DMA APIs for the drivers now, will update the
page count handling for the pages, and in the near future we should be
able to support XDP and the use of build_skb.  Once we get to that
point there should be a modest bump in performance since we can drop
the memcpy for headers.

>> So for example in the near future I am planning to expand out the
>> DMA_ATTR_SKIP_CPU_SYNC DMA attribute beyond just the ARM architecture
>> to see if I can expand it for use with SWIOTLB.  If we can use this on
>> unmap we might be able to solve some of the existing problems that
>> required us to make the page read-only since we could unmap the page
>> without invalidating any existing writes on the page.
>
> Ack. Actually it is the same decoupling between "setup i/o" and "sync
> caches" I've mentioned above.

Right.  That is kind of what I was thinking as well.  We need to be
able to create and destroy DMA mappable pages without corrupting
things once we hand the pages up the stack.  If we can get away from
having to worry about unmap invalidating any writes from the CPU then
we can get away with using things like build_skb which should give us
a pretty good increase in throughput.

- Alex
