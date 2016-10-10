From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: igb driver can cause cache invalidation of non-owned memory?
Date: Mon, 10 Oct 2016 10:38:21 -0700
Message-ID: <CAKgT0UcSkG1Nws1kcUp-QV0jnwdXcXrOZ2m0vsWRziETA-11sw@mail.gmail.com>
References: <0b57cbe2-84f7-6c0a-904a-d166571234b5@cogentembedded.com>
 <20161010.050125.1981283393312167625.davem@davemloft.net> <10474d19-df1a-3b09-917e-70659be3a56c@cogentembedded.com>
 <20161010.075731.2449861168238706.davem@davemloft.net> <f75cf1e1-d7e8-e044-188a-987f05f321a5@cogentembedded.com>
 <CAKgT0Uc2nL1aPoryhNxdbf3+TQO+fOvAZMZDe+=9NaqnHCZPyw@mail.gmail.com> <19aebfc3-5f1a-9206-4493-2255af7269f9@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        cphealy@gmail.com
To: Nikita Yushchenko <nikita.yoush@cogentembedded.com>,
        Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <19aebfc3-5f1a-9206-4493-2255af7269f9@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Oct 10, 2016 at 10:00 AM, Nikita Yushchenko
<nikita.yoush@cogentembedded.com> wrote:
> Hi Alexander
>
> Thanks for your explanation.
>
>> The main reason why this isn't a concern for the igb driver is because
>> we currently pass the page up as read-only.  We don't allow the stack
>> to write into the page by keeping the page count greater than 1 which
>> means that the page is shared.  It isn't until we unmap the page that
>> the page count is allowed to drop to 1 indicating that it is writable.
>
> Doesn't that mean that sync_to_device() in igb_reuse_rx_page() can be
> avoided? If page is read only for entire world, then it can't be dirty
> in cache and thus device can safely write to it without preparation step.

For the sake of correctness we were adding the
dma_sync_single_range_for_device.  Since it is an DMA_FROM_DEVICE
mapping calling it should really have no effect for most DMA mapping
interfaces.

Also you may want to try updating to the 4.8 version of the driver.
It reduces the size of the dma_sync_single_range_for_cpu loops by
reducing the sync size down to the size that was DMAed into the
buffer.

> Nikita
>
>
> P.S.
>
> We are observing strange performance anomaly with igb on imx6q board.
>
> Test is - simple iperf UDP receive. Other host runs
>   iperf -c X.X.X.X -u -b xxxM -t 300 -i 3
>
> Imx6q board can run iperf -s -u, or it can run nothing - result is the same.
>
> While generated traffic (controlled via xxx) is slow, softirq thread on
> imx6 board takes near-zero cpu time.  With increasing xxx, it still is
> near zero - up to some moment about 700 Mbps. At this moment softirqd
> cpu usage suddenly jumps to almost 100%.  Without anything in between:
> it is near-zero with slightly smaller traffic, and it is immediately
>>99% with slightly larger traffic.
>
> Profiling this situation (>99% in softirqd) with perf gives up to 50%
> hits inside cache invalidation loops. That's why originally we thought
> cache invalidation is slow. But having the above dependency between
> traffic and softirq cpu usage (where napi code runs) can't be explained
> with slow cache invalidation.
>
> Also there are additional factors:
> - if UDP traffic is dropped - via iptables, or via forcing error paths
> at different points of network stack - softirqd cpu usage drops back to
> near-zero - although it still does all the same cache invalidations,
> - I tried to modify igb driver to disallow page reuse (made
> igb_add_rx_frag() always returning false). Result was - "border traffic"
> where softirq cpu usage goes from zero to 100% changed from ~700 Mbps to
> ~400 Mbps.
>
> Any ideas what can happen there, and how to debug it?
>
> TIA

I'm adding Eric Dumazet as he is more of an expert on all things NAPI
than I am, but it is my understanding that there are known issues in
regards to how the softirq traffic is handled.  Specifically I believe
the 0->100% accounting problem is due to the way this is all tracked.
You may want to try pulling the most recent net-next kernel and
testing that to see if you still see the same behavior as Eric has
recently added a fix that is meant to allow for better sharing between
softirq polling and applications when dealing with stuff like UDP
traffic.

As far as identifying the problem areas your best bet would be to push
the CPU to 100% and then identify the hot spots.

- Alex
