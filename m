From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 3/3] vhost_net: tx support batching
Date: Wed, 9 Nov 2016 22:05:21 +0200
Message-ID: <20161109215753-mutt-send-email-mst@kernel.org>
References: <1478677113-13126-1-git-send-email-jasowang@redhat.com>
 <1478677113-13126-3-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37890 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751618AbcKIUFW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 15:05:22 -0500
Content-Disposition: inline
In-Reply-To: <1478677113-13126-3-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 09, 2016 at 03:38:33PM +0800, Jason Wang wrote:
> This patch tries to utilize tuntap rx batching by peeking the tx
> virtqueue during transmission, if there's more available buffers in
> the virtqueue, set MSG_MORE flag for a hint for tuntap to batch the
> packets. The maximum number of batched tx packets were specified
> through a module parameter: tx_bached.
> 
> When use 16 as tx_batched:

When using

> 
> Pktgen test shows 16% on tx pps in guest.
> Netperf test does not show obvious regression.

Why doesn't netperf benefit?

> For safety, 1 were used as the default value for tx_batched.

s/were used/is used/

> Signed-off-by: Jason Wang <jasowang@redhat.com>

These tests unfortunately only run a single flow.
The concern would be whether this increases latency when
NIC is busy with other flows, so I think this is what
you need to test.


> ---
>  drivers/vhost/net.c   | 15 ++++++++++++++-
>  drivers/vhost/vhost.c |  1 +
>  drivers/vhost/vhost.h |  1 +
>  3 files changed, 16 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index 5dc128a..51c378e 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -35,6 +35,10 @@ module_param(experimental_zcopytx, int, 0444);
>  MODULE_PARM_DESC(experimental_zcopytx, "Enable Zero Copy TX;"
>  		                       " 1 -Enable; 0 - Disable");
>  
> +static int tx_batched = 1;
> +module_param(tx_batched, int, 0444);
> +MODULE_PARM_DESC(tx_batched, "Number of patches batched in TX");
> +
>  /* Max number of bytes transferred before requeueing the job.
>   * Using this limit prevents one virtqueue from starving others. */
>  #define VHOST_NET_WEIGHT 0x80000

I think we should do some tests and find a good default.



> @@ -454,6 +458,16 @@ static void handle_tx(struct vhost_net *net)
>  			msg.msg_control = NULL;
>  			ubufs = NULL;
>  		}
> +		total_len += len;
> +		if (vq->delayed < tx_batched &&
> +		    total_len < VHOST_NET_WEIGHT &&
> +		    !vhost_vq_avail_empty(&net->dev, vq)) {
> +			vq->delayed++;
> +			msg.msg_flags |= MSG_MORE;
> +		} else {
> +			vq->delayed = 0;
> +			msg.msg_flags &= ~MSG_MORE;
> +		}
>  		/* TODO: Check specific error and bomb out unless ENOBUFS? */
>  		err = sock->ops->sendmsg(sock, &msg, len);
>  		if (unlikely(err < 0)) {
> @@ -472,7 +486,6 @@ static void handle_tx(struct vhost_net *net)
>  			vhost_add_used_and_signal(&net->dev, vq, head, 0);
>  		else
>  			vhost_zerocopy_signal_used(net, vq);
> -		total_len += len;
>  		vhost_net_tx_packet(net);
>  		if (unlikely(total_len >= VHOST_NET_WEIGHT)) {
>  			vhost_poll_queue(&vq->poll);
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index fdf4cdf..bc362c7 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -311,6 +311,7 @@ static void vhost_vq_reset(struct vhost_dev *dev,
>  	vq->busyloop_timeout = 0;
>  	vq->umem = NULL;
>  	vq->iotlb = NULL;
> +	vq->delayed = 0;
>  }
>  
>  static int vhost_worker(void *data)
> diff --git a/drivers/vhost/vhost.h b/drivers/vhost/vhost.h
> index 78f3c5f..9f81a94 100644
> --- a/drivers/vhost/vhost.h
> +++ b/drivers/vhost/vhost.h
> @@ -141,6 +141,7 @@ struct vhost_virtqueue {
>  	bool user_be;
>  #endif
>  	u32 busyloop_timeout;
> +	int delayed;
>  };
>  
>  struct vhost_msg_node {
> -- 
> 2.7.4
