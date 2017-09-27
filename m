From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 5/5] vhost_net: basic tx virtqueue batched
 processing
Date: Wed, 27 Sep 2017 10:04:18 +0800
Message-ID: <16ea7512-d770-21ef-edb6-3ada51f08592@redhat.com>
References: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
 <1506067355-5771-6-git-send-email-jasowang@redhat.com>
 <20170926222223-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926222223-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年09月27日 03:25, Michael S. Tsirkin wrote:
> On Fri, Sep 22, 2017 at 04:02:35PM +0800, Jason Wang wrote:
>> This patch implements basic batched processing of tx virtqueue by
>> prefetching desc indices and updating used ring in a batch. For
>> non-zerocopy case, vq->heads were used for storing the prefetched
>> indices and updating used ring. It is also a requirement for doing
>> more batching on top. For zerocopy case and for simplicity, batched
>> processing were simply disabled by only fetching and processing one
>> descriptor at a time, this could be optimized in the future.
>>
>> XDP_DROP (without touching skb) on tun (with Moongen in guest) with
>> zercopy disabled:
>>
>> Intel(R) Xeon(R) CPU E5-2650 0 @ 2.00GHz:
>> Before: 3.20Mpps
>> After:  3.90Mpps (+22%)
>>
>> No differences were seen with zerocopy enabled.
>>
>> Signed-off-by: Jason Wang <jasowang@redhat.com>
> So where is the speedup coming from? I'd guess the ring is
> hot in cache, it's faster to access it in one go, then
> pass many packets to net stack. Is that right?
>
> Another possibility is better code cache locality.

Yes, I think the speed up comes from:

- less cache misses
- less cache line bounce when virtqueue is about to be full (guest is 
faster than host which is the case of MoonGen)
- less memory barriers
- possible faster copy speed by using copy_to_user() on modern CPUs

>
> So how about this patchset is refactored:
>
> 1. use existing APIs just first get packets then
>     transmit them all then use them all

Looks like current API can not get packets first, it only support get 
packet one by one (if you mean vhost_get_vq_desc()). And used ring 
updating may get more misses in this case.

> 2. add new APIs and move the loop into vhost core
>     for more speedups

I don't see any advantages, looks like just need some e.g callbacks in 
this case.

Thanks
