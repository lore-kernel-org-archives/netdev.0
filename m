From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: [PATCH V6 net-next 1/5] xen-netback: Factor queue-specific data
 into queue struct.
Date: Fri, 14 Mar 2014 15:55:05 +0000
Message-ID: <1394812505.6442.128.camel@kazak.uk.xensource.com>
References: <1393847269-6981-1-git-send-email-andrew.bennieston@citrix.com>
	 <1393847269-6981-2-git-send-email-andrew.bennieston@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xenproject.org>, <wei.liu2@citrix.com>,
	<paul.durrant@citrix.com>, <netdev@vger.kernel.org>,
	<david.vrabel@citrix.com>
To: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:53942 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754471AbaCNP5W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Mar 2014 11:57:22 -0400
In-Reply-To: <1393847269-6981-2-git-send-email-andrew.bennieston@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-03-03 at 11:47 +0000, Andrew J. Bennieston wrote:
> From: "Andrew J. Bennieston" <andrew.bennieston@citrix.com>
> 
> In preparation for multi-queue support in xen-netback, move the
> queue-specific data from struct xenvif into struct xenvif_queue, and
> update the rest of the code to use this.
> 
> Also[...]
> 
> Finally,[...]

This is already quite a big patch, and I don't think the commit log
covers everything it changes/refactors, does it?

It's always a good idea to break these things apart but in particular
separating the mechanical stuff (s/vif/queue/g) from the non-mechanical
stuff, since the mechanical stuff is essentially trivial to review and
getting it out the way makes the non-mechanical stuff much easier to
check (or even spot).


