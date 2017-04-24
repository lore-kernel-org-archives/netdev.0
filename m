From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH RFC] ptr_ring: add ptr_ring_unconsume
Date: Mon, 24 Apr 2017 19:54:18 +0800
Message-ID: <21a19608-40be-38d4-9843-088a273fd71a@redhat.com>
References: <1492384496-22644-1-git-send-email-mst@redhat.com>
 <0defb746-3d4b-14b3-1ad7-82842048ebba@redhat.com>
 <20170424022711-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170424022711-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年04月24日 07:28, Michael S. Tsirkin wrote:
> On Tue, Apr 18, 2017 at 11:07:42AM +0800, Jason Wang wrote:
>>
>> On 2017年04月17日 07:19, Michael S. Tsirkin wrote:
>>> Applications that consume a batch of entries in one go
>>> can benefit from ability to return some of them back
>>> into the ring.
>>>
>>> Add an API for that - assuming there's space. If there's no space
>>> naturally we can't do this and have to drop entries, but this implies
>>> ring is full so we'd likely drop some anyway.
>>>
>>> Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
>>> ---
>>>
>>> Jason, in my mind the biggest issue with your batching patchset is the
>>> backet drops on disconnect.  This API will help avoid that in the common
>>> case.
>> Ok, I will rebase the series on top of this. (Though I don't think we care
>> the packet loss).
> E.g. I care - I often start sending packets to VM before it's
> fully booted. Several vhost resets might follow.

Ok.

>
>>> I would still prefer that we understand what's going on,
>> I try to reply in another thread, does it make sense?
>>
>>>    and I would
>>> like to know what's the smallest batch size that's still helpful,
>> Yes, I've replied in another thread, the result is:
>>
>>
>> no batching   1.88Mpps
>> RX_BATCH=1    1.93Mpps
>> RX_BATCH=4    2.11Mpps
>> RX_BATCH=16   2.14Mpps
>> RX_BATCH=64   2.25Mpps
>> RX_BATCH=256  2.18Mpps
> Essentially 4 is enough, other stuf looks more like noise
> to me. What about 2?

The numbers are pretty stable, so probably not noise. Retested on top of 
batch zeroing:

no  1.97Mpps
1   2.09Mpps
2   2.11Mpps
4   2.16Mpps
8   2.19Mpps
16  2.21Mpps
32  2.25Mpps
64  2.30Mpps
128 2.21Mpps
256 2.21Mpps

64 performs best.

Thanks

>
>>>    but
>>> I'm not going to block the patch on these grounds assuming packet drops
>>> are fixed.
>> Thanks a lot.
>>
>>> Lightly tested - this is on top of consumer batching patches.
>>>
>>> Thanks!
>>>
>>>    include/linux/ptr_ring.h | 57 ++++++++++++++++++++++++++++++++++++++++++++++++
>>>    1 file changed, 57 insertions(+)
>>>
>>> diff --git a/include/linux/ptr_ring.h b/include/linux/ptr_ring.h
>>> index 783e7f5..5fbeab4 100644
>>> --- a/include/linux/ptr_ring.h
>>> +++ b/include/linux/ptr_ring.h
>>> @@ -457,6 +457,63 @@ static inline int ptr_ring_init(struct ptr_ring *r, int size, gfp_t gfp)
>>>    	return 0;
>>>    }
>>> +/*
>>> + * Return entries into ring. Destroy entries that don't fit.
>>> + *
>>> + * Note: this is expected to be a rare slow path operation.
>>> + *
>>> + * Note: producer lock is nested within consumer lock, so if you
>>> + * resize you must make sure all uses nest correctly.
>>> + * In particular if you consume ring in interrupt or BH context, you must
>>> + * disable interrupts/BH when doing so.
>>> + */
>>> +static inline void ptr_ring_unconsume(struct ptr_ring *r, void **batch, int n,
>>> +				      void (*destroy)(void *))
>>> +{
>>> +	unsigned long flags;
>>> +	int head;
>>> +
>>> +	spin_lock_irqsave(&(r)->consumer_lock, flags);
>>> +	spin_lock(&(r)->producer_lock);
>>> +
>>> +	if (!r->size)
>>> +		goto done;
>>> +
>>> +	/*
>>> +	 * Clean out buffered entries (for simplicity). This way following code
>>> +	 * can test entries for NULL and if not assume they are valid.
>>> +	 */
>>> +	head = r->consumer_head - 1;
>>> +	while (likely(head >= r->consumer_tail))
>>> +		r->queue[head--] = NULL;
>>> +	r->consumer_tail = r->consumer_head;
>>> +
>>> +	/*
>>> +	 * Go over entries in batch, start moving head back and copy entries.
>>> +	 * Stop when we run into previously unconsumed entries.
>>> +	 */
>>> +	while (n--) {
>>> +		head = r->consumer_head - 1;
>>> +		if (head < 0)
>>> +			head = r->size - 1;
>>> +		if (r->queue[head]) {
>>> +			/* This batch entry will have to be destroyed. */
>>> +			++n;
>>> +			goto done;
>>> +		}
>>> +		r->queue[head] = batch[n];
>>> +		r->consumer_tail = r->consumer_head = head;
>>> +	}
>>> +
>>> +done:
>>> +	/* Destroy all entries left in the batch. */
>>> +	while (n--) {
>>> +		destroy(batch[n]);
>>> +	}
>>> +	spin_unlock(&(r)->producer_lock);
>>> +	spin_unlock_irqrestore(&(r)->consumer_lock, flags);
>>> +}
>>> +
>>>    static inline void **__ptr_ring_swap_queue(struct ptr_ring *r, void **queue,
>>>    					   int size, gfp_t gfp,
>>>    					   void (*destroy)(void *))
