From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 2/2] xen-netback: Turn off the carrier if the
 guest is not able to receive
Date: Tue, 5 Aug 2014 13:45:52 +0100
Message-ID: <20140805124552.GE11230@zion.uk.xensource.com>
References: <1407165658-20146-1-git-send-email-zoltan.kiss@citrix.com>
 <1407165658-20146-3-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<xen-devel@lists.xenproject.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1407165658-20146-3-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 04, 2014 at 04:20:58PM +0100, Zoltan Kiss wrote:
[...]
>  struct xenvif {
> diff --git a/drivers/net/xen-netback/interface.c b/drivers/net/xen-netback/interface.c
> index fbdadb3..48a55cd 100644
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -78,8 +78,12 @@ int xenvif_poll(struct napi_struct *napi, int budget)
>  	/* This vif is rogue, we pretend we've there is nothing to do
>  	 * for this vif to deschedule it from NAPI. But this interface
>  	 * will be turned off in thread context later.
> +	 * Also, if a guest doesn't post enough slots to receive data on one of
> +	 * its queues, the carrier goes down and NAPI is descheduled here so
> +	 * the guest can't send more packets until it's ready to receive.
>  	 */
> -	if (unlikely(queue->vif->disabled)) {
> +	if (unlikely(queue->vif->disabled ||
> +		     !netif_carrier_ok(queue->vif->dev))) {
>  		napi_complete(napi);
>  		return 0;
>  	}
> @@ -97,7 +101,16 @@ int xenvif_poll(struct napi_struct *napi, int budget)
>  static irqreturn_t xenvif_rx_interrupt(int irq, void *dev_id)
>  {
>  	struct xenvif_queue *queue = dev_id;
> +	struct netdev_queue *net_queue =
> +		netdev_get_tx_queue(queue->vif->dev, queue->id);
>  
> +	/* QUEUE_STATUS_RX_PURGE_EVENT is only set if either QDisc was off OR
> +	 * the carrier went down and this queue was previously blocked
> +	 */

Could you change "blocked" to "stalled" so that the comment matches the
code closely?

> +	if (unlikely(netif_tx_queue_stopped(net_queue) ||
> +		     (!netif_carrier_ok(queue->vif->dev) &&
> +		      test_bit(QUEUE_STATUS_RX_STALLED, &queue->status))))
> +		set_bit(QUEUE_STATUS_RX_PURGE_EVENT, &queue->status);
>  	xenvif_kick_thread(queue);
>  
>  	return IRQ_HANDLED;
> @@ -125,16 +138,14 @@ void xenvif_wake_queue(struct xenvif_queue *queue)
>  	netif_tx_wake_queue(netdev_get_tx_queue(dev, id));
>  }
>  
> -/* Callback to wake the queue and drain it on timeout */
> -static void xenvif_wake_queue_callback(unsigned long data)
> +/* Callback to wake the queue's thread and turn the carrier off on timeout */
> +static void xenvif_rx_stalled(unsigned long data)
>  {
>  	struct xenvif_queue *queue = (struct xenvif_queue *)data;
>  
>  	if (xenvif_queue_stopped(queue)) {
> -		netdev_err(queue->vif->dev, "draining TX queue\n");
> -		queue->rx_queue_purge = true;
> +		set_bit(QUEUE_STATUS_RX_PURGE_EVENT, &queue->status);
>  		xenvif_kick_thread(queue);
> -		xenvif_wake_queue(queue);
>  	}
>  }
>  
[...]
>  static inline int tx_work_todo(struct xenvif_queue *queue)
> @@ -1935,6 +1934,75 @@ static void xenvif_start_queue(struct xenvif_queue *queue)
>  		xenvif_wake_queue(queue);
>  }
>  
> +/* Only called from the queue's thread, it handles the situation when the guest
> + * doesn't post enough requests on the receiving ring.
> + * First xenvif_start_xmit disables QDisc and start a timer, and then either the
> + * timer fires, or the guest send an interrupt after posting new request. If it
> + * is the timer, the carrier is turned off here.
> + * */

Please remove that extra "*".

> +static void xenvif_rx_purge_event(struct xenvif_queue *queue)
> +{
> +	/* Either the last unsuccesful skb or at least 1 slot should fit */
> +	int needed = queue->rx_last_skb_slots ?
> +		     queue->rx_last_skb_slots : 1;
> +
> +	/* It is assumed that if the guest post new slots after this, the RX
> +	 * interrupt will set the QUEUE_STATUS_RX_PURGE_EVENT bit and wake up
> +	 * the thread again
> +	 */

Basically in this state machine you have a tuple (RX_STALLED bit,
PURGE_EVENT bit, carrier state). This whole state transaction is very
scary, any chance you can draw a graph like the xenbus state machine in
xenbus.c?

I fear that after three month noone can easily understand this code
unless he / she spends half a day reading the code. And without defining
what state is legal it's very hard to tell what behavior is expected and
what is not.

> +	set_bit(QUEUE_STATUS_RX_STALLED, &queue->status);
> +	if (!xenvif_rx_ring_slots_available(queue, needed)) {
> +		rtnl_lock();
> +		if (netif_carrier_ok(queue->vif->dev)) {
> +			/* Timer fired and there are still no slots. Turn off
> +			 * everything except the interrupts
> +			 */
> +			netif_carrier_off(queue->vif->dev);
> +			skb_queue_purge(&queue->rx_queue);
> +			queue->rx_last_skb_slots = 0;
> +			if (net_ratelimit())
> +				netdev_err(queue->vif->dev, "Carrier off due to lack of guest response on queue %d\n", queue->id);

Line too long.

> +		} else {
> +			/* Probably an another queue already turned the carrier
> +			 * off, make sure nothing is stucked in the internal
> +			 * queue of this queue
> +			 */
> +			skb_queue_purge(&queue->rx_queue);
> +			queue->rx_last_skb_slots = 0;
> +		}
> +		rtnl_unlock();
> +	} else if (!netif_carrier_ok(queue->vif->dev)) {
> +		unsigned int num_queues = queue->vif->num_queues;
> +		unsigned int i;
> +		/* The carrier was down, but an interrupt kicked
> +		 * the thread again after new requests were
> +		 * posted
> +		 */
> +		clear_bit(QUEUE_STATUS_RX_STALLED,
> +			  &queue->status);
> +		rtnl_lock();
> +		netif_carrier_on(queue->vif->dev);
> +		netif_tx_wake_all_queues(queue->vif->dev);
> +		rtnl_unlock();
> +
> +		for (i = 0; i < num_queues; i++) {
> +			struct xenvif_queue *temp = &queue->vif->queues[i];
> +
> +			xenvif_napi_schedule_or_enable_events(temp);
> +		}
> +		if (net_ratelimit())
> +			netdev_err(queue->vif->dev, "Carrier on again\n");
> +	} else {
> +		/* Queuing were stopped, but the guest posted
> +		 * new requests and sent an interrupt
> +		 */
> +		clear_bit(QUEUE_STATUS_RX_STALLED,
> +			  &queue->status);
> +		del_timer_sync(&queue->rx_stalled);
> +		xenvif_start_queue(queue);
> +	}
> +}
> +
>  int xenvif_kthread_guest_rx(void *data)
>  {
>  	struct xenvif_queue *queue = data;
> @@ -1944,8 +2012,12 @@ int xenvif_kthread_guest_rx(void *data)
>  		wait_event_interruptible(queue->wq,
>  					 rx_work_todo(queue) ||
>  					 queue->vif->disabled ||
> +					 test_bit(QUEUE_STATUS_RX_PURGE_EVENT, &queue->status) ||

Line too long.

>  					 kthread_should_stop());
>  
> +		if (kthread_should_stop())
> +			break;
> +
>  		/* This frontend is found to be rogue, disable it in
>  		 * kthread context. Currently this is only set when
>  		 * netback finds out frontend sends malformed packet,
> @@ -1955,24 +2027,21 @@ int xenvif_kthread_guest_rx(void *data)
>  		 */
>  		if (unlikely(queue->vif->disabled && queue->id == 0))
>  			xenvif_carrier_off(queue->vif);

I think you also need to check vif->disabled flag in your following code
so that you don't accidently re-enable a rogue vif in a queue whose id
!= 0.

Further more "disabled" can be transformed to a bit in vif->status.
You can incorporate such change in your previous patch or a separate
prerequisite patch.

> -
> -		if (kthread_should_stop())
> -			break;
> -
> -		if (queue->rx_queue_purge) {
> +		else if (unlikely(test_and_clear_bit(QUEUE_STATUS_RX_PURGE_EVENT,
> +						     &queue->status))) {
> +			xenvif_rx_purge_event(queue);
> +		} else if (!netif_carrier_ok(queue->vif->dev)) {
> +			/* Another queue stalled and turned the carrier off, so
> +			 * purge the internal queue of queues which were not
> +			 * blocked
> +			 */

"blocked" -> "stalled"?

In theory even one queue stalls all other queues can still make
progress, isn't it?

Wei.
