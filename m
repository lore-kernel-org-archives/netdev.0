From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC net-next] virtio_net: refill buffer right after being
 used
Date: Wed, 3 Aug 2011 23:26:48 +0300
Message-ID: <20110803202648.GA19501@redhat.com>
References: <1311979448.24300.28.camel@localhost.localdomain>
 <1311980131.24300.30.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org
To: Shirley Ma <mashirle@us.ibm.com>
Return-path: <kvm-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1311980131.24300.30.camel@localhost.localdomain>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 29, 2011 at 03:55:31PM -0700, Shirley Ma wrote:
> Resubmit it with a typo fix.
> 
> Signed-off-by: Shirley Ma <xma@us.ibm.com>
> ---
> 
> diff --git a/drivers/net/virtio_net.c b/drivers/net/virtio_net.c
> index 0c7321c..c8201d4 100644
> --- a/drivers/net/virtio_net.c
> +++ b/drivers/net/virtio_net.c
> @@ -429,6 +429,22 @@ static int add_recvbuf_mergeable(struct virtnet_info *vi, gfp_t gfp)
>  	return err;
>  }
>  
> +static int fill_one(struct virtnet_info *vi, gfp_t gfp)
> +{
> +	int err;
> +
> +	if (vi->mergeable_rx_bufs)
> +		err = add_recvbuf_mergeable(vi, gfp);
> +	else if (vi->big_packets)
> +		err = add_recvbuf_big(vi, gfp);
> +	else
> +		err = add_recvbuf_small(vi, gfp);
> +
> +	if (err >= 0)
> +		++vi->num;
> +	return err;
> +}
> +
>  /* Returns false if we couldn't fill entirely (OOM). */
>  static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
>  {
> @@ -436,17 +452,10 @@ static bool try_fill_recv(struct virtnet_info *vi, gfp_t gfp)
>  	bool oom;
>  
>  	do {
> -		if (vi->mergeable_rx_bufs)
> -			err = add_recvbuf_mergeable(vi, gfp);
> -		else if (vi->big_packets)
> -			err = add_recvbuf_big(vi, gfp);
> -		else
> -			err = add_recvbuf_small(vi, gfp);
> -
> +		err = fill_one(vi, gfp);
>  		oom = err == -ENOMEM;
>  		if (err < 0)
>  			break;
> -		++vi->num;
>  	} while (err > 0);
>  	if (unlikely(vi->num > vi->max))
>  		vi->max = vi->num;
> @@ -506,13 +515,13 @@ again:
>  		receive_buf(vi->dev, buf, len);
>  		--vi->num;
>  		received++;
> -	}
> -
> -	if (vi->num < vi->max / 2) {
> -		if (!try_fill_recv(vi, GFP_ATOMIC))
> +		if (fill_one(vi, GFP_ATOMIC) < 0)
>  			schedule_delayed_work(&vi->refill, 0);

If we get a large packet, we might add less that what we removed from
the ring.  Isn't this a problem?

>  	}
>  
> +	/* notify buffers are refilled */
> +	virtqueue_kick(vi->rvq);
> +
>  	/* Out of packets? */
>  	if (received < budget) {
>  		napi_complete(napi);
> 
> 

-- 
MST
