From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: Re: [PATCH net-next 2/2] xen-netback: Turn off the carrier if the
 guest is not able to receive
Date: Wed, 6 Aug 2014 20:18:44 +0100
Message-ID: <53E27F94.7000903@citrix.com>
References: <1407165658-20146-1-git-send-email-zoltan.kiss@citrix.com> <1407165658-20146-3-git-send-email-zoltan.kiss@citrix.com> <20140805124552.GE11230@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:53524 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932246AbaHFTSr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Aug 2014 15:18:47 -0400
In-Reply-To: <20140805124552.GE11230@zion.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/08/14 13:45, Wei Liu wrote:
> On Mon, Aug 04, 2014 at 04:20:58PM +0100, Zoltan Kiss wrote:
> [...]
>>   struct xenvif {
>> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
>> index fbdadb3..48a55cd 100644
>> --- a/drivers/net/xen-netback/interface.c
>> +++ b/drivers/net/xen-netback/interface.c
>> @@ -97,7 +101,16 @@ int xenvif_poll(struct napi_struct *napi, int budget)
>>   static irqreturn_t xenvif_rx_interrupt(int irq, void *dev_id)
>>   {
>>   	struct xenvif_queue *queue = dev_id;
>> +	struct netdev_queue *net_queue =
>> +		netdev_get_tx_queue(queue->vif->dev, queue->id);
>>
>> +	/* QUEUE_STATUS_RX_PURGE_EVENT is only set if either QDisc was off OR
>> +	 * the carrier went down and this queue was previously blocked
>> +	 */
>
> Could you change "blocked" to "stalled" so that the comment matches the
> code closely?
Ok

>> @@ -1935,6 +1934,75 @@ static void xenvif_start_queue(struct xenvif_queue *queue)
>>   		xenvif_wake_queue(queue);
>>   }
>>
>> +/* Only called from the queue's thread, it handles the situation when the guest
>> + * doesn't post enough requests on the receiving ring.
>> + * First xenvif_start_xmit disables QDisc and start a timer, and then either the
>> + * timer fires, or the guest send an interrupt after posting new request. If it
>> + * is the timer, the carrier is turned off here.
>> + * */
>
> Please remove that extra "*".
Ok

>> +static void xenvif_rx_purge_event(struct xenvif_queue *queue)
>> +{
>> +	/* Either the last unsuccesful skb or at least 1 slot should fit */
>> +	int needed = queue->rx_last_skb_slots ?
>> +		     queue->rx_last_skb_slots : 1;
>> +
>> +	/* It is assumed that if the guest post new slots after this, the RX
>> +	 * interrupt will set the QUEUE_STATUS_RX_PURGE_EVENT bit and wake up
>> +	 * the thread again
>> +	 */
>
> Basically in this state machine you have a tuple (RX_STALLED bit,
> PURGE_EVENT bit, carrier state). This whole state transaction is very
> scary, any chance you can draw a graph like the xenbus state machine in
> xenbus.c?
>
> I fear that after three month noone can easily understand this code
> unless he / she spends half a day reading the code. And without defining
> what state is legal it's very hard to tell what behavior is expected and
> what is not.
Ok

>
>> +	set_bit(QUEUE_STATUS_RX_STALLED, &queue->status);
>> +	if (!xenvif_rx_ring_slots_available(queue, needed)) {
>> +		rtnl_lock();
>> +		if (netif_carrier_ok(queue->vif->dev)) {
>> +			/* Timer fired and there are still no slots. Turn off
>> +			 * everything except the interrupts
>> +			 */
>> +			netif_carrier_off(queue->vif->dev);
>> +			skb_queue_purge(&queue->rx_queue);
>> +			queue->rx_last_skb_slots = 0;
>> +			if (net_ratelimit())
>> +				netdev_err(queue->vif->dev, "Carrier off due to lack of guest response on queue %d\n", queue->id);
>
> Line too long.
Ok


>> @@ -1944,8 +2012,12 @@ int xenvif_kthread_guest_rx(void *data)
>>   		wait_event_interruptible(queue->wq,
>>   					 rx_work_todo(queue) ||
>>   					 queue->vif->disabled ||
>> +					 test_bit(QUEUE_STATUS_RX_PURGE_EVENT, &queue->status) ||
>
> Line too long.
Ok

>
>>   					 kthread_should_stop());
>>
>> +		if (kthread_should_stop())
>> +			break;
>> +
>>   		/* This frontend is found to be rogue, disable it in
>>   		 * kthread context. Currently this is only set when
>>   		 * netback finds out frontend sends malformed packet,
>> @@ -1955,24 +2027,21 @@ int xenvif_kthread_guest_rx(void *data)
>>   		 */
>>   		if (unlikely(queue->vif->disabled && queue->id == 0))
>>   			xenvif_carrier_off(queue->vif);
>
> I think you also need to check vif->disabled flag in your following code
> so that you don't accidently re-enable a rogue vif in a queue whose id
> != 0.
Yes.
>
> Further more "disabled" can be transformed to a bit in vif->status.
> You can incorporate such change in your previous patch or a separate
> prerequisite patch.
Yes, I've already done that on my non-multiqueue branch.
>
>> -
>> -		if (kthread_should_stop())
>> -			break;
>> -
>> -		if (queue->rx_queue_purge) {
>> +		else if (unlikely(test_and_clear_bit(QUEUE_STATUS_RX_PURGE_EVENT,
>> +						     &queue->status))) {
>> +			xenvif_rx_purge_event(queue);
>> +		} else if (!netif_carrier_ok(queue->vif->dev)) {
>> +			/* Another queue stalled and turned the carrier off, so
>> +			 * purge the internal queue of queues which were not
>> +			 * blocked
>> +			 */
>
> "blocked" -> "stalled"?
Ok
>
> In theory even one queue stalls all other queues can still make
> progress, isn't it?
This patch makes sure that if a queue is stalled, none of the others can 
transmit, even if they would be able to do so. It is documented at the 
definition of QUEUE_STATUS_RX_STALLED.

>
> Wei.
>
