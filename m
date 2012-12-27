From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH 1/2] vhost_net: correct error hanlding in
 vhost_net_set_backend()
Date: Thu, 27 Dec 2012 15:14:42 +0200
Message-ID: <20121227131442.GF20595@redhat.com>
References: <1356590360-32770-2-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9050 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752046Ab2L0NLb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Dec 2012 08:11:31 -0500
Content-Disposition: inline
In-Reply-To: <1356590360-32770-2-git-send-email-jasowang@redhat.com>
 <1356590360-32770-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 27, 2012 at 02:39:19PM +0800, Jason Wang wrote:
> Fix the leaking of oldubufs and fd refcnt when fail to initialized used ring.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
>  drivers/vhost/net.c |   14 +++++++++++---
>  1 files changed, 11 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/vhost/net.c b/drivers/vhost/net.c
> index ebd08b2..629d6b5 100644
> --- a/drivers/vhost/net.c
> +++ b/drivers/vhost/net.c
> @@ -834,8 +834,10 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
>  		vhost_net_enable_vq(n, vq);
>  
>  		r = vhost_init_used(vq);
> -		if (r)
> -			goto err_vq;
> +		if (r) {
> +			sock = NULL;
> +			goto err_used;
> +		}
>  
>  		n->tx_packets = 0;
>  		n->tx_zcopy_err = 0;
> @@ -859,8 +861,14 @@ static long vhost_net_set_backend(struct vhost_net *n, unsigned index, int fd)
>  	mutex_unlock(&n->dev.mutex);
>  	return 0;
>  
> +err_used:
> +	if (oldubufs)
> +		vhost_ubuf_put_and_wait(oldubufs);
> +	if (oldsock)
> +		fput(oldsock->file);
>  err_ubufs:
> -	fput(sock->file);
> +	if (sock)
> +		fput(sock->file);
>  err_vq:
>  	mutex_unlock(&vq->mutex);
>  err:

I think it's a real bug, but I don't see how the fix
makes sense.
We are returning an error, so we ideally
revert to the state before the faulty
operation. So this should put sock and ubufs,
not oldsock/oldubufs.


The best way is probably to change
vhost_init_used so that it gets private data
pointer as a parameter.

We can then call it before ubuf alloc.
You can then add err_used right after err_ubufs
with no extra logic.




-- 
MST
