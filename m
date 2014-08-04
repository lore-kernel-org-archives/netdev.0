From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH] xen-netback: Turn off the carrier if the
 guest is not able to receive
Date: Mon, 4 Aug 2014 14:35:32 +0100
Message-ID: <53DF8C24.6030709@citrix.com>
References: <1406749849-4356-1-git-send-email-zoltan.kiss@citrix.com> <1406749849-4356-2-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	David Vrabel <david.vrabel@citrix.com>,
	<linux-kernel@vger.kernel.org>
To: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1406749849-4356-2-git-send-email-zoltan.kiss@citrix.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30/07/14 20:50, Zoltan Kiss wrote:
> Currently when the guest is not able to receive more packets, qdisc layer starts
> a timer, and when it goes off, qdisc is started again to deliver a packet again.
> This is a very slow way to drain the queues, consumes unnecessary resources and
> slows down other guests shutdown.
> This patch change the behaviour by turning the carrier off when that timer
> fires, so all the packets are freed up which were stucked waiting for that vif.
> Instead of the rx_queue_purge bool it uses the VIF_STATUS_RX_PURGE_EVENT bit to
> signal the thread that either the timout happened or an RX interrupt arrived, so
> the thread can check what it should do. It also disables NAPI, so the guest
> can't transmit, but leaves the interrupts on, so it can resurrect.

I don't think you should disable NAPI, particularly since you have to
fiddle with the bits directly instead of usign the API to do so.

I looked at some hardware drivers and none of them disabled NAPI -- they
just allow it to naturally end once hardware queues are drained.

netback is a little different as a frontend could stop processing
to-guest packets but continue sending from-guest ones.  I don't see any
problem with allowing this.

> @@ -1955,24 +1955,78 @@ int xenvif_kthread_guest_rx(void *data)
>  		 */
>  		if (unlikely(queue->vif->disabled && queue->id == 0))
>  			xenvif_carrier_off(queue->vif);
> +		else if (unlikely(test_and_clear_bit(QUEUE_STATUS_RX_PURGE_EVENT,
> +						     &queue->status))) {
> +			/* Either the last unsuccesful skb or at least 1 slot
> +			 * should fit
> +			 */
> +			int needed = queue->rx_last_skb_slots ?
> +				     queue->rx_last_skb_slots : 1;
>  
> -		if (kthread_should_stop())
> -			break;
> -
> -		if (queue->rx_queue_purge) {
> +			/* It is assumed that if the guest post new
> +			 * slots after this, the RX interrupt will set
> +			 * the bit and wake up the thread again
> +			 */
> +			set_bit(QUEUE_STATUS_RX_STALLED, &queue->status);

This big if needs to go in a new function.

David
