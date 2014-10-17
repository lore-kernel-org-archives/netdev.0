From: Jason Wang <jasowang@redhat.com>
Subject: Re: [RFC PATCH net-next 1/6] virtio: make sure used event never go
	backwards
Date: Fri, 17 Oct 2014 13:04:44 +0800
Message-ID: <5440A36C.8050700@redhat.com>
References: <1413357930-45302-1-git-send-email-jasowang@redhat.com>
	<1413357930-45302-2-git-send-email-jasowang@redhat.com>
	<20141015093432.GB25776@redhat.com> <543E48BF.4080502@redhat.com>
	<20141015103232.GG25776@redhat.com> <543E5019.9020507@redhat.com>
	<20141015113859.GA26918@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20141015113859.GA26918@redhat.com>
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

On 10/15/2014 07:38 PM, Michael S. Tsirkin wrote:
> On Wed, Oct 15, 2014 at 06:44:41PM +0800, Jason Wang wrote:
>> On 10/15/2014 06:32 PM, Michael S. Tsirkin wrote:
>>> On Wed, Oct 15, 2014 at 06:13:19PM +0800, Jason Wang wrote:
>>>> On 10/15/2014 05:34 PM, Michael S. Tsirkin wrote:
>>>>> On Wed, Oct 15, 2014 at 03:25:25PM +0800, Jason Wang wrote:
>>>>>> This patch checks the new event idx to make sure used event idx never
>>>>>> goes back. This is used to synchronize the calls between
>>>>>> virtqueue_enable_cb_delayed() and virtqueue_enable_cb().
>>>>>>
>>>>>> Cc: Rusty Russell <rusty@rustcorp.com.au>
>>>>>> Cc: Michael S. Tsirkin <mst@redhat.com>
>>>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>>>> the implication being that moving event idx back might cause some race
>>>>> condition?  
>>>> This will cause race condition when tx interrupt is enabled. Consider
>>>> the following cases
>>>>
>>>> 1) tx napi was scheduled
>>>> 2) start_xmit() call virtqueue_enable_cb_delayed() and disable cb, [used
>>>> event is vq->last_used_idx + 3/4 pendg bufs]
>>>> 3) tx napi enable the callback by virtqueue_enable_cb() [ used event is
>>>> vq->last_used_idx ]
>>>>  
>>>> After step 3, used event was moved back, unnecessary tx interrupt was
>>>> triggered.
>>> Well unnecessary interrupts are safe.
>> But it that is what we want to reduce.
> It's all about correctness. I don't think mixing enable_cb
> and enable_cb_delayed makes sense, let's just make
> virtio behave correctly if that happens, no need to
> optimize for that.

Then as you said, need document or add WARN_ON() or BUG() in case both
of the two are used.
>
>
>>> With your patch caller of virtqueue_enable_cb will not get an
>>> interrupt on the next buffer which is not safe.
>>>
>>> If you don't want an interrupt on the next buffer, don't
>>> call virtqueue_enable_cb.
>> So something like this patch should be done in virtio core somewhere
>> else. Virtio-net can not do this since it does not have the knowledge of
>> event index.
> Take a look at my patch - no calls to enable_cb, only
> enable_cb_delayed, so we should be fine.
>
>>>>> If yes but please describe the race explicitly.
>>>>> Is there a bug we need to fix on stable?
>>>> Looks not, current code does not have such race condition.
>>>>> Please also explicitly describe a configuration that causes event idx
>>>>> to go back.
>>>>>
>>>>> All this info should go in the commit log.
>>>> Will do this.
>>>>>> ---
>>>>>>  drivers/virtio/virtio_ring.c |    7 +++++--
>>>>>>  1 files changed, 5 insertions(+), 2 deletions(-)
>>>>>>
>>>>>> diff --git a/drivers/virtio/virtio_ring.c b/drivers/virtio/virtio_ring.c
>>>>>> index 3b1f89b..1b3929f 100644
>>>>>> --- a/drivers/virtio/virtio_ring.c
>>>>>> +++ b/drivers/virtio/virtio_ring.c
>>>>>> @@ -559,14 +559,17 @@ unsigned virtqueue_enable_cb_prepare(struct virtqueue *_vq)
>>>>>>  	u16 last_used_idx;
>>>>>>  
>>>>>>  	START_USE(vq);
>>>>>> -
>>>>>> +	last_used_idx = vq->last_used_idx;
>>>>>>  	/* We optimistically turn back on interrupts, then check if there was
>>>>>>  	 * more to do. */
>>>>>>  	/* Depending on the VIRTIO_RING_F_EVENT_IDX feature, we need to
>>>>>>  	 * either clear the flags bit or point the event index at the next
>>>>>>  	 * entry. Always do both to keep code simple. */
>>>>>>  	vq->vring.avail->flags &= ~VRING_AVAIL_F_NO_INTERRUPT;
>>>>>> -	vring_used_event(&vq->vring) = last_used_idx = vq->last_used_idx;
>>>>>> +	/* Make sure used event never go backwards */
>>>>> s/go/goes/
>>>>>
>>>>>> +	if (!vring_need_event(vring_used_event(&vq->vring),
>>>>>> +			      vq->vring.avail->idx, last_used_idx))
>>>>>> +		vring_used_event(&vq->vring) = last_used_idx;
>>>>> The result will be that driver will *not* get an interrupt
>>>>> on the next consumed buffer, which is likely not what driver
>>>>> intended when it called virtqueue_enable_cb.
>>>> This will only happen when we want to delay the interrupt for next few
>>>> consumed buffers (virtqueue_enable_cb_delayed() was called). For the
>>>> other case, vq->last_used_idx should be ahead of previous used event. Do
>>>> you see any other case?
>>> Call virtqueue_enable_cb_delayed, later call virtqueue_enable_cb.  If
>>> event index is not updated in virtqueue_enable_cb, driver will not get
>>> an interrupt on the next buffer.
>> This is just what we want I think. The interrupt was not lost but fired
>> after 3/4 pending buffers were consumed. Do you see any real issue on this?
> Yes, this violates the API. For example device might never
> consume the rest of buffers.

Then it should be a bug of device which is out of the control of guest.
If not, device might never also consume 3/4 rest of buffers.
>
>>>>> Instead, how about we simply document the requirement that drivers either
>>>>> always call virtqueue_enable_cb_delayed or virtqueue_enable_cb
>>>>> but not both?
>>>> We need call them both when tx interrupt is enabled I believe.
>>> Can you pls reply to my patch and document issues you see?
>>>
>> In the previous reply you said you're using
>> virtuqueue_enable_cb_delayed(), so no race in your patch.
> OK so you think my patch is also correct, but that yours gives better
> efficiency?
>

Need some benchmark to see the difference I think.
