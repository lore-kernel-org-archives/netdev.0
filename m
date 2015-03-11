From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH net-next v3 2/2] enic: use netdev_dma_alloc
Date: Wed, 11 Mar 2015 07:00:19 -0700
Message-ID: <55004A73.3040904@gmail.com>
References: <1426009384-11544-1-git-send-email-_govind@gmx.com> <1426009384-11544-3-git-send-email-_govind@gmx.com> <54FF50B0.3080900@redhat.com> <alpine.LNX.2.03.1503111428210.3394@ws.cisco>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:32883 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750856AbbCKOAW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 10:00:22 -0400
Received: by igbhl2 with SMTP id hl2so36942590igb.0
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 07:00:21 -0700 (PDT)
In-Reply-To: <alpine.LNX.2.03.1503111428210.3394@ws.cisco>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/2015 02:27 AM, Govindarajulu Varadarajan wrote:
>
> On Tue, 10 Mar 2015, Alexander Duyck wrote:
>
>>
>> On 03/10/2015 10:43 AM, Govindarajulu Varadarajan wrote:
>>> This patches uses dma cache skb allocator fot rx buffers.
>>>
>>> netdev_dma_head is initialized per rq. All calls to
>>> netdev_dma_alloc_skb() and
>>> netdev_dma_frag_unmap() happens in napi_poll and they are serialized.
>>>
>>> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
>>
>> This isn't going to work. The problem is the way you are using your
>> fragments you can end up with a memory corruption as the frame
>> headers that were updated by the stack may be reverted for any frames
>> received before the last frame was unmapped.  I ran into that issue
>> when I was doing page reuse with build_skb on the Intel drivers and I
>> suspect you will see the same issue.
>>
>
> Is this behaviour platform dependent? I tested this patch for more
> than a month
> and I did not face any issue. I ran normal traffic like ssh, nfs and
> iperf/netperf.
> Is there a special scenario when this could occur?

Yes it depends on the platform and IOMMU used.  For an example take a
loot at the SWIOTLB implementation.  I always assumed if I can work with
that when it is doing bounce buffers I can work with any IOMMU or platform.

>
> Will using DMA_BIDIRECTIONAL and sync_to_cpu & sync_to_device solve this?
> Each desc should have different dma address to write to. Can you
> explain me how
> this can happen?

No that won't help.  The issue is that when the page is mapped you
should not be updating any fields in the page until it is unmapped. 
Since you have multiple buffers mapped to a single page you should be
waiting until the entire page is unmapped.

>
>> The way to work around it is to receive the data in to the fragments,
>> and then pull the headers out and store them in a separate skb via
>> something similar to copy-break.  You can then track the fragments in
>> frags.
>>
>
> If I split the pkt header into another frame, is it guaranteed that
> stack will
> not modify the pkt data?

Paged fragments in the frags list use the page count to determine if
they can update it.  The problem is you cannot use a shared page as
skb->head if you plan to do any DMA mapping with it as it can cause
issues if you change any of the fields before it is unmapped.

>
> Thanks a lot for reviewing this patch.

No problem.  Just glad I saw this before you had to go though reverting
your stuff like I did.

- Alex
