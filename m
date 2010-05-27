From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/3] vhost: fix to check the return value of
	copy_to/from_user() correctly
Date: Thu, 27 May 2010 13:48:30 +0300
Message-ID: <20100527104830.GA7278@redhat.com>
References: <20100527185803.0c0213a1.yoshikawa.takuya@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org
To: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25855 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751991Ab0E0Kwy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 06:52:54 -0400
Content-Disposition: inline
In-Reply-To: <20100527185803.0c0213a1.yoshikawa.takuya@oss.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 27, 2010 at 06:58:03PM +0900, Takuya Yoshikawa wrote:
> copy_to/from_user() returns the number of bytes that could not be copied.
> 
> So we need to check if it is not zero, and in that case, we should return
> the error number -EFAULT rather than directly return the return value from
> copy_to/from_user().
> 
> Signed-off-by: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>

Thanks, applied.

> ---
>  drivers/vhost/vhost.c |   51 ++++++++++++++++++++++++++----------------------
>  1 files changed, 28 insertions(+), 23 deletions(-)
> 
> diff --git a/drivers/vhost/vhost.c b/drivers/vhost/vhost.c
> index 5c9c657..9633a3c 100644
> --- a/drivers/vhost/vhost.c
> +++ b/drivers/vhost/vhost.c
> @@ -320,10 +320,8 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
>  {
>  	struct vhost_memory mem, *newmem, *oldmem;
>  	unsigned long size = offsetof(struct vhost_memory, regions);
> -	long r;
> -	r = copy_from_user(&mem, m, size);
> -	if (r)
> -		return r;
> +	if (copy_from_user(&mem, m, size))
> +		return -EFAULT;
>  	if (mem.padding)
>  		return -EOPNOTSUPP;
>  	if (mem.nregions > VHOST_MEMORY_MAX_NREGIONS)
> @@ -333,11 +331,10 @@ static long vhost_set_memory(struct vhost_dev *d, struct vhost_memory __user *m)
>  		return -ENOMEM;
>  
>  	memcpy(newmem, &mem, size);
> -	r = copy_from_user(newmem->regions, m->regions,
> -			   mem.nregions * sizeof *m->regions);
> -	if (r) {
> +	if (copy_from_user(newmem->regions, m->regions,
> +			   mem.nregions * sizeof *m->regions)) {
>  		kfree(newmem);
> -		return r;
> +		return -EFAULT;
>  	}
>  
>  	if (!memory_access_ok(d, newmem, vhost_has_feature(d, VHOST_F_LOG_ALL)))
> @@ -389,9 +386,10 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
>  			r = -EBUSY;
>  			break;
>  		}
> -		r = copy_from_user(&s, argp, sizeof s);
> -		if (r < 0)
> +		if (copy_from_user(&s, argp, sizeof s)) {
> +			r = -EFAULT;
>  			break;
> +		}
>  		if (!s.num || s.num > 0xffff || (s.num & (s.num - 1))) {
>  			r = -EINVAL;
>  			break;
> @@ -405,9 +403,10 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
>  			r = -EBUSY;
>  			break;
>  		}
> -		r = copy_from_user(&s, argp, sizeof s);
> -		if (r < 0)
> +		if (copy_from_user(&s, argp, sizeof s)) {
> +			r = -EFAULT;
>  			break;
> +		}
>  		if (s.num > 0xffff) {
>  			r = -EINVAL;
>  			break;
> @@ -419,12 +418,14 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
>  	case VHOST_GET_VRING_BASE:
>  		s.index = idx;
>  		s.num = vq->last_avail_idx;
> -		r = copy_to_user(argp, &s, sizeof s);
> +		if (copy_to_user(argp, &s, sizeof s))
> +			r = -EFAULT;
>  		break;
>  	case VHOST_SET_VRING_ADDR:
> -		r = copy_from_user(&a, argp, sizeof a);
> -		if (r < 0)
> +		if (copy_from_user(&a, argp, sizeof a)) {
> +			r = -EFAULT;
>  			break;
> +		}
>  		if (a.flags & ~(0x1 << VHOST_VRING_F_LOG)) {
>  			r = -EOPNOTSUPP;
>  			break;
> @@ -477,9 +478,10 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
>  		vq->used = (void __user *)(unsigned long)a.used_user_addr;
>  		break;
>  	case VHOST_SET_VRING_KICK:
> -		r = copy_from_user(&f, argp, sizeof f);
> -		if (r < 0)
> +		if (copy_from_user(&f, argp, sizeof f)) {
> +			r = -EFAULT;
>  			break;
> +		}
>  		eventfp = f.fd == -1 ? NULL : eventfd_fget(f.fd);
>  		if (IS_ERR(eventfp)) {
>  			r = PTR_ERR(eventfp);
> @@ -492,9 +494,10 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
>  			filep = eventfp;
>  		break;
>  	case VHOST_SET_VRING_CALL:
> -		r = copy_from_user(&f, argp, sizeof f);
> -		if (r < 0)
> +		if (copy_from_user(&f, argp, sizeof f)) {
> +			r = -EFAULT;
>  			break;
> +		}
>  		eventfp = f.fd == -1 ? NULL : eventfd_fget(f.fd);
>  		if (IS_ERR(eventfp)) {
>  			r = PTR_ERR(eventfp);
> @@ -510,9 +513,10 @@ static long vhost_set_vring(struct vhost_dev *d, int ioctl, void __user *argp)
>  			filep = eventfp;
>  		break;
>  	case VHOST_SET_VRING_ERR:
> -		r = copy_from_user(&f, argp, sizeof f);
> -		if (r < 0)
> +		if (copy_from_user(&f, argp, sizeof f)) {
> +			r = -EFAULT;
>  			break;
> +		}
>  		eventfp = f.fd == -1 ? NULL : eventfd_fget(f.fd);
>  		if (IS_ERR(eventfp)) {
>  			r = PTR_ERR(eventfp);
> @@ -575,9 +579,10 @@ long vhost_dev_ioctl(struct vhost_dev *d, unsigned int ioctl, unsigned long arg)
>  		r = vhost_set_memory(d, argp);
>  		break;
>  	case VHOST_SET_LOG_BASE:
> -		r = copy_from_user(&p, argp, sizeof p);
> -		if (r < 0)
> +		if (copy_from_user(&p, argp, sizeof p)) {
> +			r = -EFAULT;
>  			break;
> +		}
>  		if ((u64)(unsigned long)p != p) {
>  			r = -EFAULT;
>  			break;
> -- 
> 1.7.0.4