> 
> Signed-off-by: Andrew J. Bennieston <andrew.bennieston@citrix.com>
> Reviewed-by: Paul Durrant <paul.durrant@citrix.com>
> ---
>  drivers/net/xen-netback/common.h    |   85 ++++--
>  drivers/net/xen-netback/interface.c |  329 ++++++++++++++--------
>  drivers/net/xen-netback/netback.c   |  530 ++++++++++++++++++-----------------
>  drivers/net/xen-netback/xenbus.c    |   87 ++++--
>  4 files changed, 608 insertions(+), 423 deletions(-)
> 
> diff --git a/drivers/net/xen-netback/common.h b/drivers/net/xen-netback/common.h
> index ae413a2..4176539 100644
> --- a/drivers/net/xen-netback/common.h
> +++ b/drivers/net/xen-netback/common.h
> @@ -108,17 +108,39 @@ struct xenvif_rx_meta {
>   */
>  #define MAX_GRANT_COPY_OPS (MAX_SKB_FRAGS * XEN_NETIF_RX_RING_SIZE)
>  
> -struct xenvif {
> -	/* Unique identifier for this interface. */
> -	domid_t          domid;
> -	unsigned int     handle;
> +/* Queue name is interface name with "-qNNN" appended */
> +#define QUEUE_NAME_SIZE (IFNAMSIZ + 6)

One more than necessary? Or does IFNAMSIZ not include the NULL? (I can't
figure out if it does or not!)

> [...] 
> -	/* This array is allocated seperately as it is large */
> -	struct gnttab_copy *grant_copy_op;
> +	struct gnttab_copy grant_copy_op[MAX_GRANT_COPY_OPS];

Is this deliberate? It seems like a retrograde step reverting parts of
ac3d5ac27735 "xen-netback: fix guest-receive-side array sizes" from Paul
(at least you are nuking a speeling erorr)

How does this series interact with Zoltan's foreign mapping one? Badly I
should imagine, are you going to rebase?

> +	/* First, check if there is only one queue to optimise the
> +	 * single-queue or old frontend scenario.
> +	 */
> +	if (vif->num_queues == 1) {
> +		queue_index = 0;
> +	} else {
> +		/* Use skb_get_hash to obtain an L4 hash if available */
> +		hash = skb_get_hash(skb);
> +		queue_index = (u16) (((u64)hash * vif->num_queues) >> 32);

No modulo num_queues here?

Is the multiply and shift from some best practice somewhere? Or else
what is it doing?


> +	/* Obtain the queue to be used to transmit this packet */
> +	index = skb_get_queue_mapping(skb);
> +	if (index >= vif->num_queues)
> +		index = 0; /* Fall back to queue 0 if out of range */

Is this actually allowed to happen?

Even if yes, not modulo num_queue so spread it around a bit?

>  static void xenvif_up(struct xenvif *vif)
>  {
> -	napi_enable(&vif->napi);
> -	enable_irq(vif->tx_irq);
> -	if (vif->tx_irq != vif->rx_irq)
> -		enable_irq(vif->rx_irq);
> -	xenvif_check_rx_xenvif(vif);
> +	struct xenvif_queue *queue = NULL;
> +	unsigned int queue_index;
> +
> +	for (queue_index = 0; queue_index < vif->num_queues; ++queue_index) {

This vif->num_queues -- is it the same as dev->num_tx_queues? Or areew
there differing concepts of queue around?

> +		queue = &vif->queues[queue_index];
> +		napi_enable(&queue->napi);
> +		enable_irq(queue->tx_irq);
> +		if (queue->tx_irq != queue->rx_irq)
> +			enable_irq(queue->rx_irq);
> +		xenvif_check_rx_xenvif(queue);
> +	}
>  }
>  
>  static void xenvif_down(struct xenvif *vif)
>  {
> -	napi_disable(&vif->napi);
> -	disable_irq(vif->tx_irq);
> -	if (vif->tx_irq != vif->rx_irq)
> -		disable_irq(vif->rx_irq);
> -	del_timer_sync(&vif->credit_timeout);
> +	struct xenvif_queue *queue = NULL;
> +	unsigned int queue_index;

Why unsigned?

> @@ -496,9 +497,30 @@ static void connect(struct backend_info *be)
>  		return;
>  	}
>  
> -	xen_net_read_rate(dev, &be->vif->credit_bytes,
> -			  &be->vif->credit_usec);
> -	be->vif->remaining_credit = be->vif->credit_bytes;
> +	xen_net_read_rate(dev, &credit_bytes, &credit_usec);
> +	read_xenbus_vif_flags(be);
> +
> +	be->vif->num_queues = 1;
> +	be->vif->queues = vzalloc(be->vif->num_queues *
> +			sizeof(struct xenvif_queue));
> +
> +	for (queue_index = 0; queue_index < be->vif->num_queues; ++queue_index) {
> +		queue = &be->vif->queues[queue_index];
> +		queue->vif = be->vif;
> +		queue->id = queue_index;
> +		snprintf(queue->name, sizeof(queue->name), "%s-q%u",
> +				be->vif->dev->name, queue->id);
> +
> +		xenvif_init_queue(queue);
> +
> +		queue->remaining_credit = credit_bytes;
> +
> +		err = connect_rings(be, queue);
> +		if (err)
> +			goto err;
> +	}
> +
> +	xenvif_carrier_on(be->vif);
>  
>  	unregister_hotplug_status_watch(be);
>  	err = xenbus_watch_pathfmt(dev, &be->hotplug_status_watch,
> @@ -507,18 +529,24 @@ static void connect(struct backend_info *be)
>  	if (!err)
>  		be->have_hotplug_status_watch = 1;
>  
> -	netif_wake_queue(be->vif->dev);
> +	netif_tx_wake_all_queues(be->vif->dev);
> +
> +	return;
> +
> +err:
> +	vfree(be->vif->queues);
> +	be->vif->queues = NULL;
> +	be->vif->num_queues = 0;
> +	return;

Do you not need to unwind the setup already done on the previous queues
before the failure?

>  }
>  
> 
> -static int connect_rings(struct backend_info *be)
> +static int connect_rings(struct backend_info *be, struct xenvif_queue *queue)
>  {
> -	struct xenvif *vif = be->vif;
>  	struct xenbus_device *dev = be->dev;
>  	unsigned long tx_ring_ref, rx_ring_ref;
> -	unsigned int tx_evtchn, rx_evtchn, rx_copy;
> +	unsigned int tx_evtchn, rx_evtchn;
>  	int err;
> -	int val;
>  
>  	err = xenbus_gather(XBT_NIL, dev->otherend,
>  			    "tx-ring-ref", "%lu", &tx_ring_ref,
> @@ -546,6 +574,27 @@ static int connect_rings(struct backend_info *be)
>  		rx_evtchn = tx_evtchn;
>  	}
>  
> +	/* Map the shared frame, irq etc. */
> +	err = xenvif_connect(queue, tx_ring_ref, rx_ring_ref,
> +			     tx_evtchn, rx_evtchn);
> +	if (err) {
> +		xenbus_dev_fatal(dev, err,
> +				 "mapping shared-frames %lu/%lu port tx %u rx %u",
> +				 tx_ring_ref, rx_ring_ref,
> +				 tx_evtchn, rx_evtchn);
> +		return err;
> +	}
> +
> +	return 0;
> +}
> +
