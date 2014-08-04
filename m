From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH] xen-netback: Turn off the carrier if the guest is not
 able to receive
Date: Mon, 4 Aug 2014 16:04:26 +0100
Message-ID: <53DFA0FA.4060505@citrix.com>
References: <1406749849-4356-1-git-send-email-zoltan.kiss@citrix.com> <1406749849-4356-2-git-send-email-zoltan.kiss@citrix.com> <20140801105227.GA17947@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140801105227.GA17947@zion.uk.xensource.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/08/14 11:52, Wei Liu wrote:
> On Wed, Jul 30, 2014 at 08:50:49PM +0100, Zoltan Kiss wrote:
>> --- a/drivers/net/xen-netback/common.h
>> +++ b/drivers/net/xen-netback/common.h
>> @@ -176,9 +176,9 @@ struct xenvif_queue { /* Per-queue data for xenvif */
>>   	struct xen_netif_rx_back_ring rx;
>>   	struct sk_buff_head rx_queue;
>>   	RING_IDX rx_last_skb_slots;
>> -	bool rx_queue_purge;
>> +	unsigned long status;
>>
>> -	struct timer_list wake_queue;
>> +	struct timer_list rx_stalled;
>>
>>   	struct gnttab_copy grant_copy_op[MAX_GRANT_COPY_OPS];
>>
>> @@ -198,9 +198,17 @@ struct xenvif_queue { /* Per-queue data for xenvif */
>>   	struct xenvif_stats stats;
>>   };
>>
>> -enum vif_state_bit_shift {
>> +enum state_bit_shift {
>
> Why change the name?
It's better to change this in the first patch. I've prepared this on a 
pre-multiqueue codebase, where these bits were for the whole vif, not 
for a queue.

>> +	 * reason for the carrier off, so it should kick the thread
>> +	 */
>
> I guess you're saying "so it should purge the queue"? I don't see
> xenvif_kick_thread guarded by QUEUE_STATUS_RX_STALLED but I do see
> QUEUE_STATUS_RX_PURGE_EVENT is set due to QUEUE_STATUS_RX_STALLED in rx
> interrupt handler.
>
>> +	QUEUE_STATUS_RX_STALLED
>
> What's the interaction of these two bits? I see in below code one is set
> under certain test result of the other in various places. It would be
> good if you can provide some detailed description on the control flow.
I'll extend that description. STALLED bit marks the queues which were 
blocked and brought the carrier off. Otherwise an another queue which is 
still operational would turn the carrier on even if the blocked ones are 
still blocked. That can cause a fast flapping of carrier. I think it's 
better if we don't turn the carrier on until at least one of the blocked 
queues comes back alive, but I'm open of other opinions.
Also, the conditions were wrong in the interrupt handler, I'll fix that too.

>> @@ -1955,24 +1955,78 @@ int xenvif_kthread_guest_rx(void *data)
>>   		 */
>>   		if (unlikely(queue->vif->disabled && queue->id == 0))
>>   			xenvif_carrier_off(queue->vif);
>> +		else if (unlikely(test_and_clear_bit(QUEUE_STATUS_RX_PURGE_EVENT,
>> +						     &queue->status))) {
>> +			/* Either the last unsuccesful skb or at least 1 slot
>> +			 * should fit
>> +			 */
>> +			int needed = queue->rx_last_skb_slots ?
>> +				     queue->rx_last_skb_slots : 1;
>>
>> -		if (kthread_should_stop())
>> -			break;
>> -
>
> Is it really necessary to have kthread_should_stop moved after queue
> purging logic? Is it better to leave it here so that we don't do any
> more unnecessary work and just quit?
I've just left where it was, after the check for vif->disable, but 
indeed we can move it before it.
>
>> -		if (queue->rx_queue_purge) {
>> +			/* It is assumed that if the guest post new
>> +			 * slots after this, the RX interrupt will set
>> +			 * the bit and wake up the thread again
>> +			 */
>
> This needs more detailed. Reading this comment and the "set_bit" in
> following is a bit confusing.
>
> I can tell after reading the code that "the bit" refers to
> QUEUE_STATUS_RX_PURGE_EVENT. The following line sets
> QUEUE_STATUS_RX_STALLED which has the effect of setting
> QUEUE_STATUS_RX_PURGE_EVENT in rx interrupt handler.
>
Ok
>> +			set_bit(QUEUE_STATUS_RX_STALLED, &queue->status);
>> +			if (!xenvif_rx_ring_slots_available(queue, needed)) {
>> +				rtnl_lock();
>> +				if (netif_carrier_ok(queue->vif->dev)) {
>> +					/* Timer fired and there are still no
>> +					 * slots. Turn off everything except the
>> +					 * interrupts
>> +					 */
>> +					netif_carrier_off(queue->vif->dev);
>> +					skb_queue_purge(&queue->rx_queue);
>> +					queue->rx_last_skb_slots = 0;
>> +					if (net_ratelimit())
>> +						netdev_err(queue->vif->dev, "Carrier off due to lack of guest response on queue %d\n", queue->id);
>> +				}
>> +				rtnl_unlock();
>> +			} else if (!netif_carrier_ok(queue->vif->dev)) {
>> +				unsigned int num_queues = queue->vif->num_queues;
>> +				unsigned int i;
>> +				/* The carrier was down, but an interrupt kicked
>> +				 * the thread again after new requests were
>> +				 * posted
>> +				 */
>> +				clear_bit(QUEUE_STATUS_RX_STALLED,
>> +					  &queue->status);
>> +				rtnl_lock();
>> +				netif_carrier_on(queue->vif->dev);
>> +				netif_tx_wake_all_queues(queue->vif->dev);
>> +				rtnl_unlock();
>> +
>> +				for (i = 0; i < num_queues; ++i) {
>> +					struct xenvif_queue *temp = &queue->vif->queues[i];
>> +					xenvif_napi_schedule_or_enable_events(temp);
>> +				}
>> +				if (net_ratelimit())
>> +					netdev_err(queue->vif->dev, "Carrier on again\n");
>> +				continue;
>> +			} else {
>> +				/* Queuing were stopped, but the guest posted
>> +				 * new requests
>> +				 */
>> +				clear_bit(QUEUE_STATUS_RX_STALLED,
>> +					  &queue->status);
>> +				del_timer_sync(&queue->rx_stalled);
>> +				xenvif_start_queue(queue);
>> +				continue;
>> +			}
>> +		} else if (!netif_carrier_ok(queue->vif->dev)) {
>> +			/* Another queue stalled and turned the carrier off, so
>> +			 * purge our internal queue
>> +			 */
>
> If I'm not misreading this branch doesn't have
> QUEUE_STATUS_RX_PURGE_EVENT set but you still pruge internal queues.
> So the QUEUE_STATUS_RX_PURGE_EVENT only controls QDISK purging? If so, I
> think you might need to say that clearly in comment above.
Nope. PURGE_EVENT is only set for the queues which were blocked in 
start_xmit, and STALLED bit makes sure that only they can turn the 
carrier on again. This branch is for the queues which are still 
functioning. QDisc were already purged when the carrier was turned off.
>
> I've tried my best to understand what's going on in this patch. AFAICT
> this looks like an improvement but not a bug fix to me. I need to
> justify the complexity introduced and the benefit gained but so far I
> don't have very good clue. I think it's better to have a 00/N patch to
> describe high level design and motive, as DaveM suggested.
Indeed, it's not trivial as there are a lot of racing possibilities due 
to multiqueue. I'll resend with more comments and explanation
>
> Wei.
>
>>   			skb_queue_purge(&queue->rx_queue);
>> -			queue->rx_queue_purge = false;
>> +			queue->rx_last_skb_slots = 0;
>>   		}
>>
>> +		if (kthread_should_stop())
>> +			break;
>> +
>>   		if (!skb_queue_empty(&queue->rx_queue))
>>   			xenvif_rx_action(queue);
>>
>> -		if (skb_queue_empty(&queue->rx_queue) &&
>> -		    xenvif_queue_stopped(queue)) {
>> -			del_timer_sync(&queue->wake_queue);
>> -			xenvif_start_queue(queue);
>> -		}
>> -
>>   		cond_resched();
>>   	}
>>
