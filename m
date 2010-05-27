From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 2/3] vhost-net: fix to check the return value of
	copy_to/from_user() correctly
Date: Thu, 27 May 2010 13:48:45 +0300
Message-ID: <20100527104845.GB7278@redhat.com>
References: <20100527185803.0c0213a1.yoshikawa.takuya@oss.ntt.co.jp> <20100527190158.4587a2db.yoshikawa.takuya@oss.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.osdl.org,
	netdev@vger.kernel.org
To: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64444 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755034Ab0E0KxI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 May 2010 06:53:08 -0400
Content-Disposition: inline
In-Reply-To: <20100527190158.4587a2db.yoshikawa.takuya@oss.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 27, 2010 at 07:01:58PM +0900, Takuya Yoshikawa wrote:
> copy_to/from_user() returns the number of bytes that could not be copied.
> 
> So we need to check if it is not zero, and in that case, we should return
> the error number -EFAULT rather than directly return the return value from
> copy_to/from_user().
> 
> Signed-off-by: Takuya Yoshikawa <yoshikawa.takuya@oss.ntt.co.jp>

Thanks, applied.

> ---
>  drivers/vhost/net.c |   14 +++++++-------
>  1 files changed, 7 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index aa88911..0f41c91 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -593,17 +593,17 @@ static long vhost_net_ioctl(struct file *f, unsigned int ioctl,
>  	int r;
>  	switch (ioctl) {
>  	case VHOST_NET_SET_BACKEND:
> -		r = copy_from_user(&backend, argp, sizeof backend);
> -		if (r < 0)
> -			return r;
> +		if (copy_from_user(&backend, argp, sizeof backend))
> +			return -EFAULT;
>  		return vhost_net_set_backend(n, backend.index, backend.fd);
>  	case VHOST_GET_FEATURES:
>  		features = VHOST_FEATURES;
> -		return copy_to_user(featurep, &features, sizeof features);
> +		if (copy_to_user(featurep, &features, sizeof features))
> +			return -EFAULT;
> +		return 0;
>  	case VHOST_SET_FEATURES:
> -		r = copy_from_user(&features, featurep, sizeof features);
> -		if (r < 0)
> -			return r;
> +		if (copy_from_user(&features, featurep, sizeof features))
> +			return -EFAULT;
>  		if (features & ~VHOST_FEATURES)
>  			return -EOPNOTSUPP;
>  		return vhost_net_set_features(n, features);
> -- 
> 1.7.0.4
