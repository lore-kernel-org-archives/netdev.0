From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH net v2 2/3] xen-netback: don't stop dealloc
 kthread too early
Date: Mon, 11 Aug 2014 13:10:12 +0100
Message-ID: <53E8B2A4.9070008@citrix.com>
References: <1407515833-2550-1-git-send-email-wei.liu2@citrix.com> <1407515833-2550-3-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Ian Campbell <ian.campbell@citrix.com>,
	Zoltan Kiss <zoltan.kiss@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:52108 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752518AbaHKMKP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 08:10:15 -0400
In-Reply-To: <1407515833-2550-3-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/08/14 17:37, Wei Liu wrote:
> Reference count the number of packets in host stack, so that we don't
> stop the deallocation thread too early. If not, we can end up with
> xenvif_free permanently waiting for deallocation thread to unmap grefs.
[...]
> --- a/drivers/net/xen-netback/interface.c
> +++ b/drivers/net/xen-netback/interface.c
> @@ -43,6 +43,17 @@
>  #define XENVIF_QUEUE_LENGTH 32
>  #define XENVIF_NAPI_WEIGHT  64
>  
> +void xenvif_inc_inflight_packets(struct xenvif_queue *queue)
> +{
> +	atomic_inc(&queue->inflight_packets);
> +}
> +
> +void xenvif_dec_inflight_packets(struct xenvif_queue *queue)
> +{
> +	if (atomic_dec_and_test(&queue->inflight_packets))
> +		wake_up(&queue->inflight_wq);
> +}

You don't need these wrappers if you remove the inflight_wq (see below).

>  static inline void xenvif_stop_queue(struct xenvif_queue *queue)
>  {
>  	struct net_device *dev = queue->vif->dev;
> @@ -561,6 +572,8 @@ int xenvif_connect(struct xenvif_queue *queue, unsigned long tx_ring_ref,
>  
>  	init_waitqueue_head(&queue->wq);
>  	init_waitqueue_head(&queue->dealloc_wq);
> +	init_waitqueue_head(&queue->inflight_wq);
> +	atomic_set(&queue->inflight_packets, 0);
>  
>  	if (tx_evtchn == rx_evtchn) {
>  		/* feature-split-event-channels == 0 */
> @@ -687,6 +700,9 @@ void xenvif_disconnect(struct xenvif *vif)
>  			queue->task = NULL;
>  		}
>  
> +		wait_event(queue->inflight_wq,
> +			   atomic_read(&queue->inflight_packets) == 0);

Just make the dealloc task not stop unless it has deallocated all
outstanding requests.  There's no need for another wait queue here.

> +
>  		if (queue->dealloc_task) {
>  			kthread_stop(queue->dealloc_task);
>  			queue->dealloc_task = NULL;
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index 4734472..d2f0c7d7 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -107,6 +107,18 @@ static inline unsigned long idx_to_kaddr(struct xenvif_queue *queue,
>  #define callback_param(vif, pending_idx) \
>  	(vif->pending_tx_info[pending_idx].callback_struct)
>  
> +/* This function is used to set SKBTX_DEV_ZEROCOPY as well as
> + * increasing the inflight counter. We need to increase the inflight
> + * counter because core driver calls into xenvif_zerocopy_callback
> + * which calls xenvif_dec_inflight_packets.
> + */
> +static void set_skb_zerocopy(struct xenvif_queue *queue,
> +			     struct sk_buff *skb)
> +{
> +	skb_shinfo(skb)->tx_flags |= SKBTX_DEV_ZEROCOPY;
> +	xenvif_inc_inflight_packets(queue);
> +}

This name makes this look like a core function instead of a netback
specific one.

I would suggest a pair of functions:

xenvif_skb_zerocopy_prepare()
xenvif_skb_zerocopy_complete()

Or similar.

David
