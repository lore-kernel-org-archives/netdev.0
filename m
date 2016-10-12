From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: igb driver can cause cache invalidation of non-owned memory?
Date: Wed, 12 Oct 2016 11:30:13 -0700
Message-ID: <CAKgT0UdMG4D8CZCVhBD7vF+E5aOk7zyPEp1xXaBukg3v0aYfFg@mail.gmail.com>
References: <0b57cbe2-84f7-6c0a-904a-d166571234b5@cogentembedded.com>
 <20161010.050125.1981283393312167625.davem@davemloft.net> <10474d19-df1a-3b09-917e-70659be3a56c@cogentembedded.com>
 <20161010.075731.2449861168238706.davem@davemloft.net> <f75cf1e1-d7e8-e044-188a-987f05f321a5@cogentembedded.com>
 <CAKgT0Uc2nL1aPoryhNxdbf3+TQO+fOvAZMZDe+=9NaqnHCZPyw@mail.gmail.com>
 <19aebfc3-5f1a-9206-4493-2255af7269f9@cogentembedded.com> <CAKgT0UcSkG1Nws1kcUp-QV0jnwdXcXrOZ2m0vsWRziETA-11sw@mail.gmail.com>
 <a0779e4d-3228-8649-1e68-21dffd4249bd@cogentembedded.com> <CAKgT0UfPC_uAn5=+0iiAOGyY7QA-4NWAmedVmWf6TGnywjJR8A@mail.gmail.com>
 <063D6719AE5E284EB5DD2968C1650D6DB01E6F0F@AcuExch.aculab.com>
 <cbd0f41d-bc01-3f93-9171-2795c61afdc9@cogentembedded.com> <CAKgT0UdqwpjP0b4knt2d4DqS1Z9dR+vg-smkgBTZDeACGGdx=Q@mail.gmail.com>
 <d34b7175-1024-8cc9-d422-d9f75f56c069@cogentembedded.com>
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
In-Reply-To: <d34b7175-1024-8cc9-d422-d9f75f56c069@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 12, 2016 at 11:12 AM, Nikita Yushchenko
<nikita.yoush@cogentembedded.com> wrote:
>> It would make more sense to update the DMA API for
>> __dma_page_cpu_to_dev on ARM so that you don't invalidate the cache if
>> the direction is DMA_FROM_DEVICE.
>
> No, in generic case it's unsafe.
>
> If CPU issued a write to a location, and sometime later that location is
> used as DMA buffer, there is danger that write is still in cache only,
> and writeback is pending. Later this writeback can overwrite data
> written to memory via DMA, causing corruption.

Okay so if I understand it correctly then the invalidation in
sync_for_device is to force any writes to be flushed out, and the
invalidation in sync_for_cpu is to flush out any speculative reads.
So without speculative reads then the sync_for_cpu portion is not
needed.  You might want to determine if the core you are using
supports the speculative reads, if not you might be able to get away
without having to do the sync_for_cpu at all.

>> The point I was trying to make is that you are invalidating the cache
>> in both the sync_for_device and sync_for_cpu.  Do you really need that
>> for ARM or do you need to perform the invalidation on sync_for_device
>> if that may be pushed out anyway?  If you aren't running with with
>> speculative look-ups do you even need the invalidation in
>> sync_for_cpu?
>
> I'm not lowlevel arm guru and I don't know for sure. Probably another
> CPU core can be accessing locations neighbor page, causing specilative
> load of locations in DMA page.
>
>
>> Changing the driver code for this won't necessarily work on all
>> architectures, and on top of it we have some changes planned which
>> will end up making the pages writable in the future to support the
>> ongoing XDP effort.  That is one of the reasons why I would not be
>> okay with changing the driver to make this work.
>
> Well I was not really serious about removing that sync_for_device() in
> mainline :)   Although >20% throughput win that this provides is
> impressive...

I agree the improvement is pretty impressive.  The think is there are
similar gains we can generate on x86 by stripping out bits and pieces
that are needed for other architectures.  I'm just wanting to make
certain we aren't optimizing for one architecture at the detriment of
others.

> But what about doing something safer, e.g. adding a bit of tracking and
> only sync_for_device() what was previously sync_for_cpu()ed?  Will you
> accept that?
>
> Nikita

The problem is that as we move things over for XDP we will be looking
at having the CPU potentially write to any spot in the region that was
mapped as we could append headers to the front or pad data onto the
end of the frame.  It is probably safest for us to invalidate the
entire region just to make sure we don't have a collision with
something that is writing to the page.

So for example in the near future I am planning to expand out the
DMA_ATTR_SKIP_CPU_SYNC DMA attribute beyond just the ARM architecture
to see if I can expand it for use with SWIOTLB.  If we can use this on
unmap we might be able to solve some of the existing problems that
required us to make the page read-only since we could unmap the page
without invalidating any existing writes on the page.

- Alex
