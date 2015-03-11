From: Zoltan Kiss <zoltan.kiss@linaro.org>
Subject: Re: [Xen-devel] [PATCHv1 net] xen-netback: notify immediately after
 pushing Tx response.
Date: Wed, 11 Mar 2015 17:09:04 +0000
Message-ID: <550076B0.3090404@linaro.org>
References: <1426087679-13927-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: xen-devel@lists.xenproject.org, Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:41269 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470AbbCKRJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2015 13:09:08 -0400
Received: by wesw62 with SMTP id w62so10715092wes.8
        for <netdev@vger.kernel.org>; Wed, 11 Mar 2015 10:09:07 -0700 (PDT)
In-Reply-To: <1426087679-13927-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 11/03/15 15:27, David Vrabel wrote:
> This fixes a performance regression introduced by
> 7fbb9d8415d4a51cf542e87cf3a717a9f7e6aedc (xen-netback: release pending
> index before pushing Tx responses)
>
> Moving the notify outside of the spin locks means it can be delayed a
> long time (if the dealloc thread is descheduled or there is an
> interrupt or softirq).
>
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>
Reviewed-by: Zoltan Kiss <zoltan.kiss@linaro.org>
> ---
>   drivers/net/xen-netback/netback.c |   23 ++++++++++++-----------
>   1 file changed, 12 insertions(+), 11 deletions(-)
>
> diff --git a/drivers/net/xen-netback/netback.c b/drivers/net/xen-netback/netback.c
> index c4d68d7..7f8a466 100644
> --- a/drivers/net/xen-netback/netback.c
> +++ b/drivers/net/xen-netback/netback.c
> @@ -96,6 +96,7 @@ static void xenvif_idx_release(struct xenvif_queue *queue, u16 pending_idx,
>   static void make_tx_response(struct xenvif_queue *queue,
>   			     struct xen_netif_tx_request *txp,
>   			     s8       st);
> +static void push_tx_responses(struct xenvif_queue *queue);
>
>   static inline int tx_work_todo(struct xenvif_queue *queue);
>
> @@ -655,15 +656,10 @@ static void xenvif_tx_err(struct xenvif_queue *queue,
>   	unsigned long flags;
>
>   	do {
> -		int notify;
> -
>   		spin_lock_irqsave(&queue->response_lock, flags);
>   		make_tx_response(queue, txp, XEN_NETIF_RSP_ERROR);
> -		RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&queue->tx, notify);
> +		push_tx_responses(queue);
>   		spin_unlock_irqrestore(&queue->response_lock, flags);
> -		if (notify)
> -			notify_remote_via_irq(queue->tx_irq);
> -
>   		if (cons == end)
>   			break;
>   		txp = RING_GET_REQUEST(&queue->tx, cons++);
> @@ -1655,7 +1651,6 @@ static void xenvif_idx_release(struct xenvif_queue *queue, u16 pending_idx,
>   {
>   	struct pending_tx_info *pending_tx_info;
>   	pending_ring_idx_t index;
> -	int notify;
>   	unsigned long flags;
>
>   	pending_tx_info = &queue->pending_tx_info[pending_idx];
> @@ -1671,12 +1666,9 @@ static void xenvif_idx_release(struct xenvif_queue *queue, u16 pending_idx,
>   	index = pending_index(queue->pending_prod++);
>   	queue->pending_ring[index] = pending_idx;
>
> -	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&queue->tx, notify);
> +	push_tx_responses(queue);
>
>   	spin_unlock_irqrestore(&queue->response_lock, flags);
> -
> -	if (notify)
> -		notify_remote_via_irq(queue->tx_irq);
>   }
>
>
> @@ -1697,6 +1689,15 @@ static void make_tx_response(struct xenvif_queue *queue,
>   	queue->tx.rsp_prod_pvt = ++i;
>   }
>
> +static void push_tx_responses(struct xenvif_queue *queue)
> +{
> +	int notify;
> +
> +	RING_PUSH_RESPONSES_AND_CHECK_NOTIFY(&queue->tx, notify);
> +	if (notify)
> +		notify_remote_via_irq(queue->tx_irq);
> +}
> +
>   static struct xen_netif_rx_response *make_rx_response(struct xenvif_queue *queue,
>   					     u16      id,
>   					     s8       st,
>
