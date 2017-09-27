From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 0/5] batched tx processing in vhost_net
Date: Wed, 27 Sep 2017 08:27:37 +0800
Message-ID: <afb7cad9-d760-b4d7-ecc5-518442e061b1@redhat.com>
References: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
 <20170926164055-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926164055-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年09月26日 21:45, Michael S. Tsirkin wrote:
> On Fri, Sep 22, 2017 at 04:02:30PM +0800, Jason Wang wrote:
>> Hi:
>>
>> This series tries to implement basic tx batched processing. This is
>> done by prefetching descriptor indices and update used ring in a
>> batch. This intends to speed up used ring updating and improve the
>> cache utilization.
> Interesting, thanks for the patches. So IIUC most of the gain is really
> overcoming some of the shortcomings of virtio 1.0 wrt cache utilization?

Yes.

Actually, looks like batching in 1.1 is not as easy as in 1.0.

In 1.0, we could do something like:

batch update used ring by user copy_to_user()
smp_wmb()
update used_idx

In 1.1, we need more memory barriers, can't benefit from fast copy helpers?

for () {
     update desc.addr
     smp_wmb()
     update desc.flag
}

>
> Which is fair enough (1.0 is already deployed) but I would like to avoid
> making 1.1 support harder, and this patchset does this unfortunately,

I think the new APIs do not expose more internal data structure of 
virtio than before? (vq->heads has already been used by vhost_net for 
years). Consider the layout is re-designed completely, I don't see an 
easy method to reuse current 1.0 API for 1.1.

> see comments on individual patches. I'm sure it can be addressed though.
>
>> Test shows about ~22% improvement in tx pss.
> Is this with or without tx napi in guest?

MoonGen is used in guest for better numbers.

Thanks

>
>> Please review.
>>
>> Jason Wang (5):
>>    vhost: split out ring head fetching logic
>>    vhost: introduce helper to prefetch desc index
>>    vhost: introduce vhost_add_used_idx()
>>    vhost_net: rename VHOST_RX_BATCH to VHOST_NET_BATCH
>>    vhost_net: basic tx virtqueue batched processing
>>
>>   drivers/vhost/net.c   | 221 ++++++++++++++++++++++++++++----------------------
>>   drivers/vhost/vhost.c | 165 +++++++++++++++++++++++++++++++------
>>   drivers/vhost/vhost.h |   9 ++
>>   3 files changed, 270 insertions(+), 125 deletions(-)
>>
>> -- 
>> 2.7.4
