From: Jason Wang <jasowang@redhat.com>
Subject: Re: [net-next rfc V2 7/8] macvtap: add TUNSETQUEUE ioctl
Date: Wed, 05 Jun 2013 11:01:46 +0800
Message-ID: <51AEAA1A.7060202@redhat.com>
References: <1369994005-5943-1-git-send-email-jasowang@redhat.com> <1369994005-5943-8-git-send-email-jasowang@redhat.com> <20130602112228.GA10190@redhat.com> <51AC27BA.8050808@redhat.com> <20130603110923.GA11241@redhat.com> <51AD8130.1090807@redhat.com> <20130604070519.GE19433@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34593 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750791Ab3FEDCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Jun 2013 23:02:16 -0400
In-Reply-To: <20130604070519.GE19433@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/04/2013 03:05 PM, Michael S. Tsirkin wrote:
> On Tue, Jun 04, 2013 at 01:54:56PM +0800, Jason Wang wrote:
>> On 06/03/2013 07:09 PM, Michael S. Tsirkin wrote:
>>> On Mon, Jun 03, 2013 at 01:20:58PM +0800, Jason Wang wrote:
>>>> On 06/02/2013 07:22 PM, Michael S. Tsirkin wrote:
>>>>> On Fri, May 31, 2013 at 05:53:24PM +0800, Jason Wang wrote:
>>>>>> This patch adds TUNSETQUEUE ioctl to let userspace can temporarily disable or
>>>>>> enable a queue of macvtap. This is used to be compatible at API layer of tuntap
>>>>>> to simplify the userspace to manage the queues.
>>>>>>
>>>>>> This is done by split the taps array into three different areas:
>>>>>>
>>>>>> - [0, numvtaps) : enabled taps
>>>>>> - [numvtaps, numvtaps + numdisabled) : disabled taps
>>>>>> - [numvtaps + numdisabled, MAX_MAXVTAP_QUEUES) : unused slots
>>>>>>
>>>>>> When a tap were enabled and disabled, it was moved to another area.
>>>>>>
>>>>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
[...]
>>>>> +static int macvtap_disable_queue(struct macvtap_queue *q)
>>>>> +{
>>>>> +	struct macvlan_dev *vlan;
>>>>> +	int err = -EINVAL;
>>>>> +
>>>>> +	spin_lock(&macvtap_lock);
>>>>> +	vlan = rcu_dereference_protected(q->vlan,
>>>>> +					 lockdep_is_held(&macvtap_lock));
>>>>> +
>>>>> +	if (vlan) {
>>>>> +		int total = vlan->numvtaps + vlan->numdisabled;
>>>>> +		int index = q->queue_index;
>>>>> +
>>>>> +		BUG_ON(q->queue_index >= total);
>>>>> +		if (q->queue_index >= vlan->numvtaps)
>>>>> +			goto out;
>>>>> +
>>>>> +		err = 0;
>>>>> +		macvtap_swap_slot(vlan, index, total - 1);
>>>>> +		if (vlan->numdisabled)
>>>>> +			/* If there's disabled taps, the above swap will cause
>>>>> +			 * a disabled tap to be moved to enabled area. So
>>>>> +			 * another swap is needed to keep the right order.
>>>>> +			 */
>>>>> +			macvtap_swap_slot(vlan, index, vlan->numvtaps - 1);
>>>>> +
>>>>> +		/* make sure the pointers were seen before indices */
>>>>> +		wmb();
>>>>> Hmm this looks questionable. The code near rmb first
>>>>> checks numvtaps then dereferences the queue.
>>>>> So it might see a new queue but old value of numvtaps.
>>>> Right, barriers here were just best effort to reduce the possibility of
>>>> wrong queue selection when changing the number of queues.
>>> If this is an optimization, I'd say benchmark it and
>>> see if it helps performance.
>>>
>>> I don't expect it to have any effect really.
>>> In fact, the re-ordering of queues that this patch does
>>> is likely to cause packet reorering and hurt performance
>>> more.
>> Yes, so I will remove the barriers.
>>
>> The re-ordering seems to be the easiest way to do fast lookup of active
>> queues. We could use indirection to avoid the re-ordering of queues,
>> it's hard to eliminate OOO packets. If we don't depends on changing the
>> number of queues frequently, we're ok.
>>> I'm guessing the only thing we need for correctness
>>> is ACCESS_ONCE on numvtaps?
>> Did't see how it help.
> For this loop:
>                while (unlikely(rxq >= numvtaps))
>                         rxq -= numvtaps;
>
> you better read numvtaps with ACCESS_ONCE otherwise
> compiler can re-read numvtaps and it would
> change during loop execution.
> rxq can then become negative.
>

I get your meaning, looks like tun should be fixed as well.

Thanks
