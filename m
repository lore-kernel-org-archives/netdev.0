From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH][VHOST] fix race with guest on multi-buffer used buffer
	updates
Date: Mon, 24 May 2010 13:17:10 +0300
Message-ID: <20100524101709.GA28349@redhat.com>
References: <1274374686.8492.12.camel@w-dls.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1638 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753632Ab0EXKV1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 May 2010 06:21:27 -0400
Content-Disposition: inline
In-Reply-To: <1274374686.8492.12.camel@w-dls.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 20, 2010 at 09:58:06AM -0700, David L Stevens wrote:
> [for Michael Tsirkin's vhost development git tree]
> 
> This patch fixes a race between guest and host when
> adding used buffers wraps the ring. Without it, guests
> can see partial packets before num_buffers is set in
> the vnet header.
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

Could you please explain what the race is?

> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 7f2568d..74790ab 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -1065,14 +1065,6 @@ static int __vhost_add_used_n(struct vhost_virtqueue *vq,
>  		vq_err(vq, "Failed to write used");
>  		return -EFAULT;
>  	}
> -	/* Make sure buffer is written before we update index. */
> -	smp_wmb();
> -	if (put_user(vq->last_used_idx + count, &vq->used->idx)) {
> -		vq_err(vq, "Failed to increment used idx");
> -		return -EFAULT;
> -	}
> -	if (unlikely(vq->log_used))
> -		vhost_log_used(vq, used);
>  	vq->last_used_idx += count;
>  	return 0;
>  }
> @@ -1093,7 +1085,17 @@ int vhost_add_used_n(struct vhost_virtqueue *vq, struct vring_used_elem *heads,
>  		heads += n;
>  		count -= n;
>  	}
> -	return __vhost_add_used_n(vq, heads, count);
> +	r = __vhost_add_used_n(vq, heads, count);
> +
> +	/* Make sure buffer is written before we update index. */
> +	smp_wmb();
> +	if (put_user(vq->last_used_idx, &vq->used->idx)) {
> +		vq_err(vq, "Failed to increment used idx");
> +		return -EFAULT;
> +	}
> +	if (unlikely(vq->log_used))
> +		vhost_log_used(vq, vq->used->ring + start);
> +	return r;
>  }
>  
>  /* This actually signals the guest, using eventfd. */
> 
