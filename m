From: Edward Cree <ecree@solarflare.com>
Subject: Re: [PATCH] sfc: efx: add support for skb->xmit_more
Date: Mon, 13 Oct 2014 19:02:22 +0100
Message-ID: <543C13AE.80606@solarflare.com>
References: <1413219585-15854-1-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <nikolay@redhat.com>,
	<netdev@vger.kernel.org>, Shradha Shah <sshah@solarflare.com>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:37415 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753945AbaJMSFk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Oct 2014 14:05:40 -0400
In-Reply-To: <1413219585-15854-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13/10/14 17:59, Daniel Borkmann wrote:
> Add support for xmit_more batching: efx has BQL support, thus we need
> to only move the queue hang check before the hw tail pointer write
> and test for xmit_more bit resp. whether the queue/stack has stopped.
> Thanks to Nikolay Aleksandrov who had a Solarflare NIC to test!
I see two issues here.

1) The error handling path (labels dma_err: and err:) will unwind back
to tx_queue->insert_count, which (AFAICT) only gets updated by
efx_nic_push_buffers() (at least on EF10, where that calls
efx_ef10_tx_write()).
So if we transmit a bunch of skbs with xmit_more, then get an error, we
will unwind all the way back to the start, whereas (again, AFAICT) the
previous skbs were nicely completed and safe to send.
The unwind will leave us in a good state, but we'll have failed to send
some packets that there was nothing wrong with.
I think the appropriate fix for this would be to maintain two separate
insert_counts, as xmit_more means we can't conflate "last write pointer
pushed" and "write pointer at start of this skb" any longer.

2) I think we shouldn't do PIO when xmit_more is set - it's probably bad
for performance (though I haven't measured), and I'm not entirely
convinced it will behave correctly.  I think
efx_nic_tx_is_empty(tx_queue) will return true if we have xmit_more'd a
PIO packet, enabling us to potentially PIO the next packet as well, thus
overwriting the PIO buffer before the NIC's had a chance to read it.
I'm also unsure about what happens to TX Push (efx_ef10_push_tx_desc),
for similar reasons.
So I think TX PIO and TX Push both need to be suppressed when
skb->xmit_more (as a correctness issue), and should also be suppressed
on the !xmit_more skb that 'uncorks' a previous row of xmit_mores - as a
performance issue at the least, and for TX Push I'm also unsure about
the correctness (though I haven't worked that one through in detail).

Until these issues are addressed, I have to NAK this.  Tomorrow I'll try
to rustle up an rfc patch that handles these issues, unless someone
beats me to it.

-Edward

> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> Acked-by: Nikolay Aleksandrov <nikolay@redhat.com>
> Cc: Shradha Shah <sshah@solarflare.com>
> ---
>  drivers/net/ethernet/sfc/tx.c | 15 ++++++++-------
>  1 file changed, 8 insertions(+), 7 deletions(-)
>
> diff --git a/drivers/net/ethernet/sfc/tx.c b/drivers/net/ethernet/sfc/tx.c
> index 3206098..566432c 100644
> --- a/drivers/net/ethernet/sfc/tx.c
> +++ b/drivers/net/ethernet/sfc/tx.c
> @@ -439,13 +439,13 @@ finish_packet:
>  
>  	netdev_tx_sent_queue(tx_queue->core_txq, skb->len);
>  
> +	efx_tx_maybe_stop_queue(tx_queue);
> +
>  	/* Pass off to hardware */
> -	efx_nic_push_buffers(tx_queue);
> +	if (!skb->xmit_more || netif_xmit_stopped(tx_queue->core_txq))
> +		efx_nic_push_buffers(tx_queue);
>  
>  	tx_queue->tx_packets++;
> -
> -	efx_tx_maybe_stop_queue(tx_queue);
> -
>  	return NETDEV_TX_OK;
>  
>   dma_err:
> @@ -1308,11 +1308,12 @@ static int efx_enqueue_skb_tso(struct efx_tx_queue *tx_queue,
>  
>  	netdev_tx_sent_queue(tx_queue->core_txq, skb->len);
>  
> -	/* Pass off to hardware */
> -	efx_nic_push_buffers(tx_queue);
> -
>  	efx_tx_maybe_stop_queue(tx_queue);
>  
> +	/* Pass off to hardware */
> +	if (!skb->xmit_more || netif_xmit_stopped(tx_queue->core_txq))
> +		efx_nic_push_buffers(tx_queue);
> +
>  	tx_queue->tso_bursts++;
>  	return NETDEV_TX_OK;
>  
