From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net-next v3 2/2] enic: use netdev_dma_alloc
Date: Wed, 11 Mar 2015 14:57:39 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1503111428210.3394@ws.cisco>
References: <1426009384-11544-1-git-send-email-_govind@gmx.com> <1426009384-11544-3-git-send-email-_govind@gmx.com> <54FF50B0.3080900@redhat.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Govindarajulu Varadarajan <_govind@gmx.com>, davem@davemloft.net,
	netdev@vger.kernel.org, ssujith@cisco.com, benve@cisco.com
To: Alexander Duyck <alexander.h.duyck@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.15]:54293 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751012AbbCKJ1y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Mar 2015 05:27:54 -0400
In-Reply-To: <54FF50B0.3080900@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 10 Mar 2015, Alexander Duyck wrote:

>
> On 03/10/2015 10:43 AM, Govindarajulu Varadarajan wrote:
>> This patches uses dma cache skb allocator fot rx buffers.
>> 
>> netdev_dma_head is initialized per rq. All calls to netdev_dma_alloc_skb() 
>> and
>> netdev_dma_frag_unmap() happens in napi_poll and they are serialized.
>> 
>> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
>
> This isn't going to work. The problem is the way you are using your fragments 
> you can end up with a memory corruption as the frame headers that were 
> updated by the stack may be reverted for any frames received before the last 
> frame was unmapped.  I ran into that issue when I was doing page reuse with 
> build_skb on the Intel drivers and I suspect you will see the same issue.
>

Is this behaviour platform dependent? I tested this patch for more than a month
and I did not face any issue. I ran normal traffic like ssh, nfs and iperf/netperf.
Is there a special scenario when this could occur?

Will using DMA_BIDIRECTIONAL and sync_to_cpu & sync_to_device solve this?
Each desc should have different dma address to write to. Can you explain me how
this can happen?

> The way to work around it is to receive the data in to the fragments, and 
> then pull the headers out and store them in a separate skb via something 
> similar to copy-break.  You can then track the fragments in frags.
>

If I split the pkt header into another frame, is it guaranteed that stack will
not modify the pkt data?

Thanks a lot for reviewing this patch.
