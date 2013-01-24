From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V6 1/3] vhost_net: correct error handling in
 vhost_net_set_backend()
Date: Thu, 24 Jan 2013 12:38:33 +0200
Message-ID: <20130124103833.GC9368@redhat.com>
References: <1358351078-58915-1-git-send-email-jasowang@redhat.com>
 <1358351078-58915-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:55191 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752824Ab3AXKeY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jan 2013 05:34:24 -0500
Content-Disposition: inline
In-Reply-To: <1358351078-58915-2-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 16, 2013 at 11:44:36PM +0800, Jason Wang wrote:
> Currently, when vhost_init_used() fails the sock refcnt and ubufs were
> leaked. Correct this by calling vhost_init_used() before assign ubufs and
> restore the oldsock when it fails.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/vhost/net.c |   16 +++++++++++-----
>  1 files changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index ebd08b2..d10ad6f 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -827,15 +827,16 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
>  			r = PTR_ERR(ubufs);
>  			goto err_ubufs;
>  		}
> -		oldubufs = vq->ubufs;
> -		vq->ubufs = ubufs;
> +
>  		vhost_net_disable_vq(n, vq);
>  		rcu_assign_pointer(vq->private_data, sock);
> -		vhost_net_enable_vq(n, vq);
> -
>  		r = vhost_init_used(vq);
>  		if (r)
> -			goto err_vq;
> +			goto err_used;
> +		vhost_net_enable_vq(n, vq);
> +
> +		oldubufs = vq->ubufs;
> +		vq->ubufs = ubufs;
>  
>  		n->tx_packets = 0;
>  		n->tx_zcopy_err = 0;
> @@ -859,6 +860,11 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
>  	mutex_unlock(&n->dev.mutex);
>  	return 0;
>  
> +err_used:
> +	rcu_assign_pointer(vq->private_data, oldsock);
> +	vhost_net_enable_vq(n, vq);
> +	if (ubufs)
> +		vhost_ubuf_put_and_wait(ubufs);
>  err_ubufs:
>  	fput(sock->file);
>  err_vq:
> -- 
> 1.7.1
