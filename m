From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH v2 9/9] sfc: Support for byte queue limits
Date: Mon, 15 Aug 2011 19:36:35 +0100
Message-ID: <1313433395.2731.30.camel@bwh-desktop>
References: <alpine.DEB.2.00.1108072151500.13386@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:19497 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751873Ab1HOSgt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2011 14:36:49 -0400
In-Reply-To: <alpine.DEB.2.00.1108072151500.13386@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-08-07 at 21:53 -0700, Tom Herbert wrote:
> Changes to sfc to use byte queue limits.
> 
> Signed-off-by: Tom Herbert <therbert@google.com>
> ---
>  drivers/net/sfc/tx.c |   27 +++++++++++++++++++++------
>  1 files changed, 21 insertions(+), 6 deletions(-)
> 
> diff --git a/drivers/net/sfc/tx.c b/drivers/net/sfc/tx.c
> index 84eb99e..9aa4339 100644
> --- a/drivers/net/sfc/tx.c
> +++ b/drivers/net/sfc/tx.c
> @@ -31,7 +31,9 @@
>  #define EFX_TXQ_THRESHOLD(_efx) ((_efx)->txq_entries / 2u)
>  
>  static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
> -			       struct efx_tx_buffer *buffer)
> +			       struct efx_tx_buffer *buffer,
> +			       unsigned int *pkts_compl,
> +			       unsigned int *bytes_compl)
>  {
>  	if (buffer->unmap_len) {
>  		struct pci_dev *pci_dev = tx_queue->efx->pci_dev;
> @@ -48,6 +50,8 @@ static void efx_dequeue_buffer(struct efx_tx_queue *tx_queue,
>  	}
>  
>  	if (buffer->skb) {
> +		(*pkts_compl)++;
> +		(*bytes_compl) += buffer->skb->len;

We avoid using *buffer->skb on the completion path, as it is liklely to
be cache-cold.  I would prefer to add and subtract fragment lengths
(buffer->len) instead.  (This will also result in a slightly more
accurate estimate of the queue length when TSO is used.)

>  		dev_kfree_skb_any((struct sk_buff *) buffer->skb);
>  		buffer->skb = NULL;
>  		netif_vdbg(tx_queue->efx, tx_done, tx_queue->efx->net_dev,
> @@ -254,6 +258,8 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
>  	buffer->skb = skb;
>  	buffer->continuation = false;
>  
> +	netdev_tx_sent_queue(tx_queue->core_txq, 1, skb->len);
> +
>  	/* Pass off to hardware */
>  	efx_nic_push_buffers(tx_queue);
>  
> @@ -271,10 +277,11 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
>   unwind:
>  	/* Work backwards until we hit the original insert pointer value */
>  	while (tx_queue->insert_count != tx_queue->write_count) {
> +		unsigned int pkts_compl = 0, bytes_compl = 0;
>  		--tx_queue->insert_count;
>  		insert_ptr = tx_queue->insert_count & tx_queue->ptr_mask;
>  		buffer = &tx_queue->buffer[insert_ptr];
> -		efx_dequeue_buffer(tx_queue, buffer);
> +		efx_dequeue_buffer(tx_queue, buffer, &pkts_compl, &bytes_compl);
>  		buffer->len = 0;
>  	}
>  
> @@ -297,7 +304,9 @@ netdev_tx_t efx_enqueue_skb(struct efx_tx_queue *tx_queue, struct sk_buff *skb)
>   * specified index.
>   */
>  static void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
> -				unsigned int index)
> +				unsigned int index,
> +				unsigned int *pkts_compl,
> +				unsigned int *bytes_compl)
>  {
>  	struct efx_nic *efx = tx_queue->efx;
>  	unsigned int stop_index, read_ptr;
> @@ -315,7 +324,7 @@ static void efx_dequeue_buffers(struct efx_tx_queue *tx_queue,
>  			return;
>  		}
>  
> -		efx_dequeue_buffer(tx_queue, buffer);
> +		efx_dequeue_buffer(tx_queue, buffer, pkts_compl, bytes_compl);
[...]

Since efx_deqeueue_buffers() is the only caller of efx_dequeue_buffer()
that actually wants to count the completed packets & bytes, the counting
should be done here.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

