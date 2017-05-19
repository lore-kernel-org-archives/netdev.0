From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next V5 0/9] vhost_net rx batch dequeuing
Date: Fri, 19 May 2017 14:27:16 +0800
Message-ID: <0d1dbf31-32c8-34b4-d8e8-48d04f2fc205@redhat.com>
References: <1494994485-12994-1-git-send-email-jasowang@redhat.com>
 <20170517235738-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170517235738-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年05月18日 04:59, Michael S. Tsirkin wrote:
> On Wed, May 17, 2017 at 12:14:36PM +0800, Jason Wang wrote:
>> This series tries to implement rx batching for vhost-net. This is done
>> by batching the dequeuing from skb_array which was exported by
>> underlayer socket and pass the sbk back through msg_control to finish
>> userspace copying. This is also the requirement for more batching
>> implemention on rx path.
>>
>> Tests shows at most 7.56% improvment bon rx pps on top of batch
>> zeroing and no obvious changes for TCP_STREAM/TCP_RR result.
>>
>> Please review.
>>
>> Thanks
> A surprisingly large gain for such as simple change.  It would be nice
> to understand better why this helps - in particular, does the optimal
> batch size change if ring is bigger or smaller?

Will test, just want to confirm. You mean virtio ring not tx_queue_len here?

Thanks

> But let's merge it
> meanwhile.
>
> Series:
>
> Acked-by: Michael S. Tsirkin <mst@redhat.com>
>
>
>
>> Changes from V4:
>> - drop batch zeroing patch
>> - renew the performance numbers
>> - move skb pointer array out of vhost_net structure
>>
>> Changes from V3:
>> - add batch zeroing patch to fix the build warnings
>>
>> Changes from V2:
>> - rebase to net-next HEAD
>> - use unconsume helpers to put skb back on releasing
>> - introduce and use vhost_net internal buffer helpers
>> - renew performance numbers on top of batch zeroing
>>
>> Changes from V1:
>> - switch to use for() in __ptr_ring_consume_batched()
>> - rename peek_head_len_batched() to fetch_skbs()
>> - use skb_array_consume_batched() instead of
>>    skb_array_consume_batched_bh() since no consumer run in bh
>> - drop the lockless peeking patch since skb_array could be resized, so
>>    it's not safe to call lockless one
>>
>> Jason Wang (8):
>>    skb_array: introduce skb_array_unconsume
>>    ptr_ring: introduce batch dequeuing
>>    skb_array: introduce batch dequeuing
>>    tun: export skb_array
>>    tap: export skb_array
>>    tun: support receiving skb through msg_control
>>    tap: support receiving skb from msg_control
>>    vhost_net: try batch dequing from skb array
>>
>> Michael S. Tsirkin (1):
>>    ptr_ring: add ptr_ring_unconsume
>>
>>   drivers/net/tap.c         |  25 +++++++--
>>   drivers/net/tun.c         |  31 ++++++++---
>>   drivers/vhost/net.c       | 128 +++++++++++++++++++++++++++++++++++++++++++---
>>   include/linux/if_tap.h    |   5 ++
>>   include/linux/if_tun.h    |   5 ++
>>   include/linux/ptr_ring.h  | 120 +++++++++++++++++++++++++++++++++++++++++++
>>   include/linux/skb_array.h |  31 +++++++++++
>>   7 files changed, 327 insertions(+), 18 deletions(-)
>>
>> -- 
>> 2.7.4
