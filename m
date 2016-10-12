From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: igb driver can cause cache invalidation of non-owned memory?
Date: Wed, 12 Oct 2016 08:32:46 -0700
Message-ID: <CAKgT0UfPC_uAn5=+0iiAOGyY7QA-4NWAmedVmWf6TGnywjJR8A@mail.gmail.com>
References: <0b57cbe2-84f7-6c0a-904a-d166571234b5@cogentembedded.com>
 <20161010.050125.1981283393312167625.davem@davemloft.net> <10474d19-df1a-3b09-917e-70659be3a56c@cogentembedded.com>
 <20161010.075731.2449861168238706.davem@davemloft.net> <f75cf1e1-d7e8-e044-188a-987f05f321a5@cogentembedded.com>
 <CAKgT0Uc2nL1aPoryhNxdbf3+TQO+fOvAZMZDe+=9NaqnHCZPyw@mail.gmail.com>
 <19aebfc3-5f1a-9206-4493-2255af7269f9@cogentembedded.com> <CAKgT0UcSkG1Nws1kcUp-QV0jnwdXcXrOZ2m0vsWRziETA-11sw@mail.gmail.com>
 <a0779e4d-3228-8649-1e68-21dffd4249bd@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Chris Healy <cphealy@gmail.com>
To: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:35393 "EHLO
        mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752704AbcJLPdB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 11:33:01 -0400
In-Reply-To: <a0779e4d-3228-8649-1e68-21dffd4249bd@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 11, 2016 at 11:55 PM, Nikita Yushchenko
<nikita.yoush@cogentembedded.com> wrote:
>>>> The main reason why this isn't a concern for the igb driver is because
>>>> we currently pass the page up as read-only.  We don't allow the stack
>>>> to write into the page by keeping the page count greater than 1 which
>>>> means that the page is shared.  It isn't until we unmap the page that
>>>> the page count is allowed to drop to 1 indicating that it is writable.
>>>
>>> Doesn't that mean that sync_to_device() in igb_reuse_rx_page() can be
>>> avoided? If page is read only for entire world, then it can't be dirty
>>> in cache and thus device can safely write to it without preparation step.
>>
>> For the sake of correctness we were adding the
>> dma_sync_single_range_for_device.
>
> Could you please elaborate this "for sake of correctness"?
>
> If by "correctness" you mean ensuring that buffer gets frame DMAed by
> device and that's not broken by cache activity, then:
> - on first use of this buffer after page allocation, sync_for_device()
> is not needed due to previous dma_page_map() call,
> - on later uses of the same buffer, sync_for_device() is not needed due
> to buffer being read-only since dma_page_map() call, thus it can't be
> dirty in cache and thus no writebacks of this area can be possible.
>
> If by "correctness" you mean strict following "ownership" concept - i.e.
> memory area is "owned" either by cpu or by device, and "ownersip" must
> be passed to device before DMA and back to cpu after DMA - then, igb
> driver already breaks these rules anyway:

Sort of.  Keep in mind the recent changes to only sync what the device
had DMAed into is a recent change and was provided by a third party.

> - igb calls dma_map_page() at page allocation time, thus entire page
> becomes "owned" by device,
> - and then, on first use of second buffer inside the page, igb calls
> sync_for_device() for buffer area, despite of that area is already
> "owned" by device,

Right.  However there is nothing wrong with assigning a buffer to the
device twice especially since we are just starting out.  If we wanted
to be more correct we would probably be allocating and deallocating
the pages with the DMA_ATTR_SKIP_CPU_SYNC attribute and then just do
the sync_for_device before reassigning the page back to the device.

> - and later, if a buffer within page gets reused, igb calls
> sync_for_device() for entire buffer, despite of only part of buffer was
> sync_for_cpu()'ed at time of completing receive of previous frame into
> this buffer,

This is going to come into play with future changes we have planned.
If we update things to use build_skb we are going to be writing into
other parts of the page as we will be using that for shared info.

> - and later, igb calls dma_unmap_page(), despite of that part of page
> was sync_for_cpu()'ed and thus is "owned" by CPU.

Right we are looking into finding a fix for that.

> Given all that, not calling sync_for_device() before reusing buffer
> won't make picture much worse :)

Actually it will since you are suggesting taking things in a different
direction then the rest of the community.  What we plan to do is
weaken the dma_map/dma_unmap semantics by likely using
DMA_ATTR_SKIP_CPU_SYNC on the map and unmap calls.

>> Since it is an DMA_FROM_DEVICE
>> mapping calling it should really have no effect for most DMA mapping
>> interfaces.
>
> Unfortunately dma_sync_single_range_for_device() *is* slow on imx6q - it
> does cache invalidation.  I don't really understand why invalidating
> cache can be slow - it only removes data from cache, it should not
> access slow outer memory - but cache invalidation *is* in top of perf
> profiles.
>
> To get some throughput improvement, I propose removal of that
> sync_for_device() before reusing buffer. Will you accept such a patch ;)

Not one that gets rid of sync_for_device() in the driver.  From what I
can tell there are some DMA APIs that use that to perform the
invalidation on the region of memory so that it can be DMAed into.
Without that we run the risk of having a race between something the
CPU might have placed in the cache and something the device wrote into
memory.  The sync_for_device() call is meant to invalidate the cache
for the region so that when the device writes into memory there is no
risk of that race.

What you may want to do is look at the DMA API you are using and
determine if it is functioning correctly.  Most DMA APIs I am familiar
with will either sync Rx data on the sync_for_cpu() or
sync_for_device() but it should not sync on both.  The fact that it is
syncing on both makes me wonder if the API was modified to work around
a buggy driver that didn't follow the proper semantics for buffer
ownership instead of just fixing the buggy driver.

>> Also you may want to try updating to the 4.8 version of the driver.
>> It reduces the size of the dma_sync_single_range_for_cpu loops by
>> reducing the sync size down to the size that was DMAed into the
>> buffer.
>
> Actually that patch came out of the work I'm currently participating in
> ;).  Sure I have it.
>
>> Specifically I believe
>> the 0->100% accounting problem is due to the way this is all tracked.
>
> Thanks for this hint - shame on me not realizing this earlier...
>
>> You may want to try pulling the most recent net-next kernel and
>> testing that to see if you still see the same behavior as Eric has
>> recently added a fix that is meant to allow for better sharing between
>> softirq polling and applications when dealing with stuff like UDP
>> traffic.
>>
>> As far as identifying the problem areas your best bet would be to push
>> the CPU to 100% and then identify the hot spots.
>
> Thanks for hints
>
>
> Nikita
