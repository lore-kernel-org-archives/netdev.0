From: Jason Wang <jasowang@redhat.com>
Subject: Re: virtio_net: Fix napi poll list corruption
Date: Mon, 22 Dec 2014 16:18:33 +0800
Message-ID: <5497D3D9.2070509@redhat.com>
References: <20141220002327.GA31975@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org,
	konrad.wilk@oracle.com, boris.ostrovsky@oracle.com,
	edumazet@google.com, "David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>,
	David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55559 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751110AbaLVISx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Dec 2014 03:18:53 -0500
In-Reply-To: <20141220002327.GA31975@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 12/20/2014 08:23 AM, Herbert Xu wrote:
> David Vrabel <david.vrabel@citrix.com> wrote:
>> After d75b1ade567ffab085e8adbbdacf0092d10cd09c (net: less interrupt
>> masking in NAPI) the napi instance is removed from the per-cpu list
>> prior to calling the n->poll(), and is only requeued if all of the
>> budget was used.  This inadvertently broke netfront because netfront
>> does not use NAPI correctly.
> A similar bug exists in virtio_net.
>
> -- >8 --
> The commit d75b1ade567ffab085e8adbbdacf0092d10cd09c (net: less
> interrupt masking in NAPI) breaks virtio_net in an insidious way.
>
> It is now required that if the entire budget is consumed when poll
> returns, the napi poll_list must remain empty.  However, like some
> other drivers virtio_net tries to do a last-ditch check and if
> there is more work it will call napi_schedule and then immediately
> process some of this new work.  Should the entire budget be consumed
> while processing such new work then we will violate the new caller
> contract.
>
> This patch fixes this by not touching any work when we reschedule
> in virtio_net.
>
> The worst part of this bug is that the list corruption causes other
> napi users to be moved off-list.  In my case I was chasing a stall
> in IPsec (IPsec uses netif_rx) and I only belatedly realised that it
> was virtio_net which caused the stall even though the virtio_net
> poll was still functioning perfectly after IPsec stalled.
>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index b8bd719..5ca9771 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -760,7 +760,6 @@ static int virtnet_poll(struct napi_struct *napi, int budget)
>  		container_of(napi, struct receive_queue, napi);
>  	unsigned int r, received = 0;
>  
> -again:
>  	received += virtnet_receive(rq, budget - received);
>  
>  	/* Out of packets? */
> @@ -771,7 +770,6 @@ again:
>  		    napi_schedule_prep(napi)) {
>  			virtqueue_disable_cb(rq->vq);
>  			__napi_schedule(napi);
> -			goto again;
>  		}
>  	}
>
> Cheers,

Acked-by: Jason Wang <jasowang@redhat.com>

btw, looks like at least caif_virtio has the same issue.
