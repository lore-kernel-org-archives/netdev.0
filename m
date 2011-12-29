From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH] virtio_net: use non-reentrant workqueue.
Date: Thu, 29 Dec 2011 22:33:14 +0200
Message-ID: <20111229203314.GB5051@redhat.com>
References: <87ehvogitg.fsf@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22087 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752421Ab1L2UbM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Dec 2011 15:31:12 -0500
Content-Disposition: inline
In-Reply-To: <87ehvogitg.fsf@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 29, 2011 at 01:55:47PM +1030, Rusty Russell wrote:
> Michael S. Tsirkin also noticed that we could run the refill work
> multiple CPUs: if we kick off a refill on one CPU and then on another,
> they would both manipulate the queue at the same time (they use
> napi_disable to avoid racing against the receive handler itself).
> 
> Tejun points out that this is what the WQ_NON_REENTRANT flag is for,
> and that there is a convenient system kthread we can use.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/virtio_net.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -507,7 +507,7 @@ static void refill_work(struct work_stru
>  	/* In theory, this can happen: if we don't get any buffers in
>  	 * we will *never* try to fill again. */
>  	if (still_empty)
> -		schedule_delayed_work(&vi->refill, HZ/2);
> +		queue_delayed_work(system_nrt_wq, &vi->refill, HZ/2);
>  }
>  
>  static int virtnet_poll(struct napi_struct *napi, int budget)
> @@ -526,7 +526,7 @@ again:
>  
>  	if (vi->num < vi->max / 2) {
>  		if (!try_fill_recv(vi, GFP_ATOMIC))
> -			schedule_delayed_work(&vi->refill, 0);
> +			queue_delayed_work(system_nrt_wq, &vi->refill, 0);
>  	}
>  
>  	/* Out of packets? */
> @@ -727,7 +727,7 @@ static int virtnet_open(struct net_devic
>  
>  	/* Make sure we have some buffers: if oom use wq. */
>  	if (!try_fill_recv(vi, GFP_KERNEL))
> -		schedule_delayed_work(&vi->refill, 0);
> +		queue_delayed_work(system_nrt_wq, &vi->refill, 0);
>  
>  	virtnet_napi_enable(vi);
>  	return 0;
