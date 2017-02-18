From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: Questions on XDP
Date: Sat, 18 Feb 2017 15:28:11 -0800
Message-ID: <58A8D88B.3000907@gmail.com>
References: <CAKgT0Uc0RQyK0SCALEUVGBj8JMHCfp+CqiBsTJXN9mat9jUNjQ@mail.gmail.com>
 <58A62979.1050600@gmail.com> <20170218173402.1af86005@redhat.com>
 <1487439675.1311.96.camel@edumazet-glaptop3.roam.corp.google.com>
 <CAKgT0UfE+RN-bK_Hu05kJv62s-edJtkrmkBefHU6UCYQSDdkvw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Netdev <netdev@vger.kernel.org>,
        Tom Herbert <tom@herbertland.com>,
        Alexei Starovoitov <ast@kernel.org>,
        John Fastabend <john.r.fastabend@intel.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33323 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750816AbdBRXez (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 18 Feb 2017 18:34:55 -0500
Received: by mail-pf0-f194.google.com with SMTP id e4so6854494pfg.0
        for <netdev@vger.kernel.org>; Sat, 18 Feb 2017 15:34:54 -0800 (PST)
In-Reply-To: <CAKgT0UfE+RN-bK_Hu05kJv62s-edJtkrmkBefHU6UCYQSDdkvw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 17-02-18 10:18 AM, Alexander Duyck wrote:
> On Sat, Feb 18, 2017 at 9:41 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> On Sat, 2017-02-18 at 17:34 +0100, Jesper Dangaard Brouer wrote:
>>> On Thu, 16 Feb 2017 14:36:41 -0800
>>> John Fastabend <john.fastabend@gmail.com> wrote:
>>>
>>>> On 17-02-16 12:41 PM, Alexander Duyck wrote:
>>>>> So I'm in the process of working on enabling XDP for the Intel NICs
>>>>> and I had a few questions so I just thought I would put them out here
>>>>> to try and get everything sorted before I paint myself into a corner.
>>>>>
>>>>> So my first question is why does the documentation mention 1 frame per
>>>>> page for XDP?
>>>
>>> Yes, XDP defines upfront a memory model where there is only one packet
>>> per page[1], please respect that!
>>>
>>> This is currently used/needed for fast-direct recycling of pages inside
>>> the driver for XDP_DROP and XDP_TX, _without_ performing any atomic
>>> refcnt operations on the page. E.g. see mlx4_en_rx_recycle().

Alex, does your pagecnt_bias trick resolve this? It seems to me that the
recycling is working in ixgbe patches just fine (at least I never see the
allocator being triggered with simple XDP programs). The biggest win for
me right now is to avoid the dma mapping operations.

>>
>>
>> XDP_DROP does not require having one page per frame.
> 
> Agreed.
> 
>> (Look after my recent mlx4 patch series if you need to be convinced)
>>
>> Only XDP_TX is.

I'm still not sure what page per packet buys us on XDP_TX. What was the
explanation again?

>>
>> This requirement makes XDP useless (very OOM likely) on arches with 64K
>> pages.
> 
> Actually I have been having a side discussion with John about XDP_TX.
> Looking at the Mellanox way of doing it I am not entirely sure it is
> useful.  It looks good for benchmarks but that is about it.  Also I
> don't see it extending out to the point that we would be able to
> exchange packets between interfaces which really seems like it should
> be the ultimate goal for XDP_TX.

This is needed if we want XDP to be used for vswitch use cases. We have
a patch running on virtio but really need to get it working on real
hardware before we push it.

> 
> It seems like eventually we want to be able to peel off the buffer and
> send it to something other than ourselves.  For example it seems like
> it might be useful at some point to use XDP to do traffic
> classification and have it route packets between multiple interfaces
> on a host and it wouldn't make sense to have all of them map every
> page as bidirectional because it starts becoming ridiculous if you
> have dozens of interfaces in a system.
> 
> As per our original discussion at netconf if we want to be able to do
> XDP Tx with a fully lockless Tx ring we needed to have a Tx ring per
> CPU that is performing XDP.  The Tx path will end up needing to do the
> map/unmap itself in the case of physical devices but the expense of
> that can be somewhat mitigated on x86 at least by either disabling the
> IOMMU or using identity mapping.  I think this might be the route
> worth exploring as we could then start looking at doing things like
> implementing bridges and routers in XDP and see what performance gains
> can be had there.

One issue I have with TX ring per CPU per device is in my current use
case I have 2k tap/vhost devices and need to scale up to more than that.
Taking the naive approach and making each tap/vhost create a per cpu
ring would be 128k rings on my current dev box. I think locking could
be optional without too much difficulty.

> 
> Also as far as the one page per frame it occurs to me that you will
> have to eventually deal with things like frame replication.  Once that
> comes into play everything becomes much more difficult because the
> recycling doesn't work without some sort of reference counting, and
> since the device interrupt can migrate you could end up with clean-up
> occurring on a different CPUs so you need to have some sort of
> synchronization mechanism.
> 
> Thanks.
> 
> - Alex
> 
