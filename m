From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH 2/4] virtio_net: return NETDEV_TX_BUSY instead of
 queueing an extra skb.
Date: Tue, 02 Jun 2009 09:07:30 +0100
Message-ID: <1243930050.9146.53.camel@blaa>
References: <200905292346.04815.rusty@rustcorp.com.au>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, virtualization@lists.linux-foundation.org,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33205 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754563AbZFBIIL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jun 2009 04:08:11 -0400
In-Reply-To: <200905292346.04815.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-05-29 at 23:46 +0930, Rusty Russell wrote:

> This effectively reverts 99ffc696d10b28580fe93441d627cf290ac4484c
> "virtio: wean net driver off NETDEV_TX_BUSY".
> 
> The complexity of queuing an skb (setting a tasklet to re-xmit) is
> questionable,

It certainly adds some subtle complexities to start_xmit() 

>  especially once we get rid of the other reason for the
> tasklet in the next patch.
> 
> If the skb won't fit in the tx queue, just return NETDEV_TX_BUSY.  It
> might be frowned upon, but it's common and not going away any time
> soon.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> Cc: Herbert Xu <herbert@gondor.apana.org.au>
> ---
>  drivers/net/virtio_net.c |   49 ++++++++++-------------------------------------
>  1 file changed, 11 insertions(+), 38 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
>  
> @@ -526,27 +517,14 @@ again:
>  	/* Free up any pending old buffers before queueing new ones. */
>  	free_old_xmit_skbs(vi);
>  
> -	/* If we has a buffer left over from last time, send it now. */
> -	if (unlikely(vi->last_xmit_skb) &&
> -	    xmit_skb(vi, vi->last_xmit_skb) != 0)
> -		goto stop_queue;
> +	/* Put new one in send queue and do transmit */
> +	__skb_queue_head(&vi->send, skb);
> +	if (likely(xmit_skb(vi, skb) == 0)) {
> +		vi->svq->vq_ops->kick(vi->svq);
> +		return NETDEV_TX_OK;
> +	}

Hmm, is it okay to leave the skb on the send queue if we return
NETDEV_TX_BUSY?

Cheers,
Mark.

