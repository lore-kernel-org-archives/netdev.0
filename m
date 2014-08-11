From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sunvnet: Fixes to avoid soft lockup in sunvnet
Date: Mon, 11 Aug 2014 13:56:42 -0700 (PDT)
Message-ID: <20140811.135642.2149726326739266234.davem@davemloft.net>
References: <20140810194807.GB5222@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: raghuram.kothakota@oracle.com, netdev@vger.kernel.org
To: sowmini.varadhan@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932130AbaHKU4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 16:56:47 -0400
In-Reply-To: <20140810194807.GB5222@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Date: Sun, 10 Aug 2014 15:48:07 -0400

> 
> 1. ldc_rx -> vnet_rx -> .. -> vnet_walk_rx->vnet_send_ack should not
>    spin into an infinite loop waiting  EAGAIN to lift.
> 
>    The sender could have sent us a burst, and gone to lunch without
>    doing any more ldc_read()'s. That should not cause the receiver to
>    loop infinitely till soft-lockup kicks in.
> 
> 2. Similarly __vnet_tx_trigger should only loop on EAGAIN a finite
>    number of times. The caller (vnet_start_xmit()) already has code
>    to reset the dring state and bail on errors from __vnet_tx_trigger()
> 
> 3. No need to ask for an ack with every vnet_start_xmit()- the single
>    ACK with DRING_STOPPED is sufficient for the protocol, and we free
>    the sk_buff in vnet_start_xmit itself, so we dont need an ACK back.
> 
> 4. At the tail of vnet_event(), if we hit the maybe_tx_wakeup()
>    condition, we try to take the netif_tx_lock() in the
>    recv-interrupt-context and can deadlock with dev_watchdog().
>    Two changes to fix this:
>    (a) The contents of maybe_tx_wakeup() should be moved into
>        vnet_tx_timeout
>    (b) vnet_event() should kick off a tasklet that triggers
>        netif_wake_queue()
> 
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> Acked-by: Raghuram Kothakota <raghuram.kothakota@oracle.com>

Please don't fix multiple things in one huge patch, split up the
changes into separate easily reviewed patches.

> +/*
> + * Heuristic for the number of times to exponentially backoff and
> + * retry sending an LDC trigger when EAGAIN is encountered
> + */

In the networking, comments are formatted:

/* Like
 * this.
 */

> +			printk(KERN_INFO 
> +			    "ECONNRESET %x:%x:%x:%x:%x:%x\n",
> +			    port->raddr[0], port->raddr[1],
> +			    port->raddr[2], port->raddr[3],
> +			    port->raddr[4], port->raddr[5]);

This is not indented correctly.  The second and subsequent lines
of the printk() function call should start at exactly the first
column after the openning parenthesis of the function call.

> +	/*
> +	 * Kick off a tasklet to wake the queue.  We cannot call 
> +	 * maybe_tx_wakeup directly here because we could deadlock on
> +	 * netif_tx_lock() with dev_watchdog()
> +	 */

Comment formatting.

> +	/*
> +	 * We don't rely on the ACKs to free the skb in vnet_start_xmit(),
> +	 * thus it is safe to not set VIO_ACK_ENABLE for each transmission:
> +	 * the protocol itself does not require it as long as the peer
> +	 * sends a VIO_SUBTYPE_ACK for VIO_DRING_STOPPED. 
> +	 *
> +	 * An ACK for every packet in the ring is expensive as the
> +	 * sending of LDC messages is slow and affects performance.
> +	 */

Likewise.
