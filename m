From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Subject: Re: igb driver can cause cache invalidation of non-owned memory?
Date: Wed, 12 Oct 2016 09:55:31 +0300
Message-ID: <a0779e4d-3228-8649-1e68-21dffd4249bd@cogentembedded.com>
References: <0b57cbe2-84f7-6c0a-904a-d166571234b5@cogentembedded.com>
 <20161010.050125.1981283393312167625.davem@davemloft.net>
 <10474d19-df1a-3b09-917e-70659be3a56c@cogentembedded.com>
 <20161010.075731.2449861168238706.davem@davemloft.net>
 <f75cf1e1-d7e8-e044-188a-987f05f321a5@cogentembedded.com>
 <CAKgT0Uc2nL1aPoryhNxdbf3+TQO+fOvAZMZDe+=9NaqnHCZPyw@mail.gmail.com>
 <19aebfc3-5f1a-9206-4493-2255af7269f9@cogentembedded.com>
 <CAKgT0UcSkG1Nws1kcUp-QV0jnwdXcXrOZ2m0vsWRziETA-11sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        cphealy@gmail.com
To: Alexander Duyck <alexander.duyck@gmail.com>,
        Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:35932 "EHLO
        mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754681AbcJLGzu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 02:55:50 -0400
Received: by mail-lf0-f51.google.com with SMTP id b75so63882948lfg.3
        for <netdev@vger.kernel.org>; Tue, 11 Oct 2016 23:55:44 -0700 (PDT)
In-Reply-To: <CAKgT0UcSkG1Nws1kcUp-QV0jnwdXcXrOZ2m0vsWRziETA-11sw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>>> The main reason why this isn't a concern for the igb driver is because
>>> we currently pass the page up as read-only.  We don't allow the stack
>>> to write into the page by keeping the page count greater than 1 which
>>> means that the page is shared.  It isn't until we unmap the page that
>>> the page count is allowed to drop to 1 indicating that it is writable.
>>
>> Doesn't that mean that sync_to_device() in igb_reuse_rx_page() can be
>> avoided? If page is read only for entire world, then it can't be dirty
>> in cache and thus device can safely write to it without preparation step.
> 
> For the sake of correctness we were adding the
> dma_sync_single_range_for_device.

Could you please elaborate this "for sake of correctness"?

If by "correctness" you mean ensuring that buffer gets frame DMAed by
device and that's not broken by cache activity, then:
- on first use of this buffer after page allocation, sync_for_device()
is not needed due to previous dma_page_map() call,
- on later uses of the same buffer, sync_for_device() is not needed due
to buffer being read-only since dma_page_map() call, thus it can't be
dirty in cache and thus no writebacks of this area can be possible.

If by "correctness" you mean strict following "ownership" concept - i.e.
memory area is "owned" either by cpu or by device, and "ownersip" must
be passed to device before DMA and back to cpu after DMA - then, igb
driver already breaks these rules anyway:
- igb calls dma_map_page() at page allocation time, thus entire page
becomes "owned" by device,
- and then, on first use of second buffer inside the page, igb calls
sync_for_device() for buffer area, despite of that area is already
"owned" by device,
- and later, if a buffer within page gets reused, igb calls
sync_for_device() for entire buffer, despite of only part of buffer was
sync_for_cpu()'ed at time of completing receive of previous frame into
this buffer,
- and later, igb calls dma_unmap_page(), despite of that part of page
was sync_for_cpu()'ed and thus is "owned" by CPU.

Given all that, not calling sync_for_device() before reusing buffer
won't make picture much worse :)

> Since it is an DMA_FROM_DEVICE
> mapping calling it should really have no effect for most DMA mapping
> interfaces.

Unfortunately dma_sync_single_range_for_device() *is* slow on imx6q - it
does cache invalidation.  I don't really understand why invalidating
cache can be slow - it only removes data from cache, it should not
access slow outer memory - but cache invalidation *is* in top of perf
profiles.

To get some throughput improvement, I propose removal of that
sync_for_device() before reusing buffer. Will you accept such a patch ;)


> Also you may want to try updating to the 4.8 version of the driver.
> It reduces the size of the dma_sync_single_range_for_cpu loops by
> reducing the sync size down to the size that was DMAed into the
> buffer.

Actually that patch came out of the work I'm currently participating in
;).  Sure I have it.

> Specifically I believe
> the 0->100% accounting problem is due to the way this is all tracked.

Thanks for this hint - shame on me not realizing this earlier...

> You may want to try pulling the most recent net-next kernel and
> testing that to see if you still see the same behavior as Eric has
> recently added a fix that is meant to allow for better sharing between
> softirq polling and applications when dealing with stuff like UDP
> traffic.
> 
> As far as identifying the problem areas your best bet would be to push
> the CPU to 100% and then identify the hot spots.

Thanks for hints


Nikita
