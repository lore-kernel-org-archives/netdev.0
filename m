From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [patch 1/2] vhost: potential integer overflows
Date: Mon, 11 Oct 2010 18:26:39 +0100
Message-ID: <20101011172639.GL19804@ZenIV.linux.org.uk>
References: <20101011172256.GF5851@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
	Juan Quintela <quintela@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Rusty Russell <rusty@rustcorp.com.au>, kvm@vger.kernel.org,
	virtualization@lists.osdl.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:34186 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755697Ab0JKR0v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 13:26:51 -0400
Content-Disposition: inline
In-Reply-To: <20101011172256.GF5851@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 11, 2010 at 07:22:57PM +0200, Dan Carpenter wrote:
> I did an audit for potential integer overflows of values which get passed
> to access_ok() and here are the results.

FWIW, UINT_MAX is wrong here.  What you want is maximal size_t value.

> Signed-off-by: Dan Carpenter <error27@gmail.com>
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index dd3d6f7..c2aa12c 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -429,6 +429,14 @@ static int vq_access_ok(unsigned int num,
>  			struct vring_avail __user *avail,
>  			struct vring_used __user *used)
>  {
> +
> +	if (num > UINT_MAX / sizeof *desc)
> +		return 0;
> +	if (num > UINT_MAX / sizeof *avail->ring - sizeof *avail)
> +		return 0;
> +	if (num > UINT_MAX / sizeof *used->ring - sizeof *used)
> +		return 0;
> +
>  	return access_ok(VERIFY_READ, desc, num * sizeof *desc) &&
>  	       access_ok(VERIFY_READ, avail,
>  			 sizeof *avail + num * sizeof *avail->ring) &&
> @@ -447,6 +455,9 @@ int vhost_log_access_ok(struct vhost_dev *dev)
>  /* Caller should have vq mutex and device mutex */
>  static int vq_log_access_ok(struct vhost_virtqueue *vq, void __user *log_base)
>  {
> +	if (vq->num > UINT_MAX / sizeof *vq->used->ring - sizeof *vq->used)
> +		return 0;
> +
>  	return vq_memory_access_ok(log_base, vq->dev->memory,
>  			    vhost_has_feature(vq->dev, VHOST_F_LOG_ALL)) &&
>  		(!vq->log_used || log_access_ok(log_base, vq->log_addr,
> @@ -606,12 +617,17 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
>  			}
>  
>  			/* Also validate log access for used ring if enabled. */
> -			if ((a.flags & (0x1 << VHOST_VRING_F_LOG)) &&
> -			    !log_access_ok(vq->log_base, a.log_guest_addr,
> +			if (a.flags & (0x1 << VHOST_VRING_F_LOG)) {
> +				if (vq->num > UINT_MAX / sizeof *vq->used->ring - sizeof *vq->used) {
> +					r = -EINVAL;
> +					break;
> +				}
> +				if (!log_access_ok(vq->log_base, a.log_guest_addr,
>  					   sizeof *vq->used +
>  					   vq->num * sizeof *vq->used->ring)) {
> -				r = -EINVAL;
> -				break;
> +					r = -EINVAL;
> +					break;
> +				}
>  			}
>  		}
>  
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
