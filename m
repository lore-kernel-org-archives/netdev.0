From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH V2 net-next 1/7] ptr_ring: introduce batch dequeuing
Date: Sat, 1 Apr 2017 13:14:10 +0800
Message-ID: <a5677aa1-9475-2a1b-25f4-51c19767b9da@redhat.com>
References: <1490858550-7763-1-git-send-email-jasowang@redhat.com>
 <1490858550-7763-2-git-send-email-jasowang@redhat.com>
 <20170330160403-mutt-send-email-mst@kernel.org>
 <941892c4-40f6-9dea-3922-fa02afdc8208@redhat.com>
 <20170331151619-mutt-send-email-mst@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170331151619-mutt-send-email-mst@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 2017年03月31日 22:31, Michael S. Tsirkin wrote:
> On Fri, Mar 31, 2017 at 11:52:24AM +0800, Jason Wang wrote:
>> On 2017年03月30日 21:53, Michael S. Tsirkin wrote:
>>> On Thu, Mar 30, 2017 at 03:22:24PM +0800, Jason Wang wrote:
>>>> This patch introduce a batched version of consuming, consumer can
>>>> dequeue more than one pointers from the ring at a time. We don't care
>>>> about the reorder of reading here so no need for compiler barrier.
>>>>
>>>> Signed-off-by: Jason Wang<jasowang@redhat.com>
>>>> ---
>>>>    include/linux/ptr_ring.h | 65 ++++++++++++++++++++++++++++++++++++++++++++++++
>>>>    1 file changed, 65 insertions(+)
>>>>
>>>> diff --git a/include/linux/ptr_ring.h b/include/linux/ptr_ring.h
>>>> index 6c70444..2be0f350 100644
>>>> --- a/include/linux/ptr_ring.h
>>>> +++ b/include/linux/ptr_ring.h
>>>> @@ -247,6 +247,22 @@ static inline void *__ptr_ring_consume(struct ptr_ring *r)
>>>>    	return ptr;
>>>>    }
>>>> +static inline int __ptr_ring_consume_batched(struct ptr_ring *r,
>>>> +					     void **array, int n)
>>> Can we use a shorter name? ptr_ring_consume_batch?
>> Ok, but at least we need to keep the prefix since there's a locked version.
>>
>>
>>
>>>> +{
>>>> +	void *ptr;
>>>> +	int i;
>>>> +
>>>> +	for (i = 0; i < n; i++) {
>>>> +		ptr = __ptr_ring_consume(r);
>>>> +		if (!ptr)
>>>> +			break;
>>>> +		array[i] = ptr;
>>>> +	}
>>>> +
>>>> +	return i;
>>>> +}
>>>> +
>>>>    /*
>>>>     * Note: resize (below) nests producer lock within consumer lock, so if you
>>>>     * call this in interrupt or BH context, you must disable interrupts/BH when
>>> I'd like to add a code comment here explaining why we don't
>>> care about cpu or compiler reordering. And I think the reason is
>>> in the way you use this API: in vhost it does not matter
>>> if you get less entries than present in the ring.
>>> That's ok but needs to be noted
>>> in a code comment so people use this function correctly.
>> Interesting, but I still think it's not necessary.
>>
>> If consumer is doing a busy polling, it will eventually get the entries. If
>> the consumer need notification from producer, it should drain the queue
>> which means it need enable notification before last try of consuming call,
>> otherwise it was a bug. The batch consuming function in this patch can
>> guarantee return at least one pointer if there's many, this looks sufficient
>> for the correctness?
>>
>> Thanks
> You ask for N entries but get N-1. This seems to imply the
> ring is now empty. Do we guarantee this?

I think consumer can not assume ring is empty consider producer can 
produce at the same time. It need enable notification and do another 
poll in this case.

Thanks
