From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH RFC v5 net-next 2/6] virtio_ring: try to disable event
 index callbacks in virtqueue_disable_cb()
Date: Wed, 11 Feb 2015 06:03:36 +0008
Message-ID: <1423634136.4369.1@smtp.corp.redhat.com>
References: <1423471165-34243-1-git-send-email-jasowang@redhat.com>
	<1423471165-34243-3-git-send-email-jasowang@redhat.com>
	<20150210102417.GB9505@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, pagupta@redhat.com
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150210102417.GB9505@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, Feb 10, 2015 at 6:24 PM, Michael S. Tsirkin <mst@redhat.com> 
wrote:
> On Mon, Feb 09, 2015 at 03:39:21AM -0500, Jason Wang wrote:
>>  Currently, we do nothing to prevent the callbacks in
>>  virtqueue_disable_cb() when event index is used. This may cause
>>  spurious interrupts which may damage the performance. This patch 
>> tries
>>  to publish avail event as the used even to prevent the callbacks.
>>  
>>  Signed-off-by: Jason Wang <jasowang@redhat.com>
> 
> I'm surprised that this ever happens though.
> Normally we call this after getting an interrupt, and
> interrupts won't trigger again until the rings wraps around.

It was used to disable tx interrupt during start_xmit().
> 
> When I tested this, touching an extra cache line was more
> expensive.
> 
> Does this really reduce number of interrupts?
> Could you pls share some numbers with and without this patch?

Yes. It does reduce, see the following test results on multiple 
sessions of TCP_RR

Datacopy:
/size/sessions/+-throughput%/+-cpu%/+-per_cpu_throughput%/+-tx_interrupts%/
/1/50/+0.1/+0.7/-0.6/-72.3/
/64/50/+1.7/+1.0/+0.7/-72.2/
/256/50/+0.0/-0.8/+0.9/-72.4/

Zerocopy:
/size/sessions/+-throughput%/+-cpu%/+-per_cpu_throughput%/+-tx_interrupts%/
/1/50/+3.2/-1.3/+4.6/-71.7/
/64/50/+1.9/-0.2/+2.1/-70.8/
/256/50/+4.4/+0.6/+3.9/-84.2/

No obvious changes for stream rx and tx.
> 
> 
> 
>>  ---
>>   drivers/virtio/virtio_ring.c | 2 ++
>>   1 file changed, 2 insertions(+)
>>  
>>  diff --git a/drivers/virtio/virtio_ring.c 
>> b/drivers/virtio/virtio_ring.c
>>  index 545fed5..e9ffbfb 100644
>>  --- a/drivers/virtio/virtio_ring.c
>>  +++ b/drivers/virtio/virtio_ring.c
>>  @@ -539,6 +539,8 @@ void virtqueue_disable_cb(struct virtqueue *_vq)
>>   	struct vring_virtqueue *vq = to_vvq(_vq);
>>   
>>   	vq->vring.avail->flags |= cpu_to_virtio16(_vq->vdev, 
>> VRING_AVAIL_F_NO_INTERRUPT);
>>  +	vring_used_event(&vq->vring) = cpu_to_virtio16(_vq->vdev,
>>  +						       vq->vring.avail->idx);
> 
> Hmm in fact, can't this actually cause an extra interrupt
> when avail->idx is completed?

We need to try best to avoid any interrupt after this and 
virtqueue_disable_cb() were always need virtqueue_enable_cb() or 
virtqueue_enable_cb_delayed() afterwards. Those two function will check 
the pending used buffers and set a proper used event.
> 
> 
> I think that if you really can show disabling interrupts like this 
> helps, you should
> set some invalid value like 0xfffff, or move it back to 
> vq->vring.avail->idx - 1.
> No?

I tested avail->idx + vq.num but not obvious changes in the performance 
compared to just use avail->idx here. So 0xffff probably won't help 
much. Since we call virtqueue_enable_cb() or 
virtqueue_disable_cb_delayed() afterwards, it doesn't matter that 
whether avail->idx or avail->idx - 1 is used.
> 
> 
> 
> 
>>   }
>>   EXPORT_SYMBOL_GPL(virtqueue_disable_cb);
>>   
>>  -- 
>>  1.8.3.1
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
