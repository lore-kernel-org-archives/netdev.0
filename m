From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH net-next 2/6] virtio: introduce
	virtio_enable_cb_avail()
Date: Wed, 15 Oct 2014 18:58:15 +0800
Message-ID: <543E5347.7060106@redhat.com>
References: <1413357930-45302-1-git-send-email-jasowang@redhat.com>
	<1413357930-45302-3-git-send-email-jasowang@redhat.com>
	<20141015092849.GA25776@redhat.com> <543E4A23.7060903@redhat.com>
	<20141015104130.GH25776@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141015104130.GH25776@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 10/15/2014 06:41 PM, Michael S. Tsirkin wrote:
> On Wed, Oct 15, 2014 at 06:19:15PM +0800, Jason Wang wrote:
>> On 10/15/2014 05:28 PM, Michael S. Tsirkin wrote:
>>> On Wed, Oct 15, 2014 at 03:25:26PM +0800, Jason Wang wrote:
>>>> This patch introduces virtio_enable_cb_avail() to publish avail idx
>>>> and used event. This could be used by batched buffer submitting to
>>>> reduce the number of tx interrupts.
>>>>
>>>> Cc: Rusty Russell <rusty@rustcorp.com.au>
>>>> Cc: Michael S. Tsirkin <mst@redhat.com>
>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>>> ---
>>>>  drivers/virtio/virtio_ring.c |   22 ++++++++++++++++++++--
>>>>  include/linux/virtio.h       |    2 ++
>>>>  2 files changed, 22 insertions(+), 2 deletions(-)
>>>>
>>>> diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
>>>> index 1b3929f..d67fbf8 100644
>>>> --- a/drivers/virtio/virtio_ring.c
>>>> +++ b/drivers/virtio/virtio_ring.c
>>>> @@ -567,14 +567,32 @@ unsigned virtqueue_enable_cb_prepare(struct virtqueue *_vq)
>>>>  	 * entry. Always do both to keep code simple. */
>>>>  	vq->vring.avail->flags &= ~VRING_AVAIL_F_NO_INTERRUPT;
>>>>  	/* Make sure used event never go backwards */
>>>> -	if (!vring_need_event(vring_used_event(&vq->vring),
>>>> -			      vq->vring.avail->idx, last_used_idx))
>>>> +	if (vq->vring.avail->idx != vring_used_event(&vq->vring) &&
>>>> +	    !vring_need_event(vring_used_event(&vq->vring),
>>>> +			      vq->vring.avail->idx, last_used_idx)) {
>>>>  		vring_used_event(&vq->vring) = last_used_idx;
>>>> +	}
>>>>  	END_USE(vq);
>>>>  	return last_used_idx;
>>>>  }
>>>>  EXPORT_SYMBOL_GPL(virtqueue_enable_cb_prepare);
>>>>
>>> I see you are also changing virtqueue_enable_cb_prepare, why?
>> This is also used to prevent it from moving the used event backwards.
>> This may happens when we handle tx napi after we publish avail idx as
>> used event (virtqueue_enable_cb_avail() was called).
> So it's wrong exactly in the same way.
>
> But also, please document this stuff, don't put
> unrelated changes in a patch called "introduce
> virtqueue_enable_cb_avail".
>
>
>>>> +bool virtqueue_enable_cb_avail(struct virtqueue *_vq)
>>>> +{
>>>> +	struct vring_virtqueue *vq = to_vvq(_vq);
>>>> +	bool ret;
>>>> +
>>>> +	START_USE(vq);
>>>> +	vq->vring.avail->flags &= ~VRING_AVAIL_F_NO_INTERRUPT;
>>>> +	vring_used_event(&vq->vring) = vq->vring.avail->idx;
>>>> +	ret = vring_need_event(vq->vring.avail->idx,
>>>> +			       vq->last_used_idx, vq->vring.used->idx);
>>>> +	END_USE(vq);
>>>> +
>>>> +	return ret;
>>>> +}
>>>> +EXPORT_SYMBOL_GPL(virtqueue_enable_cb_avail);
>>>> +
>>>>  /**
>>>>   * virtqueue_poll - query pending used buffers
>>>>   * @vq: the struct virtqueue we're talking about.
>>> Could not figure out what this does.
>>> Please add documentation.
>>>
>> Sure, does something like below explain what does this function do?
>>
>> /**                                                                            
>>
>>  * virtqueue_enable_cb_avail - restart callbacks after
>> disable_cb.           
>>  * @vq: the struct virtqueue we're talking
>> about.                              
>>  *                                                                             
>>
>>  * This re-enables callbacks but hints to the other side to
>> delay              
>>  * interrupts all of the available buffers have been processed;         
>
> So this is like virtqueue_enable_cb_delayed but even more
> aggressive?
> I think it's too agressive: it's better to wake up guest
> after you are through most of buffers, but not all,
> so guest and host can work in parallel.

Note that:

- it was only used when there are still few of free slots (which is
greater than 2 + MAX_SKB_FRAGS)
- my patch keeps the free_old_xmit_skbs() in the beginning of
start_xmit(), so the tx skb reclaiming does not depends totally on tx
interrupt. If more packets comes, we'd expect some of them were freed in
ndo_start_xmit(). If not, finally we may trigger the
virtqueue_enable_cb_delayed().

So probably not as aggressive as it looks. I will do benchmark on this.
>
>
>>  * it returns "false" if there are at least one pending buffer in the
>> queue,          
>>  * to detect a possible race between the driver checking for more
>> work,        
>>  * and enabling
>> callbacks.                                                     
>>  *                                                                             
>>
>>  * Caller must ensure we don't call this with other
>> virtqueue                  
>>  * operations at the same time (except where
>> noted).                           
>>  */
>>
>>>> diff --git a/include/linux/virtio.h b/include/linux/virtio.h
>>>> index b46671e..bfaf058 100644
>>>> --- a/include/linux/virtio.h
>>>> +++ b/include/linux/virtio.h
>>>> @@ -65,6 +65,8 @@ bool virtqueue_enable_cb(struct virtqueue *vq);
>>>>  
>>>>  unsigned virtqueue_enable_cb_prepare(struct virtqueue *vq);
>>>>  
>>>> +bool virtqueue_enable_cb_avail(struct virtqueue *vq);
>>>> +
>>>>  bool virtqueue_poll(struct virtqueue *vq, unsigned);
>>>>  
>>>>  bool virtqueue_enable_cb_delayed(struct virtqueue *vq);
>>>> -- 
>>>> 1.7.1
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>> Please read the FAQ at  http://www.tux.org/lkml/
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
