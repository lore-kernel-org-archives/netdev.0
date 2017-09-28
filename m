From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next RFC 0/5] batched tx processing in vhost_net
Date: Thu, 28 Sep 2017 15:16:59 +0800
Message-ID: <030a3f75-a957-2502-a8cb-e7781827a61c@redhat.com>
References: <1506067355-5771-1-git-send-email-jasowang@redhat.com>
 <20170926164055-mutt-send-email-mst@kernel.org>
 <afb7cad9-d760-b4d7-ecc5-518442e061b1@redhat.com>
 <20170928012009-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kvm@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170928012009-mutt-send-email-mst@kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年09月28日 06:28, Michael S. Tsirkin wrote:
> On Wed, Sep 27, 2017 at 08:27:37AM +0800, Jason Wang wrote:
>>
>> On 2017年09月26日 21:45, Michael S. Tsirkin wrote:
>>> On Fri, Sep 22, 2017 at 04:02:30PM +0800, Jason Wang wrote:
>>>> Hi:
>>>>
>>>> This series tries to implement basic tx batched processing. This is
>>>> done by prefetching descriptor indices and update used ring in a
>>>> batch. This intends to speed up used ring updating and improve the
>>>> cache utilization.
>>> Interesting, thanks for the patches. So IIUC most of the gain is really
>>> overcoming some of the shortcomings of virtio 1.0 wrt cache utilization?
>> Yes.
>>
>> Actually, looks like batching in 1.1 is not as easy as in 1.0.
>>
>> In 1.0, we could do something like:
>>
>> batch update used ring by user copy_to_user()
>> smp_wmb()
>> update used_idx
>> In 1.1, we need more memory barriers, can't benefit from fast copy helpers?
>>
>> for () {
>>      update desc.addr
>>      smp_wmb()
>>      update desc.flag
>> }
> Yes but smp_wmb is a NOP on e.g. x86. We can switch to other types of
> barriers as well.

We need consider non x86 platforms as well. And we meet similar things 
on batch reading.

>    We do need to do the updates in order, so we might
> need new APIs for that to avoid re-doing the translation all the time.
>
> In 1.0 the last update is a cache miss always. You need batching to get
> less misses. In 1.1 you don't have it so fundamentally there is less
> need for batching. But batching does not always work.  DPDK guys (which
> batch things aggressively) already tried 1.1 and saw performance gains
> so we do not need to argue theoretically.

Do they test on non-x86 CPUs? And the prototype should be reviewed 
carefully since a bug can boost the performance in this case.

>
>
>
>>> Which is fair enough (1.0 is already deployed) but I would like to avoid
>>> making 1.1 support harder, and this patchset does this unfortunately,
>> I think the new APIs do not expose more internal data structure of virtio
>> than before? (vq->heads has already been used by vhost_net for years).
> For sure we might need to change vring_used_elem.
>
>> Consider the layout is re-designed completely, I don't see an easy method to
>> reuse current 1.0 API for 1.1.
> Current API just says you get buffers then you use them. It is not tied
> to actual separate used ring.

So do this patch I think? It introduces:

int vhost_prefetch_desc_indices(struct vhost_virtqueue *vq,
                 struct vring_used_elem *heads,
                 u16 num);
int vhost_add_used_idx(struct vhost_virtqueue *vq, int n);

There's nothing new exposed to vhost_net. (vring_used_elem has been used 
by net.c at many places without this patch).

>
>
>>> see comments on individual patches. I'm sure it can be addressed though.
>>>
>>>> Test shows about ~22% improvement in tx pss.
>>> Is this with or without tx napi in guest?
>> MoonGen is used in guest for better numbers.
>>
>> Thanks
> Not sure I understand. Did you set napi_tx to true or false?

MoonGen uses dpdk, so virtio-net pmd is used in guest. (See 
http://conferences.sigcomm.org/imc/2015/papers/p275.pdf)

Thanks

>
>>>> Please review.
>>>>
>>>> Jason Wang (5):
>>>>     vhost: split out ring head fetching logic
>>>>     vhost: introduce helper to prefetch desc index
>>>>     vhost: introduce vhost_add_used_idx()
>>>>     vhost_net: rename VHOST_RX_BATCH to VHOST_NET_BATCH
>>>>     vhost_net: basic tx virtqueue batched processing
>>>>
>>>>    drivers/vhost/net.c   | 221 ++++++++++++++++++++++++++++----------------------
>>>>    drivers/vhost/vhost.c | 165 +++++++++++++++++++++++++++++++------
>>>>    drivers/vhost/vhost.h |   9 ++
>>>>    3 files changed, 270 insertions(+), 125 deletions(-)
>>>>
>>>> -- 
>>>> 2.7.4
