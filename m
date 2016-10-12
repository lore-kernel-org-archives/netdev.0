From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: igb driver can cause cache invalidation of non-owned memory?
Date: Wed, 12 Oct 2016 10:56:32 -0700
Message-ID: <CAKgT0UdqwpjP0b4knt2d4DqS1Z9dR+vg-smkgBTZDeACGGdx=Q@mail.gmail.com>
References: <0b57cbe2-84f7-6c0a-904a-d166571234b5@cogentembedded.com>
 <20161010.050125.1981283393312167625.davem@davemloft.net> <10474d19-df1a-3b09-917e-70659be3a56c@cogentembedded.com>
 <20161010.075731.2449861168238706.davem@davemloft.net> <f75cf1e1-d7e8-e044-188a-987f05f321a5@cogentembedded.com>
 <CAKgT0Uc2nL1aPoryhNxdbf3+TQO+fOvAZMZDe+=9NaqnHCZPyw@mail.gmail.com>
 <19aebfc3-5f1a-9206-4493-2255af7269f9@cogentembedded.com> <CAKgT0UcSkG1Nws1kcUp-QV0jnwdXcXrOZ2m0vsWRziETA-11sw@mail.gmail.com>
 <a0779e4d-3228-8649-1e68-21dffd4249bd@cogentembedded.com> <CAKgT0UfPC_uAn5=+0iiAOGyY7QA-4NWAmedVmWf6TGnywjJR8A@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB01E6F0F@AcuExch.aculab.com> <cbd0f41d-bc01-3f93-9171-2795c61afdc9@cogentembedded.com>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f41.google.com ([209.85.214.41]:33309 "EHLO
        mail-it0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932454AbcJLSEL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 14:04:11 -0400
In-Reply-To: <cbd0f41d-bc01-3f93-9171-2795c61afdc9@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 12, 2016 at 9:11 AM, Nikita Yushchenko
<nikita.yoush@cogentembedded.com> wrote:
>>>> To get some throughput improvement, I propose removal of that
>>>> sync_for_device() before reusing buffer. Will you accept such a patch ;)
>>>
>>> Not one that gets rid of sync_for_device() in the driver.  From what I
>>> can tell there are some DMA APIs that use that to perform the
>>> invalidation on the region of memory so that it can be DMAed into.
>>> Without that we run the risk of having a race between something the
>>> CPU might have placed in the cache and something the device wrote into
>>> memory.  The sync_for_device() call is meant to invalidate the cache
>>> for the region so that when the device writes into memory there is no
>>> risk of that race.
>>
>> I'm not expert, but some thought...
>>
>> Just remember that the cpu can do speculative memory and cache line reads.
>> So you need to ensure there are no dirty cache lines when the receive
>> buffer is setup and no cache lines at all at before looking at the frame.
>
> Exactly.
>
> And because of that, arm does cache invalidation both in sync_for_cpu()
> and sync_for_device().
>
>> If you can 100% guarantee the cpu hasn't dirtied the cache then I
>> think the invalidate prior to reusing the buffer can be skipped.
>> But I wouldn't want to debug that going wrong.
>
> I've written earlier in this thread why it is the case for igb - as long
> as Alexander's statement that igb's buffers are readonly for the stack
> is true. If Alexander's statement is wrong, then igb is vulnerable to
> issue I've described in the first message of this thread.
>
> Btw, we are unable get any breakage with that sync_to_device() removed
> already for a day. And - our tests run with software checksumming,
> because on our hardware i210 is wired connected to DSA switch and in
> this config, no i210 offloading works (i210 hardware gets frames with
> eDSA headers that it can't parse). Thus any breakage should be
> immediately discovered.
>
> And throughput measured by iperf raises from 650 to 850 Mbps.
>
> Nikita

The point I was trying to make is that you are invalidating the cache
in both the sync_for_device and sync_for_cpu.  Do you really need that
for ARM or do you need to perform the invalidation on sync_for_device
if that may be pushed out anyway?  If you aren't running with with
speculative look-ups do you even need the invalidation in
sync_for_cpu?  The underlying problem lives in the code for
__dma_page_cpu_to_dev and __dma_page_dev_to_cpu.  It seems like they
are trying to solve for both speculative and non-speculative setups
and having "FIXME" comments in the code related to this kind of points
to your problems being there.

Changing the driver code for this won't necessarily work on all
architectures, and on top of it we have some changes planned which
will end up making the pages writable in the future to support the
ongoing XDP effort.  That is one of the reasons why I would not be
okay with changing the driver to make this work.

It would make more sense to update the DMA API for
__dma_page_cpu_to_dev on ARM so that you don't invalidate the cache if
the direction is DMA_FROM_DEVICE.

- Alex
